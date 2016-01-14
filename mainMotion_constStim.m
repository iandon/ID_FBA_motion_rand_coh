clear all;
addpath(genpath('/users/purplab/Desktop/Ian/ID_FBA_motion/sdCoh/helper functions'))
addpath(genpath('/users/Shared/Psychtoolbox'))


global params;
params = motion_params_constStim_LD; %SET for each participant


homedir = pwd;  
addpath(genpath(strcat(homedir,'/mgl')));


% params.eye.run = 0;
params.stair.run = 0;
params.stim.colorTest = 0;

%initials = 'test'; sesNum = '0';    
initials = input('Please enter subject initials: \n', 's'); initials = upper(initials);
params.subj.gender = input('Please enter subject GENDER: M/F/O \n', 's');
params.subj.age = input('Please enter subject AGE: \n', 's');
sesNumquest = input('Please enter the session number:\n', 's'); sesNum = str2double(sesNumquest); params.save.sesNum = sesNum; params.sesVar.sesNum = sesNum;
%sesTypequest = input('Test(0) or Training(1)? \n', 's'); sesType = str2double(sesTypequest); params.save.sesType = sesType;
% TRAIN LOCATION is in Plexp_defs file -> Make sure it is the right one!

if (sesNumquest > 1) && ~strcmp(initials,params.save.SubjectInitials)
     error('Check if settings file used is correct for this participant'); 
end




%%%%%%%%% set some general screen params %%%%%%%%% 
Screen('CloseAll');   
Screen('Preference', 'VisualDebugLevel', 1);
wPtr = Screen('OpenWindow',  params.screen.num, params.screen.bkColor, params.screen.rectPix);

%%%%%%%%% Load  new gamma table to fit the current screen %%%%%%%%%
    
startclut = Screen('ReadNormalizedGammaTable', params.screen.num); 
load(params.screen.calib_filename); 
new_gamma_table = repmat(calib.table, 1, 3);
Screen('LoadNormalizedGammaTable',wPtr,new_gamma_table,[]); 

