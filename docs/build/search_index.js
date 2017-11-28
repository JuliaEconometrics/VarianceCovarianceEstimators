var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "VarianceCovarianceEstimators.jl Documentation",
    "title": "VarianceCovarianceEstimators.jl Documentation",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#VarianceCovarianceEstimators.jl-Documentation-1",
    "page": "VarianceCovarianceEstimators.jl Documentation",
    "title": "VarianceCovarianceEstimators.jl Documentation",
    "category": "section",
    "text": "CurrentModule = VarianceCovarianceEstimatorsVarianceCovarianceEstimators.jl allows estimation of variance covariance matrices for StatsBase.RegressionModel.Pages = [\"GettingStarted.md\",\n		\"ModelAPI.md\",\n		\"Diagnostics.md\",\n		\"Examples.md\",\n		\"References.md\"]"
},

{
    "location": "GettingStarted.html#",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "page",
    "text": ""
},

{
    "location": "GettingStarted.html#Getting-Started-1",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "section",
    "text": ""
},

{
    "location": "GettingStarted.html#Installation-1",
    "page": "Getting Started",
    "title": "Installation",
    "category": "section",
    "text": "During the Beta test stage the package can be installed using:Pkg.clone(\"https://github.com/JuliaEconometrics/VarianceCovarianceEstimators.jl.git\")Once it is released you it may be installed using:Pkg.add(\"VarianceCovarianceEstimators\")"
},

{
    "location": "GettingStarted.html#For-Package-Developers-1",
    "page": "Getting Started",
    "title": "For Package Developers",
    "category": "section",
    "text": "This package provides a simple API for package developers to have access to a variety of variance covariance estimators. The struct should be <: StatsBase.RegressionModel and have the following methods implemented.StatsBase.modelmatrix(obj::StatsBase.RegressionModel)\nStatsBase.residuals(obj::StatsBase.RegressionModel)The model matrix should be the matrix used for the parameter estimates. This implies that for instrumental variable methods it should be the instrumented matrix. If the model uses weights the model matrix should be weighted. For instrumental variables, the residuals should be calculated using the matrix with the endogenous variables.In addition several methods have a default behavior which may need to be overwritten:function StatsBase.dof_residual(obj::StatsBase.RegressionModel)\n	reduce(-, size(StatsBase.modelmatrix(obj)))\nend\nfunction StatsBase.deviance(obj::StatsBase.RegressionModel)\n	StatsBase.residuals(obj).'StatsBase.residuals(obj) / StatsBase.dof_residual(obj)\nend\nfunction StatsBase.nobs(obj::StatsBase.RegressionModel)\n	length(StatsBase.residuals(obj))\nendThe residual degrees of freedom will depend on the (1) effective number of observations if using some weighting scheme and (2) the effective degrees of freedom (account for intercept, absorbed fixed effects, and regularization).In addition to StatsBase methods the package has two more methods that can be used:function bread(obj::StatsBase.RegressionModel)\n	mm = StatsBase.modelmatrix(obj)\n	output = inv(cholfact!(mm.'mm))\n	return output\nend\nclusters(obj::StatsBase.RegressionModel) = Vector{Vector{Int64}}()The function bread can be overwritten with a cached object stored during the fitting process to avoid computing the inverse again or modified to allow for Ridge Regressionfunction bread(obj::MyPkg.MyStruct)\n	Γ = getfield(obj, :Γ)\n	mm = StatsBase.modelmatrix(obj)\n	output = inv(cholfact!(mm.'mm + Γ))\n	return output\nendClusters can be specified by Clusters[Dimension[Cluster[Observations]]] of type Vector{Vector{Vector{T}}} where T <: Integer."
},

{
    "location": "ModelAPI.html#",
    "page": "API",
    "title": "API",
    "category": "page",
    "text": ""
},

{
    "location": "ModelAPI.html#API-1",
    "page": "API",
    "title": "API",
    "category": "section",
    "text": ""
},

{
    "location": "ModelAPI.html#Estimators-1",
    "page": "API",
    "title": "Estimators",
    "category": "section",
    "text": "The available estimators are heteroskedasticity consistent (Eicker 1967; Huber 1967; White 1980) in their multiway-way (Colin Cameron, Gelbach, and Miller 2011) cluster robust (Liang and Zeger 1986; Arellano 1987; Rogers 1993) versions. The estimators HC1, HC2, HC3 (MacKinnon and White 1985) and their cluster robust versions (Bell and McCaffrey 2002)."
},

{
    "location": "ModelAPI.html#vcov-1",
    "page": "API",
    "title": "vcov",
    "category": "section",
    "text": "One can access a variance covariance estimate using the following syntax:vcov(model::StatsBase.RegressionModel, estimator::Symbol)were the estimators can be: :OLS, :HC1, :HC2, :HC3. The methods adapt to the error structure given by clusters(obj::StatsBase.RegressionModel)."
},

{
    "location": "Examples.html#",
    "page": "Examples",
    "title": "Examples",
    "category": "page",
    "text": ""
},

