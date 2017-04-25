function err=FitCSF(g, grating1D,  meanContrast)
% calculates the filter (made from 2 Gaussians) 
% needed to match Mike's CSF
% is done in terms of pixels not visual angle so this
% filter will not work (without conversion) 
% if display properties
% change

% G_conv is the estimated CSF based on blurring with the mexican hat defined
% by g
[G_conv, g]=Calculate1DBlur(g, grating1D);

% find the difference between the estimated CSF and Mike's actual CSF
err=sum(((G_conv)-(meanContrast)).^2);
