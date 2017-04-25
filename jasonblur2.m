
%dirname='C:\Users\Ione Fine\Documents\Projects\jasonblur'
%cd(dirname)
k=1;

%% create Gaussian in the space domain
pixperdeg=1./((atan(16.5/65)*180/pi)./360);
sz=[720 480];
[x,y] = meshgrid(linspace(-28/2,28/2,sz(1)+1));
x = x(1:end-1,1:end-1);
y = y(1:end-1,1:end-1);
sigma=.3560;
G=normpdf(x(1, :),0,sigma);
G=G'*G;

%% move Gaussian into the Fourier domain
G_F = myfft2(G,x, y, k);
%G_F.amp=1000*G_F.amp./sum(G_F.amp(:));
G_F.amp=G_F.amp./max(G_F.amp(:))
%% create image in the space domain
filename=dir(fullfile([dirname, '/*.jpg'])); % get list of files
for ff=1:5; %:length(filename)
   
    img=imread(filename(ff).name);
    figure(ff)
    subplot(1, 2, 1)
    image(img(:, :, :))
    rows=sz(1)/2-sz(2)/2:sz(1)/2+sz(2)/2-1;
    minmax=[min(img(:)) max(img(:)) ];
    
    %% put the image in the Fourier domain
    for d=1:3
        mnlum=img(:, :, d);
        mnlum=mean(mnlum(:));
        tmpimg=mnlum+zeros(sz(1));
        tmpimg(rows,:)=img(:, :, d);
        img_F = myfft2(tmpimg,x, y, k);
        % multiply by normalized gaussian
        img_FG=img_F;
        img_FG.amp=img_FG.amp.*G_F.amp;
        
        %% move resulting image back to space domain
        gimg(ff).img(:, :, d) = myifft2(img_FG);
    end
    subplot(1, 2,2)
    image(uint8(gimg(1).img(rows, :, :)));
    colormap(gray)
end




%
%
% Gaussian = exp(-F.sf.^2/sigma^2);
% F.amp = F.amp.*Gaussian;
% lowPassImg = myifft2(F);
% plotFFT2(lowPassImg,x,y,k,20);
%
% va=14.24*2;
%
% x=1:720;
% cpi=[15 40];
% dpc=va./cpi;
% cpd=1./dpc
% tmp=sin(x/max(x)*cpi(1)*2*pi)+sin(x/max(x)*cpi(2)*2*pi);
% img=scaleif(tmp, -1, 1);
%
% plot(x, img, 'b'); hold on
%
%
%
%
% G_conv=conv(img,G1, 'same');
% plot(G_conv, 'r')