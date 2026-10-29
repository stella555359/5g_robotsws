*** Settings ***
Documentation    This is for CB009359 keywords
...              Author: Gao melinda
...              Contact: melinda.gao@nokia-sbell.com
...              squad: 5G_PZ_HZ_8_SG

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
#Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Library      ../TestData/variables_CB009359.py
Variables    ../TestData/variables_CB009359.py

*** Variables ***
@{cell_1}    ${1}
@{cell_2}    ${2}
@{cell_1_2}    ${1}  ${2}
*** Keywords ***
case_preparion_commision_8DL8UL_SCF
    log to console    start commission CB009359 8DL8UL SCF...
    ${SCF_CB009359_8DL8UL}    Replace String    ${Golden_SCF_Path}    .xml    _8DL8UL.xml
    COAM Commission with scf file    scf_file_path=${SCF_CB009359_8DL8UL}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair

General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_muMIMO
    case_preparion_commision_8DL8UL_SCF
    data_transfer_common    tput_self_define=${tput_define_8DL8UL_100M}    cell_id=${cell_2}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=${0.5}    min_percent=${0.3}    tput_from=self_define
#    data_transfer_common    tput_self_define=${tput_define_8DL8UL_100M}    cell_id=${cell_2}    loop_times=${1}    duration=${300}
#    ...    target_avg_percent=${0.95}    min_percent=${0.85}

CB009359_General_SiSo_Cell_block_and_unblock
    case_preparion_commision_8DL8UL_SCF
    General_SISO_Cell_Block_Unblock_SG08    tput_self_define=${tput_define_8DL8UL_100M}    Max_loop=${10}    target_avg_percent=0.3
    ...    min_percent=0.2    duration=${300}