*** Settings ***
Documentation
    ...  This test case was created to imitate whole link break scenario.
    ...  Test will be done by deleting VLANs via CLI on physical switch.
    ...  VLANs are being loaded from IM, there is no need to point them as parameter.
    ...  Switch IP and other parameters are being loaded from robot file.
    ...  Scenario is fitted to commissioned technologies (eg. WCDMA alarms won't be checked if configuration is LTE-GSM only).
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


*** Keywords ***
TC__FM__link_break_Abis_long
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-8378
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8378 - Initial TAT creation
    ...  - 23.04.2017 - https://jira3.int.net.nokia.com/browse/TAT-9832 - Get all [TECHNOLOGY] Tx Power from all RMs needs to be adjusted to work
    ...  with 3+3
    ...  - 11.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15037 - Replacement of depracated KW "check_if_target_is_available"
    ...  - 14.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15267 - Removed additional space
    ...  - 18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  - 13.08.2019 - https://jira3.int.net.nokia.com/browse/TAT-17047 - Change GSM cell states and alarm severity
    ...  - 04.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17385  -  Nokia 7210 Switch commands syntax addition
    ...  - 19.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19746 - Move keywords to resource file
    ...  - 14.09.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20163 - Include custom restore link connection as failling action in all checks
    ...  throughout the test based on switch type in cofiguration
    ...  - 20.01.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20724 - Change switch_type name in link breaks scenariors
    ...  - 06.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21206 - Testcase failed because GSMVlan = 251 , should contain also vlan 252
    ...  - 09.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22134 - Change BSC connection from telnet to ssh
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24051 - Optimization of KW usage for FM
    ...  - 11.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26019 - Testcase checks uncommissioned technologies
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 05.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26773 - Add new steps to FM__link_break_SBTS_long
    ...  - 26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-rafal.ozga@nokia.com  MAINTAINER-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534  FEATURE-RP001145_RP000920  FEATURE-RP001486_RP000920

    Step1: Check All Required States
    Step2: Perform Long Abis Link Break
    Step3: Check Alarms Presence And GSM Related States After Abis Link Break
    Step4: Restore Abis Link Connection
    Step5: Check Links State After Links Were Restored And All Cells State


Step1: Check All Required States
    [Documentation]  In this step user input and specific states of links will be checked.

    Log  \nStep1: Check All Required States.  console=true

    ${all_rmods_power_before_link_break}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}
    ${all_rmods_power_after_link_break}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}
    ${all_rmo_ds_gsm_power_after_link_break}  Create List
    Set Test Variable  ${ALL_RMO_DS_GSM_POWER_AFTER_LINK_BREAK}

    Check Commissioned Technologies  GSM

    Check If TRXs Are In WO State

    Set_keepalive  240 seconds

    Check Links Status  Available


Step2: Perform Long Abis Link Break
    [Documentation]  In this step Abis Link Break will be performed.

    Log  \nStep2: Perform Long Abis Link Break.  console=true

    Get Used VLANs

    ${status}  Run Keyword And Return Status
    ...  List Should Contain Value  ${VLA_NIDS}  @{GSM_VLAN}

    Run Keyword If  ${status}
    ...  Log  GSM VLAN which is set in configuration file has been also found in IM, test will continue [OK]  console=true
    ...  ELSE
    ...  Fail  msg=GSM VLAN which is set in configuration file has not been found in IM, test will be set to failed

    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}
    FOR  ${vlan}  IN  @{GSM_VLAN}
        Log  Vlan ${vlan} will be shutdown.  console=true
        Run Keyword If  '${SWITCH_TYPE}'=='Nokia_7210' or '${SWITCH_TYPE}'=='Nokia_Nuage'
        ...  Wait Until Keyword Succeeds  5min  1min
        ...  Connect To Nokia Serving Switch And Perform Action  ${SWITCH_IP}  ${SWITCH_USER}  ${SWITCH_PASSWORD}  ${vlan}  ${INTERFACE_ID}  shutdown
        ...  ELSE
        ...  Fail  msg=Serving switch is not supported, test will be set as failed.
    END


Step3: Check Alarms Presence And GSM Related States After Abis Link Break
    [Documentation]  In this step alarms and link state related to GSM after Abis link break will be checked.

    Log  \nStep3: Check Alarms presence and GSM related states after Abis Link Break.  console=true

    Sleep  600s

    ${fid_2401_params}  Get String With Alarm Parameters  ${FAULT_2401}
    Assert Alarm Active  parameters=${fid_2401_params}  timeout=30
    Log  Fault ${FAULT_2401}[fault_id] has been triggered.  console=true

    ${fid_2412_params}  Get String With Alarm Parameters  ${FAULT_2412_MINOR}
    Assert Alarm Active  parameters=${fid_2412_params}  timeout=30
    Log  Fault ${FAULT_2412_MINOR}[fault_id] has been triggered.  console=true

    Log  RMs will be check if GSM carriers are set to OFF

    Get All GSM Tx Power From All RMs  ${ALL_RMO_DS_GSM_POWER_AFTER_LINK_BREAK}

    ${link_status}  Run Keyword And Return Status
    ...  Abis Link Status  Unavailable

    Run Keyword If  ${link_status}
    ...  Log  Abis link status is correctly set after link break [OK}  console=TRUE
    ...  ELSE
    ...  Fail  msg= Abis link status is not correctly set after link break

    ${cell_status}  Run Keyword And Return Status
    ...  Assert Every  GNCEL  operationalState=${DISABLED}  timeout=60

    Run Keyword If  ${cell_status}
    ...  Log  All GSM Cells state are set correctly after Abis link break [OK}  console=TRUE
    ...  ELSE
    ...  Fail  msg= GSM Cells state are wrong after Abis link break. Link will be restored

    Check Not Affected Resources Status


Check Not Affected Resources Status
    [Documentation]  To check if not affected technologies are available LTE + WCDMA

    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  Run Keywords
    ...  Check WCDMA Cells Abis Link Break
    ...  AND
    ...  Check CNBAP And DNBAP Link
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  Run Keywords
    ...  Check LTE Cells Abis Link Break
    ...  AND
    ...  Check S1 Link


Step4: Restore Abis Link Connection
    [Documentation]  In this step Abis lin connection will be restored.

    Log  \nStep4: Restore Abis link connection.  console=true
    FOR  ${vlan}  IN  @{GSM_VLAN}
        Log  Vlan ${vlan} will be set to no shutdown.  console=true
        Run Keyword If  '${SWITCH_TYPE}'=='Nokia_7210' or '${SWITCH_TYPE}'=='Nokia_Nuage'
        ...  Wait Until Keyword Succeeds  5min  1min
        ...  Connect To Nokia Serving Switch And Perform Action  ${SWITCH_IP}  ${SWITCH_USER}  ${SWITCH_PASSWORD}  ${vlan}  ${INTERFACE_ID}
        ...  no shutdown
    END
    Sleep  300s


Step5: Check Links State After Links Were Restored And All Cells State
    [Documentation]  In this step links state and cells state will be checked after link has been restored.

    Log  \nStep5: Check links state and cells state after Link has been restored.  console=true

    Check All Cells

    Check Links Status  Available

    Check If TRXs Are In WO State

    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}

    Compare TXs  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}

    Unset_keepalive

    Admin Check Active Alarms TAF


TC Setup
    Common Test Setup  tc_name=FM__link_break_Abis_long
    Connect To BSC Setup


TC Teardown
    hran_bsc.Close Connection
    Run Keyword If Test Failed
    ...  Restore Abis Link
    Common Test Teardown
