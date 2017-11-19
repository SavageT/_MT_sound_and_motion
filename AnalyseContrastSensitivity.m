% Analyses ContrastSensitivity Data

% clear all
close all


%% add directories (LHchange)
initstr='C:\Dropbox\__Projects\_MT_sound_and_motion';
addpath([initstr]);

%% load file to be analysed
[file,path] = uigetfile('*.mat','Select data file to be analysed');
cd(path);
load(file);

% normalize results
normMeanSens=[csf.res(:).meanSens]./max([csf.res(:).meanSens]);


%% insert data from other CSF function

sflist=csf.pars.sfList;
if csf.pars.dispType==1
    
    grating=csf.pars.gratings;
    
elseif csf.pars.dispType==2
    boom {not square}
end


% gratingtmp(:, :, 2:8)=grating;
% clear grating;
% grating=gratingtmp;


%% plot results
figure; clf;
subplot(1, 3, 1)
plot(sflist, normMeanSens, '.k-', 'MarkerSize', 20); hold on
%errorbar(sflist, normMeanSens, normStdSens, 'k', 'LineStyle', ...
%   'none', 'Marker', 'none', 'LineWidth', 1);
title('CSF')
xlabel('spatial frequency');
ylabel('sensitivity');
hold on

%% fit blur function
% set of sinusoids in 1024 pixel space that match sflist
grating1D=squeeze(grating(1, :, :));
g.ppd=csf.display.pxPerDeg;

%% MEXICAN HAT
% create a Mexican hat fit for the CSF that is g.size degrees in size
g.A=[4 -.5];
g.SD=[1 2];
g.size=1;
g.version='MexicanHat';
g.X=linspace(-g.size/2, g.size/2, round(g.size*g.ppd));
g=fit('FitCSF', g,{'A', 'SD'},  grating1D,normMeanSens);
[G_conv, g]=Calculate1DBlur(g, grating1D);

% plot fitted CSF based on Mexican Hat
subplot(1, 3, 1);
plot(sflist, G_conv, '.--','Color', 'r',  'MarkerSize', 20, 'MarkerFaceColor', [1 1 1]);

% plot the Mex hat filter in space
subplot(1, 3, 2)
plot(g.X,g.G, 'r');
xlabel('screen width in degrees')
ylabel('amplitude of filter')
title('filter in space');
hold on

% save  results
[file,path] = uiputfile('*.mat','Save Data As', [path, 'blurParamsMexHat_', date, '.mat']);
cd(path);
save(file, 'g');


%% GAUSSIAN
g.A=[1];
g.SD=[1];
g.size=1;
g.version='Gaussian';
g.X=linspace(-g.size/2, g.size/2, round(g.size*g.ppd));
g=fit('FitCSF', g,{'A', 'SD'},  grating1D,normMeanSens);
[G_conv, g]=Calculate1DBlur(g, grating1D);

% plot fitted CSF based on Gaussian
subplot(1, 3, 1);
plot(sflist, G_conv, '.--','Color', 'm',  'MarkerSize', 20, 'MarkerFaceColor', [1 1 1]);

% plot the Gaussian filter in space
subplot(1, 3, 2)
plot(g.X,g.G, 'm');
xlabel('screen width in degrees')
ylabel('amplitude of filter')
title('filter in space');
hold on

% save Gaussian results
[file,path] = uiputfile('*.mat','Save Data As', [path, 'blurParamsGaussian_', date, '.mat']);
cd(path);
save(file, 'g');

%% PIECEWISE
g.A=NaN;
g.SD=NaN;
g.size=1;
g.npts=10;
g.version='Piecewise';
g.Gfit=ones(g.npts, 1);
g.X=linspace(-g.size/2, g.size/2, round(g.size*g.ppd));

g=fit('FitCSF', g,{'Gfit'},  grating1D,normMeanSens);
[G_conv, g]=Calculate1DBlur(g, grating1D);

% plot fitted CSF based on Piecewise
subplot(1, 3, 1);
plot(sflist, G_conv, '.--','Color', 'b',  'MarkerSize', 20, 'MarkerFaceColor', [1 1 1]);

% plot the Piecewise filter in space
subplot(1, 3, 3)
plot(g.X,g.G, 'b');
xlabel('screen width in degrees')
ylabel('amplitude of filter')
title('filter in space');

% save  results
[file,path] = uiputfile('*.mat','Save Data As', [path, 'blurParamsPiecewise_', date, '.mat']);
cd(path);
save(file, 'g');
