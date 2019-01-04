function filtered_data =  filter_linenoise(raw_data, args)
% filter_linenoise : filters for line-noise and first two harmonics.
%                    (optional) - downsamples to user specified ratio.
% INPUTS    : 
%                       1. raw_data             : Matrix -  Data in format [channels x time]. Within the UNICOG pipeline, this
%                                                           variable has been created using the function load_raw_data. 
%
%
%                       2. args                 : Struct -  The main configuration
%                                                           struct constructed
%                                                           @load_settings_args.params.m
% OUTPUTS   :           
%                       1. filtered_data        : Matrix -  Data in format [channels x time]. 
% -----------------------------------------------------------------------------------------------------------------------------

%% variables intialization
channels = size(raw_data,1);
% used in the progress bar.
timecount       = linspace(1,100,size(raw_data,1));

%% ----------- FILTERING AND DOWNSAMPLING ----------- %%
% Downsample data
if args.preferences.down_sample_data
    clear textprogressbar
    textprogressbar([newline 'Downsampling all channels: ']);
    for channel = 1:(channels)
        textprogressbar(timecount(channel));
        signal(channel,:)   = downsample(raw_data(channel,:),args.params.downsampling_ratio,0); % downsample per channel
    end
    % update the sampling rate
    args.params.srate   = args.params.srate./args.params.downsampling_ratio;
    duration            = size(signal,2);
    filtered_data       = zeros(channels,duration);
else
    signal = raw_data;
    duration            = size(signal,2);
    filtered_data       = zeros(channels,duration);
end
% release RAM
clear raw_data textprogressbar

textprogressbar([newline 'Removing line noise and harmonics from all channels : ']);
% Filter the line noise and the harmonics
for channel = 1:(channels)
    textprogressbar(timecount(channel));
    % Notch filtering
    [wave]  = notch(signal(channel,:), args.params.srate, args.params.first_harmonic{1},  args.params.first_harmonic{2},1);
    [wave]  = notch(wave, args.params.srate, args.params.second_harmonic{1}, args.params.second_harmonic{2},1);         % Second harmonic of 60 or 50
    [wave]  = notch(wave, args.params.srate, args.params.third_harmonic{1},  args.params.third_harmonic{2},1);          % Third harmonic of 60 or 50
    % in Houston they obseved noise at the first sub-harmonics (90Hz)
    if args.preferences.filter_sub_harmonics
        [wave]  = notch(signal(channel,:), args.params.srate, args.params.first_sub_harmonic{1}, args.params.first_sub_harmonic{2},1);  % First sub-harmonic of 60 or 50
    end
    filtered_data(channel,:) = wave;
    % release RAM
    clear wave
end
% release RAM
clear signal
textprogressbar([newline 'The line noise removal has been completed.'])
%% Output checks :
if ~size(filtered_data,2) > size(filtered_data,1)
    try % this might lead to memory overload
        filtered_data = filtered_data';
    catch 
        disp([newline 'Please transpose your input data before continuing'])
        return;
    end
end



