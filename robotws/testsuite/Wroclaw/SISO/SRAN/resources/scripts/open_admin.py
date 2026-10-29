from selenium import webdriver

link = "https://192.168.255.129/#/login"
options = webdriver.ChromeOptions()
options.add_argument('ignore-certificate-errors')

driver = webdriver.Chrome(chrome_options=options)
driver.get(link)
driver.maximize_window()

find_login = driver.find_elements_by_class_name("ng-pristine")
find_login[1].send_keys("Nemuadmin")
find_password = driver.find_elements_by_class_name("ng-pristine")
find_password[0].send_keys("nemuuser")
click_login_button = driver.find_elements_by_class_name("p-button")
click_login_button[0].click()
