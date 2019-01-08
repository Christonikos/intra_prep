function rejected_channels  = rejection_based_on_hfos(filtered_data,labels, rejected_channels, args)

test_number = 4;
% Get the variance of all channels
disp([newline 'test #4 : Rejection based on detection of HFOs.'])

%% get the detection threshold
detection_threshold = args.params.hfo_detection_threshold;
fs                  = args.params.srate;
% handle to hfo detection function 
d = @detect_paChan;
[deviant_channels, pathological_event, ~] = d(filtered_data,labels, fs, detection_threshold);

% Update the logical channel variable #test 4
rejected_channels(deviant_channels , test_number) = false;

disp(['In total ' num2str(length(deviant_channels)) ...
    ' have been removed due to spiking activity.'])
