*** Settings ***
Documentation    This is for SG8 common keywords
...              Author: lanwen.cai
...              Squard: HZ SG8

Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot

*** Variables ***

*** Keywords ***
General_SiSo_E2E_system_setup_with_data_transfer_C5
    ${tput_info1}    get_tput_info_by_tool    cell_id=1
    ${tput_info6}    get_tput_info_by_tool    cell_id=6    ue_index=${1}
    Check keyword with retry   Check 6976 cell L3call    tput1=${tput_info1}    tput6=${tput_info6}    target_avg_percent=0.98    min_percent=0.85
    ...    duration=${600}

General_SiSo_E2E_system_setup_with_data_transfer_C5_60M
    Check keyword with retry   Check 6976 cell L3call    tput=${C5_TPUT_60M}    target_avg_percent=0.98    min_percent=0.85
    ...    duration=${600}

General_SiSo_E2E_system_setup_with_data_transfer_C14
    Check keyword with retry   Check 6976 cell L3call    tput=${C14_TPUT}    target_avg_percent=0.98    min_percent=0.85
    ...    duration=${600}    configuration=C14

General_SiSo_E2E_system_setup_with_data_transfer_C15
    ${tput_info6}    get_tput_info_by_tool    cell_id=6    ue_index=${1}
    Check keyword with retry    Check 6976 cell L3call    tput6=${tput_info6}    target_avg_percent=0.98    min_percent=0.85
    ...    duration=${600}    configuration=C15

General_SiSo_E2E_system_setup_with_data_transfer_C15_100M
    Check keyword with retry   Check 6976 cell L3call    tput=${C15_TPUT_100M}    target_avg_percent=0.98    min_percent=0.85
    ...    duration=${600}    configuration=C15

Check 6976 cell L3call
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Start multicell traffic
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]    ${tput1}=${None}    ${tput6}=${None}    ${protocol}=udp    ${target_avg_percent}=0.5    ${min_percent}=0.2    ${duration}=${30}
    ...    ${configuration}=C5    ${traffic_duration}=${7200}
    run keyword if    '${configuration}'!='C15'
    ...    UE attach and start traffic    ue_index=${0}    dl_tp=${tput1['dl_tp']}     ul_tp=${tput1['ul_tp']}
    ...    traffic_duration=${traffic_duration}
    run keyword if    '${configuration}'!='C14'
    ...    UE attach and start traffic    ue_index=${1}    dl_tp=${tput6['dl_tp']}     ul_tp=${tput6['ul_tp']}
    ...    traffic_duration=${traffic_duration}
    log to console    \n***Start Collect and Check Throughput***
    ${tput_log}    samsung.Collect Tput    duration=${duration}    ignore_time=2min
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id1}    run keyword if    '${configuration}'!='C15'    Convert To String    ${cell_mapping[1]['nrCellIdentity']}
    ${cell_id1}    run keyword if    '${configuration}'!='C15'    Create List    ${cell_id1}
    ${cell_id6}    run keyword if    '${configuration}'!='C14'    Convert To String    ${cell_mapping[6]['nrCellIdentity']}
    ${cell_id6}    run keyword if    '${configuration}'!='C14'    Create List    ${cell_id6}
    run keyword if    '${configuration}'!='C15'
    ...    samsung.Check Bi Tput    log=${tput_log}    cells=${cell_id1}    ultarget_throughput=${tput1['ul_exp']}
    ...    dltarget_throughput=${tput1['dl_exp']}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    run keyword if    '${configuration}'!='C14'
    ...    samsung.Check Bi Tput    log=${tput_log}    cells=${cell_id6}    ultarget_throughput=${tput6['ul_exp']}
    ...    dltarget_throughput=${tput6['dl_exp']}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Teardown]    Run keywords  run keyword and ignore error    csn.disconnect    connection=ASIK Master  AND
    ...    run keyword and ignore error    Stop 2UE L3 Call

