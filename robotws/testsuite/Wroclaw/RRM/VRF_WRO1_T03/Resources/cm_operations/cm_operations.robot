*** Settings ***
Documentation
...     Keywords set for cm operations

Library    BuiltIn
Library    OperatingSystem
Library    XML  lxml=True
Library    taf.config.scf    WITH NAME    scf
Library    taf.sbts.oam.coam.admin     WITH NAME     admin
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell

*** Variables ***
${local_mplane_ip}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${bts_port}    443

*** Keywords ***
Connect To Admin
    [Arguments]    ${bts_host}=${local_mplane_ip}    ${bts_port}=${bts_port}    ${username}=Nemuadmin
    ...                     ${password}=nemuuser     ${connection}=default    ${timeout}=120
    Log    --- Connect to admin: Nemuadmin@${local_mplane_ip} ---    console=True
    admin.Connect To    ${bts_host}    ${bts_port}   username=${username}
    ...                     password=${password}     name=${connection}    timeout=${timeout}
    Log    --- Connection to admin established with name: ${connection} ---    console=True

Close Admin Connection
    [Arguments]    ${connection}=default
    Log    --- Close connection do admin ---    console=True
    admin.Teardown Admin    ${connection}
    Log    --- Connection to admin closed ---    console=True

Activate Internal Trace
    [Arguments]    ${actordeact}=${True}
    Log    --- Start activate internal trace ---    console=True
    ${scf_file}    admin.Get Current Scf File    local_dir_path=${OUTPUT_DIR}    file_name=actual_SCF.xml    timeout=60s
    scf.Load Scf    ${scf_file}
    ${trace}    scf.Get Value From Scf    dist_name=MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ...     p_name=actInternalTrace
    Run Keyword If    '${trace}'=='False' or '${trace}'=='false'
    ...    admin.perform parameter recommissioning    dist_name=MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter=actInternalTrace    value=${actordeact}    operation=update
    ...    ELSE IF    '${trace}'=='True' or '${trace}'=='true'    Deactive And Active Internal Trace
    Log    --- Internal trace activated ---    console=True

Deactive And Active Internal Trace
    Log    --- Set to false and next to true actInternalTrace parameter ---    console=True
    admin.Perform Parameter Recommissioning    dist_name=MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter=actInternalTrace    value=${False}    operation=update
    Sleep    30s
    admin.Perform Parameter Recommissioning    dist_name=MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter=actInternalTrace    value=${True}    operation=update

#########################
#    Cell operations    #
#########################
Modify Cell Param
    [Arguments]    ${cell_id}    ${param_name}    ${param_value}
    ${param_to_modify}=    Set Variable
    ...    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-${cell_id}, ${param_name}, ${param_value}
    Modify parameter    ${param_to_modify}

Unbarr Cell
    [Arguments]    ${cell_id}
    ${current_value}=    Check Param Value
    ...     dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-${cell_id}    param=cellBarred
    Run Keyword If    '${current_value}'=='barred'    Modify Cell Param      ${cell_id}    cellBarred    notBarred

Barr Cell
    [Arguments]    ${cell_id}
    ${current_value}=    Check Param Value
    ...     MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-${cell_id}    cellBarred
    Run Keyword If    '${current_value}'=='notBarred'    Modify Cell Param      ${cell_id}    cellBarred    barred

Wait For All Cells To Be OnAir
    [Arguments]    ${wait_time_min}=12
    Log To Console    Wait Max ${wait_time_min}min For All Cells To Be OnAir
    Wait Until Keyword Succeeds    ${wait_time_min}min    15s    gnbcell.Verify All Cells Are Onair

Wait For Cell To Be OnAir
    [Arguments]    ${id}=1    ${wait_time_min}=12
    Log To Console    Wait Max ${wait_time_min}min For Cell Id ${id} To Be OnAir
    Wait Until Keyword Succeeds    ${wait_time_min}min    15s    gnbcell.Verify Cell Is Onair  cell_id=${id}

