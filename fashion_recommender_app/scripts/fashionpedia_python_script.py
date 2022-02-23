# Copyright 2020 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
# pylint: disable=line-too-long
r"""A stand-alone binary to run model inference and visualize results.

It currently only supports model of type `retinanet` and `mask_rcnn`. It only
supports running on CPU/GPU with batch size 1.
"""
# pylint: enable=line-too-long



from __future__ import absolute_import
from __future__ import division
from __future__ import print_function


import base64
import csv
import io

from absl import flags
from absl import logging

import numpy as np
import pandas as pd
from PIL import Image
from pycocotools import mask as mask_api
import tensorflow.compat.v1 as tf
import os

os.chdir("/srv/shiny-server/fashion_recommender_app_cloud/tpu/models")
# os.getcwd()

# import official.detection.projects
# from dataloader import mode_keys
# from official.detection.projects.fashionpedia.configs import model_config
# from official.detection.projects.fashionpedia.configs import factory as config_factory
# from official.detection.projects.fashionpedia.modeling import factory as model_factory
# from utils import box_utils
# from utils import input_utils
# from utils import mask_utils
# from utils.object_detection import visualization_utils
# from hyperparameters import params_dict


from dataloader import mode_keys
from projects.fashionpedia.configs import factory as config_factory
from projects.fashionpedia.modeling import factory as model_factory
from utils import box_utils
from utils import input_utils
from utils import mask_utils
from utils.object_detection import visualization_utils
from hyperparameters import params_dict



model="attribute_mask_rcnn"
image_size=640
checkpoint_path="/srv/shiny-server/fashion_recommender_app_cloud/tpu/models/projects/fashionpedia/fashionpedia-r50-fpn/model.ckpt"
label_map_file="official/detection/datasets/coco_label_map.csv"
image_file_pattern="/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/data/google_images/low_resolution/Adidas_Continental_80/Adidas_Continental_805.jpg"
output_html="./test.html"
label_map_format = "csv"
max_boxes_to_draw=10 
min_score_threshold=0.05
config_file = ''
params_override = ''
image_size = 640



#brand_folder = "/home/nicolas/Desktop/test_images" #"/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/data/google_images/low_resolution" 
#output_folder = "/home/nicolas/Desktop/test"
#brand_query = os.listdir(brand_folder)
#brand_query = [x for x in brand_query if x != "geckodriver.log"]


