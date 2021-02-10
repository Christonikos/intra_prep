# intracranial_preprocessing
Christos Zacharopoulos @Unicog, NeuroSpin, Paris, France

This is a pipeline for preliminary cleaning of intracranial data. It applies the following steps to raw data (see methods for details):
1. notch filtering
2. detrending
3. downsampling.
4. automatic pathological spikes detection. 
5. Channel rejection based on deviant power spectrum.
6. pathological high frequency oscillation (HFO) detection (optional).

- The pipeline is compatible with both BlackRock and Neuralynx.
- It is applied to a single session/recording of a patient (if you need to clean data from several sessions, patients and hospitals you should therefore launch several jobs). 

## Instructions:

### Command to launch:
As an example, to execute the pipeline for session 'S01' of patient 'TS096' from 'Houston' hospital, assuming the data is in '/home/Projects/Neurosyntax' (see data structure section below) - run the following command:

* runPreprocessing('root_path', '/home/Projects/Neurosyntax', 'hospital','Houston','patients','TS096','session','S01') *

If you do not run steps that require user decision, you can launch the pipeline from the terminal (UBUNTU - this will *not* produce any visual output): 

matlab -nodisplay -nosplash -nodesktop -r " runPreprocessing('root_path', '/home/Projects/Neurosyntax', 'hospital','Houston','patients','TS096','session','S01');exit;" | tail -n +11


### Arguments:
The arguments that the main function *runPreprocessing.m* expects are:
1. root_path: string - the path to the folder up the tree of your project.
2. Hospital ID: string - hospital ID (e.g., 'UCLA', 'Houston'...), which should match the name of the data folder in your project.
3. Patient ID: string - patient ID (e.g., 'TS096', 'patient_479'..), which should match the name of the data folder in your project.
4. session: string - session name (e.g., 'S01'), which should match the name of the data subfolder in your project. 

- Arguments are case sensitive

### Data structure and organization:
Importantly, *the pipeline expect a very specific folder tree*, as examplified below:
- Level 0 (root_path): name of your project (e.g., 'Neurosyntax')
- Level 1: should contain the following three folders - '/Data', '/Output' and '/Figure' (case sensitive!).

Then, the '/Data' subfolder has hospital names as subfolder, then patients and finally sessions.
Below is an example for the required folder tree for a project called 'Neurosyntax', with data from two hospital: Houston, with two patients - TS096 (with three sessions S01, S02, S03) and TS104 (with two session S01, S02); and UCLA, with two patients - P479 (with two sessions S01 and S01) and P482 (with a single session S01):

```bash

└── Neurosyntax\n
    ├── Data\n
    │   ├── Houston\n
    │   │   ├── TS096
    │   │   │   ├── S01
    │   │   │   │   ├── GA1-STG1.ncs
    │   │   │   │   ├── GA1-STG2.ncs
    │   │   │   │   ├── GA1-STG3.ncs
    │   │   │   │   ├── GA1-STG4.ncs
    │   │   │   │   ├── GA1-STG5.ncs
    │   │   │   │   ├── GA1-STG6.ncs
    │   │   │   │   ├── GA1-STG7.ncs
    │   │   │   │   └── GA1-STG8.ncs
    │   │   │   ├── S02
    │   │   │   └── S03
    │   │   └── TS104
    │   │       ├── S01
    │   │       └── S02
    │   └── UCLA
    │       ├── P479
    │       │   ├── S01
    │       │   └── S02
    │       └── P482
    │           └── S01
    ├── Figures
    └── Output
```
- The raw blackrock (*.nsX) or Neuralynx (*.ncs) files should be in the session subfolders, as examplified for Houston/TS096/S01 sub-folder in the above tree.
- Any deviation from this data organization structure would result in errors!

### Parameters of clearning and filtering
All parameters of the cleaning and filtering procedures can be controlled from:
*functions/common_generic_functions/load_settings_params.m*

For example, the frequency of the line can be changes in the following line code of load_settings_params():
params.first_harmonic{1} = 60;

### Preferences
All preferences regarding which steps of the pipeline to execute, whether to generate plots, etc., can be controlled from:
*functions/common_generic_functions/load_settings_params.m*

A list of flags (true/false) 
For example, to skip down-sampling of the raw data, set:
preferences.down_sample_data = false;

## Methods:
This section elaborates about each of the pre-processing stages.

#### 1. Notch filtering
Notch filtering is applied for the line noise frequency and the first 2 harmonics.
The frequencies of choise are defined as parameters in
 *functions/common_generic_functions/load_setting_params.m*

#### 2. Linear detrending
The linear trend is removed from the non-rejected channels.

#### 3. Pathological spikes removal



#### 4. Re-referencing

