 function variable=ThreeupOnedown(variable,correct, step); 
%
% determines the value of the dependent variable for a 3 up 1 down staircase,
% takes as input:
%			 - the current value of the dependent variable 
%(0 would mean the comparison stimulus is the same as the standard
%			 - the list of correct/incorrect responses
%			 - the stepsize of the staircase
% returns the new value of the dependent variable
%
% the step size is multiplied by two for the first 20 trials
% in case the starting value for the dependent variable is 
%far away from threshold
%
% written by if 7/2000

% if less than twenty trials, double the step size
if length(correct)<15;
   step=step*3;
end;

% if incorrect, increase the difference 
if correct(length(correct))==0;
   variable=variable+step;
   % if correct, reduce the difference
elseif (length(correct)>=3 & sum(correct(length(correct)-2:length(correct)))>=3);
   variable=variable-step;
end

% make sure you don't go "over the top" 
if variable<0;
   variable=0;
end;

