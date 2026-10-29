*** Settings ***
Documentation    This is for feature CB008247 related common keywords.
...              Please do not modify the file without notification to author
...              Author:xiaoxia.hao@nokia-sbell.com
...              Squard: HZ SG6

Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/TestData.py
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008015/Resources/CB008015_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008360/Resources/aaslog_keywords.robot

*** Keywords ***
Suite Setup For CB007737
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${scf_file_name}=Configuration_CB007737    ${asik_alais}=ASIK Master
    robot_common_operations.Common Suite Setup
    Generate Suite Log Path
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=${asik_alais}
    ${Active_SW_version}    Get Active SW Version
    Set Suite Variable    ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    Set Suite Variable    ${stream}
    Power Off eNB
    ${Golden_SCF_Path}    Get Golden SCF Path
    set suite variable      ${Golden_SCF_Path}
    Log To Console    \n***start to load CB007737 scf after power off eNB***
    Get SCF File Path
    ${scf_file_full_name}    set variable    ${scf_file_name}_${stream}.xml
    ${scf_file_path}    Join Path    ${scf_full_path}    ${scf_file_full_name}
    Log To Console    ${scf_file_path}
    COAM Commission with scf file    scf_file_path=${scf_file_path}    timeout=600
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair

Suite TearDown For CB007737
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    Log To Console    \n***start to recover gNB and pwoer on eNB***
    [Arguments]    ${is_need_enable_uboot}=${False}
    Log To Console    ${Golden_SCF_Path}
    robot_common_operations.Common Suite Teardown
    Power On eNB
    Get SCF File Path
#    ${scf_file_full_name}    set variable    Configuration_IWK_${stream}.xml
#    ${scf_file}    Join Path    ${scf_full_path}    ${scf_file_full_name}
#    ${recover_scf_file_full_path}   set variable if    'SBTS00' in '${stream}'    ${scf_file}    ${Golden_SCF_Path}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${Golden_SCF_Path}    timeout=600    is_pdl_checking_needed=${False}
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    run keyword if    ${is_need_enable_uboot}    Run Keyword And Ignore Error    Set Uboot For Netboot
    robot_common_operations.Common Suite Teardown
    Run Keyword And Ignore Error    COAM Teardown gnb connections

Case SetUp For CB007737
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]     ${is_get_same_core_infor}=${True}    ${asik_alais}=ASIK Master
    robot_common_operations.Common Case Setup
    Generate Test Case Log Path
    ${time_stamp}    Get Current Date    result_format=%Y%m%d%H%M%S
    Set Test Variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    Create Directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    Connect to Common Unit Master    alias=${asik_alais}
    return from keyword if    not ${is_get_same_core_infor}
    Get Core Group Infor From Aaslog

Case SetUp For NR Only on UTE CLoud
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${scf_file_name}=Configuration_CB007737    ${is_get_same_core_infor}=${False}    ${swconfig_modify}=${None}
    ...            ${asik_alais}=ASIK Master    ${is_pdl_checking_needed}=${False}
    Power Off eNB
    ${Golden_SCF_Path}    Get Golden SCF Path
    set suite variable      ${Golden_SCF_Path}
    Log To Console    \n***start to load CB007737 scf after power off eNB***
    Get SCF File Path
    ${scf_file_full_name}    set variable    ${scf_file_name}_${stream}.xml
    ${scf_file_path}    Join Path    ${scf_full_path}    ${scf_file_full_name}
    Log To Console    ${scf_file_path}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    Connect to Common Unit Master    alias=${asik_alais}
    run keyword if    "${swconfig_modify}" != "${None}"     Backup and Modify swconfig file    is_called_in_test_case_level=${True}
    ...                swconfig_modify=${swconfig_modify}
    COAM Commission with scf file    scf_file_path=${scf_file_path}    is_pdl_checking_needed=${is_pdl_checking_needed}    timeout=600
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    robot_common_operations.Common Case Setup
    Generate Test Case Log Path
    ${time_stamp}    Get Current Date    result_format=%Y%m%d%H%M%S
    Set Test Variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    Create Directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    Connect to Common Unit Master    alias=${asik_alais}
    return from keyword if    not ${is_get_same_core_infor}
    Get Core Group Infor From Aaslog

