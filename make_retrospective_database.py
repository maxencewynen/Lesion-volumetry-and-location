#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Aug 30 22:26:36 2020

@author: mwynen
"""
import os
import pandas as pd

MAIN_DIR=os.environ["MAIN_DIR"]

participants = pd.read_excel(MAIN_DIR + "/participants.xls")


subjects = list()
for i in participants['id']:
    subjects.append((3-len(str(i)))*'0' + str(i))

subjects.remove('010')
subjects.remove('023')
subjects.remove('039')

retrospective_db = pd.DataFrame(columns = ['id', 'Intracranial volume', 'Brain volume', 
                                           'Ventricles', 'White matter', 'Gray matter', 
                                           'Caudate', 'Putamen', 'Thalamus',
                                           'Total lesion volume', 'Number of lesions',
                                           'White matter lesions %', 'Cortical or juxta-cortical lesions %',
                                           'Periventricular lesions %', 'Infratentorial lesions %'])
for subject in subjects:
    try:
        df = pd.read_excel(MAIN_DIR + "/sub-{0}/stats/sub-{0}.xls".format(subject))
        df['id'] = int(subject)
        
        df = df[['id', 'Intracranial volume', 'Brain volume', 
                                           'Ventricles', 'White matter', 'Gray matter', 
                                           'Caudate', 'Putamen', 'Thalamus',
                                           'Total lesion volume', 'Number of lesions',
                                           'White matter lesions %', 'Cortical or juxta-cortical lesions %',
                                           'Periventricular lesions %', 'Infratentorial lesions %']]
        
        retrospective_db = retrospective_db.merge(df, how='outer')
    except FileNotFoundError:
        print("No file found for subject {0}".format(subject))

retrospective_db = participants.merge(retrospective_db, how = 'left')

retrospective_db.to_excel(MAIN_DIR + '/retrospective_database.xls', index = 'id')