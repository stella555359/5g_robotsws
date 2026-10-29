*** Settings ***
Documentation
    ...  This TC is created to trigger fault 242 on FSP with productName ABIA and which processes only LTE.
    ...  The parameter actForceUnitAutoReset is changed to FALSE.
    ...  The 1st FSP will be chosen and also cells deployed on him will be collected.
    ...  The fault 242 is sent on FSP and the alarm with alarm id 7101 should appear, those cells on FSP and BBMOD states are checked.
    ...  FSP recovery reset is performed, the state and the alarm should dissapear,
    ...  those cells on FSP, BBMOD and SMOD are checked and expected to be online.
    ...  The fault 242 is sent again on FSP and the alarm with alarm id 7101 should appear, those cells on FSP and BBMOD states are checked.
    ...  FSP recovery reset is performed, the state and the alarm should dissapear,
    ...  those cells on FSP, BBMOD and SMOD are checked and expected to be online.
    ...  The fault 242 is sent again on FSP and the alarm with alarm id 7100 should appear, those cells on FSP and BBMOD states are checked.
    ...  Check if alarm is active in Mantaray.
    ...  FSP recovery reset is not performed in this case.
    ...  Site Reset will be performed and the alarm must be cleared.
    ...  Check if alarm is inactive in Mantaray.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${CELLS_RECOVERY_TIMEOUT}  600  # [in seconds] Timeout for cells to recover after test scenario.
${MODULE_TIMEOUT}  300  # [in seconds] Timeout for SMOD/BBMOD to reach expected state.
${ALARM_TIMEOUT}  300  # [in seconds] Timeout for alarm to appear/disappear.


*** Keywords ***
TC__FM__FSP_recovery_fault_242
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22353
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  16.12.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22353 - Initial TAT creation
    ...  03.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22594 - Checking if alarms are inactive after SBTS is onAir
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  09.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27311 - Change alarm that is checked in Mantaray
    ...  29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in Mantaray
    ...  27.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28938 - Move keyword to resource
    ...  03.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29686 - Check fault 4309 and optimize TC
    ...  *******************

    Set Tags  CA-FM  OWNER-delia.nacov@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS22

    Step 1: TC Preconditions
    Step 2: Send Fault 242 And Verify Recovery
    Step 3: Send Fault 242 And Verify Recovery
    Step 4: Send Fault 242 And Verify Faulty State


Step 1: TC Preconditions
    Log  \nStep 1: TC Preconditions.  console=true

    Perform Site Reset
    Change Parameter ActForce(Unit)AutoReset  false  actForceUnitAutoReset
    ${bbmods_list}  Get Fbb Info
    ${lte_soc_list}  Create List
    FOR  ${bbmod}  IN  @{bbmods_list}
         IF  'ABIA' not in '${bbmod}[productName]'  CONTINUE
         ${bbmod_r_dn}  Set Variable  ${bbmod}[id][internal]
         ${bbmod_l}  Get Module L Dist Name  ${bbmod}[serialNumber]  BBMOD
         ${bbmod_soc_list}  Query Infomodel  get list ${bbmod_l}/BBU_L-1/POWER_GROUP_L-*/SOC_L-*
         ${lte_soc_list}  Get LTE SOC From BBMOD  ${bbmod_soc_list}
         BREAK
    END
    ${length}  Get Length  ${lte_soc_list}
    IF  ${length} == 0  Fail  msg=ABIA BBMOD with LTE cells mapped on SOC not found on SBTS.
    ${first_fsp_dn}  Set Variable  ${EMPTY}
    FOR  ${soc}  IN  @{lte_soc_list}
         ${status}  Run Keyword And Return Status  Should Contain  ${soc}[dist_name]  SOC_L-1
         IF  ${status}
             ${first_fsp_dn}  Set Variable  ${soc}[dist_name]
             BREAK
         END
    END
    Should Not Be Empty  ${first_fsp_dn}  msg=SOC_L-1 not found on chosen BBMOD: ${bbmod_l}.
    ${bbu_l}  Fetch From Left  ${first_fsp_dn}  /POWER_GROUP
    ${cells_on_fsp}  Get Cell Mapping By Module Id  ${bbu_l}
    Set Test Variable  ${CELLS_ON_FSP}
    ${core}  coam.Get Parameters  ${first_fsp_dn}/DSP_L-1/CORE_L-1
    ${bbmod_r_obj}  coam.Get Parameters  ${bbmod_r_dn}
    ${receiver}  Set Variable If  '${bbmod_r_obj}[horizontalPosition]'=='1'  0x10111202  0x20111202
    ${node_id_hex}  Convert To Hex  ${core}[nodeId]
    ${sender}  Set Variable  0x${node_id_hex}04b5
    Set Test Variable  ${NODE_VALUE}  ${core}[nodeId]
    Set Test Variable  ${SENDER}
    Set Test Variable  ${RECEIVER}

    Log  Chosen BBMOD: ${bbmod_r_dn}  console=true
    Log  First FSP on BBMOD: ${first_fsp_dn}  console=true
    Log  Cells mapped on FSP: ${cells_on_fsp}  console=true
    Log  Sender: ${sender}  console=true
    Log  Receiver: ${receiver}  console=true


