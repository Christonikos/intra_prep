function [settings, params, P] = load_settings_params(P)
% load_settings_params : Add the paths to the Data and the various
% toolboxes needed for the analysis.
%       INPUTS  :
%                   1. hard_drive_path : String - The path to the data (provided by getCore.m)
%                   2. patid           : String - The ID of the given
%                                        patient (provided @ runPreprocessing.m)
%                   3. hopid           : String - The hospital-ID (provided @ runPreprocessing.m).
%                   4. P               : Struct - The main configuration
%                                                 struct (created @ runPreprocessing.m)
%       OUTPUTS : 
%                   1. settings        : Struct - Holds the paths to
%                                                 various locations such as the data directory etc.
%                   2. params          : Struct - Holds various hospital-specific information such as the 
%                                                 soa of the paradigm and the notch filtering parameters.  
%                   3. P               : Struct - Returns the configuration
%                                                 struct including the following fields : 
%                                                 3.1 : recording method (sEEG, Grid)
%                                                 3.2 : median threshold -
%                                                 This threshold will be
%                                                 later used on the
%                                                 rejection of channels
%                                                 based on non-pathological
%                                                 reasons. 
%                                                 3.3 : spiking threshold -
%                                                 This threshold will be
%                                                 used to to detect spikes
%                                                 (abrupt voltage changes)
%                                                 in the signal.
%                                                 3.4 : processing -
%                                                 "quick"/"slow" : The option "slow" 
%                                                 allows for visualization of the 
%                                                 rejected electrodes at each stage 
%                                                 of the pipeline.
%                                                 
%  
% --------------------------------------------------------------------------------------------------------
% Add the path to fieldtrip (if you need to open raw files using fieldtrip)
% addpath(fullfile(core,'NeuroSyntax2', 'Code','External','MATLAB','ToolBoxes','fieldtrip_20171218'));
% To load the neuromeg data, add the path to the mne from fieldtip
% addpath(fullfile(core,'NeuroSyntax2', 'Code','External','MATLAB','ToolBoxes','fieldtrip_20171218','external','mne'));
% Check the fieldtrip installation
% ft_defaults;
% --------------------------------------------------------------------------------------------------------

%------------------- HOSPITAL - CHOSEN IN THE RUN FUNCTION -------------------%
hard_drive_path = P.root_path;
checkField(P,'Hospital',{'Houston'});
% get the hospital-ID
hopid = P.Hospital;

