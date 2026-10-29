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
Suite Teardown      Suite Teardown
Test Setup          Common Preconditions With Watching Alarms
Test Teardown       Common Postconditions With Watching Alarms

*** Variables ***
@{additional_allowed_alarms}
...    Sleeping Cell Detection Due To Degraded RACH Setup Attempts
...    No feedback signal
...    BTS site autonomous reset as recovery action
...    NgGnbInitFullReset
...    BTS Reset Cause
...    No X2 link available
${SEND_TRUCK_ROLL_EMAIL}         ${False}
@{nrcell-1010}  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-1010
@{nrcell-1020}  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-1010
@{nrcell-1030}  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-1010
&{notEnergySaving}    energySavingState=notEnergySaving
&{reducedEnergySaving}    energySavingState=reducedEnergySaving
&{energySavingState_notEnergySaving_cell1010}  MRBTS-${global_bts_id}/NRBTS-${global_bts_id}/NRCELL-1010=${notEnergySaving}
&{energySavingState_reducedEnergySaving_cell1010}  MRBTS-${global_bts_id}/NRBTS-${global_bts_id}/NRCELL-1010=${reducedEnergySaving}
&{energySavingState_notEnergySaving_cell1020}  MRBTS-${global_bts_id}/NRBTS-${global_bts_id}/NRCELL-1020=${notEnergySaving}
&{energySavingState_reducedEnergySaving_cell1020}  MRBTS-${global_bts_id}/NRBTS-${global_bts_id}/NRCELL-1020=${reducedEnergySaving}
&{energySavingState_notEnergySaving_cell1030}  MRBTS-${global_bts_id}/NRBTS-${global_bts_id}/NRCELL-1030=${notEnergySaving}
&{energySavingState_reducedEnergySaving_cell1030}  MRBTS-${global_bts_id}/NRBTS-${global_bts_id}/NRCELL-1030=${reducedEnergySaving}


*** Test Cases ***
CB008144-5G_28_Sleeping_cell_detected_in_reducedEnergySaving_state_interaction_with_CB008133
    Perform Full Commissioning and Wait for onAir    prefix_tag=CB008144
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/NRBTS-${global_bts_id}
    ...  param_name=actNrLBmMimoRTXPowerSaving
    ...  param_value=true
    ...  skip_parameter_relation_errors=${true}
    ...  timeout=${300}
    Wait for onAir on all DUs
    gnbbbu.verify_configuration_parameters_values    param_dict=${energySavingState_notEnergySaving_cell1010}
    gnbbbu.verify_configuration_parameters_values    param_dict=${energySavingState_notEnergySaving_cell1020}
    gnbbbu.verify_configuration_parameters_values    param_dict=${energySavingState_notEnergySaving_cell1030}
    sleep    90
    gnbbbu.verify_configuration_parameters_values    param_dict=${energySavingState_reducedEnergySaving_cell1010}
    gnbbbu.verify_configuration_parameters_values    param_dict=${energySavingState_reducedEnergySaving_cell1020}
    gnbbbu.verify_configuration_parameters_values    param_dict=${energySavingState_reducedEnergySaving_cell1030}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actNrAutCntRachStpSlCellDetRec
    ...  param_value=true
    ...  skip_parameter_relation_errors=${true}
    Wait until Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Degraded RACH Setup Attempts
    ...  ${nrcell-1010}
    ...  interval=${15}
    ...  iterations=${30}
    Wait until Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Degraded RACH Setup Attempts
    ...  ${nrcell-1020}
    ...  interval=${15}
    ...  iterations=${4}
    Wait until Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Degraded RACH Setup Attempts
    ...  ${nrcell-1030}
    ...  interval=${15}
    ...  iterations=${4}
    Save gNB uptime
    Wait for gNB recovery action - autonomous reset
    sleep    120
#    Wait for site to be onair
#    verify_cell_statuses    cell_id=1010    availability_status=online
#    verify_cell_statuses    cell_id=1020    availability_status=online
#    verify_cell_statuses    cell_id=1030    availability_status=online
    wait until keyword succeeds    15x     30sec
    ...    gnbcell.verify_all_cells_are_onair
    Verify gNB reboot since last saved uptime
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actNrAutCntRachStpSlCellDetRec
    ...  param_value=false
    ...  skip_parameter_relation_errors=${true}
    ...  timeout=${300}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/NRBTS-${global_bts_id}
    ...  param_name=actNrLBmMimoRTXPowerSaving
    ...  param_value=false
    ...  skip_parameter_relation_errors=${true}
    ...  timeout=${300}

*** Keywords ***
Suite Setup
    gnbbbu.Upload SWconfig    sw_config_path=${CURDIR}/resources/swconfig.txt
    Perform Full Commissioning on Classical gNB    update_timeout=${3600}    prefix_tag=CB008144
    Wait for onAir on all DUs
    Common Suite Setup

Suite Teardown
    Common Suite Teardown
