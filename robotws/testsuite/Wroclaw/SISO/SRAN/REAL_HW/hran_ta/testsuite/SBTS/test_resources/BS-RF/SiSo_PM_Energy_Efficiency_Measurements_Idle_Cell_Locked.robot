*** Settings ***
Documentation
...  TC for feature: 5GC000433-A-SyVe - Embedded Power Meter for Energy Efficiency

#Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Resource    ../../../../resources/ca_BSRF_Energy_Efficiency.robot

Library    taf.sbts.oam.coam.admin  WITH NAME  admin

*** Variables ***

${INTERVAL}  15  # for parameter: mtBtsEnergyMonitoring. Please enter only the number. Available intervals in minutes: 15,30,60,360,720,1440
${INTERVAL_AMOUNT}  1
${SNAPSHOT}  False
${node}  default

*** Keywords ***
TC__SiSo_PM_Energy_Efficiency_Measurements_Idle_Cell_Locked
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-17657
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  TC for feature: CB008962-SR-F-ST2 Energy Efficiency
    ...  The purpose of this Test Case is to gather EEM counters.
    ...  Power Meter is capable of measure power consumption (DC voltage and amperage) in RFM, SM and whole BTS.
    ...  Counters are collecting when LTE and NR cells are locked.
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

    Step1: Preconditions with Cells Lock
    Step2: Lock Cells And Wait For Counters
    Step3: Collect PM Counters
    Step4: Unlock Cells And Deactivate Energy Efficiency Feature

    [Teardown]  Run Keywords  Log to console  TC finished. Result = ${KEYWORD STATUS}
    ...  AND  Set Suite Variable  ${KEYWORD STATUS}

