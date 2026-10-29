*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to verify proper functioning of ALD selection window options, namely: assignment to aldAllowedList
...  and setting hdlcStartAddr.
...  The ALD sharing feature is only applicable for AISG 2.0 ALD and for ALDs which are detected from radio with OBSAI, CPRI-N and eCPRI protocol.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  23.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-298 - Test creation
...  23.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-522 - Automated__ALD__sharing_management_in_ALD fix for watchdog fid10
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM

	ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM.Test_Step.0 Check If ALDs Are In Configuration
    ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM.Test_Step.1 Feature Activation
    ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM.Test_Step.2 Set ALD Sharing And Verify Table Content
    ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM.Test_Step.3 Feature Deactivation
    ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM.Test_Step.4 Check ALD State

ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${ALD_R_ALL}
    IF  ${num_of_MHAs}==${0} and ${num_of_RETs}==${0}  Fail  msg=There is no at least one ALD in configuration
    Log  You have ${num_of_MHAs} MHAs and ${num_of_RETs} RETs in configuration  console=${True}
    Check And Resolve Google Chrome And Webdriver Version Compatibility

ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM.Test_Step.1 Feature Activation
    Log to console    \n========================================
    Log  Step: 1 Feature Activation  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=10  #fault_name: No connection to unit
    ${feature_state}  Set Feature On Expected Value  parameter=actAldSharing  value=true  #since 23R2
    Set Test Variable  ${feature_state}
    IF  '${feature_state}' == 'true'
        Open Chrome Browser
        Login To WebEM
        Remove ALD Sharing For All Devices
    END
    [Teardown]  Selenium2Library.Close All Browsers

ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM.Test_Step.2 Set ALD Sharing And Verify Table Content
    Log to console    \n========================================
    Log  Step: 2 Check Button In ALD Sharing Configuration  console=${True}
    Log to console    ========================================
    Open Chrome Browser
    Login To WebEM
    Set ALD Sharing For All Devices
    Sleep    5s
    Check ALD Allowed List Table
    Sleep    5s
    Check ALD HDLC List Table
    Check ALDs State  ${ALD_expected_states}
    Wait For Inactive Fault  faultID=10  timeout=1min
    Disallow Fault In Watchdog  faultID=10  #fault_name: No connection to unit
    [Teardown]  Selenium2Library.Close All Browsers

ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM.Test_Step.3 Feature Deactivation
    Log to console    \n========================================
    Log  Step: 3 Feature Deactivation  console=${True}
    Log to console    ========================================
    Open Chrome Browser
    Login To WebEM
    Allow Fault In Watchdog  faultID=10  #fault_name: No connection to unit
    Remove ALD Sharing For All Devices
    Set Feature On Expected Value  parameter=actAldSharing  value=false
    Sleep  60s
    Disallow Fault In Watchdog  faultID=10  #fault_name: No connection to unit
    [Teardown]  Selenium2Library.Close All Browsers

ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM.Test_Step.4 Check ALD State
    Log to console    \n========================================
    Log  Step: 4 Check ALD State  console=${True}
    Log to console    ========================================
	Check ALDs State  ${ALD_expected_states}

ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    IF  '${feature_state}' == 'true'
        Allow Fault In Watchdog  faultID=10  #fault_name: No connection to unit
        Set Feature On Expected Value  parameter=actAldSharing  value=true
        Open Chrome Browser
        Login To WebEM
        Set ALD Sharing For All Devices
        Sleep  60s
        Disallow Fault In Watchdog  faultID=10  #fault_name: No connection to unit
    ELSE
        Set Feature On Expected Value  parameter=actAldSharing  value=false
    END
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    IF  '${feature_state}' == 'true'
        Allow Fault In Watchdog  faultID=10  #fault_name: No connection to unit
        Set Feature On Expected Value  parameter=actAldSharing  value=true
        Open Chrome Browser
        Login To WebEM
        Set ALD Sharing For All Devices
        Sleep  60s
        Disallow Fault In Watchdog  faultID=10  #fault_name: No connection to unit
    ELSE
        Set Feature On Expected Value  parameter=actAldSharing  value=false
    END
    Run Keywords  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    ...  AND  Kill All Instances Of Chrome
    Run Keyword If Test Failed  ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM.Test Specific Teardown
