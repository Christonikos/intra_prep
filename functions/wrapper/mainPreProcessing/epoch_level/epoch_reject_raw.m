function [badtrials, badinds] = epoch_reject_raw(data,thr_raw,thr_diff)

%% epoch_reject.m
% Function: Identifies bad epoch for analysis exclusion based on
%           outlier values of the raw signal or large jumps in the
%           raw signal
%           data can be either epoched or a single timecourse (i.e. 1 trial)
%           data should have dimensions of trials x time
%
% Inputs:
%   data: either epoched or a single timecourse (trial x time)
%   thr_raw: threshold for raw data (z-score threshold relative to all data points) to exclude timepoints
%   thr_diff: threshold for changes in signal (diff bw two consecutive points; also z-score)
%   perc_bad: % of bad timpts in trial for a trial to be marked as bad

% Output: modifies globalVar file to include info on bad epochs
%
% Amy Daitch (adaitch@stanford.edu)

%% Inputs/define

if isempty(thr_raw)
    thr_raw = 5;
end
if isempty(thr_diff)
    thr_diff = 5;
end
% if isempty(perc_bad)
perc_bad = 0.05;  % of bad timpts in trial for a trial to be marked as bad
% end


%% identify bad epochs

[ntrials,ntime] = size(data);

zraw = (data-(nanmean(data(:))))/nanstd(data(:));
datadiff = diff(data,[],2);
zdiff = (datadiff-nanmean(datadiff(:)))/nanstd(datadiff(:));

bad_raw = abs(zraw)>thr_raw;
bad_diff = [false(ntrials,1) abs(zdiff)>thr_diff];

bad_all = bad_raw | bad_diff;
badinds.raw = cell(1,ntrials);
badinds.diff = cell(1,ntrials);
badinds.all = cell(1,ntrials);
badtrials = (sum(bad_all,2)/ntime)>perc_bad;

for ti = 1:ntrials
    badinds.raw{ti} = find(bad_raw(ti,:));
    badinds.diff{ti} = find(bad_diff(ti,:));
    badinds.all{ti} = find(bad_all(ti,:));
end

    
    
    
