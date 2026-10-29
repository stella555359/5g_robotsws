*** Settings ***
Library      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/TestData/overheat.py
Library      overheat.Overheat_operate    WITH NAME    Overheat
Resource    ./../../CB007873/Resources/CB007873_keywords.robot

Documentation    Suite description
...   author: Cui Lingue
...   contact: lingxue.cui@nokia-sbell.com
...   squad group: MMW_SG1
...   Feature 5GC001390-G/-EE

Force Tags    5G_RRM
...    PY36
Suite Setup     7873 Suite preparation
Suite Teardown  run keyword and ignore error    CA Suite teardown

*** Test Cases ***
#[1]5GC001390_G_B7_1007_Cell_Unlock_of_TDD_Cell_and_Blind_Scell_activation_SA
#    [Tags]    CRT_21A    CIT_21B
#    [Documentation]    Author: Cui Lingxue
#    ...    Description: The purpose of this test case is to verify GNB’s supporting of the Cell Unlock is performed on the TDD cell which is
#    ...                 the SCell for UEs capable of Carrier Aggregation.
#    ...                 after lock scell, need check
#    ...                   1. UE release from TDD by message 'RRC Reestablishment Request'.
#    ...                      sometimes no this msg: RRC Reestablishment Request filter is (f1ap.procedureCode == 11) && (nr-rrc.c1 == 2)
#    ...                      need to check NGRest message: (ngap.procedureCode == 20) && (ngap.Cause == 0)
#    ...                   2. re-attach to FDD, UE not changed, need to check throughput on pcell
#    ...                 after unlock scell, need check
#    ...                   1. no TP on scell
#    ...                   2. check TP on pcell.
#    ...                  detach and attach and start traffic, there are dl throughput on pcell and secll. ul throughput on pcell.
#    [Setup]    run keywords    Common case setup    NSA_SA=SA    AND
#    ...    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${PCELL_ID}
##    CA_basic_L3_call
#    log to console    step1: attach to FDD, verify CA and start UDP traffic
#    Sleep    30s   reason=add some sleep time between bar tdd cell and attach
#    UE attach to FDD cell and verify CA    wa_flag=${False}    4G_check=${False}
#    ...    check_counter=${False}    scell_addition_method=blind    ue_index=${0}    tcpdump_log_name=basic_l3_call_CA_before_lock_unlock_tdd
#    Start data transfer based on direction    dl_tput=${DL_TPUT}     ul_tput=${UL_TPUT}    protocol=udp
#    ...    duration=3000s   data_transfer_direction=both
#
#    log to console    step2: check pcell and scell throughput
##    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    ignore_time=1min
##    ${dict_tput_info}    Check tput via power UE    cell_id=${PCELL_ID},${SCELL_ID}    exp_ul=1,-1    exp_dl=1,1    log=${tput_log}
#     Sleep    30s   reason=Wait for traffic to be stable
#    ${tput_info_cell_before_lock_tdd}    Check Tput info for each cell
#    ...    dl_cell_id=${PCELL_ID},${SCELL_ID}    exp_dl=100,600    ul_cell_id=${PCELL_ID},${SCELL_ID}
#    ...    exp_ul=50,0    tput_duration=${DURATION_OF_TPUT_CHECK}
#
#    ${ue_addr_before_lock_tdd}    run keyword and continue on failure    Get the UE IP address    ue_index=${0}
#    log to console    step3: lock scell and check there is RRC Reestablishment Request message and there is only throughput on PCELL
#    Start capture F1AP log    tcpdump_collector_name=lock_tdd_cell
#    Lock TDD cell via rest api
#    sleep    5s
#    ${lock_tdd_cell_log_path}    Stop tcpdump log collection    tcpdump_collector_name=lock_tdd_cell
##    ${pdml_list}    Load pcap file with filter     log_path_pcap=${lock_tdd_cell_log_path}     filter=f1ap.procedureCode == 11 and nr-rrc.c1 == 2
##    ${rrc_reestablishment_request}    pcap.get_field_value_by_name    field_name=nr-rrc.c1    attribute_name=show
##    run keyword and continue on failure    should not be empty    ${rrc_reestablishment_request}
#    ${pdml_list}    Load pcap file with filter     log_path_pcap=${lock_tdd_cell_log_path}     filter=ngap.procedureCode == 20 and ngap.Cause == 0
#    ${NGReset}    pcap.get_field_value_by_name    field_name=ngap.Cause    attribute_name=show
#    run keyword and continue on failure    should not be empty    ${NGReset}
#
#    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    ignore_time=1min
#    run keyword and continue on failure   Check tput via power UE   cell_id=${PCELL_ID},${SCELL_ID}   exp_ul=50,-1   exp_dl=100,-1   log=${tput_log}
#    ${ue_addr_after_lock_tdd}    run keyword and continue on failure    Get the UE IP address    ue_index=${0}
#    run keyword and continue on failure   should be true    '${ue_addr_before_lock_tdd}' == '${ue_addr_after_lock_tdd}'
#
#
#    log to console    step4: Unlock scell and check there is only throughput on PCELL
#    Unlock TDD cell via rest api
#    run keyword and continue on failure  Data transmission only on FDD Cell
#    Stop data transfer and detach UE
#    Sleep    30s   reason=add some sleep time between unlock tdd cell and attach again
#    log to console    step5: CA bassic L3 call, there should DL throughput on PCELL and SCELL, and UL throughput on SCELL.
#    ${tput_info_cell_again}    run keyword and continue on failure    CA_basic_L3_call
#    ...    exp_dl=100,600    exp_ul=50,0    tcpdump_log_name=basic_l3_call_CA_after_lock_unlock_tdd
#
#    run keyword and continue on failure     throughput should be as expected
#    ...    tput_info_cell_before=${tput_info_cell_before_lock_tdd}    tput_info_cell_after=${tput_info_cell_again}
#
#    [Teardown]    run keywords    run keyword and ignore error    Unlock TDD cell via rest api    AND
#    ...    run keyword and ignore error    Case restoration and teardown    wa_flag=${False}

