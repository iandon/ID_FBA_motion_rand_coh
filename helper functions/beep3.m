function beep3(w1, w2, t, good)
%beep3(w1,, w2, t, good)
%plays two short tones as an audible cue
%
%USAGE:
%    beep3
%    beep3(w1, w2)    specify frequency (200-1,000 Hz)
%    beep3(w1, w2, t)     "       "       and duration in seconds
%    beep3(w1, w2, t,good)   " "  and  " " and if good = 0, then tone is perturbed (more harsh -> for 'incorrect' response tone)

fs=8192;  %sample freq in Hz

if (nargin <= 1 )
    w1=1000; w2=1000;   %default
    t = [0:1/fs:.2];   %default
elseif (nargin == 2)
    t = [0:1/fs:.2];   %default
elseif (nargin <= 5)
    t = [0:1/fs:t];
    t2 = t*4;
end

if (nargin == 4)
    if good
        wave1 = sin(2*pi*w1*t); wave2 = sin(2*pi*w2*t);
    else
        wave1=sin(2*pi*w1*t) + (.1*cos(2*pi*w2*t2 +(pi/3))); wave2=sin(2*pi*w2*t) + (.1*cos(2*pi*w2*t2 +(pi/3)));
    end
else
    wave1 = sin(2*pi*w1*t); wave2 = sin(2*pi*w2*t);
end
    
    
%play sound
sound([wave1, wave2],fs);
end