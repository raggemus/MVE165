"""
  Construct and returns the model of this assignment.
"""
function build_model(relax_x::Bool = false, relax_z::Bool = false)
  m = Model()

#  c2=zeros(10,150,T+1)

  cc=hcat(c, zeros(length(Components),1))
  cits(i,s,t) = (t-s <= U[i]) ? (cc[i,t]) : (T*(maximum(d) + length(Components)*maximum(c)) + 1)
  # for s in 0:T, t in s+1:T+1,i in Components
  # if (t -s) <= U[i]
  #     global  c2[i,j,k]= c[i,t]
  #   elseif
  #     global  c2[i,j,k]= (T*(maximum(d) + length(Components)*maximum(c)) + 1
  # end
  # end


  if relax_x
    @variable(m, x[Components, s in 0:T,s+1:T+1] >= 0)
  else
    @variable(m, x[Components, s in 0:T,s+1:T+1] >= 0, Bin)
  end
  if relax_z
      @variable(m, z[1:T] <= 1)
  else
      @variable(m, z[1:T] <= 1, Bin)
  end

    #objective function
    @objective(m,Min,sum(d[t]*z[t] for t in 1:T)
      + sum(cits(i,s,t)*x[i,s,t]
      for i in Components,s in 0:T,t in s+1:T+1))

      #1b
    @constraint(m,[i in Components,t in 1:T],
      sum(x[i,s,t] for s in 0:t-1) <= z[t])

      #1c
    @constraint(m,[i in Components, t in 1:T],
      sum(x[i,s,t] for s in 0:t-1)
      == sum(x[i,t,r] for r in t+1:T+1))

      #1d
    @constraint(m,[i in Components],
      sum(x[i,0,t] for t in 1:T+1) == 1)





  return m, x,z
end
"""
  Adds the constraint:  z[1] + x[1,2] + x[2,2] + x[1,3] + x[2,3] + z[4] >= 2
  which is a VI for the small instance
"""
function add_cut_to_small(m::Model)
  @constraint(m, z[1] + x[1,2] + x[2,2] + x[1,3] + x[2,3] + z[4] >= 2)
end


# @objective(m,Min,sum(d[t]*z[t] for t in s+1:T+1)
# + sum(c[i,s,t]*x[i,s,t] for i in Components,
# for s in 0:T,for t in (s+1):(T+1)))


#Components - the set of components
#T - the number of time steps in the model
#d[1,..,T] - cost of a maintenance occasion
#c[Components, 1,..,T] - costs of new components
#U[Components] - lives of new components
