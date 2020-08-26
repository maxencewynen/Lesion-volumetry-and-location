#!/bin/bash
# Makes all directory needed for the database filling
SUBJECT=${1}

mkdir /home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}
mkdir /home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}/anat
mkdir /home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}/segmentations
mkdir /home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}/stats
mkdir /home/mwynen/scripts/MultipleSclerosis/sub-${SUBJECT}/samseg_results
