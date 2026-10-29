*** Settings ***
Documentation
    ...  This test case was created to imitate CCplane VN crash recovery reset scenario.
    ...  PID of CCplane process will be found from lxc-attach -n$(hex_node_id) and kill -9 20.
    ...  Steps will be intiatted 4 times till counter reaches limit.

Library  ute_async
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  300  # [in seconds] Timeout for SBTS to recover after crash scenario
${CELLS_TIMEOUT}  180  # [in seconds] Timeout for cells to reach expected stae
${NETACT_TIMEOUT}  180  # [in seconds] Timeout for alarm to be reported in Netact


*** Keywords ***
TC__FM_VN_CCplane_LTE_reset_counter_exceeded
    [Documentation]
     ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10463
     ...
     ...  ******************
     ...  History of changes
     ...  ******************
     ...  09.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-19328 - Remove VNU_L and replace it with SW_NODE_L
     ...  19.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19746 - Move keywords to resource file
     ...  10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
     ...  14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
     ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
     ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
     ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
     ...  20.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26956 - Enhancement for CB008880
     ...  05.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27300 - Skip parameter change for older sw releases
     ...  26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
     ...  10.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27767 - Raise FID 4753 and check it's appearance.
     ...  13.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27947 - Check FID 4753 only for newer releases.
     ...  21.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27965 - Block cells that are on air.
     ...  29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
     ...  15.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27608 - Add check for fault signature
     ...  10.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29199 - Test fails due to expected FID 7107 and NR cell disabled
     ...  10.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29065 - Extra info field did not matched
     ...  27.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29370 - Enhancement for CB008708
     ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
     ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
     ...  30.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29599 - Change verification for NSA cells.
     ...  22.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29757 - Filter by software version for maintenance window
     ...  07.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29817 - Test fails at SA+NSA cell status check
     ...  03.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30269 - FMCADM_R-1 in CM Editor immediate detection and recovery action optimized
     ...  16.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30319 - Added maintenance window cleanup in case the test failed
     ...  18.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30278 - Filtering alarms for different software versions
     ...  30.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30683 - Added check for FID 4383 and 4753 in Netact
     ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-piotr.szlegel@nokia.comm  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534  FEATURE-CB008880

    Step0: Check All Required States
    FOR  ${loop}  IN RANGE  0  3
        Step ${loop+1}: Triger Loop With CCplane Crash
    END
    Step4: Reset Counter Reaches Limit
    Step5: Activate Maintenance Window
    Step6: Deactivate Maintenance Window
    Step7: Check BTS After Test Steps


