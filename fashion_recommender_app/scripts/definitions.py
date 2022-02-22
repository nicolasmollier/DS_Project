# Packages

import torch
from matplotlib import pyplot as plt
import datetime
import numpy as np
import torchvision.transforms.functional as F




# Definitions

def train_model(model, criterion, optimizer, dataloaders, num_epochs=25, decay_rate = 0.4, step_size = 10):
    lr_scheduler = torch.optim.lr_scheduler.StepLR(optimizer, step_size = step_size, gamma=decay_rate, last_epoch=-1, verbose=False)
    loss_history = {'train': [], 'val': []}
    acc_history = {'train': [], 'val': []}
    for epoch in range(num_epochs):
        print('Epoch {}/{} ({})'.format(epoch, num_epochs - 1,  datetime.datetime.now()))
        print('-' * 10)

        # Each epoch has a training and validation phase
        for phase in ['train', 'val']:
            if phase == 'train':
                model.train()  # Set model to training mode
            else:
                model.eval()   # Set model to evaluate mode

            running_loss = 0.0
            running_corrects = 0

            # Iterate over data.
            for inputs, labels in dataloaders[phase]:
                inputs = inputs.to(device)
                labels = labels.to(device)

                # zero the parameter gradients
                optimizer.zero_grad()

                # forward, track history if only in train
                with torch.set_grad_enabled(phase == 'train'):
                    outputs = model(inputs)
                    _, preds = torch.max(outputs, 1)
                    loss = criterion(outputs, labels)

                    # backward + optimize only if in training phase
                    if phase == 'train':
                        loss.backward()
                        optimizer.step()

                # statistics
                running_loss += loss.item() * inputs.size(0)
                running_corrects += torch.sum(preds == labels.data)

            epoch_loss = running_loss / dataset_sizes[phase]
            epoch_acc = running_corrects.double() / dataset_sizes[phase]
            loss_history[phase].append(epoch_loss)
            acc_history[phase].append(epoch_acc)
            print('{} Loss: {:.4f} Acc: {:.4f}'.format(
                phase, epoch_loss, epoch_acc))
        lr_scheduler.step()
    plt.plot(loss_history['train'], label = 'train')
    plt.plot(loss_history['val'], label = 'val')
    plt.legend()  
    

class map_df(torch.utils.data.Dataset):
    def __init__(self, dataset, map_fn):
        self.dataset = dataset
        self.map = map_fn

    def __getitem__(self, index):
        return (self.map(self.dataset[index][0]), self.dataset[index][1])

    def __len__(self):
        return len(self.dataset)
    
    
class SquarePad:
	def __call__(self, image):
		w, h = image.size
		max_wh = np.max([w, h])
		hp = int((max_wh - w) / 2)
		vp = int((max_wh - h) / 2)
		padding = (hp, vp, hp, vp)
		return F.pad(image, padding, 0, 'constant')