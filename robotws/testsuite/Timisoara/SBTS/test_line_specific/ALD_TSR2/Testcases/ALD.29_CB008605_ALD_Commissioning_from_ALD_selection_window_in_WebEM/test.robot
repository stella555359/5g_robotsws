*** Settings ***
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/common.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/alarms.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/ald.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/selenium.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to verify if the option to commission ALDs in CW by entering it from ALD selection window works as expected.
...  The ALD sharing feature is only applicable for AISG 2.0 ALD and for ALDs which are detected from radio with OBSAI, CPRI-N and eCPRI protocol.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  23.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-299 - Test creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***


*** Keywords ***
ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM

	ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM.Test_Step.0 Check If ALDs Are In Configuration
    ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM.Test_Step.1 Feature Activation
    ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM.Test_Step.2 Check Button In ALD Sharing Configuration
    ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM.Test_Step.3 Feature Deactivation
    ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM.Test_Step.4 Check ALD State

ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${ALD_R_ALL}
    Run Keyword If  ${num_of_MHAs}==${0} and ${num_of_RETs}==${0}
    ...  Fail  msg=There is no at least one ALD in configuration
    Log  You have ${num_of_MHAs} MHAs and ${num_of_RETs} RETs in configuration  console=${True}
    Check And Resolve Google Chrome And Webdriver Version Compatibility

ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM.Test_Step.1 Feature Activation
    Log to console    \n========================================
    Log  Step: 1 Feature Activation  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=10  #fault_name: No connection to unit
    ${feature_state}  Set Feature On Expected Value  parameter=actAldSharing  value=true  #since 23R2
    Set Test Variable  ${feature_state}

ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM.Test_Step.2 Check Button In ALD Sharing Configuration
    Log to console    \n========================================
    Log  Step: 2 Check Button In ALD Sharing Configuration  console=${True}
    Log to console    ========================================
    Open Chrome Browser
    Login To WebEM
    Check Button In ALD Sharing Configuration
    [Teardown]  Selenium2Library.Close All Browsers

ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM.Test_Step.3 Feature Deactivation
    Log to console    \n========================================
    Log  Step: 3 Feature Verification and Deactivation if needed  console=${True}
    Log to console    ========================================
    Run Keyword If  '${feature_state}' == 'true'  Set Feature On Expected Value  parameter=actAldSharing  value=true
    ...  ELSE
    ...  Set Feature On Expected Value  parameter=actAldSharing  value=false

ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM.Test_Step.4 Check ALD State
    Log to console    \n========================================
    Log  Step: 4 Check ALD State  console=${True}
    Log to console    ========================================
	Check ALDs State  ${ALD_expected_states}
	Disallow Fault In Watchdog  faultID=10  #fault_name: No connection to unit

ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword If  '${feature_state}' == 'true'  Set Feature On Expected Value  parameter=actAldSharing  value=true
    ...  ELSE
    ...  Set Feature On Expected Value  parameter=actAldSharing  value=false
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keywords  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    ...  AND  Kill All Instances Of Chrome
    Run Keyword If Test Failed  ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM.Test Specific Teardown
