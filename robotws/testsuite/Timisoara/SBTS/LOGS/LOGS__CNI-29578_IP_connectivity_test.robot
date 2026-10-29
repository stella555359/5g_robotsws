*** Settings ***
Documentation  Test IP Connectivity
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    hran_radio
Library    SSHLibrary
Library    hran_pm
Library    DateTime
Resource    ../resources/verdicts.robot
Resource    ../resources/BTS_log_level.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${CLOSE_BROWSER_AFTER_TEST}       True           #If you want to stay windows browser open after the test, please set this parameter to False
${TESTED_IP_ADDRESS}              192.168.255.1  #In this parameter can be defined own IP address to perform the test on it
${xpath_ipconnectivity}  //*[@id="main-view"]/div/div[1]/div/div/div[1]/ng-view/wf-panel/wf-panel-section/div/div/ip-connectivity-test/
...    div/div/ip-connectivity-test-input/form/div/div[3]/div/wf-dropdown/div/ul/wf-dropdown-item[2]/li/a/span
${xpath_main_view}    //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[1]/ot-compact-drawer/button/span[1]
${xpath_panel}    //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[1]/ot-compact-drawer/p-sidebar
...    /div/div[2]/p-panelmenu/div/div[6]
*** Keywords ***
TC__LOGS__CNI-29578_IP_connectivity_test.robot
    [Documentation]
    ...  [CASE LINK] https://jira3.int.net.nokia.com/browse/TAT-18431
    ...
    ...  *****************
    ...  The purpose of this test case is check if IP connectivity test via Admin command line is working below 1-2 minutes.
    ...  CNI-29578 IP connectivity test need spend 1-2 minutes for each IP address - https://jira3.int.net.nokia.com/browse/CNI-29578
    ...  Test steps based on manual test: LOGS_IP_connectivity_test_all_configured_hosts
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  10.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18431 - test creation
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 24.10.2023 - TAT-26305 - Removed index*2 in Step 3, causing incorrect iteration of rows in table
    ...  - 11.01.2024 - TAT-26547 - Checking all resolved IP addresses of FQDN from req. OAM_REQ_WEBEM_1527, OAM_REQ_WEBEM_1531
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image: https://tatools.emea.nsn-net.net/static/hran_doc/LOGS__CNI-29578_IP_connectivity_test.png#


    Set Tags    CA-LOGS    OWNER-marcin.berkowski@nokia.com    AUTHOR-marcin.berkowski@nokia.com
    ...    MAINTAINER-marcin.berkowski@nokia.com    PHASE-CRT    SW-SBTS20A    GROUP_IN_CHARGE-WRO_6_Vrf    CNI-29578

    Test_Step.1 Check If Page Contains Needed Elements
    Test_Step.2 Select One Address As A Input For IP Connectivity Test
    Test_Step.3 Test All Configured Hosts
    Test_Step.4 Test User Defined Address


Test_Step.1 Check If Page Contains Needed Elements
    [Documentation]
    ...  In this test step is checked if page contains needed elements

    Log  \nTest_Step.1 Check If Page Contains Needed Elements  console=${True}

    Open WebEM
    Go To IP Connectivity Test

    Wait Until Page Contains Element  xpath=//h1[text()="IP Connectivity Test"]  timeout=20s
    Wait Until Page Contains Element  xpath=//label[text()="Scope:"]  timeout=20s
    Wait Until Page Contains Element  xpath=//label[text()="Address:"]  timeout=20s
    Wait Until Page Contains Element  xpath=//label[text()="Source address:"]  timeout=20s
    Wait Until Page Contains Element  xpath=//label[text()="Payload size:"]  timeout=20s
    Wait Until Page Contains Element  xpath=//span[text()="bytes [16...61411]"]  timeout=20s
    Wait Until Page Contains Element  xpath=//label[text()="DSCP:"]  timeout=20s
    Wait Until Page Contains Element  xpath=//span[text()="[0...63]"]  timeout=20s
    Wait Until Page Contains Element  xpath=//th[text()="Host"]  timeout=20s
    Wait Until Page Contains Element  xpath=//th[text()="Address"]  timeout=20s
    Wait Until Page Contains Element  xpath=//th[text()="Test result"]  timeout=20s

    #TAT-26547
    Check all resolved IP addresses of FQDN
    Log  Page contains needed elements [OK]  console=${True}

