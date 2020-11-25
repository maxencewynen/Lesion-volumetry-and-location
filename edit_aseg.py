#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Aug 25 16:13:54 2020

@author: mwynen

USAGE:
    python edit_aseg.py sub_id
    
    -> sub_id   : Subject id (e.g. 001)
"""

import numpy as np
import nibabel as nib 
import numpy.ma as ma
import os

SUBJECTS_DIR = os.environ["SUBJECTS_DIR"]
MAIN_DIR = os.environ["MAIN_DIR"]
SESSION = os.environ["SESSION"]

def update_aseg_norm(subject):
    """
    Merge normalized Freesurfer brain segmentation with the lesion segmentation 
    performed by samseg. 

    Parameters
    ----------
    subject : TYPE str
        Subject id.

    Returns
    -------
    None.

    """
    # Load lesion mask
    lesion_image = nib.load(MAIN_DIR+'/derivatives/segmentations/sub-{0}/ses-{1}/sub-{0}_lesions_binary.nii.gz'.format(subject,SESSION))
    lesion_mx = lesion_image.get_fdata()
    
    lesion_mask = ma.masked_not_equal(lesion_mx,1)
    
    # Load Freesurfer segmentation mask (aseg)
    aseg_image = nib.load(MAIN_DIR + "/derivatives/segmentations/sub-{0}/ses-{1}/sub-{0}_aseg_normalized.nii.gz".format(subject,SESSION))
    aseg_mx = aseg_image.get_fdata()
    
    # Set all voxels of aseg marked as lesion in the lesion mask to 99 (Freesurfer lesion id)
    aseg_mask = ma.masked_array(aseg_mx, np.logical_not(lesion_mask.mask), fill_value=99).filled()
    
    # Save resulting matrix to nifti file
    nifti_out = nib.Nifti1Image(aseg_mask,affine=aseg_image.affine)
    nib.save(nifti_out, MAIN_DIR + "/derivatives/segmentations/sub-{0}/ses-{1}/sub-{0}_aseg_lesions.nii.gz".format(subject,SESSION))   


def update_aseg_fs(subject):
    """
    Merge Freesurfer brain segmentation with the lesion segmentation 
    performed by samseg in Freesurfer's space.

    Parameters
    ----------
    subject : TYPE str
        Subject id.

    Returns
    -------
    None.

    """
    # Load lesion mask
    lesion_image = nib.load(SUBJECTS_DIR + "/sub-{0}_MPRAGE.nii/mri/lesions_fs.mgz".format(subject))
    lesion_mx = lesion_image.get_fdata()
    
    lesion_mask = ma.masked_not_equal(lesion_mx,1)
    
    # Load Freesurfer segmentation mask (aseg)
    aseg_image = nib.load(SUBJECTS_DIR + "/sub-{0}_MPRAGE.nii/mri/aseg.mgz".format(subject))
    aseg_mx = aseg_image.get_fdata()
    
    # Set all voxels of aseg marked as lesion in the lesion mask to 99 (Freesurfer lesion id)
    aseg_mask = ma.masked_array(aseg_mx, np.logical_not(lesion_mask.mask), fill_value=99).filled()
    
    # Save resulting matrix to nifti file
    nifti_out = nib.Nifti1Image(aseg_mask,affine=aseg_image.affine)
    nib.save(nifti_out, SUBJECTS_DIR +"/sub-{0}_MPRAGE.nii/mri/aseg_lesions.nii.gz".format(subject))   
    
    
def update_aseg(subject):
    """
    Updates aseg in Freesurfer space as well as in Samseg space according to the lesion mask
    created by samseg and then binarized.

    Parameters
    ----------
    subject : TYPE str
        Subject id.

    Returns
    -------
    None.

    """
    update_aseg_norm(subject)
    update_aseg_fs(subject)
    
    
if __name__ == "__main__":
    import sys
    subject = sys.argv[1]
    update_aseg(subject)
    
    
    
    
    