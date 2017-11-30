__precompile__(true)

module VarianceCovarianceEstimators

using StatsBase
import StatsBase: vcov

## Abstract and Structs
abstract type AbstractVCE end
abstract type AbstractHCVCE <: AbstractVCE end
abstract type AbstractCRVCE <: AbstractVCE end
struct OLS <: AbstractVCE end
struct HC1 <: AbstractHCVCE end
struct HC2 <: AbstractHCVCE end
struct HC3 <: AbstractHCVCE end
struct CRVE1 <: AbstractCRVCE end
struct CRVE2 <: AbstractCRVCE end
struct CRVE3 <: AbstractCRVCE end
VCESymHCMapper = Dict([(:OLS, OLS()),(:HC1, HC1()),(:HC2, HC2()),(:HC3, HC3())])
VCESymCRMapper = Dict([(:HC1, CRVE1()), (:HC2, CRVE2()), (:HC3, CRVE3())])

## Methods packages should implement
function bread(obj::RegressionModel)
	mm = modelmatrix(obj)
	output = inv(cholfact!(mm.'mm))
	return output
end
clusters(obj::RegressionModel) = Vector{Vector{Int64}}()

## API
function vcov(model::RegressionModel, estimator::Symbol)
    groups = clusters(model)
    if isempty(groups)
        @assert haskey(VCESymHCMapper, estimator) (@sprintf "%s is not a valid variance covariance estimator. Valid estimators are: OLS, HC1, HC2, HC3." estimator)
        output = vcov(model, get(VCESymHCMapper, estimator, OLS()))
    else
        @assert haskey(VCESymCRMapper, estimator) (@sprintf "%s is not a valid cluster robust variance covariance estimator. Valid estimators are: HC1, HC2, HC3." estimator)
        output = vcov(model, get(VCESymCRMapper, estimator, HC1()), groups)
    end
    return output
end

## Core Methods
vcov(model::RegressionModel, estimator::OLS) = deviance(model) * bread(model)
function vcov(model::RegressionModel, estimator::AbstractHCVCE)
    mm = modelmatrix(model)
    Bread = bread(model)
    û = residuals(model)
    output = Bread * meat(estimator, mm, û) * Bread
    if isa(estimator, HC1)
        output .*= nobs(model) / dof_residual(model)
    end
    return output
end
function vcov(model::RegressionModel,
						estimator::AbstractCRVCE,
						Clusters::Vector{Vector{Vector{T}}}) where T <: Integer
    mm = modelmatrix(model)
    Bread = bread(model)
    û = residuals(model)
    G = BitMatrix(zeros(size(mm, 1), size(mm, 1)))
    for dimension ∈ Clusters
        for level ∈ dimension
            for comparison ∈ dimension
                values = intersect(level, comparison)
                G[values, values] = true
            end
        end
    end
    if isa(estimator, CRVE2) | isa(estimator, CRVE3)
        h = Dict{Vector{Int64},Vector{Float64}}()
        output = zeros(length(û))
        for each ∈ 1:size(G, 1)
            group = find(G[:,each])
            P = 1 - first(get!(h, group, diag(mm[group,:] * pinv(mm[group,:])))[findfirst(equalto(each), group)])
            output[each] = P
        end
        if isa(estimator, CRVE2)
            û = û ./ sqrt.(output)
        elseif isa(estimator, CRVE3)
            û = û ./ output
        end
    end
    output = Bread * mm.' * (û * û.' .* G) * mm * Bread
    # g = length(unique(map(col -> find(G[:,col]), 1:size(G, 2))))
	g = minimum(length.(Clusters))
    rdf = dof_residual(model)
    output .*= g / (g - 1) * (nobs(model) - 1) / rdf
    return output, min(rdf, g - 1)
end

## Helper
meat(estimator::HC1, X::AbstractMatrix, û::AbstractVector) = X.' * Diagonal(û.^2) * X
meat(estimator::HC2, X::AbstractMatrix, û::AbstractVector) = X.' * Diagonal(û.^2 ./ (1 .- diag(X * pinv(X)))) * X
meat(estimator::HC3, X::AbstractMatrix, û::AbstractVector) = X.' * Diagonal((û ./ (1 .- diag(X * pinv(X)))).^2) * X

end