[1]5GC001390_G_B15_1009_Online_modification_of_CA_Relationship_removal_SA
    [Tags]    CRT_21A    CIT_TRUNK    CRT_21B    CIT_22R1    CRT_22R1    CRT_22R3    CIT_22R4
    [Documentation]    Author: Cui Lingxue
    ...    Description: This case is to verify the modifcation of CA related NIDD parameters will not affect current active UE.
    ...                 New attached UE will follow the behavior for activate or not CA after the modification.
    ...    Precondition: CA is configured, CA-capable UE attached to FDD cell with CA activated.
    ...    Step1: remove sCellAdditionMethod, check UE data transmission not affected.
    ...    Step2: UE detach, and re-attach. Check UE didn't activate CA.
    ...    Step3: Add sCellAdditionMethod=blind, check UE data transmission not affected.
    ...    Step4: UE detach, and re-attach. Check UE attached with CA activated.
    ...    Step5: repeat step 1~4 for carrierAggregationSupportList and NRREL.
    ...    TBD: add PDL validation.
    ...    Note: from 21B on, modification of CA relationship might lead to pcell lock/unlock, thus all UEs attached to pcell will be released.
    ...          NRBTS/NRCELL/NRREL.sCellAdditionMethod
    ...          - Removing this parameter for a given NRREL instance will provoke a cell lock.
    ...          - Removal of a NRREL instance that has this parameter configured will provoke a cell lock.
    ...          NRBTS/NRCELL/NRREL. lcrId
    ...          - Changing this parameter for a given NRREL instance which has sCellAdditionMethod configured will provoke a cell lock.
    ...          NRBTS/NRDU. flexibleCAMode
    ...          - Modifying the value of this parameter will provoke a gNB reset.

    [Setup]    Common case setup    NSA_SA=SA
    Online_modification_of_CA_Relationship_removal_SA
    [Teardown]    run keyword and ignore error    Case restoration and teardown

