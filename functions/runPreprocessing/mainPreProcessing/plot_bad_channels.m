function plot_bad_channels(filtered_data, rejected_channels)

ntests = size(rejected_channels,2);
% --------  Visual Inspection of the Rejected Channels  -------- %
% blue channels -    detected with test 1 (saturated noise, etc)
% black channels -   detected with test 2 (spiking channels)
% magenda channels - detected with test 3 (rejected from the power-spectrum)

% red channels = detected on with test(rejected based on the HFOs)

deviant_channels{1} = rejected_channels(:,1);
deviant_channels{2} = rejected_channels(:,2);
deviant_channels{3} = rejected_channels(:,3);
if ntests == 4 ; deviant_channels{4} = rejected_channels(:,4); end

reason{1} = 'Step 1 (median thresholding)';
reason{2} = 'Step 2 (spiking channels)';
reason{3} = 'Step 3 (deviant behavior in the PowerSpectrum)';
reason{4} = 'Step 4 (Presence of HFOs)';

ymax = max(max(filtered_data(~rejected_channels(:,1),:)));

for step = 1:numel(deviant_channels(1:ntests))
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
    tmp_channels = find(~deviant_channels{step});
    
    for channel = 1:length(find(~deviant_channels{step}))
        plot(filtered_data(tmp_channels(channel),:),'Color',color_plot)
        ylim([-ymax ymax])
        xlabel('Time [Samples]')
        ylabel('Amplitude')
        grid on
        grid minor
        legend(reason{step})
        pause(3)
    end
end
