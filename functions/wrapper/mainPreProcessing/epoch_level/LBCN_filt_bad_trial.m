function [badind, filtered_beh,spkevtind,spkts] = LBCN_filt_bad_trial(data_raw,fs,spk_thr,atf_thr,resamp)
%   This function examines each epoched data and get the indicies of sharp spikes in a epoch.
%   Time stamps of identified spikes and the [-50 50] window will be
%   stored.
%   Overlapping windows will be merged as one. Epochs with large variance, 
%   or more than 3 spikes / > 400 samples identified will be marked as bad.
%   Input:  data_raw -- epoched data in columns.
%           spk_thr -- threshold to find spikes in a signal. Default 8.
%           Data with spikes identified by this threshold will be filtered.
%           atf_thr -- threshold to find artifacts in a signal. Default 5 times of the spk threshold.
%           Data with atf identified by this threshold would be excluded.
%           resamp -- put 1 to exclude spikes and resample the data. Defalt 0.
%   Output: badind -- indicies of trials to exclude.
%           filtered_beh: data with spikes set to NaN. Data point after the NaN
%           window is shifted to avoid jump in the amplitude. 
%           spkevtind -- epochs with spikes identified.
%           spkts -- time stamps of spikes. These time stamps can be set to NaN for later plots. 
%   Su Liu
%   suliu@stanford.edu.
% text_su = fileread('su_txt.txt')


if nargin < 3 || isempty(spk_thr)
    spk_thr = 8;
end
if nargin < 4 || isempty(atf_thr)
    atf_thr = 5;
end
if nargin < 5
    resamp = 0;
end
[b,a] = butter(2,[4 70]/(fs/2));
[b2,a2] = butter(2,70/(fs/2),'high');
tn = size(data_raw,2);
dn = size(data_raw,1);
badind = false(1,tn);
spkts = false(size(data_raw));
badind(sum(data_raw)==0) = 1;
spkevtind = false(1,tn);
filtered_beh = zeros(size(data_raw));
df = filtfilt(b,a,data_raw);
dfn = data_norm(df,2);
vn = nan(1,tn);
vn(~badind) = var(dfn(:,~badind));
vnn = zeros(1,tn);
vnn(~badind) = data_norm(vn(~badind)',5);
badind(vnn<0.6*median(vnn)) = 1;
for j = 1:tn
% for j = find(~badind)
    dat = data_raw(:,j);
    check = filtfilt(b,a,dat);
    checkhf = filtfilt(b2,a2,dat);
    [~,thhf] = get_threshold(checkhf,16,8,'std',3.5);
    [~,th2] = get_threshold(check,16,8,'std',spk_thr);
    peakind = find(diff(sign(diff(check))) ~= 0)+1;
    peakind2 = find(diff(sign(diff(checkhf))) ~= 0)+1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     subplot 411
    %     y=detrend(dat,'constant');
    %     plot(y);hold on
    %     line([300 300],[min(y)*5 max(y)*5],'color','k','linewidth',2);
    %     xlim([0 dn]);
    %     ylim([min(y)*1.5 max(y)*1.5]);
    %     hold off;
    %     zc=zerocross_count(filtfilt(b2,a2,y)');
    %     title(num2str(zc));
    %     subplot 412
    %     plot(check);hold on
    %     line([300 300],[min(check)*5 max(check)*5],'color','k','linewidth',2);
    %     plot(ones(size(check))*th2,'r--');
    %     plot(-ones(size(check))*th2,'r--');
    %     xlim([0 dn]);
    %     ylim([min(check)*1.5 max(check)*1.5]);
    %     hold off
    %     title(num2str(std(data_norm(y,5))));
    %
    %
    %     subplot 413
    %     pp=filtfilt(b2,a2,dat);
    %     [~,th3] = get_threshold(pp,16,8,'std',5);
    %
    %     plot(pp);hold on
    %     plot(ones(size(check))*th3,'r--');
    %     plot(-ones(size(check))*th3,'r--');
    %     line([300 300],[min(pp)*1.2 max(pp)*1.2],'color','k','linewidth',2);
    %     xlim([0 dn]);title(num2str(j));
    %     hold off;
    %pause;
    peaks = check(peakind);
    peaks2 = checkhf(peakind2);
    ind = peakind([find(peaks > th2)' find(peaks < -th2)']);
    ind2 = peakind2([find(peaks2 > thhf)' find(peaks2 < -thhf)']);
    match = false(1,length(ind));
    for ii = 1:length(ind)
        if any(ismember(ind2,ind(ii)-5:ind(ii)+5))
            match(ii)=1;
        end
    end
    ind = ind(match);
    if ~isempty(ind)
        window = [ind-50 ind+50];
        [~,A] = sort(window(:,1));
        window = window(A,:);
        overlap = find(window(2:end,:)-window(1:end-1,2)<0);
        window(overlap,2) = nan;
        window(overlap+1,1) = nan;
        window(isnan(window)) = [];
        window(window<=0) = 1;
        window(window>=dn) = dn;
        try
            window = reshape(window,length(window)/2,2);
        catch
        end
        if any(abs(peaks) > th2) && ~any(abs(peaks) > th2*atf_thr) && size(window,1)<=3 ...
                && max(abs(dat)) < 1000 && sum(window(:,2)-window(:,1)) <= 400
            
            if size(window,1)==1
                    dnew=[dat(1:window(1));nan(window(1,2)-window(1,1)-1,1);dat(window(2):end)+dat(window(1))-dat(window(2))];
            elseif size(window,1)==2
                    dnew=[dat(1:window(1,1));...
                        nan(window(1,2)-window(1,1)-1,1);dat(window(1,2):window(2,1))+dat(window(1,1))-dat(window(1,2));...
                        nan(window(2,2)-window(2,1)-1,1);dat(window(2,2):end)+dat(window(1,1))-dat(window(1,2))+dat(window(2,1))-dat(window(2,2))];
            elseif size(window,1)==3
                dnew=[dat(1:window(1,1));...
                    nan(window(1,2)-window(1,1)-1,1);dat(window(1,2):window(2,1))+dat(window(1,1))-dat(window(1,2));...
                    nan(window(2,2)-window(2,1)-1,1);dat(window(2,2):window(3,1))+dat(window(1,1))-dat(window(1,2))+dat(window(2,1))-dat(window(2,2));...
                    nan(window(3,2)-window(3,1)-1,1);dat(window(3,2):end)+dat(window(1,1))-dat(window(1,2))+dat(window(2,1))-dat(window(2,2))+dat(window(3,1))-dat(window(3,2))];
            end
            dat = dnew;
            if resamp
                dnew(isnan(dnew))=[];
                dat=resample(dnew,dn+10,length(dnew));
                dat=dat(1:dn);
            else
                for k = 1:size(window,1)
                    spkts(window(k,1):window(k,2),j)=1;
                end
            end
            spkevtind(j) = 1;
        else 
            badind(j) = 1;
        end
        
    end
    filtered_beh(:,j) = dat;
end