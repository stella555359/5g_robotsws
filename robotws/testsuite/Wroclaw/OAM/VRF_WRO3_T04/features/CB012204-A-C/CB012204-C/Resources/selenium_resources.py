from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

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
                       ],
          }


def log_to_vdu(username, password, address):
    extended_url = "/procedures/ssh-service-account-rannic"
    full_url = address + extended_url
    driver = webdriver.Chrome(chrome_options=profile)
    driver.get(full_url)
    username_field = driver.find_element(By.XPATH, '//*[@id="login-username"]')
    password_field = driver.find_element(By.XPATH, '//*[@id="login-password"]')
    username_field.send_keys(username)
    password_field.send_keys(password)
    login = driver.find_element(By.XPATH, '//*[@id="login-button"]')
    login.click()
    return driver


def confirm_button(driver):
    WebDriverWait(driver, 60).until(EC.visibility_of_element_located((By.XPATH,
                                                                      '//*[@id="laf-component"]/ot-dialog/p-dialog'
                                                                      '/div/div/div[3]/ot-footer/p-button[1]')))
    WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH,
                                                                '//*[@id="laf-component"]/ot-dialog/p-dialog/div/div'
                                                                '/div[3]/ot-footer/p-button[1]')))
    confirm = driver.find_element(By.XPATH,
                                  '//*[@id="laf-component"]/ot-dialog/p-dialog/div/div/div[3]/ot-footer/p-button[1]')
    confirm.click()


def manual_synchro(driver):
    WebDriverWait(driver, 60).until(EC.visibility_of_element_located((By.XPATH,
                                                                      '//*[@id="p-tabpanel-1"]/blocks-service-'
                                                                      'account-ssh-common/div/div/cem-block'
                                                                      '-panel/div/div[2]/div[2]/'
                                                                      'div[2]/cem-operation-button/div/'
                                                                      'p-button/button/span')))
    WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH,
                                                                '//*[@id="p-tabpanel-1"]/blocks-service-account-ssh'
                                                                '-common/div/div/cem-block'
                                                                '-panel/div/div[2]/div[2]/div['
                                                                '2]/cem-operation-button/div/p-button/button/span')))
    confirm = driver.find_element(By.XPATH,
                                  '//*[@id="p-tabpanel-1"]/blocks-service-account-ssh-common/div/div/cem-block-panel'
                                  '/div/div[2]/div[2]/div[2]/cem-operation-button/div/p-button/button/span')
    confirm.click()
