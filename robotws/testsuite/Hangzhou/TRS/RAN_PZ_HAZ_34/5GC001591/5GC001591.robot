# *** Settings ***
# Documentation     author: Jerry Wu
# ...               contact: jerry.wu@nokia-sbell.com
# ...               squad group: SG_07
# Force Tags    PY36
# ...               RAN_5G    RAN_5G_TDD
# Resource          Resources/common_keyword_1591.robot
# 
# Suite Setup       CI_interface.Common Suite Setup
# Suite Teardown    Test_suite_teardown
# 
# 
# *** Variables ***
# ${modify_topDomainNumber}    25
# ${modify_eCpriMasterDomainNumber}    24
# ${filter_expression}=    vlan.id == 295
# ${field_name}=    vlan.priority
# 
# *** Test Cases ***
# [1][2.0] 5GC000560_012_Configuration_Management_mechanism_for_ToP_above_24GHz_AEUD
#     [Documentation]    5GC000560_012_Configuration_Management_mechanism_for_ToP_above_24GHz_AEUD
#     [Tags]  
#     [Setup]    Cases common Setup
#     Check_syncState_and_lockState    expect_syncstate=Locked    expect_lockstate=Locked
#     [Teardown]    Cases Common teardown
# 
# [1][1.0] 5GC000560_014_Configuration_of_acceptable_PTP_Domain_number_above_24GHz_AEUD
#     [Documentation]    5GC000560_014_Configuration_of_acceptable_PTP_Domain_number_above_24GHz_AEUD
#     [Tags]   
#     [Setup]    Cases common Setup
#     sleep    20s
#     Get Filter topDomainNumber
#     Get Filter eCpriMasterDomainNumber
#     Run Keyword If    ${modify_topDomainNumber}!=${topDomainNumber_value}
#     ...    Modify topDomainNumber in webui
#     Run Keyword If    ${modify_eCpriMasterDomainNumber}!=${eCpriMasterDomainNumber_value}
#     ...    Modify eCpriMasterDomainNumber in webui 
#     Check_syncState_and_lockState    expect_syncstate=Freerun    expect_lockstate=OutOfLock
#     Check_expect_alarm    alarm_id=7115
#     Check_expect_alarm    alarm_id=7116 
#     [Teardown]    Cases560_14 Common teardown
#     
# [1]5GC000560_017_Generic_Startup_of_synchtonization_function_successfully_above_24GHz_AEUD
#     [Documentation]    5GC000560_017_Generic_Startup_of_synchtonization_function_successfully_above_24GHz_AEUD
#     [Tags]   
#     [Setup]    Cases common Setup
#     RU_Reset
#     Check_syncState_and_lockState    expect_syncstate=Locked    expect_lockstate=Locked 
#     [Teardown]    Cases Common teardown
