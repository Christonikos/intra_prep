% loads the epoched data that the user has deposited at the path
% /Data/derivatives/epochs/ and renames the workspace saved
% variable into a common format. 
%
% INPUTS  : 
%           1. args     - Struct : The configuration struct that holds 
%                              the settings, params and preferences.
% OUTPUTS :
%
%           1. epochs   - Cell : [number of blocks x 1]. Each entry
%                              has dimensions : [ntrials x 1] where 
%                              each entry has dimensions 
%                              [nchannels x samples] 
%           
%------------------------------------------------------------------
function [epochs, behav_timevector, labels] = load_epoched_data(args)
disp([newline '-------- Loading epoched data -----------' ...
    newline newline ...
    'Patient            : ' args.settings.patient  '.' newline ...
    'Hospital           : ' args.settings.hospital '.' newline ...
    'Project            : ' args.settings.project  '.' newline ...
    newline   '-----------------------------------------'])

% -----------------------------------------------------------------------
%% LOAD THE EPOCHED DATA AND STORE THEM UNDER A COMMON VARIABLE NAME.
%% CHECK IF THE EPOCHING OCCURED USING THE FIELDTRIP TOOLBOX.
% -----------------------------------------------------------------------

% List the available files per session (irrelevant of stored datatype)
nfiles = dir(fullfile(args.settings.path2epoched_data));
% clear directorie entries if UNIX
if isunix; nfiles(1:2) = []; end
% initialize cell to hold epochs
user_epochs = cell(numel(nfiles));
% intialization for the progress bar 
timecount = linspace(1,100,size(user_epochs,1));
clear textprogressbar
textprogressbar([':'])
% loop through the available files
for file_id = 1:numel(nfiles)
    textprogressbar(timecount(file_id))
    % get information on the stored variables without loading anything
    file_name = fullfile(join([args.settings.path2epoched_data,filesep,nfiles(file_id).name]));
    % check if we have a .mat file
    if endsWith(file_name,'.mat'); files{file_id} = matfile(file_name); end
    v = whos(files{file_id});
    % get the workspace variable name
    varname = v.name;
    % now load the file ignoring the user's varname and assigning a new
    % name.
    T = load(file_name,varname);     % function output form of LOAD
    % If the loaded var is struct - check for the fieldname .cfg to
    % determine whether it was created via fieldtrip.
    if isstruct(T)
        if any(ismember(fieldnames(T.(varname)),'cfg'))
            user_epochs{file_id,2} = 'fieldtrip';
        else
            user_epochs{file_id,2} = 'other';
        end
    end
    user_epochs{file_id,1} = T.(varname); % store user's var to the user_epochs var.
end
clear textprogressbar

% -----------------------------------------------------------------------
%% IF THE USER PERFORMED THE EPOCHING USING FIELDTRIP GET THE BEHAVIORAL 
%% TIMESTAMP USING THE FIELD .sampleinfo .ELSE REQUEST THE VECTOR OF 
%% BEHAVIORAL ONSET FROM THE USER. 
% -----------------------------------------------------------------------
epochs = {};
for entryID = 1:size(user_epochs,1)
    if strcmp(user_epochs{entryID,2},'fieldtrip')
        behav_timevector{entryID} = user_epochs{entryID,1}.sampleinfo;
        % Now get the trials per block 
        epochs{entryID} = user_epochs{entryID,1}.trial;
    else
        error('Please provide with the vector of behavioral onset of the current project!')
        % Dimensions [1 x ntrials] (only fixation onset) or [2 x ntrials] (fixation onset to last word onset) 
    end
end

% -----------------------------------------------------------------------
%% LOAD THE CHANNEL LABELS
% -----------------------------------------------------------------------

% load the file that contains the probe information
files = dir(fullfile(args.settings.path2rawdata, '*elecs*'));
if isempty(files); error('probe names file not found!');end
labels = strtrim(string(importdata(fullfile(args.settings.path2rawdata,files.name))));
labels = strrep( labels,'"','');



