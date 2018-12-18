% runPreprocessing: This is the pre-processing pipeline for the intracranial
% data. The goal of this scrip is to be as generic as possible, integrating
% data from various research centers such as the Houston medical center,
% the Marseille research center etc.
% Written by : Christos-Nikolaos Zacharopoulos @UNICOG 2018
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
% Add the dependencies on the path
addpath(genpath(fullfile(pwd,'functions')));
% Get the data path based on the hostname of the computer in use. The
% variables are unaffected from the OS.
[~,hard_drive_path, elecs_path] = getCore;
%% -----------  BRANCH 2 - SPECIFY THE RESEARCH CENTER  AND THE CLEANING PARAMETERS ----------- %
% In this branch we manunally add the list of patients that corresponds to each
% individual project.
P = parsePairs(varargin);
%checkField(P,'Hospital',{'Houston'});
% get the hospital-ID
hopID = P.Hospital{1};
% load settings and parameters
[settings, params, P]   = load_settings_params(hard_drive_path, P);
%recID                   = P.recordingmethod{1};
%datatypeID              = P.datatype{1};
%% -----------  BRANCH 3 - LOAD THE RAW DATA ----------- %
% load the raw data : matrix of dimensions : [channels x time]. 
[raw_data, ~, labels]   = load_raw_data(settings, P);
%% -----------  BRANCH 4 - MAIN  CHANNEL REJECTION ANALYSIS----------- %
% Memory pre-allocation
clean_data              = zeros(size(raw_data,1),size(raw_data,2)); 
% function handle to the main function.
m = @mainPreProcessing;
[clean_data, indexofcleandata] = m(P, settings, raw_data{recording }, params, labels, gyri);
















