*** Settings ***
Documentation
...   Test suite for regression testing of feature CB006020-D
...   author: Radoslaw Serafin
...   contact: radoslaw.serafin@nokia.com


Library     taf.sw.reporting_portal
Library     taf.rfrl.common_resources.oam_kpi.report_oam_kpi
Library     taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner
Resource    ./resources/keywords.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_gNB_Site_Reset_From_WebUI.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               prefix_tag=CB006020
...               increase_timeout_for_update_sw=${1800}
...               increase_time_for_checking_radios=${1800}
...               list_of_additional_allowed_alarms=${PREP_ALLOWED_ALARMS}
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms and Restore Configuration If Test Failed


*** Variables ***
${COLLECT_LOGS_DURING_DATA_TRANSFER}    False
${ENABLE_RACH_OBSERVER}                 False
@{GNB_RESET_ALLOWED_ALARMS}             No X2 link available for a specific LTEENB    No X2 link available
@{PREP_ALLOWED_ALARMS}                  BTS configuration error (not enough HW for LCR)
@{CUSTOM_ALLOWED_ALARMS}                User Account has Default Password

${runs_success_rate}    100
${main_ru_id}    1
${extension_ru_id}    2

# tput variables for D test cases with 7 + 1 configuration
${duration}    180s
${main_tput_dl}     3780 Mbits/sec
${main_tput_ul}     250 Mbits/sec
${ext_tput_dl}     540 Mbits/sec
${ext_tput_ul}     125 Mbits/sec

# common tput variables
${deviation}     25%
${protocol}    tcp
${reboot_ue}    True
${timeout_reboot_ue}    100


*** Test Cases ***
[1][1.0] General_SiSo_Auto_gNB_Site_Reset_From_WebUI
    [Timeout]    20h

    Allow Alarm         ${GNB_RESET_ALLOWED_ALARMS}
    General SiSo Auto gNB Site Reset From WebUI
    Disallow Alarm      ${GNB_RESET_ALLOWED_ALARMS}

[1][1.0] OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI
    [Setup]    Common Preconditions

    Set Test Variable    &{target_CB006020}    kpi51a=240  kpi51b=240
    Set Test Variable    &{additional_allowed_alarm}    fault_id=4592  fault_name=BTS Reset Cause
    Set Test Variable    @{additional_allowed_alarms}    &{additional_allowed_alarm}

    ${results}    Run Reset Rmod in Loop
    ...                                     iterations=${runs_success_rate}
    ...                                     target=${target_CB006020}
    ...                                     report_to_rep=${True}
    ...                                     additional_allowed_alarms=${additional_allowed_alarms}

    [Teardown]    Common Postconditions With Restore Configuration If Test Failed

