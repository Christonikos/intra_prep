function [raw_data, num_channels, args] = load_blackrock_data(args)
% This function handles the raw Blackrock data that originate from the
% older versions of the Blackrock recording systems (2 possible boxes 
% of 128 entries). It corrects for the unbalanced duration between the 
% two boxes and the posssible synchronization issues. 
%
% INPUTS : 
%                   1. args             : Struct - The configuration struct
%                                                  with fields :
%                                                    a. params
%                                                    b. settings
%                                                    c. preferences
%
%                                                   Created @:
%                                                   load_settings_params
%                                                   and used to get the
%                                                   paths and update the sr
%                                                   variable.
%
%   OUTPUTS :
%                   1. raw_data         : Matrix  -   Dimensions [Channels x time]
%
%
%                   2. num_channels     : Double  -   Number of channels used 
%                                                     in the current raw file.
%
%                   3. args             : Struct  -   We update the field params.srate 
%                                                     with the srate provided by the
%                                                     recording system.
%                                                     
%                   4. ttl_pulses       :(.CSV FILE)- Contains the synchronized ttl 
%                                                     pulses tranformed
%                                                     into seconds.
%                                                     Saved @: 
%                                                     project/Data/derivatives/preproc/Hospital/Patient/session/
%
%
%                   5. overlayed ttls   :(.PNG FIGURE) - Figure containing the ttl
%                                                     pulses overlayed as a
%                                                     sanity check. Saved
%                                                     @ project/Figures/Hospital/Patient/session/
%
% Written by : Christos Nikolaos Zacharopoulos @UNICOG19
% -------------------------------------------------------------------------
%% LOAD THE .NS3 FILES OF THE CURRENT SESSION AND CONCATENATE 
%% THE RECORDINGS FROM THE TWO BOXES CORRECTING FOR THE DIFFERENCE
%% IN DURATION BETWEEN THE BOXES.
% -------------------------------------------------------------------------
% List the available files per recording session
nfiles = dir(fullfile(args.settings.path2rawdata, '*.ns3'));
% loop through the available files
for file_id = 1:numel(nfiles)
    openNSx(fullfile(join([args.settings.path2rawdata,filesep,nfiles(file_id).name])))
    % list the output that Blackrock provides
    files       = NS3.Data;
    % some times a single .ns3 file contains two raw data files (still within the same
    % recording session)
    files_len   = length(files);
    switch files_len
        case 2
            % choose the one that contains more data
            if length(files{1}) > length(files{2})
                data =   files{1};
            else
                data =   files{2};
            end
    end
    ns3_files{file_id} = data;
    % release memory
    clear data files files_len
end

% get the time-difference between the two .ns3 files
timeDelay = length(ns3_files{1}) - length(ns3_files{2});
syncShift = abs(timeDelay) - 1;
% trim the large .ns3 file
if sign(timeDelay) == -1
    ns3_files{2}(:,end-syncShift:end) = [];
else
    ns3_files{1}(:,end-syncShift:end) = [];
end

% get the trigger channels from the two boxes
trig_ch_1 = ns3_files{1}(end,:);
trig_ch_2 = ns3_files{2}(end,:);

% concatenate the two files into a single variable
% excluding the first trigger channel & convert to double.
raw_data = [double(ns3_files{1}(1:end-1,:)); double(ns3_files{2})];
% release RAM
clear ns3_files nfiles NS3

% -------------------------------------------------------------------------
%% CHECK AND CORRECT FOR ANY SYNCHRONIZATION ISSUES BETWEEN THE TTL PULSES 
%% RECORDED WITH THE TWO BOXES
% -------------------------------------------------------------------------

%% get the peaks [mV] and times [samples] from the two boxes
[pks1,locs_1] = findpeaks(double(trig_ch_1),'MinPeakHeight',3e4,'MinPeakDistance',15);
[pks2,locs_2] = findpeaks(double(trig_ch_2),'MinPeakHeight',3e4,'MinPeakDistance',15);

%% calculate the rmse
calc_rmse = @(a,b) sqrt(mean((a(:)-b(:)).^2));
rmse = calc_rmse(locs_1,locs_2);

if ~rmse == 0 && mean(sign((locs_1-locs_2))) == -1
    % the second box is ahead of the first
    % swift the second box by the rounded rmse
    locs_2 = locs_2 - round(rmse);
else
    % the first box is ahead
    locs_1 = locs_1 - round(rmse);
end
% check again the rmse between the shifted triggers
if ~round(calc_rmse(locs_1,locs_2)) == 0
    error('The triggers between  the two boxes are not synchronized!')
end

% -------------------------------------------------------------------------
%% UPDATE THE SAMPLING RATE USING THE OUTPUT OF THE RECORDING SYSTEM AND 
%% CONVERT THE TTL VECTOR TO UNITS OF SECONDS. FINALLY, EXPORT THE TTL 
%% PULSES AS A .CSV FILE TO THE PATH : /derivatives/preproc
% -------------------------------------------------------------------------

% If the above test is passed, it is safe to export any of the two
% trigger channels as a reference. To avoid messing up with
% downsampling issues, we export the trigger channel tranformed
% into seconds.
%% get the sampling rate from the recording system :
args.params.srate = NS3.MetaTags.SamplingFreq;
% transform the samples time-vector to a seconds time-vector:
ttl_pulses = (locs_2.*(1e-3))./(args.params.srate);
%% save the ttl pulses in seconds @the /derivatives/preproc
curr_session = args.settings.session;
curr_patient = args.settings.patient;
% check if dir exists - else create
dir2save = args.settings.path2deriv.preproc;
if ~exist(string(dir2save),'dir'); mkdir(dir2save); end
% save the triggers of the second box as a .csv file
file_name       = fullfile(dir2save, ...
    join(['ttl_pulses_',curr_session,'_',curr_patient,'.csv']));
csvwrite(file_name,ttl_pulses);


% -------------------------------------------------------------------------
%% OUTPUT CHECKS
% -------------------------------------------------------------------------

%% 1 : Check dimensions of raw_data
if ~(size(raw_data,2) > size(raw_data,1)); error('Wrong dimensions!');end
num_channels = size(raw_data,1);

%% 2 : Plot the trigger chans from the two boxes
dir2save = args.settings.path2figures;
if ~exist(string(dir2save),'dir'); mkdir(dir2save); end
switch args.preferences.visualization
    case true
        f1 = figure('Color',[1 1 1],'visible','on');
    case false
        f1 = figure('Color',[1 1 1],'visible','off');
end
bar(locs_1,pks1); hold on; bar(locs_2,pks2);
xlabel('samples'); ylabel('amplitude')
title(['Trigger channels from the two boxes.' newline ...
    'patient : ' args.settings.patient ', session: ' args.settings.session])
switch args.preferences.visualization
    case true
        pause(10)
end
% Enlarge figure to full screen.
set(f1, 'units','normalized','outerposition',[0 0 1 1]);
file_name = ['trigger_channels'];
saveas(f1, fullfile(dir2save, file_name), 'png')
close(f1)
