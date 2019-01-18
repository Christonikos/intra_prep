function rejected_channels  = rejection_based_on_powerspectrum(filtered_data,rejected_channels, args)

clear textprogressbar
textprogressbar([newline 'test #3 : Detecting deviant channels in the freq domain: '])
test_number = 3;
channels    = size(rejected_channels,1);
%% ----- SET POWERSPECTRUM PARAMETERS ----- %%
set_ov      = 0; % overlaping window
f           = 0:250; % frequency axis
data_pxx    = zeros(channels, length(f));

timecount   = linspace(1,100,(channels));
% loop through channels
for chanID = 1:(channels)
    textprogressbar(timecount(chanID))
    [Pxx,f] = pwelch(filtered_data(chanID,1:100*args.params.srate), ...
        args.params.srate, set_ov, f, args.params.srate);
    data_pxx(chanID,:) = Pxx;
end
log_data_pxx = log(data_pxx);

% ---------------------- power-spectrum figure ----------------------% 
dir2save = args.settings.path2figures;
f1 = figure('Color',[1 1 1],'visible','on');
for chanID = 1:(channels)
    plot(log_data_pxx(chanID,:),'tag' ...
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
% Enlarge figure to full screen.
set(f1, 'units','normalized','outerposition',[0 0 1 1]);
warning('on','all')
file_name = 'power_spectrum';
saveas(f1, fullfile(dir2save, file_name), 'png')
% ----------------------------------------------------------------------%

% Callback function to get input from the plot
datacursormode on
dcm = datacursormode(gcf);
set(dcm,'UpdateFcn',@returnchannel)


%% instructions to the user : 
disp([newline '------------------------------------------------------------------------------' ...
newline 'Please explore the power spectrum to decide about deviant channels.' newline ...
'Get the channel number by clicking on a curve.' newline ...
'If no channels should be rejected press ENTER.' newline ...
'Enter channel numbers with spaces between them and press ENTER when you are done.' newline ...
'------------------------------------------------------------------------------'])

% Ask the user if they wish to remove channels based on the
% powerspectrum plot
prompt = (': ');
deviant_channels = input(prompt,'s');
deviant_channels = str2num(deviant_channels);
close(f1)
disp([num2str(length(deviant_channels)) ' channels  have been removed.'])

% Update the logical channel variable #test 3
rejected_channels(deviant_channels',test_number) = false;
