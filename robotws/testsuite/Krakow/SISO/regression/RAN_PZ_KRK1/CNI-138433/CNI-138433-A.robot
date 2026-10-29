*** Settings ***
Documentation
...   Test suite for regression testing of feature CNI-138433
...   author: Radoslaw Serafin, Agnieszka Bylica, Julia Luszcz
...   author/contact: radoslaw.serafin@nokia.com, agnieszka.bylica@nokia.com, julia.luszcz@nokia.com


Library     ../resources/python/common.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../resources/robot/common.robot
Resource    ../resources/robot/tput.robot
Resource    ../resources/rjio_procedures/Manual_SiSo_SM_NR_RAT_reset.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./resources/variables.py
Variables   ../resources/python/variables.py


Force Tags    CA_VRF_KRK

Suite Setup       Run Keywords    Common Suite Setup With OnAir Test Line Preparation
...                               prefix_tag=${prefix_tag}
...                               increase_timeout_for_update_sw=${1800}
...                               increase_time_for_checking_radios=${1800}
...                               AND
...                               load_ru_matrix    ${prefix_tag_L3_call}
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords    Common Preconditions With Watching Alarms     AND
...               Reconfigure DL MIMO Mode 8x4   operation=disable    delta_template=${delta_dlmimomode_template}
...               nrcellids=${nrcellids_to_reconfiguring_dlmimomode_A}
Test Teardown     Run Keywords    Reconfigure DL MIMO Mode 8x4   operation=enable    delta_template=${delta_dlmimomode_template}
...               nrcellids=${nrcellids_to_reconfiguring_dlmimomode_B}     AND
...               Common Postconditions With Watching Alarms and Restore Configuration If Test Failed


*** Variables ***
# ${prefix_tag} requires setting of CONFIGURATION variable e.g.: -v CONFIGURATION:Krakow.7_7_UTE5GCLOUDT8SK134
${prefix_tag}                           CNI-138433-A
${prefix_tag_L3_call}                   CNI-138433-A_L3_call
# ${current_config} to remove after TL preparation added; to skip commissioning set equal to ${prefix_tag}
${current_config}                       ${None}
${BTS_startup_time}                     ${600}

#tput
${reboot_ue}                            False
${capabilities}                         REAL_UE
${duration}                             180s
${parallel_streams_dl}                  4
${parallel_streams_ul}                  4
${size_packet}                          1400B
${deviation}                            20%
${size_packet_dl}                       1400B
${size_packet_ul}                       1400B
${interval}                             1
${omit}                                 5
${alias}                                UE
${COLLECT_LOGS_DURING_DATA_TRANSFER}    False
${ENABLE_RACH_OBSERVER}  False
#attach
${timeout_reboot_ue}                    100
#rf switch
${RFS_ALIAS}                            Matrix
${RF_VENDOR}                            RFLIGHT
${RF_IP}                                10.255.27.56
${RF_MODEL}                             NT-4X64NS


*** Test Cases ***
[1][1.0] CNI-138433-A_Manual_SiSo_SM_NR_RAT_reset
    [Timeout]    20h

    Manual_SiSo_SM_NR_RAT_reset    rat_startup_time=${BTS_startup_time}
    ...                            is_actRatResetEnhancement_frozen=True
