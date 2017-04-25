
clear all
close all
PsychJavaTrouble

%% setup
% subject=inputdlg('Enter the subject ID:'  );
% nblock = inputdlg('Enter block number:');

subject='test'
nblock='1'


savedir = 'C:\Dropbox\MT Sound Motion';
experiment = 'BehAudInfluence_VisMot_7levels_MM';
saveIt = 1;

%% get opt seq (example-001.par)

list_rand = randperm(10);
filename = ['test_AV15level-00', int2str(list_rand(1)), '.par'];

[tri,conNum] = textread(filename,'%f%d%*[^\n]');
conNum (find(conNum == 0)) = []; % take out null cond added by optseq2

% InitializeMatlabOpenGL

%% Generate p.order
for i = 1: length(conNum)
   % p.disp.coherence = [0 0.1 0.2 0.3 0.4 .5 0.6 0.7 1];
    if ceil (conNum(i)/2) == 1 %for conNum 1 and 2
        p.order(i, 1) = 2; % .1 coherence 
    elseif ceil (conNum(i)/2) == 2 %for conNum 3 and 4
        p.order(i, 1) = 3; % .2 coherence 
    elseif ceil (conNum(i)/2) == 3 %for conNum 5 and 6
        p.order(i, 1) = 4; % .3 coherence 
        
    elseif ceil (conNum(i)/2) == 4 %for conNum 7 and 8
        p.order(i, 1) = 5; % .4 coherence 
    elseif ceil (conNum(i)/2) == 5 %for conNum 9 and 10
        p.order(i, 1) = 6; % .5 coherence     
    elseif ceil (conNum(i)/2) == 6 %for conNum 11 and 12
        p.order(i, 1) = 7; % .6 coherence     
    elseif ceil (conNum(i)/2) == 7 %for conNum 13 and 14
        p.order(i, 1) = 8; % .7 coherence         
    end
    % fix conNum 15 (0% coherence)
    if conNum(i) == 15
       p.order(i, 1) = 1;
    end
    
    % p.order(i,2) right/left of test visual motion 
    if mod(conNum(i), 2) == 0
        p.order(i, 2) = 2; % left
    else
        p.order(i, 2) = 1; % right
    end    
end

% p.order (i,3) right/left of accompany auditory motion
% possible auditory order 
aud_order = unique (perms([1 1 2 2]), 'rows'); % 1 right 2 left
for i = 1:max(p.order(:,1))
    indL = find (p.order(:,1) == i & p.order (:,2) == 1);
    if isempty(indL) ~= 1
        p.order(indL, 3) = aud_order(randi(size(aud_order,1)), :);
    end
    indR = find (p.order(:,1) == i & p.order (:,2) == 2);
    if isempty(indR) ~= 1
        p.order(indR, 3) = aud_order(randi(size(aud_order,1)), :);
    end
end

%% Block Duration
    
p.blockDur=3; % stimulus block duration
%% resp output
% exp.order = p.order;
exp.resp = zeros(length(p.order),1);
exp.resptime = zeros(length(p.order),1);


%% display  
display.screenNum = 1;
% display.dist = 68;     % 68 in scanner % measured Sept 2013 for 32-channel
% display.width = 32.25;     % 32.25 in scanner; visual angle ~26.68
display.dist = 50; %%50; %laptop % 57 display++
display.width = 28.5; %28.5; %laptop % 70 display++
display.skipChecks = 1;
display.bkColor = zeros(1,3);
display.fixation.size = 1 ; % increase from 0.5 (default) to 1 for MM
display.fixation.color = {[255,0,0],[0,0,0]}; % change fixation color from white to red for MM
display.fixation.mask = 3; % default is 2 deg
 
%% Dots Parameters

%p.disp.dotSize = .15;        % diameter of dots in degrees (.6 Saenz 2003)(.15 Serences 2007)
p.disp.dotSize = 1;  %%  MM
p.dotDensity = 0.3;    %% MM
p.disp.direction = [90 270];
% p.disp.coherence = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7]; 

% % p.disp.coherence = [0.0250 0.0500 0.0750 0.1000 0.1250 0.1500 0.1750 0.2000 0.2250 0.2500]; 
p.disp.coherence = [0 0 .1 .2 .3 .4 .5 .5];
% p.disp.coherence = linspace(.02,.16,8); %Tristram's best values {self}
% p.disp.coherence = linspace(0,.35,8); %Ione's proposed values
% p.disp.coherence = linspace(.30,.75,8); 
% dots structure for moving dots
% dots.coherence and dots.direction to be defined in the loop
dots.speed = 12; % deg/sec
dots.lifetime = 36;        % lifetime in frames increased from 12 for MM

dots.apertureSize = [16, 16];   % diameter in degrees
dots.center = [0, 0];
dots.color = [255, 255, 255];
dots.nDots = round( p.dotDensity * pi*(dots.apertureSize(1)/2)^2 );




