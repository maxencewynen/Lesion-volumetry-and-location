#!/bin/bash

# Freesurfer environment variables
export FREESURFER_HOME=/home/mwynen/freesurfer
export TUTORIAL_DATA=/home/mwynen/tutorial_data
export SUBJECTS_DIR=$FREESURFER_HOME/subjects
source $FREESURFER_HOME/SetUpFreeSurfer.sh

# les_voloc paths
export MAIN_DIR=/home/mwynen/scripts/MultipleSclerosis # Path for database directory
export ANTSPATH=/home/mwynen/softwares/install/bin # Path for ANTs Registration
export ALL_SUBJECTS=(006 012 013 019 034 035 036 037 038 040 041 042 043 044 045 047 048 051 052 058 059 097 098) # List of all subjects
export LES_VOLOC_DIR=/home/mwynen/scripts/MS-Database-filling # Path to directory containing this script
export SAMSEG=/home/mwynen/freesurfer/python/scripts/run_samseg # run_samseg file (full path)
export ANTs_registration=/home/mwynen/softwares/ANTs/Scripts/antsRegistrationSyNQuick.sh # antsRegistrationSyNQuick.sh §full path)
export THRESHOLD=0.5 # Threshold for binarizing lesion probability mask (leave at 0.5)
#ALL_SUBJECTS=(006 010 012 013 019 023 034 035 036 037 038 039 040 041 042 043 044 045 047 048 051 052 058 059 097 098)
alias les_voloc='source $LES_VOLOC_DIR/les_voloc.sh'

echo
echo "-------- Setting up environment for les_voloc --------"
echo "FREESURFER_HOME   /home/mwynen/freesurfer"
echo "SAMSEG            $SAMSEG"
echo "MAIN_DIR          $MAIN_DIR"
echo "LES_VOLOC_DIR     $LES_VOLOC_DIR"
echo "ANTSPATH          $ANTSPATH"
echo "ANTs_registration $ANTs_registration"
echo "THRESHOLD         $THRESHOLD"
