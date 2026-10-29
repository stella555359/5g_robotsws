# @Time    : 2023/9/24 20:53
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB010498.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB010498-SR-D ABIQ NR FR1 TDD eCPRI configuration rules
...    Feature CB010498-SR-B ABIQ NR FR1 TDD eCPRI configuration rules

Suite Setup         SISO Coam Suite Setup
Suite Teardown      SISO Coam Suite Teardown
#Suite Teardown      Run Keywords    robot_common_operations.Common Case Teardown
#...                 AND    Connect to gnb coam via ssl
#...                 AND    COAM Commission with scf file    ${SCF_COMMON_WITH_ABIN_FEADEP}
#...                 is_pdl_checking_needed=${False}    timeout=900
#...                 AND    SISO Coam Suite Teardown
Test Setup          MMW5 Common Case Setup
Test Teardown       MMW5 Common Case Teardown
Force Tags          CRT_TRUNK    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot

*** Variables ***
${if_commissioning}                    False
${SCF_COMMON_WITH_ABIN_FEADEP}         ${CURDIR}/SCF_COMMON_WITH_ABIN_FeaDep.xml
${SCF_COMMON_WITH_ABIN}                ${CURDIR}/SCF_COMMON_WITH_ABIN.xml
${SCF_COMMON_WITHOUT_ABIN}             ${CURDIR}/SCF_COMMON_WITHOUT_ABIN.xml
${SCF_301}                             ${CURDIR}/SCF_301.xml
${BARRY_NR_CELLS}                      ${CURDIR}/BARRY_NR_CELLS.json
${BARRY_LTE_CELLS}                     ${CURDIR}/BARRY_LTE_CELLS.json
${NOT_BARRY_NRCELL_2}                  ${CURDIR}/NOT_BARRY_NRCELL_2.json
${NOT_BARRY_NRCELL_3}                  ${CURDIR}/NOT_BARRY_NRCELL_3.json
${NOT_BARRY_NRCELL_6}                  ${CURDIR}/NOT_BARRY_NRCELL_6.json

*** Test Cases ***
#[1][2.0] Manual_SiSo_SM_NR_RAT_reset
#    [Documentation]    Author: jian.1.chen@nokia-sbell.com
#    # Precondition
#    COAM Commission with scf file    ${SCF_COMMON_WITH_ABIN}    is_pdl_checking_needed=${False}    timeout=900
#    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
#
#    coam.perform_delta_recommissioning    delta_file=${BARRY_LTE_CELLS}
#    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
#    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#
#    Modify Parameter On ENB With Activate    dist_name=MRBTS-2032/LNBTS-10444/LNCEL-25
#    ...    parameter=administrativeState    value=locked
#
#    Manual_SiSo_SM_NR_RAT_reset_2.0

[1][2.0] General_SiSo_RF_module_power_reset
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    # Precondition
    COAM Commission with scf file    ${SCF_COMMON_WITH_ABIN}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State

    coam.perform_delta_recommissioning    delta_file=${BARRY_LTE_CELLS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

    Modify Parameter On ENB With Activate    dist_name=MRBTS-2032/LNBTS-10444/LNCEL-25
    ...    parameter=administrativeState    value=locked

    General_SiSo_RF_module_power_reset_2.0

[1][1.0] Manual_SiSo_CM_Recommissioning
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    # Precondition
    COAM Commission with scf file    ${SCF_COMMON_WITH_ABIN}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State

    coam.perform_delta_recommissioning    delta_file=${BARRY_LTE_CELLS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

    Modify Parameter On ENB With Activate    dist_name=MRBTS-2032/LNBTS-10444/LNCEL-25
    ...    parameter=administrativeState    value=locked

    Manual_SiSo_CM_Recommissioning_1.0

[1][2.0] Manual_SiSo_SM_BTS_Site_Reset
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    # Precondition
    AlarmWatchdog.add_allow_alarms    fault_id=6823
    AlarmWatchdog.add_allow_alarms    fault_id=6825
    AlarmWatchdog.add_allow_alarms    fault_id=6826
    COAM Commission with scf file    ${SCF_COMMON_WITH_ABIN}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State

    coam.perform_delta_recommissioning    delta_file=${BARRY_LTE_CELLS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

    Modify Parameter On ENB With Activate    dist_name=MRBTS-2032/LNBTS-10444/LNCEL-25
    ...    parameter=administrativeState    value=locked

    Manual_SiSo_SM_BTS_Site_Reset_2.0
    AlarmWatchdog.remove_allow_alarms    fault_id=6823
    AlarmWatchdog.remove_allow_alarms    fault_id=6825
    AlarmWatchdog.remove_allow_alarms    fault_id=6826

[1.0] Manual_SiSo_SM_LTE_cell_lock_unlock_(administrative_state_change)_from_GUI
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/10/17 14:08
    # Precondition, lock enb cell, barry nr cell
    AlarmWatchdog.add_allow_alarms    fault_id=6823
    AlarmWatchdog.add_allow_alarms    fault_id=6825
    AlarmWatchdog.add_allow_alarms    fault_id=6826
    COAM Commission with scf file    ${SCF_COMMON_WITH_ABIN}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State

    coam.perform_delta_recommissioning    delta_file=${BARRY_NR_CELLS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

    Modify Parameter On ENB With Activate    dist_name=MRBTS-2032/LNBTS-10444/LNCEL-25
    ...    parameter=administrativeState    value=locked

    Manual_SiSo_SM_LTE_cell_lock_unlock_administrative_state_change_from_GUI_1.0
    AlarmWatchdog.remove_allow_alarms    fault_id=6823
    AlarmWatchdog.remove_allow_alarms    fault_id=6825
    AlarmWatchdog.remove_allow_alarms    fault_id=6826
    # restore, unlock enb cell. never use LTE cell.
    #Modify Parameter On ENB With Activate    dist_name=MRBTS-2032/LNBTS-10444/LNCEL-25
    #...    parameter=administrativeState    value=unlocked


CB010498-5G-B_301_E2E_system_setup_with L3 call verified
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/10/23 14:10
    [Tags]    301
    # Precondition, lock enb cell, barry nr cell
    COAM Commission with scf file    ${SCF_301}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online

    # Step 1: tcp on AEHC cell 2
    UE Attach And Check Single Cell TCP Throughput    global_cell_id=1
    ...    ul_tp_threshold=5    dl_tp_threshold=10    attach_mode=SA


[1][2.1] General_SiSo_Cell_block_and_unblock
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    COAM Commission with scf file    ${SCF_COMMON_WITHOUT_ABIN}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online

    AlarmWatchdog.add_allow_alarms    fault_id=49
    General_SiSo_Cell_block_and_unblock_2.1
    AlarmWatchdog.remove_allow_alarms    fault_id=49
