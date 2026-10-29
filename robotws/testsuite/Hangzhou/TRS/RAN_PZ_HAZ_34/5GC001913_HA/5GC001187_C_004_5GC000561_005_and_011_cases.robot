# *** Settings ***
# Documentation     author: Wu Jerry
# ...               contact: jerry.wu@nokia-sbell.com
# ...               squad group: MMW_02
# Suite Setup       CI_interface.Common Suite Setup
# Suite Teardown    Test_suite_teardown
# Force Tags        
# ...    PY36
# ...               RAN_5G    RAN_5G_TDD
# Resource          Resources/common_keyword.robot
# 
# *** Variables ***
# ${names_case05}    1913HA_case5
# ${names_case11}    1913HA_case11  
# ${testline_name}      null
# ${CONFIGURATION}      null
# 
# *** Test Cases ***
# [2]5GC001187_C_004_5GC000561_005_RAU_lost_of_synchronization_source_during_normal_operation
#     [Documentation]    Check_if_NE_support_reported_PTP_fields_status_to_OAM_for_troubleshooting
#     [Tags]    
#     [Setup]    Case05 common Setup
#     2377_HB and 1913_HA case05    names=${names_case05}
#     [Teardown]    Case05 Common teardown
# 
# [2]5GC001187_C_004_5GC000561_011_Check_if_NE_support_reported_PTP_fields_status_to_OAM_for_troubleshooting
#     [Documentation]    Check_if_NE_support_reported_PTP_fields_status_to_OAM_for_troubleshooting
#     [Tags]    
#     [Setup]    Case11 common Setup
#     2377_HB and 1913_HA case11    names=${names_case11}
#     [Teardown]    Case11 Common teardown
#    