*** Settings ***
Documentation
    ...  This test case is created to trigger site reset as recovery action when actForceAutoReset is set on true and cells are enabled.
    ...  It will be done by escalation from secondary core reset to site reset. faultId 2080 will be send using Fault Generator method.
    ...  Recovery action will be tested by checking faultID 2080 with
    ...  alarmId=7101 BTS site autonomous reset as recovery action and the occurance of BTS site reset.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${PING_TIMEOUT}   180  # [in seconds] Timeout for ping loss during reset.
${ALARM_TIMEOUT}  400  # [in seconds] Timeout for alarm to appear in WebEM.
${NETACT_TIMEOUT}  120  # [in seconds] Timeout for alarm to appear in Netact.


*** Keywords ***
TC__FM__Site_reset_actForceAutoReset_true_enabled_cell
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-9201
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  20.02.2018 - https://jira3.int.net.nokia.com/browse/TAT-9201 - Initial TAT creation
    ...  13.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15238 - Added data_length parameter to 'Send Hwapi Api2 Alarm msg'
    ...  18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  05.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15296 - Reset counter clearance moved at the TC beginning
    ...  04.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-15675 - Separate admin session for fault detection
    ...  24.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-17000 - Minor code fix
    ...  28.08.2020 - https://jira3.int.net.nokia.com/browse/TAT-19950 - Update FM Site reset actForceAutoReset true enabled cell
    ...  24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  26.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29236 - Add support for SBTS25R3 and higher - verify fault 4670
    ...  01.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  05.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  05.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29097 - Enhancement replace the FaultGenerator for FID 2080 by cmd line command
    ...  20.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30657 - Changed the parameter value to lowercase
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-iwona.andrejewicz@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534

    Step0: Verify All Required States Of SBTS
    Step1: Perform Site Reset
    FOR  ${loop}  IN RANGE  0  2
        Step2: Trigger Fault 2080 And Verify Recovery
    END
    Step4: Trigger Escalation To Site Reset And Verify Resources


Step0: Verify All Required States Of SBTS
    Log  \nStep0: Check actForceAutoReset and change for TRUE if needed.  console=true
    Change FMCADM Parameter  actForceAutoReset  true
    Set Variables For Fault Signature Check
    ${rnc_infomodel}  Query Infomodel  get object //RAT-*/WTS-*/RNC-*
    ${wbts_infomodel}  Query Infomodel  get object //RAT-*/WTS-*/RNC-*/WBTS-*
    ${rnc_id}  Fetch From Right  ${rnc_infomodel}[dist_name]  RNC-
    ${wbts_id}  Fetch From Right  ${wbts_infomodel}[dist_name]  WBTS-
    Set Test Variable  ${RNC_ID}
    Set Test Variable  ${WBTS_ID}


Step1: Perform Site Reset
    Log  \nStep1: Site reset will be performed to clear all counters.  console=true
    Perform Site Reset


Step2: Trigger Fault 2080 And Verify Recovery
    Log  \nStep2: Trigger fault 2080 and verify recovery.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Open Connection To Primary Core
    Open Connection To Secondary Core
    SSHLibrary.Write  rio hpdalm send hld
    SSHLibrary.Read Until Prompt
    ${fault_2080_params}  Get String With Alarm Parameters  ${FAULT_2080_2_ND_CORE_AUTO_RST}
    Assert Alarm Active  parameters=${fault_2080_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_2080_2_ND_CORE_AUTO_RST} is active in WebEM.  console=true

    ${secondary_dn}  Query Infomodel  get object /MRBTS-1/RAT-1/BTS_L-* is [storedRole=Idle]
    ${cells_on_secondary}  Infomodel Get Cells Deployed On Module  ${secondary_dn}
    FOR  ${im_cell}  IN  @{cells_on_secondary}
        Infomodel Cell Should Be Failed  ${im_cell}
    END

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2080_2_ND_CORE_AUTO_RST}  time_from=${start_time}
    ...  additional_fault_id=${FAULT_2080_2_ND_CORE_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_2080_2_ND_CORE_AUTO_RST} reported and cleared in Netact.  console=true

    IF  ${SCF_COUNT_WCDMA} and '${ENB_BRANCH}' >= 'SBTS25R3'
        ${fid_4670_params}  Get String With Alarm Parameters  ${FAULT_4670}
        Assert Alarm Active  parameters=${fid_4670_params}  timeout=300s
        Log  Fault ${FAULT_4670} is visible in WebEM.  console=true
    END

    Log  Verify SBTS after recovery.  console=true
    Wait Until Keyword Succeeds  600s  10s  Check All Cells
    Check Links Status  Available
    Admin Check Active Alarms Taf
    Wait Until Keyword Succeeds  300s  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2080_2_ND_CORE_AUTO_RST}  time_from=${start_time}
    Log    Fault ${FAULT_2080_2_ND_CORE_AUTO_RST} reported and cleared from WebEM and Netact.  console=true
    IF  ${SCF_COUNT_WCDMA} and '${ENB_BRANCH}' >= 'SBTS25R3'
        Wait Until Keyword Succeeds  300s  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4670}
        ...                                                                               time_from=${start_time}
        ...                                                                               dist_name=PLMN-PLMN/RNC-${RNC_ID}/WBTS-${WBTS_ID}
        Log  Fault ${FAULT_4670} reported and cleared from WebEM and Netact.  console=true
    END

    Log  Checking fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM
    ...  fault_id=${FAULT_2080_2_ND_CORE_AUTO_RST}[fault_id]
    ...  info=${INFO}
    ...  scope=${SCOPE}
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
    ...  scope=SCOPE:${SPACE}${SCOPE}
    ...  minor=MINOR:${SPACE}${MINOR}
    ...  category=CATEGORY:${SPACE}${CATEGORY}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...  reset_counter=RESET_COUNTER:${SPACE}${COUNTER}
    ...  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}


