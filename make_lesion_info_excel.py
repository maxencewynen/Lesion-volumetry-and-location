#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Aug 21 14:25:25 2020

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

def load_lesion(subject):
    """
    Loads the lesion image and matrix

    Parameters
    ----------
    subject : TYPE <str>
        Subject id.

    Returns
    -------
    image : TYPE <nibabel.freesurfer.mghformat.MGHImage>
        Image of the lesion mask.
    TYPE 3D numpy.ndarray
        Matrix of lesion probabilities.

    """
    image = nib.load("{0}/sub-{1}/segmentations/sub-{1}_lesions.mgz".format(MAIN_DIR,subject))
    return image, image.get_fdata()

def make_lesion_info_excel(subject, minimum_lesion_size=5):
    image, lesions = load_lesion(subject) 
    lesions = np.round(lesions)
    
    # Get number of components (thus number of lesions)
    structure = np.ones((3, 3, 3))
    labeled_lesions, nlesions = label(lesions,structure)
    
    print("Number of lesions before discarding: {0}".format(nlesions))
    
    id_lesions_dic = {}
                
    for lesion_id in range(1,nlesions+1):
        lesions_mskd = ma.masked_where(labeled_lesions != lesion_id, labeled_lesions)
        lesion_voxel_volume_count = lesions_mskd.sum() // lesion_id
        
        if lesion_voxel_volume_count > minimum_lesion_size:
            id_lesions_dic[lesion_id] = [lesion_voxel_volume_count]
            print("Lesion {0}: {1} voxels".format(lesion_id, lesion_voxel_volume_count))
        else: 
            labeled_lesions[labeled_lesions == lesion_id] = 0
            print("Lesion {0}: {1} voxels ==> Discarded (too small)".format(lesion_id, lesion_voxel_volume_count))
    

    
    try:
        os.mkdir(MAIN_DIR + "/sub-{0}/stats".format(subject))
    except:
        pass
    
    columns = ["Voxel Volume"]
    
    df = pd.DataFrame.from_dict(id_lesions_dic, orient='index', columns=columns)
    df.to_excel(MAIN_DIR + "/sub-{0}/stats/sub-{0}_lesions.xls".format(subject))
    
    nifti_out = nib.Nifti1Image(labeled_lesions,affine=image.affine)
    nib.save(nifti_out, MAIN_DIR+'/sub-{0}/segmentations/sub-{0}_labeled_lesions.nii.gz'.format(subject))


if __name__ == "__main__":
    for subject in SUBJECTS:
        try:
            make_lesion_info_excel(subject)
        except FileNotFoundError:
            print("Error with subject {0}, could not find a file".format(subject))
    