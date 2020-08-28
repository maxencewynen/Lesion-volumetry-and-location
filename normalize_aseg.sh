#!/bin/bash
# Args: SUBJECT: subject id
# Finds the transformation from MPRAGE normalized to the orig used for recon all


Help()
{
   # Display Help
   echo "Transform the Freesurfer segmentation (product of recon-all) into the normalized space (Samseg space)"
   echo
   echo "Arguments:"
   echo "    Subject id"
   echo
   echo "Output:"
   echo "    sub-\${SUBJECT_ID}_aseg_normalized.nii.gz ; 256x256x256, 1mm3."
   echo "    sub-\${SUBJECT_ID}_ORIG_to_MPRAGE_normalized0GenericAffine.mat"
   echo
   echo "USAGE: "
   echo "     source normalize_aseg.sh \$SUBJECT_ID"
   echo
}

if [ $1 == -h ] || [ $1 == -help ] || [ $1 == --help ]; then
  Help
  return
fi

SUBJECT=${1}
SUBJECT_DIR=$MAIN_DIR/sub-${SUBJECT}

mri_convert $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/orig.mgz $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/orig.nii.gz

MPn=${SUBJECT_DIR}/anat/sub-${SUBJECT}_MPRAGE_normalized.nii.gz
ORIG=$SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/orig.nii.gz

ASEG=$SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/aseg.nii.gz
mri_convert $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/aseg.mgz $ASEG


$ANTs_registration -d 3 -n 4 -f $MPn -m $ORIG -t r -o $SUBJECT_DIR/anat/sub-${SUBJECT}_ORIG_to_MPRAGE_normalized

${ANTSPATH}/antsApplyTransforms \
-d 3 \
-i ${ASEG} \
-r $MPn \
-n GenericLabel \
-t $SUBJECT_DIR/anat/sub-${SUBJECT}_ORIG_to_MPRAGE_normalized0GenericAffine.mat \
-o $MAIN_DIR/sub-${SUBJECT}/segmentations/sub-${SUBJECT}_aseg_normalized.nii.gz
