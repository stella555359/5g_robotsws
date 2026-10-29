*** Settings ***
Documentation
...   This is for  TA common keywords
...   squad group: MMW_SG1
Resource    ./5GC002546_Variables.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
#Library     OperatingSystem
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ipsl.robot
Library    taf.analyzer.pcap    WITH NAME    pcap
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Library     ./txt_check.py     WITH NAME   txt
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000920/Resources/5GC000920_Keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/case_keywords.robot
Resource    ./../../CB007873/Resources/CB007873_keywords.robot
Variables   ../TestDate/swconfig_change.py


*** Keywords ***
Check specific log in snapshot file
    [Documentation]     Author: zheng.4.liu@nokia-sbell.com
    ...                 For example:
    ...                 Check Incorrect Radio HW log in runtime BTSOM File in Snapshot, the key string "IncorrectRadioHardware" is in
    ...                 BTS45_1011_runtime/runtime_BTSOM.log, the specific_file is BTS45_1011_runtime.zip
    ...                 Check EDlSubcellType in CPRT startup log in snapshot file,  the key string "EDlSubcellType = SUBCELLTYPE_C4" is in
    ...                 BTS45_E005_startup/startup_cp_rt.log
    ...                 ${extract_path} is the dir path that the specific zip file unzip to.
    [Arguments]    ${snapshot_path}=${TS_CASE_LOG_PATH}  ${connection}=${GNB_COAM_ALIAS}
    ...    ${specific_zip_file}=BTS${tl.gnbs[0].instance_id}_1523_startup.zip    ${specific_xz_file}=startup_cp_rt.log.xz
    ...    ${key_string}=crnti
    ${extract_path}=    Collect snapshot and extract specific file    snapshot_log_folder=${TS_CASE_LOG_PATH}
    ...    connection=${GNB_COAM_ALIAS}    specific_file=${specific_zip_file}
    OperatingSystem.File should exist    ${extract_path}/${specific_xz_file}
    Run     unxz ${extract_path}/${specific_xz_file}
    ${unxz_file}    Fetch from left    ${specific_xz_file}    .xz
    ${output}   OperatingSystem.grep file    ${extract_path}/${unxz_file}
    ...    ${key_string}    encoding_errors=replace
    ${crntiOverlapPoolId_list}    ${crntiNonOverlapPoolId_list}  txt.check_crnti_pool_id  ${output}
    Run keyword and continue on failure    should not be empty    ${crntiOverlapPoolId_list}
    Run keyword and continue on failure    should not be empty   ${crntiNonOverlapPoolId_list}



Suite preparation for 2546
    [Documentation]    Author: fang ludan
                ...    modify and commission SCF
    [Arguments]    ${swconfig_modify}=${None}
    Set Suite Variable    ${dpa_enable}    ${True}
    Import NIDD variables

    set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_DEFAULT_ALIGNBWP}
    CA Suite preparation    prepare_ue=${True}    swconfig_modify=${swconfig_modify}
    ${PCELL_ID_1}   set variable if  '${PROGRAM}'=='21B'    ${PCELL_LIST[1]['nrCellId']}   ${-1}
    ${PCELL_ID_2}   set variable if  '${PROGRAM}'=='21B'    ${PCELL_LIST[2]['nrCellId']}   ${-1}
    set suite variable   ${PCELL_ID_1}
    set suite variable   ${PCELL_ID_2}
    import variables   ${CURDIR}/../TestDate/5GC002546_SCF_modify.py

check CRNTI Pool in snapshot
    [Documentation]    Author: fang ludan
                ...    step1:get node id
                ...    step2:check Pool ID
    ${nodeID}      Get the container id for specific nodename from ASIK to ABIL    node_name=CPRT   BST_status=left
    log to console  ${nodeID[2:]}
    5GC002546_keywords.Check specific log in snapshot file   specific_zip_file=BTS${tl.gnbs[0].instance_id}_${nodeID[2:]}_startup.zip
    ...    specific_xz_file=startup_cp_rt.log.xz   key_string=cp_rt

Get the container id for specific nodename from ASIK to ABIL
    [Documentation]    Author: fang ludan
                ...    Get the container id for specific nodename from ASIK to ABIL
                ...    param ${node_name}: refer to container name, eg, UPUE, CPIF
                ...    param ${BST_status}: left or right (The position of the board is placed)
    [Timeout]    20 min
    [Arguments]  ${node_name}   ${BST_status}
    ${local_node_id_list_right}  BuiltIn.Create List  0x2011  0x2021  0x223D  0x233D
    ${local_node_id_list_left}  BuiltIn.Create List  0x1011  0x1021  0x123D  0x133D
    ${container_id_out}  set variable  ${None}
    ${local_node_id_list}   set variable if  '${BST_status}'=='left'  ${local_node_id_list_left}   ${local_node_id_list_right}
    FOR  ${nodeID}  IN  @{local_node_id_list}
        ${container_id}  Get the container id for specific nodename without check length   local_node_id=${nodeID}   node_name=${node_name}
        ${output_len}    Get length    ${container_id}
        ${container_id_out}   set variable if   ${output_len} > ${0}  ${container_id}   ${container_id_out}
    END
    log to console  ${container_id_out}
    [Return]  ${container_id_out}

