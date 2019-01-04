function args = load_settings_params(P)

% load_settings_params : Add the paths to the Data and the various
% toolboxes needed for the analysis.
%       INPUTS  :   varargin
%
%       OUTPUTS :   args               : Struct - with the following fields
%                   1. settings        : Struct - paths and general info
%                   2. params          : Struct - parameters of the paradigm and filtering
%                   3. preferences     : Struct - flags for what to execute 
%
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
params.downsampling_ratio           = 4; % integer: Decrease the sampling rate of a sequence by n.
params.srate            = 2000;
% Stage 1: line filtering (set the notch-filtering bandwidth)
params.first_harmonic{1}            = 59;
params.first_harmonic{2}            = params.first_harmonic{1}  + 2;
params.first_sub_harmonic{1}        = 90; % Apply only if preference.filter_sub_harmonics is set to True
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
preferences.down_sample_data        = true;
preferences.filter_sub_harmonics    = false;
preferences.hfo_detection           = false;

%% Append to args struct:
args.settings = settings;
args.params = params;
args.prefernces = preferences;

end