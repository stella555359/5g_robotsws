*** Settings ***
Force Tags  SBTS00  SRAN  CLOUD_SRAN_LWG_2ASIA_5ABIA_2FRGY_2FXDB_1AHEB  STATE_SKIP_AGENT
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_Radio_Reset.robot
Resource    ../../WebEM/test_resources/WebEM__Automatically_log_off_and_Session_Lock.robot

*** Variables ***
${SCF_ID}    01

*** Test Cases ***
Test
    Log Variables

Open browser WebEM
    Specifying a Known Mobile Device with Chrome

[1]WebEM__Admin_CLI_Radio_Reset
    [Timeout]    14400
    [Setup]     WebEM__Admin_CLI_Radio_Reset.TC Setup
    TC__WebEM__Admin_CLI_Radio_Reset
    [Teardown]  WebEM__Admin_CLI_Radio_Reset.TC Teardown

[1]WebEM__Automatically_log_off_and_Session_Lock
    [Timeout]    14400
    [Setup]     WebEM__Automatically_log_off_and_Session_Lock.TC Setup
    TC__WebEM__Automatically_log_off_and_Session_Lock
    [Teardown]  WebEM__Automatically_log_off_and_Session_Lock.TC Teardown



*** Keywords ***
Specifying a Known Mobile Device with Chrome
    [Documentation]  This keyword open the browser in mobile view with Chrome.
    ${var_user_agent}  Catenate
    ...  "Mozilla/5.0 (Linux; Android 4.2.1; en-us; Nexus 5 Build/JOP40D)"
    ...  \ "AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.166 Mobile Safari/535.19"
    ${USER_AGENT}  Set variable  ${var_user_agent}
    ${visual}  Create dictionary  width=${900}  height=${700}  pixelRatio=${4.0}
    ${MOBILE_EMULATION}  Create dictionary  userAgent=${USER_AGENT}  deviceMetrics=${visual}
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_experimental_option    mobileEmulation    ${MOBILE_EMULATION}
    Call Method    ${chrome options}    add_argument    --ignore-ssl-errors
    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --disable-popup-blocking
    Create Webdriver    Chrome    options=${chrome options}
    Go to    https://192.168.255.129
    Sleep    10 secs