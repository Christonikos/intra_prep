# intracranial_preprocessing

This is a pre-processing pipeline for intracranial data. It gets as input a raw recording file, either from BlackRock or Neuralynx, and run the following steps (see methods for details):
1. notch filtering
2. detrending
3. automatic pathological spikes detection 
4. (optional) re-referencing


## Instructions:

### Arguments:
The main script to run is *runPreprocessing.m*, together with additional arguments:
1. Hospital ID
2. Patient ID
3.

- arguemnts are case sensitive

### Default values
For the optional arguments, default values can be provided or modified in *functions/common_generic_functions/load_setting_params.m*
---give an example from this function ---

### Paths:
the paths are automatically detected, assuming the following folder structure:

### Example:
To execute the pipeline for patient 'TS096' from 'Houston' hospital, run the following command:
* matlab -nodisplay runPreprocessing.m Houston *



## Methods:
This section elaborates about each of the pre-processing stages.

#### 1. Notch filtering
Notch filtering is applied for .... [50Hz, 100Hz, ...]

#### 2. Linear detrending
...

#### 3. Pathological spikes removal
...


#### 4. Re-referencing

