*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

Library     OperatingSystem
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/UE_start_traffic.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/modify_scf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME
...         throughput_computation


*** Variables ***
@{ul_power_port_list}         43500   43600
${TL_NRBTS_ID}                ${tl.gnbs[0].instance_id}
@{T928_all_cell_list}         1   2   5
@{T928_all_nr_cell_list}      167247873    167247874    167247877
@{CHANNEL_list}               1   2   3   4   5
@{T719_rmod_list}             6   6   6   6
@{T719_all_nr_cell_list}      599754    599755    599756    599757    599748    599749    599750    599751
@{T719_physCellId_id_list}    330    331    332    333
@{ul_traffic_list}            10    30
@{allowed_list1}              ${4655}    ${61524}    ${61652}    ${61649}    ${4654}    ${4592}
@{allowed_list2}              ${4655}    ${61524}    ${61652}    ${61649}    ${4654}    ${4592}    ${49}
${SW_build_path}              /home/ute/Downloads
@{RF_index_list}              0   1
@{T719_RF_index_list}         0   1   2
@{PA_port_list}               ${0}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}
@{PA_value_list}              ${0}    ${0}    ${0}    ${0}    ${10}    ${10}    ${10}    ${10}
@{T719_PA_port_list}          ${8}    ${9}    ${10}    ${11}
@{T719_PA_value_list}         ${0}    ${0}    ${0}    ${0}
@{CA_2CC_cell_list}           1   3
@{CA_2CC_nr_list}             167247873    167247875
@{CA_4CC_cell_list}           1   2   4   5
@{CA_4CC_nr_list}             167247873    167247874    167247876     167247877


*** Keywords ***
########### setup KW #################
CB009514 Suit Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup

Case Setup
    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Check GNB on air    bts_host=${gNB_ip}
    Check Alarm List on BTS    bts_host=${gNB_ip}    allowed_list=${allowed_list1}
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog

Case Teardown
    Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Ignore error     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.3      Delete_old_ERR_WRN=1
    ...       Fail_Case=False       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Save Snapshot    bts_host=${gNB_ip}
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown


Commission CB009514 scf
    [Arguments]    ${scf_path}    ${bts_host}=${gNB_ip}
    wait until keyword succeeds   9x   20s
    ...    Connect to gnb coam via ssl
    ...    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=GNB_OAM
    COAM Commission with scf file    scf_file_path=${scf_path}    connection=GNB_OAM    timeout=540
    Run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
    Check GNB on air    bts_host=${bts_host}

############# Logic Code ###############
Add Element To List
    [Arguments]    ${input_list}    ${excpet_element_list}
    @{output_list}    Create List
    FOR    ${i}    IN   @{input_list}
        run keyword if    '${i}' not in @{excpet_element_list}    Append To List    ${output_list}    ${i}
    END
    [Return]    ${output_list}

Start Traffic And Check Tp
    [Arguments]    ${ul_tp_list}    ${process}    ${log_time}    ${ul_list}    ${dl_list}    ${exp_ul_tp}    ${exp_dl_tp}
    ...    ${multiue_config_direction}=${TLCommonConfig["MultiUECFG"]}    ${ul_port_list}=${ul_power_port_list}    ${target_avg_percent}=1
    ...    ${min_percent}=0    ${if_ul}=${False}    ${if_dl}=${True}    ${duration}=6000    ${get_spark_license}=${True}
    wait until keyword succeeds   60x   10s
    ...    Start Traffic By Spark    ul_tp_list=${ul_tp_list}
    ...     if_ul=${if_ul}    if_dl=${if_dl}    duration=${duration}    process=${process}
    ...     multiue_config_direction=${multiue_config_direction}
    ...     ul_port_list=${ul_port_list}    get_spark_license=${get_spark_license}
    Check TP From Aasyslog    log_time=${log_time}    ul_list=${ul_list}    dl_list=${dl_list}    exp_ul_tp=${exp_ul_tp}
    ...    exp_dl_tp=${exp_dl_tp}   target_avg_percent=${target_avg_percent}
    ...     min_percent=${min_percent}    if_ul=${if_ul}    if_dl=${if_dl}
    [Teardown]    Stop Traffic And Detach UE    if_ul=${if_ul}    if_dl=${if_dl}

