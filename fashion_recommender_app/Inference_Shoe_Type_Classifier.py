# -*- coding: utf-8 -*-
"""
Created on Sun Dec 12 15:54:32 2021

@author: Study
"""

import torch
import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
import seaborn as sns
import torch

# define mapping
mapping_result = {
   0: "Adidas Continental 80",
   1: "Adidas Sneaker",
   2: "Asics Gel",
   3: "Birkenstock Arizona",
   4: "Birkenstock Gizeh",
   5: "Birkenstock Madrid",
   6: "Converse chucks high",
   7: "Converse chucks low",
   8: "Crocs",
   9: "Dr. Martens Boots",
   10: "Fila Sneaker",
   11: "Flipflops",
   12: "Kswiss sneaker",
   13: "New Balance Sneaker",
   14: "Nike Sneaker",
   15: "Puma Sneaker",
   16: "Reebok Sneaker",
   17: "Sketchers Sneaker",
   18: "Steve Madden Sneaker",
   19: "Timberland ",
   20: "Tommy Hilfiger Sneaker", 
   21: "UGG Stiefel",
   22: "Winter Stiefel",
   23: "business schuhe",
   24: "high pumps", 
   25: "lacoste sneaker",
   26: "sandals",
   27: "vans slip on",
   28: "vans sneaker"
   }

# import images
from torchvision import transforms
from torchvision import datasets
transform = transforms.Compose([transforms.Resize(224),transforms.ToTensor()])

# load model
model = torch.load("model_weights/Brands_classifier_5.pt", map_location=torch.device('cpu'))
model = model.eval()
#image = datasets.ImageFolder("Adidas_Shoe", transform = transform) 



def return_shoe_type(model, image):
    image = transforms.Resize(image, 224)
    image = image.permute(2,0,1)
    #_, class_pred = torch.max(model(image[0][0].unsqueeze(0)), 1)
    _, class_pred = torch.max(model(image.unsqueeze(0)), 1)
    class_pred = class_pred.detach().numpy()
    class_pred_mapped = np.vectorize(mapping_result.get)(class_pred)[0]
    return [class_pred, class_pred_mapped] 

# classes = return_shoe_type(model, image)





