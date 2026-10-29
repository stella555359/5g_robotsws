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
${NUMBER_OF_LOOPS}  3  # Number of multiple Abis link break and restoration. Default value is 3.


*** Keywords ***
TC__FM__link_break_Abis_short
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-8377
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8377 - Initial TAT creation
    ...  - 23.04.2017 - https://jira3.int.net.nokia.com/browse/TAT-9832 - Get all [TECHNOLOGY] Tx Power from all RMs needs to be adjusted to work
    ...  with 3+3
    ...  - 14.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15267 - Removed additional space
    ...  - 18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  - 04.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17385  -  Nokia 7210 Switch commands syntax addition
    ...  - 14.09.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20163 - Include custom restore link connection as failling action in all checks
    ...  throughout the test based on switch type in cofiguration
    ...  - 20.01.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20724 - Change switch_type name in link breaks scenariors
    ...  - 06.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21206 - Testcase failed because GSMVlan = 251 , should contain also vlan 252
    ...  - 09.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22134 - Change BSC connection from telnet to ssh
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24051 - Optimization of KW usage for FM
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to SSHLibrary
    ...  - 04.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27284 - Add fault for watchdog monitoring
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

    Check Commissioned Technologies  GSM

    Check If TRXs Are In WO State

    Check Links Status  Available


Step2: Perform Short Link Break
    [Documentation]  In this step Link Break will be performed.

    Log  \nStep2: Perform Short Link Break.  console=true

    Get Used VLANs

    ${status}  Run Keyword And Return Status
    ...  List Should Contain Value  ${VLA_NIDS}  @{GSM_VLAN}

    Run Keyword If  ${status}
    ...  Log  GSM VLAN which is set in configuration file is also found in IM, test will continue [OK]  console=true
    ...  ELSE
    ...  Fail  msg=GSM VLAN which is set in configuration file was not found in IM, test will be set to failed

    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}
    Run Keyword If  '${SWITCH_TYPE}'=='Nokia_7210' or '${SWITCH_TYPE}'=='Nokia_Nuage'
    ...  Wait Until Keyword Succeeds  5min  1min
    ...  Connect To Nokia Switch And Perform Short Interruption On Abis  ${SWITCH_IP}
    ...  ${SWITCH_USER}
    ...  ${SWITCH_PASSWORD}
    ...  ${GSM_VLAN}
    ...  ${INTERFACE_ID}
    ...  ELSE
    ...  Fail  msg=Serving switch is not supported, test will be set as failed.


Connect To Nokia Switch And Perform Short Interruption On Abis
    [Documentation]  Checking availability of serving switch and performing action: add or remove vlans
    [Arguments]  ${switch_ip_address}  ${switch_user}  ${switch_password}  ${vlan}  ${interface}

    ${status}  Check if target is stable  ${switch_ip_address}  30  30  90
    Run Keyword If  ${status}
    ...  Log  Serving switch with IP address ${switch_ip_address} is reachable, test will be continued  console=true
    ...  ELSE
    ...  Fail  msg=Serving switch with IP address ${switch_ip_address} is not reachable, test will be set as failed

    Log  Opening ssh connection to switch: ${switch_ip_address} and performing operation: short interuptions VLAN  console=true
    SSHLibrary.Open Connection  host=${switch_ip_address}
    SSHLibrary.Login  username=${switch_user}  password=${switch_password}
    SSHLibrary.Set Client Configuration  prompt=>#

    FOR  ${loop}  IN RANGE  0  ${NUMBER_OF_LOOPS}
        ${loop_incrementation}  Evaluate  ${loop} + 1
        Log  Current loop is: ${loop_incrementation}  console=true
        Log  Vlan ${vlan}[0] will be shutdown.  console=true
        SSHLibrary.Write  configure service vpls ${vlan}[0] sap 1/1/${interface}:${vlan}[0] shutdown
        SSHLibrary.Read Until Prompt
        Log  Vlan ${vlan}[1] will be shutdown.  console=true
        SSHLibrary.Write  configure service vpls ${vlan}[1] sap 1/1/${interface}:${vlan}[1] shutdown
        SSHLibrary.Read Until Prompt
        Wait Random Time
        Log  Vlan ${vlan}[0] will be restored.  console=true
        SSHLibrary.Write  configure service vpls ${vlan}[0] sap 1/1/${interface}:${vlan}[0] no shutdown
        SSHLibrary.Read Until Prompt
        Log  Vlan ${vlan}[1] will be restored.  console=true
        SSHLibrary.Write  configure service vpls ${vlan}[1] sap 1/1/${interface}:${vlan}[1] no shutdown
        SSHLibrary.Read Until Prompt
    END
    SSHLibrary.Close All Connections
    Log  Operation is done, test case will be continued [OK]  console=true


Wait Random Time
    [Documentation]  Use to wait random time after link break
    [Tags]  helper

    ${random_int}  Evaluate  random.randint(1, 10)  modules=random
    Sleep  ${random_int}


Step3: Check Links State After Links Were Restored And All Cells State
    [Documentation]  In this step links state and cells state will be checked after link has been restored.

    Log  \nStep3: Check links state and cells state after Link has been restored.  console=true

    Sleep  300s

    Check All Cells

    Check Links Status  Available

    Check If TRXs Are In WO State

    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}

    Compare TXs  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}

    Admin Check Active Alarms TAF


TC Setup
    Common Test Setup  tc_name=FM__link_break_Abis_short
    Connect To BSC Setup


TC Teardown
    hran_bsc.Close Connection
    Run Keyword If Test Failed
    ...  Restore Abis Link
    Common Test Teardown
