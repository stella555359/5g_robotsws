*** Settings ***
Documentation
...    SISO Common Resource files

Library    taf.selenium.sbts    WITH NAME    selenium_coam

*** Keywords ***
Selenium Login
    [Arguments]    ${url}=https://${BTS_HOST}
    ...            ${username}=Nemuadmin
    ...            ${password}=nemuuser
    ...            ${download_dir}=${TEST_LOGS_DIR_PATH}
    ...            ${timeout}=${60}
    ...            ${index}=${0}
    ...            ${version}=SBTS25R1
    ...            ${browser}=Firefox
    ...            ${alias}=default
    Log    ${index}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}
    ...    username=${username}
    ...    password=${password}
    ...    download_dir=${download_dir}
    ...    timeout=${timeout}
    ...    version=${version}
    ...    browser=${browser}
    ...    alias=${alias}
    selenium_coam.disable_message_box    sbts=${alias}
    selenium_coam.disable_screen_lock    sbts=${alias}

Selenium Logout
    [Arguments]    ${alias}=default
    Run Keyword And Ignore Error    selenium_coam.logout    sbts=${alias}
    Run Keyword And Ignore Error    selenium_coam.disable_virtual_display
    Run Keyword And Ignore Error    selenium_coam.close_browser    sbts=${alias}

Selenium Multi Parameters Recommission
    [Arguments]    ${para_list}    ${alias}=default
    FOR    ${para}    IN    @{para_list}
        ${is_exist}    Run Keyword And Return Status    Variable Should Exist    ${para["node_index"]}
        Run Keyword If    ${is_exist}    selenium_coam.set_parameter_value
        ...    dist_name=${para["dist_name"]}    filter_param=${para["para_name"]}
        ...    node_index=${para["node_index"]}    new_value=${para["para_value"]}    sbts=${alias}
        ...    ELSE    selenium_coam.set_parameter_value
        ...    dist_name=${para["dist_name"]}    filter_param=${para["para_name"]}
        ...    new_value=${para["para_value"]}    sbts=${alias}
    END

Selenium Check Multi Parameters Value
    [Arguments]    ${para_list}    ${alias}=default
    selenium_coam.refresh_page    sbts=${alias}
    sleep    10s
    FOR    ${para}    IN    @{para_list}
        ${is_exist}    Run Keyword And Return Status    Variable Should Exist    ${para["node_index"]}
        ${out_value}    Run Keyword If    ${is_exist}    selenium_coam.get_parameter_value
        ...    dist_name=${para["dist_name"]}    filter_param=${para["para_name"]}    node_index=${para["node_index"]}
        ...    sbts=${alias}
        ...    ELSE    selenium_coam.get_parameter_value    dist_name=${para["dist_name"]}
        ...    filter_param=${para["para_name"]}    sbts=${alias}
        Should Be Equal    ${para["para_value"]}    ${out_value}
    END

Selenium Active Plan
    [Arguments]    ${alias}=default
    sleep    10s
    selenium_coam.validate_plan    sbts=${alias}
    sleep    10s
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=180    sbts=${alias}
    Wait Until Keyword Succeeds    600    30    Create Node Parameters From Current SCF
    Wait For All Cells Onair    timeout=${ONAIR_TIME}

Selenium Multi Objects Operate
    [Arguments]    ${object_list}    ${alias}=default
    FOR    ${obj}    IN    @{object_list}
        Run Keyword If    "${obj["operate"]}"=="add"    selenium_coam.add_object
        ...    object_name=${obj["object_name"]}    object_class_name=${obj["object_class_name"]}
        ...    plan_to_copy_from=${obj["plan_to_copy_from"]}    copy_from=${obj["copy_from"]}
        ...    include_subobject=${obj["include_subobject"]}    id_value=${obj["id_value"]},
        ...    is_load_default_values=${obj["is_load_default_values"]}    sbts=${alias}
        ...    ELSE    selenium_coam.remove_object    object_name=${obj["object_name"]}    sbts=${alias}
    END

