*** Settings ***
Documentation
    ...  This test case was created to imitate whole link break scenario.
    ...  Test will be done by deleting VLANs via CLI on physical switch.
    ...  VLANs are being loaded from IM, there is no need to point them as parameter.
    ...  Switch IP and other parameters are being loaded from robot file.
    ...  Scenario is fitted to commissioned technologies (eg. GSM alarms won't be checked if configuration is LTE-WCDMA only).
    ...  In robot file variables should be added as global parameters (for example):
    ...  @{GSMVlan}            ${261}  ${262}
    ...  ${WCDMAVlan}          ${464}
    ...  ${LTEVlan}            ${461}
    ...  ${Switch_IP}          10.255.6.18
    ...  ${Switch_type}        Nokia_Nuage
    ...  ${INTERFACE_TYPE}     GigabitEthernet
    ...  ${INTERFACE_ID}       5
    ...  ${Switch_USER}        AutoUser
    ...  ${Switch_PASSWORD}    AutoPass123$

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${TIMER}  600  # Timer which is needed for configuraiton to reach OnAir status with active fault 17 after startup


*** Keywords ***
TC__FM__link_break_IuB_startup
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-8375
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 21.03.2018 - https://jira3.int.net.nokia.com/browse/TAT-9478 - Initial TAT creation
    ...  - 11.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15037 - Replacement of depracated KW "check_if_target_is_available"
    ...  - 14.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15267 - Removed additional space
    ...  - 18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  - 04.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17385  -  Nokia 7210 Switch commands syntax addition
    ...  - 13.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19471 - Aligment with taf.rnc.oms.nwi3 library for FM test cases that use nwi3
    ...  - 19.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19746 - Move keywords to resource file
    ...  - 14.09.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20163 - Include custom restore link connection as failling action in all checks
    ...  throughout the test based on switch type in cofiguration
    ...  - 20.01.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20724 - Change switch_type name in link breaks scenariors
    ...  - 12.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21215 - Update FM TCs accordingly with CNI-64164
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 11.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26019 - Testcase checks uncommissioned technologies
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 05.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26773 - Add new steps to FM__link_break_SBTS_long
    ...  - 26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  - 17.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29103 - Update testcases and resourses for CB011146
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-rafal.ozga@nokia.com  MAINTAINER-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534  FEATURE-RP001145_RP000920  FEATURE-RP001486_RP000920

    Step1: Check All Required States
    Step2: Perform Long IuB Link Break And Reset Site
    Step3: Wait For Ping To SBTS Is Back And Assert Active Alarm 7107 With Fault 17
    Step4: Restore IuB Link Connection
    Step5: Check Links State After Links Were Restored And All Cells State


Step1: Check All Required States
    [Documentation]  In this step user input and specific states of links will be checked.

    Log  \nStep1: Check All Required States.  console=true
    ${all_rmods_power_before_link_break}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}
    ${all_rmods_power_after_link_break}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}
    ${all_rmo_ds_wcdma_power_after_link_break}  Create List
    Set Test Variable  ${ALL_RMO_DS_WCDMA_POWER_AFTER_LINK_BREAK}
    ${top}  Check SyncInputType
    Set Test Variable  ${TOP}
    Log  TOP status before link break ${TOP}  console=true
    Check Commissioned Technologies  WCDMA
    Checking RNCid And WBTSid From IM
    ${wcdma_cells_state}  Create List
    ${wcdma_cells_state}  Check If WCDMA Cells Are In Working State From RNC PoV  ${RNC_ID}  ${WBTS_ID}  ${RNC["OMS_IP"]}
    ${wcdma_cells_status}  Run Keyword And Return Status  List Should Not Contain Value  ${wcdma_cells_state}  ${False}
    IF  ${wcdma_cells_status}
      Log  All of WCells are in WORKING state om RNC, test will continue. [OK]  console=true
    ELSE
      Fail  msg=Some of WCells are not in WORKING state on RNC, test will be set to failed.
    END
    Check Links Status  Available
    ${bts_name}  Infomodel Get Objects Parameter  //MRBTS_A-*  btsName
    ${mrbts}  Infomodel Get Objects Parameter  /MRBTS-1/RAT-1/BTS_L-1  btsId
    Set Test Variable  ${CONF_OBJ}  [${bts_name[0]}] MRBTS-${mrbts[0]}


Check SyncInputType
    [Documentation]  Checking if TOP status is Available and returing bool value true or false. If it's false other syncInputType is used.

    ${top}  Query Infomodel  get list //CLOCK-*
    ${top_reference_list}  Create List
    ${top_state_dict}  Create Dictionary
    FOR  ${item}  IN  @{top}
        Append To List  ${top_reference_list}  ${item.referenceSourceList}
    END
    ${getfromlist}  Get From List  ${top_reference_list}  0
    ${status}  Run Keyword And Return Status  Get From List  ${top_reference_list}  1
    FOR  ${item}  IN  @{getfromlist}
        IF  '${item["source"]}' == 'TOP'  Set To Dictionary  ${top_state_dict}  ${item["source"]}  ${item["availabilityStatus"]}
    END
    IF  '${top_state_dict["TOP"]}' == 'Unavailable' and ${status}  Second Clock Check  ${top_reference_list}  ${top_state_dict}

    [Return]  ${top_state_dict["TOP"]}


