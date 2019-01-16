% load_raw_data : This generic function can be used to return the raw data from multiple Hospitals
% and for various recording techniques.
% Written by : Christos-Nikolaos Zacharopoulos (christonik@gmail.com)
% @UNICOG, 2018
%
%   INPUTS:
%                   1. args             : Struct - The configuration struct
%                                                  with fields :
%                                                    a. params
%                                                    b. settings
%                                                    c. preferences
%
%                                                   Created @:
%                                                   load_settings_params
%
%   OUTPUTS :
%                   1. raw_data         : Matrix  -   Dimensions [Channels x time]
%
%                   2. Labels           : Cell of strings - labels of all
%                                           channels
%
%                   3. num_channels     : Double  -   Number of channels used in the current raw file.
%
%                   4. args             : Struct  -   In the cases of
%                                                     "Blackorock" and "NihonKohden" datatypes, we update the
%                                                     field params.srate with the srate provided by the
%                                                     recording system.

% ---------------------------------------------------------------------------------------------------------------
function [raw_data, labels, num_channels, args] = load_raw_data(args)

disp([newline '---------- Loading raw data -------------' ...
    newline newline ...
    'Patient            : ' args.settings.patient  '.' newline ...
    'Hospital           : ' args.settings.hospital '.' newline ...
    'Datatype           : ' args.settings.datatype '.' newline ...
    newline   '-----------------------------------------'])

raw_data = []; 
% switch datatype
switch args.settings.datatype
    case 'Blackrock'
        %% --------- LOAD THE RAW BLACKROCK DATA --------- %%
        % List the available files per session
        nfiles = dir(fullfile(args.settings.path2rawdata, '*.ns3'));
        % loop through the available files
        for file_id = 1:numel(nfiles)
            openNSx(fullfile(join([args.settings.path2rawdata,filesep,nfiles(file_id).name])))
            % list the output that Blackrock provides
            files       = NS3.Data;
            % some times a single .ns3 file contains two raw data files
            files_len   = length(files);
            switch files_len
                case 2
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
        clear ns3_files
        
        % load the file that contain the probe information
        files = dir(fullfile(args.settings.path2rawdata, '*elecs*'));
        if isempty(files); error('probe names file not found!');end
        labels = strtrim(string(importdata(fullfile(args.settings.path2rawdata,files.name))));
        labels = strrep( labels,'"','');
        
        % get the sampling rate from the recording system :
        args.params.srate = NS3.MetaTags.SamplingFreq;
        
        %% ----------- Output checks ----------- %%
        % 1 : dimensions of raw_data
        if ~(size(raw_data,2) > size(raw_data,1)); error('Wrong dimensions!');end
        num_channels = size(raw_data,1);
        
        % 2 : Plot the trigger chans from the two boxes
        dir2save = args.settings.path2figures;
        if ~exist(string(dir2save),'dir'); mkdir(dir2save); end
        switch args.preferences.visualization
            case true
                f1 = figure('Color',[1 1 1],'visible','on');
            case false
                f1 = figure('Color',[1 1 1],'visible','off');
        end
        plot(trig_ch_1); hold on; plot(trig_ch_2);
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
        
    case 'Neuralynx'
        ncs_files = dir(fullfile(args.settings.path2rawdata, '*.ncs'));
        num_channels=0;
        for ncs_file_name=ncs_files'
            num_channels = num_channels+1;
            file_name = ncs_file_name.name;
            ncs_file = fullfile(args.settings.path2rawdata,file_name);
            fprintf('Channel #%i Reading file %s\n', num_channels, ncs_file)
            [Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples, Samples, Header] = Nlx2MatCSC_v3(ncs_file,[1 1 1 1 1],1,1,1);
            data=reshape(Samples,1,size(Samples,1)*size(Samples,2));
            data=int16(data);
            raw_data = [raw_data; data];
            labels{num_channels} = file_name;
            %             samplingInterval = 1000/SampleFrequencies(1);
        end
        
    case 'NihonKohden'
        nfiles = dir(fullfile(args.settings.path2rawdata, '*.edf'));
        raw_data = []; labels = []; data = {}; 
        for file_id = 1:numel(nfiles)
            curr_file = fullfile(args.settings.path2rawdata,nfiles(file_id).name);
            [hdr{file_id},data{file_id}] = edfread(curr_file);
            raw_data = [raw_data; data{file_id}];
            labels   = [hdr{file_id}.label'];
        end
        num_channels = hdr{file_id}.ns;
end
