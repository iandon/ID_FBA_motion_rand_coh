function neutPreCue(wPtr)
global params

rect1 = CenterRectOnPointd(params.neutralCue.rectPix, params.neutralCue.locationsPix1(1),params.neutralCue.locationsPix1(2));
rect2 = CenterRectOnPointd(params.neutralCue.rectPix, params.neutralCue.locationsPix2(1), params.neutralCue.locationsPix2(2));
rect = [rect1', rect2'];
Screen('FillRect', wPtr ,params.neutralCue.color, rect);
end