%% do it 

% load premade auditory motion 60s long


%%My cars
% load car_316_hz_02 
% stimNorm60s=repmat(stimNorm60s',1,20)'; stimFlippedNorm60s=repmat(stimFlippedNorm60s',1,20)';
% p.Fs = 41000;

%%fangs cars
% load stimAV60s 
% p.Fs = 41000;

%%groffs cars
load AuditoryMotionStimuli
ramp=ones(size(audR));
for i=1:2
    ramp(351:850,i)=linspace(0,1,500);
    ramp(end-499:end,i)=linspace(1,0,500);
end
audR=audR.*ramp;
audL=audL.*ramp;
pad=zeros(size(audL));
stimNorm60s=[audR;pad];
stimFlippedNorm60s=[audL;pad];
stimNorm60s=repmat(stimNorm60s',1,60)'; 
stimFlippedNorm60s=repmat(stimFlippedNorm60s',1,60)'; 
p.Fs = 36104;






startingID = ((randperm(60)-1)*p.Fs)+1;
endingID = startingID + p.Fs*0.5 -1; %500ms

display = OpenWindow(display);
dots.size = angle2pix(display,p.disp.dotSize);

% HideCursor
drawFixation(display);
drawText(display, [0 1],'Waiting to initiate',255*ones(1,3));


GetChar;
drawFixation(display);
tic
startTime = GetSecs;

while GetSecs < startTime + 2.25
    drawFixation(display)
end
    
for block = 1:size(p.order,1)
    if p.order(block, 3)== 1 % right
        stim = stimNorm60s(startingID(block):endingID(block), :);
    elseif p.order(block, 3) == 2 % left
        stim = stimFlippedNorm60s(startingID(block):endingID(block), :);
    end
    while GetSecs < startTime + p.blockDur*(block-1)+2.75
        drawFixation(display);
        sound(stim./max(stim(:)), p.Fs)
        dots.direction = p.disp.direction(p.order(block, 2));
        dots.coherence = p.disp.coherence(p.order(block, 1));
        movingDots(display, dots, 0.5)% 500ms dots
    end
    
    %FlushEvents;p
    while GetSecs < startTime + p.blockDur*(block-1) + 5.25
        [keyIsDown, timeSecs, keyCode ] = KbCheck;
        if keyIsDown
            exp.resp(block, 1) = find(keyCode); % 37 'left arrow key' (left); 39 'right arrow key' (right)
            exp.resptime(block, 1) = timeSecs - startTime- p.blockDur*(block-1)-2.75;
            if keyCode==27;break;end
            while KbCheck; end  % clear the keyboard buffer
        end
    end
    
    while GetSecs < startTime + 2.75 + p.blockDur*(block-1)
        drawFixation(display);
    end
    
end

ShowCursor
Screen('CloseAll');

endTime=GetSecs;
totalDur=endTime-startTime;

keys=exp.resp; kR=keys==39; keys(kR)=1;
kL=keys==37; keys(kL)=2;

cong=p.order(:,2)==p.order(:,3);
incong=~cong;
hits=p.order(:,2)==keys;
incongHits=hits; incongHits(~cong)=[];
congHits=hits; congHits(cong)=[];
totalAcc=sum(hits);

for i=1:max(p.order(:,1))
    hitTempC=hits;
    congTemp=cong;
mask=p.order(:,1)==i;
hitTempC(~mask)=[];
congTemp(~mask)=[];
hitTempI=hitTempC;
hitTempC(~congTemp)=[]; %congruent score
hitTempI(congTemp)=[]; %incongruent score

acc{i}{1}=hitTempC;
acc{i}{2}=hitTempI;
acc{i}{3}=sum(hitTempC + hitTempI);
acc{i}{4}=acc{i}{3}/(length(hitTempC) + length(hitTempI));
bGra(i)=acc{i}{4};
bGraI(i)=(sum(hitTempI)/length(hitTempI));
bGraC(i)=(sum(hitTempC)/length(hitTempC));
end
exp.acc=acc;
exp.barA=bGra;
exp.barC=bGraC;
exp.barI=bGraI;
%% save the data
if saveIt
    chdir(savedir)
    %dateTime = getDateTime;
    vec=datevec(now);
    yyyymmdd=sprintf('%04d%02d%02d', vec(1), vec(2), vec(3));
    hhmm=sprintf('%02d%02d', vec(4), vec(5));
    fileName = sprintf('S%s_%s_%s_%s_%s_%s',char(subject),yyyymmdd,hhmm,experiment,char(nblock)); %year; month; day; hour; minute
    saveStr = sprintf('save %s p exp',fileName);
    eval(saveStr);
    disp(['saved ',fileName])
    % go back
    cd ..
end