#[1]5GC001390_D_22_Single_UE_Call_with_overheating_triggered_SCell_scheduling_suspension_for_FDD_PCell_SA
#    [Documentation]    Author: Ren Biyao
#    ...    Description: test steps
#    ...    Step 1 :  attach and send dl data
#    ...    Step 2 :  send command on qxdm to trigger overheating
#    ...    Step 3:    no data on scell.get
#    ...    Step 4 : send command on qxdm to recover overheating
#    ...    Step 5:  data recover on scell.
#    [Setup]    Common case setup    NSA_SA=SA
#    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${PCELL_ID}
#
#    wait until keyword succeeds     3X    1s    Overheat.root_ue_before_send_cqi     ue_sn=${tl.ues[${0}].serial_number}
#    ...    hostname=${tl.ues[${0}].ssh_connection_details.addr}
#
#    run keyword and continue on failure    L3 call check tput via power UE    cell_id=${PCELL_ID},${SCELL_ID}
#    ...    dl_tput=1000M     ul_tput=0    exp_ul=-1,-1    exp_dl=${PCELL_EXP_DL},${SCELL_EXP_DL}
#    ...    data_transfer_direction=dl
#
#    wait until keyword succeeds     3X    1s    Overheat.set_cqi_value    cqi_value=${6}
#    ...    ue_sn=${tl.ues[${0}].serial_number}    hostname=${tl.ues[${0}].ssh_connection_details.addr}
#    sleep    5s
#
#    wait until keyword succeeds     3X    1s     Check Tput info for each cell
#    ...    dl_cell_id=${PCELL_ID},${SCELL_ID}    exp_dl=${PCELL_EXP_DL},0
#    ...    exp_ul=-1,0   ul_cell_id=${PCELL_ID},${SCELL_ID}   min_tp_check_needed=${false}
#
#    wait until keyword succeeds     3X    1s    Overheat.set_cqi_value    cqi_value=${0}
#    ...    ue_sn=${tl.ues[${0}].serial_number}    hostname=${tl.ues[${0}].ssh_connection_details.addr}
#    sleep    5s
#    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=5m    ignore_time=1min
#    run keyword and continue on failure   Check tput via power UE   cell_id=${PCELL_ID},${SCELL_ID}   exp_ul=-1,-1
#    ...    exp_dl=${PCELL_EXP_DL},${SCELL_EXP_DL}   log=${tput_log}
#
#    [Teardown]    run keyword and ignore error    run keywords     wait until keyword succeeds     3X    1s
#    ...    Overheat.set_cqi_value    cqi_value=${0}    ue_sn=${tl.ues[${0}].serial_number}
#    ...    hostname=${tl.ues[${0}].ssh_connection_details.addr}
#    ...    AND    ssh.disconnect    connection=cygwin
#    ...    AND    ssh.disconnect    connection=login_cpc
#    ...    AND    Common case teardown    detach_ue=${True}

