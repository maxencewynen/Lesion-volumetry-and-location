#!/bin/bash
# Args: SUBJECT: subject id
# Produces the normalized FLAIR

source setup_env.sh
export ANTSPATH=/home/mwynen/softwares/install/bin

SUBJECT=${1}

ANAT_DIR=/home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}/anat

rm -r $SUBJECTS_DIR/sub-${SUBJECT}_FLAIR_normalized

recon-all -motioncor -i $ANAT_DIR/sub-${SUBJECT}_FLAIR.nii.gz -subjid sub-${SUBJECT}_FLAIR_normalized

mri_convert $SUBJECTS_DIR/sub-${SUBJECT}_FLAIR_normalized/mri/orig.mgz  $ANAT_DIR/sub-${SUBJECT}_FLAIR_normalized.nii.gz
