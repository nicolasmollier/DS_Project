#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 29 16:39:02 2021

@author: nicolas
"""

from fashionpedia.fp import Fashionpedia

import os
os.chdir("/home/nicolas/Desktop/fashionpediaapi")


anno_file = "data/sample.json"
img_root = "images"


# initialize Fashionpedia api
fp = Fashionpedia(anno_file)
fp



# Display the categories and attributes.
# Pls refer to the final data for the final version of categories and attributes
cats = fp.loadCats(fp.getCatIds())
cat_names =[cat['name'] for cat in cats]
print('Fashionpedia categories: \n{}\n'.format('; '.join(cat_names)))


fp.getAttIds()
atts = fp.loadAttrs(fp.getAttIds())
atts
att_names = [att["name"] for att in atts]
print('Fashionpedia attributes (first 10): \n{}\n'.format('; '.join(att_names[:10])))