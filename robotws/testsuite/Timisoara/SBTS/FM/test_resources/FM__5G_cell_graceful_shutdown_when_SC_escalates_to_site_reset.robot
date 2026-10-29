*** Settings ***
Documentation
    ...  This test case is created to check gracefully shutdown of the NR cells.
    ...  actForceAutoReset and actFaultSignature parameters will be set to true.
    ...  Crash will be done by sending fault 2080 to secondary core.
    ...  After the 3rd fault 2080 sent on secondary escalation to site reset will be checked.
    ...  Presence of fault 2080 will be checked in WebEM and Netact. Recovery of services will be checked.
    ...  Fault 2080 should have correct fault signature, gracefully shutdown of NR cells mapped on primary should appear.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${PING_TIMEOUT}  240  # [in seconds] Timeout for SBTS to be reachable after reset.
${ALARM_TIMEOUT}  240  # [in seconds] Timeout for alarm to be reported in WebEM.
${NETACT_TIMEOUT}  240  # [in seconds] Timeout for alarm to be reported in Netact.
${STARTUP_TIMEOUT}  900  # [in seconds] Timeout for SBTS startup after site reset.


*** Keywords ***
TC__FM__5G_cell_graceful_shutdown_when_SC_escalates_to_site_reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26134
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  15.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26134 - Initial TAT creation
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  06.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26772 - Option to disable alarm check on MantaRay
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  21.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27160 - Keyword enhancement in resource file
    ...  17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27606 - Multiple keywords for checking fault signature in FM testcases
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  01.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  05.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  05.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29097 - Enhancement replace the FaultGenerator for FID 2080 by cmd line command
    ...  18.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30645 - Changed the parameter value to lowercase
    ...  *******************

    Set Tags  CA-FM  OWNER-marius.irimia@nokia.com  AUTHOR-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS21  FEATURE-RP002956

    Step0: Set Parameters
    Step1: Perform Site Reset
    Step2: Send Fault 2080 On Secondary Core
    Step3: Send Fault 2080 On Secondary Core
    Step4: Send Third Fault On Secondary Core
    Step5: Check Alarm History


Step0: Set Parameters
    Log  Step0: Set parameters.  console=true
    Change FMCADM Parameter  actForceAutoReset  true
    Set ActFaultSignature Value  true
    Set Variables For Fault Signature Check


Step1: Perform Site Reset
    Log  Step1: Perform site reset.  console=true
    Perform Site Reset


Step${index}: Send Fault 2080 On Secondary Core
    Log  Step${index}: Send fault 2080 on secondary core.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Open Connection To Primary Core
    Open Connection To Secondary Core
    SSHLibrary.Write  rio hpdalm send hld
    SSHLibrary.Read Until Prompt
    ${fault_2080_params}  Get String With Alarm Parameters  ${FAULT_2080_2_ND_CORE_AUTO_RST}
    Assert Alarm Active  parameters=${fault_2080_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_2080_2_ND_CORE_AUTO_RST} is active in WebEM.  console=true

    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=192.168.255.119  timeout=${PING_TIMEOUT}  remote_host=${PC_IP2}
    IF  ${ping_loss_status}
      Log  Ping is lost.  console=true
    ELSE
      Set Test Restriction  Ping has not been lost within timeout.
    END
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=192.168.255.119  timeout=${PING_TIMEOUT}  remote_host=${PC_IP2}
    IF  ${ping_regain_status}
      Log  Target is reachable.  console=true
    ELSE
      Set Test Restriction  Ping has not been regained within timeout.
    END
    ${cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check All Cells
    IF  ${cells_status}
      Log  Cells reached on air state after recovery.  console=true
    ELSE
      Fail  Cells didn't reached on air state after recovery.  console=true
    END

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2080_2_ND_CORE_AUTO_RST}  time_from=${start_time}
    ...  additional_fault_id=${FAULT_2080_2_ND_CORE_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_2080_2_ND_CORE_AUTO_RST} reported and cleared in Netact.  console=true
    Log  Checking fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM
    ...  fault_id=${FAULT_2080_2_ND_CORE_AUTO_RST}[fault_id]
    ...  info=${INFO}
    ...  scope=${SCOPE_ESM}
    ...  minor=${MINOR}
    ...  category=${CATEGORY}
    ...  load_name=${SW_VERSION}
    ...  reset_counter=${COUNTER}
    ...  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact
    ...  fault_id=${FAULT_2080_2_ND_CORE_AUTO_RST}[fault_id]
    ...  time_from=${start_time}
    ...  info=INFO:${SPACE}${INFO}
    ...  scope=SCOPE:${SPACE}${SCOPE_ESM}
    ...  minor=MINOR:${SPACE}${MINOR}
    ...  category=CATEGORY:${SPACE}${CATEGORY}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...  reset_counter=RESET_COUNTER:${SPACE}${COUNTER}
    ...  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}