Block Cell And Start Traffic
    [Arguments]    ${excpet_element_list}    ${all_cells_list}    ${ul_tp_list}    ${nr_cell_list}    ${exp_ul_tp}    ${exp_dl_tp}
    ...    ${log_time}=60s    ${block_flag}=${True}    ${multiue_config_direction}=${TLCommonConfig["MultiUECFG"]}    ${if_ul}=${True}
    ${output_list}    Add Element To List    input_list=${all_cells_list}    excpet_element_list=${excpet_element_list}
    BLock or UnBlock Cell And Check Status    block_flag=${block_flag}    block_cell_id_list=${output_list}    allowed_list=${allowed_list2}
    ...    unblock_cell_id_list=${excpet_element_list}     NRBTS_ID=${TL_BTS_ID}
    Start Traffic And Check Tp    ul_tp_list=${ul_tp_list}    process=${2}    log_time=${log_time}
    ...    exp_ul_tp=${exp_ul_tp}    exp_dl_tp=${exp_dl_tp}    ul_list=${nr_cell_list}    dl_list=${nr_cell_list}
    ...    multiue_config_direction=${multiue_config_direction}    if_ul=${if_ul}
    [Teardown]   BLock or UnBlock Cell And Check Status    block_flag=${False}   unblock_cell_id_list=${output_list}    allowed_list=${allowed_list1}

Add Or Delete Cell And Check On air
    [Arguments]    ${if_add}    ${bts_host}   ${BTS_ID}    ${NRBTS_ID}    ${cell_id_list}    ${nrcellgrp_id_list}    ${expect_cell_list}
    ...    ${allowed_list}=${allowed_list1}    ${scf_name}=${EMPTY}
    ${info}    Get Distname Parameters Vlaue     dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ${refNrCellGroup_list}    Set Variable        ${info[${0}]['parameters']['refNrCellGroup']}
    ${node_index_list}    run keyword if    ${if_add}    Add Node Index    org_node_list=${refNrCellGroup_list}   cell_id_list=${cell_id_list}
    ...    ELSE    Delete Node Index    org_node_list=${refNrCellGroup_list}    cell_id_list=${cell_id_list}
    Add Or Delete Cell By WebUI    if_add=${if_add}    bts_host=${bts_host}    scf_name=${scf_name}   BTS_ID=${BTS_ID}    NRBTS_ID=${NRBTS_ID}
    ...    cell_id_list=${cell_id_list}    nrcellgrp_id_list=${nrcellgrp_id_list}    node_index_list=${node_index_list}
    ...    scf_path=${output_dir}/new_scf.xml
    Wait Until Keyword Succeeds    10min    30s    Check Cells List    bts_host=${bts_host}    expect_cell_list=${expect_cell_list}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

Delete Node Index
    [Arguments]    ${org_node_list}    ${cell_id_list}
    ${node_index_list}    Create List
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${node_index}    Get Index From List    ${org_node_list}    ${cell_id}
        Append To List    ${node_index_list}    ${node_index}
    END
    [Return]    ${node_index_list}

Add Node Index
    [Arguments]    ${org_node_list}   ${cell_id_list}
    ${node_length}    Get Length    ${org_node_list}
    ${add_cell_len}    Get Length    ${cell_id_list}
    ${node_index_list}    Create List
    FOR   ${id}  IN RANGE  ${add_cell_len}
        ${node_index}    Evaluate    ${node_length} + ${id}
        Append To List    ${node_index_list}    ${node_index}
    END
    [Return]    ${node_index_list}

