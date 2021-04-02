

SUBJECT=$1
FLAIRstar1=$MAIN_DIR/sub-$SUBJECT/ses-01/anat/sub-${SUBJECT}_ses-01_acq-star_FLAIR.nii.gz
FLAIRstar2=$MAIN_DIR/sub-$SUBJECT/ses-02/anat/sub-${SUBJECT}_ses-02_acq-star_FLAIR.nii.gz

FLAIR1=$MAIN_DIR/sub-$SUBJECT/ses-01/anat/sub-${SUBJECT}_ses-01_FLAIR.nii.gz
FLAIR2=$MAIN_DIR/sub-$SUBJECT/ses-02/anat/sub-${SUBJECT}_ses-02_FLAIR.nii.gz

PHASE2=$MAIN_DIR/sub-$SUBJECT/ses-02/anat/sub-${SUBJECT}_ses-02_acq-phase_T2star.nii.gz

RIM1=$MAIN_DIR/derivatives/expert_annotations/sub-${SUBJECT}/ses-01/sub-${SUBJECT}_ses-01_expertsannotations.nii.gz
RIM2=$MAIN_DIR/derivatives/expert_annotations/sub-${SUBJECT}/ses-02/sub-${SUBJECT}_ses-02_expertsannotations.nii.gz


# Register FLAIR1 to FLAIRstar1
$ANTs_registration -d 3 -n 4 -f $FLAIRstar1 \
  -m $FLAIR1 \
  -t r \
  -o $MAIN_DIR/sub-$SUBJECT/ses-01/anat/sub-${SUBJECT}_ses-01_FLAIR_regstar

mv $MAIN_DIR/sub-$SUBJECT/ses-01/anat/sub-${SUBJECT}_ses-01_FLAIR_regstarWarped.nii.gz $MAIN_DIR/sub-$SUBJECT/ses-01/anat/sub-${SUBJECT}_ses-01_FLAIR_regstar.nii.gz
rm $MAIN_DIR/sub-$SUBJECT/ses-01/anat/sub-${SUBJECT}_ses-01_FLAIR_regstarInverseWarped.nii.gz
rm $MAIN_DIR/sub-$SUBJECT/ses-01/anat/sub-${SUBJECT}_ses-01_FLAIR_regstar0GenericAffine.mat


FLAIR1=$MAIN_DIR/sub-$SUBJECT/ses-01/anat/sub-${SUBJECT}_ses-01_FLAIR_regstar.nii.gz


# Register FLAIR2 to FLAIR1
$ANTs_registration -d 3 -n 4 -f $FLAIR1 \
  -m $FLAIR2 \
  -t r \
  -o $MAIN_DIR/sub-$SUBJECT/ses-02/anat/sub-${SUBJECT}_ses-02_FLAIR_reg-ses01

mv $MAIN_DIR/sub-$SUBJECT/ses-02/anat/sub-${SUBJECT}_ses-02_FLAIR_reg-ses01Warped.nii.gz $MAIN_DIR/sub-$SUBJECT/ses-02/anat/sub-${SUBJECT}_ses-02_FLAIR_reg-ses01.nii.gz
rm $MAIN_DIR/sub-$SUBJECT/ses-02/anat/sub-${SUBJECT}_ses-02_FLAIR_reg-ses01InverseWarped.nii.gz
rm $MAIN_DIR/sub-$SUBJECT/ses-02/anat/sub-${SUBJECT}_ses-02_FLAIR_reg-ses010GenericAffine.mat


# Register FLAIRstar2 to FLAIRstar1
$ANTs_registration -d 3 -n 4 -f $FLAIRstar1 \
  -m $FLAIRstar2 \
  -t r \
  -o $MAIN_DIR/sub-$SUBJECT/ses-02/anat/sub-${SUBJECT}_ses-02_acq-star_FLAIR_reg-ses01


# Register RIM2 to flairstar1
${ANTSPATH}/antsApplyTransforms \
  -d 3 \
  -i $RIM2 \
  -r $FLAIRstar1 \
  -t $MAIN_DIR/sub-$SUBJECT/ses-02/anat/sub-${SUBJECT}_ses-02_acq-star_FLAIR_reg-ses010GenericAffine.mat \
  -n GenericLabel \
  -o $MAIN_DIR/derivatives/expert_annotations/sub-${SUBJECT}/ses-02/sub-${SUBJECT}_ses-02_expertsannotations_reg-ses01.nii.gz

# Register phase2 to flairstar1
${ANTSPATH}/antsApplyTransforms \
  -d 3 \
  -i $PHASE2 \
  -r $FLAIRstar1 \
  -t $MAIN_DIR/sub-$SUBJECT/ses-02/anat/sub-${SUBJECT}_ses-02_acq-star_FLAIR_reg-ses010GenericAffine.mat \
  -n nearestNeighbor \
  -o $MAIN_DIR/sub-$SUBJECT/ses-02/anat/sub-${SUBJECT}_ses-02_acq-phase_T2star_reg-ses01.nii.gz


mv $MAIN_DIR/sub-$SUBJECT/ses-02/anat/sub-${SUBJECT}_ses-02_acq-star_FLAIR_reg-ses01Warped.nii.gz $MAIN_DIR/sub-$SUBJECT/ses-02/anat/sub-${SUBJECT}_ses-02_acq-star_FLAIR_reg-ses01.nii.gz
rm $MAIN_DIR/sub-$SUBJECT/ses-02/anat/sub-${SUBJECT}_ses-02_acq-star_FLAIR_reg-ses01InverseWarped.nii.gz
rm $MAIN_DIR/sub-$SUBJECT/ses-02/anat/sub-${SUBJECT}_ses-02_acq-star_FLAIR_reg-ses010GenericAffine.mat
