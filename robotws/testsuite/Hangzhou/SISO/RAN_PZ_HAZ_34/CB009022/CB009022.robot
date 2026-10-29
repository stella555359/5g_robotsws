*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           #SISO Coam Test Setup
Test Teardown        #SISO Coam Test Teardown
Test Timeout         300 min

Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource             ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource             ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Resource             ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource             ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot

#Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
#Library             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/get_case_variables.py
#Variables           TestData/case_variables.yml

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB009022 in SBTS23R4 program with configuration block 23R4-N-CB009904-A1/B1/D1/A5/D2

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY36    master_classicalbts_all

*** Variables ***

*** Test Cases ***
[1]CB009022_SR_A_05_Baseband_cell_set_up_to_4cells_TDD_Ecpri_8DL4UL_MIMO_layers_with_BF
    [Tags]    4S-1CC-8D8U_100M_CB009904-A1    CIT_23R4    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    log to console    recommissioning completed; Cell setup completed.
#    ${cell_list}    Create List    ${1}
#    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown

[1]CB009022_SR_B_01_Baseband_cell_set_up_to_4cells_8DL2UL_MIMO_layers_with_BF
    [Tags]    4S-1CC-8D4U_100M_CB009904-B1    CRT_23R4    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    log to console    recommissioning completed; Cell setup completed.
#    ${cell_list}    Create List    ${1}
#    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown

[1]CB009904_SR_C_05_RF_lock_unlock_for_2cells_per_radio_TDD_Ecpri_8DL2UL_MIMO_layers_with_BF
    [Tags]    4S-2CC-8D4U_100-20M_CB009904-D1    CRT_23R4    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${False}
    [Teardown]    SISO Coam Test Teardown

[1]CB009904_SR_A_02_cells_block_unblock_for_4cells_TDD_Ecpri_8DL2UL_MIMO_layers_with_BF
    [Tags]    4S-2CC-8D8U_100-20M_CB009904-A5    CIT_23R4    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${False}
    [Teardown]    SISO Coam Test Teardown

[1]CB009904_SR_A_12_BTS_site_reset_for_4cells_TDD_Ecpri_4DL2UL_MIMO_layers_with_BF
    [Tags]    4S-2CC-4D4U_100-50M_CB009904-D2    CRT_23R4    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_Auto_BTS_site_reset    with_call=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

*** Keywords ***
