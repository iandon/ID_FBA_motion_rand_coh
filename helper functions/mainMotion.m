function mainMotion(varargin)


%mainMotion('dirDiff',20,'baseDir',225,'eyeTrack',0,'numBlocks',1)
%pre training at training direction and location
%mainMotion('dirDiff',4,'baseDir',315,'eyeTrack',1,'numBlocks',3)
%transfer direction and training location
%mainMotion('dirDiff',4,'baseDir',315,'eyeTrack',1,'numBlocks',3)
%transfer direction and training location
%mainMotion('dirDiff',4,'baseDir',225,'eyeTrack',1,'numBlocks',3,'apertureCenter',[-5 5;5 -5])
%mainMotion('dirDiff',4,'baseDir',225,'eyeTrack',1,'numBlocks',3,'apertureC
%enter',[-5 -5;5 5])
%training neutral cue
%mainMotion('dirDiff',4,'baseDir',225,'eyeTrack',1,'numBlocks',6,'stair',0,
%'coherence',0.96)
% training attn cue
%mainMotion('dirDiff',4,'baseDir',225,'eyeTrack',1,'numBlocks',6,'stair',0,
%'cueType',1,'coherence',0.96)
%%% initialize default params

eval(evalargs(varargin,0,0,{'stair','coherence','baseDir','dirDiff','cueType','apertureCenter','eyeTrack','numBlocks'}));

if ieNotDefined('stair'),stair = 1;end
if ieNotDefined('coherence'),coherence = 1;end
if ieNotDefined('baseDir'),baseDir = 315;end
if ieNotDefined('dirDiff'),dirDiff = 6;end
if ieNotDefined('apertureCenter'),apertureCenter=[-5 0 ; 5 0];end
if ieNotDefined('cueType'),cueType=3;end
if ieNotDefined('numBlocks'),numBlocks=3;end
if ieNotDefined ('initials'), initials=input('Please enter subject initials (2 characters): \n', 's'); end %NOT LONGER THAN 2 CHARACTERS  
if ieNotDefined('sesNum'), sesNum=input('Please enter number of session:\n', 's'); end % 0 for pretest and posttest, other number for training sessions
if ieNotDefined('eyeTrack'), eyeTrack=1;end

%%%%%%%%% set paths to psychtoolbox, mgl and the homedir %%%%%%%%% 

addpath(genpath('/users/Shared/Psychtoolbox')); 
homedir = pwd;  
addpath(genpath(strcat(homedir,'/mgl')));

motion_params;%(stair,coherence,baseDir,dirDiff,apertureCenter,cueType,eyeTrack,numBlocks); 
global params;  


params.preCue.dotMotion = makePreCueDotMotion;


%%%%%%%%% set some general screen params %%%%%%%%% 
Screen('CloseAll');   
Screen('Preference', 'VisualDebugLevel', 1);
wPtr = Screen('OpenWindow',  params.screenVar.num, params.screenVar.bkColor, params.screenVar.rectPix);

%%%%%%%%% Load  new gamma table to fit the current screen %%%%%%%%%
    
startclut = Screen('ReadNormalizedGammaTable', params.screenVar.num); 
load( params.screenVar.calib_filename); 
new_gamma_table = repmat(calib.table, 1, 3);
Screen('LoadNormalizedGammaTable',wPtr,new_gamma_table,[]); 

Priority(MaxPriority(wPtr)); 
recal=0;
instructions(wPtr,recal); % print instructions

%%%%%%%%% If need make main screen black here 

%%%%%%%%% Initialize response and experiment data variables %%%%%%%%%
% trialstype: variable that carries cue location 1: LVF, 2: RVF 3: neutra
% central cue. RespType: indicate the direction CW or CCW of the LVF or RVF stim 
% resp = struct('rt', {[]}, 'key', {[]}, 'correct', {[]},'block',{[]});
% expData  = struct('angles',{[]},'trialsType',{[]},'respType',{[]},
% 'stairOrder',{[]},'dotCoh',{[]},'block',{[]},'stairs',{[]});



%%%%%%%%% eye-tracker %%%%%%%%%
%%%%%%%%% To initialize and calibrate %%%%%%%%%
%%%%%%%%% Do this at the begining of each session %%%%%%%%%
if params.eye.run
    Eyelink('Initialize'); %this establishes the connection to the eyelink
    el = prepEyelink(wPtr);
    edfFile = sprintf('%s%s%s%s.edf', initials, sesNum,dateTime(5:6),dateTime(10:11)); edfFileStatus = Eyelink('OpenFile', edfFile); %this creates the .edf file (doesn't like many characters in name, i think 6 or 8 max)
    if edfFileStatus ~= 0, fprintf('Cannot open .edf file. Exiting ...'); return; end
    cal = DoTrackerSetup(el); %This calibrates the eyelink . 
end

%%%%%%%%% Initialize fixation break structure %%%%%%%%%
fixBreak=struct('fixBreak',{0},'recal',{0},'currRunNum',{0},'numFixBreaks',{0},'breakTrack',{0},'breakRecent',{0});


%HideCursor;


%%%%%% Initialize block and trial parameters %%%%%%%


%%%% --------------      Start experiment  --------------%%%%%
correctTrial=zeros(params.trialVars.numTrialsPerBlock,params.blockVars.numBlocks);
trialNum = 0;
stair = cell(params.blockVars.numBlocks,params.stairVars.numStairs);
procedure = cell(params.blockVars.numBlocks,1);
for b = 1:params.blockVars.numBlocks
%     for stairNum = 1:params.stairVars.numStairs
%         stair{b}{stairNum} = PAL_AMPM_setupPM('stimRange',params.stairVars.stimRange,...
%                                            'priorAlphaRange',params.stairVars.priorAlphaRange,...
%                                            'priorBetaRange',params.stairVars.priorBetaRange,...
%                                            'gamma',params.stairVars.gamma,'lambda',params.stairVars.lambda,...
%                                            'PF',@PAL_Weibull,'numTrials',params.stairVars.numTrials,'marginalize',params.stairVars.marginalize);
%     end 
    procedure{b} = calcTrialsVars_ConstStim(b);
    blockBreak(wPtr, b);
    if params.eye.run && (b > 1)
        EyelinkDoDriftCorrect(el, params.screenVar.centerPix(1),...
                              params.screenVar.centerPix(2), 1, 1);
    end
    t=0;
    while t < params.trialVars.numTrialsPerBlock
        t=t+1;
        recal = 0;
        procedure{b}{t}.dotCoh= 1;
        
        procedure{b}{t}.targetAngle = procedure{b}{t}.horizDir+(params.stairVars.stimRangeDisplay(2)*stair{b}{procedure{b}{t}.stairNum}.xCurrent)*procedure{b}{t}.vertDir;
        
        [fixBreak.fixBreak, respTrial, timestamp] = trial(wPtr, procedure{b}{t}.targetAngle, startclut, b, sesNum, t,...
                                                          procedure{b}{t}.cueType, procedure{b}{t}.cueDir,procedure{b}{t}.SOA,procedure{b}{t}.dotCoh);
        % update trial parameters after response
        procedure{b}{t}.timestamp=timestamp;
        if fixBreak.fixBreak
            disp((sprintf(' block %d, trial %d is a fixation break',b,t)));
            [procedure{b}, fixBreak, recal] = breakProc(procedure{b},t,wPtr,el,fixBreak);
            t=t-1;%%% reset trial counter by 1
        else
            correctTrial(b,t) = respTrial.correct;
            procedure{b}{t}.correct = respTrial.correct;
            procedure{b}{t}.rt = respTrial.rt;
            procedure{b}{t}.key = respTrial.key;
            disp(sprintf('Elapsed time for block %d, trial %d is %G',b,t,timestamp.ts));
            
            stair{b}{procedure{b}{t}.stairNum} = PAL_AMPM_updatePM(stair{b}{procedure{b}{t}.stairNum},procedure{b}{t}.correct);
           
        end
        if recal; breakFix.Block.recalCount = breakFix.Block.recalCount + 1; recalProc(el, wPtr); end

    end
    
    correctPercent = 100*(correctProp/nTrials);
    blockBreak(wPtr, b, correctPercent);

    save(blockFileName, 'expData', 'results','sesNum', 'params', 'breakFix', 'stair');
    if params.eye.run, Eyelink('StopRecording'); Eyelink('Message', sprintf('Block # %d Complete', b));end
    
    
    
    Screen('Close');
end

if params.eye.run; Eyelink('ReceiveFile', edfFile, direc,1); Eyelink('CloseFile'); Eyelink('Shutdown'); end

Screen('Close'); Priority(0);
Screen('CloseAll'); ShowCursor;
%%%%%-------------     End the experiment    ----------%%%%%

%%%%%------------- Save all experiment data ----------%%%%%
cd(direc);
date = sprintf('Date:%02d/%02d/%4d  Time:%02d:%02d:%02i ', c(2),c(3),c(1),c(4),c(5),ceil(c(6)));
save(saveExpFile);
cd(homedir);

% %%%%%%% run some analysis %%%%%%%
% totalTrials=(params.trialVars.numTrialsPerBlock*numBlocks);
c = clock;
homedir = pwd; 
dirc = sprintf('results/%s/%s', params.saveVars.expTypeDirName,initials);
mkdir(dirc); cd(dirc)
if params.eye.run; Eyelink('ReceiveFile', ELfileName, dirc,1); Eyelink('CloseFile'); Eyelink('Shutdown'); end
Screen('Close');
date = sprintf('Date:%02d/%02d/%4d  Time:%02d:%02d:%02i ', c(2),c(3),c(1),c(4),c(5),ceil(c(6)));
saveExpFile = sprintf('%s_results_%s_ses%d_%02d_%02d_%4d_time_%02d_%02d_%02i.mat',...
                      params.saveVars.fileName, initials, sesNum,...
                      c(2),c(3),c(1),c(4),c(5),ceil(c(6)));
          
save(saveExpFile ,'procedure', 'results','sesNum', 'params', 'date', 'stair', 'breakFix');

cd(homedir);
%%%%%--------------------------------------------------%%%%%

%delete('tmpData.mat');
Screen('LoadNormalizedGammaTable',params.screenVar.num,startclut,[]);
Screen('CloseAll');
disp('Done!');
%%