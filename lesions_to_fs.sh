#!/bin/bash
# Args: SUBJECT: subject id
# Finds the transformation from MPRAGE normalized to the orig used for recon all

Help()
{
   # Display Help
   echo "Transform the binarized lesion mask (product of samseg) into Freesurfer space."
   echo
   echo "Arguments:"
   echo "    Subject id"
   echo
   echo "Output:"
   echo "    sub-\${SUBJECT_ID}_lesions_fs.mgz ; 256x256x256, 1mm3."
   echo
   echo "USAGE: "
   echo "     source lesions_to_fs.sh \$SUBJECT_ID"
   echo
}

if [ $1 == -h ] || [ $1 == -help ] || [ $1 == --help ]; then
  Help
  return
fi


SUBJECT=${1}
SUBJECT_DIR=$MAIN_DIR/sub-${SUBJECT}

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
