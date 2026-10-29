*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010588
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/bts/robot/gnb.robot
Resource     ./resources/common_keywords.robot
Resource     taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource     testsuite/Krakow/resources/RAN_VRF_KRK5/robot/call_procedure/call_procedure_keywords.robot

Library      taf.ue     WITH NAME   ue

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/common_variables.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
Suite Teardown    Common Suite Teardown

*** Variables ***
@{CellIDs_1}      NRCELL-1     NRCELL-2     NRCELL-3     NRCELL-4     NRCELL-5     NRCELL-6     NRCELL-7     NRCELL-8
...               NRCELL-9     NRCELL-10
@{CellIDs_2}      NRCELL-11     NRCELL-5     NRCELL-6     NRCELL-7     NRCELL-8     NRCELL-9     NRCELL-10
@{CellIDs_3}      NRCELL-1     NRCELL-2     NRCELL-3     NRCELL-4     NRCELL-22
@{CellIDs_4}      NRCELL-11     NRCELL-22

${ue_capabilities}      REAL_UE

*** Test Cases ***
[1][1.0] CB010588_General_SiSo_Cell_block_and_unblock
    [Setup]    Actions before test With Checking Configuration and Changing It If Needed
    ...        correct_config=7-7-UTE5GCLOUDT4SK112_CB010588_H4_2_config_1
    ...        alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Cell_block_unblock]
    ${traffic_matrix}    Convert To Dictionary    ${TPUT_MATRIX}
    Call To Selected Cells    cells_list=${CellIDs_1}    duration=120s    traffic_matrix=${traffic_matrix}
    ...                       ue_capabilities=${ue_capabilities}    deviation=20%    reboot_ue=${False}
    General SiSo Cell block and unblock
    Call To Selected Cells    cells_list=${CellIDs_1}    duration=120s    traffic_matrix=${traffic_matrix}
    ...                       ue_capabilities=${ue_capabilities}    deviation=20%    run_num=2    reboot_ue=${False}
    [Teardown]    Actions after test

[1][1.0] CB010588_Manual_SiSo_CALL_L3_data_call
    [Setup]    Actions before test With Checking Configuration and Changing It If Needed
    ...        correct_config=7-7-UTE5GCLOUDT4SK112_CB010588_H4_2_config_1
    ${traffic_matrix}    Convert To Dictionary    ${TPUT_MATRIX}
    Call To Selected Cells    cells_list=${CellIDs_1}    duration=420s    traffic_matrix=${traffic_matrix}
    ...                       ue_capabilities=${ue_capabilities}    deviation=5%    reboot_ue=${False}
    [Teardown]    Actions after test

[1][1.0] CB010588_NRTDD_CPRI_super_cell_NR_TDD_eCPRI_normal_cell_L3_call
    [Setup]    Actions before test With Checking Configuration and Changing It If Needed
    ...        prefix_tag=CPRI_supercell_eCPRI_normal     correct_config=7-7-UTE5GCLOUDT4SK112_CB010588_H4_2_config_2
    ${traffic_matrix}    Convert To Dictionary    ${TPUT_MATRIX}
    Call To Selected Cells    cells_list=${CellIDs_2}    duration=480s    traffic_matrix=${traffic_matrix}
    ...                       ue_capabilities=${ue_capabilities}    deviation=5%    reboot_ue=${False}
    [Teardown]    Actions after test

[1][1.0] CB010588_NRTDD_CPRI_normal_cell_NR_TDD_eCPRI_super_cell_L3_call
    [Setup]    Actions before test With Checking Configuration and Changing It If Needed
    ...        prefix_tag=CPRI_normal_eCPRI_supercell     correct_config=7-7-UTE5GCLOUDT4SK112_CB010588_H4_2_config_3
    ${traffic_matrix}    Convert To Dictionary    ${TPUT_MATRIX}
    Call To Selected Cells    cells_list=${CellIDs_3}    duration=360s    traffic_matrix=${traffic_matrix}
    ...                       ue_capabilities=${ue_capabilities}    deviation=5%    reboot_ue=${False}
    [Teardown]    Actions after test

[1][1.0] CB010588_NRTDD_CPRI_super_cell_NR_TDD_eCPRI_super_cell_L3_call
    [Setup]    Actions before test With Checking Configuration and Changing It If Needed
    ...        prefix_tag=CPRI_supercell_eCPRI_supercell     correct_config=7-7-UTE5GCLOUDT4SK112_CB010588_H4_2_config_4
    ${traffic_matrix}    Convert To Dictionary    ${TPUT_MATRIX}
    Call To Selected Cells    cells_list=${CellIDs_4}    duration=120s    traffic_matrix=${traffic_matrix}
    ...                       ue_capabilities=${ue_capabilities}    deviation=5%    reboot_ue=${False}
    [Teardown]    Actions after test
