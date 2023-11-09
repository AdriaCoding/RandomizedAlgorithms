# Adrià's Randomized Algorithms repository

This is a repository of all my codes for the course in Randomized Algorithms at my master's degree, check out the course's open source [webpage](https://www.cs.upc.edu/~conrado/docencia/ra-miri.html).

To install Julia, you can go the [official website](https://julialang.org/downloads/) and follow the appropriate steps for your system. 

If you have added Julia to PATH, you can start a new session into the Julia REPL by just running "julia" (or else, run "/path/to/julia/bin/julia)" on your favorite command interface.
```
$ julia
               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.8.1 (2022-09-06)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
|__/                   |

julia>
```
Feel free to play arround with the REPL to be more familiarized with the language. I encourage checking out the [offical documentation manual](https://docs.julialang.org/en/v1/manual/getting-started/), and this [cool tutorial](https://youtu.be/EkgCENBFrAY?si=DTJ3SP1Shm0wYKTk) by Miguel Raz.

## Assignment 1 : Estimating π
First assignment is about calculating π using the classic "throwing-darts" and "Buffon needles" Monte Carlo algorithms. See *assignment-1.pdf* for further details about the assignment.

To test my code you just need to clone the repository and start a Julia REPL session from there. You can check your current working directory via the ```pwd()``` function and change it via ```cd("/path/to/RandomizedAlgorithms")```. 

I created a custom module named **RandomPi** containing all the functions for the assignment. Import it, along with all its dependencies, by typing
```
include("Assignment1\\main.jl")
```
Now you can execute any of the functions freely
```
fast_darts(10000)
plot_everything()
```
And also measure their performance with the macros from BenchmarkTools!

```
N = 10^6
@btime naive_buffon(N)
@btime fast_buffon(N)
@benchmark master_buffon(10^7, 10^6)
```

## Assignment 2 : Sesquickselect algorithm
Second assignment is about implementing a variation of the quickselect algorithm invented by my teacher and his research collaborators named _Sesquickselect_.

Sesquickselect returns the $m$-smallest element of an unsorted array with an average complexity of $O(n)$. It is similar to the standard _Quickselect_ algorithm in terms of estimated number of comparisons perform, but reduces cache misses.

For more information about the algorithm read the Assignment and the related papers [1], [2], and [3].

To test my code one has to proceed as with the previous assignment, and import the module named **SelectionAlgorithms** into the REPL via:

```
include("Assignment2\\main.jl")
```