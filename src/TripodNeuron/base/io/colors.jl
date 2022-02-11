using Plots
RED = RGBA(0.889, 0.436,0.278,1)
BLU = RGBA(0,0.605,0.978,1)
GREEN = RGBA{Float64}(0.2422242978521988,0.6432750931576304,0.30444865153411527,1.0)
PURPLE = RGBA{Float64}(0.7644401754934356,0.4441117794687767,0.8242975359232758,1.0)
BROWN =
RGBA{Float64}(0.675544,0.555662,0.0942343,1.0)
BLUGREEN = RGBA{Float64}(4.82118e-7,0.665759,0.680997,1.0)
GREY = RGBA{Float64}(.4,.4,.4,1.)
color_list = [BLU RED GREEN PURPLE BROWN BLUGREEN]
# colors = [:red, :green, :grey, :purple, :yellow, :orange, :lightblue, :blue, :lightgreen, :white]
colormap(L,c1=BLU, c2=RED) = reshape( range(c1, stop=c2,length=L), 1, L );
rectangle(w, h, x, y) = Shape(x .+ [0,w,w,0], y .+ [0,0,h,h])

pyplot()
