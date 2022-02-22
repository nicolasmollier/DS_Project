#conda install --yes -c pytorch pytorch=1.7.1 torchvision cudatoolkit=11.0
#pip install ftfy regex tqdm
#pip install git+https://github.com/openai/CLIP.git



import torch
import clip
from PIL import Image
import os
from matplotlib import pyplot as plt
import pandas as pd
import numpy as np

os.chdir("/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project")


device = "cuda" if torch.cuda.is_available() else "cpu"
device = "cpu"
model, preprocess = clip.load("ViT-B/32", device=device)


image = preprocess(Image.open("data/google_images/Adidas_Shoe/Adidas_Shoe2.jpg")).unsqueeze(0).to(device)
plt.imshow(image.squeeze(0).to('cpu').permute(1,2,0))


brands = pd.read_table("data/brand_list.csv", delimiter = ";", skiprows=1)
brands = np.array(brands.iloc[:,0])
brands = np.append(brands,["High Heels"])
text = clip.tokenize(brands).to(device)
text


brand = "Adidas_Shoe_Only"
data_file = "data/google_images"
data_file = data_file + "/" + brand
image_files = os.listdir(data_file)
image_files = [image_file for image_file in image_files if "xml" not in image_file]
brand_prediction = []

for image_file in image_files:
    image_path = data_file + "/" + image_file
    image = preprocess(Image.open(image_path)).unsqueeze(0).to(device)
    
    
    with torch.no_grad():
        image_features = model.encode_image(image)
        text_features = model.encode_text(text)
        
        logits_per_image, logits_per_text = model(image, text)
        probs = logits_per_image.softmax(dim=-1).cpu().numpy()

    #print("Label probs:", probs)

    # Pick the top 5 most similar labels for the image
    image_features /= image_features.norm(dim=-1, keepdim=True)
    text_features /= text_features.norm(dim=-1, keepdim=True)
    similarity = (100.0 * image_features @ text_features.T).softmax(dim=-1)
    values, indices = similarity[0].topk(5)
    _, index_pred = similarity[0].topk(1)
    brand_prediction.append(brands[index_pred.item()] == "Adidas")

    # Print the result
    print("\nTop predictions:\n")
    for value, index in zip(values, indices):
        print(f"{brands[index]:>16s}: {100 * value.item():.2f}%")
    plt.imshow(image.squeeze(0).cpu().permute(1,2,0))
    plt.show()


np.array(brand_prediction).mean()
