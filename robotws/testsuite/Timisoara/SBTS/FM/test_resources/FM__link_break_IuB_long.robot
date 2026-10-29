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
${CELLS_TIMEOUT}  360  # [in seconds] Timeout for SBTS to recover after link break.
${ALARM_TIMEOUT}  420  # [in seconds] Timeout for alarm to appear/disappear in WebEm.


*** Keywords ***
TC__FM__link_break_IuB_long
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-8375
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8375 - Initial TAT creation
    ...  - 23.04.2017 - https://jira3.int.net.nokia.com/browse/TAT-9832 - Get all [TECHNOLOGY] Tx Power from all RMs needs to be adjusted to work
    ...  with 3+3
    ...  - 11.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15037 - Replacement of depracated KW "check_if_target_is_available"
    ...  - 14.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15267 - Removed additional space
    ...  - 18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  - 04.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17385  -  Nokia 7210 Switch commands syntax addition
    ...  - 13.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19471 - Aligment with taf.rnc.oms.nwi3 library for FM test cases that use nwi3
    ...  - 19.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19746 - Move keywords to resource file
    ...  - 14.09.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20163 - Include custom restore link connection as failling action in all checks
    ...  throughout the test based on switch type in cofiguration
    ...  - 20.01.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20724 - Change switch_type name in link breaks scenariors
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 11.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26019 - Testcase checks uncommissioned technologies
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 05.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26773 - Add new steps to FM__link_break_SBTS_long
    ...  - 13.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27629 - Wait for fault to be inactive at the end
    ...  - 26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-rafal.ozga@nokia.com  MAINTAINER-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534  FEATURE-RP001145_RP000920  FEATURE-RP001486_RP000920

    Step1: Check All Required States
    Step2: Perform Long IuB Link Break
    Step3: Check Alarms Presence And WCDMA Related States After IuB Link Break
    Step4: Restore IuB Link Connection
    Step5: Check Links State After Links Were Restored And All Cells State


Step1: Check All Required States
    [Documentation]  In this step user input and specific states of links will be checked.

    Log  Step1: Check all required states.  console=True
    ${all_rmods_power_before_link_break}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}
    ${all_rmods_power_after_link_break}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}
    ${all_rmods_wcdma_power_after_link_break}  Create List
    Set Test Variable  ${ALL_RMODS_WCDMA_POWER_AFTER_LINK_BREAK}
    ${top}  Check SyncInputType
    Set Test Variable  ${TOP}
    Log  TOP status before link break ${TOP}.  console=True
    Check Commissioned Technologies  WCDMA
    Checking RNCid And WBTSid From IM
    ${wcdma_cells_state}  Create List
    ${wcdma_cells_state}  Check If WCDMA Cells Are In Working State From RNC PoV  ${RNC_ID}  ${WBTS_ID}  ${RNC["OMS_IP"]}
    ${wcdma_cells_status}  Run Keyword And Return Status
    ...  List Should Not Contain Value  ${wcdma_cells_state}  ${False}
    Run Keyword If  ${wcdma_cells_status}
    ...  Log  All of WCDMA cells are in working state on RNC side, test will continue. [OK]  console=True
    ...  ELSE
    ...  Fail  Some of WCDMA cells are not in working state on RNC side. Test will be set to failed.
    Check Links Status  Available


Step2: Perform Long IuB Link Break
    [Documentation]  In this step IuB Link Break will be performed.

    Log  Step2: Perform long IuB link break.  console=True
    Get Used VLANs
    ${status}  Run Keyword And Return Status
    ...  List Should Contain Value  ${VLA_NIDS}  ${WCDMA_VLAN}
    Run Keyword If  ${status}
    ...  Log  WCDMA VLAN which is set in configuration file was found in IM, test will continue. [OK]  console=True
    ...  ELSE
    ...  Fail  WCDMA VLAN which is set in configuration file was not found in IM, test will be set to failed.
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}
    Run Keyword If  '${SWITCH_TYPE}'=='Nokia_7210' or '${SWITCH_TYPE}'=='Nokia_Nuage'
    ...  Wait Until Keyword Succeeds  5min  1min
    ...  Connect To Nokia Serving Switch And Perform Action  ${SWITCH_IP}
    ...  ${SWITCH_USER}
    ...  ${SWITCH_PASSWORD}
    ...  ${WCDMA_VLAN}
    ...  ${INTERFACE_ID}
    ...  shutdown
    ...  ELSE
    ...  Fail  Serving switch is not supported, test will be set as failed.


