# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           #SISO Coam Test Setup
# Test Teardown        #SISO Coam Test Teardown
# Test Timeout         180 min
# 
# Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource             ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource             ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
# #Resource             ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
# #Resource             ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
# 
# Documentation
# ...    Author: Liu Yue
# ...    Contact: yue.2.liu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature CB010744:FR1 TDD NR configs eCPRI for ABIP #2
# ...    in SBTS24R2 LL program with configuration block 24R1_N_CB010744_5
# 
# Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY36    master_classicalbts_all
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB010744-SR-E-04-General_SiSo_Cell_block_and_unblock
#     [Tags]    3S-1CC-8D8U_100M_8Rx-IRC_CB010744-5    CRT_TRUNK
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_Cell_block_and_unblock    with_call=${False}
#     [Teardown]    Run Keywords    add fault to allowed history fault list    faultId=${49}   AND
#     ...    SISO Coam Test Teardown
# 
# *** Keywords ***