Second Clock Check
    [Arguments]  ${top_reference_list}  ${top_state_dict}

    ${getfromlist}  Get From List  ${top_reference_list}  1
    FOR  ${item}  IN  @{getfromlist}
        IF  '${item["source"]}' == 'TOP'  Set To Dictionary  ${top_state_dict}  ${item["source"]}  ${item["availabilityStatus"]}
    END


Step2: Perform Long IuB Link Break And Reset Site
    [Documentation]  In this step IuB Link Break and site reset will be performed.

    Log  \nStep2: Perform Long IuB Link Break and site reset.  console=true
    Get Used VLANs
    ${status}  Run Keyword And Return Status  List Should Contain Value  ${VLA_NIDS}  ${WCDMA_VLAN}
    IF  ${status}
      Log  WCDMA VLAN which is set in configuration file has been also found in IM, test will continue. [OK]  console=true
    ELSE
      Fail  msg=WCDMA VLAN which is set in configuration file has not been found in IM, test will be set to failed.
    END
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}
    IF  '${SWITCH_TYPE}'=='Nokia_7210' or '${SWITCH_TYPE}'=='Nokia_Nuage'
      Wait Until Keyword Succeeds  5min  1min  Connect To Nokia Serving Switch And Perform Action  ${SWITCH_IP}  ${SWITCH_USER}  ${SWITCH_PASSWORD}
      ...  ${WCDMA_VLAN}  ${INTERFACE_ID}  shutdown
    ELSE
      Fail  msg=Serving switch is not supported, test will be set as failed.
    END
    Log  Site reset will be performed.  console=true
    coam.Reset Site
    Log  Site reset has been performed. [OK]  console=true


Step3: Wait For Ping To SBTS Is Back And Assert Active Alarm 7107 With Fault 17
    [Documentation]  In this step alarms and link state related to WCDMA after IuB link break will be checked.

    Log  \nStep3: Wait for ping to SBTS is back, check alarms presence and WCDMA related states after IuB Link Break.  console=true
    Sleep  600s
    Log  Wait until ping to SBTS is back.  console=true
    Wait Until Keyword Succeeds  2 min  0 sec  Check if target is stable  ${OAM_BTS_IP}  30  30  120
    Log  Ping to SBTS is back, test will be continued. [OK]  console=true
    ${mrbts_dn}  Set Variable  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_17}
    ${alarm_parameters}  Catenate  ${alarm_parameters},  alarmingResource=${mrbts_dn},  'impactedCells'=""WCDMA:\n\tFaulty: All""
    Assert Alarm Active  parameters=${alarm_parameters}  timeout=${TIMER}
    Log  Fault ${FAULT_17}[fault_id] has been triggered on ${mrbts_dn}.
    Assert Alarm Active  parameters=faultId=${FAULT_17}[fault_id], configObjectName="${CONF_OBJ}"  timeout=60
    Log  Configuration alarming object is filled correctly : configObjectName="${CONF_OBJ}".  console=true
    ${fault18_suppresion}  Run Keyword And Return Status  Assert Alarm Inactive  faultId=18
    IF  ${fault18_suppresion}
      Log  Fault 18 is suppresed by fault 17, test will continue. [OK]  console=true
    ELSE
      Set Test Restriction  Fault 18 is not suppresed by fault 17, test will continue. [NOK]
    END
    Get All WCDMA Tx Power From All RMs  ${ALL_RMO_DS_WCDMA_POWER_AFTER_LINK_BREAK}
    ${cnbap_link_status}  Run Keyword And Return Status  CNBAP Link Status  Unavailable
    IF  ${cnbap_link_status}
      Log  CNBAP link status is correctly set after link break. [OK]  console=true
    ELSE
      Fail  msg= CNBAP link status is not correctly set after link break.
    END
    ${dnbap_link_status}  Run Keyword And Return Status  DNBAP Link Status  Unavailable
    IF  ${dnbap_link_status}
      Log  DNBAP link status is correctly set after link break. [OK]  console=true
    ELSE
      Fail  msg= DNBAP link status is not correctly set after link break.
    END
    ${cell_status}  Run Keyword And Return Status  Assert Every  WNCEL  operationalState=${DISABLED}  timeout=60
    IF  ${cell_status}
      Log  All WCDMA Cells state are set correctly after IuB link break. [OK]  console=true
    ELSE
      Fail  msg= WCDMA Cells state are wrong after IuB link break. Link will be restored.
    END
    Check Not Affected Resources Status


