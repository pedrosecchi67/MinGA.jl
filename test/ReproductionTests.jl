@assert begin
    chg=generate_child_gene(
        "Hello",
        "World"
    )

    @assert chg in ["Hello", "World"]

    chg=generate_child_gene(
        0.6,
        0.8;
        bias=0.3,
        continuous=true
    )

    @assert (chg>=0.6 && chg<=0.8)

    true
end

@assert begin
    d1=Dict(
        "P1"=>"Hello",
        "P2"=>:World,
        "P3"=>1,
        "P3"=>3.0
    )
    d2=Dict(
        "P1"=>"World",
        "P2"=>:Hello,
        "P3"=>2,
        "P3"=>1.0
    )

    chld=intertwined_child_genotype(
        d1, d2;
        bias=0.5,
        continuous=true
    )

    for (k, v) in chld
        if isa(v, Float64)
            maxv=maximum([d1[k], d2[k]])
            minv=minimum([d1[k], d2[k]])

            @assert (minv<=v && v<=maxv)
        else
            @assert (d1[k]==v || d2[k]==v)
        end
    end

    true
end

@assert begin
    g1=[1, 2.0, 'a']
    g2=[2, 3.0, 'c']

    child=cross_over_child_genotype(
        g1,
        g2
    )

    for (i, c) in enumerate(child)
        @assert (c==g1[i]) || (c==g2[i])
    end

    true
end
