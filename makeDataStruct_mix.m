function [dataStruct] = makeDataStruct_mix(procedure,params,sesNum,varargin)

eval(evalargs(varargin,0,0,{'dataStruct'}));

addpath(genpath('/users/purplab/Desktop/Ian/ID_FBA_motion/sdCoh/palamedes1_5_0'))

numBlocks = params.block.numBlocks;
numTrials = params.trial.numTrialsPerBlock;


cueTypeCell = {'neut','valid','invalid'};


sdCohVect = params.stim.sdVals;

numLevels = length(sdCohVect);





if sesNum == 1
    for cueTypeCurr = 1:length(cueTypeCell)
        
        dataStruct.(cueTypeCell{cueTypeCurr}).accAllTrials = nan(numTrials*numBlocks,numLevels);
        dataStruct.(cueTypeCell{cueTypeCurr}).numCorr = zeros(1,numLevels);
        dataStruct.(cueTypeCell{cueTypeCurr}).numTrialsLevel = zeros(1,numLevels);
        dataStruct.(cueTypeCell{cueTypeCurr}).numTrialsExcludeMiss = zeros(1,numLevels);
        
    end
end
dataStruct.sdCohVect = sdCohVect;
%% calculate accuracy/prop correct/num correct
for b = 1:numBlocks

    for t = 1:numTrials
        cueTypeCurr = cueTypeCell{(procedure{b}{t}.cueType+1)};
        %which SD val?
        currColumn = find(sdCohVect == procedure{b}{t}.sdCoh);
        
        
        %count number of trials per level
        dataStruct.(cueTypeCurr).numTrialsLevel(currColumn) = dataStruct.(cueTypeCurr).numTrialsLevel(currColumn)+1;
        
        %count, but exclude misses
        dataStruct.(cueTypeCurr).numTrialsExcludeMiss(currColumn) = dataStruct.(cueTypeCurr).numTrialsExcludeMiss(currColumn) + (procedure{b}{t}.correct ~= 2);
     
        %row determined by number of trial per level SO FAR
        currRowSes = dataStruct.(cueTypeCurr).numTrialsLevel(currColumn);

        
        %record correctness (correct, incorrect, or no response)
        dataStruct.(cueTypeCurr).accAllTrials(currRowSes,currColumn) = procedure{b}{t}.correct;
        
        %count the number correct
        dataStruct.(cueTypeCurr).numCorr(currColumn) = dataStruct.(cueTypeCurr).numCorr(currColumn) + (1==procedure{b}{t}.correct);
    end

end

for cueTypeCurr = 1:length(cueTypeCell)
    dataStruct.(cueTypeCell{cueTypeCurr}).propCorr = dataStruct.(cueTypeCell{cueTypeCurr}).numCorr./dataStruct.(cueTypeCell{cueTypeCurr}).numTrialsLevel;
    dataStruct.(cueTypeCell{cueTypeCurr}).propCorrExcludeMiss = dataStruct.(cueTypeCell{cueTypeCurr}).numCorr./dataStruct.(cueTypeCell{cueTypeCurr}).numTrialsExcludeMiss;
end





%% fit curves


StimLevels = sdCohVect;

paramGuess = [30,-20,.15];
xCurve = linspace(10^-1.5,250,10000);
xCurveLog = log10(xCurve);

axisVect = [min(xCurveLog),max(xCurveLog),.4,1];
axisVect2 = [min(xCurve),max(xCurve),.4,1];

colorVect = [0,0,1;1,0,0;0,.6,.12];
markerTypeVect = {'o','s','d'};

PF = @PAL_Weibull;

alphaguess = [0:1:180];
betaguess = [-100:1:100];
gammaguess = 0.5;
lambdaguess = [0:.05:.5];

paramsFree = [1 1 0 1];

lapseLimits = [0, .5];

searchGrid = struct('alpha', alphaguess,'beta', betaguess,'gamma',gammaguess, 'lambda',lambdaguess);


for cueTypeCurr = 1:length(cueTypeCell)
NumPos = dataStruct.(cueTypeCell{cueTypeCurr}).numCorr; OutOfNum = dataStruct.(cueTypeCell{cueTypeCurr}).numTrialsLevel;
[dataStruct.(cueTypeCell{cueTypeCurr}).propCorrFit.params,dataStruct.(cueTypeCell{cueTypeCurr}).propCorrFit.LL, dataStruct.(cueTypeCell{cueTypeCurr}).propCorrFit.exitflag]...
        = PAL_PFML_Fit(StimLevels,...
                       NumPos,...
                       OutOfNum,...
                       searchGrid, paramsFree, PF, 'lapseLimits', lapseLimits);
                   
NumPos = dataStruct.(cueTypeCell{cueTypeCurr}).numCorr; OutOfNum = dataStruct.(cueTypeCell{cueTypeCurr}).numTrialsExcludeMiss;
[dataStruct.(cueTypeCell{cueTypeCurr}).propCorrFitExcludeMiss.params,dataStruct.(cueTypeCell{cueTypeCurr}).propCorrFitExcludeMiss.LL, dataStruct.(cueTypeCell{cueTypeCurr}).propCorrFitExcludeMiss.exitflag]...
        = PAL_PFML_Fit(StimLevels,...
                       NumPos,...
                       OutOfNum,...
                       searchGrid, paramsFree, PF, 'lapseLimits', lapseLimits);
