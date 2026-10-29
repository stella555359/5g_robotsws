*** Settings ***
Documentation
...   This is for common keywords that cannot clasified for exist common robot file.
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot

Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/coam_parameter.py  WITH NAME  coam_parameter

*** Variables ***
${PA_OUT_PORTS}    ${None}
${PA_MAX_COLUMN_NUM}    8
${PA_ROWS}              32
${PA_MAX_SUPPORTED_VALUE}    127

*** Keywords ***
_For_filter
    Commission on LTE
    Connect to Attenuator
    Get Attenuation Channels For RU
    Adjust PA gradually for specified RUs
    Set attenuator ports of specified RUs to same value
    Block whole attenuator ports for testline
    Initialize attenuator values for testline

Commission on LTE
    [Documentation]  Author: Ding Binmei
    ...              Description: ${is_called_in_test_case_level}: available values: ${True} ${False},
    ...                           default to ${False} which means keyword is called in test suite setup phase
    [Arguments]  ${enb_default_scf_file}=${ENB_SCF_DEFAULT_FILE_PATH}    ${is_called_in_test_case_level}=${False}
    ...    ${is_pdl_checking_needed}=${True}    ${timeout}=600s
    ${local_log_file_folder}    set variable if  ${is_called_in_test_case_level}==${True}    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
    ${enb_scf_file}    Copy file    source=${enb_default_scf_file}    destination=${local_log_file_folder}
    enb_lte.Connect to eNB via ssl    connection=enblte
    coam_gnb_classical.COAM Commission with scf file     scf_file_path=${enb_default_scf_file}
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}    connection=enblte    timeout=${timeout}
    [Teardown]  enb_lte.Enblte close down    connection=enblte

########## Programmable attenuator
Connect to Attenuator
    [Documentation]   author: Cui Lingxue  mmW_SG1
    ...    Setup the connection to attenuator. Default alias is ATTEN_0.
    ...    :param ${vendor}: vendor of attenuator, eg. HBTE, Topyoung, radiorack...
    ...    :param ${attenuation_port_numbers}: List of Port numbers on the attenuator, this parameter is useless for HBDE
    [Arguments]    ${attenuator_index}=${0}    ${attenuation_port_numbers}=${tl.attenuators[${attenuator_index}].attenuation_port_numbers}
    ...    ${alias}=ATTEN_${attenuator_index}
    ${attenuator_addr}    set variable    ${tl.attenuators[${attenuator_index}].ip_addr}
    ${attenuator_api_port}    set variable    ${tl.attenuators[${attenuator_index}].port}
    ${vendor}    set variable    ${tl.attenuators[${attenuator_index}].__class__.__name__}
    ${model}    set variable    ${tl.attenuators[${attenuator_index}].model}
    Wait Until Keyword Succeeds    90 sec    3 sec    attenuator.setup_attenuator
    ...    ip_addr=${attenuator_addr}
    ...    port=${attenuator_api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}
    ...    vendor=${vendor}
    ...    alias=${alias}
    ...    model=${model}

Set attenuator port value
    [Documentation]   author: Cui Lingxue  mmW_SG1
    ...    Set specified values to attenuator ports.
    ...    :param ${atten_port_value_dict}: configure attenuator ports to given values. eg. {'129':'50', '130':'60'}
    [Arguments]    ${atten_port_value_dict}    ${attenuator_index}=${0}    ${alias}=ATTEN_${attenuator_index}
    ...    ${confirm_after_modify}=${True}
    ${atten_port_list}    get_dictionary_keys    ${atten_port_value_dict}
    FOR    ${port}    IN    @{atten_port_list}
        ${port}    evaluate    int(${port})
        ${port_value}    evaluate    int(${atten_port_value_dict['${port}']})
        attenuator.set_attenuation
        ...    port=${port}
        ...    value=${port_value}
        ...    confirm=${confirm_after_modify}
        ...    attenuator_device=${alias}
    END

Get attenuator value for specific RU
    [Documentation]    Author: Ding Binmei
    ...    Get attenuator value for specific RU
    ...    ${is_connection_needed}: if ${True}, will connect to attenuator first
    ...    Return: list of attenuation values for each port. E.G: [0, 0, 0, 0]
    [Arguments]    ${attenuator_index}=${0}    ${alias}=ATTEN_${attenuator_index}    ${is_connection_needed}=${True}
    ...    ${gnb_index}=${0}    ${ru_index}=${0}
    Run keyword if    ${is_connection_needed}
    ...    Connect to Attenuator    attenuator_index=${attenuator_index}    alias=${alias}
    ${atten_ports}    gnb_classical_hangzhou.Get Attenuation Channels For RU    gnb_id=${gnb_index}    RU_id=${ru_index}
    ${atten_values}    attenuator.read_ports_attenuation    ports=${atten_ports}    attenuator_device=${alias}
    [Return]    ${atten_values}

