import time
from taf.selenium.sbts import sbts
import string as str
import re


def escape_ascii(string):
    ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
    result = ansi_escape.sub('', string)
    return result


def change_password_for_user(user, new_password, old_password):
    interface = sbts()
    interface.enable_virtual_display()
    interface.login("https://{}".format(web_ip), web_user, web_password)
    time.sleep(50)
    status = interface.change_password_for_service_account(username=user,
                                                           old_password=old_password,
                                                           new_password=new_password,
                                                           confirm_password=new_password)
    interface.logout()
    interface.disable_virtual_display()
    return status


def crop_last_line(string):
    s = string[0:string.rfind("\n")]
    if s.split("\n")[-1][1] in str.ascii_letters:
        return s[0:s.rfind("\n")]
    return s


def crop_first_line(string):
    lines = string.split("\n")
    lines = lines[1:]
    if lines and lines[0] and lines[0][0] in str.ascii_letters:
        lines = lines[1:]
    result = "\n".join(lines)
    return result


def get_output_banner(output):
    lines = output.split('\n')
    if len(lines) >= 3:
        return lines[1]
    else:
        return None


def trigger_synchronization(driver):
    procedures_button_path = "/html/body/main-view/div/div[1]/app-header/main-menu/nav-item[7]/div/nav-menu-link" \
                             "/span/i[1]"
    find_element(driver=driver, element_xpath=procedures_button_path, click=True)
    service_account_button_path = "/html/body/main-view/div/div[1]/app-header/main-menu/nav-item[7]/div" \
                                  "/ng-transclude/div/div[4]/nav-link/a/span[1]"
    find_element(driver=driver, element_xpath=service_account_button_path, click=True)
    synchronize_button_path = "/html/body/main-view/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/div" \
                              "/div[1]/service-account-ssh/div/div/div[3]/div/ui-button/button"
    find_element(driver=driver, element_xpath=synchronize_button_path, click=True)
    success_tick_path = '//*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/div/div[1]" \
                       "/service-account-ssh/div/div/div[3]/ssh-procedure-bar/span/span/ui-inline-info/div/span[1]'
    find_element(driver=driver, element_xpath=success_tick_path, click=False)
    time.sleep(20)


def manually_trigger_the_service_account_synchronization():
    driver = create_driver()
    login_to_webem(driver=driver, user="Nemuadmin", password="nemuuser")
    trigger_synchronization(driver=driver)
    driver.close()
