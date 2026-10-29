*** Settings ***
Documentation

Resource    ../../CB006976_CB007308/Resources/CB006796_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ./CB008953_common_keyword.robot
Library    taf.hw.rf_attenuator    WITH NAME    attenuator

*** Variables ***

*** Keywords ***
General_SiSo_RU_lock_unlock_A7
    [Documentation]
    ...    *****************
    ...    Owner_lanwen.cai@nokia-sbell.com
    ...    [TEST PURPOSE] The purpose of this test case is to verify that radio module
    ...    and OAM behaves correctly during procedure of locking and unlocking.
    ...    ******************
    [Arguments]   ${tput}=${C5_TPUT}
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    ${ru_index_list}    Get All RU Index
    log to console    \n***lock RU1, start RU2 L3call***
    selenium_coam.lock_ru    ru_index=1
    wait until keyword succeeds   5min  20sec  RU Should Be Locked  ru_index=1
    log to console    check RU2 cell6 tput
    General_SiSo_E2E_system_setup_with_data_transfer_conducted_A7    tput=${tput}    configuration=C15
    log to console    \n***Start lock RU2***
    selenium_coam.lock_ru    ru_index=2
    wait until keyword succeeds   5min  20sec  RU Should Be Locked  ru_index=2
    sleep    ${X2_link_shutdown_time}min
    run keyword if    '${gNb_CuType}'=='NSA'
    ...    Wait until keyword succeeds    2min    20sec    Expect Fault Should Present    faultId=7300
    log to console    \n***Start unlock all RUs***
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.unlock_ru    ru_index=${ru_index}
        wait until keyword succeeds  5min  20sec  RU Should Be unLocked  ru_index=${ru_index}
    END
    run keyword if    '${gNb_CuType}'=='NSA'
    ...    Wait until keyword succeeds    5min    20sec    Expect Fault Should Absent    faultId=7300
    log to console    \n***Test RU1&RU2 L3call***
    Check keyword with retry   General_SiSo_E2E_system_setup_with_data_transfer_conducted_A7    tput=${tput}
    [Teardown]    Run Keywords    excute ru unlock    ru_index_list=${ru_index_list}    AND
    ...    Selenium Logout And Close Browser

General_SiSo_E2E_system_setup_with_data_transfer_conducted_A7
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Start multicell traffic
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]    ${tput}    ${protocol}=udp    ${target_avg_percent}=0.85    ${min_percent}=0.5    ${duration}=${30}
    ...    ${configuration}=C5    ${traffic_duration}=${7200}
    run keyword if    '${configuration}'!='C15'
    ...    UE attach and start traffic    ue_index=${0}    dl_tp=${tput['dl_send']}     ul_tp=${tput['ul_send']}   pci=${650}
    ...    traffic_duration=${traffic_duration}
    run keyword if    '${configuration}'!='C14'
    ...    UE attach and start traffic    ue_index=${1}    dl_tp=${tput['dl_send6']}     ul_tp=${tput['ul_send6']}
    ...    traffic_duration=${traffic_duration}    set_ue_technology=${True}    pci=${655}
    log to console    \n***Start Collect and Check Throughput***
    ${tput_log}    samsung.Collect Tput    duration=${duration}    ignore_time=2min
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id1}    run keyword if    '${configuration}'!='C15'    Convert To String    ${cell_mapping[1]['nrCellIdentity']}
    ${cell_id1}    run keyword if    '${configuration}'!='C15'    Create List    ${cell_id1}
    ${cell_id6}    run keyword if    '${configuration}'!='C14'    Convert To String    ${cell_mapping[6]['nrCellIdentity']}
    ${cell_id6}    run keyword if    '${configuration}'!='C14'    Create List    ${cell_id6}
    ${tput_info1}    get_tput_info_by_tool    cell_id=1
    ${tput_info6}    get_tput_info_by_tool    cell_id=6
    run keyword if    '${configuration}'!='C15'
    ...    samsung.Check Bi Tput    log=${tput_log}    cells=${cell_id1}    ultarget_throughput=${tput_info1['ul_exp']}
    ...    dltarget_throughput=${tput_info1['dl_exp']}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    run keyword if    '${configuration}'!='C14'
    ...    samsung.Check Bi Tput    log=${tput_log}    cells=${cell_id6}    ultarget_throughput=${tput_info6['ul_exp']}
    ...    dltarget_throughput=${tput_info6['dl_exp']}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Teardown]    Run keywords  run keyword and ignore error    csn.disconnect    connection=ASIK Master  AND
    ...    run keyword and ignore error    Stop 2UE L3 Call

