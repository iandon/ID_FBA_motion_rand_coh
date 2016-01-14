function [pixels] = degs2Pixels(screenRes, screenSize, distance, degs,getScreenLoc, varargin)
% screenRes - the resolution of the monitor
% screenSize - the size of the monitor in cm
% (these values can either be along a single dimension or for both the width and height)
% distance - the viewing distance in cm.
% degs - the amount of degress that should be transformed to a number of pixels
% xylocdeg: stim aperture centers in degrees - can be one or 2 or more
% getScreenLoc: whether degs are coordinates  or just absolute size 


pixSizeCm = screenSize./screenRes; %calculates the size of a pixel in cm

degperpix=(2*atan(pixSizeCm./(2*distance))).*(180/pi);

pixperdeg = 1./degperpix;


len=size(degs);
if nargin == 5
    for i=1:len(1)
        pixels(i,:) = pixperdeg.*degs(i,:);
    end
    screenRes=repmat(screenRes./2,i,1);
    pixels= pixels+ screenRes;
else
    pixels = pixperdeg.*degs;
end



