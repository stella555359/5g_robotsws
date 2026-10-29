# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# #Test Setup           SISO Coam Test Setup
# #Test Teardown        SISO Coam Test Teardown
# Test Timeout         100 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
# Resource     ../resource/resources_l3call.robot
# Resource     ../../common/siso_resource.robot
# 
# 
# Documentation
# ...    Author: Liu Yue
# ...    Contact: yue.2.liu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature CB006277 in 5G22R1 program
# 
# Force Tags        RAN_5G_TDD
# ...    PY36
# 
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB006277_DF_01_AQQL_256QAM_for_PUSCH_Feature_Activation
#     [Tags]    master_classicalbts_all     CRT_TRUNK   CIT_22R2   CIT_22R3
#     [Setup]    SISO Coam Test Setup
#     Activate 256QAM for PUSCH
#     @{cell_list}    Create List    ${1}	
#     Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
#     [Teardown]    SISO Coam Test Teardown
# #*** Test Cases ***
# [1]CB006277_DF_02_AQQL_256QAM_for_PUSCH_Feature_deactivation
#     [Tags]    master_classicalbts_all    CRT_TRUNK
#     [Setup]    SISO Coam Test Setup
#     Deactivate 256QAM for PUSCH
#     @{cell_list}    Create List    ${1}	
#     Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${False}
#     [Teardown]    SISO Coam Test Teardown
# 
# *** Keywords ***
# Activate 256QAM for PUSCH
#     Selenium Login And Disable Screen Lock
#     #selenium_coam.refresh_page
#     ${status}    Run Keyword And Ignore Error    selenium_coam.get_parameter_value 
#     ...    dist_name=MRBTS-${MRBTS_ID}/NRCELL-1
#     ...    filter_param=Activate 256QAM in UL
#     Run Keyword If    '${status[0]}' == '${False}'    selenium_coam.refresh_page
#     ${status[1]}=    Run Keyword If    '${status[0]}' == '${False}'    
#     ...    selenium_coam.get_parameter_value
#     ...    dist_name=MRBTS-${MRBTS_ID}/NRCELL-1
#     ...    filter_param=Activate 256QAM in UL
#     Run keyword if    '${status[1]}' == 'false'    selenium_coam.set_parameter_value  dist_name=MRBTS-${MRBTS_ID}/NRCELL-1
#         ...    filter_param=Activate 256QAM in UL
#         ...    abbr=actUl256Qam    new_value=true
#     selenium_coam.validate_plan
#     selenium_coam.activate_plan
#     [Teardown]  Selenium Logout And Close Browser
# 
# Deactivate 256QAM for PUSCH
#     Selenium Login And Disable Screen Lock
#     selenium_coam.refresh_page
#     ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRCELL-1
#     ...    filter_param=Activate 256QAM in UL
#     run keyword if    '${currect_status}' == 'true'    selenium_coam.set_parameter_value  dist_name=MRBTS-${MRBTS_ID}/NRCELL-1
#         ...    filter_param=Activate 256QAM in UL
#         ...    abbr=actUl256Qam    new_value=false
#     selenium_coam.validate_plan
#     selenium_coam.activate_plan
#     [Teardown]  Selenium Logout And Close Browser
