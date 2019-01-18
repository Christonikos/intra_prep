function [filtered_data, args] =  filter_linenoise(raw_data, args)
% filter_linenoise : i)   filters for line-noise and first two harmonics.
%                    ii)  (optional) - downsamples to user specified ratio.
%                    iii) (Blackrock datatype) - saves the trigger channel
%                    as .csv @the preproc directory.
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
%                       2. args                 : Struct -  In case of downsampling, we have 
%                                                           an updated sampling rate.
% -----------------------------------------------------------------------------------------------------------------------------

%% variables intialization
channels = size(raw_data,1);
% used in the progress bar.
timecount       = linspace(1,100,size(raw_data,1));

%% ----------- DOWNSAMPLING ----------- %%
% Downsample data
if args.preferences.down_sample_data
    ratio = args.params.downsampling_ratio;
    sr_i = args.params.srate ;
    sr_f = (sr_i./ ratio); 
    clear textprogressbar
    textprogressbar([newline 'Downsampling from ' ...
        num2str(sr_i) ' Hz to ' num2str(sr_f) ' Hz: ']);
    for channel = 1:(channels)
        textprogressbar(timecount(channel));
        signal(channel,:)   = downsample(raw_data(channel,:),ratio); % downsample per channel
    end
    % update the sampling rate
    args.params.srate   = sr_f;
    duration            = size(signal,2);
    filtered_data       = zeros(channels,duration);
else
    signal = raw_data;
    duration            = size(signal,2);
    filtered_data       = zeros(channels,duration);
end
% release RAM
clear raw_data textprogressbar

% Blackrock specific case - (trigger channel included @the dataset).
% Save the trigger channel after downsampling (if selected) @path2preproc.
curr_datatype = args.settings.datatype;
if strcmp(curr_datatype,'Blackrock')
    curr_session = args.settings.session;
    curr_patient = args.settings.patient;
    trig_ch      = filtered_data(end,:);
    % check if dir exists - else create 
    dir2save = args.settings.path2deriv.preproc;
    if ~exist(string(dir2save),'dir'); mkdir(dir2save); end
    % save the triggers of the second box as a .csv file
    file_name       = fullfile(dir2save, ...
        join(['trigger_channel_sr',num2str(args.params.srate),'_',curr_session,'_',curr_patient,'.csv']));
    csvwrite(file_name,trig_ch);
end

%% ----------- FILTERING ----------- %%
line_noise      = num2str(args.params.first_harmonic{1} +1);
first_harmonic  = num2str(args.params.second_harmonic{1}+1);
third_harmonic  = num2str(args.params.third_harmonic{1} +1);

textprogressbar([newline 'Removing line noise and harmonics (' line_noise ',' ...
   first_harmonic ','  third_harmonic ' Hz): ']);
   
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
clear signal textprogressbar

%% Output checks :
if ~size(filtered_data,2) > size(filtered_data,1)
    try % this might lead to memory overload
        filtered_data = filtered_data';
    catch 
        disp([newline 'Please transpose your input data before continuing'])
        return;
    end
end



