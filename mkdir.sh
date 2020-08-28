#!/bin/bash
# Makes all directory needed for the database filling
SUBJECT=${1}

mkdir $MAIN_DIR/sub-${SUBJECT}
mkdir $MAIN_DIR/sub-${SUBJECT}/anat
mkdir $MAIN_DIR/sub-${SUBJECT}/segmentations
mkdir $MAIN_DIR/sub-${SUBJECT}/stats
mkdir $MAIN_DIR/sub-${SUBJECT}/samseg_results
