### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ a2c302a2-bee3-4fc0-abe7-34e3e35e98be
begin
	import Pkg
	Pkg.activate(".")

	
	Pkg.add.(
		[
			"StatsBase",
		]
	)
	Pkg.instantiate()

	using
		StatsBase
end

# ╔═╡ 4c25c370-21c8-11ee-0347-43efcf43c842
begin
	include("../shared/savemarked.jl")
	savemarked()
end

# ╔═╡ d5d2e576-d068-4f13-b94b-4f954a73edb6
begin
	md"""#### genalg_1
	* discrete ga - 
	"""
end

# ╔═╡ a6a1ba67-c880-479d-b510-c6c7617be212
begin

# building blocks of the problem
const TVAR=Int8                           # type of the vars
const NVAR=5                              # num of vars
const LB,UB=-10,10                        # lower and upper bound 4 vars
const DOM=TVAR.(collect(LB:UB))           # the domain of vars
const PM=0.05                             # prob of mutation

mutable struct TGENE                # type for the genes
	arr::Vector{TVAR}           
	val::Float64
end

# min -> max of the negative
value(x::Vector{TVAR})=sum(x.^2)
value!(x::TGENE)=x.val=value(x.arr)    

function mutate(x::TGENE)
	IDX=(1:NVAR)[rand(NVAR).<PM]
	x.arr[IDX]=rand(DOM,length(IDX))
end


function cross(p1::TGENE,p2::TGENE,c1::TGENE,c2::TGENE)	
	for i in 1:NVAR
		c1.arr[i],c2.arr[i]=if rand()<0.5
			p1.arr[i],p2.arr[i]
		else
			p2.arr[i],p1.arr[i]
		end
	end
end

# random gene
choose(TGENE)=(arr=rand(DOM,NVAR);TGENE(arr,value(arr)))


const POP_SIZE=10
const MAXSTEP=100

function ga()
	POP=[choose(TGENE) for k in 1:2POP_SIZE]
	for step in 1:MAXSTEP
		w=Weights([exp(-POP[i].val) for i in 1:POP_SIZE])
		idx=sample(1:POP_SIZE, w, POP_SIZE; replace=true)
		for i in 1:2:POP_SIZE
			p1,p2,c1,c2=POP[idx[i]],POP[idx[i+1]],POP[i+POP_SIZE],POP[i+POP_SIZE+1]
			cross(p1,p2,c1,c2)
			mutate(c1)
			mutate(c2)
			value!(c1)
			value!(c2)
		end
		sort!(POP; by=x->x.val)
		println(POP[1].val)
	end
end

end

# ╔═╡ 110d4571-b454-4431-9c57-e6a033d263cd
# ╠═╡ disabled = true
#=╠═╡
# try
begin
POP=[choose(TGENE) for k in 1:8]
for k in 1:2:4
	p1,p2,c1,c2=POP[k],POP[k+1],POP[k+4],POP[k+4+1]
	cross(p1,p2,c1,c2)
	mutate(c1)
	mutate(c2)
	eval(c1)
	eval(c2)
end

POP
end
  ╠═╡ =#

# ╔═╡ d0be687d-e3b6-4cd0-9f14-e01935717ba0
ga()

# ╔═╡ Cell order:
# ╟─4c25c370-21c8-11ee-0347-43efcf43c842
# ╠═d5d2e576-d068-4f13-b94b-4f954a73edb6
# ╠═a2c302a2-bee3-4fc0-abe7-34e3e35e98be
# ╠═a6a1ba67-c880-479d-b510-c6c7617be212
# ╠═110d4571-b454-4431-9c57-e6a033d263cd
# ╠═d0be687d-e3b6-4cd0-9f14-e01935717ba0
