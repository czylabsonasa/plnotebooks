### A Pluto.jl notebook ###
# v0.19.26

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

# ╔═╡ a2c302a2-bee3-4fc0-abe7-34e3e35e98be
begin
	include("../shared/savemarked.jl")
	import Pkg
	Pkg.activate(".")

	
	Pkg.add.(
		[
			"StatsBase",
			"DataStructures"
		]
	)
	Pkg.instantiate()

	using
		StatsBase, 
		DataStructures
end

# ╔═╡ 88bca062-8dbd-41da-8602-369411046d46
md"""
runit $(@bind _runit html"<input type=checkbox >")
$(@bind _savemarked html"<input type=button value='savemarked'>")
"""

# ╔═╡ 85edbabf-920c-45b4-8310-fe7e779035c9
begin
  _savemarked
  savemarked()
end

# ╔═╡ d5d2e576-d068-4f13-b94b-4f954a73edb6
begin
	md"""#### genalg_1
	* a simple genetic algorithm: `ga0()`
	"""
end

# ╔═╡ a6a1ba67-c880-479d-b510-c6c7617be212
begin

# building blocks of the problem
const TVAR=Int8                           # type of the vars
const TOBJ=Float64                        # for simplicity float is used
const INF=typemax(TOBJ)
const NVAR=5                              # num of vars
const LB,UB=-10,10                        # lower and upper bound 4 vars
const DOM=TVAR.(collect(LB:UB))           # the domain of vars
const PMUT=0.05                             # prob of mutation

mutable struct TCHROM                # type for the chromosome
	arr::Vector{TVAR}           
	val::TOBJ
end

value(x::Vector{TVAR})=sum(x.^2)
value!(x::TCHROM)=x.val=value(x.arr)    

function mutate!(x::TCHROM)
	IDX=(1:NVAR)[rand(NVAR).<PMUT]
	x.arr[IDX]=rand(DOM,length(IDX))
end


function cross(p1::TCHROM,p2::TCHROM,c1::TCHROM,c2::TCHROM)	
	for i in 1:NVAR
		c1.arr[i],c2.arr[i]=if rand()<0.5
			p1.arr[i],p2.arr[i]
		else
			p2.arr[i],p1.arr[i]
		end
	end
end

# random chromosome
choose()=(arr=rand(DOM,NVAR);TCHROM(arr,value(arr)))


const POP_SIZE=50
const MAXSTEP=200
const STOP=(
	idle=floor(0.1*MAXSTEP)|>Int,
	tol=1e-4
)  # will stop at `step` if gbest[step] and gbest[step-idle+1] close to each other (no improvement in the last `idle` interval)
function ga0()
	gbest=choose(); gbest.val=Inf
	tail=CircularBuffer{TOBJ}(STOP.idle)
	for i in 1:STOP.idle
		push!(tail,INF)
	end
	
	status=("MAXSTEP",MAXSTEP)
	POP=[choose() for k in 1:2POP_SIZE]
	for step in 1:MAXSTEP
		w=Weights([exp(-POP[i].val) for i in 1:POP_SIZE])
		idx=sample(1:POP_SIZE, w, POP_SIZE; replace=true)
		for i in 1:2:POP_SIZE
			p1,p2,c1,c2=POP[idx[i]],POP[idx[i+1]],POP[i+POP_SIZE],POP[i+POP_SIZE+1]
			cross(p1,p2,c1,c2)
			mutate!(c1)
			mutate!(c2)
			value!(c1)
			value!(c2)
		end
		sort!(POP; by=x->x.val)
		lbest=POP[1]
		#println(lbest.val)
		
		
		if lbest.val<gbest.val
			gbest=deepcopy(lbest)
		end
		push!(tail,gbest.val)
		if last(tail)+STOP.tol>first(tail)
			status=("IDLE",step)
			break
		end
	end # of main loop
	gbest,status

end

end

# ╔═╡ d0be687d-e3b6-4cd0-9f14-e01935717ba0
begin
	_runit && 
	@time ga0()|>println
end

# ╔═╡ Cell order:
# ╟─88bca062-8dbd-41da-8602-369411046d46
# ╟─85edbabf-920c-45b4-8310-fe7e779035c9
# ╠═d5d2e576-d068-4f13-b94b-4f954a73edb6
# ╠═a2c302a2-bee3-4fc0-abe7-34e3e35e98be
# ╠═a6a1ba67-c880-479d-b510-c6c7617be212
# ╠═d0be687d-e3b6-4cd0-9f14-e01935717ba0
