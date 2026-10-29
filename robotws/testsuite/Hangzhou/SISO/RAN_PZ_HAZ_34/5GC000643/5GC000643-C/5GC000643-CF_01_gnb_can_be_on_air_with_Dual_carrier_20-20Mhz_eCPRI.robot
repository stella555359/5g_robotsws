*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup
Test Teardown
Test Timeout         100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_gnb_can_be_on_air_with_Given_Information.robot

Documentation
...    Author: Annie hu
...    Contact: Annie.hu@nokia-sbell.com
...    squad group:SG_05
...    Feature 5GC000643-CF in 5G21A program
...    Configurtion:1S-2CC-4DL-2UL for ASIK+ABIL+AEQE eCPRI

Force Tags            5G_RAN_TDD
...    PY39

*** Variables ***

*** Test Cases ***
[1]5GC000643-CF_01_gnb_can_be_on_air_with_Dual_carrier_20+20Mhz_eCPRI
    [Tags]    1S-2CC_for_CIT    CIT_TRUNK    CRT_24R1   CRT_23R4
    [Setup]    SISO Coam Test Setup
    General_gnb_can_be_on_air_with_Given_Information    band=20    frame_structure=1116_3ms_GP1_A5   dl_ul_layer=4DL2UL
#    ${cell_list}    create list    ${1}
#    Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${True}
#    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    [Teardown]    run keywords   SISO Coam Test Teardown     Recommission Golden Scf

#[1]5GC000643-CF_02_peak_Tput_with_Dual_carrier_20+20Mhz_eCPRI
#    [Tags]    1S-2CC-4D-2U
#    [Setup]    SISO Coam Test Setup
#    General_SiSo_E2E_system_setup_with_data_transfer    band=20   beamset=2 beams   dl_ul_layer=4DL2UL
#    [Teardown]   SISO Coam Test Teardown
#
#[1]5GC000643-CF_03_cell_lock_unlock_with_Dual_carrier_20+20Mhz_eCPRI
#    [Tags]    1S-2CC-4D-2U
#    [Setup]    SISO Coam Test Setup
#    General_SiSo_Cell_lock_and_unlock    with_call=${True}    with_peak=${False}
#    [Teardown]   SISO Coam Test Teardown

*** Keywords ***
Recommission Golden Scf
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=${0}
    Run Keyword And Ignore Error    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
