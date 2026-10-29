*** Settings ***
Documentation
...   author: pengliang.wu@nokia-sbell.com
...   contact: pengliang.wu@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    ./CB010680_UE.robot
Library     ./CB010680_SRS_BIP.py
Variables   ./CB010680_SRS_BIP.py


*** Variables ***
${TL_BTS_ID}               ${tl.gnbs[${0}].instance_id}
${TL_NRBTS_ID}             ${tl.gnbs[${0}].global_bts_id}
@{EMPTY_List}
${ul_iperf_port_list}      ${tl.ues[0].iperf_details.ports[0:3]}
${dl_iperf_port_list}      ${tl.ues[0].iperf_details.ports[3:6]}
${xiaomi12_ui_version}    Mi12UI13.0.28
@{Allowed_list}    ${61652}    ${61524}    ${61649}    ${9000}    ${4592}    ${4527}    ${1932}    ${4334}    ${61074}
...    ${61618}    ${4687}    ${4654}    ${4655}    ${8150}    ${7300}    ${7319}    ${49}    ${6829}    ${6825}    ${6832}
@{all_ue_list}    ${0}    ${1}    ${2}
${copy_from_plan}          CONF-1_origion_scf


*** Keywords ***
CB010680_B Suite setup
    [Arguments]    ${gnb_index}=${0}
    robot_common_operations.Common Suite Setup
    ${bts_host}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    Setup Commission SCF    bts_host=${bts_host}    connection=GNB_SCF_OAM    timeout=400
    Check GNB on air And alarm    bts_host=${bts_host}    allowed_list=${Allowed_list}    time=20min
    ${NRCELl_List}    Get All NRCELL From BTS    gnb_index=${gnb_index}
    Set Suite Variable    ${NRCELl_List}
    Kill Firefox process

Kill Firefox process
    Run    kill -9 $(pgrep -f firefox)

CB010680_B Case TearDown
    [Arguments]    ${gnb_index}=${0}
    SISO_common_operation.Common Case Teardown    bts_host=${gNB_ip}
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Save Snapshot    bts_host=${gNB_ip}
    Check Fault 6832 SAS Server Lost
    Run Keyword And Ignore Error    UE stop traffic and detach    ue_index_list=${all_ue_list}
    Run Keyword And Ignore Error    Lock and Unlock NRCELL    unlock_cell_list=${NRCELl_List}    gnb_index=${gnb_index}
    Run Keyword If    '${TEST_STATUS}'=='FAIL'    Setup Commission SCF    bts_host=${gNB_ip}
    ...    connection=GNB_SCF_OAM    timeout=400
    Run Keyword And Ignore Error    Check GNB on air And alarm    bts_host=${gNB_ip}
    ...    allowed_list=${Allowed_list}    time=20min

