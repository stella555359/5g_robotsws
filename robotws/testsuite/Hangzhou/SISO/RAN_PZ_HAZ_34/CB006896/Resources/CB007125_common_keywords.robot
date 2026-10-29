*** Settings ***
Documentation
...    author: Qing Kang
...    contact: qing.kang.ext@nokia-sbell.com
...    squad group: SG_08
...    feature : CB007125

#Resource   ../../../SRAN/resources/common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000733/Resources/5GC000733_common_keyword.robot

Library    DateTime
#Library     robot.libraries.DateTime

*** Variables ***
${MAX_LOOP}    2   #20

*** Keywords ***
Webui reset RU
    [Arguments]
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
       Perform RU Reset    ru_index=${ru_index}
       sleep   30s
    END

Verify cell Onair status
    [Arguments]
    wait until keyword succeeds    15 min    10 sec     Verify all cells should be onair

interger calculate
    [Arguments]    ${input_number}=0
    ${input_number}=    Convert To Integer    ${input_number}
    ${input_number}    Evaluate    ${input_number}+1
    Set Test Variable    ${fail_count}    ${input_number}
    [Return ]    ${fail_count}

calculate cell not onair times
    [Arguments]
    ${status}    run keyword and return status    Verify cell Onair status
    log    ${status}
    Run Keyword If    '${status}'=='False'
    ...    interger calculate    input_number=${fail_count}
    log    ${fail_count}

KPI Reset multiple RU from webui_AHPF
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this keyword is reset multiple RU from webui with KPI count
    [Arguments]
    FOR    ${count}    IN RANGE    3     #34
       Webui reset RU
       calculate cell not onair times
    END

OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_AHPF
    Set Test Variable    ${fail_count}    0
    KPI Reset multiple RU from webui_AHPF
    log    ${fail_count}
    should be true     ${fail_count}<2

OAM_KPI_61a_SiSo_Auto_BTS_site_reset_AHPF
    [Tags]    CRT_21A    CRT_TRUNK
    ${gnb_type}    Set Variable      ${gNb_CuType}
    FOR    ${TEST_LOOP}    IN RANGE    0  ${MAX_LOOP}
        Set Global Variable                              ${TEST_LOOP}
        ${date}=                                         Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
        Log To Console                                   \n GNB Reset Iteration ${TEST_LOOP} in progress at: ${date}
        Perform BTS Site Reset
        Sleep                                            30s
        COAM Wait for gnb ready and cell setup    timeout=10min    gnb_type='${gnb_type}'
    END
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}

General_SiSo_RU_lock_unlock_AHPF
    ${start_time}    get current date
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${ru_index_list}    Get All RU Index
    ${cell_list}    Get All Cell Id
    ${ue_num}    checkuenumber    ${tl.ues}
    log to console    ${ue_num}
    sort list    ${cell_list}
    run keyword and continue on failure    Lock all RUs and check all status_AHPF    ru_index_list=${ru_index_list}
    ...    cell_list=${cell_list}    gnb_type='${gNb_CuType}'    ue_num=${ue_num}
    Close Start Up View    timeout=60
    UnLock all RUs and check all status_AHPF    ru_index_list=${ru_index_list}    cell_list=${cell_list}
    ...   gnb_type='${gNb_CuType}'    start_time=${start_time}    ue_num=${ue_num}
    run keyword if    '${gNb_CuType}'=='NSA'    start traffic all cells nsa_AHPF    cell_list=${cell_list}
    run keyword if    '${gNb_CuType}'=='SA'     start traffic all cells sa_AHPF     cell_list=${cell_list}
    ...    ue_num=${ue_num}
    [Teardown]    Run Keywords    excute ru unlock    ru_index_list=${ru_index_list}    AND
    ...    Selenium Logout And Close Browser

