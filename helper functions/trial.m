function   [fixBreak, resp, allPosPix, timestamp] = trial(wPtr,baseAngle,blockNum,sesNum, trialNum ,cueType,SOA,dotCoh,ansResp)
global params;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%Initialise trial event durations%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cumulativeDur = struct('fixation', (params.fixation.dur),...
                       'preCue', (params.fixation.dur + params.preCue.dur),...
                       'ISIpre', (params.fixation.dur + params.preCue.dur + SOA ),...
                       'stim', (params.fixation.dur + params.preCue.dur + SOA + params.stim.dur),... %'ISIpost', (params.fixation.dur + params.preCue.dur + SOA + params.stim.dur + params.respCue.RespCueISIdur),...
                       'total', (params.fixation.dur + params.preCue.dur + SOA + params.stim.dur));

timestamp.ts=0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% initialize dot positions for the two aperture
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[allPosPix.cue]= computeMotion_Cue(baseAngle,cueType);
[allPosPix.target]= computeMotion_Target(baseAngle,dotCoh);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% start eye-tracker  %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if params.eye.run
    Eyelink('StartRecording');
    Eyelink('Message', sprintf('StartTrial_SesNum_%d_Block_%d_Trial_%d_angle_%d_loc_%d',...
            sesNum,blockNum, trialNum,baseAngle,cueType));
end

pressQ = 0;
[keyIsDown, secs, keyCode] = KbCheck;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% each trial is initiated by 300ms of fixation. If the subject does not
%%%%% fixate prompt with a msg after 20ms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fixation(wPtr); Screen('Flip', wPtr); WaitSecs(.300);

if params.eye.run
    fixBreakPRE = 1; FirstFixClock = tic;
    keyIsDown = 0;
    while fixBreakPRE && ~pressQ
        tsFirstFix = toc(FirstFixClock); [fixBreakPRE] = fixCheck; fixation(wPtr);
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyIsDown == 1; pressQ = keyCode(KbName('Q')); end
        if tsFirstFix > .02
            fixation(wPtr, 0)
            %Screen('TextSize', wPtr, (params.textVars.size*(2/3)));
            %Screen('DrawText', wPtr, fixBreakObsvMSG, params.screenVar.centerPix(1)-90, params.screenVar.centerPix(2)-50,[0 0 0]);
        end
        Screen('Flip', wPtr);
        if tsFirstFix > 2
            fixBreak = 1; correctTrial = []; resp = []; timestamp = [];
            Eyelink('Message', sprintf('DID NOT FIXATE BEFORE TRIAL'));
            clear FirstFixClock tsFirstFix;
            return;
        end
        [fixBreakPRE] = fixCheck;
    end
    tsFirstFix = toc(FirstFixClock); 
timestamp.ts=tsFirstFix;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% if the subject presses Q exit experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if  pressQ == 1
    Screen('CloseAll'); clear FirstFixClock tsFirstFix; Eyelink('StopRecording');
    error('Experiment stopped by user!');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Start trial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear FirstFixClock tsFirstFix;


fixBreak = 0;


if params.eye.run, chk = 1; [fixBreak] = fixCheck; else chk = 3; end

trlStart = chk; preCueON = chk; preCueOFF = chk; stimON = chk; stimOFF = chk; postCueON = chk;

ts = 0; 
trialStart = tic;
while ~fixBreak && (ts < cumulativeDur.total) && ~pressQ
    ts = toc(trialStart);
    [keyIsDown, secs, keyCode] = KbCheck; pressQ = keyCode(KbName('Q'));
    if ts < cumulativeDur.fixation
        if trlStart == 1, Eyelink('Message', sprintf('Trial Start')); end
        fixation(wPtr); Screen('Flip', wPtr);
        timestamp.fixation = ts;
        if trlStart < 2, trlStart = trlStart + 1; end
    elseif ts < cumulativeDur.preCue
        if preCueON == 1, Eyelink('Message', sprintf('PreCue ON')); end
        moveDots(allPosPix.cue,wPtr,0,cumulativeDur.preCue-cumulativeDur.fixation);
        timestamp.preCue = ts;
        if preCueON < 2, preCueON = preCueON + 1; end
    elseif ts < cumulativeDur.ISIpre
        if preCueOFF == 1, Eyelink('Message', sprintf('PreCue OFF')); end
        fixation(wPtr); Screen('Flip', wPtr);
        timestamp.ISIpre = ts;
        if preCueOFF < 2 , preCueOFF = preCueOFF + 1; end
    elseif ts < cumulativeDur.stim
        if stimON == 1, Eyelink('Message', sprintf('Stimulus ON')); end
        moveDots(allPosPix.target, wPtr,1,cumulativeDur.stim-cumulativeDur.ISIpre); %%%%% draw dots
        fixation(wPtr); Screen('Flip', wPtr);
        timestamp.stim = ts;
        if stimON < 2, stimON = stimON + 1; end
    elseif ts < cumulativeDur.total %postCue -> last phase on which we care about fixation
        if postCueON == 1, Eyelink('Message', sprintf('PostCue ON')); end
%        resp=drawRespCue(respType,wPtr);break;
        fixation(wPtr); Screen('Flip', wPtr);
        timestamp.postCue = ts;
        if stimOFF < 2, stimOFF = stimOFF + 1; end
        if postCueON < 2, postCueON = postCueON + 1; end
    end
    if params.eye.run, [fixBreak] = fixCheck; end
end
if params.eye.run && ~fixBreak, Eyelink('Message', sprintf('Fixation Check Window Closed')); end

if params.eye.run
    Eyelink('StopRecording');
end

if pressQ
    Screen('CloseAll'); 
    error('Experiment stopped by user!');
end

if fixBreak
    Eyelink('Message', sprintf('TRIAL INCOMPLETE'));
    for i=1:4 beep2(params.feedback.high/2,params.feedback.dur); end
    timestamp = ts; resp = []; correctTrial = []; fixation( wPtr); tsBrkMsg = 0; BrkTime = tic; rng = -5:0.2:5;
    while tsBrkMsg < params.eye.breakWaitDur;
        tsBrkMsg = toc(BrkTime); %shadeX = rng(ceil(tsBrkMsg*100));
        fixation(wPtr, 0); Screen('Flip', wPtr);
    end
    clear BrkTime
else
    if params.eye.run, Eyelink('Message', sprintf('Post Cue OFF')); end
    fixation(wPtr); Screen('Flip', wPtr); resp = response;
    correctTrial = checkResp(resp, ansResp); 
    audFB(correctTrial);
    resp.correct = correctTrial;
    timestamp.resp = ts;
    timestamp.ts=ts;
end


if params.eye.run
    Eyelink('Message', sprintf('Trial End'));
    Eyelink('Message', sprintf('EndTrial_SesNum_%d_Block_%d_Trial_%d_angle_%d_loc_%d_val',...
    sesNum,blockNum, trialNum,baseAngle,cueType));
end

 