Open WebEM
    [Documentation]
    ...  In this keyword there is open WebEM via Chrome browser and it is checked time duration for this procedure
    ${time_0}=   Get Time
    ${conv_time_0}=   Convert Date    ${time_0}    epoch
    BTS_log_level.WebEM Login
    ${time_1}=   Get Time
    ${conv_time_1}=   Convert Date    ${time_1}    epoch
    ${delta_t}=    Evaluate   ${conv_time_1}-${conv_time_0}
    Run Keyword If    ${delta_t}>40
    ...  Log  Time for login to WebEM is quite long: ${delta_t} sec  WARN  console=yes
    ...  ELSE  Log  Login to WebEM in ${delta_t} sec [OK]  console=${True}
    Sleep  60s

Go To IP Connectivity Test
    [Documentation]
    ...  In this keyword Go To IP Connectivity Test in WebEM and it is checked time duration for this procedure

    Wait Until Page Contains Element  ${xpath_main_view}  timeout=30s
    ${time_0}=   Get Time
    ${conv_time_0}=   Convert Date    ${time_0}    epoch
    Click Element  //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[1]/ot-compact-drawer/button/span[1]
    Sleep  3
    Click Element  xpath=${xpath_panel}
    Click Element  xpath=//*[@id="ip-connectivity-test"]/div/span
    ${time_1}=   Get Time
    ${conv_time_1}=   Convert Date    ${time_1}    epoch
    ${delta_t}=    Evaluate   ${conv_time_1}-${conv_time_0}
    Run Keyword If    ${delta_t}>20
    ...  Log  Time for go to IP Connectivity is quite long: ${delta_t} sec  WARN  console=yes
    ...  ELSE  Log  Go To IP Connectivity Test in Chrome browser in ${delta_t} sec [OK]  console=${True}

Check all resolved IP addresses of FQDN
    [Documentation]
    ...  In this KW there are checked all resolved IP addresses of FQDN given in req. OAM_REQ_WEBEM_1531 (OAM_REQ_WEBEM_1527)

    Wait Until Page Contains    "User-defined address"   timeout=20s
    Click Element    xpath=//*[@ng-click='$ctrl.toggle($event)']/*/*[@title='User-defined address']
    Wait Until Page Contains    "All configured hosts"   timeout=20s
    Log  Page contains "All configured hosts" [OK]    console=${True}

    coam.Get Current Scf File   ${BTS Files}  scf.xml  export_type=configurationAndRuntimeObjects
    Setup Pm  scf_path=${BTS Files}/scf.xml

    Log  [TAT-26547] Checking all resolved IP addresses of FQDN from req. OAM_REQ_WEBEM_1527, OAM_REQ_WEBEM_1531    console=${True}
    @{list_of_parameters_to_check}=    Create list    ipAddrPrim  ipAddrSec  sgwIpAddress  rTPmCollEntityHost  remoteSyslogServerHost
    ...  currentSctpIpAddress  ntpServerIpAddrList  ntpServersList  ntpServerIpAddrOrFqdnList  ldapServerPrimary  masterIpAddr
    ...  serverHost  secondaryServerHost  serverIpAddressPrimary  serverIpAddressSecondary  bfdDestIpAddr  destIpAddress  gateway  gatewayIpv6Addr
    ...  mPlaneRemoteIpAddressOmuSig  mPlaneRemoteIpV6AddressOmuSig  mPlaneRemoteIpAddressOmuSig2  mPlaneRemoteIpV6AddressOmuSig2
    ...  amfIPAddress  ipAddr  vesEndpointIpAddress  nrNearRTRICIPAddress  rTPmCollEntityIpAddr  remoteSyslogServerIPaddress

    FOR  ${i}  IN  @{list_of_parameters_to_check}
      Check if Webpage contains given SCF par IP    ${i}
    END

    Click Element    xpath=//*[@ng-click='$ctrl.toggle($event)']/*/*[@title='User-defined address']