start traffic all cells sa_AHPF
    [Documentation]
    ...    *****************
    ...    Owner_zhenzhen.ren@nokia-sbell.com
    ...    ******************
    [Arguments]    ${cell_list}    ${ue_num}
    log to console    \n***start traffic all cells sa***
    Get UE From Init File and Make call    cell_list=${cell_list}    random_access=${True}
    ...    ue_num_each_call=${ue_num}    duration=100

start traffic all cells nsa_AHPF
    [Arguments]    ${cell_list}
    FOR    ${cell_id}  IN  @{cell_list}
        ${cell_id_list}    create list    ${cell_id}
        Get UE From Init File and Make call    cell_list=${cell_id_list}    duration=100
    END

UnLock all RUs and check all status_AHPF
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] UnLock all RUs and check all status
    ...    Author: zhenzhen.ren@nokia-sbell.com
    ...    *****************
    [Arguments]  ${start_time}    ${ru_index_list}    ${cell_list}    ${ue_num}    ${gnb_type}='${gNb_CuType}'
    ...   ${check_alarm}=${True}    ${with_call}=${True}
    log to console  \n**UnLock all RUs and check all status***
    ${led_status_list}    create list   GREEN GREEN
    FOR  ${ru_index}  IN  @{ru_index_list}
        Collect RF Logs To TestPC    log_name=before_ru_unlock    ru_index=${ru_index}
        ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status    log_name=before_ru_unlock
        ${status}    run keyword and return status  Expect Fault Should Present    faultId=4687
        selenium_coam.unlock_ru    ru_index=${ru_index}
        sleep  15
        Run Keyword If  ${status}==${True}    wait until keyword succeeds    10min    20sec    RU Should Be Offline    ru_index=${ru_index}
        wait until keyword succeeds    10min    20sec    RU Should Be Online    ru_index=${ru_index}
        Run Keyword If  ${status}==${False}    Check LED Status In RU Log    led_status_list=${led_status_list}    log_name=after_ru_unlock
        ...    ru_index=${ru_index}    timestamp=${new_timestamp}    exclude_led_status=YELLOW YELLOW
        Download Soap and Check Ru Lock Unlock Message    type=unlock    ru_index=${ru_index}
        Run Keyword If  ${status}==${False}    Check file Exist in RU    ru_index=${ru_index}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        sort list    ${cell_id_ru}
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be enabled    cell_list=${cell_id_ru}
#        run keyword if    ${gnb_type}=='NSA' and ${with_call}    start traffic all cells nsa    cell_list=${cell_id_ru}
#        run keyword if    ${gnb_type}=='SA' and ${with_call}     start traffic all cells sa     cell_list=${cell_id_ru}
#        ...    ue_num=${ue_num}
    END
    Connect to gnb coam via ssl
    FOR  ${ru_index}  IN  @{ru_index_list}
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${ru_index}
    END
    wait until keyword succeeds    5min    20sec    Cell status Should Be enabled    cell_list=${cell_list}
    run keyword if    ${check_alarm}==${True} and ${gnb_type}=='NSA'
    ...  Wait until keyword succeeds  5min  20sec  Expect Fault Should Absent    faultId=7300

Lock all RUs and check all status_AHPF
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] Lock all RUs and check all status
    ...    Author: zhenzhen.ren@nokia-sbell.com
    ...    *****************
    [Arguments]  ${ru_index_list}    ${cell_list}    ${ue_num}    ${gnb_type}='${gNb_CuType}'
    ...    ${check_alarm}=${True}    ${with_call}=${True}
    log to console  \n**Lock all RUs and check all status***
    ${led_status_list_lock}    create list    YELLOW YELLOW
    ${cell_list_new}    samelist    ${cell_list}
    FOR  ${ru_index}  IN  @{ru_index_list}
        Create file in RU    ru_index=${ru_index}
        Collect RF Logs To TestPC    log_name=before_ru_lock    ru_index=${ru_index}
        ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status    log_name=before_ru_lock
        selenium_coam.lock_ru    ru_index=${ru_index}
        sleep  15
        Check LED Status In RU Log    led_status_list=${led_status_list_lock}    log_name=after_ru_lock
        ...    ru_index=${ru_index}    timestamp=${new_timestamp}    exclude_led_status=GREEN GREEN
        Download Soap and Check Ru Lock Unlock Message    type=lock    ru_index=${ru_index}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be Disabled    cell_list=${cell_id_ru}
        ${flag}    ${cell_list_new}    getusefulid    ${cell_id_ru}    ${cell_list_new}
        sort list    ${cell_list_new}
