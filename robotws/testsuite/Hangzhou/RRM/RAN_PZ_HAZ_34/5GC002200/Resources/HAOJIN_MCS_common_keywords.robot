*** Settings ***
Documentation
...    author: kk
...    contact:kk.wang@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC002200


Resource       ./5GC002200_coam_common_keywords.robot
Variables      ./variables.py
Library        ./tput_output.py

*** Variables ***
${haojin_ip_365}            ${tl.attenuator[0].ip_addr}
${model}                    ${tl.attenuator[0].model}
${vendor_hj}                HAOJIN
${server_port}              ${tl.attenuator[0].port}

*** Keywords ***
HAOJIN MCS Prepare
    [Arguments]     ${ip}    ${vendor}=${vendor_hj}    ${model}=${model}    ${server_port}=${server_port}    ${mcs_alias}=HJ
    MCS.Setup     alias=${mcs_alias}    vendor=${vendor}    model=${model}    ip=${ip}    port=${${server_port}}

Set HAOJIN Odd ATT By Output_port
    [Arguments]    ${begin_output_port}    ${end_output_port}    ${attenuation}    ${B_Odd}    ${mcs_alias}=HJ
    FOR    ${num}    IN RANGE    ${${begin_output_port}}    ${${end_output_port}}+1
      Run keyword if    ${num}%2 and '${B_Odd}'=='True'    HAOJIN MCS Set Odd Attenuations    attenuation=${${attenuation}}
      ...    output_port=${${num}}    mcs_alias=${mcs_alias}
      Run keyword if    ${num}%2==0 and '${B_Odd}'=='False'    HAOJIN MCS Set Odd Attenuations    attenuation=${${attenuation}}
      ...    output_port=${${num}}    mcs_alias=${mcs_alias}
      sleep    3s
    END

Set HAOJIN Even ATT By Output_port
    [Arguments]    ${begin_output_port}    ${end_output_port}    ${attenuation}    ${B_Odd}    ${mcs_alias}=HJ
    FOR    ${num}    IN RANGE    ${${begin_output_port}}    ${${end_output_port}}+1
      Run keyword if    ${num}%2 and '${B_Odd}'=='True'    HAOJIN MCS Set Even Attenuations    attenuation=${${attenuation}}
      ...    output_port=${${num}}    mcs_alias=${mcs_alias}
      Run keyword if    ${num}%2==0 and '${B_Odd}'=='False'    HAOJIN MCS Set Even Attenuations    attenuation=${${attenuation}}
      ...    output_port=${${num}}    mcs_alias=${mcs_alias}
    END

Set HAOJIN horizontal and vertical Phases by output_port
    [Arguments]    ${begin_output_port}    ${end_output_port}    ${input_group_id}    ${vertical_angle}
    ...    ${horizontal_angle}    ${vertical_distance}    ${horizontal_distance}    ${mcs_alias}
    FOR    ${B_value}    IN    ${${begin_output_port}}    ${${end_output_port}}
      HAOJIN MCS Set Phases According to Angles    input_group_id=${input_group_id}    vertical_angle=${vertical_angle}
      ...    horizontal_angle=${horizontal_angle}    output_group_id=${B_value}    vertical_distance=${vertical_distance}
      ...    horizontal_distance=${horizontal_distance}    mcs_alias=${mcs_alias}
    END

HAOJIN MCS Set Phases According to Angles
    [Arguments]    ${vertical_angle}    ${horizontal_angle}    ${vertical_distance}    ${horizontal_distance}
    ...    ${output_group_id}    ${input_group_id}    ${mcs_alias}
    mcs.set_phases_according_to_angles    vertical_angle=${vertical_angle}    horizontal_angle=${horizontal_angle}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    ...    output_group_id=${output_group_id}    input_group_id=${input_group_id}    mcs_device=${mcs_alias}

HAOJIN MCS Set Odd Attenuations
    [Arguments]     ${attenuation}     ${output_port}    ${mcs_alias}
    MCS.set_odd_attenuations    attenuation=${attenuation}    output_port=${output_port}    mcs_device=${mcs_alias}

HAOJIN MCS Set Even Attenuations
    [Arguments]     ${attenuation}     ${output_port}    ${mcs_alias}
    MCS.set_even_attenuations    attenuation=${attenuation}     output_port=${output_port}    mcs_device=${mcs_alias}

