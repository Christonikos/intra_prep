function rejected_channels  = rejection_based_on_powerspectrum(filtered_data,rejected_channels, args)

disp([newline 'test #3 : Detecting deviant channels in the freq domain.'])
test_number = 3;
channels    = size(rejected_channels,1);
%% ----- SET POWERSPECTRUM PARAMETERS ----- %%
set_ov      = 0; % overlaping window
f           = 0:250; % frequency axis
data_pxx    = zeros(channels, length(f));


textprogressbar([newline 'Calculating the Welch''s Power Spectral Density' newline ])
timecount   = linspace(1,100,(channels));
% loop through channels
for chanID = 1:(channels)
    textprogressbar(timecount(chanID))
    [Pxx,f] = pwelch(filtered_data(chanID,1:100*args.params.srate), ...
        args.params.srate, set_ov, f, args.params.srate);
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
        deviant_channels = [];
        break
    elseif strcmp(user_response,'Y')
        secondprompt = ('Please add the channels using space between them and press enter when you are done : ');
        deviant_channels = input(secondprompt,'s');
        deviant_channels = str2num(deviant_channels);
        break
    else
        disp('Please only add numerical values')
        continue
    end
    % Based on the user response update or not the channels
end

disp(['In total ' num2str(length(deviant_channels)) ' channels'...
    ' have been removed based on the power spectrum.'])

% Update the logical channel variable #test 3
rejected_channels(deviant_channels',test_number) = false;
