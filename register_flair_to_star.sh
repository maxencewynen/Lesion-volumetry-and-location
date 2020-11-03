#!/bin/bash
# Args: SUBJECT: subject id
# Produces the normalized MPRAGE registered to the FLAIR

Help()
{
   # Display Help
   echo "Registers the FLAIR and binary lesion mask to the EPI (T2* and PHASE)"
   echo
   echo "Arguments:"
   echo "    Subject id"
   echo
   echo "Output:"
   echo "    sub-\${SUBJECT_ID}_lesions.nii.gz ; 256x256x256, 1mm3."
   echo
   echo "USAGE: "
   echo "     source run_samseg.sh \$SUBJECT_ID"
   echo
}


SUBJECT=$1
$ANTs_registration -d 3 -n 4 -f $MAIN_DIR/sub-${SUBJECT}/ses-01/anat/sub-${SUBJECT}_ses-01_acq-mag_T2star.nii.gz -m $MAIN_DIR/derivatives/transformations/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_FLAIR_normalized.nii.gz -t r -o $MAIN_DIR/derivatives/transformations/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_FLAIR_normalized_star

${ANTSPATH}/antsApplyTransforms \
  -d 3 \
  -i $MAIN_DIR/derivatives/segmentations/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_lesions_binary.nii.gz \
  -r $MAIN_DIR/sub-${SUBJECT}/ses-01/anat/sub-${SUBJECT}_ses-01_acq-mag_T2star.nii.gz \
  -t $MAIN_DIR/derivatives/transformations/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_FLAIR_normalized_star0GenericAffine.mat \
  -n GenericLabel \
  -o $MAIN_DIR/derivatives/segmentations/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_lesions_binary_star.nii.gz


mv $MAIN_DIR/derivatives/transformations/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_FLAIR_normalized_starWarped.nii.gz $MAIN_DIR/derivatives/transformations/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_FLAIR_normalized_star.nii.gz
rm $MAIN_DIR/derivatives/transformations/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_FLAIR_normalized_star0GenericAffine.mat
rm $MAIN_DIR/derivatives/transformations/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_FLAIR_normalized_starInverseWarped.nii.gz
