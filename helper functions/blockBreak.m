function blockBreak(wPtr,b)
global params;

    instruct = sprintf('Block number %d ended.', b);
    start=sprintf('Press space when ready, to start!');
    Screen('TextSize', wPtr, params.text.size);
    Screen('TextColor', wPtr, params.text.color);
    Screen('TextBackgroundColor',wPtr, params.text.bkColor );

    Screen('DrawText', wPtr, instruct, params.screen.centerPix(1)-350, params.screen.centerPix(2));
  
    Screen('Flip', wPtr);
    if b == 4
        WaitSecs(30)    
    else
        WaitSecs(15)
    end
    Screen('DrawText', wPtr, start, params.screen.centerPix(1)-350, params.screen.centerPix(2));
    Screen('Flip', wPtr);
    keyIsDown = 0;
    while (~keyIsDown)
        [keyIsDown,secs,keyCode] = KbCheck;
         if keyCode(kbname('Space')),  keyIsDown = 1; break; else keyIsDown =0;  end   
    end