Case SetUp For DSS On UTE CLoud
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${scf_file_name}=${None}    ${is_pdl_checking_needed}=${False}    ${asik_alais}=ASIK Master    ${timeout}=900
    robot_common_operations.Common Case Setup
    Generate Test Case Log Path
    ${time_stamp}    Get Current Date    result_format=%Y%m%d%H%M%S
    Set Test Variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    Create Directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    ${old_scf_file_name}    Get Variable Value    ${old_scf_file_name}
    Get SCF File Path
    ${scf_file_full_name}    set variable    ${scf_file_name}.xml
    ${scf_file_path}    Join Path    ${scf_full_path}    ${scf_file_full_name}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    Connect to Common Unit Master    alias=${asik_alais}
    Run Keyword If    "${scf_file_name}" != "${old_scf_file_name}" and "${scf_file_name}" != "${None}"
    ...                                                                       COAM Commission with scf file    scf_file_path=${scf_file_path}
    ...                                                                       is_pdl_checking_needed=${is_pdl_checking_needed}
    ...                                                                       timeout=${timeout}
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair

Recommission With Backup SCF File
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${is_pdl_checking_needed}=${False}    ${timeout}=900    ${connection}=GNB_OAM
    ${status}    Run Keyword And Return Status     COAM Commission with scf file
    ...                                            scf_file_path=${backup_scf_file}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    ...                                            is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If  ${status}==${False}    Fail    recovery with backup scf file failed.

Case TearDown For CB007737
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${is_recover_swconfig}=${False}    ${timeout}=900    ${connection}=GNB_OAM
    robot_common_operations.Common Case Teardown
    run keyword and ignore error    COAM Teardown gnb connections
    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Run Keyword If Test Failed    Run Keyword And Ignore Error    COAM Save snapshot via rest api    timeout=${600}
