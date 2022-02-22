# -*- coding: utf-8 -*-
"""
Created on Sun Dec 12 15:54:32 2021

@author: Study
"""


import numpy as np
import pandas as pd
#from matplotlib import pyplot as plt
#import seaborn as sns
import torch

# define mapping
mapping_result = {
   0: "Adidas Continental 80",
   1: "Adidas Shoe",
   2: "Adidas Stan Smith",
   3: "Adidas Ultraboost",
   4: "Asics Gel",
   5: "Asics Tiger", # Asics Sneaker
   6: "Birkenstock Arizona",
   7: "Birkenstock Gizeh",
   8: "Birkenstock Madrid",
   9: "Converse chucks high",
   10: "Converse chucks low",
   11: "Crocs",
   12: "Dr. Martens Boots",
   13: "Fila Sneaker",
   14: "Flipflops",
   15: "Gucci Ace",
   16: "Kswiss sneaker",
   17: "NewBalance Sneaker",
   18: "Nike AirforceOne",
   19: "Nike Blazer",
   20: "Nike Jordans",
   21: "Nike Running", # Nike Sneaker
   22: "Puma Sneaker",
   23: "Reebok Sneaker",
   24: "Sketchers Sneaker",
   25: "Steve Madden Sneaker",
   26: "Timberland Boots",
   27: "Tommy Hilfiger Sneaker", 
   28: "UGG boots",
   29: "Winter boots",
   30: "sandals", # Ballerinas
   31: "suit shoe",
   32: "High Heels", 
   33: "lacoste sneaker",
   34: "sandals",
   35: "vans classic slip on",
   36: "vans sneaker"
   }


# import images
from torchvision import transforms
from torchvision import datasets
#transform = transforms.Compose([transforms.ToTensor()])

# load model
model_weights = torch.load("model_weights/Brands_classifier_v2.pt", map_location=torch.device('cpu'))
model_weights = model_weights.eval()
#image = datasets.ImageFolder("/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/fashion_recommender_app/Adidas_Shoe") 



def return_shoe_type(model, image):
    image = torch.Tensor(image)
    image = image.permute(2,0,1)
    transform = transforms.Resize((224, 224))
    image = transform(image)
    #_, class_pred = torch.max(model(image[0][0].unsqueeze(0)), 1)
    _, class_pred = torch.max(model(image.unsqueeze(0)), 1)
    class_pred = class_pred.detach().numpy()
    class_pred_mapped = np.vectorize(mapping_result.get)(class_pred)[0]
    return class_pred_mapped

#classes = return_shoe_type(model, image)


