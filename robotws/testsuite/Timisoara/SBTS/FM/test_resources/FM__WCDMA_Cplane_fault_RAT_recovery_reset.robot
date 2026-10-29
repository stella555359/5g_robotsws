*** Settings ***
Documentation
    ...  This test case was created to imitate WCDMA Cplane fault RAT recovery reset scenario. Fault generator will be used to inject
    ...  appropriate fault using OAM_SEND_FAULT_IND_MSG. Before fault is triggered it's being randomly choose from list [139,149,158].
    ...  Fault 139/149/158 appearance and WCDMA cells reset are being checked in two seperate threads.
    ...  In meantime also Recovery Reset Indication appearance
    ...  is checked under FRI. At the end the correctness of recovery action is being check (fault presence, fault history and cells status).

Library  ute_async
Resource  ../../common_resources/ca_FM_general.robot


*** Keywords ***
TC__FM__WCDMA_Cplane_fault_RAT_recovery_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10144
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 14.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-10144 - Initial TAT creation
    ...  - 12.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14205 - Alarm's field which was checked has changed
    ...  - 07.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15102 - Support for 4+3 platform added
    ...  - 11.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15037 - Replacement of depracated KW "check_if_target_is_available"
    ...  - 14.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15267 - Removed additional space
    ...  - 18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  - 21.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15380 - Check primary core prefix KW changed
    ...  - 05.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15296 - Reset counter clearance moved at the TC beginning
    ...  - 28.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16740 - Change the way of historical alarms verification
    ...  - 13.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19471 - Aligment with taf.rnc.oms.nwi3 library for FM test cases that use nwi3
    ...  - 19.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19746 - Move keywords to resource file
    ...  - 17.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21635 - Implement new method for choosing DSP for crash based on DSPs
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 13.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23682 - Change keyword to work for new python version
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  - 29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-rafal.ozga@nokia.com  MAINTAINER-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534

    Step1: Check All Required States
    Step2: Trigged WCDMA Cplane Fault
    Step3: Verify Success Of Recovery Action


Step1: Check All Required States
    [Documentation]  In this step user input and specific states of links will be checked.

    Log  \nStep1: Check All Required States.  console=true

    Check Commissioned Technologies  WCDMA

    Log  Site reset will be performed to clear recovery reset counter.  console=true
    Perform Site Reset

    ${all_rmods_power_before_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    ${all_rmods_power_after_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_AFTER_RECO_RESET}

    ${act_force_auto_reset_ini}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    Set Test Variable  ${ACT_FORCE_AUTO_RESET_INI}
    Log  Value of actForceAutoReset is ${ACT_FORCE_AUTO_RESET_INI}  console=true
    ${status_act}  Run Keyword And Return Status
    ...  Should Contain  ${ACT_FORCE_AUTO_RESET_INI}  true
    Run Keyword If  ${status_act} == ${FALSE}
    ...  Change Parameter ActForce(Unit)AutoReset  true  actForceAutoReset
    ${act_force_auto_reset_changed}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    Run Keyword If  ${status_act} == ${FALSE}
    ...  Log  Value of actForceAutoReset after change is ${act_force_auto_reset_changed}  console=true
    Set Test Variable  ${STATUS_ACT}

    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}

    Check Links Status  Available

    Checking RNCid And WBTSid From IM

    ${wcdma_cells_state}  Check If WCDMA Cells Are In Working State From RNC PoV  ${RNC_ID}  ${WBTS_ID}  ${RNC["OMS_IP"]}
    ${wcdma_cells_status}  Run Keyword And Return Status
    ...  List Should Not Contain Value  ${wcdma_cells_state}  ${False}
    Run Keyword If  ${wcdma_cells_status}
    ...  Log  All of WCells are in WORKING state om RNC, test will continue [OK]  console=true
    ...  ELSE
    ...  Fail  msg=Some of WCells are not in WORKING state on RNC, test will be set to failed

    Check Which Core Is Primary

    Run Keyword If  '${PRIMARY_CORE_PREFIX}'=='BTS_L-1'
    ...  Set Test Variable  ${PRIMARY_PREFIX}  0x1011
    ...  ELSE
    ...  Set Test Variable  ${PRIMARY_PREFIX}  0x2011

    Choose DSP

    Collect Payload For SEND_OAM_FAULT_IND_MSG