Stop 2UE L3 Call
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Stop 2UE L3 Call
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    log to console    \n***Stop UE L3 Call***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${0}
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${0}
    ${status}  ${5Grach_ed}  run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_type}    ue_index=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${1}
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${1}
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${1}
    ${status}  ${5Grach_ed}  run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_type}    ue_index=${1}

General_SiSo_RU_lock_unlock_C5
    [Documentation]
    ...    *****************
    ...    Owner_lanwen.cai@nokia-sbell.com
    ...    [TEST PURPOSE] The purpose of this test case is to verify that radio module
    ...    and OAM behaves correctly during procedure of locking and unlocking.
    ...    ******************
#    [Arguments]   ${tput}=${C5_TPUT}
#    ${tput}    get_self_define_tput_by_release    tput_info=${tput}
    ${tput_info1}    get_tput_info_by_tool    cell_id=1
    ${tput_info6}    get_tput_info_by_tool    cell_id=6    ue_index=${1}
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    ${ru_index_list}    Get All RU Index
    log to console    \n***lock RU1, start RU2 L3call***
    selenium_coam.lock_ru    ru_index=1
    wait until keyword succeeds   5min  20sec  RU Should Be Locked  ru_index=1
    #Check 6976 cell L3call    tput=${tput}    configuration=C15
    Check 6976 cell L3call    tput6=${tput_info6}   configuration=C15
    log to console    \n***Start lock RU2***
    selenium_coam.lock_ru    ru_index=2
    wait until keyword succeeds   5min  20sec  RU Should Be Locked  ru_index=2
    sleep    ${X2_link_shutdown_time}min
    run keyword if    '${gNb_CuType}'=='NSA'
    ...    Wait until keyword succeeds    2min    20sec    Expect Fault Should Present    faultId=7300
    log to console    \n***Start unlock all RUs***
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.unlock_ru    ru_index=${ru_index}    timeout=300
        wait until keyword succeeds  5min  20sec  RU Should Be unLocked  ru_index=${ru_index}
    END
    run keyword if    '${gNb_CuType}'=='NSA'
    ...    Wait until keyword succeeds    5min    20sec    Expect Fault Should Absent    faultId=7300
    log to console    \n***Test RU1&RU2 L3call***
    #Check keyword with retry   Check 6976 cell L3call    tput=${tput}
    Check keyword with retry   Check 6976 cell L3call    tput1=${tput_info1}    tput6=${tput_info6}
    [Teardown]    Run Keywords    excute ru unlock    ru_index_list=${ru_index_list}    AND
    ...    Selenium Logout And Close Browser

General_SiSo_RU_lock_unlock_C14
    General_SiSo_RU_lock_unlock    with_call=${False}
    Check 6976 cell L3call    tput=${C14_TPUT}    configuration=C14

General_SiSo_RU_lock_unlock_C15
    General_SiSo_RU_lock_unlock    with_call=${False}
    ${tput_info6}    get_tput_info_by_tool    cell_id=6    ue_index=${1}
    Check 6976 cell L3call    tput6=${tput_info6}    configuration=C15

General_SiSo_Cell_block_and_unblock_14
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    ${cell_id_list}  Get All Cell Id
    log to console    \n***block RU-CELL2, check C14 L3call***
	${block_list}    Create List    2
    Block cells and check status    block_list=${block_list}    check_alarm=${False}
    Check 6976 cell L3call    tput=${C14_TPUT}    configuration=C14
	${block_list}    Create List    1
    Block cells and check status    block_list=${block_list}
    log to console    \n***unblock all cells, check C14 L3call***
    UnBlock Cells and check status   block_list=${cell_id_list}
    Check 6976 cell L3call    tput=${C14_TPUT}    configuration=C14
    [Teardown]    Run keywords    Run Keyword And Ignore Error    UnBlock Cells and check status   block_list=${cell_id_list}
    ...    check_alarm=${True}  gnb_type='${gNb_CuType}'    AND   Selenium Logout And Close Browser