##### --- BTS lock/unlock block/unblock --- #####
All NR Cell block unblock
    [Arguments]    ${gnb_index}=${0}    ${connection}=cell_block_coam
    ${bts_ip}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    ${NRCELl_List}    Get All NRCELL From BTS    connection=${connection}
    ${NRCELL_id_List}    Create List
    FOR    ${Item}    IN    @{NRCELL_List}
        ${NRCELL_id}    Fetch From Right    ${Item}    -
        Append to list    ${NRCELL_id_List}    ${NRCELL_id}
    END
    BLock or UnBlock Cell And Check Status
    ...    allowed_list=${Allowed_list}    BTS_ID=${TL_BTS_ID}   NRBTS_ID=${TL_NRBTS_ID}
    ...    block_cell_id_list=${NRCELL_id_List}    unblock_cell_id_list=${EMPTY_List}
    ...    block_flag=${True}    bts_host=${bts_ip}
    BLock or UnBlock Cell And Check Status
    ...    allowed_list=${Allowed_list}    BTS_ID=${TL_BTS_ID}   NRBTS_ID=${TL_NRBTS_ID}
    ...    block_cell_id_list=${EMPTY_List}    unblock_cell_id_list=${NRCELL_id_List}
    ...    block_flag=${False}    bts_host=${bts_ip}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Lock and Unlock NRCELL
    [Arguments]    ${connection}=lock_unlock_coam    ${gnb_index}=${0}
    ...    ${lock_cell_list}=${EMPTY_List}    ${unlock_cell_list}=${EMPTY_List}
    ...    ${allowed_list}=${Allowed_list}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    ${NRCELL_Op_list}    create List
    FOR  ${cell_distname}  IN  @{unlock_cell_list}
        ${NRCELL_dict_item}    create dictionary
        Set to dictionary    ${NRCELL_dict_item}    dist_name=${cell_distname}
        Set to dictionary    ${NRCELL_dict_item}    parameter=administrativeState
        Set to dictionary    ${NRCELL_dict_item}    value=Unlocked
        Set to dictionary    ${NRCELL_dict_item}    operation=update
        Append to list    ${NRCELL_Op_list}    ${NRCELL_dict_item}
    END
    FOR  ${cell_distname}  IN  @{lock_cell_list}
        ${NRCELL_dict_item}    create dictionary
        Set to dictionary    ${NRCELL_dict_item}    dist_name=${cell_distname}
        Set to dictionary    ${NRCELL_dict_item}    parameter=administrativeState
        Set to dictionary    ${NRCELL_dict_item}    value=Locked
        Set to dictionary    ${NRCELL_dict_item}    operation=update
        Append to list    ${NRCELL_Op_list}    ${NRCELL_dict_item}
    END
    ${bts_ip}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    Modify Parameters with json    bts_host=${bts_ip}    input_list=${NRCELL_Op_list}    connection=para_coam
    Wait Until Keyword Succeeds    60s    10s    Check cell lock unlock status    connection=${connection}
    ...    lock_cell_list=${lock_cell_list}    unlock_cell_list=${unlock_cell_list}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_ip}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check cell lock unlock status
    [Arguments]    ${connection}    ${lock_cell_list}=${EMPTY_List}    ${unlock_cell_list}=${EMPTY_List}
    ${cellinfo_list}    coam.get_cells_info    cell_type=nr    connection=${connection}
    FOR  ${cell_id}  IN  @{cellinfo_list}
        ${cell_distname}    set variable    ${cell_id}[id][configuration]
        ${cell_status}    set variable    ${cell_id}[status]
        ${is_lock_cell}    Run Keyword And Return Status    List Should Contain Value    ${lock_cell_list}    ${cell_distname}
        ${is_unlock_cell}    Run Keyword And Return Status    List Should Contain Value    ${unlock_cell_list}    ${cell_distname}
        Run Keyword If    ${is_lock_cell}==${True} and ${is_unlock_cell}==${False}
        ...    Check cell status should as expected    lock    ${cell_status}
        Run Keyword If    ${is_unlock_cell}==${True} and ${is_lock_cell}==${False}
        ...    Check cell status should as expected    unlock    ${cell_status}
    END

Check cell status should as expected
    [Arguments]    ${status_expected}    ${cell_status}
    [Documentation]    ${status_expected} should be lock or unlock
    Log to console    Verify cells status after cell lock/unlock
    ${administrative_expected}    set variable if    '${status_expected}'=='lock'    Locked    Unlocked
    ${operationalState}    set variable if    '${status_expected}'=='lock'    disabled    enabled
    Should Be Equal As Strings    ${cell_status['administrativeState']}    ${administrative_expected}
    Should Be Equal As Strings    ${cell_status['operationalState']}    ${operationalState}
    Run keyword if    '${status_expected}'=='unlock'    Dictionary Should Not Contain Key    ${cell_status}     availabilityStatus
    Run keyword if    '${status_expected}'=='lock'    Dictionary Should Contain Key    ${cell_status}     availabilityStatus

Get All NRCELL From BTS
    [Arguments]    ${gnb_index}=${0}    ${connection}=cell_caom
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    ${cellinfo_list}    coam.get_cells_info    cell_type=nr    connection=${connection}
    ${NRCELL_List}    create list
    FOR    ${cell_item}    IN    @{cellinfo_list}
        ${NRCELL_distname}    set variable    ${cell_item}[id][configuration]
        Append to list    ${NRCELL_List}    ${NRCELL_distname}
    END
    Log to console    NRCELL_list: ${NRCELL_List}
    [Return]    ${NRCELL_List}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Download Current BTS SCF To UTE
    [Arguments]    ${gnb_index}=${0}    ${connection}=Download_SCF_COAM    ${scf_name}=${Empty}
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    coam.get_current_scf_file    local_dir_path=${OUTPUT_DIR}/${TEST NAME}    file_name=${scf_name}.xml    connection=${connection}
    ...    timeout=20
    sleep    5s
    File Should Exist    ${OUTPUT_DIR}/${TEST NAME}/${scf_name}.xml
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