Selenium Get Teardown Parameters
    [Arguments]    ${para}    ${bts_id}
    ${host_ip}    Get Scfc localIpAddr    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    ${alias}    Set Variable    get_para_${bts_id}
    Selenium Login    url=https://${host_ip}    version=${NODE_CFG["${bts_id}"]["software_release"]}
    ...    alias=${alias}
    ${out_value}    selenium_coam.get_parameter_value    dist_name=${para["dist_name"]}
    ...    filter_param=${para["para_name"]}    sbts=${alias}
    ${teardown_para}    Create Dictionary    dist_name=${para["dist_name"]}    para_name=${para["para_name"]}
    ...    para_value=${out_value}
    Append To List    ${TEARDOWN_PARA_LIST}    ${teardown_para}
    ${related_para_exist}    Run Keyword And Return Status    Should Not Be Empty    ${para["related_paras"]}
    Return From Keyword If    "${related_para_exist}"=="False"
    ${related_paras}    Set Variable    ${para["related_paras"]}
    FOR    ${related_para}    IN    @{related_paras}
        ${out_value2}    selenium_coam.get_parameter_value    dist_name=${related_para["dist_name"]}
        ...    filter_param=${related_para["para_name"]}    sbts=${alias}
        ${teardown_para2}    Create Dictionary    dist_name=${related_para["dist_name"]}
        ...    para_name=${related_para["para_name"]}    para_value=${out_value2}
        Append To List    ${TEARDOWN_PARA_LIST}    ${teardown_para2}
    END
    [Teardown]    Selenium Logout    alias=${alias}

Selenium Block BTS Site
    [Arguments]    ${btsid}    ${hostip}
    Selenium Login    url=https://${hostip}    version=${NODE_CFG["${bts_id}"]["software_release"]}    alias=${btsid}
    selenium_coam.block_site    sbts=${btsid}
    [Teardown]    Selenium Logout    alias=${btsid}

Selenium Unblock BTS Site
    [Arguments]    ${btsid}    ${hostip}
    Selenium Login    url=https://${hostip}    version=${NODE_CFG["${bts_id}"]["software_release"]}    alias=${btsid}
    selenium_coam.unblock_site    sbts=${btsid}
    [Teardown]    Selenium Logout    alias=${btsid}

MultiNode Selenium Login
    [Arguments]    ${bts_id_list}=${BTS_LIST}
    FOR    ${bts_id}    IN    @{bts_id_list}
        ${localIpAddr}    Get Scfc localIpAddr    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
        Selenium Login    url=https://${localIpAddr}
        ...    version=${NODE_CFG["${bts_id}"]["software_release"]}    alias=${CASE_NAME}_${bts_id}_ui
    END

MultiNode Selenium Logout
    [Arguments]    ${bts_id_list}=${BTS_LIST}
    FOR    ${bts_id}    IN    @{bts_id_list}
        Selenium Logout    alias=${CASE_NAME}_${bts_id}_ui
    END

MultiNode Selenium Activate
    [Arguments]    ${bts_id_list}=${BTS_LIST}
    FOR    ${bts_id}    IN    @{bts_id_list}
        sleep    10s
        selenium_coam.validate_plan    sbts=${CASE_NAME}_${bts_id}_ui
        sleep    10s
        selenium_coam.activate_plan    sbts=${CASE_NAME}_${bts_id}_ui
    END

Cells deletion With Selenium
    [Arguments]    ${cell_list}
    FOR    ${cell_info}    IN    @{cell_list}
        ${alias}    Set Variable    ${CASE_NAME}_${cell_info["btsId"]}_ui
        Run Keyword If    "${cell_info['NetworkType']}"=="4G"    Cell deletion With Selenium For LTE
        ...    ${cell_info["cellId"]}    alias=${alias}
        ...    ELSE    Cell deletion With Selenium For NR    ${cell_info["cellId"]}    ${cell_info["nrCellGRP"]}
        ...    ${cell_info["btsId"]}    alias=${alias}
    END

