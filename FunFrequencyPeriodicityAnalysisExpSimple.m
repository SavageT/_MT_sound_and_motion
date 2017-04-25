clear all
close all
addpath('Z:\Dropbox\_FYP\Stimuli\GRS_stimfiles_final')

nStim=10; % number of stimulus pairs
nTrials=17;
stepsize=.01;
nFreq=14;
filename=['IF_FreqPeriod_orig26b_', datestr(now, 'hh-mmmm-dd-yyyy')];
nPeriods=1000;
if nPeriods==40
    Fs=36000;
elseif nPeriods==20
    Fs=36000/2;
elseif nPeriods==10
    Fs=36000/4;
elseif nPeriods==1000;
    Fs=36000;
end
audioFilenames=Stim_List_final; %returns audioFilenames

%list=reshape(Shuffle(1:nStim*2), nStim, 2);

%list=[11    14;    8     7;  3    20;    2    19;    16    15;   9     1;   4    13;   5    10;    6    12;   17    18];
list=[ 32 21;   40    25;  22    37;   34    31; 35    27;  30    26;   33    36;  38    23;  28    24;  29    39];

disp('compiling stimulus structures');
for n=1:nStim
    stim(n).mixval=.1;
    stim(n).correct=[];
    stim(n).resp=[];
    stim(n).whichint=Shuffle(repmat([1:3]', ceil(nTrials/3), 1));
    stim(n).whichbase=Shuffle(repmat([1:2]',ceil(nTrials/2), 1));
    stim(n).whichtrial=1;
    [y1, Fs1]=audioread(audioFilenames{list(n, 1)});y1=y1(1:2*Fs1)';
    [y2,Fs2] = audioread(audioFilenames{list(n, 2)});y2=y2(1:2*Fs2)';
    y1i=interp1(1:2*Fs1,y1, linspace(1, 2*Fs1, Fs*2));
    y2i=interp1(1:2*Fs2,y2, linspace(1, 2*Fs2, Fs*2));
    if nPeriods==1000
        [stim(n).y1recon]=y1i;
        [stim(n).y2recon]=y2i;
    else
        [stim(n).y1recon, stim(n).F, stim(n).M]=FrequencyPeriodicityAnalysis(y1i', Fs, nFreq, nPeriods);
        [stim(n).y2recon, stim(n).F, stim(n).M]=FrequencyPeriodicityAnalysis(y2i', Fs, nFreq, nPeriods);
    end
    if size(stim(n).y1recon)~=size(stim(n).y2recon)
        disp('size error'); return; end
    disp(['finished compiling ', num2str(n)])
    soundsc(stim(n).y1recon,Fs);pause(2+.5)
    soundsc(stim(n).y2recon,Fs);
end

stimorder=Shuffle(repmat([1:nStim]', nTrials, 1));  % order to present
disp('starting to run');
Snd('Play',sin(0:.06:300));
for n=1:length(stimorder)
    disp(num2str(n));
    mix=stim(stimorder(n)).mixval(end);
    y=((1-mix).*stim(stimorder(n)).y1recon) + mix.*stim(stimorder(n)).y2recon;
    dur = length(y)/Fs;
    for i=1:3
        % if using the original as oddman
        if i==stim(stimorder(n)).whichint(stim(stimorder(n)).whichtrial) && stim(stimorder(n)).whichbase(stim(stimorder(n)).whichtrial)==1
            soundsc(y,Fs); % original sound
        elseif i~=stim(stimorder(n)).whichint(stim(stimorder(n)).whichtrial) && stim(stimorder(n)).whichbase(stim(stimorder(n)).whichtrial)==1
            soundsc(stim(stimorder(n)).y1recon,Fs); % original sound
            % using scrambled as oddman
        elseif i==stim(stimorder(n)).whichint(stim(stimorder(n)).whichtrial) && stim(stimorder(n)).whichbase(stim(stimorder(n)).whichtrial)==2
            soundsc(stim(stimorder(n)).y1recon,Fs); % mixed sound
        else
            soundsc(y,Fs); % mixed sound
        end
        pause(dur+.5)
    end
    FlushEvents;
    ch='x';
    while ch ~='1' & ch~='2' & ch~='3'
        [ch, when] = GetChar;
    end
       stim(stimorder(n)).resp=cat(1,stim(stimorder(n)).resp, ch);
    tic
    if str2num(stim(stimorder(n)).resp(stim(stimorder(n)).whichtrial))==stim(stimorder(n)).whichint(stim(stimorder(n)).whichtrial)
        stim(stimorder(n)).correct=cat(1,stim(stimorder(n)).correct, 1);
        Snd('Play',sin(0:.3:1500));
    else
        stim(stimorder(n)).correct= cat(1,stim(stimorder(n)).correct, 0);
        Snd('Play',sin(0:.03:150));
    end
    variable=ThreeupOnedown(stim(stimorder(n)).mixval, [stim(stimorder(n)).correct], stepsize);
    if variable(end)<=0; variable(end)=0; end
    stim(stimorder(n)).whichtrial=stim(stimorder(n)).whichtrial+1;
    stim(stimorder(n)).mixval(stim(stimorder(n)).whichtrial)=variable(end); % add the mixer for the trial to come
end

save(filename)

