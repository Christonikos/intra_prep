function [settings, params, preferences, P] = load_settings_params(P)
% -------------------------------------
% function args = load_settings_params(P)
% --------------------------------------

% load_settings_params : Add the paths to the Data and the various
% toolboxes needed for the analysis.
%       INPUTS  :   varargin
%
%       OUTPUTS : 
%                   1. settings        : Struct - Holds the paths to
%                                                 various locations such as the data directory etc.
%                   2. params          : Struct - Holds various hospital-specific information such as the
%                                                 soa of the paradigm and the notch filtering parameters.
%                   3. preferences     : Struct - Returns the preferences
%                                                 struct including the following fields :
%                                                 3.1 : median threshold -
%                                                 This threshold will be
%                                                 later used on the
%                                                 rejection of channels
%                                                 based on non-pathological
%                                                 reasons.
%                                                 3.2 : spiking threshold -
%                                                 This threshold will be
%                                                 used to to detect spikes
%                                                 (abrupt voltage changes)
%                                                 in the signal.
%                                                 3.3 : visualization -
%                                                 "true"/"false" : The option "true"
%                                                 allows for visualization of the
%                                                 rejected electrodes at each stage
%                                                 of the pipeline.
%
%                   4.P                : Struct - Holds generic arguments
%                                                 such as the root path, 
%                                                 the datatype and the session.
% ---------------------------------------------------------------------------------------------
P = parsePairs(P);
%% -------- Default arguments -------- %%
checkField(P,'root_path', fullfile(filesep, 'neurospin','unicog', 'protocols', 'intracranial','example_project'));
checkField(P,'hospital' ,'Houston');
checkField(P,'patient'  ,'TS096');
checkField(P,'datatype' ,'Blackrock');
checkField(P,'session'  ,'s1')

%% General settings:
settings.path2rawdata   = fullfile(P.root_path,'data',   P.hospital , P.patient, P.session, filesep); % Path to raw-data folder
settings.path2figures   = fullfile(P.root_path,'figures',P.hospital , P.patient, P.session, filesep); % Path to Figures folder
settings.path2output    = fullfile(P.root_path,'output', P.hospital , P.patient, P.session, filesep); % Path to output folder

% Append info to settings object:
settings.root_path = P.root_path;
settings.hospital = P.hospital;
settings.patient = P.patient;
settings.datatype = P.datatype;

%% General parameters:
params.downsampling                 = 500;    % [Hz]
params.srate            = 2000;
% Stage 1: line filtering (set the notch-filtering bandwidth)
params.first_harmonic{1}            = 59;
params.first_harmonic{2}            = params.first_harmonic{1}  + 2;
params.second_harmonic{1}           = 119;
params.second_harmonic{2}           = params.second_harmonic{1} + 2;
params.third_harmonic{1}            = 179;
params.third_harmonic{2}            = params.third_harmonic{1}  + 2;
% Stage 2: variance-based rejection
params.medianthreshold              = 5;      % [var] used @stage 1
params.spikingthreshold             = 80;     % [mV]  used @stage 2
% Stage 3: spike detection
params.jump_rate_thresh = 1;    % [Hz] For spike detection (stage 3): meximal number of jumps allowed per sec.

%% Preferences
preferences.visualization           = false;
preferences.filter_sub_harmonics    = false;
preferences.hfo_detection           = false;

args.settings = settings;
args.params = params;
args.prefernces = preferences;
