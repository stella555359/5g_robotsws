# *** Settings ***
# Force Tags    PY36
# Documentation
# ...   author: zheyuan.chen@nokia-sbell.com
# ...   contact: zheyuan.chen@nokia-sbell.com
# ...   Dual Core Sync
# 
# #Suite Setup    suite_setup
# Suite Setup    Run keywords    suite_setup    AND    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# Resource    resources/comm_829D.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# *** Variable ***
# @{gnss_mode}    GPS-GLONASS    GPS-Beidou    GPS only    GLONASS only    Beidou only
# @{expect_detail_list1}    37    True    True    False    False    10.57.249.62    True    128    128    20    True    21
# ...    6    00B0AEFFFE05260B    6400    00B0AEFFFE05260B    MASTER_CLOCK_OK    1    1    used    8    1    None
# @{expect_detail_list2}    37    None    None    None    None    10.57.249.62    None    None    None    None    None    None    None
# ...     None    None    None     MASTER_CLOCK_DISABLED    1    None    not used    8    None    None
# ${cmd1}       /opt/hwmt/python/SendOMMessage.py
# ${cmd2}     ${cmd1} -s 0x04dc -d HWASYNC-1/CLOCKOUTPUTS-1/BACKPLANE-1 --proto SYNC/backplane -t execute --action setClock1Pps --args clock1Pps=0
# ${cmd3}     ${cmd1} -s 0x04dc -d HWASYNC-1/CLOCKOUTPUTS-1/BACKPLANE-1 --proto SYNC/backplane -t execute --action setClock1Pps --args clock1Pps=1
# *** Test Cases ***
# [1]5GC000829-D_01-SyVe FYGM startup, automatic self-survey with automatic location mode
#     [Documentation]
#     ...    The purpose of this test is to check the correct FYGM startup in automatic location mode.
#     ...    -19.03.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_21A    CRT_TRUNK    5GC000829-D    CRT_21B
#     [Setup]    case1_setup
#     Check BTS Should Be Normal
#     Check GNSS Product Name And status    expect_product_name=FYGM
#     Change Sync Input Type    expect_SMOD=SMOD_A-1    synctype=1pps/ToD from external GNSS receiver
#     Change GNSS Operation Mode And Check Sync Stutas_Trunk    beidou_value=true    glonass_value=false    gps_value=true
#     ...    expect_Beidou_usage=Yes    expect_Glonass_usage=No    expect_Gps_usage=Yes
#     Change GNSS Operation Mode And Check Sync Stutas_Trunk    beidou_value=false    glonass_value=false    gps_value=true
#     ...    expect_Beidou_usage=No    expect_Glonass_usage=No    expect_Gps_usage=Yes
# #    Change GNSS Operation Mode And Check Sync Stutas_Trunk    beidou_value=false    glonass_value=true    gps_value=false
# #    ...    expect_Beidou_usage=No    expect_Glonass_usage=Yes    expect_Gps_usage=No
#     Change GNSS Operation Mode And Check Sync Stutas_Trunk    beidou_value=true    glonass_value=false    gps_value=false
#     ...    expect_Beidou_usage=Yes    expect_Glonass_usage=No    expect_Gps_usage=No
#     Change GNSS Operation Mode And Check Sync Stutas_Trunk    beidou_value=false    glonass_value=true    gps_value=true
#     ...    expect_Beidou_usage=No    expect_Glonass_usage=Yes    expect_Gps_usage=Yes
# #    Change GNSS Operation Mode And Check Sync Stutas
#     [Teardown]    case1_teardown
# 
# [1]5GC000829-D_03-SyVe -ToP_Phase_Sync_TOP_Detailed_Info
#     [Documentation]
#     ...    The purpose of this test case is to verify DU synchronization mode configuration and sync source switching function.
#     ...    -19.03.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_21A    CRT_TRUNK    5GC000829_D    CRT_21B
#     [Setup]    case2_setup
#     Check BTS Should Be Normal
#     Check Sync Status And Web Detail    expect_isActive=${True}
#     ...    expect_availability=Available    expect_usability=Usable    expect_detail_list=@{expect_detail_list1}
#     Change Top Domain Number    Domain_value=5
#     wait until keyword succeeds    5min    15s    Check Alarm FaultID Contain Expect_alarm    expect_fault_id=${4298}
#     Check Sync Status And Web Detail    expect_isActive=${False}
#     ...    expect_availability=Unavailable    expect_usability=Unusable    expect_detail_list=@{expect_detail_list2}
#     ...    expect_tuningMode=Adaptive holdover
#     Change Top Domain Number    Domain_value=0
#     wait until keyword succeeds    5min    15s    Check Alarm FaultID Not Contain Expect_alarm    expect_fault_id=${4298}
#     Check Sync Status And Web Detail    expect_isActive=${True}
#     ...    expect_availability=Available    expect_usability=Usable    expect_detail_list=@{expect_detail_list1}
#     Change Secondary SMOD Sync    command=${cmd2}
#     wait until keyword succeeds    15min    20s    Check Alarm FaultID Contain Expect_alarm    expect_fault_id=${4385}
#     Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${False}
#     ...    expect_availability=Unavailable    expect_usability=Unusable    expect_tuningMode=Adaptive holdover
#     Change Secondary SMOD Sync    command=${cmd3}
#     wait until keyword succeeds    15min    20s    Check Alarm FaultID Not Contain Expect_alarm    expect_fault_id=${4385}
#     Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${True}
#     ...    expect_availability=Available    expect_usability=Usable
#     [Teardown]    case2_teardown
# 
# [1]5GC000829-D_04-Synchronization_Mode_ReferenceSource_Switching
#     [Documentation]
#     ...    The purpose of this test case is to verify DU synchronization mode configuration and sync source switching function.
#     ...    -19.03.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_21A    CRT_TRUNK    5GC000829_D    CRT_21B
#     [Setup]    case3_setup
#     Check BTS Should Be Normal
#     Start Catch BTS Log
#     Disconnect Sync Connector Less Than 5s
#     Stop Catch BTS Log And Check Log
#     Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${True}
#     ...    expect_availability=Available    expect_usability=Usable
#     Change Top Domain Number    Domain_value=5
#     Check Both Primary Sync Status    TOPP_isActive=${False}    TOPP_Availability=Unavailable    TOPP_Usability=Unusable
#     ...    GNSS_isActive=${True}
#     wait until keyword succeeds    10min    20s    Check Alarm FaultID Contain Expect_alarm    expect_fault_id=${4298}
#     Start Catch BTS Log And Check Log
#     Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${True}
#     ...    expect_availability=Available    expect_usability=Usable
#     Change Top Domain Number    Domain_value=0
#     wait until keyword succeeds    10min    20s    Check Alarm FaultID Not Contain Expect_alarm    expect_fault_id=${4298}
#     Start Catch BTS Log
#     Check Both Primary Sync Status    TOPP_isActive=${True}    TOPP_Availability=Available    TOPP_Usability=Usable
#     ...    GNSS_isActive=${False}
#     Stop Catch BTS Log And Check Log
#     Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${True}
#     ...    expect_availability=Available    expect_usability=Usable
#     [Teardown]    CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Change GNSS Operation Mode And Check Sync Stutas
#     FOR    ${item}    IN    @{gnss_mode}
#         Change GNSS Operation Mode    Actual_value=${item}
#         wait until keyword succeeds     20min    1min    Check Sync Status    target=primary
#         ...    expect_syncInputType=1pps/ToD from external GNSS receiver     expect_isActive=${True}
#         Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${True}
#         ...    expect_availability=Available    expect_usability=Usable
#         Check GNSS Mode    expect_control_mode=${item}    expect_constellation_mode=${item}
#     END
# 
# Change GNSS Operation Mode And Check Sync Stutas_Trunk
#     [Arguments]    ${beidou_value}=false    ${glonass_value}=true    ${gps_value}=true
#     ...    ${expect_Beidou_usage}=No    ${expect_Glonass_usage}=Yes    ${expect_Gps_usage}=Yes
#     comm_829D.Change_GNSS_Mode_TRUNK    beidou_value=${beidou_value}    glonass_value=${glonass_value}    gps_value=${gps_value}
#     wait until keyword succeeds     20min    1min    Check Sync Status    target=primary
#     ...    expect_syncInputType=1pps/ToD from external GNSS receiver     expect_isActive=${True}
#     Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${True}
#     ...    expect_availability=Available    expect_usability=Usable
#     comm_829D.Check GNSS Mode_trunk    expect_Beidou_usage=${expect_Beidou_usage}    expect_Glonass_usage=${expect_Glonass_usage}
#     ...    expect_Gps_usage=${expect_Gps_usage}
# 
# Check Sync Status And Web Detail
#     [Arguments]    ${expect_isActive}    ${expect_availability}    ${expect_usability}    ${expect_detail_list}
#     ...    ${expect_tuningMode}=Normal tuning    ${expect_isActive2}=${True}
#     wait until keyword succeeds    5min    20s    Check Sync Status    target=primary    expect_syncInputType=TOPP
#     ...    expect_isActive=${expect_isActive}    expect_availability=${expect_availability}    expect_usability=${expect_usability}
#     ...    expect_tuningMode=${expect_tuningMode}
#     Check Web TOP Synchronization Detail    expect_detail_list=${expect_detail_list}
#     Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane
#     ...    expect_isActive=${expect_isActive2}    expect_availability=Available    expect_usability=Usable
# 
# Stop Catch BTS Log And Check Log
#     Stop and collect btslog on local machine
#     Check Phase Error
# 
# Start Catch BTS Log And Check Log
#     Start Catch BTS Log
#     sleep    40s
#     Stop and collect btslog on local machine
#     Check ESelectedClockSource Phase Error
# 
# Check Alarm FaultID Contain Expect_alarm
#     [Arguments]    ${expect_fault_id}
#     Log To Console    Check Alarm FaultID Contain Expect_alarm
#     ${fault_id_list}    Get BTS Alarm FaultID
#     list should contain value    ${fault_id_list}    ${expect_fault_id}
# 
# Check Alarm FaultID Not Contain Expect_alarm
#     [Arguments]    ${expect_fault_id}
#     Log To Console    Check Alarm FaultID Not Contain Expect_alarm
#     ${fault_id_list}    Get BTS Alarm FaultID
#     list should not contain value    ${fault_id_list}    ${expect_fault_id}
# 
# Check Both Primary Sync Status
#     [Arguments]    ${TOPP_isActive}    ${TOPP_Availability}    ${TOPP_Usability}    ${GNSS_isActive}
#     Check Sync Status    target=primary    expect_syncInputType=TOPP    expect_isActive=${TOPP_isActive}
#     ...    expect_availability=${TOPP_Availability}    expect_usability=${TOPP_Usability}
#     Check Sync Status    target=primary    expect_syncInputType=1pps/ToD from external GNSS receiver
#     ...    expect_isActive=${GNSS_isActive}    index=${1}
# 
# case1_setup
#     Delete Structure2 And Change Sync Input Type    expect_SMOD=SMOD_A-1    synctype=1pps/ToD from external GNSS receiver
# 
# case1_teardown
# #    Change GNSS Operation Mode    Actual_value=GPS-GLONASS
#     Add Structure2 And Change Sync Input Type    expect_SMOD=SMOD_A-1    synctype1=1pps/ToD from external GNSS receiver    synctype2=TOPP
#     CI_interface.Common Case Teardown
# 
# case2_setup
#     Delete Structure2 And Change Sync Input Type    expect_SMOD=SMOD_A-1    synctype=TOPP
# 
# case2_teardown
#     Add Structure2 And Change Sync Input Type    expect_SMOD=SMOD_A-1    synctype1=1pps/ToD from external GNSS receiver    synctype2=TOPP
#     CI_interface.Common Case Teardown
# 
# case3_setup
#     Change Two Sync Input Type    expect_SMOD=SMOD_A-1    synctype1=TOPP    synctype2=1pps/ToD from external GNSS receiver
# 
# suite_setup
#     Setup Commission SCF    SBTS_scf_name=SCF_SBTS00.xml    Branch_scf_name=SCF_0.800_DU.xml
#     Check BTS Should Be Normal
