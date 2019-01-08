function [filtered_data , rejected_channels, args] = mainPreProcessing(raw_data, labels, args)
% This is the main function of the pre-processing pipeline.  It is a modified pipeline based on
% the pipeline used at the Stanford University.
%
%    INPUTS :          
%                       1. raw_data             : Matrix -  Data in format [channels x time]. Within the UNICOG pipeline, this
%                                                           variable has been created using the function load_raw_data. It is
%                                                           advised that you provide the data chunked, to avoid nemory problems
%
%
%                       2. args                 : Struct -  The main configuration
%                                                           struct constructed
%                                                           @load_settings_args.params.m
%
%   OUTPUTS : 
%                       1. filtered_data        : Matrix - Data in format [channels x time]. Rejection of channels based on : 
%                                                       a.  Variance thresholding.
%
%                                                       b.  Pathological spike detection.
%
%                                                       c.  Deviation on the Power-spectrum.
%
%                                                       d. (Optional) HFOs detection.
%
%                                                       The rejected channels are replaced with NaNs. The non-rejected
%                                                       channels are linearly de-trended, downsampled to 1KHz and notch
%                                                       filtered for line noise and harmonics.
%
%                        
%                       2. rejectedchannels : Struct - Each field contains
%                                                      the indices of the rejected channels per TEST (see
%                                                      output 1).
%
%                       3. args             : Struct - In case of downsampling, we have 
%                                                      an updated sampling rate.
%  
%
% Written by : Christos Nikolaos Zacharopoulos and Yair Lakretz @UNICOG 2018.
% ------------------------------------------------------------------------------------------------------------------%

%% Input checks :
if ~size(raw_data,2) > size(raw_data,1)
    try
        raw_data = raw_data';
    catch 
        disp([newline 'Please transpose your input data before continuing'])
        return;
    end
end

%% Variables initialization
% Create a channel log-file. This will be a logical array where :
%       1 == non rejected channel.
%       0 == rejected channel.
% Initialize a logical array where we assume all channels to be 1.
if args.preferences.hfo_detection; num_tests = 4; else num_tests = 3; end

rejected_channels         =   true(size(raw_data,1),num_tests);

%% Filtering and downsampling
[filtered_data, args]    =   filter_linenoise(raw_data, args);
% After this TEST, the data are :
% 1. Notch filtered for line noise and harmonics.
% 2. Downsampled to the specified ratio.
% release RAM 
clear raw_data
%% ---------------------------------  TEST 1 - VARIANCE THRESHOLDING      --------------------------------- %%
%    Removal of channels based on the variance of the raw power.
%    This TEST will track all the channels where the broadband
%    signal exceeds an upper and lower threshold of variance.
rejected_channels  =   variance_thresholding(filtered_data, rejected_channels, args);
%%  --------------------------------- TEST 2 - SPIKES DETECTION          ---------------------------------- %%
% Remove channels based on the spikes in the raw signal
% Detect abnormalities (spikes) in the raw signal. 
rejected_channels  =   spike_detection(filtered_data,rejected_channels, args);
%%  --------------------------------- TEST 3 - REJECTION BASED ON FREQUENCY CONTENT ----------------------- %%
rejected_channels  =   rejection_based_on_powerspectrum(filtered_data, rejected_channels, args);
if args.preferences.hfo_detection
    %%  ----------------------------  TEST 4 - REJECTION BASED ON HFOs ----------------------------- %%
    rejected_channels  = rejection_based_on_hfos(filtered_data,labels, rejected_channels, args);
end
%% Linear detrending
filtered_data = data_detrending(filtered_data);

%% VIZUALIZE REJECTED CHANNELS %% 
if args.preferences.visualization
    plot_bad_channels(filtered_data, rejected_channels);
end



