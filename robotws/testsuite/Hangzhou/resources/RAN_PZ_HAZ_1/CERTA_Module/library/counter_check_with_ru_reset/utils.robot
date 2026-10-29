*** Settings ***
Documentation
...    Module files

Library    XML    use_lxml=true
Library    taf.hw.rf_attenuator    WITH NAME    attenuator
Library    taf.sbts.oam.coam.admin               WITH NAME    coam
Library    taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library    ./parser_xml.py

Resource    ./Commercial_phone.robot
Resource    ../../../Module/Module.robot

*** Keywords ***
UE L3 Call with traffic
    [Arguments]    ${product_type}    ${ue_type}    ${PA_param}
    ...    ${bts_index}=${0}    ${cudu_index}=${0}    &{kwargs}
    Set PA Value    source=${PA_param["source_max"]}
    ...    tl_descriptor_path=${PA_param["tl_descriptor_path"]}    cell_list=${PA_param["cell_list"]}    function=disable
    Set PA Value    source=${PA_param["source"]}
    ...    tl_descriptor_path=${PA_param["tl_descriptor_path"]}    cell_list=${PA_param["call_cell"]}    function=enable
    ${cell_bar}    get_cell_bar_for_same_ru    ${product_type}    ${PA_param["call_cell"]}    ${PA_param["cell_list"]}
    Make Cell Bar    ${product_type}    ${cell_bar}    bts_index=${bts_index}    cudu_index=${cudu_index}
    Run Keyword    ${ue_type}.L3 Call with traffic    &{kwargs}
    [Teardown]    Run Keywords    Run keyword And Continue On Failure    Make Cell UnBar    ${product_type}    ${cell_bar}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    ...    AND    Set PA Value    source=${PA_param["source"]}
    ...    tl_descriptor_path=${PA_param["tl_descriptor_path"]}    cell_list=${PA_param["call_cell"]}    function=disable

Get Cell Info With Cell Distname Id
    [Arguments]    ${cell_distname_id}    ${cell_list}
    FOR    ${cell_info}    IN    @{cell_list}
        Return From Keyword If    "${cell_distname_id}"=="${cell_info["distName"]}"    ${cell_info}
    END
    Fail

Get RUs Distname Mapping Cell
    [Arguments]    ${cell_info}
    ${ru_distname_list}    Create List
    FOR    ${rf}    IN    @{cell_info["RF"]}
        ${ru_distname}    Split String    ${rf["distName"]}    /
        Append To List    ${ru_distname_list}    ${ru_distname[-1]}
    END
    ${rus_distname}    Catenate    @{ru_distname_list}
    [Return]    ${rus_distname}

Get Related Cell Info
    [Arguments]    ${product_type}    ${cell_distname_id}    ${bts_index}=${0}    ${cudu_index}=${0}
    ${scfc_path}    Get Current Scf File    ${product_type}    bts_index=${bts_index}    cudu_index=${cudu_index}
    ${cell_list}    parser_xml.Get Cells Info    ${scfc_path}
    ${cell_info}    Get Cell Info With Cell Distname Id    ${cell_distname_id}    ${cell_list}
    ${rus_distname}    Get RUs Distname Mapping Cell    ${cell_info}
    [Return]    ${cell_list}    ${cell_info}    ${rus_distname}

Set PA Value
    [Arguments]    ${source}=${None}    ${tl_descriptor_path}=${None}    ${cell_list}=${None}    ${function}=enable
    Run Keyword If    "${source}" != "${None}"    PA Operation    source=${source}    target=${None}
    ...    ELSE IF  "${tl_descriptor_path}" != "${None}"  Set Attenuation Values  ${cell_list}  ${tl_descriptor_path}  ${function}
    ...    ELSE    Log To Console    No need to set PA value!

Make Cell Bar
    [Arguments]    ${product_type}    ${cell_distname_id}    ${bts_index}=${0}    ${cudu_index}=${0}
    ${cell_num}    Get Length    ${cell_distname_id}
    Return From Keyword If    ${cell_num} == ${0}
    ${para_list}    Create List    cellBarred
    ${value_list}    Create List    barred
    ${out}    Parameter Operation    operation=parameter_update    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}    para_list=${para_list*${cell_num}}
    ...    value_list=${value_list*${cell_num}}    mo_list=@{cell_distname_id}

Make Cell Unbar
    [Arguments]    ${product_type}    ${cell_distname_id}    ${bts_index}=${0}    ${cudu_index}=${0}
    ${cell_num}    Get Length    ${cell_distname_id}
    Return From Keyword If    ${cell_num} == ${0}
    ${para_list}    Create List    cellBarred
    ${value_list}    Create List    notBarred
    ${out}    Parameter Operation    operation=parameter_update    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}    para_list=${para_list*${cell_num}}
    ...    value_list=${value_list*${cell_num}}    mo_list=@{cell_distname_id}

