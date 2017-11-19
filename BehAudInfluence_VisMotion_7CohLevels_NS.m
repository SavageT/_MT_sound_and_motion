
clearvars -except levels bGrALL
% levels =[];
% bGrALL=[];
close all
PsychJavaTrouble

%% setup
% subject=inputdlg('Enter the sjubject ID:'  );
% nblock = inputdlg('Enter block number:');
choice = questdlg('Did you check SAVEIT, fLux, fNAme?, and block?','HALT!','Yes','No', 'No');

switch choice
    case 'Yes'
           fLux=1;
    case 'No'
        
        fLux=0;
end 

if fLux==0; boom; end


subject='mpNSMD02';
% nblock='1'
nblock = inputdlg('Enter block number:');

% savedir = 'C:\Dropbox\__Projects\_MT_sound_and_motion';
savedir = 'C:\Dropbox\__Projects\_MT_sound_and_motion';

experiment = 'BehAudInfluence_VisMot_7levels';
saveIt = 1;
br=0;
P=0;

%% get opt seq (example-001.par)

list_rand = randperm(10); % directions on each block
filename = ['test_AV15level-00', int2str(list_rand(1)), '.par'];

%load blur filej
% load('blurParamsGaussian_30-Jun-2017.mat')
% load('MikeMay_Fixation34.15.11-08-17.mat')j
load('MikeMay_Freeview25.15.11-08-17.mat')

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

%% block Duration`
p.trialDur=.5; % stimulus block duration
%% resp output
expr.order = p.order;
expr.resp = zeros(length(p.order),1);
expr.resptime = zeros(length(p.order),1);


%% display 
display.screenNum = 2;

% %%Screen and viewing params
% display.dist=57; % in cm       % 68 in scanner % measured Sept 2013 for 32-channel
% display.width=59.69; % in cm % 32.25 in scanner; visual angle ~26.68
% display.height=33.528;% in cmj
% display.pxPerDeg=46.3;J
%%Laptop
% display.dist=57; % in cm       % 68 in scanner % measured Sept 2013 for 32-channel
% display.width=38.26; % in cm % 32.25 in scanner; visual angle ~26.68
% display.height=21.52;% in cm
% display.pxPerDeg=51.74;

display.dist = 50; %%50; %laptop % 57 display++
display.width = 28.5; %28.5; %laptop % 70 difsplay++
display.skipChecks = 1;
display.bkColor = zeros(1,3);
display.fixation.size = 1 ; % increase from 0.5 (default) to 1 for MM
display.fixation.color = [255,0,0]; %,[0,0,0]}; % change fixation color from white to red for MM
display.fixation.mask = 3; % default is 2 degjf

%% Dots Parameters
p.disp.dotSize = 1;  %%  degj
p.dotDensity = 0.3;    %% MMj
p.disp.direction = [90 270];
% p.disp.coherence = [0 .175 .25 .275 .3 .325 .35 .375];\
p.disp.coherence = [0 .075 01 .15 .f2 .25 .3 .45];
% p.disp.coherence = [0 .075 .1 .125 .15 .15 .175 .2];f`
% p.disp.coherence = [0 .1 .15 .2 .25 .275 .3 .35];ffj5J
% p.disp.coherence = [.4 .45j .5 .6 .7 .8 .9 .9];f

% dots structure for moving dotsf
% dots.coherence and dots.direction to be defined in the loop
dots.speed=12; % deg/sec
dots.lifetime = 36;        % lifetime in frames increased from 12 for MM
dots.apertureSize = [16, 16;];   % diameter in degrees
dots.center = [0, 0];
dots.color = [255, 255, 255];
dots.nDots = round( p.dotDensity * pi*(dots.apertureSize(1)/2)^2 );
dots.sizeDeg=p.disp.dotSize; 
blur=1;

% load premade auditory motion 60s long

%%groffs cars
load AuditoryMotionStimuli
ramp=ones(size(audR));

for i=1:2
    ramp(351:850,i)=linspace(0,1,500);
    ramp(end-499:end,i)=linspace(1,0,500);
