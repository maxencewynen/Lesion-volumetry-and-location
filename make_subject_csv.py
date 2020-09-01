#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Aug 26 15:31:18 2020

@author: mwynen


USAGE:
    python make_subject_csv.py sub_id 
    
    -> sub_id       : Subject id (e.g. 001)
"""


import pandas as pd
import sys
import os

SUBJECTS_DIR = os.environ["SUBJECTS_DIR"]
MAIN_DIR = os.environ["MAIN_DIR"]

def get_brain_volumes(subject):
    """
    Retrieves brain volumes from the aseg_lesions.stats file produced by volumetry.sh

    Parameters
    ----------
    subject : TYPE <str>
        Subject id.

    Returns
    -------
    stats : TYPE <dict>
        Dictionary of brain volumes.

    """
    stats={}
    
    with open(SUBJECTS_DIR + "/sub-{0}_MPRAGE.nii/stats/aseg_lesions.stats".format(subject)) as file:
        for line in file:
            if "Estimated Total Intracranial Volume," in line:
                lst = line.split(', ')
                stats['Intracranial volume'] = float(lst[3])
            elif "Brain Segmentation Volume," in line:
                lst = line.split(', ')
                stats['Brain volume'] = float(lst[3])
            elif "Volume of ventricles and choroid plexus," in line:
                lst = line.split(', ')
                stats['Ventricles'] = float(lst[3])
            elif "Total gray matter volume," in line:
                lst = line.split(', ')
                stats['Gray matter'] = float(lst[3])
            elif "Total cerebral white matter volume," in line:
                lst = line.split(', ')
                stats['White matter'] = float(lst[3])
            elif "Left-Caudate" in line:
                lst = line.split(' ')
                column = 0
                for el in lst:
                    if el != '':
                        if column == 5:
                            left_caudate = float(el)
                        column+=1
            elif "Right-Caudate" in line:
                lst = line.split(' ')
                column = 0
                for el in lst:
                    if el != '':
                        if column == 5:
                            right_caudate = float(el)
                        column+=1
            elif "Left-Putamen" in line:
                lst = line.split(' ')
                column = 0
                for el in lst:
                    if el != '':
                        if column == 5:
                            left_putamen = float(el)
                        column+=1
            elif "Right-Putamen" in line:
                lst = line.split(' ')
                column = 0
                for el in lst:
                    if el != '':
                        if column == 5:
                            right_putamen = float(el)
                        column+=1
            elif "Left-Thalamus" in line:
                lst = line.split(' ')
                column = 0
                for el in lst:
                    if el != '':
                        if column == 5:
                            left_thalamus = float(el)
                        column+=1
            elif "Right-Thalamus" in line:
                lst = line.split(' ')
                column = 0
                for el in lst:
                    if el != '':
                        if column == 5:
                            right_thalamus = float(el)
                        column+=1
            elif " WM-hypointensities" in line:
                lst = line.split(' ')
                column = 0
                for el in lst:
                    if el != '':
                        if column == 5:
                            wm_hypo = float(el)
                        column+=1
        
        stats['Caudate']=left_caudate+right_caudate
        stats['Putamen']=left_putamen+right_putamen
        stats['Thalamus']=left_thalamus+right_thalamus
        stats['WM-hypointenisities'] = wm_hypo
        
        brainvol = stats["Intracranial volume"]
        for key,value in stats.items():
            if key != "Intracranial volume":
                stats[key] = value/brainvol
       
        
        return stats
    
    
def get_lesions_information(subject, stats):
    """
    Updates stats with the subjects' lesion informations

    Parameters
    ----------
    subject : TYPE <str>
        Subject id.
    stats : TYPE <dict>
        Dictionary of brain volumes.

    Returns
    -------
    stats : TYPE <dict>
        Dictionary of brain volumes and lesion informations.
    wm_lesions: TYPE <int>
        Total volume of white matter lesions

    """
    
    df = pd.read_csv(MAIN_DIR + "/sub-{0}/stats/sub-{0}_lesions.csv".format(subject))
    
    lesion_count  = df['Unnamed: 0'].count()
    lesion_volume = df['Voxel Volume'].sum()
    
    stats["Number of lesions"]   = lesion_count
    stats["Total lesion volume"] = lesion_volume
    
    wm_lesions = df[df['Location 20%'] != 'Infratentorial']['Voxel Volume'].sum()
    
    wml = df[df["Location 20%"] == 'White Matter']['Voxel Volume'].sum()
    peril = df[df["Location 20%"] == 'Periventricular']['Voxel Volume'].sum()
    gml = df[df["Location 20%"] == 'Cortical or juxta-cortical']['Voxel Volume'].sum()
    infratl = df[df["Location 20%"] == 'Infratentorial']['Voxel Volume'].sum()
    
    stats['White matter lesions %'] = (wml / lesion_volume)*100
    stats['Cortical or juxta-cortical lesions %'] = (gml / lesion_volume)*100
    stats['Periventricular lesions %'] = (peril / lesion_volume)*100
    stats['Infratentorial lesions %'] = (infratl / lesion_volume)*100
    
    
    
    return stats, wm_lesions
    
    

def make_subject_csv(subject):
    
    stats = get_brain_volumes(subject)
    stats, wm_lesions = get_lesions_information(subject,stats)
    
    ic_volume = stats['Intracranial volume']
    
    stats['White matter'] = stats['White matter'] - stats['WM-hypointenisities'] 
    stats['Total lesion volume'] = stats['Total lesion volume'] / ic_volume 
    
    df = pd.DataFrame.from_dict(stats, orient='index', columns = [subject])
    df = df.transpose()
    df.to_csv(MAIN_DIR + "/sub-{0}/stats/sub-{0}.csv".format(subject))
    
if __name__ == "__main__":
    subject = sys.argv[1]
    make_subject_csv(subject)
