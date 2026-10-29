*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand
...  AUTHORS:       mateusz.gadek@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test is to check if BTS Element Manager provides read telemetry on demnad for RAE unit
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  01.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-316 - Test creation
...  30.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-409 - Change logic in test ALD35. and ALD.34_CB006856_ALD_Read_RAE_sensor
...  18.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28872 - Fixes for new SBTS interface
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand

    ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand.Test_Step.0 Check If ALDs Are In Configuration
    ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand.Test_Step.1 Open Centralized RET Management And Read RAE Sensor Data
    ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand.Test_Step.2 Reset radio with connected RAE
    ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand.Test_Step.3 Reading RAE Sensor Data after radio reset
    ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand.Test_Step.4 Check ALD State

ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${ALD_R_ALL}
    Set Test Variable  ${ALD_R_RAEs}
    IF  ${num_of_RAEs}==${0}  Fail  msg=There is no at least one RAE in configuration
    Log  \n You have ${num_of_MHAs} MHAs and ${num_of_RETs} RETs and ${num_of_RAEs} RAEs in configuration  console=${True}
    Check And Resolve Google Chrome And Webdriver Version Compatibility

ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand.Test_Step.1 Open Centralized RET Management And Read RAE Sensor Data
    Log to console    \n========================================
    Log  Step: 1 Go To Centralized RAE Management View   console=${True}
    Log to console    ========================================
    ${ALD_R}=  admin.get managed objects  ALD_R
    ${chosen_RAE}=  Select Random RAE  ${ALD_R_RAEs}
    Set Test Variable  ${chosen_RAE}
    Open Chrome Browser
    Login To WebEM
    ${enb_release}  coam.get sw release name
    Log  sw release :${enb_release}  console=True
    ${sw}  coam.Get Sw Version
    Log  active sw :${sw}  console=True
    ${sw_fsm_status}  Run Keyword And Return Status  Should Not Contain  ${sw}  FSM
    IF  ${sw_fsm_status} and '${enb_release}' >= 'SBTS25R1'
      Go To Centralized RAE Management View New GUI
    ELSE
      Go To Centralized RAE Management View
    END
    IF  ${sw_fsm_status} and '${enb_release}' >= 'SBTS25R1'
      Read Sensor Data New GUI    ${chosen_RAE}
    ELSE
      Read Sensor Data    ${chosen_RAE}
    END
    [Teardown]  Selenium2Library.Close All Browsers

ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand.Test_Step.2 Reset radio with connected RAE
    Log to console    \n========================================
    Log  Step: 2 Reset radio with connected RAE device  console=${True}
    Log to console    ========================================
    ${ignore}  ${ald_r}=  Split String From Right  ${chosen_RAE}  separator=APEQM_R-1/
    Log  RAE for check: ${ald_r}    console=${true}
    ${DC}  ${conf}  ALD Connection Mapping
    ${rae_index}=	Get Index From List	 ${DC}	${ald_r}
    ${rmod_index}=  Evaluate  ${rae_index}-1
    ${rmod_to_reset}=  Get From List  ${DC}  ${rmod_index}
    Log  \n Reseting ${rmod_to_reset}  console=${true}
    admin.reset unit  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/${rmod_to_reset}  reset_type=Hard  timeout=600
    Check If NLWG Cells Are OnAir
    Log  \n Checking ALD state after ${rmod_to_reset} reset:  console=${True}
    Check ALDs State  ${ALD_expected_states}

ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand.Test_Step.3 Reading RAE Sensor Data after radio reset
    Log to console    \n========================================
    Log  Step: 3 Reading RAE Sensor Data after radio reset  console=${True}
    Log to console    ========================================
    Open Chrome Browser
    Login To WebEM
    ${enb_release}  coam.get sw release name
    Log  sw release :${enb_release}  console=True
    ${sw}  coam.Get Sw Version
    Log  active sw :${sw}  console=True
    ${sw_fsm_status}  Run Keyword And Return Status  Should Not Contain  ${sw}  FSM
    IF  ${sw_fsm_status} and '${enb_release}' >= 'SBTS25R1'
      Go To Centralized RAE Management View New GUI
    ELSE
      Go To Centralized RAE Management View
    END
    IF  ${sw_fsm_status} and '${enb_release}' >= 'SBTS25R1'
      Read Sensor Data New GUI    ${chosen_RAE}
    ELSE
      Read Sensor Data    ${chosen_RAE}
    END
    [Teardown]  Selenium2Library.Close All Browsers

ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand.Test_Step.4 Check ALD State
    Log to console    \n========================================
    Log  Step: 4 Check ALD State  console=${True}
    Log to console    ========================================
    Check ALDs State  ${ALD_expected_states}

ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keywords  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    ...  AND  Kill All Instances Of Chrome
    Run Keyword If Test Failed  ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand.Test Specific Teardown
