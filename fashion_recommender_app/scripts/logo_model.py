#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Nov  2 15:42:18 2021

@author: nicolas
"""

# Packages

import torch
from torchvision import transforms, datasets
from matplotlib import pyplot as plt
import torchvision.models as models
import torchvision.models.detection.faster_rcnn
from torchvision.models.detection.faster_rcnn import FastRCNNPredictor
from torchvision.models.detection.mask_rcnn import MaskRCNNPredictor
import os
import datetime
from torch import nn


# Working Directory

os.chdir("/home/nicolas/Desktop/Uni/WiSe21_22/Project")



# Definitions

exec(open("scripts/definitions.py").read())




# Set Seed

torch.manual_seed(42)






# Load the Data + Train-Test-Split

logo_train = datasets.ImageFolder(root = "/home/nicolas/Desktop/Uni/WiSe21_22/Project/data/logo_2_k/train_and_test/train/Clothes",
                                  transform = transforms.ToTensor())

logo_test = datasets.ImageFolder(root = "/home/nicolas/Desktop/Uni/WiSe21_22/Project/data/logo_2_k/train_and_test/test/Clothes",
                                  transform = transforms.ToTensor())

n_train = int(0.9 * len(logo_train))
n_val = len(logo_train) - n_train
logo_train, logo_val = torch.utils.data.random_split(logo_train, [n_train, n_val])





# Channel Means and SDs
#imgs = torch.stack([img for img, _ in logo_train], dim = 3)
#channel_means = imgs.reshape(3,-1).mean(dim = 1)
#channel_stds = imgs.reshape(3,-1).std(dim = 1)

#channel_means
#channel_stds
#del imgs





# Data Transformation + Dataloader

transformer_train = transforms.Compose([
                transforms.Normalize([0.7041, 0.6786, 0.6721], [0.3786, 0.3829, 0.3839]),
                transforms.RandomRotation(30),
                transforms.RandomHorizontalFlip()
                ])

transformer_val_test = transforms.Compose([
                transforms.Normalize([0.7041, 0.6786, 0.6721], [0.3786, 0.3829, 0.3839])
                ])


logo_train = map_df(logo_train, transformer_train)
logo_val = map_df(logo_val, transformer_val_test)
logo_test = map_df(logo_test, transformer_val_test)


logo_datasets = {'train': logo_train, 'val': logo_val, 'test': logo_test} 

dataloaders = {x: torch.utils.data.DataLoader(logo_datasets[x], batch_size=8, shuffle=True) for x in ['train', 'val']}

dataset_sizes = {x: len(logo_datasets[x]) for x in ['train', 'val']}

device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")





# Model, Criterion, Optimizer

model_ft = models.resnet50(pretrained=True)


n_in_features = model_ft.fc.in_features

n_brands = len(os.listdir("/home/nicolas/Desktop/Uni/WiSe21_22/Project/data/logo_2_k/train_and_test/train/Clothes"))

model_ft.fc = nn.Linear(n_in_features, n_brands)
model_ft = model_ft.to(device)

criterion = nn.CrossEntropyLoss()
#criterion.requres_grad = True

for param in model_ft.parameters():
    param.requires_grad = True


optimizer_ft = torch.optim.SGD([
        {"params": model_ft.conv1.parameters(), "lr": 1e-7},
        {"params": model_ft.layer1.parameters(), "lr": 1e-6},
        {"params": model_ft.layer2.parameters(), "lr": 1e-5},
        {"params": model_ft.layer3.parameters(), "lr": 1e-4},
        {"params": model_ft.layer4.parameters(), "lr": 1e-3},
        {"params": model_ft.fc.parameters(), "lr": 1e-2}
    ], lr=5e-4
)



    

# Model Training

model_ft[0].weight.data.device

train_model(model_ft, criterion, optimizer_ft, dataloaders, num_epochs=10, decay_rate = 0.3, step_size = 4)







# Faster RCNN

# Model, Criterion, Optimizer

model_ft = torchvision.models.detection.fasterrcnn_resnet50_fpn(pretrained=True)
model_ft.roi_heads

n_in_features = model_ft.fc.in_features

n_brands = len(os.listdir("/home/nicolas/Desktop/Uni/WiSe21_22/Project/data/logo_2_k/train_and_test/train/Clothes"))

model_ft.fc = nn.Linear(n_in_features, n_brands)
model_ft = model_ft.to(device)

criterion = nn.CrossEntropyLoss()
#criterion.requres_grad = True

for param in model_ft.parameters():
    param.requires_grad = True


optimizer_ft = torch.optim.SGD([
        {"params": model_ft.conv1.parameters(), "lr": 1e-7},
        {"params": model_ft.layer1.parameters(), "lr": 1e-6},
        {"params": model_ft.layer2.parameters(), "lr": 1e-5},
        {"params": model_ft.layer3.parameters(), "lr": 1e-4},
        {"params": model_ft.layer4.parameters(), "lr": 1e-3},
        {"params": model_ft.fc.parameters(), "lr": 1e-2}
    ], lr=5e-4
)
FastRCNNPredictor.layer1
model_ft.layer1
