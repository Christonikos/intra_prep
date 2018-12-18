function [filtered_data, channel_index, rejected_on_step_4]  = rejection_based_on_powerspectrum(filtered_data, labels, channel_index, params)

% Provide feedback to the user.
disp([newline...
    '---------------- Intiating Stage 4 of the analysis ---------------- ' ...
    newline ...
    '(Rejection of channels based on deviation on the PowerSpectrum)'...
    newline newline])
channels    = size(filtered_data,1);

%% ----- SET POWERSPECTRUM PARAMETERS ----- %%
set_ov      = 0; % overlaping window
f           = 0:250; % frequency axis
data_pxx    = zeros(channels, length(f));


textprogressbar([newline 'Calculating the Welch''s Power Spectral Density' newline ])
timecount   = linspace(1,100,(channels));
% loop through channels
for chanID = 1:(channels)
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

for chanID = 1:(channels)
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
    channel_index(pwschannels) = false;
end


clc;

disp(['In total ' num2str(length(pwschannels)) ...
    ' have been removed due to spiking activity.'...
    newline ' The channels have the following labels : '  ])
disp(labels(pwschannels,:))
pause(3)

rejected_on_step_4 = pwschannels;
