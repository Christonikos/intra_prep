function rejected_channels  = rejection_based_on_hfos(filtered_data,labels, rejected_channels, args)

test_number = 4;
% Get the variance of all channels
disp([newline 'test #4 : Rejection based on detection of HFOs.'])

%% get the threshold
threshold   = args.params.hfo_detection_threshold;
fs          = args.params.srate;
% handle to hfo detection function 
d = @find_paChan;
[pathological_chan_id, pathological_event_bipolar_montage] = d(filtered_data,labels, fs, threshold);

curr_session = args.settings.session;
curr_patient = args.settings.patient;
% save the time of the pathological samples as a .csv file
file_name       = fullfile(args.settings.path2deriv.preproc, ...
    join(['pathological_event_bipolar_montage', curr_session,'_',curr_patient,'.csv']));
% check if dir2save exists - else create it:
dir2save = args.settings.path2deriv.preproc;
if ~exist(string(dir2save),'dir'); mkdir(dir2save); end
csvwrite(file_name,pathological_event_bipolar_montage.ts);

% Update the logical channel variable #test 4
rejected_channels(pathological_chan_id' , test_number) = false;

disp([newline num2str(length(pathological_chan_id)) ...
    ' channels have been removed.'])