Set HAOJIN ATT
    [Arguments]    ${att_value}
    Set HAOJIN Odd ATT By Output_port    begin_output_port=1    end_output_port=4    attenuation=${att_value}    B_Odd=True
    sleep    3s
    Set HAOJIN Even ATT By Output_port    begin_output_port=1    end_output_port=4    attenuation=90    B_Odd=True
    sleep    3s
    Set HAOJIN Odd ATT By Output_port    begin_output_port=1    end_output_port=4    attenuation=90    B_Odd=False
    sleep    3s
    Set HAOJIN Even ATT By Output_port    begin_output_port=1    end_output_port=4    attenuation=${att_value}    B_Odd=False
    sleep    3s

Set HAOJIN Port13 to Port16 ATT
    [Arguments]    ${att_value}
    Set HAOJIN Odd ATT By Output_port    begin_output_port=13    end_output_port=16    attenuation=${att_value}    B_Odd=True
    sleep    3s
    Set HAOJIN Even ATT By Output_port    begin_output_port=13    end_output_port=16    attenuation=90    B_Odd=True
    sleep    3s
    Set HAOJIN Odd ATT By Output_port    begin_output_port=13    end_output_port=16    attenuation=90    B_Odd=False
    sleep    3s
    Set HAOJIN Even ATT By Output_port    begin_output_port=13    end_output_port=16    attenuation=${att_value}    B_Odd=False
    sleep    3s

Set HAOJIN Begin_Port to End_Port ATT
    [Arguments]    ${begin_port}    ${end_port}    ${att_value}
    Set HAOJIN Odd ATT By Output_port    begin_output_port=${begin_port}    end_output_port=${end_port}    attenuation=${att_value}    B_Odd=True
    sleep    3s
    Set HAOJIN Even ATT By Output_port    begin_output_port=${begin_port}    end_output_port=${end_port}    attenuation=90    B_Odd=True
    sleep    3s
    Set HAOJIN Odd ATT By Output_port    begin_output_port=${begin_port}    end_output_port=${end_port}    attenuation=90    B_Odd=False
    sleep    3s
    Set HAOJIN Even ATT By Output_port    begin_output_port=${begin_port}    end_output_port=${end_port}    attenuation=${att_value}    B_Odd=False
    sleep    3s

Set HAOJIN ATT_port5_8
    [Arguments]    ${att_value}
    Set HAOJIN Odd ATT By Output_port    begin_output_port=5    end_output_port=8    attenuation=${att_value}    B_Odd=True
    sleep    3s
    Set HAOJIN Even ATT By Output_port    begin_output_port=5    end_output_port=8    attenuation=90    B_Odd=True
    sleep    3s
    Set HAOJIN Odd ATT By Output_port    begin_output_port=5    end_output_port=8    attenuation=90    B_Odd=False
    sleep    3s
    Set HAOJIN Even ATT By Output_port    begin_output_port=5    end_output_port=8    attenuation=${att_value}    B_Odd=False
    sleep    3s

Set HAOJIN ATT_90
    [Arguments]    ${att_value}
    Set HAOJIN Odd ATT By Output_port    begin_output_port=1    end_output_port=4    attenuation=${att_value}    B_Odd=True
    sleep    3s
    Set HAOJIN Even ATT By Output_port    begin_output_port=1    end_output_port=4    attenuation=90    B_Odd=True
    sleep    3s
    Set HAOJIN Odd ATT By Output_port    begin_output_port=1    end_output_port=4    attenuation=90    B_Odd=False
    sleep    3s
    Set HAOJIN Even ATT By Output_port    begin_output_port=1    end_output_port=4    attenuation=${att_value}    B_Odd=False
    sleep    3s

Set HAOJIN θ poll for horizontal
    [Arguments]    ${begin_θ_h}    ${end_θ_h}    ${B1_port}    ${B2_port}    ${B3_port}    ${B4_port}    ${input_group_id}
    ...    ${vertical_distance}    ${vertical_angle}    ${horizontal_distance}    ${vertical_x}    ${csv_path}    ${mcs_alias}=HJ
    ...    ${cellid}=${1}
    FOR    ${θ_horizontal}    IN RANGE    ${${begin_θ_h}}    ${${end_θ_h}}    5
        Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${B1_port}    end_output_port=${B2_port}
        ...    input_group_id=${input_group_id}    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
        ...    vertical_angle=${vertical_angle}    horizontal_angle=${θ_horizontal}    mcs_alias=${mcs_alias}
        ${θ_horizontal_x}    BuiltIn.Evaluate    ${θ_horizontal}+5
        sleep    5s
        Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${B3_port}    end_output_port=${B4_port}
        ...    input_group_id=${input_group_id}    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
        ...    vertical_angle=${vertical_angle}    horizontal_angle=${θ_horizontal_x}    mcs_alias=${mcs_alias}
        sleep    10s
        ${tput}    Power UE check throughput with nrcellid     cellid=${cellid}     dlexpect=${dlexpect}
        Append To List    ${list}    ${tput}
        tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=${vertical_x}    value2=${θ_horizontal}    value3=${tput}
        log    ${list}
        ${i}=    BuiltIn.Evaluate    ${i}+1
    END

