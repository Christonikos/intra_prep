function save_logfile(rejected_channels, args)
% export a log file to the output folder with the indices of the rejected
% channels per test #.
reasons_of_exclusion = {'channel variance : ' 'spikes detection : ' ...
    'powerspectrum deviation : ' 'hfos detecion : '};
ntests          = size(rejected_channels,2);
curr_session    = args.settings.session; 
curr_patient    = args.settings.patient;
file_name       = fullfile(args.settings.path2deriv.preproc, ...
    join(['rejected_channels_by_tests_', curr_session,'_',curr_patient,'.txt']));

% check if dir2save exists - else create it:
dir2save = args.settings.path2deriv.preproc;
if ~exist(string(dir2save),'dir'); mkdir(dir2save); end
% loop through number of tests
for t_id = 1:ntests
    if t_id ==1; p = 'w'; else p = 'a'; end         % p = permission;
    curr_test = find(~rejected_channels(:,t_id))';   % t_id = test id
    fileID = fopen(file_name,p);
    % loop through the channels of the curr_test
    for chID = 1:numel(curr_test)
        if chID == 1
           fprintf(fileID,'%s' ,reasons_of_exclusion{t_id});
        end
        if chID == numel(curr_test)
            fprintf(fileID,'%d\n',curr_test(chID));
        else
            fprintf(fileID,'%d,',curr_test(chID));
        end
    end
    fclose(fileID);
end

