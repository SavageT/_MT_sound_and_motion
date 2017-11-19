function [fixRect,fixTexture]=fixationComplex2RealBlur(display, csf, blur)


% Normalize and add value of 1 for 0 c/deg
csfR=(csf.res.meanSens./max(csf.res.meanSens));
csfR(end)=0;
sf=csf.res.sf;
sf = [0;sf];
csfR = [1;csfR];

%%Make the fixation img
display=getFixation(display);
fc=display.fixation.sz(3);
fch=fc/2;
fr1=display.fixation.sz(1);
fr2=display.fixation.sz(2);

[rr cc] = meshgrid(1:fc);
fixCirc=~(sqrt((rr-(fch)).^2+(cc-(fch)).^2)<=fch);
fixCirc=(sqrt((rr-(fch)).^2+(cc-(fch)).^2)<=fch)*255;

fixRect=uint8(ones(fc,fc));
fixRect(fch-fr1:fch+fr1,fch-fr1:fch+fr1,1)=255;
fixRect(fch-fr2:fch+fr2,fch-fr2:fch+fr2,1)=0;

% Take the 2D fft of the dot image

fftImg = complex2real2(fft2(fixRect),rr,cc);

% Interpolate mike's csf into the sf's of the dot image's sfs

interpCSF = interp1(sf,csfR,fftImg.sf(:),'linear',0);
interpCSF = reshape(interpCSF,size(fftImg.sf));

% Attenuate the amplitudes of the fft of the dot image by the interpolated
% CSF
fftImgFilt = fftImg;
fftImgFilt.amp = fftImgFilt.amp.*interpCSF;

% Invert the FFT to get the filtered dot image
ImgFilt = real(ifft2(real2complex2(fftImgFilt)));


ImgFilt2=ImgFilt./max(ImgFilt(:));

ImgFilt2(:,:,4)=uint8(fixCirc)*255; 




% dotTexture=Screen('MakeTexture', display.windowPtr, dotImgFinal);
% dotRect = [0 0 size(dotImgFinal,1) size(dotImgFinal,2)];

end