Check if Webpage contains given SCF par IP
    [Documentation]
    ...  In this KW there is checked if parameter {checked_parameter} exist in SCF
    ...  if yes then check if its value is present on current webpage (in WebEM)
    ...  if not then print info that such {checked_parameter} doesn't exist in SCF
    [arguments]  ${checked_parameter}
    ${does_parameter_exist}=    Set Variable    ${False}
    ${does_parameter_exist}    Run Keyword And Ignore Error    Get Scf Parameter    ${checked_parameter}
    Run Keyword If    '${does_parameter_exist}[0]' == 'PASS'    Run Keywords
    ...  Wait Until Page Contains    ${does_parameter_exist}[1]    timeout=20s
    ...  AND    Log    Page contains: ${checked_parameter} ${does_parameter_exist}[1] [OK]    console=${True}
    ...  ELSE   Log    Parameter doesn't exist in SCF: ${checked_parameter}    console=${True}

Test_Step.2 Select One Address As A Input For IP Connectivity Test
    [Documentation]
    ...  In this test step is tested only one host IP address and checked if test is Passed

    Log  \nTest_Step.2 Select One Address As A Input For IP Connectivity Test  console=${True}

    Log  Set Address: ${TESTED_IP_ADDRESS}  console=${True}
    Wait Until Page Contains Element  xpath=//input[@aria-labelledby='ip-connectivity-address-label']  timeout=20s
    Input Text  //input[@aria-labelledby='ip-connectivity-address-label']  ${TESTED_IP_ADDRESS}
    Click Start Button

    Log  Wait when test will be finished (max 2 min)  console=${True}
    ${test_tesult_xpath}=  Set Variable  //input[@aria-labelledby='ip-connectivity-table-test-result']
    Wait Until Page Contains Element  xpath=${test_tesult_xpath}  timeout=20s
    Wait Until Keyword Succeeds    2 min    3 sec    Wait For End Of Testing

    ${test_result_value}=  SeleniumLibrary.Get Value  xpath=${test_tesult_xpath}
    Run Keyword If   '${test_result_value}'=='Passed'  Run Keywords
    ...  Log  test_result_value is: ${test_result_value}  console=${True}
    ...  AND  Log  Test one address as a input for IP connectivity [OK]  console=${True}
    ...  ELSE IF  '${test_result_value}'=='Timeout'
    ...  Log  test_result_value is: ${test_result_value}  WARN  console=yes
    ...  ELSE  verdicts.Set Test Failed  Incorrect test_result_value: ${test_result_value}.

Click Start Button
    [Documentation]  Cilck on "Start" button in WebEM in Chrome browser
    ${start_button_xpath}=  Set Variable  //ui-button[@a-text="Start"]/button
    Wait Until Page Contains Element  xpath=${start_button_xpath}  timeout=20s
    Click Button  xpath=${start_button_xpath}

Wait For End Of Testing
    [Documentation]  Check if field with "Test result" is different from "Testing" state
    ${test_tesult_xpath}=  Set Variable  //input[@aria-labelledby='ip-connectivity-table-test-result']
    ${test_result_value}=  SeleniumLibrary.Get Value  xpath=${test_tesult_xpath}
    Should Not Be Equal  ${test_result_value}  Testing