Check Cells Deletion Not Exist
    [Arguments]    ${cell_list}
    FOR    ${cell_info}    IN    @{cell_list}
        ${technology}    Run Keyword If    "${cell_info["NetworkType"]}"=="SA" or "${cell_info["NetworkType"]}"=="NSA"
        ...    Set Variable    NR
        ...    ELSE IF    "${cell_info["NetworkType"]}"=="4G"    Set Variable    LTE
        ${cell_status}    Run Keyword And Return Status    selenium_coam.get_cell_info    cell_idx=${cell_info["cellId"]}
        ...    technology=${technology}    sbts=${CASE_NAME}_${cell_info["btsId"]}_ui
        Should Not Be True    ${cell_status}
    END

Cells Addition With Selenium
    [Arguments]    ${cell_list}    ${bts_id_list}
    FOR    ${bts_id}    IN    @{bts_id_list}
        selenium_coam.Load Commissioning File And Check Load Status    file_path=${NODE_CFG["${bts_id}"]["scf_file_path"]}
        ...    sbts=${CASE_NAME}_${bts_id}_ui
    END
    FOR    ${cell_info}    IN    @{cell_list}
        ${alias}    Set Variable    ${CASE_NAME}_${cell_info["btsId"]}_ui
        Run Keyword If    "${cell_info['NetworkType']}"=="4G"    Cell Addition With Selenium For LTE
        ...    ${cell_info["cellId"]}    ${cell_info["lcrId"]}    ${cell_info["btsId"]}    alias=${alias}
        ...    ELSE    Cell Addition With Selenium For NR    ${cell_info["cellId"]}
        ...    ${cell_info["nrCellGRP"]}   ${cell_info["lcrId"]}   ${cell_info["btsId"]}    alias=${alias}
    END

Cell deletion With Selenium For LTE
    [Arguments]    ${delete_cell_id}    ${alias}=default
    selenium_coam.remove_object    object_name=LNCEL-${delete_cell_id}    timeout=60    sbts=${alias}
    selenium_coam.remove_object    object_name=LCELL-${delete_cell_id}    timeout=60    sbts=${alias}

Cell deletion With Selenium For NR
    [Arguments]    ${delete_cell_id}    ${cellgrp_id}    ${bts_id}    ${alias}=default
    ${cells_info}    coam.get_cells_info    cell_type=nr    timeout=60    connection=${CASE_NAME}_${bts_id}
    ${cell_group_num}    Get Length    ${cells_info}
    selenium_coam.remove_object    object_name=NRCELL-${delete_cell_id}    timeout=60    sbts=${alias}
    selenium_coam.remove_object    object_name=LCELNR-${delete_cell_id}    timeout=60    sbts=${alias}
    selenium_coam.remove_object    object_name=NRCELLGRP-${cellgrp_id}    timeout=60    sbts=${alias}
    FOR    ${index}    IN RANGE    ${cell_group_num}
        ${value}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group    node_index=${index}     sbts=${alias}
        Run Keyword If    "${value}"=="${cellgrp_id}"    Run Keywords    selenium_coam.remove_element
        ...    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group    node_index=${index}     sbts=${alias}
        ...    AND    Exit For Loop
    END

Get Plan Configuration Name
    [Arguments]    ${bts_id}    ${scf_file}=${EMPTY}
    ${scf_file}  Set Variable If  "${scf_file}" == "${EMPTY}"  ${NODE_CFG["${bts_id}"]["scf_file_path"]}  ${scf_file}
    ${sw_release}    Set Variable    ${NODE_CFG["${bts_id}"]["software_release"]}
    ${scf_name}    Should Match Regexp    ${scf_file}    ([^/]+?)\\.\\w+$
    ${plan_scfc}    Run Keyword If    '${sw_release}' == 'SBTS25R1' or '${sw_release}' == 'SBTS24R3'
    ...    Set Variable    CONF-1
    ...    ELSE    Set Variable    CONF-1_${scf_name[1]}
    [Return]    ${plan_scfc}