Get the container id for specific nodename without check length
    [Documentation]    Author: fang ludan
    ...    :param ${local_node_id}: refer to ASIK/ABIL Master/Slave node id, eg, 0x1011, 0x123D
    ...    :param ${node_name}: refer to container name, eg, UPUE, CPIF
    ...    2020/04/22 Cui Lingxue: extend to support both trunk and other branch.
    [Arguments]    ${local_node_id}   ${node_name}    ${connection_alias}=ASIK Master    ${gnb_index}=${0}    ${du_index}=${0}
    csn.connect_to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection_alias}
    #${is_feature_1514_enabled}    stream_manager.feature_1514_opened    connection=${connection_alias}
    csn.connect_to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection_alias}
    #${cmd}    run keyword if    ${is_feature_1514_enabled}
    #...    Catenate    export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/SupervisorS.py -n ${local_node_id} -o list_cbts
    #...              -p 15004 | grep -i ${node_name} |awk '{print $2}'
    #...    ELSE    Catenate    export PYTHONPATH=/opt/hwmt/python; python /opt/hwmt/python/hwapi/SupervisorS.py -n ${local_node_id} -o list_cbts
    #...              | grep -i ${node_name} |awk '{print $2}'
    ${cmd}    Catenate    export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/SupervisorS.py -n ${local_node_id} -o list_cbts
    ...              -p 15004 | grep -i ${node_name} |awk '{print $2}'

    ${cmd_output}    csn.Execute    command=${cmd}    connection=${connection_alias}
    ${output_len}    Get length    ${cmd_output}
#    Should be true    ${output_len} > ${0}    msg=there is no ${node_name} in ${local_node_id}.
    ${container_id_tmp}    fetch from left    ${cmd_output}    ,
    ${container_id}    fetch from right    ${container_id_tmp}    :
    [Return]    ${container_id}


Change addition and activation
    [Documentation]    Author: fang ludan
    ...   step1:set_FDD_0 sCellActivationMethod:scell activation method-- blind
    ...   step2:set_FDD_1 ,FDD_2 sCellActivationMethod:scell activation method-- covBasedA1
    ...   step3:set activition mothod bufferbased
    [Arguments]
      ...        ${add_sCellActivationMethod}=${add_sCellActivationMethod_bufferbased}
    Add NIDD sCellAdditionMethod via restapi
    set NIDD sCellActivationMethod via restapi  add_sCellActivationMethod=${add_sCellActivationMethod}




set NIDD sCellActivationMethod via restapi
    [Documentation]   author: fang ludan
    ...    Add nidd parameter sCellAdditionMethod=blind via restapi. Verify cell is on-air after modification.
    [Arguments]  ${add_sCellActivationMethod}=${add_sCellActivationMethod_bufferbased}   ${NSA_SA}=SA
    COAM Update several parameters via rest api    parameters_to_update_via_api=${add_sCellActivationMethod}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${SCF_DISABLE_CIPHER}  timeout=${TIMER_FOR_MODIFY_VIA_API}
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    Wait until cluster is on cell on air status    timeout=${TIMER_FOR_MODIFY_VIA_API}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}


attach to FDD and check CA and check Scell activated inactivated
    [Documentation]   author: fang ludan
    ...    :param ${FDD_ID}: which cell be barred
    ...    :param ${scell_addition_method}:blind or covBasedA1
    [Arguments]  ${FDD_ID}   ${scell_addition_method}=blind
    Change status for parameter cellBarred on GNB
    ...  exp_status=notBarred   list_cell_ids=${FDD_ID}
    CA_L3_call_tput   scell_addition_method=${scell_addition_method}   check_scell_activation=${True}
    ...   cell_id=${FDD_ID},${SCELL_ID}    protocol=tcp
    check Scell deactivated


Modify sCell addition method to covBasedA1 And Attach
    [Arguments]   ${PCELL_ID}
    run keyword and ignore error   power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
    Modify sCell addition method to covBasedA1   cell_index=${PCELL_ID}   a1ThresholdSCellAddSsbRsrp_TDD=${80}
    attach to FDD and check CA and check Scell activated inactivated  FDD_ID=${PCELL_ID}
    ...   scell_addition_method=covBasedA1
