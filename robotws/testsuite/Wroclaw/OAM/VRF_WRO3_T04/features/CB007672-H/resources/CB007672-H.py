from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from robot.api import logger
import time

default_admin_password = 'nemuuser'
profile = webdriver.ChromeOptions()
profile.add_argument('--window-size=1200,1100')
profile.add_argument('--no-sandbox')
profile.add_argument('--ignore-certificate-errors')
profile.add_argument('--headless')
profile.add_argument('--disable-dev-shm-usage')

xpaths = {'SBTS22R2': ["//h1[normalize-space()='Update default password']",
                       "//i[@class='right-icon pi pi-exclamation-triangle']",
                       "/html[1]/body[1]/login-root[1]/div[1]/change-password[1]/div[1]/p-card[1]/div[1]/div[2]/div[1]"
                       "/div[1]/form[1]/div[2]/input[1]"
                       ],
          'SBTS22R3': ["//div[@class='ot-login-title']",
                       "//span[@class='p-inputgroup-addon mdi mdi-alert']",
                       "/html[1]/body[1]/login-root[1]/div[1]/change-password[1]/div[1]/div[1]/div[1]/div[1]/form[1]/"
                       "div[2]/div[1]/input[1]"
                       ],
          'SBTS22R4': ["//div[@class='ot-login-title']",
                       "//span[@class='p-inputgroup-addon mdi mdi-alert']",
                       "/html[1]/body[1]/login-root[1]/div[1]/change-password[1]/div[1]/div[1]/div[1]/div[1]/form[1]/"
                       "div[2]/div[1]/input[1]"
                       ],
          'SBTS23R1': ["//div[@class='ot-login-title']",
                       "//span[@class='p-inputgroup-addon mdi mdi-alert']",
                       "/html[1]/body[1]/login-root[1]/div[1]/change-password[1]/div[1]/div[1]/div[1]/div[1]/form[1]/"
                       "div[2]/div[1]/input[1]"
                       ],
          'SBTS23R2': ["//div[@class='ot-login-title']",
                       "//span[@class='p-inputgroup-addon mdi mdi-alert']",
                       "/html[1]/body[1]/login-root[1]/div[1]/change-password[1]/div[1]/div[1]/div[1]/div[1]/form[1]/"
                       "div[2]/div[1]/input[1]"
                       ],
          'SBTS23R3': ["//div[@class='ot-login-title']",
                       "//span[@class='p-inputgroup-addon mdi mdi-alert']",
                       "/html[1]/body[1]/login-root[1]/div[1]/change-password[1]/div[1]/div[1]/div[1]/div[1]/form[1]/"
                       "div[2]/div[1]/input[1]"
                       ],
          'SBTS23R4': ["//div[@class='ot-login-title']",
                       "//span[@class='p-inputgroup-addon mdi mdi-alert']",
                       "/html[1]/body[1]/login-root[1]/div[1]/change-password[1]/div[1]/div[1]/div[1]/div[1]/form[1]/"
                       "div[2]/div[1]/input[1]"
                       ],
          'SBTS24R1': ["//div[@class='ot-login-title']",
                       "//span[@class='p-inputgroup-addon mdi mdi-alert']",
                       "/html[1]/body[1]/login-root[1]/div[1]/change-password[1]/div[1]/div[1]/div[1]/div[1]/form[1]/"
                       "div[2]/div[1]/input[1]"
                       ],
          'SBTS24R2': ["//div[@class='ot-login-title']",
                       "//span[@class='p-inputgroup-addon mdi mdi-alert']",
                       "/html[1]/body[1]/login-root[1]/div[1]/change-password[1]/div[1]/div[1]/div[1]/div[1]/form[1]/"
                       "div[2]/div[1]/input[1]"
                       ],
          'SBTS24R3': ["//div[@class='ot-login-title']",
                       "//span[@class='p-inputgroup-addon mdi mdi-alert']",
                       "/html[1]/body[1]/login-root[1]/div[1]/change-password[1]/div[1]/div[1]/div[1]/div[1]/form[1]/"
                       "div[2]/div[1]/input[1]"
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


def check_if_update_window_appears(driver, sw_release):
    WebDriverWait(driver, 120).until(EC.visibility_of_element_located((By.XPATH, xpaths[sw_release][0])))


def update_with_incorrect_new_password(driver, sw_release):
    logger.console("Updating password with incorrect new passwords")
    list_of_pass = [gen.generate_too_short_password(), gen.generate_no_special_character_password(),
                    gen.generate_no_digit_password(), gen.generate_two_same_characters_in_row_password(),
                    gen.generate_no_upcase_letter_password(), gen.generate_only_one_digit_password(),
                    gen.generate_password_containing_username('Nemuadmin'), gen.generate_too_long_password(),
                    gen.generate_no_lowcase_letter_password()]
    WebDriverWait(driver, 120).until(
        EC.visibility_of_element_located((By.XPATH, xpaths[sw_release][2])))
    old_pass = driver.find_element(By.XPATH, xpaths[sw_release][2])
    new_pass = driver.find_element(By.XPATH, "//input[@name='password']")
    repeat_pass = driver.find_element(By.XPATH, "//input[@name='confirmPassword']")
    for passw in list_of_pass:
        old_pass.clear()
        new_pass.clear()
        repeat_pass.clear()
        old_pass.send_keys(default_admin_password)
        new_pass.send_keys(passw)
        repeat_pass.send_keys(passw)
        logger.console("Updating with wrong new password: {passw}".format(passw=passw))
        WebDriverWait(driver, 120).until(
            EC.visibility_of_element_located((By.XPATH, xpaths[sw_release][1])))
    driver.quit()


def update_with_incorrect_old_password(driver, sw_release):
    logger.console("Updating password with incorrect old password")
    wrong_pass = gen.generate_too_short_password()
    correct_pass = gen.generate_correct_password()
    WebDriverWait(driver, 120).until(
        EC.visibility_of_element_located((By.XPATH, xpaths[sw_release][2])))
    old_pass = driver.find_element(By.XPATH, xpaths[sw_release][2])
    new_pass = driver.find_element(By.XPATH, '//input[@name=\'password\']')
    repeat_pass = driver.find_element(By.XPATH, '//input[@name=\'confirmPassword\']')
    old_pass.clear()
    new_pass.clear()
    repeat_pass.clear()
    old_pass.send_keys(wrong_pass)
    new_pass.send_keys(correct_pass)
    repeat_pass.send_keys(correct_pass)
    logger.console("Updating password with wrong old password: {wrong_pass}, new password: {correct_pass}".format(
        wrong_pass=wrong_pass, correct_pass=correct_pass))
    WebDriverWait(driver, 120).until(EC.visibility_of_element_located((By.XPATH,
                                                                       '//span[normalize-space()=\'Update\']')))
    WebDriverWait(driver, 120).until(EC.element_to_be_clickable((By.XPATH, '//span[normalize-space()=\'Update\']')))
    update = driver.find_element(By.XPATH, "//span[normalize-space()='Update']")
    time.sleep(5)
    update.click()
    WebDriverWait(driver, 120).until(
        EC.visibility_of_element_located((By.XPATH, '/html[1]/body[1]/login-root[1]/div[1]/change-password[1]/div[1]/'
                                                    'div[1]/p-footer[1]/div[1]/div[2]/ot-instruction[1]/div[1]'
                                                    '/span[1]')))
    driver.find_element(By.XPATH, '/html[1]/body[1]/login-root[1]/div[1]/change-password[1]/div[1]/div[1]/p-footer[1]'
                                  '/div[1]/div[2]/ot-instruction[1]/div[1]/span[1]')


def update_password(driver, sw_release, correct_new_pass, close=1):
    logger.console("Updating password with correct password")
    WebDriverWait(driver, 120).until(
        EC.visibility_of_element_located((By.XPATH, xpaths[sw_release][2])))
    old_pass = driver.find_element(By.XPATH, xpaths[sw_release][2])
    new_pass = driver.find_element(By.XPATH, '//input[@name=\'password\']')
    repeat_pass = driver.find_element(By.XPATH, '//input[@name=\'confirmPassword\']')
    old_pass.clear()
    new_pass.clear()
    repeat_pass.clear()
    old_pass.send_keys(default_admin_password)
    new_pass.send_keys(correct_new_pass)
    repeat_pass.send_keys(correct_new_pass)
    logger.console("Updating with correct password: {correct_new_pass}".format(correct_new_pass=correct_new_pass))
    WebDriverWait(driver, 120).until(EC.visibility_of_element_located((By.XPATH, "//span[normalize-space()='Update']")))
    WebDriverWait(driver, 120).until(EC.element_to_be_clickable((By.XPATH, "//span[normalize-space()='Update']")))
    update = driver.find_element(By.XPATH, "//span[normalize-space()='Update']")
    time.sleep(5)
    update.click()
    WebDriverWait(driver, 120).until(EC.visibility_of_element_located((By.XPATH,
                                                                       '//div[text()=" Web Element Manager "]')))
    driver.find_element(By.XPATH, '//div[text()=" Web Element Manager "]')
    if close == 1:
        driver.quit()
    return correct_new_pass


def update_with_different_new_passwords(driver, sw_release):
    logger.console("Updating password with incorrect new passwords")
    wrong_pass1 = gen.generate_too_short_password()
    wrong_pass2 = gen.generate_no_lowcase_letter_password()
    WebDriverWait(driver, 60).until(
        EC.visibility_of_element_located((By.XPATH, xpaths[sw_release][2])))
    old_pass = driver.find_element(By.XPATH, xpaths[sw_release][2])
    new_pass = driver.find_element(By.XPATH, '//input[@name=\'password\']')
    repeat_pass = driver.find_element(By.XPATH, '//input[@name=\'confirmPassword\']')
    old_pass.clear()
    new_pass.clear()
    repeat_pass.clear()
    old_pass.send_keys('nemuuser')
    new_pass.send_keys(wrong_pass1)
    repeat_pass.send_keys(wrong_pass2)
    logger.console("Updating password with different new passwords: {wrong_pass1}, new password: {wrong_pass2}".format(
        wrong_pass1=wrong_pass1, wrong_pass2=wrong_pass2))
    WebDriverWait(driver, 60).until(EC.visibility_of_element_located((By.XPATH,
                                                                      '//span[normalize-space()=\'Update\']')))
    WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH, '//span[normalize-space()=\'Update\']')))
    update = driver.find_element(By.XPATH, "//span[normalize-space()='Update']")
    time.sleep(5)
    update.click()


