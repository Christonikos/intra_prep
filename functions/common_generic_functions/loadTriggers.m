function  concatenatedTriggers = loadTriggersCFC(settings)
% List the directory for more than 1 recordings
files = dir(fullfile(settings.path2output,join([ 'daq_events_',settings.patient]), 'daq_events_*.mat'));
% Preallocate the cell for storing the data (assume a maximum 100 of recordings)
triggers = cell(100,1);
% Loop through recordings
for f = 1:length(files)
  triggers{f,:} = load(fullfile(settings.path2output,join([ 'daq_events_',settings.patient]),files(f).name));
end
% Keep only the non empty rows
triggers = triggers(~cellfun('isempty',triggers));
% Based on length of the triggers cell concatenate across recordings 
if length(triggers) == 1
  concatenatedTriggers = triggers{1}.ttl_all;
elseif length(triggers) == 2
  concatenatedTriggers = [triggers{1}.ttl_all triggers{2}.ttl_all];
else 
  concatenatedTriggers = [triggers{1}.ttl_all triggers{2}.ttl_all triggers{3}.ttl_all];
end