Wait For End Of Testing Host I
    [Documentation]  Check if field with "Test result" in i-row is different from "Testing" state
    [arguments]  ${index}
    ${test_tesult_xpath}=  Set Variable  (//input[@aria-labelledby='ip-connectivity-table-test-result'])[${index}]
    ${test_result_value}=  SeleniumLibrary.Get Value  xpath=${test_tesult_xpath}
    Should Not Be Equal  ${test_result_value}  Testing

Test_Step.3 Test All Configured Hosts
    [Documentation]
    ...  In Step 3 it is tested IP connectivity for all IP hosts addresses and checked if test is Passed

    Log  \nTest_Step.3 Test All Configured Hosts  console=${True}

    Wait Until Keyword Succeeds    60    5   Click Element    xpath=//*[@ng-click='$ctrl.toggle($event)']/*/*[@title='User-defined address']
    Wait Until Keyword Succeeds    60    5   Click Element    xpath=//*[@title='All configured hosts']/*[@ng-click='$ctrl.selectItem($event)']/*

    Click Start Button

    Log  Start testing for all configured hosts (max 2 min for each IP hosts)  console=${True}
    FOR  ${index}    IN RANGE  1  50
      ${test_tesult_xpath}=  Set Variable  (//input[@aria-labelledby='ip-connectivity-table-test-result'])[${index}]
      ${check_if_exist_next_host}=  Run Keyword And Ignore Error  Page Should Contain Element  xpath=${test_tesult_xpath}  timeout=1s
      ${status}=  Get From List  ${check_if_exist_next_host}  0
      Run Keyword If   '${status}'=='FAIL'    Exit For Loop
      Wait Until Keyword Succeeds    2 min    3 sec    Wait For End Of Testing Host I  ${index}
      ${ip_xpath}=  Set Variable  (//td[@class='ng-binding'])[${index}]
      ${ip_value}=  SeleniumLibrary.Get Text  xpath=${ip_xpath}
      ${test_result_value}=  SeleniumLibrary.Get Value  xpath=${test_tesult_xpath}
      Run Keyword If   '${test_result_value}'=='Passed'
      ...  Log  Test ${index} host IP address ${ip_value}: ${test_result_value}  console=${True}
      ...  ELSE IF  '${test_result_value}'=='Timeout'
      ...  Log  Test ${index} host IP address ${ip_value}: ${test_result_value}  WARN  console=${True}
      ...  ELSE  verdicts.Set Test Failed  Incorrect test_result_value: ${test_result_value} for IP Address ${ip_value}.
    END

Test_Step.4 Test User Defined Address
    [Documentation]
    ...  In this test step is customized by user test
    ...  following parameters are changed: Address, Source address, Payload size, DSCP
    ...  and it is checked if tests was Passed

    Log  \nTest_Step.4 Test User Defined Address  console=${True}
    sleep    10

    Wait Until Page Contains Element    xpath=//*[@ng-click='$ctrl.toggle($event)']/*/*[@title='All configured hosts']    timeout=90

    Click Element    xpath=//*[@ng-click='$ctrl.toggle($event)']/*/*[@title='All configured hosts']
    sleep    3
#    Wait Until Page Contains Element    xpath=//*[@title='User-defined address']/*[@ng-click='$ctrl.selectItem($event)']/*    timeout=300
    Click Element    xpath=//*[@title='User-defined address']/*[@ng-click='$ctrl.selectItem($event)']/*

    Log  Set Address: ${TESTED_IP_ADDRESS}  console=${True}
    Wait Until Page Contains Element  xpath=//input[@aria-labelledby='ip-connectivity-address-label']  timeout=20s
    Input Text  //input[@aria-labelledby='ip-connectivity-address-label']  ${TESTED_IP_ADDRESS}

    ${payload_size}=  Evaluate  random.randint(16, 800)  modules=random
    Log  Set Payload size: ${payload_size}  console=${True}
    Input Text  xpath=//input[@aria-labelledby='ip-connectivity-paload-size-label']  ${payload_size}

    ${random_dscp}=  Evaluate  random.randint(0, 63)  modules=random
    Log  Set DSCP: ${random_dscp}  console=${True}
    Input Text  xpath=//input[@aria-labelledby='ip-connectivity-dscp-label']  ${random_dscp}

    Click Element    xpath=//span[@title='Default interface']

    Click Element    xpath=${xpath_ipconnectivity}
    Click Start Button

    Log  Wait when test will be finished (max 2 min)  console=${True}
    ${test_tesult_xpath}=  Set Variable  //input[@aria-labelledby='ip-connectivity-table-test-result']
    Wait Until Keyword Succeeds    2 min    3 sec    Wait For End Of Testing

    ${test_result_value}=  SeleniumLibrary.Get Value  xpath=${test_tesult_xpath}
    Run Keyword If   '${test_result_value}'=='Passed'  Run Keywords
    ...  Log  test_result_value is: ${test_result_value}  console=${True}
    ...  AND  Log  Test user defined address IP connectivity [OK]  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Incorrect test_result_value: ${test_result_value}.

Customer Test Teardown
    [Documentation]
    ...  In this test step the Chrome browser with WebEM is closed
    Run Keyword If  ${CLOSE_BROWSER_AFTER_TEST}==True
    ...  SeleniumLibrary.Close Browser
    ...  ELSE  Log   Browser window will be NOT closed   console=${True}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
    ...    AND    Customer Test Teardown
