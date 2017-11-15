__precompile__(true)

module VarianceCovarianceEstimators

import StatsBase

for (dir, filename) in [
	("", "Structs.jl"),
	("", "Main.jl")
	]
	include(joinpath(dir, filename))
end

end
