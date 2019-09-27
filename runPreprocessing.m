% runPreprocessing: This is the pre-processing pipeline for the intracranial
% data. The goal of this scrip is to be as generic as possible, integrating
% data from various research centers such as the Houston medical center,
% the Marseille research center etc.
% Written by : Christos-Nikolaos Zacharopoulos and Yair Lakretz @UNICOG 2018
%              [christonik[at]gmail.com]
% based on a similar pipeline used at the Stanford University.
% This is a plug-and-play function, to change any input variable, provide it
% as a pair-input  in the command window.
% example :
% runPreprocessing('patients','TS096','medianthreshold',4,'spikingthreshold',80);
% --------------------------------------------------------------------------------------------------
function runPreprocessing(varargin)
%% -----------  BRANCH 1 - SET AND ADD PATHS ----------- %
% Keep the workspace clean
clearvars -except varargin; clc; close all;
%Check whether the debug mode is on
if feature('IsDebugMode')
    dbquit all
    dbstop if error
end
dbstop if error
% Add the dependencies to the path.
addpath(genpath(fullfile(pwd,'functions')));
%% -----------  LOAD PARAMETERS ----------- %
% load settings and parameters
args = load_settings_params(varargin);
%% -----------  LOAD RAW DATA ----------- %
% load the raw data : matrix of dimensions : [channels x time].
[raw_data, labels, channels]   = load_raw_data(args);
fprintf('Raw files were loaded into matlab (#channels = %d)\n', channels)
%% -----------  MAIN  CHANNEL REJECTION ANALYSIS----------- %
[filtered_data , rejected_channels, args] = mainPreProcessing_channel(raw_data, labels, args);
clear raw_data % release RAM
%% -----------  SAVE DATA AND LOG-FILE ------------------ %
% save channel log-file to output folder
save_logfile(rejected_channels, args)
% save filtered data to output folder
save_channels(filtered_data, args)