Get Current Scf File
    [Arguments]    ${product_type}=gnb
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${folder_path}=${OUTPUT DIR}
    ...            ${alias}=get_scfc
    ${tmp_product_type}    Run keyword If   "${product_type}"=="vdu"    Set Variable    vdu
    ...    ELSE IF    "${product_type}"=="gnb" or "${product_type}"=="enb"    Set Variable    classic
    ...    ELSE    Fail    Invalid product type!
    Run keyword    _${product_type}.API Login    product_type=${product_type}    alias=${alias}
    ...    bts_index=${bts_index}    vdu_index=${cudu_index}
    ${scf_path}    Run Keyword    _${tmp_product_type}.get current scf file    folder_path=${folder_path}
    ...    alias=${alias}
    [Return]    ${scf_path}
    [Teardown]    Run Keyword And Ignore Error    _${tmp_product_type}.API Logout    alias=${alias}

_enb.API login
    [Arguments]    ${alias}=default    ${bts_index}=${0}    &{kwargs}
    ${status}    Run Keyword And Return Status    Should Not Be Equal    ${tl.enbs[${bts_index}].airscale}    ${None}
    ${module}    Set Variable If    "${status}"=="True"     airscale    system_module
    coam.connect_to    bts_host=${tl.enbs[0].${module}.common_units[0].lmp_connection.addr}
    ...    admin_api_log_dir=${OUTPUT_DIR}
    ...    use_ssl=${True}
    ...    update_interval=${5000}
    ...    name=${alias}