[1]5GC001390_G_EC1_1011_Reset_of_ABIL_hosting_FDD_PCell_SA
    [Tags]    CRT_21A    CIT_21B    CIT_TRUNK    CRT_22R1    CIT_22R2    CIT_22R3    CDRT_22R2    CIT_22R4    CDRT_22R3
    [Documentation]    Author: Ren Biyao
    ...    Description: test steps
    ...    1. ue attach, tput peak
    ...    2. reset TDD ABIL and observe FDD cell still have 100M tput
    ...    3. TDD back to onair and attach again and tput peak
    ...    4. reset FDD ABIL and observe TDD cell still have 100M tput
    ...    5. FDD back to onair and attach again and tput peak
    [Setup]    Common case setup    NSA_SA=SA
    run keyword if    '${PROGRAM}'=='21B'    Block PA ports of non-used RUs
    ${para_file}    coam_parameter.create_update_parameters_delta    parameters=${RESTAPI_TDD_RRC_TIMER}    connection=GNB_OAM
    coam_parameter.perform_scf_delta_commission    delta_file=${para_file['updated']}    connection=GNB_OAM
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${PCELL_ID}

    FOR    ${i}    IN RANGE    ${2}
        ${status}    run keyword and return status    CA_basic_L3_call    duration=1800s    tcpdump_log_name=init_tput
        exit for loop if    ${status}
        run keyword and ignore error     Stop data transfer and detach UE
        log to console    this is ${i} time, init tput status is ${status}
    END
    should be true     ${status}    msg=init tput check fail for 3 times! No need continue.

    log to console    reset the tdd ru connected baseband board, expect the tput remain on fdd cell.
    log    prevent ue attach to the other AEHC cell after reseet BBMOD, need to barred the cell-5
    Change status for parameter cellBarred on GNB    exp_status=barred     list_cell_ids=5
    ${tdd_abil_reset_debug}   Trigger BBMOD reset via webui    abil_index=${SCELL_LIST[0]['tddAbil']}
    Wait until cluster is on cell on air status    timeout=10min    is_all_cells_checking_needed=${True}
    ...    is_x2_check_from_enb_needed=${False}    is_enb_status_check_needed=${False}
    sleep   30s    msg=Wait for cell stable to access.
    ${check_tput}    run keyword and return status    Check Tput info for each cell    dl_cell_id=${PCELL_ID}    exp_dl=100
    ...    exp_ul=50    tput_duration=15    ul_cell_id=${PCELL_ID}
    run keyword if    ${check_tput}    run    rm ${tdd_abil_reset_debug}
    run keyword and continue on failure     should be true    ${check_tput}    msg=reset tdd abil, tput not remained.
    run keyword and ignore error     Stop data transfer and detach UE

    FOR   ${i}    IN RANGE    ${3}
         # check the F+T tput before reset fdd baseband board, if fails, it probabaly be pr.
         run keyword and continue on failure    CA_basic_L3_call    tput_duration=15    duration=900
         ...    tcpdump_log_name=tput_aft_tdd_reset_${i}
         log to console    reset the fdd ru connected baseband board, expect the tput remain on tdd cell.
         ${fdd_abil_reset_debug}    Trigger BBMOD reset via webui    abil_index=${PCELL_LIST[0]['fddAbil']}
         log to console    add this step to check if the gnb connected after trigger Basebandboard reset, if this fails, it probabaly be pr.
         Connect to gnb coam via ssl
         ${check_tput}   run keyword and return status    wait until keyword succeeds    5x    1s
         ...    Check Tput info for each cell    dl_cell_id=${SCELL_ID}    exp_dl=100    ul_cell_id=${SCELL_ID}
         ...    exp_ul=0    tput_duration=10
         Wait until cluster is on cell on air status    timeout=10min    is_all_cells_checking_needed=${True}
         ...    is_x2_check_from_enb_needed=${False}    is_enb_status_check_needed=${False}
         run keyword if    ${check_tput} or ${i}!=${3}    run    rm ${fdd_abil_reset_debug}
         exit for loop if    ${check_tput}
         run keyword and continue on failure    Change status for parameter cellBarred on GNB
         ...    exp_status=notBarred   list_cell_ids=${PCELL_ID}
         run keyword and ignore error    wait until keyword succeeds    2X    1s    run keywords
         ...    Retry commercial ue attach if failed   prepare_ue_needed=${False}    4G_check=False   retry_time=${1}
         ...    AND    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${0}
         run keyword and continue on failure    Change status for parameter cellBarred on GNB    exp_status=notBarred
         run keyword and ignore error    wait until keyword succeeds    2X    1s    run keywords
         ...    Retry commercial ue attach if failed   prepare_ue_needed=${False}    4G_check=False   retry_time=${1}
         ...    AND    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${0}

    END

    run keyword and continue on failure     should be true    ${check_tput}    msg=reset fdd abil, tput not remained.
    run keyword and ignore error     Stop data transfer and detach UE
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${PCELL_ID}
    sleep     2s
    run keyword and continue on failure    CA_basic_L3_call    tput_duration=15    duration=600
    ...    tcpdump_log_name=tput_aft_fdd_reset

    [Teardown]    run keyword and ignore error    run keywords
    ...    Initialize attenuator values for testline
    ...    AND    coam_parameter.perform_scf_delta_commission    delta_file=${para_file['reverse']}    connection=GNB_OAM
    ...    AND    Common case teardown    detach_ue=${True}

*** Keywords ***
throughput should be as expected
    [Documentation]   Author: Liu Zheng
    ...    compare the throughputs which are returned from CA_basic_l3_call
    [Arguments]    ${tput_info_cell_before}    ${tput_info_cell_after}    ${target_avg_percent}=0.95
    ${ul_pcell_before}    set variable    ${tput_info_cell_before['${PCELL_ID}']['ul_avg_tput']}
    ${dl_pcell_before}    set variable    ${tput_info_cell_before['${PCELL_ID}']['dl_avg_tput']}
    ${dl_scell_before}    set variable    ${tput_info_cell_before['${SCELL_ID}']['dl_avg_tput']}

    ${ul_pcell_after}    set variable    ${tput_info_cell_after['${PCELL_ID}']['ul_avg_tput']}
    ${dl_pcell_after}    set variable    ${tput_info_cell_after['${PCELL_ID}']['dl_avg_tput']}
    ${dl_scell_after}    set variable    ${tput_info_cell_after['${SCELL_ID}']['dl_avg_tput']}

    run keyword and continue on failure    should be true    ${ul_pcell_after} > ${ul_pcell_before}*${target_avg_percent}
    run keyword and continue on failure    should be true    ${dl_pcell_after} > ${dl_pcell_before}*${target_avg_percent}
    run keyword and continue on failure    should be true    ${dl_scell_after} > ${dl_scell_before}*${target_avg_percent}
