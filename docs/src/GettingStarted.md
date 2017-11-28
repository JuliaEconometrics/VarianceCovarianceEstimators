# Getting Started

## Installation

During the Beta test stage the package can be installed using:
```julia
Pkg.clone("https://github.com/JuliaEconometrics/VarianceCovarianceEstimators.jl.git")
```

Once it is released you it may be installed using:
```julia
Pkg.add("VarianceCovarianceEstimators")
```

## For Package Developers

This package provides a simple API for package developers to have access to a variety
of variance covariance estimators. The struct should be `<: StatsBase.RegressionModel`
and have the following methods implemented.

```
StatsBase.modelmatrix(obj::StatsBase.RegressionModel)
StatsBase.residuals(obj::StatsBase.RegressionModel)
```

The model matrix should be the matrix used for the parameter estimates. This implies
that for instrumental variable methods it should be the instrumented matrix. If the
model uses weights the model matrix should be weighted. For instrumental variables,
the residuals should be calculated using the matrix with the endogenous variables.

In addition several methods have a default behavior which may need to be overwritten:
```
function StatsBase.dof_residual(obj::StatsBase.RegressionModel)
	reduce(-, size(StatsBase.modelmatrix(obj)))
end
function StatsBase.deviance(obj::StatsBase.RegressionModel)
	StatsBase.residuals(obj).'StatsBase.residuals(obj) / StatsBase.dof_residual(obj)
end
function StatsBase.nobs(obj::StatsBase.RegressionModel)
	length(StatsBase.residuals(obj))
end
```

The residual degrees of freedom will depend on the (1) effective number of observations
if using some weighting scheme and (2) the effective degrees of freedom (account for intercept,
absorbed fixed effects, and regularization).

In addition to `StatsBase` methods the package has two more methods that can be used:
```
function bread(obj::StatsBase.RegressionModel)
	mm = StatsBase.modelmatrix(obj)
	output = inv(cholfact!(mm.'mm))
	return output
end
clusters(obj::StatsBase.RegressionModel) = Vector{Vector{Int64}}()
```
The function `bread` can be overwritten with a cached object stored during the fitting
process to avoid computing the inverse again or modified to allow for Ridge Regression
```
function bread(obj::MyPkg.MyStruct)
	Γ = getfield(obj, :Γ)
	mm = StatsBase.modelmatrix(obj)
	output = inv(cholfact!(mm.'mm + Γ))
	return output
end
```
Clusters can be specified by `Clusters[Dimension[Cluster[Observations]]]` of type
`Vector{Vector{Vector{T}}} where T <: Integer`.
