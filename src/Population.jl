export random_population, fill_population!

"""
Obtain a population with random values for genes

* `argsets`: delimiters for possible gene values. For floating-point genes, should contain
    a tuple with domain boundaries; for discrete genes, should contain an array of possible values.

    Example:

    ```
    [
        [1, 2, 3], # for a discrete, integer gene
        (0.0, 1.0) # for a continuous, floating point gene
    ]
    ```

    Or:

    ```
    Dict(
        :gene1 => [1, 2, 3],
        :gene2 => (0.0, 1.0)
    )
    ```

* `n_individuals`: number of individuals to be generated

* return: an array of genotypes
"""
function random_population(
    argsets::Union{AbstractArray, AbstractDict},
    n_individuals::Int64
)
    isdict = typeof(argsets) <: AbstractDict

    [
        begin
            isdict ? begin 
                g=Dict()

                for (k, v) in argsets
                    if typeof(v) <: AbstractArray
                        g[k]=v[abs(rand(Int64))%length(v)+1]
                    else
                        g[k]=rand(Float64)*(v[2]-v[1])+v[1]
                    end
                end

                g
            end :
            [
                (
                    (typeof(v) <: AbstractArray) ? begin
                        v[abs(rand(Int64))%length(v)+1]
                    end :
                    begin
                        rand(Float64)*(v[2]-v[1])+v[1]
                    end
                ) for v in argsets
            ]
        end for i=1:n_individuals
    ]
end

"""
Fill a population up to a certain number of individuals using reproductions and mutations

* `argsets`: argument delimiting instructions for the mutation of each variable, as in `mutate_genotype!`
* `population`: original members of the population. Edited in place
* `n_individuals`: final number of individuals
* `reproduction_function`: function to produce a new child genome after recieving two others
* `mutation_rate`: dictionary, array or floating point variable to delimit mutation rates for each gene 
    (see `mutate_genotype!`)
"""
function fill_population!(argsets::Union{AbstractArray, AbstractDict}, 
    population::AbstractArray, n_individuals::Int64; reproduction_function::Function=intertwined_child_genotype,
    mutation_rate::Union{AbstractDict, AbstractArray, Float64}=0.2)
    noriginal=length(population)

    if noriginal==0
        throw(
            error(
                "fill_population:ERROR:cannot fill an empty population. Use random_population instead"
            )
        )
    end

    while length(population) < n_individuals
        cr1=abs(rand(Int64))%noriginal+1
        cr2=abs(rand(Int64))%noriginal+1

        newind=reproduction_function(population[cr1], population[cr2])

        mutate_genotype!(newind, argsets; mutation_rate=mutation_rate)

        push!(population, newind)
    end
end
