% DrawBlurDots.m Uses somewhat clever indexing to insert multiple copies of
% small images (dots) into a big image.  Draws a single frame for a single
% set of dots.

% Size of big image (pixels)
m = 420;
n = 640;

% Size of small image (pixels, assume it fits in a square)
nn = 45;

% generate the small image
[xx,yy] = meshgrid(linspace(-1,1,nn));

% Gaussian
dotImg = exp(-(xx.^2+yy.^2)/.5^2);

figure(1)
clf
imagesc(dotImg);
axis equal
axis off
colormap(gray);
truesize

% Find the pixels in the small image that above a threshold.  These are the
% only ones that we will be using.
id = find(dotImg(:)>.05);

% Find the indices to these non-black pixels
[idx,idy] = ind2sub([nn,nn],id);

% Create a blank big image to be filled with dots
img = zeros(m,n);
nDots = 100;
dotCenter = round([rand(nDots,1)*(n-nn),rand(nDots,1)*(m-nn)]);
img = zeros(m,n);

% This should be the fast part: add the small images into the big image
tic
for i=1:nDots
    newId =   idy+dotCenter(i,2) + (idx+dotCenter(i,1))*m;
    img(newId) = img(newId)+dotImg(id);
end
toc

% Show the big image
figure(2)
clf
imagesc(img)
axis equal
axis tight
colormap(gray);