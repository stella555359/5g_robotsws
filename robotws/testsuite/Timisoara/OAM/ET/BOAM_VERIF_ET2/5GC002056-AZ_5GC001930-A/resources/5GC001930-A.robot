*** Settings ***
Documentation
...    Author: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Maintainer: Andreea Zaharia (andreea-oana.zaharia@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC001930-A
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC002056-AZ_5GC001930-A/general.robot

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
${LOGIN_BUTTON_TRUNK}=                  //p-button[@ng-reflect-label="Login"]


*** Keywords ***
5GC001930-A-a_ABION_Display_Basic_BTS_information_in_Mobile_WEBEM
        log to console  Start 1st test
        sleep  30s
        SELENIUM Prepare Enviroment
        Login To Web Element Manager on iPhone X
        SELENIUM Click Visible Element   locator=//ui-button[@a-text="Close"]
        SELENIUM Click Visible Element   locator=//div[contains(text(), "STARTED")]
        SELENIUM Click Visible Element   locator=//div[contains(text(), "SUCCEEDED")]
        Sleep            2s
        Click Element                    xPath =//*[@id="main-view"]/div/div[1]/app-header/div[1]/i
        #Click Element                    locator=//div[contains(text(), "BTS Status")]
        Click Element                    locator=//div[contains(text(), "Site View")]
        Click Element                    xPath =//*[@id="main-view"]/div/div[1]/app-header/div[2]/i
        WEBEM Check if BTS contains basic info
        Capture Page Screenshot
        SELENIUM Teardown Enviroment
        log to console  End 1st test

5GC001930-A-a_ABION_Display_SW_information_in_Mobile_WEBEM
        log to console  Start 2nd test
        sleep  30s
        SELENIUM Prepare Enviroment
        Login To Web Element Manager on iPhone X
        SELENIUM Click Visible Element   locator=//ui-button[@a-text="Close"]
        SELENIUM Click Visible Element   locator=//div[contains(text(), "STARTED")]
        SELENIUM Click Visible Element   locator=//div[contains(text(), "SUCCEEDED")]
        Sleep            2s
        Click Element                    xPath =//*[@id="main-view"]/div/div[1]/app-header/div[1]/i
        SELENIUM Click Visible Element   locator=//div[contains(text(), "Software Management")]
        WEBEM Check if SW information is visible
        Capture Page Screenshot
         Sleep            2s
        Click Element                    xPath =//*[@id="main-view"]/div/div[1]/app-header/div[1]/i
        Click Element                    locator=//div[contains(text(), "BTS Status")]
        Click Element                    locator=//div[contains(text(), "Site View")]
        Click Element                    xPath =//*[@id="main-view"]/div/div[1]/app-header/div[2]/i
        WEBEM Check if BTS contains basic info
        Capture Page Screenshot
        SELENIUM Teardown Enviroment
        log to console  End 2nd test



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
    Set Selenium Implicit Wait    15
    Sleep  60s
    Specifying a Known Mobile Device
    Input Text    locator=${INPUT_NAME_FIELD}
    ...           text=${login}
    Input Text    locator=${INPUT_PASSWORD_FIELD}
    ...               text=${password}
    Branch or Trunk
    Run Keyword If  '${branch}' == '5G21A'  Run Keyword  Click Element   locator=${LOGIN_BUTTON}
    ...         ELSE  Run Keyword  Click Element   locator=${LOGIN_BUTTON_TRUNK}
    Wait Until Element Is Visible    locator=${CONFIRM_BUTTON}
    ...                              timeout=40
    Click Element    locator=${CONFIRM_BUTTON}

Branch or Trunk
    @{sw_version}=  Split String  ${out_active_sw}  separator=\_
    ${branch}=  Set Variable  @{sw_version}[0]
    Set Global Variable  ${branch}




