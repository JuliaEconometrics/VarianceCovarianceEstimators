## API

### Packages must implement the following methods
"""
	vce(obj::StatsBase.RegressionModel)

Returns the variance covariance estimator for the model as an AbstractVCE.
"""
function getvce(obj::StatsBase.RegressionModel)
	output = :OLS
	return output
end
function getvce(obj::Symbol)
	if obj == :OLS
		output = OLS()
	elseif obj == :HC0
		output = HC0()
	elseif obj == :HC1
		output = HC1()
	elseif obj == :HC2
		output = HC2()
	elseif obj == :HC3
		output = HC3()
	else
		@assert false "Not a valid variance covariance estimator."
	end
	return output
end

"""
	clusters(obj::StatsBase.RegressionModel)

Returns the clusters for the variance covariance estimates as an AbstractMatrix where each column is a dimension.
"""
function getclusters(obj::StatsBase.RegressionModel)
	û = StatsBase.residuals(obj)
	output = Matrix{Int64}(length(û),1)
	output[:,1] = eachindex(û)
	return output
end

"""
	Γ(obj::StatsBase.RegressionModel)

Returns the Tikhonov matrix, a diagonal matrix with non-negative values as a `AbstractMatrix`.
"""
function getΓ(obj::StatsBase.RegressionModel)
	n = size(StatsBase.modelmatrix(obj), 2)
	output = zeros(n, n)
	return output
end

### Use this functions for your packages

function vcov!(obj::StatsBase.RegressionModel, fieldname::Symbol)
	setfield(obj, fieldname, vce(obj, getvce(obj)))
end
function vce(obj::StatsBase.RegressionModel)
	Bread = getbread(obj)
	ũ = getũ(obj)
	G = getG(obj)
	Meat = ũ * ũ.' .* G
	fsa = getγ(obj, G)
	output = fsa * Bread * Meat * Bread.'
	return output
end

## Clusters

function getclusters(obj::AbstractVector)
	output = map(value -> find(obj .== value), unique(obj))
	return output
end
function getclusters(obj::AbstractMatrix)
	output = map(col -> getclusters(obj[:,col]), 1:size(obj, 2))
	return output
end

function getG(obj::StatsBase.RegressionModel)
	X = StatsBase.modelmatrix(obj)
	clusters = getclusters(X)
	output = BitMatrix(zeros(size(X, 1), size(X, 1)))
	for dimension ∈ clusters
		for level ∈ dimension
			for comparison ∈ dimension
				values = intersect(level, comparison)
				output[values, values] = true
			end
		end
	end
	return output
end

## Residuals
function getũ(obj::StatsBase.RegressionModel)
	vce = getvce(getvce(obj))
	output = getû(obj, vce) / broadcast(-, 1, geth(obj, vce)).^getδ(vce)
end
function getû(obj::StatsBase.RegressionModel,
	vce::AbstractVCE)
	return StatsBase.residuals(obj)
end
function getû(obj::StatsBase.RegressionModel,
	vce::OLS)
	û = StatsBase.residuals(obj)
	return sqrt(û.'û / StatsBase.dof_residual(obj)) * ones(length(û))
end
function geth(obj::StatsBase.RegressionModel, vce::AbstractVCE)
	return geth(vce, StatsBase.modelmatrix(obj))
end
function geth(vce::AbstractVCE, X::AbstractMatrix)
	return zero(Float64)
end
function geth(vce::HC2, X::AbstractMatrix)
	return diag(X * inv(cholfact!(X.'X)) * X.')
end
function geth(vce::HC3, X::AbstractMatrix)
	return diag(X * inv(cholfact!(X.'X)) * X.')
end
function getδ(vce::AbstractVCE)
	return zero(Float64)
end
function getδ(vce::HC2)
	return 0.5
end
function getδ(vce::HC3)
	return one(Float64)
end
## Bread

function getbread(obj::StatsBase.RegressionModel)
	X = StatsBase.modelmatrix(obj)
	Γ = getΓ(obj)
	return inv(cholfact!(X.'X + Γ)) * X.'
end

## Finite Sample Adjustment

function getγ(obj::StatsBase.RegressionModel, G::AbstractMatrix)
	m = length(StatsBase.residuals(obj))
	k = StatsBase.dof(obj)
	if isdiag(G)
		output = m / (m - k)
	else
		g = minimum(length.(getclusters(getclusters(obj))))
		output = g / (g - 1) * (m - 1) / (m - k)
	end
	return output
end
