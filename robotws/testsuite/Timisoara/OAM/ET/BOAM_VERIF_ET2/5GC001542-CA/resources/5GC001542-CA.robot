*** Settings ***
Documentation
...    Author: Alin Necula (alin.necula@nokia.com)
...    Maintainer: Roxana Craciun (roxana.craciun@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC001542-CA
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC001542-CA/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        BuiltIn



Resource    ../../resources/admin.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    XPaths.robot


*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${CONFIRM_BUTTON}=                      //ui-button[@a-text="Confirm"]
${CUSTOMER_LOGIN}=                      developer
${CUSTOMER_PASSWORD}=                   $developer#
${WebEM IP}                             https://192.168.255.1:3600
${INPUT_NAME_FIELD}=                    userName
${INPUT_PASSWORD_FIELD}=                password
${LOGIN_BUTTON}=                        //ui-button[@a-text="Login"]

${delta_file_reportingIntervalPm_5min}=          ${CURDIR}/../resources/Delta_Set_reportingIntervalPm_5min.json
${delta_file_reportingIntervalPm_60min}=         ${CURDIR}/../resources/Delta_Set_reportingIntervalPm_60min.json

@{BTS_NAME_PM}=                 M55121C00001    M55123C00003    M55314C02001
${CELL_NAME_PM}=                M55601C00001
${TNL_NAME_PM}=                 M51321C0



*** Keywords ***
5GC001542-CA_Check_BTS_counter_view
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_reportingIntervalPm_5min}
    ...                                                 skip_parameter_relation_errors=True
#    SELENIUM Prepare Enviroment                        #Commented due to Click Element  locator=${XPath_BTS} not found
    Login To Web Element Manager
    Go To BTS Counter Tab
    Wait Until Element Is Visible
    ...    locator=//span[@title="BTS"]
    ...    timeout=350
    Check BTS_NRBTS For PM In Main View
    Check CELLS_NRCELL For PM In Main View         pm_name=${CELL_NAME_PM}
    Close Browser
#    SELENIUM Teardown Enviroment                       #Commented due to Click Element  locator=${XPath_BTS} not found
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_reportingIntervalPm_60min}
    ...                                                 skip_parameter_relation_errors=True


5GC001542-CA_Check_BTS_transport_counters
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_reportingIntervalPm_5min}
    ...                                                 skip_parameter_relation_errors=True
    SELENIUM Prepare Enviroment
    Login To Web Element Manager
    Go To Transport Counters Tab
    Wait Until Element Is Visible
    ...    locator=//span[@title="TNL-1"]
    ...    timeout=350
    Check TNL For PM In Main View            pm_name=${TNL_NAME_PM}
    Close Browser
    SELENIUM Teardown Enviroment
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_reportingIntervalPm_60min}
    ...                                                 skip_parameter_relation_errors=True



Login To Web Element Manager
    [Arguments]    #${browser_url}=${WEBEM_IP}
    ...            ${webem_username}=${USERNAME}
    ...            ${webem_password}=${PASSWORD}
    #...            ${browser_type}=chrome
    #...            ${browser_alias}=browser
    Set Selenium Implicit Wait    5
    Open Browser
    SELENIUM Input Text in Visible Element
    ...    locator=${WELCOME_SCREEN_USERNAME_INPUT}
    ...    text=${webem_username}
    Input Text
    ...    locator=${WELCOME_SCREEN_PASS_INPUT}
    ...    text=${webem_password}
    Click Element
    ...    locator=${WELCOME_SCREEN_LOGIN_BTN}
    SELENIUM Pop Confirm
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//ui-button[@a-text="Close"]
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "STARTED")]
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "SUCCEEDED")]


Open Browser
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --window-size\=1900,1200
    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    https://192.168.255.129
    Sleep    10 secs


Go To BTS Counter Tab
    Wait Until Page Contains Element    locator=//div[@aria-describedby="admin.navigationBar.performance.TITLE"]
    Sleep  5s
    Click Element    locator=//div[@aria-describedby="admin.navigationBar.performance.TITLE"]
    Click Element    locator=//span[text()="Performance Management"]



Download Export Table
    Wait Until Element Is Visible    locator=//ui-button[@a-title='Export Table']//button
    ...                              timeout=15
    Click Button    locator=//ui-button[@a-title='Export Table']//button
    Sleep  1



Check BTS_NRBTS For PM In Main View
    Click Element    locator=${XPath_BTS}
    Click Element    locator=${XPath_NRBTS}
    Click Element    locator=${XPath_DU}
    Click Element    locator=${XPath_NR F1-U Interface Report DU}
    Click Element    locator=${XPath_M55314C02001}
    Click Element    locator=${XPath_NRCUUP}
    Click Element    locator=${XPath_NR E1AP Interface Report per CU-UP}
    Click Element    locator=${XPath_M55123C00003}
    Click Element    locator=${XPath_NR E1AP Interface Report per BTS}
    CLick Element    locator=${XPath_M55121C00001}
    Download Export Table
    FOR    ${i}    IN      @{BTS_NAME_PM}
       Wait Until Page Contains Element    locator=//th[contains(text(),'${i}')]
       Log    Name "${i}" is visible in PM Main View    console=yes
    END
    Sleep  2s
    Click Element    locator=${XPath_BTS_Collapse}



Check CELLS_NRCELL For PM In Main View
    [Arguments]    #${title}
    ...            ${pm_name}

    Click Element   locator=${XPath_CELLS}
    Click Element   locator=${XPath_NRCELL}
    Click Element   locator=${XPath_NR_Cell_Availability}
    Click Element   locator=${XPath_NR_Radio_Bearer}
    Download Export Table
    Wait Until Page Contains Element     locator=//th[contains(text(),'${pm_name}')]
    Log    Name "${pm_name}" is visible in PM Main View    console=yes
    Sleep  2s
    Click Element   locator=${XPath_CELLS_Collapse}


Check TNL For PM In Main View
    [Arguments]    #${title}
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
    ...    timeout=5
    Mouse Over
    ...    locator=//span[contains(text(),'Performance Management')]
    Wait Until Element Is Visible
    ...    locator=//span[contains(text(),'Transport Counters')]
    ...    timeout=5
    Click Element
    ...    locator=//span[contains(text(),'Transport Counters')]
