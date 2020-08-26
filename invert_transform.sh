#!/bin/bash
# Args: SUBJECT: subject id
# Inverts transform registering MPRAGE to normalized flair for the lesion mask
# found by samseg

export ANTSPATH=/home/mwynen/softwares/install/bin
source setup_env.sh

SUBJECT=${1}

MPRAGE=/home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}/anat/sub-${SUBJECT}_MPRAGE.nii.gz
LESION=/home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}/segmentations/sub-${SUBJECT}_lesions_binary.nii.gz

${ANTSPATH}/antsApplyTransforms \
-d 3 \
-i ${LESION} \
-r ${MPRAGE} \
-n Linear \
-t [ /home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}/anat/sub-${SUBJECT}_MPRAGE_to_FLAIR.mat, 1] \
-o /home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}/segmentations/sub-${SUBJECT}_lesions-in-rawavg.nii.gz