Create new Cell via Delta
	[Documentation]    This KW will create new Cell by copy another one from SCF. All neccesary parameters will be updated accordingly.
	...    Arguments:
	...    cell_id - Mandatory parameter. Correct Cell ID number that will be used to create new one.
	...    t_rmod - Targed RMOD of new cell. Type "None" to no changes.
	...    prachc_i - PrachConfigurationIndex for new cell. Default - prach_from_old_one +1.
	...    t_cellgroup - Target CellGroup ID - Default value - 50.
	...    t_cell_id - Target Cell ID of new cell - Default value - 50.
	...    phys_id - physCellId of new cell - Default value - 100.
	...    cellgroup_i - index from nrCellList in NRCELLGRP of new cell.
	...    mrbts_id_delta - MNBTSID - Default value is taken from init file.
	...    Returns:
	...    Cell ID of new cell.
	...    New CellGroup ID.
    [Arguments]    ${cell_id}    ${prachc_i}=98    ${t_cellgroup}=2
    ...    ${t_cell_id}=2    ${phys_id}=222    ${cellgroup_i}=0    ${mrbts_id_delta}=${tl.gnbs[0].instance_id}
    ...    ${skip_parameter_relation_errors}=False
    ${scf_1}    ${scf_2}    Start Delta preparation
    ${t_cell_id}    ${t_cellgroup}  Add new cell to Delta    ${cell_id}    ${prachc_i}    ${t_cellgroup}
    ...    ${t_cell_id}    ${phys_id}    ${cellgroup_i}    ${mrbts_id_delta}
    Create and upload Delta    ${scf_1}    ${scf_2}    ${skip_parameter_relation_errors}
    [Return]    ${t_cell_id}    ${t_cellgroup}

Add new cell to Delta
    [Documentation]    Create new cell by copying another existing cell. Arguments are the same like in "Create new Cell via Delta" KW.
    ...    Returns new Cell ID and Cell Group.
    [Arguments]    ${original_cell_id}    ${prach_conf_index}=98    ${target_cellgroup_id}=2
    ...    ${target_cell_id}=2    ${phys_cell_id}=222    ${cellgroup_index}=0    ${mrbts_id_for_new_cell}=${tl.gnbs[0].instance_id}
    ...    ${nrarfcn}=630000
#    ${original_cellgroup_id}    Get CellGroup number from Cell    ${original_cell_id}
    scf.clone_mo_with_descendant_mos    MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELL-${original_cell_id}
    ...    MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELL-${target_cell_id}
    scf.clone_mo_with_descendant_mos    MRBTS-${mrbts_id_for_new_cell}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${original_cell_id}
    ...    MRBTS-${mrbts_id_for_new_cell}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${target_cell_id}
    scf.clone_mo_with_descendant_mos    MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELLGRP-1
    ...    MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELLGRP-${target_cellgroup_id}
    scf.modify_scf_element    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELLGRP-2
    ...    list_name=nrCellList    index=${cellgroup_index}    value=${target_cell_id}
    scf.modify_scf_element    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELL-${target_cell_id}    p_name=lcrId
    ...    value=${target_cell_id}
    scf.modify_scf_element    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELL-${target_cell_id}    p_name=nrarfcn
    ...    value=${nrarfcn}
    scf.add_elements_to_list    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRDU-1    list_name=refNrCellGroup
    ...    elements=c
    ${refNrCellGroup_modified}    scf.get_all_values_from_scf    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRDU-1
    ...    list_name=refNrCellGroup
    set test variable    ${refNrCellGroup_index}    0
    FOR    ${i}    IN    @{refNrCellGroup_modified}
        ${cellgroup_c}    run keyword and return status    should be equal    ${i}    c
        run keyword if    '${cellgroup_c}'=='True'    scf.modify_scf_element
        ...    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRDU-1
        ...    list_name=refNrCellGroup    index=${refNrCellGroup_index}    value=${target_cellgroup_id}
        ${refNrCellGroup_index}    evaluate    ${refNrCellGroup_index}+1
    END
    run keyword if    '${prach_conf_index}'=='None'    Prach index change    ${target_cell_id}    ELSE    scf.modify_scf_element
    ...    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELL-${target_cell_id}    p_name=prachConfigurationIndex
    ...    value=${prach_conf_index}
    scf.modify_scf_element    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELL-${target_cell_id}    p_name=physCellId
    ...    value=${phys_cell_id}
    [Return]    ${target_cell_id}    ${target_cellgroup_id}