Cell Addition With Selenium For NR
    [Arguments]    ${add_cell_id}    ${cellgrp_id}    ${lcrid}    ${bts_id}    ${alias}=default
    ${plan_scfc}    Get Plan Configuration Name    ${bts_id}
    ${cells_info}    coam.get_cells_info    cell_type=nr    timeout=60    connection=${CASE_NAME}_${bts_id}
    ${cell_group_num}    Get Length    ${cells_info}
    selenium_coam.add_object    object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1    object_class_name=LCELNR
    ...    plan_to_copy_from=${plan_scfc}    copy_from=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${add_cell_id}
    ...    include_subobject=${True}    id_value=${add_cell_id}    sbts=${alias}
    selenium_coam.add_object    object_name=MRBTS-${bts_id}/NRBTS-${bts_id}    object_class_name=NRCELL
    ...    plan_to_copy_from=${plan_scfc}    copy_from=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${add_cell_id}    include_subobject=${True}
    ...    id_value=${add_cell_id}    sbts=${alias}
    selenium_coam.add_object    object_name=MRBTS-${bts_id}/NRBTS-${bts_id}    object_class_name=NRCELLGRP
    ...    plan_to_copy_from=${plan_scfc}    copy_from=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELLGRP-${cellgrp_id}
    ...    include_subobject=${True}    id_value=${cellgrp_id}    sbts=${alias}
    selenium_coam.Set Parameter Value    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${add_cell_id}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrid}    sbts=${alias}
    selenium_coam.Add Element    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRDU-1     abbr=refNrCellGroup
    ...    filter_param=Reference to cell group    sbts=${alias}
    selenium_coam.Set Parameter Value    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRDU-1    filter_param=Reference to cell group
    ...    new_value=${cellgrp_id}    node_index=${cell_group_num}    sbts=${alias}

Cell Addition With Selenium For LTE
    [Arguments]    ${add_cell_id}    ${lcrid}    ${bts_id}    ${alias}=default
    ${plan_scfc}    Get Plan Configuration Name    ${bts_id}
    selenium_coam.add_object    object_name=MRBTS-${bts_id}/LNBTS-${bts_id}    object_class_name=LNCEL
    ...    plan_to_copy_from=${plan_scfc}    copy_from=MRBTS-${bts_id}/LNBTS-${bts_id}/LNCEL-${add_cell_id}
    ...    include_subobject=${True}    id_value=${add_cell_id}    sbts=${alias}
    selenium_coam.add_object    object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1    object_class_name=LCELL
    ...    plan_to_copy_from=${plan_scfc}    copy_from=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${add_cell_id}
    ...    include_subobject=${True}    id_value=${add_cell_id}    sbts=${alias}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}/LNCEL-${add_cell_id}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrid}    sbts=${alias}

