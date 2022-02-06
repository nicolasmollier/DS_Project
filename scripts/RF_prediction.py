# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""


import sklearn
import pickle
import numpy as np


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
    'Converse_chucks_high': "Chucks",
    'Converse_chucks_low': "Chucks",
    'Crocs': "Crocs",
    'Dr._Marten_low-level_shoes': "Dr. Martens low-level shoe",
    'Dr._Martens_Boots': "Dr. Martens boot",
    'Fila_Sneaker': "Fila sneaker",
    'Flipflops': "flipflops",
    'Gucci_Ace': "Gucci Ace",
    'High_Heels': "high heels",
    'Kswiss_sneaker': "Kswiss sneaker",
    'Louboutin_Shoes': "Louboutin high heel",
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
    'UGG_boots': "UGG boot",
    'Winter_boot': "Winter boot",
    'lacoste_sneaker': "Lacoste sneaker",
    'sandals': "sandals",
    'suit_shoe': "business shoe",
    'vans_classic_slip_on': "Vans slip on",
    'vans_old_school': "Vans old school",
    'vans_sneaker': "Vans sneaker"
}





# load the model from disk
filename = 'models/finalized_model.sav'
loaded_model = pickle.load(open(filename, 'rb'))


# prediction function
def make_recommendation_RF(fp_data, n: int):
  
  # select row for respective obs. and respective values
  obs = fp_data[0]

  # get prob. of all classes for obs.
  probs = loaded_model.predict_proba(obs.reshape(1,-1))

  # retrieve recommendations
  probs = -probs
  recomm_idx = np.argsort(probs)[0][:n]

  # retrieve model classes
  classes = loaded_model.classes_
  
  # map model classes to nicer ones
  classes = [mapping_same_category[key] for key in classes]

  # select respective classes that should be recommended
  recomm = classes[recomm_idx]
  
  return recomm