#    run keyword and continue on failure    CI_interface.Common Case Teardown
    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Connect to Common Unit Master
    run keyword if    ${is_recover_swconfig}    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=ASIK Master
    ${active_alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Run Keyword And Ignore Error   Unexpect History Alarm Should Not Exist    allowed_faults=${ALLOWED_HISTORY_FAULT}
    run keyword if    not ${active_alarm_status}
    ...               Run Keyword And Ignore Error    COAM Save snapshot via rest api    connection=${connection}    timeout=${timeout}
    Run Keyword And Continue On Failure    should be true    ${active_alarm_status}
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error   csn.disconnect    connection=RU
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Slave
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master
    run keyword and ignore error   COAM Teardown gnb connections
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    CI_interface.Common Case Teardown

Get Core Group Infor From Aaslog
    [Documentation]    Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${timeout}=600   ${connection}=GNB_OAM    ${asik_alais}=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl    connection=${connection}
    coam.reset_site    wait_for_reconnection=${True}    timeout=${timeout}    connection=${connection}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    Connect to Common Unit Master    alias=${asik_alais}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    log_name=l2pslog.txt
    COAM Wait For Gnb Ready And Cell Setup    timeout=20 min
    Wait until keyword succeeds    10 min    30 sec   verify all cells should be onair

Get Same Core Group List
    [Documentation]    Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${log_path}=/tmp/l2pslog.txt    ${asp_id}=1730    ${asik_alais}=ASIK Master
    @{same_core_cellid_list}    create list
    ${command_0}     set variable    cat ${log_path} | grep -a "${asp_id}.*Group_DlFd.*created"
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    Connect to Common Unit Master    alias=${asik_alais}
    ${group_d1fd_output}    csn.execute    command=cat ${log_path} | grep -a "${asp_id}.*Group_DlFd.*created"    connection=${asik_alais}
    ${coreid_infor}    get regexp matches    ${group_d1fd_output}   core.*\\d+
    ${coreid_list}    remove duplicates  ${coreid_infor}
    FOR    ${coreid_infor}    IN    @{coreid_list}
        ${command_1}    set variable    cat ${log_path} | grep -a "${asp_id}.*Group_DlFd.*created.*on.*${coreid_infor}"
        ${group_d1fd_output}    csn.execute    command=${command_1}
        ...                                    connection=${asik_alais}
        ${group_d1fd_infor}    get regexp matches    ${group_d1fd_output}    DlFd\\d*Sched
        ${cellid_list}    Get From Cell Group ID From Coreid    group_d1fd_infor=${group_d1fd_infor}    asp_id=${asp_id}    log_path=${log_path}
        ${same_core_cell_dict}     Create Dictionary
        ${coreid}     get regexp matches    ${coreid_infor}    \\d+
        Set To Dictionary    ${same_core_cell_dict}    coreid    ${coreid}[0]
        Set To Dictionary    ${same_core_cell_dict}    cellgrp_id    ${cellid_list}
        append to list    ${same_core_cellid_list}    ${same_core_cell_dict}
    END
    [Return]    ${same_core_cellid_list}

Get From Cell Group ID From Coreid
    [Documentation]    Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${group_d1fd_infor}     ${log_path}=/tmp/l2pslog.txt    ${asp_id}=1730    ${asik_alais}=ASIK Master
    @{cellid_list}    create list
    FOR    ${group_d1fd}    IN     @{group_d1fd_infor}
        @{d1fd_infor} =    get regexp matches    ${group_d1fd}    \\d+
        ${schedulerIndex}    evaluate    int(${d1fd_infor}[0])-1
        ${group_d1fd_output}    csn.execute
        ...                                command=cat ${log_path} | grep -a "${asp_id}.*chosen schedulerIndex ${schedulerIndex} for NrCellGrpId.*"
        ...                                connection=${asik_alais}
        ${cell_grp_id}    get regexp matches    ${group_d1fd_output}    \\d+
        log    ${cell_grp_id}
        ${cell_grp_id_value}    set variable if    len(${cell_grp_id})>0    ${cell_grp_id}[-1]   ${EMPTY}
        run keyword if     '${cell_grp_id_value}'!='${EMPTY}'    append to list      ${cellid_list}    ${cell_grp_id}[-1]
    END
    [Return]    ${cellid_list}

Get Pcell Same Core Id And Cell Id
    [Documentation]    Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${same_core_cellid_list}    ${pcell_index}
    ${pcell_index}    Convert To String    ${pcell_index}
    FOR    ${core_infor}    IN     @{same_core_cellid_list}
        ${dict_value}    Get Dictionary Values    ${core_infor}
        ${status}    run keyword and return status    List Should Contain Value    ${core_infor['cellgrp_id']}    ${pcell_index}
        run keyword if    ${status}    Remove Values From List    ${core_infor['cellgrp_id']}    ${pcell_index}
        ${target_cell_id}    set variable if    ${status}      ${core_infor['cellgrp_id']}
        ${corce_id}    set variable if    ${status}      ${core_infor['coreid']}
        exit for loop if    ${status}
    END
    [Return]    ${target_cell_id}    ${corce_id}

Get Same Core Id And Cell Id Except Pcell Group
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${same_core_cellid_list}    ${pcell_index}
    ${pcell_index}    Convert To String    ${pcell_index}
    @{target_cell_id}    create list
#    @{tdd_cell_id}    create list    3    4
    FOR    ${core_infor}    IN     @{same_core_cellid_list}
        ${dict_value}    Get Dictionary Values    ${core_infor}
        Remove values from list    ${core_infor['cellgrp_id']}    3    4
        ${status}    run keyword and return status    List Should Not Contain Value   ${core_infor['cellgrp_id']}    ${pcell_index}
        ${not_contain_empty}    run keyword and return status    List Should Not Contain Value   ${core_infor['cellgrp_id']}    ${EMPTY}
        ${cell_number}    Get Length    ${core_infor['cellgrp_id']}
#        ${not_contain_tdd_1}    run keyword and return status    List Should Not Contain Value   ${core_infor['cellgrp_id']}    3
#        ${not_contain_tdd_2}    run keyword and return status    List Should Not Contain Value   ${core_infor['cellgrp_id']}    4
        ${target_cell_id}    set variable if    ${status} and ${not_contain_empty} and ${cell_number}>1
        ...                                     ${core_infor['cellgrp_id']}
        ${corce_id}    set variable if    ${status} and ${not_contain_empty} and ${cell_number}>1
        ...                                    ${core_infor['coreid']}
        exit for loop if    ${status} and ${not_contain_empty} and ${cell_number}>1
    END
    #Remove values from list  ${target_cell_id}    3    4
    @{target_cell_id}     get slice from list     ${target_cell_id}     0     2
    [Return]    ${target_cell_id}    ${corce_id}

Get PLMN value And gNBId Length
    [Documentation]    Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${nr_bts_id}=${tl.gnbs[0].global_bts_id}    ${connection}=GNB_OAM
    ${gnbidlength_value}    coam_parameter.get_single_value_from_scf_file    parameter=gNbIdLength    dist_name=NRBTS-${nr_bts_id}
    ...                                                               connection=${connection}
    ${mcc_value}    coam_parameter.get_single_value_from_scf_file    parameter=mcc    dist_name=NRBTS-${nr_bts_id}/NRPLMN-1
    ...                                                               connection=${connection}
        ${mnc_value}    coam_parameter.get_single_value_from_scf_file    parameter=mnc    dist_name=NRBTS-${nr_bts_id}/NRPLMN-1
    ...                                                               connection=${connection}
        ${mncLength_value}    coam_parameter.get_single_value_from_scf_file    parameter=mncLength    dist_name=NRBTS-${nr_bts_id}/NRPLMN-1
    ...                                                               connection=${connection}
    [Return]    ${gnbidlength_value}    ${mcc_value}    ${mnc_value}    ${mncLength_value}

Add NRREL Cell Infor On Gnb
    [Documentation]    Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${pcell_index}    ${target_cell_id}    ${nr_bts_id}=${tl.gnbs[0].global_bts_id}    ${connection}=GNB_OAM
    ...            ${mrbts_id}=${tl.gnbs[0].instance_id}    ${timeout}=300
    ${gnbidlength_value}    ${mcc_value}    ${mnc_value}    ${mncLength_value}    Get PLMN value And gNBId Length    nr_bts_id=${nr_bts_id}
    ...                                                                                                              connection=${connection}
    @{common_add_param}    create list
    ${target_cell_id_length}    Get Length    ${target_cell_id}
    FOR    ${nrrel_id}    IN RANGE      1   ${target_cell_id_length}+1
        ${dis_name_dir}    set variable    MRBTS-${mrbts_id}/NRBTS-${nr_bts_id}/NRCELL-${pcell_index}/NRREL-${nrrel_id}
        ${cell_index}    Evaluate    ${nrrel_id}-1
        ${common_params}    Catenate    {'dist_name': '${dis_name_dir}', 'parameter': 'gNbId', 'value': '${mrbts_id}'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'gNbIdLength', 'value': '${gnbidlength_value}'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'lcrId', 'value': '${target_cell_id}[${cell_index}]'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'cellIndividualSsbRsrpOffset', 'value': '0dB'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'cellIndividualSsbRsrqOffset', 'value': '0dB'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'handoverAllowedSA', 'value': 'allowed'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'removeNotAllowed', 'value': 'false'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'sCellAdditionMethod', 'value': 'covBasedA1'},
#        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'nrRelId', 'value': '0'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'gnbPlmn',
        ...                              'value': [{'mcc':'${mcc_value}','mnc':'${mnc_value}','mncLength':'${mncLength_value}'}]}
        ${common_SBTS00_params}    Catenate    {'dist_name': '${dis_name_dir}', 'parameter': 'gNbId', 'value': '${mrbts_id}'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'gNbIdLength', 'value': '${gnbidlength_value}'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'lcrId', 'value': '${target_cell_id}[${cell_index}]'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'cellIndividualSsbRsrpOffset', 'value': '0dB'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'cellIndividualSsbRsrqOffset', 'value': '0dB'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'handoverAllowedSA', 'value': 'allowed'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'handoverAllowedSARedCap', 'value': 'forbidden'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'removeNotAllowed', 'value': 'false'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'sCellAdditionMethod', 'value': 'covBasedA1'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'sCellOperationalMode', 'value': 'dlOnly'},
