#!/bin/bash
# Args: SUBJECT: subject id
# Produces the normalized MPRAGE registered to the FLAIR

Help()
{
   # Display Help
   echo "Register MPRAGE to normalized FLAIR."
   echo
   echo "Arguments:"
   echo "    Subject id"
   echo
   echo "Output:"
   echo "    sub-\${SUBJECT_ID}_MPRAGE_normalized.nii.gz ; 256x256x256, 1mm3."
   echo
   echo "USAGE: "
   echo "     source register_and_normalize_MPRAGE.sh \$SUBJECT_ID"
   echo
}

if [ $1 == -h ] || [ $1 == -help ] || [ $1 == --help ]; then
  Help
  return
fi

SUBJECT=${1}
ANAT_DIR=$MAIN_DIR/sub-${SUBJECT}/ses-01/anat
TRANSFORMATIONS=$MAIN_DIR/derivatives/transformations
FLAIR=$TRANSFORMATIONS/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_FLAIR_normalized.nii.gz
MPRAGE=$ANAT_DIR/sub-${SUBJECT}_ses-01_MPRAGE.nii.gz


$ANTs_registration -d 3 -n 4 -f $FLAIR -m $MPRAGE -t r -o $TRANSFORMATIONS/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_MPRAGE_normalized

rm $TRANSFORMATIONS/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_MPRAGE_normalizedInverseWarped.nii.gz
mv $TRANSFORMATIONS/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_MPRAGE_normalizedWarped.nii.gz $TRANSFORMATIONS/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_MPRAGE_normalized.nii.gz
#mv $ANAT_DIR/sub-${SUBJECT}_MPRAGE_normalized0GenericAffine.mat $ANAT_DIR/sub-${SUBJECT}_MPRAGE_to_FLAIR.mat
rm $TRANSFORMATIONS/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_MPRAGE_normalized0GenericAffine.mat
