% loads the epoched data that the user has deposited at the path
% /Data/derivatives/epochs/ and renames the workspace saved
% variable into a common format. 
%
% INPUTS  : 
%           1. args     - Struct : The configuration struct that holds 
%                              the settings, params and preferences.
% OUTPUTS :
%
%           1. epochs   - Cell : [number of blocks x 2]. 
%                              1st col: The loaded data file.
%                              2nd col: Information on the epoching 
%                                       method.
%           2. channels - Double : The number of channels without any
%                                  rereferencing. 
%           
%------------------------------------------------------------------
function [epochs, channels, onset_timestamp] = load_epoched_data(args)
disp([newline '-------- Loading epoched data -----------' ...
    newline newline ...
    'Patient            : ' args.settings.patient  '.' newline ...
    'Hospital           : ' args.settings.hospital '.' newline ...
    'Datatype           : ' args.settings.datatype '.' newline ...
    newline   '-----------------------------------------'])

% List the available files per session (irrelevant of stored datatype)
nfiles = dir(fullfile(args.settings.path2epoched_data));
% clear directorie entries if UNIX
if isunix; nfiles(1:2) = []; end
% initialize cell to hold epochs
epochs = cell(numel(nfiles));
% intialization for the progress bar 
timecount = linspace(1,100,size(epochs,1));
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
            epochs{file_id,2} = 'fieldtrip';
        else
            epochs{file_id,2} = 'other';
        end
    end
    epochs{file_id,1} = T.(varname); % store user's var to the epochs var.
end
clear textprogressbar

