#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Aug 26 15:31:18 2020

@author: mwynen
"""


import pandas as pd
import sys
import os

SUBJECTS_DIR = os.environ["SUBJECTS_DIR"]
MAIN_DIR = os.environ["MAIN_DIR"]

def get_brain_volumes(subject):
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
        
        stats['Caudate']=left_caudate+right_caudate
        stats['Putamen']=left_putamen+right_putamen
        stats['Thalamus']=left_thalamus+right_thalamus
        
        brainvol = stats["Brain volume"]
        for key,value in stats.items():
            if key != "Brain volume":
                stats[key] = value/brainvol
        
        return stats

def make_subject_xls(subject):
    
    stats = get_brain_volumes(subject)
    df = pd.DataFrame.from_dict(stats, orient='index', columns = [subject])
    df = df.transpose()
    df.to_excel(MAIN_DIR + "/sub-{0}/stats/sub-{0}.xls".format(subject))
    
if __name__ == "__main__":
    subject = sys.argv[1]
    make_subject_xls(subject)
