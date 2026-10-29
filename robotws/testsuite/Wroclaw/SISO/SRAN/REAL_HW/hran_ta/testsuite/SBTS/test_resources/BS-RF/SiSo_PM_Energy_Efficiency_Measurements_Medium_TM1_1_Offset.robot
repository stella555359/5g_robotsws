*** Settings ***
Documentation
...  TC for feature: CB008962-SR-F-ST2 Energy Efficiency

#Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Resource    ../../../../resources/ca_BSRF_Energy_Efficiency.robot

Library    taf.sbts.oam.coam.admin  WITH NAME  admin

*** Variables ***

${INTERVAL}  15  # for parameter: mtBtsEnergyMonitoring. Please enter only the number. Available intervals in minutes: 15,30,60,360,720,1440
${INTERVAL_AMOUNT}  1
${TM_OFFSET}  51
${SNAPSHOT}  False
${node}  default

*** Keywords ***
TC__SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-17657
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  TC for feature: CB008962-SR-F-ST2 Energy Efficiency
    ...  The purpose of this Test Case is to gather EEM counters.
    ...  Power Meter is capable of measure power consumption (DC voltage and amperage) in RFM, SM and whole BTS.
    ...  Counters are collecting when BTS is in TDS mode and TM1.1 for NR and LTE cells is started.
    ...  User have to pass TM_offset (power backoff) parameter for test model, if not, default 5.1dB is used.
    ...  SBTS counters: M40002C0,M40002C1,M40002C2
    ...  RFM counters:  M40003C0,M40003C1,M40003C2,M40003C3,M40003C4,M40003C5
    ...  SM counters:   M40004C0,M40004C1,M40004C2,M40004C3,M40004C4,M40004C5
    ...  TC sends all gathered counters to excel file.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 05.01.2023 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-17657 - Initial creation

    Set Tags    OWNER-mateusz.kawka@nokia.com
    ...         AUTHOR-mateusz.kawka@nokia.com
    ...         MAINTAINER-mateusz.kawka@nokia.com
    ...         PHASE-CRT

    Step1: Preconditions with TM - Offset ${TM_OFFSET}
    Step2: Start TM And Wait For Counters
    Step3: Collect PM Counters And Stop TM
    step4: Exit From TDS And Deactivate Feature

    [Teardown]  Run Keywords  Log to console  TC finished. Result = ${KEYWORD STATUS}
    ...  AND  Set Suite Variable  ${KEYWORD STATUS}

Step1: Preconditions with TM - Offset ${TM_OFFSET}

    Log To Console  Step1: Preconditions with TM - Offset ${TM_OFFSET}${\n}

    ${errors_list}  Create List
    Set Test Variable  ${SBTS_COUNTERS}  M40002C0,M40002C1,M40002C2
    Set Test Variable  ${RFM_COUNTERS}   M40003C0,M40003C1,M40003C2,M40003C3,M40003C4,M40003C5
    Set Test Variable  ${SM_COUNTERS}    M40004C0,M40004C1,M40004C2,M40004C3,M40004C4,M40004C5
    Set Test Variable  ${ERRORS_LIST}
    Set Test Variable  ${BTS_avg_per_h_offset_${TM_OFFSET}}  ${0}

    ${bts_params}  admin.Get parameters for all  BTS  alias=${node}
    Set Test Variable  ${BTS_ID}  ${bts_params[0].btsId}

    Set Test Variable  ${object_variable_actPowerMeter}  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    Set Test Variable  ${object_variable_mtBtsEnergyMonitoring}  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1

    Check Interval  ${INTERVAL}
    Log To Console  Test will collect PM counters for ${INTERVAL_AMOUNT} x ${INTERVAL}min !${\n}

    ${new_counters_path}    Check If Current Build Is Newer Than    SBTS24R2_ENB_9999_231220_000004
    Set Test Variable  ${NEW_COUNTERS_PATH}

    Parameters Recommissioning For Power Meter  true  ${INTERVAL}min  alias=${node}
    Sleep  60s
    Log To Console  Energy Efficiency feature activated !${\n}

    Log To Console  Entering to Test Dedicated State, please wait !${\n}
    admin.Reset To Test Dedicated  timeout=600  alias=${node}

    ${bts_test_state}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  10 min  20 s  Check Required Mrbts State  Test  alias=${node}

    Run Keyword If  '${bts_test_state}'=='True'
    ...  Log to console  BTS is in TDS !${\n}
    ...  ELSE  Run Keywords  Log to console  BTS is NOT in TDS, set test failed !${\n}
    ...  AND  Append To List  ${ERRORS_LIST}  BTS is NOT in TDS !
    ...  AND  Fail  BTS is NOT in TDS, set test failed !

    Sleep  60s

