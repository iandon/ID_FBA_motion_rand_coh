function [dataStruct] = makeDataStruct(procedure,params)

addpath(genpath('/users/purplab/Desktop/Ian/ID_FBA_motion/sdCoh/palamedes1_5_0'))

numBlocks = params.block.numBlocks;
numTrials = params.trial.numTrialsPerBlock;

sdCohVect = params.stim.sdVals;

numLevels = length(sdCohVect);

dataStruct.sdCohVect = sdCohVect;



dataStruct.ses.accAllTrials = nan(numTrials*numBlocks,numLevels);
dataStruct.ses.numCorr = zeros(1,numLevels);
dataStruct.ses.numTrialsLevel = zeros(1,numLevels);
dataStruct.ses.numTrialsExcludeMiss = zeros(1,numLevels);
 
dataStruct.block = cell(numBlocks,1);

%% calculate accuracy/prop correct/num correct
for b = 1:numBlocks
    dataStruct.block{b}.accAllTrials = nan(numTrials,numLevels);
    dataStruct.block{b}.numCorr = zeros(1,numLevels);
    dataStruct.block{b}.numTrialsLevel = zeros(1,numLevels);
    dataStruct.block{b}.numTrialsExcludeMiss = zeros(1,numLevels);

    for t = 1:numTrials
        currColumn = find(sdCohVect == procedure{b}{t}.sdCoh);
        
        %count number of trials per level
        dataStruct.ses.numTrialsLevel(currColumn) = dataStruct.ses.numTrialsLevel(currColumn)+1;
        dataStruct.block{b}.numTrialsLevel(currColumn) = dataStruct.ses.numTrialsLevel(currColumn)+1;
        
        %count, but exclude misses
        dataStruct.ses.numTrialsExcludeMiss(currColumn) = dataStruct.ses.numTrialsExcludeMiss(currColumn) + (procedure{b}{t}.correct ~= 2);
        dataStruct.block{b}.numTrialsExcludeMiss(currColumn) = dataStruct.block{b}.numTrialsExcludeMiss(currColumn) + (procedure{b}{t}.correct ~= 2);
        
        %row determined by number of trial per level SO FAR
        currRowSes = dataStruct.ses.numTrialsLevel(currColumn);
        currRowBlock = dataStruct.block{b}.numTrialsLevel(currColumn);
        
        %record correctness (correct, incorrect, or no response)
        dataStruct.ses.accAllTrials(currRowSes,currColumn) = procedure{b}{t}.correct;
        dataStruct.block{b}.accAllTrials(currRowBlock,currColumn) = procedure{b}{t}.correct;
        
        
        %count the number correct
        dataStruct.ses.numCorr(currColumn) = dataStruct.ses.numCorr(currColumn) + (1==procedure{b}{t}.correct);
        dataStruct.block{b}.numCorr(currColumn)  = dataStruct.block{b}.numCorr(currColumn)  + (1==procedure{b}{t}.correct);
        
    end

    
    dataStruct.block{b}.propCorr = dataStruct.block{b}.numCorr./dataStruct.block{b}.numTrialsLevel;
    dataStruct.block{b}.propCorrExcludeMiss = dataStruct.block{b}.numCorr./dataStruct.block{b}.numTrialsExcludeMiss;

end

dataStruct.ses.propCorr = dataStruct.ses.numCorr./dataStruct.ses.numTrialsLevel;
dataStruct.ses.propCorrExcludeMiss = dataStruct.ses.numCorr./dataStruct.ses.numTrialsExcludeMiss;






%% fit curves


StimLevels = sdCohVect;

paramGuess = [30,20,.15];
xCurve = linspace(10^-6,180,10000);
xCurveLog = log10(xCurve);

axisVect = [min(xCurveLog),max(xCurveLog),.4,1];
axisVect2 = [min(xCurve),max(xCurve),.4,1];

PF = @PAL_Weibull;

alphaguess = [0:1:180];
betaguess = [-100:1:100];
gammaguess = 0.5;
lambdaguess = [0:.05:.5];

paramsFree = [1 1 0 1];

lapseLimits = [0, .5];

searchGrid = struct('alpha', alphaguess,'beta', betaguess,'gamma',gammaguess, 'lambda',lambdaguess);


NumPos = dataStruct.ses.numCorr; OutOfNum = dataStruct.ses.numTrialsLevel;
[dataStruct.ses.propCorrFit.params,dataStruct.ses.propCorrFit.LL, dataStruct.ses.propCorrFit.exitflag]...
        = PAL_PFML_Fit(StimLevels,...
                       NumPos,...
                       OutOfNum,...
                       searchGrid, paramsFree, PF, 'lapseLimits', lapseLimits);
                   
NumPos = dataStruct.ses.numCorr; OutOfNum = dataStruct.ses.numTrialsExcludeMiss;
[dataStruct.ses.propCorrFitExcludeMiss.params,dataStruct.ses.propCorrFitExcludeMiss.LL, dataStruct.ses.propCorrFitExcludeMiss.exitflag]...
        = PAL_PFML_Fit(StimLevels,...
                       NumPos,...
                       OutOfNum,...
                       searchGrid, paramsFree, PF, 'lapseLimits', lapseLimits);
                   
                   
for b = 1:numBlocks             
                   
NumPos = dataStruct.block{b}.numCorr; OutOfNum = dataStruct.block{b}.numTrialsLevel;
[dataStruct.block{b}.propCorrFit.params,dataStruct.block{b}.propCorrFit.LL, dataStruct.block{b}.propCorrFit.exitflag]...
        = PAL_PFML_Fit(StimLevels,...
                       NumPos,...
                       OutOfNum,...
                       searchGrid, paramsFree, PF, 'lapseLimits', lapseLimits);
  
NumPos = dataStruct.block{b}.numCorr; OutOfNum = dataStruct.block{b}.numTrialsExcludeMiss;
[dataStruct.block{b}.propCorrFitExcludeMiss.params,dataStruct.block{b}.propCorrFitExcludeMiss.LL, dataStruct.block{b}.propCorrFitExcludeMiss.exitflag]...
        = PAL_PFML_Fit(StimLevels,...
                       NumPos,...
                       OutOfNum,...
                       searchGrid, paramsFree, PF, 'lapseLimits', lapseLimits);
end


%% plot for ses


figure(1), clf, hold on
plot(log10(StimLevels),dataStruct.ses.propCorr,'bo')
plot(xCurveLog,PF(dataStruct.ses.propCorrFit.params,xCurve),'b-')
axis(axisVect)
hold off

figure(2), clf, hold on
plot(log10(StimLevels),dataStruct.ses.propCorrExcludeMiss,'bo')
plot(xCurveLog,PF(dataStruct.ses.propCorrFitExcludeMiss.params,xCurve),'b-')
axis(axisVect)
hold off



%%
figure(3), clf, hold on
plot(StimLevels,dataStruct.ses.propCorr,'bo')
plot(xCurve,PF(dataStruct.ses.propCorrFit.params,xCurve),'b-')
axis(axisVect2)
hold off

figure(4), clf, hold on
plot(StimLevels,dataStruct.ses.propCorrExcludeMiss,'bo')
plot(xCurve,PF(dataStruct.ses.propCorrFitExcludeMiss.params,xCurve),'b-')
axis(axisVect2)
hold off


