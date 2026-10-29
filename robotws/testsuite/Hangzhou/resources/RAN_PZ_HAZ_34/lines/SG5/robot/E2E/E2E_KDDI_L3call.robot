*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         400 min

Resource    resources/e2e_common_cases_l3call.robot

Documentation
...    Author:Zhaojun Chen
...    contact:zhaojun.chen@nokia-sbell.com
...    squad group:SG_05
...    Feature CB007835-5G-A: Key customer scenario testing - KDDI cmWave in 22R1 program
...    Configuration blocks: FR1-FR2 mixed

Force Tags    5G_RAN_TDD
...   PY27

*** Variables ***
@{list_RU_index_to_Test}      1      # 1       2
@{list_RU_type_to_Test}       AZQJ   # AZQJ    AEQE

*** Test Cases ***
[1][1.0] E2E_gNB_SiSo_RU_lock_and_unlock_by_RadioIndex_l3call
    [Documentation]
    ...    *************************************************************
    ...    operate RU lock and unlock by RU index and check l3call
    ...    *************************************************************
    ...    ru_index:            #RU or RUs to be tested
    ...    with_call:           #l3call before & after RU lock/unlock; ignore following arguments if ${False}
   #...    with_peak=${False}   #TBD
    ...    cell_id:             #str; cell to make l3call; start from 1
    ...    ue_index:            #str; ue to make l3call in one cell; start from 0
    ...    ue_number:           #str; ue number to make l3call in one cell; start from 1
    ...    ui_version:          #UI version for samsung; used to initialize pointer variable
    ...    iperf_type:          #start ul traffic via_app for commercial ue other than via_command
    ...    protocol:            #traffic type is upd other than tcp
    ...    call_duration:       #str; call duration; unit is second (s)
    ...    dl_tp:               #used for DL iperf command; can be larger than theory peak tput
    ...    ul_tp:               #used for UL iperf command; can be larger than theory peak tput
    ...    dl_exp:              #DL expect tput; dl_exp=peak_dl_tp=peak from NRDIM if ${with_peak}=${True}
    ...    ul_exp:              #UL expect tput; Ul_exp=peak_ul_tp=peak from NRDIM if ${with_peak}=${True}
    ...    target_avg_percent:  #used to check real UL/DL AVG tput; pass if UE tput >= dl_exp(and ul_exp)*target_avg_percent
    ...    min_percent:         #used to check real UL/DL min tput; pass if UE tput >= dl_exp(and ul_exp)*min_percent
    ...    cell_and_peak_info:  #self defined dl_exp;ul_exp;avg_expect_rate=target_avg_percent;min_expect_rate=min_percent
    #if ${True} from generated peak info (NRDIM): dl_exp;ul_exp; and dl_expavg_expect_rate=0.9, min_expect_rate=0.8 by default
    [Tags]    E2E_22R1
    FOR  ${RU_index_to_Test}  IN  @{list_RU_index_to_Test}
        Run Keyword   E2E_gNB_SiSo_RU_lock_and_unlock_by_RadioIndex_l3call
        ...    ru_index=${RU_index_to_Test}
        ...    with_call=${True}
   #    ...    with_peak=${False}
        ...    cell_id=${1}
        ...    ue_index=${0}
        ...    ue_number=${1}
        ...    ui_version=S21UI3.1
        ...    iperf_type=via_app
        ...    protocol=udp
        ...    call_duration=${120}
        ...    dl_tp=1600M
        ...    ul_tp=100M
        ...    dl_exp=1200
        ...    ul_exp=70
        ...    target_avg_percent=0.1
        ...    min_percent=0.1
        ...    cell_and_peak_info=${None}
    END

