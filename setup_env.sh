#!/bin/bash

# Freesurfer environment variables
export FREESURFER_HOME=/home/stluc/Programmes/freesurfer
export SUBJECTS_DIR=$FREESURFER_HOME/subjects
source $FREESURFER_HOME/SetUpFreeSurfer.sh

# les_voloc paths
export MAIN_DIR=/media/stluc/Elements/MS-PRL # Path for database directory
export ANTSPATH=/home/stluc/Programmes/ANTs/install/bin # Path for ANTs Registration
export ALL_SUBJECTS=(098) # List of all subjects
export LES_VOLOC_DIR=/home/stluc/Programmes/les_voloc # Path to directory containing this script
export SAMSEG=${FREESURFER_HOME}/python/scripts/run_samseg # run_samseg file (full path)
export ANTs_registration=/home/stluc/Programmes/ANTs/Scripts/antsRegistrationSyNQuick.sh # antsRegistrationSyNQuick.sh §full path)
export THRESHOLD=0.5 # Threshold for binarizing lesion probability mask (leave at 0.5)
export SESSION=01
alias les_voloc='source $LES_VOLOC_DIR/les_voloc.sh'
alias newsubj='source $LES_VOLOC_DIR/subject_folders_creator.sh'
function label {
  conda activate
  python $LES_VOLOC_DIR/label_lesion_mask.py $1 $2 $3
  conda deactivate
}
echo
echo "-------- Setting up environment for les_voloc --------"
echo "FREESURFER_HOME   $FREESURFER_HOME"
echo "SAMSEG            $SAMSEG"
echo "MAIN_DIR          $MAIN_DIR"
echo "LES_VOLOC_DIR     $LES_VOLOC_DIR"
echo "ANTSPATH          $ANTSPATH"
echo "ANTs_registration $ANTs_registration"
echo "THRESHOLD         $THRESHOLD"
