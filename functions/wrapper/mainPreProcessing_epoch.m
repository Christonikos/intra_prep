function rejected_epochs = mainPreProcessing_epoch(epochs, args,behav_timevector, labels)
% This is the main function of the pre-processing pipeline at the epoch level. It is a modified pipeline based on
% the pipeline used at the Stanford University.
%
%    INPUTS :          
%                       1. epochs               : Cell   -  [number of blocks x 2]. 
%                                                           1st col: The loaded data file.
%                                                           2nd col: Information on the epoching method.
%                                       
%
%                       2. args                 : Struct -  The main configuration
%                                                           struct constructed
%                                                           @load_settings_args.params.m
%
%   OUTPUTS : 
%                      
% -------------------------------------------------------------------------------------------------------------  
%% Input checks :
if isempty(epochs); error('empty input!');end
% initialization:
num_tests           = 4;
%% ----------------------- TEST 1 - Reject based  on the presence of HFOs ----------------------------------------------- %%
% load the variable that holds the detected hfos at the channel level (see
% test#4 @mainPreProcessing_channel) 
[hfos_evtime, hfos_channels] = load_hfos_event_time(args);
lockevent                    = behav_timevector{1}(:,1); 
hfos_channels                = num2cell(hfos_channels);

[bad_epochs_HFO, bad_indices_HFO] = exclude_trial(hfos_evtime,hfos_channels, lockevent, labels, params.before_onset , params.after_onset , args.params.srate);
%% ----------------------- TEST 2 - Reject based on spikes in LF and HF components of signal ----------------------------- %%
[be.bad_epochs_raw_LFspike, filtered_beh,spkevtind,spkts_raw_LFspike] = LBCN_filt_bad_trial(data_CAR.wave',data_CAR.fsample);
%% ----------------------- TEST 3 - Reject based on outliers of the raw signal and jumps --------------------------------- %%
[be.bad_epochs_raw_jump, badinds_jump] = epoch_reject_raw(data_CAR.wave,thr_raw,thr_diff);
%% ----------------------- TEST 4 - Reject based on spikes in HF component of signal ------------------------------------- %%
[be.bad_epochs_raw_HFspike, filtered_beh,spkevtind,spkts_raw_HFspike] = LBCN_filt_bad_trial_noisy(data_CAR.wave',data_CAR.fsample);


%% VIZUALIZE REJECTED EPOCHS %% 
if args.preferences.visualization
    plot_bad_channels(filtered_data, rejected_epochs);
end



