*** Settings ***
Documentation    Place for MCS common keywords, including three type of MCS:TopYoung, HAOJIN, HBTE
...    contact:lei.jia@nokia-sbell.com
...    for topyoung mcs, you can use it in this way:
...    output_port is B9/B10/B11/B12， input_port is A1/A2...A63/A64.
...    ${mcs_type}    mcs_common.Get MCS Type
...    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=2600_1_ALL
...    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
...               begin_output_port=${9}    end_output_port=${10}    begin_input_port=${1}
...               end_input_port=${32}    vertical_angle=${-6}    horizontal_angle=${-7}
...               vertical_distance=${2.1}    horizontal_distance=${0.5}
...    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
...               begin_output_port=${11}    end_output_port=${12}    begin_input_port=${1}
...               end_input_port=${32}    vertical_angle=${-6}    horizontal_angle=${-22}
...               vertical_distance=${2.1}    horizontal_distance=${0.5}
...    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value}
...               begin_output_port=${9}    end_output_port=${12}    begin_input_port=${1}    end_input_port=${64}


Library     OperatingSystem
Library     Collections
Library     String
Library     BuiltIn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/topyoung.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/haojin.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/hbte.robot

*** Keywords ***
################## STEP:Get MCS Type From testline configuration ########################
mcs_common.Get MCS Type
    [Arguments]    ${mcs_index}=${0}
    ${vendor}    set variable    ${tl.attenuators[${mcs_index}].vendor}
    ${vendor}    Convert To Lower Case    ${vendor}
    ${model}    set variable    ${tl.attenuator[${mcs_index}].model}
    ${mcs_type} =    run keyword if
    ...               '${vendor}' == 'topyoung' and 'MCS' in '${model}'   set variable    topyoung
    ...    ELSE IF    '${vendor}' == 'topyoung' and 'Radio' in '${model}'    set variable    haojin
    ...    ELSE IF    '${vendor}' == 'hbte' and 'PPSAM' in '${model}'    set variable    hbte
    [Return]    ${mcs_type}

################################## STEP:Setup MCS ###############################################
mcs_common.Setup MCS
    [Documentation]    Setup MCS.
    [Arguments]    ${mcs_type}    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...            ${server_ip}=${tl.attenuator[${mcs_index}].ip_addr}
    ...            ${server_port}=${tl.attenuator[${mcs_index}].port}
    ...            ${vendor}=${tl.attenuator[${mcs_index}].vendor}
    ...            ${model}=${tl.attenuator[${mcs_index}].model}
    ...            ${frequency}=${None}
    ${output}    run keyword    ${mcs_type}.Setup MCS    mcs_index=${mcs_index}
    ...                                                  mcs_alias=${mcs_alias}
    ...                                                  server_ip=${server_ip}
    ...                                                  server_port=${server_port}
    ...                                                  vendor=${vendor}
    ...                                                  model=${model}
    ...                                                  frequency=${frequency}
    [Return]    ${output}

####################### STEP:Set Phases According To Angles For Input And Output Groups ##################################
mcs_common.Set Phases According To Angles For Input And Output Groups
    [Documentation]    set channel phases according to vertical, horizontal angles for given input and output groups
    ...  :param  begin_output_port/end_output_port:  output group id,
    ...                   e.g ${begin_output_port}=${1}, mapping to B1. ${end_output_port}=${4}, mapping to B4.
    ...                   only B1 and B4 ports are calcuted.
    ...  :param  begin_input_port/end_input_port: input_group_id, note it is group id!
    ...                for topyoung begin_input_port=1,  means input_group_id = 1, output_ids (A1, A2)
    ...                when set ${begin_input_port}=${1}, ${end_input_port}=${32}, all A1-A64(total 64 ports) will be calcuted.
    [Arguments]    ${mcs_type}    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_output_port}=${1}    ${end_output_port}=${4}
    ...    ${begin_input_port}=${1}    ${end_input_port}=${32}    ${input_group_id}=${None}
    ...    ${vertical_angle}=${None}    ${horizontal_angle}=${None}
    ...    ${vertical_distance}=${None}    ${horizontal_distance}=${None}
    ${output}    run keyword    ${mcs_type}.Set Phases According To Angles For Input And Output Groups
    ...                                                 mcs_index=${mcs_index}
    ...                                                 mcs_alias=${mcs_alias}
    ...                                                 begin_output_port=${begin_output_port}
    ...                                                 end_output_port=${end_output_port}
    ...                                                 begin_input_port=${begin_input_port}
	...                                                 end_input_port=${end_input_port}
    ...                                                 input_group_id=${input_group_id}
    ...                                                 vertical_angle=${vertical_angle}
    ...                                                 horizontal_angle=${horizontal_angle}
    ...                                                 vertical_distance=${vertical_distance}
    ...                                                 horizontal_distance=${horizontal_distance}
    [Return]    ${output}

