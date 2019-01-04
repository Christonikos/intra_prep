function filtered_data =  filter_linenoise(raw_data, args)
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

% Downsample data
if args.preferences.down_sample_data
    wave   = downsample(raw_data',args.params.downsampling_ratio,0); % downsample the entire matrix (column-wise)
end

% Filter the line noise and the harmonics
for channel = 1:(channels)
    textprogressbar(timecount(channel));
    % Notch filtering
    [wave]  = notch(wave, args.params.srate, args.params.first_harmonic{1}, args.params.first_harmonic{2},1);
    [wave]  = notch(wave, args.params.srate, args.params.second_harmonic{1},args.params.second_harmonic{2},1);         % Second harmonic of 60 or 50
    [wave]  = notch(wave, args.params.srate, args.params.third_harmonic{1},args.params.third_harmonic{2},1);          % Third harmonic of 60 or 50
    % in Houston they obseved noise at the first sub-harmonics (90Hz)
    if args.preference.filter_sub_harmonics
        [wave]  = notch(wave, args.params.srate, args.params.first_sub_harmonic{1}, args.params.first_sub_harmonic{2},1);  % First sub-harmonic of 60 or 50
    end
    
    filtered_data(channel,:) = wave;
end

textprogressbar([newline 'The line noise removal has been completed.'])
