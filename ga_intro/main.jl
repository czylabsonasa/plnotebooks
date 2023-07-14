### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ 4c25c370-21c8-11ee-0347-43efcf43c842
begin
	include("../shared/savemarked.jl")
	savemarked()
end

# ╔═╡ d5d2e576-d068-4f13-b94b-4f954a73edb6
begin
	md"""#### genalg_1
	* simple ga 
	"""
end

# ╔═╡ a6a1ba67-c880-479d-b510-c6c7617be212
begin

# building blocks of the problem
TVAR=Int8
NVAR=5
LB,UB=-10,10
PM=0.05

# a type for individuals
struct X
	val::Float64
	arr::Vector{TVAR}
end

value(x::Vector{TVAR})=sum(x.^2)
eval(x::X)=(x.val=value(x.arr))
	
rand(X)=(arr=TVAR.(Base.rand(LB:UB,NVAR));X(value(arr),arr))

function mutate(x::X)
	IDX=(1:NVAR)[Base.rand(NVAR).<PM]
	x.arr[IDX]=Base.rand(LB:UB,length(IDX))
end

function ucross(p1::X,p2::X,c1::X,c2::X)	
	for (i,t) in enumerate(Base.rand(NVAR))
		c1.arr[i],c2.arr[i]=if t<0.5
			p1.arr[i],p2.arr[i]
		else
			p2.arr[i],p1.arr[i]
		end
	end
end

end

# ╔═╡ 110d4571-b454-4431-9c57-e6a033d263cd
# try
begin
POP=[rand(X) for k in 1:8]
for k in 1:2:4
	p1,p2,c1,c2=POP[k],POP[k+1],POP[k+4],POP[k+4+1]
	ucross(p1,p2,c1,c2)
	mutate(c1)
	mutate(c2)
	eval(c1)
	eval(c2)
end

POP
end

# ╔═╡ Cell order:
# ╠═4c25c370-21c8-11ee-0347-43efcf43c842
# ╠═d5d2e576-d068-4f13-b94b-4f954a73edb6
# ╠═a6a1ba67-c880-479d-b510-c6c7617be212
# ╠═110d4571-b454-4431-9c57-e6a033d263cd
