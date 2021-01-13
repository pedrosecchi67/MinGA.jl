# MinGA.jl

This is my personal, minimalist implementation of the necessary tools for assembling genetic algorithm implementations.

## Basics

* Genes can be of continuous (floating point) or discrete type;
* Genotypes can be stored in either array or dictionary format;
* Populations are stored as arrays of genotypes and objective function evaluations, which can be either floats (for mono-objective optimization) or arrays of floats.

## Handling Mutations

### Gaussian Mutation
Function to obtain a Gaussian floating point gene mutation within a given acceptability range

* `g`: original gene around which the Gaussian probability curve for mutations is centered
* `bounds`: tuple of floats for mutated value boundaries
* `standard_deviation`: keyword argument with distribution standard deviation. If none is provided, 
    `0.05*abs(g)` is assumed

* return: value for the mutated gene
```
function Gaussian_mutation(g::Float64, bounds::Tuple{Float64, Float64}; 
    standard_deviation::Union{Float64, Nothing}=nothing)
```

### Discrete Mutation
Function to obtain a mutated value from an array of discrete values

* `possibilities`: array of possible values

* return: value for the mutated gene
```
function discrete_mutation(possibilities::AbstractArray)
```

### Whole genotypes
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
```
function mutate_genotype!(
    genotype::Union{AbstractArray, AbstractDict},
    argsets::Union{AbstractArray, AbstractDict};
    mutation_rate::Union{Float64, AbstractArray, AbstractDict}=0.2
)
```

## Handling Reproduction

### Individual Genes
Generate a child between two genes, generating a gene for the child

* `g1`: gene 1
* `g2`: gene 2
* `bias`: a pseudo-aleatory number between zero and 1 is generated. 
    If the number (`k`) is such that `k>bias`, `g2` is chosen for the child. 
    `g1` is chosen otherwise.

    In continuous mode (see the next argument), `1.0-bias` and `bias` are respectively used to 
    weight `g1` and `g2` to generate a gene for the child
* `continuous`: implies that the cross-over results in a child with a value ponderated between g1 and g2.
    If continuous mode is requested with discrete input genes, this argument is neglected

* return: the new gene
```
function generate_child_gene(
    g1::Any,
    g2::Any;
    bias::Float64=0.5,
    continuous::Bool=false
)
```

### Interwoven Genotypes
Function to generate an intertwined cross-over between two genotypes in array or dictionary format

* `genotype1`: first genotype
* `genotype2`: second genotype
* `continuous`, `bias`: arguments to be passed to `generate_child_gene`

* return: the new genotype
```
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
```

### Cross-Over
Function similar to `intertwined_child_genotype`, but generates a crossover between vector-defined genotypes
by adopting gene positions below an array index from a parent and above it from another

* `g1`: genotype for parent 1 (an array)
* `g2`: genotype for parent 2 (an array)

* return: the new genotype
```
function cross_over_child_genotype(g1::AbstractArray, g2::AbstractArray)
```

## Fitness and Optimality

### Pareto Optimality
Function comparing two objective function evaluations to determine which of two
genotypes is characterized by Pareto optimality (`f1 ⪰ f2`)

* `f1`: objective function evaluation for the first genotype
* `f2`: objective function evaluation for the second genotype

* return: a boolean indicating whether `f1` discards `f2` from the pareto front (`f1 ⪰ f2`)
```
function Pareto_precedence(f1::AbstractArray, f2::AbstractArray)
function Pareto_precedence(f1::Float64, f2::Float64)
```

### Pareto Front
Given a population (array of genotypes - arrays or dictionaries) and its scores (array of
arrays or floats with objective function evaluations),
return the genotypes and evaluations corresponding to the Pareto front

* `genotypes`: array of genotypes
* `fs`: array of objective function evaluations

* return: tuple with the array of genotypes and the array of function evaluations that remains 
    after the selection of the Pareto front
```
function Pareto_front(genotypes::AbstractArray, fs::AbstractArray)
```

### Restrictions
Apply restriction function to a population

* `restr`: function recieving a genome and a function evaluation, respectively, and returning a boolean
    (true for "fits restriction", false otherwise)
* `pop`: population (array of genotypes)
* `fs`: objective function evaluations (array of arrays or floats)
* `min_remainder`: optional argument with a minimum number of remaining individuals (an argument that
    can be used in case reproduction is to be performed after restriction application, for example)

* return: a tuple with the remaning population and its objective function evaluations, in array format
```
function apply_restriction(restr::Function, 
    population::AbstractArray, fs::AbstractArray; min_remainder::Int64=0)
```

## Handling Populations
### Generate Random population
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
```
function random_population(
    argsets::Union{AbstractArray, AbstractDict},
    n_individuals::Int64
)
```

### Fill with Reproduction and Mutation
Fill a population up to a certain number of individuals using reproductions and mutations

* `argsets`: argument delimiting instructions for the mutation of each variable, as in `mutate_genotype!`
* `population`: original members of the population. Edited in place
* `n_individuals`: final number of individuals
* `reproduction_function`: function to produce a new child genome after recieving two others
* `mutation_rate`: dictionary, array or floating point variable to delimit mutation rates for each gene 
    (see `mutate_genotype!`)
```
function fill_population!(argsets::Union{AbstractArray, AbstractDict}, 
    population::AbstractArray, n_individuals::Int64; 
    reproduction_function::Function=intertwined_child_genotype,
    mutation_rate::Union{AbstractDict, AbstractArray, Float64}=0.2)
```

## Installation

You can install MinGA.jl using its GitHub repository link:

```
]add https://github.com/pedrosecchi67/MinGA.jl
```
