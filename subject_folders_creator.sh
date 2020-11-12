#!/bin/bash
# Args: SUBJECT: subject id
# Produces the normalized MPRAGE registered to the FLAIR

Help()
{
   # Display Help
   echo "Makes all necessary subfolders for a subject with a given ID according to the Brain Imaging Data Structure"
   echo
   echo "Arguments:"
   echo "    Subject id"
   echo
   echo "USAGE: "
   echo "     source subjec_folders_creator.sh \$SUBJECT_ID"
   echo
}


SUBJECT=$1
SESSION="01"
MAIN=$MAIN_DIR

mkdir $MAIN/sub-${SUBJECT}
mkdir $MAIN/sub-${SUBJECT}/ses-${SESSION}
mkdir $MAIN/sub-${SUBJECT}/ses-${SESSION}/anat
mkdir $MAIN/derivatives/samseg/sub-${SUBJECT}
mkdir $MAIN/derivatives/samseg/sub-${SUBJECT}/ses-${SESSION}
mkdir $MAIN/derivatives/segmentations/sub-${SUBJECT}
mkdir $MAIN/derivatives/segmentations/sub-${SUBJECT}/ses-${SESSION}
mkdir $MAIN/derivatives/stats/sub-${SUBJECT}
mkdir $MAIN/derivatives/stats/sub-${SUBJECT}/ses-${SESSION}
mkdir $MAIN/derivatives/transformations/sub-${SUBJECT}
mkdir $MAIN/derivatives/transformations/sub-${SUBJECT}/ses-${SESSION}
