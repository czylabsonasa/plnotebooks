### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ 89b711fa-790a-4199-aed6-21ef644c0083
begin
	import Pkg
	Pkg.activate(".")

	
	# Pkg.add.(
	# 	[
	# 		"DelimitedFiles",
	# 		"Graphs", "Colors",
	# 		"DataFrames", "StatsBase",
	# 		"CairoMakie", "GraphMakie"
	# 	]
	# )
	# Pkg.instantiate()

	using
		DelimitedFiles,
		Graphs,Colors,
		DataFrames, StatsBase,
		CairoMakie, GraphMakie
end

# ╔═╡ 3be28e6d-32b3-4c17-b8c0-b97f4ce66cda
begin
	include("../shared/savemarked.jl")
	savemarked()
end

# ╔═╡ 44f6cc10-a462-4676-ae5e-f6e8372d3d77
begin
	md"""#### project_1"""
end

# ╔═╡ f2d1d317-898e-48b6-8b3d-cf1af8e53176
begin
#--->project_1_data

function project_1_data()
	# read the data
	d0,h0=readdlm(
		"../data/synthetic_school_enrollment_data.csv",','; 
		header=true
	)
	# convert the original data
	
	# drop out the first three columns (name,major/minor)
	# and convert it to a valid logical matrix
	data=map(
		x->if x=="True"
			true
		elseif x=="False"
			false
		else
			throw(error("unknown value"))
		end, 
		d0[:,4:end]
	)
	
	header=h0[4:end]
	num_of_students,num_of_courses=size(data)

	# build the graph:
	# the nodes are the courses with an edge between them if there is a student visiting either.
	
	# first, collect the set of students visiting each courses
	S=[Set((1:num_of_students)[col]) for col in eachcol(data)]
	
	
	# then, use the sets
	G=Graph()
	add_vertices!(G,num_of_courses)
	for i in 1:num_of_courses-1, j in i+1:num_of_courses
		!isdisjoint(S[i],S[j]) && add_edge!(G,i,j)
	end
	(
		G=G,
		num_of_students=num_of_students,num_of_courses=num_of_courses,
		header=header
	)
end

#--->project_1_data


data=project_1_data()
G=data.G
num_of_students=data.num_of_students
num_of_courses=data.num_of_courses
header=data.header
	
end

# ╔═╡ f4d4ad61-d0b0-4c9a-90c9-0b5b5f2a87e8
begin
	# plot the graph
	deg=degree(G)
	scene=graphplot(
		G,
		node_size=deg,
		node_color="Purple",
		edge_color="LightGray",
		edge_width=0.5,
	)
	hidedecorations!(scene.axis)
	scene
end

# ╔═╡ 25ac6b79-c8a3-4c93-9607-59b4c0326134
begin
	# as in networkX in Graph.jl there is a "builtin" method 
	# greedy_color(G; reps) to generate 
	# colorings, therefore we'll use it
	# it returns an object w/ num_colors and colors fields
	# we need col.num_colors dates for the exams
	@time the_coloring=greedy_color(G; reps=1000)
	
end

# ╔═╡ d3fba262-7c12-4b4e-b8cc-46de4cf3829f
begin
	# plotting the graph w/ colors assigned
	# shell layout would be better but 
	# see https://github.com/JuliaGraphs/GraphPlot.jl/pull/186
	dc=distinguishable_colors(the_coloring.num_colors, colorant"blue")

	# first is the innermost
	the_shells=[[] for c in 1:the_coloring.num_colors]
	for v in vertices(G)
		push!(the_shells[the_coloring.colors[v]],v)
	end
	sort!(the_shells, by=x->length(x))
	
	colored_G=graphplot(
		G,
		layout=GraphMakie.Shell(
			;
			nlist=the_shells
		),
		node_size=deg,
		node_color=dc[the_coloring.colors],
		edge_color="LightGray",
		edge_width=0.5,
	)
	hidedecorations!(colored_G.axis)
	colored_G
end

# ╔═╡ 35243cac-b754-41dc-9d7a-988cfc5411fa
begin
	# we need maxcolsize rooms
	cm=the_coloring.colors|>countmap
	mincolsize,maxcolsize=extrema(nc for (c,nc) in cm)
	
	# build the final table
	# exams for courses with the color 'k' will be held on the 'k'-th date given
	table=fill("-",the_coloring.num_colors,maxcolsize) # indices for filling in
	idx=fill(0,the_coloring.num_colors)
	for i in 1:num_of_courses
	  ri=the_coloring.colors[i]
	  ci=(idx[ri]+=1)
	  table[ri,ci]=header[i]
	end
	
	df=DataFrame(
	  hcat("Exam-".*string.(1:the_coloring.num_colors),table),
	  vcat("Exam","Room-".*string.(1:maxcolsize)))
end

# ╔═╡ a75a3f9e-1b93-45cd-923c-7c18dd3b581a
begin
	md"""
	#### Note
	* inspecting the data and the result in the original tutorial more closely one can found that the 2021-06-15 18:00 Bioinformatics and Data Science exams share a student, namely Katrina Scott (Computer Science major/no minor). So, the tutorial's program has some error (which explains why we see different number of edges in the graphs)
	"""
end

# ╔═╡ Cell order:
# ╠═3be28e6d-32b3-4c17-b8c0-b97f4ce66cda
# ╠═44f6cc10-a462-4676-ae5e-f6e8372d3d77
# ╟─89b711fa-790a-4199-aed6-21ef644c0083
# ╠═f2d1d317-898e-48b6-8b3d-cf1af8e53176
# ╠═f4d4ad61-d0b0-4c9a-90c9-0b5b5f2a87e8
# ╠═25ac6b79-c8a3-4c93-9607-59b4c0326134
# ╠═d3fba262-7c12-4b4e-b8cc-46de4cf3829f
# ╠═35243cac-b754-41dc-9d7a-988cfc5411fa
# ╠═a75a3f9e-1b93-45cd-923c-7c18dd3b581a