Calculate Theoretical TP
    [Arguments]  ${scf_path}    ${dl_cell_list}=${empty_list}    ${ul_cell_list}=${empty_list}    ${UL_Rank}=${1}
    ${total_ul_tp}    set variable    ${0}
    ${total_dl_tp}    set variable    ${0}
    ${dl_cell_num}    get length    ${dl_cell_list}
    ${ul_cell_num}    get length    ${ul_cell_list}
    ${ul_divided_by}    set variable if    ${UL_Rank}==${1}    ${2}    ${1}
    FOR  ${i}  IN RANGE   ${dl_cell_num}
        ${cell_id}    Evaluate    ${dl_cell_list}[${i}]
        ${calculator_tp_dl}    ${calculator_tp_ul}    throughput_computation.get_theoretical_throughput    scf_path=${scf_path}    cell_id=${cell_id}
        ${total_dl_tp}    Evaluate    ${calculator_tp_dl}+${total_dl_tp}
    END
    FOR  ${i}  IN RANGE   ${ul_cell_num}
        ${cell_id}    Evaluate    ${ul_cell_list}[${i}]
        ${calculator_tp_dl}    ${calculator_tp_ul}    throughput_computation.get_theoretical_throughput    scf_path=${scf_path}    cell_id=${cell_id}
        ${total_ul_tp}    Evaluate    ${calculator_tp_ul}/${ul_divided_by}+${total_ul_tp}
    END
    [Return]  ${total_ul_tp}    ${total_dl_tp}

Get Theoretical TP From NRDIM
    [Arguments]    ${dl_cell_list}=${empty_list}    ${ul_cell_list}=${empty_list}    ${UL_Rank}=${1}
    Adapt to ute cloud commission scf
    Set default SCF    scf_name=${EMPTY}    bts_host=${gNB_ip}
    ${total_ul_tp}    ${total_dl_tp}    Calculate Theoretical TP    scf_path=${default_scf_path}    dl_cell_list=${dl_cell_list}
    ...    ul_cell_list=${ul_cell_list}    UL_Rank=${UL_Rank}
    # NRDIM not consider SSB configuration for super-cell
    ${total_dl_tp}    Evaluate    ${total_dl_tp}-${15}
    ${total_ul_tp}    Evaluate    ${total_ul_tp}+${4}
    Log to console    Theoretical Tput calculated via NRDIM DL:${total_dl_tp}Mbps, UL:${total_ul_tp}Mbps
    [Return]    ${total_ul_tp}    ${total_dl_tp}

Change Configuration For CB012997
    [Arguments]    ${bts_host}   ${BTS_ID}=${TL_BTS_ID}    ${NRBTS_ID}=${TL_NRBTS_ID}
    Adapt to ute cloud commission scf
    Set default SCF    scf_name=${EMPTY}    bts_host=${bts_host}
    scf.load_scf       file_path=${default_scf_path}
    Remove Cell In SCf    BTS_ID=${BTS_ID}    NRBTS_ID=${NRBTS_ID}
    Copy Cell From AQQY    BTS_ID=${BTS_ID}    NRBTS_ID=${NRBTS_ID}
    scf.save_scf        file_path=${output_dir}/new_scf.xml
    [Return]    ${output_dir}/new_scf.xml

Remove Cell In SCf
    [Arguments]    ${BTS_ID}=${TL_BTS_ID}    ${NRBTS_ID}=${TL_NRBTS_ID}
    Remove Multiple Mo In Scf    dist_list=${delete_dist_list}    ID_list=${T719_delete_cell_list}
    FOR  ${i}  IN RANGE  ${4}
        scf.remove_element_from_scf     dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1    list_name=refNrCellGroup    index=0
    END

