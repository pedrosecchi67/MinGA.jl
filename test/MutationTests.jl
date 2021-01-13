@assert begin
    bnds=(1.0, 5.0)

    g=3.0

    chld=Gaussian_mutation(g, bnds)

    (chld>=bnds[1] && chld<=bnds[2])
end

@assert begin
    possibilities=[
        :a,
        :b,
        :c
    ]

    chld=discrete_mutation(possibilities)

    chld in possibilities
end

@assert begin
    genotype=Dict(
        :Day => :Wednesday,
        :Dudes => true,
        :oooooh => 0.5
    )

    argsets=Dict(
        :Day => [:Wednesday, :NotWednesday], # it's always either one, or the other
        :Dudes => [false, true],
        :oooooh => ((0.0, 1.0), 0.25)
    )

    mutation_rate=Dict(
        :Day => 0.3,
        :Dudes => 0.2,
        :oooooh => 0.6
    )

    mutate_genotype!(genotype, argsets; mutation_rate=mutation_rate)

    @assert genotype[:Day] in argsets[:Day]
    @assert genotype[:Dudes] in argsets[:Dudes]

    bounds, std_dev=argsets[:oooooh]

    @assert bounds[1]<=genotype[:oooooh] && genotype[:oooooh]<=bounds[2]

    true
end