Priority(MaxPriority(wPtr)); 
recal=0;

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
    edfFile = sprintf('%s%d.edf', initials, sesNum); edfFileStatus = Eyelink('OpenFile', edfFile); %this creates the .edf file (doesn't like many characters in name, i think 6 or 8 max)
    if edfFileStatus ~= 0, fprintf('Cannot open .edf file. Exiting ...'); return; end
    cal = EyelinkDoTrackerSetup(el); %This calibrates the eyelink . 
end

%%%% INTRO SCREEN %%%%
instructions(wPtr,recal); % print instructions

%%%% --------------      Start experiment  --------------%%%%%
correctTrial=zeros(params.trial.numTrialsPerBlock,params.block.numBlocks);
trialNum = 0;
if params.stair.run, stair = cell(params.block.numBlocks,params.stair.numStairs);end
procedure = cell(params.block.numBlocks,1); fixBreak = cell(params.block.numBlocks,1);
for b = 1:params.block.numBlocks
%     for stairNum = 1:params.stair.numStairs
%         stair{b}{stairNum} = PAL_AMPM_setupPM('stimRange',params.stair.stimRange,...
%                                            'priorAlphaRange',params.stair.priorAlphaRange,...
%                                            'priorBetaRange',params.stair.priorBetaRange,...
%                                            'gamma',params.stair.gamma,'lambda',params.stair.lambda,...
%                                            'PF',@PAL_Weibull,'numTrials',params.stair.numTrials,'marginalize',params.stair.marginalize);
%     end 
    fixBreak{b}.num = 0;fixBreak{b}.recent = [];fixBreak{b}.track = [];fixBreak{b}.numRecal = 0;
    procedure{b} = calcTrialsVars_ConstStim;
    if params.eye.run && (b > 1)
        EyelinkDoDriftCorrect(el, params.screen.centerPix(1),...
                              params.screen.centerPix(2), 1, 1);
    end
    nTrials = params.trial.numTrialsPerBlock;
    t=0;
    j = 0; nTrialsUPDATE = nTrials;
    while j < nTrialsUPDATE
        j = j + 1;
        i = j - fixBreak{b}.num;
        recal = 0;
        
        
        
        [fixBreak{b}.fixBreak, respTrial, allPosPix, timestamp] = trial(wPtr, procedure{b}{i}.targetAngle,procedure{b}{i}.baseAngle, b, sesNum, i,...
                                                                        procedure{b}{i}.cueType,procedure{b}{i}.SOA,procedure{b}{i}.sdCoh,procedure{b}{i}.ansResp);
                                                      %trial(wPtr,trialAngle,baseAngle,blockNum,sesNum, trialNum ,cueType,SOA,dotCoh)
        % update trial parameters after response
        procedure{b}{i}.timestamp=timestamp;
        if fixBreak{b}.fixBreak
            disp((sprintf(' block %d, trial attempt %d is a fixation break',b,j)));
            fixBreak{b}.num = fixBreak{b}.num+1; nTrialsUPDATE = nTrialsUPDATE+1;
            [procedure{b}, fixBreak{b}, recal] = breakProc(procedure{b},nTrials,i,j,fixBreak{b});
        else
            correctTrial(b,i) = respTrial.correct;
            procedure{b}{i}.correct = respTrial.correct;
            procedure{b}{i}.rt = respTrial.rt;
            procedure{b}{i}.key = respTrial.key;
            procedure{b}{i}.resTrial = respTrial;
            procedure{b}{i}.allPosPix = allPosPix;
            procedure{b}{i}.timestamp = timestamp;        
%             stair{b}{procedure{b}{i}.stairNum} = PAL_AMPM_updatePM(stair{b}{procedure{b}{i}.stairNum},procedure{b}{i}.correct);
           
        end
        if recal, recalProc(el); end

    end
    
    
    blockFileName = sprintf('%s_%s_BlockData_Ses%d_Block%d.mat',...
                            params.save.fileName, initials, sesNum, b);
    
    if params.stair.run, save(blockFileName, 'procedure','sesNum', 'params', 'fixBreak', 'stair');
    else save(blockFileName, 'procedure','sesNum', 'params', 'fixBreak'); end
    
    if params.eye.run, Eyelink('StopRecording'); Eyelink('Message', sprintf('Block # %d Complete', b));end
    
%     correctProp = sum(sum(correctTrial==1))/length(correctTrial(:));
%     correctPercent = 100*(correctProp/nTrials);
    if b < params.block.numBlocks, blockBreak(wPtr, b); end
    
    Screen('Close');
end



Screen('Close'); Priority(0);
Screen('CloseAll'); ShowCursor;
%%%%%-------------     End the experiment    ----------%%%%%

% %%%%%------------- Save all experiment data ----------%%%%%
% cd(dirc);
% date = sprintf('Date:%02d/%02d/%4d  Time:%02d:%02d:%02i', c(2),c(3),c(1),c(4),c(5),ceil(c(6)));
% save(saveExpFile);
% cd(homedir);

% %%%%%%% run some analysis %%%%%%%
% totalTrials=(params.trial.numTrialsPerBlock*numBlocks);
c = clock;
homedir = pwd; 
dirc = sprintf('results/%s',initials);
if params.eye.run; Eyelink('ReceiveFile', edfFile, dirc,1); Eyelink('CloseFile'); Eyelink('Shutdown'); end
mkdir(dirc); cd(dirc)

Screen('Close');
date = sprintf('Date:%02d/%02d/%4d  Time:%02d:%02d:%02i ', c(2),c(3),c(1),c(4),c(5),ceil(c(6)));
saveExpFile = sprintf('%s_results_%s_ses%d_%02d_%02d_%4d_time_%02d_%02d_%02i.mat',...
                      params.save.fileName, initials, sesNum,...
                      c(2),c(3),c(1),c(4),c(5),ceil(c(6)));
if params.stair.run, save(saveExpFile ,'procedure', 'respTrial','sesNum', 'params', 'date', 'fixBreak', 'stair');
else save(saveExpFile ,'procedure', 'respTrial','sesNum', 'params', 'date', 'fixBreak'); end

cd(homedir);
%%%%%--------------------------------------------------%%%%%

%delete('tmpData.mat');
Screen('LoadNormalizedGammaTable',params.screen.num,startclut,[]);
Screen('CloseAll');
disp('Done!');
%%