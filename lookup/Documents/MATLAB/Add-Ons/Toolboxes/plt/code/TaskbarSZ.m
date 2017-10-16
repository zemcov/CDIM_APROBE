function [loc,TaskH,TaskW] = TaskbarSZ()

% Returns the taskbar location.
% This function will only be called in unusual situations (such as
% with very old versions of Matlab) where the java frame does not exist.

% If like most people, you have a taskbar at the bottom of the screen you
% probably do not need to edit this file unless you use a taskbar that is
% thicker or skinnier than average.
%
% On the other hand if you do have an unusual screen layout or you are
% very particular about the exact locations where plt places its figures
% you may want to edit this file. If you do this, it is a good idea to
% move the file to some other folder on your Matlab path so that this
% file doesn't get overwritten when you update plt to a newer version.

% Typical values for a large screen (1920x1200) --------------
% loc   = 'botttom'; % must be 'bottom', 'top', 'left', or 'right', 'none'
% TaskH =  46;       % taskbar height (pixels)
% TaskW = 132;       % taskbar width (pixels)

% Typical values for a small screen (1024x768) --------------
%  loc   = 'bottom'; % must be 'bottom', 'top', 'left', or 'right', on 'none'
%  TaskH =  30;      % taskbar height (pixels)
%  TaskW = 105;      % taskbar width (pixels)

loc   = 'bottom';
TaskH = 30;
TaskW = 105;

% Note that TaskW will not be used if loc is set to 'top','bot', or 'non'
% and TaskH will not be used of loc is set to 'rig','lef', or 'non'
% and you may set the unused values to zero if you never intend to switch
% the taskbar location.
