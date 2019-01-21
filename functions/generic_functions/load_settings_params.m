function args = load_settings_params(P)

% load_settings_params : Add the paths to the Data and the various
% toolboxes needed for the analysis.
%       INPUTS  :   P                  :varargin
%
%       OUTPUTS :   args               : Struct - with the following fields
%                   1. settings        : Struct - paths and general info
%                   2. params          : Struct - parameters of the paradigm and filtering
%                   3. preferences     : Struct - flags for what to execute 
%
% ---------------------------------------------------------------------------------------------

%% -------- Default arguments -------- %%
P = parsePairs(P); % Parse varargin
checkField(P,'root_path', fullfile(filesep, 'neurospin','unicog', 'protocols', 'intracranial','example_project'));
checkField(P,'hospital' ,'Houston');
checkField(P,'patient'  ,'TS096');
checkField(P,'datatype' ,'Blackrock');
checkField(P,'session'  ,'s1')
checkField(P,'cleaning_level','channel');% epoch/channel

%% General settings:
settings.path2rawdata       = fullfile(P.root_path,'Data', 'Raw', P.hospital , P.patient, P.session, filesep);                      % Path to raw-data folder.
settings.path2deriv.power   = fullfile(P.root_path,'Data','derivatives','power', P.hospital , P.patient, P.session, filesep);       % Path to power derivative.
settings.path2deriv.preproc = fullfile(P.root_path,'Data','derivatives','preproc', P.hospital , P.patient, P.session, filesep);     % Path to pre-processed data.
settings.path2epoched_data  = fullfile(P.root_path,'Data', 'derivatives','epochs', P.hospital , P.patient, P.session, filesep);     % Path to the epoched-data folder.
settings.path2figures       = fullfile(P.root_path,'Figures',P.hospital , P.patient, P.session, filesep);                           % Path to Figures folder.
settings.path2output        = fullfile(P.root_path,'Output', P.hospital , P.patient, P.session, filesep);                           % Path to output folder.


% Append info to settings object:
settings.root_path  =    P.root_path;
settings.hospital   =    P.hospital;
settings.patient    =    P.patient;
settings.datatype   =    P.datatype;
settings.session    =    P.session;

%% General parameters:
params.downsampling_ratio           = 4; % integer: Decrease the sampling rate of a sequence by n.
params.srate                        = 2000;

%% Stage 1: line filtering (set the notch-filtering bandwidth)
params.first_harmonic{1}            = 59;
params.first_harmonic{2}            = params.first_harmonic{1}  + 2;
params.first_sub_harmonic{1}        = 90;  % Apply only if preference.filter_sub_harmonics is set to True
params.first_sub_harmonic{2}        = params.first_sub_harmonic{1} + 2;
params.second_harmonic{1}           = 119;
params.second_harmonic{2}           = params.second_harmonic{1} + 2;
params.third_harmonic{1}            = 179;
params.third_harmonic{2}            = params.third_harmonic{1}  + 2;


%% Stage 2: variance-based rejection
params.medianthreshold              = 5;        % [var] used @stage 1
params.spikingthreshold             = 1e5;      % [mV/second]  used @stage 2
%% Stage 3: spike detection
params.jump_rate_thresh             = 1;        % [Hz] For spike detection (stage 3): maximal number of jumps allowed per sec.
%% Stage 4 : HFOs detection 
params.hfo_detection_threshold      = 1.5;      % ratio used @stage 4 (HFO detection)

%% Preferences
preferences.visualization           = false;
preferences.down_sample_data        = true;
preferences.filter_sub_harmonics    = false;
preferences.cleaning_level          = P.cleaning_level; 


%% Append to args struct:
args.settings       = settings;
args.params         = params;
args.preferences    = preferences;