Step0: Check All Required States
    Log  \nStep0: Check all required states.  console=true
    Check Commissioned Technologies  LTE
    Perform Site Reset
    Check Which Core Is Primary
    ${all_rmods_power_before_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    ${all_rmods_power_after_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    Check Links Status  Available

    ${nsa_cells}  Create List
    ${sa_nsa_cells}  Create List
    ${sa_cells}  Create List
    ${all_cells}  Get Cells Info
    FOR  ${cell}  IN  @{all_cells}
         ${nsa_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${cell}[cellDepType]  NSA
         ${sa_nsa_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${cell}[cellDepType]  SA+NSA
         IF  ${nsa_status}
             Append To List  ${nsa_cells}  ${cell}[id][internal]
         ELSE IF  ${sa_nsa_status}
             Append To List  ${sa_nsa_cells}  ${cell}[id][internal]
         ELSE
             Append To List  ${sa_cells}  ${cell}[id][internal]
         END
    END
    Set Test Variable  ${SA_CELLS}
    Set Test Variable  ${NSA_CELLS}
    Set Test Variable  ${SA_NSA_CELLS}
    ${date}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${date}

    Log  Change actForceAutoReset value to FALSE if needed.  console=true
    ${list}  Create List  actForceAutoReset
    ${object}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1  ${list}
    ${initial_value}  Set Variable  ${object}[0][parameters][actForceAutoReset]
    Set Test Variable  ${INITIAL_VALUE}
    Change FMCADM Parameter  actForceAutoReset  false

    IF  '${ENB_BRANCH}' >= 'SBTS24R2' or '${ENB_BRANCH}' == 'SBTS00'  Change FEATCADM Parameter  actRatResetEnhancement  true
    IF  '${ENB_BRANCH}' < 'SBTS24R3'  RETURN
    Change FMCADM Parameter  actAlarmOfRatOutage  true
    ${fault_service_out}  Copy Dictionary  ${FAULT_4753}
    ${4753_parameters}  Get String With Alarm Parameters  ${fault_service_out}
    Set Test Variable  ${SUPPLEMENTARY_ALARM_INFO}  All Cells are disabled but not all Cells are failed
    ${alarm_4753_parameters_with_suppl_info}  Catenate  SEPARATOR=${SPACE}  ${4753_parameters},
    ...  supplAlarmInfo="${SUPPLEMENTARY_ALARM_INFO}"
    ${lnbts}  Admin Get LNBTS ID
    Set Test Variable  ${LNBTS}  ${lnbts}
    ${bts_name}  Get Bts Name
    ${alarm_4753_parameters_with_suppl_info_dn}  Catenate  SEPARATOR=${SPACE}  ${alarm_4753_parameters_with_suppl_info},
    ...  configObjectName="[${bts_name}] MRBTS-${BTS_ID}/LNBTS-${LNBTS}"
    Set Test Variable  ${4753_PARAMETERS}  ${alarm_4753_parameters_with_suppl_info_dn}
    IF  '${ENB_BRANCH}' <= 'SBTS26R1'
        ${alarm_4383_parameters}  Get String With Alarm Parameters  ${FAULT_4383_VNODE_NOT_RESP}
        Set Test Variable  ${ALARM_4383_DICT}  ${FAULT_4383_VNODE_NOT_RESP}
        Set Test Variable  ${ALARM_4383_CRITICAL_PARAMETERS}  ${alarm_4383_parameters}
    ELSE
        ${alarm_4383_parameters}  Get String With Alarm Parameters  ${FAULT_4383_INTERNAL_NOT_RESP}
        Set Test Variable  ${ALARM_4383_DICT}  ${FAULT_4383_INTERNAL_NOT_RESP}
        Set Test Variable  ${ALARM_4383_CRITICAL_PARAMETERS}  ${alarm_4383_parameters}
    END


Step${index}: Triger Loop With CCplane Crash
    [Documentation]  In this step LTE CCplane VN crash will be triggered.

    Log  \nStep${index}: Triger loop with CCplane crash.  console=true
    ${vnu_l}  Query Infomodel  get list /MRBTS-1/RAT-*//SOC_L-1/SW_NODE_L-* is [rat="LTE", applicationGroup="CentralCPlane"]  timeout=60
    ${element}  Get From List  ${vnu_l}  0
    IF  ${index} == 1
        Set Test Variable  ${ELEMENT}
        Set Test Variables For Fault Signature In LTE CCplane crashes
    END
    ${node_id}  Convert To Hex  ${element}[nodeId]  prefix=0x
    ${low_node_id}  Convert To Lowercase  ${node_id}
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=fault
    Crash VN  ${element}  ${low_node_id}
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4383_RAT_AUTO_RST}
    ${fault_status}  Run Keyword In Background  Assert Alarm Active  parameters=${alarm_parameters}  timeout=660  alias=fault
    ${reset_recovery}  Start Async  ute_admin_infomodel  Query Infomodel  get list //RECOVERY_RESET_IND-*  timeout=660  alias=recovery
    ${vnu_status}  Run Keyword And Return Status
    ...  Query Infomodel  get list ${element}[dist_name] is [stateInfo.reasoningStatus[0]="NodeStoppedUnexpectedly"]  timeout=300
    IF  ${vnu_status}
        Log  Reasoning status is NodeStoppedUnexpectedly. [OK]  console=true
    ELSE
        Set Test Restriction  Reasoning status is different than expected. [NOK]
    END

    ${state_lte_cells}  Catenate  operationalState=${DISABLED}  availabilityStatus=${FAILED}
    ${lte_cells_status}  Run Keyword And Return Status  Assert Every  LNCEL  ${state_lte_cells}  timeout=${CELLS_TIMEOUT}
    IF  ${lte_cells_status}
        Log  LTE cells were failed. [OK]  console=true
    ELSE
        Fail  LTE cells were not failed. [NOK]
    END
    IF  ${SCF_COUNT_NR}
        Assert Every  NRCEL  operationalState=${ENABLED}  timeout=${CELLS_TIMEOUT}
        Log  NR cells are enabled. [OK]  console=true
    ELSE
        Log  NR not comissioned, check will be skipped.  console=true
    END

    ${status_fault}  Run Keyword And Return Status  Collect Keyword Result  ${fault_status}  timeout=660
    IF  ${status_fault}
        Log  Fault ${FAULT_4383_RAT_AUTO_RST} was visible in WebEM. [OK]  console=true
    ELSE
        Set Test Restriction  Fault ${FAULT_4383_RAT_AUTO_RST} was not visible in WebEM. [NOK]
    END
    ${status_reset_recovery}  ${async_result}  Run Keyword And Ignore Error  Wait For Async Result  alias=recovery
    IF  '${status_reset_recovery}' == 'FAIL'
        Set Test Restriction  Recovery Reset Indication is not visible under FRI. [NOK]
    ELSE
        Log  RAT reset indication is visible uder FRI. [OK]  console=true
    END
    Stop Async  alias=recovery
    Run Keyword And Continue On Failure  Teardown Admin  alias=fault

    ${fault_status_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4383_RAT_AUTO_RST}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_4383_RAT_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_4383_RAT_AUTO_RST} reported and cleared in Netact.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT} sec  65 sec  Check All Cells
    ${alarm7101_recovery_status}  Run Keyword And Return Status  Assert Alarm Inactive  parameters=${alarm_parameters}
    IF  ${alarm7101_recovery_status}
        Log  Alarm ${FAULT_4383_RAT_AUTO_RST} is not visible after recovery action. [OK]  console=true
    ELSE
        Fail  Alarm ${FAULT_4383_RAT_AUTO_RST} is visible after recovery action. [NOK]
    END
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Compare TXs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    Admin Check Active Alarms TAF

    Log  Check fault signature in alarm.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${EXPECTED_FAULT_ID}  category=${CATEGORY}  extra_info=${EXTRA_INFO}  info=${INFO}
    ...  load_name=${SW_VERSION}  minor=${MINOR}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${EXPECTED_FAULT_ID}  time_from=${START_TIME}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...  minor=MINOR:${SPACE}${MINOR}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  scope=SCOPE:${SPACE}${SCOPE}
    ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}


