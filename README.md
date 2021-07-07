#Dataset2BIDS

Tool for converting DICOM folders of pre-/post- surgical data into a standard Brain Imaging Data Structure (BIDS) format dataset

#Usage

Dataset2BIDS.sh -i <input_dir> -o <output_dir> -c <config> [-e <epre>] [-p <pre>] [-s <post> ] [-l <lpost>]

Main arguments:
    
	-i, --inputdir      directory of the dicoms folderts of the subjects    
	-o, --outpudir      outpu directory of the resulting BIDS style data
	-c, --config 		configurator file specify the naming convention
   
Optional input:

	-p, --pre           pre surgery data unique identifier label 
	-e, --early-pre     early pre surgery unique identifier label
	-s, --early-post    early post surgery unique identifier label     
	-l, --late-post     late post surgery unique identifier label 

#Dependences

In order to use the tool _dcm2bids_ must be installed.

for example, you can install it via _conda_


`conda install -c conda-forge dcm2bids`

or via _pip_

`pip install dcm2bids`




