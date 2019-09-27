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
%                                                     "Blackrock" and "NihonKohden" datatypes, we update the
%                                                     field params.srate with the srate provided by the
%                                                     recording system.

% ---------------------------------------------------------------------------------------------------------------
function [raw_data, labels, num_channels, args] = load_raw_data(args)

disp([newline '---------- Loading raw data -------------' ...
    newline newline ...
    'Patient            : ' args.settings.patient  '.' newline ...
    'Datatype           : ' args.settings.datatype '.' newline ...
    newline   '-----------------------------------------'])

raw_data = []; 
% switch datatype
switch args.settings.datatype
    case 'Blackrock'
        %% --------- LOAD THE RAW BLACKROCK DATA --------- %%
        % load the Blackrock data and perform sanity checks on the time
        % differences between the recording boxes. 
        [raw_data, num_channels, args] = load_blackrock_data(args);
        % load the file that contains the probe information
        files = dir(fullfile(args.settings.path2rawdata, '*elecs*'));
        if isempty(files); error('probe names file not found!');end
        labels = strtrim(string(importdata(fullfile(args.settings.path2rawdata,files.name))));
        labels = strrep( labels,'"','');

    case 'Neuralynx'
        ncs_files = dir(fullfile(args.settings.path2rawdata, '*.ncs'));
        num_channels=0;
        for ncs_file_name=ncs_files
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
        
    case 'Neuroscan'
        addpath('/home/czacharo/Software/MATLAB/toolbox/fieldtrip-20190922')
        nfiles = dir(fullfile(args.settings.path2rawdata, '*.eeg'));
        if isempty(nfiles)
            error('FileNotFound')
        end
        
        raw_data = []; labels = []; data = {};
        for file_id = 1:numel(nfiles)
            cfg = [];
            cfg.dataset = fullfile(args.settings.path2rawdata,nfiles(file_id).name);
            % Only working for one file only at the moment
            dataInfo = ft_preprocessing(cfg);
            raw_data = dataInfo.trial{1};  
        end
       labels       = dataInfo.label; 
       num_channels = numel(labels);
       args.srate   = dataInfo.fsample;
end
