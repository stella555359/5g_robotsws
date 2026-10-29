*** Settings ***
Documentation
    ...  This TC can be only run on dual core platforms with NO IQ routing.
    ...  Fault 6710 is trigered on secondary core. ActFoceAutoReset is set to False.
    ...  WCDMA cells from secondary cells go down. Recovery action is not performed. Original fault is reported.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1800  # [in seconds] Timeout for waiting until cells are onAir after maintenance window action.
${ALARM_TIMEOUT}  660  # [seconds] Timeout for alarm to be reported in WebEM.
${NETACT_TIMEOUT}  120  # [seconds] Timeout for alarm to be reported in Netact.


*** Keywords ***
TC__FM__SC_reset_actForceAutoReset_false_enabled_cells
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-14618
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  25.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19753 - Update SC reset actForceAutoReset false enabled cells
    ...  17.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21635 - Implement new method for choosing DSP for crash based on DSPs
    ...  24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  16.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22441 - Fix for chosen SC DSP
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  29.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29811 - Fix list call for one DSP
    ...  14.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30021 - Receiver is hardcoded and when slave on left side fault is not generated
    ...  27.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29373 - Enhancement for CB008708
    ...  29.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30096 - Enhancement alarms not checked in Netact
    ...  16.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30319 - Added maintenance window cleanup in case the test failed
    ...  17.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30505 - Add verification of 4352 and 4670 faults from 26R1 onwards
    ...  24.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30567 - Replace a character in the object ID variable for Netact verification
    ...  ******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  MAINTAINER-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS20A  FEATURE-RP001498  FEATURE-RP001621  FEATURE-CB008708

    Step 0: Tc Prerequisites
    Step 1: Trigged WCDMA DSP Crash
    Step 2: Activate Maintenance Window And Check Recovery And Faults


Step 0: Tc Prerequisites
    Log  \nStep 0: Tc prerequisites.  console=true

    Change FMCADM Parameter  actForceAutoReset  false
    ${smods}  coam.Get Fsm Info
    ${number_of_smods}  Get Length  ${smods}
    IF  ${number_of_smods} < 2
        Fail  msg=Tested configuration is not dual core, test will be set as fail. [NOK]
    ELSE
        Log  Tested configuration is dual core, test will continue. [OK]  console=true
    END
    FOR  ${smod}  IN  @{smods}
        IF  '${smod}[activeRole]'=='Secondary'
            Set Test Variable  ${SMOD_R_DN}  ${smod}[id][internal]
            BREAK
        END
    END
    IF  '${ENB_BRANCH}'>='SBTS26R1'
        ${bts_name}  Get Bts Name
        ${sc_notifier}  Replace String Using Regexp  ${SMOD_R_DN}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
        ${sc_notifier}  Get Regexp Matches  ${sc_notifier}  MRBTS-${BTS_ID}.*
        ${sc_notifier}  Catenate  [${bts_name}]  ${sc_notifier}[0]
        Set Test Variable  ${SC_NOTIFIER}
        Set Test Variable  ${SC_OBJECT_ID_NMS}  PLMN-PLMN/${sc_notifier}[0]

        ${cells_on_sc}  Get Cell Mapping By Module Id  ${SMOD_R_DN}
        Set Test Variable  ${CELLS_ON_SC}
        ${all_rnc_ids}  Get Ids For All  RNC
        ${rnc_parameters}  coam.Get Parameters  ${all_rnc_ids}[0]
        Set Test Variable  ${RNC_ID}  ${rnc_parameters}[rncId]
        Set Test Variable  ${WBTS_ID}  ${rnc_parameters}[wbtsId]
    END
    Perform Site Reset


