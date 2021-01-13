using Distributions

export Gaussian_mutation, discrete_mutation, mutate_genotype!

"""
Function to obtain a Gaussian floating point gene mutation within a given acceptability range

* `g`: original gene around which the Gaussian probability curve for mutations is centered
* `bounds`: tuple of floats for mutated value boundaries
* `standard_deviation`: keyword argument with distribution standard deviation. If none is provided, 
    `0.05*abs(g)` is assumed
"""
function Gaussian_mutation(g::Float64, bounds::Tuple{Float64, Float64}; 
    standard_deviation::Union{Float64, Nothing}=nothing)
    std_dev=something(standard_deviation, 0.05*abs(g))

    rnd=Truncated(
        Normal(g, std_dev),
        bounds[1], bounds[2]
    )

    rand(rnd)
end

"""
Function to obtain a mutated value from an array of discrete values

* `possibilities`: array of possible values
"""
function discrete_mutation(possibilities::AbstractArray)
    ind=abs(rand(Int64))%length(possibilities)+1

    possibilities[ind]
end

"""
Function to apply discrete and Gaussian mutations to a whole genotype

* `genotype`: an array or dictionary of values corresponding to a genotype
* `argsets`: an array or dictionary of arrays and/or tuples.
    Its elements are used to determine mutation arguments for `Gaussian_mutation` in floating point genes and
    `discrete_mutation` in discrete variations.

    Example:

    ```
    [
        ((0.0, 5.0), 2.0), # respectively, bounds and standard deviation for a floating point gene
        [1, 2, 4, 8], # array of possibilities for a discrete gene
        [:a, :b, :c] # array of possibilities for a discrete gene
    ]
    ```
* `mutation_rate`: keyword argument with a probability for mutation occurences - or a dictionary/array indicating it for each variable 
"""
function mutate_genotype!(
    genotype::Union{AbstractArray, AbstractDict},
    argsets::Union{AbstractArray, AbstractDict};
    mutation_rate::Union{Float64, AbstractArray, AbstractDict}=0.2
)
    if typeof(genotype) <: AbstractArray
        if !(typeof(argsets) <: AbstractArray)
            throw(
                error(
                    "mutate_genotype!:ERROR:unable to use genotype and argsets of different types"
                )
            )
        end

        for (i, (g, args)) in enumerate(zip(genotype, argsets))
            if typeof(mutation_rate) <: AbstractDict
                throw(
                    error(
                        "mutate_genotype!:ERROR:mutation_rate is of type incompatible to argsets"
                    )
                )
            elseif typeof(mutation_rate) <: AbstractArray
                mutrate=mutation_rate[i]
            else
                mutrate=mutation_rate
            end

            if rand(Float64)<=mutrate
                if typeof(args) <: AbstractArray
                    genotype[i]=discrete_mutation(args)
                else
                    try
                        (bounds, std_dev)=args

                        genotype[i]=Gaussian_mutation(g, bounds; standard_deviation=std_dev)
                    catch
                        throw(
                            error(
                                "mutate_genotype!:ERROR:unable to parse arguments for mutation. Please check argument structure"
                            )
                        )
                    end
                end
            end
        end
    elseif typeof(genotype) <: AbstractDict
        if !(typeof(argsets) <: AbstractDict)
            throw(
                error(
                    "mutate_genotype:ERROR:unable to use genotype and argsets of different types"
                )
            )
        end

        for (k, g) in genotype
            args=argsets[k]

            if typeof(mutation_rate) <: AbstractArray
                throw(
                    error(
                        "mutate_genotype!:ERROR:mutation_rate is of type incompatible to argsets"
                    )
                )
            elseif typeof(mutation_rate) <: AbstractDict
                mutrate=mutation_rate[k]
            else
                mutrate=mutation_rate
            end

            if rand(Float64)<=mutrate
                if typeof(args) <: AbstractArray
                    genotype[k]=discrete_mutation(args)
                else
                    try
                        (bounds, std_dev)=args

                        genotype[k]=Gaussian_mutation(g, bounds; standard_deviation=std_dev)
                    catch
                        throw(
                            error(
                                "mutate_genotype!:ERROR:unable to parse arguments for mutation. Please check argument structure"
                            )
                        )
                    end
                end
            end
        end
    end
end
