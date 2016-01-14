function params = motion_params_constStim()


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      screen params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
screen = struct('num', {1}, 'rectPix',{[0 0  1280 960]}, 'dist', {57}, 'size', {[40 30]},...
                   'res', {[1280 960 ]},'monRefresh', 85, 'calib_filename', {'0001_titchener_130226.mat'}); 
screen.centerPix = [screen.rectPix(3)/2 screen.rectPix(4)/2];
white = 255; black = 0;

gray = (white+black)/2; 
screen.bkColor = gray; screen.black = black; screen.white = white;
% Compute deg to pixels ratio:
ratio = degs2Pixels(screen.res, screen.size, screen.dist, [1 1]);
ratioX = ratio(1); ratioY = ratio(2);
screen.degratioX = ratioX; screen.ppd = ratioX; 
screen.degratioY = ratioY; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            fixation params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Draw fixation cross, sizeCross is the cross size,
% and sizeRect is the size of the rect surronding the cross
fixation = struct( 'color',{[black black black 255]},'dur', {0.5}, 'penWidthPix', {2.5}, 'bkColor', screen.bkColor,...
                      'sizeCrossDeg', {[.5 .5]}, 'colorDisc', {[black black black 255]},'present2ndFix',{1}); 
fixation.sizeCrossPix = degs2Pixels(screen.res, screen.size, screen.dist, fixation.sizeCrossDeg); % {15}
fixation.rectPix = [0 0 fixation.sizeCrossDeg(1)*screen.degratioX fixation.sizeCrossDeg(2)*screen.degratioY];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      stimuli params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stim = struct('dur', {.2}, 'possibleAngels', {[-1 1]},'boundaryAngle', {[0 0]},...
              'radiusDeg',{3}, 'bkColor', {gray}, 'speedDegPerSec', {15},'lifetime', {1},...
              'limitLifetime', {0.05},'apertureCenter',[-5,0,-5,0],'baseAngles', [0,90,180,270],...
              'angleDiff',8,'color',{black});
% [3 357 183 177]
%cw/ccw: Note, response is encoded in response.cw_ccw = [1 2]. Any changes must be done there as well
stim.cw_ccw = [1, 2]; %CW (1) or CCW (2) from the boundary, for example 3deg is CCW from 0deg


% stim.boundaryAngleRad = stim.boundaryAngle*pi/180;
% speed = visual degreee per per second; num =# of dots; coh=propotion moving in designated direction; 
% diam = diameter of circle of dots in visual degrees; lifetime = logical, are dots limited life time or not
% limitLifetime = proportion of dots which will be randomly replaced in  each frame

stim.radiusPix = deg2pix1Dim(stim.radiusDeg, ratioX);
stim.durInFrames = round(stim.dur*screen.monRefresh);
stim.apertureCenterPix = [stim.apertureCenter(1)*screen.degratioX, stim.apertureCenter(3)*screen.degratioY];


% stim.sdVals = [.00001, 2, 4, 8, 16, 32, 48, 64];

