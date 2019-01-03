function [filtered_data, params] =  filter_linenoise(raw_data, params)
% Provide feedback to the user.
disp([newline...
    '---------------- Intiating Stage 1 of the analysis ---------------- ' ...
    newline ...
    '(Removal of line noise and harmonics)'...
    newline newline])
%% ----------- STEP 1 : VARIABLES INITIALIZATION ----------- %%
% Initialize variable to hold the filtered data
channels        = size(raw_data,1);
% Get the duration of the recording
duration        = size(raw_data,2);
filtered_data   = zeros(channels,duration);
timecount       = linspace(1,100,size(raw_data,1));

%% ----------- STEP 2 : FILTERING AND DOWNSAMPLING ----------- %%
clear textprogressbar
textprogressbar([newline 'Removing line noise and harmonics from all channels : ']);
% Filter the line noise and the harmonics
for channel = 1:(channels)
    textprogressbar(timecount(channel));
    % Downsample the data to 1kHz
    wave    = downsample(raw_data(channel,:),1,0);
    [wave]  = notch(wave, params.srate, params.first_harmonic{1}, params.first_harmonic{2},1);
    [wave]  = notch(wave, params.srate, params.first_sub_harmonic{1}, params.first_sub_harmonic{2},1);  % First sub-harmonic of 60 or 50
    [wave]  = notch(wave, params.srate, params.second_harmonic{1},params.second_harmonic{2},1);         % Second harmonic of 60 or 50
    [wave]  = notch(wave, params.srate, params.third_harmonic{1},params.third_harmonic{2},1);           % Third harmonic of 60 or 50
    filtered_data(channel,:) = wave;
end
% At this point, we have filtered, and downsampled  the raw
% data. Export this dataset out of the current scope. 
% Update the sampling rate (in the params struct)
params.srate = 1000;
textprogressbar([newline 'The line noise removal has been completed.'])