General_SiSo_Cell_block_and_unblock_A7
    [Documentation]
    ...    *****************
    ...    Owner_lanwen.cai@nokia-sbell.com
    ...    ******************
    [Arguments]   ${tput}=${A7_TPUT}
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    ${cell_id_list}  Get All Cell Id
    Set qRxLevMin value    value=${-22}    cellid=2
    Set qRxLevMin value    value=${-22}    cellid=5
    log to console    \n***start RU1-CELL1 L3call***
    UE attach and start traffic    ue_index=${0}    dl_tp=${tput['dl_send']}     ul_tp=${tput['ul_send']}
    log to console    \n***block RU1-CELL2,3,4, check RU1-CELL1 Tput without re-attach***
    ${block_list}    Create List    2    3    4
    Block cells and check status    block_list=${block_list}    check_alarm=${False}
    ${tput_log}    huawei.Collect Tput    duration=${30}    ignore_time=2min
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id1}    Convert To String    ${cell_mapping[1]['nrCellIdentity']}
    ${cell_id1}    Create List    ${cell_id1}
    ${cell_id6}    Convert To String    ${cell_mapping[6]['nrCellIdentity']}
    ${cell_id6}    Create List    ${cell_id6}
    huawei.Check Bi Tput
    ...    log=${tput_log}    cells=${cell_id1}    ultarget_throughput=${tput['ul_exp_tp']}
    ...    dltarget_throughput=${tput['dl_exp_tp']}    target_avg_percent=0.5    min_percent=0.2
    log to console    \n***unblock RU1-CELL2,3,4, check RU1-CELL1 Tput without re-attach***
    UnBlock Cells and check status    block_list=${block_list}    check_alarm=${False}
    ${tput_log}    samsung.Collect Tput    duration=${30}    ignore_time=2min
    huawei.Check Bi Tput
    ...    log=${tput_log}    cells=${cell_id1}    ultarget_throughput=${tput['ul_exp_tp']}
    ...    dltarget_throughput=${tput['dl_exp_tp']}    target_avg_percent=0.5    min_percent=0.2
    huawei.Check Bi Tput
    ...    log=${tput_log}    cells=${cell_id1}    ultarget_throughput=${tput['ul_exp_tp']}
    ...    dltarget_throughput=${tput['dl_exp_tp']}    target_avg_percent=0.5    min_percent=0.2
    log to console    \n***block RU2-CELL5, check RU2-CELL6 L3call***
    ${block_list}    Create List    5
    Block cells and check status    block_list=${block_list}   check_alarm=${False}
    UE attach and start traffic    ue_index=${1}    dl_tp=${tput['dl_send6']}     ul_tp=${tput['ul_send6']}
    ${tput_log}    samsung.Collect Tput    duration=${30}    ignore_time=2min
    huawei.Check Bi Tput
    ...    log=${tput_log}    cells=${cell_id6}    ultarget_throughput=${tput['ul_exp_tp6']}
    ...    dltarget_throughput=${tput['dl_exp_tp6']}    target_avg_percent=0.5    min_percent=0.2
    log to console    \n***unblock RU2-CELL5, check RU1-CELL6 Tput without re-attach***
    UnBlock Cells and check status    block_list=${block_list}    check_alarm=${False}
    ${tput_log}    samsung.Collect Tput    duration=${30}    ignore_time=2min
    huawei.Check Bi Tput
    ...    log=${tput_log}    cells=${cell_id6}    ultarget_throughput=${tput['ul_exp_tp6']}
    ...    dltarget_throughput=${tput['dl_exp_tp6']}    target_avg_percent=0.5    min_percent=0.2
    run keyword and ignore error    Stop 2UE L3 Call
    ${block_list}    Create List    1    6
    Block cells and check status    block_list=${block_list}    check_alarm=${False}
    log to console    \n***unblock cell1&6 L3call***
    UnBlock Cells and check status   block_list=${block_list}
    Check keyword with retry   Check 6976 cell L3call    tput=${tput}
    [Teardown]    Run keywords    Run Keyword And Ignore Error    UnBlock Cells and check status   block_list=${cell_id_list}
    ...    check_alarm=${True}  gnb_type='${gNb_CuType}'    AND    run keyword and ignore error    Stop 2UE L3 Call
    ...    AND    Recover qRxLevMin value   AND  Selenium Logout And Close Browser

