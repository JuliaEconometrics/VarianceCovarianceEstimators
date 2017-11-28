
using Documenter, VarianceCovarianceEstimators

makedocs(
    # format = :html,
    sitename = "VarianceCovarianceEstimators.jl",
    pages = [
        "index.md",
        "GettingStarted.md",
        "ModelAPI.md",
        "Examples.md",
        "References.md"
    ]
)

deploydocs(
    deps = Deps.pip("pygments", "mkdocs", "python-markdown-math"),
    repo = "github.com/JuliaEconometrics/VarianceCovarianceEstimators.jl.git",
    julia  = "nightly"
)
