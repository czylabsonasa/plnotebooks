### A Pluto.jl notebook ###
# v0.19.25

using Markdown
using InteractiveUtils

# ╔═╡ d7387866-b1de-49ec-88ff-8ece60b887d7
begin
	import Pkg
	Pkg.activate(".")

	
	Pkg.add.(
		[
			"DelimitedFiles",
			"Graphs", 
			"StatsBase",
		]
	)
	Pkg.instantiate()

	using
		DelimitedFiles,
		Graphs,
		StatsBase
end

# ╔═╡ a58cad7c-7d7f-4af9-86d1-800cdeea518f
begin
	include("../shared/savemarked.jl")
	savemarked()
end

# ╔═╡ 3c6f89d7-0ddf-4901-963b-901c8495fdae
# now deal w/ the original data of project_1
begin
include("../shared/graphcol_1_data.jl")
data=graphcol_1_data()
G=data.G
num_of_students=data.num_of_students
num_of_courses=data.num_of_courses
header=data.header	
end

# ╔═╡ 9bb6db3e-f84e-4d5e-b095-44e90954b6a4
begin
# deal w/ long running cell(s)
runall=true
printstyled(stderr,"runall is $(runall)\n",color=:light_red)
end

# ╔═╡ 1146a1a4-208e-11ee-3e56-5b164f873592
begin
	md"""#### graphcol_2
	* the graph is 9-colorable, it would be interesting to know that 8 or less color is enough or not.
	* for this purpose, we'll develop (actually i wrote it for a [codesignal](https://codesignal.com) interview question...) a simple function in julia, that can be used to compute the chromatic number for *very small* graphs: `graphcol_bt`	
	"""
end

# ╔═╡ 2175207f-9699-4e54-b783-417d4268a44f
begin

#--->graphcol_bt
	
# the backtracking solution
# it is a naive implementation w/o any smartness,
# just administration

function graphcol_bt(G::Vector{Vector{Int}},maxcol::Int) # max number of colors
	# the actual color are in 1..maxcol
	N=length(G)
	
	forbidden=fill(0,maxcol,N) 
	# colors currently forbidden for a particular node
	# forbidden=already reserved by some of its neighbour
	# reserved if >0
	
	# actual and returned colorings
	color=fill(0,N) # for work with
	color_ret=fill(0,N)
	
	# modifies the forbidden and color arrays
	function paint(node,c)
		oldc=color[node]
		if oldc>0
			for t in G[node]
				forbidden[oldc,t]-=1
			end
		end
	
		color[node]=c
		(c==0) && return
		
		for t in G[node]
			forbidden[c,t]+=1
		end
	end
	
	found=false
	paint(1,1)
	
	function trav(node)
		if node>N
			found=true
			color_ret.=color
			return
		end
	
	
		for c in 1:maxcol
			(forbidden[c,node]>0) && continue
			paint(node,c)
			trav(node+1)
			found && break
		end
	
		paint(node,0) # restore the original state
	end # of trav
	
	trav(2)
	(found,color_ret)
end


# a method (variant) that takes a Graph() instance and returns a similar
# object that is returned by Graphs.random_greedy_color
# (imitating by namedtuple)
function graphcol_bt(G::Graph,maxcol::Int) # max number of colors
	GG=[Int[] for n in 1:nv(G)]
	for e in edges(G)
		a,b=src(e),dst(e)
		push!(GG[a],b)
		push!(GG[b],a)    
	end
	found,color=graphcol_bt(GG,maxcol)
	if found
		(num_colors=length(Set(color)),colors=color)
	else
		(num_colors=-1,colors=nothing)
	end
end

#--->graphcol_bt
	
end

# ╔═╡ 6fc964df-9337-45cc-90a1-c3bbdb11065c
begin
	n=rand(3:2:9)
	G2=cycle_graph(n)
	@time the_coloring=graphcol_bt(G2,3);println(the_coloring)
	@time failed=graphcol_bt(G2,2);println(failed)
	if runall==true
		# and use graphcol_bt for the original data of project_1
		@time the_coloring=graphcol_bt(G,9);println(the_coloring)
		@time failed=graphcol_bt(G,8);println(failed)
	end
end

# ╔═╡ c254f378-0fed-4e2b-ba84-2270715c55df
begin
	md"""
	#### Conclusion
	* even for this small graph this backtracking solution is very slow, but after executing it we can be sure that fewer than 9 colors (exam dates) is not enough.
	"""
end

# ╔═╡ Cell order:
# ╠═9bb6db3e-f84e-4d5e-b095-44e90954b6a4
# ╠═a58cad7c-7d7f-4af9-86d1-800cdeea518f
# ╠═1146a1a4-208e-11ee-3e56-5b164f873592
# ╟─d7387866-b1de-49ec-88ff-8ece60b887d7
# ╠═2175207f-9699-4e54-b783-417d4268a44f
# ╠═3c6f89d7-0ddf-4901-963b-901c8495fdae
# ╠═6fc964df-9337-45cc-90a1-c3bbdb11065c
# ╠═c254f378-0fed-4e2b-ba84-2270715c55df
