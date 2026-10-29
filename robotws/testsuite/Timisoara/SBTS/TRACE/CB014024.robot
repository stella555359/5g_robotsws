*** Settings ***
Documentation     [PURPOSE]
Library		Collections
Library    json
Library    String
Library    OperatingSystem
Library    taf.gnb.oam.coam.vdu    WITH NAME    vdu
Library    taf.nms.netact
Library    XML    use_lxml=True
Library    DateTime

*** Variables ***
${vdu_mplane_ip}   10.108.198.50        #BTS-37543
${cu_mplane_ip}   10.110.29.134         #BTS-37542
${vdu_username}     Nemuadmin
${vdu_password}     Nokia@123

*** Keywords ***
CB014024 Delta Commissioning with Frozen parameters
    [Documentation]    Short description.
    ${mocs}=    Create List    NRCELL
    ${nrcells}=    vdu.get_current_plan_objects    ${mocs}
    Should Not Be Empty    ${nrcells}[objects]
    ${parameter1}=    Create Dictionary    parameterName=caBlockingLoadLevel    value=99    operation=update
    ${parameters}=    Create List    ${parameter1}
    ${delta_json}=    Create Dictionary    distName=${nrcells}[objects][0][distName]    operation=update
    ...    parameters=${parameters}
    ${delta_jsons}=    Create List    ${delta_json}
    ${delta_jsons}=    Evaluate    json.dumps(${delta_jsons})    modules=json
    ${err_msg}=    Run Keyword And Expect Error  *Plan validation failed*
    ...    vdu.perform_delta_recommissioning    ${delta_jsons}
    Log    ${err_msg}

CB014024 Delta Commissioning with Non Frozen and Frozen parameters
    [Documentation]    Short description.
    ${mocs}=    Create List    NRCELL
    ${nrcells}=    vdu.get_current_plan_objects    ${mocs}
    Should Not Be Empty    ${nrcells}[objects]
    ${parameter1}=    Create Dictionary    parameterName=caBlockingLoadLevel    value=99    operation=update
    ${parameter2}=    Create Dictionary    parameterName=cellName    value=666    operation=update
    ${parameters}=    Create List    ${parameter1}    ${parameter2}
    ${delta_json}=    Create Dictionary    distName=${nrcells}[objects][0][distName]    operation=update
    ...    parameters=${parameters}
    ${delta_jsons}=    Create List    ${delta_json}
    ${delta_jsons}=    Evaluate    json.dumps(${delta_jsons})    modules=json
    ${err_msg}=    Run Keyword And Expect Error  *Plan validation failed*
    ...    vdu.perform_delta_recommissioning    ${delta_jsons}
    Log    ${err_msg}

CB014024 Delta Commissioning with Non Frozen parameter
    [Documentation]    Short description.
    ${mocs}=    Create List    NRCELL
    ${nrcells}=    vdu.get_current_plan_objects    ${mocs}
    Should Not Be Empty    ${nrcells}[objects]
    ${cellname}=    Evaluate    ''.join(random.choices(string.ascii_letters, k=80))    modules=random,string
    ${parameter2}=    Create Dictionary    parameterName=cellName    value=${cellname}    operation=update
    ${parameters}=    Create List    ${parameter2}
    ${delta_json}=    Create Dictionary    distName=${nrcells}[objects][0][distName]    operation=update
    ...    parameters=${parameters}
    ${delta_jsons}=    Create List    ${delta_json}
    ${delta_jsons}=    Evaluate    json.dumps(${delta_jsons})    modules=json
    vdu.perform_delta_recommissioning    ${delta_jsons}

CB014024 Robustness Test For Delta Commissioning
    ${kw_list}=    Create List
#    ...    CB014024 Delta Commissioning with Non Frozen parameter
    ...    CB014024 Delta Commissioning with Non Frozen and Frozen parameters
    ...    CB014024 Delta Commissioning with Frozen parameters
    FOR    ${index}    IN RANGE    0    100
        ${kw}=    Evaluate    random.choice(${kw_list})    modules=random
        Run keyword    ${kw}
    END
    CB014024 Delta Commissioning with Non Frozen parameter

