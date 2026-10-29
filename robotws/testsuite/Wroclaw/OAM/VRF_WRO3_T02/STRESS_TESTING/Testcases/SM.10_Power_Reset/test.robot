*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/apc.robot
Resource    ../../../resources_mem/selenium.robot
Resource    ../../../resources_mem/oam_kpi.robot

Documentation
...  TEST NAME:     SM.10_Power_Reset
...  AUTHORS:       anna.niedzwiecka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform power reset operation, check eNB status.
...  *****************
...  Pre-conditions
...  *****************
...  PDU informations:IP, outlet(s) in config file, eg.: PDU_IP, PDU_PRIMARY_CORE, if fullrack: PDU_SECONDARY_CORE
...  ******************
...  History of changes
...  ******************
...  23.11.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - Test creation
...  08.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - Apply APC Control keyword from UUF to control PDU
...  01.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - Added KW "Collect SW History Report" as a workaround solution for TEMPO
...  26.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - Resource added to APC_Contrl for checking SNMP.
...  21.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-410 - modification in accordance with CB007040;
...               random selection added due to PR729323 not visible during CB007040 power resets.
...  02.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-487 - robotws migration and small hotfixes
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
SM.10_Power_Reset

    SM.10_Power_Reset.Test_Step:0 Test Preparation
    SM.10_Power_Reset.Test_Step:1 Perform Power Reset
    SM.10_Power_Reset.Test_Step:2 Check BTS
    SM.10_Power_Reset.Test_Step:3 KPI Time Measurement

SM.10_Power_Reset.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${rats}  Detect RATs
    Set Test Variable  ${rats}
    Check If NLWG Cells Are OnAir
    SCF Backup
    ${method_defined}  Run Keyword And Return Status  Variable Should Exist  ${POWER_RESET_METHOD}
    Set Test Variable  ${method_defined}

SM.10_Power_Reset.Test_Step:1 Perform Power Reset
    Log to console    \n========================================
    Log  Step: 1 Perform Power Reset  console=${True}
    Log to console    ========================================
    ${PDU_or_APC_or_EPC}  Run Keyword If  ${method_defined}  Run Keyword And Return Status
    ...    Evaluate  re.search(r'(?i)PDU|[A|E]PC', '${POWER_RESET_METHOD}').group(0)  re
    ${looks_like}         Run Keyword If  ${method_defined}  Run Keyword And Return Status
    ...    Evaluate  re.search(r'(?i)POWER|CB007040', '${POWER_RESET_METHOD}').group(0)  re
    ${random}             Run Keyword If  ${method_defined}  Run Keyword And Return Status
    ...    Evaluate  re.search(r'(?i)RANDOM', '${POWER_RESET_METHOD}').group(0)  re
    ${nr_exist}  Run Keyword And Return Status  List Should Contain Value  ${rats}  nr
    Allow Fault In Watchdog  faultID=9     #fault_name: Difference between BTS master clock and reference frequency
    Allow Fault In Watchdog  faultID=1898  #fault_name: PPS reference missing
    Allow Fault In Watchdog  faultID=4122  #fault_name: GPS receiver alarm: not tracking satellites
    Allow Fault In Watchdog  faultID=4123  #fault_name: GPS receiver alarm: survey in progress
    Allow Fault In Watchdog  faultID=4124  #fault_name: GPS receiver alarm: no stored position
    Allow Fault In Watchdog  faultID=4125  #fault_name: GPS receiver alarm: position questionable
    Allow Fault In Watchdog  faultID=4590  #fault_name: Fault signature for crash or failure
    Set Test Variable    ${nr_exist}
    Run Keyword If  ${nr_exist}  Run Keywords  Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
                                 ...    AND    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
                                 ...    AND    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Run Keyword If  not ${method_defined} and ${CB007040_available}       Power Reset Through CB007040
    ...    ELSE IF  ${looks_like}                                         Power Reset Through CB007040
    ...    ELSE IF  not ${method_defined} and not ${CB007040_available}   Power Reset Through APC
    ...    ELSE IF  ${PDU_or_APC_or_EPC}                                  Power Reset Through APC
    ...    ELSE IF  ${random} and ${CB007040_available}                   Power Reset Through Random Method