_create dict for atten modification
    [Documentation]   author: Cui Lingxue  mmW_SG1
    [Arguments]    ${atten_port_values}    ${gnb_index}=${0}    ${ru_index}=${0}
    ${atten_ports}    gnb_classical_hangzhou.Get Attenuation Channels For RU    gnb_id=${gnb_index}    RU_id=${ru_index}
    ${port_numbers}    get length    ${atten_ports}
    ${atten_port_value_dict}    create dictionary
    FOR    ${i}    IN RANGE    ${port_numbers}
        ${port}     evaluate    str(${atten_ports[${i}]})
        ${value}    set variable    ${atten_port_values[${i}]}
        set_to_dictionary    ${atten_port_value_dict}    ${port}    ${value}
    END
    [Return]    ${atten_port_value_dict}

Adjust attenuator for specified RU ports
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${atten_values}    ${gnb_index}=${0}    ${ru_index}=${0}
    ${atten_port_value_dict}    _create dict for atten modification    atten_port_values=${atten_values}    gnb_index=${gnb_index}
    ...    ru_index=${ru_index}
    Set attenuator port value    atten_port_value_dict=${atten_port_value_dict}

Block attenuator for specified RU
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${gnb_index}=${0}    ${ru_index}=${0}
    _set attenuator ports of specified RU to same value    exp_pa_value=${127}    gnb_index=${gnb_index}    ru_index=${ru_index}

Initialize attenuator for specified RU
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${exp_pa_value}=${0}    ${gnb_index}=${0}    ${ru_index}=${0}    ${multi-ports}=${True}
    _set attenuator ports of specified RU to same value    exp_pa_value=${exp_pa_value}    gnb_index=${gnb_index}    ru_index=${ru_index}
    ...    multi-ports=${multi-ports}

Block attenuator for specified LTE RU
    [Documentation]    Author: catherine.cheng@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}    ${ru_index}=${0}
    _set attenuator ports of specified RU to same value    exp_pa_value=${127}    gnb_index=${enb_index}
    ...    ru_index=${ru_index}    is_enb=${True}

Initialize attenuator for specified LTE RU
    [Documentation]    Author: catherine.cheng@nokia-sbell.com
    [Arguments]    ${exp_pa_value}=${0}    ${enb_index}=${0}    ${ru_index}=${0}
    _set attenuator ports of specified RU to same value    exp_pa_value=${exp_pa_value}    gnb_index=${enb_index}
    ...    ru_index=${ru_index}    is_enb=${True}

Adjust attenuator to expected value based specific interval for specified RU
    [Documentation]    Author: Dandan Fang
    [Arguments]    ${pa_start}=${0}   ${exp_pa_value}=${0}    ${gnb_index}=${0}    ${ru_index}=${0}
    ...            ${multi-ports}=${True}   ${pa_interval}=${0}
    @{pa_values}    Generate pa values based on provided range    pa_start=${pa_start}    pa_end=${exp_pa_value}    pa_interval=${pa_interval}
    FOR    ${pa_value}    IN    @{pa_values}
        _set attenuator ports of specified RU to same value    exp_pa_value=${pa_value}    gnb_index=${gnb_index}    ru_index=${ru_index}
    ...    multi-ports=${multi-ports}
    END

Generate pa values based on provided range
    [Documentation]  Author: Ding Binmei
    ...    if pa_start=10, pa_end=48, pa_interval=10, then returned value as bellow:
    ...    [10, 20, 30, 40, 48]
    ...    if pa_start=pa_end, then return value as [pa_end]
    [Arguments]    ${pa_start}    ${pa_end}    ${pa_interval}    ${is_need_to_include_start_value}=${True}
    ${pa_start}    convert to integer    ${pa_start}
    ${pa_end}    convert to integer    ${pa_end}
    ${pa_interval}    convert to integer    ${pa_interval}
    @{list_pa_value}    create list
    ${pa_interval}    Set variable if    ${pa_end}>${pa_start}    ${pa_interval}    ${pa_interval}*-1
    Run keyword If    ${pa_end}==${pa_start}    append to list    ${list_pa_value}    ${pa_end}
    Return From Keyword If    ${pa_end}==${pa_start}    ${list_pa_value}
    FOR    ${pa_value}    IN RANGE   ${pa_start}    ${pa_end}    ${pa_interval}
        append to list    ${list_pa_value}    ${pa_value}
    END
    Append to list    ${list_pa_value}    ${pa_end}
    Run keyword if    ${is_need_to_include_start_value}==${False}    Remove From List    ${list_pa_value}    index=0
    [Return]  ${list_pa_value}

