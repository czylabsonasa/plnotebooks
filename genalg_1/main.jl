### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 271ac99b-2526-450f-91a4-fe036faa0bc8
begin
  include("../shared/savemarked.jl")
	
  import Pkg
  Pkg.activate(".")

  Pkg.add.([
	  "StatsBase", 
	  "DataStructures", 
	  "Distributions",
	  "CairoMakie",
  ])

  Pkg.instantiate()

  using 
  	StatsBase, 
	DataStructures, 
	Distributions,
	CairoMakie
end

# ╔═╡ 8d0ebf43-77ed-42ee-a9f9-d050d72ff45e
md"""
| runit | savemarked | jlformat |
|---|---|---|
|$(@bind _runit html"<input type=checkbox >")|$(@bind _savemarked html"<input type=button value='savemarked'>")|$(@bind _jlformat html"<input type=button value='jlformat'>")|
"""

# ╔═╡ 85edbabf-920c-45b4-8310-fe7e779035c9
begin
  _savemarked
  savemarked()
end

# ╔═╡ d5d2e576-d068-4f13-b94b-4f954a73edb6
begin
  md"""#### genalg_1
    * implementation based on (at least partly) [this](https://pub.towardsai.net/genetic-algorithm-ga-introduction-with-example-code-e59f9bc58eaf), with source on [github](https://github.com/towardsai/tutorials/blob/master/genetic-algorithm-tutorial/implementation.py)
  * the parameter names modified to my taste
  """
end

# ╔═╡ a6a1ba67-c880-479d-b510-c6c7617be212
# the prototype

begin
  # num of vars
  const DIM = 5                              

  # the type for cromosomes
  mutable struct TCHROM
    arr::Vector{Float64}
    obj::Float64
  end

  # the function to be minimized
  obj(x) = sum(x .^ 2)
  obj!(x::TCHROM) = x.obj = obj(x.arr)

  # lower and upper bound 4 the vars
  const LB, UB = -10, 10                        
	
  # during the mutate event the variables/coordinates can leave the domain, 
  # this adjust back them
  # scalar variant
  adjust(x)=min(UB,max(LB,x))

  function adjust!(x::TCHROM)
    x.arr .= adjust.(x.arr)
  end

  
  SIGMUT=0.1#*(UB - LB)
  mutdist = Normal(0, SIGMUT)
  mutstep() = rand(mutdist)
  mutate(x)= adjust(x + mutstep())

  # prob of mutation
  const PMUT = 0.08                             
  function mutate!(x::TCHROM)
    IDX = (1:DIM)[rand(DIM).<PMUT]
    x.arr[IDX] = mutate.(x.arr[IDX])
  end

  function cross!(p1::TCHROM, p2::TCHROM, c1::TCHROM, c2::TCHROM)
    for i = 1:DIM
      c1.arr[i], c2.arr[i] = if rand() < 0.5
        p1.arr[i], p2.arr[i]
      else
        p2.arr[i], p1.arr[i]
      end
    end
  end

  # random chromosome
  choose(;n=1) = rand(Uniform(LB, UB),n)
  choose(TCHROM) = (arr=choose(;n=DIM);TCHROM(arr, obj(arr)))

  const POP_SIZE = 50
  const OFF_SIZE = 40 # must be even and ≤ than POP_SIZE
  # reversing the obj values (to be able to use the weighted `sample`, 
  # smaller obj -> larger prob. of choosing)
  const BETA=1.0

  function selection(pool,POP,OFF)
	w = Weights([exp(-POP[i].obj) for i = 1:POP_SIZE])
	idx = sample(1:POP_SIZE, w, OFF_SIZE; replace = true)
	for i = 1:2:OFF_SIZE
	  p1, p2 = POP[idx[i]], POP[idx[i+1]]
	  c1, c2= OFF[i], OFF[i+1]
	  cross!(p1, p2, c1, c2)
	  mutate!(c1); obj!(c1)
	  mutate!(c2); obj!(c2)
	end
	sort!(pool; by = x -> x.obj)

	pool[1]
  end



  const MAXSTEP = 500
  # the process will stop at `step` if gbest[step] and gbest[step-idle+1] close to each other (no improvement in the last `idle` length interval)	
  const STOP = (idle = min(30,floor(0.1 * MAXSTEP)) |> Int, tol = 1e-9)  
  function ga0()
    trace=[]
    gbest = choose(TCHROM); gbest.obj = Inf
	  
    tail = CircularBuffer{Float64}(STOP.idle)
    for i = 1:STOP.idle
      push!(tail, Inf)
    end

    status = ("MAXSTEP", MAXSTEP)
	pool_size=(POP_SIZE+OFF_SIZE)
    pool = [choose(TCHROM) for k = 1:pool_size]
	
	POP = view(pool,1:POP_SIZE)
	OFF = view(pool,(POP_SIZE+1):pool_size)
    for step = 1:MAXSTEP
      lbest = selection(pool,POP,OFF)
	  
	  #println(POP)
	  
	  
      if lbest.obj < gbest.obj
        gbest = deepcopy(lbest)
      end
	  push!(trace,gbest.obj)
		
      push!(tail, gbest.obj)
      if last(tail) + STOP.tol > first(tail)
        status = ("IDLE", step)
        break
      end
    end # of main loop
    gbest, status, trace

  end

end

# ╔═╡ d0be687d-e3b6-4cd0-9f14-e01935717ba0
begin
  if _runit
	best,status,trace=ga0()
	println(best," ",status)
	#scatter(Float32.(log.(trace)))
	scatter(Float32.(log.(trace)))
  end
end

# ╔═╡ Cell order:
# ╟─8d0ebf43-77ed-42ee-a9f9-d050d72ff45e
# ╟─85edbabf-920c-45b4-8310-fe7e779035c9
# ╠═271ac99b-2526-450f-91a4-fe036faa0bc8
# ╟─d5d2e576-d068-4f13-b94b-4f954a73edb6
# ╠═a6a1ba67-c880-479d-b510-c6c7617be212
# ╠═d0be687d-e3b6-4cd0-9f14-e01935717ba0
