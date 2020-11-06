#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Nov  6 14:04:53 2020

@author: mwynen
"""


import nibabel as nib 
import os
import numpy as np
from scipy.ndimage.measurements import label
import sys

if len(sys.argv) <2:
    print("USAGE : \n    python change_orientation.py path/to/input.nii.gz axis[x|y|z] path/to/output.nii.gz")
elif sys[1] == "-h":
    print("USAGE : \n    python change_orientation.py path/to/input.nii.gz axis[x|y|z] path/to/output.nii.gz")

file = sys.argv[1]
axis = sys.argv[2]
output = sys.argv[3]
AXES = {'x':0,'y':1,'z':2}

image = nib.load(file)

new_data = np.flip(image.get_fdata(), AXES[axis])
new_image = nib.Nifti1Image(new_data, image.affine, image.header)
nib.save(new_image, output)
