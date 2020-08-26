#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Aug 25 21:44:32 2020

@author: mwynen
"""

import numpy as np
import nibabel as nib 
from scipy.ndimage.measurements import label
import numpy.ma as ma
import os
import pandas as pd
from scipy.ndimage.morphology import binary_dilation

MAIN_DIR="/home/mwynen/scripts/MultipleSclerosis"
SUBJECTS = ["006", "010", "012", "013", "019", "023", "034", "035", "036", "037", "038", "039",
             "040", "041", "042", "043", "044", "045", "047", "048", "051", "052", "058", "059", "097", "098"]

def load_segmentations(subject):
    """
    Loads the segmentation image and matrix as well as the lesion matrix

    Parameters
    ----------
    subject : TYPE <str>
        Subject id.

    Returns
    -------
    aseg_image : TYPE <nibabel.freesurfer.mghformat.MGHImage>
        Image of the segmentation mask.
    seg:         TYPE 3D numpy.ndarray
        Matrix of segmentations.
    lesion:      TYPE 3D numpy.ndarray
        Lesion matrix.

    """
    aseg_img = nib.load(MAIN_DIR + "/sub-{0}/segmentations/sub-{0}_aseg_lesions.nii.gz".format(subject))
    seg = aseg_img.get_fdata()
    
    lesion = seg.copy()
    lesion[lesion!=99] = 0
    lesion[lesion==99] = 1
    
    return aseg_img, seg, lesion





def make_lesions_xls(subject, minimum_lesion_size=5):
    
    image, aseg, lesion = load_segmentations(subject) 
    
    # Get number of components (thus number of lesions)
    structure = np.ones((3, 3, 3))
    labeled_lesions, nlesions = label(lesion,structure)
    
    print("Number of lesions before discarding: {0}".format(nlesions))
    
    id_lesions_dic = {}
                
    for lesion_id in range(1,nlesions+1):
        lesions_mskd = ma.masked_where(labeled_lesions != lesion_id, labeled_lesions)
        lesion_voxel_volume_count = lesions_mskd.sum() // lesion_id
        
        if lesion_voxel_volume_count > minimum_lesion_size:
            loc_20,_,_ = lesion_location(subject, lesion_id, lesion_mx=labeled_lesions,
                                       aseg_mx=aseg, percentage=0.2)
            loc_30,_,_ = lesion_location(subject, lesion_id, lesion_mx=labeled_lesions,
                                       aseg_mx=aseg, percentage=0.3)
            
            id_lesions_dic[lesion_id] = [lesion_voxel_volume_count, loc_20, loc_30]#, loc_40, loc_50]
            print("Lesion {0}: {1} voxels".format(lesion_id, lesion_voxel_volume_count))
        else: 
            print("Lesion {0}: {1} voxels ==> Discarded (too small)".format(lesion_id, lesion_voxel_volume_count))
    
    
    columns = ["Voxel Volume", "Location 20%", "Location 30%"]
    
    df = pd.DataFrame.from_dict(id_lesions_dic, orient='index', columns=columns)
    df.to_excel(MAIN_DIR + "/sub-{0}/stats/sub-{0}_lesions.xls".format(subject))
    
    nifti_out = nib.Nifti1Image(labeled_lesions,affine=image.affine)
    nib.save(nifti_out, MAIN_DIR+'/sub-{0}/segmentations/sub-{0}_labeled_lesions.nii.gz'.format(subject))
    
    
    
    
    
def lesion_location(subject, lesion_label, lesion_mx=None, aseg_mx=None, percentage=0.2):
    """
    Finds the location of a lesion

    Parameters
    ----------
    machine : TYPE <str>
        "PHILIPS" or "SIEMENS".
    subject : TYPE <str>
        Subject id.
    lesion_label : TYPE <int>
        Label for the lesion of interest.
    lesion_mx : TYPE 3D numpy.ndarray, optional
        Matrix of labeled lesions. The default is retrieved based on the machine and subject path.
    aseg_mx : TYPE 3D numpy.ndarray, optional
        Matrix of labeled brain structures. The default is retrieved based on the machine and subject path.
    percentage : TYPE <int>, optional
        Percentage of the lesion volume that has to match with the brain structure. The default is 0.5.

    Returns
    -------
    TYPE <str>
        Lesion location. Either "White Matter", "Cortical or juxta-cortical", "Periventricular" or "Infratentorial".
    lesion_volume : TYPE <int>
        Lesion volume (voxel count).

    """
    
    if lesion_mx is None:
        lesion_image = nib.load(MAIN_DIR + "/sub-{0}/segmentations/sub-{0}_labeled_lesions.nii.gz".format(subject))
        lesion_mx = lesion_image.get_fdata()
    if aseg_mx is None:
        aseg_image = nib.load(MAIN_DIR + "/sub-{2}/segmentations/sub-{0}_aseg.mgz".format(subject))
        aseg_mx = aseg_image.get_fdata()
    
    aseg_mx[aseg_mx == 41] = 2 #White matter
    aseg_mx[aseg_mx == 42] = 3 #Gray matter
    aseg_mx[aseg_mx == 43] = 4 #Ventricle
    aseg_mx[aseg_mx == 7] = 16 #Left Cerebellum Cortex -> Brainstem
    aseg_mx[aseg_mx == 8] = 16 #Left Cerebellum WM -> Brainstem
    aseg_mx[aseg_mx == 47] = 16 #Right Cerebellum Cortex -> Brainstem
    aseg_mx[aseg_mx == 46] = 16 #Right Cerebellum WM -> Brainstem
    
    results = []
    
    # for seg,iterations in [(3, 2), (4, 3), (16, 1)]:
    for seg,iterations in [(3, 1), (4, 3), (16, 1)]:
        print(seg)
        aseg_mask = ma.masked_not_equal(aseg_mx, seg)
        aseg_mask.fill_value = 0
        aseg_mask = aseg_mask.filled()
        
        aseg_temp = binary_dilation(aseg_mask, iterations=iterations).astype(aseg_mx.dtype)
        results.append(count_matching_lesion_voxels(lesion_mx, aseg_temp, lesion_label, seg))
    
    print(results)
    lesions_mskd = ma.masked_where(lesion_mx != lesion_label, lesion_mx)
    lesion_volume = lesions_mskd.sum() // lesion_label
    
    index = {-1:"White Matter", 0:"Cortical or juxta-cortical", 1:"Periventricular", 2: "Infratentorial"}
    
    loc = results.index(max(results))
    if (loc == 0 or loc == 1) and max(results) < percentage*lesion_volume:
        loc = -1
    
    return index[loc], lesion_volume, results
     

def count_matching_lesion_voxels(lesion_mx, segmentation_mx, lesion, segmentation):
    """
    Counts the number of voxels where the lesion_mx[index] = lesion and 
    segmentation_mx[index] = segmentation for the same index

    Parameters
    ----------
    lesion_mx : 3D numpy.ndarray
        Matrix of labeled lesions.
    segmentation_mx : 3D numpy.ndarray
        Matrix of labeled brain segmentation.
    lesion : TYPE <int>
        Label for the lesion of interest.
    segmentation : TYPE <int>
        Label for the brain structure of interest.

    Returns
    -------
    TYPE <int>
        Count of matching voxels.

    """
    les_mx = lesion_mx.copy()
    
    les_mx = ma.masked_not_equal(les_mx, lesion)
    les_mx.fill_value = -1
    les_mx = les_mx.filled()
    
    les_mx[les_mx == lesion] = 1
    
    return np.sum(les_mx == segmentation_mx)   
    
    
    
    
    
    
    
    
    
    
    
    
    
    