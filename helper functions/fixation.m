function fixation(wPtr, trialType)
global params;

if nargin<2
    xHR= params.screen.centerPix(1)+ params.fixation.sizeCrossPix(1);
    xHL = params.screen.centerPix(1)- params.fixation.sizeCrossPix(1);
    yH = params.screen.centerPix(2);
    Screen('DrawLine',wPtr,params.fixation.color,xHR,yH,xHL, yH,params.fixation.penWidthPix);

    yVU= params.screen.centerPix(2)+ params.fixation.sizeCrossPix(2);
    yVD = params.screen.centerPix(2)- params.fixation.sizeCrossPix(2);
    xV = params.screen.centerPix(1);
    Screen('DrawLine',wPtr,params.fixation.color,xV,yVU,xV, yVD,params.fixation.penWidthPix);
elseif trialType == 0
    xHR= params.screen.centerPix(1)+ params.fixation.sizeCrossPix(1);
    xHL = params.screen.centerPix(1)- params.fixation.sizeCrossPix(1);
    yH = params.screen.centerPix(2);
    Screen('DrawLine',wPtr,params.fixation.colorDisc,xHR,yH,xHL, yH,params.fixation.penWidthPix);

    yVU= params.screen.centerPix(2)+ params.fixation.sizeCrossPix(2);
    yVD = params.screen.centerPix(2)- params.fixation.sizeCrossPix(2);
    xV = params.screen.centerPix(1);
    Screen('DrawLine',wPtr,params.fixation.colorDisc,xV,yVU,xV, yVD,params.fixation.penWidthPix);
end
    