Normal NRcell Copy From Super cell
    [Arguments]    ${cell_id}   ${cellgrp_id}    ${channel_group_id}    ${new_physCellId}    ${new_lcrid}    ${new_cell_id}
    ...    ${new_cellgrp_id}    ${bts_id}    ${alias}=default
    ${cell_group_list}    selenium_coam.get_object_name_list    object_name=NRCELLGRP     timeout=60    sbts=${alias}
    ${cell_group_num}    Get Length    ${cell_group_list}
    selenium_coam.add_object    object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1    object_class_name=LCELNR
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
    ...    include_subobject=${False}    id_value=${new_cell_id}    sbts=${alias}
    selenium_coam.add_object    object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${new_cell_id}
    ...    object_class_name=CHANNELGROUP    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${channel_group_id}
    ...    include_subobject=${True}    id_value=${channel_group_id}    sbts=${alias}
    selenium_coam.add_object    object_name=MRBTS-${bts_id}/NRBTS-${NODE_CFG["${bts_id}"]["nrbts"]}    object_class_name=NRCELL
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${bts_id}/NRBTS-${NODE_CFG["${bts_id}"]["nrbts"]}/NRCELL-${cell_id}
    ...    include_subobject=${True}    id_value=${new_cell_id}    sbts=${alias}
    selenium_coam.add_object    object_name=MRBTS-${bts_id}/NRBTS-${NODE_CFG["${bts_id}"]["nrbts"]}    object_class_name=NRCELLGRP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${bts_id}/NRBTS-${NODE_CFG["${bts_id}"]["nrbts"]}/NRCELLGRP-${cellgrp_id}
    ...    include_subobject=${True}    id_value=${new_cellgrp_id}    sbts=${alias}
    selenium_coam.Set Parameter Value    dist_name=MRBTS-${bts_id}/NRBTS-${NODE_CFG["${bts_id}"]["nrbts"]}/NRCELL-${new_cell_id}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${new_lcrid}    sbts=${alias}
    selenium_coam.Set Parameter Value    dist_name=MRBTS-${bts_id}/NRBTS-${NODE_CFG["${bts_id}"]["nrbts"]}/NRCELL-${new_cell_id}
    ...    filter_param=Physical cell identifier    abbr=physCellId    new_value=${new_physCellId}    sbts=${alias}
    selenium_coam.Add Element    dist_name=MRBTS-${bts_id}/NRBTS-${NODE_CFG["${bts_id}"]["nrbts"]}/NRDU-1     abbr=refNrCellGroup
    ...    filter_param=Reference to cell group    sbts=${alias}
    selenium_coam.Set Parameter Value    dist_name=MRBTS-${bts_id}/NRBTS-${NODE_CFG["${bts_id}"]["nrbts"]}/NRDU-1
    ...    filter_param=Reference to cell group    new_value=${new_cellgrp_id}    node_index=${cell_group_num}    sbts=${alias}
    selenium_coam.Set Parameter Value    dist_name=MRBTS-${bts_id}/NRBTS-${NODE_CFG["${bts_id}"]["nrbts"]}/NRCELLGRP-${new_cellgrp_id}
    ...    filter_param=List of NR cells assigned to cell group
    ...    abbr=nrcelllist    new_value=${new_cell_id}    node_index=${0}    sbts=${alias}
    selenium_coam.Set Parameter Value    dist_name=MRBTS-${bts_id}/NRBTS-${NODE_CFG["${bts_id}"]["nrbts"]}/NRCELL-${new_cell_id}
    ...    filter_param=Activate super cell    abbr=actSuperCell    new_value=false    sbts=${alias}
    selenium_coam.Set Parameter Value    dist_name=MRBTS-${bts_id}/NRBTS-${NODE_CFG["${bts_id}"]["nrbts"]}/NRCELLGRP-${new_cellgrp_id}
    ...    filter_param=Number of transmitted Synchronization Signal Blocks
    ...    abbr=numberOfTransmittedSsBlocks    new_value=1 beam    sbts=${alias}
    Run Keyword And Ignore Error    selenium_coam.get_test_clock_status    sbts=${alias}
#    ${smodDN}    selenium_coam.get_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
#    ...    filter_param=System module distinguished name    abbr=smodDN     sbts=${alias}
#    ${smodDN_pre}    ${smodDN_id}    Run Keyword If    "${smodDN}"!="${EMPTY}"    Split String From Right    ${smodDN}     -    1
#    ${new_smodDN_id}    Set Variable If    "${smodDN_id}"=="1"    2    1
#    Run Keyword If    "${smodDN}"!="${EMPTY}"    selenium_coam.Set Parameter Value
#    ...    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${new_cell_id}
#    ...    filter_param=System module distinguished name    abbr=smodDN    new_value=${smodDN_pre}-${new_smodDN_id}    sbts=${alias}

