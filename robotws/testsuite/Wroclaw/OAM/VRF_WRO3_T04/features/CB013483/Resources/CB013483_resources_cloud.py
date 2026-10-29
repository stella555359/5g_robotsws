import time
from robot.api import logger
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait


def log_to_webem_and_check_logout_timer_inactive(username, password, mplane):
    '''
    Login to WebEM and check if the logout will be proceed after some time of inactivity.
    :param username: username to WebEM
    :param passwow212rd: password to WebEM
    :param mplane:  mplane address of the BTS
    :return difference_time: The time after which the user is logged out of WebEM
    '''
    profile = webdriver.ChromeOptions()
    profile.add_argument('ignore-certificate-errors')
    profile.add_argument('--headless')
    profile.add_argument('--no-sandbox')
    profile.add_argument('--disable-dev-shm-usage')
    profile.add_argument("--start-fullscreen")
    driver = webdriver.Chrome(chrome_options=profile)
    driver.get(f"https://{mplane}")
    username_field = driver.find_element_by_id("login-username")
    password_field = driver.find_element_by_id("login-password")
    assert driver.find_element_by_xpath('//input[@type="password"]'), 'Password is no hiding'
    username_field.send_keys(username)
    password_field.send_keys(password)
    login = driver.find_element(By.XPATH, '//span[text()="Log In"]')
    login.click()
    legal_notice_element = WebDriverWait(driver, 15).\
        until(EC.element_to_be_clickable((By.XPATH, '//span[text()="Accept"]')))
    legal_notice_element.click()
    try:
        start_up = WebDriverWait(driver, 15). \
            until(EC.element_to_be_clickable((By.XPATH, '//span[text()="Close"]')))
        start_up.click()
    except Exception:
        print("Startup view not found, continuing.")
    dashboard = WebDriverWait(driver, 15). \
        until(EC.element_to_be_clickable((By.XPATH, '//*[@aria-label="Dashboard"]')))
    dashboard.click()
    login_time = time.time()
    for i in range(750):
        try:
            dashboard = WebDriverWait(driver, 15).\
                until(EC.element_to_be_clickable((By.XPATH, '//*[@aria-label="Dashboard"]')))
        except Exception:
            logout_time = time.time()
            break
        time.sleep(1)
    else:
        raise RuntimeError(f"login timeout took too long for {username}")
    difference_time = logout_time - login_time
    logger.console('Time difference: {}'.format(difference_time))
    WebDriverWait(driver, 5).until(EC.element_to_be_clickable((By.XPATH, '//span[text()="Log In"]')))
    driver.quit()
    return difference_time


def log_to_webem_and_check_logout_timer_active(username, password, mplane):
    '''
    Login to WebEM and check if the logout will be proceed after token expiration time despite the activity.
    :param username: username to WebEM
    :param passwow212rd: password to WebEM
    :param mplane:  mplane address of the BTS
    :return difference_time: The time after which the user is logged out of WebEM
    '''
    profile = webdriver.ChromeOptions()
    profile.add_argument('ignore-certificate-errors')
    profile.add_argument('--headless')
    profile.add_argument('--no-sandbox')
    profile.add_argument('--disable-dev-shm-usage')
    profile.add_argument("--start-fullscreen")
    driver = webdriver.Chrome(chrome_options=profile)
    driver.get(f"https://{mplane}")
    username_field = driver.find_element_by_id("login-username")
    password_field = driver.find_element_by_id("login-password")
    assert driver.find_element_by_xpath('//input[@type="password"]'), 'Password is no hiding'
    username_field.send_keys(username)
    password_field.send_keys(password)
    login = driver.find_element(By.XPATH, '//span[text()="Log In"]')
    login.click()
    legal_notice_element = WebDriverWait(driver, 15).\
        until(EC.element_to_be_clickable((By.XPATH, '//span[text()="Accept"]')))
    legal_notice_element.click()
    try:
        start_up = WebDriverWait(driver, 15). \
            until(EC.element_to_be_clickable((By.XPATH, '//span[text()="Close"]')))
        start_up.click()
    except Exception:
        print("Startup view not found, continuing.")
    dashboard = WebDriverWait(driver, 15). \
        until(EC.element_to_be_clickable((By.XPATH, '//*[@aria-label="Dashboard"]')))
    login_time = time.time()
    for i in range(750):
        try:
            dashboard = WebDriverWait(driver, 15).\
                until(EC.element_to_be_clickable((By.XPATH, '//*[@aria-label="Dashboard"]')))
            dashboard.click()
            # WebDriverWait(driver, 15). \
            #     until(EC.element_to_be_clickable((By.XPATH, '//*[@aria-label="Dashboard"]')))
        except Exception:
            logout_time = time.time()
            break
        time.sleep(1)
    else:
        raise RuntimeError(f"login timeout took too long for {username}")
    difference_time = logout_time - login_time
    logger.console('Time difference: {}'.format(difference_time))
    # WebDriverWait(driver, 5).until(EC.element_to_be_clickable((By.XPATH, '//span[text()="Log In"]')))
    driver.quit()
    return difference_time
