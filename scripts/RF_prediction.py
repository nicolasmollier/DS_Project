#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Feb  6 16:05:31 2022

@author: shared
"""


import sklearn
import pickle
import numpy as np
import os
import pyreadr


# define mapping of prediction
mapping_same_category = {
    'Adidas_Continental_80': "Adidas Continental 80",
    'Adidas_Running': "Adidas Running",
    'Adidas_Shoe': "Adidas Shoe",
    'Adidas_Stan_Smith': "Adidas Stan Smith",
    'Adidas_Superstar': "Adidas Superstar",
    'Adidas_Ultraboost': "Adidas Ultraboost",
    'Anzugsschuhe': "business shoe",
    'Asics_Gel': "Asics Gel",
    'Asics_Tiger': "Asics Tiger",
    'Autumn_boot': "Autumn boot",
    'Birkenstock_Arizona': "Birkenstock Arizona",
    'Birkenstock_Gizeh': "Birkenstock Gizeh",
    'Birkenstock_Madrid': "Birkenstock Madrid",
    'Boot': 'boot',
    "Chucks": "Chucks",
    'Crocs': "Crocs",
    'Dr. Marten low-level': "Dr. Martens low-level shoe",
    'Martens_Boots': "Dr. Martens boot",
    'Fila_Sneaker': "Fila sneaker",
    'Flipflops': "flipflops",
    'Gucci_Ace': "Gucci Ace",
    'High Heels': "high heels",
    'Kswiss_sneaker': "Kswiss sneaker",
    'Louboutin': "Louboutin high heel",
    'NewBalance_Sneaker': "New Balance sneaker",
    'Nike_AirforceOne': "Nike AirforceOne",
    'Nike_Blazer': "Nike Blazer",
    'Nike_Jordans': "Nike Jordans",
    'Nike_Running': "Nike Running",
    'Puma_Sneaker': "Puma Sneaker",
    'Reebok_Sneaker': "Reebok sneaker",
    'Sketchers_Sneaker': "Sketchers sneaker",
    'Steve_Madden_Sneaker': "Steve Madden sneaker",
    'Timberland_Boots': "Timberland boot",
    'Tommy_Hilfiger_Sneaker': "Tommy Hilfiger sneaker",
    'UGG': "UGG boot",
    'Lacoste_sneaker': "Lacoste sneaker",
    'sandals': "sandals",
    'suit shoe': "business shoe",
    'vans_classic_slip_on': "Vans slip on",
    'vans_old_school': "Vans old school",
    'vans_sneaker': "Vans sneaker"
}


import joblib
joblib.load("/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/fashion_recommender_app/model_weights/finalized_model.joblib")
loaded_model = pickle.load(open("/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/fashion_recommender_app/model_weights/RF_feature2_final.sav", 'rb'))



# prediction function
def make_recommendation_RF(fp_data, n: int, bla):
  
  # select row for respective obs. and respective values
  obs = fp_data.iloc[0,:].values

  # get prob. of all classes for obs.
  probs = bla.predict_proba(obs.reshape(1,-1))

  # retrieve recommendations
  probs = -probs
  recomm_idx = np.argsort(probs)[0][:n]

  # retrieve model classes
  classes = loaded_model.classes_
  
  # map model classes to nicer ones
  classes = np.array([mapping_same_category[key] for key in classes])

  # select respective classes that should be recommended
  recomm = classes[recomm_idx]
  
  return recomm