Delete One SubCell
    [Arguments]    ${cell_id}    ${channel_group_id}    ${bts_id}    ${alias}=default
    selenium_coam.remove_object
    ...    object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${channel_group_id}
    ...        timeout=60    sbts=${alias}

Delete SubCells In One Cell
    [Arguments]    ${cell_id}    ${channelgroup_id_list}    ${bts_id}    ${alias}=default
    FOR    ${channelgroup_id}    IN    @{channelgroup_id_list}
        Delete One SubCell    ${cell_id}    ${channel_group_id}    ${bts_id}    alias=${alias}
    END

Add SubCells In One Cell
    [Arguments]    ${cell_id}    ${channelgroup_id_list}    ${bts_id}    ${scf_file}    ${alias}=default
    selenium_coam.Load Commissioning File And Check Load Status    file_path=${scf_file}
    ...    sbts=${alias}
    ${plan_scfc}    Get Plan Configuration Name    ${bts_id}    scf_file=${scf_file}
    FOR    ${channelgroup_id}    IN    @{channelgroup_id_list}
        selenium_coam.add_object    object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
        ...    object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=${plan_scfc}
        ...    copy_from=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${channelgroup_id}
        ...    include_subobject=${True}    id_value=${channelgroup_id}    sbts=${alias}
        Run Keyword And Ignore Error    selenium_coam.get_test_clock_status    sbts=${alias}
    END

Selenium Refresh Page
    [Arguments]    ${alias}=default
    selenium_coam.refresh_page    sbts=${alias}
    sleep    10s

Copy Lcelnr With Half Subcell
    [Arguments]    ${bts_id}    ${copy_Lcelnr_id}    ${copy_chlgrp_count}    ${new_lcelnr_id}=2    ${alias}=default
    ${copy_lcelnr_distname}    Set Variable    MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${copy_Lcelnr_id}
	selenium_coam.add_object    object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1    object_class_name=LCELNR
	...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=${copy_lcelnr_distname}
	...    include_subobject=${False}    id_value=${new_lcelnr_id}    sbts=${alias}
	${new_chlgrp_id}    Set Variable    ${1}
	${split_chlgrp_count}    Evaluate    int(${copy_chlgrp_count}/2)
    FOR    ${chlgrp_id}    IN RANGE     ${split_chlgrp_count}    ${copy_chlgrp_count}
        ${copy_chlgrp_id}    Evaluate    ${chlgrp_id}+1
        selenium_coam.add_object    object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${new_lcelnr_id}
        ...    object_class_name=CHANNELGROUP    plan_to_copy_from=CURRENT_BTS_CONF-1
        ...    copy_from=${copy_lcelnr_distname}/CHANNELGROUP-${copy_chlgrp_id}
        ...    include_subobject=True    id_value=${new_chlgrp_id}    sbts=${alias}
        selenium_coam.remove_object
        ...    object_name=${copy_lcelnr_distname}/CHANNELGROUP-${copy_chlgrp_id}
        ...    sbts=${alias}
        ${new_chlgrp_id}    Evaluate    ${new_chlgrp_id}+1
        Run Keyword And Ignore Error    selenium_coam.get_test_clock_status    sbts=${alias}
    END