def confirm_button(driver):
    WebDriverWait(driver, 60).until(EC.visibility_of_element_located((By.XPATH,
                                                                      '/html/body/div[1]/div/div/ui-modal-renderer'
                                                                      '/login-banner-modal'
                                                                      '/ui-modal/div/div/div['
                                                                      '3]/div/ui-footer/div/ui-button[1]/button')))
    WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH,
                                                                '/html/body/div[1]/div/div/ui-modal-renderer/login'
                                                                '-banner-modal/'
                                                                'ui-modal/div/div/div[3]/div/ui-footer/div/ui-button['
                                                                '1]/button')))
    confirm = driver.find_element(By.XPATH,
                                  '/html/body/div[1]/div/div/ui-modal-renderer/login-banner-modal/'
                                  'ui-modal/div/div/div[3]/div/ui-footer/div/ui-button[1]/button')
    confirm.click()


def open_user_account_management(driver):
    logger.console("Open User Account Management In Commissioning Wizard")
    WebDriverWait(driver, 60).until(EC.element_to_be_clickable(
        (By.XPATH, '//*[@id="main-view"]/div/div[1]/app-header/div[2]/shortcuts-menu/ul/li[2]/nav-link/a')))
    user_account = driver.find_element(By.XPATH,
                                       '//*[@id="main-view"]/div/div[1]/app-header/div[2]/shortcuts-menu/ul/li['
                                       '2]/nav-link/a')
    user_account.click()

    WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH,
                                                                '//*[@id="main-view"]/div/div[1]/div['
                                                                '2]/global-search/div/wf-panel/'
                                                                'wf-panel-section/div/div/div/ul/li[2]/a')))
    user_account = driver.find_element(By.XPATH,
                                       '//*[@id="main-view"]/div/div[1]/div['
                                       '2]/global-search/div/wf-panel/wf-panel-section/div/div/div/ul/li[2]/a')
    user_account.click()

    WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH, '//span[normalize-space()=\'Security\']')))
    user_account = driver.find_element(By.XPATH, '//span[normalize-space()=\'Security\']')
    user_account.click()

    WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH,
                                    '//span[normalize-space()=\'User Account Management\']')))
    user_account = driver.find_element(By.XPATH, '//span[normalize-space()=\'User Account Management\']')
    user_account.click()


