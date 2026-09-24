function [mode]  = markov_chain(seed,P,state)
  N = size(P,1);
    for j = 1 : N 
        pi_aux = [0 cumsum(P(state,:))];
        if seed > pi_aux(j) && seed <= pi_aux(j+1)
           mode = j;
        end
   end


