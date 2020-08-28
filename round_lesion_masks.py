#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 24 16:43:08 2020

@author: mwynen
"""

import numpy as np
import nibabel as nib 
import os

MAIN_DIR=os.environ["MAIN_DIR"]

def save_rounded_lesionmask(subject, threshold=0.5):
    from make_lesion_info_excel import load_lesion
    image,lesions = load_lesion(subject)
    lesions[lesions >= threshold] = 1
    lesions[lesions <  threshold] = 0
    
    nifti_out = nib.Nifti1Image(lesions,affine=image.affine)
    nib.save(nifti_out, MAIN_DIR+'/sub-{0}/segmentations/sub-{0}_lesions_binary.nii.gz'.format(subject))
    
    
    
if __name__ == "__main__":
    import sys
    subject = sys.argv[1]
    
    if len(sys.argv) < 2:
        threshold = float(sys.argv[2])
    else:
        threshold = 0.5
    save_rounded_lesionmask(subject,threshold)
    
    