Step4: Send Third Fault On Secondary Core
    Log  Step4: Send third fault on secondary core.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Open Connection To Primary Core
    Open Connection To Secondary Core
    SSHLibrary.Write  rio hpdalm send hld
    SSHLibrary.Read Until Prompt
    ${fault_2080_params}  Get String With Alarm Parameters  ${FAULT_2080_SITE_AUTO_RST}
    ${assert_fault_2080_site}  Assert Alarm Active  parameters=${fault_2080_params}  timeout=200
    Log  Fault 2080 ${FAULT_2080_SITE_AUTO_RST} is visible in WebEM.  console=true
    ${fault_2080_site}  Save Alarm For Later Checks  ${assert_fault_2080_site}  ${FAULT_2080_SITE_AUTO_RST}

    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}  timeout=${PING_TIMEOUT}
    IF  ${ping_loss_status}
      Log  Ping is lost.  console=true
    ELSE
      Set Test Restriction  Ping has not been lost within timeout.
    END
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=${PING_TIMEOUT}
    IF  ${ping_regain_status}
      Log  Target is reachable.  console=true
    ELSE
      Set Test Restriction  Ping has not been regained within timeout.
    END
    ${cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check All Cells
    IF  ${cells_status}
      Log  Cells reached on air state after recovery.  console=true
    ELSE
      Fail  Cells didn't reached on air state after recovery.  console=true
    END

    Log  Alarm presence will be verified in Netact.  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}s  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2080_SITE_AUTO_RST}  time_from=${start_time}
    ...  additional_fault_id=${FAULT_2080_SITE_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_2080_SITE_AUTO_RST} reported and cleared in Netact.  console=true
    Log  Check fault signature.  console=true
    Check Fault Signature Of Saved Alarm WebEM
    ...  saved_alarm=${fault_2080_site}
    ...  info=${INFO}
    ...  scope=${SCOPE_SITE}
    ...  minor=${MINOR}
    ...  category=${CATEGORY}
    ...  load_name=${SW_VERSION}
    ...  reset_counter=${COUNTER}
    ...  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact
    ...  fault_id=${FAULT_2080_SITE_AUTO_RST}[fault_id]
    ...  time_from=${start_time}
    ...  info=INFO:${SPACE}${INFO}
    ...  scope=SCOPE:${SPACE}${SCOPE_SITE}
    ...  minor=MINOR:${SPACE}${MINOR}
    ...  category=CATEGORY:${SPACE}${CATEGORY}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...  reset_counter=RESET_COUNTER:${SPACE}${COUNTER}
    ...  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}


Step5: Check Alarm History
    Log  Step5: Check alarm history.  console=true
    ${faults_list}  Create List
    ${historical_alarms}  coam.Get Historic Alarms
    FOR  ${alarm}  IN  @{historical_alarms}
        ${status_system_time}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[systemTime]  Default System Time
        ${status_severity}  Run Keyword And Return Status  Should Not Be Equal As Strings  ${alarm}[severity]  Warning
        IF  ${status_system_time} and ${status_severity}
          Append To List  ${faults_list}  ${alarm}[faultId]
          Log  Alarm with Default System Time tag found in alarm history.  console=true
        END
    END
    ${active_alarms}  Assert Alarm Active
    ${matched_alarms}  Create List
    FOR  ${alarm}  IN  @{active_alarms}
        ${status}  Run Keyword And Return Status  List Should Contain Value  ${faults_list}  ${alarm}[faultId]
        IF  ${status}  Append To List  ${matched_alarms}  ${alarm}
    END
    ${length_matched_faults}  Get Length  ${faults_list}
    ${length_matched_alarms}  Get Length  ${matched_alarms}
    Should Be Equal  ${length_matched_faults}  ${length_matched_alarms}
    FOR  ${alarm}  IN  @{matched_alarms}
        ${status_system_time}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[systemTime]  Default System Time
        IF  ${status_system_time}
          Set Test Restriction  Alarm was raised again with Default System Time tag.
        ELSE
          Log  Alarm was raised again without Default System Time tag.  console=true
        END
    END


Set Variables For Fault Signature Check
    ${smods_list}  coam.Get Fsm Info
    FOR  ${smod}  IN  @{smods_list}
      IF  '${smod}[activeRole]' == 'Secondary'  BREAK
      IF  '${smod}[activeRole]' == 'Primary'  CONTINUE
    END
    Set Test Variable  ${PRODUCT_CODE}  ${smod}[productCode]
    Set Test Variable  ${PRODUCT_NAME}  ${smod}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${smod}[serialNumber]
    Set Test Variable  ${INFO}  .*RapidIO host link down.*
    Set Test Variable  ${MINOR}  FCT SRIO
    Set Test Variable  ${SCOPE_ESM}  ESM
    Set Test Variable  ${SCOPE_SITE}  Site
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${COUNTER}  [0-9]+
    Set Test Variable  ${EXTRA_INFO}  .*gracefully_shutdown_cells=.*NR:[0-9]+.*
    Set Unit Position For Fault Signature  ${smod}[id][internal]


TC Setup
    Common Test Setup  tc_name=FM__5G_cell_graceful_shutdown_SC_escalates_to_site_reset
    Setup NetAct


TC Teardown
    Teardown NetAct
    Common Test Teardown
