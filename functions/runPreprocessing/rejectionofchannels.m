function rejected_channels_index = rejectionofchannels(indexofcleandata, rejectedchannels,gyri,settings,hopID,labels,pathological_event)
indexConjuction  = horzcat([indexofcleandata{:}]);
% A logical conjuction of rejected channels will lead to a total sum of 0
% (these are the channels that were rejected in all epochs);
sumofindex = find((sum(indexConjuction,2) == 0 ));

switch hopID
  case 'Houston'
    % chek if the channel Index -output folder exist - else create it
    if ~(exist(fullfile(join([settings.path2output,'Clean_channels',settings.patient]),'dir')) == 7) ==1
      mkdir(fullfile(join([settings.path2output,'Clean_channels_',settings.patient])))
    end

    badchannels_index.total_bad_channels = sumofindex;
    badchannels_index.labels = labels;
    badchannels_index.gyri = gyri;
    badchannels_index.timestamp_of_hfos = pathological_event;
    
    if ~(exist(fullfile(join([settings.path2output,'Clean_data_',settings.patient]),'dir')) == 7) ==1
      mkdir(fullfile(join([settings.path2output,'Clean_data_',settings.patient])))
    end
    
    % Save to output folder here.
    save(fullfile(join([settings.path2output,'Clean_data_',settings.patient]), ...
      join(['badchannels_index_',settings.patient])),'badchannels_index','-v7.3');
    
    rejected_channels_index = sumofindex;
end