Power Reset Through APC
    Log To Console  Power reset via APC
    ${POWER_ON_TIMESTAMP}  DateTime.Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
    Set Test Variable  ${POWER_ON_TIMESTAMP}
    APC Control  REBOOT  SM
    ${status}  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=${MSM_IP}  timeout=600
    Log To Console  Wait for target to be reachable after power reset
    ${status}  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=${MSM_IP}
    Log To Console  Check if target is stable for 180s
    ${ping_status}  ${reset_counter}  Check If Target Is Stable And Return Reset Counter  ip=${MSM_IP}  min_uptime=180  max_downtime=180  timeout=1400
    Log  Reset Counter incremented +${reset_counter} after 180s uptime

Power Reset Through CB007040
    [Documentation]  Keywords allows to trigger BTS power off/on "look- alike" reset remotely.
    Log To Console  Power off/on "look- alike"
    admin.Power Reset  wait_for_reconnection=true
    ${ping_status}  ${reset_counter}  Check If Target Is Stable And Return Reset Counter  ip=${MSM_IP}  min_uptime=180  max_downtime=180  timeout=1400
    Log  Reset Counter incremented +${reset_counter} after 180s uptime

Power Reset Through Random Method
    ${methods}    Create List    Power Reset Through APC    Power Reset Through CB007040
    ${selected_method}    Evaluate  random.choice(${methods})  random
    Run Keyword If    '${selected_method}'=='Power Reset Through APC'       ${selected_method}
    ...    ELSE IF    '${selected_method}'=='Power Reset Through CB007040'  ${selected_method}
    Set Test Variable  ${selected_method}

SM.10_Power_Reset.Test_Step:2 Check BTS
    Log to console    \n========================================
    Log  Step: 2 Check BTS  console=${True}
    Log to console    ========================================
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    ${BTS_on_Air}  Run Keyword And Return Status  Check If NLWG Cells Are OnAir
    Run Keyword If  ${BTS_on_Air} and ${nr_exist}  Run Keywords    Wait For Inactive Fault  faultID=6327  timeout=1min
                                                     ...    AND    Wait For Inactive Fault  faultID=7300  timeout=1min
                                                     ...    AND    Wait For Inactive Fault  faultID=7319  timeout=1min
    Wait For Inactive Fault  faultID=1898  timeout=5min
    Disallow Fault In Watchdog  faultID=9     #fault_name: Difference between BTS master clock and reference frequency
    Disallow Fault In Watchdog  faultID=1898  #fault_name: PPS reference missing
    Disallow Fault In Watchdog  faultID=4122  #fault_name: GPS receiver alarm: not tracking satellites
    Disallow Fault In Watchdog  faultID=4123  #fault_name: GPS receiver alarm: survey in progress
    Disallow Fault In Watchdog  faultID=4124  #fault_name: GPS receiver alarm: no stored position
    Disallow Fault In Watchdog  faultID=4125  #fault_name: GPS receiver alarm: position questionable
    Disallow Fault In Watchdog  faultID=4590  #fault_name: Fault signature for crash or failure
    Run Keyword If  ${nr_exist}  Run Keywords  Wait Until Keyword Succeeds  10min  1min  Check X2 Link
                                 ...    AND    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
                                 ...    AND    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
                                 ...    AND    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB

SM.10_Power_Reset.Test_Step:3 KPI Time Measurement
    Log to console    \n========================================
    Log  Step: 3 KPI Time Measurement  console=${True}
    Log to console    ========================================
    Run Keyword And Ignore Error  Run Keyword If  '${selected_method}'=='Power Reset Through APC'
    ...  Calculate KPI3  ${POWER_ON_TIMESTAMP}  ${ITERATION_INDEX}
    Run Keyword And Ignore Error  Run Keyword If  '${selected_method}'=='Power Reset Through CB007040'
    ...  Calculate KPI11  ${ITERATION_INDEX}

SM.10_Power_Reset.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY
