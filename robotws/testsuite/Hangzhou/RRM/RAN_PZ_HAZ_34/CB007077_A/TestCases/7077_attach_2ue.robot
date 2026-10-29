# *** Settings ***
# Resource           ./../Resources/7077_keywords.robot
# 
# 
# Documentation    Suite description
# ...   author: Ren Biyao
# ...   contact: biyao.ren@nokia-sbell.com
# ...   squad group: MMW_SG1
# 
# Force Tags    5G_RAN_TDD
# ...    PY36
# Suite Setup    7077 Suite setup
# Suite Teardown  Run keyword and ignore error    Common suite recovery    is_log_required=${True}
# 
# *** Test Cases ***
# [1]CB007077_A_13_deactivatedOrDisabled_to_be_activeAndEnabled_mixedModeByrecoverySctpX2ThenNG
#     [Tags]    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1     CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1
#     [Documentation]    Author: Ren Biyao
#     ...    This scenario addresses gNB behavior for the case wherein both an associated NG link and an assosiated X2
#     ...    link of a Mixed NSA 3x + SA 2 mode cell are recovered and cell is activated and operational in mixed mode
#     ...    ADD cp: check 5min SA tput, both ul and dl at least 30M
#      [Setup]    Common case setup    is_log_required=${True}
#      Connect to Common Unit Master
#      Connect to gnb coam via ssl
#      COAM Update several parameters via rest api   parameters_to_update_via_api=${CELL_BAR_TIMER_VIA_API}    timeout=6 min
#      Drop ng link
#      Wait until keyword succeeds    6min    2sec   Expect Fault Should Present     faultId=7304
#      wait until keyword succeeds    6min    2sec   Cell should be barred
#      Connect to gnb coam via ssl
#      ${STATUS1}    run keyword and return status      Retry commercial ue attach if failed    prepare_ue_needed=${False}
#      ...    ue_type=${UE_TYPE}    ue_index=${0}    retry_time=${2}    detach_request=${False}
#      run keyword and continue on failure    should be true    ${STATUS1}    msg=NSA attach should succeed, but fails.
#      run keyword and ignore error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
#      Connect to Common Unit Master
#      Recover ng link
#      Wait until keyword succeeds    5min    2sec    Expect Fault Should Absent    faultId=7304
#      wait until keyword succeeds    3min    2sec    Cell should be unbarred
#      sleep    2min
#      Connect to gnb coam via ssl
#      Retry commercial ue attach if failed    prepare_ue_needed=${False}
#      ...    ue_type=${UE_TYPE2}    ue_index=${1}    retry_time=${2}    4G_check=${False}
#      power_ue.Start traffic    ue_index=${1}    direction=ul    throughput=35M    duration=900    ue_type=${UE_TYPE2}
#      ...   process_num=${1}    iperf_type=via_command
#      sleep    1s
#      power_ue.Start traffic    ue_index=${1}    direction=dl    throughput=35M    duration=900    ue_type=${UE_TYPE2}
#      ...   process_num=${1}
#      [Teardown]     run keyword and ignore error    run keywords
#      ...    power_ue.Stop traffic    direction=ul    ue_index=${1}    ue_type=${UE_TYPE2}
#      ...    AND    power_ue.Stop traffic    direction=dl    ue_index=${1}    ue_type=${UE_TYPE2}
#      ...    AND    Post case recovery
# 
# [1]CB007077_A_11_deactivatedOrDisabled_to_be_activeAndEnabled_NSAmodeByrecoverySCTP_port
#    [Tags]    CRT_21A    CRT_21B    CRT_22R1     CRT_22R2
#    [Documentation]    Author: Ren Biyao
#    ...    This scenario addresses gNB behavior for the case wherein an associated X2 link of a Mixed NSA 3x + SA 2
#    ...    mode cell is recovered and cell is activated and operational in NSA mode
#    ...    7308  Transport layer connection failure in X2 interface
#     [Setup]    Common case setup    is_log_required=${True}
#     Connect to Common Unit Master
#     Connect to gnb coam via ssl
#     COAM Update several parameters via rest api   parameters_to_update_via_api=${CELL_BAR_TIMER_VIA_API}
#     COAM Update several parameters via rest api   parameters_to_update_via_api=${DEF_CELL_DEACTIVE_TIMER_VIA_API}
#     Drop ng link
#     Disable x2 route from enb
#     Wait until keyword succeeds    5min    2sec   Expect Fault Should Present     faultId=7308
#     Wait until keyword succeeds    5min    2sec   Expect Fault Should Present     faultId=7304
#     wait until keyword succeeds    8min     2sec    Cell should be deactived and unbarred
#     Connect to gnb coam via ssl
#     ${STATUS2}    run keyword and return status      Retry commercial ue attach if failed    prepare_ue_needed=${False}
#     ...    ue_type=${UE_TYPE2}    ue_index=${1}    retry_time=${1}    4G_check=${False}
#     run keyword and continue on failure    should not be true    ${STATUS2}    msg=SA attach should fail.
#     Recover x2 route from enb
#     Wait until keyword succeeds    6min    2sec    Expect Fault Should Absent    faultId=7308
#     Wait until keyword succeeds    6min    2sec    COAM Check X2 link status from GNB
#     ${STATUS1}    run keyword and return status      Retry commercial ue attach if failed    prepare_ue_needed=${False}
#     ...    ue_type=${UE_TYPE}    ue_index=${0}    retry_time=${2}    detach_request=${False}
#     run keyword and continue on failure    should be true    ${STATUS1}    msg=NSA attach should succeed, but fails.
#     [Teardown]     run keyword and ignore error    Post case recovery
# 
# [1]5GC002478_A_06_Cell_activation_due_to_SCTP_recovery_on_X2_link
#     [Tags]     CRT_22R1    CRT_21B    CRT_22R2    CRT_22R3
#     [Documentation]    Author: Ren Biyao
#     ...    This scenario addresses gNB behavior for the case wherein both an associated NG link and an assosiated X2
#     ...    link of a Mixed NSA 3x + SA 2 mode cell are recovered and cell is activated and operational in mixed mode
#     [Setup]    Common case setup    is_log_required=${True}
#     Connect to Common Unit Master
#     Connect to gnb coam via ssl
#     Lock or unlock AMF on gnb side    parameters_to_update_via_api=${AMF1_LOCK_VIA_API}
#     Lock or unlock AMF on gnb side    parameters_to_update_via_api=${AMF2_LOCK_VIA_API}
#     Lock or unlock x2 link on gnb side    parameters_to_update_via_api=${GNB_LOCK_VIA_API}
#     Connect to gnb coam via ssl
#     COAM Update several parameters via rest api   parameters_to_update_via_api=${CELL_BAR_TIMER_VIA_API}    timeout=6 min
#     Lock or unlock AMF on gnb side    parameters_to_update_via_api=${AMF1_UNLOCK_VIA_API}
#     Lock or unlock AMF on gnb side    parameters_to_update_via_api=${AMF2_UNLOCK_VIA_API}
#     Connect to gnb coam via ssl
#     Wait until keyword succeeds    10 min    2 sec    Cell Should Be Unlocked
#     wait until keyword succeeds    5min    2sec    Cell should be unbarred
#     sleep    60s
#     Connect to Common Unit Master
#     run keyword and ignore error    Connect to Common Unit Slave
#     Run Keyword And Continue On Failure    Start CP-IF Log Collection
#     Connect to gnb coam via ssl
#     ${STATUS2}    run keyword and return status      Retry commercial ue attach if failed    prepare_ue_needed=${False}
#     ...    ue_type=${UE_TYPE2}    ue_index=${1}    retry_time=${2}    4G_check=${False}
#     Connect to Common Unit Master
#     run keyword and ignore error    Connect to Common Unit Slave
#     ${7077_cpif}    Stop tcpdump log collection    target_dir=${TS_CASE_LOG_PATH}
#     Load pcap with filter    filter_expression=ngap    command_template=${PDML_CONVERT_NGAP_TEMPLATE}
#     ...    pcap_file=${7077_cpif}
#     ${TC_pdml}    run keyword and continue on failure    Get pdml log    tcpdump_log=${7077_cpif}
#     Lock or unlock x2 link on gnb side    parameters_to_update_via_api=${GNB_UNLOCK_VIA_API}
#     wait until keyword succeeds     5min    2sec    X2 should be available
#     Wait until cluster is on cell on air status    timeout=5min    is_all_cells_checking_needed=${True}
#     ...    is_x2_check_from_enb_needed=${False}    is_enb_status_check_needed=${False}
#     Connect to gnb coam via ssl
#     ${STATUS1}    run keyword and return status      Retry commercial ue attach if failed    prepare_ue_needed=${False}
#     ...    ue_type=${UE_TYPE}    ue_index=${0}    retry_time=${2}    detach_request=${False}
#     [Teardown]     run keyword and ignore error       run keywords
#     ...    Connect to Common Unit Master
#     ...    AND     Stop trace capturing    log_prefix=TC       connection_alias=ASIK Master
#     ...    AND     Post case recovery    is_need_to_recover_link=${False}
# 
# [1]CB007077_A_18_deactivatedOrDisabled_to_be_activeAndEnabled_mixedModeByunlockMoreAMFThenUnlock_x2linklock
#     [Tags]     CIT_21A    CRT_21B    CRT_22R1    CRT_22R2
#     [Documentation]    Author: Ren Biyao
#     ...    This scenario addresses gNB behavior for the case wherein an associated NG link of a Mixed NSA 3x + SA 2
#     ...    mode cell is recovered and cell is activated and operational in SA mode.
#     ...    covered by [1]CB007077_A_17
#     [Setup]    Common case setup    is_log_required=${True}
#     Connect to Common Unit Master
#     Lock or unlock x2 link on gnb side    parameters_to_update_via_api=${GNB_LOCK_VIA_API}
#     Lock or unlock AMF on gnb side    parameters_to_update_via_api=${AMF1_LOCK_VIA_API}
#     Lock or unlock AMF on gnb side    parameters_to_update_via_api=${AMF2_LOCK_VIA_API}
#     Lock or unlock AMF on gnb side    parameters_to_update_via_api=${AMF1_UNLOCK_VIA_API}
#     Lock or unlock AMF on gnb side    parameters_to_update_via_api=${AMF2_UNLOCK_VIA_API}
#     wait until keyword succeeds    5min    2sec    Cell should be unbarred
#     wait until keyword succeeds     5min    2sec    X2 should be unavailable
#     Connect to gnb coam via ssl
#     ${STATUS1}    run keyword and return status      Retry commercial ue attach if failed    prepare_ue_needed=${False}
#     ...    ue_type=${UE_TYPE}    ue_index=${0}    retry_time=${1}    detach_request=${False}    4G_check=${True}
#     run keyword and continue on failure    should not be true    ${STATUS1}    msg=NSA attach should fail.
#     Connect to Common Unit Master
#     sleep    60s
#     ${STATUS2}    run keyword and return status      Retry commercial ue attach if failed    prepare_ue_needed=${False}
#     ...    ue_type=${UE_TYPE2}    ue_index=${1}    retry_time=${2}    4G_check=${False}
#     [Teardown]     run keyword and ignore error     Post case recovery    is_need_to_recover_link=${False}
# 
# [1]CB007077_A_01_NSAModeCell_FromMixedModeToNSAMode_AllNGLinksDownBylockAMF
#     [Tags]     CRT_21A    CRT_21B    CRT_22R1    CRT_22R2
#     [Documentation]    Author: Ren Biyao
#     ...    The purpose of the test is to check that in NSA mode, cell is deactivated when the only X2 link is locked at gNB.
#     [Setup]    Common case setup    is_log_required=${True}
#     Connect to Common Unit Master
#     Lock or unlock AMF on gnb side    parameters_to_update_via_api=${AMF1_LOCK_VIA_API}
#     Lock or unlock AMF on gnb side    parameters_to_update_via_api=${AMF2_LOCK_VIA_API}
#     Connect to gnb coam via ssl
#     ${STATUS1}    run keyword and return status      Retry commercial ue attach if failed    prepare_ue_needed=${False}
#     ...    ue_type=${UE_TYPE}    ue_index=${0}    retry_time=${2}    4G_check=${False}    detach_request=${False}
#     run keyword and continue on failure    should be true    ${STATUS1}    msg=NSA attach should succeed, but fails.
#     ${STATUS2}    run keyword and return status      Retry commercial ue attach if failed    prepare_ue_needed=${False}
#     ...    ue_type=${UE_TYPE2}    ue_index=${1}    retry_time=${1}    4G_check=${False}
#     run keyword and continue on failure    should not be true    ${STATUS2}    msg=SA attach should fail, but succeeds.
#     [Teardown]        Run keyword and ignore error    Post case recovery    is_need_to_recover_link=${False}
# 
# [1]CB007077_A_02_NSAModeCell_FromMixedModeToNSAMode_AllNGLinksDownByDropSCTP-port
#     [Tags]     CRT_21A    CRT_21B    CRT_22R1
#     [Documentation]    Author: Ren Biyao
#     ...    This scenario addresses gNB behavior for the case wherein all associated NG links of a cell operating in
#     ...    mixed mode fail, but at least one X2 link is available
#     ...    fault id  7304	NG SCTP endpoint broken
#     [Setup]    Common case setup    is_log_required=${True}
#     Connect to Common Unit Master
#     Drop ng link
#     Wait until keyword succeeds    6min    2sec   Expect Fault Should Present     faultId=7304
#     ${STATUS1}    run keyword and return status      Retry commercial ue attach if failed    prepare_ue_needed=${False}
#     ...    ue_type=${UE_TYPE}    ue_index=${0}    retry_time=${2}    4G_check=${False}    detach_request=${False}
#     run keyword and continue on failure    should be true    ${STATUS1}    msg=NSA attach should succeed, but fails.
#     ${STATUS2}    run keyword and return status      Retry commercial ue attach if failed    prepare_ue_needed=${False}
#     ...    ue_type=${UE_TYPE2}    ue_index=${1}    retry_time=${1}    4G_check=${False}
#     run keyword and continue on failure    should not be true    ${STATUS2}    msg=SA attach should fail, but succeeds.
#     [Teardown]     run keyword and ignore error     Post case recovery
# 
# [1]CB007886_01_Cell_Service_Status_Indication_In_Service_SA_mode
#     [Tags]    CRT_TRUNK     CRT_21B    CIT_22R1     CRT_22R2    CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
#     [Documentation]     The purpose of this test case is to test gNB behaviour for handling cell service status
#     ...    indication at the time of SA mode cell set up (In-Service Status).
#     [Setup]     Common case setup    is_log_required=${True}
#     BTS reset and capture cellsetup log     is_all_cells_checking_needed=${True}
#     clean threads before do UE attach    ue_type=${UE_TYPE2}   ue_index=${1}   clean_threads_needed=${True}
#     Retry commercial ue attach if failed    prepare_ue_needed=${False}
#     ...    ue_type=${UE_TYPE2}    ue_index=${1}    retry_time=${2}    4G_check=${False}
#     [Teardown]     run keyword and ignore error     run keywords
#     ...    COAM add several MOs via rest api     objects_to_add_via_api=${ADD_AMF_OBJ}
#     ...    AND    Post case recovery    is_need_to_recover_link=${False}
#     ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'      collect Enb Snapshot Log
#     ...    AND    Common case teardown    is_log_required=${True}
# 
# #[1]CB007886_08_Cell_Service_Status_Indication_OneCell_OutOfService_OneCell_InService_mixed_mode
# #    [Tags]    CRT_21B
# #    [Documentation]     The purpose of this test case is to test gNB behaviour for handling cell service status
# #    ...    indication at the time of mixed(SA+NSA) mode cell set up (one cell In-Service and one cell Out-Of-Service).
# #    [Setup]     coam create log directory
# #    ${PARAMS_MOD_ALL}   combine lists       ${PARAMS_TO_MODIFY}    ${TL_PARAMS_TO_MODIFY_SA}    ${TL_PARAMS_TO_MODIFY_CELLS}
# #    ${PARAMS_ADD_ALL}    combine lists    ${PARAMS_TO_ADD}    ${TL_PARAMS_TO_ADD_CELL2}
# #    ${TC7886_08}    scfpro.SCFProcess    scf_template_path=/home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${MRBTS_ID}_step2.xml
# #    ...   scf_process_folder=${TS_CASE_LOG_PATH}
# #    ...    list_para_to_delete=${PARAMS_TO_DELETE}    list_para_to_modify=${PARAMS_MOD_ALL}    list_para_to_add=${PARAMS_ADD_ALL}
# #    Preparation with swconfig modification and comissioning    swconfig_modify=${None}     is_called_in_test_case_level=${True}
# #    ...    is_pdl_checking_needed=${False}    scf_template_path=${TC7886_08}
# #    run keyword and continue on failure    Wait until cluster is on cell on air status    timeout=5min    is_all_cells_checking_needed=${False}
# #    ...    is_x2_check_from_enb_needed=${False}    is_enb_status_check_needed=${False}
# #    BTS reset and capture cellsetup log     is_all_cells_checking_needed=${False}
# #    [Teardown]      run keyword and ignore error     Post case recovery    is_need_to_recover_link=${False}
