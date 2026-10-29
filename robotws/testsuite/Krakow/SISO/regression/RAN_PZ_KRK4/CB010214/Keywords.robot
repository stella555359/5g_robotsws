*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: CB010214 test case

Library    SeleniumLibrary
Library    taf.selenium.sc    WITH NAME    selenium
Library    ta_emss
Library    OperatingSystem
Library    taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations      WITH NAME   asir
Library    testsuite.Krakow.SISO.regression.RAN_PZ_KRK4.CB010214.resources.AsirSelenium.AsirWebEMOperations    WITH NAME    AsirWebEMOperations
Library    ./resources/syslog.py
Resource   taf/rfrl/bts/robot/gnb.robot
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables  ./resources/variables.py

*** Variables ***
${LOGIN URL}       https://${tl.gnbs[0].cu.oam_http_connection_details.addr}:3601/
${BROWSER}         Chrome
${username}        Nemuadmin
${password}        nemuuser
${XPATH_terminated_session}               //div[@class="last-modal-background ng-star-inserted"]
${XPATH_not_terminated_session}           //div[@aria-label="The session will not be terminated due to R/W session is allowed."]
${XPATH_errorAuthLogin}                   //div[@id="errorAuthLogin"]
${bts_id}          ${tl.gnbs[0].global_bts_id}
${emssim_host}     ${tl.test_pc.default_ssh_connection_details.addr}
${emssim_user}     asir1
${macro_emssim_user}     macro1
${terminated_session_warning}         Terminated warning\nThe session will be terminated in 60 seconds due to no R/W session is allowed.\nClose
${not_terminated_session_warning}     The session will not be terminated due to R/W session is allowed.
${errorAuthLogin}                     No read/write session is allowed.
${btsEMRestrictedAccessLogoutTimer}   60

*** Keywords ***
CB010214-F_Modification_of_btsEMRestrictAccSession
    Prepare Tools
    btslogcollector.Start Collecting Btslog
    Activate NE3S
    Login ASIR WebEM
    Disallow RW Session And Wait For Warning Window
    Close No RW Session Allowed Warning Window
    Deactivate RW Session Control And Wait For Confirmation Window
    Wait Restricted Access Logout Time
    Disallow RW Session And Wait For Warning Window
    Wait Restricted Access Logout Time
    Enter Login Credentials
    Verify RW Session Locked
    Deactivate NE3S
    Sleep  10
    btslogcollector.Stop Collecting Btslog
    Verify NMS Msg In Syslog
    ...    msg=NMS_CONN_NOK
    Login ASIR WebEM
    btslogcollector.Start Collecting Btslog
    Activate NE3S
    Wait For No RW Session Allowed Warning Window
    Close No RW Session Allowed Warning Window
    Sleep  10
    btslogcollector.Stop Collecting Btslog
    Verify NMS Msg In Syslog
    ...    msg=NMS_CONN_OK
    Deactivate RW Session Control And Wait For Confirmation Window
    [Teardown]  run keywords
    ...    Deactivate NE3S
    ...    AND    Run Keyword And Ignore Error  selenium.logout
    ...    AND    selenium.close_browser


*** Keywords ***
Prepare Macro EMSSIM
    OperatingSystem.Run  sudo iptables -I INPUT --proto tcp --match multiport --dport 80,443,8080,8443,6080 -j ACCEPT
    OperatingSystem.Run    sudo iptables -I INPUT 1 -p tcp -i eth0 -m tcp --dport 6443 -j ACCEPT
    OperatingSystem.Run    sudo iptables -I INPUT 1 -p tcp -i eth0 -m tcp --dport 14601 -j ACCEPT
    Run    sudo /opt/emssim/util/add_user.pl -u ${macro_emssim_user} -ip ${tl.gnbs[0].cu.oam_http_connection_details.addr}
    Sleep    5s
    Run    cd /home/${macro_emssim_user}
    ${HOST}    Run    hostname -i
    Setup Emss    bts_id=${bts_id}    host=${HOST}    user=${macro_emssim_user}    wait_connected=False    alias=macroAC

Prepare ASiR EMSSIM
    OperatingSystem.Run  sudo iptables -I INPUT --proto tcp --match multiport --dport 80,443,8080,8443,6080 -j ACCEPT
    OperatingSystem.Run    sudo iptables -I INPUT 1 -p tcp -i eth0 -m tcp --dport 6443 -j ACCEPT
    OperatingSystem.Run    sudo iptables -I INPUT 1 -p tcp -i eth0 -m tcp --dport 14601 -j ACCEPT
    Run    sudo /opt/emssim/util/add_user.pl -u ${emssim_user} -ip ${tl.gnbs[0].cu.oam_http_connection_details.addr}
    Sleep    5s
    Run    cd /home/${emssim_user}
    ${HOST}    Run    hostname -i
    Setup Emss    bts_id=${bts_id}    host=${HOST}    user=${emssim_user}    wait_connected=False    alias=asirAC

Prepare webdriver
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --maximized
    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Call Method    ${chrome options}    add_argument    --disable-extensions
    Call Method    ${chrome options}    add_argument    --disable-dev-shm-usage
    ${webdriver}=    Create Webdriver    Chrome    alias=chromedriver    chrome_options=${chrome options}
    ${sl}=    BuiltIn.get_library_instance    SeleniumLibrary
    ${webdriver} =    Set Variable    ${sl.driver}
    set global variable    ${webdriver}

Wait Restricted Access Logout Time
    ${btsEMRestrictedAccessLogoutTimer_int}    Convert To Integer    ${btsEMRestrictedAccessLogoutTimer}
    sleep    ${btsEMRestrictedAccessLogoutTimer_int+5}

Wait For No RW Session Allowed Warning Window
    ${msg_terminated_session}    Wait Until Keyword Succeeds  6 sec  2 sec    get text   ${XPATH_terminated_session}
    should be equal  ${msg_terminated_session}  ${terminated_session_warning}

Disallow RW Session And Wait For Warning Window
    AsirWebEMOperations.set_asir_parameter_value    ASI-1/SECPRM-1    btsEMRestrictAccSession    NoRWsessionAllowed
    Wait For No RW Session Allowed Warning Window

Deactivate RW Session Control And Wait For Confirmation Window
    AsirWebEMOperations.set_asir_parameter_value    ASI-1/SECPRM-1    btsEMRestrictAccSession    RWsessionCtrlNotActivated
    ${msg_not_terminated_session}    Wait Until Keyword Succeeds  6 sec  2 sec    get text   ${XPATH_not_terminated_session}
    should be equal  ${msg_not_terminated_session}  ${not_terminated_session_warning}

Verify RW Session Locked
    ${msg_errorAuthLogin}    Wait Until Keyword Succeeds  6 sec  2 sec    get text   ${XPATH_errorAuthLogin}
    should be equal  ${msg_errorAuthLogin}    ${errorAuthLogin}

Prepare Tools
    Prepare ASiR EMSSIM
    Prepare webdriver
    AsirWebEMOperations.setup    ${webdriver}
    sleep    120

Activate NE3S
    Run EMSSIM Command  ne3s_activate   bts_id=${bts_id}  get_full_data=True  alias=asirAC

Deactivate NE3S
    Run EMSSIM Command  ne3s_deactivate   bts_id=${bts_id}  get_full_data=True  alias=asirAC

Login ASIR WebEM
    selenium.login    url=${LOGIN URL}    username=${username}    password=${password}  browser=${webdriver}
