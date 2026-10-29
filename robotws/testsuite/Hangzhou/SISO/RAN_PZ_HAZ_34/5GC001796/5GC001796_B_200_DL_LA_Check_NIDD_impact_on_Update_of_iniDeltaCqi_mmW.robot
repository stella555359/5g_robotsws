# *** Settings ***
# Documentation     author: yan meng
# ...               contact: meng.yan@nokia-sbell.com
# ...               squad group: MMW_02
# 
# Suite Setup         SISO Coam Suite Setup for CLOUD UTE    enb_flag=${False}
# Suite Teardown      SISO Coam Suite Teardown
# 
# Force Tags    5G_RAN    5G_RAN_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASOE_2xAEWD_ENB    master_pDU
# ...   PY39
# Resource          ./resources/common.robot
# #Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007326_2060/Resources/CB007326_2060_coam_common_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# *** Variables ***
# ${scf_1796}    1796.xml
# ${swconfig_1796}    /home/ute/MN/UTE/robotws/commissionings/HGZ/7_5_UTE5G402T159/swconfig_1796.txt
# ${swconfig}    /home/ute/MN/UTE/robotws/commissionings/HGZ/7_5_UTE5G402T159/swconfig.txt
# ${scf_1796＿path}    /home/ute/MN/UTE/robotws/commissionings/HGZ/7_5_UTE5G402T159/
# ${ultp}    120M
# ${dltp}    600M
# ${ue_index}    1
# ${exp_ul}    0
# ${exp_dl}    10
# *** Test Cases ***
# [2][1.0] 5GC001796_B_200_DL_LA_Check_NIDD_impact_on_Update_of_iniDeltaCqi_mmW
#     [Documentation]  check:1796-B is not applied: update of iniDeltaCqi occurs when set to FALSE.
#     ...    applied and No update of iniDeltaCqi occurs 
# 	...    for highest, lowest MCS and 1796-A case when NIDD parameter is set to TRUE.
#     [Tags]          SBTS00
#     [Setup]    Cases common Setup
#     ${list_of_cell_ids1}    Create List    2605057
#     step1: Prepare UE    ue_index=${ue_index}
#     start tti
# 	Step2: UE Attach    ue_index=${ue_index}
# 	Step3: Start traffic    dl_throughput=${dltp}
# 	Capture TTI log_ASOE
# 	Parse laIniDelta Event_ASOE    target=SKIP
# 	Run Keyword And Ignore Error    Step6: Stop traffic    ue_index=${ue_index}
#     Run Keyword And Ignore Error    Step7: UE Detach    ue_index=${ue_index}
#     Modify actEnhancedLinkAdaptation false
#     COAM gNB Reset site
#     start tti
# 	Step2: UE Attach    ue_index=${ue_index}
# 	Step3: Start traffic    dl_throughput=${dltp}
# 	Capture TTI log_ASOE
#     Parse laIniDelta Event_ASOE
#     Run Keyword And Ignore Error    Step6: Stop traffic    ue_index=${ue_index}
#     Run Keyword And Ignore Error    Step7: UE Detach    ue_index=${ue_index}
#     [Teardown]    Cases Common teardown
# 
# *** Keywords ***
# Cases common Setup
#     [Documentation]    Author: meng.yan
#     ...                Description: case common setup
#     robot_common_operations.Common Case Setup
#     Run Keyword And Ignore Error    Prepare testline to cell onair for SA 1796    localFilePath=${swconfig_1796}
#     ...    tl_scf_filename=${scf_1796}
#     #Connect to gnb coam via ssl
#     #Wait Until Keyword Succeeds    10min    20s    COAM Check GNB cell on air
#     #COAM Teardown gnb connections
# 
# Cases Common teardown
#     [Documentation]    Author: meng.yan
#     ...                Description: case common teardown
#     robot_common_operations.Common Case Teardown
# 	restore swConfig to default    ${swconfig}
# 	Run Keyword And Ignore Error    Step6: Stop traffic    ue_index=${ue_index}
#     Run Keyword And Ignore Error    Step7: UE Detach    ue_index=${ue_index}
# 	Case_Teardown
#     #Prepare testline to cell onair    localFilePath=${localFilePath2}   tl_scf_filename=${tl_scf_filename}
# 	#Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 	
# 
# 
