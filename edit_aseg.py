#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Aug 25 16:13:54 2020

@author: mwynen
"""

import numpy as np
import nibabel as nib 
import numpy.ma as ma
import os

SUBJECTS_DIR = os.environ["SUBJECTS_DIR"]
MAIN_DIR = os.environ["MAIN_DIR"]

def update_aseg_norm(subject):

    lesion_image = nib.load(MAIN_DIR + "/sub-{0}/segmentations/sub-{0}_lesions_binary.nii.gz".format(subject))
    lesion_mx = lesion_image.get_fdata()
    
    
    lesion_mask = ma.masked_not_equal(lesion_mx,1)
    
    aseg_image = nib.load(MAIN_DIR + "/sub-{0}/segmentations/sub-{0}_aseg_normalized.nii.gz".format(subject))
    aseg_mx = aseg_image.get_fdata()
    
    aseg_mask = ma.masked_array(aseg_mx, np.logical_not(lesion_mask.mask), fill_value=99).filled()
    
    nifti_out = nib.Nifti1Image(aseg_mask,affine=aseg_image.affine)
    nib.save(nifti_out, MAIN_DIR + "/sub-{0}/segmentations/sub-{0}_aseg_lesions.nii.gz".format(subject))   


def update_aseg_fs(subject):

    lesion_image = nib.load(SUBJECTS_DIR + "/sub-{0}_MPRAGE.nii/mri/lesions_fs.mgz".format(subject))
    lesion_mx = lesion_image.get_fdata()
    
    
    lesion_mask = ma.masked_not_equal(lesion_mx,1)
    
    aseg_image = nib.load(SUBJECTS_DIR + "/sub-{0}_MPRAGE.nii/mri/aseg.mgz".format(subject))
    aseg_mx = aseg_image.get_fdata()
    
    aseg_mask = ma.masked_array(aseg_mx, np.logical_not(lesion_mask.mask), fill_value=99).filled()
    
    nifti_out = nib.Nifti1Image(aseg_mask,affine=aseg_image.affine)
    nib.save(nifti_out, SUBJECTS_DIR +"/sub-{0}_MPRAGE.nii/mri/aseg_lesions.nii.gz".format(subject))   
    
    
def update_aseg(subject):
    update_aseg_norm(subject)
    update_aseg_fs(subject)
    
    
if __name__ == "__main__":
    import sys
    subject = sys.argv[1]
    update_aseg(subject)
    
    
    
    
    