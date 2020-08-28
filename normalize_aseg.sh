#!/bin/bash
# Args: SUBJECT: subject id
# Finds the transformation from MPRAGE normalized to the orig used for recon all

export ANTSPATH=/home/mwynen/softwares/install/bin
source setup_env.sh

SUBJECT=${1}
MAIN_DIR=/home/mwynen/scripts/MultipleSclerosis
SUBJECT_DIR=$MAIN_DIR/sub-${SUBJECT}

mri_convert $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/orig.mgz $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/orig.nii.gz

MPn=${SUBJECT_DIR}/anat/sub-${SUBJECT}_MPRAGE_normalized.nii.gz
ORIG=$SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/orig.nii.gz

ASEG=$SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/aseg.nii.gz
mri_convert $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/aseg.mgz $ASEG


/home/mwynen/softwares/ANTs/Scripts/antsRegistrationSyNQuick.sh -d 3 -n 4 -f $MPn -m $ORIG -t r -o $SUBJECT_DIR/anat/sub-${SUBJECT}_ORIG_to_MPRAGE_normalized

${ANTSPATH}/antsApplyTransforms \
-d 3 \
-i ${ASEG} \
-r $MPn \
-n GenericLabel \
-t $SUBJECT_DIR/anat/sub-${SUBJECT}_ORIG_to_MPRAGE_normalized0GenericAffine.mat \
-o /home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}/segmentations/sub-${SUBJECT}_aseg_normalized.nii.gz