switch hopid
    case 'Houston'
        % -------- Patients -------- %
        checkField(P,'patients',{'TS096'});
        % get the patient-ID
        patid               = P.patients;
        settings.patient    = patid;
        % ------------------------------------- SETTINGS ------------------------------------- %
        settings.path2rawdata   = fullfile(hard_drive_path,'NeuroSyntax2','Data','Houston', settings.patient);
        %------------------- Figure paths -------------------%
        settings.path2figures   = fullfile(hard_drive_path,'NeuroSyntax2','Figures', settings.patient, filesep);
        %------------------- Output paths -------------------%
        settings.path2output    = fullfile(hard_drive_path,'NeuroSyntax2','Output', settings.patient ,filesep);
        % ------------------------------------- PARAMETERS  ------------------------------------- %
        params.srate    = 2000;
        params.soa      = 0.532;
        % Set the notch-filtering bandwidth
        params.first_harmonic{1}        = 59;
        params.first_harmonic{2}        = params.first_harmonic{1} +2;
        params.first_sub_harmonic{1}    = 89;
        params.first_sub_harmonic{2}    = params.first_sub_harmonic{1} +2;
        params.second_harmonic{1}       = 119;
        params.second_harmonic{2}       = params.second_harmonic{1} +2;
        params.third_harmonic{1}        = 179;
        params.third_harmonic{2}        = params.third_harmonic{1} +2;
        
        % -------- Recording methods -------- %
        checkField(P,'recordingmethod',{'sEEG'});
        checkField(P,'datatype',{'Blackrock'});
        % -------- Cleaning Thresholds --------     %
        checkField(P,'medianthreshold', 5);         % distance from the median
        checkField(P,'spikingthreshold',80);        % spiking threshold
        checkField(P,'rereference','bipolar');      % commonaverage, clinical
        checkField(P,'vizualization',true);         %'slow'/'quick'.
        checkField(P,'hfo_detection',false);
        checkField(P,'rawfilename','TS096_NeuroSyntax2_sEEG_files_a/20170606-111436-001.ns3')
        
        % -------------------- APPENDIX -------------------- %
        % --- Houston Patients --- %
        %   'TA719'
        %   'TA724'
        %   'TA750'
        %   'TS083'
        %   'TS096'
        %   'TS097'
        %   'TS100'
        %   'TS101'
        %   'TS104'
        %   'TS107'
        %   'TS109'
        % ----------------------- %

    case 'UMC'
        % ------------------------------------- SETTINGS ------------------------------------- %
        settings.path2rawdata   = fullfile(hard_drive_path,'NijmegenHippocampus','Data',settings.patient);
        %------------------- Figure paths -------------------%
        settings.path2figures   = fullfile(hard_drive_path,'NijmegenHippocampus','Figures', settings.patient, filesep);
        %------------------- Output paths -------------------%
        settings.path2output    = fullfile(hard_drive_path,'NijmegenHippocampus','Output', settings.patient ,filesep);
        % ------------------------------------- 	PARAMETERS  ------------------------------------- %
        params.srate = 1000;
        % Set the notch-filtering bandwidth
        params.first_harmonic{1}    = 49;
        params.first_harmonic{2}    = params.first_harmonic{1} +2;
        params.second_harmonic{1}   = 99;
        params.second_harmonic{2}   = params.first_harmonic{1} +2;
        params.third_harmonic{1}    = 149;
        params.third_harmonic{2}    = params.first_harmonic{1} +2;
        
    case 'NeuroSpin'
        % ------------------------------------- SETTINGS ------------------------------------- %
        settings.path2rawdata   = fullfile(hard_drive_path,'FoscaMEG','Data',settings.patient);
        %------------------- Figure paths -------------------%
        settings.path2figures   = fullfile(hard_drive_path,'FoscaMEG','Figures', settings.patient, filesep);
        %------------------- Output paths -------------------%
        settings.path2output    = fullfile(hard_drive_path,'FoscaMEG','Output', settings.patient ,filesep);
        % ------------------------------------- 	PARAMETERS  ------------------------------------- %
        params.srate = 1000;
        % Set the notch-filtering bandwidth
        params.first_harmonic{1}    = 49;
        params.first_harmonic{2}    = params.first_harmonic{1} +2;
        params.second_harmonic{1}   = 99;
        params.second_harmonic{2}   = params.first_harmonic{1} +2;
        params.third_harmonic{1}    = 149;
        params.third_harmonic{2}    = params.first_harmonic{1} +2;
        
    case 'Marseille'
        % -------- Recording methods -------- %
        checkField(P,'recordingmethod',{'sEEG'});
        checkField(P,'datatype',{'Blackrock'});
        % -------- Cleaning Thresholds --------     %
        checkField(P,'medianthreshold', 5);         % distance from the median
        checkField(P,'spikingthreshold',80);        % spiking threshold
        checkField(P,'rereference','bipolar');      % commonaverage, clinical
        % ------------------------------------- SETTINGS ------------------------------------- %
        settings.path2rawdata   = fullfile(hard_drive_path, 'Marseille_MEG_SEEG','Data','RAW_DATA', settings.patient, P.recordingmethod{1}, filesep);
        %------------------- Output paths -------------------%
        settings.path2output    = fullfile(hard_drive_path,'Marseille_MEG_SEEG','Output', settings.patient,recMethod ,filesep);
        %------------------- Figure paths -------------------%
        settings.path2figures   = fullfile(hard_drive_path,'Marseille_MEG_SEEG','Figures', settings.patient,recMethod ,filesep);
        % ------------------------------------- 	PARAMETERS  ------------------------------------- %
        params = struct();
        % Set the notch-filtering bandwidth
        params.first_harmonic{1}    = 49;
        params.first_harmonic{2}    = params.first_harmonic{1} +2;
        params.second_harmonic{1}   = 99;
        params.second_harmonic{2}   = params.first_harmonic{1} +2;
        params.third_harmonic{1}    = 149;
        params.third_harmonic{2}    = params.first_harmonic{1} +2;

    case 'UCLA'
        
        % -------- Patients -------- %
        checkField(P,'patients','patient_479');
        % get the patient-ID
        patid               = P.patients;
        settings.patient    = patid;
        % ------------------------------------- SETTINGS ------------------------------------- %
        settings.path2rawdata   = fullfile(hard_drive_path,'Data','UCLA', settings.patient, 'Raw');
        %------------------- Figure paths -------------------%
        settings.path2figures   = fullfile(hard_drive_path,'Figures', settings.patient, filesep);
        %------------------- Output paths -------------------%
        settings.path2output    = fullfile(hard_drive_path,'Output', settings.patient ,filesep);
        % ------------------------------------- PARAMETERS  ------------------------------------- %
        params.srate    = 2000;
        params.soa      = 0.532;
        % Set the notch-filtering bandwidth
        params.first_harmonic{1}        = 59;
        params.first_harmonic{2}        = params.first_harmonic{1} +2;
        params.first_sub_harmonic{1}    = 89;
        params.first_sub_harmonic{2}    = params.first_sub_harmonic{1} +2;
        params.second_harmonic{1}       = 119;
        params.second_harmonic{2}       = params.second_harmonic{1} +2;
        params.third_harmonic{1}        = 179;
        params.third_harmonic{2}        = params.third_harmonic{1} +2;
        
        % -------- Recording methods -------- %
        checkField(P,'recordingmethod',{'sEEG'});
        checkField(P,'datatype',{'Blackrock'});
        % -------- Cleaning Thresholds --------     %
        checkField(P,'medianthreshold', 5);         % distance from the median
        checkField(P,'spikingthreshold',80);        % spiking threshold
        checkField(P,'rereference','bipolar');      % commonaverage, clinical
        checkField(P,'vizualization',true);         %'slow'/'quick'.
        checkField(P,'hfo_detection',false);
        checkField(P,'rawfilename','TS096_NeuroSyntax2_sEEG_files_a/20170606-111436-001.ns3')
end
P
