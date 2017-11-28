using VarianceCovarianceEstimators
using Test

srand(0)
using StatsBase

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

makegroups(obj::AbstractVector) =
	find.(map(val -> obj .== val, unique(obj)))

groups = makegroups.([PID, TID])

V = vcov(model, :OLS)
@test mapreduce(idx -> V[idx:end, idx], vcat, 1:size(V, 1)) ≈
    [0.016812950819883037,
    -0.013785344698385674,
    -0.015506005910982551,
    0.023981369378055544,
    0.0032463406452211837,
    0.02804994376185539]