Step 1: Trigged WCDMA DSP Crash
    Log  \nStep 1: Trigger WCDMA DSP crash.  console=true

    ${start_time_netact}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME_NETACT}
    ${start_time_webem}  Get BTS time in UTC format  %Y-%m-%d %H:%M:%S.%6N
    Set Test Variable  ${START_TIME_WEBEM}
    Check Links Status  Available
    Choose DSP For Crash  WCDMA
    ${regexp_left_side}  Run Keyword And Return Status  Should Match Regexp  ${NODE_ID}  1...
    ${receiver}  Set Variable If  ${regexp_left_side}  0x10110009  0x20110009
    Log  Send fault.  console=true
    Run Keyword And Continue On Failure  Send Fault Ind Msg  ${NODE_ID}0240  ${receiver}  6710  1
    ${fault_6710_params}  Get String With Alarm Parameters  ${FAULT_6710_AIF2_BUFF_OVERFLOW}
    ${alarm_status_webem}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fault_6710_params}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${alarm_status_webem}  Fault ${FAULT_6710_AIF2_BUFF_OVERFLOW} is not active in WebEM. [NOK]
    Log  Fault ${FAULT_6710_AIF2_BUFF_OVERFLOW} is active in WebEM. [OK]  console=true
    ${wcdma_cell_status}  Run Keyword And Return Status  Assert Any  WNCEL  operationalState=${DISABLED} availabilityStatus=${FAILED}  timeout=60
    Should Be True  ${wcdma_cell_status}  WCDMA cells were not failed while fault 6710 occured. [NOK]
    Log  WCDMA cells were failed while fault 6710 occured. [OK]  console=true
    ${unaffected_rats}  Create List  NR  LTE  GSM
    FOR  ${rat}  IN  @{unaffected_rats}
        IF  ${SCF_COUNT_${rat}}
            ${cells_status}  Verify Cells TAF  technology=${rat}  scf_check=${FALSE}
            Should Be True  ${cells_status}  ${rat} cells are failed after WCDMA crash.
            Log  ${rat} cells are unaffected after WCDMA crash.  console=true
        END
    END
    ${alarm_status_netact}  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}s  30s
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_6710_AIF2_BUFF_OVERFLOW}
    ...  additional_fault_id=${FAULT_6710_AIF2_BUFF_OVERFLOW}[fault_id]
    Should Be True  ${alarm_status_netact}  Fault ${FAULT_6710_AIF2_BUFF_OVERFLOW} is not active in Netact. [NOK]
    Log  Fault ${FAULT_6710_AIF2_BUFF_OVERFLOW} is active in Netact. [OK]  console=true


