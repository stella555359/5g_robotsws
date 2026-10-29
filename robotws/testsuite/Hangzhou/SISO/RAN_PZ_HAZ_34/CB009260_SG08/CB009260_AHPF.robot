# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# 
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007841_AQQK/Resources/CB007841_common_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
# 
# 
# Documentation
# ...    Author:zhenzhen ren
# ...    contact:zhenzhen.ren@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB009260_AHPF
# 
# Force Tags            5G_RAN_TDD    SBTS00    CRT_22R4    CRT_23R1
# 
# 
# *** Variables ***
# ${SCF_CB009260}    ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_CB009260.xml
# ${dist_name}    MRBTS-1142/EQM-1/HWTOP-1/CABLINK-5
# @{sfp_list}    FOTB    AOZEB
# @{link_list}    'connected'
# 
# 
# *** Test Cases ***
# [1]CB009260-SR_7_The_BTS_shall_support_NIDD_parameter_(EQM_APEQM-SFPOperatorMode)_to_enable_and_disable_SFP+_or_SFP28_compliance_validation
#     [Tags]    CRT_TRUNK    CRT_23R2
#     COAM Commission with scf file    scf_file_path=${SCF_CB009260}   timeout=15min
#     Wait until keyword succeeds    15 min    20 sec    COAM Check GNB cell on air    connection=GNB_OAM
#     CB007841-5G-E_AQQK_01_The BTS shall support NIDD parameter (EQM APEQM-SFPOperatorMode)    sfp_list=${sfp_list}
# 
# [1]CB009260-SR_8_BTS_startup_Cooled_SFP+_or_SFP28_transceivers_support_for_interface
#     [Tags]    CRT_TRUNK    CRT_23R2
#     COAM Commission with scf file    scf_file_path=${SCF_CB009260}   timeout=15min
#     Wait until keyword succeeds    15 min    20 sec    COAM Check GNB cell on air    connection=GNB_OAM
#     BTS startup Cooled SFP+ or SFP28 transceivers support for FH interface
# 
# [1]CB009260-SR_B_BTS_startup_SFP_power_level_1-2_compatibility_validation
#     [Tags]    CRT_TRUNK    CRT_23R2
#     BTS startup SFP power level compatibility validation    RF_port=RF1    power=PL2
# 
# #[1]CB009260-SR_3_BTS_startup_SFP_power_level_3-4_compatibility_validation
# #    [Tags]    CRT_TRUNK    CRT_23R2
# #    BTS startup SFP power level compatibility validation    RF_port=RF4    power=PL4
# 
# [1]CB009260-SR_12_BTS_startup_rate_selection_for_[Q]SFP28_transceiver_module_on_System_Module_fronthaul
#     [Tags]    CRT_TRUNK    CRT_23R2
#     COAM Commission with scf file    scf_file_path=${SCF_CB009260}   timeout=15min
#     Wait until keyword succeeds    15 min    20 sec    COAM Check GNB cell on air    connection=GNB_OAM
#     BTS_startup_rate_selection_for_[Q]SFP28_transceiver_module    dist_name=${dist_name}
#     Check sfp information   link_list=${link_list}
# 
# 
