# *** Settings ***
# Variables          ./../TestData/5750_nidd_modify.py
# Resource           ./../Resources/5750_keywords.robot
# 
# Documentation    Suite description
# ...   author: Ren Biyao
# ...   contact: biyao.ren@nokia-sbell.com
# ...   squad group: MMW_SG1
# 
# Force Tags    5G_RAN_TDD
# ...    PY36
# Suite Setup     run keywords    Add LNADJGNB on enb side    parameters_to_update_via_api=${ENB2_ADD_LNADJGNB_VIA_API}    enb_index=${1}
# ...                             AND    Suite setup
# 
# Suite Teardown  Run keyword and ignore error    Post suite condition
# 
# *** Test Cases ***
# [1]CB005750_A_09_Cell_deactivation_due_to_all_X2_links_unavailable
#     [Tags]     CRT_21A    CRT_21B    CRT_22R1     CRT_22R2
#     [Documentation]    Author: Ren Biyao
#     ...    The purpose of the test is to check that in NSA mode, cell is deactivated when there is no X2 link available.
#     ...    enb1: tl246 enb    enb2: tl249 enb
#     [Setup]    Common case setup    is_log_required=${True}
#     Lock or unlock x2 link on enb side     parameters_to_update_via_api=${ENB2_LOCK_VIA_API}    enb_index=${1}
#     Connect to Common Unit Master
#     run keyword and ignore error    Connect to Common Unit Slave
#     Connect to gnb coam via ssl
#     Run Keyword And Continue On Failure    Start CP-IF Log Collection
#     Retry commercial ue attach if failed    prepare_ue_needed=${False}    4G_check=${False}
#     ...    ue_type=${UE_TYPE}    ue_index=${0}    retry_time=${2}    detach_request=${False}
#     Disable x2 route from enb
#     Wait until keyword succeeds    6min    5sec   Expect Fault Should Present     faultId=7308
#     ${5Grach_ed}    power_ue.UE Attach    ue_type=${UE_TYPE}
#     Connect to Common Unit Master
#     run keyword and ignore error    Connect to Common Unit Slave
#     ${5750_x2log}    Stop tcpdump log collection    target_dir=${TS_CASE_LOG_PATH}
#     ${STATUS}    run keyword and return status    power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}
#     ...    4G_check=${False}
#     should not be true     ${STATUS}     msg=nsa attach should fail, but succeed.
#     [Teardown]     Run keyword and ignore error    run keywords    Recover x2 route from enb
#     ...    AND    Recover route
#     ...    AND    Post case condition
# 
# [1]CB005750_A_10_Cell_activation_when_at_least_one_X2_link_is_available
#     [Tags]    CRT_TRUNK    CIT_21A    CRT_21B    CRT_22R1     CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1
#     [Documentation]    Author: Ren Biyao
#     ...    The purpose of the test is to check that in NSA mode, cell is activated when at least one X2 link is available
#     [Setup]    Common case setup    is_log_required=${True}
#     Connect to Common Unit Master
#     Connect to gnb coam via ssl
#     Retry commercial ue attach if failed    prepare_ue_needed=${False}    4G_check=${False}
#     ...    ue_type=${UE_TYPE}    ue_index=${0}    retry_time=${2}    detach_request=${False}
#     Lock or unlock x2 link on enb side     parameters_to_update_via_api=${ENB1_LOCK_VIA_API}    enb_index=${0}
#     Disable x2 route from enb    enb_index=${1}
#     wait until keyword succeeds     6min    5sec   X2 should be unavailable
#     Lock or unlock x2 link on enb side     parameters_to_update_via_api=${ENB1_UNLOCK_VIA_API}    enb_index=${0}
#     wait until keyword succeeds     5min    5sec    X2 should be available
#     Wait until cluster is on cell on air status    timeout=5min    is_all_cells_checking_needed=${True}
#     ...    is_x2_check_from_enb_needed=${False}
#     ...    is_enb_status_check_needed=${False}
#     sleep   15s
#     Retry commercial ue attach if failed    prepare_ue_needed=${False}    4G_check=${False}
#     ...    ue_type=${UE_TYPE}    ue_index=${0}    retry_time=${2}     detach_request=${False}
#     [Teardown]     Run keyword and ignore error    run keywords    Recover x2 route from enb   enb_index=${1}
#     ...    AND    Recover route
#     ...    AND    Post case condition
# 
# [1]CB005750_A_11_Endurance_of_cell_activation_and_deactivation
#     [Tags]     CRT_21A    CRT_21B    CRT_22R1     CRT_22R2
#     [Documentation]    Author: Ren Biyao
#     ...    The purpose of the test is to check that in NSA mode, cell is activated when at least one X2 link is available
#     [Setup]    Common case setup    is_log_required=${True}
#     Connect to gnb coam via ssl
#     ${start_time}    DateTime.get current date     result_format=epoch    exclude_millis=True
#     ${end_time}    Evaluate    ${start_time}+${TC11_DURATION}
#     FOR    ${i}    IN RANGE    ${start_time}    ${end_time}
#         Lock or unlock x2 link on enb side     parameters_to_update_via_api=${ENB1_LOCK_VIA_API}    enb_index=${0}
#         Lock or unlock x2 link on enb side     parameters_to_update_via_api=${ENB2_LOCK_VIA_API}    enb_index=${1}
#         ${cell_disable_status}    run keyword and return status
#         ...    wait until keyword succeeds    1 min    5s      Cell Should Be Disabled
#         exit for loop if    ${cell_disable_status}==${False}
#         sleep    15s
#         Lock or unlock x2 link on enb side     parameters_to_update_via_api=${ENB1_UNLOCK_VIA_API}    enb_index=${0}
#         Lock or unlock x2 link on enb side     parameters_to_update_via_api=${ENB2_UNLOCK_VIA_API}    enb_index=${1}
#         ${cell_enable_status}    run keyword and return status
#         ...   Wait until keyword succeeds    10 min    20 sec    Cell Should Be Unlocked
#          exit for loop if    ${cell_enable_status}==${False}
#          sleep     15s
#          ${current_time_stamp}    DateTime.get current date    result_format=epoch    exclude_millis=True
#          exit for loop if    ${current_time_stamp}>${end_time}
#     END
#     should be true     ${cell_disable_status}      mag=cell should be disabled after locking all x2 links!
#     [Teardown]     Run keyword and ignore error    run keywords
#     ...    Lock or unlock x2 link on enb side     parameters_to_update_via_api=${ENB1_UNLOCK_VIA_API}    enb_index=${0}
#     ...    AND     Lock or unlock x2 link on enb side     parameters_to_update_via_api=${ENB2_UNLOCK_VIA_API}    enb_index=${1}
#     ...    AND     Wait until cluster is on cell on air status    timeout=5min    is_all_cells_checking_needed=${True}
#     ...    is_x2_check_from_enb_needed=${False}    is_enb_status_check_needed=${False}
#     ...    AND     Post case condition
