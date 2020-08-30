#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Aug 25 21:44:32 2020

@author: mwynen

USAGE:
    python make_lesions_xls.py sub_id [percentage]
    
    -> sub_id       : Subject id (e.g. 001)
    -> percentage   : (optional) Percentage of the lesion that must match the dilation of a brain 
                        structure (Ventricles and Cortex) in order to consider the location
                        of said lesion as periventricular or juxta-cortical. Default is set to 20.
"""

import numpy as np
import nibabel as nib 
from scipy.ndimage.measurements import label
import numpy.ma as ma
import os
import pandas as pd
from scipy.ndimage.morphology import binary_dilation

MAIN_DIR=os.environ["MAIN_DIR"]
WHITE_MATTER   = 2
GRAY_MATTER    = 3
VENTRICLES     = 4
INFRATENTORIAL = 16 

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
        Image of the Freesurfer segmentation mask.
    seg:         TYPE 3D numpy.ndarray
        Matrix of segmentations.
    lesion:      TYPE 3D numpy.ndarray
        Lesion matrix.

    """
    # Load segmentations
    aseg_img = nib.load(MAIN_DIR + "/sub-{0}/segmentations/sub-{0}_aseg_lesions.nii.gz".format(subject))
    seg = aseg_img.get_fdata()
    
    # Make lesion matrix from segmentations matrix
    lesion = seg.copy()
    lesion[lesion!=99] = 0
    lesion[lesion==99] = 1
    
    return aseg_img, seg, lesion





def make_lesions_xls(subject, minimum_lesion_size=5):
    """
    Makes the lesion based database (lesions.xls) that regroups informations about
    the lesions of one subject (label - volume - location). 

    Parameters
    ----------
    subject : TYPE <str>
        Subject id.
    minimum_lesion_size : TYPE <int>, optional
        Minimum size for a lesion to be considered as such. The default is 5.

    Returns
    -------
    None.

    """
    # Load segmentations
    image, aseg, lesion = load_segmentations(subject) 
    
    # Get number of components (thus number of lesions)
    structure = np.ones((3, 3, 3))
    labeled_lesions, nlesions = label(lesion,structure)
    
    print("Number of lesions before discarding: {0}".format(nlesions))
    
    id_lesions_dic = {}
                
    # For every lesion
    for lesion_id in range(1,nlesions+1):
        # Create lesion mask for this specific lesion
        lesions_mskd = ma.masked_where(labeled_lesions != lesion_id, labeled_lesions)
        
        # Compute the lesion volume
        lesion_voxel_volume_count = lesions_mskd.sum() // lesion_id
        
        
        if lesion_voxel_volume_count > minimum_lesion_size:
            print("\n\nLesion {0}: {1} voxels".format(lesion_id, lesion_voxel_volume_count))
            
            # Get the lesion location
            loc_20,_,_ = lesion_location(subject, lesion_id, lesion_mx=labeled_lesions,
                                       aseg_mx=aseg, percentage=0.2)
            loc_30,_,_ = lesion_location(subject, lesion_id, lesion_mx=labeled_lesions,
                                       aseg_mx=aseg, percentage=0.3)
            
            id_lesions_dic[lesion_id] = [lesion_voxel_volume_count, loc_20, loc_30]#, loc_40, loc_50]
            
        else: 
            # Discard lesion if size is inferior to the minimum lesion size
            print("\n\nLesion {0}: {1} voxels ==> Discarded (too small)".format(lesion_id, lesion_voxel_volume_count))
            #labeled_lesions[labeled_lesions == lesion_id] = 0 # Leave commented, not working
    
    
    # Make the database
    columns = ["Voxel Volume", "Location 20%", "Location 30%"]
    
    df = pd.DataFrame.from_dict(id_lesions_dic, orient='index', columns=columns)
    df.to_excel(MAIN_DIR + "/sub-{0}/stats/sub-{0}_lesions.xls".format(subject))
    
    # Save the lesion mask with labels to a nifti file
    nifti_out = nib.Nifti1Image(labeled_lesions,affine=image.affine)
    nib.save(nifti_out, MAIN_DIR+'/sub-{0}/segmentations/sub-{0}_labeled_lesions.nii.gz'.format(subject))
    
    
    
    
    