Step2: Start TM And Wait For Counters

    Log To Console  step2: Start TM And Wait For Counters${\n}

    Start Downlink NR TM1.1  ${TM_OFFSET}
    Start Downlink LTE TM1.1

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}  ${INTERVAL_AMOUNT}*${INTERVAL}
    Log To Console
    ...  ${\n}Waiting for ${time_to_sleep} minutes to Get PM Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !${\n}
    Sleep  ${time_to_sleep} minutes

Step3: Collect PM Counters And Stop TM

    Log To Console  Step3: Collect PM Counters And Stop TM${\n}

    ${raw_sbts_counters}  admin.Get Pm Counters  ${SBTS_COUNTERS}  timeout=100s  alias=${node}

    ${SM_avg_per_h}  Get Average SBTS Counter Value  M40002C0  ${raw_sbts_counters}
    ${RM_avg_per_h}  Get Average SBTS Counter Value  M40002C1  ${raw_sbts_counters}
    ${temp_value}  Get Average SBTS Counter Value  M40002C2  ${raw_sbts_counters}
    Set Test Variable  ${BTS_avg_per_h_offset_${TM_OFFSET}}  ${temp_value}

    ${sbts_status}  Evaluate  (${SM_avg_per_h}+${RM_avg_per_h}) == ${BTS_avg_per_h_offset_${TM_OFFSET}}
    Run Keyword If  ${sbts_status}
    ...  Log To Console  Average value of SM and RM counters is equal to SBTS counter !
    ...  ELSE
    ...  Run Keywords
    ...  Log To Console  Average value of SM and RM counters is NOT equal to SBTS counter ! Feature deactivation !
    ...  AND  Append To List  ${ERRORS_LIST}  Average value of SM and RM counters is NOT equal to SBTS counter
    ...  AND  Parameters Recommissioning For Power Meter  false  disabled  alias=${node}
    ...  AND  Run Keyword And Continue On Failure  Fail  Average value of SM and RM counters is NOT equal to SBTS counter !

    Log To Console  Main KPI value M40002C2: ${BTS_avg_per_h_offset_${TM_OFFSET}}${\n}
    Set Test Variable  ${BTS_avg_per_h_offset_${TM_OFFSET}}

    Collect Counters And Send To Excel  RFM  ${RFM_COUNTERS}  alias=${node}
    Collect Counters And Send To Excel  SM  ${SM_COUNTERS}  alias=${node}

    Log To Console  ${\n}Stopping TM1.1, please wait ...${\n}
    Stop Downlink NR TM1.1
    Stop Downlink LTE TM1.1

step4: Exit From TDS And Deactivate Feature

    Log To Console  ${\n}step4: Exit From TDS And Deactivate Feature${\n}

    Log To Console  Site resetting, please wait !${\n}
    admin.Reset Site  timeout=600  alias=${node}

    Log To Console  Waiting for onAir state, please wait !
    ${bts_onair_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  10 min  20 s  Check Required Mrbts State  OnAir  alias=${node}

    ${cells_onair_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  6 min  10 s  Check If All Cells Are onAir  alias=${node}

    Run Keyword If  '${bts_onair_status}'=='True' and '${cells_onair_status}'=='True'
    ...  Log to console  BTS is onAir after Site Reset !${\n}
    ...  ELSE  Run Keywords  Log to console  BTS is NOT onAir after Site Reset, set test failed !${\n}
    ...  AND  Append To List  ${ERRORS_LIST}  BTS is NOT onAir after Site Reset ( NO KPI IMPACT )
    ...  AND  Run Keyword And Continue On Failure  Fail  BTS is NOT onAir after Site Reset, set test fail !

    Parameters Recommissioning For Power Meter  false  disabled  alias=${node}

    Sleep  60s

TC Setup
    admin.Setup Admin  bts_host=${BTS_MPLANE_IP}  admin_api_log_dir=${OUTPUT_DIR}/AdminAPI_logs

TC Teardown
    ${kpi_name}  Evaluate
    ...  'Medium' if '${TM_OFFSET}' == '51' else 'Busy' if '${TM_OFFSET}' == '29' else '100% RF load (Max)'
    Send Main KPI To Excel  ${BTS_avg_per_h_offset_${TM_OFFSET}}  ${kpi_name}
    Run Keyword If  ${SNAPSHOT}  Run Keywords
    ...  Log To Console  Collecting snapshot on demand, please wait !${\n}
    ...  AND  admin.Collect Snapshot  ${PATH_TO_REPORT_FILE}/Snapshot_${TEST_NAME}.zip  timeout=1200  connection=${node}
    admin.Teardown Admin
