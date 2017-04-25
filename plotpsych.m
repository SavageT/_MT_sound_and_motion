function match=plotpsych(x,y,v,psychoname,varargin)
%vargin=logflag,gamma,choiceepsilon, xLabel, clrstr, place) 
%match=plotpsych(x,y,v,psychoname,[logflag], gamma,epsilon, xLabel, clrstr, place) 
% 
% draws a graph of raw psychometric data and a fit of a 
% psychometric function to that data. 
% 
%'x' holds the stimulus intensities used in the staircase. 
% The first column of y holds the number of correct responses 
% for each stimulus strenght in x.  The second column holds 
% the number of incorrect responses. 
% v = [u,s] where u is the stimulus intensity that will give 
% 79.37% correct performance.  (.7939 = (1/2)^(1/3), which is 
% the expected percent correct for a three down, one up staircase. 
% s controls the slope of the psychometric function. 
% 
% if logflag = 1, x axis is drawn on a log scale (the default) 
%Written by G. Boynton in the summer of 96 


logflag=0;
place=1;
gamma=0;
clrstr='b';
xLabel='Intensity';
epsilon=(1/2)^(1/3);


if length(varargin)>=1
    logflag=varargin{1};
end
if length(varargin)>=2
    gamma=varargin{2};
end
if length(varargin)>=3
    choiceepsilon=varargin{3};
end
if length(varargin)>=4
    xLabel=varargin{4};
end
if length(varargin)>=5
    clrstr=varargin{5};
end
if length(varargin)>=6
    place=varargin{6};
end

if ~isstr(clrstr)
    clrstr=[clrstr clrstr clrstr];
end

% plot the markers
sums=sum(y')'; 
for i=1:length(x) 
   if logflag 
      plot(log10(x(i)),y(i,1)/sums(i),'b.','MarkerSize',sqrt(sum(y(i,:)))*1) 
   else       
      plot(x(i),y(i,1)/sums(i),'.','MarkerSize',sqrt(sum(y(i,:)))*7, 'Color', clrstr) 
   end 
   hold on 
end 

if logflag 
   xx=10.^(linspace(log10(min(x)),log10(max(x)),100)); 
else 
   xx=linspace(min(x),max(x),100); 
end 
%
str  = (['y = ',psychoname,'(v,xx);']); 
eval(str); 


if logflag 
   plot(log10(xx),y,clrstr) 
   set(gca,'XTick',log10(x)); 
   set(gca,'XLim',log10([min(x),max(x)])); 
else 
   plot(xx,y,'Color', clrstr); 
   %set(gca,'XTick',sort(x)); 
   set(gca,'XLim',[min(x),max(x)]); 
end 
%widen; 
set(gca,'YLim',[-0.05,1.05]); 

% str = (['pthresh = ',psychoname,'(v,xx);']); 
% if nargin<=6 
%    xintercept=v(1);
%    eval(str); 
% else 
%    pthresh = choiceepsilon;
%    xintercept=x(round(end/2));
% %   xintercept=fminsearch('FindXWeibullIntercept', xintercept, [], v, pthresh, gamma);  
% end 
% 
% if logflag 
%    a=line([log10(min(x)),log10(xintercept),log10(xintercept)], ...
%        [pthresh,pthresh,0],'Color',clrstr,'LineStyle',':'); 
% else 
% %   a=line([min(x),xintercept,xintercept], ...
%   %    [pthresh,pthresh,0],'Color',clrstr,'LineStyle',':'); 
% end 
% hold off 
% if logflag 
%    text(log10(v(1))+0.05,pthresh,num2str(xintercept)); 
% else 
%  %  text(xintercept+0.05,pthresh,num2str(round2place(xintercept, place))); 
% end 
% xlabel(xLabel); 
% ylabel('Probability'); 
% if logflag 
%    logx2raw(10,4); 
% end 
% match=v(1); 
