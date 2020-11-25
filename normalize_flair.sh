#!/bin/bash
# Args: SUBJECT: subject id
# Produces the normalized FLAIR

Help()
{
   # Display Help
   echo "Produces the normalized FLAIR."
   echo
   echo "Arguments:"
   echo "    Subject id"
   echo
   echo "Output:"
   echo "    sub-\${SUBJECT_ID}_FLAIR_normalized.nii.gz ; 256x256x256, 1mm3."
   echo
   echo "USAGE: "
   echo "     source normalize_flair.sh \$SUBJECT_ID"
   echo
}

if [ $1 == -h ] || [ $1 == -help ] || [ $1 == --help ]; then
  Help
  return
fi



SUBJECT=${1}

ANAT_DIR=$MAIN_DIR/sub-${SUBJECT}/ses-${SESSION}/anat
FLAIR=$ANAT_DIR/sub-${SUBJECT}_ses-${SESSION}_FLAIR.nii.gz
MPRAGE=$ANAT_DIR/sub-${SUBJECT}_ses-${SESSION}_MPRAGE.nii.gz

TRANSFORMATIONS=$MAIN_DIR/derivatives/transformations

rm -r $SUBJECTS_DIR/sub-${SUBJECT}_FLAIR_normalized

recon-all -motioncor -i $FLAIR -subjid sub-${SUBJECT}_FLAIR_normalized

mri_convert $SUBJECTS_DIR/sub-${SUBJECT}_FLAIR_normalized/mri/orig.mgz  $TRANSFORMATIONS/sub-${SUBJECT}/ses-${SESSION}/sub-${SUBJECT}_FLAIR_normalized.nii.gz
