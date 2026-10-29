*** Settings ***
Force Tags    PY36
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com
...   Dual Core Sync

Suite Setup    Run keywords    suite_setup    AND    robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

Resource    ./resources/CB007310_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variable ***
@{gnss_mode}    GPS-Beidou    Beidou only
@{expect_detail_list1}    37    True    True    False    False    10.57.249.62    True    128    128    20    True    21
...    6    00:B0:AE:FF:FE:05:26:0B    6400    00:B0:AE:FF:FE:05:26:0B    MASTER_CLOCK_OK    1    used    1    None
@{expect_detail_list2}    37    None    None    None    None    10.57.249.62    None    None    None    None    None    None    None
...     None    None    None     MASTER_CLOCK_DISABLED    1    not used    None    None
${cmd1}       /opt/hwmt/python/SendOMMessage.py
${cmd2}     ${cmd1} -s 0x04dc -d HWASYNC-1/CLOCKOUTPUTS-1/BACKPLANE-1 --proto SYNC/backplane -t execute --action setClock1Pps --args clock1Pps=0
${cmd3}     ${cmd1} -s 0x04dc -d HWASYNC-1/CLOCKOUTPUTS-1/BACKPLANE-1 --proto SYNC/backplane -t execute --action setClock1Pps --args clock1Pps=1
*** Test Cases ***
#[1]CB007310-5G-C-SyVe_TC01_FYGM startup, automatic self-survey with automatic location mode_TRUNK
[1]CB007310-5G-C-SyVe_TC01_FYGM startup, automatic self-survey with automatic location mode
    [Documentation]
    ...    The purpose of this test is to check the correct FYGM startup in automatic location mode.
    ...    -29.06.2021,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CRT_UTE    SBTS00    RAN_5G    STATE_SW_UPLOADED      CLOUD_5G_CLASSICAL_FULLRACK_SA_ASILL_ABIOB1_AEQN-ASILR_ABIOB4_AEQN
    [Setup]    case1_setup
    Check BTS Should Be Normal
    Check GNSS Product Name And status_trunk    expect_product_name=FYGM
    Change Sync Input Type    expect_SMOD=SMOD_A-1    synctype=1pps/ToD from external GNSS receiver
    Change GNSS Operation Mode And Check Sync Stutas_Trunk    beidou_value=true    glonass_value=false    gps_value=true
    ...    expect_Beidou_usage=Yes    expect_Glonass_usage=No    expect_Gps_usage=Yes
    Change GNSS Operation Mode And Check Sync Stutas_Trunk    beidou_value=true    glonass_value=false    gps_value=false
    ...    expect_Beidou_usage=Yes    expect_Glonass_usage=No    expect_Gps_usage=No
    [Teardown]    case1_teardown

#[1]CB007310-5G-C-SyVe_TC01_FYGM startup, automatic self-survey with automatic location mode_21B
#    [Documentation]
#    ...    The purpose of this test is to check the correct FYGM startup in automatic location mode.
#    ...    -29.06.2021,zheyuan.chen@nokia-sbell.com,case draft
#    [Tags]    CRT_21B    CB007310
#    [Setup]    case1_setup
#    Check BTS Should Be Normal
#    Check GNSS Product Name And status_21B    expect_product_name=FYGM
#    Change Sync Input Type    expect_SMOD=SMOD_A-1    synctype=1pps/ToD from external GNSS receiver
#    Change GNSS Operation Mode And Check Sync Stutas_21B
#    [Teardown]    case1_teardown

#[1]CB007310-5G-C-SyVe_TC01_FYGM startup, automatic self-survey with automatic location mode
#    [Tags]    CRT_UTE    SBTS00    RAN_5G    STATE_SW_UPLOADED      CLOUD_5G_CLASSICAL_FULLRACK_SA_ASILL_ABIOB1_AEQN-ASILR_ABIOB4_AEQN
#    Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS

[1]CB007310-5G-C-SyVe_TC03_ToP_Phase_Sync_TOP_Detailed_Info
    [Documentation]
    ...    The purpose of this test case is to verify DU synchronization mode configuration and sync source switching function.
    ...    -21.06.2021,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CRT_UTE    SBTS00    RAN_5G    STATE_SW_UPLOADED      CLOUD_5G_CLASSICAL_FULLRACK_SA_ASILL_ABIOB1_AEQN-ASILR_ABIOB4_AEQN
    [Setup]    case2_setup
    Check BTS Should Be Normal
    run keyword and ignore error    Check Sync Status And Web Detail    expect_isActive=${True}
    ...    expect_availability=Available    expect_usability=Usable    expect_detail_list=@{expect_detail_list1}
    Change Top Domain Number    Domain_value=5
    wait until keyword succeeds    5min    15s    Check Alarm FaultID Contain Expect_alarm    expect_fault_id=${4298}
    run keyword and ignore error    Check Sync Status And Web Detail    expect_isActive=${False}
    ...    expect_availability=Unavailable    expect_usability=Unusable    expect_detail_list=@{expect_detail_list2}
    ...    expect_tuningMode=Adaptive holdover
    Change Top Domain Number    Domain_value=0
    wait until keyword succeeds    5min    15s    Check Alarm FaultID Not Contain Expect_alarm    expect_fault_id=${4298}
    run keyword and ignore error    Check Sync Status And Web Detail    expect_isActive=${True}
    ...    expect_availability=Available    expect_usability=Usable    expect_detail_list=@{expect_detail_list1}
    Change Secondary SMOD Sync    command=${cmd2}
    wait until keyword succeeds    15min    20s    Check Alarm FaultID Contain Expect_alarm    expect_fault_id=${4385}
    Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${False}
    ...    expect_availability=Unavailable    expect_usability=Unusable    expect_tuningMode=Adaptive holdover
    Change Secondary SMOD Sync    command=${cmd3}
    wait until keyword succeeds    15min    20s    Check Alarm FaultID Not Contain Expect_alarm    expect_fault_id=${4385}
    Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${True}
    ...    expect_availability=Available    expect_usability=Usable
    [Teardown]    case2_teardown

[1]CB007310-5G-C-SyVe_TC04_Synchronization_Mode_ReferenceSource_Switching
    [Documentation]
    ...    The purpose of this test case is to verify DU synchronization mode configuration and sync source switching function.
    ...    -21.06.2021,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CRT_UTE    SBTS00    RAN_5G    STATE_SW_UPLOADED      CLOUD_5G_CLASSICAL_FULLRACK_SA_ASILL_ABIOB1_AEQN-ASILR_ABIOB4_AEQN
    [Setup]    case3_setup
    Check BTS Should Be Normal
    Start Catch BTS Log
    Disconnect Sync Connector Less Than 5s
    Stop Catch BTS Log And Check Log
    Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${True}
    ...    expect_availability=Available    expect_usability=Usable
    Change Top Domain Number    Domain_value=5
    Check Both Primary Sync Status    TOPP_isActive=${False}    TOPP_Availability=Unavailable    TOPP_Usability=Unusable
    ...    GNSS_isActive=${True}
    wait until keyword succeeds    10min    20s    Check Alarm FaultID Contain Expect_alarm    expect_fault_id=${4298}
    Start Catch BTS Log And Check Log
    Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${True}
    ...    expect_availability=Available    expect_usability=Usable
    Change Top Domain Number    Domain_value=0
    wait until keyword succeeds    10min    20s    Check Alarm FaultID Not Contain Expect_alarm    expect_fault_id=${4298}
    Start Catch BTS Log
    Check Both Primary Sync Status    TOPP_isActive=${True}    TOPP_Availability=Available    TOPP_Usability=Usable
    ...    GNSS_isActive=${False}
    Stop Catch BTS Log And Check Log
    Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${True}
    ...    expect_availability=Available    expect_usability=Usable
    [Teardown]    run keyword and ignore error    CI_interface.Common Case Teardown

*** Keywords ***
Change GNSS Operation Mode And Check Sync Stutas_Trunk
    [Arguments]    ${beidou_value}=false    ${glonass_value}=true    ${gps_value}=true
    ...    ${expect_Beidou_usage}=No    ${expect_Glonass_usage}=Yes    ${expect_Gps_usage}=Yes
    Change_GNSS_Mode_TRUNK    beidou_value=${beidou_value}    glonass_value=${glonass_value}    gps_value=${gps_value}
    wait until keyword succeeds     20min    1min    Check Sync Status    target=primary
    ...    expect_syncInputType=1pps/ToD from external GNSS receiver     expect_isActive=${True}
    Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${True}
    ...    expect_availability=Available    expect_usability=Usable
    Check GNSS Mode_trunk    expect_Beidou_usage=${expect_Beidou_usage}    expect_Glonass_usage=${expect_Glonass_usage}
    ...    expect_Gps_usage=${expect_Gps_usage}

