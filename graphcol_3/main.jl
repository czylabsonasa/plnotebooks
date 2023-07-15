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

# ╔═╡ 5f3aba34-63bf-41bd-9765-81c22345f59e
begin
  include("../shared/savemarked.jl")
  import JuliaFormatter

  import Pkg
  Pkg.activate(".")


  Pkg.add.(["Graphs", "StatsBase"])
  Pkg.instantiate()

  using Graphs, StatsBase
end

# ╔═╡ 0523fb39-6160-405e-9d74-2c5178835ca4
begin

  # test 
  include("../shared/graphcol_bt.jl")
  G = loadgraph("../data/col-instances/queen5_5.lg")
  opt = parse(Int, read("../data/col-instances/queen5_5.opt", String))
  @time graphcol_bt(G, opt - 1) |> println
  @time graphcol_bt(G, opt) |> println
  @time greedy_color(G, reps = 33) |> println

end

# ╔═╡ ad753282-425f-4034-92e9-57d00bee9263
md"""
| runit | savemarked | jlformat |
|---|---|---|
|$(@bind _runit html"<input type=checkbox >")|$(@bind _savemarked html"<input type=button value='savemarked'>")|$(@bind _jlformat html"<input type=button value='jlformat'>")|
"""

# ╔═╡ e73f4b2e-3b33-48bc-8622-69d21689de8e
begin
  _savemarked
  savemarked()
end

# ╔═╡ 4852c4db-9a69-413f-ac3b-39acd64ed2fa
begin
  _jlformat
  JuliaFormatter.format("main.jl"; indent = 2)
end

# ╔═╡ d61c96d0-20ae-11ee-0550-b51324cdd3af
begin

  md"""
  #### graphcol_3
  * graph loader/converter for dimacs `col` format: `loadcol`
    * the `tolg` parameter for converting the data into the default `lg` format
  * the data is from [Michael Trick's page](https://mat.gsia.cmu.edu/COLOR/instances.html)
  * dimacs is an old/simple format described [here](https://mat.gsia.cmu.edu/COLOR/general/ccformat.ps)"""

end

# ╔═╡ c6dc32db-b8d8-407b-af43-903babe275ba
#--->loadcol

# .col extension is a must
function loadcol(gfile::String; tolg = false, toopt = false)
  _e(msg) = error("loadcol: $(msg)")

  !isfile(gfile) && _e("no such file")
  sfile = split(gfile, '.')
  (sfile[end] != "col") && _e("wrong extension")
  gstring = split(read(gfile, String), '\n', keepempty = false)

  num_colors = -1
  E = []
  nV, nE, tV = -1, -1, -1
  for line in gstring
    sline = split(line, keepempty = false)
    (sline[1] == "c") && continue

    if sline[1] == "p" # only the last counts, but must precede the first 'p' line, bcos it  is used in a sanity check
      nV, nE = parse.(Int, sline[3:end])
      continue
    end
    if sline[1] == "e"
      a, b = parse.(Int, split(line)[2:end])
      if a < 1 || a > nV || b < 1 || b > nV
        _e("vertex is out of range")
      end
      push!(E, (a, b))
      continue
    end
    if sline[1] == "num_colors"
      num_colors = parse(Int, sline[2])
      continue
    end
  end
  if nV < 0 || nE < 0 || length(E) != nE
    _e("wrong data")
  end
  G = Graph()
  add_vertices!(G, nV)
  for (a, b) in E
    add_edge!(G, a, b)
  end
  if tolg == true
    sfile = join(sfile[1:end-1], '.')
    savegraph("$(sfile).lg", G)
    printstyled(stderr, "saved $(sfile).lg\n"; color = :green)
  end
  if num_colors > 0 && toopt == true
    open("$(sfile).opt", "w") do f
      println(f, num_colors)
    end
    printstyled(stderr, "saved $(sfile).opt\n"; color = :yellow)
  end
  G
end

#--->loadcol

# ╔═╡ 6ca7c713-a728-4565-b048-3960dff08f1d
#### convert the col's to lg's
for f in readdir("../data/col-instances/"; join = true)
  sf = split(f, '.')
  if sf[end] == "col"
    jf = join(sf[1:end-1], '.')
    isfile("$(jf).lg") && isfile("$(jf).opt") && continue
    loadcol(f; tolg = true, toopt = true)
  end
end

# ╔═╡ Cell order:
# ╠═ad753282-425f-4034-92e9-57d00bee9263
# ╠═e73f4b2e-3b33-48bc-8622-69d21689de8e
# ╠═4852c4db-9a69-413f-ac3b-39acd64ed2fa
# ╠═d61c96d0-20ae-11ee-0550-b51324cdd3af
# ╠═5f3aba34-63bf-41bd-9765-81c22345f59e
# ╠═c6dc32db-b8d8-407b-af43-903babe275ba
# ╠═6ca7c713-a728-4565-b048-3960dff08f1d
# ╠═0523fb39-6160-405e-9d74-2c5178835ca4
