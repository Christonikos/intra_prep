function [hfos_evtime, hfos_channels] = load_hfos_event_time(args)
% Load the .csv array that contains the event time of the amplitude peak 
% that corresponds to an HFO. This is created using test#4
% @the mainPreProcessing_channel function.
% 
% INPUTS  : 
%           args         : Struct -  The main configuration
%                                    struct constructed
%                                    @load_settings_args.params.m
%
% OUTPUTS :
%
%           hfos_evt     : Matrix  - [event-time x channels]. 
%                                    The second dimension corresponds to
%                                    the channel where this event was
%                                    detected in bipolar montage. 
% -----------------------------------------------------------------
path2index = args.settings.path2deriv.preproc;
nfiles = dir(fullfile(path2index,'*pathological_event_bipolar*'));
% input check : there should be 1.csv/session
if isempty(nfiles) || numel(nfiles)>1
    error('Input error - check the folder that contains the saved file.')
end
% load the file
hfos = csvread(fullfile(join([path2index,filesep,nfiles.name])));

hfos_evtime   = hfos(:,1);
hfos_channels = hfos(:,2);