[1][1.0] E2E_gNB_SiSo_cell_block_and_unblock_by_RadioIndex_l3call
    [Tags]    E2E_22R1
    FOR  ${RU_index_to_Test}  IN  @{list_RU_index_to_Test}
        Run Keyword   E2E_gNB_SiSo_cell_block_and_unblock_by_RadioIndex_l3call
        ...    ru_index=${RU_index_to_Test}
        ...    with_call=${True}
   #    ...    with_peak=${False}
        ...    cell_id=${1}
        ...    ue_index=${0}
        ...    ue_number=${1}
        ...    ui_version=S21UI3.1
        ...    iperf_type=via_app
        ...    protocol=udp
        ...    call_duration=${120}
        ...    dl_tp=1600M
        ...    ul_tp=100M
        ...    dl_exp=1200
        ...    ul_exp=70
        ...    target_avg_percent=0.1
        ...    min_percent=0.1
        ...    cell_and_peak_info=${None}
    END

[1][1.0] E2E_gNB_SiSo_RF_module_power_reset_by_RadioIndex_l3call
    [Tags]    E2E_22R1
    FOR  ${RU_index_to_Test}  IN  @{list_RU_index_to_Test}
        Run Keyword   E2E_gNB_SiSo_RF_module_power_reset_by_RadioIndex_l3call
        ...    ru_index=${RU_index_to_Test}
        ...    with_call=${True}
   #    ...    with_peak=${False}
        ...    cell_id=${1}
        ...    ue_index=${0}
        ...    ue_number=${1}
        ...    ui_version=S21UI3.1
        ...    iperf_type=via_app
        ...    protocol=udp
        ...    call_duration=${120}
        ...    dl_tp=1600M
        ...    ul_tp=100M
        ...    dl_exp=1200
        ...    ul_exp=70
        ...    target_avg_percent=0.1
        ...    min_percent=0.1
        ...    cell_and_peak_info=${None}
    END

[1][1.0] E2E_gNB_SiSo_RF_module_reset_from_WebEM_by_RadioIndex_l3call
    [Tags]    E2E_22R1
    FOR  ${RU_index_to_Test}  IN  @{list_RU_index_to_Test}
        Run Keyword   E2E_gNB_SiSo_RF_module_reset_from_WebEM_by_RadioIndex_l3call
        ...    ru_index=${RU_index_to_Test}
        ...    with_call=${True}
   #    ...    with_peak=${False}
        ...    cell_id=${1}
        ...    ue_index=${0}
        ...    ue_number=${1}
        ...    ui_version=S21UI3.1
        ...    iperf_type=via_app
        ...    protocol=udp
        ...    call_duration=${120}
        ...    dl_tp=1600M
        ...    ul_tp=100M
        ...    dl_exp=1200
        ...    ul_exp=70
        ...    target_avg_percent=0.1
        ...    min_percent=0.1
        ...    cell_and_peak_info=${None}
    END

#[1][1.0] E2E_gNB_SiSo_RU_lock_and_unlock_by_RadioType_l3call
#    [Tags]    E2E_22R1
#    FOR  ${RU_type_to_Test}  IN  @{list_RU_type_to_Test}
#        Run Keyword   E2E_gNB_SiSo_RU_lock_and_unlock_by_RadioType_l3call
#        ...    RU_type=${RU_type_to_Test}
#        ...    with_call=${True}
#   #    ...    with_peak=${False}
#        ...    cell_id=${1}
#        ...    ue_index=${0}
#        ...    ue_number=${1}
#        ...    ui_version=S21UI3.1
#        ...    iperf_type=via_app
#        ...    protocol=udp
#        ...    call_duration=${120}
#        ...    dl_tp=1600M
#        ...    ul_tp=100M
#        ...    dl_exp=1200
#        ...    ul_exp=70
#        ...    target_avg_percent=0.1
#        ...    min_percent=0.1
#        ...    cell_and_peak_info=${None}
#    END
#
#[1][1.0] E2E_gNB_SiSo_cell_block_and_unblock_by_RadioType_l3call
#    [Tags]    E2E_22R1
#    FOR  ${RU_type_to_Test}  IN  @{list_RU_type_to_Test}
#        Run Keyword   E2E_gNB_SiSo_cell_block_and_unblock_by_RadioType_l3call
#        ...    RU_type=${RU_type_to_Test}
#        ...    with_call=${True}
#   #    ...    with_peak=${False}
#        ...    cell_id=${1}
#        ...    ue_index=${0}
#        ...    ue_number=${1}
#        ...    ui_version=S21UI3.1
#        ...    iperf_type=via_app
#        ...    protocol=udp
#        ...    call_duration=${120}
#        ...    dl_tp=1600M
#        ...    ul_tp=100M
#        ...    dl_exp=1200
#        ...    ul_exp=70
#        ...    target_avg_percent=0.1
#        ...    min_percent=0.1
#        ...    cell_and_peak_info=${None}
#    END