Copy Nrcell With Subobject
    [Arguments]    ${bts_id}    ${copy_cell_id}=1    ${new_cell_id}=2    ${alias}=default
    ${phy_id_list}    Get Key Values From Json List    phyCellId    ${ALL_CELL_LIST}
    selenium_coam.add_object    object_name=MRBTS-${bts_id}/NRBTS-${bts_id}    object_class_name=NRCELL
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${copy_cell_id}
    ...    include_subobject=${True}   id_value=${new_cell_id}    sbts=${alias}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${new_cell_id}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${new_cell_id}    sbts=${alias}

    ${copy_nrarfcn}    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${copy_cell_id}
    ...    filter_param=NR Absolute radio frequency channel number    abbr=nrarfcn    sbts=${alias}
    ${copy_nrarfcn}    Convert To Integer    ${copy_nrarfcn}
    ${new_nrarfcn}    Evaluate    ${copy_nrarfcn}+1000
    ${is_exist}    Run Keyword And Return Status    Variable Should Exist    ${NEW_CELL_NRARFCN}
    ${new_nrarfcn}    Set Variable If    ${is_exist}    ${NEW_CELL_NRARFCN}     ${new_nrarfcn}

    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${new_cell_id}
    ...    filter_param=NR Absolute radio frequency channel number    abbr=nrarfcn
    ...    new_value=${new_nrarfcn}    sbts=${alias}
    ${new_phy_id}    Evaluate    ${phy_id_list[-1]}+1
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${new_cell_id}
    ...    filter_param=Physical cell identifier    abbr=physCellId
    ...    new_value=${new_phy_id}    sbts=${alias}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${new_cell_id}
    ...    filter_param=Cell name    abbr=cellName    new_value=test_${new_cell_id}    sbts=${alias}

Copy Nrcellgrp With Subobject
    [Arguments]    ${bts_id}    ${copy_cellgrp_id}=1    ${new_cellgrp_id}=2    ${new_cell_id}=2    ${alias}=default
    ${cellgrp_list}    Get Key Values From Json List    nrCellGRP    ${ALL_CELL_LIST}
    ${cellgrp_count}    Get Length    ${cellgrp_list}
    selenium_coam.add_object    object_name=MRBTS-${bts_id}/NRBTS-${bts_id}    object_class_name=NRCELLGRP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1   copy_from=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELLGRP-${copy_cellgrp_id}
    ...    id_value=${new_cellgrp_id}    sbts=${alias}
    selenium_coam.add_element    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    sbts=${alias}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group    new_value=${new_cellgrp_id}
    ...    node_index=${cellgrp_count}    sbts=${alias}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELLGRP-${new_cellgrp_id}
    ...    abbr=nrCellList    filter_param=List of NR cells assigned to cell group     new_value=${new_cell_id}
    ...    node_index=${0}    sbts=${alias}

RF Diagnostic Test Edit And Saving Thresholds
    [Arguments]   ${bts_thresholds}    ${bands_thresholds}=${None}     ${activate}=${False}
    ...    ${technology}=LTE    ${cell}=All LTE cells    ${alias}=default
    Log    ${cell}
    selenium_coam.configure_rf_diagnostic_test    activate=${activate}    cell=All LTE cells
    ...    bts_thresholds=${bts_thresholds}    bands_thresholds=${bands_thresholds}    sbts=${alias}
    ...    technology=${technology}   timeout=60
    selenium_coam.save_thresholds    sbts=${alias}    timeout=60

Selenium Start RF Diagnostic Test
    [Arguments]    ${bts_thresholds}=${None}    ${bands_thresholds}=${None}    ${technology}=LTE
    ...    ${cell}=All ${technology} cells    ${alias}=default
    Run Keyword And Ignore Error    RF Diagnostic Test Edit And Saving Thresholds
    ...    ${bts_thresholds}    ${bands_thresholds}    activate=${True}    technology=${technology}    cell=${cell}
    ...    alias=${alias}
    selenium_coam.start_rf_diagnostic_test    timeout=120    sbts=${alias}

