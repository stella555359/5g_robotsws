*** Settings ***
Documentation    This is for CB007408 AENB eCPRI keywords
...              Author: Gao melinda
...              Contact: melinda.gao@nokia-sbell.com
...              squad: 5G_PZ_HZ_8_SG


Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006502_CB007833/Resources/CB006502_Keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Library    taf.selenium.sbts    WITH NAME    selenium_sbts
Variables    ../TestData/variables_7408.py

*** Variables ***
@{band1}    60M
@{cell_1}    ${1}
@{cell_2}    ${2}
@{cell_1_2}    ${1}  ${2}
${ui_version_xiaomi}    Mi12UI13.0.12
*** Keywords ***

eCPRI_256_QAM_for_PUSCH_Feature_Activation
    [Arguments]    ${filter_param}=Activate 256QAM in UL    ${new_value}=true    ${abbr}=actUl256Qam    ${cell_id}=1
    log to console    \n******  commission 60M scf *******
    Commission SCF With Specific Band If Needed    band=${band1}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    Selenium Login And Disable Screen Lock
    sleep    10s
    log to console    \n******** start set actUl256Qam to true *******
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...    filter_param=${filter_param}    new_value=${new_value}    abbr=${abbr}
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    log to console    \n****** get actUl256Qam new_value ******
    ${actUl256Qam}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...    filter_param=${filter_param}
    should be equal    ${actUl256Qam}    ${new_value}
    log to console    \n****** start traffic *******
    General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1116_0ms_GP2_A7    enable_2197=${False}    iperf_type=via_command
    [Teardown]    Selenium Logout And Close Browser

General_SiSo_eCPRI_cpri_switch_on_WebEM
    [Arguments]    ${origin_radio_protocol}    ${cell_id}=${1}
    ${radio_protocol_temp}    get_radio_protocal_via_admin
    should be equal    ${radio_protocol_temp}    ${origin_radio_protocol}
    log to console    start traffic for ${radio_protocol_temp}
    ${cell_list}  create list  ${cell_id}
    run keyword and ignore error   Get UE From Init File and Make call  cell_list=${cell_list}    with_peak=${True}
    ${5793_SCF}   run keyword if    '${radio_protocol_temp}'=='CPRI'    Replace String    ${Case_SCF_Path}    .xml    _5793_CPRI.xml
    ...    ELSE    Replace String    ${Case_SCF_Path}    .xml    _5793_eCPRI.xml
    Commissioning SCF And Check On Air      scf_path=${5793_SCF}
    ${cell_list}  create list  ${cell_id}
    ${current_pkg}   Download current SW  SW=${Active_SW_version}
    run keyword if    '${radio_protocol_temp}'=='${origin_radio_protocol}'    Gnb Ecpri Cpri Switch    current_pkg=${current_pkg}
    run keyword and ignore error   Get UE From Init File and Make call  cell_list=${cell_list}    with_peak=${True}
    log to console    switch to ${radio_protocol_temp}
    Gnb Ecpri Cpri Switch    current_pkg=${current_pkg}
    [Teardown]    delete Downloaded    ${current_pkg}

Gnb Ecpri Cpri Switch
    [Arguments]    ${current_pkg}
    selenium login and disable screen lock
    Delete CMD Object If Exist
    Add PRTCLCHGRES Object By Webem
    log to console  start check fault 23 appear
    Wait For Expect Fault Present    faultId=23   timeout=600
    log to console  upload current version package and activate: ${current_pkg}
    Perform SW Update  ${current_pkg}
    sleep  360
    Wait Until Keyword Succeeds    10min    360s    Check HW modules detection
    log to console  start check fault 23 disappear
    Wait For Expect Fault To Disappear  faultId=23   timeout=600
    log to console     \n++++ start validate ++++
    Validate Check on WebUI
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Check Protocol Change Result Via Webem
    Delete CMD Object If Exist
    ${radio_protocol_after_switch}    get_radio_protocal_via_admin
    ${scf_file_backup}    COAM Download scf from cluster  scf_dir_path=${SAVE LOG DIRECTORY}
    log to console    after swicth to ${radio_protocol_after_switch},back up SCF PATH:${scf_file_backup}
    ${5793_SCF2}   run keyword if    '${radio_protocol_after_switch}'=='CPRI'
    ...    Replace String    ${Case_SCF_Path}    .xml    _5793_CPRI.xml
    ...    ELSE    Replace String    ${Case_SCF_Path}    .xml    _5793_eCPRI.xml
    Commissioning SCF And Check On Air    scf_path=${5793_SCF2}
    log to console    current l3Protocal is ${radio_protocol_after_switch}
    Selenium Logout And Close Browser