end

audR2=audR.*ramp;

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
Screen('BlendFunction', display.windowPtr,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
dots.size = angle2pix(display,p.disp.dotSize);
display.pxPerDeg=angle2pix(display,1);


[dotRect,dotTexture]=DotFilteringUsingComplex2Real(display, dots, csf, blur);
[fixRectSz,fixRectLoc,fixTexture]=makeBlurFix(display, csf);

% Screen('CloseAll');
% boom

%pass those into our main structs
display.fixation.fixRectSz=fixRectSz;
display.fixation.fixRectLoc=fixRectLoc;
display.fixation.fixTexture=fixTexture;

dots.dotRect=dotRect;
dots.dotTexture=dotTexture;



%%
%%Begin our dark works....

try 
Screen('DrawTexture', display.windowPtr, fixTexture, fixRectSz, fixRectLoc);
drawText(display, [0 1],'Waiting to initiate',255*ones(1,3));
Screen('Flip',display.windowPtr);
@GetChar;
tic
HideCursor;
startTime = GetSecs;
topPriorityLevel=MaxPriority(display.windowPtr);

    
for block = 1:size(p.order,1)
   
    
    if p.order(block, 3)== 1 % right
        stim = stimNorm60s(startingID(block):endingID(block), :);
    elseif p.order(block, 3) == 2 % left
        stim = stimFlippedNorm60s(startingID(block):endingID(block), :);
    end
    
     FlushEvents;
    blockstartTime = GetSecs;
    PsychHID('KbQueueCreate');PsychHID('KbQueueStart');
    if P==0
        sound(stim./max(stim(:)), p.Fs)
        dots.direction = p.disp.direction(p.order(block, 2));
        dots.coherence = p.disp.coherence(p.order(block, 1));
        
        P=movingDotsSimple(display, dots, p.trialDur);
        
    Screen('DrawTexture', display.windowPtr, fixTexture, fixRectSz, fixRectLoc);
    Screen('Flip',display.windowPtr);
    end
    
    

    
    while GetSecs < blockstartTime + 3; end
    
    
    [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes, lastKeyPressTimes, lastKeyReleaseTimes]=PsychHID('KbQueueCheck');
    PsychHID('KbQueuestop');
    
    
    
    
    if keyIsDown
        
        [kt I]=max(lastKeyReleaseTimes);
        expr.resp(block, 1) = I; % 70'for f' (left); 74 for 'j' (right)
        expr.resptime(block, 1) = kt-blockstartTime;
        
        if any(find(lastKeyReleaseTimes)==82);
            P=0;
        end
        
        if any(find(lastKeyReleaseTimes)==27); br=1;break;end
        
    end
    
    
    
    if br==1;break;end
    
end
%%
catch ME
  Priority(0)
ShowCursor
Screen('CloseAll');  
br=1;
rethrow(ME)
end


Priority(0)
ShowCursor
Screen('CloseAll');

endTime=GetSecs;
totalDur=endTime-startTime;

keys=expr.resp;
kR=keys==70;
kL=keys==74;
keys(kR)=2;
keys(kL)=1;
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

expr.acc=acc;
expr.barA=bGra;
expr.barC=bGraC;
expr.barI=bGraI;

%% save the data
if saveIt && br==0
    chdir(savedir)
    %dateTime = getDateTime;
    vec=datevec(now);
    yyyymmdd=sprintf('%04d%02d%02d', vec(1), vec(2), vec(3));
    hhmm=sprintf('%02d%02d', vec(4), vec(5));
    fileName = sprintf('%s_%s_%s_%s_%s_%s',char(subject),yyyymmdd,hhmm,experiment,char(nblock)); %year; month; day; hour; minute
    saveStr = sprintf('save %s p expr display dots',fileName);
    eval(saveStr);
    disp(['saved ',fileName])
    % go back
    cd ..
end

% bar(bGra)
% 
% levels=[levels p.disp.coherence];
% 
% bGrALL=[bGrALL bGra];
% 
% for z=1:length(p.order(:,1))
% bGrALL

