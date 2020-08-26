#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 24 16:43:08 2020

@author: mwynen
"""

import numpy as np
import nibabel as nib 
from scipy.ndimage.measurements import label
import numpy.ma as ma
import os
import pandas as pd
from shutil import copyfile
import matplotlib.pyplot as plt
from scipy.ndimage.morphology import binary_dilation
import subprocess as sp

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
    pass
    """for subject in SUBJECTS:
        try:
            save_rounded_lesionmask(subject)
        except FileNotFoundError:
            print("Error with subject {0}, could not find the lesion mask".format(subject))"""
    
    