Copy Cell From AQQY
    [Arguments]    ${BTS_ID}=${TL_BTS_ID}    ${NRBTS_ID}=${TL_NRBTS_ID}
    Clone Multiple Mo In Scf    dist_list=${add_dist_list}    source_ID_list=${T719_all_cell_list[:4]}    target_ID_list=${T719_all_cell_list[4:]}
    Clone Multiple Mo In Scf    dist_list=${add_dist_list1}    source_ID_list=${profile_list1}    target_ID_list=${profile_list2}
    scf.clone_mo_with_descendant_mos    source_mo_dist_name=${add_dist_list2}[${0}]    target_mo_dist_name=${add_dist_list2}[${1}]
    ${dist_name_list1}    ${p_name_list1}    ${new_value_list1}    Generate multiple Parameter With Same P_name
    ...    dist_name_list=${modify_para_dict1['dist_name_list']}    p_name_list=${modify_para_dict1['p_name_list']}
    ...    all_id_list=${modify_para_dict1['all_id_list']}    new_value_list=${modify_para_dict1['new_value_list']}

    ${dist_name_list2}    ${p_name_list2}    ${new_value_list2}    CB012997_common_keywords.Generate New cell Corresponding RMOD
    ...    rmod_id_list=${T719_rmod_list}    add_cell_list=${T719_all_cell_list[4:]}    CHANNELGROUP_id=${1}    CHANNEL_id_list=${CHANNEL_list}

    ${dist_name_list3}    ${p_name_list3}    ${new_value_list3}    CB012997_common_keywords.Generate New cell Corresponding RMOD
    ...    rmod_id_list=${T719_rmod_list}    add_cell_list=${T719_all_cell_list[4:]}    CHANNELGROUP_id=${2}    CHANNEL_id_list=${CHANNEL_list[:4]}

    ${dist_name_list}    Evaluate    @{dist_name_list1} + @{dist_name_list2} + @{dist_name_list3}
    ${p_name_list}    Evaluate    @{p_name_list1} + @{p_name_list2} + @{p_name_list3}
    ${new_value_list}    Evaluate    @{new_value_list1} + @{new_value_list2} + @{new_value_list3}

    Modify Ordinary Parameter Value    dist_name_list=${dist_name_list}    p_name_list=${p_name_list}    new_value_list=${new_value_list}
    Modify Structure Parameter Value Without P_name    dist_name_list=${modify_para_dict2['dist_name_list']}
    ...    list_name_list=${modify_para_dict2['list_name']}    value_list=${modify_para_dict2['new_value_list']}
    ...    index_list=${modify_para_dict2['index_list']}
    scf.add_elements_to_list    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1    list_name=refNrCellGroup    elements=${T719_all_cell_list[4:]}

Generate New cell Corresponding RMOD
    [Arguments]  ${rmod_id_list}    ${add_cell_list}    ${CHANNEL_id_list}    ${CHANNELGROUP_id}    ${BTS_ID}=${TL_BTS_ID}    ${p_name}=resourceDN
    ${LCELNR_ID}     Set Variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR
    ${dist_name_list}    Create List
    ${p_name_list}    Create List
    ${new_value_list}    Create List
    ${list_len}    Get length    ${rmod_id_list}
    FOR  ${item}  IN RANGE   0  ${list_len}
        ${dist_name}    set variable    ${LCELNR_ID}-${add_cell_list}[${item}]/CHANNELGROUP-${CHANNELGROUP_id}/CHANNEL
        ${dist_name_list_tmp}    ${p_name_list_tmp}    Generate Parameter With Same P_name On same Father Mo    dist_name=${dist_name}
        ...    id_list=${CHANNEL_id_list}    p_name=${p_name}
        ${single_LCELNR_Rmod_value_list}    Generate the LCELNR Corresponding RMOD    CHANNEL_id_list=${CHANNEL_id_list}
        ...    dist_name_list=${dist_name_list_tmp}    p_name_list=${p_name_list_tmp}    rmod_id=${rmod_id_list}[${item}]
        Append to list    ${dist_name_list}    @{dist_name_list_tmp}
        Append to list    ${p_name_list}    @{p_name_list_tmp}
        Append to list    ${new_value_list}    @{single_LCELNR_Rmod_value_list}
    END
    [Return]  ${dist_name_list}    ${p_name_list}    ${new_value_list}






