function plot_bad_channels(rejected_on_step_2, rejected_on_step_3, rejected_on_step_4, raw_data, channel_index, labels)

% --------  Visual Inspection of the Rejected Channels  -------- %
% blue channels - detected on step 1 (saturated noise, etc)
% black channels - detected on step 2 (spiking channels)
% magenda channels - detected on step 3 (rejected from the power-spectrum)

rejected_channels{1} = rejected_on_step_2';
rejected_channels{2} = rejected_on_step_3;
rejected_channels{3} = rejected_on_step_4;

reason{1} = 'Step 1 (median thresholding)';
reason{2} = 'Step 2 (spiking channels)';
reason{3} = 'Step 3 (deviant behavior in the PowerSpectrum)';
ymax = max(max(raw_data(find(~channel_index),:)));

for step = 1:length(rejected_channels)
    switch step
        case 1
            color_plot = [0 0 1];
        case 2
            color_plot = [0 0 0];
        case 3
            color_plot = [1 0 1];
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
