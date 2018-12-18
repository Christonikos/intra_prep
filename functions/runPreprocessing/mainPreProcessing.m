function [signal , indexofcleandata, rejectedchannels, pathological_event] = mainPreProcessing(P, settings, raw_data, params, labels)
% This is the main function of the pre-processing pipeline.  It is a modified pipeline based on
% the pipeline used at the Stanford University.
%    INPUTS :   1. raw_data : data in format [channels x time]. Within the UNICOG pipeline, this
%                                            variable has been created using the function load_raw_data. It is
%                                            advised that you provide the data chunked, to avoid nemory problems
%                      2. params    : This is a struct created by the  function load_settings_params.
%                                             It contains  hospital-specific parameters.
%                      3. labels      :  This variable contains the  labelling of the electrodes. It is provided by
%                                             the  function load_raw_data.
%                      4.gyri           : Hospital-specific corregistration  of the electrodes to an anatomical atlas.
%                      5.hopID       : The ID of the Hospital currently under consideration.
% Written by : Christos-Nikoalaos Zacharopoulos, @UNICOG 2018.
% ------------------------------------------------------------------------------------------------------------------%

% Keep the workspace clean.
clearvars -except P settings raw_data params labels 
% Input checks :
if ~size(raw_data,2) > size(raw_data,1)
    try
        raw_data = raw_data';
    catch 
        disp([newline 'Please transpose your input data before continuing'])
        return;
    end
end
%% --------------------------------- STEP 0 - VARIABLE INITIALIZATION   --------------------------------- %%
% Create a channel log-file. This will be a logical array where 1
% will denote a good channel and 0 will denote a bad channel.
% Initialize a logical array where we assume all channels to be
% good
allchannels = true(size(raw_data,1),1);
%% --------------------------------- STEP 1 - FILTERING AND DOWNSAMPLING --------------------------------- %%
filtered_data =  filter_linenoise(raw_data, params);
%% --------------------------------- STEP 2 - VARIANCE THRESHOLDING      --------------------------------- %%
%    Removal of channels based on the variance of the raw power.
%    This step will track all the channels where the broadband
%    signal exceeds an upper and lower threshold of variance.
[filtered_data, allchannels] = variance_thresholding(filtered_data, labels, allchannels, P);
% Set the rejected channels to NaNs
filtered_data(find(~allchannels),:) = NaN;
%%  --------------------------------- STEP 3 - SPIKES DETECTION          --------------------------------- %%
% Remove channels based on the spikes in the raw signal
% Detect abnormalities (spikes) in the raw signal. Here, we
% basically detect rapid changes in the signal (jumps).
[filtered_data, allchannels] = spike_detection(filtered_data, labels, allchannels, P, params);


% Provide a summary from step 1 and 2 to the user :
disp([newline newline 'So far,  ' num2str(length(find(~allchannels))) ...
    ' channels have been rejected out of the total ' num2str(channels) '.' newline  newline...
    num2str(length(spottedChannels)) ' of them have been rejected based on raw power  ' ...
    newline num2str(length(exceeding_channels)) ' due to detected spiking activity.' newline newline])
pause(3);


%% --------------------------------- STEP 3 --------------------------------- %
% Remove channels based on their frequency content


% Provide feedback to the user.
disp([newline...
    '---------------- Intiating Stage 3 of the analysis ---------------- ' ...
    newline ...
    '(Rejection of channels based on deviation on the PowerSpectrum)'...
    newline newline ...
    'Epoch ' num2str(epoch) '/' num2str(nE)])


set_ov = 0; % overlaping window
f = 0:250; % frequency axis
data_pxx = zeros(channels-1, length(f));


textprogressbar([newline 'Calculating the Welch''s Power Spectral Density' newline ])
timecount = linspace(1,100,(channels-1));
for chanID = 1:(channels-1)
    textprogressbar(timecount(chanID))
    [Pxx,f] = pwelch(filtered_data(chanID,1:100*params.srate), ...
        params.srate, set_ov, f, params.srate);
    data_pxx(chanID,:) = Pxx;
end
textprogressbar([ newline 'Estimation completed'])

figureDim = [0 0 1 1];
figure('units', 'normalized', 'outerposition', figureDim)
log_data_pxx = log(data_pxx);
clear textprogressbar

% To do: maybe add a butterfly plot to observe behavior in the time
% domain as well.

for chanID = 1:(channels-1)
    plot(f,log_data_pxx(chanID,:),'tag' ...
        ,sprintf('Channel %d',chanID));
    grid on
    grid minor
    xlabel('Frequency [Hz]')
    ylabel('Power [au]')
    xticks(0:10:f(end))
    hold on
    title(['Observe deviant channels based on the power-spectrum.' ...
        newline '(Click on those channels that you wish to remove )'])
    warning('off','all')
end

warning('on','all')

% Callback function to get input from the plot
datacursormode on
dcm = datacursormode(gcf);
set(dcm,'UpdateFcn',@returnchannel)


% Ask the user if they wish to remove channels based on the
% powerspectrum plot
while true
    prompt = 'Do you want to add channels for rejection? Y/N : ';
    user_response = input(prompt,'s');
    if strcmp(user_response,'N')
        disp('No extra channels were added')
        pwschannels = [];
        break
    elseif strcmp(user_response,'Y')
        secondprompt = ('Please add the channels using space between them and press enter when you are done : ');
        pwschannels = input(secondprompt,'s');
        pwschannels = str2num(pwschannels);
        break
    else
        disp('Please only add numerical values')
        continue
    end
    % Based on the user response update or not the channels