###### --- online delete and add RMOD and NRCELL --- #####
Delete and Add RMOD And NRCELL
    [Arguments]    ${cell_id_list}=${None}    ${cellgrp_id_list}=${None}    ${rmod_list}=${None}    ${cablink_list}=${None}
    ...    ${gnb_index}=${0}    ${scf_path}=None
    ${bts_host}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    ${T749_all_cell_distname_list}    Get All NRCELL From BTS    gnb_index=${gnb_index}
    ${T749_all_cell_list}    Create List
    FOR    ${cell_distname}    IN    @{T749_all_cell_distname_list}
        ${cell_id}    Fetch From Right    ${cell_distname}    -
        Append To List    ${T749_all_cell_list}    ${cell_id}
    END
    ${output_list}    Add Element To List    input_list=${T749_all_cell_list}    excpet_element_list=${cell_id_list}
    Add Or Delete RMOD and Cell And Check On air    if_add=${False}    bts_host=${bts_host}   BTS_ID=${TL_BTS_ID}
    ...    cell_id_list=${cell_id_list}    nrcellgrp_id_list=${cellgrp_id_list}    allowed_list=${Allowed_list}     NRBTS_ID=${TL_NRBTS_ID}
    ...    rmod_list=${rmod_list}    cablink_list=${cablink_list}    expect_cell_list=${output_list}
    sleep  30s
    Add Or Delete RMOD and Cell And Check On air    if_add=${True}    bts_host=${bts_host}   BTS_ID=${TL_BTS_ID}
    ...    cell_id_list=${cell_id_list}    nrcellgrp_id_list=${cellgrp_id_list}    allowed_list=${Allowed_list}     NRBTS_ID=${TL_NRBTS_ID}
    ...    rmod_list=${rmod_list}    cablink_list=${cablink_list}    expect_cell_list=${T749_all_cell_list}    scf_path=${scf_path}

Add Or Delete RMOD and Cell And Check On air
    [Arguments]    ${if_add}    ${bts_host}   ${BTS_ID}    ${NRBTS_ID}    ${cell_id_list}=${None}    ${nrcellgrp_id_list}=${None}
    ...    ${expect_cell_list}=${None}    ${rmod_list}=${None}    ${cablink_list}=${None}    ${allowed_list}=${allowed_list1}
    ...    ${scf_name}=${EMPTY}    ${scf_path}=None
    ${info}    Get Distname Parameters Vlaue     dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ${targetDNList_info}    Get Distname Parameters Vlaue     dist_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/SYNC-2
    ${refNrCellGroup_list}    Set Variable        ${info[${0}]['parameters']['refNrCellGroup']}
    ${RMOD_targetDNList}    Set Variable        ${targetDNList_info[${0}]['parameters']['targetDNList']}
    ${RMOD_id_targetDNList}    Create List
    FOR    ${rmod_distname}    IN    @{RMOD_targetDNList}
        ${rmod_id}    Fetch From Right    ${rmod_distname}    -
        Append To List    ${RMOD_id_targetDNList}    ${rmod_id}
    END
    ${node_index_list_ru}    run keyword if    ${if_add}    Add Node Index    org_node_list=${RMOD_id_targetDNList}
    ...    new_id_list=${rmod_list}
    ...    ELSE    Delete Node Index    org_node_list=${RMOD_id_targetDNList}    new_id_list=${rmod_list}
    ${node_index_list}    run keyword if    ${if_add}    Add Node Index    org_node_list=${refNrCellGroup_list}
    ...    new_id_list=${nrcellgrp_id_list}
    ...    ELSE    Delete Node Index    org_node_list=${refNrCellGroup_list}    new_id_list=${nrcellgrp_id_list}
    Add Or Delete Cell And RMOD By WebUI    if_add=${if_add}    bts_host=${bts_host}    scf_name=${scf_name}   BTS_ID=${BTS_ID}
    ...    NRBTS_ID=${NRBTS_ID}    scf_path=${scf_path}
    ...    cell_id_list=${cell_id_list}    nrcellgrp_id_list=${nrcellgrp_id_list}    node_index_list=${node_index_list}
    ...    ru_node_index_list=${node_index_list_ru}    rmod_id_list=${rmod_list}    cablink_id_list=${cablink_list}
    Wait Until Keyword Succeeds    10min    30s    Check Cells List    bts_host=${bts_host}    expect_cell_list=${expect_cell_list}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