Step 2: Activate Maintenance Window And Check Recovery And Faults
    Log  \nStep 2: Activate Maintenance Window and check recovery and faults.  console=true

    Create Maintenance Window
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}s  10s  Check All Cells
    ${secondary_smod_parameters}  coam.Get Parameters  ${SMOD_R_DN}
    ${value}  Fetch From Right  ${secondary_smod_parameters}[configDN]  /BTS_L-
    ${value_bts_r}  Fetch From Left  ${value}  /BTS_CONF
    ${right_side_smod_r}  Fetch From Right  ${SMOD_R_DN}  MRBTS_R-${value_bts_r}/
    ${recovery_execution_result}  Set Variable  BTS secondary core recovery reset:MRBTS-${BTS_ID}/${right_side_smod_r}
    ${parameter_object}  Wait Until Keyword Succeeds  300s  10s  Get Forced Recovery Parameter When Is Completed
    Verify Force Recovery Parameters  ${parameter_object}  ${FAULT_6710_AIF2_BUFF_OVERFLOW}  recovery_execution_result=${recovery_execution_result}

    IF  '${ENB_BRANCH}'>='SBTS26R1'
        ${status_wcdma}  Cells From RAT Are Mapped On SC  WNCEL  ${CELLS_ON_SC}
        ${status_gsm}  Cells From RAT Are Mapped On SC  GNCEL  ${CELLS_ON_SC}

        IF  ${status_wcdma}==${TRUE} and ${status_gsm}==${TRUE}
            ${webem_historical_alarms}  coam.Get Historic Alarms
            ${alarm_4352_2nd_core_auto_rst}  Get Alarm From List Of Alarms In WebEM  ${webem_historical_alarms}
            ...                                                                      &{FAULT_4352_2ND_CORE_AUTO_RST}
            ...                                                                      filtering_time=${START_TIME_WEBEM}
            ...                                                                      notifier=${SC_NOTIFIER}
            Should Not Be Empty  ${alarm_4352_2nd_core_auto_rst}  Fault ${FAULT_4352_2ND_CORE_AUTO_RST} was not active in WebEM. [NOK]
            ${alarm_4352_cores_not_conn}  Get Alarm From List Of Alarms In WebEM  ${webem_historical_alarms}
            ...                                                                   &{FAULT_4352_CORES_NOT_CONN}
            ...                                                                   filtering_time=${START_TIME_WEBEM}
            ...                                                                   notifier=${SC_NOTIFIER}
            Should Not Be Empty  ${alarm_4352_cores_not_conn}  Fault ${FAULT_4352_CORES_NOT_CONN} was not active in WebEM. [NOK]
            ${alarm_4670}  Get Alarm From List Of Alarms In WebEM  ${webem_historical_alarms}
            ...                                                    &{FAULT_4670}
            ...                                                    filtering_time=${START_TIME_WEBEM}
            Should Not Be Empty  ${alarm_4670}  Fault ${FAULT_4670} was not active in WebEM. [NOK]
            Log  Faults ${FAULT_4352_2ND_CORE_AUTO_RST}, ${FAULT_4352_CORES_NOT_CONN} and ${FAULT_4670} were active in WebEM during SC reset. [OK]
            ...  console=true

            Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}s  30s
            ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4352_2ND_CORE_AUTO_RST}
            ...                                                                               time_from=${START_TIME_NETACT}
            ...                                                                               object_id=${SC_OBJECT_ID_NMS}
            Log  Fault ${FAULT_4352_2ND_CORE_AUTO_RST} was active & cleared from Netact. [OK]  console=true
            Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}s  30s
            ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4352_CORES_NOT_CONN}
            ...                                                                               time_from=${START_TIME_NETACT}
            ...                                                                               object_id=${SC_OBJECT_ID_NMS}
            Log  Fault ${FAULT_4352_CORES_NOT_CONN} was active & cleared from Netact. [OK]  console=true
            ${suppl_alarm_info}  Catenate  BTS secondary core is enabled, or, un-commissioned BBMOD detected
            ...  at BTS start-up is commissioned at runtime or BBMOD is reset at runtime\\.
            ...  To use the affected resources and setup disabled WCDMA cell\\(s\\), the WCDMA RAT Reset is needed\\.
            Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}s  30s
            ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4670}
            ...                                                                               time_from=${START_TIME_NETACT}
            ...                                                                               dist_name=PLMN-PLMN/RNC-${RNC_ID}/WBTS-${WBTS_ID}
            ...                                                                               suppl_info=${suppl_alarm_info}
            Log  Fault ${FAULT_4670} was active & cleared from Netact. [OK]  console=true
        ELSE
            Log  WCDMA and GSM cells are not mapped on SC, check of faults 4352 and 4670 is not needed.  console=true
        END
    END

    [Teardown]  Delete Maintenance Window


Recovery Action
    Perform Site Reset
    Check Links Status  Available
    Admin Check Active Alarms Taf
    ${fault_6710_params}  Get String With Alarm Parameters  ${FAULT_6710_AIF2_BUFF_OVERFLOW}
    Assert Alarm Inactive  parameters=${fault_6710_params}  timeout=60
    Log  Fault ${FAULT_6710_AIF2_BUFF_OVERFLOW} is inactive in WebEM.  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}s  30s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_6710_AIF2_BUFF_OVERFLOW}
    ...                                                                               time_from=${START_TIME_NETACT}
    ...                                                                               additional_fault_id=${FAULT_6710_AIF2_BUFF_OVERFLOW}[fault_id]
    Log  Fault ${FAULT_6710_AIF2_BUFF_OVERFLOW} is cleared for Netact. [OK]  console=true


TC Setup
    Common Test Setup  tc_name=FM__SC_reset_actForceAutoReset_false_enabled_cells
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed  Maintenance Window Cleanup
    Recovery Action
    Teardown NetAct
    Common Test Teardown
