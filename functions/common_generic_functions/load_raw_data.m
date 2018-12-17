% load_raw_data : This generic function can be used to return the raw data from multiple Hospitals
% and for various recording techniques.
% Written by : Christos-Nikolaos Zacharopoulos (christonik@gmail.com)
% @UNICOG, 2018
%
%    INPUTS:
%                   1. settings         : Struct  -   Holds the paths to
%                                                   various locations such as the data directory etc.
%
%                   2. P                : Struct  -   The configuration struct that is constructed at the
%                                                   begginin of each run function.
%
%                   3. datatype         : String  -   The data type (provided @ load_settings_params)
%
%                   4. elecs_path       : String  -   The path to the electrodes (provided by getCore.m)
%
%                   5. hopID            : String  -   This is the hospital ID, specified at the beginning of each run function.
%
%  OUTPUTS :
%                   1. raw_data         : Matrix  -   Dimensions [Channels x time]
%
%           		2. channels         : Double  -   Number of channels used in the current raw file.
%
%                   3. labels           : String  -   Channel labels
%                                                     provided by the recording system. 
% ---------------------------------------------------------------------------------------------------------------
function [raw_data, channels, labels] = load_raw_data(settings, P, datatypeID, recMethod, hopid)
switch datatypeID
    case 'Blackrock'
        %% --------- LOAD THE RAW BLACKROCK DATA --------- %%
                % Display information to the user
        disp([newline '---------- Loading the raw data -------------' ...
            newline newline ...
            'Patient            : ' settings.patient '.' newline ...
            'Hospital           : ' hopid newline ...
            'Recording method   : ' num2str(recMethod) newline ...
            'Datatype           : ' datatypeID newline ...
            newline   '-----------------------------------------'])
        openNSx(fullfile(join([settings.path2rawdata,filesep,P.rawfilename])))
        % list the output that Blackrock provides
        files       = NS3.Data;
        files_len   = length(files);
        switch files_len
            case 2
                if length(files{1}) > length(files{2})
                    raw_data =   files{1};
                else
                    raw_data =   files{2};
                end
        end
        channels = size(raw_data,1);
        labels   = vertcat(NS3.ElectrodesInfo.Label);
end
