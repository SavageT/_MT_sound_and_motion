function  p=CDFNorm(v,x)

% p=CDFNorm(v,x)
% Rearranges input values and sends it to normcdf to make 
% compatible with plotpsych


p =normcdf(x, v.t, v.s);
