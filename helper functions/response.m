function resp = response()
global params; 
resp = struct('rt', {NaN}, 'key', {NaN});
KbName('UnifyKeyNames');

keyIsDown = 0;
secs1 = GetSecs;
t = 0; tic;
while (~keyIsDown && t<params.response.dur)
    [keyIsDown,secs2,keyCode] = KbCheck;
    if keyIsDown ==1
        %check if key pressed was allowed one and if so end the trial
        if sum(find(keyCode)== params.response.allowedRespKeysCodes), 
            resp.key = find(keyCode);
            resp.rt = secs2-secs1;   
            resp.check = 1;
            break;
        else 
            if keyCode(KbName('ESCAPE')),  
                Screen('CloseAll'); error('Experiment stopped by user!');
            else
                clear secs2 keyCode
                keyIsDown = 0;
            end
        end
        resp.check = 0;
    else
        resp.check = 0;
    end
    t=toc;
end
if (t>params.response.dur || t==params.response.dur) && keyIsDown==0
      %beep2(600,params.fbVars.dur)
end
    
