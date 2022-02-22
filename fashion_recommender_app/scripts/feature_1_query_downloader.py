from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver import Firefox




options = Options()
options.add_argument("--disable-gpu")
options.add_argument("--disable-extensions")
options.add_argument('--proxy-server="direct://"')
options.add_argument("--proxy-bypass-list=*")
options.add_argument("--start-maximized")
options.add_argument("headless") 
#In headless mode, it is not "displayed", so you can only download around 100 items.







def feature_1_scrape(query):
    driver = Firefox(executable_path='/home/nicolas/anaconda3/lib/python3.9/site-packages/geckodriver_autoinstaller/v0.30.0/geckodriver')
    url = "https://www.asos.com/us/search/?page=1&q=" + query
    driver = Firefox(executable_path='/home/nicolas/anaconda3/lib/python3.9/site-packages/geckodriver_autoinstaller/v0.30.0/geckodriver')
    driver.get(url)

    

    srcs = driver.find_elements(By.XPATH, '//*[contains(concat( " ", @class, " " ), concat( " ", "_2r9Zh0W", " " ))]')
    srcs_2 = driver.find_elements(By.XPATH, '//*[contains(concat( " ", @class, " " ), concat( " ", "_16nzq18", " " ))]')

    #Counter for assigning serial numbers to file names
    feature_1_link_df = []
    
    for src in srcs[:3]:
        src = src.get_attribute("src")
        if src != None:
            feature_1_link_df.append(src)

    feature_1_price_df = []
    
    for src_2 in srcs_2[:3]:
        src = src_2.text
        if src != None:
            feature_1_price_df.append(src)
    
    return([feature_1_link_df, feature_1_price_df])
            

