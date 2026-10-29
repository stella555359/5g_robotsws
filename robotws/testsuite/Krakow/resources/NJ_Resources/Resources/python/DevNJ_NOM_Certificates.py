import os
import time
from robot.api import logger
from selenium import webdriver


def nom_browser_certificates_installation(certificate_file, browser='chrome'):
    """
    Main Function:
    Keyword of nom_browser_certificates_installation provides function that install NOM certificate before opening NOM
    Web browser.

    Arguments:
    :param certificate_file: the path of certificate file, this path is for absolute path under /home
    :param browser: the type of browser, and default is chrome
    :return: None

    Examples:
    | nom_browser_certificates_installation | certificate_file='/home/ute/Downloads/neo0024_issuing_ca.crt'|

    Version:
        | Author | Version | Delivery Date | Comments |
        | Zhao Longmei| 0.0.1 | 2022/06/28 | First draft version |
        | Zhao Longmei| 1.0.0 | 2022/07/05 | Approve Version|
        | Zhao Longmei| 1.0.1 | 2022/07/06 | Modify for different Chrome versions|
    """

    cmd_pip = "python -m pip install --upgrade pip"
    logger.info("Update pip version: {}".format(cmd_pip), also_console=True)
    os.system(cmd_pip)
    cmd_xlib = "/opt/ute/python3/bin/pip3 install python-xlib"
    logger.info("Try to install xlib: {}".format(cmd_xlib), also_console=True)
    install_xlib = os.system(cmd_xlib)
    cmd_pywinauto = "/opt/ute/python3/bin/pip3 install pywinauto"
    logger.info("Try to install pywinauto: {}".format(cmd_pywinauto), also_console=True)
    install_pywinauto = os.system(cmd_pywinauto)
    if install_xlib != 0:
        cmd_xlib = "pip install python-xlib"
        logger.info("Retry to install xlib: {}".format(cmd_xlib), also_console=True)
        os.system(cmd_xlib)
    if install_pywinauto != 0:
        cmd = "pip install pywinauto"
        logger.info("Retry to install pywinauto: {}".format(cmd), also_console=True)
        os.system(cmd)
    from pywinauto.keyboard import send_keys

    if browser.lower() == 'chrome':
        options = webdriver.ChromeOptions()
        options.add_argument('--ignore-certificate-errors')
        options.add_argument('--start-maximized')
        chrome_driver = r"/opt/ute/chromedriver/chromedriver"
        wd = webdriver.Chrome(chrome_driver, chrome_options=options)
        wd.get('chrome://settings/certificates')
        logger.info("Open Browser to start installing certificate", also_console=True)
        wd.implicitly_wait(15)

        # right click to copy JS path
        Authorities_JSpath = 'return document.querySelector("body > settings-ui").shadowRoot.querySelector("#main").' \
                             'shadowRoot.querySelector("settings-basic-page").shadowRoot.querySelector("#basicPage ' \
                             '> settings-section.expanded > settings-privacy-page").shadowRoot.querySelector' \
                             '("#pages > settings-subpage.iron-selected > certificate-manager").shadowRoot.' \
                             'querySelector("cr-tabs").shadowRoot.querySelector("div:nth-child(4)")'
        Authorities_shadow = wd.execute_script(Authorities_JSpath)
        if Authorities_shadow.text == 'Authorities':
            wd.execute_script(Authorities_JSpath).click()
        else:
            Authorities_JSpath = 'return document.querySelector("body > settings-ui").shadowRoot.querySelector' \
                                 '("#main").shadowRoot.querySelector("settings-basic-page").shadowRoot.querySelector' \
                                 '("#basicPage > settings-section.expanded > settings-privacy-page").shadowRoot.' \
                                 'querySelector("#pages > settings-subpage > certificate-manager").shadowRoot.' \
                                 'querySelector("cr-tabs").shadowRoot.querySelector("div:nth-child(5)")'
            wd.execute_script(Authorities_JSpath).click()

        Import_JSpath = 'return document.querySelector("body > settings-ui").shadowRoot.querySelector("#main").' \
                        'shadowRoot.querySelector("settings-basic-page").shadowRoot.querySelector("#basicPage > ' \
                        'settings-section.expanded > settings-privacy-page").shadowRoot.querySelector("#pages >' \
                        ' settings-subpage.iron-selected > certificate-manager").shadowRoot.querySelector' \
                        '("#caCerts").shadowRoot.querySelector("#import")'
        wd.execute_script(Import_JSpath).click()
        time.sleep(3)
        send_keys(certificate_file)
        send_keys("{VK_RETURN}")

        Trust_iden_websites_JSpath = 'return document.querySelector("body > settings-ui").shadowRoot.' \
                                     'querySelector("#main").shadowRoot.querySelector("settings-basic-page").' \
                                     'shadowRoot.querySelector("#basicPage > settings-section.expanded > ' \
                                     'settings-privacy-page").shadowRoot.querySelector("#pages > settings-subpage.' \
                                     'iron-selected > certificate-manager").shadowRoot.querySelector("ca-trust-' \
                                     'edit-dialog").shadowRoot.querySelector("#ssl").shadowRoot.querySelector' \
                                     '("#checkbox")'
        Trust_email_users_JSpath = 'return document.querySelector("body > settings-ui").shadowRoot.querySelector' \
                                   '("#main").shadowRoot.querySelector("settings-basic-page").shadowRoot.' \
                                   'querySelector("#basicPage > settings-section.expanded > settings-privacy-page").' \
                                   'shadowRoot.querySelector("#pages > settings-subpage.iron-selected > ' \
                                   'certificate-manager").shadowRoot.querySelector("ca-trust-edit-dialog").' \
                                   'shadowRoot.querySelector("#email").shadowRoot.querySelector("#checkbox")'
        Trust_software_makers_JSpath = 'return document.querySelector("body > settings-ui").shadowRoot.' \
                                       'querySelector("#main").shadowRoot.querySelector("settings-basic-page").' \
                                       'shadowRoot.querySelector("#basicPage > settings-section.expanded > ' \
                                       'settings-privacy-page").shadowRoot.querySelector("#pages > settings-subpage.' \
                                       'iron-selected > certificate-manager").shadowRoot.querySelector' \
                                       '("ca-trust-edit-dialog").shadowRoot.querySelector("#objSign").shadowRoot.' \
                                       'querySelector("#checkbox")'
        OK_JSpath = 'return document.querySelector("body > settings-ui").shadowRoot.querySelector("#main").' \
                    'shadowRoot.querySelector("settings-basic-page").shadowRoot.querySelector("#basicPage > ' \
                    'settings-section.expanded > settings-privacy-page").shadowRoot.querySelector("#pages > ' \
                    'settings-subpage.iron-selected > certificate-manager").shadowRoot.querySelector' \
                    '("ca-trust-edit-dialog").shadowRoot.querySelector("#ok")'

        time.sleep(3)
        wd.execute_script(Trust_iden_websites_JSpath).click()
        wd.execute_script(Trust_email_users_JSpath).click()
        wd.execute_script(Trust_software_makers_JSpath).click()
        wd.execute_script(OK_JSpath).click()

        Confirm_JSpath = 'return document.querySelector("body > settings-ui").shadowRoot.querySelector("#main").' \
                         'shadowRoot.querySelector("settings-basic-page").shadowRoot.querySelector("#basicPage > ' \
                         'settings-section.expanded > settings-privacy-page").shadowRoot.querySelector("#pages > ' \
                         'settings-subpage.iron-selected > certificate-manager").shadowRoot.querySelector' \
                         '("certificates-error-dialog").shadowRoot.querySelector("#ok")'
        try:
            wd.execute_script(Confirm_JSpath).click()
            logger.info("NON certificates had been installed before", also_console=True)
        except Exception as e:
            logger.info("The first time to install NON certificates", also_console=True)

        Check_CA_JSpath = 'return document.querySelector("body > settings-ui").shadowRoot.querySelector("#main").' \
                          'shadowRoot.querySelector("settings-basic-page").shadowRoot.querySelector("#basicPage ' \
                          '> settings-section.expanded > settings-privacy-page").shadowRoot.querySelector("#pages ' \
                          '> settings-subpage > certificate-manager").shadowRoot.querySelector("#caCerts").' \
                          'shadowRoot.querySelector("certificate-entry:nth-child(54)").shadowRoot.querySelector' \
                          '("div.expand-box > cr-expand-button").shadowRoot.querySelector("#icon").' \
                          'shadowRoot.querySelector("#icon > iron-icon")'
        wd.execute_script("arguments[0].scrollIntoView();", wd.execute_script(Check_CA_JSpath))
        wd.execute_script(Check_CA_JSpath).click()

        Nokia_CA_JSpath = 'return document.querySelector("body > settings-ui").shadowRoot.querySelector("#main").' \
                          'shadowRoot.querySelector("settings-basic-page").shadowRoot.querySelector("#basicPage > ' \
                          'settings-section.expanded > settings-privacy-page").shadowRoot.querySelector("#pages > ' \
                          'settings-subpage > certificate-manager").shadowRoot.querySelector("#caCerts").shadowRoot.' \
                          'querySelector("certificate-entry:nth-child(54)").shadowRoot.querySelector("div.list-' \
                          'frame > certificate-subentry").shadowRoot.querySelector("div > div.name")'
        Nokia_CA_shadow = wd.execute_script(Nokia_CA_JSpath)

        if Nokia_CA_shadow.text == 'Nokia cnms Root CA':
            logger.info("Install NOM Certificates successfully!", also_console=True)
        else:
            Check_CA_JSpath = 'return document.querySelector("body > settings-ui").shadowRoot.querySelector' \
                              '("#main").shadowRoot.querySelector("settings-basic-page").shadowRoot.querySelector' \
                              '("#basicPage > settings-section.expanded > settings-privacy-page").shadowRoot.' \
                              'querySelector("#pages > settings-subpage > certificate-manager").shadowRoot.' \
                              'querySelector("#caCerts").shadowRoot.querySelector("certificate-entry:nth-child(59)")' \
                              '.shadowRoot.querySelector("div > cr-expand-button").shadowRoot.querySelector("#icon")' \
                              '.shadowRoot.querySelector("#icon > iron-icon")'
            wd.execute_script("arguments[0].scrollIntoView();", wd.execute_script(Check_CA_JSpath))
            wd.execute_script(Check_CA_JSpath).click()
            Nokia_CA_JSpath = 'return document.querySelector("body > settings-ui").shadowRoot.querySelector' \
                              '("#main").shadowRoot.querySelector("settings-basic-page").shadowRoot.querySelector' \
                              '("#basicPage > settings-section.expanded > settings-privacy-page").shadowRoot.' \
                              'querySelector("#pages > settings-subpage > certificate-manager").shadowRoot.' \
                              'querySelector("#caCerts").shadowRoot.querySelector("certificate-entry:nth-child' \
                              '(59)").shadowRoot.querySelector("div.list-frame > certificate-subentry").' \
                              'shadowRoot.querySelector("div > div.name")'
            Nokia_CA_shadow = wd.execute_script(Nokia_CA_JSpath)
            if Nokia_CA_shadow.text == 'Nokia cnms Root CA':
                logger.info("Install NOM Certificates successfully!", also_console=True)
            else:
                raise Exception("Failed to install NOM Certificates!")


if __name__ == '__main__':
    nom_browser_certificates_installation(certificate_file='/home/ute/Downloads/neo0024_issuing_ca.crt')
