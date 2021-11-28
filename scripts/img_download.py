from selenium import webdriver
import time
from selenium.webdriver import Firefox
from selenium.common.exceptions import ElementClickInterceptedException
from selenium.common.exceptions import ElementNotInteractableException
import os
import io
from PIL import Image
import requests
from selenium.webdriver.common.keys import Keys


# working directory + base directory for images
os.chdir('/home/nicolas/Desktop/Uni/WiSe21_22/DS_Project/data/google_images')
baseDir=os.getcwd()


opts = webdriver.FirefoxOptions()
opts.headless =True

# Creating a webdriver instance
driver = Firefox(executable_path='/home/nicolas/anaconda3/lib/python3.8/site-packages/geckodriver_autoinstaller/v0.30.0/geckodriver')

search_url="https://www.google.com/search?q={}&tbm=isch&tbs=sur%3Afc&hl=en&ved=0CAIQpwVqFwoTCKCa1c6s4-oCFQAAAAAdAAAAABAC&biw=1251&bih=568" 



# queries


names = ["Adidas Shoe", "Nike Shoe"]

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


# Anzahl Bilder pro Query
limit = 300


for n_query in range(len(queries)):
    file_name_base = names[n_query].replace(" ", "_")
    query = queries[n_query]
    file_path = baseDir + "/" + file_name_base
    os.mkdir(file_path)
    print(file_name_base)
    time.sleep(200)

    #set chromodriver.exe path
    driver.implicitly_wait(0.5)
    #launch URL
    driver.get(search_url)

    #identify search box
    imgResults = driver.find_element_by_name("q")
    #totalResults=len(imgResults)
    

    #enter search text
    imgResults.send_keys(query)
    #perform Google search with Keys.ENTER
    imgResults.send_keys(Keys.ENTER)
    
    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);") 
    time.sleep(5)

    imgResults = driver.find_elements_by_xpath("//img[contains(@class,'Q4LuWd')]") 
    totalResults=len(imgResults) 


    #Click on each Image to extract its corresponding link to download

    img_urls = set()
    for i in  range(0,len(imgResults)):
        if i >= limit:
            print(i)
            break
        img=imgResults[i]
        try:
            img.click()
            time.sleep(2)
            actual_images = driver.find_elements_by_css_selector('img.n3VNCb')
            for actual_image in actual_images:
                if actual_image.get_attribute('src') and 'https' in actual_image.get_attribute('src'):
                    img_urls.add(actual_image.get_attribute('src'))
        except ElementClickInterceptedException or ElementNotInteractableException as err:
            print(err)




    for i, url in enumerate(img_urls):
        file_name = f"{file_name_base + str(i)}.jpg" 
        try:
            image_content = requests.get(url).content

        except Exception as e:
            print(f"ERROR - COULD NOT DOWNLOAD {url} - {e}")

        try:
            image_file = io.BytesIO(image_content)
            image = Image.open(image_file).convert('RGB')
        
            image_path = os.path.join(file_path, file_name)
        
            #with open(file_path, 'wb') as f:
            image.save(image_path, "JPEG", quality=85)
            print(f"SAVED - {url} - AT: {file_path}")
        except Exception as e:
            print(f"ERROR - COULD NOT SAVE {url} - {e}")
  
