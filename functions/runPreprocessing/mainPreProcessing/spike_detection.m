function [filtered_data, allchannels, rejected_on_step_3] = spike_detection(filtered_data, allchannels, args)


% Set a threshold (in mV)
jump_threshold = args.params.spikingthreshold;
% Initialize variable to hold the channels that will be rejected
% due to spiking activity
channels        = size(filtered_data,1);
nr_jumps        = zeros(channels,1);
rec_duration    = size(filtered_data,2);

textprogressbar([newline 'Detecting spiking channels.' newline])
timecount = linspace(1,100,size(filtered_data,1));
close all;
% Loop through the channels and detect abrupt changes
for chID = 1:size(filtered_data,1)
    textprogressbar(timecount(chID))
    nr_jumps(chID) = length(find(diff(filtered_data(chID,:)) > jump_threshold));
end
textprogressbar([newline 'Detection completed.'])

switch args.preferences.visualization
    case true
        % Plot the spike-plot
        figureDim = [0 0 1 1];
        f = figure('units', 'normalized', 'outerposition', figureDim);
        bar(nr_jumps)
        title('Spiking Channels')
        xlabel('Channels')
        ylabel('Number of Spikes deteted')
        grid on
        grid minor
        pause(5)
        
        file_name = ['SpikingChannels_', args.settings.patient , '.png'];
        saveas(f, fullfile(args.settings.path2figures, file_name), 'png')
        close(f)
end
% Only keep voltage jumps that exceed the average fluctuation
rec_duration_sec    = floor(rec_duration/args.params.srate);
jump_rate           = nr_jumps/rec_duration_sec;
exceeding_channels  = find(jump_rate > args.params.jump_rate_thresh);

disp(['In total ' num2str(length(exceeding_channels)) ...
    ' have been removed due to spiking activity.'])

if args.preferences.visualization
    % Plot the spike-plot
    figureDim = [0 0 1 1];
    f = figure('units', 'normalized', 'outerposition', figureDim);
    for spikeCh = 1:length(exceeding_channels)
        plot(zscore(filtered_data(exceeding_channels(spikeCh),:)))
        title(['Channel Index : ' ...
            num2str(exceeding_channels(spikeCh))],'Interpreter','none')
        xlabel('time [samples]')
        ylabel('z-score')
        legend(['Channel ' num2str(spikeCh) '/' num2str(length(exceeding_channels)) newline '' ] ...
            ,'Location','northeastoutside')
        grid on
        grid minor
        pause(5)
    end
    close(f)
end

% Update the logical channel variable and remove the trigger channel
allchannels(exceeding_channels)     = false;
% Set the rejected channels to NaNs
filtered_data(exceeding_channels,:) = NaN;
rejected_on_step_3                  = exceeding_channels;



