#!/bin/bash
# Args: SUBJECT: subject id
# Produces the normalized MPRAGE registered to the FLAIR

source setup_env.sh

SUBJECT=${1}

ANAT_DIR=/home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}/anat
SAMSEG_OUTDIR=/home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}/samseg_results
:'
# For freesurfer visualization
mri_convert $ANAT_DIR/sub-${SUBJECT}_MPRAGE_normalized.nii.gz $ANAT_DIR/sub-${SUBJECT}_MPRAGE_normalized.mgz
mri_convert $ANAT_DIR/sub-${SUBJECT}_FLAIR_normalized.nii.gz $ANAT_DIR/sub-${SUBJECT}_FLAIR_normalized.mgz

mkdir /home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}/samseg_results


SAMSEG=/home/mwynen/freesurfer/python/scripts/run_samseg

fspython $SAMSEG -i $ANAT_DIR/sub-${SUBJECT}_MPRAGE_normalized.mgz -i $ANAT_DIR/sub-${SUBJECT}_FLAIR_normalized.mgz --lesion --lesion-mask-pattern 0 1 --threads 4 -o $SAMSEG_OUTDIR --save-posteriors
'
cp $SAMSEG_OUTDIR/posteriors/Lesions.mgz /home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}/segmentations/sub-${SUBJECT}_lesions.mgz

mri_convert /home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}/segmentations/sub-${SUBJECT}_lesions.mgz /home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}/segmentations/sub-${SUBJECT}_lesions.nii.gz