stim.cohVals = .01.*[0,logspace(log10(2),log10(100),7)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Stair params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% stimValsRangeREAL = [.1,25];
% stimValsRangeSTAIR = [stimValsRangeREAL(1)/stimValsRangeREAL(2),1];
% numStimVals = 200;
% numAlphaRange = 100;
% 
% 
% priorAlphaRange = linspace(stimValsRangeSTAIR(1),stimValsRangeSTAIR(2),numAlphaRange);
% priorBetaRange = 0:10;
% priorLambdaRange = 0:.01:.1;
% gamma = .5;
% 
% 
% stair = struct('stimRange',stimValsRangeSTAIR,'stimRangeDisplay',stimValsRangeREAL,...
%                    'priorAlphaRange',priorAlphaRange,...
%                    'priorBetaRange',priorBetaRange,...
%                    'gamma',gamma,'lambda',priorLambdaRange,...
%                    'PF',@PAL_Weibull,'marginalize',[4,2],...
%                    'AvoidConsecutive',1,'WaitTime',4,'numTrials',60,'numStairs',3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Dot params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dots = struct('sizeInPix', {4}, 'numPerDeg',1.65);
dots.num = round(dots.numPerDeg*(pi*(stim.radiusDeg)^2)); % 1 dot per deg/deg

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Oval within dots params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
oval = struct('radiusDegSize',{.75}, 'color',{[gray gray gray 255]});
xoval = oval.radiusDegSize*ratioX; 
yoval = oval.radiusDegSize*ratioY; %radius
oval.rectPix = [screen.centerPix(1)-xoval, screen.centerPix(2)-yoval, screen.centerPix(1)+xoval, screen.centerPix(2)+yoval];
oval.present = 1; %whether to present the black oval within the circle of dots
oval.fixation = 1; %whether to present a fixation in the oval or not


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     response params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KbName('UnifyKeyNames');
response = struct( 'allowedRespKeys', {['1', '2']}, 'dur',{1.5},'keyEscape', 'ESCAPE', 'percentEstimation', {0});
response.cw_ccw = [1 2]; %6 up, 3 down

for i = 1:length(response.allowedRespKeys)
    response.allowedRespKeysCodes(i) = KbName(response.allowedRespKeys(i));
end
% Note that the correctness of the resp will be computed according to the
% index in the array of resp so that allowedRespKeys(i) is the correct
% response of stim.possibleAngels(i)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      PreCue params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
preCue = struct('dur', .1,'vertDistDeg',1,'color',{white});

preCue.horizDistDeg = (stim.speedDegPerSec/2)*preCue.dur;

preCue.vertDistPix = ratioY*preCue.vertDistDeg;
preCue.horizDistPix = ratioX*preCue.horizDistDeg;

preCue.durInFrames = round(preCue.dur*screen.monRefresh);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      neutral PreCue params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

neutralCue = struct('rectDeg', {[0.2, 0.1]}, 'color',{black}, 'bkColor', {screen.bkColor}, ...
                   'dur', {0.06}, 'penWidthPix', {1}, 'dist2centerDeg', {0.9}); 
sp1 = deg2pix1Dim(neutralCue.rectDeg(1), ratioX); sp2 = deg2pix1Dim(neutralCue.rectDeg(2), ratioY); 


neutralCue.dist2centerPix = deg2pix1Dim(neutralCue.dist2centerDeg, ratioY);

neutralCue.locationsPix1 = [screen.centerPix(1), (screen.centerPix(2) - neutralCue.dist2centerPix)];
neutralCue.locationsPix2 = [screen.centerPix(1), (screen.centerPix(2) + neutralCue.dist2centerPix)];

neutralCue.rectPix = [0 0 sp1 sp2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Block params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
block = struct('numBlocks', 5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Trial params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trial = struct('numTrialsPerBlock', {160}); %total number of trials in a blocks
% if mod(trial.numTrialsPerBlock,length(stim.possibleAngels))~=0
%     error('number of trials must be a multiplication of the possible angles');
% end
trial.numTrialsTotal = trial.numTrialsPerBlock * block.numBlocks;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Save Data params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save = struct('fileName', {'ID_FBA_motion'}, 'expTypeDirName', {'EstiDisc'}, 'SubjectInitials',{'TEST'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Text params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
text = struct('color', black, 'bkColor', gray, 'size', 24);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     ISI params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ISI = struct('postDur', {0.05},'preDur',{.250}); %'preOrder',2,)
% 
% switch ISI.preOrder
%     case 1
%         ISI.preDurVect = [0.05,  0.250, 0.450]; % short, medium, long
%     case 2
%         ISI.preDurVect = [0.250, 0.450, 0.05];  % medium, long, short
%     case 3
%         ISI.preDurVect = [0.450,  0.05, 0.250]; % long, short, medium
%     case 4
%         ISI.preDurVect = [0.05,  0.450, 0.250]; % short, long, medium
%     case 5
%         ISI.preDurVect = [0.250,  0.05, 0.450]; % medium, short, long
%     case 6
%         ISI.preDurVect = [0.450, 0.250, 0.05];  % long, medium, short
%     otherwise
%         error('SOA order by block set incorrectly')
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Feedback params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
feedback = struct('dur', {0.1}, 'high', {500}, 'low', {200}); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     eye params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eye = struct('run',{1}, 'fixCheck',{0}, 'fixRequiredSecs', {0.2}, 'fixCheckRadiusDeg', {2},...
             'fixLongGoCalbirate', {2},'breakWaitDur',{2}); 
% record (1) or not to record (0)
%If recording set that there will be a second fixation because transfering
%the files takes time and we want to present a fixation when that happens
eye.fixCheckRadiusPix = ratioX*eye.fixCheckRadiusDeg;


%-------------------------------------------------------------------------%
%----------------------%%%%%%%%%%%%%%%%%%%--------------------------------%
%                        TOTAL ALL params                                 %
%----------------------%%%%%%%%%%%%%%%%%%%--------------------------------%
%-------------------------------------------------------------------------%

global params;
params = struct('screen', screen, 'trial', trial, 'block', block, 'save', save,...
                'fixation', fixation,'text',text, 'response', response, 'feedback', feedback,...
                'stim', stim, 'ISI', ISI, 'dots', dots, 'eye', eye, 'oval', oval,...
                'preCue',preCue,'neutralCue',neutralCue); %'stair',stair
% cl = 1;
% if cl
%     clear white gray black locationL locationR screen stim fixation precueExg box postCue response ;
%     clear trial i block feedback ratio ratioX ratioY sp1 sp2 rc1 ISI sqslope hfslp neutralCue boundary stair;
%     clear save text preCue screenInfo mouse dotInfo eye xres yres test xoval yoval oval dots cl outerRadiusDeg preCue;
% end
%     