function L=FitCDFNorm(v,x,y);
%
%L=FitCDFNorm(v,x,y);
%
%Returns L, the likelihood of observing the psychometric
%data in x and y, 
% given parameter values v for the Cumulative Normal function.
%
%'x' holds the stimulus intensities used in the staircase.
% The first column of y holds the number of correct responses
% for each stimulus strength in x.  The second column holds
% the number of incorrect responses.
% v.t, v.s where t is the stimulus intensity that will give
% 50% probabililty of making wither response (.7939 = (1/2)^(1/3)
% s controls the slope of the psychometric function.

%Written by G. Boynton in the summer of 96.

p=CDFNorm(v, x)';
p=(p*0.99)+.005;

%p=(p'*0.99);
%p=scale(p', .02, .98 ,CDFNorm(v, 0), max(p));
L=-log(1-p)*y(:,2)-log(p)*y(:,1);   