Step ${index}: Send Fault 242 And Verify Recovery
    Log  \nStep ${index}: Send Fault 242 And Verify Recovery  console=true

    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Send Hwapi Api2 Alarm Msg  ${SENDER}  ${RECEIVER}  1  242  ${NODE_VALUE}  timeout=180
    Log  Fault 242 was sent! [OK]  console=true
    Assert Any  BBMOD  availabilityStatus=${OFFLINE}  timeout=${MODULE_TIMEOUT}

    Log  Check fault 242 presence in WebEM.  console=true
    ${fault_bb_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_242_BB_AUTO_RST}
    Assert Alarm Active  parameters=${fault_bb_auto_rst_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_242_BB_AUTO_RST} was active in WebEM.  console=true

    Log  Check modules and cells state...  console=true
    Assert Every  BBMOD  operationalState=${ENABLED}  timeout=${MODULE_TIMEOUT}
    Assert Every  SMOD  operationalState=${ENABLED}  timeout=${MODULE_TIMEOUT}
    Wait Until Keyword Succeeds  ${CELLS_RECOVERY_TIMEOUT}  10  Check All Cells
    Log  All modules and cells are back online after recovery.  console=true

    Assert Alarm Inactive  parameters=${fault_bb_auto_rst_params}  timeout=${ALARM_TIMEOUT}
    Log  Check fault 242 presence in Mantaray.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_242_BB_AUTO_RST}
    ...                                                                               time_from=${start_time}
    ...                                                                               additional_fault_id=${FAULT_242_BB_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_242_BB_AUTO_RST} was reported & cleared from Mantaray.  console=true


Step 4: Send Fault 242 And Verify Faulty State
    Log  \nStep 4: Send Fault 242 And Verify Faulty State.  console=true

    ${start_time_fault_critical}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME_FAULT_CRITICAL}
    Send Hwapi Api2 Alarm Msg  ${SENDER}  ${RECEIVER}  1  242  ${NODE_VALUE}  timeout=180
    Log  Fault 242 was sent! [OK]  console=true
    Assert Any  BBMOD  availabilityStatus=${FAILED}  timeout=${MODULE_TIMEOUT}

    Log  Check fault 242 presence in WebEM.  console=true
    ${fault_eth_links_fail_params}  Get String With Alarm Parameters  ${FAULT_242_ETH_LINKS_FAIL}
    Assert Alarm Active  parameters=${fault_eth_links_fail_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_242_ETH_LINKS_FAIL} is active in WebEM.  console=true

    Log  Check fault 242 presence in Mantaray.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_242_ETH_LINKS_FAIL}
    ...                                                          additional_fault_id=${FAULT_242_ETH_LINKS_FAIL}[fault_id]
    Log  Fault ${FAULT_242_ETH_LINKS_FAIL} is active in Mantaray.  console=true

    ${fault_4309_status}  Run Keyword And Return Status  Check Fault 4309 Presence In WebEM And Mantaray
    IF  ${fault_4309_status}  Log  Fault ${FAULT_4309} is active in WebEM and Mantaray.  console=true
    Check If Alarms From WebEM And NetAct Are The Same
    Wait Until Keyword Succeeds  120s  10s  Checking Cells On The Given FSP  ${CELLS_ON_FSP}  ${FAILED}  ${DISABLED}


Perform Recovery Action
    Perform Site Reset
    ${fault_eth_links_fail_params}  Get String With Alarm Parameters  ${FAULT_242_ETH_LINKS_FAIL}
    Assert Alarm Inactive  parameters=${fault_eth_links_fail_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_242_ETH_LINKS_FAIL} is inactive in WebEM.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_242_ETH_LINKS_FAIL}
    ...                                                                               time_from=${START_TIME_FAULT_CRITICAL}
    ...                                                                               additional_fault_id=${FAULT_242_ETH_LINKS_FAIL}[fault_id]
    Log  Fault ${FAULT_242_ETH_LINKS_FAIL} was reported & cleared from Mantaray.  console=true


Get LTE SOC From BBMOD
    [Arguments]  ${bbmod_soc_list}

    ${soc_temp_list}  Create List
    FOR  ${soc}  IN  @{bbmod_soc_list}
        ${lte_status}  Run Keyword And Return Status  List Should Contain Value  ${soc}[rat]  LTE
        IF  ${lte_status}  Append To List  ${soc_temp_list}  ${soc}
    END

    RETURN  ${soc_temp_list}


Check Fault 4309 Presence In WebEM And Mantaray
    Log  Check fault 4309 presence in WebEM.  console=true
    ${fault_4309_params}  Get String With Alarm Parameters  ${FAULT_4309}
    Assert Alarm Active  parameters=${fault_4309_params}  timeout=${ALARM_TIMEOUT}
    Log  Check fault 4309 presence in Mantaray.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10  Check Additional Information For Given Alarm And Fault  &{FAULT_4309}


TC Setup
    Common Test Setup  tc_name=FM__FSP_recovery_fault_242
    Setup NetAct


TC Teardown
    Perform Recovery Action
    Teardown NetAct
    Common Test Teardown