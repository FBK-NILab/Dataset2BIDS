## Dataset2BIDS

Tool for converting DICOM folders of pre-/post- surgical longitudinal data into the  Brain Imaging Data Structure (BIDS) standard

## Usage
```
Dataset2BIDS.sh -i <input_dir> -o <output_dir> -c <config> [-e <epre>] [-p <pre>] [-s <post> ] [-l <lpost>]

Compulsory arguments:
    
	-i, --inputdir      directory of the dicoms folderts of the subjects    
	-o, --outputdir      outpu directory of the resulting BIDS style data
	-c, --config        configuration file specify the naming convention
   
Optional input:

	-p, --pre           pre surgery data unique identifier label 
	-e, --early-pre     early pre surgery unique identifier label
	-s, --early-post    early post surgery unique identifier label     
	-l, --late-post     late post surgery unique identifier label 
```

### Example of configuration file

The option ```--config_``` (or ```-c```) accepts in input a JSON (_.json_) configuration file.
Here is an example of a configuration file, where T1-w (named _T1-w_), rs-fMRI (named _task-rest_run-01_) and diffusion-weighted Imaging MRI data (named _dwi_) are considered.


```
 {
   "descriptions": [
      {
         "dataType": "anat",
         "modalityLabel": "T1w",
         "criteria": {
            "SidecarFilename": "001*"
         }
      },
      {
         "dataType": "func",
         "modalityLabel": "bold",
         "customLabels": "task-rest_run-01",
         "criteria": {
            "SidecarFilename": "002*"
         },
         "sidecarChanges": {
            "TaskName": "rest"
         }
      },      
      {
         "dataType": "dwi",
         "modalityLabel": "dwi",
         "criteria": {
            "SidecarFilename": "003*"
         }
      }
   ]
}


```


## Dependences

In order to use the tool _dcm2bids_ must be installed.

for example, you can install it via _conda_


`conda install -c conda-forge dcm2bids`

or via _pip_

`pip install dcm2bids`




