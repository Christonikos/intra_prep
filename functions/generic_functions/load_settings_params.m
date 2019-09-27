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
%checkField(P,'root_path', fullfile(filesep, 'neurospin','unicog', 'protocols', 'intracranial','example_project'));
checkField(P,'root_path', fullfile(filesep,'media','czacharo' ,'Transcend', 'Marseille_Jab'));
checkField(P,'project' ,'Marseille_Jab');
checkField(P,'patient'  ,'JAP02');
checkField(P,'datatype' ,'Neuroscan');
checkField(P,'session'  ,'ses-01');
checkField(P,'modality', 'ieeg');

%% General settings:
% --INPUT--
settings.path2rawdata           = fullfile(P.root_path,'Data',  P.patient, P.session, P.modality, filesep);  				                    % Path to raw-data folder.
% --OUTPUT--
settings.path2deriv.power       = fullfile(P.root_path,'Data','Derivatives','Power', P.patient, P.session, filesep);       % Path to power derivative.
settings.path2deriv.preproc     = fullfile(P.root_path,'Data','Derivatives','Preproc', P.patient, P.session, filesep);     % Path to pre-processed data.
settings.path2epoched_data      = fullfile(P.root_path,'Data', 'Derivatives','Epochs', P.patient, P.session, filesep);     % Path to the epoched-data folder.
settings.path2figures           = fullfile(P.root_path,'Figures', P.patient, P.session, filesep);                          % Path to Figures folder.
settings.path2output            = fullfile(P.root_path,'Output', P.patient, P.session, filesep);                           % Path to output folder.
settings.path2behavioral_files  = fullfile(settings.path2rawdata,'Behavioral_files');                                      % Path to the behavioral files.

% Append info to settings object:
settings.root_path  =    P.root_path;
settings.project    =    P.project;
settings.patient    =    P.patient;
settings.datatype   =    P.datatype;
settings.session    =    P.session;

%% General parameters:
params.downsampling_ratio           = 2; % integer: Decrease the sampling rate of a sequence by n.
params.srate                        = 2500;

%% Stage 1: line filtering (set the notch-filtering bandwidth)
params.first_harmonic{1}            = 49;
params.first_harmonic{2}            = params.first_harmonic{1}  + 2;
params.first_sub_harmonic{1}        = 99;  % Apply only if preference.filter_sub_harmonics is set to True
params.first_sub_harmonic{2}        = params.first_sub_harmonic{1} + 2;
params.second_harmonic{1}           = 149;
params.second_harmonic{2}           = params.second_harmonic{1} + 2;
params.third_harmonic{1}            = 199;
params.third_harmonic{2}            = params.third_harmonic{1}  + 2;

%% Set the epoching window:
params.before_onset                 = 300;      % [ms]
params.after_onset                  = 800;      % [ms]

%% Stage 2: variance-based rejection
params.medianthreshold              = 6;        % [var] used @stage 1
params.spikingthreshold             = 1e5;      % [mV/second]  used @stage 2
%% Stage 3: spike detection
params.jump_rate_thresh             = .1;        % [Hz] For spike detection (stage 3): maximal number of jumps allowed per sec.
%% Stage 4 : HFOs detection 
params.hfo_detection_threshold      = 1.5;      % ratio used @stage 4 (HFO detection)

%% Preferences
preferences.visualization           = false;
preferences.down_sample_data        = true;
preferences.filter_sub_harmonics    = true;


%% Append to args struct:
args.settings       = settings;
args.params         = params;
args.preferences    = preferences;

