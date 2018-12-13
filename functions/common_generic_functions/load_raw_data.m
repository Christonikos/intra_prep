% load_raw_data : This generic function can be used to return the raw data from multiple Hospitals
% and for various recording techniques.
% Written by : Christos-Nikolaos Zacharopoulos (christonik@gmail.com)
% @UNICOG, 2018
%
%    INPUTS:
%                   1. settings        : Struct - Holds the paths to
%                                                 various locations such as the data directory etc.
%                   2. params          : Struct - Holds various hospital-specific information such as the
%                                                 soa of the paradigm and the notch filtering parameters.
%                   3. P               : Struct - The configuration struct that is constructed at the
%                                                 begginin of each run function.
%                   4. hard_drive_path : String - The path to the data       (provided by getCore.m)
%
%                   5. elecs_path      : String - The path to the electrodes (provided by getCore.m)
%
%                   6. hopID           : String - This is the hospital ID, specified at the beginning of each run function.
%
%  OUTPUTS :
%                   1. raw_data     : Cell   - The dimensions of the cell correspond to the number of the recording sessions per experiment.
%                                              Each entry is a matrix of dimensions [Channels x time]
%
%           		2. channels     : Double - Number of channels used in the experiment.
%
%                   3. labels       : Cell   - Labeling of the channels [channels x 1].
%
%                   4. gyri         : Cell   - This is a hospital specific output. In intracranial data, some labs
%                                              provide the corregistration of the labels with an anatomical atlas.
%                                              If this provided, it will be stored in the variable gyri.
%                   5. coords       : Matrix - MNI or Talairach coordinates of the electrodes (Hospital specific).
%                                              [channels x 3]
%           		6. params       : Struct - Some times the sampling rate is known before-hand and manually provided
%                                              in the function load_settings_params. In other cases, it needs to be
%                                              extracted from the data. This is why the params struct is being updated
%                                              here.
%                   7. recordings   : Double - Most recordings originating from intracranial paradigms have multiple sessions.
%                                              The number of those sessions is provided here.
% ---------------------------------------------------------------------------------------------------------------

%
function [raw_data, channels ,labels, gyri, coords,  params, recordings] = load_raw_data(settings, P, ...
    params, datatypeID, elecs_path, recMethod, hopid)