General_SiSo_Cell_block_and_unblock_15
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    ${cell_id_list}  Get All Cell Id
    log to console    \n***block RU-CELL3, check C15 L3call***
	${block_list}    Create List    3
    Block cells and check status    block_list=${block_list}    check_alarm=${False}
    Check 6976 cell L3call    tput6=${tput_info6}    configuration=C15
	${block_list}    Create List    1    2    4    5    6
    Block cells and check status    block_list=${block_list}
    log to console    \n***unblock all cells, check C15 L3call***
    UnBlock Cells and check status   block_list=${cell_id_list}
    Check 6976 cell L3call    tput6=${tput_info6}    configuration=C15
    [Teardown]    Run keywords    Run Keyword And Ignore Error    UnBlock Cells and check status   block_list=${cell_id_list}
    ...    check_alarm=${True}  gnb_type='${gNb_CuType}'    AND   Selenium Logout And Close Browser

General_SiSo_Cell_block_and_unblock_C5
    [Documentation]
    ...    *****************
    ...    Owner_lanwen.cai@nokia-sbell.com
    ...    ******************
    #${C5_TPUT}    get_self_define_tput_by_release    tput_info=${C5_TPUT}
    ${tput_info1}    get_tput_info_by_tool    cell_id=1
    ${tput_info6}    get_tput_info_by_tool    cell_id=6    ue_index=${1}

    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    ${cell_id_list}  Get All Cell Id
    log to console    \n***start RU1-CELL1 L3call***
    #UE attach and start traffic    ue_index=${0}    dl_tp=${C5_TPUT['dl_send']}     ul_tp=${C5_TPUT['ul_send']}
    UE attach and start traffic    ue_index=${0}    dl_tp=${tput_info1['dl_tp']}     ul_tp=${tput_info1['ul_tp']}
    log to console    \n***block RU1-CELL2, check RU1-CELL1 Tput without re-attach***
    ${block_list}    Create List    2
    Block cells and check status    block_list=${block_list}    check_alarm=${False}
    ${tput_log}    samsung.Collect Tput    duration=${30}    ignore_time=2min
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id1}    Convert To String    ${cell_mapping[1]['nrCellIdentity']}
    ${cell_id1}    Create List    ${cell_id1}
    samsung.Check Bi Tput
    #...    log=${tput_log}    cells=${cell_id1}    ultarget_throughput=${C5_TPUT['ul_exp_tp']}
    ...    log=${tput_log}    cells=${cell_id1}    ultarget_throughput=${tput_info1['ul_exp']}
    #...    dltarget_throughput=${C5_TPUT['dl_exp_tp']}    target_avg_percent=0.5    min_percent=0.2
    ...    dltarget_throughput=${tput_info1['dl_exp']}    target_avg_percent=0.5    min_percent=0.2
    log to console    \n***block RU2-CELL3-5, check RU2-CELL6 L3call***
    ${block_list}    Create List    3    4    5
    Block cells and check status    block_list=${block_list}   check_alarm=${False}
    #Check 6976 cell L3call    tput=${C5_TPUT}    configuration=C15
    Check 6976 cell L3call    tput6=${tput_info6}    configuration=C15
    ${block_list}    Create List    1    6
    Block cells and check status    block_list=${block_list}
    log to console    \n***unblock all cells, check C5 L3call***
    UnBlock Cells and check status   block_list=${cell_id_list}
    #Check keyword with retry   Check 6976 cell L3call    tput=${C5_TPUT}
    Check keyword with retry   Check 6976 cell L3call    tput1=${tput_info1}    tput6=${tput_info6}
    [Teardown]    Run keywords    Run Keyword And Ignore Error    UnBlock Cells and check status   block_list=${cell_id_list}
    ...    check_alarm=${True}  gnb_type='${gNb_CuType}'    AND   Selenium Logout And Close Browser

Get RU and cell numbers
    ${ru_index_list}    Get All RU Index
    ${cell_list}    Get All Cell Id
    ${RU_nums}    get length    ${ru_index_list}
    ${cell_nums}    get length    ${cell_list}
    [Return]  ${RU_nums}    ${cell_nums}