_gnb.API login
    [Arguments]    ${alias}=default    ${bts_index}=${0}    &{kwargs}
    coam.connect_to    bts_host=${tl.gnbs[${bts_index}].cu.oam_http_connection_details.addr}
    ...    username=${tl.gnbs[${bts_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${bts_index}].cu.oam_http_connection_details.password}
    ...    admin_api_log_dir=${OUTPUT_DIR}
    ...    use_ssl=${True}
    ...    update_interval=${5000}
    ...    name=${alias}

_vdu.API login
    [Arguments]    ${alias}=default    ${vdu_index}=${0}    ${bts_index}=${0}
    vdu.connect to
    ...  host=${tl.gnbs[${bts_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[${bts_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${bts_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  secure=True
    ...  connection_name=${alias}
    [Return]    ${alias}

_classic.API logout
    [Arguments]    ${alias}=${None}
    coam.teardown    connection=${alias}

_vdu.API logout
    [Arguments]    ${alias}=default
    vdu.disconnect    ${alias}

_classic.get current scf file
    [Arguments]    ${folder_path}=/home/ute/btsauto/logs    ${alias}=default
    ${time}=  Get Time
    Set Test Variable  ${scf_path}  ${folder_path}/scf_${time}.xml
    coam.get_current_scf_file  local_dir_path=${folder_path}  file_name=scf_${time}.xml
    ...    timeout=60  connection=${alias}  export_type=configurationAndRuntimeObjects
    [Return]  ${scf_path}

_vdu.get current scf file
    [Arguments]    ${folder_path}=/home/ute/btsauto/logs    ${alias}=default
    Log To Console    ${alias}
    ${time}=  Get Time
    ${vdu_current_scfc}=    vdu.get_current_plan_file    local_dir_path=${folder_path}
    ...    filename=SCFC_${time}.xml
    ...    include_runtime_data=${True}
    [Return]    ${vdu_current_scfc}

Set Attenuation Value With Channels
    [Arguments]    ${vendor}    ${model}     ${ip}    ${port}    ${channels}   ${values}   ${min}    ${max}
    Log To Console    ${min}
    ${device}   attenuator.setup_attenuator
    ...    ip_addr=${ip}
    ...    port=${port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=${vendor}
    ...    model=${model}
    ...    alias=${ip}
    ...    max_attenuation=${max}
    ${channel_count}   Get Length    ${channels}

    FOR  ${channel_index}  IN RANGE    ${channel_count}
        ${port}   Evaluate  int(${channels[${channel_index}]})
        ${value}    Evaluate    ${values[${channel_index}]}
        attenuator.set_attenuation    port=${port}
        ...    value=${value}   attenuator_device=${device}
        Run Keyword And Ignore Error    attenuator.read_attenuation     port=${port}
        ...    attenuator_device=${device}
    END

Set Attenuation Values
    [Arguments]   ${cell_list}    ${tl_descriptor_path}    ${function}=enable
    ${out_is_define_testline_desc}    Run Keyword And Return Status
    ...    Variable Should Not Exist    ${tl_descriptor_path}
    Return From Keyword If    ${out_is_define_testline_desc}
    ${RF_list}    Create List
    ${type}    Evaluate    type(${cell_list}).__name__
    ${cell_list}    Run Keyword If   "${type}" == "list"    Set Variable    ${cell_list}
    ...    ELSE    Create List    ${cell_list}
    FOR    ${cell_info}    IN    @{cell_list}
        ${RF_list}    combine_lists    ${RF_list}    ${cell_info['RF']}
    END

    FOR    ${RF_info}   IN    @{RF_list}
        ${RF_serial_num}    Set Variable   ${RF_info["serialNumber"]}
        @{pipe_num}    Set Variable    ${RF_info["antl"]}
        ${rf_pa}    ${PAs}    Get Attention With RF    ${tl_descriptor_path}   ${RF_serial_num}    ${pipe_num}
        ${len}   Get Length    ${PAs}
        Run Keyword If    '${len}'!='0'     Set Attenuation Value With RF     rf=${rf_pa}
        ...    tl_descriptor_path=${tl_descriptor_path}    function=${function}
    END

Set Attenuation Value With RF
    [Arguments]    ${rf}    ${tl_descriptor_path}    ${function}=enable
    ${has_att}    Run Keyword And Return Status    dictionary_should_not_contain_key    ${rf}     att
    return from keyword if  ${has_att}
    ${att_ids}     get_dictionary_keys    ${rf['att']}
    FOR  ${att_id}    IN      @{att_ids}
        Set Attenuation Value With ATT Id    ${rf}     ${att_id}    ${tl_descriptor_path}    function=${function}
    END

Set Attenuation Value With ATT Id
    [Arguments]    ${rf}    ${att_id}    ${tl_descriptor_path}    ${function}=enable
    log list    ${rf}

    ${att_info}   Set Variable    ${rf['att']['${att_id}']}
    ${os_att_IP}=    XML.evaluate xpath    ${tl_descriptor_path}
    ...     //Unit[@Type="ATT"][@Number="${att_id}"]/Attenuator/@IP
    ${os_att_vendor}=    XML.evaluate xpath    ${tl_descriptor_path}
    ...     //Unit[@Type="ATT"][@Number="${att_id}"]/Attenuator/@Type

    ${os_att_model}=    XML.evaluate xpath    ${tl_descriptor_path}
    ...     //Unit[@Type="ATT"][@Number="${att_id}"]/Attenuator/@Model

    ${os_att_port}=    XML.evaluate xpath    ${tl_descriptor_path}
    ...     //Unit[@Type="ATT"][@Number="${att_id}"]/Attenuator/@Port
    ${os_att_min}=    XML.evaluate xpath    ${tl_descriptor_path}
    ...     //Unit[@Type="ATT"][@Number="${att_id}"]/Attenuator/@Min
    ${os_att_max}=    XML.evaluate xpath    ${tl_descriptor_path}
    ...     //Unit[@Type="ATT"][@Number="${att_id}"]/Attenuator/@Max
    #${att_port_info}=     Set Variable     ${att_info["ports"]}
    ${att_ports}    Set Variable    ${att_info["ports"]}
    ${channels}    Create List
    ${disable_value}    Create List
    ${enable_value}    Create List
    FOR    ${att_port_info}    IN    @{att_ports}
        ${port}   EVALUATE  int(${att_port_info['port']})
        append to list    ${channels}    ${port}
        append to list    ${disable_value}    ${att_port_info['disable']}
        append to list    ${enable_value}    ${att_port_info['enable']}
        ${setting_value}     Set Variable If        '${function}'=='disable'    ${disable_value}     ${enable_value}
    END
    ${min}   EVALUATE  int(${os_att_min[0]})
    ${max}   EVALUATE  int(${os_att_max[0]})

    ${len}     Get Length     ${os_att_model}
    ${model}     Set Variable If      '${len}'!='0'     ${os_att_model[0]}     DEFAULT

    Set Attenuation Value With Channels    vendor=${os_att_vendor[0]}    model=${model}
    ...      ip=${os_att_IP[0]}    port=${os_att_port[0]}
    ...      channels=${channels}    values=${setting_value}    min=${min}    max=${max}

Counter Compare Result Check
    [Arguments]    ${result}
    ${rule_list}    Get Dictionary Keys    ${result}
    ${compare_result}    Set Variable    ${True}
    FOR    ${rule}    IN    @{rule_list}
        Continue For Loop If    "delta_" not in "${rule}"
        ${rule_res}    Get From Dictionary    ${result}    ${rule}
        Run Keyword If    "${rule_res}"!="True"    Log To Console    \nthe result of ${rule} is wrong!
        ${compare_result}    Set Variable If    "${rule_res}"=="True"    ${True}    ${False}
        Exit For Loop If    "${rule_res}"!="True"
    END
    Should Be True    ${compare_result}