def lesion_location(subject, lesion_label, lesion_mx=None, aseg_mx=None, percentage=0.2):
    """
    Finds the location of a lesion

    Parameters
    ----------
    subject : TYPE <str>
        Subject id.
    lesion_label : TYPE <int>
        Label id for the lesion of interest.
    lesion_mx : TYPE 3D numpy.ndarray, optional
        Matrix of labeled lesions. The default is retrieved based on the machine and subject path.
    aseg_mx : TYPE 3D numpy.ndarray, optional
        Matrix of labeled brain structures. The default is retrieved based on the machine and subject path.
    percentage : TYPE <int>, optional
        Percentage of the lesion volume that has to match with the dilated brain structure. The default is 0.2.

    Returns
    -------
    TYPE <str>
        Lesion location. Either "White Matter", "Cortical or juxta-cortical", "Periventricular" or "Infratentorial".
    lesion_volume : TYPE <int>
        Lesion volume (voxel count).

    """
    
    if lesion_mx is None:
        # Load lesion mask
        lesion_image = nib.load(MAIN_DIR + "/sub-{0}/segmentations/sub-{0}_labeled_lesions.nii.gz".format(subject))
        lesion_mx = lesion_image.get_fdata()
        
    if aseg_mx is None:
        # Load segmentation
        aseg_image = nib.load(MAIN_DIR + "/sub-{2}/segmentations/sub-{0}_aseg.mgz".format(subject))
        aseg_mx = aseg_image.get_fdata()
    
    
    # Regroup left and right structures into the same label 
    aseg_mx[aseg_mx == 41] = WHITE_MATTER #White matter
    aseg_mx[aseg_mx == 42] = GRAY_MATTER #Gray matter
    aseg_mx[aseg_mx == 43] = VENTRICLES #Ventricle
    aseg_mx[aseg_mx == 7]  = INFRATENTORIAL #Left Cerebellum Cortex -> Brainstem
    aseg_mx[aseg_mx == 8]  = INFRATENTORIAL #Left Cerebellum WM -> Brainstem
    aseg_mx[aseg_mx == 47] = INFRATENTORIAL #Right Cerebellum Cortex -> Brainstem
    aseg_mx[aseg_mx == 46] = INFRATENTORIAL #Right Cerebellum WM -> Brainstem
    
    results = []
    dic = {WHITE_MATTER: "white matter", GRAY_MATTER: "gray matter", 
           VENTRICLES: "ventricles", INFRATENTORIAL: "infratentorial structures"}
    
    for seg,iterations in [(GRAY_MATTER, 1), (VENTRICLES, 3), (INFRATENTORIAL, 1)]:
        
        print("Dilating " + dic[seg] + "...", end= " ")
        
        # Make the brain structure segmentation mask (other segmentations removed)
        aseg_mask = ma.masked_not_equal(aseg_mx, seg)
        aseg_mask.fill_value = 0
        aseg_mask = aseg_mask.filled()
        
        # Dilate the brain structure 'iterations' timesaseg_temp 
        aseg_temp = binary_dilation(aseg_mask, iterations=iterations).astype(aseg_mx.dtype) # Binary mask
        
        # Append the results
        matching_voxels = count_matching_lesion_voxels(lesion_mx, aseg_temp, lesion_label, seg)
        print( str(matching_voxels) + " voxels in common with the lesion")
        results.append(matching_voxels)
    
    # Get the lesion volume
    lesions_mskd = ma.masked_where(lesion_mx != lesion_label, lesion_mx)
    lesion_volume = lesions_mskd.sum() // lesion_label
    
    index = {-1:"White Matter", 0:"Cortical or juxta-cortical", 1:"Periventricular", 2: "Infratentorial"}
    
    # Set the lesion location as white matter if the count of overlapping voxels do not 
    # exceed the percentage of the lesion volume
    loc = results.index(max(results))
    if (loc == 0 or loc == 1) and max(results) < percentage*lesion_volume:
        loc = -1
    
    return index[loc], lesion_volume, results
     

def count_matching_lesion_voxels(lesion_mx, segmentation_mx, lesion, segmentation):
    """
    Counts the number of voxels where 
        lesion_mx[index]       = lesion         and 
        segmentation_mx[index] = segmentation 
    for the same index

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
    
    # Set all voxels whose value differ from the lesion id to -1
    les_mx = ma.masked_not_equal(les_mx, lesion)
    les_mx.fill_value = -1
    les_mx = les_mx.filled()
    
    # Set all voxels whose value equal to the lesion id to 1
    les_mx[les_mx == lesion] = 1
    
    return np.sum(les_mx == segmentation_mx)   
    
    
    
    
    
def make_location_mask(subject, percentage=20):
    """
    Makes a lesion location mask based on the lesion based db (lesions.xls)

    Parameters
    ----------
    subject : TYPE <str>
        Subject id.
    percentage : TYPE <int>, optional
        Percentage of the lesion volume that has to match with the dilated brain 
        structure. The default is 20.

    Returns
    -------
    None.

    """
    # Retrieve lesion based database
    df = pd.read_excel(MAIN_DIR + "/sub-{0}/stats/sub-{0}_lesions.xls".format(subject))
    locations = list(df["Location {0}%".format(percentage)])
    ids = list(df["Unnamed: 0"])
    
    lesion_image = nib.load(MAIN_DIR+ "/sub-{0}/segmentations/sub-{0}_labeled_lesions.nii.gz".format(subject))
    lesion_mx = lesion_image.get_fdata()
    
    lesion_loc = lesion_mx.copy()
    
    dictionary = {"White Matter":100, "Cortical or juxta-cortical":200, "Periventricular":300, "Infratentorial":400}
    
    for i in range(len(locations)):
        lesion_loc[lesion_loc == ids[i]] = dictionary[locations[i]]
    
    nifti_out = nib.Nifti1Image(lesion_loc,affine=lesion_image.affine)
    nib.save(nifti_out, MAIN_DIR+'/sub-{0}/segmentations/sub-{0}_lesion_locations_{1}.nii.gz'.format(subject,percentage))

    
    
    
    
    
    
if __name__ == "__main__":
    import sys
    
    subject = sys.argv[1]
    make_lesions_xls(subject)
    
    if len(sys.argv)>2:
        make_location_mask(subject, int(sys.argv[2]))
        
    else:
        make_location_mask(subject,20)
        make_location_mask(subject,30)
    