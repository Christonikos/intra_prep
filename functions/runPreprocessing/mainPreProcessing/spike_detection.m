function rejected_channels = spike_detection(filtered_data, rejected_channels, args)



test_number     = 2;
% Set a threshold (in mV)
jump_threshold  = args.params.spikingthreshold;
% Initialize variable to hold the channels that will be rejected
% due to spiking activity
channels        = size(filtered_data,1);
nr_jumps        = zeros(channels,1);
rec_duration    = size(filtered_data,2);


timecount = linspace(1,100,size(filtered_data,1));
close all; clear textprogressbar
textprogressbar([newline 'test #2 : Channel rejection based on epileptic spiking activity: ' ])
% Loop through the channels and detect abrupt changes
for chID = 1:size(filtered_data,1)
    textprogressbar(timecount(chID))
    nr_jumps(chID) = length(find(diff(filtered_data(chID,:)) > jump_threshold));
end

% ---------------------- spikes per channel figure ----------------------% 
dir2save = args.settings.path2figures;
switch args.preferences.visualization
    case true
        f1 = figure('Color',[1 1 1],'visible','on');
    case false
        f1 = figure('Color',[1 1 1],'visible','off');
end
bar(nr_jumps)
title('Spiking Channels')
xlabel('Channels')
ylabel('Number of Spikes deteted')
grid on
grid minor
pause(5)
file_name = ['SpikingChannels_', args.settings.patient , '.png'];
% Enlarge figure to full screen.
set(f1, 'units','normalized','outerposition',[0 0 1 1]);
saveas(f1, fullfile(dir2save, file_name), 'png')
close(f1)
% ----------------------------------------------------------------------%


%% Only keep voltage jumps that exceed the jumping threshold
rec_duration_sec    = floor(rec_duration/args.params.srate);
jump_rate           = nr_jumps/rec_duration_sec;
deviant_channels    = find(jump_rate > args.params.jump_rate_thresh);




% Update the logical channel variable #test 2
rejected_channels(deviant_channels , test_number) = false;

disp([newline num2str(length(deviant_channels)) ' channels have been removed.'])

if args.preferences.visualization
    % Plot the spike-plot
    figureDim = [0 0 1 1];
    f = figure('units', 'normalized', 'outerposition', figureDim);
    for spikeCh = 1:length(deviant_channels)
        plot(zscore(filtered_data(deviant_channels(spikeCh),:)))
        title(['Channel Index : ' ...
            num2str(deviant_channels(spikeCh))],'Interpreter','none')
        xlabel('time [samples]')
        ylabel('z-score')
        legend(['Channel ' num2str(spikeCh) '/' num2str(length(deviant_channels)) newline '' ] ...
            ,'Location','northeastoutside')
        grid on
        grid minor
        pause(5)
    end
    close(f)
end




