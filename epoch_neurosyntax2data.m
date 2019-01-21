function epochs = epoch_neurosyntax2data(raw_data,args)

% --------------------------------------------------------
%% LOAD THE OUTPUT OF THE PARADIGM FOR THE CURRENT PATIENT
%% AND THE CURRENT RECORDING SESSION.
% --------------------------------------------------------
% List the available files per recording session
nfiles = dir(fullfile(args.settings.path2behavioral_files, '*.mat'));
% pre-allocation (see below for explanation)
[exp_files,gen_files] = deal({}); block_duration = [];
% loop through the available files
for file_id = 1:numel(nfiles)
    % the NS behavioral output consists of two distinct files, the
    % "ExperimentalRun files" and the "GeneratedSentences files".
    
    % check if the name of the file listed in the directory and split in
    % to two categories.
    curr_file = ...
        fullfile(join([args.settings.path2behavioral_files,filesep,nfiles(file_id).name]));
    if contains(curr_file,'Experimental')
        % store the ExperimentalRun files
        exp_files{file_id}      = load(curr_file);
        % store the BlockDuration 
        block_duration(file_id) = exp_files{file_id}.BlockDur; 
    elseif contains(curr_file,'GeneratedSentences')
        % store the GeneratedSentences files
        gen_files{file_id}      = load(curr_file); 
        % remove empty entries to have 1-1 mapping with exp_files
        gen_files = gen_files(~cellfun('isempty',gen_files));
    end
end

% --------------------------------------------------------
%% CHECK THE BlockDur FIELD TO FIND FALSE ENTRIES
% --------------------------------------------------------
block_durmedian = median(block_duration);
%% bound the block duration: 
upper_bound = find(block_duration > 5.*block_durmedian);
lower_bound = find(block_duration < block_durmedian/5);
% concatenate and exclude from analysis 
excluded_blocks = [lower_bound upper_bound];
[exp_files{excluded_blocks}, gen_files{excluded_blocks}] = deal([]);
% keep only non empty values :
exp_files = gen_files(~cellfun('isempty',exp_files));
gen_files = gen_files(~cellfun('isempty',gen_files));

% check that the dimensionality of the two variables is the same
if any(~size(exp_files) == size(gen_files))
   error('mismatch between the behavioral files!') 
end

% --------------------------------------------------------
%% LOOP THROUGH BLOCKS AND SPLIT ACCORDING TO CONDITIONS
% --------------------------------------------------------
[loc, main] = deal({});

% loop through blocks
for block_id = 1:numel(exp_files)
    % split in main blocks and localizer blocks
    if contains(exp_files{block_id}.Addstr,'Loc')
        loc{block_id} = exp_files{block_id};
        % remove empty entries at each iteration
        loc = loc(~cellfun('isempty',loc));
        % loop through trials to identify whether we are in a locword 
        % or a locsentence condition.
        for trial = 1:numel(loc{block_id})
            % if the deepstructure field is empty-we have a locwords
            % condition
            if isempty(loc{block_id}.deepstructure{trial})

            end
        end
    else
        main{block_id} = exp_files{block_id};
        main = main(~cellfun('isempty',main));
    end
end