def system_admin_def_pass(driver):
    WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH,
                                                                '//wizard-parameter-input-cell'
                                                                '[@class=\'ng-scope ng-isolate-scope\']'
                                                                '//span[@class=\'checkbox-value ng-binding\']')))
    system_admin = driver.find_element(By.XPATH,
                                       '//wizard-parameter-input-cell[@class=\'ng-scope ng-isolate-scope\']'
                                       '//span[@class=\'checkbox-value ng-binding\']')
    system_admin.click()

    WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH, '//button[normalize-space()=\'Done\']')))
    system_admin = driver.find_element(By.XPATH, '//button[normalize-space()=\'Done\']')
    system_admin.click()


def plan_activation(driver):
    logger.console("Plan validation!")
    WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH,
                                                                '//button[normalize-space()=\'Validate Plan\']')))
    validation = driver.find_element(By.XPATH, '//button[normalize-space()=\'Validate Plan\']')
    validation.click()

    logger.console("Plan activation!")
    WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH, '//button[normalize-space()=\'Activate '
                                                                          'Plan\']//i[@class=\'fa fa-download\']')))
    activation = driver.find_element(By.XPATH, '//button[normalize-space()=\'Activate '
                                               'Plan\']//i[@class=\'fa fa-download\']')
    activation.click()

    WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH, '//button[normalize-space()=\'Execute\']')))
    execute = driver.find_element(By.XPATH, '//button[normalize-space()=\'Execute\']')
    execute.click()

    WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH, '//button[normalize-space()=\'Close\']')))
    close = driver.find_element(By.XPATH, '//button[normalize-space()=\'Close\']')
    close.click()

    WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH,
                                                                '/html[1]/body[1]/main-view[1]/div[1]/div[1]'
                                                                '/app-header[1]/main-menu[1]/nav-item[1]'
                                                                '/div[1]/nav-menu-link[1]/span[1]/i[2]')))
    main_page = driver.find_element(By.XPATH,
                                    '/html[1]/body[1]/main-view[1]/div[1]/div[1]'
                                    '/app-header[1]/main-menu[1]/nav-item[1]'
                                    '/div[1]/nav-menu-link[1]/span[1]/i[2]')
    main_page.click()
    WebDriverWait(driver, 60).until(EC.element_to_be_clickable((By.XPATH,
                                                                '/html[1]/body[1]/main-view[1]/div[1]/div[1]'
                                                                '/app-header[1]/main-menu[1]/nav-item[1]/div[1]'
                                                                '/ng-transclude[1]/div[1]/div[2]'
                                                                '/nav-link[1]/a[1]/span[1]')))
    main_page = driver.find_element(By.XPATH,
                                    '/html[1]/body[1]/main-view[1]/div[1]/div[1]'
                                    '/app-header[1]/main-menu[1]/nav-item[1]/div[1]'
                                    '/ng-transclude[1]/div[1]/div[2]/nav-link[1]/a[1]/span[1]')
    main_page.click()


def password_is_already_updated(driver):
    logger.console("Password is already updated - check")
    WebDriverWait(driver, 120).until(EC.visibility_of_element_located((By.XPATH,
                                                                       '/html/body/login-root/div/login'
                                                                       '/div/div/div/div[1]/div[1]/div[2]/span[2]')))
