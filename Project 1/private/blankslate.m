%This initializes the workspace, memory and command line to give a clean slate. 
%It also avoids overly many significant digits and too much output blanks
%Pascal Wallisch
%08/20/2012

clear all;
close all;
clc;
tic;
format short
format compact

%It also starts tic in case you wonder how long you had Matlab running (if you
%invoke toc)
