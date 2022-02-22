#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Feb 22 11:37:21 2022

@author: shared
"""


import numpy as np
import onnx
import onnxruntime as ort
import tensorflow as tf
#from PIL import Image


# define mapping to classes
mapping_dict_classifier = {
    0: 'Adidas Continental 80',
    1: 'Adidas Sneaker',
    2: 'Adidas Stan Smith',
    3: 'Adidas Ultraboost',
    4: 'Asics Gel',
    5: 'Asics Sneaker',
    6: 'Birkenstock Arizona',
    7: 'Birkenstock Gizeh',
    8: 'Birkenstock Madrid',
    9: 'Converse chucks high',
    10: 'Converse chucks low',
    11: 'Crocs',
    12: 'Dr. Martens Boots',
    13: 'Fila Sneaker',
    14: 'Flipflops',
    15: 'Gucci Ace',
    16: 'Kswiss sneaker',
    17: 'New Balance Sneaker',
    18: 'Nike AirforceOne',
    19: 'Nike Blazer',
    20: 'Nike Jordans',
    21: 'Nike Sneaker',
    22: 'Puma Sneaker',
    23: 'Reebok Sneaker',
    24: 'Sketchers Sneaker',
    25: 'Steve Madden Sneaker',
    26: 'Timberland',
    27: 'Tommy Hilfiger Sneaker',
    28: 'UGG Stiefel',
    29: 'Winter Stiefel',
    30: 'ballerinas',
    31: 'business schuhe',
    32: 'high pumps',
    33: 'lacoste sneaker',
    34: 'sandals',
    35: 'vans slip on',
    36: 'vans sneaker'}



def preprocess(img):
    img = tf.image.resize(img, [224, 224])
    img = (img - [0.7134, 0.6977, 0.6914]) / [0.3700, 0.3752, 0.3796]
    img = np.transpose(img, axes=[2, 0, 1])
    img = img.astype(np.float32)
    img = np.expand_dims(img, axis=0)
    return img
  



def predict_shoe(image):
    img = preprocess(image)
    ort_inputs = {session.get_inputs()[0].name: img}
    preds = session.run(None, ort_inputs)[0]
    preds = np.squeeze(preds)
    a = np.argsort(preds)[::-1]
    print('probability=%f' %(preds[a[0]]))
    return mapping_dict_classifier[a[0]]


### use onnx model for inference
model_weights = onnx.load("model_weights/classifier.onnx")
session = ort.InferenceSession(model_weights.SerializeToString())

# # define which image to take
# img_path = 'highheel.jpg'
# 
# # make prediction
# pred = predict(img_path)
# print(pred)

# feature_3_image_shoe = pyreadr.read_r('data/feature_3_image_shoe.RData') # also works for Rds
# img = feature_3_image_shoe
# img = img["feature_3_image_shoe"]
# 
# preprocess(img)
# predict_shoe(img)
