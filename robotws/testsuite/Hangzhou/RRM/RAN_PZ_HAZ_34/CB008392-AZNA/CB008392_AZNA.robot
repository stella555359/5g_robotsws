# *** Settings ***
# #Suite Setup          SISO Coam Suite Setup
# Suite Setup          Run Keywords    SISO Coam Suite Setup    AND    case_preparion_commision_SCF
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
# Test Teardown        SISO Coam Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ./Resources/CB008392-AZNA-keywords.robot
# 
# 
# Documentation
# ...    Author: Melinda
# ...    Contact: meinda.gao@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB008392 powersaving for AZNA
# 
# Force Tags    RAN_5G_TDD    5G_RAN_TDD    5G_RAN    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AZNA
# ...    CRT_TRUNK    PY36    CRT_23R1
# ...    SBTS00
# 
# *** Variables ***
# ${if_commissioning}   False
# 
# *** Test Cases ***
# 
# [1]CB008392-A_3_Feature_CB008392_Deactivation_with_cell_in_reducedEnergySaving_state
#     [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
#     CB008392-A_3_Feature_CB008392_Deactivation_with_cell_in_reducedEnergySaving_state
# 
# [1]CB008392-A_15_View_Power_Saving_Performance_Management_Counters
#     [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
#     CB008392-A_15_View_Power_Saving_Performance_Management_Counters
# 
# [1]CB008392-A_9_4TX_Cell_Switch_On_Cell_TX_Paths
#     [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
#     CB008392-A_9_4TX_Cell_Switch_On_Cell_TX_Paths    call_duration=${300}
# 
# [1]CB008392-A_8_4TX_Cell_Switch_Off_Cell_TX_Paths
#     [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
#     CB008392-A_8_4TX_Cell_Switch_Off_Cell_TX_Paths
# 
# *** Keywords ***
