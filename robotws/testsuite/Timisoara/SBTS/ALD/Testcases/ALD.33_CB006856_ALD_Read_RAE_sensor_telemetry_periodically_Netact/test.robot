*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/netact.robot
Resource    ../../resources/power_saving.robot


Documentation
...  TEST NAME:     ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact
...  AUTHORS:       mateusz.gadek@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test is to check if telemetry update interval is working correctly. Parameter is being changed via Netact
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  01.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-316 - Test creation
...  30.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-409 - Change logic in test ALD35. and ALD.34_CB006856_ALD_Read_RAE_sensor
...  15.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-454 - Add TAF Netact teardown to test ALD.33_CB006856_ALD_Read_RAE_sensor_with_Netact
...  09.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-491 - Fix for X2 link alarm for TC
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact

    ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact.Test_Step.0 Check If ALDs Are In Configuration
    ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact.Test_Step.1 Select RAE for testing
    ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact.Test_Step.2 Change telemetry interval via NetAct
    ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact.Test_Step.3 Check prints in syslog for RAE interval
    ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact.Test_Step.4 Reading RAE Sensor Data after update
    ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact.Test_Step.5 Check ALD State

ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${ALD_R_ALL}
    Set Test Variable  ${ALD_R_RAEs}
    IF  ${num_of_RAEs}==${0}  Fail  There is no at least one RAE in configuration
    Log  \n You have ${num_of_MHAs} MHAs and ${num_of_RETs} RETs and ${num_of_RAEs} RAEs in configuration  console=${True}
    Check And Resolve Google Chrome And Webdriver Version Compatibility
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Log  \n Adding flag 0x190303=2 to swconfig. (Change telemetry update interval time)  console=${True}
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Add Flag To Swconfig  0x190303=2
    Wait Until Keyword Succeeds  30min  60s  Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}


ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact.Test_Step.1 Select RAE for testing
    Log to console    \n========================================
    Log  Step: Testing  console=${True}
    Log to console    ========================================
    ${ALD_R}=  admin.get managed objects  ALD_R
    ${chosen_RAE}=  Select Random RAE  ${ALD_R_RAEs}
    ${ALD_R_to_ALD_A}=  Mapping ALD_R To ALD_A
    ${ALD_A}=  Get From Dictionary  ${ALD_R_to_ALD_A}  ${chosen_RAE}
    ${ignore}  ${ALD_A_TO_MAP}  Split String From Right  ${ALD_A}  separator=/  max_split=1
    ${RAE_ID_for_check}=   Evaluate  re.search(r'ALD_A-(\\d+)','''${ALD_A}''').group(1)  re
    Check Received RAE Info  ${RAE_ID_for_check}
    Set Test Variable  ${RAE_ID_for_check}

ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact.Test_Step.2 Change telemetry interval via NetAct
    Log to console    \n========================================
    Log  Step: 1 Go To Centralized RAE Management View   console=${True}
    Log to console    ========================================
    Set Parameter Under ALD Via NA  telemetryUpdateInterval  ${RAE_ID_for_check}  1

ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact.Test_Step.3 Check prints in syslog for RAE interval
    Log to console    \n========================================
    Log  Step: 2 Check prints in syslog for RAE interval console=${True}
    Log to console    ========================================
    Check Syslog For RAE Sensor Data Reading  start
    Sleep  300s
    Check Syslog For RAE Sensor Data Reading  end

ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact.Test_Step.4 Reading RAE Sensor Data after update
    Log to console    \n========================================
    Log  Step: Testing after parameter changed via Netact  console=${True}
    Log to console    ========================================
    Check Received RAE Info  ${RAE_ID_for_check}
    [Teardown]  Selenium2Library.Close All Browsers

ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact.Test_Step.5 Check ALD State
    Log to console    \n========================================
    Log  Step: 4 Check ALD State  console=${True}
    Log to console    ========================================
    Check ALDs State  ${ALD_expected_states}

ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keywords  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}  AND  Teardown TAF Netact
    ...  AND  Kill All Instances Of Chrome
    Run Keyword If Test Failed  ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact.Test Specific Teardown

