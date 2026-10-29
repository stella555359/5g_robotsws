# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# #Suite Setup          AENB CPRI Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
# Resource    ./Resources/CB007833-td-cpri_Keywords.robot
# Resource    ./Resources/CB006502_Keywords.robot
# Library    ./TestData/variables_CB007833.py
# Variables    ./TestData/variables_6502_60M.py
# 
# Documentation
# ...    Author: Melinda
# ...    Contact: meinda.gao@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB006502 made, Feature CB007833-5G-A-td_cpri_Amber
# 
# Force Tags    RAN_5G_TDD    5G_RAN_TDD    master_classicalbts_all    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED
# ...    PY36
# ...    SBTS00    CLOUD_5G_CLASSICAL_QC_ASIKL_ABILB1_AENB_ENB    SBTS22R1    SBTS22R2    SBTS22R4    CRT_22R4
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB007833-5G-A_06_RU_Black_Box_contents_in_BTS_Technical_Log
#     [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3
#     CB007833-5G-A_06_RU_Black_Box_contents_in_BTS_Technical_Log_All_RU_Operation
# 
# [1]CB006502_AENB_General_SiSo_E2E_system_setup_with_data_transfer_conducted_MCS27_30km_60MHz
#    [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
#     General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1116_0ms_GP2_A7    iperf_type=via_command
# 
# [1]General_SiSo_BTS_(Q)SFP+SFP28_provisioning_enhancements
#     General_SiSo_BTS_(Q)SFP+SFP28_provisioning_enhancements    SFP_1=S_RF1    QSFP_1=Q_RF1
# 
# #CB006502_Customer_Pronto_PMAX
# #    [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2
# #    Customer_Pronto_PMAX
# 
# *** Keywords ***