Step4: Reset Counter Reaches Limit
    Log  \nStep4: Reset counter reaches limit.  console=true
    ${vnu_l}  Query Infomodel  get list /MRBTS-1/RAT-*//SOC_L-1/SW_NODE_L-* is [rat="LTE", applicationGroup="CentralCPlane"]  timeout=60
    ${element}  Get From List  ${vnu_l}  0
    ${node_id}  Convert To Hex  ${element}[nodeId]  prefix=0x
    ${low_node_id}  Convert To Lowercase  ${node_id}
    Crash VN  ${element}  ${low_node_id}
    Assert Alarm Active  parameters=${ALARM_4383_CRITICAL_PARAMETERS}  timeout=660
    Log  Alarm ${ALARM_4383_DICT} is visible. [OK]  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10
    ...  Check Additional Information For Given Alarm And Fault  &{ALARM_4383_DICT}  additional_fault_id=${ALARM_4383_DICT}[fault_id]
    Log  Fault ${ALARM_4383_DICT} is visible on NetAct.  console=true
    ${vnu_status}  Run Keyword And Return Status
    ...  Query Infomodel  get list ${element.dist_name} is [stateInfo.reasoningStatus[0]="NodeStoppedUnexpectedly"]  timeout=300
    IF  ${vnu_status}
        Log  Reasoning status is NodeStoppedUnexpectedly. [OK]  console=true
    ELSE
        Set Test Restriction  message=Reasoning Status is different than expected. [NOK]
    END

    ${state_lte_cells}  Catenate  operationalState=${DISABLED}  availabilityStatus=${FAILED}
    ${lte_cells_status}  Run Keyword And Return Status  Assert Every  LNCEL  ${state_lte_cells}  timeout=${CELLS_TIMEOUT}
    IF  ${lte_cells_status}
        Log  LTE cells were failed. [OK]  console=true
    ELSE
        Fail  LTE cells were not failed. [NOK]
    END
    Log  Verify LTEENB x2LinkStatus.  console=true
    ${x2_link_status}  Set Variable  ${FALSE}
    ${lteenb_objs}  Query Infomodel  get list //NRBTS_R-*/LTEENB_R-*
    FOR  ${item}  IN  @{lteenb_objs}
         IF  '${item}[x2LinkStatus]' == 'available'
             ${x2_link_status}  Set Variable  ${TRUE}
             Log  At least one LTEENB has x2LinkStatus available - NSA and SA+NSA cells will be online.  console=true
             BREAK
         END
    END
    IF  ${SCF_COUNT_NR}
        IF  ${x2_link_status}
            Check Parameters Status For Cells  ${NSA_CELLS}  operationalState=${ENABLED}
            Check Parameters Status For Cells  ${SA_NSA_CELLS}  operationalState=${ENABLED}
        ELSE
            Check Parameters Status For Cells  ${NSA_CELLS}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
            Check Parameters Status For Cells  ${SA_NSA_CELLS}  availabilityStatus=${DEGRADED}
        END
        Check Parameters Status For Cells  ${SA_CELLS}  operationalState=${ENABLED}
    ELSE
        Log  NR not comissioned, check will be skipped.  console=true
    END

    IF  '${ENB_BRANCH}' < 'SBTS24R3'  RETURN
    Block online cells for given RAT  lte
    Sleep  11 min  Wait for fault to appear.
    Assert Alarm Active  parameters=${4753_PARAMETERS}  timeout=120s
    Log  Fault ${FAULT_4753}[fault_id] with name ${FAULT_4753}[fault_name] - reported in WebEM. [OK]  console=true
    Change FMCADM Parameter  actAlarmOfRatOutage  false
    Assert Alarm Inactive  parameters=${4753_PARAMETERS}  timeout=180s
    Log  Fault ${FAULT_4753}[fault_id] with name ${FAULT_4753}[fault_name] - cleared from WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4753}
    ...  object_id=PLMN-PLMN/MRBTS-${BTS_ID}/LNBTS-${LNBTS}  time_from=${START_TIME}  suppl_info=${SUPPLEMENTARY_ALARM_INFO}
    ...  additional_fault_id=${FAULT_4753}[fault_id]
    Log  Fault ${FAULT_4753}[fault_id] with name ${FAULT_4753}[fault_name] reported and cleared in Netact.  console=true


