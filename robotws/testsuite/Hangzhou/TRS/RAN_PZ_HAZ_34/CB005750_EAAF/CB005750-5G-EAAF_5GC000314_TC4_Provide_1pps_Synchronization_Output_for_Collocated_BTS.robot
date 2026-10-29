# *** Settings ***
# Force Tags    PY36
# Suite Setup        robot_common_operations.Common Suite Setup
# Suite Teardown     robot_common_operations.Common Suite Teardown
# 
# Documentation
# ...   author: zheyuan.chen@nokia-sbell.com
# ...   contact: zheyuan.chen@nokia-sbell.com
# ...   Sync
# 
# Resource    resources/EAAF_comm.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    ../CB005750_EA/Resources/common_keyword.robot
# Library     ../CB005750_EA/Resources/5G000313_common_keywords.py
# Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# 
# *** Test Cases ***
# [1]CB005750-5G-EAAF_5GC000314_TC4_Provide_1pps_Synchronization_Output_for_Collocated_BTS
#     [Documentation]
#     ...    The goal of this test is to check that 5gNB shares the synchronization source with 1PPS/TOD GNSS.
#     ...    -23.02.2021,zheyuan.chen@nokia-sbell.com
#     [Tags]     CRT_TRUNK      CRT_22R3
#     [Setup]    case_setup
#     Change Master Clock Output    Actual_value=Disabled
#     Check Sync Status    DU_IP=${SLAVE_DU_OAM_IP}    expect_syncInputType=1pps/ToD from Sync Hub Master    expect_isActive=${False}
#     ...     expect_availability=Unavailable    expect_usability=Unusable    expect_tuningMode=Adaptive holdover
#     wait until keyword succeeds    150s    30s    Alarm Contain Target FaultID    DU_IP=${SLAVE_DU_OAM_IP}    expect_fault=${1898}
#     Change Master Clock Output    Actual_value=EnabledWithBtsInputReference
#     Check Sync Status    DU_IP=${SLAVE_DU_OAM_IP}    expect_syncInputType=1pps/ToD from Sync Hub Master    expect_isActive=${True}
#     ...     expect_availability=Available    expect_usability=Usable    expect_tuningMode=Normal tuning
#     wait until keyword succeeds    150s    30s    Alarm Not Contain Targer FaultID    DU_IP=${SLAVE_DU_OAM_IP}    expect_fault=${1898}
#     Start Catch BTS Log
#     sleep    40s
#     Stop BTS Log and Check Phase Error
#     Change Sync Input Type    DU_IP=${DU_OAM_IP}    BTS_ID=${BTS_ID}    synctype=TOPP
#     Check Sync Status    DU_IP=${SLAVE_DU_OAM_IP}    expect_syncInputType=1pps/ToD from Sync Hub Master    expect_isActive=${True}
#     ...     expect_availability=Available    expect_usability=Usable    expect_tuningMode=Normal tuning
#     wait until keyword succeeds    150s    30s    Alarm Not Contain Targer FaultID    DU_IP=${SLAVE_DU_OAM_IP}    expect_fault=${1898}
#     Start Catch BTS Log
#     sleep    40s
#     Stop BTS Log and Check Phase Error
#     Change Master Clock Output    Actual_value=Disabled
#     Check Sync Status    DU_IP=${SLAVE_DU_OAM_IP}    expect_syncInputType=1pps/ToD from Sync Hub Master    expect_isActive=${False}
#     ...     expect_availability=Unavailable    expect_usability=Unusable    expect_tuningMode=Adaptive holdover
#     wait until keyword succeeds    150s    30s    Alarm Contain Target FaultID    DU_IP=${SLAVE_DU_OAM_IP}    expect_fault=${1898}
#     wait until keyword succeeds    150s    30s    Alarm Contain Target FaultID    DU_IP=${SLAVE_DU_OAM_IP}    expect_fault=${4405}
#     [Teardown]    case_teardown
# 
# *** Keywords ***
# case_setup
#     Log To Console    case set up
#     Setup Commission SCF
#     Change BTS Sync Mode To PhaseSync    DU_IP=${DU_OAM_IP}    BTS_ID=${BTS_ID}
#     Change BTS Sync Mode To PhaseSync    DU_IP=${SLAVE_DU_OAM_IP}    BTS_ID=${SLAVE_BTS_ID}
#     Change Sync Input Type And Delete Structure2    DU_IP=${DU_OAM_IP}    BTS_ID=${BTS_ID}
#     ...    synctype=1pps/ToD from external GNSS receiver
#     Check Sync Status    DU_IP=${DU_OAM_IP}    expect_syncInputType=1pps/ToD from external GNSS receiver    expect_isActive=${True}
#     ...    expect_availability=Available    expect_usability=Usable    expect_tuningMode=Normal tuning
#     Change Sync Input Type And Delete Structure2    DU_IP=${SLAVE_DU_OAM_IP}    BTS_ID=${SLAVE_BTS_ID}
#     ...    synctype=1pps/ToD from Sync Hub Master
# 
# Stop BTS Log and Check Phase Error
#     Log To Console    Stop and collect btslog on local machine
#     EAAF_comm.Stop and collect btslog on local machine
#     Check Phase Error
# 
# Alarm Contain Target FaultID
#     [Arguments]    ${DU_IP}    ${expect_fault}
#     ${fault_id_list}    Get BTS Alarm FaultID    DU_IP=${DU_IP}
#     list should contain value    ${fault_id_list}    ${expect_fault}
# 
# Alarm Not Contain Targer FaultID
#     [Arguments]    ${DU_IP}    ${expect_fault}
#     ${fault_id_list}    Get BTS Alarm FaultID    DU_IP=${DU_IP}
#     list should not contain value    ${fault_id_list}    ${expect_fault}
# 
# case_teardown
#     Log To Console    case teardown
#     Change Sync Input Type And Add Structure2    DU_IP=${DU_OAM_IP}    BTS_ID=${BTS_ID}
#     ...    synctype1=1pps/ToD from external GNSS receiver    synctype2=TOPP
#     Change Sync Input Type And Add Structure2   DU_IP=${SLAVE_DU_OAM_IP}    BTS_ID=${SLAVE_BTS_ID}
#     ...    synctype1=TOPP    synctype2=1pps/ToD from Sync Hub Master
#     CI_interface.Common Case Teardown