CB014024-A Verify Parameters
    Log    CB014024-A Verify Parameters
    ${mocs}=    Create List    NRCELL
    ${nrcells}=    vdu.get_current_plan_objects    ${mocs}
    Should Not Be Empty    ${nrcells}[objects]
    FOR    ${cell}    IN    @{nrcells}[objects]
        Log Dictionary    ${cell}
        log    ${cell}[json_repr]
        ${cell_parameters}=    Evaluate    json.loads('${cell}[json_repr]')    modules=json
        Log Dictionary    ${cell_parameters}
        Should Be True  '${cell_parameters}[caBlockingLoadLevel]'=='100'
        Should Be True  '${cell_parameters}[ulMimoMode]'=='Closed loop Spatial Multiplexing (2x2)'
        ${err_msg}=    Run Keyword And Expect Error  *Plan validation failed*    vdu.perform_parameter_recommissioning
        ...    dist_name=${cell}[distName]    parameter=caBlockingLoadLevel    operation=update    value=99
        Log    ${err_msg}
    END

CB014024-B Verify Parameters
    Log    CB014024-B Verify Parameters
    ${mocs}=    Create List    NRCELL
    ${nrcells}=    vdu.get_current_plan_objects    ${mocs}
    Should Not Be Empty    ${nrcells}[objects]
    FOR    ${cell}    IN    @{nrcells}[objects]
        Log Dictionary    ${cell}
        log    ${cell}[json_repr]
        ${cell_parameters}=    Evaluate    json.loads('${cell}[json_repr]')    modules=json
        Log Dictionary    ${cell_parameters}
        Should Be True  '${cell_parameters}[sichangeindduration]'=='0'
        ${err_msg}=    Run Keyword And Expect Error  *Plan validation failed*    vdu.perform_parameter_recommissioning
        ...    dist_name=${cell}[distName]    parameter=sichangeindduration    operation=update    value=1
        Log    ${err_msg}
    END

CB014024-C Verify Parameters
    Log    CB014024-C Verify Parameters
    ${mocs}=    Create List    NRCELL
    ${nrcells}=    vdu.get_current_plan_objects    ${mocs}
    Should Not Be Empty    ${nrcells}[objects]
    FOR    ${cell}    IN    @{nrcells}[objects]
        Log Dictionary    ${cell}
        log    ${cell}[json_repr]
        ${cell_parameters}=    Evaluate    json.loads('${cell}[json_repr]')    modules=json
        Log Dictionary    ${cell_parameters}
        Should Be True  '${cell_parameters}[caBlockingLoadLevel]'=='100'
        ${err_msg}=    Run Keyword And Expect Error  *Plan validation failed*    vdu.perform_parameter_recommissioning
        ...    dist_name=${cell}[distName]    parameter=caBlockingLoadLevel    operation=update    value=99
        Log    ${err_msg}
    END

CB014024-A Verify Parameters From NMS
    CB014024 Verify Single Parameters From NMS    mrbts_id=${mrbts_id}    mo_class=NRCELL
    ...    parameter=caBlockingLoadLevel    valid_value=100    invalid_value=99

