function [pathological_chan_id,pathological_event]=find_paChan(eeg,chanNames,fs,thr)
%   Find possible pathological channels with HFO and spikes.
%   Pathological (irritative) channels are defined as channels with event
%   occuerrnce rate > [thr] times of the average HFO+spike rate
%   eeg:        miltichannel EEG data in columns.
%   chanNames:  channel labels.
%   fs:         sampling frequency.
%   tr:         threshold to define the patholgocial channels.
%
%   pathological_chan_id: pathological channels index (monopolar)
%   pathological_event:    -ts(:,1) = timestamps of each event;
%                          -ts(:,2) = corresponding channel index (***bipolar)
%   Su Liu
%   suliu@standord.edu

if nargin<4
    thr = 2;
end


% Chris : this function requires the data in the format : [time x channels]
% which is not the case for our data. 
if size(eeg,2)> size(eeg,1); eeg = eeg';end

z=1;
%Create bipolar for HFO and spike detection
fprintf('%s\n','---- Creating bipolar montage ----')

%%%%%%%change
if strcmp(chanNames{1,1},'01')
    labels=str2double(chanNames);
    [new_labels,orig_order]=sort(labels);
    for i=1:size(eeg,2)-1
        eeg_bi(:,z)=eeg(:,orig_order(i))-eeg(:,orig_order(i+1));
        chan{1,z}=sprintf('%s-%s',chanNames{i},chanNames{i+1});
        z=z+1;        
    end
else 
    for i=1:size(eeg,2)-1
        name1 = join(regexp(string(chanNames{i}),'[a-z]','Match','ignorecase'),'');
        name2 = join(regexp(string(chanNames{i+1}),'[a-z]','Match','ignorecase'),'');
        if strcmp(name1,name2)
            eeg_bi(:,z) = eeg(:,i)-eeg(:,i+1);
            chan{1,z}=sprintf('%s-%s',chanNames{i},chanNames{i+1});
            z=z+1;
        else
            continue
        end
    end
end
%%% change

%Detecting events

fprintf('%s\n','---- Detecting pathological events ----');
% Chris : flag for fs = 500 Hz.
wn = [80 450]/(fs/2);
if fs<900
    error('Sampling rate < 900 Hz. The sampling frequency should be at least twice the upper cuttof frequency.')
end

b = fir1(64,wn);
a = 1;
input_filtered = filtfilt(b,a,eeg_bi);
n = size(input_filtered,2);

% loop over channels
for i = 1:n %1:n
    [~,th] = get_threshold(input_filtered(:,i),100,50,'std',5);
    try
        timestamp{i}(:,1) = find_event(input_filtered(:,i),th,2,1);
        timestamp{i}(:,2) = i;
    catch
        continue;
    end
end

T = cat(1,timestamp{:}); % C : 1st column sample points of peaks that exceed the threshold , 2nd column = channel index
[~,I] = sort(T(:,1)); % C : sort by channel
event.timestamp = T(I,:); % C : sort by sample point
[alligned,allignedIndex,K] = getaligneddata(eeg_bi,event.timestamp(:,1),[-150 150]); %alligned = epoched HFOS, allignedIndex = HFO and window around it,
% K = HFO rejection index based on the detection time with respect to the recording duration (too early - too late)
event.timestamp=event.timestamp(logical(K),:); % Only keep the non-borderline detected HFOS
ttlN = size(alligned,3);
for i = 1:ttlN % C : loop through event peaks
    event.data(:,1,i) = alligned(:,event.timestamp(i,2),i); %raw segment
    event.data(:,2,i) = input_filtered(allignedIndex(i,:), event.timestamp(i,2))*1000; %filtered segment
    event.data(:,3,i) = allignedIndex(i,:); %index
end
atf_ind = find(eliminate_noise(event.data,fs));
event.data(:,:,atf_ind) = [];
channel = event.timestamp(:,2);
channel(atf_ind)=[];
pChan = chan(event.timestamp(:,2));
pChan(atf_ind)=[];
event.timestamp(atf_ind,:)=[];
s_p = zeros(1,n);
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


