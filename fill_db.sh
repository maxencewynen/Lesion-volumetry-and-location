#!/bin/bash
# Args: SUBJECT: subject id
# Performs the pipeline filling the retrospective database
# @Pre: BIDS format with at least sub-xxx/anat/sub-xxx_MPRAGE.nii.gz and sub-xxx/anat/sub-xxx_MPRAGE.nii.gz


Help()
{
   # Display Help
   echo "Performs the pipeline filling the retrospective MS database."
   echo "Files must be organized in BIDS format."
   echo "If no option is specified, the '-all' option is assumed."
   echo
   echo "Syntax: source fill_db [-all|-p|-s|-a|-h]"
   echo "options:"
   echo "-all   Performs all the pipeline."
   echo "-p     Steps 1-2  : Processes data (MPRAGE and FLAIR) to prepare for samseg lesion localisation."
   echo "-s     Step 3     : Runs samseg."
   echo "-les   Step 4     : Makes the binarized lesion mask."
   echo "-a     Steps 5-10 : Runs analyses and makes output db files."
   echo "-h     Prints this help."
   echo
}

if [ $1 == -h ] || [ $1 == -help ] || [ $1 == --help ]; then
  Help
  return
fi

SUBJECT=${1}


#source recon-all
if [ $# == 1 ] || [ "$2" == "-all" ]
then
  source $LES_VOLOC_DIR/normalize_flair.sh $SUBJECT
  source $LES_VOLOC_DIR/register_and_normalize_MPRAGE.sh $SUBJECT

  source $LES_VOLOC_DIR/run_samseg.sh $SUBJECT

  conda activate
  python $LES_VOLOC_DIR/round_lesion_masks.py $SUBJECT
  source $LES_VOLOC_DIR/normalize_aseg.sh $SUBJECT
  source $LES_VOLOC_DIR/lesions_to_fs.sh $SUBJECT
  python $LES_VOLOC_DIR/edit_aseg.py $SUBJECT
  python $LES_VOLOC_DIR/make_lesions_xls.py $SUBJECT
  source $LES_VOLOC_DIR/volumetry.sh $SUBJECT
  python $LES_VOLOC_DIR/make_subject_xls.py $SUBJECT
fi

if [[ "$*" == *"-p"* ]]
then
  source $LES_VOLOC_DIR/normalize_flair.sh $SUBJECT
  source $LES_VOLOC_DIR/register_and_normalize_MPRAGE.sh $SUBJECT
fi

if [[ "$*" == *"-s"* ]]
then
  source $LES_VOLOC_DIR/run_samseg.sh $SUBJECT
fi

if [[ "$*" == *"-les"* ]]
then
  conda activate
  python $LES_VOLOC_DIR/round_lesion_masks.py $SUBJECT
  conda deactivate
fi

if [[ "$*" == *"-a"* ]]
then
  conda activate
  source $LES_VOLOC_DIR/normalize_aseg.sh $SUBJECT
  source $LES_VOLOC_DIR/lesions_to_fs.sh $SUBJECT
  python $LES_VOLOC_DIR/edit_aseg.py $SUBJECT
  python $LES_VOLOC_DIR/make_lesions_xls.py $SUBJECT
  source $LES_VOLOC_DIR/volumetry.sh $SUBJECT
  python $LES_VOLOC_DIR/make_subject_xls.py $SUBJECT
  conda deactivate
fi
