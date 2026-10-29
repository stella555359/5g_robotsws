*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Test Cases CB008144-5G Improved 5G sleeping cell detection

Resource      ../../../features/CB008144/resources/Resources.robot
Resource      taf/rfrl/bts/robot/logs_collecting.robot
Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables     resources/counter_dict.py
Library       DateTime
Library       ./resources/time_keywords.py

Test Timeout  24 hours

Suite Setup         CB0010575 Setup
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions With Watching Alarms
Test Teardown       Common Postconditions With Watching Alarms

*** Variables ***
@{additional_allowed_alarms}
...    Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
...    Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurements
...    Baseband card autonomous reset as recovery action
...    No feedback signal
...    BTS site autonomous reset as recovery action
...    Setup of X2 connectivity to gNB failed
...    NgGnbInitFullReset
...    BTS Reset Cause
${global_bts_id} =  ${tl.gnbs[0].global_bts_id}
@{TC_19_expected_cells_without_alarm} =
...  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-5
...  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-6
@{TC_1_expected_cells_without_alarm} =  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-5
...  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-6
@{TC_1_expected_rmods_without_alarm} =  MRBTS-${tl.gnbs[0].global_bts_id}/EQM-1/APEQM-1/RMOD-1
...  MRBTS-${tl.gnbs[0].global_bts_id}/EQM-1/APEQM-1/RMOD-4

*** Test Cases ***
019_CB007043_Sleeping Cell Detection and Recovery Maintenance Window
    ${TimeStart} =  prepare_window_time    hours_shift=${-1}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=slCellDetRecMaintWindowSchedTimeStart
    ...  param_value=${TimeStart}
    ...  skip_parameter_relation_errors=${true}
    ${EndStart} =  prepare_window_time    hours_shift=${2}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=slCellDetRecMaintWindowSchedTimeEnd
    ...  param_value=${EndStart}
    ...  skip_parameter_relation_errors=${true}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrRxPwrSlCellDetLowPwrThrAnt
    ...  param_value=1789
    ...  skip_parameter_relation_errors=${true}
    ${StartTime}=  Get Current Date  result_format=%M:%S
    Save gNB uptime
    Check if BBMOD did not reset      timeout=10 min
    Verify Alarm Is Not In Alarm History
    ...  Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurement
    ...  ${TC_19_expected_cells_without_alarm}
    Verify no gNB reboot since last saved uptime
    Wait for next PM period if needed  ${StartTime}
    Verify PM Counters Not Incremented  ${counter_dict_19_1}
    gnb_counter.Wait for next PM period
    ${TimeStart} =  prepare_window_time    hours_shift=${2}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=slCellDetRecMaintWindowSchedTimeStart
    ...  param_value=${TimeStart}
    ...  skip_parameter_relation_errors=${true}
    ${EndStart} =  prepare_window_time    hours_shift=${-2}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=slCellDetRecMaintWindowSchedTimeEnd
    ...  param_value=${EndStart}
    ...  skip_parameter_relation_errors=${true}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrRxPwrSlCellDetLowPwrThrAnt
    ...  param_value=900
    ...  skip_parameter_relation_errors=${true}

    Wait Until Alarm Is Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurements
    ...  timeout=420
    ${StartTime}=  Get Current Date  result_format=%M:%S
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=Baseband card autonomous reset as recovery action
    ...  timeout=300
    Wait for BBMOD reset
    Wait for next PM period if needed  ${StartTime}
    Verify PM Counters Incremented  ${counter_dict_19_2}
    Verify PM Counters Not Incremented  ${counter_dict_19_3}
    Wait Until Keyword Succeeds  2 min  15 sec  Verify BBMOD is up and running
    Verify gNB is onAir

    Wait Until Alarm Is Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurements
    ...  timeout=300
    Save gNB uptime
    Wait for gNB recovery action - autonomous reset
    Wait for site to be onair
    Verify gNB reboot since last saved uptime
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrRxPwrSlCellDetLowPwrThrAnt
    ...  param_value=400
    ...  skip_parameter_relation_errors=${true}
    ${StartTime}=  Get Current Date  result_format=%M:%S
    Run Keyword And Expect Error
    ...  ExecutionException*Alarm*is not active*
    ...  Wait Until Alarm Is Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurement
    ...  timeout=300
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actNrAutRxPwrSlCellDetRec
    ...  param_value=false
    ...  skip_parameter_relation_errors=${true}
    Wait for next PM period if needed  ${StartTime}
    Verify One Of PM Counters Incremented  ${counter_dict_19_3}
    Verify PM Counters Not Incremented  ${counter_dict_19_2}

CB008144-5G_1_Antenna_RX_power_sleeping_cell_detected_all_recovery_phases
    CB008144-5G_1_Antenna_RX_power_sleeping_cell_detected_all_recovery_phases

CB008144-5G_7_Antenna_RX_power_sleeping_cell_detected_limit_of_recovery_actions
    CB008144-5G_7_Antenna_RX_power_sleeping_cell_detected_limit_of_recovery_actions

*** Keywords ***
CB0010575 Setup
    gnbbbu.Upload SWconfig    sw_config_path=${CURDIR}/resources/swconfig.txt
    Common Suite Setup With Commissioning    prefix_tag=CB010575
    Go To State FCT
