# intracranial_preprocessing

This is a pre-processing pipeline for intracranial data. It gets as input a raw recording file, either from BlackRock or Neuralynx, and runs the following steps (see methods for details):
1. notch filtering
2. detrending
3. downsampling to 1KHz.
4. automatic pathological spikes detection 
5. pathological high frequency oscillation detection (optional)

## Instructions:

### Arguments:
The main script to run is *runPreprocessing.m*, together with additional arguments:
1. Hospital ID
2. Patient ID
3. rawfile name

- arguments are case sensitive

### Example:
To execute the pipeline for patient 'TS096' from 'Houston' hospital, run the following command:

* runPreprocessing('hospital',{'Houston'},'patients',{'TS096'},'rawfilename','TS096_NeuroSyntax2_sEEG_files_a/20170606-111436-001.ns3') *

To do so from the command line (UBUNTU) : 

matlab -nodisplay -nosplash -nodesktop -r " runPreprocessing('hospital',{'Houston'},'patients',{'TS096'},'rawfilename','TS096_NeuroSyntax2_sEEG_files_a/20170606-111436-001.ns3');exit;" | tail -n +11

Be aware that this option will not produce any visual output.

### Default values
For the optional arguments, default values can be provided or modified in *functions/common_generic_functions/load_setting_params.m*

As an example : 

runPreprocessing('hospital',{'Houston'},'patients',{'TS096'},'medianthreshold',5,'vizualization', true, 'hfo_detection', false)

### Paths:
the paths are automatically detected, assuming the following folder structure:

DATA, OUTPUT, FIGURES

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