Step3: Check Alarms Presence And WCDMA Related States After IuB Link Break
    [Documentation]  In this step alarms and link state related to WCDMA after IuB link break will be checked.

    Log  Step3: Check alarms presence and WCDMA related states after IuB link break.  console=True
    Sleep  600s
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_17}
    Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_17}[fault_id] "${FAULT_17}[fault_name]" has been triggered.  console=True
    Get All WCDMA Tx Power From All RMs  ${ALL_RMODS_WCDMA_POWER_AFTER_LINK_BREAK}
    ${cnbap_link_status}  Run Keyword And Return Status
    ...  CNBAP Link Status  Unavailable
    Run Keyword If  ${cnbap_link_status}
    ...  Log  CNBAP link status is correctly set after link break. [OK]  console=True
    ...  ELSE
    ...  Fail  CNBAP link status is not correctly set after link break.
    ${dnbap_link_status}  Run Keyword And Return Status
    ...  DNBAP Link Status  Unavailable
    Run Keyword If  ${dnbap_link_status}
    ...  Log  DNBAP link status is correctly set after link break. [OK]  console=True
    ...  ELSE
    ...  Fail  DNBAP link status is not correctly set after link break.
    ${cell_status}  Run Keyword And Return Status
    ...  Assert Every  WNCEL  operationalState=${DISABLED}  timeout=60
    Run Keyword If  ${cell_status}
    ...  Log  All WCDMA cells state are set correctly after IuB link break. [OK]  console=True
    ...  ELSE
    ...  Fail  WCDMA cells state are wrong after IuB link break. Link will be restored.
    Check Not Affected Resources Status


Step4: Restore IuB Link Connection
    [Documentation]  In this step IuB link connection will be restored.

    Log  Step4: Restore IuB link connection.  console=True
    Run Keyword If  '${SWITCH_TYPE}'=='Nokia_7210' or '${SWITCH_TYPE}'=='Nokia_Nuage'
    ...  Wait Until Keyword Succeeds  5min  1min
    ...  Connect To Nokia Serving Switch And Perform Action  ${SWITCH_IP}
    ...  ${SWITCH_USER}
    ...  ${SWITCH_PASSWORD}
    ...  ${WCDMA_VLAN}
    ...  ${INTERFACE_ID}
    ...  no shutdown


Step5: Check Links State After Links Were Restored And All Cells State
    [Documentation]  In this step links state and cells state will be checked after link has been restored.

    Log  Step5: Check links state after links were restored and all cells state.  console=True
    Wait Until Keyword Succeeds  ${CELLS_TIMEOUT}s  60s
    ...  Check All Cells
    Check Links Status  Available
    ${wcdma_cells_state}  Check If WCDMA Cells Are In Working State From RNC PoV  ${RNC_ID}  ${WBTS_ID}  ${RNC["OMS_IP"]}
    ${wcdma_cells_status}  Run Keyword And Return Status
    ...  List Should Not Contain Value  ${wcdma_cells_state}  ${False}
    Run Keyword If  ${wcdma_cells_status}
    ...  Log  All of WCDMA cells are in WORKING state on RNC side, test will continue. [OK]  console=True
    ...  ELSE
    ...  Fail  Some of WCDMA cells are not in WORKING state on RNC side, test will be set to failed.
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}
    Compare TXs  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_17}
    Assert Alarm Inactive  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Admin Check Active Alarms TAF


