function audFB(correctTrial)
global params;

switch correctTrial
    case 0 %WRONG
        beep3(params.feedback.low,params.feedback.low,params.feedback.dur,0)
    case 1 %CORRECT
        %
    case 2 %NO RESP
        beep2(params.feedback.low,params.feedback.dur+.2)
end