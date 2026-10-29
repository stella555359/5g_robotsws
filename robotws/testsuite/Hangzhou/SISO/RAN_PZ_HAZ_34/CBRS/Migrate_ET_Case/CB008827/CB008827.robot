# *** Settings ***
# Suite Setup          Run Keywords    CBRS Suite Setup  AND  Case Preparation for CB007857 ET
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CBRS Test Setup
# Test Teardown        CBRS Test Teardown
# 
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CBRS/Migrate_ET_Case/CB007857/Resources/CB007857-ET_common_keywords.robot
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CBRS/resources/cbrs_common_keywords.robot
# 
# Documentation
# ...    Author:Gao, melinda
# ...    contact:melinda.gao@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB008827 ET CBRS
# 
# Force Tags    SBTS00    CRT_TRUNK
# ...   PY36
# 
# *** Variables ***
# ${CB008827_json_path}    ${CURDIR}/Resources/json
# ${8827_A-06_Scf_delta_6}    ${CB008827_json_path}/Delta_plan_6.json
# ${8827_A-06_Scf_delta_pmax}    ${CB008827_json_path}/Delta_plan_desiredpmax_27.json
# ${8827_A-06_Scf_delta_recovery}    ${CB008827_json_path}/Delta_plan_6_recovery.json
# ${8827_A-23_scf_delta_23}    ${CB008827_json_path}/Delta_plan_23.json
# ${8827_A-23_scf_delta_chbw}    ${CB008827_json_path}/Delta_plan_change_desiredChBw.json
# ${8827_A_23_scf_delta_recovery}    ${CB008827_json_path}/Delta_plan_23_recovery.json
# ${8827_A-29_scf_delta}    ${CB008827_json_path}/Delta_plan_25.json
# ${8827_A-29_scf_delta_1}    ${CB008827_json_path}/Delta_plan_29.json
# ${8827_A-29_scf_recovery}    ${CB008827_json_path}/Scfc_recover.json
# 
# ${8827_A-06_Scf_delta_6_master}    ${CB008827_json_path}/Delta_plan_6_master.json
# ${8827_A-06_Scf_delta_pmax_master}    ${CB008827_json_path}/Delta_plan_desiredpmax_27_master.json
# ${8827_A-06_Scf_delta_recovery_master}    ${CB008827_json_path}/Delta_plan_6_recovery_master.json
# ${8827_A-23_scf_delta_23_master}    ${CB008827_json_path}/Delta_plan_23_master.json
# ${8827_A-23_scf_delta_chbw_master}    ${CB008827_json_path}/Delta_plan_change_desiredChBw_master.json
# ${8827_A_23_scf_delta_recovery_master}    ${CB008827_json_path}/Delta_plan_23_recovery_master.json
# ${8827_A-29_scf_delta_master}    ${CB008827_json_path}/Delta_plan_25_master.json
# ${8827_A-29_scf_delta_1_master}    ${CB008827_json_path}/Delta_plan_29_master.json
# ${8827_A-29_scf_recovery_master}    ${CB008827_json_path}/Scfc_recover_master.json
# *** Test Cases ***
# [1]CB007857-A_06_pmax_exceed_fcc_limitation
#     CB007857-A_06_pmax_exceed_fcc_limitation    delta_file_1=${8827_A-06_Scf_delta_6}    delta_file_1_master=${8827_A-06_Scf_delta_6_master}
#     ...    delta_file_2=${8827_A-06_Scf_delta_pmax}    delta_file_teardown=${8827_A-06_Scf_delta_recovery}
#     ...    delta_file_2_master=${8827_A-06_Scf_delta_pmax_master}    delta_file_teardown_master=${8827_A-06_Scf_delta_recovery_master}
# 
# [1]CB007857-A_23_desiredchbw_increased_supportedspectrumv2_widen
#     CB007857-A_23_desiredchbw_increased_supportedspectrumv2_widen    delta_file_1=${8827_A-23_scf_delta_23}
#     ...    delta_file_2=${8827_A-23_scf_delta_chbw}    delta_file_teardown=${8827_A_23_scf_delta_recovery}
#     ...    delta_file_1_master=${8827_A-23_scf_delta_23_master}    delta_file_2_master=${8827_A-23_scf_delta_chbw_master}
#     ...    delta_file_teardown_master=${8827_A_23_scf_delta_recovery_master}
# 
# [1]CB007857-B_29_desiredpmax_decreased
#     CB007857-B_29_desiredpmax_decreased    delta_file_1=${8827_A-29_scf_delta}    delta_file_1_master=${8827_A-29_scf_delta_master}
#     ...    delta_file_2=${8827_A-29_scf_delta_1}    delta_file_teardown=${8827_A-29_scf_recovery}
#     ...    delta_file_2_master=${8827_A-29_scf_delta_1_master}     delta_file_teardown_master=${8827_A-29_scf_recovery_master}
# *** Keywords ***
