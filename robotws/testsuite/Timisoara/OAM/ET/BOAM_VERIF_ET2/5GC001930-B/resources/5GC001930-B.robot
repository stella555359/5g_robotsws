*** Settings ***
Documentation
...    Author: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Maintainer: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC001930-B
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC001930-B/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
#Library        Selenium2Library


Resource    ../../resources/admin.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot


*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${CONFIRM_BUTTON}=                      //ui-button[@a-text="Confirm"]
${CUSTOMER_LOGIN}=                      Nemuadmin
${CUSTOMER_PASSWORD}=                   nemuuser
${WebEM IP}                             https://192.168.255.1:3600
${INPUT_NAME_FIELD}=                    userName
${INPUT_PASSWORD_FIELD}=                password
${LOGIN_BUTTON}=                        //ui-button[@a-text="Login"]



*** Keywords ***
5GC001930-B_Simplified_Site_View_BBMOD_and_SMOD_visualization_in_Mobile_WEBEM
        log to console  Start 1st test
        SELENIUM Prepare Enviroment
        Login To Web Element Manager on iPhone X
        SELENIUM Click Visible Element   locator=//ui-button[@a-text="Close"]
        SELENIUM Click Visible Element   locator=//div[contains(text(), "STARTED")]
        SELENIUM Click Visible Element   locator=//div[contains(text(), "SUCCEEDED")]
        Sleep            2s
        Click Element                    xPath =//*[@id="main-view"]/div/div[1]/app-header/div[1]/i
#        Click Element                    locator=//div[contains(text(), "BTS Status")]
        Click Element                    locator=//div[contains(text(), "Site View")]
        WEBEM Check simplified view of SMOD and BBMOD
        Capture Page Screenshot
        SELENIUM Teardown Enviroment
        log to console  End 1st test


5GC001930-B_Simplified_Site_View_RMOD_visualization_in_Mobile_WEBEM
        log to console  Start 2nd test
        SELENIUM Prepare Enviroment
        Login To Web Element Manager on iPhone X
        WEBEM Go to simplified Site View
        WEBEM Check simplified view of RMOD
        Capture Page Screenshot
        SELENIUM Teardown Enviroment
        log to console  End 2nd test

5GC001930-B_Simplified_Site_View_cells_visualization_in_Mobile_WEBEM
        log to console  Start 3rd test
        SELENIUM Prepare Enviroment
        Login To Web Element Manager on iPhone X
        WEBEM Go to simplified Site View
        WEBEM Check simplified cells view
        Capture Page Screenshot
        SELENIUM Teardown Enviroment
        log to console  End 3rd test


WEBEM Go to simplified Site View
        SELENIUM Click Visible Element   locator=//ui-button[@a-text="Close"]
        SELENIUM Click Visible Element   locator=//div[contains(text(), "STARTED")]
        SELENIUM Click Visible Element   locator=//div[contains(text(), "SUCCEEDED")]
        Sleep            2s
        Click Element                    xPath =//*[@id="main-view"]/div/div[1]/app-header/div[1]/i
   #     Click Element                    locator=//div[contains(text(), "BTS Status")]
        Click Element                    locator=//div[contains(text(), "Site View")]

WEBEM Check simplified cells view
        Wait Until Element Is Visible
        ...    xpath: //site[@id="simplifiedSiteContainer"]
        ...    timeout=60
        Wait Until Element Is Visible
        ...    xpath: //div[@class="cell-header"]//div[contains(text(), "NR cells")]
        ...    timeout=60
        Wait Until Element Is Visible
        ...    xpath: //div[@class="cell-content"]//div[contains(text(), "1")]
        ...    timeout=60
        run keyword and ignore error  Wait Until Element Is Visible
        ...    xpath: //div[@class="cell-content"]//div[@class="alarms-block"]
        ...    timeout=60
        Wait Until Element Is Visible
        ...    xpath: //div[@class="cell-content"]//div[@class="site-widget-diode gray-diode"]
        ...    timeout=60
        Wait Until Element Is Visible
        ...    xpath: //div[@class="cell-content"]//div[@title="Offline"]
        ...    timeout=60

WEBEM Check simplified view of RMOD
        Wait Until Element Is Visible
        ...    xpath: //site[@id="simplifiedSiteContainer"]
        ...    timeout=60
        Wait Until Element Is Visible
        ...    locator=//div[contains(text(), "AEQA")]
        ...    timeout=60
        Wait Until Element Is Visible
        ...    locator=//div[contains(text(), "RMOD-1")]
        ...    timeout=60


WEBEM Check simplified view of SMOD and BBMOD
        Wait Until Element Is Visible
        ...    xpath: //site[@id="simplifiedSiteContainer"]
        ...    timeout=60
        Wait Until Element Is Visible
        ...    locator=//div[contains(text(), "ABIL")]
        ...    timeout=60
        Wait Until Element Is Visible
        ...    locator=//div[contains(text(), "ASIK")]
        ...    timeout=60
        Wait Until Element Is Visible
        ...    locator=//div[contains(text(), "SMOD-1")]
        ...    timeout=60
        Wait Until Element Is Visible
        ...    locator=//div[contains(text(), "BBMOD-1")]
        ...    timeout=60
        Wait Until Element Is Visible
        ...    locator=//div[contains(text(), "AMIA")]
        ...    timeout=60
        Wait Until Element Is Visible
        ...    locator=//div[contains(text(), "CABINET-1")]
        ...    timeout=60

WEBEM Check if SW information is visible
        Wait Until Element Is Visible
        ...    locator=//div[contains(text(), "${OUT_ACTIVE_SW}")]
        ...    timeout=60
        Wait Until Element Is Visible
        ...    locator=//div[contains(text(), "${OUT_PASSIVE_SW}")]
        ...    timeout=60

WEBEM Check if BTS contains basic info
        Wait Until Element Is Visible
        ...    locator=//span[contains(text(), "BTS ID:")]
        ...    timeout=60
        Wait Until Element Is Visible
        ...    locator=//span[contains(text(), "BTS name:")]
        ...    timeout=60
        Wait Until Element Is Visible
        ...    locator=//div[contains(text(), "${OUT_ADMIN_BTS_NAME}")]
        ...    timeout=60
        Wait Until Element Is Visible
        ...    locator=//span[contains(text(), "${OUT_ACTIVE_SW}")]
        ...    timeout=60
        Wait Until Element Is Visible
        ...    locator=//div[contains(text(), "NR")]
        ...    timeout=60

Specifying a Known Mobile Device
        ${mobile emulation}=    Create Dictionary    deviceName=iPhone X
        ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
        Call Method    ${chrome options}    add_experimental_option    mobileEmulation    ${mobile emulation}
        Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
        Create Webdriver    Chrome    chrome_options=${chrome options}
        Goto    https://192.168.255.129
        Sleep    10 secs

Login To Web Element Manager on iPhone X
    [Arguments]    ${login}=${CUSTOMER_LOGIN}
    ...            ${password}=${CUSTOMER_PASSWORD}
    Set Selenium Implicit Wait    5

    Specifying a Known Mobile Device
    Input Text    locator=${INPUT_NAME_FIELD}
    ...           text=${login}
    Input Text    locator=${INPUT_PASSWORD_FIELD}
    ...               text=${password}
    Click Element   locator=${LOGIN_BUTTON}
    Wait Until Element Is Visible    locator=${CONFIRM_BUTTON}
    ...                              timeout=40
    Click Element    locator=${CONFIRM_BUTTON}




