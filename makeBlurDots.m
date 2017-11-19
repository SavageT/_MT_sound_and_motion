function [dotRect,dotTexture]=makeBlurDots(display, dots, csf, blur)

csfR=(csf.res.meanSens./max(csf.res.meanSens));
csfR(end)=0;
sf=csf.res.sf;

if blur==1


nn = dots.size; % MAKE SURE THE DOT IS AN EVEN NUMBER OF PIXELS
[xx yy] = meshgrid(1:(nn), 1:(nn));
dotImg =((xx-((nn)/2)).^2 + (yy-((nn)/2)).^2 <= ((nn)/2).^2);
dotImg=padarray(dotImg,[(round(nn)) (round(nn))]);

dotImgB1=CalculateMMfilt(dotImg,csf.display.pxPerDeg,sf,csfR);%orig
dotImgB1=CalculateMMfilt(dotImg,display.pxPerDeg,sf,csfR);
dotImgB2=(dotImgB1+abs(min(dotImgB1)));
dotImgB3=(dotImgB2./max(dotImgB2(:))*255);

dotImgA=dotImgB3;
dotImgA([dotImgB3<4])=0;
dotImgA([dotImgA>4])=255;

if isfield(dots,'color')==0
dotImg3=cat(3,dotImgA,dotImgA,dotImgA,dotImgB3);
else
    
    col=dots.color/255;
    
    dotImg3=cat(3,dotImgA*col(1),dotImgA*col(2),dotImgA*col(3),dotImgB3);
end


elseif blur==0
    

nn = dots.size; % MAKE SURE THE DOT IS AN EVEN NUMBER OF PIXELS
[xx yy] = meshgrid(1:(nn), 1:(nn));
dotImg =((xx-((nn)/2)).^2 + (yy-((nn)/2)).^2 <= ((nn)/2).^2);
dotImg=padarray(dotImg,[(round(nn/3)) (round(nn/3))]);
dotImg=double(dotImg)*255;
dotImg3=cat(3,dotImg,dotImg,dotImg,dotImg);
end

%%Make img rect sizes, location, and textures
dotRect = [0 0 size(dotImg3,1) size(dotImg3,2)];
% dotRect = [0 0 size(xx,1) size(yy,1)];


 dotTexture=Screen('MakeTexture', display.windowPtr, dotImg3);

%pass those into our main structs

dots.dotRect=dotRect;
dots.dotTexture=dotTexture;