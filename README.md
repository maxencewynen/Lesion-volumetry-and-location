# Lesion-volumetry-and-location
Computes the lesion volumetry and location of a subject.

For a better understanding of the pipeline as well as the files it uses/produces, see the pipeline schema les_voloc_pipeline.png


## Pre conditions
  - First argument must be the subject id.
  - recon-all.sh must already have been launched.
  - Files must be organized in BIDS format.
  - If no option is specified, the '-all' option is assumed.
  - Run "source source setup_env.sh" before executing this script.

## USAGE:

         les_voloc $SUBJECT_ID [-all|-p|-s|-a|-h]


## Options:
  - -all   Performs all the pipeline.
  - -p     Steps 1-2  : Processes data (MPRAGE and FLAIR) to prepare for samseg lesion localisation.
  - -s     Step 3     : Runs samseg.
  - -les   Step 4     : Makes the binarized lesion mask.
  - -a     Steps 5-10 : Runs analyses and makes output db files.
  - -h     Prints this help.

## Input:
  - anat/sub-${SUBJECT_ID}\_FLAIR.nii.gz
  - anat/sub-${SUBJECT_ID}\_MPRAGE.nii.gz

## Output:
  - sub-${SUBJECT_ID}\_lesions.csv
  - sub-${SUBJECT_ID}.csv

## Steps
    1. Normalize FLAIR (<1min)
    2. Register MPRAGE to normalized FLAIR (<5min)
    3. Run samseg segmentation. Produces lesion probability mask. (<1h)
    4. Binarize the lesion probability mask up to a certain threshold (<1min)
    5. Transform the Freesurfer segmentation (product of recon-all) into the normalized space (Samseg space) (<5min)
    6. Transform the binarized lesion mask (product of samseg) into Freesurfer space (<3min)
    7. Merge the brain segmentation files with the lesion masks in both samseg and Freesurfer spaces (<2min)
    8. Lesion labelling, volumetry and location (<15min)
    9. Recompute Freesurfer volumetry based on the new segmentation file (<30min)
    10. Make subject-xxx.xls (<1min)


## Credits & contact

Maxence Wynen - UCLouvain
maxencewynen@gmail.com
2020