General_SiSo_E2E_system_setup_with_data_transfer_conducted_B6
    [Documentation]    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]   ${tput}=${B6_TPUT}    ${target_avg_percent}=0.95    ${min_percent}=0.85    ${duration}=${300}
    log to console    \n***Start Check RU1 CELL1 2 CALL***
    Set B6 RU1 Peak PA
    Set qRxLevMin value    value=${-22}    cellid=2
    UE attach and start traffic    dl_tp=${tput['dl_send']}     ul_tp=${tput['ul_send']}
    Set qRxLevMin value    value=${-40}    cellid=2
    Set qRxLevMin value    value=${-22}    cellid=1
    UE attach and start traffic    ue_index=${1}    dl_tp=${tput['dl_send2']}     ul_tp=${tput['ul_send2']}
    log to console    \n***Start Collect Throughput and Check Throughput***
    ${tput_log}    huawei.Collect Tput    duration=${duration}    ignore_time=2min
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id1}    Convert To String    ${cell_mapping[1]['nrCellIdentity']}
    ${cell_id1}    Create List    ${cell_id1}
    ${cell_id2}    Convert To String    ${cell_mapping[2]['nrCellIdentity']}
    ${cell_id2}    Create List    ${cell_id2}
    mtk.Check Bi Tput    log=${tput_log}    cells=${cell_id1}    ultarget_throughput=${tput['ul_exp_tp']}
    ...    dltarget_throughput=${tput['dl_exp_tp']}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    mtk.Check Bi Tput    log=${tput_log}    cells=${cell_id2}    ultarget_throughput=${tput['ul_exp_tp2']}
    ...    dltarget_throughput=${tput['dl_exp_tp2']}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    run keyword and ignore error    Stop 2UE L3 Call
    log to console    \n***Start Check RU2 CELL5 6 CALL***
    Set B6 RU2 Peak PA
    Set qRxLevMin value    value=${-22}    cellid=6
    UE attach and start traffic    dl_tp=${tput['dl_send5']}     ul_tp=${tput['ul_send5']}
    Set qRxLevMin value    value=${-40}    cellid=6
    Set qRxLevMin value    value=${-22}    cellid=5
    UE attach and start traffic    ue_index=${1}    dl_tp=${tput['dl_send6']}     ul_tp=${tput['ul_send6']}
    log to console    \n***Start Collect Throughput and Check Throughput***
    ${tput_log}    huawei.Collect Tput    duration=${duration}    ignore_time=2min
#    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id5}    Convert To String    ${cell_mapping[5]['nrCellIdentity']}
    ${cell_id5}    Create List    ${cell_id5}
    ${cell_id6}    Convert To String    ${cell_mapping[6]['nrCellIdentity']}
    ${cell_id6}    Create List    ${cell_id6}
    mtk.Check Bi Tput    log=${tput_log}    cells=${cell_id5}    ultarget_throughput=${tput['ul_exp_tp5']}
    ...    dltarget_throughput=${tput['dl_exp_tp5']}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    mtk.Check Bi Tput    log=${tput_log}    cells=${cell_id6}    ultarget_throughput=${tput['ul_exp_tp6']}
    ...    dltarget_throughput=${tput['dl_exp_tp6']}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Teardown]    Run keywords  run keyword and ignore error    csn.disconnect    connection=ASIK Master  AND
    ...    run keyword and ignore error    Stop 2UE L3 Call    AND    Recover qRxLevMin value

Recover qRxLevMin value
    [Arguments]   ${value}=${-40}
    Set qRxLevMin value   value=${value}    cellid=1
    Set qRxLevMin value   value=${value}    cellid=2
    Set qRxLevMin value   value=${value}    cellid=5
    Set qRxLevMin value   value=${value}    cellid=6