CB014024 Verify Single Parameters From NMS
    [arguments]    ${mrbts_id}    ${mo_class}    ${parameter}    ${valid_value}    ${invalid_value}
    ${date}    DateTime.Get current date
    ${date_str}  Convert date  ${date}  result_format=%Y%m%d%H%M%S
    ${file_name}=    Set Variable    scf_${mrbts_id}_exported_${date_str}.xml
    ${local_dir}=    Set Variable    /home/ute/
    ${export_paras}=    Create Dictionary    -useQualifiedClassAbbreviation=${TRUE}
    ${file}=    taf.nms.netact.Export Configuration    file_name=${file_name}    local_dir=${local_dir}
    ...    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    operation_type=actual    file_format=RAML2
    ...    parameters=${export_paras}
    ${xml_content}=    Get File    ${file_name}
    ${txts}=    Get Elements Texts    ${xml_content}    //*[@name="${parameter}"]
    Should Not Be Empty    ${txts}
    ${txts}=    Remove Duplicates    ${txts}
    Length Should Be    ${txts}    1
    Should Be True    '${txts}[0]'=='${valid_value}'
    ${eles}=    Get Elements    ${xml_content}    //*[contains(@class, "${mo_class}")]
    Should Not Be Empty    ${eles}
    FOR    ${ele}    IN    @{eles}
        Log Element    ${ele}
        ${meta_class}=    Get Element Attribute    ${ele}    class
        ${status}=    Run Keyword And Return Status    Should Match Regexp    ${meta_class}    :${mo_class}$
        CONTINUE FOR LOOP IF    ${status}==${FALSE}
        ${meta_version}=    Get Element Attribute    ${ele}    version
        ${dist_name}=    Get Element Attribute    ${ele}    distName
        EXIT FOR LOOP
    END
    ${plan_name}=    Set Variable    CB014024-test-${date_str}
    ${plan}=    Run Keyword And Ignore Error    taf.nms.netact.get_plan_configuration    ${plan_name}
    Run Keyword And Ignore Error    taf.nms.netact.delete_plan_configuration    ${plan}
    ${plan}=    taf.nms.netact.create_plan_configuration    ${plan_name}
    ${obj}=    taf.nms.netact.create_managed_object    ${plan}    meta_class=${meta_class}
    ...    meta_version=${meta_version}    mo_id=${dist_name}    operation=update    ${parameter}=${invalid_value}
    Run Keyword And Expect Error  *validate of the plan failed*    taf.nms.netact.provision_plan
    ...    plan_name=${plan_name}
    Run Keyword And Ignore Error    taf.nms.netact.delete_plan_configuration    ${plan}

CB014024-B Verify Parameters From NMS
    CB014024 Verify Single Parameters From NMS    mrbts_id=${mrbts_id}    mo_class=NRCELL
    ...    parameter=sichangeindduration    valid_value=0    invalid_value=1

Setup NMS
    [Documentation]    Short description
    ${host_name}=    Run    hostname
    ${TESTLINE_NAME}=    Replace String  ${host_name}   -    _
    Set Test Variable    ${TESTLINE_NAME}
    Import Variables    /home/ute/testline_configuration/${TESTLINE_NAME}/__init__.py
    taf.nms.netact.Add Node    cmwas    ${tl.nms.ssh_connections_info.addr}    ${tl.nms.ssh_connections_info.username}
    ...    ${tl.nms.ssh_connections_info.password}
    taf.nms.netact.Add Web Url    ${tl.nms.https_main_info.addr}    ${tl.nms.ssh_connections_info.username}
    ...    ${tl.nms.ssh_connections_info.password}
    taf.nms.netact.integrate_mrbts_with_netact    release=25R3VDU    mr=MRC-COMMON/MR-COMMON
    ...    mrbts_address=${state}[ip_addresses][m_plane_ip_address][ipv4]    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}
    ...    security_mode=no TLS
    ${output}=    taf.nms.netact.upload_configuration    PLMN-PLMN/MRBTS-${mrbts_id}
    Log    ${output}

CB014024 Robustness Test For Migration
    Log    TBD


CB014024-A Verify Parameters - NMS
    Setup NMS
    CB014024-A Verify Parameters From NMS

CB014024-B Verify Parameters - NMS
    Setup NMS
    CB014024-B Verify Parameters From NMS

CB014024 setup
    Log    '${vdu_username}' '${vdu_password}'
    vdu.connect_to    host=${vdu_mplane_ip}  port=443  username=${vdu_username}
    ...    password=${vdu_password}    secure=${TRUE}    timeout=15
    ${state}=    vdu.get_vdu_state_data
    Set Test Variable    ${state}
    Log Dictionary    ${state}
    Set Test Variable    ${mrbts_id}    ${state}[mrbts_id]
    Log To Console    ${EMPTY}
    Log To Console    Running version: ${state}[software_version]
    ${nidd}=    vdu.get_nidd    need_nidd_version=${TRUE}
    Log    ${nidd}[nidd_version]
    ${pods}=    vdu.get_pods_info
    Log List    ${pods}
    ${cells_summary}=    vdu.get_vdu_cells_summary
    Log Dictionary    ${cells_summary}
    ${op_history}=    vdu.get_vdu_operation_history
    log List    ${op_history}

CB014024 teardown
    ${op_history}=    vdu.get_vdu_operation_history
    log List    ${op_history}
    vdu.disconnect