#        run keyword if    ${flag}==1 and ${gnb_type}=='NSA' and ${with_call}   start traffic all cells nsa
#        ...    cell_list=${cell_list_new}
#        run keyword if    ${flag}==1 and ${gnb_type}=='SA' and ${with_call}    start traffic all cells sa
#        ...    cell_list=${cell_list_new}    ue_num=${ue_num}
    END
    Connect to gnb coam via ssl
    FOR  ${ru_index}  IN  @{ru_index_list}
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
    END
    wait until keyword succeeds    5min    20sec    Cell status Should Be Disabled    cell_list=${cell_list}
    sleep    ${X2_link_shutdown_time}min
    run keyword if    ${check_alarm}==${True} and ${gnb_type}=='NSA'
    ...    Wait until keyword succeeds    2min    20sec    Expect Fault Should Present    faultId=7300

General_SiSo_Cell_lock_and_unlock_AHPF
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify cell and group cell lock/ unlock functionality
    ...      during normal operation (OnAir state).
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 02.19.2020 - - Created
    ...    *******************
    ...    Notice: if cell group has servals cell, get ue failed
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    Lock and Unlock Cells or Groups and L3_AHPF  lock_list=${cell_id_list}  is_group=${False}
#    Connect to gnb coam via ssl
#    ${cellgrp_id_list}  Get All Cell Group Id
#    ${cellgrp_num}    get length  ${cellgrp_id_list}
#    Lock and Unlock Cells or Groups and L3_AHPF  lock_list=${cellgrp_id_list}  is_group=${True}
    run keyword if  ${cell_num}>1  Lock and Unlock all Cells or Groups  lock_list=${cell_id_list}  is_group=${False}
#    run keyword if  ${cellgrp_num}>1  Lock and Unlock all Cells or Groups  lock_list=${cellgrp_id_list}  is_group=${True}
    [Teardown]   Selenium Logout And Close Browser

Lock and Unlock Cells or Groups and L3_AHPF
    [Arguments]  ${lock_list}  ${is_group}=${True}
    ${lock_num}    get length  ${lock_list}
    FOR  ${lock_id}  IN  @{lock_list}
        ${check_alarm}  set variable if  ${lock_num}==1  ${True}  ${False}
        ${lock_list}    create list  ${lock_id}
        Lock cells or groups and check status  lock_list=${lock_list}  is_group=${is_group}  check_alarm=${check_alarm}  gnb_type='${gNb_CuType}'
        Close Start Up View    timeout=60
        Unlock cells or groups and check status  lock_list=${lock_list}  is_group=${is_group}  check_alarm=${check_alarm}  gnb_type='${gNb_CuType}'
        ${cell_list}    run keyword if  ${is_group}    Get Cell From Cell Group  cellgrp_id=${lock_id}
        ...    ELSE   set variable  ${lock_list}
        Get UE From Init File and Make call    cell_list=${cell_list}
    END

