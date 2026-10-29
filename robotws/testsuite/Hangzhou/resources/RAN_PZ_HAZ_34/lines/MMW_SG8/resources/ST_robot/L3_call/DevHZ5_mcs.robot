*** Settings ***
Documentation
...    Author:yin zhang
...    contact:yin.zhang@nokia-sbell.com
...    squad group:VRF3_7
Library    String
Library    Collections
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/mcs_common.robot

*** Keywords ***
Get MCS Type local
    [Arguments]    ${mcs_index}=0
    ${mcs_index}    Evaluate    int(${mcs_index})
    ${vendor}    set variable    ${tl.mcses[${mcs_index}].vendor.lower()}
#    ${vendor}    Convert To Lower Case    ${vendor}
    ${model}    set variable    ${tl.mcses[${mcs_index}].model}
    ${mcs_type} =    run keyword if
    ...               '${vendor}' == 'topyoung' and 'MCS' in '${model}'   set variable    topyoung
    ...    ELSE IF    '${vendor}' == 'topyoung' and 'Radio' in '${model}'    set variable    haojin
    ...    ELSE IF    '${vendor}' == 'hbte' and 'PPSAM' in '${model}'    set variable    hbte
    [Return]    ${mcs_type}

Setup MCS local
    [Documentation]    Setup MCS.
    [Arguments]    ${mcs_type}    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...            ${server_ip}=${tl.mcses[${mcs_index}].ip_addr}
    ...            ${server_port}=${tl.mcses[${mcs_index}].port}
    ...            ${vendor}=${tl.mcses[${mcs_index}].vendor}
    ...            ${model}=${tl.mcses[${mcs_index}].model}
    ...            ${frequency}=${None}
    ${mcs_index}    Evaluate    int(${mcs_index})
    ${output}    run keyword    ${mcs_type}.Setup MCS    mcs_index=${mcs_index}
    ...                                                  mcs_alias=${mcs_alias}
    ...                                                  server_ip=${server_ip}
    ...                                                  server_port=${server_port}
    ...                                                  vendor=${vendor}
    ...                                                  model=${model}
    ...                                                  frequency=${frequency}
    [Return]    ${output}

Ajust MCS Att
    [Arguments]    ${value}    ${mcs_index}=0    ${ue_id}=1
    ${mcs_index}    Set Variable    int(${mcs_index})
    ${begin_output_port}    Evaluate    (${ue_id}-1)*4+1
    ${end_output_port}    Evaluate    (${ue_id}-1)*4+4
    ${begin_input_port}    Set Variable    ${1}
    ${end_input_port}    _extract mcs ports number    ${mcs_index}
    ${mcs_index}    Evaluate    int(${mcs_index})
    ${mcs_type}    Get MCS Type Local    ${mcs_index}
    Setup MCS Local    ${mcs_type}    mcs_index=${mcs_index}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}
    ...                                                mcs_index=${mcs_index}
    ...                                                begin_output_port=${begin_output_port}
    ...                                                end_output_port=${end_output_port}
    ...                                                begin_input_port=${begin_input_port}
    ...                                                end_input_port=${end_input_port}
    ...                                                att_value=${value}
    [Teardown]    mcs_common.Teardown MCS    ${mcs_type}    ${mcs_index}

Ajust MCS Att Stepwise
    [Arguments]    ${start_value}    ${end_value}    ${step}=2    ${interval}=0.5
    ...            ${mcs_index}=0    ${ue_id}=1
    ${begin_output_port}    Evaluate    (${ue_id}-1)*4+1
    ${end_output_port}    Evaluate    (${ue_id}-1)*4+4
    ${begin_input_port}    Set Variable    ${1}
    ${end_input_port}    _extract mcs ports number    ${mcs_index}
    ${mcs_type}    Get MCS Type Local    ${mcs_index}
    Setup MCS Local    ${mcs_type}    mcs_index=${mcs_index}
    ${times}    Evaluate   (${end_value}-${start_value})/${step}
    ${times}    convert to integer    ${times}
    ${current_value}    Evaluate   int(${start_value})
    FOR    ${time}    IN RANGE    ${${times}+1}
        mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}
        ...                                                mcs_index=${mcs_index}
        ...                                                begin_output_port=${begin_output_port}
        ...                                                end_output_port=${end_output_port}
        ...                                                begin_input_port=${begin_input_port}
        ...                                                end_input_port=${end_input_port}
        ...                                                att_value=${current_value}
        ${current_value}    Evaluate     ${current_value}+int(${step})
        Sleep    ${interval}
    END
    [Teardown]    mcs_common.Teardown MCS    ${mcs_type}    ${mcs_index}

_extract mcs ports number
    [Arguments]    ${mcs_index}=0
    ${split_string}=    Split String    ${tl.mcses[${mcs_index}].model}    -
    ${middle_part}=    Get From List    ${split_string}    1
    ${number}=    Get Regexp Matches    ${middle_part}    \\d+
    ${ports_number}    Evaluate    int(${number[0]})
    [Return]    ${ports_number}
