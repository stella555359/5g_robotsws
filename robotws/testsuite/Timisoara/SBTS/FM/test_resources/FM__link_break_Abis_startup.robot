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


*** Variables ***
${TIMER}  600  # Timer which is needed for configuration to reach OnAir status with active fault 2412 after startup
${STARTUP_TIMEOUT}  600  # Timeout for SBTS to recover after site reset
${ALARM_TIMEOUT}  60  # Timeout for alarm to be seen in WebEM
${TIMEOUT_RESTORE_ABIS_LINK_CONNECTION}    300  #Timeout after restore abis link connection

*** Keywords ***
TC__FM__link_break_Abis_startup
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-12279
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 17.09.2018 - https://jira3.int.net.nokia.com/browse/TAT-12279 - Initial TAT creation
    ...  - 04.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17385  -  Nokia 7210 Switch commands syntax addition
    ...  - 19.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19746 - Move keywords to resource file
    ...  - 14.09.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20163 - Include custom restore link connection as failling action in all checks
    ...  throughout the test based on switch type in cofiguration
    ...  - 06.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21206 - Testcase failed because GSMVlan = 251 , should contain also vlan 252
    ...  - 12.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21215 - Update FM testcases accordingly with CNI-64164
    ...  Show configuration MO in WebEM in alarms
    ...  - 09.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22134 - Change BSC connection from telnet to ssh
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24051 - Optimization of KW usage for FM
    ...  - 13.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24486 - Add timeout parameter to check not affected resources after site reset
    ...  - 24.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26017 - Testcase needs more time for SBTS to be reachable
    ...  - 11.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26019 - Testcase checks uncommissioned technologies
    ...  - 26.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26997 - Add extra time to check if the RF was recover after reset
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 05.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26773 - Add new steps to FM__link_break_SBTS_long
    ...  - 30.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27404 - Remove alarming resource check
    ...  - 26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  - 21.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28172 - Check FID 2412 before Vlan restore
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-rafal.ozga@nokia.com  MAINTAINER-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534  FEATURE-RP001145_RP000920  FEATURE-RP001486_RP000920

    Step1: Check All Required States
    Step2: Perform Long Abis Link Break And Reset Site
    Step3: Wait For Ping To SBTS Is Back And Assert Active Alarm 7107 With Fault 2412
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

    hran_bsc.Close Connection

    Check Links Status  Available

    Checking BSCid And BCFid From IM

    ${bts_name}  Infomodel Get Objects Parameter  //MRBTS_A-*  btsName
    ${mrbts}  Infomodel Get Objects Parameter  /MRBTS-1/RAT-1/BTS_L-1  btsId
    Set Test Variable  ${CONF_OBJ}  [${bts_name[0]}] MRBTS-${mrbts[0]}


Checking BSCid And BCFid From IM
    [Documentation]
    ...  To check what is BSC and BCF IDs from IM

    ${query_bcf}  Query Infomodel  get list //BCF_L-*  timeout=30
    FOR  ${entity}  IN  @{query_bcf}
        Set Test Variable  ${BCF_ID}  ${entity.bcfId}
        Set Test Variable  ${BSC_ID}  ${entity.bscId}
    END
    Run Keyword If  ${BCF_ID} and ${BSC_ID}
    ...  Log To Console  BCFid is: ${BCF_ID}, BSCid is: ${BSC_ID}
    ...  ELSE
    ...  Fail  msg=BCFid or BSCid cannot be received from IM.


Step2: Perform Long Abis Link Break And Reset Site
    [Documentation]  In this step Abis Link Break and site reset will be performed

    Log  \nStep2: Perform Long Abis Link Break and site reset.  console=true

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
    Log  Site reset will be performed  console=true

    coam.Reset Site  timeout=${STARTUP_TIMEOUT}

    Log  Site reset has been performed [OK]  console=true


