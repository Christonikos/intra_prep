% load_raw_data : This generic function can be used to return the raw data from multiple Hospitals
% and for various recording techniques.
% Written by : Christos-Nikolaos Zacharopoulos (christonik@gmail.com)
% @UNICOG, 2018
%
%   INPUTS:
%                   1. settings         : Struct  -   Holds the paths to
%                                                   various locations such as the data directory etc.
%
%                   2. P                : Struct  -   The configuration struct that is constructed at the
%                                                      begginin of each run function.
%
%
%
%   OUTPUTS :
%                   1. raw_data         : Matrix  -   Dimensions [Channels x time]
%
%                   2. Labels           : Cell of strings - labels of all
%                                           channels
%
%                   3. num_channels     : Double  -   Number of channels used in the current raw file.
%

% ---------------------------------------------------------------------------------------------------------------
function [raw_data, labels, num_channels] = load_raw_data(args)

disp([newline '---------- Loading raw data -------------' ...
    newline newline ...
    'Patient            : ' args.settings.patient  '.' newline ...
    'Hospital           : ' args.settings.hospital '.' newline ...
    'Datatype           : ' args.settings.datatype '.' newline ...
    newline   '-----------------------------------------'])

raw_data = []; labels = {};
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
            lab_files{file_id} = {NS3.ElectrodesInfo.Label}';
            % release memory
            clear data files files_len
        end
       % zero pad the time-difference between the two .ns3 files
        timeDelay = length(ns3_files{1}) - length(ns3_files{2});
        if sign(timeDelay) == -1
            ns3_files{1} = [ns3_files{1}, zeros(size(ns3_files{1},1),abs(timeDelay))];
        else
            ns3_files{2} = [ns3_files{2}, zeros(size(ns3_files{2},1),abs(timeDelay))];
        end
        % concatenate the two files into a single variable: 
        raw_data = [ns3_files{1}; ns3_files{2}];
        labels   = [lab_files{1}; lab_files{2}];
        %% Output check
        if ~(size(raw_data,2) > size(raw_data,1))
            error('Wrong dimensions!')
        end
        num_channels = size(raw_data,1);
       
        

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
end
