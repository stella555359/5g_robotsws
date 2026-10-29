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
${NUMBER_OF_LOOPS}  3  # Number of multiple SBTS short link break and restoration. Default value is 3.


*** Keywords ***
TC__FM__link_break_SBTS_short
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7389
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 7.08.2017 - https://jira3.int.net.nokia.com/browse/TAT-7389 - Initial TAT creation
    ...  - 23.04.2017 - https://jira3.int.net.nokia.com/browse/TAT-9832 - Get all [TECHNOLOGY] Tx Power from all RMs needs to be adjusted to work
    ...  with 3+3
    ...  - 14.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15267 - Removed additional space
    ...  - 18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  - 04.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17385  -  Nokia 7210 Switch commands syntax addition
    ...  - 14.09.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20163 - Include custom restore link connection as failling action in all checks
    ...  throughout the test based on switch type in cofiguration
    ...  - 20.01.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20724 - Change switch_type name in link breaks scenariors
    ...  - 03.02.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20823 - Restore link method is incorrect for SBTS link break if testcase is failed
    ...  - 18.03.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20959 - FM__link_break_SBTS_short test fail " '${mplaneStatus}' not found" due
    ...  wrong old check for Netact status
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 04.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27283 - Add faults for watchdog monitoring
    ...  - 05.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26773 - Add new steps to FM__link_break_SBTS_long
    ...  - 26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-rafal.ozga@nokia.com  MAINTAINER-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534  FEATURE-RP001145_RP000920  FEATURE-RP001486_RP000920

    Step1: Check All Required States

    Step2: Perform Short Link Break

    Step3: Check Links State After Links Were Restored And All Cells State


Step1: Check All Required States
    [Documentation]  In this step user input and specific states of links will be checked.

    Log  \nStep1: Check All Required States.  console=true

    ${all_rmods_power_before_link_break}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}
    ${all_rmods_power_after_link_break}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}
    ${all_rmo_ds_lte_power_after_link_break}  Create List
    Set Test Variable  ${ALL_RMO_DS_LTE_POWER_AFTER_LINK_BREAK}

    Verify If SBTS Is Connected To Netact
    Run Keyword If  ${NE3SADAPT}
    ...  Check NetAct Status

    Check Commissioned Technologies  none

    Check Links Status  Available


Step2: Perform Short Link Break
    [Documentation]  In this step Link Break will be performed.

    Log  \nStep2: Perform Short Link Break.  console=true

    Get Used VLANs

    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}

    Run Keyword If  '${SWITCH_TYPE}'=='Nokia_7210' or '${SWITCH_TYPE}'=='Nokia_Nuage'
    ...  Wait Until Keyword Succeeds  5min  1min
    ...  Connect To Nokia Serving Switch And Perform Short Port Interuption  ${SWITCH_IP}  ${SWITCH_USER}  ${SWITCH_PASSWORD}  ${INTERFACE_ID}
    ...  ELSE
    ...  Fail  msg=Serving switch is not supported, test will be set as failed.


Step3: Check Links State After Links Were Restored And All Cells State
    [Documentation]  In this step links state and cells state will be checked after link has been restored.

    Log  \nStep3: Check links state and cells state after Link has been restored.  console=true

    Sleep  300s

    Check All Cells

    Check Links Status  Available

    Run Keyword If  ${NE3SADAPT}
    ...  Check NetAct Status

    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}
    Compare TXs  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}

    Admin Check Active Alarms TAF


Wait Random Time
    [Documentation]  Use to wait random time after link break
    [Tags]  helper

    ${random_int}  Evaluate  random.randint(1, 10)  modules=random
    Sleep  ${random_int}


Mplane After Link Break
    [Documentation]  To check Mplane link status after link breaks were performed.
    ...  It won't be checked if NMS != Available (check done at the begining of TC)
    [Arguments]  ${mplane_status}  ${dist_nameof_mplane}

    ${status}  Run Keyword And Return Status
    ...  Should Not Be True  ${mplane_status}

    Return From Keyword If  ${status}

    ${status}  Query Infomodel  ${dist_nameof_mplane} is [stateInfo.operationalState = Available]
    Run Keyword If  ${status}
    ...  Log  Operational state of Mplane link is available after link break [OK] console=true
    ...  ELSE
    ...  Fail  State of Mplane link is currenlty other that Available test will be set to failed


TC Setup
    Common Test Setup  tc_name=FM__link_break_SBTS_short


TC Teardown
    Run Keyword If Test Failed
    ...  Connect To Nokia Serving Switch And Perform Action On Port  ${SWITCH_IP}  ${SWITCH_USER}  ${SWITCH_PASSWORD}  ${INTERFACE_ID}  no shutdown
    Common Test Teardown