Step3: Wait For Ping To SBTS Is Back And Assert Active Alarm 7107 With Fault 2412
    [Documentation]  In this step alarms and link state related to GSM after Abis link break will be checked.

    Log  \nStep3: Wait for ping to SBTS is back, check alarms presence and GSM related states after Abis Link Break.  console=true

    Log  Wait until ping to SBTS is back..  console=true

    Wait Until Keyword Succeeds  2 min  0 sec
    ...  Check if target is stable  ${SMOD1['IP']}  30  30  120

    Log  Ping to SBTS is back, test will be continued [OK]  console=TRUE

    ${mrbts_dn}  Set Variable  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_2412_CRITICAL}
    ${alarm_parameters}  Catenate  ${alarm_parameters},  alarmingResource=${mrbts_dn},  'impactedCells'=""GSM:\n\tFaulty: All""
    Assert Alarm Active  parameters=${alarm_parameters}  timeout=${TIMER}
    Log  Fault ${FAULT_2412_CRITICAL}[fault_id] has been triggered on ${mrbts_dn}.  console=true

    Assert Alarm Active  parameters=faultId=${FAULT_2412_CRITICAL}[fault_id], configObjectName="${CONF_OBJ}"  timeout=60
    Log  Configuration alarming object is filled correctly : configObjectName="${CONF_OBJ}".  console=true

    Wait Until Keyword Succeeds  300s  60s
    ...  Get All GSM Tx Power From All RMs  ${ALL_RMO_DS_GSM_POWER_AFTER_LINK_BREAK}

    ${link_status}  Run Keyword And Return Status
    ...  Abis Link Status  Unavailable

    Run Keyword If  ${link_status}
    ...  Log  Abis link status is correctly set after link break [OK]  console=TRUE
    ...  ELSE
    ...  Fail  msg= Abis link status is not correctly set after link break

    ${cell_status}  Run Keyword And Return Status
    ...  Assert Every  GNCEL  operationalState=${DISABLED}  timeout=60

    Run Keyword If  ${cell_status}
    ...  Log  All GSM Cells state are set correctly after Abis link break [OK]  console=TRUE
    ...  ELSE
    ...  Fail  msg= GSM Cells state are wrong after Abis link break. Link will be restored

    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  60
    ...  Check Not Affected Resources Status


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
    [Documentation]  In this step Abis link connection will be restored.

    Log  \nStep4: Restore Abis link connection and check if FID 2412 is inactive.  console=true
    FOR  ${vlan}  IN  @{GSM_VLAN}
        Log  Vlan ${vlan} will be not shutdown.  console=true
        Run Keyword If  '${SWITCH_TYPE}'=='Nokia_7210' or '${SWITCH_TYPE}'=='Nokia_Nuage'
        ...  Wait Until Keyword Succeeds  5min  1min
        ...  Connect To Nokia Serving Switch And Perform Action  ${SWITCH_IP}  ${SWITCH_USER}  ${SWITCH_PASSWORD}  ${vlan}  ${INTERFACE_ID}
        ...  no shutdown
    END
    Sleep  ${TIMEOUT_RESTORE_ABIS_LINK_CONNECTION}
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_2412_CRITICAL}
    ${alarm_parameters}  Catenate  ${alarm_parameters},  'impactedCells'=""GSM:\n\tFaulty: All""
    Assert Alarm Inactive  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_2412_CRITICAL}[fault_id] is not active.  console=true


Step5: Check Links State After Links Were Restored And All Cells State
    [Documentation]  In this step links state and cells state will be checked after link has been restored.

    Log  \nStep5: Check links state and cells state after Link has been restored.  console=true

    Check All Cells

    Check Links Status  Available

    Connect To BSC Setup

    Check If TRXs Are In WO State

    hran_bsc.Close Connection

    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}

    Compare TXs  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}

    Admin Check Active Alarms TAF


TC Setup
    Common Test Setup  tc_name=FM__link_break_Abis_startup
    Connect To BSC Setup


TC Teardown
    hran_bsc.Close Connection
    Run Keyword If Test Failed
    ...  Restore Abis Link
    Common Test Teardown
