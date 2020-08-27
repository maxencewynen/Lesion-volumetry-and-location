#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 24 16:43:08 2020

@author: mwynen
"""

import numpy as np
import nibabel as nib 

MAIN_DIR="/home/mwynen/scripts/MultipleSclerosis"
SUBJECTS = ["006", "010", "012", "013", "019", "023", "034", "035", "036", "037", "038", "039",
             "040", "041", "042", "043", "044", "045", "047", "048", "051", "052", "058", "059", "097", "098"]

def save_rounded_lesionmask(subject):
    from make_lesion_info_excel import load_lesion
    image,lesions = load_lesion(subject)
    lesions = np.round(lesions)
    
    nifti_out = nib.Nifti1Image(lesions,affine=image.affine)
    nib.save(nifti_out, MAIN_DIR+'/sub-{0}/segmentations/sub-{0}_lesions_binary.nii.gz'.format(subject))
    
    
    
if __name__ == "__main__":
    import sys
    subject = sys.argv[1]
    save_rounded_lesionmask(subject)
    
    