Delete Node Index
    [Arguments]    ${org_node_list}=${None}    ${new_id_list}=${None}
    ${node_index_list}    Create List
    FOR  ${cell_id}  IN  @{new_id_list}
        ${node_index}    Get Index From List    ${org_node_list}    ${cell_id}
        Append To List    ${node_index_list}    ${node_index}
    END
    ${sorted_list}    Evaluate    sorted(${node_index_list}, reverse=True)
    [Return]    ${sorted_list}

Add Node Index
    [Arguments]    ${org_node_list}=${None}   ${new_id_list}=${None}
    ${node_length}    Get Length    ${org_node_list}
    ${add_cell_len}    Get Length    ${new_id_list}
    ${node_index_list}    Create List
    FOR   ${id}  IN RANGE  ${add_cell_len}
        ${node_index}    Evaluate    ${node_length} + ${id}
        Append To List    ${node_index_list}    ${node_index}
    END
    [Return]    ${node_index_list}

Add Element To List
    [Arguments]    ${input_list}=${None}    ${excpet_element_list}=${None}
    @{output_list}    Create List
    FOR    ${i}    IN   @{input_list}
        run keyword if    '${i}' not in @{excpet_element_list}    Append To List    ${output_list}    ${i}
    END
    [Return]    ${output_list}

Delete Nrcells and RMOD Data
    [Arguments]  ${BTS_ID}    ${NRBTS_ID}    ${cell_id_list}=${None}    ${nrcellgrp_id_list}=${None}    ${node_index_list}=${None}
    ...    ${ru_node_index_list}=${None}    ${rmod_id_list}=${None}    ${cablink_id_list}=${None}
    Log To Console    Delete nrcell and rmod
    ${length}    Get Length    ${cell_id_list}
    FOR   ${item}    IN RANGE   ${length}
        Log To Console    remove NRCELL for cell_id: ${cell_id_list}[${item}]
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id_list}[${item}]
        Log To Console    remove NRCELLGRP for nrcellgrp_id: ${nrcellgrp_id_list}[${item}]
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${nrcellgrp_id_list}[${item}]
        Log To Console    remove LCELNR for cell_id: ${cell_id_list}[${item}]
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id_list}[${item}]
        Log To Console    remove NRDU-1 element for cell_id: ${cell_id_list}[${item}]
        selenium_coam.remove_element   dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    node_index=${node_index_list}[${item}]
    END
    ${ru_length}    Get Length    ${rmod_id_list}
    FOR    ${item}    IN RANGE    ${ru_length}
        Log To Console    remove RMOD for rmod_id: ${rmod_id_list}[${item}]
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${rmod_id_list}[${item}]
        Log To Console    remove SYNC-2 element for rmod_id: ${rmod_id_list}[${item}]
        selenium_coam.remove_element   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-2
        ...    filter_param=List of Distinguished Names    node_index=${ru_node_index_list}[${item}]
    END
    ${cablink_length}    Get Length    ${cablink_id_list}
    FOR    ${item}    IN RANGE    ${cablink_length}
        Log To Console    remove CABLINK for cablink_id: ${cablink_id_list}[${item}]
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/EQM-1/HWTOP-1/CABLINK-${cablink_id_list}[${item}]
    END

