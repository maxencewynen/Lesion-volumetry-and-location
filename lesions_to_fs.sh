#!/bin/bash
# Args: SUBJECT: subject id
# Finds the transformation from MPRAGE normalized to the orig used for recon all

export ANTSPATH=/home/mwynen/softwares/install/bin
source setup_env.sh

SUBJECT=${1}
SUBJECT_DIR=/home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}

mri_convert $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/orig.mgz $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/orig.nii.gz

FLAIR=${SUBJECT_DIR}/anat/sub-${SUBJECT}_FLAIR_normalized.nii.gz
ORIG=$SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/orig.nii.gz

LESIONS=$SUBJECT_DIR/segmentations/sub-${SUBJECT}_lesions_binary.nii.gz

${ANTSPATH}/antsApplyTransforms \
-d 3 \
-i ${LESIONS} \
-r $ORIG \
-n GenericLabel \
-t [$SUBJECT_DIR/anat/sub-${SUBJECT}_ORIG_to_MPRAGE_normalized0GenericAffine.mat, 1] \
-o $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/lesions_fs.nii.gz

${ANTSPATH}/antsApplyTransforms \
-d 3 \
-i ${FLAIR} \
-r $ORIG \
-n GenericLabel \
-t [$SUBJECT_DIR/anat/sub-${SUBJECT}_ORIG_to_MPRAGE_normalized0GenericAffine.mat, 1] \
-o $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/FLAIR.nii.gz

mri_convert $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/lesions_fs.nii.gz $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/lesions_fs.mgz
mri_convert $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/FLAIR.nii.gz $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/FLAIR.mgz
