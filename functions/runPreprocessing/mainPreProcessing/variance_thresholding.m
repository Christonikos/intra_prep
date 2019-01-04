function [filtered_data, rejected_channels, rejected_on_step_2] = variance_thresholding(filtered_data, labels, rejected_channels, args)

% Get the variance of all channels
disp([newline 'Detecting the variance of all channels'])
% Pre-allocate the variance variable
dataVariance    = zeros(1,size(filtered_data,1));
for channel = 1: size(filtered_data,1)
    dataVariance(1,channel) = var(filtered_data(channel,:)');
end
disp(['The calculation has been completed'])
switch args.preferences.visualization
    case true
        figureDim = [0 0 1 1];
        figure('units', 'normalized', 'outerposition', figureDim)
        subplot(211)
        bar(dataVariance)
        grid on
        grid minor
        xlabel('channels')
        ylabel('detected variance')
        title('Detected variance for all channels')
        hold on
        plot([get(gca,'xlim')],[5*median(dataVariance),5*median(dataVariance)],'r','linew',1.2)
        hold on
        plot([get(gca,'xlim')],[median(dataVariance)/5,median(dataVariance)/5],'m','linew',1.2)
        legend('detected variance','5*median','median/5','Location',  'northeastoutside')
        
        subplot(212)
        bar(dataVariance)
        grid on
        grid minor
        xlabel('channels')
        ylabel('detected variance')
        title('Detected variance for all channels')
        xlim([0 20])
        hold on
        plot([get(gca,'xlim')],[5*median(dataVariance),5*median(dataVariance)],'r','linew',1.2)
        hold on
        plot([get(gca,'xlim')],[median(dataVariance)/5,median(dataVariance)/5],'m','linew',1.2)
        legend('detected variance','5*median','median/5','Location',  'northeastoutside')
        pause(10)
        close all
end
% Set the cutting threshold
medianthreshold             = args.params.medianthreshold;
% Detect those channels that exceed 5 times the median of the
% detected variance (in both directions) 
spottedChannels_positive    = find(dataVariance > (medianthreshold * median(dataVariance)));
spottedChannels_negative    = find(dataVariance < (median(dataVariance)/medianthreshold));
% Provide the first feedback on the channels that have been removed
labels                      = string(labels);

% Concatenate the detected channels
spottedChannels             = sort([spottedChannels_negative spottedChannels_positive]);
disp([ 'In total ' num2str(length(spottedChannels)) ' channels' ...
    ' have been removed based on the variance of the all channels.'...
    newline ' The channels have the following labels : '  newline])
disp([ labels(spottedChannels)])

% Update the logical channel variable
rejected_channels(spottedChannels') = false;

if args.preferences.visualization
    % Plot the bad channels
    figureDim = [0 0 1 1];
    figure('units', 'normalized', 'outerposition', figureDim)
    for bch = 1:length(spottedChannels)
        if bch == 1
            t = text(0.5,0.5,'These are the channels rejected from step 1');
            t.BackgroundColor = 'k';
            t.Color = 'w';
            t.FontSize = 25;
            t.FontWeight = 'Bold';
            t.FontSmoothing = 'on';
            t.Clipping = 'on';
            t.HorizontalAlignment = 'center';
            axis off;
            pause(3)
        end
        plot(zscore(filtered_data(spottedChannels(bch),:)))
        title(['Label : ' labels(spottedChannels(bch))...
            'Channel Index : ' ...
            num2str(spottedChannels(bch))],'Interpreter','none') %#ok<NODEF>
        xlabel('Time [samples]')
        ylabel('zscore')
        grid on
        grid minor
        legend(['Channel ' num2str(bch) '/' num2str(length(spottedChannels)) newline '' ] ...
            ,'Location','northeastoutside')
        pause(5)
    end
    close all
end


% Set the rejected channels to NaNs
filtered_data(~rejected_channels,:) =   NaN;
rejected_on_step_2              =   spottedChannels';


