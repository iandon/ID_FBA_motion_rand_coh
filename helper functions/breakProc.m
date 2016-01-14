function [trialProcNEW fixBreakNEW recal] = breakProc(trialProc,nTrials,currTrialNum, currRunNum,fixBreak)


%[trialProcNEW, recal, fixBreakNEW.recent, breakTrackNEW] = breakProc(trialProc, nTrials, currTrialNum, currRunNum, idx, breakTrack, fixBreak.recent)
%
%To be run after a function deems "fixation broken on this trial".
%
%  First it rearranges the "trialProcedure' structure, such that the 
% current trial is put at the end of the block, and all other trials after 
% the current trial are moved up 1 in the running order. Additionally, all 
% previous trials are kept in the same place in the trialProc structure, so
% as not to alter the log of trials previously completed successfully (i.e. 
% w/o breaking fixation).
%     NOTE: As written, it requires all trial variables be arranged in the
%     structure 'trialProc' as trialProc{currTrialNum}.variableName -> this
%     makes it so each variable is bundled by trial, and thus can be 
%     rearranged altogether rather than separately (avoids some trials
%     being left out of rearrangement -> simple for loop is used so 
%     re-structure cell order. See breakProc.m file).
%
%
%   Next, this function tracks of all of the fixation breaks that have
%  occured in the blocks AND attempts to trigger recalibration, but only if
%  there have been a lot of fixation breaks in recent trials.
%     The definition of "recent" is somewhat dynamic. Read comments w/ in
%     the .m file for details on how it works.
%
%
%   Inputs:
%       trialProc       :  structure that contains cells (n = nTrials), each containing a value for each trial variable (indexed as trialProc{currentTrialNumber}.variableName)
%       nTrials         :  total number of trials per block
%       currTrialNum    :  1 + the number of trials successfully completed (no fixation break) -> an integer 1:nTrials
%       currRunNum      :  the number of times the trial procedure has been attempted (takes into account number of trials that have been truncated and skipped due to fixation break) -> a number within 1:(nTrials + numFixBreaks)
%       fixBreak.num    :  number of fixation breaks
%       fixBreak.track  :  vector of runs on which there was a fixation break on this block, as of the previous fixation break
%       fixBreak.recent :  number of recent fixation breaks, as of the previous fixation break ('recent' is not a straight-forward definition -> see breakProc.m file for details)
%
%   Outputs:
%       trialProcNEW    :  rearranged trial procedure stucture
%       fixBreakNEW     :  number of recent fixation breaks (will be called by this function on the next fixation break)
%       recal           :  recalibrate eye tracker? 1 (Yes) or  0 (No)
%       
%
%
% Ian Donovan
%  Feb/March 2013

trialProcNEW1 = cell(nTrials,1);
for i = 1:currTrialNum-1; trialProcNEW1{i} = trialProc{i}; end
for j = currTrialNum:(nTrials-1); trialProcNEW1{j} = trialProc{j+1}; end
trialProcNEW1{nTrials} = trialProc{currTrialNum};
trialProcNEW = trialProcNEW1;

fixBreakNEW.track = cell(fixBreak.num,1);
if fixBreak.num > 1; for h = 1:(fixBreak.num-1); fixBreakNEW.track{h} = fixBreak.track{h}; end; end
fixBreakNEW.track{fixBreak.num} = currRunNum;



