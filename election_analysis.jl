#analyze election to see the largest popular vote margin and still win election with 270 electoral votes
using DataFrames
using MathProgBase
using GLPKMathProgInterface
#using Gurobi 
using JuMP





function election_margin(ev,pop)
	nstates = size(ev,1)
    m = Model(solver=GLPKSolverMIP())

    # Variable for each state going to Trump
    @defVar(m, trump_states[i=1:nstates], Bin)

    # Trump wins election contsraint
    @addConstraint(m, sum{trump_states[i]*ev[i], i=1:nstates} >= 270)

    # Objective (maximize Hillary popular vote margin)
    @setObjective(m, Max, sum{pop[i]*(1-trump_states[i]), i=1:nstates}
                         +sum{(pop[i]/2-1)*trump_states[i], i=1:nstates}
						 -sum{(pop[i]/2+1)*trump_states[i], i=1:nstates}
                  )

    # Solve the integer programming problem
    println("Solving Problem...")
    @printf("\n")
    status = solve(m);


    # Puts the output of one lineup into a format that will be used later
    if status==:Optimal
        trump_state_copy = Array(Int64, 0)
        for i=1:nstates
            if getValue(trump_states[i]) >= 0.9 && getValue(trump_states[i]) <= 1.1
                trump_state_copy = vcat(trump_state_copy, fill(1,1))
            else
                trump_state_copy = vcat(trump_state_copy, fill(0,1))
            end
        end
        return(trump_state_copy)
    end
end

function election_results(trump_states,ev,pop)
	nstates = size(ev,1)
	ev_hillary = 0;
	ev_trump = 0;
	pop_hillary = 0;
	pop_trump = 0;

	for i = 1:nstates
		if trump_states[i]==1
			ev_trump = ev_trump+ev[i]
			pop_trump = pop_trump+pop[i]/2+1
			pop_hillary = pop_hillary+pop[i]/2-1
		else
			ev_hillary = ev_hillary+ev[i]
			pop_hillary = pop_hillary+pop[i]
		end
	end
	return (ev_trump,ev_hillary,pop_trump,pop_hillary)
end


function write_output(path_to_output,trump_states,state_names,ev,pop)
	str = "State,Trump,ElectoralVotes, Population\n"
	for i = 1:nstates
		str1 = string(state_names[i], "," ,trump_states[i], "," ,ev[i], "," ,pop[i],"\n")
		str = string(str,str1)
	end
	outfile = open(path_to_output, "w")
	write(outfile, str)
	close(outfile)
end

####################################################
filename = "State_populations.csv";
path_to_output = "Results2016.csv";

data = readtable(filename);
state_names = data[:State]
ev = data[:ElectoralVotes]
pop = data[:Population]

trump_states = election_margin(ev,pop);
(ev_trump,ev_hillary,pop_trump,pop_hillary) = election_results(trump_states,ev,pop)
write_output(path_to_output,trump_states,state_names,ev,pop);
println("\nResults\tTrump\t\tHillary")
println("Electoral College\t" ,ev_trump,"\t",ev_hillary)
println("Popular Vote\t", round(pop_trump/1e6)," million\t",round(pop_hillary/1e6), " million")
println("Difference = ", round((pop_hillary-pop_trump)/1e6), " million votes\n")



