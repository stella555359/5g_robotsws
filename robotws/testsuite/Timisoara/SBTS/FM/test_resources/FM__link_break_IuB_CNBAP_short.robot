*** Settings ***
Documentation
    ...  This test case was created to imitate IuB CNBAP link break scenario
    ...  It will be done by modyfing iptables
    ...  Scenario is fitted to commissioned technologies (eg. GSM link state wont be checked it confiugraiton is LW only)

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${NUMBER_OF_LOOPS}  10  # Number of multiple IuB short link break and restoration. Default value is 3.


*** Keywords ***
TC__FM__link_break_IuB_CNBAP_short
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7381
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 7.08.2017 - https://jira3.int.net.nokia.com/browse/TAT-7381 - Initial TAT creation
    ...  - 14.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15267 - Removed additional space
    ...  - 18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  - 13.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19471 - Aligment with taf.rnc.oms.nwi3 library for FM test cases that use nwi3
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-rafal.ozga@nokia.com  MAINTAINER-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534  FEATURE-RP001145_RP000920  FEATURE-RP001486_RP000920

    Step1: Check All Required States
    Step2: Perform Short CNBAP Link Break
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

    ${configuration}  Check System Modules Configuration In InfoModel
    ${chain}  Set Variable If  '${configuration}' == '4+3' or '${configuration}' == '3+4'  FORWARD  INPUT
    Set Test Variable  ${CHAIN}  ${chain}

    Log  Tested configuration type is: ${configuration}  console=true
    Log  Chain for iptables which will be used: ${CHAIN}  console=true

    Check Commissioned Technologies  WCDMA

    Checking RNCid And WBTSid From IM

    ${wcdma_cells_state}  Create List
    ${wcdma_cells_state}  Check If WCDMA Cells Are In Working State From RNC PoV  ${RNC_ID}  ${WBTS_ID}  ${RNC["OMS_IP"]}
    ${wcdma_cells_status}  Run Keyword And Return Status
    ...  List Should Not Contain Value  ${wcdma_cells_state}  ${False}
    Run Keyword If  ${wcdma_cells_status}
    ...  Log  All of WCells are in WORKING state om RNC, test will continue [OK]  console=true
    ...  ELSE
    ...  Fail  msg=Some of WCells are not in WORKING state on RNC, test will be set to failed

    Check Links Status  Available


Step2: Perform Short CNBAP Link Break
    [Documentation]  In this step multiple short CNBAP Link Breaks will be performed.

    Log  \nStep2: Perform multiple Short CNBAP Link Breaks.  console=true

    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}

    Perform Short CNBAP Link Break


Perform Short CNBAP Link Break
    [Documentation]  Method created to perform CNBAP link break via modification of iptables

    ${wnbts_object}  ute_admin_infomodel.Query Infomodel  get object /MRBTS-1/RAT-1//WNBTS_A-*
    Set Test Variable  ${MIN_SCTP_PORT}  ${wnbts_object.cPlaneList.sctpPortMin}
    Connect To SMOD  ${SMOD1['IP']}

    FOR  ${loop}  IN RANGE  0  ${NUMBER_OF_LOOPS}
        ssh.Execute  iptables -I ${CHAIN} -4 -p SCTP --dport ${MIN_SCTP_PORT} -j DROP -w
        Log  Command sent: 'iptables -I ${CHAIN} -4 -p SCTP --dport ${MIN_SCTP_PORT} -j DROP -w'  console=true
        ssh.Assert Exit Status  0  msg=Test failed because of link break failed.
        Wait Random Time
        ${output}  ssh.Execute  iptables -D ${CHAIN} -4 -p SCTP --dport ${MIN_SCTP_PORT} -j DROP -w
        Log  Command sent: 'iptables -D ${CHAIN} -4 -p SCTP --dport ${MIN_SCTP_PORT} -j DROP -w'  console=true
        ssh.Assert Exit Status  0  msg=Restore CNBAP Link failed.\n${output}
    END


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

    ${wcdma_cells_state}  Check If WCDMA Cells Are In Working State From RNC PoV  ${RNC_ID}  ${WBTS_ID}  ${RNC["OMS_IP"]}
    ${wcdma_cells_status}  Run Keyword And Return Status
    ...  List Should Not Contain Value  ${wcdma_cells_state}  ${False}
    Run Keyword If  ${wcdma_cells_status}
    ...  Log  All of WCells are in WORKING state om RNC, test will continue [OK]  console=true
    ...  ELSE
    ...  Fail  msg=Some of WCells are not in WORKING state on RNC, test will be set to failed

    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}

    Compare TXs  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}

    Admin Check Active Alarms TAF


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
