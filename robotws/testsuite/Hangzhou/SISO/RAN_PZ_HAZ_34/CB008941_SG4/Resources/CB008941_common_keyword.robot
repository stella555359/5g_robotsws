*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Documentation
...    Author: tingting.zhong
...    Contact: tingting.zhong@nokia-sbell.com
...    squad group:SG_04


*** Keywords ***
L3call_Loki_based_DU_with_UL_PRB_muting_active_FDBF
    [Documentation]  tingting.zhong@nokia-sbell.com
    Reset Site for Log
    run keyword and continue on failure    Stop Btslog With Path Check    target_dir=${SAVE LOG DIRECTORY}
    Btslog Check DL/UL Prb Muting is Enable
    ${cell_id_list}    Get All Cell Id
    Get UE From Init File and Make call    cell_list=${cell_id_list}    duration=100

L3call_with_UL_PRB_muting_active_FDBF_72E_RF7
    [Arguments]    ${with_call}=${True}  ${with_peak}=${False}  ${call_duration}=${60}    ${upload_tp}=${True}
    ...    ${upload_duration}=${True}    ${suite_name}=default    ${test_name}=default
    ...    ${ue_num_each_call}=1    ${ru_index}=${1}
    Reset Site for Log
    run keyword and continue on failure    Stop Btslog With Path Check    target_dir=${SAVE LOG DIRECTORY}
    Btslog Check DL/UL Prb Muting is Enable
    ${cell_list}    get all cell id    ru_index=${ru_index}
    run keyword if  ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${call_duration}    upload_tp=${upload_tp}    upload_duration=${upload_duration}
    ...    suite_name=${suite_name}    test_name=${test_name}    ue_num_each_call=${ue_num_each_call}

Reset Site for Log
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM
    log to console    \n***Reset Site***
    coam.reset_site    connection=${connection}    graceful_cell_shutdown=${False}
    sleep    120s
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    connection=${connection}

Btslog Check DL/UL Prb Muting is Enable
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM
    log to console    \n***Check DL/UL Prb Muting***
    ${cell_id_list}    Get All Cell Id    connection=${connection}
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
        ${nr_cell_identity}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
        ${cmd}     Catenate
        ...    cat /tmp/btslog2/SYSLOG_*.LOG|grep "nrCellIdentity:${nr_cell_identity} Fragmentation enabled \\[Ul\\] = 1"
        ${ul_enabled}=     run    command=${cmd}
        Should Not Be Empty     ${ul_enabled}
        ${cmd}     Catenate
        ...    cat /tmp/btslog2/SYSLOG_*.LOG|grep "nrCellIdentity:${nr_cell_identity} Fragmentation enabled \\[Dl\\] = 1"
        ${dl_enabled}=     run    command=${cmd}
        Should Not Be Empty     ${dl_enabled}
    END