% Load the data from the different hospitals
switch hopid
    case 'Houston'
        switch datatypeID
            case 'Blackrock'
                % List the directory for more than 1 recordings
                files = dir(fullfile(settings.path2output, 'data_ac*.mat'));
                % Preallocate the cell for storing the data (assume a maximum 100 of recordings)
                data = cell(100,1);
                % Display information to the user
                disp([newline '---------- Loading raw data -------------' ...
                    newline newline ...
                    'Patient            : ' settings.patient '.' newline ...
                    'Recordings         : ' num2str(length(files)) '.' newline ...
                    'Hospital           : ' hopid newline ...
                    'Recording method   : ' num2str(recMethod) newline ...
                    newline   '-----------------------------------------'])
                clear textprogressbar
                timecount = linspace(1,100,length(files));
                textprogressbar([newline 'Loading all recording sessions : ' newline])
                % Loop through recordings
                for f = 1:length(files)
                    textprogressbar(timecount(f));
                    data{f,:} = load(fullfile(settings.path2output,files(f).name));
                end
                clear textprogressbar;
                % Keep only the non empty rows
                data = data(~cellfun('isempty',data));
                if isempty(data)
                    disp([newline 'The data could not be found.' newline ...
                        '1. If you are using an external disk, check that the disk is mounted.', ...
                        newline , ...
                        '2. Please check the path declaration.'])
                    return
                end
                channels = size(data{1}.data_ac,1);
                % get the number of recordings
                recordings = length(data);
                raw_data = data; 
                % clear the data variable to release RAM
                clear data
                
                % Load the .mat file that contains the information on the electrodes
                load(fullfile(elecs_path,'elecs4stan_v4'));
                % Loop through the patients list and load the labels corresponding to
                % the current patient.
                % Patient TS107 has a different entry in the elecs struct
                if  strcmp(settings.patient, 'TS107') == 1
                    settings.patient = 'TS107B';
                    for patid = 1:size(elecs,1)
                        if strcmp(settings.patient, elecs{patid}.patient) == 1
                            % The number of channels for this patient does not correspond
                            % to the number of labels - so we have to pad manually to
                            % prevent crashing later on.
                            [elecs{patid}.names(end:257)] = {'Not assigned'};
                            elecs{patid}.coords = [elecs{patid}.coords ; zeros(7,3)];
                            labels = elecs{patid}.names;
                            % remove the trigger channel
                            if strcmp(labels, 'MARKER')
                                labels{strcmp(labels, 'MARKER')} = [];
                            end
                            % Same for the gyri of this patient.
                            [elecs{patid}.gyri(end:257)] = {'Not assigned'};
                            gyri  = elecs{patid}.gyri;
                            coords = elecs{patid}.coords;
                        end
                    end
                    settings.patient = 'TS107';
                else
                    for patid = 1:size(elecs,1)
                        if strcmp(settings.patient, elecs{patid}.patient) == 1
                            labels = elecs{patid}.names;
                            % remove the trigger channel
                            if strcmp(labels, 'MARKER')
                                labels{strcmp(labels, 'MARKER')} = [];
                            end
                            gyri  = elecs{patid}.gyri;
                            coords = elecs{patid}.coords;
                        end
                    end
                end
                
                % Mark empty entries on the gyri variable
                for g = 1:length(gyri)
                    if isempty(gyri{g})
                        gyri{g} = 'Empty entry';
                    end
                end
                
                disp([newline 'The data from all recordings (if multiple) have been loaded. '])
                
        end
    case 'UMC'
        
        % check if the output folder exists
        if ~(exist(fullfile(settings.path2output,'dir')) == 7) ==1
            mkdir(fullfile(settings.path2output))
        end
        
        files = dir(fullfile(settings.path2rawdata, '*.eeg'));
        % Preallocate the cell for storing the data (assume a maximum 10 of recordings)
        [data, dataInfo] = deal(cell(100,1));
        % Loop through recordings
        for f = 1:length(files)
            cfg = [];
            cfg.dataset = fullfile(settings.path2rawdata,files(f).name);
            [dataInfo{f,:}] = ft_preprocessing(cfg);
            data{f,:} = dataInfo{f}.trial{1};
        end
        
        % save the dataInfo
        save(fullfile(settings.path2output,'dataInfo'),'dataInfo')
        
        % Keep only the non empty rows
        data = data(~cellfun('isempty',data));
        dataInfo = dataInfo(~cellfun('isempty',dataInfo));
        
        labels = dataInfo{1}.label;
        channels = size(dataInfo{1}.trial{1},1);
        
        % Update the params struct
        params.srate = dataInfo{1}.fsample;
        
        
        
    case 'NeuroSpin'
        
        % Neuromag MEG data
        
        
        % check if the output folder exists
        if ~(exist(fullfile(settings.path2output,'dir')) == 7) ==1
            mkdir(fullfile(settings.path2output))
        end
        
        % List the directory for more than 1 recordings
        files = dir(fullfile(settings.path2rawdata, '*.fif'));
        % Preallocate the cell for storing the data (assume a maximum 100 of recordings)
        [data, hdr] = deal(cell(100,1));
        
        
        
        
        % Display information to the user
        disp(['Loading raw data - Patient ' settings.patient '.' ...
            newline  'Recordings :  ' num2str(length(files)) '.' ...
            newline 'Recording Method : ' P.RecordingMethod{recMethod} ...
            newline 'Hospital : ' hopid])
        
        
        % Loop through recordings
        for f = 1:length(files)
            cfg = [];
            cfg.dataset = fullfile(settings.path2rawdata,files(f).name);
            [dataInfo{f}] = ft_preprocessing(cfg);
            data{f,:} = dataInfo{f}.trial{1};
        end
        
        
        
        % Keep only the non empty rows
        data = data(~cellfun('isempty',data));
        dataInfo = dataInfo(~cellfun('isempty',dataInfo));
        
        
        channels = size(data{1},1);
        labels = hdr{1}.label;
        params.srate = hdr{1}.Fs;
        
        % Get information on the recordings
        for rec = 1:length(dataInfo)
            recordingTime(rec) = size(dataInfo{rec}.time{1},2)/dataInfo{rec}.fsample*(167e-4);
            tmpMetadata = split(dataInfo{rec}.cfg.dataset, filesep);
            metadata{rec} = tmpMetadata{end-1};
        end
        
        % chek if the figures folder exist - else create it
        if ~(exist(fullfile(join([settings.path2figures,'Ripples']),'dir')) == 7) ==1
            mkdir(fullfile(join([settings.path2figures,'Ripples'])))
        end
        
        
        if P.saveOutput
            
            % Plot the duration of each recording
            set(0,'DefaultFigureWindowStyle','normal')
            f = figure('Color', [1 1 1], 'visible', 'off' );
            fontSize = 12;
            % Modify the bar plot
            bar(recordingTime)
            hold on; plot(NaN,' w');
            legend(num2str(recordingTime),['Total duration: ' num2str(sum(recordingTime))  ...
                ' minutes'] ,'location','northoutside');
            grid on;
            grid minor;
            caption = sprintf( 'sEEG_Patient %s - Duration of recordings %d'  , settings.patient);
            title(caption, 'FontSize', fontSize, 'Color','b','Interpreter','none');
            % Enlarge figure to full screen.
            set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
            % Give a name to the title bar.
            set(gcf,'name','Recorded areas','numbertitle','off');
            ylabel(['Time [m]'],'FontSize', fontSize, 'FontWeight','bold')
            xlabel(['Recordings'],'FontSize', fontSize, 'FontWeight','bold')
            set(gca,'TickLabelInterpreter','none')
            xticklabels(metadata);
            file_name = ['duration_of_recordings_sEEG_', settings.patient , '.png'];
            saveas(f, fullfile(settings.path2figures, file_name), 'png')
            close(f)
            set(0,'DefaultFigureWindowStyle','docked')
            
            % save the dataInfo
            disp(['Saving the metadata in the output folder - Patient ' settings.patient])
            save(fullfile(settings.path2output,'dataInfo'),'dataInfo', '-v7.3')
            
            % save the data
            disp([newline 'Saving the data in the output folder - Patient ' settings.patient])
            
            save(fullfile(settings.path2output,'data'),'data', '-v7.3')
            
        end
        
        labels = dataInfo{1}.label;
        channels = size(dataInfo{1}.trial{1},1);
        
        % Update the params struct
        params.srate = dataInfo{1}.fsample;
        recordings = size(data,1);
        
        
        gyri = [];
        coords = [];
        
        
    case 'Marseille'
        
        % check if the output folder exists
        if ~(exist(fullfile(settings.path2output,'dir')) == 7) ==1
            mkdir(fullfile(settings.path2output))
        end
        
        folders = dir(fullfile(settings.path2rawdata));
        
        % Remove empty entries caused by the tree structure
        folders(1:2) = [];
        % Display information to the user
        disp([newline 'Loading raw data - Patient ' settings.patient '.' newline ...
            'Recordings : ' num2str(length(folders)) '.' newline 'Hospital : ' hopid newline ...
            'Recording method : ' num2str(recMethod)])
        
        % Preallocate the cell for storing the data (assume a maximum 100 of recordings)
        [data, dataInfo] = deal(cell(100,1));
        
        
        switch recMethod
            
            case 'sEEG'
                
                % Loop through recordings
                for foldID = 1:length(folders)
                    files = dir(fullfile(settings.path2rawdata,folders(foldID).name, '*.eeg'));
                    disp([newline 'Loading data for recording ' num2str(foldID) ' saved with the name ' folders(foldID).name ])
                    for f = 1:length(files)
                        cfg = [];
                        cfg.dataset = fullfile(settings.path2rawdata,folders(foldID).name,files(f).name);
                        [dataInfo{foldID,f}] = ft_preprocessing(cfg);
                        data{foldID,f} = dataInfo{foldID,f}.trial{1};
                    end
                end
                
                % Keep only the non empty rows
                data = data(~cellfun('isempty',data));
                dataInfo = dataInfo(~cellfun('isempty',dataInfo));
                
                % Get information on the recordings
                for rec = 1:length(dataInfo)
                    recordingTime(rec) = size(dataInfo{rec}.time{1},2)/dataInfo{rec}.fsample*(167e-4);
                    tmpMetadata = split(dataInfo{rec}.cfg.dataset, filesep);
                    metadata{rec} = tmpMetadata{end-1};
                end
                
                % chek if the figures folder exist - else create it
                if ~(exist(fullfile(join([settings.path2figures,'Ripples']),'dir')) == 7) ==1
                    mkdir(fullfile(join([settings.path2figures,'Ripples'])))
                end
                
                
                
                
                
                % Concatenate all recordings into a single element
                recordings = length(data);
                
                switch recordings
                    case 6
                        disp(['Concatenating all ' num2str(recordings) ' recordings  into a single variable .'])
                        raw_data = im2double([data{1} data{2} data{3} ...
                            data{4} data{5} data{6}]) ;
                        disp(['Concatenation completed .'])
                        toc
                    case 5
                        disp(['Concatenating all ' num2str(recordings) ' recordings  into a single variable .'])
                        tic;
                        raw_data = im2double([data{1} data{2} data{3} ...
                            data{4} data{5}]) ;
                        disp(['Concatenation completed .'])
                        toc
                    case 4
                        tic;
                        disp(['Concatenating all ' num2str(recordings) ' recordings  into a single variable .'])
                        raw_data = im2double([data{1} data{2} data{3} data{4}]) ;
                        disp(['Concatenation completed .'])
                        toc
                    case 3
                        tic;
                        disp(['Concatenating all ' num2str(recordings) ' recordings  into a single variable .'])
                        raw_data = im2double([data{1} data{2} data{3} ]) ;
                        disp(['Concatenation completed .'])
                        toc
                    case 2
                        tic;
                        disp(['Concatenating all ' num2str(recordings) ' recordings  into a single variable .'])
                        raw_data = im2double([data{1} data{2} ]) ;
                        disp(['Concatenation completed .'])
                        toc
                end
                
                
                
                
                
                if P.saveOutput
                    
                    % Plot the duration of each recording
                    set(0,'DefaultFigureWindowStyle','normal')
                    f = figure('Color', [1 1 1], 'visible', 'off' );
                    fontSize = 12;
                    % Modify the bar plot
                    bar(recordingTime)
                    hold on; plot(NaN,' w');
                    legend(num2str(recordingTime),['Total duration: ' num2str(sum(recordingTime))  ...
                        ' minutes'] ,'location','northoutside');
                    grid on;
                    grid minor;
                    caption = sprintf( 'sEEG_Patient %s - Duration of recordings %d'  , settings.patient);
                    title(caption, 'FontSize', fontSize, 'Color','b','Interpreter','none');
                    % Enlarge figure to full screen.
                    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
                    % Give a name to the title bar.
                    set(gcf,'name','Recorded areas','numbertitle','off');
                    ylabel(['Time [m]'],'FontSize', fontSize, 'FontWeight','bold')
                    xlabel(['Recordings'],'FontSize', fontSize, 'FontWeight','bold')
                    set(gca,'TickLabelInterpreter','none')
                    xticklabels(metadata);
                    file_name = ['duration_of_recordings_sEEG_', settings.patient , '.png'];
                    saveas(f, fullfile(settings.path2figures, file_name), 'png')
                    close(f)
                    set(0,'DefaultFigureWindowStyle','docked')
                    
                    % save the dataInfo
                    disp(['Saving the metadata in the output folder - Patient ' settings.patient])
                    save(fullfile(settings.path2output,'dataInfo'),'dataInfo', '-v7.3')
                    
                    % save the data
                    disp([newline 'Saving the data in the output folder - Patient ' settings.patient])
                    
                    save(fullfile(settings.path2output,'data'),'data', '-v7.3')
                    
                end
                
                labels = dataInfo{1}.label;
                channels = size(dataInfo{1}.trial{1},1);
                
                % Update the params struct
                params.srate = dataInfo{1}.fsample;
                recordings = size(data,1);
                
                
                gyri = [];
                coords = [];
                
            case 'MEG'
                
                % Loop through recordings
                for foldID = 1:length(folders)
                    files = dir(fullfile(settings.path2rawdata,folders(foldID).name, '*c,*rfDC'));
                    disp([newline 'Loading data for recording ' num2str(foldID) ' saved with the name ' folders(foldID).name ])
                    for f = 1:length(files)
                        cfg = [];
                        cfg.dataset = fullfile(settings.path2rawdata,folders(foldID).name,files(f).name);
                        [dataInfo{foldID,f}] = ft_preprocessing(cfg);
                        data{foldID,f} = dataInfo{foldID,f}.trial{1};
                    end
                end
                % Keep only the non empty rows
                data = data(~cellfun('isempty',data));
                dataInfo = dataInfo(~cellfun('isempty',dataInfo));
                
                
                % Get information on the recordings
                for rec = 1:length(dataInfo)
                    recordingTime(rec) = size(dataInfo{rec}.time{1},2)/dataInfo{rec}.fsample*(167e-4);
                    tmpMetadata = split(dataInfo{rec}.cfg.dataset, filesep);
                    metadata{rec} = tmpMetadata{end-1};
                end
                
                % chek if the figures folder exist - else create it
                if ~(exist(fullfile(join([settings.path2figures,'Ripples']),'dir')) == 7) ==1
                    mkdir(fullfile(join([settings.path2figures,'Ripples'])))
                end
                
                
                
                
                
                
                % Concatenate all recordings into a single element
                recordings = length(data);
                
                switch recordings
                    case 6
                        disp(['Concatenating all ' num2str(recordings) ' recordings  into a single variable .'])
                        raw_data = im2double([data{1} data{2} data{3} ...
                            data{4} data{5} data{6}]) ;
                        disp(['Concatenation completed .'])
                        toc
                    case 5
                        disp(['Concatenating all ' num2str(recordings) ' recordings  into a single variable .'])
                        tic;
                        raw_data = im2double([data{1} data{2} data{3} ...
                            data{4} data{5}]) ;
                        disp(['Concatenation completed .'])
                        toc
                    case 4
                        tic;
                        disp(['Concatenating all ' num2str(recordings) ' recordings  into a single variable .'])
                        raw_data = im2double([data{1} data{2} data{3} data{4}]) ;
                        disp(['Concatenation completed .'])
                        toc
                    case 3
                        tic;
                        disp(['Concatenating all ' num2str(recordings) ' recordings  into a single variable .'])
                        raw_data = im2double([data{1} data{2} data{3} ]) ;
                        disp(['Concatenation completed .'])
                        toc
                    case 2
                        tic;
                        disp(['Concatenating all ' num2str(recordings) ' recordings  into a single variable .'])
                        raw_data = im2double([data{1} data{2} ]) ;
                        disp(['Concatenation completed .'])
                        toc
                end
                
                
                
                
                if P.saveOutput
                    % Plot the duration of each recording
                    set(0,'DefaultFigureWindowStyle','normal')
                    f = figure('Color', [1 1 1], 'visible', 'off' );
                    fontSize = 12;
                    % Modify the bar plot
                    bar(recordingTime)
                    hold on; plot(NaN,' w');
                    legend(num2str(recordingTime),['Total duration: ' num2str(sum(recordingTime))  ...
                        ' minutes'] ,'location','northoutside');
                    grid on;
                    grid minor;
                    caption = sprintf( 'MEG_Patient %s - Duration of recordings %d'  , settings.patient);
                    title(caption, 'FontSize', fontSize, 'Color','b','Interpreter','none');
                    % Enlarge figure to full screen.
                    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
                    % Give a name to the title bar.
                    set(gcf,'name','Recorded areas','numbertitle','off');
                    ylabel(['Time [m]'],'FontSize', fontSize, 'FontWeight','bold')
                    xlabel(['Recordings'],'FontSize', fontSize, 'FontWeight','bold')
                    set(gca,'TickLabelInterpreter','none')
                    xticklabels(metadata);
                    file_name = ['duration_of_recordings_MEG_', settings.patient , '.png'];
                    saveas(f, fullfile(settings.path2figures, file_name), 'png')
                    close(f)
                    set(0,'DefaultFigureWindowStyle','docked')
                    
                    save the dataInfo
                    disp(['Saving the metadata in the output folder - Patient ' settings.patient])
                    save(fullfile(settings.path2output,'dataInfo'),'dataInfo', '-v7.3')
                    
                    save the data
                    disp([newline 'Saving the data in the output folder - Patient ' settings.patient])
                    save(fullfile(settings.path2output,'data'),'data', '-v7.3')
                    %
                    
                end
                labels = dataInfo{1}.label;
                channels = size(dataInfo{1}.trial{1},1);
                
                % Update the params struct
                params.srate = dataInfo{1}.fsample;
                recordings = size(data,1);
                
                
                gyri = [];
                coords = [];
                
                
        end
        
        
end