%The following loop asks the question: Should we recalibrate?
%
%  More specifically, it asks: Have there been a lot of fixation breaks
%  recently? 
%        If so, let's recalibrate. If not recently, don't bother.
%
%
%    It does so with only a few lines of code, but it may not be all that
%   straight-forward. 
%    Hence, in attempt to mitigate confusion, Enter: the green mountain of 
%   comments below.
%
%
%   breakTrack is the array in the stucture breakFix (i.e breakFix.breakTrak
%   that logs the run numbers on which there was a fixation break
%     numFixBreaks is the number of total breaks in the block, including
%     the current one
%
%   NOTE: "run number" is distinct from "trial number": Because number of 
%   trials is maintained no matter the number of fixation breaks, 
%   currTrialNum refers to 1 + the number of successfully completed trials
%   (those on which the subject gave a response w/o a fixation break). 
%     currRunNum is the number of times the trial sequence has been 
%   attempted up to this point in the block, of which the total number 
%   grows with each fixation break, even though currTrialNum stays the same
%   between a break and the next run (nRuns = nTrials + numFixBreaks).
%      Because breaking fixation leads to more runs throughout the trial
%      sequence (a fixation break causes total run numbers to go up by 1),
%      when we are asking about whether fixation breaks have been recent, 
%      we need to refer to currRunNum instead of currTrialNum. (Fixation
%      breaks, by definition, will only occur on runs that do not count as
%      completed trials, since a fixation break is the only thing that 
%      causes a trial to be repeated).
%
%      
%   Put simply, this loop sets a value for "fixBreak.recent", which accumulates
%   the number of recent breaks. If a threshold for "too many breaks too 
%   recently" is crossed, "fixBreak.recent" is reset to 0, and the variable
%   "recal" is set to 1, meaning "recalibrate after this function is done." 
%   (NOTE: "recent" is a flexible definition, and I will explain this
%   flexibility in a moment)
%
% A) First, the loop checks to see if this is the first fixation break so 
%   far on this block. If so, no recalibration happens and fixBreak.recent is 
%   set to 0. 
%      On all following breaks, the loop compares the current run num to 
%     that of the previous fixation break.
%
% B) If no break occured within in the last 3 runs, then fixBreak.recent is
%   reset to 0, and no recalibration occurs. 
%         This is the first constraint on our definition of "recent". If
%        there are 3 trials w/o a break, then the current break is
%        considered fresh, as opposed to symptomatic of a poor calibration
%
% C) If the previous break was within the last 3 runs, then the loop
%   considers this "recent" (this is where "recent" gains a complicated 
%   definition).
%            However, having only 2 breaks within 3 runs would be a low 
%           standard for recalibration (a long and annoying process-> we 
%           only want it to occur if fixation breaks are happening pretty 
%           consistently).
%
% D)    Instead, the loop verifies the value of fixBreak.recent. If it is less
%      than 3, it adds 1 to its value, but does not recalibrate.
%          This will be the value of fixBreak.recent on the next breakProc run.
%         
%
% E)    The next time there is a fixation break, it will check fixBreak.recent,
%     and if a fixation break occured within the last 3 runs, AND 
%     fixBreak.recent is > 3, THEN and ONLY THEN then will recalibration occur.
%          Therefore, there must be 4 fixation breaks "recently" for
%         recalibration to occur.
%
%   Again, if eventually there are 3 runs (trial attempts) in a row with no
%  fixation break, then fixBreak.recent is set to 0 after the next fixation break.
%   To keep track of these changes, the function outputs breakTrack and
%  fixBreak.recent, which are then called up on the next time there is
%  fixation break in the block. After each block, these variables are saved
%  to the structure breakFix.Ses{b}, where 'b' is "current block number". 
%
%
%      NOTE: If fixBreak.recent ends up being 3, but then there isn't a
%      fixation break for another 4 or 5 trials, fixBreak.recent resets to 0. 
%           You may find this threshold unideal. For me, it seemed 
%      sensible and works very well. 
%           However, you can either change the # of trials it cares about
%      ('C') or the number of 'recent' trials it takes to recalibrate ('E'). 
%      Pilot it after you change it. Too high of a threshold can be almost 
%      as bad as too low: You don't want to have to wait for too many 
%      breaks in a row, or else there will be a lot of disruptions 
%      (trials aborted and replayed), while recalibrating after fewer 
%      breaks could prevent this.
%              
%
%      NOTE: The recalibration procedure occurs outside of this function
%
%


% A)
if size(fixBreakNEW.track,1) <= 1 %Is this the first fixation break on this block?
    fixBreakNEW.recent = 0;       %   If so, define fixBreakNEW.recent as 0;
    recal = 0;                %   Don't recalibrate
% C)
elseif (currRunNum - fixBreakNEW.track{fixBreak.num-1}) < 3 %Did a fixation break happen in the last 3 trials? If "No", go to B)

% E)
    if fixBreak.recent > 3      %How many recent breaks? If more than 3, recalibrate!!         You may think this threshold isn't ideal. Change this '3' or the one above to alter the "definition" of 'recent'
        fixBreakNEW.recent = 0;      %  Reset fixBreak.recent -> no recent breakTracks w/o recalibration
        recal = 1;               %  Recalibrate!

% D)    
    else
        fixBreakNEW.recent = fixBreak.recent + 1;   %If there aren't enough recent breaks, just add to the log of number of breaks
        recal = 0;                          %Don't recal 
    end
    
% B)
else         %If there haven't been any breaks w/in the last 3 trials, but it isn't the first break this block
    recal = 0;             % No need to recalibrate
    fixBreakNEW.recent = 0;    % Reset -> none recently
end
fixBreakNEW.numRecal = fixBreak.numRecal+recal;
fixBreakNEW.num = fixBreak.num;
end


