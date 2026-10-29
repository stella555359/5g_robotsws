*** Settings ***
Documentation    This is common keywords for siso RU related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4   HZ SG8

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot


*** Keywords ***
Get Cell Information via Admin
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}=1    ${type}=technology    ${connection}=GNB_OAM
    ${cells_info}    coam.get_cells_info    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        ${value}    set variable if    '${cell['globalCellId']}'=='${cell_id}'    ${cell['${type}']}
        exit for loop if    '${cell['globalCellId']}'=='${cell_id}'
    END
    [Return]  ${value}

Get Modify Prach Cell List
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM
    ${modify_prach_cell_list}    create list
    ${cell_list}    get all cell id    connection=${connection}
    FOR    ${cell_id}    IN    @{cell_list}
        ${technology}    Get Cell Information via Admin    cell_id=${cell_id}    type=technology    connection=${connection}
        run keyword if    '${technology.lower()}'=='tdd'  append to list    ${modify_prach_cell_list}    ${cell_id}
    END
    [Return]  ${modify_prach_cell_list}

Modify Frame Structure via recommission
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${prach_index}    ${band}=${None}    ${frame_structure}=${None}    ${connection}=GNB_OAM
    run keyword if    '${band}'=='${None}' and '${frame_structure}'=='${None}'
    ...    run keywords    log to console    \nno need to modify band and frame_structure    AND
    ...    return from keyword
    connect to gnb coam via ssl    connection=${connection}
    ${release}    Get program version based on gNB active version
    ${scf_path}    download scf download via rest api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    ${final_commission_flag}    set variable    ${False}
    ${modify_prach_cell_list}    Get Modify Prach Cell List    connection=${connection}
    FOR    ${cell_id}    IN    @{modify_prach_cell_list}
        scfas.setup    scf_path=${scf_path}
        ${present_band}    scfas.get_band_from_scf    cell_id=${cell_id}
        ${cell_band}    set variable if    '${band}'=='${None}'    ${present_band}    ${band}
        ${present_frame_structure}    scfas.get_frame_structure_from_scf    cell_id=${cell_id}
        ${frame_structure}    set variable if    '${frame_structure}'=='${None}'    ${present_frame_structure}    ${frame_structure}
        ${nband}    Get Cell Nband    cell_id=${cell_id}    connection=${connection}
        ${bbname}    Get bbmod name    cell_id=${cell_id}    connection=${connection}
        ${bbname}    set variable if    '${bbname}'=='${None}'    ABIO AirScale Capacity    ${bbname}
        ${modify_msg1frequencystart}    Get Modify Msg1frequencystart Flag    cell_id=${cell_id}    connection=${connection}
        ${commission_flag}    ${new_scf_path}    generate_real_modify_params_then_modify_scf    release=${release}   scf_path=${scf_path}
        ...    cell_id=${cell_id}    band=${cell_band}    frame_structure=${frame_structure}
        ...    nband=${nband}    productName=${bbname}    modify_msg1frequencystart=${modify_msg1frequencystart}
        ...    prach_index=${prach_index}
        ${final_commission_flag}    set variable if    ${commission_flag}   ${commission_flag}    ${final_commission_flag}
    END
    run keyword if    ${commission_flag}    run keywords
    ...    COAM Commission with scf file    scf_file_path=${new_scf_path}    timeout=600    skip_parameter_relation_errors=${False}    AND
    ...    sleep  200s  reason=sleep 200s after scf commission!
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'

Modify Prach Index Via Webem
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${prach_index}    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}
    ${modify_prach_cell_list}    Get Modify Prach Cell List    connection=${connection}
    ${modify_params}  create list
    FOR    ${cell_id}    IN    @{modify_prach_cell_list}
        ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
        ...    filter_param=PRACH configuration index    p_name=prachConfigurationIndex     value=${prach_index}
        append to list  ${modify_params}  ${item}
    END
    Selenium Login And Disable Screen Lock
    Modify Parameters On Webem    modify_params=${modify_params}
    sleep  5
    ${ru_index_list}    create list
    FOR    ${cell_id}    IN    @{modify_prach_cell_list}
        ${ru_index}    get_ru_index_from_cell_id_via_admin    cell_id=${cell_id}    connection=${connection}
        ${status}    run keyword and return status    should not contain    ${ru_index_list}    ${ru_index}
        run keyword if    ${status}    append to list    ${ru_index_list}    ${ru_index}
    END
    ${ru_status}    set variable    ${True}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${status}    run keyword and return status    RU Should Be Online   ru_index=${ru_index}    connection=${connection}
        ${ru_status}    set variable if    not ${status}    ${status}    ${ru_status}
    END
    run keyword and continue on failure    should be true    ${ru_status}
    ${status}    run keyword and return status    run keyword if    not ${ru_status}
    ...    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    connection=${connection}
    ...    ELSE    Wait until keyword succeeds    5 min    20 sec   verify all cells should be onair    connection=${connection}
    run keyword if    ${status}==${false}    run keywords    perform ru reset    AND
    ...    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    connection=${connection}    AND
    ...    fail
    [Return]    ${modify_prach_cell_list}
    [Teardown]    Selenium Logout And Close Browser

Modify Prach and Make L3 Call
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${prach_index_list}    ${ue_num_each_call}    ${suite_name}=default    ${test_name}=default
    ...    ${connection}=GNB_OAM    ${duration}=${200}
    FOR    ${prach_index}    IN    @{prach_index_list}
        log to console  modify prach index to ${prach_index}
        ${modify_prach_cell_list}    Modify Prach Index Via Webem    prach_index=${prach_index}    connection=${connection}
        run keyword and continue on failure    get ue from init file and make call    cell_list=${modify_prach_cell_list}
        ...    with_peak=${True}    duration=${duration}    ue_num_each_call=${ue_num_each_call}
        ...    suite_name=${suite_name}    test_name=${test_name}
    END
