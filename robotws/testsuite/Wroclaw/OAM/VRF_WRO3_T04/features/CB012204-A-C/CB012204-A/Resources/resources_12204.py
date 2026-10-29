from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from robot.api import logger
import time


default_admin_password = 'nemuuser'
default_admin_username = 'Nemuadmin'
default_root_password = 'oZPS0POrRieRtu'
default_serviceuser_password = 'Pl(FzaYj5~c5;q'
profile = webdriver.ChromeOptions()
profile.add_argument('--window-size=1200,1100')
profile.add_argument('--no-sandbox')
profile.add_argument('--ignore-certificate-errors')
profile.add_argument('--headless')
profile.add_argument('--disable-dev-shm-usage')


xpaths = {'SBTS25R1': ["//h1[normalize-space()='Update default password']",
                       "//i[@class='right-icon pi pi-exclamation-triangle']",
                       "/html[1]/body[1]/login-root[1]/div[1]/change-password[1]/div[1]/p-card[1]/div[1]/div[2]/div[1]"
                       "/div[1]/form[1]/div[2]/input[1]"
                       ]
          }


def log_to_webem(username, password):
    driver = webdriver.Chrome(chrome_options=profile)
    driver.get("https://192.168.255.129")
    username_field = driver.find_element_by_id("login-username")
    password_field = driver.find_element_by_id("login-password")
    username_field.send_keys(username)
    password_field.send_keys(password)
    login = driver.find_element(By.XPATH, '//span[text()="Login"]')
    login.click()
    return driver


def update_passwords(driver, admin_pass, serviceuser_pass, toor4nsn_pass, close=1):
    logger.console("Updating passwords for Nemuadmin")
    WebDriverWait(driver, 120).until(
        EC.visibility_of_element_located((By.XPATH, '/html/body/login-root/div/change-password/div/div/div[2]/div['
                                                    '1]/form/div[2]/div/input')))
    old_pass = driver.find_element(By.XPATH, '/html/body/login-root/div/change-password/div/div/div[2]/div['
                                             '1]/form/div[2]/div/input')
    new_pass_admin = driver.find_element(By.XPATH, '//input[@name=\'password\']')
    repeat_pass = driver.find_element(By.XPATH, '//input[@name=\'confirmPassword\']')
    old_pass.clear()
    new_pass_admin.clear()
    repeat_pass.clear()
    old_pass.send_keys(default_admin_password)
    new_pass_admin.send_keys(admin_pass)
    repeat_pass.send_keys(admin_pass)
    logger.console("Updating Admin password: {admin_pass}".format(admin_pass=admin_pass))
    WebDriverWait(driver, 120).until(EC.visibility_of_element_located((By.XPATH, "//span[normalize-space()='Update']")))
    WebDriverWait(driver, 120).until(EC.element_to_be_clickable((By.XPATH, "//span[normalize-space()='Update']")))
    update = driver.find_element(By.XPATH, "//span[normalize-space()='Update']")
    time.sleep(5)
    update.click()
    time.sleep(15)
    logger.console("Updating passwords for serviceuser")
    WebDriverWait(driver, 120).until(
        EC.visibility_of_element_located((By.XPATH, '/html/body/login-root/div/change-password/div/div/div[2]/div['
                                                    '1]/form/div[2]/div/input')))
    old_pass = driver.find_element(By.XPATH, '/html/body/login-root/div/change-password/div/div/div[2]/div['
                                             '1]/form/div[2]/div/input')
    new_pass_service = driver.find_element(By.XPATH, '//input[@name=\'password\']')
    repeat_pass = driver.find_element(By.XPATH, '//input[@name=\'confirmPassword\']')
    old_pass.clear()
    new_pass_service.clear()
    repeat_pass.clear()
    old_pass.send_keys(default_serviceuser_password)
    new_pass_service.send_keys(serviceuser_pass)
    repeat_pass.send_keys(serviceuser_pass)
    logger.console("Updating serviceuser password: {serviceuser_pass}".format(serviceuser_pass=serviceuser_pass))
    WebDriverWait(driver, 120).until(EC.visibility_of_element_located((By.XPATH, "//span[normalize-space()='Update']")))
    WebDriverWait(driver, 120).until(EC.element_to_be_clickable((By.XPATH, "//span[normalize-space()='Update']")))
    update = driver.find_element(By.XPATH, "//span[normalize-space()='Update']")
    time.sleep(5)
    update.click()
    time.sleep(15)
    logger.console("Updating passwords for toor4nsn")
    WebDriverWait(driver, 120).until(
        EC.visibility_of_element_located((By.XPATH, '/html/body/login-root/div/change-password/div/div/div[2]/div['
                                                    '1]/form/div[2]/div/input')))
    old_pass = driver.find_element(By.XPATH, '/html/body/login-root/div/change-password/div/div/div[2]/div['
                                             '1]/form/div[2]/div/input')
    new_pass_toor = driver.find_element(By.XPATH, '//input[@name=\'password\']')
    repeat_pass = driver.find_element(By.XPATH, '//input[@name=\'confirmPassword\']')
    old_pass.clear()
    new_pass_toor.clear()
    repeat_pass.clear()
    old_pass.send_keys(default_root_password)
    new_pass_toor.send_keys(toor4nsn_pass)
    repeat_pass.send_keys(toor4nsn_pass)
    logger.console("Updating toor4nsn password: {toor4nsn_pass}".format(toor4nsn_pass=toor4nsn_pass))
    WebDriverWait(driver, 120).until(EC.visibility_of_element_located((By.XPATH, "//span[normalize-space()='Update']")))
    WebDriverWait(driver, 120).until(EC.element_to_be_clickable((By.XPATH, "//span[normalize-space()='Update']")))
    update = driver.find_element(By.XPATH, "//span[normalize-space()='Update']")
    time.sleep(5)
    update.click()
    time.sleep(15)
    if close == 1:
        driver.quit()


def get_active_alarm_list(list):
    for alarm in list:
        description = str(alarm["alarmText"]['alarmAdditionalInfo']['supplAlarmInfo'])
        print(description, end="\n\n\n")
