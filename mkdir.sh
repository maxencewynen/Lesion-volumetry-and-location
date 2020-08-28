#!/bin/bash
# Makes all directories needed for the database filling

Help()
{
   # Display Help
   echo "Makes all directories needed for the database filling."
   echo "Uses BIDS format."
   echo
   echo "Syntax: source mkdir.sh \$SUBJECT_ID"
   echo
}

if [ $1 == -h ] || [ $1 == -help ] || [ $1 == --help ]; then
  Help
  return
fi


SUBJECT=${1}

mkdir $MAIN_DIR/sub-${SUBJECT}
mkdir $MAIN_DIR/sub-${SUBJECT}/anat
mkdir $MAIN_DIR/sub-${SUBJECT}/segmentations
mkdir $MAIN_DIR/sub-${SUBJECT}/stats
mkdir $MAIN_DIR/sub-${SUBJECT}/samseg_results
