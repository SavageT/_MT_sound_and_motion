function movingDots(display,dots,duration)
% movingDots(display,dots,duration)
%
% Animates a field of moving dots based on parameters defined in the 'dots'
% structure over a period of seconds defined by 'duration'.
%
% The 'dots' structure must have the following parameters:
%
%   nDots            Number of dots in the field
%   speed            Speed of the dots (degrees/second)
%   direction        Direction 0-360 clockwise from upward
%   lifetime         Number of frames for each dot to live
%   apertureSize     [x,y] size of elliptical aperture (degrees)
%   center           [x,y] Center of the aperture (degrees)
%   color            Color of the dot field [r,g,b] from 0-255
%   size             Size of the dots (in pixels)
%   coherence        Coherence from 0 (incoherent) to 1 (coherent)
%
% 'dots' can be an array of structures so that multiple fields of dots can
% be shown at the same time.  The order that the dots are drawn is
% scrambled across fields so that one field won't occlude another.
%
% The 'display' structure requires the fields:
%    width           Width of screen (cm)
%    dist            Distance from screen (cm)
% And can also use the fields:
%    skipChecks      If 1, turns off timing checks and verbosity (default 0)
%    fixation        Information about fixation (see 'insertFixation.m')
%    screenNum       screen number
%    bkColor         background color (default is [0,0,0])
%    windowPtr       window pointer, set by 'OpenWindow'
%    frameRate       frame rate, set by 'OpenWindow'
%    resolution      pixel resolution, set by 'OpenWindow'

% 3/23/09 Written by G.M. Boynton at the University of Washington


%Calculate total number of dots across fields
nDots = sum([dots.nDots]);

%Zero out the color and size vectors
colors = zeros(3,nDots);
sizes = zeros(1,nDots);

%%T.s. addition
% blurshader = Create2DGaussianBlurShader(100);

%% create the blur dot
nn = 44; % MAKE SURE THE DOT IS AN EVEN NUMBER OF PIXELS
% generate the small image
[xx,yy] = meshgrid(linspace(-1,1,nn));
% Gaussian
%dotImg=255*ones(nn);
dotImg = 255*exp(-(xx.^2+yy.^2)/.5^2);
%dotImg(:, :, 2)=exp(-(xx.^2+yy.^2)/.5^2);
dotTexture=Screen('MakeTexture', display.windowPtr, dotImg);
dotRect = [0 0 size(dotImg,1) size(dotImg,2)];

%% Intitialize the dot positions and define some other initial parameters
%Calculate the left, right top and bottom of each aperture (in degrees)
l = dots.center(1)-dots.apertureSize(1)/2;
r = dots.center(1)+dots.apertureSize(1)/2;
b = dots.center(2)-dots.apertureSize(2)/2;
t = dots.center(2)+dots.apertureSize(2)/2;

%Generate random starting positions
dots.x = (rand(1,dots.nDots)-.5)*dots.apertureSize(1) + dots.center(1);
dots.y = (rand(1,dots.nDots)-.5)*dots.apertureSize(2) + dots.center(2);

%Create a direction vector for a given coherence level
direction = rand(1,dots.nDots)*360;
nCoherent = ceil(dots.coherence*dots.nDots);  %Start w/ all random directions
direction(1:nCoherent) = dots.direction;  %Set the 'coherent' directions

%Calculate dx and dy vectors in real-world coordinates
dots.dx = dots.speed*sin(direction*pi/180)/display.frameRate;
dots.dy = -dots.speed*cos(direction*pi/180)/display.frameRate;
dots.life =    ceil(rand(1,dots.nDots)*dots.lifetime);

%Zero out the screen position vectors and the 'goodDots' vector
pixpos.x = zeros(1,nDots);
pixpos.y = zeros(1,nDots);
goodDots = false(zeros(1,nDots));

%Calculate total number of temporal frames
nFrames = secs2frames(display,duration);

%% Loop through the frames

for frameNum=1:nFrames
    %  count = 1;
    
    %Update the dot position's real-world coordinates
    dots.x = dots.x + dots.dx;
    dots.y = dots.y + dots.dy;
    
    %Move the dots that are outside the aperture back one aperture width.
    dots.x(dots.x<l) = dots.x(dots.x<l) + dots.apertureSize(1);
    dots.x(dots.x>r) = dots.x(dots.x>r) - dots.apertureSize(1);
    dots.y(dots.y<b) = dots.y(dots.y<b) + dots.apertureSize(2);
    dots.y(dots.y>t) = dots.y(dots.y>t) - dots.apertureSize(2);
    
    %Increment the 'life' of each dot
    dots.life = dots.life+1;
    
    %Find the 'dead' dots
    deadDots = mod(dots.life,dots.lifetime)==0;
    
    %Replace the positions of the dead dots to random locations
    dots.x(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(1) + dots.center(1);
    dots.y(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(2) + dots.center(2);  
    
    %Calculate the screen positions for this field from the real-world coordinates
    x = angle2pix(display,dots.x)+ display.resolution(1)/2;
    y = angle2pix(display,dots.y)+ display.resolution(2)/2;
    destRect=[x-nn/2; y-nn/2; x+nn/2; y+nn/2];
    
    %Determine which of the dots in this field are outside this field's
    %elliptical aperture
    goodDots = (dots.x-dots.center(1)).^2/(dots.apertureSize(1)/2)^2 + ...
        (dots.y-dots.center(2)).^2/(dots.apertureSize(2)/2)^2 < 1;
    
    Screen('DrawTextures', display.windowPtr, dotTexture, dotRect, destRect);

    drawFixation(display);
end

end

