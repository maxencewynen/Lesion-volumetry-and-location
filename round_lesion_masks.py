#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 24 16:43:08 2020

@author: mwynen


USAGE:
    python round_lesion_masks.py sub_id [threshold]
    
    -> sub_id       : Subject id (e.g. 001)
    -> threshold    : (optional) threshold defining if a voxel should be a lesion or not
"""

import nibabel as nib 
import os

MAIN_DIR=os.environ["MAIN_DIR"]
SESSION=os.environ["SESSION"]

def save_rounded_lesionmask(subject, threshold=0.5):
    """
    Binarize the lesion probability mask with respect to a certain threshold.
    Saves the file in sub-id/segmentations/.

    Parameters
    ----------
    subject : TYPE str
        Subject id.
    threshold : TYPE float, optional
        Threshold for the binarizing of the lesion mask. The default is 0.5.

    Returns
    -------
    None.

    """
    image = nib.load(MAIN_DIR + "/derivatives/segmentations/sub-{0}/ses-{1}/sub-{0}_lesions.mgz".format(subject,SESSION))
    lesions = image.get_fdata()
    lesions[lesions >= threshold] = 1
    lesions[lesions <  threshold] = 0
    
    nifti_out = nib.Nifti1Image(lesions,affine=image.affine)
    nib.save(nifti_out, MAIN_DIR+'/derivatives/segmentations/sub-{0}/ses-{1}/sub-{0}_lesions_binary.nii.gz'.format(subject,SESSION))
    
    
    
if __name__ == "__main__":
    import sys
    subject = sys.argv[1]
    
    if len(sys.argv) < 2:
        threshold = float(sys.argv[2])
    else:
        threshold = 0.5
    save_rounded_lesionmask(subject,threshold)
    
    