Set HAOJIN θ poll for vertical and get UE info
    [Arguments]    ${begin_θ_v}    ${end_θ_v}    ${begin_θ_h}    ${end_θ_h}    ${B1_port}    ${B4_port}    ${B2_port}    ${B3_port}
    ...    ${csv_path}    ${input_group_id}    ${vertical_distance}    ${horizontal_distance}    ${cellid}=${1}
    FOR    ${θ_vertical}    IN RANGE    ${${begin_θ_v}}    ${${end_θ_v}}   5
        Set HAOJIN θ poll for horizontal    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    B1_port=${B1_port}    B4_port=${B4_port}
        ...    B2_port=${B2_port}    B3_port=${B3_port}    vertical_angle=${θ_vertical}    vertical_x=${θ_vertical}    csv_path=${csv_path}
        ...    input_group_id=${input_group_id}    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
        ...    cellid=${cellid}
    END

HAOJIN TEST with different ATTs
    [Arguments]     ${att_goodpoint}    ${att_medialpoint}    ${att_poorpoint}    ${begin_θ_v}    ${end_θ_v}    ${begin_θ_h}
    ...    ${end_θ_h}    ${B1_port}    ${B4_port}    ${B2_port}    ${B3_port}    ${csv_path}    ${vertical_distance}
    ...    ${horizontal_distance}    ${input_group_id}=${0}    ${cellid}=${1}
    ${list}=    create list
    set test variable    ${i}    ${1}
    set test variable    ${list}
    tput_output.create_new_file_csv    csv_file_path=${csv_path}
    FOR    ${att}    IN    ${${att_goodpoint}}    ${${att_medialpoint}}    ${${att_poorpoint}}
      Set HAOJIN ATT    att_value=${att}
      tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
      Set HAOJIN θ poll for vertical and get UE info    begin_θ_v=${begin_θ_v}    end_θ_v=${end_θ_v}    begin_θ_h=${begin_θ_h}
      ...    end_θ_h=${end_θ_h}    B1_port=${B1_port}    B4_port=${B4_port}    B2_port=${B2_port}    B3_port=${B3_port}
      ...    csv_path=${csv_path}    input_group_id=${input_group_id}    vertical_distance=${vertical_distance}
      ...    horizontal_distance=${horizontal_distance}    cellid=${cellid}
    END

HAOJIN TEST with one ATT
    [Arguments]     ${att}    ${begin_θ_v}    ${end_θ_v}    ${begin_θ_h}
    ...    ${end_θ_h}    ${B1_port}    ${B4_port}    ${B2_port}    ${B3_port}    ${csv_path}    ${vertical_distance}
    ...    ${horizontal_distance}    ${input_group_id}=${0}
    ${list}=    create list
    set test variable    ${i}    ${1}
    set test variable    ${list}
    tput_output.create_new_file_csv    csv_file_path=${csv_path}
    Set HAOJIN ATT    att_value=${att}
    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
    Set HAOJIN θ poll for vertical and get UE info    begin_θ_v=${begin_θ_v}    end_θ_v=${end_θ_v}    begin_θ_h=${begin_θ_h}
    ...    end_θ_h=${end_θ_h}    B1_port=${B1_port}    B4_port=${B4_port}    B2_port=${B2_port}    B3_port=${B3_port}
    ...    csv_path=${csv_path}    input_group_id=${input_group_id}    vertical_distance=${vertical_distance}
    ...    horizontal_distance=${horizontal_distance}    cellid=${1}

Caculate average tput_HJ
    ${count}    BuiltIn.Get Length    ${list}
    ${sum}     set variable    ${0}
    FOR    ${j}    IN RANGE    ${count}
      ${sum}=    BuiltIn.Evaluate    ${sum}+${list[${j}]}
    END
    ${ave}    BuiltIn.Evaluate    round(${sum}/${count},2)
    #tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=ave_tput    value2=is    value3=${ave}
    Log    average_tput is ${ave}
    [Return]    ${ave}