Delete Cell via Delta
    [Documentation]    By this KW cell will be deleted using delta json. NRCELLGRP from target cell will be erased also.
    ...    Arguments:
    ...    t_cell_id - Cell ID which will be removed.
    ...    mrbts_id_delta - MNBTSID - Default value is taken from init file.
    [Arguments]    ${t_cell_id}    ${mrbts_id_delta}=${tl.gnbs[0].instance_id}
    ${scf_1}    ${scf_2}    Start Delta preparation
    Delete Cell by Delta    ${t_cell_id}    ${mrbts_id_delta}
    Create and upload Delta    ${scf_1}    ${scf_2}

Delete Cell by Delta
    [Documentation]    Will delete Cell from uploaded SCF.
    [Arguments]    ${target_cell_id}    ${mrbts_id_for_new_cell}=${tl.gnbs[0].instance_id}
    ${target_cellgroup_id}    Get CellGroup number from Cell    ${target_cell_id}
    scf.remove_mo_with_descendant_mos    MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELL-${target_cell_id}
    scf.remove_mo_with_descendant_mos    MRBTS-${mrbts_id_for_new_cell}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${target_cell_id}
    scf.remove_mo_with_descendant_mos    MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELLGRP-${target_cellgroup_id}
    ${refNrCellGroup_modified}    scf.get_all_values_from_scf    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRDU-1
    ...    list_name=refNrCellGroup
    set test variable    ${refNrCellGroup_index}    0
    FOR    ${i}    IN    @{refNrCellGroup_modified}
        ${cellgroup_c}    run keyword and return status    should be equal    ${i}    ${target_cellgroup_id}
        run keyword if    '${cellgroup_c}'=='True'    scf.remove_element_from_scf
        ...    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRDU-1
        ...    list_name=refNrCellGroup    index=${refNrCellGroup_index}
        ${refNrCellGroup_index}    evaluate    ${refNrCellGroup_index}+1
    END

Get CellGroup number from Cell
    [Documentation]    KW used to retrieve Cell Group number based on Cell ID.
    [Arguments]    ${cell_number}
    ${cellggroup_list}    admin.get_bts_info
    FOR    ${c}    IN    @{cellggroup_list["cellsGroup"]}
        ${cell_is_visible}    run keyword and return status    should contain    ${c["nrCellList"]}    NRCELL-${cell_number}
        run keyword if    '${cell_is_visible}'=='False'    continue for loop
        ${cellgroup_id}    fetch from right    ${c["name"]}    -
    END
    [Return]    ${cellgroup_id}

########################
#    SCF operations    #
########################
Activate Scf
    [Arguments]    ${scf}
    Wait Until Keyword Succeeds    7 min   30 sec   admin.Perform Commissioning
    ...     scf_file=${scf}
    ...     skip_parameter_relation_errors=${False}
    ...     connection=default
    ...     timeout=900

Modify Parameter
    [Arguments]    ${param_to_modify}
    ${scf_1}    ${scf_2}    Start Delta preparation
    ${dist_name}    ${param}    ${new_value}=    Split String    ${param_to_modify}    ,${SPACE}
    scf.modify_scf_element    dist_name=${dist_name}    p_name=${param}    value=${new_value}
    Create and upload Delta    ${scf_1}    ${scf_2}
    [Teardown]    Run Keywords    Run    cd /home/ute/MN/UTE/robotws && rm actual_SCF.xml    AND
    ...                           Run    cd /home/ute/MN/UTE/robotws && rm basic_SCF.xml     AND
    ...                           Run    cd /home/ute/MN/UTE/robotws && rm delta_SCF.xml     AND
    ...                           Run    cd /home/ute/MN/UTE/robotws && rm delta.json

