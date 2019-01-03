function [filtered_data , indexofcleandata, rejectedchannels] = mainPreProcessing(P, raw_data, params, labels, settings)
% This is the main function of the pre-processing pipeline.  It is a modified pipeline based on
% the pipeline used at the Stanford University.
%
%    INPUTS :          
%                       1. raw_data     : Matrix -  Data in format [channels x time]. Within the UNICOG pipeline, this
%                                                   variable has been created using the function load_raw_data. It is
%                                                   advised that you provide the data chunked, to avoid nemory problems
%
%                       2. params       : Struct -  Holds various hospital-specific information such as the 
%                                                   soa of the paradigm and the notch filtering parameters.
%
%                       3. labels       : String -  Channel labels provided by the recording system. 
%
%                       4. P            : Struct -  The main configuration
%                                                   struct constructed
%                                                   @load_settings_params.m
%
%   OUTPUTS : 
%                       1. filtered_data     : Matrix - Data in format [channels x time]. Rejection of channels based on : 
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
%                        2. indexofcleandata : Logical array - [channels x 1]. 
%                                                               1 == non rejected channel 
%                                                               0 == rejected channel 
%
%                        3. rejectedchannels : Struct - Each field contains
%                                                       the indices of the rejected channels per step (see
%                                                       output 1).
%
% Written by : Christos Nikolaos Zacharopoulos, @UNICOG 2018.
% ------------------------------------------------------------------------------------------------------------------%
% Keep the workspace clean.
clearvars -except P settings raw_data params labels 
% Input checks :
if ~size(raw_data,2) > size(raw_data,1)
    try
        raw_data = raw_data';
    catch 
        disp([newline 'Please transpose your input data before continuing'])
        return;
    end
end
%% ---------------------------------  STEP 0 - VARIABLE INITIALIZATION   ---------------------------------- %%
% Create a channel log-file. This will be a logical array where :
%       1 == non rejected channel.
%       0 == rejected channel.
% Initialize a logical array where we assume all channels to be 1.
channel_index                   =   true(size(raw_data,1),1);
%% ---------------------------------  STEP 1 - FILTERING AND DOWNSAMPLING --------------------------------- %%
[filtered_data, params]         =   filter_linenoise(raw_data, params);
% After this step, the data are :
% 1. Notch filtered for line noise and harmonics.
% 2. Downsampled to 1kHz.
%% ---------------------------------  STEP 2 - VARIANCE THRESHOLDING      --------------------------------- %%
%    Removal of channels based on the variance of the raw power.
%    This step will track all the channels where the broadband
%    signal exceeds an upper and lower threshold of variance.
[filtered_data, channel_index, rejected_on_step_2]  =   variance_thresholding(filtered_data, labels, channel_index, P);
%%  --------------------------------- STEP 3 - SPIKES DETECTION          ---------------------------------- %%
% Remove channels based on the spikes in the raw signal
% Detect abnormalities (spikes) in the raw signal. 
[filtered_data, channel_index, rejected_on_step_3]  =   spike_detection(filtered_data, labels, channel_index, P, params, settings);
%%  ---------------------------- STEP 4 - REJECTION BASED ON FREQUENCY CONTENT ----------------------------- %%
[filtered_data, channel_index, rejected_on_step_4]  =   rejection_based_on_powerspectrum(filtered_data, labels, channel_index, params);

% Provide a summary from step 1 to 4 to the user :
disp([newline newline                                                                       ...
    'So far,  ' num2str(length(find(~channel_index)))                                       ...
    ' channels have been rejected out of the total ' num2str(size(channel_index,1)) '.'     ...
    newline  newline                                                                        ...
    num2str(length(rejected_on_step_2)) ' of them have been rejected based on raw power  '  ...
    newline num2str(length(rejected_on_step_3)) ' due to detected spiking activity.'        ...
    newline num2str(length(rejected_on_step_4)) ' due to deviation on the power-spectrum.'  ...
    newline newline])
pause(3);

switch P.hfo_detection
    case true
        %%  ---------------------------- STEP 5 - REJECTION BASED ON HFOs ----------------------------- %%
        [pathological_chan_id,pathological_event]  = rejection_based_on_hfos(filtered_data,labels , channel_index, params);
end
%% VIZUALIZE REJECTED CHANNELS %% 
switch P.vizualization
    case true
        plot_bad_channels(rejected_on_step_2, rejected_on_step_3, rejected_on_step_4, raw_data, channel_index, labels);
end
%%  ---------------------------- STEP 6 - LINEAR DE-TRENDING        ----------------------------- %%
filtered_data = filtered_data(filtered_data);



% Export the logical array of the channels
indexofcleandata                        =   channel_index;
% Export a struct that contains the individual rejection reasons
rejectedchannels.variance_rejection     =   rejected_on_step_2';
rejectedchannels.spiking_channels       =   rejected_on_step_3;
rejectedchannels.power_spectrum         =   rejected_on_step_4;



