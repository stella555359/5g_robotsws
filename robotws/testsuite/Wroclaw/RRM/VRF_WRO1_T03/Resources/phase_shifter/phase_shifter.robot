*** Settings ***
Documentation
...     Set of keywords to configure phase shifter phases and attenuations
Library     OperatingSystem
Library     Collections
Library     String
Library     BuiltIn
Library     taf.hw.mcs    WITH NAME    MCS

*** Variables ***
${mcs_index}=       ${0}
${mcs_alias}=       MCS_${mcs_index}
${server_ip}=       ${tl.attenuator[${mcs_index}].ip_addr}
${server_port}=     ${tl.attenuator[${mcs_index}].port}
${vendor}=          ${tl.attenuator[${mcs_index}].vendor}
${model}=           ${tl.attenuator[${mcs_index}].model}
@{output_ports}=    1  2  3  4  5  6  7  8  9  10  11  12  13  14  15  16            #5  6  7  8  13  14  15  16


*** Keywords ***
MCS Setup
    [Arguments]     ${mcs_alias}=${mcs_alias}    ${vendor}=${vendor}    ${model}=${model}
    ...             ${server_ip}=${server_ip}    ${server_port}=${server_port}
    MCS.Setup     alias=${mcs_alias}    vendor=${vendor}    model=${model}    server_ip=${server_ip}    server_port=${server_port}

MCS Teardown
    [Arguments]     ${mcs_alias}=${mcs_alias}
    MCS.teardown    mcs_device=${mcs_alias}

Get Current Set
    [Arguments]
    MCS.get phase  input_port=${3}  output_port=${3}  mcs_device=${mcs_alias}
    MCS.get attenuation  input_port=${3}  output_port=${3}  mcs_device=${mcs_alias}

Set Phase And Att According To CSV File
    [Arguments]    ${csv_settings}    ${specified_port_list}=${False}    ${custom_att}=${False}
    ${conf_file}=  OperatingSystem.Get File  ${csv_settings}    #${CURDIR}/../../PS_features/Resources/${csv_settings}
    ${output_ports}=    Run Keyword If    not ${specified_port_list}    Set Variable    ${output_ports}
    ...    ELSE    Set Variable    ${specified_port_list}
    FOR  ${port_b}  IN  @{output_ports}
        ${port_b_configuration}=  Get Line  ${conf_file}  ${port_b}
        @{port_b_configuration}=  Split String  ${port_b_configuration}  ,
        Remove From List  ${port_b_configuration}  -1
        ${output_port}=  Get From List  ${port_b_configuration}  0
        Set Phase And Att According To CSV File For Each Inpu Port  ${output_port}  ${port_b_configuration}  ${custom_att}
    END

Set Phase And Att According To CSV File For Each Inpu Port
    [Arguments]    ${output_port}  ${port_b_configuration}  ${custom_att}
    ${output_port}=  Get Substring  ${output_port}  1
    ${output_port}=  Convert To Integer  ${output_port}
    FOR  ${port_index}  ${port}  IN ENUMERATE  @{port_b_configuration[1:]}
        ${att}  ${phase}=  Split String  ${port}  |
        ${att}=  Run Keyword If    not ${custom_att}    Convert To Number  ${att}    ELSE    Convert To Number    ${custom_att}
        ${phase}=  Convert To Number  ${phase}
        ${port_index}=  Evaluate  ${port_index}+1
        Set Single Phase  ${phase}  ${port_index}  ${output_port}
        Set Single Attenuation  ${att}  ${port_index}  ${output_port}
    END

Set Single Phase
    [Arguments]  ${phase}  ${input_port}  ${output_port}
    MCS.Set Phase
    ...     phase=${phase}
    ...     input_port=${input_port}
    ...     output_port=${output_port}
    ...     mcs_device=${mcs_alias}

Set Single Attenuation
    [Arguments]  ${att}  ${input_port}  ${output_port}
    MCS.Set Attenuation
    ...     attenuation=${att}
    ...     input_port=${input_port}
    ...     output_port=${output_port}
    ...     mcs_device=${mcs_alias}

Set Odd Attenuations
    MCS.Set Odd Attenuations
    ...     attenuation=${30}
    ...     begin_input_port=${1}
    ...     end_input_port=${64}
    ...     output_port=${3}
    ...     mcs_device=${mcs_alias}

Set Phase According To Angle
    [Arguments]
    MCS.set phases according to angles
    ...     vertical_angle=${5}
    ...     horizontal_angle=${-2}
    ...     vertical_distance=${5}
    ...     horizontal_distance=${5}
    ...     output_group_id=${3}
    ...     input_group_id=${3}
    ...     mcs_device=${mcs_alias}

Setup PS
    [Arguments]    ${csv_settings}=controller_max_reg_1_3.csv
    MCS Setup
    Set Phase And Att According To CSV File    ${csv_settings}
    [Teardown]  MCS Teardown

Setup PS With Single Value
    [Arguments]    ${csv_settings}=controller_max_reg_1_3.csv
    MCS Setup
    Set Phase And Att According To CSV File    ${csv_settings}
    [Teardown]  MCS Teardown

Set Specified Channels To Specified Att
    [Arguments]    ${channels_list}=${False}    ${att_value}=90    ${csv_settings}=None
    MCS Setup
    Set Phase And Att According To CSV File    ${csv_settings}    ${channels_list}    ${att_value}
    [Teardown]  MCS Teardown

