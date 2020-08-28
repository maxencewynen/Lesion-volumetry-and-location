#!/bin/bash
# Args: SUBJECT: subject id
# Produces the normalized MPRAGE registered to the FLAIR

Help()
{
   # Display Help
   echo "Run samseg segmentation. Produces lesion probability mask."
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


if [ $1 == -h ] || [ $1 == -help ] || [ $1 == --help ]; then
  Help
  return
fi

SUBJECT=${1}

ANAT_DIR=$MAIN_DIR/sub-${SUBJECT}/anat
SAMSEG_OUTDIR=$MAIN_DIR/sub-${SUBJECT}/samseg_results
#:'
# For freesurfer visualization
mri_convert $ANAT_DIR/sub-${SUBJECT}_MPRAGE_normalized.nii.gz $ANAT_DIR/sub-${SUBJECT}_MPRAGE_normalized.mgz
mri_convert $ANAT_DIR/sub-${SUBJECT}_FLAIR_normalized.nii.gz $ANAT_DIR/sub-${SUBJECT}_FLAIR_normalized.mgz

mkdir $MAIN_DIR/sub-${SUBJECT}/samseg_results




fspython $SAMSEG -i $ANAT_DIR/sub-${SUBJECT}_MPRAGE_normalized.mgz -i $ANAT_DIR/sub-${SUBJECT}_FLAIR_normalized.mgz --lesion --lesion-mask-pattern 0 1 --threads 4 -o $SAMSEG_OUTDIR --save-posteriors
#'
cp $SAMSEG_OUTDIR/posteriors/Lesions.mgz $MAIN_DIR/sub-${SUBJECT}/segmentations/sub-${SUBJECT}_lesions.mgz

mri_convert $MAIN_DIR/sub-${SUBJECT}/segmentations/sub-${SUBJECT}_lesions.mgz $MAIN_DIR/sub-${SUBJECT}/segmentations/sub-${SUBJECT}_lesions.nii.gz
