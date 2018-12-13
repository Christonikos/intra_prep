function [labels, gyri, coords, TTN27, electrodes] = returnLabels(settings, P, hopID, elecs_path)
%% This function is used to return the names of the electrodes and the gyri that correspond to those labels.
switch hopID
  case 'Houston'
    % Load the .mat file that contains the information on the electrodes
    % if is
    load(fullfile(elecs_path,'elecs4stan_v4'));
    % Loop through the patients list and load the labels corresponding to
    % the current patient
    % patient TS107 has a different entry in the elecs struct
    if  strcmp(settings.patient, 'TS107') == 1
      settings.patient = 'TS107B';
      for patid = 1:size(elecs,1)
        if strcmp(settings.patient, elecs{patid}.patient) == 1
          % The number of channels for this patient does not correspond
          % to the localization file - so we have to manually pad to
          % copansate for that.
          [elecs{patid}.names(end:257)] = {'Not assigned'};
          labels = elecs{patid}.names;
          coords = elecs{patid}.coords;
          if strcmp(labels, 'MARKER')
            labels{strcmp(labels, 'MARKER')} = [];
          end
          [elecs{patid}.gyri(end:257)] = {'Not assigned'};
          gyri  = elecs{patid}.gyri;
        end
      end
      settings.patient = 'TS107';
    else
      for patid = 1:size(elecs,1)
        if strcmp(settings.patient, elecs{patid}.patient) == 1
          electrodes = elecs{patid};
          labels = elecs{patid}.names;
          gyri  = elecs{patid}.gyri;
          coords = elecs{patid}.coords;
        end
      end
    end
end