Start Delta preparation
    [Documentation]    Required to create new Delta. Returns scfs path that will be used during delta commissioning.
    ${scf_file}=     admin.get_current_scf_file    local_dir_path=${OUTPUT_DIR}    file_name=basic_SCF.xml    timeout=30
    ${scf_file_delta}=     admin.get_current_scf_file    local_dir_path=${OUTPUT_DIR}    file_name=delta_SCF.xml    timeout=30
    scf.load_scf    ${scf_file_delta}
    [Return]    ${scf_file}    ${scf_file_delta}

Create and upload Delta
    [Documentation]    Only works when "Start Delta preparation" was executied and other changes was made (for example
    ...    new cell or parameter modify).
    [Arguments]    ${scf_file}    ${scf_file_delta}    ${skip_parameter_relation_errors}=False
    scf.save_scf    ${scf_file_delta}
    scf.calculate_delta_scf    ${scf_file_delta}    ${scf_file}    ${OUTPUT_DIR}/delta.json
    admin.perform_delta_recommissioning
    ...     delta_file=${OUTPUT_DIR}/delta.json
    ...     skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...     should_activate=True
    ...     timeout=1800

Check Param Value
    [Arguments]    ${dist_name}    ${param}
    ${scf_file}    admin.get_current_scf_file    local_dir_path=${OUTPUT_DIR}    file_name=actual_SCF.xml
    ...    export_type=configurationAndRuntimeObjects    timeout=30
    scf.load_scf    ${scf_file}
    ${current_value}=    scf.get value from scf    dist_name=${dist_name}    p_name=${param}
    [Teardown]    Run    cd /home/ute/MN/UTE/robotws && rm actual_SCF.xml
    [Return]    ${current_value}

########################
#    Prepare Vendor File
########################
Prepare And Upload Vendor File
    [Arguments]    ${activate_scf}=${False}
    admin.Download Vendor File    /home/ute/Downloads/vendor_file_test
    ${xml}=    Parse XML    /home/ute/Downloads/vendor_file_test
    Set Element To Proper Value    ${xml}    ABIO    64    UL  NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm    588    1176    1092
    Set Element To Proper Value    ${xml}    ABIO    48    DL  NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm    1092    1092    800
    Set Element To Proper Value    ${xml}    ABIP    48    DL  NR_L1Pool_Thor_TDD_FR1_eCPRI    1092    1092    800
    Set Element To Proper Value    ${xml}    ABIP    48    UL  NR_L1Pool_Thor_TDD_FR1_eCPRI    588    1176    1092
    Save Xml    ${xml}    /home/ute/Downloads/vendor_file_new
    admin.Set Vendor File    /home/ute/Downloads/vendor_file_new
    Run Keyword If    ${activate_scf}    Activate Scf
    ...    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/VRF_WRO1_T03/Features/Pmax/pmax_resources/scf_branch.xml

Set Element To Proper Value
    [Arguments]    ${xml}    ${bbmod}    ${cssize}    ${direction}    ${l1PoolType}    ${layer_new_value}
    ...     ${stream_new_value}    ${wbstream_new_value}
    ${xpath_main_1}=    Set Variable
    ...    .//item[p[@name="bbHwVariant"][text()="${bbmod}"] and p[@name="csSize"][text()="${cssize}"] and
    ${xpath_main_2}=    Set Variable
    ...    p[@name="direction"][text()="${direction}"] and p[@name="l1PoolType"][text()="${l1PoolType}"]]
    ${xpath1}=    Set Variable    /p[@name="maxNumStreamPrbL1Sp"]
    ${xpath2}=    Set Variable    /p[@name="maxNumLayerPrbL1Sp"]
    ${xpath3}=    Set Variable    /p[@name="maxNumWbStreamPrbL1Sp"]
    ${stream}=    Catenate    ${xpath_main_1}    ${xpath_main_2}    ${xpath1}
    ${layer}=    Catenate    ${xpath_main_1}    ${xpath_main_2}    ${xpath2}
    ${wbstream}=    Catenate    ${xpath_main_1}    ${xpath_main_2}    ${xpath3}
    Set Element Text    ${xml}    ${stream_new_value}    xpath=${stream}
    Set Element Text    ${xml}    ${layer_new_value}    xpath=${layer}
    Set Element Text    ${xml}    ${wbstream_new_value}    xpath=${wbstream}