Add PRTCLCHGRES Object By Webem
    log to console  \n***Add PRTCLCHGRES Object Via Webem***
    ${link_speed}    ${radio_protocol_type}    ${iqCompression}    Get PRTCLCHGRES Object Params
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1
    ...    object_class_name=CMD    id_value=1    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/CMD-1
    ...    object_class_name=PRTCLCHGREQ    id_value=1    timeout=15
    ${ru_index_list}    get all ru index
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${dist_name}    set variable    MRBTS-${mrbtsID}/MNL-1/CMD-1/PRTCLCHGREQ-1
        ${ru_index_temp}    convert to number  ${ru_index}
        ${node_index_temp}    Evaluate  ${ru_index_temp}-1
        selenium_coam.add_element    dist_name=${dist_name}
        ...    filter_param=Radio modules upgrade    abbr=rModUpgrade    timeout=15
        selenium_coam.set_parameter_value  dist_name=${dist_name}    filter_param=IQ Compression
        ...    abbr=iqCompression    new_value=${iqCompression}    node_index=${node_index_temp}
        selenium_coam.set_parameter_value  dist_name=${dist_name}    filter_param=Link speed
        ...    abbr=linkSpeed    new_value=${link_speed}    node_index=${node_index_temp}
        selenium_coam.set_parameter_value  dist_name=${dist_name}    filter_param=Radio protocol type
        ...    abbr=radioProtocolType    new_value=${radio_protocol_type}    node_index=${node_index_temp}
        selenium_coam.set_parameter_value  dist_name=${dist_name}    filter_param=Radio module distinguished name
        ...    abbr=rModDN    new_value=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    node_index=${node_index_temp}
    END
    selenium_coam.validate_plan
    run keyword and ignore error    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=15

Get PRTCLCHGRES Object Params
    Wait Until Keyword Succeeds    1min    10s    Connect to gnb coam via ssl
    ${radio_protocol}    get_radio_protocal_via_admin
    ${iqCompression}    set variable if    '${radio_protocol}'=='CPRI'    eCPRI 9bits    none
    ${link_speed}    set variable if    '${radio_protocol}'=='CPRI'    eCpri25    Cpri7
    ${radio_protocol_type}    set variable if    '${radio_protocol}'=='CPRI'    25eCPRI    TDDCPRI
    [Return]  ${link_speed}    ${radio_protocol_type}    ${iqCompression}

Download current SW
    [Arguments]    ${SW}=${Active_SW_version}    ${package_store_path}=${SAVE LOG DIRECTORY}
    ${sw_name}    ${sw_full_url}    get sw name    SW=${SW}
    ${status}          run keyword and return status    file should exist  ${package_store_path}/${sw_name}
    run keyword if      ${status}    remove file    ${package_store_path}/${sw_name}
    ${sw_url}          Catenate    sudo wget ${sw_full_url} -nv -P ${package_store_path}
    ${res}             Run         ${sw_url}
    ${status}          run keyword and return status    file should exist  ${package_store_path}/${sw_name}
    should be true    ${status}
    [Return]    ${sw_name}

comission specific scf
    [Arguments]    ${replace_scf_name}    ${check_lte_cell_status}=${False}
    log to console    start commission specific SCF...
    ${SCF_replace}    Replace String    ${Golden_SCF_Path}    .xml    ${replace_scf_name}.xml
    COAM Commission with scf file    scf_file_path=${SCF_replace}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    Run Keyword If    ${check_lte_cell_status}==${True}
    ...    Wait until keyword succeeds    15min    30s    verify all cells should be onair    cell_type=lte

