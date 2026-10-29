*** Settings ***
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/common.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/alarms.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/ald.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/selenium.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors
...  AUTHORS:       mateusz.gadek@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test is to read stored 2D beamforming weight factors from RAE device. Feature CB006856.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  07.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-314 - Test creation
...  24.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-437 - Change logics and extend timeouts in selenium KWs
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***


*** Keywords ***
ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors

    ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors.Test_Step.0 Check If ALDs Are In Configuration
    ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors.Test_Step.1 Enter Centralized RAE Management
    ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors.Test_Step.2 Getting 2D Weight Factors
    ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors.Test_Step.3 Check ALD State

ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable    ${ALD_R_ALL}
    set test variable    ${ALD_R_RAEs}
    Run Keyword If  ${num_of_RAEs}==${0}
    ...  Fail  msg=There is no at least one RAE in configuration
    Log  You have ${num_of_MHAs} MHAs and ${num_of_RETs} RETs and ${num_of_RAEs} RAEs in configuration  console=${True}
    Check And Resolve Google Chrome And Webdriver Version Compatibility

ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors.Test_Step.1 Enter Centralized RAE Management
    Log to console    \n========================================
    Log  Step: 2 Enter Centralized RAE Management View   console=${True}
    Log to console    ========================================
    Open Chrome Browser
    Login To WebEM
    Go To Centralized RAE Management View

ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors.Test_Step.2 Getting 2D Weight Factors
    Log to console    \n========================================
    Log  Step: 2 Check Weight Factors Table Content  console=${True}
    Log to console    ========================================
    Get RAE Weight Factors    2D
    [Teardown]  Selenium2Library.Close All Browsers

ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors.Test_Step.3 Check ALD State
    Log to console    \n========================================
    Log  Step: 4 Check ALD State  console=${True}
    Log to console    ========================================
    Check ALDs State  ${ALD_expected_states}

ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keywords  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    ...  AND  Kill All Instances Of Chrome
    Run Keyword If Test Failed  ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors.Test Specific Teardown
