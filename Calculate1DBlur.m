function [G_conv, g]=Calculate1DBlur(g, grating1D)
% blurs images according to a filter (made from 2 Gaussians)
% designed to match Mike's CSF
% Takes as input:
% grating1D: A 2D matrix where each column is a separate 1D vector to be
% blurred
% g: parameters of the filter

if strcmp(g.version, 'Gaussian')
    G1=g.A(1).*normpdf(g.X,0,g.SD(1));
    g.G=G1;
    g.G=g.G./sum(g.G(:));
elseif strcmp(g.version, 'MexicanHat')
    G1=g.A(1).*normpdf(g.X,0,g.SD(1));
    G2=g.A(2).*normpdf(g.X,0,g.SD(2));
    g.G=G1+G2;
    g.G=g.G./sum(g.G(:));
elseif strcmp(g.version, 'Piecewise')
    G=[g.Gfit g.Gfit(end:-1:1)];
    G=G(:);
    ii=linspace(1, length(G), round(g.size*g.ppd));
    Gii=interp1(1:length(G),G,ii);
    g.G=reshape(Gii, length(Gii), 1);
    g.G=g.G./sum(g.G(:));
else
    disp('Sorry, filter fit methods not recognized');
end

% convolve with gratings of the same sf as presented to MM and find the max output
for s=1:size(grating1D, 2)
    G_conv(s)=max(conv(g.G, grating1D(:, s)));
end
G_conv=G_conv./max(G_conv);

