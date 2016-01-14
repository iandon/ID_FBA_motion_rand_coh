function [fixBreak] = fixCheck()
% check eyelink for x and y parameters of last guess
% output whether or not fixation was broken, based on param for fixation region
% 
global params



ELguess = Eyelink('newestfloatsample');
xEL = ELguess.gx(2); %Dominant eye should be measured-> check, 2 for right 1 for left
yEL = ELguess.gy(2);


x = abs(xEL) - params.screen.centerPix(1);
y = abs(yEL) - params.screen.centerPix(2);

h = sqrt((x^2) + (y^2));

if h > params.eye.fixCheckRadiusPix
    fixBreak = 1;
    Eyelink('Message', sprintf('BROKE FIXATION'));
else
    fixBreak = 0;
end
    



end