Adjust PA gradually for specified RUs
    [Documentation]    Author: Ding Binmei
    ...    Adjust PA value gradually for specified RUs
    ...    if pa_start=10, pa_end=48, pa_interval=10, then will adjust by steps as bellow: 20, 30, 40, 48
    ...    ${ru_idx_list}: can be a list or sting like: 0,1
    [Arguments]    ${pa_start}    ${pa_end}    ${pa_interval}=${5}    ${ru_idx_list}=0    ${gnb_index}=${0}
    ${pa_values}    Generate pa values based on provided range    pa_start=${pa_start}    pa_end=${pa_end}    pa_interval=${pa_interval}
    ...    is_need_to_include_start_value=${False}
    FOR    ${pa_value}    IN    @{pa_values}
        Set attenuator ports of specified RUs to same value    exp_pa_value=${pa_value}    ru_idx_list=${ru_idx_list}    gnb_index=${gnb_index}
    END

_set attenuator ports of specified RU to same value
    [Documentation]    Author: Cui Lingxue
    ...    All associated RU ports on attenuator will be modified to ${exp_pa_value}.
    ...    if multi-ports=${True}, use set_ports_attenuation to pa value at same time
    [Arguments]    ${exp_pa_value}    ${gnb_index}=${0}    ${ru_index}=${0}    ${is_connection_needed}=${True}    ${is_enb}=${False}
    ...   ${multi-ports}=${True}
    Run keyword if    ${is_connection_needed}
    ...    Connect to Attenuator    attenuator_index=${0}    alias=ATTEN_0

    ${atten_ports}    run keyword if  ${is_enb}==${True}
    ...    enb_lte.Get Attenuation Channels For LTE RU    enb_id=${gnb_index}    RU_id=${ru_index}
    ...    ELSE    gnb_classical_hangzhou.Get Attenuation Channels For RU    gnb_id=${gnb_index}    RU_id=${ru_index}

    ${exp_pa_value}    evaluate    int(${exp_pa_value})
    ${gnb_or_enb}    set variable if    ${is_enb}==${False}    gnb     enb
    ${atten_ports_len}    get length    ${atten_ports}
    ${pa_values}   evaluate  [int(${exp_pa_value}) for _ in range(${atten_ports_len})]
    run keyword if   ${multi-ports}
    ...   Log to console    ${gnb_or_enb}_index: ${gnb_index}, ru_index: ${ru_index}, atten_port:${atten_ports}, exp_pa_value: ${pa_values}
    run keyword if   ${multi-ports}    wait until keyword succeeds    5    1s
    ...    attenuator.set_ports_attenuation   ports=${atten_ports}    values=${pa_values}   confirm=${True}   attenuator_device=ATTEN_0
    return from keyword if    ${multi-ports}
    FOR    ${atten_port}    IN    @{atten_ports}
        Log to console    ${gnb_or_enb}_index: ${gnb_index}, ru_index: ${ru_index}, atten_port:${atten_port}, exp_pa_value: ${exp_pa_value}
        wait until keyword succeeds    5    1s    attenuator.set_attenuation    port=${atten_port}    value=${exp_pa_value}    confirm=${True}
        ...    attenuator_device=ATTEN_0
    END

