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
TRANSFORMATIONS=$MAIN_DIR/derivatives/transformations
FLAIR=$TRANSFORMATIONS/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_FLAIR_normalized.nii.gz
FLAIRmgz=$TRANSFORMATIONS/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_FLAIR_normalized.mgz
#MPRAGE=$TRANSFORMATIONS/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_MPRAGE_normalized.nii.gz
#MPRAGEmgz=$TRANSFORMATIONS/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_MPRAGE_normalized.mgz



SAMSEG_OUTDIR=$MAIN_DIR/derivatives/samseg/sub-${SUBJECT}/ses-01/
#:'
# For freesurfer visualization
#mri_convert $MPRAGE $MPRAGEmgz
mri_convert $FLAIR $FLAIRmgz



fspython $SAMSEG -i $FLAIRmgz --lesion --lesion-mask-pattern 0 --threads 8 -o $SAMSEG_OUTDIR --save-posteriors
#'
cp $SAMSEG_OUTDIR/posteriors/Lesions.mgz $MAIN_DIR/derivatives/segmentations/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_lesions.mgz

mri_convert $MAIN_DIR/derivatives/segmentations/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_lesions.mgz $MAIN_DIR/derivatives/segmentations/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_lesions.nii.gz
