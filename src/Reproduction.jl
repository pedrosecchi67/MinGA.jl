export generate_child_gene, intertwined_child_genotype, cross_over_child_genotype

"""
Generate a child between two genes, generating a gene for the child

* `g1`: gene 1
* `g2`: gene 2
* `bias`: a pseudo-aleatory number between zero and 1 is generated. 
    If the number (`k`) is such that `k>bias`, `g2` is chosen for the child. 
    `g1` is chosen otherwise.

    In continuous mode (see the next argument), `1.0-bias` and `bias` are respectively used to 
    weight `g1` and `g2` to generate a gene for the child
* `continuous`: implies that the cross-over results in a child with a value ponderated between g1 and g2.
    If continuous mode is requested with non-continuous input genes, this argument is neglected
"""
function generate_child_gene(
    g1::Any,
    g2::Any;
    bias::Float64=0.5,
    continuous::Bool=false
)
    k=rand(Float64)

    if continuous && (isa(g1, Float64) && isa(g2, Float64))
        chg1=(1.0-k)*g1*(1.0-bias)
        chg2=k*g2*bias

        chg=(chg1+chg2)/(k*bias+(1.0-k)*(1.0-bias))

        return chg
    else
        if k>bias
            chg=g2
        else
            chg=g1
        end

        return chg
    end
end

"""
Function to generate an intertwined cross-over between two genotypes in array or dictionary format

* `genotype1`: first genotype
* `genotype2`: second genotype
* `continuous`, `bias`: arguments to be passed to `generate_child_gene`
"""
function intertwined_child_genotype(
    genotype1::Union{
        AbstractVector,
        AbstractDict
    },
    genotype2::Union{
        AbstractVector,
        AbstractDict
    };
    bias::Float64=0.5,
    continuous::Bool=false
)
    if typeof(genotype1) <: AbstractArray && typeof(genotype2) <: AbstractArray
        return [generate_child_gene(g1, g2; bias=bias, continuous=continuous) for (g1, g2) in zip(genotype1, genotype2)]
    elseif typeof(genotype1) <: AbstractDict && typeof(genotype2) <: AbstractDict
        d=Dict{Any, Any}()

        for (k, v) in genotype1
            d[k]=generate_child_gene(
                v,
                genotype2[k];
                bias=bias,
                continuous=continuous
            )
        end

        return d
    end
end

"""
Function similar to `intertwined_child_genotype`, but generates a crossover between vector-defined genotypes
by adopting gene positions below an array index from a parent and above it from another

* `g1`: genotype for parent 1 (an array)
* `g2`: genotype for parent 2 (an array)
"""
function cross_over_child_genotype(g1::AbstractArray, g2::AbstractArray)
    k=rand(Float64)
    inv_stat=(rand(Float64)>0.5)

    if length(g1)!=length(g2)
        throw(
            error(
                "cross_over_child_genotype:ERROR:attempting to apply cross-over to genotypes of different lenghts"
            )
        )
    end

    ind=Int64(round(length(g1)*k))
    
    if inv_stat
        gkid=vcat(
            deepcopy(g2[1:ind]),
            deepcopy(g1[(ind+1):end])
        )
    else
        gkid=vcat(
            deepcopy(g1[1:ind]),
            deepcopy(g2[(ind+1):end])
        )
    end

    gkid
end
