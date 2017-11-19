function [fixRectSz,fixRectLoc,fixTexture]=makeBlurFix(display, csf)

csfR=(csf.res.meanSens./max(csf.res.meanSens));
csfR(end)=0;
sf=csf.res.sf;
sf = [0;sf];
csfR = [1;csfR];


%%Make the fixation img
 display=getFixation(display);
fc=display.fixation.sz(3);
% fch=fc/2;
% fc=fc@; %test to make fix smaller
fr1=display.fixation.sz(1);
fr2=display.fixation.sz(2);


[rr cc] = meshgrid(1:fc*2);
fixCirc=~(sqrt((rr-(fc)).^2+(cc-(fc)).^2)<=fc);

fixCirc=(sqrt((rr-(fc)).^2+(cc-(fc)).^2)<=fc)*255;


% fixCircB=CalculateMMfilt(fixCirc,csf.display.pxPerDeg,sf,csfR); %orig
fixCircB=CalculateMMfilt(fixCirc,display.pxPerDeg,sf,csfR); %using current ppD

fixRect=uint8(ones(fc*2,fc*2,3));

if isfield(display.fixation,'color')==1
fixRect(fc-fr1:fc+fr1,fc-fr1:fc+fr1,1)=display.fixation.color(1); 
fixRect(fc-fr1:fc+fr1,fc-fr1:fc+fr1,2)=display.fixation.color(2);
fixRect(fc-fr1:fc+fr1,fc-fr1:fc+fr1,3)=display.fixation.color(3);
fixRect(fc-fr2:fc+fr2,fc-fr2:fc+fr2,1:3)=0;

else
        %default red
fixRect(fc-fr1:fc+fr1,fc-fr1:fc+fr1,1)=255; 
fixRect(fc-fr2:fc+fr2,fc-fr2:fc+fr2,1:3)=0;
end

fixImgG=imgaussfilt(fixRect,5); %%Manual blur


padVal=floor((size(fixCirc,1)-size(fixImgG,1))/2);
fixImgG=padarray(fixImgG,[padVal padVal],'both');
fixImgG(:,:,4)=uint8(fixCirc)*255; %orig

fixImg=fixImgG;

%%Make img rect sizes, location, and textures
fixRectSz = [0 0 size(fixImg,1) size(fixImg,2)];

fixRectLoc=[-fc+display.fixation.center(1),-fc+display.fixation.center(2),...
    fc+display.fixation.center(1),fc+display.fixation.center(2)];

fixTexture=Screen('MakeTexture', display.windowPtr, fixImg);