end
                   


%% plot for each cue type - log x-axis


currFig = 0;
for cueTypeCurr = 1:length(cueTypeCell)
currFig = currFig+1;
figure(currFig), clf, hold on
plot(log10(StimLevels),dataStruct.(cueTypeCell{cueTypeCurr}).propCorr,'bo')
plot(xCurveLog,PF(dataStruct.(cueTypeCell{cueTypeCurr}).propCorrFit.params,xCurve),'b-')
title(sprintf('%s',(cueTypeCell{cueTypeCurr})))
axis(axisVect)
hold off


currFig = currFig+1;
figure(currFig), clf, hold on
plot(log10(StimLevels),dataStruct.(cueTypeCell{cueTypeCurr}).propCorrExcludeMiss,'bo')
plot(xCurveLog,PF(dataStruct.(cueTypeCell{cueTypeCurr}).propCorrFitExcludeMiss.params,xCurve),'b-')
title(sprintf('%s - Exclude Miss',(cueTypeCell{cueTypeCurr})))
axis(axisVect)
hold off
end





%% not log


for cueTypeCurr = 1:length(cueTypeCell)
currFig = currFig+1;
figure(currFig), clf, hold on
plot(StimLevels,dataStruct.(cueTypeCell{cueTypeCurr}).propCorr,'bo')
plot(xCurve,PF(dataStruct.(cueTypeCell{cueTypeCurr}).propCorrFit.params,xCurve),'b-')
axis(axisVect2)
title(sprintf('%s',(cueTypeCell{cueTypeCurr})))
hold off

currFig = currFig+1;
figure(currFig), clf, hold on
plot(StimLevels,dataStruct.(cueTypeCell{cueTypeCurr}).propCorrExcludeMiss,'bo')
plot(xCurve,PF(dataStruct.(cueTypeCell{cueTypeCurr}).propCorrFitExcludeMiss.params,xCurve),'b-')
axis(axisVect2)
title(sprintf('%s - Exclude Miss',(cueTypeCell{cueTypeCurr})))
hold off
end

%% ALL

legendVect = {cueTypeCell{1},cueTypeCell{2},cueTypeCell{3}};


currFig = currFig+1;
figure(currFig), clf, hold on
for cueTypeCurr = 1:length(cueTypeCell)
plot(xCurveLog,PF(dataStruct.(cueTypeCell{cueTypeCurr}).propCorrFit.params,xCurve),'Color',colorVect(cueTypeCurr,:))
end
legend(legendVect{1},legendVect{2},legendVect{3})
for cueTypeCurr = 1:length(cueTypeCell)
plot(log10(StimLevels),dataStruct.(cueTypeCell{cueTypeCurr}).propCorr,markerTypeVect{cueTypeCurr},'MarkerEdgeColor',colorVect(cueTypeCurr,:))
end
title(sprintf('All'))
axis(axisVect)
hold off



currFig = currFig+1;
figure(currFig), clf, hold on
for cueTypeCurr = 1:length(cueTypeCell)
plot(xCurveLog,PF(dataStruct.(cueTypeCell{cueTypeCurr}).propCorrFitExcludeMiss.params,xCurve),'Color',colorVect(cueTypeCurr,:))
end
legend(legendVect{1},legendVect{2},legendVect{3})
for cueTypeCurr = 1:length(cueTypeCell)
plot(log10(StimLevels),dataStruct.(cueTypeCell{cueTypeCurr}).propCorrExcludeMiss,markerTypeVect{cueTypeCurr},'MarkerEdgeColor',colorVect(cueTypeCurr,:))
end
title(sprintf('All - Exclude Miss'))
axis(axisVect)
hold off



currFig = currFig+1;
figure(currFig), clf, hold on
for cueTypeCurr = 1:length(cueTypeCell)
plot(xCurve,PF(dataStruct.(cueTypeCell{cueTypeCurr}).propCorrFit.params,xCurve),'Color',colorVect(cueTypeCurr,:))
end
legend(legendVect{1},legendVect{2},legendVect{3})
for cueTypeCurr = 1:length(cueTypeCell)
plot(StimLevels,dataStruct.(cueTypeCell{cueTypeCurr}).propCorr,markerTypeVect{cueTypeCurr},'MarkerEdgeColor',colorVect(cueTypeCurr,:))
end
title(sprintf('All'))
axis(axisVect2)
hold off



currFig = currFig+1;
figure(currFig), clf, hold on
for cueTypeCurr = 1:length(cueTypeCell)
plot(xCurve,PF(dataStruct.(cueTypeCell{cueTypeCurr}).propCorrFitExcludeMiss.params,xCurve),'Color',colorVect(cueTypeCurr,:))
end
legend(legendVect{1},legendVect{2},legendVect{3})
for cueTypeCurr = 1:length(cueTypeCell)
plot(StimLevels,dataStruct.(cueTypeCell{cueTypeCurr}).propCorrExcludeMiss,markerTypeVect{cueTypeCurr},'MarkerEdgeColor',colorVect(cueTypeCurr,:))
end
title(sprintf('All - Exclude Miss'))
axis(axisVect2)
hold off