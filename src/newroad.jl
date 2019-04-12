#Generating a random road by connecting 2 nodes:
#simple example
using OpenStreetMapX
using OpenStreetMapXPlot
using OpenStreetMapXDES
using LightGraphs
using Plots
using SparseArrays
using DataStructures
using Statistics

pth = "C:/RoadsConstructionOpt/Roboczy/"
name = "mapatest2.osm"

@time map = OpenStreetMapX.parseOSM(joinpath(pth,name))
map_data =  OpenStreetMapX.get_map_data(pth,name,use_cache = false)
m=map_data


A=rand(m.n)
B=rand(m.n)
C=(A[2],B[2])
push!(m.e,C)
m.w[A[1],B[1]]=get_distance(A[1],B[1], m.nodes,m.n)
push!(m.class,4) #Example

sim_data=get_sim_data(m,N,l)
get_distance(A[1],B[1], m.nodes,m.n) = 10 #ToDo - calculate
