function [settings, params] = load_settings_params(hard_drive_path, patid, recMethod, hopid)
% load_settings_params : Add the paths to the Data and the various
% toolboxes needed for the analysis.
%       INPUTS  :
%                   1. hard_drive_path : String - The path to the data (provided by getCore.m)
%                   2. patid           : String - The ID of the given
%                                        patient (provided @ runPreprocessing.m)
%                   3. recMethod       : String - The recording method ID (provided @ runPreprocessing.m). 
%                   4. hopid           : String - The hospital-ID (provided @ runPreprocessing.m).
%       OUTPUTS : 
%                   1. settings        : Struct - Holds the paths to
%                                                 various locations such as the data directory etc.
%                   2. params          : Struct - Holds various hospital-specific information such as the 
%                                                 soa of the paradigm and the notch filtering parameters.  
%   
% --------------------------------------------------------------------------------------------------------
% Add the path to fieldtrip (if you need to open raw files using fieldtrip)
% addpath(fullfile(core,'NeuroSyntax2', 'Code','External','MATLAB','ToolBoxes','fieldtrip_20171218'));
% To load the neuromeg data, add the path to the mne from fieldtip
% addpath(fullfile(core,'NeuroSyntax2', 'Code','External','MATLAB','ToolBoxes','fieldtrip_20171218','external','mne'));
% Check the fieldtrip installation
% ft_defaults;
% --------------------------------------------------------------------------------------------------------

%------------------- PATIENT - CHOSEN IN THE RUN FUNCTION -------------------%
settings.patient = patid;
%------------------- HOSPITAL - CHOSEN IN THE RUN FUNCTION -------------------%
switch hopid
    case 'Houston'
        % ------------------------------------- SETTINGS ------------------------------------- %
        settings.path2rawdata   = fullfile(hard_drive_path,'NeuroSyntax2','Data','Houston', settings.patient);
        %------------------- Epoch paths -------------------%
        settings.path2epochs    = fullfile(hard_drive_path,'NeuroSyntax2','Output', settings.patient,'epochs', filesep);
        %------------------- Figure paths -------------------%
        settings.path2figures   = fullfile(hard_drive_path,'NeuroSyntax2','Figures', settings.patient, filesep);
        %------------------- Output paths -------------------%
        settings.path2output    = fullfile(hard_drive_path,'NeuroSyntax2','Output', settings.patient ,filesep); 
        % ------------------------------------- PARAMETERS  ------------------------------------- %
        params.srate    = 2000;
        params.soa      = 0.532;
        % Set the notch-filtering bandwidth 
        params.first_harmonic{1}    = 59;
        params.first_harmonic{2}    = params.first_harmonic{1} +2;
        params.second_harmonic{1}   = 119;
        params.second_harmonic{2}   = params.first_harmonic{1} +2;
        params.third_harmonic{1}    = 179;
        params.third_harmonic{2}    = params.first_harmonic{1} +2;
        
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
        % ------------------------------------- SETTINGS ------------------------------------- %
        settings.path2rawdata   = fullfile(hard_drive_path, 'Marseille_MEG_SEEG','Data','RAW_DATA', settings.patient, recMethod, filesep);
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
        
end