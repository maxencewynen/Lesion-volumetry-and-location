#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 12 15:28:56 2020

@author: mwynen
"""


import numpy as np
import nibabel as nib 
from scipy.ndimage.measurements import label
import os

MAIN_DIR=os.environ["MAIN_DIR"]
SESSION=os.environ['SESSION']

def label_lesions(subject, segmentation_filename, output_filename):
    lesion_mask_img = nib.load(MAIN_DIR + "/derivatives/segmentations/sub-{0}/ses-{1}/".format(subject, SESSION) + segmentation_filename)
    lesion_mask = lesion_mask_img.get_fdata()
    
    structure = np.ones((3, 3, 3))
    labeled_lesions, nlesions = label(lesion_mask,structure)
    
    nifti_out = nib.Nifti1Image(labeled_lesions,affine=lesion_mask_img.affine)
    nib.save(nifti_out, MAIN_DIR+'/derivatives/segmentations/sub-{0}/ses-{1}/'.format(subject,SESSION) + output_filename)
    
    



if __name__ == "__main__":
    import sys
    
    if len(sys.argv)<4:
        print("Example: label 114 sub-114_lesions-edited_star.nii.gz sub-114_lesions_labels_star.nii.gz")
    else:
        subject = sys.argv[1]
        input_filename = sys.argv[2]
        output_filename = sys.argv[3]
        label_lesions(subject, input_filename, output_filename)
    