#        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'isRplCellForPSCell', 'value': 'false'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'gnbPlmn',
        ...                              'value': [{'mcc':'${mcc_value}','mnc':'${mnc_value}','mncLength':'${mncLength_value}'}]}
        ${iwk_param}    Catenate    {'dist_name': '${dis_name_dir}', 'parameter': 'rsrpOffsetRplCellForPSCell', 'value': '0dB'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'rsrqOffsetRplCellForPSCell', 'value': '0dB'},
        ...                             {'dist_name': '${dis_name_dir}', 'parameter': 'isRplCellForPSCell', 'value': 'true'}
        ${add_param}    Evaluate     [${common_params}]
        ${add_SBTS00_param}    Evaluate     [${common_SBTS00_params}]
        ${trunk_iwk_param}    Evaluate     [${iwk_param}]
        ${add_param}    Set Variable If    '${stream}'=='SBTS23R1'    ${add_param}    ${add_SBTS00_param}
        ${nrDcAllowed_value}    Create Dictionary    dist_name=${dis_name_dir}    parameter=nrDcAllowed    value='false'
        ${isRplCellForPSCell_value}    Create Dictionary    dist_name=${dis_name_dir}    parameter=isRplCellForPSCell    value='false'
        ${common_add_param}    Combine Lists    ${common_add_param}    ${add_param}
        run keyword if     '${stream}'!='SBTS22R3'    Append To List    ${common_add_param}    ${nrDcAllowed_value}
        run keyword if     '${stream}'!='SBTS00'
        ...                                                        Append To List    ${common_add_param}    ${isRplCellForPSCell_value}
        ${common_add_param}    run keyword if     '${stream}'=='SBTS00'    Combine Lists    ${common_add_param}    ${trunk_iwk_param}
        ...                                         ELSE    Set Variable    ${common_add_param}
    END
    COAM add several MOs via rest api    objects_to_add_via_api=${common_add_param}    timeout=${timeout}
    COAM Wait for gnb ready and cell setup

