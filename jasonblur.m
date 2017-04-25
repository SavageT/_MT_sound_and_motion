
close all

cd('C:\Users\Ione Fine\Documents\Projects\jasonblur')
load blurParamsGaussian_08-Jul-2011

%% create image in the space domain
sz=[720 480];
img=imread('body_01_0.000000.jpg');
[x,y] = meshgrid(linspace(-28/2,28/2,sz(1)+1));
rows=sz(1)/2-sz(2)/2:sz(1)/2+sz(2)/2-1;
x = x(rows,1:end-1);
y = y(rows,1:end-1);

%% put the image in the Fourier domain
for d=1
img_F = myfft2(img(:, :, d),x, y, 1);
end

%% create Gaussian in the space domain
pixperdeg=1/((atan(16.5/65)*180/pi)./360)
sigma=.3560;
g.X=linspace(-4, 4, pixperdeg*8);
G=normpdf(x(1, :),0,g.SD(1));
G=G'*G;
G = G(rows,1:end-1);

%% move Gaussian into the Fourier domain
G_F = myfft2(G,x, y, 1);
Gimg_F=G_F;
Gimg_F.amp=G_F.amp.*img_F.amp;
gimg = myifft2(Gimg_F);

imagesc(gimg)
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