function moveDots(allPosPix,wPtr,stimOrPreCue,totalDur)
global params; 
Screen('BlendFunction', wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


if stimOrPreCue == 1
    durInFrames = params.stim.durInFrames;
    dotColor = params.stim.color;
else
    durInFrames = params.preCue.durInFrames;
    dotColor = params.preCue.color;
end

currentFrame = 1;
stimDuration = tic;

while currentFrame <= durInFrames && toc(stimDuration) <= totalDur
    currentFrame = ceil(toc(stimDuration)*(params.screen.monRefresh/2));
    allDots = [allPosPix.x(:,currentFrame), allPosPix.y(:,currentFrame)]';
    allDots = allDots-repmat(params.screen.centerPix', 1, size(allDots,2));
    c = params.screen.centerPix;
    r = params.stim.radiusPix;
    %Screen('FillOval', wPtr ,[250 0 0], round([c(1)-r c(2)-r c(1)+r c(2)+r]));
  
    Screen('DrawDots', wPtr, allDots, params.dots.sizeInPix, dotColor, params.screen.centerPix,1);
    fixation(wPtr);
    
    
    Screen('DrawingFinished',wPtr,0);
    Screen('Flip', wPtr,0,0);
    clear allDots
end 

if params.oval.fixation, fixation(wPtr); end; 
Screen('Flip', wPtr,0,0);




