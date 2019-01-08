function export_channels(filtered_data, args)
% saves the filtered data per channel on the output folder. 
% get the number of channels 
channels = size(filtered_data,1); patient = args.settings.patient;
% check if the directory exists-else create it 
dir2output = args.settings.path2output; 
if ~exists(dir2output,'dir'); mkdir(dir2output); end
% get the current session %to do : set it as an argument
session = dir2output(end-2:end-1);
% loop through channels 
for c_id = 1:channels 
    % save each channel to the output folder 
    curr_channel = filtered_data(c_id,:);
   save(fullfile(dir2output, ...
                join(['ch_',c_id,'_',patient,'_',session])),'curr_channel','-v7.3');          
end