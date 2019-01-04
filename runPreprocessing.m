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
% runPreprocessing('patients',{'TS096'},'medianthreshold',4,'spikingthreshold',80);
% --------------------------------------------------------------------------------------------------
function runPreprocessing(varargin)
%% -----------  BRANCH 1 - SET AND ADD PATHS ----------- %
% In this branch we define the paths for the user.
clc;  close all;
% Keep the workspace clean
clearvars -except varargin
%Check whether the debug mode is on
if feature('IsDebugMode')
    dbquit all
end
% Add the dependencies to the path.
addpath(genpath(fullfile(pwd,'functions')));
%% -----------  LOAD PARAMETERS ----------- %
% load settings and parameters
args = load_settings_params(varargin);
%% -----------  LOAD RAW DATA ----------- %
% load the raw data : matrix of dimensions : [channels x time]. 
[raw_data, channels]   = load_raw_data(args);
fprintf('Raw files were loaded into matlab (#channels = %d)\n', channels)
%% -----------  MAIN  CHANNEL REJECTION ANALYSIS----------- %
[filtered_data , indexofcleandata, rejectedchannels] = mainPreProcessing(raw_data, args);

%% TODO: Save the filtered data into a new folder