end

if ~isempty(pwschannels)
    % Set the rejected channels to NaNs
    filtered_data((pwschannels),:) = NaN;
    % Provide update including step number 3
    allchannels(pwschannels) = false;
end


clc;
disp([newline newline 'So far,  ' num2str(length(find(~allchannels))) ...
    ' channels have been rejected out of the total ' num2str(channels) '.' newline newline ...
    num2str(length(spottedChannels)) ' of them have been rejected based on raw power  ' ...
    newline  num2str(length(exceeding_channels)) ' due to detected spiking activity ' newline...
    num2str(length(pwschannels)) ' due to deviant behavior in the powerspectrum.' newline newline])
pause(3)


%% --------------------------------- STEP 4 --------------------------------- %
% Remove channels based on their frequency content


% Provide feedback to the user.
disp([newline...
    '---------------- Intiating Stage 4 of the analysis ---------------- ' ...
    newline ...
    '(Rejection of channels based on the detection of HFOs)'...
    newline newline ...
    'Epoch ' num2str(epoch) '/' num2str(nE)])


% Manually set the detection threshold
detection_threshold = 1.5;

[pathological_chan_id,pathological_event, ~] = ...
    detect_paChan(filtered_data,labels, params, detection_threshold, settings,P, hopID);

% Provide feedback to the user
if  isempty(pathological_chan_id)
    disp([newline 'From the process of identifying HFOs, ' num2str(0) ...
        ' channels have been excluded.'])
    % --------  Provide the summ-up for the current epoch -------- %
    clc;
    disp([newline newline 'So far,  ' num2str(length(find(~allchannels))) ...
        ' channels have been rejected out of the total ' num2str(channels) '.' newline newline ...
        num2str(length(spottedChannels)) ' of them have been rejected based on raw power  ' ...
        newline  num2str(length(exceeding_channels)) ' due to detected spiking activity ' newline...
        num2str(length(pwschannels)) ' due to deviant behavior in the powerspectrum.' newline ...
        num2str(0) ' due to the presence of HFos.' newline newline])
    pause(3)
    
else
    disp([newline 'From the process of identifying HFOs, ' num2str(length(pathological_chan_id)) ...
        'channels have been excluded.'])
    
    % Update the channels logical array
    allchannels(pathological_chan_id') = false;
    % Update the channels matrix
    filtered_data(pathological_chan_id',:) = NaN;
    
    % --------  Provide the summ-up for the current epoch -------- %
    clc;
    disp([newline newline 'So far,  ' num2str(length(find(~allchannels))) ...
        ' channels have been rejected out of the total ' num2str(channels) '.' newline newline ...
        num2str(length(spottedChannels)) ' of them have been rejected based on raw power  ' ...
        newline  num2str(length(exceeding_channels)) ' due to detected spiking activity ' newline...
        num2str(length(pwschannels)) ' due to deviant behavior in the powerspectrum.' newline ...
        num2str(length(pathological_chan_id)) ' due to the presence of HFos.' newline newline])
    pause(3)
    
end



% --------  Visual Inspection of the Rejected Channels  -------- %
% blue channels - detected on step 1 (saturated noise, etc)
% black channels - detected on step 2 (spiking channels)
% magenda channels - detected on step 3 (rejected from the power-spectrum)
% red channels = detected on step 4 (rejected based on the HFOs)

rejected_channels{1} = spottedChannels';
rejected_channels{2} =  exceeding_channels;
rejected_channels{3} = pwschannels;
rejected_channels{4} = pathological_chan_id';

reason{1} = 'Step 1 (median thresholding)';
reason{2} = 'Step 2 (spiking channels)';
reason{3} = 'Step 3 (deviant behavior in the PowerSpectrum)';
reason{4} = 'Step 4 (Presence of HFOs)';

ymax = max(max(raw_data(find(~allchannels),:)));

for step = 1:length(rejected_channels)
    switch step
        case 1
            color_plot = [0 0 1];
        case 2
            color_plot = [0 0 0];
        case 3
            color_plot = [1 0 1];
        case 4
            color_plot = [1 0 0];
    end
    
    for channel = 1:length(rejected_channels{step})
        plot(raw_data(rejected_channels{step}(channel),:),'Color',color_plot)
        ylim([-ymax ymax])
        xlabel('Time [Samples]')
        ylabel('Amplitude')
        grid on
        grid minor
        title([num2str(channel) ' - ' labels(rejected_channels{step}(channel))]);
        legend(reason{step})
        pause(3)
    end
end
close all;

switch P.processing
    case 'slow'
        % --------  Visual Inspection of the Clean Channels  -------- %
        % Perform Common-average re-reference
        car_filtered = car(filtered_data);
        
        % The spatial filter added values to the discarded channels -
        % remove those here;
        car_filtered(~allchannels,:) = NaN;
        % Get the new y-limit
        ymax = max(max(car_filtered(allchannels,:)));
        
        for channel = 1:size(car_filtered,1)
            plot(car_filtered(channel,:))
            ylim([-ymax ymax])
            xlabel('Time [Samples]')
            ylabel('Amplitude')
            grid on
            grid minor
            title([num2str(channel) ' - ' labels(channel)])
            pause(3)
        end
end

% Export the logical array of the channels
indexofcleandata = allchannels;
% Export a struct that contains the individual rejection reasons
rejectedchannels.variance_rejection  = spottedChannels;
rejectedchannels.spiking_channels    =  exceeding_channels;
rejectedchannels.power_spectrum     =  pwschannels;
rejectedchannels.hfo_detection          =  pathological_chan_id;



