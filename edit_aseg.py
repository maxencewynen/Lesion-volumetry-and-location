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
