*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Test Cases CB008144-5G Improved 5G sleeping cell detection

Resource      resources/Resources.robot
Resource      taf/rfrl/bts/robot/logs_collecting.robot
Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library       DateTime
Variables     resources/multiple_bbmods_delta.py
Library       testsuite.Krakow.OAM.features.CB008144.resources.BBMOD_Reset.Bbmod_operations

Test Timeout  24 hours

Suite Setup         Suite Setup
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions With Watching Alarms
Test Teardown       Common Postconditions With Watching Alarms

*** Variables ***
@{nrcell-1} =  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-1
@{nrcell-2} =  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-2
@{all_nrcells}
...    MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-1
...    MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-2
@{bbmod-3} =  MRBTS-${tl.gnbs[0].global_bts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-3
@{bbmod-1} =  MRBTS-${tl.gnbs[0].global_bts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
@{additional_allowed_alarms}
...    Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
...    Baseband card autonomous reset as recovery action
...    No feedback signal
...    BTS site autonomous reset as recovery action
...    BTS Reset Cause
@{CUSTOM_ALLOWED_ALARMS}=    7312

${SEND_TRUCK_ROLL_EMAIL}         ${False}


*** Test Cases ***
CB008144-5G_24_Antenna_TX_power_Sleeping_cell_detection_on_gNB_with_multiple_BBMODs
    CB008144-5G_24 Preconditions
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actNrAutTxPwrSlCellDetRec
    ...  param_value=true
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  timeout=600
    Verify Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${nrcell-2}
    wait_until_alarm_is_active_on_configuration_objects
    ...  Baseband card autonomous reset as recovery action
    ...  ${bbmod-3}
    ...  interval=${15}
    ...  iterations=${24}
    Wait for BBMOD reset    bbmod_id=${bbmod-3_runtime_id}
    verify_cell_statuses    cell_id=1
    wait until keyword succeeds    6x    60s
    ...    verify_cell_statuses    cell_id=2    availability_status=degraded
    Verify Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${nrcell-2}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actNrAutTxPwrSlCellDetRec
    ...  param_value=false
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Not Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  timeout=120
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrTxPwrSlCellDetThr
    ...  param_value=150
    ...  skip_parameter_relation_errors=${true}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actNrAutTxPwrSlCellDetRec
    ...  param_value=true
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  timeout=600
    wait until keyword succeeds    3x    60s
    ...  Verify Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${all_nrcells}
    wait_until_alarm_is_active_on_configuration_objects
    ...  Baseband card autonomous reset as recovery action
    ...  ${bbmod-1}
    ...  interval=${15}
    ...  iterations=${24}
    Verify Alarm Is Not Active On Configuration Objects
    ...  Baseband card autonomous reset as recovery action
    ...  ${bbmod-3}
    Wait for BBMOD reset    bbmod_id=${bbmod-1_runtime_id}
    wait until keyword succeeds    6x    60s
    ...    verify_cell_statuses    cell_id=1    availability_status=degraded
    Verify Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${all_nrcells}
    Save gNB uptime
    Wait for gNB recovery action - autonomous reset
    Wait for site to be onair
    Verify gNB reboot since last saved uptime
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actNrAutTxPwrSlCellDetRec
    ...  param_value=false
    ...  skip_parameter_relation_errors=${true}
    Verify Alarm Is Not Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${all_nrcells}


CB008144-5G_26__Antenna_TX_power_manual_BBMOD_reset_after_Sleeping_Cell_detection_on_gNB_with_multiple_BBMODs
    CB008144-5G_26 Preconditions
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actNrAutTxPwrSlCellDetRec
    ...  param_value=true
    ...  skip_parameter_relation_errors=${true}
    Wait until Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${all_nrcells}
    ...  interval=${15}
    ...  iterations=${40}
    gnbbbu.Reset BBMOD  bbmod_id=${bbmod-3_runtime_id_int}
    wait until keyword succeeds    6x    60s
    ...    verify_cell_statuses    cell_id=2
    wait_until_alarm_is_active_on_configuration_objects
    ...  Baseband card autonomous reset as recovery action
    ...  ${bbmod-1}
    ...  interval=${15}
    ...  iterations=${24}
    Wait for BBMOD reset    bbmod_id=${bbmod-1_runtime_id}
    wait until keyword succeeds    24x    15s
    ...    verify_cell_statuses    cell_id=1    availability_status=degraded
    Verify Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${nrcell-1}
    Wait until Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${nrcell-2}
    ...  interval=${15}
    ...  iterations=${16}
    wait_until_alarm_is_active_on_configuration_objects
    ...  Baseband card autonomous reset as recovery action
    ...  ${bbmod-3}
    ...  interval=${15}
    ...  iterations=${24}
    Wait for BBMOD reset    bbmod_id=${bbmod-3_runtime_id}
    wait until keyword succeeds    12x    30s
    ...    verify_cell_statuses    cell_id=2    availability_status=degraded
    Verify Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${nrcell-2}
    Save gNB uptime
    Wait for gNB recovery action - autonomous reset
    Wait for site to be onair
    Verify gNB reboot since last saved uptime
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actNrAutTxPwrSlCellDetRec
    ...  param_value=false
    ...  skip_parameter_relation_errors=${true}
    Verify Alarm Is Not Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${all_nrcells}



CB008144-5G_27__Antenna_TX_power_Manual_cell_lock_unlock_procedure_during_Sleeping_Cell_detection_procedure
    CB008144-5G_27 Preconditions
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actNrAutTxPwrSlCellDetRec
    ...  param_value=true
    ...  skip_parameter_relation_errors=${true}
    sleep    240
    gnbcell.Block Cell    cell_id=${1}    timeout=${120}
    gnbcell.Unblock Cell    cell_id=${1}    timeout=${120}
    wait until keyword succeeds    6x    60s
    ...    verify_cell_statuses    cell_id=1    availability_status=online
    Wait until Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${nrcell-2}
    ...  interval=${15}
    ...  iterations=${16}
    sleep    120
    gnbcell.Block Cell    cell_id=${2}    timeout=${120}
    gnbcell.Unblock Cell    cell_id=${2}    timeout=${120}
    wait until keyword succeeds    6x    60s
    ...    verify_cell_statuses    cell_id=2    availability_status=online
    Verify Alarm Is Not Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${nrcell-2}
    wait_until_alarm_is_active_on_configuration_objects
    ...  Baseband card autonomous reset as recovery action
    ...  ${bbmod-1}
    ...  interval=${15}
    ...  iterations=${24}
    Wait until Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${nrcell-1}
    ...  interval=${15}
    ...  iterations=${24}
#    Wait until Alarm Is Active On Configuration Objects
#    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
#    ...  ${nrcell-2}
#    ...  interval=${15}
#    ...  iterations=${24}
    Wait for BBMOD reset    bbmod_id=${bbmod-1_runtime_id}
    wait_until_alarm_is_active_on_configuration_objects
    ...  Baseband card autonomous reset as recovery action
    ...  ${bbmod-3}
    ...  interval=${15}
    ...  iterations=${20}
    Wait for BBMOD reset    bbmod_id=${bbmod-3_runtime_id}
    wait until keyword succeeds    4x    60s
    ...    verify_cell_statuses    cell_id=1    availability_status=degraded
    Verify Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${nrcell-1}
    gnbcell.Block Cell    cell_id=${1}    timeout=${60}
    gnbcell.Unblock Cell    cell_id=${1}    timeout=${60}
    wait until keyword succeeds    8x    60s
    ...    verify_cell_statuses    cell_id=1    availability_status=online
    Verify Alarm Is Not Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${nrcell-1}
    wait until keyword succeeds    8x    60s
    ...    verify_cell_statuses    cell_id=2    availability_status=degraded
    Verify Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${nrcell-2}
    Wait until Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${nrcell-1}
    ...  interval=${15}
    ...  iterations=${20}
    Save gNB uptime
    Wait for gNB recovery action - autonomous reset
    sleep    120
    Wait for site to be onair
    Verify gNB reboot since last saved uptime
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actNrAutTxPwrSlCellDetRec
    ...  param_value=false
    ...  skip_parameter_relation_errors=${true}
    Verify Alarm Is Not Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${all_nrcells}

CB008144-5G_25__Antenna_TX_power_manual_BBMOD_reset_after_Sleeping_Cell_detection
    CB008144-5G_25 Preconditions
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actNrAutTxPwrSlCellDetRec
    ...  param_value=true
    ...  skip_parameter_relation_errors=${true}
    Wait until Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${nrcell-1}
    ...  interval=${2}
    ...  iterations=${270}
    sleep    100
    gnbbbu.Reset BBMOD  bbmod_id=${bbmod-1_runtime_id_int}
    wait until keyword succeeds    6x    60s
    ...    verify_cell_statuses    cell_id=1
    Wait until Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${nrcell-1}
    ...  interval=${2}
    ...  iterations=${270}
    sleep    130
    Save gNB uptime
    run keyword and expect error
    ...    AdminApiProcedureTimeoutException:*
    ...    reset_bbmod_with_timeout    bbmod_id=${bbmod-1_runtime_id_int}    timeout=60
    Wait for gNB recovery action - autonomous reset
    wait until keyword succeeds    6x    60s
    ...    verify_cell_statuses    cell_id=1
    Wait for site to be onair
    Verify gNB reboot since last saved uptime
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actNrAutTxPwrSlCellDetRec
    ...  param_value=false
    ...  skip_parameter_relation_errors=${true}


*** Keywords ***
CB008144-5G_24 Preconditions
    Perform Delta Commissioning On gNB    ${tc_24_preconditions_delta}

CB008144-5G_26 Preconditions
    perform_full_commissioning_on_classical_gnb  prefix_tag=CB008144
    Wait for site to be onair
    Perform Delta Commissioning On gNB    ${tc_26_preconditions_delta}

CB008144-5G_27 Preconditions
    Perform Delta Commissioning On gNB    ${tc_27_preconditions_delta}

CB008144-5G_25 Preconditions
    perform_full_commissioning_on_classical_gnb  prefix_tag=CB008144_one_bbmod
    Wait for site to be onair
    Perform Delta Commissioning On gNB    ${tc_25_preconditions_delta}

Wait for BBMOD reset
    [Arguments]    ${bbmod_id}
    ${output}=  Run Keyword And Ignore Error  wait until keyword succeeds    30    2
    ...  Verify BBMOD Statuses
    ...  disabled  not initialized  offline  unlocked        bbmod_id=${bbmod_id}
    log to console   ${output}
    ${contains}=    Run Keyword And Return Status    Should Contain    ${output}[1]  initializing
    Run keyword if  '${output}[0]' != 'PASS' and ${contains} == True
    ...  Log       BBMOD proceduralStatus: initializing.    WARN
    ...  ELSE IF  '${output}[0]' != 'PASS' and ${contains} == False
    ...  Fail      ${output}[1]

Suite Setup
    gnbbbu.upload_swconfig    sw_config_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
    Common Suite Setup With Commissioning    prefix_tag=CB008144
    Prepare BBMOD varaiables

Prepare BBMOD varaiables
    ${bbmod-3_runtime_id} =   get_bbmod_runtime_id    3
    ${bbmod-3_runtime_id_int} =   Convert To Integer    ${bbmod-3_runtime_id}
    ${bbmod-1_runtime_id} =   get_bbmod_runtime_id    1
    ${bbmod-1_runtime_id_int} =   Convert To Integer    ${bbmod-1_runtime_id}
    set suite variable    ${bbmod-3_runtime_id}
    set suite variable    ${bbmod-3_runtime_id_int}
    set suite variable    ${bbmod-1_runtime_id}
    set suite variable    ${bbmod-1_runtime_id_int}
