import re
import ast
import time
from selenium import webdriver
import robot.api.logger as logger


webem_username = 'Nemuadmin'
webem_password = 'nemuuser'


def get_right_bsh(output, nr):
    return output.split(' ')[nr]


def get_interfaces_list(output):
    list = output.split(":\r\n")
    list = list[: -1]
    list.remove("ethlmp0:2")
    return list


def check_if_output_matches_value(output, value):
    assert output[0] == value, "Wrong Value"


def check_if_drop_gratuitous_arp_is_properly_set(data_string):

    for item in data_string.split('\r\n'):
        r_search = re.search(r'(?<=conf/)(.*?)(?=/)', item)  # search for string between 'conf/' and '/'
        if r_search is not None:  # if not found then do nothing, this will filter prompt and other unused strings
            interface_name = r_search.group()  # assign interface_name from regex
            arp_status = item[-1]  # assign drop_gratuitous_arp value
            logger.info(f'{interface_name}:{arp_status}', html=True, also_console=True)
            required_state = '0' if interface_name != 'ethlmp0' else '1'  # prepare checked value with exeption
            assert arp_status == required_state, f'Wrong drop_gratuitous_arp state on {interface_name}'  # final check


def get_active_faults_using_netact(na_instance):
    return na_instance.get_active_faults(timeout=600)


def get_definition_errors_from_validation_results(output):
    output = output['niddValidationResult']['logs']['definitionErrors']
    return output


def get_definition_errors_list(output):
    output = str(output).split("Status reached:")[1]
    output = output.split(". ErrorCode")[0]
    output = output.strip()
    output = ast.literal_eval(output)
    results = get_definition_errors_from_validation_results(output)
    return results


def switch_tls_on_browser_to_1(browser, address):
    browser.get(address)
    time.sleep(3)
    browser.find_element_by_id("warningButton").click()
    time.sleep(5)
    browser.find_element_by_id("about-config-search").send_keys("security.tls.version.min")
    time.sleep(2)
    browser.find_element_by_xpath("//button[@class='button-edit semi-transparent']").click()
    time.sleep(2)
    browser.find_element_by_xpath("//input[@type='number']").send_keys("1")
    time.sleep(2)
    browser.find_element_by_xpath("//button[@class='primary button-save semi-transparent']").click()
    time.sleep(2)
    browser.find_element_by_id("about-config-search").clear()
    time.sleep(1)
    browser.find_element_by_id("about-config-search").send_keys("security.tls.version.max")
    time.sleep(2)
    browser.find_element_by_xpath("//button[@class='button-edit semi-transparent']").click()
    time.sleep(2)
    browser.find_element_by_xpath("//input[@type='number']").send_keys("2")
    time.sleep(2)
    browser.find_element_by_xpath("//button[@class='primary button-save semi-transparent']").click()
    time.sleep(2)


def open_browser():
    profile = webdriver.FirefoxProfile()
    profile.accept_untrusted_certs = True
    browser = webdriver.Firefox(firefox_profile=profile)
    return browser


def try_to_open_webem(browser):
    browser.get("https://192.168.255.129/")
    time.sleep(3)


def click_prefResetButton(browser):
    browser.find_element_by_id("prefResetButton").click()
    time.sleep(5)


def login_to_webem_with_default_tls(browser):
    browser.find_element_by_id("login-username").send_keys(webem_username)
    time.sleep(1)
    browser.find_element_by_id("login-password").send_keys(webem_password)
    time.sleep(1)
    browser.find_element_by_xpath("//button[@class='p-ripple p-element p-button p-component']").click()
    time.sleep(20)
    browser.find_element_by_xpath("//details-panel[@class='ng-scope ng-isolate-scope']")


def close_browser(browser):
    browser.close()
