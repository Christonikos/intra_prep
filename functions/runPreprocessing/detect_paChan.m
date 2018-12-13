function [pathological_chan_id,pathological_event, bipolar_eeg] = detect_paChan(eeg,chanNames,fs,thr, settings, P, hopID)
%   Find possible pathological channels with HFO and spikes.
%   Pathological (irritative) channels are defined as channels with event
%   occuerrnce rate > [thr] times of the average HFO+spike rate
%   eeg:        miltichannel EEG data in columns.
%   chanNames:  channel chanNames.
%   fs:         sampling frequency.
%   tr:         threshold to define the patholgocial channels.
%
%   pathological_chan_id: pathological channels index (monopolar)
%   pathological_event:    -ts(:,1) = timestamps of each event;
%                          -ts(:,2) = corresponding channel index (***bipolar)
%   Su Liu
%   suliu@standord.edu
%   Modified by : christonik@gmail.com

% Set a default threshold in case it is not provided by the user
if nargin<4
    thr = 2;
end
% legacy issue
params = fs;

switch hopID
    
    case 'Houston'
        
        
        % ----------------- STEP 1: BIPOLAR REFERENCE ----------------- %
        
        %Create a bipolar re-reference for HFO and spike detection
        fprintf('\n%s\n','---- Creating bipolar montage ----')
        
        % To do a bipolar re-reference we need to identify the different probes
        % (so we are only re-referencing within the same probe)
        
        
        % loop throught the chanNames and check the if two succesive
        % alphanumeric values are the same (this will indicate that we are
        % on the same probe).
        
        
        try
            % Pre-allocate to store the bipolar re-reference
            bipolar_eeg = zeros(size(eeg,1),size(eeg,2));
        catch ('Out of memory. Type HELP MEMORY for your options.');
        end
        
        chanNames{end+1} = char('Marker');
        timecount = linspace(1,100,size(eeg,1));
        clear textprogressbar
        textprogressbar('Re-referencing the channels : ' )
        % loop through channels
        for channel = 1: size(eeg,1)-1
            textprogressbar(timecount(channel));
            % Get the label names of the current and the following electrode
            lc = chanNames{channel}; % lc = label current
            ln = chanNames{channel + 1}; % ln = label next
            % Remove the numbers
            lc = lc(isstrprop(lc,'alpha'));
            ln = ln(isstrprop(ln,'alpha'));
            
            if strcmp(lc,ln)
                % To exlude the already rejected channels from the bipolar
                % re-reference, seek and only re-reference two consecutive
                % non-NaN channels.
                if ~isnan(eeg(channel,1)) && ~isnan(eeg(channel+1,1))
                    %                     disp(['Re-referencing channels ' num2str(channel+1) ...
                    %                         ' and ' num2str(channel) ' on probe ' lc])
                    bipolar_eeg(channel,:) = eeg(channel,:) - eeg(channel+1,:);
                else
                    %                     disp(['Channels ' num2str(channel+1) ' and ' ...
                    %                         num2str(channel) ' were skipped'])
                    bipolar_eeg(channel,:) = eeg(channel,:);
                end
            else
                %                 disp(['Changing probe. Moving to : ' ln])
                bipolar_eeg(channel,:) = eeg(channel,:);
                continue;
            end
        end
        
        
        
        disp([newline ' The bipolar re-referencing has been completed. ' newline])
        clc;
        clear eeg
        
        
        % ----------------- STEP 2: FIR-FILTERING AND HFO DETECTION ----------------- %
        
        
        fprintf('%s\n','---- Detecting pathological events ----');
        
        % low-pass filter the data using a N'th order lowpass FIR digital filter
        filter_order = 64;
        window = [80 450]/(params.srate/2);
        disp(['Designing the FIR filter kernel.' newline])
        b = fir1(filter_order, window);
        a = 1;
        %         The filter
        %         is described by the difference equation:
        %
        %         a(1)*y(n) = b(1)*x(n) + b(2)*x(n-1) + ... + b(nb+1)*x(n-nb)
        %             - a(2)*y(n-1) - ... - a(na+1)*y(n-na)
        
        disp(['Filtering with Zero-phase forward and reverse digital IIR filtering' newline])
        
        
        
        %         loop through channels and filter to ease memory consuption
        %         Pre-allocate
        input_filtered = zeros(size(bipolar_eeg,1),size(bipolar_eeg,2));
        timestamp = cell(size(bipolar_eeg,1),1);
        timesteps = linspace(1,100,size(bipolar_eeg,1));
        
        
        close all;
        clear textprogressbar
        textprogressbar('Filtering the channels and extracting the threshold : ' )
        disp(newline)
        for chanID = 1:size(bipolar_eeg,1)
            textprogressbar(timesteps(chanID))
            if isnan(bipolar_eeg(chanID))
                continue
            end
            input_filtered(chanID,:) = filtfilt(b,a,bipolar_eeg(chanID,:));
            [~,th] = get_threshold(input_filtered(chanID,:),100,50,'std',5);
            try
                events = find_event(input_filtered(chanID,:),th,2,1);
                timestamp{chanID}(:,1) = events;
                timestamp{chanID}(:,2) = chanID;
            catch 'Subscripted assignment dimension mismatch.';
                continue
            end
            
        end
        textprogressbar([newline 'Detection of HFOs completed '])
        
        
        
        % Sort the events according to the channels
        T = cat(1,timestamp{:});
        
        % Depending on the coverage of the electrodes on the brain of the
        % patient, we might not detect HFOs at all. In that case , set the
        % pathological channel to zero and return. 
        if isempty(T)
            pathological_chan_id = [];
            pathological_event.ts = [];
            pathological_event.channel =[];
            return
        end
        
        
        
        
        % Now, sort the events according to the time of occurence and get
        % the index of this occurence
        [~,I] = sort(T(:,1));
        % Creates a matrix where the events are sorted according to time
        % (1st column) and the channels that correspond to those events are
        % on the second column.
        event.timestamp = T(I,:);
        
        % -------------  Allign the data  ------------- %
        
        range = [-150 150];
        % The input to the 'getaligneddata' must have dimensionality
        % [samples x channels] which is not what we have. We therefore
        % need to transpose it. Due to the large size of the data though,
        % we will run out of memory while doing so. The work-around is to
        % epoch the continuius data (irrelevant of block type at this
        % moment)
        
        
        % transpose the filtered data for compliance reasons
        input_filtered = input_filtered';
        
        [alligned,allignedIndex,K] = getalligneddata(bipolar_eeg',event.timestamp(:,1),[-150 150]);
        
        event.timestamp = event.timestamp(logical(K),:);
        % The total number of the detected events
        ttlN = size(alligned,3);
        % loop through the events
        for eventID = 1:ttlN
            % Saves the raw segment
            event.data(:,1,eventID) = alligned(:,event.timestamp(eventID,2),eventID);%raw segment
            % Saves the filtered segment (HFO candidate)
            event.data(:,2,eventID) = input_filtered(allignedIndex(eventID,:),...
                event.timestamp(eventID,2))*1000;%filtered segment
            % Saves the index of the event
            event.data(:,3,eventID) = allignedIndex(eventID,:);%index
        end
        % Get the events that need to be discarded (events that are not
        % considered noise)
        atf_ind = find(eliminate_noise(event.data,params.srate));
        % Discard those events
        event.data(:,:,atf_ind) = [];
        % Get the channels that correspond to those events
        channel = event.timestamp(:,2);
        % and remove them
        channel(atf_ind) = [];
        
        % Create electrode-pairs list
        counter = 1;
        for chanID = 1:size(bipolar_eeg,1)
            chan{1,counter}=sprintf('%s-%s',chanNames{chanID},chanNames{chanID+1});
            counter=counter+1;
        end
        
        pChan = chan(event.timestamp(:,2))';
        pChan(atf_ind')=[];
        event.timestamp(atf_ind,:)=[];
        s_p = zeros(1,size(bipolar_eeg,1));
        u = unique(channel);
        s = zeros(1,length(u));
        for j=1:length(u)
            s(j)=length(find(channel==u(j)));
        end
        s_p(1,u)=s;
        
        
        
        %Channels with event occurence rate > 2*median rate are shown. Can change as needed.
        pc=chan(s_p>thr*mean(s_p));
        monochan=cell(length(pc),2);
        for i = 1:length(pc)
            try
                monochan(i,:) = strsplit(pc{i},'-');
            catch
                temp=strsplit(pc{i},'-');
                if length(temp)==4
                    monochan(i,1)=strcat(temp(1),'-',temp(2));
                    monochan(i,2)=strcat(temp(3),'-',temp(4));
                else
                    error('Channel name mismatch');
                end
            end
        end
        
        
        fprintf('---- Done ----')
        %%%%%%%%%show problematic chan%%%%%%%%%%%%%%
        pathological_chan=unique(monochan(:));
        pathological_event.ts=event.timestamp;
        pathological_event.channel=pChan;
        
        if isempty(pathological_chan)
            pathological_chan_id=[];
        else
            for i=1:length(pathological_chan)
                pathological_chan_id(i)=find(strcmp(pathological_chan{i},chanNames));
            end
        end
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
end

