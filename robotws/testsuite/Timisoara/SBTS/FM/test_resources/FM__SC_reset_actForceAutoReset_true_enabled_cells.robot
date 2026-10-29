*** Settings ***
Documentation
    ...  This TC can be only run on dual core platforms with NO IQ routing.
    ...  Fault 6710 is trigered on secondary core. ActFoceAutoReset is set to True.
    ...  All secondary cells go down. Recovery action is performed.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  900  # [in seconds] Timeout for fault to be visible in WebEM.
${NETACT_TIMEOUT}  240  # [in seconds] Timeout for alarm to be reported in Netact.
${RECOVERY_TIMEOUT}  420  # [in seconds] Timeout for SBTS to recover.


*** Keywords ***
TC__FM__SC_reset_actForceAutoReset_true_enabled_cells
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10246
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  26.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19780 - Update FM SC reset actForceAutoReset true enabled cells
    ...  31.03.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21123 - Add core checking for primary/secondary core in preconditions
    ...  24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  26.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29236 - Add support for SBTS25R3 and higher - verify fault 4670
    ...  09.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29857 - Increase alarm timeout
    ...  25.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29717 - Add supplementary alarm info check for FID 4670 in existing automated tests
    ...  ******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  MAINTAINER-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS20A  FEATURE-RP001498  FEATURE-RP001621

    Step1: Check All Required States
    Step2: Trigged WCDMA DSP Crash
    Step3: Check Recovery Action Result


Step1: Check All Required States
    [Documentation]  In this step specific states will be checked.

    Log  \nStep1: Check all required states.  console=true
    ${smods}  coam.Get Fsm Info
    ${number_of_smods}  Get Length  ${smods}
    IF  ${number_of_smods} < 2
        Fail  msg=Tested configuration is not dual core, test will be set as fail. [NOK]
    ELSE
        Log  Tested configuration is dual core, test will continue. [OK]  console=true
    END
    Log  Check actForceAutoReset and change to true if needed.  console=true
    Change FMCADM Parameter  actForceAutoReset  true
    ${all_rnc_ids}  Get Ids For All  RNC
    ${rnc_parameters}  coam.Get Parameters  ${all_rnc_ids}[0]
    Set Test Variable  ${RNC_ID}  ${rnc_parameters}[rncId]
    Set Test Variable  ${WBTS_ID}  ${rnc_parameters}[wbtsId]
    Perform Site Reset


Step2: Trigged WCDMA DSP Crash
    [Documentation]  In this step WCDMA DSP crash will be performed.

    Log  \nStep2: Trigger WCDMA DSP crash.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}
    Choose DSP For Crash  WCDMA
    ${regexp_left_side}  Run Keyword And Return Status  Should Match Regexp  ${NODE_ID}  1...
    ${receiver}  Set Variable If  ${regexp_left_side}  0x10110009  0x20110009
    Log  Send fault.  console=true
    Run Keyword And Continue On Failure  Send Fault Ind Msg  ${NODE_ID}0240  ${receiver}  6710  1

    ${wcdma_cell_status}  Run Keyword And Return Status  Assert Any  WNCEL  operationalState=${DISABLED} availabilityStatus=${FAILED}  timeout=60
    ${fault_6710_params}  Get String With Alarm Parameters  ${FAULT_6710_2_ND_CORE_AUTO_RST}
    Assert Alarm Active  parameters=${fault_6710_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault 6710 ${FAULT_6710_2_ND_CORE_AUTO_RST} is active in WebEM.  console=true

    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=192.168.255.119  timeout=30  remote_host=${PC_IP2}
    IF  ${ping_loss_status} == ${FALSE}
        Log  Ping is not lost.  console=true
    ELSE
        Log  Ping to secondary core is lost. [OK]  console=true
    END
    IF  ${wcdma_cell_status}
        Log  WCDMA cells were failed while fault 6710 was active. [OK]  console=true
    ELSE
        Fail  WCDMA cells were not failed while fault 6710 was active. [NOK]
    END


Step3: Check Recovery Action Result
    [Documentation]  This step check recovery action result.

    Log  \nStep3: Check recovery action result.  console=true
    ${ping_up_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=192.168.255.119  timeout=600  remote_host=${PC_IP2}
    IF  ${ping_up_status} == ${FALSE}
        Log  Ping on secondary core is not back.  console=true
    ELSE
        Log  Secondary Core is back online. [OK]  console=true
    END

    ${suppl_alarm_info}  Catenate  SEPARATOR=${SPACE}
    ...  BTS secondary core is enabled, or, un-commissioned BBMOD detected at BTS start-up is commissioned at runtime or BBMOD is reset at runtime.
    ...  To use the affected resources and setup disabled WCDMA cell.*, the WCDMA RAT Reset is needed.
    IF  ${SCF_COUNT_WCDMA} and '${ENB_BRANCH}' >= 'SBTS25R3'
        ${fault_4670_params}  Get String With Alarm Parameters  ${FAULT_4670}
        ${alarm_4670_parameters}  Catenate  SEPARATOR=,${SPACE}  ${fault_4670_params}  supplAlarmInfo=regex"${suppl_alarm_info}"
        Assert Alarm Active  parameters=${alarm_4670_parameters}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${FAULT_4670} is visible in WebEM.  console=true
        Assert Alarm Inactive  parameters=${alarm_4670_parameters}  timeout=${ALARM_TIMEOUT}
    END

    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells
    ${fault_6710_params}  Get String With Alarm Parameters  ${FAULT_6710_2_ND_CORE_AUTO_RST}
    Assert Alarm Inactive  parameters=${fault_6710_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_6710_2_ND_CORE_AUTO_RST} is inactive in WebEM.  console=true

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_6710_2_ND_CORE_AUTO_RST}  time_from=${START_TIME}
    Log  Fault ${FAULT_6710_2_ND_CORE_AUTO_RST} reported and cleared from WebEM and Netact.  console=true
    IF  ${SCF_COUNT_WCDMA} and '${ENB_BRANCH}' >= 'SBTS25R3'
        Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4670}  time_from=${START_TIME}
        ...  dist_name=PLMN-PLMN/RNC-${RNC_ID}/WBTS-${WBTS_ID}
        ...  suppl_info=${suppl_alarm_info}
        Log  Fault ${FAULT_4670} reported and cleared from WebEM and Netact.  console=true
    END

    Perform Site Reset


TC Setup
    Common Test Setup  tc_name=FM__SC_reset_actForceAutoReset_true_enabled_cells
    Setup NetAct


TC Teardown
    Change Parameter ActForce(Unit)AutoReset  false  actForceAutoReset
    Teardown NetAct
    Common Test Teardown
