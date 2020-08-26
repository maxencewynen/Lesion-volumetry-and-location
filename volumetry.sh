#!/bin/bash
# Args: SUBJECT: subject id
# Re-computes the volumetry statistics for the subject based on the lesion mask


source setup_env.sh
SUBJECT=${1}

mri_convert $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/aseg_lesions.nii.gz $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/aseg_lesions.mgz
cp $SUBJECTS_DIR/sub-${SUBJECT}_MPRAGE.nii/mri/aseg_lesions.nii.gz /home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}/segmentations/sub-${SUBJECT}_aseg_lesions.nii.gz


mri_segstats --seed 1234 --seg /home/mwynen/freesurfer/subjects/sub-${SUBJECT}_MPRAGE.nii/mri/aseg_lesions.mgz \
--sum /home/mwynen/freesurfer/subjects/sub-${SUBJECT}_MPRAGE.nii/stats/aseg_lesions.stats \
--pv /home/mwynen/freesurfer/subjects/sub-${SUBJECT}_MPRAGE.nii/mri/norm.mgz --empty \
--brainmask /home/mwynen/freesurfer/subjects/sub-${SUBJECT}_MPRAGE.nii/mri/brainmask.mgz --brain-vol-from-seg --excludeid 0 \
--excl-ctxgmwm --supratent --subcortgray --in /home/mwynen/freesurfer/subjects/sub-${SUBJECT}_MPRAGE.nii/mri/norm.mgz \
--in-intensity-name norm --in-intensity-units MR --etiv --surf-wm-vol --surf-ctx-vol \
--totalgray --euler --ctab /home/mwynen/freesurfer/ASegStatsLUT.txt --subject sub-${SUBJECT}_MPRAGE.nii
