# API

## Estimators

The available estimators are heteroskedasticity consistent (Eicker 1967; Huber 1967; White 1980) in their multiway-way (Colin Cameron, Gelbach, and Miller 2011) cluster robust (Liang and Zeger 1986; Arellano 1987; Rogers 1993) versions. The estimators HC1, HC2, HC3 (MacKinnon and White 1985) and their cluster robust versions (Bell and McCaffrey 2002).

## `vcov`

One can access a variance covariance estimate using the following syntax:
```
vcov(model::StatsBase.RegressionModel, estimator::Symbol)
```
were the estimators can be: `:OLS, :HC1, :HC2, :HC3`. The methods adapt to the
error structure given by `clusters(obj::StatsBase.RegressionModel)`.
