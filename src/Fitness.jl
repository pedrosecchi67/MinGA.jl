export Pareto_precedence, Pareto_front, apply_restriction

"""
Function comparing two objective function evaluations to determine which of two
genotypes is characterized by Pareto optimality (`f1 ⪰ f2`)

* `f1`: objective function evaluation for the first genotype (array)
* `f2`: objective function evaluation for the second genotype (array)

* return: a boolean indicating whether `f1` discards `f2` from the pareto front (`f1 ⪰ f2`)
"""
function Pareto_precedence(f1::AbstractArray, f2::AbstractArray)
    !any(f2.<=f1)
end

"""
Alternative method for `Pareto_precedence` recieving floats as objective function evaluations
"""
function Pareto_precedence(f1::Float64, f2::Float64)
    f2>f1
end

"""
Given a population (array of genotypes - arrays or dictionaries) and its scores (array of
arrays or floats with objective function evaluations),
return the genotypes and evaluations corresponding to the Pareto front

* `genotypes`: array of genotypes
* `fs`: array of objective function evaluations

* return: tuple with the array of genotypes and the array of function evaluations that remains 
    after the selection of the Pareto front
"""
function Pareto_front(genotypes::AbstractArray, fs::AbstractArray)
    ispareto=ones(Bool, length(genotypes))

    for (i, f) in enumerate(fs)
        if ispareto[i]
            for (j, f2) in enumerate(fs)
                if ispareto[j]
                    if Pareto_precedence(f2, f)
                        ispareto[i]=false

                        break
                    end
                end
            end
        end
    end

    (
        [
            g for (i, g) in enumerate(genotypes) if ispareto[i]
        ],
        [
            f for (i, f) in enumerate(fs) if ispareto[i]
        ]
    )
end

"""
Apply restriction function to a population

* `restr`: function recieving a genome and a function evaluation, respectively, and returning a boolean
    (true for "fits restriction", false otherwise)
* `pop`: population (array of genomes)
* `fs`: objective function evaluations (array of arrays or floats)
* `min_remainder`: optional argument with a minimum number of remaining individuals (an argument that
    can be used in case reproduction is to be performed after restriction application, for example)

* return: a tuple with the remaning population and its objective function evaluations, in array format
"""
function apply_restriction(restr::Function, population::AbstractArray, fs::AbstractArray; min_remainder::Int64=0)
    isrestr=map(restr, population, fs)

    newpop=[p for (r, p) in zip(isrestr, population) if r]
    newfs=[f for (r, f) in zip(isrestr, fs) if r]

    while length(newpop) < min_remainder
        for (i, r) in enumerate(isrestr)
            if !r
                push!(newpop, population[i])
                push!(newfs, fs[i])

                break
            end
        end
    end

    newpop, newfs
end