_Set PA values for all RUs in one GNB
    [Documentation]  Author: Ding Binmei
    ...    pa_values_mapping: should be in bellow format. { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
    ...                       ${INIT_PA_F_T} is defined in init file under commission folder for each test line
    ...    if PA value of some RU is set to -1, it means this RU's PA ports won't be updated.
    [Arguments]    ${gnb_index}    ${pa_values_mapping}
    ${pa_values_for_gnb}    Set variable    ${pa_values_mapping[${gnb_index}]}
    ${list_ru_index}    Evaluate    list(range(len(${pa_values_for_gnb})))
    FOR    ${ru_index}    IN    @{list_ru_index}
       run keyword if  ${pa_values_for_gnb[${ru_index}]}>=0        _set attenuator ports of specified RU to same value
       ...      exp_pa_value=${pa_values_for_gnb[${ru_index}]}    gnb_index=${gnb_index}
       ...      ru_index=${ru_index}    is_connection_needed=${False}
    END

Block whole attenuator ports for testline
    [Documentation]  Author: Catherine.cheng@nokia-sbell.com
    ...    2024-6-27 Ding Binmei: Refactor keyword to support both HBTE and topyoung,
    ...        and support update all ports for once to improve the efficiency
    ...    attenuator_out_ports: out ports of PA connected to UE
    ...    -- if topyoung: refers to rows connected to UE and ${attenuator_max_column_num} must be filled
    ...    -- if HBTE: refers to columns connected to UE.
    ...    attenuator_rows: rows in a attenuator Matrix, default to 32
    ...    attenuator_max_column_num: columns in a attenuator Matrix, default to 8
    ...    exp_pa_value: differs based on different type of PA, default to 127
    ...    ${PA_OUT_PORTS} ${PA_ROWS} ${PA_MAX_COLUMN_NUM} ${PA_MAX_SUPPORTED_VALUE} can be overwritten
    ...    in init file under commission folder for each test line,

    [Arguments]    ${attenuator_out_ports}=${PA_OUT_PORTS}    ${attenuator_rows}=${PA_ROWS}    ${exp_pa_value}=${PA_MAX_SUPPORTED_VALUE}
    ...    ${attenuator_index}=${0}    ${attenuator_max_column_num}=${PA_MAX_COLUMN_NUM}
    Run keyword if    "${attenuator_out_ports}"=="${None}"
    ...    Log to console    attenuator_out_ports is None, skip update for block whole attenuator ports
    Return from keyword if    "${attenuator_out_ports}"=="${None}"
    ${model}    set variable    ${tl.attenuators[${attenuator_index}].model}
    ${is_topyoung}  Run Keyword And Return Status   Should Start With  ${model}  TAS
    ${pa_in_ports_num}    Set variable if    ${is_topyoung}    ${attenuator_max_column_num}    ${attenuator_rows}
    ${attenuator_in_ports}     evaluate  list(range(1, int(${pa_in_ports_num})+1))
    run keyword if   ${is_topyoung}
    ...    Block whole attenuator ports for once
    ...        list_row_indexs=${attenuator_out_ports}   list_column_indexs=${attenuator_in_ports}
    ...        exp_pa_value=${exp_pa_value}    attenuator_rows=${attenuator_rows}
    ...  ELSE    Block whole attenuator ports for once
    ...        list_row_indexs=${attenuator_in_ports}   list_column_indexs=${attenuator_out_ports}
    ...        exp_pa_value=${exp_pa_value}    attenuator_rows=${attenuator_rows}

_legacy Block whole attenuator ports for testline
    [Arguments]    ${attenuator_out_ports}=${PA_OUT_PORTS}    ${attenuator_rows}=${PA_ROWS}    ${exp_pa_value}=${127}
    Connect to Attenuator
    Log to console    start to block whole PA ports, out_ports:${attenuator_out_ports}, rows:${attenuator_rows}, exp value:${exp_pa_value}
    FOR    ${out_port}    IN    @{attenuator_out_ports}
       _set PA value each attenuator line    out_port=${out_port}    attenuator_rows=${attenuator_rows}    exp_pa_value=${exp_pa_value}
    END

Block whole attenuator ports for once
    [Documentation]  Author: Dandan.Fang@nokia-sbell.com
    ...    2024-6-27 Ding Binmei: Refactor keyword for common usage
    ...    list_row_indexs: For Topyoug, refers to the out ports connected to UE
    ...    list_column_indexs: For Topyoung, refers to the in ports connected to RU
    ...    exp_pa_value: different PA type has different max value
    ...    attenuator_rows: Refers to the max rows in a attenuator Matrix
    ...    ${PA_MAX_SUPPORTED_VALUE} ${PA_ROWS}are defined in init file under commission folder for each test line,
    ...                            you can also input with other values based on your needs
    [Arguments]    ${list_row_indexs}   ${list_column_indexs}    ${exp_pa_value}=${PA_MAX_SUPPORTED_VALUE}    ${attenuator_rows}=${PA_ROWS}
    ${list_column_indexs}=         Convert data type to a list     input_data=${list_column_indexs}
    ${list_row_indexs}=         Convert data type to a list     input_data=${list_row_indexs}
    Should Not Be Empty  ${list_column_indexs}
    Should Not Be Empty  ${list_row_indexs}
    ${ports_for_update}   Get all_PA ports for update    list_row_indexs=${list_row_indexs}    list_column_indexs=${list_column_indexs}
    ...    attenuator_rows=${attenuator_rows}
    Log to console    Block for all PA ports: ${ports_for_update}
    Connect to Attenuator    attenuation_port_numbers=${ports_for_update}
    ${exp_pa_value}    evaluate    int(${exp_pa_value})
    ${atten_ports_len}    get length    ${ports_for_update}
    ${pa_values}   evaluate  [int(${exp_pa_value}) for _ in range(${atten_ports_len})]

    wait until keyword succeeds     5x    2s
    ...    attenuator.set_ports_attenuation   ports=${ports_for_update}    values=${pa_values}   confirm=${True}   attenuator_device=ATTEN_0

Get all_PA ports for update
    [Documentation]    Author: Ding Binmei
    ...    ${list_row_indexs}: should be in list type
    ...    ${list_column_indexs}: Should be in list type
    ...    return all ports numbers in range. Should be a list
    [Arguments]    ${list_row_indexs}   ${list_column_indexs}    ${attenuator_rows}=${PA_ROWS}
    ${atten_port_list}  create list
    FOR    ${column_index}    IN    @{list_column_indexs}
       @{list_ports_in_one_column}     _Get PA ports for one column    column_index=${column_index}    list_row_indexs=${list_row_indexs}
        ...    attenuator_rows=${attenuator_rows}
        Append to list    ${atten_port_list}    @{list_ports_in_one_column}
    END
    [Return]   ${atten_port_list}

_Get PA ports for one column
    [Documentation]    Author: Ding Binmei
    ...    ${column_index}: int value with specific column index
    ...    ${list_row_indexs}: Should be in list type
    ...    return all ports numbers for one row. Should be a list
    [Arguments]    ${column_index}    ${list_row_indexs}    ${attenuator_rows}=${PA_ROWS}
    ${atten_port_list}  create list
    FOR    ${row_index}    IN    @{list_row_indexs}
        ${atten_port}    evaluate    (int(${column_index})-1)*int(${attenuator_rows})+int(${row_index})
        Append To List   ${atten_port_list}   ${atten_port}
    END
    [Return]   ${atten_port_list}

_set PA value each attenuator line
    [Documentation]   set whole line for specific attenuator out port to exp_pa_value
    [Arguments]   ${out_port}    ${attenuator_rows}    ${exp_pa_value}
    FOR    ${row_index}    IN RANGE    ${1}    ${attenuator_rows}+1
        ${atten_port}    evaluate    (${out_port}-1)*${attenuator_rows}+${row_index}
        wait until keyword succeeds    5x    2s    attenuator.set_attenuation    port=${atten_port}    value=${exp_pa_value}
        ...                                                confirm=${True}    attenuator_device=ATTEN_0
    END

Initialize attenuator values for testline
    [Documentation]  Author: Ding Binmei
    ...    pa_values_mapping: should be in bellow format. { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
    ...                       ${INIT_PA_F_T} is defined in init file under commission folder for each test line
    ...    if_change_ENB_PA: set ${True} if want to change LTE PA, and ${tl.enbs[${enb_index}].rms[${ru_index}].attenuation_ports}
    ...                      need added in testline_configuration __init__.py
    ...    NSA_SA: when if_change_ENB_PA=${True}, if NSA, set LTE RU PA ports to 0; if SA, set LTE RU PA ports to 127
    [Arguments]    ${pa_values_mapping}=${INIT_PA_F_T}    ${if_change_ENB_PA}=${False}    ${NSA_SA}=SA
    Connect to Attenuator
    ${list_gnb_index}    Get dictionary keys    ${pa_values_mapping}
    log to console   start to initialize attenuator for gNB
    FOR    ${gnb_index}    IN    @{list_gnb_index}
        _Set PA values for all RUs in one GNB    gnb_index=${gnb_index}    pa_values_mapping=${pa_values_mapping}
    END
    return from keyword if    ${if_change_ENB_PA}==${False}
    log to console   start to initialize attenuator for eNB
    run keyword if    '${NSA_SA}'=='NSA'    Initialize attenuator for specified LTE RU    enb_index=${0}    ru_index=${0}
    run keyword if    '${NSA_SA}'=='SA'    Block attenuator for specified LTE RU    enb_index=${0}    ru_index=${0}

#Adjust programmable attenuation
#   [Documentation]   [Only apply for TopYoung PA]
#   ...               2021-8-26: Switch to taf method and need to test with topyoung,
#   ...    currently it's not test due to migration task and lack of env
#   ...               This step is setting the attenuation value to make link adtion good enough to
#   ...               satisfy the sinr which match case mcs. Bellow is an example for TL044:
#   ...               Port 9: dl layer 0
#   ...               Port 10:dl layer 1
#   ...               Port 11: ul 1ayer 0
#   ...               Port 12: ul layer 1
#   ...               if some port you do not needed,the value of pot should be ${None}
#   [Arguments]    ${port_of_layer1_ul}=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
#   ...            ${port_of_layer1_dl}=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
#   ...            ${port_of_layer0_ul}=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
#   ...            ${port_of_layer0_dl}=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
#   ...            ${attenuation_of_layer1_ul}=16
#   ...            ${attenuation_of_layer1_dl}=32
#   ...            ${attenuation_of_layer0_ul}=16
#   ...            ${attenuation_of_layer0_dl}=32
#   ${attenuation_port_numbers}    gnb_classical_hangzhou.Get Attenuation Channels For RU
#   Connect to Attenuator    attenuation_port_numbers=${attenuation_port_numbers}
#   run keyword if  not '${port_of_layer1_ul}'=='${None}'    Wait until keyword succeeds    3 times    2 sec    attenuator.set_attenuation
#   ...    port=${port_of_layer1_ul}    value=${attenuation_of_layer1_ul}    confirm=${True}    attenuator_device=ATTEN_0
#   run keyword if  not '${port_of_layer0_ul}'=='${None}'    Wait until keyword succeeds    3 times    2 sec   attenuator.set_attenuation
#   ...    port=${port_of_layer0_ul}    value=${attenuation_of_layer0_ul}    confirm=${True}    attenuator_device=ATTEN_0
#   run keyword if  not '${port_of_layer0_dl}'=='${None}'    Wait until keyword succeeds    3 times    2 sec   attenuator.set_attenuation
#   ...    port=${port_of_layer0_dl}    value=${attenuation_of_layer0_dl}    confirm=${True}    attenuator_device=ATTEN_0
#   run keyword if  not '${port_of_layer1_dl}'=='${None}'    Wait until keyword succeeds    3 times    2 sec   attenuator.set_attenuation
#   ...    port=${port_of_layer1_dl}    value=${attenuation_of_layer1_dl}    confirm=${True}    attenuator_device=ATTEN_0
#   ${read_attenuation_of_layer1_ul}    run keyword if  not '${port_of_layer1_ul}'=='${None}'    attenuator.read_attenuation
#   ...    port=${port_of_layer1_ul}
#   ${read_attenuation_of_layer1_dl}    run keyword if  not '${port_of_layer1_dl}'=='${None}'    attenuator.read_attenuation
#   ...    port=${port_of_layer1_dl}
#   ${read_attenuation_of_layer0_ul}    run keyword if  not '${port_of_layer0_ul}'=='${None}'    attenuator.read_attenuation
#   ...    port=${port_of_layer0_ul}
#   ${read_attenuation_of_layer0_dl}    run keyword if  not '${port_of_layer0_dl}'=='${None}'    attenuator.read_attenuation
#   ...    port=${port_of_layer0_dl}
#   ${current_attenuation_value}    catenate   SEPARATOR=
#   ...       The current attenuation value for port${port_of_layer0_dl}:${read_attenuation_of_layer0_dl} ;
#   ...       port${port_of_layer1_dl}:${read_attenuation_of_layer1_dl} ;
#   ...       port${port_of_layer0_ul}:${read_attenuation_of_layer0_ul} ;
#   ...       port${port_of_layer1_ul}:${read_attenuation_of_layer1_ul}
#   Log to console  ${current_attenuation_value}

Modify NIDD via webUI and get PDL error
    [Documentation]   author: Wang Yixiang
    ...    Modify NIDD parameter via selenium and check PDL error
    ...    ${parameter} example:
    ...    parameters = [
    ...    dict(
    ...        new_value='60',
    ...        dist_name=NR_CELL_NAME,
    ...        abbr='pucchDataDtxNumOfSamples',
    ...        filter_param='Number of PUCCH data samples for DTX detection'),
    ...    dict(
    ...        new_value='159',
    ...        dist_name=NR_CELL_NAME,
    ...        abbr='rloPathLossThreshold',
    ...        filter_param='Radio link outage path loss threshold',
    ...        unit='dB')
    ...    ]
    [Arguments]     ${parameters}
    log to console    /*** Modify NIDD parameter via selenium and return PDL error ***/
    COAM Navigate to login page via webUI
    FOR    ${cur_para_to_update}    IN    @{parameters}
        selenium_coam.set_parameter_value
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    abbr=${cur_para_to_update['abbr']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        ...    new_value=${cur_para_to_update['new_value']}
    END
    selenium_coam.validate_plan
    ${validation_error}    selenium_coam.get_relation_errors
    ${validation_error}    Convert To String    ${validation_error}
    [Return]     ${validation_error}
    [Teardown]     run keyword and ignore error     COAM selenium logout

Get NIDD value via rest api
    [Documentation]    Author: Wang Yixiang
    ...                Description:
    ...                 ${NRBTS_id}=${tl.gnbs[0].global_bts_id}
    ...                 ${MRBTS_id}=${tl.gnbs[0].instance_id}
    [Arguments]  ${parameter}    ${dist_name}    ${p_index}=${0}    ${list_name}=${None}    ${connection}=GNB_OAM
    ...          ${sub_scf_dir}=tmp_scf
    ...          ${config_type}=configurationAndRuntimeObjects
    ${local_dir}    Set Variable     ${LOG_PATH}/${sub_scf_dir}
    Create Directory    ${local_dir}
    ${current_time}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S%f
    ${scf_file_path}     Set Variable    ${local_dir}/scf_${current_time}.xml
    coam.collect_scf    target_file_name=${scf_file_path}    export_type=${config_type}
    ...    timeout=30    connection=${connection}
    ${value}     coam_parameter.get_single_value_from_scf_file    local_dir_path=${scf_file_path}   p_index=${p_index}
    ...       parameter=${parameter}   list_name=${list_name}   dist_name=${dist_name}
    ...       connection=${connection}    config_type=${config_type}
    run keyword and ignore error    run    rm -rf ${local_dir}
    [Return]   ${value}


Modification of NIDD parameters via restapi
    [Documentation]    Author: Cui Lingxue
    ...    (under construction)
    [Arguments]    ${param_to_upd}=${None}    ${param_to_add}=${None}    ${object_to_add}=${None}
    ...    ${connection}=GNB_OAM    ${timeout}=${60}
    ...    ${skip_parameter_relation_errors}=${True}    ${should_activate}=${True}
    ${delta_file_upd}        run keyword if    ${param_to_upd}!=${None}     coam_parameter.create_update_parameters_delta
    ...    parameters=${param_to_upd}    connection=${connection}
    ${delta_file_add}        run keyword if    ${param_to_add}!=${None}     coam_parameter.create_add_parameters_delta
    ...    parameters=${param_to_add}    connection=${connection}
    ${delta_file_add_obj}    run keyword if    ${object_to_add}!=${None}    coam_parameter.create_objects_delta
    ...    parameters=${object_to_add}   connection=${connection}
    ${delta_file_list_updated}    create list
    ${delta_file_list_reverse}    create list

    run keyword if    ${delta_file_upd}!=${None}    run keywords
    ...    append to list    ${delta_file_list_updated}    ${delta_file_upd['updated']}    AND
    ...    append to list    ${delta_file_list_reverse}    ${delta_file_upd['reverse']}
    run keyword if    ${delta_file_add}!=${None}    run keywords
    ...    append to list    ${delta_file_list_updated}    ${delta_file_add['updated']}    AND
    ...    append to list    ${delta_file_list_reverse}    ${delta_file_add['reverse']}
    run keyword if    ${delta_file_add_obj}!=${None}    run keywords
    ...    append to list    ${delta_file_list_updated}    ${delta_file_add_obj['updated']}    AND
    ...    append to list    ${delta_file_list_reverse}    ${delta_file_add_obj['reverse']}

    FOR    ${delta_file}    IN    @{delta_file_list_updated}
        ${commission_status}    coam_parameter.perform_scf_delta_commission    delta_file=${delta_file}    timeout=${timeout}
        ...                     connection=${connection}  skip_parameter_relation_errors=${skip_parameter_relation_errors}
        ...                     should_activate=${should_activate}
        run keyword and continue on failure    should contain    ${commission_status}    PASS    msg=Parameter modification failed.
    END
    [Return]    ${delta_file_list_reverse}

Restore NIDD parameters to original value via restapi
    [Documentation]    Author: Cui Lingxue
    ...    (under construction)
    [Arguments]    ${delta_file_list_reverse}    ${connection}=GNB_OAM    ${timeout}=${60}
    ...    ${skip_parameter_relation_errors}=${True}    ${should_activate}=${True}
    ${delta_file_list_reverse}    Convert variable to list type    ${delta_file_list_reverse}
    FOR    ${delta_file}    IN    @{delta_file_list_reverse}
        ${commission_status}    coam_parameter.perform_scf_delta_commission    delta_file=${delta_file}    timeout=${timeout}
        ...                     connection=${connection}  skip_parameter_relation_errors=${skip_parameter_relation_errors}
        ...                     should_activate=${should_activate}
        run keyword and continue on failure    should contain    ${commission_status}    PASS    msg=Parameter modification failed.
    END

Perform DL ping
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${ue_ip}=${UE_IP}    ${intervalofpings}=1    ${numberofping}=30    ${alias}=APPserver
    traffic_via_iperf.Connect to APPserver    alias=${alias}
    ${cmd_ping}    set variable    ping -c ${numberofping} -i ${intervalofpings} ${ue_ip}
    ${ping_result}    ssh.execute    command=${cmd_ping}    connection=${alias}
    [Return]    ${ping_result}
    [Teardown]    csn.disconnect    ${alias}

Perform UL ping
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${ue_index}=${0}    ${appserver_addr}=${tl.appserver.iperf_details.ssh_connection_details.addr}
    ...    ${intervalofpings}=1    ${numberofping}=5    ${alias}=cpc_${ue_index}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    ${cmd_ping}    set variable    adb -s ${serial_number} shell ping -c ${numberofping} -i ${intervalofpings} ${appserver_addr}
    FOR    ${i}    IN RANGE    ${5}
        ${ping_result}    ssh.execute    command=${cmd_ping}    connection=${alias}
        ${ping_ret}    run keyword and return status    Should Contain    ${ping_result}    rtt min/avg/max
        exit for loop if    ${ping_ret}==${True}
    END
    [Return]    ${ping_result}

Get ping latency and sort from largest to smallest
    [Documentation]    Author: Cui Lingxue
    ...    Will return a dict which contain average ping latency, max ping latency, all ping latency sorted from largest to smallest.
    ...    Eg, {'avg': '0.012', 'max': '0.018', 'details': [0.011, 0.016, 0.018, 0.016, 0.009, 0.009, 0.014, 0.009, 0.009, 0.009]}
    [Arguments]     ${ping_result}
    ${rtt}    Get lines containing String      ${ping_result}      min/avg/max/mdev
    ${rtt}    Get Regexp Matches      ${rtt}    [0123456789]{1,4}\.[0123456789]{1,3}
    ${average_rtt}    set variable    ${rtt[${1}]}
    ${max_rtt}    set variable    ${rtt[${2}]}
    ${ping_details}    Get lines containing String      ${ping_result}      time=
    ${ping_details_list}    split_to_lines    ${ping_details}
    ${ping_latency_list}    create list
    FOR    ${ping_result}    IN    @{ping_details_list}
        ${latency}    fetch_from_right    ${ping_result}    time=
        ${latency}    Get Regexp Matches      ${latency}    [0-9]+\.[0-9]*
        ${latency}    evaluate    float(${latency[0]})
        append to list    ${ping_latency_list}     ${latency}
    END
    sort_list    ${ping_latency_list}
    reverse_list    ${ping_latency_list}

    &{ping_latency}    create dictionary    avg=${average_rtt}    max=${max_rtt}    details=${ping_latency_list}
    [Return]    ${ping_latency}

Perform DL ping and calculate latency
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${UE_TYPE}    ${intervalofpings}=1    ${numberofping}=30
    Get UP IP and set as suite variable    ue_index=${ue_index}    ue_type=${ue_type}
    ${ping_result}    Perform DL ping    ue_ip=${UE_IP}    intervalofpings=${intervalofpings}    numberofping=${numberofping}    alias=APPserver
    ${ping_latency}    Get ping latency and sort from largest to smallest    ping_result=${ping_result}
    [Return]    ${ping_latency}

Perform DL ping and check all packet loss
    [Documentation]    Author: Dandan Fang
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${UE_TYPE}    ${intervalofpings}=1    ${numberofping}=30
    Get UP IP and set as suite variable    ue_index=${ue_index}    ue_type=${ue_type}
    ${ping_result}    Perform DL ping    ue_ip=${UE_IP}    intervalofpings=${intervalofpings}    numberofping=${numberofping}    alias=APPserver
    should contain    ${ping_result}    100% packet loss

Set ENB defaultLnRelGnbCellId to value
    [Documentation]    Author: Wang Yixiang
    ...    update "Default NR cell for dual connectivity" of eNB
    [Arguments]    ${value}    ${para_update_timeout}=5min    ${ln_cell_id}=1    ${alias}=enblte
    Connect to eNB via ssl    connection=${alias}
    ${defaultLnRelGnbCellId}    evaluate
    ...    [dict(dist_name='LNBTS-${tl.enbs[0].global_bts_id}/LNCEL-${ln_cell_id}', parameter='defaultLnRelGnbCellId', value='${value}')]
    ${update_status}    COAM Update several parameters via rest api
    ...    connection=${alias}     parameters_to_update_via_api=${defaultLnRelGnbCellId}    timeout=${para_update_timeout}
    Should be true    '${update_status}'=='PASS'
    [Teardown]    Enblte close down    connection=${alias}

Set attenuator ports of specified RUs to same value
    [Documentation]    Author: Wang Yixiang
    ...    All associated RU ports on attenuator will be modified to ${exp_pa_value}.
    ...    ru_idx_list can be ru index in testline init file, for example:ru_idx_list=0,1
    [Arguments]    ${exp_pa_value}    ${ru_idx_list}    ${gnb_index}=${0}    ${is_connection_needed}=${True}
    ${ru_idx_list}    string2list    ${ru_idx_list}
    ${atten_ports_list}    create list

    Run keyword if    ${is_connection_needed}
    ...    Connect to Attenuator    attenuator_index=${0}    alias=ATTEN_0

    FOR    ${ru_index}    IN    @{ru_idx_list}
        ${ru_index}    Convert To Integer   ${ru_index}
        ${atten_ports}    gnb_classical_hangzhou.Get Attenuation Channels For RU    gnb_id=${gnb_index}    RU_id=${ru_index}
        ${atten_ports_list}   Combine Lists     ${atten_ports_list}    ${atten_ports}
    END

    ${exp_pa_value}    evaluate    int(${exp_pa_value})
    ${atten_ports_len}    get length    ${atten_ports_list}
    ${pa_values}   evaluate  [int(${exp_pa_value}) for _ in range(${atten_ports_len})]
    Log to console    gnb_index: ${gnb_index}, ru_index: ${ru_idx_list}, atten_port:${atten_ports_list}, exp_pa_value: ${pa_values}
    wait until keyword succeeds    5    1s
    ...    attenuator.set_ports_attenuation   ports=${atten_ports_list}    values=${pa_values}   confirm=${True}   attenuator_device=ATTEN_0
