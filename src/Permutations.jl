# Module written by Ed Scheinerman, ers@jhu.edu
# distributed under terms of the MIT license

module Permutations

import Base.length, Base.show, Base.inv
export Permutation, IdentityPermutation, RandomPermutation
export length, getindex, array, two_row
export inv, cycles, cycle_string, parity
export order, matrix

# Defines the Permutation class. Permutations are bijections of 1:n.
immutable Permutation
    data::Array{Int,1}
    function Permutation(dat::Array{Int,1})
        n = length(dat)
        if sort(dat) != 1:n
            error("Improper array: must be a permutation of 1:n")
        end
        new(dat) 
    end
end

# create the k'th permutation of 1:n
function Permutation(n,k)
    return Permutation(nthperm([1:n],k))
end

IdentityPermutation(n::Int) = Permutation([1:n])

RandomPermutation(n::Int) = Permutation(randperm(n))

# Returns the number of elements in the Permtuation
function length(p::Permutation) 
    return length(p.data)
end

# Check for equality of permutations
==(p::Permutation, q::Permutation) = p.data==q.data

# Apply the Permutation to an element: p[k]
function getindex(p::Permutation, k::Int)
    return p.data[k]
end

# Convert this Permutation into a one-dimensional array of integers
function array(p::Permutation)
    return collect(p.data)
end

# Create a two-row representation of this permutation
function two_row(p::Permutation)
    n = length(p)
    return [ (1:n)', p.data']
end

# Composition of two permutations
function *(p::Permutation, q::Permutation)
    n = length(p)
    if n != length(q)
        error("Cannot compose Permutations of different lengths")
    end
    dat = [ p[q[k]] for k in 1:n ]
    return Permutation(dat)
end

# Inverse of a permutation
function inv(p::Permutation)
    n = length(p)
    data = zeros(Int,n) 
    for k=1:n
        j = p[k]
        data[j] = k
    end
    return Permutation(data)
end

# Find the cycles in a permutation
function cycles(p::Permutation)
    n = length(p)
    result = Array{Int,1}[]
    todo = trues(n)
    while any(todo)
        k = find(todo)[1]
        todo[k] = false
        cycle = [k]
        j = p[k]
        while j != k
            append!(cycle,[j])
            todo[j] = false
            j = p[j]
        end
        push!(result, cycle)
    end
    return result
end

# Create a nice, printable string representation from the cycle
# structure of a permutation
function cycle_string(p::Permutation)
    str = ""
    cc = cycles(p)
    for c in cc
        str *= array2string(c)
    end
    return str
end

# helper function for cycle_string (not exposed). Converts an integer
# array such as [1,3,5,2] into the string "(1,3,5,2)".
function array2string(a::Array{Int,1})
    n = length(a)
    res = "("
    for k=1:n
        res *= string(a[k])
        if k<n
            res *= ","
        else
            res *= ")"
        end
    end
    return res
end

# Determine the parity of this permutation (0=even, 1=odd)
function parity(p::Permutation)
    cc = cycles(p)
    szs = [ length(c)+1 for c in cc ]
    return sum(szs)%2
end

# When we print a permutation, it appears in disjoint cycle format.
function show(io::IO, p::Permutation)
    print(io, cycle_string(p))
end

# Find the smallest positive n such that p^n is the identity
function order(p::Permutation)
    result = 1
    clist = cycles(p)
    for c in clist
        result = lcm(result, length(c))
    end
    return result
end

# Extend p^n so negative exponents work too
function ^(p::Permutation, n::Int)
    if n==0
        return IdentityPermutation(length(p))
    end
    if n<0
        return inv(p)^(-n)
    end
    if n==1
        return p
    end

    m::Int = int(floor(n/2))  # m = floor(n/2)
    q::Permutation = p^m

    if n%2 == 0   # if even
        return q*q
    end

    return p*q*q
end

# Represent as a permtuation matrix. 
function matrix(p::Permutation, sparse::Bool = false)
    n = length(p)
    if sparse
        A = speye(Int,n)
    else
        A = int(eye(n))
    end
    return A[array(p),:]
end


end # end of module Permutations