General_SiSo_E2E_system_setup_with_data_transfer_for_AHPF
    [Arguments]  ${ul_tp}    ${dl_tp}    ${ul_exp}    ${dl_exp}    ${duration}=${600}
    ${release}    Get program version based on gNB active version
    ${status}    run keyword and return status    variable should exist    ${rate_for_stream}
    @{dict_keys}    run keyword if    ${status}    Get Dictionary Keys    ${rate_for_stream}
    ${case_rate}    run keyword if    '${release}' in @{dict_keys}    get from dictionary    ${rate_for_stream}    ${release}
    ...    ELSE    set variable    ${0.95}
    ${case_rate}    run keyword if   '${case_rate}'=='peak'    set variable    ${0.95}
    ...    ELSE    set variable    ${case_rate}
    ${status}    run keyword and return status    variable should exist    ${rate_for_stream_min}
    @{dict_keys}    run keyword if    ${status}    Get Dictionary Keys    ${rate_for_stream_min}
    ${case_rate_min}    run keyword if    '${release}' in @{dict_keys}    get from dictionary    ${rate_for_stream_min}    ${release}
    ...    ELSE    set variable    ${0.85}
    UE L3 Call And Throughput
    ...           ul_tp=${ul_tp}
    ...           dl_tp=${dl_tp}
    ...           ul_exp=${ul_exp}
    ...           dl_exp=${dl_exp}
    ...           target_avg_percent=${case_rate}
    ...           min_percent=${case_rate_min}
    ...           duration=${duration}

Check MCS Send To L1 By Paging AHPF
    [Documentation]   Author:lanwen.cai@nokia-sbell.com
    ...               Checkpoint:MCS is sent to L1 ABIL by paging.
    ...               Comment: use condition bip.rnti == 65534 filter Paging message
    [Arguments]    ${cell_mcs}=0    ${scaling_factor}=SF2    ${list_abil_index}=1    ${bb_slot_2}=false
    ...            ${luashark_path}=/home/ute/luashark/luashark.lua    ${arb_name}=arb0p1    ${pdsch_subtree}=PdschSendReq
    ...            ${ue_index}=${0}    ${dl_throughput}=5M
    ...            ${bb_slot_1}=true    ${bb_slot_2}=false    ${bb_slot_5}=false
    ${ue_pdu1_ip}      Start UE Attach And Check Idle Status    loopindex=${cell_mcs}
    Start CP-IF Log Collection    tcpdump_collector_name=cpif_pagging   asik_connection_alias=ASIK Master
    ...                           gnb_index=${0}    du_index=${0}
    Bip Capture with gnbMirroring scripts with retry    file_size_mbytes=200    number_of_files=1
    ...    bb_slot_1=${bb_slot_1}    bb_slot_2=${bb_slot_2}    bb_slot_5=${bb_slot_5}
    log to console    \n***Start traffic***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=5M
    ...    duration=${1800}
    Sleep    30 sec
#    ${bip_log}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
#    ...    log_prefix=ue_bip_paging_loop${cell_mcs}
#    ...    asib_interface=eths3
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
	${cpif_pagging_log_on_testPC}    Stop tcpdump log collection    tcpdump_collector_name=cpif_pagging
#    Check Paging Send On NGAP    wireshark_log=${cpif_pagging_log_on_testPC}    tac=270

Start UE Attach And Check Idle Status
    [Documentation]   Author: lanwen.cai@nokia-sbell.com
    ...               Description: This keyword is used to do UE attach and waiting UE go into idle status.
    [Arguments]    ${loopindex}=0    ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Start CP-IF Log Collection    tcpdump_collector_name=cpif_attach    asik_connection_alias=ASIK Master
    ...                           gnb_index=${0}    du_index=${0}
    ...                           options=-i any '((sctp) and ((port 38472) or (port 38412)))' -s 0
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Run keyword if    '${gNb_CuType}'=='NSA'    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}
    ...    ue_index=${ue_index}    ELSE    power_ue.Verify attach
    ...    ue_type=${ue_type}    4G_check=False    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}
#    ${srbinactivity_timer}    Get srbInactivityTimerSA Timer From SCF
#    Sleep    ${srbinactivity_timer} sec
    Sleep    15 sec
	${cpif_attach_log_on_testPC}    Stop tcpdump log collection    tcpdump_collector_name=cpif_attach
#    Check UE Enter RRC Idle State    wireshark_log=${cpif_attach_log_on_testPC}
#    ${ue_pdu1_ip}    Get Pdu IP via Pcap    wireshark_log=${cpif_attach_log_on_testPC}
#    [Return]    ${ue_pdu1_ip}