Choose DSP
    [Documentation]  This KW is created to draw a desired DSP which will be used during TC

    ${dsps_dist_names}  Create DSP List  WNBTS
    Log  LTE DSPs list: ${dsps_dist_names}  console=true
    Set Test Variable  ${DSPS_DIST_NAMES}  ${dsps_dist_names}
    ${list_length}  Get Length  ${DSPS_DIST_NAMES}
    ${crashed_dsp}  Evaluate  random.randint(0, ${list_length}-1)  modules=random
    ${dist_name}  Get From List  ${DSPS_DIST_NAMES}  ${crashed_dsp}
    ${dsp_object}  Query Infomodel  get object ${dist_name}
    ${node_id}  Convert To Hex  ${dsp_object.nodeId}
    ${selected_dsp}  Create Dictionary  ${dist_name}  ${node_id}
    Set Test Variable  ${SELECTED_DSP}


Collect Payload For SEND_OAM_FAULT_IND_MSG
    [Documentation]  This KW is created to collect needed payload data and triggerd random fault from list [139,149,158]

    Log  Querring InfoModel to find WTS taskId  console=true
    ${processes}  Query Infomodel  get list //PROCESS-*
    FOR  ${element}  IN  @{processes}
        ${item}  Get From List  ${element.servicesMap}  0
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${item["name"]}  Wts
        Run Keyword If  ${status}
        ...  Set Test Variable  ${WT_STASK_ID}  ${item}
    END

    Log  WTS has been found under this taskId:  console=true
    Log  ${WT_STASK_ID}  console=true

    Log  Fields to be filled in generate fault requests are:  console=true
    ${key}  Get Dictionary Keys  ${SELECTED_DSP}
    ${specific_fault_info}  Catenate  SEPARATOR=  0x  ${SELECTED_DSP["${key[0]}"]}  0222
    Set Test Variable  ${SPECIFIC_FAULT_INFO}
    Log  Parameter Specific fault info is: ${SPECIFIC_FAULT_INFO}  console=true

    ${sender}  Catenate  SEPARATOR=  ${PRIMARY_PREFIX}  0009
    Set Test Variable  ${SENDER}
    Log  Parameter Sender is: ${SENDER}  console=true

    ${key}  Get Dictionary Keys  ${WT_STASK_ID}
    ${wt_snode_id}  Convert To Hex  ${WT_STASK_ID["${key[1]}"]}
    ${receiver}  Catenate  SEPARATOR=  ${PRIMARY_PREFIX}  ${wt_snode_id}
    Set Test Variable  ${RECEIVER}
    Log  Parameter Receiver is: ${RECEIVER}  console=true
    Log  Supported fault list is: fault_139, fault_149, fault_158  console=true
    ${fault_names}  Create List  fault_139_EFaultId_DspModeChangeFailAl  fault_149_EFaultId_DspNacksReceivedAl
    ...  fault_158_EFaultId_HangingHspaResourcesAl
    ${supported_fault_list}  Create List  139  149  158
    ${list_length}  Get Length  ${supported_fault_list}
    ${list_length}  Evaluate  ${list_length}-1
    ${id}  Evaluate  random.randint(0,${list_length})  random
    ${tested_fault}  Evaluate  ${supported_fault_list[${id}]}
    Log  Fault which will be tested is: ${fault_names[${id}]}  console=true
    Set Test Variable  ${TESTED_FAULT}

    Log  Fault's required info is being parsed to decimal format which is needed for ADMIN API  console=true
    Log  Parsed required fields are:  console=true
    ${sender_dec}  Convert To Integer  ${SENDER}
    Log  Parameter Sender in HEX:${SENDER} and in DEC: ${sender_dec}  console=true
    Set Test Variable  ${SENDER_DEC}
    ${receiver_dec}  Convert To Integer  ${RECEIVER}
    Log  Parameter Receiver in HEX:${RECEIVER} and in DEC: ${receiver_dec}  console=true
    Set Test Variable  ${RECEIVER_DEC}
    ${specific_fault_info_dec}  Convert To Integer  ${SPECIFIC_FAULT_INFO}
    Log  Parameter Specific fault info in HEX:${SPECIFIC_FAULT_INFO} and in DEC: ${specific_fault_info_dec}  console=true
    Set Test Variable  ${SPECIFIC_FAULT_INFO_DEC}


