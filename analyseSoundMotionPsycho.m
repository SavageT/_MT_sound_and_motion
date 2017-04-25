% Analyse Cross Modal Psycho data

% information about data structurs
% p.order(:, 1): visual motion coherence: (0.1-0.7) plus ambiguous
% p.order(:, 2): visual motion direction
% p.order(:, 3): auditory motion direction
% 60 trials per block: 4 per coherence (7) x  per direction (2)  + 4 ambiguous ones
% among the 4 trials,
% 2 has rightward auditory motion (-1)
% 2 has leftward (1)  auditory motion
% 37 is left,  converts to a 1
% 39 is right, converts to a -1

clear all; close all

    cd('C:\Dropbox\_MT Sound Motion');
MyFileInfo = dir('SMM*.mat');

%% collate data

v_coh=[]; v_dir=[]; a_dir=[]; v_resp=[];congruent=[];correct=[];o
for f=1:length(MyFileInfo)
    data=load(MyFileInfo(f).name);
    order=data.p.order;  resp=data.exp.resp; coherence=data.p.disp.coherence;
    for t=1:size(order, 1)
        v_dir=cat(1, v_dir, 2*(order(t, 2)-1.5)); % convert to -1 1
        v_coh=cat(1, v_coh,v_dir(end).*coherence(order(t, 1))); %
        
        a_dir=cat(1, a_dir, 2*(order(t, 3)-1.5)); % convert to -1 1
        v_resp=cat(1,v_resp, -(resp(t)-38));
        congruent=cat(1, congruent, v_dir(end)==a_dir(end)); % two modalities congruent?
        correct=cat(1, correct, v_dir(end)==v_resp(end));
    end
end


%% collate data as a function of direction coherence
coh_levels=unique(v_coh);
for c=1:length(coh_levels)
    
    ind=find(v_coh==coh_levels(c));
    ind_left=intersect(ind, find(a_dir==1));% leftward aud
    n_aL_respL(c)=length(find(v_resp(ind_left)==1));
    n_aL_respR(c)=length(ind_left)-n_aL_respL(c);

    
    ind_right=intersect(ind, find(a_dir==-1));% rightward aud
    n_aR_respL(c)=length(find(v_resp(ind_right)==1));
    n_aR_respR(c)=length(ind_right)-n_aR_respL(c);
    

end

freeList = {'t','s'};
p.t=0; % starting point for coherence threshold
p.s=1; % starting estimate for slope

figure(1); hold on
pL = fit('FitCDFNorm',p, freeList, coh_levels,[n_aL_respL; n_aL_respR]');
plotpsych(coh_levels,[n_aL_respL; n_aL_respR]',pL,'CDFNorm'); hold on
set(gca, 'YLim', [-.1 1.1])
set(gca, 'XLim', [-1 1])
title('aud left')

text(-.6,-0.1, 'right')
text(.6,-0.1, 'left')
xlabel('visual motion coherence')
ylabel('% report left')

% figure; hold on
pR = fit('FitCDFNorm',p, freeList, coh_levels,[n_aR_respL; n_aR_respR]');
plotpsych(coh_levels,[n_aR_respL; n_aR_respR]',pR,'CDFNorm', [], [],[],[], 'r')
set(gca, 'YLim', [-.1 1.1])
set(gca, 'XLim', [-1 1])
title('aud right = red')

text(-.6,-0.1, 'right')
text(.6,-0.1, 'left')
set(gca, 'XLim', [-1 1])
xlabel('visual motion coherence')
ylabel('% report left')

h=text(.6, .6, num2str(round(pR.t, 2)))
set(h, 'Color', 'r')
h=text(.6, .3, num2str(round(pL.t, 2)));
set(h, 'Color', 'b')