Add Nrcells and RMOD Data
    [Arguments]  ${scf_name}    ${bts_host}   ${BTS_ID}    ${NRBTS_ID}    ${cell_id_list}=${None}    ${nrcellgrp_id_list}=${None}
    ...    ${node_index_list}=${None}    ${ru_node_index_list}=${None}    ${rmod_id_list}=${None}    ${cablink_id_list}=${None}
    ...    ${scf_path}=None
    Adapt to ute cloud commission scf
    Set default SCF    scf_name=${scf_name}    bts_host=${bts_host}
    ${commisioning_file}    set variable if    '${scf_path}' != 'None'    ${scf_path}    ${default_scf_path}
    Log to console    Load SCF: ${commisioning_file}
    Log To Console    Add nrcell and rmod
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${commisioning_file}
    ${length}    Get Length    ${cell_id_list}
    FOR   ${item}    IN RANGE   ${length}
        ${cell_id}    set variable    ${cell_id_list}[${item}]
        Log To Console    Add NRCELL-${cell_id} for cell_id: ${cell_id}
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELL    plan_to_copy_from=${copy_from_plan}
        ...    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}    include_subobject=${TRUE}    id_value=${cell_id}
        Log To Console    update lcrid to ${cell_id} for cell_id: ${cell_id}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Local cell resource ID   new_value=${cell_id}    abbr=lcrId
        Log To Console    Add LCELNR-${cell_id} for cell_id: ${cell_id}
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
        ...    plan_to_copy_from=${copy_from_plan}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
        ...    include_subobject=${TRUE}    id_value=${cell_id}
        Log To Console    Add NRCELLGRP-${nrcellgrp_id_list}[${item}] for cell_id: ${cell_id}
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELLGRP
        ...    plan_to_copy_from=${copy_from_plan}    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${nrcellgrp_id_list}[${item}]
        ...    include_subobject=${TRUE}    id_value=${nrcellgrp_id_list}[${item}]
        Log To Console    Update refNrCellGroup in NRDU-1 for cell_id: ${cell_id}
        selenium_coam.add_element    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    abbr=refNrCellGroup
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    new_value=${nrcellgrp_id_list}[${item}]
        ...    node_index=${node_index_list}[${item}]    abbr=refNrCellGroup
    END
    ${ru_length}    Get Length    ${rmod_id_list}
    FOR    ${item}    IN RANGE    ${ru_length}
        ${rmod_id}    set variable    ${rmod_id_list}[${item}]
        Log To Console    Add RMOD-${rmod_id} for rmod_id: ${rmod_id}
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1
        ...   object_class_name=RMOD    plan_to_copy_from=${copy_from_plan}    include_subobject=${TRUE}
        ...   copy_from=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${rmod_id}    id_value=${rmod_id}
        Log To Console    Update targetDNList in SYNC-2 for rmod_id: ${rmod_id}
        selenium_coam.add_element    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-2
        ...    filter_param=List of Distinguished Names    abbr=targetDNList
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-2
        ...    filter_param=List of Distinguished Names    new_value=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${rmod_id}
        ...    node_index=${ru_node_index_list}[${item}]    abbr=targetDNList
    END
    ${cablink_length}    Get Length    ${cablink_id_list}
    FOR    ${item}    IN RANGE    ${cablink_length}
        ${cablink_id}    set variable    ${cablink_id_list}[${item}]
        Log To Console    Add CABLINK-${cablink_id} for cablink_id: ${cablink_id}
        wait until keyword succeeds    3x   1min    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/EQM-1/HWTOP-1
        ...   object_class_name=CABLINK    plan_to_copy_from=${copy_from_plan}    include_subobject=${TRUE}
        ...   copy_from=MRBTS-${BTS_ID}/EQM-1/HWTOP-1/CABLINK-${cablink_id}    id_value=${cablink_id}
    END

Add Or Delete Cell And RMOD By WebUI
    [Arguments]  ${if_add}    ${bts_host}    ${scf_name}   ${BTS_ID}    ${NRBTS_ID}    ${cell_id_list}=${None}
    ...    ${nrcellgrp_id_list}=${None}    ${node_index_list}=${None}    ${ru_node_index_list}=${None}
    ...    ${rmod_id_list}=${None}    ${cablink_id_list}=${None}    ${scf_path}=None
    WEBUI Login    bts_host=${bts_host}
    run keyword if    ${if_add}    Add Nrcells and RMOD Data    scf_name=${scf_name}    bts_host=${bts_host}
    ...    BTS_ID=${BTS_ID}    NRBTS_ID=${NRBTS_ID}    scf_path=${scf_path}
    ...    cell_id_list=${cell_id_list}    nrcellgrp_id_list=${nrcellgrp_id_list}    node_index_list=${node_index_list}
    ...    ru_node_index_list=${ru_node_index_list}    rmod_id_list=${rmod_id_list}    cablink_id_list=${cablink_id_list}
    ...    ELSE    Delete Nrcells and RMOD Data    BTS_ID=${BTS_ID}    node_index_list=${node_index_list}
    ...    NRBTS_ID=${NRBTS_ID}    cell_id_list=${cell_id_list}    nrcellgrp_id_list=${nrcellgrp_id_list}
    ...    ru_node_index_list=${ru_node_index_list}    rmod_id_list=${rmod_id_list}    cablink_id_list=${cablink_id_list}
    ${new_plan}    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    Log To Console    new plan file path is: ${new_plan}
    #copy new_plan file to case folder ${OUTPUT_DIR}/${TEST NAME}
    Copy File    ${new_plan}    ${OUTPUT_DIR}/${TEST NAME}
    selenium_coam.validate_plan    timeout=120
    #add workaround for https://jiradc.ext.net.nokia.com/browse/BULLDOG-4959
    sleep    120s
    ${pdl_results}    selenium_coam.get_relation_errors
    Log To Console    Validate Plan result: ${pdl_results}
    Log To Console    Activate plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}    timeout=${180}
    [Teardown]    WEBUI Logout

