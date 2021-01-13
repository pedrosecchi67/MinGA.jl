@assert begin
    argsets=[
        [1, 2, 3],
        (1.0, 3.0)
    ]

    rdpop=random_population(argsets, 2)

    @assert all(
        [
            begin
                all(
                    [
                        (
                            isa(g, Float64) ? (g <= as[2] && g >= as[1]) : (g in as)
                        ) for (g, as) in zip(e, argsets)
                    ]
                )
            end for e in rdpop
        ]
    )

    argsets=Dict(
        :gene1 => [1, 2, 3],
        :gene2 => (1.0, 3.0)
    )

    rdpop=random_population(argsets, 2)

    @assert all(
        [
            begin
                all(
                    [
                        (
                            isa(e[k], Float64) ? (e[k] <= as[2] && e[k] >= as[1]) : (e[k] in as)
                        ) for (k, as) in argsets
                    ]
                )
            end for e in rdpop
        ]
    )

    argsets=Dict(
        :gene1 => [1, 2, 3],
        :gene2 => ((1.0, 3.0), 0.5)
    )

    fill_population!(argsets, rdpop, 4)

    argsets=Dict(
        :gene1 => [1, 2, 3],
        :gene2 => (1.0, 3.0)
    )

    @assert all(
        [
            begin
                all(
                    [
                        (
                            isa(e[k], Float64) ? (e[k] <= as[2] && e[k] >= as[1]) : (e[k] in as)
                        ) for (k, as) in argsets
                    ]
                )
            end for e in rdpop
        ]
    )

    true
end