Get SCF File Path
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    ${scf_full_path}    Get Variable Value    ${scf_full_path}
    return from keyword if    '${scf_full_path}' != 'None'
    ${SCF_Path}    ${result}    Split String From Right  ${CURDIR}    testsuite     1
    ${testline_name}  Get Variable Value    ${testline_name}
    ${TL_NAME}   set variable if    '${testline_name}' == 'None' or '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_5${TLNAME}[0]
    set suite variable    ${scf_full_path}    ${SCF_PATH}commissionings/HGZ/${testlinename}

Power Off eNB
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${unit_index}=${0}
    ...    ${model}=${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.pdu.__class__.__name__}
    ${enb_pdu_ip}=  set variable  ${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.pdu.addr}
    ${enb_pdu_port}=  set variable  ${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${enb_pdu_ip}    alias=enb_pdu
    pdu.power_off    port=${enb_pdu_port}    pdu_device=enb_pdu
    BuiltIn.Log    Reset eNB via Power off

Power On eNB
    [Arguments]    ${unit_index}=${0}
    ...    ${model}=${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.pdu.__class__.__name__}
    ${enb_pdu_ip}=  set variable  ${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.pdu.addr}
    ${enb_pdu_port}=  set variable  ${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${enb_pdu_ip}    alias=enb_pdu
    pdu.power_off    port=${enb_pdu_port}    pdu_device=enb_pdu
    pdu.power_on    port=${enb_pdu_port}    pdu_device=enb_pdu

Update PA Value For Tput
    [Documentation]   Author:lei.jia@nokia-sbell.com
    [Arguments]    ${PA_value}=0    ${AEHC_PA_value}=20
#    Run Keyword If    '${stream}'=='SBTS00'
#    ...                Adjust Attenuation To Trigger Peak Tput For Trunk    PA1_value=${AEHC_PA_value}
#    ...       ELSE     Modify All Attenuation Ports Value For All RU For Branch   value=${PA_value}
    log    ${AEHC_PA_value}
    Modify All Attenuation Ports Value For All RU For Branch   value=${PA_value}

Adjust Attenuation To Trigger Peak Tput For Trunk
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]       ${PA0_value}=0   ${PA1_value}=20
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA0_value}   RU_id=0
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA0_value}   RU_id=1
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA0_value}   RU_id=2
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA1_value}   RU_id=3
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA1_value}   RU_id=4
    Sleep  2sec

