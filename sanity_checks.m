%% Houston
load('bad_channels.mat')% variable created @Houston. 
h_rej.indices = find(~chs{4});
h_rej.number  = numel(h_rej.indices);


%% Stanford
% txt file generated from the Stanford pipeline
%% Stanford
% txt file generated from the Stanford pipeline
f_txt =  ...
importdata('rejected_channels_Stanford_S18_125_LU.txt'); 
test = struct(); reject_chan_pool = []; 
for tid = 1:size(f_txt.data,1)
    cur_indices = f_txt.data(tid,:);
    %exclude the first trigger channel for compliance reasons
    cur_indices(ismember(cur_indices,129)) = [];
    % get rejection indices per test#
    test_indices.(['n_' num2str(tid)]) = ...
        cur_indices(~isnan(cur_indices));
    reject_chan_pool = ...
        [reject_chan_pool cur_indices(~isnan(cur_indices))];
end
% non conservative option : at least on 1 test
f_rej.indices.non_cons = unique(reject_chan_pool);
f_rej.number.non_cons  = numel(f_rej.indices.non_cons);



% txt file generated from the Unicog pipeline
u_txt =  ...
importdata('rejected_channels_by_tests_s1_S18542.txt'); 
test = struct(); reject_chan_pool = []; 
for tid = 1:size(u_txt.data,1)
    cur_indices = u_txt.data(tid,:);
    %exclude the first trigger channel for compliance reasons
    cur_indices(ismember(cur_indices,129)) = [];
    % get rejection indices per test#
    test_indices.(['n_' num2str(tid)]) = ...
        cur_indices(~isnan(cur_indices));
    reject_chan_pool = ...
        [reject_chan_pool cur_indices(~isnan(cur_indices))];
end
% non conservative option : at least on 1 test
u_rej.indices.non_cons = unique(reject_chan_pool);
u_rej.number.non_cons  = numel(u_rej.indices.non_cons);

common_exclusion = numel(intersect(f_rej.indices.non_cons,u_rej.indices.non_cons));

% -------- comparison figure -------- % 
f3 = figure('Color',[1 1 1],'visible','on');
rng 'default';fontSize = 13.5;        
data = [f_rej.number.non_cons u_rej.number.non_cons common_exclusion];
fHand = f3;
aHand = axes('parent', fHand);
hold(aHand, 'on')
colors = ['k','r','g'];
for conID = 1:numel(data)
    bar(conID, data(conID),'grouped', 'parent', aHand, 'facecolor', colors(conID));
end
grid on
grid minor
xticks([1 2 3])
legendInfo = {"Stanford Pipeline" "Unicog Pipeline" "Intersection"};
legend(legendInfo,'Location','northeastoutside','FontSize', fontSize)
ylabel('#rejected electrodes')
title('S18542 - s1')
close(f3)
% ------------------------------------%
