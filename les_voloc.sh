#!/bin/bash
# Args: SUBJECT: subject id
# Performs the pipeline filling the retrospective database
# @Pre: BIDS format with at least sub-xxx/anat/sub-xxx_MPRAGE.nii.gz and sub-xxx/anat/sub-xxx_MPRAGE.nii.gz


Help()
{
   # Display Help
   echo
   echo "Computes the lesion volumetry and location of a subject."
   echo
   echo "For a better understanding of the pipeline as well as the files it uses/produces, see the pipeline schema les_voloc_pipeline.png"
   echo
   echo
   echo "Pre conditions"
   echo "  - First argument must be the subject id."
   echo "  - recon-all.sh must already have been launched."
   echo "  - Files must be organized in BIDS format."
   echo "  - If no option is specified, the '-all' option is assumed."
   echo "  - Run \"source source setup_env.sh\" before executing this script."
   echo
   echo "USAGE:"
   echo
   echo "         les_voloc \$SUBJECT_ID [-all|-p|-s|-a|-h]"
   echo
   echo
   echo "Options:"
   echo "  -all   Performs all the pipeline."
   echo "  -p     Steps 1-2  : Processes data (MPRAGE and FLAIR) to prepare for samseg lesion localisation."
   echo "  -s     Step 3     : Runs samseg."
   echo "  -les   Step 4     : Makes the binarized lesion mask."
   echo "  -a     Steps 5-10 : Runs analyses and makes output db files."
   echo "  -h     Prints this help."
   echo
   echo "Input:"
   echo "  -> anat/sub-\${SUBJECT_ID}_FLAIR.nii.gz"
   echo "  -> anat/sub-\${SUBJECT_ID}_MPRAGE.nii.gz"
   echo
   echo "Output: "
   echo "  -> sub-\${SUBJECT_ID}_lesions.xls"
   echo "  -> sub-\${SUBJECT_ID}.xls"
   echo
   echo "Steps"
   echo "    1. Normalize FLAIR (<1min)"
   echo "    2. Register MPRAGE to normalized FLAIR (<5min)"
   echo "    3. Run samseg segmentation. Produces lesion probability mask. (<1h)"
   echo "    4. Binarize the lesion probability mask up to a certain threshold (<1min)"
   echo "    5. Transform the Freesurfer segmentation (product of recon-all) into the normalized space (Samseg space) (<5min)"
   echo "    6. Transform the binarized lesion mask (product of samseg) into Freesurfer space (<3min)"
   echo "    7. Merge the brain segmentation files with the lesion masks in both samseg and Freesurfer spaces (<2min)"
   echo "    8. Lesion labelling, volumetry and location (<15min)"
   echo "    9. Recompute Freesurfer volumetry based on the new segmentation file (<30min)"
   echo "    10. Make subject-xxx.xls (<1min)"
   echo
   echo
   echo "Credits & contact"
   echo
   echo "Maxence Wynen - UCLouvain"
   echo "maxencewynen@gmail.com"
   echo "2020"
   echo
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
  echo
  echo
  echo "+-+-+-+-+-+-+-+- Normalizing FLAIR +-+-+-+-+-+-+-+-"
  echo
  source $LES_VOLOC_DIR/normalize_flair.sh $SUBJECT

  echo
  echo
  echo "+-+-+-+-+-+-+-+- Normalizing MPRAGE +-+-+-+-+-+-+-+-"
  echo
  source $LES_VOLOC_DIR/register_and_normalize_MPRAGE.sh $SUBJECT

  echo
  echo
  echo "+-+-+-+-+-+-+-+- Running samseg +-+-+-+-+-+-+-+-"
  echo
  source $LES_VOLOC_DIR/run_samseg.sh $SUBJECT

  conda activate
  echo
  echo
  echo "+-+-+-+-+-+-+-+- Round lesion mask +-+-+-+-+-+-+-+-"
  echo
  python $LES_VOLOC_DIR/round_lesion_masks.py $SUBJECT $THRESHOLD

  echo
  echo
  echo "+-+-+-+-+-+-+-+- Normalizing aseg +-+-+-+-+-+-+-+-"
  echo
  source $LES_VOLOC_DIR/normalize_aseg.sh $SUBJECT

  echo
  echo
  echo "+-+-+-+-+-+-+-+- Lesions to FS space +-+-+-+-+-+-+-+-"
  echo
  source $LES_VOLOC_DIR/lesions_to_fs.sh $SUBJECT

  echo
  echo
  echo "+-+-+-+-+-+-+-+- Editing ASEG +-+-+-+-+-+-+-+-"
  echo
  python $LES_VOLOC_DIR/edit_aseg.py $SUBJECT

  echo
  echo
  echo "+-+-+-+-+-+-+-+- Make lesions.xls  +-+-+-+-+-+-+-+-"
  echo
  python $LES_VOLOC_DIR/make_lesions_xls.py $SUBJECT

  echo
  echo
  echo "+-+-+-+-+-+-+-+- Re-running volumetry +-+-+-+-+-+-+-+-"
  echo
  source $LES_VOLOC_DIR/volumetry.sh $SUBJECT

  echo
  echo
  echo "+-+-+-+-+-+-+-+- Make subject.xls +-+-+-+-+-+-+-+-"
  echo
  python $LES_VOLOC_DIR/make_subject_xls.py $SUBJECT
fi

if [[ "$*" == *"-p"* ]]
then
  echo
  echo
  echo "+-+-+-+-+-+-+-+- Normalizing FLAIR +-+-+-+-+-+-+-+-"
  echo
  source $LES_VOLOC_DIR/normalize_flair.sh $SUBJECT

  echo
  echo
  echo "+-+-+-+-+-+-+-+- Normalizing MPRAGE +-+-+-+-+-+-+-+-"
  echo
  source $LES_VOLOC_DIR/register_and_normalize_MPRAGE.sh $SUBJECT

fi

if [[ "$*" == *"-s"* ]]
then
  echo
  echo
  echo "+-+-+-+-+-+-+-+- Running samseg +-+-+-+-+-+-+-+-"
  echo
  source $LES_VOLOC_DIR/run_samseg.sh $SUBJECT
fi

if [[ "$*" == *"-les"* ]]
then
  echo "THRESHOLD = $THRESHOLD"
  conda activate
  echo
  echo
  echo "+-+-+-+-+-+-+-+- Round lesion mask +-+-+-+-+-+-+-+-"
  echo
  python $LES_VOLOC_DIR/round_lesion_masks.py $SUBJECT $THRESHOLD
  conda deactivate
fi

if [[ "$*" == *"-a"* ]]
then
  conda activate

    echo
    echo
    echo "+-+-+-+-+-+-+-+- Normalizing aseg +-+-+-+-+-+-+-+-"
    echo
    source $LES_VOLOC_DIR/normalize_aseg.sh $SUBJECT

    echo
    echo
    echo "+-+-+-+-+-+-+-+- Lesions to FS space +-+-+-+-+-+-+-+-"
    echo
    source $LES_VOLOC_DIR/lesions_to_fs.sh $SUBJECT

    echo
    echo
    echo "+-+-+-+-+-+-+-+- Editing ASEG +-+-+-+-+-+-+-+-"
    echo
    python $LES_VOLOC_DIR/edit_aseg.py $SUBJECT

    echo
    echo
    echo "+-+-+-+-+-+-+-+- Make lesions.xls  +-+-+-+-+-+-+-+-"
    echo
    python $LES_VOLOC_DIR/make_lesions_xls.py $SUBJECT

    echo
    echo
    echo "+-+-+-+-+-+-+-+- Re-running volumetry +-+-+-+-+-+-+-+-"
    echo
    source $LES_VOLOC_DIR/volumetry.sh $SUBJECT

    echo
    echo
    echo "+-+-+-+-+-+-+-+- Make subject.xls +-+-+-+-+-+-+-+-"
    echo
    python $LES_VOLOC_DIR/make_subject_xls.py $SUBJECT
  conda deactivate
fi