Modify All Attenuation Ports Value For All RU For Branch
    [Documentation]   lei.jia@nokia-sbell.com
    ...           Modify all atteuation ports for all RUs defined in init.py
    ...           :param ${value}: <list> or <string>, it can be several values or only one.
    ...           for example:
    ...           if ${value} = [10, 20, 20, 30], it means port 5=10, 6=20, 7=20, 9=30.
    ...           if ${value} = 10, it will set all ports under RU to value 10.
    [Arguments]    ${value}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
       ${RU_id}    evaluate    ${ru_index} - 1
       gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU
        ...    value=${value}   RU_id=${RU_id}
    END

Delete NRREL Cell Infor On Gnb
    [Arguments]    ${pcell_index}     ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...            ${mrbts_id}=${tl.gnbs[0].instance_id}    ${scell_list}=${TARGET_CELL_ID}
    @{common_delete_param}    create list
    ${target_cell_id_length}    Get Length    ${scell_list}
    FOR    ${nrrel_id}    IN RANGE      1   ${target_cell_id_length}+1
        ${common_params}    Catenate    {'dist_name': 'MRBTS-${mrbts_id}/NRBTS-${nr_bts_id}/NRCELL-${pcell_index}/NRREL-${nrrel_id}'}
        ${delte_param}    Evaluate     [${common_params}]
        ${common_delete_param}    Combine Lists    ${common_delete_param}    ${delte_param}
    END
    COAM delete objects via rest api    objects_to_delete_via_api=${common_delete_param}    timeout=900
    COAM Wait for gnb ready and cell setup
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair

Get gNb Cu Type Value
    [Arguments]    ${connection}=GNB_OAM
    ${gNbCuType}    Get Variable Value    ${gNbCuType}
    return from keyword if    '${gNbCuType}' != 'None'
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    Set Suite Variable    ${gNbCuType}

Lock Cell
    [Arguments]    ${cell_id}=4    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    Log To Console    Cell ${cell_id} Locked
    perform_cell_lock_via_admin    cell_id=${cell_id}    connection=${connection}    lock_timeout=120
    sleep    60s    #wait for cell locked

Unlock Cell
    [Arguments]    ${cell_id}=4    ${connection}=GNB_OAM
    Log To Console    Cell ${cell_id} Unlocked
    Connect to gnb coam via ssl
    perform_cell_unlock_via_admin    cell_id=${cell_id}    connection=${connection}    lock_timeout=120
    sleep    60s    #wait for cell unlocked

Lock Cells
    [Arguments]    ${cells_list}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    FOR    ${cell_id}    IN     @{cells_list}
        Log To Console    Cell ${cell_id} Locked
        perform_cell_lock_via_admin    cell_id=${cell_id}    connection=${connection}    lock_timeout=120
        sleep    10s    #wait for cell locked
    END
    sleep    60s

Unlock Cells
    [Arguments]    ${cells_list}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
        FOR    ${cell_id}    IN     @{cells_list}
        Log To Console    Cell ${cell_id} Unlocked
        perform_cell_unlock_via_admin    cell_id=${cell_id}    connection=${connection}    lock_timeout=120
        sleep    10s    #wait for cell locked
    END
    sleep    60s    #wait for cell unlocked

