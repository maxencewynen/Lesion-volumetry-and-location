#!/bin/bash
# Args: SUBJECT: subject id
# Re-computes the volumetry statistics for the subject based on the lesion mask

Help()
{
   # Display Help
   echo "Recompute Freesurfer volumetry based on the new segmentation file."
   echo
   echo "Arguments:"
   echo "    Subject id"
   echo
   echo "Output:"
   echo "    aseg_lesions.stats"
   echo
   echo "USAGE: "
   echo "     source volumetry.sh \$SUBJECT_ID"
   echo
}

if [ $1 == -h ] || [ $1 == -help ] || [ $1 == --help ]; then
  Help
  return
fi

SUBJECT=${1}

mri_convert $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/aseg_lesions.nii.gz $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/aseg_lesions.mgz
cp $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/aseg_lesions.nii.gz $MAIN_DIR/sub-${SUBJECT}/segmentations/sub-${SUBJECT}_aseg_lesions.nii.gz


mri_segstats --seed 1234 --seg $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/aseg_lesions.mgz \
--sum $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/stats/aseg_lesions.stats \
--pv $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/norm.mgz --empty \
--brainmask $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/brainmask.mgz --brain-vol-from-seg --excludeid 0 \
--excl-ctxgmwm --supratent --subcortgray --in $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/norm.mgz \
--in-intensity-name norm --in-intensity-units MR --etiv --surf-wm-vol --surf-ctx-vol \
--totalgray --euler --ctab $FREESURFER_HOME/ASegStatsLUT.txt --subject sub-${SUBJECT}_MPRAGE.nii
