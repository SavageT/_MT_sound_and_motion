function filtimg=CalculateMMfilt(img,pixperdeg,sf,csf)
% filtimg=CalculateMMfilt(img, params, scFac, sf, csf)
%
% Blurs image with a lowpass filter designed to match Mike's CSF
% Calculates the fft of an image, filters out high sf, then remakes image
% 
% Input:
%   img: unfiltered image
%   params: info about the screen
%   scFac: image scaling factor
%   sf: spatial frequencies used to test MM
%   csf: sensitivity function

%%Geoff's name removed :) 

% n is the Nyquist limit
n=round((pixperdeg)/2);
sx=ceil(size(img,2)/2);
sy=ceil(size(img,1)/2);

% take fourier transform
fftimg=fft2(img);

%create a matrix of spatial frequencies
[x,y]=meshgrid(linspace(0,n,sx),linspace(0,n,sy));
r=sqrt(x.^2+y.^2);

%interpolate csf to create the filter
% quadfilt=resample(sf,csf,r);
quadfilt=interp1(sf,csf,r);
quadfilt(isnan(quadfilt))=0;

%fill in the inverse fft filter by filling all four quadrants
fftfilt=zeros(size(img));
fftfilt(1:sy,1:sx)=quadfilt;
fftfilt((end-sy+2):end,1:sx)=flipud(quadfilt(2:end,:));
fftfilt(1:sy,(end-sx+2):end)=fliplr(quadfilt(:,2:end));
fftfilt((end-sy+2):end,(end-sx+2):end)= ...
flipud(fliplr(quadfilt(2:end,2:end)));

%multiply the fft of the image by the fft filter
fftfiltimg=fftimg.*fftfilt;

%take the inverse fft to get the filtered image
filtimg=ifft2(fftfiltimg);