[1][1.0] E2E_gNB_SiSo_RF_module_power_reset_by_RadioType_l3call
    [Tags]    E2E_22R1
    FOR  ${RU_type_to_Test}  IN  @{list_RU_type_to_Test}
        Run Keyword   E2E_gNB_SiSo_RF_module_power_reset_by_RadioType_l3call
        ...    RU_type=${RU_type_to_Test}
        ...    with_call=${True}
   #    ...    with_peak=${False}
        ...    cell_id=${1}
        ...    ue_index=${0}
        ...    ue_number=${1}
        ...    ui_version=S21UI3.1
        ...    iperf_type=via_app
        ...    protocol=udp
        ...    call_duration=${120}
        ...    dl_tp=1600M
        ...    ul_tp=100M
        ...    dl_exp=1200
        ...    ul_exp=70
        ...    target_avg_percent=0.1
        ...    min_percent=0.1
        ...    cell_and_peak_info=${None}
    END

[1][1.0] E2E_gNB_SiSo_RF_module_reset_from_WebEM_by_RadioType_l3call
    [Tags]    E2E_22R1
    FOR  ${RU_type_to_Test}  IN  @{list_RU_type_to_Test}
        Run Keyword   E2E_gNB_SiSo_RF_module_reset_from_WebEM_by_RadioType_l3call
        ...    RU_type=${RU_type_to_Test}
        ...    with_call=${True}
   #    ...    with_peak=${False}
        ...    cell_id=${1}
        ...    ue_index=${0}
        ...    ue_number=${1}
        ...    ui_version=S21UI3.1
        ...    iperf_type=via_app
        ...    protocol=udp
        ...    call_duration=${120}
        ...    dl_tp=1600M
        ...    ul_tp=100M
        ...    dl_exp=1200
        ...    ul_exp=70
        ...    target_avg_percent=0.1
        ...    min_percent=0.1
        ...    cell_and_peak_info=${None}
    END

[1][1.0] E2E_gNB_SiSo_site_power_reset_l3call
    [Tags]    E2E_22R1
    E2E_gNB_SiSo_site_power_reset_l3call
    ...    ru_index=${1}
    ...    with_call=${True}
   #...    with_peak=${False}
    ...    cell_id=${1}
    ...    ue_index=${0}
    ...    ue_number=${1}
    ...    ui_version=S21UI3.1
    ...    iperf_type=via_app
    ...    protocol=udp
    ...    call_duration=${120}
    ...    dl_tp=1600M
    ...    ul_tp=100M
    ...    dl_exp=1200
    ...    ul_exp=70
    ...    target_avg_percent=0.1
    ...    min_percent=0.1
    ...    cell_and_peak_info=${None}

[1][1.0] E2E_gNB_SiSo_site_software_reset_l3call
    [Tags]    E2E_22R1
    E2E_gNB_SiSo_site_software_reset_l3call
    ...    ru_index=${1}
    ...    with_call=${True}
   #...    with_peak=${False}
    ...    cell_id=${1}
    ...    ue_index=${0}
    ...    ue_number=${1}
    ...    ui_version=S21UI3.1
    ...    iperf_type=via_app
    ...    protocol=udp
    ...    call_duration=${120}
    ...    dl_tp=1600M
    ...    ul_tp=100M
    ...    dl_exp=1200
    ...    ul_exp=70
    ...    target_avg_percent=0.1
    ...    min_percent=0.1
    ...    cell_and_peak_info=${None}

*** Keywords ***
