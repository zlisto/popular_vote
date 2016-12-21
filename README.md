# popular_vote
Julia code that calculates the largest possible popular vote margin Donald Trump can lose by and still win 270 electoral college votes in the US presidential election of 2016.

Turns out Trump could win the electoral college with only 22% of the popular vote.

To show this, just run election_analysis.jl in julia and it will solve the optimization problem with tries to minimize Donald Trump's popular vote while still giving him at least 270 electoral college votes, and thus becoming president.  The code assumes if Trump wins a state, he wins by one vote, but if Hillary wins, she wins all the popular vote in the state.  This scenario will give her the largest possible popular vote margin.

FILES:

election_analysis.jl is the julia code with the optimization problem


State_populations.csv contains the population and electoral college votes of each state in 2016.


Results2016.csv returns the results of the optimization problem (who won each state).