Step4: Trigger Escalation To Site Reset And Verify Resources
    Log  \nStep4: Trigger escalation to site reset and verify resources.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Open Connection To Primary Core
    Open Connection To Secondary Core
    SSHLibrary.Write  rio hpdalm send hld
    SSHLibrary.Read Until Prompt

    ${states}  Catenate  SEPARATOR=  stateInfo.availabilityStatus=Failed, stateInfo.operationalState=Disabled,
    ...  stateInfo.reasoningStatus[0]=SrioHostLinkDown
    ${status_ccu_l}  ${im_ccu_l_object}  Run Keyword And Ignore Error  Query Infomodel  get object //CCU_L-1 is [${states}]  timeout=45
    IF  '${status_ccu_l}' == 'FAIL'
        Set Test Restriction  message=StateInfo of CCU_L is different than expected [NOK]
    ELSE
        Log  StateInfo: availabilityStatus, operationalState, reasoningStatus for CCU_L is as expected [OK]  console=true
    END
    ${fault_2080_params}  Get String With Alarm Parameters  ${FAULT_2080_SITE_AUTO_RST}
    ${assert_fault_2080_site}  Assert Alarm Active  parameters=${fault_2080_params}  timeout=200
    Log  Fault 2080 ${FAULT_2080_SITE_AUTO_RST} is visible in WebEM.  console=true
    ${fault_2080_site}  Save Alarm For Later Checks  ${assert_fault_2080_site}  ${FAULT_2080_SITE_AUTO_RST}

    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['IP']}  timeout=${PING_TIMEOUT}  remote_host=${PC_IP1}
    IF  ${ping_loss_status} == ${False}
        Set Test Restriction  Ping has not been lost within timeout=${PING_TIMEOUT}.
    ELSE
        Log  Ping is lost.  console=true
    END
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['IP']}  timeout=${PING_TIMEOUT}  remote_host=${PC_IP1}
    IF  ${ping_regain_status} == ${False}
        Set Test Restriction  Ping has not been regained within timeout=${PING_TIMEOUT}..
    ELSE
        Log  Target is reachable.  console=true
    END

    Wait Until Keyword Succeeds  600s  10s  Check All Cells
    Check Links Status  Available
    Admin Check Active Alarms Taf
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}s  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2080_SITE_AUTO_RST}  time_from=${start_time}
    ...  additional_fault_id=${FAULT_2080_SITE_AUTO_RST}[fault_id]
    Log  Fault 2080 ${FAULT_2080_SITE_AUTO_RST} is visible in Netact.  console=true

    Check Fault Signature Of Saved Alarm WebEM
    ...  ${fault_2080_site}
    ...  info=${INFO}
    ...  scope=Site
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
    ...  scope=SCOPE:${SPACE}Site
    ...  minor=MINOR:${SPACE}${MINOR}
    ...  category=CATEGORY:${SPACE}${CATEGORY}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...  reset_counter=RESET_COUNTER:${SPACE}${COUNTER}
    ...  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}


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
    Set Test Variable  ${SCOPE}  ESM
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${COUNTER}  [0-9]+
    ${extra_info}  Catenate  SEPARATOR=${SPACE}
    ...  faulty_cells=(.*GSM:[0-9]+.*,)?(.*WCDMA:[0-9]+.*,)?(.*LTE:[0-9]+.*,)?(.*NR:[0-9]+.*,)?[0-9]+;
    ...  gracefully_shutdown_cells=(.*GSM:[0-9]+.*,)?(.*WCDMA:[0-9]+.*,)?(.*LTE:[0-9]+.*,)?(.*NR:[0-9]+.*,)?[0-9]+
    Set Test Variable  ${EXTRA_INFO}  ${extra_info}
    Set Unit Position For Fault Signature  ${smod}[id][internal]


TC Setup
    Common Test Setup  tc_name=FM__Site_reset_actForceAutoReset_true_enabled_cell
    Setup Netact

TC Teardown
    Teardown Netact
    Common Test Teardown
