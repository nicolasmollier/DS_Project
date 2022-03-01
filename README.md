# DS_Project
Master in Data Science in Business and Economics: DS Project

## 1. What is this project about

This project is about building an application that allows users to get fashion recommendations based on user input (selection or uploads). To this end, we scraped around 17,000 outfit images from Google that contain 42 different shoe types (different brands and models). We then extracted the fashion (=clothing) items and their attributes from each image in order to build a database that contains information about which shoes are combined with which fashion items and their corresponding attributes. The final application consists of three main features:

### Feature 1: Outfit recommendation

The user selects a shoe from the image gallery. Then, one can specify the gender, the country of origin and choose specific items to get recommendations for. Based on the selected shoe, the database is filtered. For the 5 most likely fashion items (and their most likely attribute) that are worn with this kind of shoe, queries are sent to online shopping website Asos. For each recommended item, the top three items (according to Asos' ranking) are used for the recommendation. The images and prices of those items are scraped from Asos and displayed as recommendations inside the user interface of the application. For more details on how the images and prices are scraped from within the app, see **server.R** and the respective functions in **feature_1_functions.R** and **feature_2_and_3_functions.R**.

### Feature 2: Shoe recommendation

The user uploads an image of an entire outfit. The attribute mask R-CNN model is applied to the uploaded image to extract the fasion items worn in the outfit and their respective attributes. As a result, we get the fashion items together with probabilities for the presence of certain attributes in this image. Based on this user upload and the extracted information from it, the app returns three shoe types as recommendations by finding the most similar outfits in the database. The most similar outfits are found by looking at the terminal nodes of a random forest model that was trained and tuned on our database (see 1. above). Images and prices for the recommended shoes are again scraped from Asos inside the app. The model training script can be found on Google Drive in following folder: scripts/preparation_scripts/model_training/. See below for more information on how to access the scripts on Google Drive.

### Feature 3: Outfit evaluation

The user uploads both an image of a shoe and an image of an entire outfit. The outfit image is processed in the same way as in feature 2. The shoe image is classified by the classifier in scripts/inference_onnx.py which uses the trained model weights in model_weights/classifier.onnx. The database then is filtered again with respect to the predicted shoe type. For each class depicted in the uploaded body shot (with at least a probability of 60%), the vector of attribute probability is compared to the aggregated vector for that particular class of the database. Then, the cosine similarity score with respect to each class is computed and depicted in the user interface. For the item class that is most different, the user obtains a better suited item-attribute-combination to increase the similarity score to the database. Moreover, three further items are depcited in order to complement the outfit at hand.

## 2. Repository structure

The folder **fashion_recommender_app** contains necessary files for running/deploying the app. Inside this folder, you will find an Rproj file. If you open this file in RStudio, all the paths in the other files are interpreted relativily to the folder in which the Rproj file lies. The file **global.R** loads the necessary data and sources all the scripts that are required in the server part of the application. The scripts lie inside the *scripts* folder within the **fashion_recommender_app** folder (see 2.1. below). The file **ui.R** contains the UI-part of the app whereas **server.R** contains the back-end of the app (calculations performed in the background based on user input). In Shiny-Server, **global.R**, **ui.R** and **server.R** are executed automatically. 

### 2.1. The scripts folder

#### 2.1.1. Functions

**fashionpedia_python_script.R**
- can be used to apply the attribute mask R-CNN model on a single image (inside the app in feature 2 and 3)
- can be used to apply the attribute mask R-CNN model on a group of folders with outfit images in order to create a database as the foundation for the recommendations (Note, that the paths in this file are set in a way that allows the script to work inside the app on the bwCloud. If you want to use this script outside of the app, you will need to change the paths accordingly.)

**feature_1_functions.R**
- contains necessary functions needed in feature 1 of the app (outfit recommendation) as well as scraping functions for the live-scrape from Asos.

**feature_2_and_3_functions.R**
- contains functions needed in feature 2 and 3 of the app (shoe recommendation / outfit evaluation)

**img_download.py** and **img_downloader_version2.py**
- Scripts used to scrape outfit images from Google which were then later used to build the database by applying the attribute mask R-CNN model on them in a second step. (see *fashionpedia_python_script.R**)

**inference_onnx.py**
- Functions to be used for applying the shoe classifier inside the app since the prior torch-model could not be executed in the bwCloud

#### 2.1.2. App appearance

**create_img_tags.R**
- creates image tags for the images to be displayed in the app in the shoe gallery
- it loops through the images in www/img and saves the HTML tags in **img_html**
**dashboard_logo.R**
**dashboard_theme.R**
- contains the theme choices controlling the app design and app interfaces

## 3. How to deploy this application

First of all, put the folder **fashion_recommender_app** in the folder srv/shiny-server in a bwCloud instance. Note, that you will have to change the ownership and the rights for certain folders in the bwCloud instance for the app to run. For example, the shiny user has to have proper rights for the scripts to be executed. We recommend to install all the R and Python packages in the RStudio Server and a command windox (f.ex. PuTTY), respectively and to keep an eye on the storage space (it is limited to 12 GB). When all files are loaded, the instance is active and all packages are installed, the application will be running.

### 3.1. What else is needed

Since the following folders are large in size, they are not included in this repository. Instead they can be accessed at https://drive.google.com/drive/u/0/folders/1_ZqrOthCsygdpKpe7f4ljx-3eJfJCnIt 

*data*
- data/scraped_google_images/low_resolution/ contains folders labeled by shoe brand and shoe type, respectively, where each of them contains outfit images that combine fashion items with the respective shoe.

*model weights*
- contains the model weights of the models used in the app, except for the attribute mask R-CNN model which can be found inside the tpu folder (see below)

*tpu*
- contains the fashionpedia repository. Note that it is not identical to the one found in https://github.com/tensorflow/tpu since we had to make changes in order to make it run in our local version and to re-write the fashionpedia script in order to make it usable as a function.

*www*
- contains the folder *img* which in turn contains the shoe images to be displayed in the app (shoe gallery)

Note: All four folders (*data*, *model_weights*, *tpu* and *www*) have to be placed in the same folder as the Rproj, ui.R, server.R and global.R files

### 3.2. How tun run the app locally on your PC

As described in 3.1., put the *data*, *model_weights*, *tpu* and *www* folders from the google drive inside the same folder as the Rproj, ui.R, server.R and global.R files. For coud deployment, shiny-server needs the app to be split into *global.R*, *server.R* and *ui.R*. However, for using the app locally, you will need to copy and paste the content of *global.R*, *server.R* and *ui.R* into a new file *app.R*. Note that the ordering is important: The part from *global.R* needs to be executed first. After that add the following line at the end of *app.R*: shinyApp(ui, server). Furthermore, *app.R* needs to be saved in the same folder as the Rproj file. Since the code was written to work on the bwCloud, for running the app locally, one path in the file **fashion_recommender_app/scripts/fashionpedia_python_script.py** file needs to be adapted in line 44. Change the path to where **fashion_recommender_app/tpu/models** is saved on your local machine. 

Now, open the project by double-clicking on the Rproj file. RStudio will oben. Next, open app.R in your Rstudio and click the Run app Button in RStudio in order to run the app.



If you want to take a look at scripts that were used in preparation for the app functionality, take a look at the additional files in https://drive.google.com/drive/u/0/folders/1UHUgOhLlW-B1K-AQVJKb6nOtXdLd9E0V