def extract_fashion_attibutes(model, image_size, in_app_use, shoe_image_path):
  # Load the label map.
  print(' - Loading the label map...')
  label_map_dict = {}
  if label_map_format == 'csv':
    with tf.gfile.Open(label_map_file, 'r') as csv_file:
      reader = csv.reader(csv_file, delimiter=':')
      for row in reader:
        if len(row) != 2:
          raise ValueError('Each row of the csv label map file must be in '
                           '`id:name` format.')
        id_index = int(row[0])
        name = row[1]
        label_map_dict[id_index] = {
            'id': id_index,
            'name': name,
        }
  else:
    raise ValueError(
        'Unsupported label map format: {}.'.format(label_map_format))

  params = config_factory.config_generator(model)
  if config_file:
    params = params_dict.override_params_dict(
        params, config_file, is_strict=True)
  params = params_dict.override_params_dict(
      params, params_override, is_strict=True)
  params.override({
      'architecture': {
          'use_bfloat16': False,  # The inference runs on CPU/GPU.
      },
  }, is_strict=True)
  params.validate()
  params.lock()
  print('Hi')

  model = model_factory.model_generator(params)

  with tf.Graph().as_default():
    image_input = tf.placeholder(shape=(), dtype=tf.string)
    image = tf.io.decode_image(image_input, channels=3)
    image.set_shape([None, None, 3])

    image = input_utils.normalize_image(image)
    image_size = [image_size, image_size]
    image, image_info = input_utils.resize_and_crop_image(
        image,
        image_size,
        image_size,
        aug_scale_min=1.0,
        aug_scale_max=1.0)
    image.set_shape([image_size[0], image_size[1], 3])

    # batching.
    images = tf.reshape(image, [1, image_size[0], image_size[1], 3])
    images_info = tf.expand_dims(image_info, axis=0)

    # model inference
    outputs = model.build_outputs(
        images, {'image_info': images_info}, mode=mode_keys.PREDICT)

    outputs['detection_boxes'] = (
        outputs['detection_boxes'] / tf.tile(images_info[:, 2:3, :], [1, 1, 2]))

    predictions = outputs

    # Create a saver in order to load the pre-trained checkpoint.
    saver = tf.train.Saver()

    image_with_detections_list = []
    with tf.Session() as sess:
      print(' - Loading the checkpoint...')
      saver.restore(sess, checkpoint_path)

      #res = []
      #image_files = os.listdir(brand_folder) # shoe_image_path
      #image_files = [x for x in image_files if x != "geckodriver.log"]
      #image_files = tf.gfile.Glob(image_file_pattern)
      inference_index = 0
      #temp_res = pd.DataFrame(columns = ['image_name', 'classes', 'probabilities', 'attributes', 'masks', 'boxes', 'height', 'width'])

      if in_app_use == True:
        res = [None]*1

        print(shoe_image_path)

        with tf.gfile.GFile(shoe_image_path, 'rb') as f:   #image_file
          image_bytes = f.read()

        image = Image.open(shoe_image_path)
        image = image.convert('RGB')  # needed for images with 4 channels.
        width, height = image.size
        np_image = (np.array(image.getdata())
                    .reshape(height, width, 3).astype(np.uint8))

        predictions_np = sess.run(
            predictions, feed_dict={image_input: image_bytes})

        num_detections = int(predictions_np['num_detections'][0])
        np_boxes = predictions_np['detection_boxes'][0, :num_detections]
        np_scores = predictions_np['detection_scores'][0, :num_detections]
        np_classes = predictions_np['detection_classes'][0, :num_detections]
        np_classes = np_classes.astype(np.int32)
        np_attributes = predictions_np['detection_attributes'][
            0, :num_detections, :]
        np_masks = None
        if 'detection_masks' in predictions_np:
          instance_masks = predictions_np['detection_masks'][0, :num_detections]
          np_masks = mask_utils.paste_instance_masks(
              instance_masks, box_utils.yxyx_to_xywh(np_boxes), height, width)
          encoded_masks = [
              mask_api.encode(np.asfortranarray(np_mask))
              for np_mask in list(np_masks)]

        res[inference_index] = {
            'image_file': shoe_image_path,
            'boxes': np_boxes,
            'classes': np_classes,
            'scores': np_scores,
            'attributes': np_attributes,
            'masks': encoded_masks,
            'height': height,
            'width': width
        }
          
        
        print(inference_index)
        #print(res.shape)
        inference_index += 1 #gives the row in the resulting data frame fashionpedia_inference (represents a particular image)
      #print(" - Pre-Saving the outputs...")
      #np.savez_compressed(output_folder, x = res)
        
      if in_app_use == False:
        res = [None]*18000

        for j in image_files:
            image_folder = brand_folder + "/" + j 
            image_folder_files = os.listdir(image_folder)
            for i, image_file in enumerate(image_folder_files):
              shoe_image_path = brand_folder + "/" + j + "/" + image_file
                
              print(' - Processing image %d...' % i)
              print(shoe_image_path)
      
              with tf.gfile.GFile(shoe_image_path, 'rb') as f:   #image_file
                image_bytes = f.read()
      
              image = Image.open(shoe_image_path)
              image = image.convert('RGB')  # needed for images with 4 channels.
              width, height = image.size
              np_image = (np.array(image.getdata())
                          .reshape(height, width, 3).astype(np.uint8))
      
              predictions_np = sess.run(
                  predictions, feed_dict={image_input: image_bytes})
      
              num_detections = int(predictions_np['num_detections'][0])
              np_boxes = predictions_np['detection_boxes'][0, :num_detections]
              np_scores = predictions_np['detection_scores'][0, :num_detections]
              np_classes = predictions_np['detection_classes'][0, :num_detections]
              np_classes = np_classes.astype(np.int32)
              np_attributes = predictions_np['detection_attributes'][
                  0, :num_detections, :]
              np_masks = None
              if 'detection_masks' in predictions_np:
                instance_masks = predictions_np['detection_masks'][0, :num_detections]
                np_masks = mask_utils.paste_instance_masks(
                    instance_masks, box_utils.yxyx_to_xywh(np_boxes), height, width)
                encoded_masks = [
                    mask_api.encode(np.asfortranarray(np_mask))
                    for np_mask in list(np_masks)]
      
              res[inference_index] = {
                  'image_file': shoe_image_path,
                  'boxes': np_boxes,
                  'classes': np_classes,
                  'scores': np_scores,
                  'attributes': np_attributes,
                  'masks': encoded_masks,
                  'height': height,
                  'width': width
              }
                
              
              print(inference_index)
              #print(res.shape)
              inference_index += 1 #gives the row in the resulting data frame fashionpedia_inference (represents a particular image)
            #print(" - Pre-Saving the outputs...")
            #np.savez_compressed(output_folder, x = res)

  #print(' - Saving the outputs...')
  #np.save("/home/nicolas/Desktop/res", temp_res)
  #np.savez_compressed(output_folder, x = res)
  return(res)

