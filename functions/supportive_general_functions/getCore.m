function [script_path,hard_drive_path, elecs_path] = getCore
% Returns the path variables (data path, script path and electrodes path)
% based on the hostname. That is, this function automatically detects the
% computer that is currently used and adapts the paths according to this.
% defined the main path for the analysis. It is also used to call the
% function load_settings_params which contains the individual paths as well
% as settings and parameters for the individual projects
% All the paths except for the electrodes path are irrelevant of the
% project (or research center).
% Written by : Christos-Nikolaos Zacharopoulos
%              christonik@gmail.com

dbstop if error
% Make the script compatible with all OSs
if ismac == 1
    % Fosca
    script_path = fullfile(filesep,'Users','fosca','Documents','Fosca','Post_doc','Projects','Neurosyntax2');
    hard_drive_path = fullfile(filesep,'Volumes','COUCOU_CFC');
elseif ispc == 1
  % Here, distinguish between multiple Windows machines
  [~, name] = system('hostname');
  % Get the Hostname (Computer ID)
  name = strip(name);
  % Christos - Windows PC
  if strcmp(name,'DESKTOP-4ALPTJB')
    hard_drive_path = fullfile('F:', filesep);
    script_path = fullfile('C:','Projects' );
    elecs_path = fullfile(hard_drive_path,'NeuroSyntax2','Data','Houston');
    format compact
    format shortG
    % Fanis - Workstation
  elseif strcmp(name,'IS154095')
      hard_drive_path = fullfile('A:','protocols','intracranial');
      script_path = fullfile('J:','Matlab Code');
      elecs_path = fullfile(hard_drive_path,'NeuroSyntax2','Data','Houston');
  end

elseif isunix == 1
    % Here, distinguish between multiple UNIX machines
    [~, name] = system('hostname');
    % Get the Hostname (Computer ID)
    name = strip(name);
    if strcmp(name, 'is154105')
        % Christos - CEA laptop
        script_path = fullfile(filesep,'home', 'czacharo','Projects');
        hard_drive_path = fullfile(filesep,'media','czacharo','Transcend');
        elecs_path = fullfile(hard_drive_path,'NeuroSyntax2','Data','Houston');
        format compact
        format shortG
        %% ---- NeuroSpin Workstations ---- %%
    elseif strcmp(name, 'is150940') || strcmp(name, 'is153802') || strcmp(name, 'is150939')
        script_path = fullfile(filesep,'home', 'czacharo','Projects');
        hard_drive_path = fullfile(filesep, 'neurospin','unicog', 'protocols', 'intracranial');
        elecs_path = fullfile(hard_drive_path,'NeuroSyntax2','Data','Houston');
        format compact
        format shortG
        % Fernanda - linux Laptop
    end
end

% Add the path to the fieldtrip-toolbox used to load raw_data
addpath(fullfile(script_path,'Core','fieldtrip'));

