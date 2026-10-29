# *** Settings ***
# Force Tags    PY36
# Documentation
# ...   author: zheyuan.chen@nokia-sbell.com
# ...   contact: zheyuan.chen@nokia-sbell.com
# ...   Sync
# 
# Suite Setup       Suite Setup
# Suite Teardown    Suite Teardown
# 
# Resource    resources/trans_comm.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Test Cases ***
# [1]5GC002377-FA_02_Phase_Sync_Declare_Synchronization_with_ToPP_1st_and_SHM_2nd_via_WebUI
#     [Documentation]
#     ...    Declare (via WebUI, by manuel databsemodification) Flexible Input Synchronization,TOPP  with Priority 1
#     ...    SHM with Priority 2
#     ...    -12.11.2020,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_20B    5GC002377_319    CRT_21B
#     [Setup]
#     Check BTS Should Be Normal
#     Change Sync Input Priority    syncInputPrio1=2    syncInputPrio2=1
#     Check Syncs Status    expect_syncInputType1=TOPP    expect_syncInputType2=1pps/ToD from external GNSS receiver
#     ...    expect_isActive1=${True}    expect_isActive2=${False}    expect_availability1=Available   expect_availability2=Available
#     ...    expect_usability1=Usable    expect_usability2=Usable    expect_tuningMode=Normal tuning
#     Check BTS Should Be Normal
#     [Teardown]    case1 teardown
# 
# [1]5GC002377-FA_05_Phase_Sync_Power_On_with_all_sync_inputs_available
#     [Documentation]
#     ...    Power On NodeB with all synch source available
#     ...    Check NodeB synchronize on Highest priority source
#     ...    -12.11.2020,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_20B    5GC002377_319    CRT_21B
#     [Setup]
#     Check BTS Should Be Normal
#     Check Syncs Status    expect_syncInputType1=1pps/ToD from external GNSS receiver    expect_syncInputType2=TOPP
#     ...    expect_isActive1=${True}    expect_isActive2=${False}    expect_availability1=Available   expect_availability2=Available
#     ...    expect_usability1=Usable    expect_usability2=Usable    expect_tuningMode=Normal tuning
#     Power Off DU And Wait Until DU Up
#     Check GNSS Fisrt Recovery And TOPP Second Recovery
#     sleep    5min
#     Check BTS Should Be Normal
#     [Teardown]   CI_interface.Common Case Teardown
# 
# [1]5GC002377-FA_10_Phase_Sync_Change_priority
#     [Documentation]
#     ...    change priority level of déclared synchro source
#     ...    Check Active synchronization move to the new highest priority source declared
#     ...    -12.11.2020,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_20B    CRT_TRUNK    5GC002377_319   CRT_21B
#     [Setup]
#     Check BTS Should Be Normal
#     Log To Console    Change TOPP To syncInputPriority1
#     Change Sync Input Priority    syncInputPrio1=2    syncInputPrio2=1
#     Check Syncs Status    expect_syncInputType1=TOPP    expect_syncInputType2=1pps/ToD from external GNSS receiver
#     ...    expect_isActive1=${True}    expect_isActive2=${False}    expect_availability1=Available   expect_availability2=Available
#     ...    expect_usability1=Usable    expect_usability2=Usable    expect_tuningMode=Normal tuning
#     Check BTS Should Be Normal
#     Log To Console    Change GNSS To syncInputPriority1
#     Change Sync Input Priority    syncInputPrio1=1    syncInputPrio2=2
#     Check Syncs Status    expect_syncInputType1=1pps/ToD from external GNSS receiver    expect_syncInputType2=TOPP
#     ...    expect_isActive1=${True}    expect_isActive2=${False}    expect_availability1=Available   expect_availability2=Available
#     ...    expect_usability1=Usable    expect_usability2=Usable    expect_tuningMode=Normal tuning
#     Check BTS Should Be Normal
#     [Teardown]    CI_interface.Common Case Teardown
# 
# *** Keywords ***
# case1 teardown
#     Log To Console    case1 teardown
#     Change Sync Input Priority    syncInputPrio1=1    syncInputPrio2=2
#     Check Syncs Status    expect_syncInputType1=1pps/ToD from external GNSS receiver    expect_syncInputType2=TOPP
#     ...    expect_isActive1=${True}    expect_isActive2=${False}    expect_availability1=Available   expect_availability2=Available
#     ...    expect_usability1=Usable    expect_usability2=Usable    expect_tuningMode=Normal tuning
#     CI_interface.Common Case Teardown
# Suite Setup
#     TRANS Common Setup
#     Add And Change Sync Input Type    synctype1=1pps/ToD from external GNSS receiver     synctype2=TOPP
# 
# Suite Teardown
#     Delete And Change Sync Input Type    synctype=1pps/ToD from external GNSS receiver
#     TRANS Common Teardown