Set PA Vaules to 127
    ${PA_124}    attenuator.setup_attenuator    attenuator=${tl.attenuators[0]}    alias=HBTE
    ${PA_126}    attenuator.setup_attenuator    attenuator=${tl.attenuators[1]}    alias=HBTE
    FOR  ${index}    IN RANGE    1    9
        attenuator.set_attenuation   port=${index}    value=${127}    attenuator_device=${PA_124}
    END
    FOR  ${index}    IN RANGE    1    13
        attenuator.set_attenuation   port=${index}    value=${127}    attenuator_device=${PA_126}
    END

Set A7 Peak PA
    [Documentation]   [TEST PURPOSE]Set A7 Peak PA   Owner_lanwen.cai@nokia-sbell.com
    Set PA Vaules to 127
    ${PA_126}    attenuator.setup_attenuator    attenuator=${tl.attenuators[1]}    alias=HBTE
    ${PA_124}    attenuator.setup_attenuator    attenuator=${tl.attenuators[0]}    alias=HBTE
    attenuator.set_attenuation    port=${1}    value=${20}    attenuator_device=${PA_126}
    attenuator.set_attenuation    port=${2}    value=${20}    attenuator_device=${PA_126}
    attenuator.set_attenuation    port=${5}    value=${25}    attenuator_device=${PA_124}
    attenuator.set_attenuation    port=${6}    value=${25}    attenuator_device=${PA_124}


Set B6 RU1 Peak PA
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Set RU1 Peak PA
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    Set PA Vaules to 127
    ${PA_126}    attenuator.setup_attenuator    attenuator=${tl.attenuators[1]}    alias=HBTE
    ${PA_124}    attenuator.setup_attenuator    attenuator=${tl.attenuators[0]}    alias=HBTE
    FOR  ${index}    IN RANGE    1    5
        attenuator.set_attenuation    port=${index}    value=${25}    attenuator_device=${PA_126}
    END
    FOR  ${index}    IN RANGE    1    5
        attenuator.set_attenuation    port=${index}    value=${25}    attenuator_device=${PA_124}
    END

Set B6 RU2 Peak PA
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Set RU2 Peak PA
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    Set PA Vaules to 127
    ${PA_126}    attenuator.setup_attenuator    attenuator=${tl.attenuators[1]}    alias=HBTE
    ${PA_124}    attenuator.setup_attenuator    attenuator=${tl.attenuators[0]}    alias=HBTE
    FOR  ${index}    IN RANGE    9    13
        attenuator.set_attenuation    port=${index}    value=${28}    attenuator_device=${PA_126}
    END
    FOR  ${index}    IN RANGE    5    9
        attenuator.set_attenuation    port=${index}    value=${35}    attenuator_device=${PA_124}
    END

Set qRxLevMin value
    [Documentation]    Set qRxLevMin value by coam.  author_lanwen.cai@nokia-sbell.com
    [Arguments]    ${value}    ${cellid}=1    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}
    ...                                            parameter=qRxLevMin
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            connection=${connection}

Get nrCellType value by coam
    [Documentation]    Set nrCellType value by coam.  author_lanwen.cai@nokia-sbell.com
    [Arguments]    ${class_name}=NRCELL_A    ${pattern}=nrCellType     ${cellID}=1
    ${MO}    coam.get_managed_objects    class_name=${class_name}    connection=GNB_OAM
    ${distname}    Set variable    ${MO[0]['distName']}
    ${dict_pattern}     coam.get_parameters    dist_name=${distname}    pattern=${pattern}    connection=GNB_OAM
    ${pattern_value}    set variable     ${dict_pattern['${pattern}']}
    [Return]    ${pattern_value}

Set B6 Peak PA
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Set Peak PA
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    Set PA Vaules to 127
    ${PA_126}    attenuator.setup_attenuator    attenuator=${tl.attenuators[1]}    alias=HBTE
    ${PA_124}    attenuator.setup_attenuator    attenuator=${tl.attenuators[0]}    alias=HBTE
    FOR  ${index}    IN RANGE    1    5
        attenuator.set_attenuation    port=${index}    value=${20}    attenuator_device=${PA_126}
    END
    FOR  ${index}    IN RANGE    5    9
        attenuator.set_attenuation    port=${index}    value=${15}    attenuator_device=${PA_124}
    END