Step5: Activate Maintenance Window
    IF  '${ENB_BRANCH}' < 'SBTS25R3'  RETURN
    Log  \nStep5: Activate maintenance window.  console=true
    Create Maintenance Window
    Wait Until Keyword Succeeds  900s  10s
    ...  Check All Cells
    ${parameter_object}  Wait Until Keyword Succeeds  300  10  Get Forced Recovery Parameter When Is Completed
    Verify Force Recovery Parameters  ${parameter_object}  ${ALARM_4383_DICT}


Step6: Deactivate Maintenance Window
    IF  '${ENB_BRANCH}' < 'SBTS25R3'  RETURN
    Log  \nStep6: Deactivate maintenance window.  console=true
    Delete Maintenance Window


Step7: Check BTS After Test Steps
    Log  \nStep7: Check BTS after test steps.  console=true
    Perform Site Reset
    Log  \nactForceAutoReset Initial state  console=true
    Change FMCADM Parameter  actForceAutoReset  ${INITIAL_VALUE}


Recovery Action
    Maintenance Window Cleanup
    Perform Site Reset


Crash VN
    [Documentation]  This KW is created to crash VN using kill-9 <PID> command.
    [Arguments]  ${vnu_dist_name}  ${low_node_id}

    Log  ${vnu_dist_name}[dist_name]  console=true
    ${status}  Run Keyword And Return Status  Should Not Contain  ${vnu_dist_name}[dist_name]  ${PRIMARY_CORE_BTS_L}
    ${smod_ip}  Set Variable If  ${status}  192.168.255.119  192.168.255.129
    Connect To SMOD  ${smod_ip}
    ${result}  ssh.Execute  lxc-attach -n ${low_node_id} ps aux | grep btssw
    ${regex}  Get Regexp Matches  ${result}  btssw\\s+\\d+
    ${length_list}  Get Length  ${regex}
    ${random_regex}  Evaluate  random.randint(0, ${length_list}-1)  modules=random
    ${from_list}  Get From List  ${regex}  ${random_regex}
    ${words}  Split String  ${from_list}
    ${process_id}  Get From List  ${words}  1
    ssh.Execute  lxc-attach -n ${low_node_id} -- bash -c '{ sleep 1; } | kill -9 ${process_id}'


TC Setup
    Common Test Setup  tc_name=FM__VN_CCplane_LTE_reset_counter_exceeded
    Setup NetAct


TC Teardown
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'  Run Keyword If Test Failed  Change FMCADM Parameter  actAlarmOfRatOutage  false
    Run Keyword If Test Failed  Recovery Action
    Teardown NetAct
    Common Test Teardown