CB009359_Manual_SiSo_SM_RF_Module_lock_unlock
    comission specific scf    replace_scf_name=_9359_8DL8UL    check_lte_cell_status=${True}
    data_transfer_common    tput_self_define=${tput_define_8DL8UL_100M}    cell_id=${cell_1}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=${0.3}    min_percent=${0.3}    ui_version=${ui_version_xiaomi}
    log to console    ++++ start lock all RUs ++++
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    ${ru_index_list}    Get All RU Index
    FOR    ${RU_idx}    IN    @{ru_index_list}
        selenium_sbts.lock_ru    ru_index=${RU_idx}
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
    END
    log to console    ++++ start unlock all RUs ++++
    FOR    ${RU_idx}    IN    @{ru_index_list}
        selenium_sbts.unlock_ru    ru_index=${RU_idx}
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
    END
    Selenium Logout And Close Browser
    Wait until keyword succeeds    15min    30s    verify all cells should be onair
    data_transfer_common    tput_self_define=${tput_define_8DL8UL_100M}    cell_id=${cell_1}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=${0.3}    min_percent=${0.3}    ui_version=${ui_version_xiaomi}
    [Teardown]    Selenium Logout And Close Browser

CB009359-SR-S_General_SiSo_Cell_block_and_unblock
    comission specific scf    replace_scf_name=_9359_8DL8UL    check_lte_cell_status=${True}
    data_transfer_common    tput_self_define=${tput_define_8DL8UL_100M}    cell_id=${cell_1}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=${0.3}    min_percent=${0.3}    tput_from=self_define    ui_version=${ui_version_xiaomi}
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    ${cell_id_list}  Get All Cell Id    cell_type=${cell_type}
    FOR    ${cell_index}    IN    @{cell_id_list}
        log to console    Start block cell_${cell_index}...
        selenium_sbts.block_cell    cell_idx=${cell_index}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_index}
        Wait Until Keyword Succeeds   3 min  10 sec   Cell Should Be Blocked   cell_idx=${cell_index}   cell_group_idx=${cellgrp_id}
        Wait For Expect Fault Present    faultId=49    timeout=120
    END
    FOR    ${cell_index}    IN    @{cell_id_list}
        log to console     Start unblock cell_${cell_index}...
        selenium_sbts.unblock_cell    cell_idx=${cell_index}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_index}
        Wait Until Keyword Succeeds   5 min  10 sec   cell should be unblocked   cell_idx=${cell_index}    cell_group_idx=${cellgrp_id}
    END
    Wait For Expect Fault To Disappear    faultId=49    timeout=120
    Selenium Logout And Close Browser
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    data_transfer_common    tput_self_define=${tput_define_8DL8UL_100M}    cell_id=${cell_1}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=${0.3}    min_percent=${0.3}    tput_from=self_define    ui_version=${ui_version_xiaomi}
    [Teardown]    Selenium Logout And Close Browser

CB009359-SR-T_Manual_SiSo_SM_NR RAT reset
    comission specific scf    replace_scf_name=_9359_16DL8UL    check_lte_cell_status=${True}
    data_transfer_common    tput_self_define=${tput_define_16DL8UL_100M}    cell_id=${cell_1}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=${0.3}    min_percent=${0.3}    ui_version=${ui_version_xiaomi}
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    selenium_sbts.reset_nr    timeout=120
    sleep    180s
    Wait until keyword succeeds    15min    30s    verify all cells should be onair
    Wait until keyword succeeds    15min    30s    verify all cells should be onair    cell_type=lte
    Selenium Logout And Close Browser
    data_transfer_common    tput_self_define=${tput_define_16DL8UL_100M}    cell_id=${cell_1}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=${0.3}    min_percent=${0.3}    ui_version=${ui_version_xiaomi}
    [Teardown]    Selenium Logout And Close Browser

7408_dataTransfer_80M
    comission specific scf    replace_scf_name=_80M
    ${PA_Port_List}    Get PA Ports For each RU    ru_index=${0}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_List}    value=${0}
    data_transfer_common    tput_self_define=${tput_define_80M}    cell_id=${cell_1}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=${0.98}    min_percent=${0.85}    ui_version=${ui_version_xiaomi}