#Clone Gnblogs Tool
#    [Arguments]    ${gnb_logs_dir}=/home/ute
#    ${status}    Run Keyword And Return Status    File Should Exist    /home/ute/gnb_logs/gnb_logs.exe
#    return from keyword if    ${status}==${True}
#    Run Process    mkdir /home/ute/gnb_logs_tool    shell=True
#    Log To Console    start clone gnb_logs tool
#    Run Process    git clone https://gitlabe1.ext.net.nokia.com/p5li/gnb_logs-tool.git /home/ute/gnb_logs_tool
#    ...    shell=True
#    ...    stdout=${gnb_logs_dir}/gnblogs_install_result.txt
#    Run Process    unzip /home/ute/gnb_logs_tool/gnb_logs.zip -d ${gnb_logs_dir}
#    ...    shell=True
#    Run Process    chmod 774 ${gnb_logs_dir}/gnb_logs/gnb_logs
#    ...    shell=True
#    Log To Console    gnb_logs tool install finish

Check NONDTX And Txnumber on TTI
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${duration}=5
    ...            ${eth_port_on_ute}=eth0    ${log_dir}=${TS_CASE_LOG_PATH}/ttitrace_streaming
    Start Ttitrace With Streaming Mode    collector_names=${collector_names}    eth_port_on_ute=${eth_port_on_ute}
    Sleep    ${duration}s    reason=Wait for logs
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${file_path}    Stop Ttitrace    collector_names=${collector_names}    log_dir=${log_dir}/ttitrace_streaming_${timestamp}
    ${tti_file_path_ul}    Decode Ttitrace Logs    file_path=${file_path}    direction=ul
    Sleep    5sec
    ${tti_file_path_dl}    Decode Ttitrace Logs    file_path=${file_path}    direction=dl
    ${ul_retry_txnumber}    ${ul_non_dtx_percent}    calculate_ul_non_dtx_and_ul_txnumber    file_path=${tti_file_path_ul}
    ${dl_retry_txnumber}    ${dl_non_dtx_percent}    calculate_dl_non_dtx_and_dl_txnumber    file_path=${tti_file_path_dl}
    run keyword and continue on failure    Should Be True    ${ul_retry_txnumber}>0
    run keyword and continue on failure    Should Be True    ${ul_non_dtx_percent}>0.97
    run keyword and continue on failure    Should Be True    ${dl_retry_txnumber}>0
    run keyword and continue on failure    Should Be True    ${dl_non_dtx_percent}>0.97

Check UL NONDTX And Txnumber on TTI
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${duration}=5
    ...            ${eth_port_on_ute}=eth0    ${log_dir}=${TS_CASE_LOG_PATH}/ttitrace_streaming
    Start Ttitrace With Streaming Mode    collector_names=${collector_names}    eth_port_on_ute=${eth_port_on_ute}
    Sleep    ${duration}s    reason=Wait for logs
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${file_path}    Stop Ttitrace    collector_names=${collector_names}    log_dir=${log_dir}/ttitrace_streaming_${timestamp}
    ${tti_file_path_ul}    Decode Ttitrace Logs    file_path=${file_path}    direction=ul
    Sleep    5sec
    ${ul_retry_txnumber}    ${ul_non_dtx_percent}    calculate_ul_non_dtx_and_ul_txnumber    file_path=${tti_file_path_ul}
    run keyword and continue on failure    Should Be True    ${ul_retry_txnumber}>0
    run keyword and continue on failure    Should Be True    ${ul_non_dtx_percent}>0.97

Cycle UPdate PA Value
    [Arguments]    ${cell_index}    ${PA_value}=45    ${target_PA_Value}=${60}
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA_value}   RU_id=${cell_index}
    Sleep    5sec
     FOR    ${i}    IN RANGE    1    10
        Log To Console    Cell ${cell_index} update PA value to
        ${new_pa_value}    evaluate    int(${PA_value})+3
        gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${new_pa_value}   RU_id=${cell_index}
        sleep    10s    #wait for cell locked
        ${PA_value}    Set Variable    ${new_pa_value}
        exit for loop if    int(${new_pa_value})>${target_PA_Value}
    END

Wait Until Next Counter Update
    [Arguments]    ${counter_period}=5    ${gnb_connection}=ASIK Master
    [Documentation]    Author:xiaoxia.hao@nokia.com
    ...
    ...    Owner:yangyang.zhou@nokia-sbell.com
    ${period}    Evaluate    ${counter_period}*60
    ${current}     csn.execute    command=date +%s    connection=${gnb_connection}
    ${current}    Get Line    ${current}    -1
    ${sleep}    Evaluate    ${period}+${period}-${current}+int(${current}/${period})*${period}
    Sleep    ${sleep}
    sleep    30

