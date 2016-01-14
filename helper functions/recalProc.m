function [] = recalProc(el)

Eyelink('Message', 'RECALIBRATE OBSERVER')
EyelinkDoTrackerSetup(el, 'c');

doneRecalMSG = sprintf('Recalibration complete!')



end
