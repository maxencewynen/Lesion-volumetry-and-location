#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Aug 25 16:13:54 2020

@author: mwynen
"""


from make_lesion_info_excel import MAIN_DIR, SUBJECTS, load_lesion
import numpy as np
import nibabel as nib 
from scipy.ndimage.measurements import label
import numpy.ma as ma
import subprocess as sp

SUBJECTS_DIR = "/home/mwynen/freesurfer/subjects"

def update_aseg(subject):

    lesion_image = nib.load(MAIN_DIR + "/sub-{0}/segmentations/sub-{0}_lesions_fs_volumetry.mgz".format(subject))
    lesion_mx = lesion_image.get_fdata()
    
    
    threshold = 0.5
    lesion_mask = ma.masked_less(lesion_mx,threshold)
    
    aseg_image = nib.load(SUBJECTS_DIR + "/sub-{0}_MPRAGE.nii/mri/aseg.mgz".format(subject))
    aseg_mx = aseg_image.get_fdata()
    
    aseg_mask = ma.masked_array(aseg_mx, np.logical_not(lesion_mask.mask), fill_value=99).filled()
    
    nifti_out = nib.Nifti1Image(aseg_mask,affine=aseg_image.affine)
    nib.save(nifti_out, SUBJECTS_DIR +"/sub-{0}_MPRAGE.nii/mri/aseg_lesions.nii.gz".format(subject))   
    nib.save(nifti_out, MAIN_DIR + "/sub-{0}/segmentations/sub-{0}_aseg_lesions.nii.gz".format(subject))   

"""    sp.run(["bash", "/home/mwynen/setup_env.sh"], shell=True)
    sp.run(["mri_convert", SUBJECTS_DIR +"/sub-{0}_MPRAGE.nii/mri/aseg_lesions.nii.gz".format(subject), 
             SUBJECTS_DIR +"/sub-{0}_MPRAGE.nii/mri/aseg_lesions.mgz".format(subject)], shell=True)

    mri_segstats = "mri_segstats --seed 1234 --seg /home/mwynen/freesurfer/subjects/sub-{0}_MPRAGE.nii/mri/aseg_lesions.mgz --sum \
        /home/mwynen/freesurfer/subjects/sub-{0}_MPRAGE.nii/stats/aseg_lesions.stats --pv /home/mwynen/freesurfer/subjects/sub-{0}_MPRAGE.nii/mri/norm.mgz --empty \
            --brainmask /home/mwynen/freesurfer/subjects/sub-{0}_MPRAGE.nii/mri/brainmask.mgz --brain-vol-from-seg --excludeid 0 \
                --excl-ctxgmwm --supratent --subcortgray --in /home/mwynen/freesurfer/subjects/sub-{0}_MPRAGE.nii/mri/norm.mgz \
                    --in-intensity-name norm --in-intensity-units MR --etiv --surf-wm-vol --surf-ctx-vol \
                        --totalgray --euler --ctab /home/mwynen/freesurfer/ASegStatsLUT.txt --subject sub-{0}_MPRAGE.nii" 
    mri_segstats = mri_segstats.format(subject)
    sp.run(mri_segstats.split())"""