Check SyncInputType
    [Documentation]  Checking if TOP status is Available and returing bool value true or false. If it's false other syncInputType is used.

    ${top}  Query Infomodel  get list //CLOCK-*
    ${top_reference_list}  Create List
    ${top_state_dict}  Create Dictionary
    FOR  ${item}  IN  @{top}
        Append To List  ${top_reference_list}  ${item.referenceSourceList}
    END
    ${get_from_list}  Get From List  ${top_reference_list}  0
    ${status}  Run Keyword And Return Status
    ...  Get From List  ${top_reference_list}  1
    FOR  ${item}  IN  @{get_from_list}
        Run Keyword If  '${item["source"]}' == 'TOP'
        ...  Set To Dictionary  ${top_state_dict}  ${item["source"]}  ${item["availabilityStatus"]}
    END
    Run Keyword If  '${top_state_dict["TOP"]}' == 'Unavailable' and ${status}
    ...  Second Clock Check  ${top_reference_list}  ${top_state_dict}

    [Return]  ${top_state_dict["TOP"]}


Second Clock Check
    [Arguments]  ${top_reference_list}  ${top_state_dict}

    ${get_from_list}  Get From List  ${top_reference_list}  1
    FOR  ${item}  IN  @{get_from_list}
        Run Keyword If  '${item["source"]}' == 'TOP'
        ...  Set To Dictionary  ${top_state_dict}  ${item["source"]}  ${item["availabilityStatus"]}
    END


Check Not Affected Resources Status
    [Documentation]  To check if not affected technologies are available LTE + WCDMA.

    Log  Checking not affected resources having TOP availability in mind.  console=True
    ${top_status}  Check SyncInputType
    Set Test Variable  ${TOP_STATUS}
    Log  TOP status after link break is: ${TOP_STATUS}.  console=True
    Log  Checking other commissioned cells state. TOP availability is included in check.  console=True
    Sleep  100s
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  Run Keywords
    ...  Check GSM Cells With TOP
    ...  AND
    ...  Check Abis Link Iub Link Break
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  Run Keywords
    ...  Check LTE Cells With TOP
    ...  AND
    ...  Check S1 Link Iub Link Break


Check GSM Cells With TOP
    [Documentation]  To check state of GSM cells after IuB link break including TOP availability.

    Run Keyword If  '${TOP}' == 'Available' and '${TOP_STATUS}' == 'Available'
    ...  Check GSM Cells IuB Link Break  ${ACTIVE}  ${ENABLED}
    ...  ELSE IF  '${TOP}' != 'Available' and '${TOP_STATUS}' != 'Available'
    ...  Check GSM Cells IuB Link Break  ${ACTIVE}  ${ENABLED}
    ...  ELSE
    ...  Check GSM Cells IuB Link Break  ${ACTIVE}  ${ENABLED}  ${DEGRADED}


Check LTE Cells With TOP
    [Documentation]  To check state of LTE cells after IuB link break including TOP availability.

    Run Keyword If  '${TOP}' == 'Available' and '${TOP_STATUS}' == 'Available'
    ...  Check LTE Cells  ${ON_AIR_DONE}  ${ENABLED}
    ...  ELSE IF  '${TOP}' != 'Available' and '${TOP_STATUS}' != 'Available'
    ...  Check LTE Cells  ${ON_AIR_DONE}  ${ENABLED}
    ...  ELSE
    ...  Check LTE Cells  ${ON_AIR_DONE}  ${ENABLED}  ${DEGRADED}


Check LTE Cells
    [Documentation]  To check state of LTE cells after IuB link break.
    [Arguments]  ${procedural_state}  ${operational_state}  ${availability_state}=${EMPTY}

    ${string}  Set Variable If  '${availability_state}'=='${EMPTY}'  proceduralState=${procedural_state}, operationalState=${operational_state}  ELSE
    ...  proceduralState=${procedural_state}, operationalState=${operational_state}, availabilityStatus=${availability_state}
    ${status}  Run Keyword And Return Status
    ...  Assert Every  LNCEL  ${string}  timeout=180
    ${cells_states}  Catenate  SEPARATOR=,${SPACE}  ${procedural_state}  ${operational_state}  ${availability_state}
    Run Keyword If  ${status}
    ...  Log  Status of LTE cells after IuB link break is correct: ${cells_states}. Test will continue. [OK]  console=True
    ...  ELSE
    ...  Fail  Status of LTE cells after IuB link break is correct, test will be set to failed.


TC Setup
    Common Test Setup  tc_name=FM__link_break_IuB_long


TC Teardown
    Run Keyword If Test Failed
    ...  Restore Link  ${WCDMA_VLAN}
    Common Test Teardown