Check Not Affected Resources Status
    [Documentation]  To check if not affected technologies are available LTE + WCDMA.

    Log  Checking not affected resources having TOP availability.  console=true
    ${top_status}  Check SyncInputType
    Set Test Variable  ${TOP_STATUS}
    Log  TOP status after link break is: ${TOP_STATUS}  console=true
    Log  Checking other commissioned cells state. TOP availability is incudled in check.  console=true
    IF  ${SCF_COUNT_GSM}
      Check GSM Cells With TOP
      Check Abis Link Iub Link Break
    END
    IF  ${SCF_COUNT_LTE}
      Check LTE Cells With TOP
      Check S1 Link Iub Link Break
    END


Check GSM Cells With TOP
    [Documentation]  To check state of GSM cells after IuB link break bassed on TOP availability.

    IF  '${TOP}' == 'Available' and '${TOP_STATUS}' == 'Available'
      Check GSM Cells IuB Link Break  ${ACTIVE}  ${ENABLED}
    ELSE IF  '${TOP}' != 'Available' and '${TOP_STATUS}' != 'Available'
      Check GSM Cells IuB Link Break  ${ACTIVE}  ${ENABLED}
    ELSE
      Check GSM Cells IuB Link Break  ${ACTIVE}  ${ENABLED}  ${DEGRADED}
    END


Check LTE Cells With TOP
    [Documentation]  To check state of LTE cells after IuB link break bassed on TOP availability.

    IF  '${TOP}' == 'Available' and '${TOP_STATUS}' == 'Available'
      Check LTE Cells  ${ON_AIR_DONE}  ${ENABLED}
    ELSE IF  '${TOP}' != 'Available' and '${TOP_STATUS}' != 'Available'
     Check LTE Cells  ${ON_AIR_DONE}  ${ENABLED}
    ELSE
      Check LTE Cells  ${ON_AIR_DONE}  ${ENABLED}  ${DEGRADED}
    END


Check LTE Cells
    [Documentation]  To check state of LTE cells after IuB link break.
    [Arguments]  ${procedural_state}  ${operational_state}  ${availability_state}=${EMPTY}

    ${string}  Set Variable If  '${availability_state}'=='${EMPTY}'  proceduralState=${procedural_state}, operationalState=${operational_state}
    ...  proceduralState=${procedural_state}, operationalState=${operational_state}, availabilityStatus=${availability_state}

    ${status}  Run Keyword And Return Status  Assert Every  LNCEL  ${string}  timeout=180
    ${cells_states}  Catenate  SEPARATOR=,${SPACE}  ${procedural_state}  ${operational_state}  ${availability_state}
    IF  ${status}
      Log  Status of LTE cells after IuB link break is correct:${cells_states}. Test will continue. [OK]  console=true
    ELSE
      Fail  msg=Status of LTE cells after IuB link break is correct, test will be set to failed.
    END


Step4: Restore IuB Link Connection
    [Documentation]  In this step IuB link connection will be restored.

    Log  \nStep4: Restore IuB link connection.  console=true
    Wait Until Keyword Succeeds  5min  1min  Connect To Nokia Serving Switch And Perform Action  ${SWITCH_IP}  ${SWITCH_USER}  ${SWITCH_PASSWORD}
    ...  ${WCDMA_VLAN}  ${INTERFACE_ID}  no shutdown
    Sleep  300s
    ${dist_name_of_fault17}  Convert To String  /MRBTS-1/RAT-1/WTS-1/RNC-${RNC_ID}/WBTS-${WBTS_ID}
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_17}
    ${alarm_parameters}  Catenate  ${alarm_parameters},  alarmingResource=${dist_name_of_fault17},  'impactedCells'=""WCDMA:\n\tFaulty: All""
    Assert Alarm Active  parameters=${alarm_parameters}  timeout=60
    Log  Fault ${FAULT_17}[fault_id] has been triggered on ${dist_name_of_fault17}.
    ${fault18_suppresion}  Run Keyword And Return Status  Assert Alarm Inactive  faultId=18
    IF  ${fault18_suppresion}
      Log  Fault 18 is suppresed by fault 17, test will continue. [OK]  console=true
    ELSE
      Set Test Restriction  Fault 18 is not suppresed by fault 17, test will continue. [NOK]
    END
    Sleep  300s


Step5: Check Links State After Links Were Restored And All Cells State
    [Documentation]  In this step links state and cells state will be checked after link has been restored.

    Log  \nStep5: Check links state and cells state after Link has been restored.  console=true
    Check All Cells
    Check Links Status  Available
    ${wcdma_cells_state}  Check If WCDMA Cells Are In Working State From RNC PoV  ${RNC_ID}  ${WBTS_ID}  ${RNC["OMS_IP"]}
    ${wcdma_cells_status}  Run Keyword And Return Status  List Should Not Contain Value  ${wcdma_cells_state}  ${False}
    IF  ${wcdma_cells_status}
      Log  All of WCells are in WORKING state on RNC, test will continue. [OK]  console=true
    ELSE
      Fail  msg=Some of WCells are not in WORKING state on RNC, test will be set to failed.
    END
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}
    Compare TXs  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}
    Admin Check Active Alarms TAF


TC Setup
    Common Test Setup  tc_name=FM__link_break_IuB_startup


TC Teardown
    Run Keyword If Test Failed  Restore Link  ${WCDMA_VLAN}
    Common Test Teardown