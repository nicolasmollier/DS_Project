from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver import Firefox

import os
import time
import requests
import shutil
import base64

os.chdir('/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/data/google_images/low_resolution')
baseDir=os.getcwd()

options = Options()
options.add_argument("--disable-gpu")
options.add_argument("--disable-extensions")
options.add_argument('--proxy-server="direct://"')
options.add_argument("--proxy-bypass-list=*")
options.add_argument("--start-maximized")
#In headless mode, it is not "displayed", so you can only download around 100 items.

driver = Firefox(executable_path='/home/nicolas/anaconda3/lib/python3.9/site-packages/geckodriver_autoinstaller/v0.30.0/geckodriver')



# queries


names = ["Adidas Shoe", 
          "Adidas Superstar",
          "Adidas Stan Smith",
          "Adidas Ultraboost",
          "Adidas Running",
          "Adidas Continental 80",
          #"Asics Sneaker",
          "Asics Gel",
          "Asics Tiger",
          "Birkenstock Arizona",
          "Birkenstock Madrid",
          "Birkenstock Gizeh",
          "sandals",
          "High Heels",
          "Louboutin Shoes",
          "Winter boot",
          "Autumn boot",
          "Converse chucks high", 
          "Converse chucks low",
          "Crocs",
          "Dr. Martens Boots",
          "Dr. Marten low-level shoes",
          "Nike AirforceOne",
          "Nike Jordans",
          "Nike Running",
          #"Nike Sneaker",
          "Nike Blazer",
          "NewBalance Sneaker",
          "Puma Sneaker",
          "Reebok Sneaker",
          "Sketchers Sneaker",
          "Steve Madden Sneaker",
          "Timberland Boots",
          "Flipflops",
          "Anzugsschuhe",
          "suit shoe",
          "Tommy Hilfiger Sneaker",
          "UGG boots",
          "vans sneaker",
          "vans classic slip on",
          "vans old school",
          "Fila Sneaker", 
          "Gucci Ace", 
          "Kswiss sneaker", 
          "lacoste sneaker"]


queries = [x + " outfit" for x in names]


for n_query in range(len(queries)):
    
    file_name_base = names[n_query].replace(" ", "_")
    query = queries[n_query]
    file_path = baseDir + "/" + file_name_base
    os.mkdir(file_path)


    url = ("https://www.google.com/search?hl=jp&q=" + "+".join(query.split()) + "&btnG=Google+Search&tbs=0&safe=off&tbm=isch")
    driver = Firefox(executable_path='/home/nicolas/anaconda3/lib/python3.9/site-packages/geckodriver_autoinstaller/v0.30.0/geckodriver')
    driver.get(url)

    #Scroll down appropriately--
    for t in range(5):
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight)")
        time.sleep(1.5)
        try:
            #Pressing the button "Show more search results"
            driver.find_element_by_class_name("mye4qd").click() 
        except:
            pass
    for t in range(5):
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight)")
        time.sleep(1.5)

        srcs = driver.find_elements(By.XPATH, '//img[@class="rg_i Q4LuWd"]')

    #Counter for assigning serial numbers to file names
    i = 0 

    print("Downloading...")
    for j, src in enumerate(srcs):
        file_name_number = f"{file_name_base + str(i)}.jpg" 
        if j % 50 == 0 or j == len(srcs)-1:
            print("|"+ ("■" * (20 * j // (len(srcs)-1)))+ (" -" * (20 - 20 * j // (len(srcs)-1)))+ "|",f"{100*j//(len(srcs)-1)}%") #The one that shows the progress of the download
        #file_name = f"{query}/{'_'.join(query.split())}_{str(i).zfill(3)}.jpg " #File name or location
        file_name = os.path.join(file_path, file_name_number)
        src = src.get_attribute("src")
        if src != None:
        #Convert to image--
            if "base64," in src:
                with open(file_name, "wb") as f:
                    f.write(base64.b64decode(src.split(",")[1]))
                    
                
                   
            else:
                res = requests.get(src, stream=True)
                with open(file_name, "wb") as f:
                    shutil.copyfileobj(res.raw, f)

            i += 1

    #close the window
    driver.quit() 
    print(f"Download is complete. {i} images are downloaded.")
    # pause for 5 minutes 
    print("pause for 5 minutes")
    print("break: 5 minutes left")
    time.sleep(60)
    print("break: 4 minutes left")
    time.sleep(60)
    print("break: 3 minutes left")
    time.sleep(60)
    print("break: 2 minutes left")
    time.sleep(60)
    print("break: 1 minutes left")
    time.sleep(60)
    print("end of break")