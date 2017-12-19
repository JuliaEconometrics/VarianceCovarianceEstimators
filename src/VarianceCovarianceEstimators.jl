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
	output = inv(factorize(Hermitian(mm.'mm)))
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
function vcov(model::RegressionModel, estimator::OLS)
	û = residuals(model)
	output = û.'û / dof_residual(model) * bread(model)
end
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
    R = eye(length(û))
    for dimension ∈ Clusters
        for level ∈ dimension
            for comparison ∈ dimension
                values = intersect(level, comparison)
                R[values, values] .= one(Float64)
            end
        end
    end
    if isa(estimator, CRVE2) | isa(estimator, CRVE3)
        h = Dict{Vector{Int64},Vector{Float64}}()
        output = zeros(length(û))
        for each ∈ 1:size(R, 1)
            group = find(R[:,each])
            output[each] = 1 - first(get!(h, group, hatvalues(mm[group,:]))[findfirst(equalto(each), group)])
        end
        if isa(estimator, CRVE2)
            û = û ./ sqrt.(output)
        elseif isa(estimator, CRVE3)
            û = û ./ output
        end
    end
    output = Bread * mm.' * (û * û.' .* R) * mm * Bread
    # g = length(unique(map(col -> find(R[:,col]), 1:size(R, 2))))
	g = minimum(length.(Clusters))
    rdf = dof_residual(model)
    output .*= g / (g - 1) * (nobs(model) - 1) / reduce(-, size(mm))
    return output, min(rdf, g - 1)
end

## Helper

gram(obj::AbstractMatrix) = obj'obj
function hatvalues(X::AbstractMatrix; Γ::AbstractMatrix = zeros(size(X, 2), size(X, 2)))
	sum((X * inv(factorize(Hermitian(X'X + Γ)))) .* X, 2)
end

meat(estimator::HC1, X::AbstractMatrix, û::AbstractVector) = gram(abs.(û) .* X)
meat(estimator::HC2, X::AbstractMatrix, û::AbstractVector) = gram(abs.(û) ./ sqrt.(broadcast(-, 1., hatvalues(X))) .* X)
meat(estimator::HC3, X::AbstractMatrix, û::AbstractVector) = gram(abs.(û) ./ broadcast(-, 1., hatvalues(X)) .* X)

end
