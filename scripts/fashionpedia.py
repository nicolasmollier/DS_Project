#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 25 19:47:24 2021

@author: nicolas
"""

!pip install tensorflow==1.15 --user

!sudo apt-get install -y python-tk && \
!pip3 install --user Cython matplotlib opencv-python-headless pyyaml Pillow && \
!pip3 install --user 'git+https://github.com/cocodataset/cocoapi#egg=pycocotools&subdirectory=PythonAPI'

import os

os.chdir("/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project")


MODEL="mask_rcnn"
IMAGE_SIZE=640
CHECKPOINT_PATH="/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/Fashionpedia/fashionpedia-spinenet-143"
PARAMS_OVERRIDE=""  # if any.
LABEL_MAP_FILE="/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/Fashionpedia/models/official/detection/datasets/coco_label_map.csv"
IMAGE_FILE_PATTERN="/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/data/blurr_test/AirForceOne/AirForceOne_4.jpg"
OUTPUT_HTML="./test.html"
python /home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/Fashionpedia/models/official/detection/inference.py \
  --model="${MODEL?}" \
  --image_size="${IMAGE_SIZE?}" \
  --checkpoint_path="${CHECKPOINT_PATH?}" \
  --label_map_file="${LABEL_MAP_FILE?}" \
  --image_file_pattern="${IMAGE_FILE_PATTERN?}" \
  --output_html="${OUTPUT_HTML?}" \
  --max_boxes_to_draw=10 \
  --min_score_threshold=0.05





export PYTHONPATH="$PYTHONPATH:/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/tpu/models/official/detection/dataloader/"
export PYTHONPATH="$PYTHONPATH:/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/tpu/models/official/efficientnet/"
export PYTHONPATH="$PYTHONPATH:/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/tpu/models/hyperparameters/"




# Das hier funktioniert


export PYTHONPATH=$PYTHONPATH:/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/tpu/models/


MODEL="attribute_mask_rcnn"
IMAGE_SIZE=640
CHECKPOINT_PATH="/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/tpu/models/official/detection/projects/fashionpedia/fashionpedia-r50-fpn/model.ckpt"
PARAMS_OVERRIDE=""  # if any.
LABEL_MAP_FILE="/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/tpu/models/official/detection/projects/fashionpedia/dataset/fashionpedia_label_map.csv"

IMAGE_FILE_PATTERN="/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/data/google_images/low_resolution/Anzugsschuhe/Anzugsschuhe11.jpg"
OUTPUT_HTML="/home/nicolas/Desktop/test2.html"
OUTPUT_FILE="/home/nicolas/Desktop/res"
python /home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/tpu/models/official/detection/inference.py \
  --model="${MODEL?}" \
  --image_size=${IMAGE_SIZE?} \
  --checkpoint_path="${CHECKPOINT_PATH?}" \
  --label_map_file="${LABEL_MAP_FILE?}" \
  --image_file_pattern="${IMAGE_FILE_PATTERN?}" \
  --output_html="${OUTPUT_HTML?}" \
  --output_file="${OUTPUT_FILE?}" \
  --max_boxes_to_draw=11 \
  --min_score_threshold=0.2

import numpy as np
res=np.load("/home/nicolas/Desktop/res.npy", allow_pickle=True)
res
res[0][0]
res[0][1]
res[0][2]
len(res[0][3]
x[0].keys()
len(x[0]['classes'])
len(x[0]['boxes'])
x[0]['image_file']
x[0]['scores']
x[0]['attributes'].sum()
x[0]['masks']

classes = np.unique(x[0]['classes'])
x[0]["classes"]

np.argmax(x[0]['attributes'][0])
x[0]['attributes'][0][248]
len(np.unique(x[0]["classes"]))

fashionpedia_inference
