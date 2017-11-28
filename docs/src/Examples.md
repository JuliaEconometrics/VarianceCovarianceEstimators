# Examples

```@setup Tutorial
srand(0)
using StatsBase
using VarianceCovarianceEstimators

PID = repeat(1:10, inner = 10)
TID = repeat(1:10, outer = 10)
X = hcat(ones(100), rand(100, 2))
y = (X * ones(3,1) + repeat(rand(10), inner = 10) + repeat(rand(10), outer = 10) + rand(100))[:]
β = X \ y
ŷ = X * β
û = Vector(y - ŷ)

mutable struct MyModel <: StatsBase.RegressionModel
end

model = MyModel()
StatsBase.modelmatrix(obj::MyModel) = X
StatsBase.residuals(obj::MyModel) = û
StatsBase.dof_residual(obj::MyModel) = reduce(-, size(StatsBase.modelmatrix(obj)))
StatsBase.deviance(obj::MyModel) = StatsBase.residuals(obj).'StatsBase.residuals(obj) / StatsBase.dof_residual(obj)
StatsBase.nobs(obj::MyModel) = length(StatsBase.residuals(obj))

groups = map(obj -> find.(map(val -> obj .== val, unique(obj))), [PID, TID])
```

## Spherical Errors

```@example Tutorial
vcov(model, :OLS)
```

## Heteroscedasticity Consistent Estimators

### HC1

```@example Tutorial
vcov(model, :HC1)
```

### HC2

```@example Tutorial
vcov(model, :HC2)
```

### HC3

```@example Tutorial
vcov(model, :HC3)
```

## Cluster Robust Variance Covariance Estimators (multi-way clustering)

```@example Tutorial
VarianceCovarianceEstimators.clusters(obj::MyModel) = groups
```

### CRVE1

```@example Tutorial
V, rdf = vcov(model, :HC1)
V
```

### CRVE2

```@example Tutorial
V, rdf = vcov(model, :HC2)
V
```

### CRVE3

```@example Tutorial
V, rdf = vcov(model, :HC3)
V
```