Step2: Trigged WCDMA Cplane Fault
    [Documentation]  In this step WCDMA Cplane fault will be triggered.

    Log  \nStep2: Trigger WCDMA Cplane fault.  console=true

    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=cellsCheck

    ${fault_rat_auto_reset}  Set Variable  ${FAULT_139}
    Set To Dictionary  ${fault_rat_auto_reset}  fault_id=${TESTED_FAULT}
    ${fault_rat_auto_reset_params}  Get String With Alarm Parameters  ${fault_rat_auto_reset}
    ${fault_status}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_rat_auto_reset_params}  timeout=660

    ${cells_status}  Run Keyword In Background  Assert Every  class_name=WNCEL  parameters=operationalState=${DISABLED}  timeout=660
    ...  alias=cellsCheck

    Log  Request SEND_OAM_FAULT_IND_MSG is being sent via ADMIN API  console=true
    Run Keyword And Ignore Error
    ...  Send Oam Fault Ind Msg  ${SENDER_DEC}  ${RECEIVER_DEC}  ${TESTED_FAULT}  1  1  0  ${SPECIFIC_FAULT_INFO_DEC}  timeout=30

    ${recovery_reset}  Run Keyword And Return Status
    ...  Query Infomodel  get list //RECOVERY_RESET_IND-*  timeout=120

    ${status_fault}  Run Keyword And Return Status
    ...  Collect Keyword Result  ${fault_status}  timeout=660

    ${status_cells}  Run Keyword And Return Status
    ...  Collect Keyword Result  ${cells_status}  timeout=660

    Run Keyword And Continue On Failure
    ...  Teardown Admin  alias=cellsCheck

    Run Keyword If  ${status_fault}
    ...  Log  Fault ${TESTED_FAULT} "${FAULT_139}[fault_name]" occured [OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Fault ${TESTED_FAULT} "${FAULT_139}[fault_name]" didn't occurr [NOK]

    Run Keyword If  ${status_cells}
    ...  Log  WCDMA cells were failed while fault ${TESTED_FAULT} occured [OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  WCDMA cells were not failed while fault ${TESTED_FAULT} occured [NOK]

    Run Keyword If  ${recovery_reset}
    ...  Log  Recovery Reset Indication was visible under FRI [OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Recovery Reset Indication was not visible under FRI [NOK]


Step3: Verify Success Of Recovery Action
    [Documentation]  In this step verification of recovery action will be checked.

    Log  \nStep3: Verify success of recovery action after WCDMA Cplane fault was triggered.  console=true

    ${fault_rat_auto_reset}  Set Variable  ${FAULT_139}
    Set To Dictionary  ${fault_rat_auto_reset}  fault_id=${TESTED_FAULT}
    ${fault_rat_auto_reset_params}  Get String With Alarm Parameters  ${fault_rat_auto_reset}
    Assert Alarm Inactive  parameters=${fault_rat_auto_reset_params}
    Log  Fault ${TESTED_FAULT} "${fault_rat_auto_reset}[fault_name]" is not visible after recovery action.  console=TRUE

    Log  Checking Historical Alarms for presence of 7101 Autonomous Rat Reset notification  console=true
    ${historical_alarms}  Get_historic_alarms  severity=warning
    FOR  ${element}  IN  @{historical_alarms}
        ${status7101}  Run Keyword And Return Status
        ...  Should Be Equal As Integers  ${element}[alarmId]  7101
        Exit For Loop If  ${status7101}
    END
    Should Be True  ${status7101}  Alarm 7101 "${fault_rat_auto_reset}[fault_name]" is not visible in historical alarms.
    Log  Alarm 7101 "${fault_rat_auto_reset}[fault_name]" is visible in historical alarms.  console=true

    Log  TC will now sleep for 6 minutes to check if WCDMA cells are recovered  console=true

    Sleep  360s

    Log  DSPs stateInfo will be checked under specified pattern:  console=true
    ${dsp}  Query Infomodel  get list //DSP_L-1
    Verify Parameters  ${dsp}  .stateInfo  operationalState=Enabled  availabilityStatus=Online  proceduralState=RoutingLoaded

    ${wcdma_cells_state}  Check If WCDMA Cells Are In Working State From RNC PoV  ${RNC_ID}  ${WBTS_ID}  ${RNC["OMS_IP"]}
    ${wcdma_cells_status}  Run Keyword And Return Status
    ...  List Should Not Contain Value  ${wcdma_cells_state}  ${False}
    Run Keyword If  ${wcdma_cells_status}
    ...  Log  All of WCells are in WORKING state om RNC, test will continue [OK]  console=true
    ...  ELSE
    ...  Fail  msg=Some of WCells are not in WORKING state on RNC, test will be set to failed

    Check All Cells

    Check Links Status  Available

    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}

    Compare TXs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}

    Run Keyword If  ${STATUS_ACT} == ${FALSE}
    ...  Change Parameter ActForce(Unit)AutoReset  ${ACT_FORCE_AUTO_RESET_INI}  actForceAutoReset

    Admin Check Active Alarms TAF


TC Setup
    Common Test Setup  tc_name=FM__WCDMA_Cplane_fault_RAT_recovery_reset


TC Teardown
    Common Test Teardown
