function cleandata = concatenatecleandata(filtered_data, nE,rejected_channels_index, labels,P,settings, hopID,recID)
% Re-reference the filtered_data and remove the rejected channels. 
% Save the clean data on the data output folder. 

chanNames = labels;
chanNames{end+1} = char('Marker');
re_referenced_data = cell(nE,1);
%% PERFORM THE RE-REFERENCING
switch P.rereference
  case 'bipolar'
    % loop through the epochs
    for epID = 1:nE
      % for each chunk of the data, remove the rejected channels
      data = filtered_data{epID};
      data(rejected_channels_index,:) = NaN;
      try
        % Pre-allocate to store the bipolar re-reference
        bipolar_data = zeros(size(data,1),size(data,2));
      catch ('Out of memory. Type HELP MEMORY for your options.');
      end
      timecount = linspace(1,100,size(data,1));
      clear textprogressbar
      textprogressbar([newline 'Re-referencing the channels : ' newline 'Method : ' ...
        P.rereference newline 'Epoch : ' num2str(epID)])
      % loop through channels
      for channel = 1: size(data,1)
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
          if ~isnan(data(channel,1)) && ~isnan(data(channel+1,1))
            %                     disp(['Re-referencing channels ' num2str(channel+1) ...
            %                         ' and ' num2str(channel) ' on probe ' lc])
            bipolar_data(channel,:) = data(channel,:) - data(channel+1,:);
          else
            %                     disp(['Channels ' num2str(channel+1) ' and ' ...
            %                         num2str(channel) ' were skipped'])
            bipolar_data(channel,:) = data(channel,:);
          end
        else
          %                 disp(['Changing probe. Moving to : ' ln])
          bipolar_data(channel,:) = data(channel,:);
          continue;
        end
      end
      clear data
      re_referenced_data{epID} = bipolar_data;
      textprogressbar([newline ' The re-referencing has been completed. ' newline])
      clc;
    end
    
  case 'commonaverage'
    % To be implemented
    
    
  case 'clinical'
    re_referenced_data = filtered_data;
end


%% CONCATENATE THE DATA TO A SINGLE VARIABLE
% (At this stage the data are de-trended, downsampled and notch filtered)
cleandata = [];
clear textprogressbar
textprogressbar([newline 'Concatenating the clean data' newline])
timecount = linspace(1,100,nE);
for epID = 1:nE
  textprogressbar(timecount(epID));
  cleandata = [cleandata re_referenced_data{epID}];
end
textprogressbar([newline 'Concatenation completed'])

    try
      signal = zeros(size(cleandata,1),size(cleandata,2));
    catch ('Out of memory')
    end
    clear textprogressbar
    textprogressbar([newline 'Removing the linear trend from the data' newline ])
    timecount = linspace(1,100,size(cleandata,1));
    % remove the linear trend from the re-referenced data
    for channel = 1:size(cleandata,1)
      textprogressbar(timecount(channel))
      signal(channel,:) = detrend(cleandata(channel,:));
    end
    textprogressbar('Detrending completed.')

clear cleandata

% Construct the collective struct
cleandata.data                          = signal;
cleandata.patient                     = settings.patient;
cleandata.hospital                   = hopID;
cleandata.recording_method = recID;
cleandata.rejected_channels_index = rejected_channels_index;
cleandata.re_referencing_method = P.rereference;

% chek if the output folder exist - else create it
if ~(exist(fullfile(join([settings.path2output,'Clean_data']),'dir')) == 7) ==1
  mkdir(fullfile(join([settings.path2output,'Clean_data'])))
end

disp(['------ Saving the clean data to the output folder ------ '])
         save(fullfile(join([settings.path2output,'Clean_data']), ...
                join(['Clean_data',settings.patient])),'cleandata','-v7.3');
disp(['------ Saving completed  ------ '])

