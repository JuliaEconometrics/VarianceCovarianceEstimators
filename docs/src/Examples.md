# Examples

```@setup Tutorial
srand(0)
using StatsBase
using DataFrames
using EconUtils
using VarianceCovarianceEstimators
df = DataFrame(PID = repeat(1:10, inner = 10), TID = repeat(1:10, outer = 10),
    X1 = rand(100), X2 = rand(100), X3 = rand(100))
df[:y] = (Matrix(df[[:X1, :X2, :X3]]) * ones(3,1) .+ repeat(rand(10), inner = 10) .+ repeat(rand(10), outer = 10) .+ rand(100))[:]
X = hcat(ones(100), Matrix(df[[:X1, :X2, :X3]]))
y = Vector(df[:y])
β = X \ y
ŷ = X * β
û = y - ŷ
mutable struct MyModel <: StatsBase.RegressionModel
    mm::Matrix{Float64}
    û::Vector{Float64}
end
model = MyModel(X, û)
StatsBase.modelmatrix(obj::MyModel) = getfield(obj, :mm)
StatsBase.residuals(obj::MyModel) = getfield(obj, :û)
StatsBase.dof_residual(obj::MyModel) = reduce(-, size(StatsBase.modelmatrix(obj)))
StatsBase.deviance(obj::MyModel) = StatsBase.residuals(obj).'StatsBase.residuals(obj) / StatsBase.dof_residual(obj)
StatsBase.nobs(obj::MyModel) = length(StatsBase.residuals(obj))
groups = EconUtils.makegroups(df[[:PID, :TID]])
```

- OLS

```@example Tutorial
vcov(model, :OLS)
```

- HC1

```@example Tutorial
vcov(model, :HC1)
```

- HC2

```@example Tutorial
vcov(model, :HC2)
```

- HC3

```@example Tutorial
vcov(model, :HC3)
```

Two-ways clustering returns `V, rdf` where `V` is the variance covariance estimate
and `rdf` is the `dof_residual` based on the error structure.

```@setup Tutorial
VarianceCovarianceEstimators.clusters(obj::MyModel) = groups
```

- CRVE1

```@example Tutorial

V, rdf = vcov(model, :HC1)
print(V)

```

- CRVE2

```@example Tutorial

V, rdf = vcov(model, :HC2)
print(V)

```

- CRVE3

```@example Tutorial

V, rdf = vcov(model, :HC3)
print(V)

```