Make Vonr Call For Qualcomm
    [Arguments]    ${ue_index}=${0}
    ...            ${phone_number}=006688
    ...            ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...            ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...            ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...            ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL -d tel:${phone_number}
    ...    connection=cpc_${ue_index}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Hang Up Vonr Call For Qualcomm
    [Arguments]    ${ue_index}=${0}
    ...            ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...            ${sleep_time}=5sec
    ...            ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...            ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...            ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_ENDCALL    connection=cpc_${ue_index}
    Sleep    ${sleep_time}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Get Same nrarfcnDl Cell List
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]   ${nrcell_list}    ${mrbts_id}=${tl.gnbs[0].instance_id}    ${nr_bts_id}=${tl.gnbs[0].global_bts_id}    ${connection}=GNB_OAM
    ...           ${timeout}=300
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    ${target_cell_nrarfcn}    Create List
    FOR    ${nrcell}    IN    @{nrcell_list}
        ${nrarfcnDl_value}    coam_parameter.get_single_value_from_scf_file    parameter=nrarfcnDl
        ...                                                            dist_name=MRBTS-${mrbts_id}/NRBTS-${nr_bts_id}/NRCELL-${nrcell}/NRCELL_FDD-1
        ...                                                            connection=${connection}
        ...                                                            timeout=${timeout}
        Append To List    ${target_cell_nrarfcn}    ${nrarfcnDl_value}
    END
    ${nrcells_list}    Get Cell ID list via Admin CLI    connection=${connection}
    Remove values from list    ${nrcells_list}    NRCELL-3    NRCELL-4
    ${lock_cell_list}    Create List
    FOR    ${nrcell}    IN    @{nrcells_list}
        ${nrarfcnDl_value}    coam_parameter.get_single_value_from_scf_file    parameter=nrarfcnDl
        ...                                                               dist_name=MRBTS-${mrbts_id}/NRBTS-${nr_bts_id}/${nrcell}/NRCELL_FDD-1
        ...                                                               connection=${connection}
        @{nrcell}    string.split string    ${nrcell}    separator=-
        ${status}    Run Keyword And Return Status    List Should Contain Value     ${target_cell_nrarfcn}      ${nrarfcnDl_value}
        ${cell_list}    Run Keyword And Return Status    List Should Contain Value     ${nrcell_list}       ${nrcell}[-1]
        run keyword if    ${status} and not ${cell_list}    Append To List    ${lock_cell_list}     ${nrcell}[-1]
    END
    [Return]    ${lock_cell_list}

Get Cell ID list via Admin CLI
    [Documentation]    :Author: xiaoxia.hao@nokia-sbell.com
    ...                  this keyword is used to get cell id list from GNB via admin cli.
    ...                  FOR example:    [u'NRCELL-2', u'NRCELL-1']
    [Arguments]    ${connection}=GNB_OAM
    ${cell_info}   coam.get_subcells_status   timeout=20    connection=${connection}
    ${cell_group_list}    get dictionary keys    ${cell_info}
    ${cell_list}   create list
    FOR    ${cell_group}    IN    @{cell_group_list}
        ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    ${cell_group}
        ${cell_id_list}    Get Dictionary Keys    ${cell_from_cellgrp}
        ${cell_list}    combine lists    ${cell_id_list}    ${cell_list}
    END
    sort list    ${cell_list}
    [Return]    ${cell_list}

Set Uboot For Netboot
    [Arguments]    ${ASIK_MASTER_ALIAS}=ASIK Master
    Cloud DU connect to gnb coam via ssl
    Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
    Run Keyword And Continue On Failure    csn.execute    command=uboot_env set netboot=netboot_first
    ...                                                        connection=${ASIK_MASTER_ALIAS}
    Sleep   10sec
     [Teardown]    csn.disconnect    connection=${ASIK_MASTER_ALIAS}
