function procedure = calcTrialsVars_ConstStim(currISI)
global params;  
numTrials = params.trial.numTrialsPerBlock; % should be 160

numRepeats = 1; %how many times does each trial type repeat?
                   % 4 baseAngles, 5 cueType, 8 cohVals = 160
                   % 1 repeats =  160 trials per block


baseAnglePossibleIndex = 1:length(params.stim.baseAngles); %up,right,down,left CHECK THIS
cueTypePossible  = [0,1,2,3,4]; %neut,valid,invalidSameAxis,invalidDiffAxis1,invalidDiffAxis2
cohPossible = params.stim.cohVals;

[baseAngleIndex,cueType,coh,repeat] = ndgrid(baseAnglePossibleIndex, cueTypePossible,cohPossible,1:numRepeats);

ord = randperm(numTrials);

baseAngleIndex = baseAngleIndex(ord);
baseAngle = params.stim.baseAngles(baseAngleIndex);
cueType  = cueType(ord);
coh = coh(ord);


ansResp = ((baseAngleIndex == 1)+(baseAngleIndex == 3))+1;

% SOA = repmat(params.ISI.preDurVect(blockNum),[numTrials,1]);


        
procedure = cell(numTrials,1);
for i = 1:numTrials
    procedure{i}.baseAngle = baseAngle(i);
    procedure{i}.baseAngleIndex = baseAngleIndex(i);
    procedure{i}.cueType  = cueType(i);
    procedure{i}.coh  = coh(i);
    procedure{i}.ansResp  = ansResp(i);
    procedure{i}.trialIndex = i;
    procedure{i}.SOA = currISI;
end