@assert begin
    gs=[
        [1, 2, 0],
        [0, 2, 3],
        [1, 1, 3]
    ]
    fs=[
        [-1.0, -0.5],
        [-0.5, -1.0],
        [0.0, 0.0]
    ]

    gps, fps=Pareto_front(gs, fs)

    @assert all(gps[1].==gs[1])
    @assert all(gps[2].==gs[2])

    restr=(g, f) -> ( g[1]==0 )

    grs, frs=apply_restriction(restr, gs, fs; min_remainder=2)

    @assert all(grs[2].==gs[1])
    @assert all(grs[1].==gs[2])

    true
end
