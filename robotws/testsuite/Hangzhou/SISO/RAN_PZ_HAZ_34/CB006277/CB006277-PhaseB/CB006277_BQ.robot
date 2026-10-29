# # # *** Settings ***
# # # Suite Setup          SISO Coam Suite Setup
# # # Suite Teardown       SISO Coam Suite Teardown
# # # #Test Setup           SISO Coam Test Setup
# # # #Test Teardown        SISO Coam Test Teardown
# # # Test Timeout         100 min
# # # 
# # # Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# # # Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# # # Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
# # # Resource     ../../common/siso_resource.robot
# # # 
# # # 
# # # Documentation
# # # ...    Author: Liu Yue
# # # ...    Contact: yue.2.liu@nokia-sbell.com
# # # ...    squad group:SG_05
# # # ...    Feature CB006277 in 5G22R1 program
# # # 
# # # Force Tags    QCD_MN_5G    QCP_5G    5G_RAN_TDD
# # # ...    PY36
# # # 
# # # *** Variables ***
# # # 
# # # *** Test Cases ***
# # # [1]CB006277_BQ_02_Call_setup_with_prach_config_index_92
# # #     [Tags]    master_classicalbts_all    CRT_TRUNK
# # #     [Setup]    SISO Coam Test Setup
# # #     Modify_Band_Frame_Structure    prach_index=92    frame_structure=1070_GP1_A3    dl_ul_layer=4DL4UL
# # #     @{cell_list}    Create List    ${1}	
# # #     Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${False}
# # #     [Teardown]    SISO Coam Test Teardown
# # # *** Test Cases ***
# # # [1]CB006277_BQ_03_Call_setup_with_prach_config_index_98
# # #     [Tags]    master_classicalbts_all    CRT_TRUNK
# # #     [Setup]    SISO Coam Test Setup
# # #     Modify_Band_Frame_Structure    prach_index=98    frame_structure=1116_3ms_GP1_A5    dl_ul_layer=4DL4UL
# # #     @{cell_list}    Create List    ${1}	
# # #     Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${False}
# # #     [Teardown]    SISO Coam Test Teardown
# # # 
# # # *** Keywords ***