Step1: Preconditions with Cells Lock

    Log To Console  Step1: Preconditions with Cells Lock${\n}

    ${errors_list}  Create List
    Set Test Variable  ${SBTS_COUNTERS}  M40002C0,M40002C1,M40002C2
    Set Test Variable  ${RFM_COUNTERS}   M40003C0,M40003C1,M40003C2,M40003C3,M40003C4,M40003C5
    Set Test Variable  ${SM_COUNTERS}    M40004C0,M40004C1,M40004C2,M40004C3,M40004C4,M40004C5
    Set Test Variable  ${ERRORS_LIST}
    Set Test Variable  ${BTS_avg_per_h_idle}  ${0}

    ${bts_params}  admin.Get parameters for all  BTS  alias=${node}
    Set Test Variable  ${BTS_ID}  ${bts_params[0].btsId}

    Set Test Variable  ${object_variable_actPowerMeter}  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    Set Test Variable  ${object_variable_mtBtsEnergyMonitoring}  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1

    Check Interval  ${INTERVAL}
    Log To Console  Test will collect PM counters for ${INTERVAL_AMOUNT} x ${INTERVAL}min !${\n}

    ${new_counters_path}    Check If Current Build Is Newer Than    SBTS24R2_ENB_9999_231220_000004
    Set Test Variable  ${NEW_COUNTERS_PATH}

    Log To Console  Site reset will be perform now, please wait !${\n}
    admin.Reset Site  timeout=600  alias=${node}

    ${bts_onair_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  10 min  20 s  Check Required Mrbts State  OnAir  alias=${node}

    ${cells_onair_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5 min  20 s  Check If All Cells Are onAir  alias=${node}

    Run Keyword If  '${bts_onair_status}'=='True' and '${cells_onair_status}'=='True'
    ...  Log to console  BTS is onAir after Site Reset !${\n}
    ...  ELSE  Run Keywords  Log to console  BTS is NOT onAir after Site Reset, set test failed !${\n}
    ...  AND  Append To List  ${ERRORS_LIST}  BTS is NOT onAir after Site Reset
    ...  AND  Fail  BTS is NOT onAir after Site Reset, set test fail !

    Parameters Recommissioning For Power Meter  true  ${INTERVAL}min  alias=${node}

    ${status}  Run Keyword And Return Status  Check Required Mrbts State  OnAir  alias=${node}
    Run Keyword If  '${status}'=='False'  Run Keywords
    ...  Parameters Recommissioning For Power Meter  false  disabled  alias=${node}
    ...  AND  Append To List  ${ERRORS_LIST}  BTS is NOT onAir after EEM feature activation
    ...  AND  Fail  Cells are not onAir after recommissioning! Feature deactivated and set test failed !
    ...  ELSE
    ...  Log to console  BTS is onAir after recommissioning, going to next step !${\n}

Step2: Lock Cells And Wait For Counters

    Log To Console  step2: Lock Cells And Wait For Counters${\n}

    Lock/Unlock AdministrativeState For Cells  Locked  alias=${node}

    ${nrcel_assert_status}  Run Keyword And Return Status
    ...  admin.Assert Every  NRCEL  administrativeState=regex"(?i)Locked"  alias=${node}
    ${lncel_assert_status}  Run Keyword And Return Status
    ...  admin.Assert Every  LNCEL  administrativeState=regex"(?i)Locked"  search_for_iot_cells=${True}  alias=${node}

    Run Keyword If  '${nrcel_assert_status}'!='True' or '${lncel_assert_status}'!='True'
    ...  Run Keywords
    ...  Log To Console
    ...  Assertion for administrativeState = locked for NRCEL and(or) LNCEL FAILED, feature deactivation, please wait !${\n}
    ...  AND  Lock/Unlock AdministrativeState For Cells  unlocked  alias=${node}
    ...  AND  Parameters Recommissioning For Power Meter  false  disabled  alias=${node}
    ...  AND  Append To List  ${ERRORS_LIST}  Locking for NRCEL and(or) LNCEL failed.
    ...  AND  Fail  Assertion for administrativeState = locked for NRCEL and(or) LNCEL FAILED.
    ...  ELSE
    ...  Log To Console  All NRCEL(s) and LNCEL(s) has administrativeState = locked !${\n}

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}  ${INTERVAL_AMOUNT}*${INTERVAL}
    Log To Console
    ...  Waiting for ${time_to_sleep} minutes to Get PM Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !${\n}
    Sleep  ${time_to_sleep} minutes


Step3: Collect PM Counters

    Log To Console  Step3: Collect PM Counters${\n}

    ${raw_sbts_counters}  admin.Get Pm Counters  ${SBTS_COUNTERS}  timeout=100s  alias=${node}

    ${SM_avg_per_h}  Get Average SBTS Counter Value  M40002C0  ${raw_sbts_counters}
    ${RM_avg_per_h}  Get Average SBTS Counter Value  M40002C1  ${raw_sbts_counters}
    ${BTS_avg_per_h_idle}  Get Average SBTS Counter Value  M40002C2  ${raw_sbts_counters}

    ${sbts_status}  Evaluate  (${SM_avg_per_h}+${RM_avg_per_h}) == ${BTS_avg_per_h_idle}
    Run Keyword If  ${sbts_status}
    ...  Log To Console  Average value of SM and RM counters is equal to SBTS counter !
    ...  ELSE
    ...  Run Keywords
    ...  Log To Console  Average value of SM and RM counters is NOT equal to SBTS counter ! Feature deactivation !
    ...  AND  Append To List  ${ERRORS_LIST}  Average value of SM and RM counters is NOT equal to SBTS counter
    ...  AND  Lock/Unlock AdministrativeState For Cells  Unlocked  alias=${node}
    ...  AND  Parameters Recommissioning For Power Meter  false  disabled  alias=${node}
    ...  AND  Run Keyword And Continue On Failure  Fail  Average value of SM and RM counters is NOT equal to SBTS counter !

    Log To Console  Main KPI value M40002C2: ${BTS_avg_per_h_idle}${\n}
    Set Test Variable  ${BTS_avg_per_h_idle}

    Collect Counters And Send To Excel  RFM  ${RFM_COUNTERS}  alias=${node}
    Collect Counters And Send To Excel  SM  ${SM_COUNTERS}  alias=${node}

step4: Unlock Cells And Deactivate Energy Efficiency Feature

    Log To Console  ${\n}step4: Unlock Cells And Deactivate Energy Efficiency Feature${\n}

    Lock/Unlock AdministrativeState For Cells  Unlocked  alias=${node}
    Parameters Recommissioning For Power Meter  false  disabled  alias=${node}

    ${status}  Run Keyword And Return Status  Check Required Mrbts State  OnAir  alias=${node}
    Run Keyword If  '${status}'=='False'  Run Keywords
    ...  Append To List  ${ERRORS_LIST}  After EEM deactivation cells are not onAir ( NO KPI IMPACT )
    ...  AND  Fail  BTS is not onAir after recommissioning! Feature deactivated and set test failed !
    ...  ELSE
    ...  Log to console  All cells are onAir !${\n}


TC Setup
    admin.Setup Admin  bts_host=${BTS_MPLANE_IP}  admin_api_log_dir=${OUTPUT_DIR}/AdminAPI_logs

TC Teardown
    Send Main KPI To Excel  ${BTS_avg_per_h_idle}  Idle
    Run Keyword If  ${SNAPSHOT}  Run Keywords
    ...  Log To Console  Collecting snapshot on demand, please wait !${\n}
    ...  AND  admin.Collect Snapshot  ${PATH_TO_REPORT_FILE}/Snapshot_${TEST_NAME}.zip  timeout=1200  connection=${node}
    admin.Teardown Admin
