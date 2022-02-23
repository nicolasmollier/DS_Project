# Transformed version of the classifier (torch to tensorflow)
# Classifier which is indeed called in the application

import numpy as np
import onnx
import onnxruntime as ort
import tensorflow as tf
#from PIL import Image


# define mapping to classes
mapping_dict_classifier = {
    0: 'Adidas Continental 80',
    1: 'Adidas Shoe',
    2: 'Adidas Stan Smith',
    3: 'Adidas Ultraboost',
    4: 'Asics Gel',
    5: 'Asics Sneaker', # Asics Tiger
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
    16: 'KSwiss Sneaker',
    17: 'NewBalance Sneaker',
    18: 'Nike AirforceOne',
    19: 'Nike Blazer',
    20: 'Nike Jordans',
    21: 'Nike Sneaker', #Nike Running
    22: 'Puma Sneaker',
    23: 'Reebok Sneaker',
    24: 'Sketchers Sneaker',
    25: 'Steve Madden Sneaker',
    26: 'Timberland Boots',
    27: 'Tommy Hilfiger Sneaker',
    28: 'UGG Boots', # UGG boots
    29: 'Winter Boot', # Winter boot
    30: 'Ballerinas', #sandals
    31: 'Suit shoe', #suit shoe
    32: 'High Heels',
    33: 'Lacoste sneaker', #lacoste sneaker
    34: 'Sandals', #sandals
    35: 'Vans classic slip on', #vans classic slip on
    36: 'Vans sneaker'} # vans sneaker



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



