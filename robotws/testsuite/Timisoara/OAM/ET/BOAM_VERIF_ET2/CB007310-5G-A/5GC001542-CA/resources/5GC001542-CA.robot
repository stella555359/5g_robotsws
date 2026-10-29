*** Settings ***
Documentation
...    Author: Zaharia Andreea-Oana
...    Maintainer: Izabela Muntean
...    Test Description: gNB PM result files are reported according to the configuration
...    AC: LTE_OPR_AC_8735
...    REQ: LTE_OPR_REQ_9077; LTE_OPR_REQ_9077

Library     ute_syslog
Library     ute_admin_infomodel
Library     BuiltIn
Library     String
Library     Selenium2Library
Library    XML  lxml=True
Library    Process

Resource    ../../../resources/admin.robot
Resource   ../../../resources/admin_infomodel.robot
Resource    ../../../resources/pretest_posttest.robot
Resource    ../../../resources/system.robot
Resource    ../../../resources/fault_trigger.robot
Resource       ./selenium.robot



*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${SW_DESTINATION}     /home/ute
${CONFIRM_BUTTON}=                      //ui-button[@a-text="Confirm"]
${CUSTOMER_LOGIN}=                      developer
${CUSTOMER_PASSWORD}=                   $developer#
${WebEM IP}                             https://192.168.255.1:3600
${INPUT_NAME_FIELD}=                    userName
${INPUT_PASSWORD_FIELD}=                password
${LOGIN_BUTTON}=                        //ui-button[@a-text="Login"]
${USERNAME}                             Nemuadmin
${PASSWORD}                             nemuuser
${WELCOME_SCREEN_USERNAME_INPUT_SBTS}=         //input[@id="login-username"]
${WELCOME_SCREEN_PASS_INPUT_SBTS}=             //input[@id="login-password"]
${WELCOME_SCREEN_LOGIN_BTN_SBTS}=              //span[contains(text(), "Login")]
${POP_CONFIRM_BTN}                             //div[@class="ui-modal"]//button[contains(text(), "Confirm")]

${delta_file_reportingIntervalPm_5min}=          ${CURDIR}/5m.json
${delta_file_reportingIntervalPm_60min}=         ${CURDIR}/60m.json

${TNL_NAME_PM}=                 M51321C0

*** Keywords ***
5GC001542-CA Check_BTS_transport_counters
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_reportingIntervalPm_5min}
    ...                                        skip_parameter_relation_errors=True
    ...                                        should_activate=True
    ...                                        timeout=300
    SELENIUM Prepare Enviroment
    Login To Web Element Manager
    Go To Transport Counters Tab
    Wait Until Element Is Visible
    ...    locator=//span[@title="TNL-1"]
    ...    timeout=350
    Check TNL For PM In Main View            title=TNL
    ...                                      pm_name=${TNL_NAME_PM}
    Close Browser
    SELENIUM Teardown Enviroment
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_reportingIntervalPm_60min}
    ...                                        skip_parameter_relation_errors=True
    ...                                        should_activate=True
    ...                                        timeout=30


Check TNL For PM In Main View
    [Arguments]    ${title}
    ...            ${pm_name}

    Click Element   locator=${XPath_TNL}
    Click Element   locator=${XPath_IPIF}
    Click Element   locator=${XPath_IPIF5}
    Click Element   locator=${XPath_IP_Interface_Statistics}
    Click Element   locator=${XPath_M51321C0}
    Download Export Table
    Wait Until Page Contains Element     locator=//th[contains(text(),'${pm_name}')]
    Log    Name "${pm_name}" is visible in PM Main View    console=yes
    Sleep  2s
    Click Element   locator=${XPath_TNL_Collapse}

Download Export Table
    Wait Until Element Is Visible    locator=//ui-button[@a-title='Export Table']//button
    ...                              timeout=15
    Click Button    locator=//ui-button[@a-title='Export Table']//button
    Sleep  1


Login To Web Element Manager
    [Arguments]    ${browser_url}=${WEBEM_IP}
    ...            ${webem_username}=${USERNAME}
    ...            ${webem_password}=${PASSWORD}
    ...            ${browser_type}=chrome
    ...            ${browser_alias}=browser
    Selenium2Library.Set Selenium Implicit Wait    5
    Open Browser
    SELENIUM Input Text in Visible Element
    ...    locator=${WELCOME_SCREEN_USERNAME_INPUT_SBTS}
    ...    text=${webem_username}
    Input Text
    ...    locator=${WELCOME_SCREEN_PASS_INPUT_SBTS}
    ...    text=${webem_password}
    Click Element
    ...    locator=${WELCOME_SCREEN_LOGIN_BTN_SBTS}
    SELENIUM Pop Confirm
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//ui-button[@a-text="Close"]
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "STARTED")]
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "SUCCEEDED")]


Open Browser
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --window-size\=1900,1200
#    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    https://192.168.255.129
    Sleep    10 secs


Go To Transport Counters Tab
    Wait Until Element Is Visible
    ...    locator=//div[@aria-describedby="admin.navigationBar.performance.TITLE"]
    ...    timeout=10
    Run Keyword And Ignore Error
    ...    Wait Until Element Is Not Visible
    ...    locator=//div[@class="notifyjs-corner"]//div
    ...    timeout=60
    Click Element
    ...    locator=//div[@aria-describedby="admin.navigationBar.performance.TITLE"]
    Wait Until Element Is Visible
    ...    locator=//span[contains(text(),'Performance Management')]
    ...    timeout=20
    Mouse Over
    ...    locator=//span[contains(text(),'Performance Management')]
    Wait Until Element Is Visible
    ...    locator=//span[contains(text(),'Transport Counters')]
    ...    timeout=20
    Click Element
    ...    locator=//span[contains(text(),'Transport Counters')]

UTE TL Preparation
    [Documentation]  Keyword used for setting up local 5G TLs to onAir state, as UTE reserve it only to sw_upload state
    #TO DO:             Add Check for onAir State. For cases when the Suite is run more than one time
    PREPOST Setup Admin
    ADMIN Change R&D Port Status    status=True
    @{status}   Run Keyword and Ignore Error    ADMIN Check BTS onair
    Run Keyword If  '@{status}[0]' == 'FAIL'   Run Keyword  5GC001542-CA.Configured_SwDownload_SwUpdate_OnAir
    ...     ELSE    Log To Console  --- BTS already onAir ---
    ADMIN Teardown Admin

Configured_SwDownload_SwUpdate_OnAir
    ADMIN Check BTS Not Commisioned
    Get TL Hostname
    Get Software Release
    ADMIN Perform Commissioning
    ...   scf_file=/home/ute/MN/UTE/robotws/custom-config/Timisoara/${tl_hostname}/${sw_release}/${tl_hostname}_SCF.xml
    ${configured}   Run Keyword and Return Status
    ...    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    Run Keyword If  '${configured}' == 'True'  Sleep  180
    Run Keyword Unless   ${configured}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    ...    AND     Sleep  180
    Log To Console  Fault ID23 Checking...
    ${result}   Run Keyword and Return Status    ADMIN Check If Alarm Is Active  fault_id=23
    BuiltIn.Run Keyword If  '${result}' == 'True'   Run Keywords
    ...    Log To Console  Fault ID23 found. Start RF Software Update
    ...     AND     ADMIN Download And Update Current Software
    ...     ELSE    Log To Console  Fault ID23 not found.
    ${onair}   Run Keyword and Return Status
    ...    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    Run Keyword Unless   ${onair}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir






