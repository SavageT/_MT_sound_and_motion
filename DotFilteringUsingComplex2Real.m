function [dotRect,dotTexture]=DotFilteringUsingComplex2Real(display, dots, csf, blur)


% Normalize and add value of 1 for 0 c/deg
csfR=(csf.res.meanSens./max(csf.res.meanSens));
csfR(end)=0;
sf=csf.res.sf;
sf = [0;sf];
csfR = [1;csfR];

% Set the size of the dots in degrees
% dots.size=1; % (deg)

% Set the image size
imgSize = dots.sizeDeg*display.pxPerDeg*6;

v = (-imgSize/2:imgSize/2)/display.pxPerDeg;
[xx yy] = meshgrid(v,v);

% Make the dot image
dotImg =sqrt(xx.^2+yy.^2) <= dots.sizeDeg/2;

if blur==1
    
    dotImg=double(dotImg);
    
    % Take the 2D fft of the dot image
    
    fftDotImg = complex2real2(fft2(dotImg),xx,yy);
    
    % Interpolate mike's csf into the sf's of the dot image's sfs
    
    interpCSF = interp1(sf,csfR,fftDotImg.sf(:),'linear',0);
    interpCSF = reshape(interpCSF,size(fftDotImg.sf));
    
    % Attenuate the amplitudes of the fft of the dot image by the interpolated
    % CSF
    fftImgFilt = fftDotImg;
    fftImgFilt.amp = fftImgFilt.amp.*interpCSF;
    
    % Invert the FFT to get the filtered dot image
    dotImgFilt = real(ifft2(real2complex2(fftImgFilt)));
    dotImgFilt2=dotImgFilt;
%     dotImgFilt=dotImgFilt-.0021;
%     dotImgFilt2=dotImgFilt./max(dotImgFilt(:));
    
    % pull out the middle part
    %     dotImgFilt2 = dotImgFilt(abs(xx)<dots.sizeDeg & abs(yy)<dots.sizeDeg);
    %     dotImgFilt2 = reshape(dotImgFilt2,sum(abs(xx(1,:))<dots.sizeDeg),   sum(abs(yy(:,1))<dots.sizeDeg));
    
    %     dotImgFilt2=dotImgFilt; %%to skip reshapiong
    
    cnv=ones(size(dotImgFilt2));
    %     dotImgFinal=uint8(cat(3,dotImgFilt,dotImgFilt,dotImgFilt)*255);
    %     dotImgFinal=uint8(cat(3,dotImgFilt,dotImgFilt,dotImgFilt,dotImgFilt)*255);
    
    
    if isfield(dots,'color')==0
        dotImgFinal=uint8(cat(3,cnv,cnv,cnv,dotImgFilt2)*255);
    else
        
        col=dots.color/255;
        
        dotImgFinal=uint8(cat(3,cnv*col(1),cnv*col(2),cnv*col(3),dotImgFilt2)*255);
        
    end
    
    
else
    dotImg = dotImg(abs(xx)<dots.sizeDeg & abs(yy)<dots.sizeDeg);
    dotImg = reshape(dotImg,sum(abs(xx(1,:))<dots.sizeDeg),   sum(abs(yy(:,1))<dots.sizeDeg));
    cnv=ones(size(dotImg));
    
    if isfield(dots,'color')==0
        dotImgFinal=uint8(cat(3,cnv,cnv,cnv,dotImg)*255);
    else
        
        col=dots.color/255;
        
        dotImgFinal=uint8(cat(3,cnv*col(1),cnv*col(2),cnv*col(3),dotImg)*255);
        
    end
    
    
    
end




dotTexture=Screen('MakeTexture', display.windowPtr, dotImgFinal);
dotRect = [0 0 size(dotImgFinal,1) size(dotImgFinal,2)];

end