##### --- online change parameters --- #####
Online active and deactive CB010680
    [Arguments]    ${gnb_index}=${0}    ${cell_id_list}=${None}    ${if_active}=${True}
    ${bts_ip}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    ${MRBTS_ID}    set variable    ${tl.gnbs[${0}].instance_id}
    ${NRBTS_ID}    set variable    ${tl.gnbs[${0}].global_bts_id}
    ${active_value}    Create list    UL-TDOA
    ${deactive_value}    Create list    disabled
    ${para_value}    set variable if    ${if_active}    ${active_value}    ${deactive_value}
    ${ecid_value}    Set Variable If    ${if_active}    true    false
    ${parameter_list}    Create List
    FOR   ${cell_id}    IN    @{cell_id_list}
        ${parameter_dict}    Create dictionary
        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    parameter=actHPPosMethodOptList
        ...    value=${para_value}
        ...    operation=update
        Append to list    ${parameter_list}    ${parameter_dict}
        ${parameter_dict}    Create dictionary
        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    parameter=actUlNrEcIdNgRanApPosition
        ...    value=${ecid_value}
        ...    operation=update
        Append to list    ${parameter_list}    ${parameter_dict}
    END
    Modify Parameters with json    bts_host=${bts_ip}    input_list=${parameter_list}    connection=para_coam
    Check GNB on air And alarm    bts_host=${bts_ip}    allowed_list=${Allowed_list}

Online change bbmodBoardConfigType to lock BB half resource
    [Arguments]    ${gnb_index}=${0}    ${if_full}=${True}
    ${bts_ip}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    ${MRBTS_ID}    set variable    ${tl.gnbs[${0}].instance_id}
    ${expected_alarm}    set variable    ${1868}
    ${expected_alarm_cells_number}    set variable    ${6}
    ${para_value}    set variable if    ${if_full}    NRTDD    NRFDD_NRTDD
    ${parameter_list}    Create List
    ${parameter_dict}    Create dictionary
    ...    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    ...    parameter=bbmodBoardConfigType
    ...    value=${para_value}
    ...    operation=update
    Append to list    ${parameter_list}    ${parameter_dict}
    Modify Parameters with json    bts_host=${bts_ip}    input_list=${parameter_list}    connection=para_coam
    Run keyword if    ${if_full}    Check GNB on air And alarm    bts_host=${bts_ip}    allowed_list=${Allowed_list}    time=15min
    ...    ELSE    Wait Until Keyword Succeeds    600s    15s    Check GNB alarm as expected
    ...    bts_host=${bts_ip}    expected_alarm=${expected_alarm}    expected_alarm_number=${expected_alarm_cells_number}

Check GNB alarm as expected
    [Arguments]    ${bts_host}    ${expected_alarm}=${1}    ${expected_alarm_number}=${6}
    Log to console    Check GNB alarm as expected
    ${actual_fault_id_list}    ${history_id_list}    Get Alarm on BTS    bts_host=${bts_host}    connection=alarm_coam
    ${alarm_count}    count values in list    ${actual_fault_id_list}    ${expected_alarm}
    List Should Contain Value    ${actual_fault_id_list}    ${expected_alarm}
    Should be True    ${alarm_count}==${expected_alarm_number}
    Append to list    ${allowed_list}    ${expected_alarm}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}
    Remove Values From List    ${allowed_list}    ${expected_alarm}

Check Fault 6832 SAS Server Lost
    [Arguments]    ${connection}=srs_check    ${gnb_index}=${0}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    @{fault}    Create List    ${6832}
    ${active_alarms}    coam.get_active_alarms    connection=${connection}
    FOR   ${active_alarm}    IN   @{active_alarms}
        ${roll}    Run Keyword And Return Status    List Should not Contain Value    ${fault}    ${active_alarm['faultId']}
        Run Keyword If    not ${roll}    Log To Console    Fault ${active_alarm['faultId']}, SAS server connection lost issue, Sleep 24 hours !!!!!
        Run Keyword If    not ${roll}    Sleep    12h
    END
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}