Change GNSS Operation Mode And Check Sync Stutas_21B
    FOR    ${item}    IN    @{gnss_mode}
        Change_GNSS_Mode_21B    Actual_value=${item}
        wait until keyword succeeds     20min    1min    Check Sync Status    target=primary
        ...    expect_syncInputType=1pps/ToD from external GNSS receiver     expect_isActive=${True}
        Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${True}
        ...    expect_availability=Available    expect_usability=Usable
        Check GNSS Mode_21B    expect_control_mode=${item}    expect_constellation_mode=${item}
    END

Check Sync Status And Web Detail
    [Arguments]    ${expect_isActive}    ${expect_availability}    ${expect_usability}    ${expect_detail_list}
    ...    ${expect_tuningMode}=Normal tuning    ${expect_isActive2}=${True}
    wait until keyword succeeds    5min    20s    Check Sync Status    target=primary    expect_syncInputType=TOPP
    ...    expect_isActive=${expect_isActive}    expect_availability=${expect_availability}    expect_usability=${expect_usability}
    ...    expect_tuningMode=${expect_tuningMode}
    Check Web TOP Synchronization Detail    expect_detail_list=${expect_detail_list}
    run keyword and continue on failure    Check Top PortNumber    brnumber=br0
    Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane
    ...    expect_isActive=${expect_isActive2}    expect_availability=Available    expect_usability=Usable

Stop Catch BTS Log And Check Log
    Stop and collect btslog on local machine
    Check Phase Error

Start Catch BTS Log And Check Log
    Start Catch BTS Log
    sleep    40s
    Stop and collect btslog on local machine
    Check ESelectedClockSource Phase Error

Check Alarm FaultID Contain Expect_alarm
    [Arguments]    ${expect_fault_id}
    Log To Console    Check Alarm FaultID Contain Expect_alarm
    ${fault_id_list}    Get BTS Alarm FaultID
    list should contain value    ${fault_id_list}    ${expect_fault_id}

Check Alarm FaultID Not Contain Expect_alarm
    [Arguments]    ${expect_fault_id}
    Log To Console    Check Alarm FaultID Not Contain Expect_alarm
    ${fault_id_list}    Get BTS Alarm FaultID
    list should not contain value    ${fault_id_list}    ${expect_fault_id}

Check Both Primary Sync Status
    [Arguments]    ${TOPP_isActive}    ${TOPP_Availability}    ${TOPP_Usability}    ${GNSS_isActive}
    Check Sync Status    target=primary    expect_syncInputType=TOPP    expect_isActive=${TOPP_isActive}
    ...    expect_availability=${TOPP_Availability}    expect_usability=${TOPP_Usability}
    Check Sync Status    target=primary    expect_syncInputType=1pps/ToD from external GNSS receiver
    ...    expect_isActive=${GNSS_isActive}    index=${1}

case1_setup
    robot_common_operations.Common case Setup
    Delete Structure2 And Change Sync Input Type    expect_SMOD=SMOD_A-1    synctype=1pps/ToD from external GNSS receiver

case1_teardown
    Add Structure2 And Change Sync Input Type    expect_SMOD=SMOD_A-1    synctype1=1pps/ToD from external GNSS receiver    synctype2=TOPP
#    run keyword and ignore error    CI_interface.Common Case Teardown

case2_setup
    robot_common_operations.Common case Setup
    Delete Structure2 And Change Sync Input Type    expect_SMOD=SMOD_A-1    synctype=TOPP

case2_teardown
    Add Structure2 And Change Sync Input Type    expect_SMOD=SMOD_A-1    synctype1=1pps/ToD from external GNSS receiver    synctype2=TOPP
#    run keyword and ignore error    CI_interface.Common Case Teardown

case3_setup
    robot_common_operations.Common case Setup
    Change Two Sync Input Type    expect_SMOD=SMOD_A-1    synctype1=TOPP    synctype2=1pps/ToD from external GNSS receiver

suite_setup
    CI_interface.Common Suite Setup    
    Setup Commission SCF
    Check BTS Should Be Normal
    Iptables UDP destination port ACCEPT
