*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       Run Keywords    SISO Coam Suite Teardown    AND    selenium_set_8392_flag
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ./Resources/CB008392-AZQF-keywords.robot


Documentation
...    Author: Melinda
...    Contact: meinda.gao@nokia-sbell.com
...    squad group:SG_08
...    Feature CB008392 powersaving for AZQF

Force Tags    RAN_5G_TDD    5G_RAN_TDD    CRT_TRUNK    CRT_23R1    CRT_23R2
...    PY36
...    SBTS00

*** Variables ***

*** Test Cases ***

[1]CB008392-A_3_Feature_CB008392_Deactivation_with_cell_in_reducedEnergySaving_state
    CB008392-A_3_Feature_CB008392_Deactivation_with_cell_in_reducedEnergySaving_state

[1]CB008392-A_15_View_Power_Saving_Performance_Management_Counters
    CB008392-A_15_View_Power_Saving_Performance_Management_Counters

[1]CB008392_A_5_Determine_Cell_TX_Path_Reduction_Power_Saving_Mode
    CB008392_A_5_Determine_Cell_TX_Path_Reduction_Power_Saving_Mode

[1]CB008392-B_2_8TX_Cell(non-BF_case)Switch_On_Cell_TX_Paths
    CB008392-B_2_8TX_Cell(non-BF_case)Switch_On_Cell_TX_Paths

[1]CB008392-B_1_8TX_Cell(non-BF_case)Switch_Off_Cell_TX_Paths
    CB008392-B_1_8TX_Cell(non-BF_case)Switch_Off_Cell_TX_Paths

[1]CB008392-A Cell degraded due to cell and BTS level alarm
    CB008392-A Cell degraded due to cell and BTS level alarm

*** Keywords ***
