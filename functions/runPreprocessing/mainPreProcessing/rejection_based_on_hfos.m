function rejected_channels  = rejection_based_on_hfos(filtered_data,labels, rejected_channels, args)

test_number = 4;
% Get the variance of all channels
disp([newline 'test #4 : Rejection based on detection of HFOs.'])

%% get the threshold
threshold   = args.params.hfo_detection_threshold;
fs          = args.params.srate;
% handle to hfo detection function 
d = @find_paChan;
[pathological_chan_id,~] = d(filtered_data,labels, fs, threshold);

% Update the logical channel variable #test 4
rejected_channels(pathological_chan_id' , test_number) = false;

disp([newline num2str(length(pathological_chan_id)) ...
    ' channels have been removed.'])
