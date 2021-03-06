function save_channels(filtered_data, args)
%  save_channels:  saves the filtered data per channel
%                   on the derivative/preproc folder.
% INPUTS :
%           1. filtered_data : Matrix [channels x time]
%           2. args          : Struct - the configuration struct.

% get the number of channels
channels = size(filtered_data,1); patient = args.settings.patient;
% check if the directory exists-else create it
dir2save = args.settings.path2deriv.preproc;
if ~exist(string(dir2save),'dir'); mkdir(dir2save); end
% current session
session = args.settings.session;
% loop through channels

timecount = linspace(1,100,size(filtered_data,1));
clear textprogressbar
textprogressbar([newline  'Saving each channel as a .csv file: ' ])
for c_id = 1:channels
    % save each channel to the dir2save folder
    textprogressbar(timecount(c_id))
    curr_channel = filtered_data(c_id,:);
    csvwrite(fullfile(dir2save, ...
        join(['ch_',num2str(c_id),'_',patient,'_',session,'.csv'])),curr_channel);
end
disp([newline 'Preprocessed data saved to : ' newline dir2save])