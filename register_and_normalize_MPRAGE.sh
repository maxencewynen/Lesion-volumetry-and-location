#!/bin/bash
# Args: SUBJECT: subject id
# Produces the normalized MPRAGE registered to the FLAIR

export ANTSPATH=/home/mwynen/softwares/install/bin
source setup_env.sh

SUBJECT=${1}

ANAT_DIR=/home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}/anat

FLAIR=$ANAT_DIR/sub-${SUBJECT}_FLAIR_normalized.nii.gz
MPRAGE=$ANAT_DIR/sub-${SUBJECT}_MPRAGE.nii.gz

/home/mwynen/softwares/ANTs/Scripts/antsRegistrationSyNQuick.sh -d 3 -n 4 -f $FLAIR -m $MPRAGE -t r -o $ANAT_DIR/sub-${SUBJECT}_MPRAGE_normalized

rm $ANAT_DIR/sub-${SUBJECT}_MPRAGE_normalizedInverseWarped.nii.gz
mv $ANAT_DIR/sub-${SUBJECT}_MPRAGE_normalizedWarped.nii.gz $ANAT_DIR/sub-${SUBJECT}_MPRAGE_normalized.nii.gz
#mv $ANAT_DIR/sub-${SUBJECT}_MPRAGE_normalized0GenericAffine.mat $ANAT_DIR/sub-${SUBJECT}_MPRAGE_to_FLAIR.mat
rm $ANAT_DIR/sub-${SUBJECT}_MPRAGE_normalized0GenericAffine.mat