{
    "location": "Examples.html#Examples-1",
    "page": "Examples",
    "title": "Examples",
    "category": "section",
    "text": "srand(0)\nusing StatsBase\nusing VarianceCovarianceEstimators\n\nPID = repeat(1:10, inner = 10)\nTID = repeat(1:10, outer = 10)\nX = hcat(ones(100), rand(100, 2))\ny = (X * ones(3,1) + repeat(rand(10), inner = 10) + repeat(rand(10), outer = 10) + rand(100))[:]\nβ = X \\ y\nŷ = X * β\nû = Vector(y - ŷ)\n\nmutable struct MyModel <: StatsBase.RegressionModel\nend\n\nmodel = MyModel()\nStatsBase.modelmatrix(obj::MyModel) = X\nStatsBase.residuals(obj::MyModel) = û\nStatsBase.dof_residual(obj::MyModel) = reduce(-, size(StatsBase.modelmatrix(obj)))\nStatsBase.deviance(obj::MyModel) = StatsBase.residuals(obj).'StatsBase.residuals(obj) / StatsBase.dof_residual(obj)\nStatsBase.nobs(obj::MyModel) = length(StatsBase.residuals(obj))\n\ngroups = map(obj -> find.(map(val -> obj .== val, unique(obj))), [PID, TID])"
},

{
    "location": "Examples.html#Spherical-Errors-1",
    "page": "Examples",
    "title": "Spherical Errors",
    "category": "section",
    "text": "vcov(model, :OLS)"
},

{
    "location": "Examples.html#Heteroscedasticity-Consistent-Estimators-1",
    "page": "Examples",
    "title": "Heteroscedasticity Consistent Estimators",
    "category": "section",
    "text": ""
},

{
    "location": "Examples.html#HC1-1",
    "page": "Examples",
    "title": "HC1",
    "category": "section",
    "text": "vcov(model, :HC1)"
},

{
    "location": "Examples.html#HC2-1",
    "page": "Examples",
    "title": "HC2",
    "category": "section",
    "text": "vcov(model, :HC2)"
},

{
    "location": "Examples.html#HC3-1",
    "page": "Examples",
    "title": "HC3",
    "category": "section",
    "text": "vcov(model, :HC3)"
},

{
    "location": "Examples.html#Cluster-Robust-Variance-Covariance-Estimators-(multi-way-clustering)-1",
    "page": "Examples",
    "title": "Cluster Robust Variance Covariance Estimators (multi-way clustering)",
    "category": "section",
    "text": "VarianceCovarianceEstimators.clusters(obj::MyModel) = groups"
},

{
    "location": "Examples.html#CRVE1-1",
    "page": "Examples",
    "title": "CRVE1",
    "category": "section",
    "text": "V, rdf = vcov(model, :HC1)\nV"
},

{
    "location": "Examples.html#CRVE2-1",
    "page": "Examples",
    "title": "CRVE2",
    "category": "section",
    "text": "V, rdf = vcov(model, :HC2)\nV"
},

{
    "location": "Examples.html#CRVE3-1",
    "page": "Examples",
    "title": "CRVE3",
    "category": "section",
    "text": "V, rdf = vcov(model, :HC3)\nV"
},

{
    "location": "References.html#",
    "page": "References",
    "title": "References",
    "category": "page",
    "text": ""
},

{
    "location": "References.html#References-1",
    "page": "References",
    "title": "References",
    "category": "section",
    "text": "Arellano, Manuel. 1987. \"Computing Robust Standard Errors for Within-groups Estimators.\" Oxford Bulletin of Economics and Statistics 49 (4): 431–434. doi:10.1111/j.1468- 0084.1987.mp49004006.x.Bell, Robert M., and Daniel F. McCaffrey. 2002. \"Bias Reduction in Standard Errors for Linear Regression with Multi- Stage Samples.\" Survey Methodology 28(2):169–79. https://statcan.gc.ca/olc-cel/olc.action?ObjId=12-001-X20020029058&ObjType=47Colin Cameron, A., Jonah B. Gelbach, and Douglas L. Miller. 2011. \"Robust Inference With Multiway Clustering.\" Journal of Business & Economic Statistics 29 (2): 238–249. doi:10.1198/jbes.2010.07136.Eicker, Friedhelm. 1967. \"Limit theorems for regressions with unequal and dependent errors.\" In Proceedings of the Fifth Berkeley Symposium on Mathematical Statistics and Probability, Volume 1: Statistics, 59–82. Berkeley, California: University of California Press. https://projecteuclid.org/euclid.bsmsp/1200512981.Huber, Peter J. 1967. \"The behavior of maximum likelihood estimates under nonstandard conditions.\" In Proceedings of the Fifth Berkeley Symposium on Mathematical Statistics and Probability, Volume 1: Statistics, 221–233. Berkeley, California: University of California Press. https://projecteuclid.org/euclid.bsmsp/1200512988.Liang, Kung-Yee, and Scott L. Zeger. 1986. \"Longitudinal data analysis using generalized linear models.\" Biometrika 73 (1): 13–22. doi:10.1093/biomet/73.1.13.MacKinnon, James G, and Halbert White. 1985. \"Some heteroskedasticity-consistent covariance matrix estimators with improved finite sample properties.\" Journal of Econometrics 29 (3): 305–325. doi:10.1016/0304-4076(85)90158-7.Rogers, William. 1993. \"Regression standard errors in clustered samples.\" Stata Technical Bulletin 13 (17): 19–23. https://www.stata.com/products/stb/journals/stb13.pdf.White, Halbert. 1980. \"A Heteroskedasticity-Consistent Covariance Matrix Estimator and a Direct Test for Heteroskedasticity.\" Econometrica 48 (4): 817. doi:10.2307/1912934."
},

]}
