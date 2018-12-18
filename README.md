# intracranial_preprocessing

This is a pre-processing pipeline for intracranial data. It gets as input a raw recording file, either from BlackRock or Neuralynx, and runs the following steps (see methods for details):
1. notch filtering
2. detrending
3. downsampling to 1KHz.
4. automatic pathological spikes detection 

## Instructions:

### Arguments:
The main script to run is *runPreprocessing.m*, together with additional arguments:
1. Hospital ID
2. Patient ID
3. rawfile name

- arguemnts are case sensitive

### Default values
For the optional arguments, default values can be provided or modified in *functions/common_generic_functions/load_setting_params.m*




### Paths:
the paths are automatically detected, assuming the following folder structure:

### Example:
To execute the pipeline for patient 'TS096' from 'Houston' hospital, run the following command:
* matlab -nodisplay runPreprocessing.m Houston *



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