Selenium Check RF Diagnostic General Test Information
    [Arguments]    ${cell_list}=${ALL_CELL_LIST}    ${technology}=LTE    ${alias}=default    ${check_item}=${EMPTY}
    ...    ${check_status}=Pass
    ${check_status_copy}    Set Variable    ${check_status}
    FOR    ${cell_info}    IN    @{cell_list}
        ${cell_tech}    Set Variable    ${cell_info["NetworkType"]}
        Continue For Loop If    "${technology}"=="LTE" and "${cell_tech}"!="4G"
        Continue For Loop If    "${technology}"=="NR" and "${cell_tech}"!="SA" and"${cell_tech}"!="NSA"
        ${test_info}    selenium_coam.get_general_test_information    cell_id=${cell_info["cellId"]}    sbts=${alias}
        ${check_test_info}    Convert To String    ${test_info[-1]}
        ${get_status}    Run Keyword If    "${check_item}"=="Fail"
        ...    Selenium Generate RF Diagnostic Test Check Status    ${cell_info["cellId"]}    ${alias}    ${check_item}
        ${check_status}    Set Variable If    "${get_status}"!="None"    ${get_status}    ${check_status_copy}
        Run Keyword If    "${check_status}"=="Pass"    Run Keywords    Should Not Contain    ${check_test_info}    Fail
        ...    AND    Should Not Contain    ${check_test_info}    PrematureTermination
        ...    ELSE IF    "${check_status}"=="PrematureTermination"
        ...    Should Contain    ${check_test_info}    PrematureTermination
        ...    ELSE    Should Contain    ${check_test_info}    Fail
    END

Selenium Generate RF Diagnostic Test Check Status
    [Arguments]    ${cell_id}    ${alias}    ${check_item}
    ${detail_list}    selenium_coam.get_detailed_result_for_each_antenna    cell_id=${cell_id}    sbts=${alias}
    ${vswr_list}    Get Key Values From Json List    VSWR    ${detail_list}
    ${pr_error_list}    Get Key Values From Json List    Forward transmit RF power error (dB)    ${detail_list}
    ${rf_pwr_error_min}    Evaluate    abs(${pr_error_list[0]})
    ${rf_pwr_error_max}    Evaluate    abs(${pr_error_list[-1]})
    ${pr_error_status}    Set Variable If    ${rf_pwr_error_min}>2 or ${rf_pwr_error_max}>2    Fail    Pass
    Return From Keyword If   "${check_item}"=="rf_power_error"    ${pr_error_status}
    ${vswr_status}    Set Variable If    ${vswr_list[-1]}>1    Fail    Pass
    Return From Keyword If   "${check_item}"=="vswr"    ${vswr_status}

Selenium Get RF Diagnostic Detailed Result
    [Arguments]    ${cell_list}=${ALL_CELL_LIST}    ${technology}=LTE    ${alias}=default
    ${detail_dict}    Create Dictionary
    FOR    ${cell_info}    IN    @{cell_list}
        ${cell_tech}    Set Variable    ${cell_info["NetworkType"]}
        Continue For Loop If    "${technology}"=="LTE" and "${cell_tech}"!="4G"
        Continue For Loop If    "${technology}"=="NR" and "${cell_tech}"!="SA" and"${cell_tech}"!="NSA"
        ${detail_result}    selenium_coam.get_detailed_result_for_each_antenna    cell_id=${cell_info["cellId"]}
        ...    sbts=${alias}
        Set To Dictionary    ${detail_dict}    ${cell_info["cellId"]}=${detail_result}
    END
    [Return]    ${detail_dict}

Remove RF Diagnostic Test
    [Arguments]   ${bts_id}    ${alias}=default
    selenium_coam.remove_object    object_name=TEST-1    sbts=${alias}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate remote RF diagnostic test     abbr=actRemoteRfDiag
    ...    new_value=false    sbts=${alias}
    selenium active plan    alias=${alias}

Selenium Run Diagnostic Test
    [Arguments]   ${bts_thresholds}=${None}    ${bands_thresholds}=${None}     ${activate}=${True}
    ...    ${technology}=LTE    ${cell}=All ${technology} cells    ${alias}=default
    selenium_coam.configure_rf_diagnostic_test    activate=${activate}    cell=${cell}
    ...    bts_thresholds=${bts_thresholds}    bands_thresholds=${bands_thresholds}    sbts=${alias}
    ...    technology=${technology}   timeout=60
    selenium_coam.start_rf_diagnostic_test    timeout=120    sbts=${alias}