####################### STEP:Set Odd And Even ATT For Output Port ##################################
mcs_common.Set Odd And Even ATT For Output Port
    [Documentation]    set set specified odd and even channel attenuation value for output ports
    ...  :param  begin_output_port/end_output_port:  output port in channel,
    ...                   e.g ${begin_output_port}=${1}, ${end_output_port}=${4}, B1/B2/B3/B4 attenuation values are set.
    ...  :param  begin_input_port/end_input_port: begin/end input port in channel, note it is port!
    ...                when set ${begin_input_port}=${1}, ${end_input_port}=${64}, all A1-A64 attenuation values are set.
    [Arguments]    ${mcs_type}    ${att_value}    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_output_port}=${None}    ${end_output_port}=${None}
    ...    ${begin_input_port}=${1}    ${end_input_port}=${64}
    ${output}    run keyword    ${mcs_type}.Set Odd And Even ATT For Output Port
    ...                                                 mcs_index=${mcs_index}
    ...                                                 mcs_alias=${mcs_alias}
    ...                                                 begin_output_port=${begin_output_port}
    ...                                                 end_output_port=${end_output_port}
    ...                                                 begin_input_port=${begin_input_port}
	...                                                 end_input_port=${end_input_port}
    ...                                                 att_value=${att_value}
    [Return]    ${output}

####################### STEP:Set θ Poll For Horizontal Angle ##################################
mcs_common.Set θ Poll For Horizontal Angle
    [Arguments]    ${mcs_type}    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_input_port}=${None}    ${end_input_port}=${None}   ${input_group_id}=${None}
    ...    ${begin_θ_h}=${None}    ${end_θ_h}=${None}    ${θ_h_increment}=5
    ...    ${B1_port}=${None}    ${B2_port}=${None}    ${B3_port}=${None}    ${B4_port}=${None}
    ...    ${vertical_angle}=${None}    ${vertical_x}=${None}    ${sleep_time}=5s    ${range_step}=5
    ...    ${vertical_distance}=${None}    ${horizontal_distance}=${None}
    ${output}    run keyword    ${mcs_type}.Set θ Poll For Horizontal Angle
    ...                                                 mcs_index=${mcs_index}
    ...                                                 mcs_alias=${mcs_alias}
    ...                                                 begin_θ_h=${begin_θ_h}
    ...                                                 end_θ_h=${end_θ_h}
    ...                                                 begin_input_port=${begin_input_port}
	...                                                 end_input_port=${end_input_port}
    ...                                                 B1_port=${B1_port}
    ...                                                 B2_port=${B2_port}
    ...                                                 B3_port=${B3_port}
    ...                                                 B4_port=${B4_port}
    ...                                                 vertical_angle=${vertical_angle}
    ...                                                 θ_h_increment=${θ_h_increment}
    ...                                                 vertical_x=${vertical_x}
    ...                                                 input_group_id=${input_group_id}
    ...                                                 vertical_angle=${vertical_angle}
    ...                                                 vertical_distance=${vertical_distance}
    ...                                                 horizontal_distance=${horizontal_distance}
    ...                                                 sleep_time=${sleep_time}
    ...                                                 range_step=${range_step}
    [Return]    ${output}

####################### STEP:Set θ Poll For Vertical Angel##################################
mcs_common.Set θ Poll For Vertical Angel
    [Arguments]    ${mcs_type}    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_input_port}=${None}    ${end_input_port}=${None}    ${input_group_id}=${None}
    ...    ${begin_θ_h}=${None}    ${end_θ_h}=${None}
    ...    ${begin_θ_v}=${None}    ${end_θ_v}=${None}
    ...    ${B1_port}=${None}    ${B4_port}=${None}    ${B2_port}=${None}    ${B3_port}=${None}
    ...    ${vertical_distance}=${None}    ${horizontal_distance}=${None}
    ${output}    run keyword    ${mcs_type}.Set θ Poll For Vertical Angel
    ...                                                 mcs_index=${mcs_index}
    ...                                                 mcs_alias=${mcs_alias}
    ...                                                 begin_θ_h=${begin_θ_h}
    ...                                                 end_θ_h=${end_θ_h}
    ...                                                 begin_input_port=${begin_input_port}
	...                                                 end_input_port=${end_input_port}
    ...                                                 B1_port=${B1_port}
    ...                                                 B2_port=${B2_port}
    ...                                                 B3_port=${B3_port}
    ...                                                 B4_port=${B4_port}
    ...                                                 input_group_id=${input_group_id}
    ...                                                 vertical_distance=${vertical_distance}
    ...                                                 horizontal_distance=${horizontal_distance}
    [Return]    ${output}

####################### STEP:Teardown MCS ##################################
mcs_common.Teardown MCS
    [Arguments]     ${mcs_type}    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ${output}    run keyword    ${mcs_type}.Teardown MCS    mcs_alias=${mcs_alias}
    [Return]    ${output}

