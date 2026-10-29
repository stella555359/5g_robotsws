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
${topyoung_ip_362}           ${tl.attenuator[0].ip_addr}
${model}                     ${tl.attenuator[0].model}
${vendor_tp}                  TOPYOUNG
${server_port}               ${tl.attenuator[0].port}

*** Keywords ***
Set Odd ATT By Output_port
    [Arguments]    ${begin_output_port}    ${end_output_port}    ${attenuation}    ${B_Odd}    ${mcs_alias}=TPY
    FOR    ${num}    IN RANGE    ${${begin_output_port}}    ${${end_output_port}}+1
      Run keyword if    ${num}%2 and '${B_Odd}'=='True'    MCS Set Odd Attenuations    attenuation=${${attenuation}}
      ...    begin_input_port=${1}    end_input_port=${64}    output_port=${${num}}    mcs_alias=${mcs_alias}
      Run keyword if    ${num}%2==0 and '${B_Odd}'=='False'    MCS Set Odd Attenuations    attenuation=${${attenuation}}
      ...    begin_input_port=${1}    end_input_port=${64}    output_port=${${num}}    mcs_alias=${mcs_alias}
    END

Set Even ATT By Output_port
    [Arguments]    ${begin_output_port}    ${end_output_port}    ${attenuation}    ${B_Odd}    ${mcs_alias}=TPY
    FOR    ${num}    IN RANGE    ${${begin_output_port}}    ${${end_output_port}}+1
      Run keyword if    ${num}%2 and '${B_Odd}'=='True'    MCS Set Even Attenuations    attenuation=${${attenuation}}
      ...    begin_input_port=${1}    end_input_port=${64}    output_port=${${num}}    mcs_alias=${mcs_alias}
      Run keyword if    ${num}%2==0 and '${B_Odd}'=='False'    MCS Set Even Attenuations    attenuation=${${attenuation}}
      ...    begin_input_port=${1}    end_input_port=${64}    output_port=${${num}}    mcs_alias=${mcs_alias}
    END

MCS Prepare and set frequency
    [Arguments]     ${ip}    ${vendor}=${vendor_tp}    ${model}=${model}    ${server_port}=${server_port}    ${mcs_alias}=TPY
    MCS.Setup     alias=${mcs_alias}    vendor=${vendor}    model=${model}    server_ip=${ip}    server_port=${${server_port}}
    MCS.Set_frequency    frequency=3500_1_ALL    mcs_device=${mcs_alias}

Set TOPYOUNG horizontal and vertical Phases by output_port
    [Arguments]    ${begin_output_port}    ${end_output_port}    ${begin_input_port}    ${end_input_port}    ${vertical_angle}
    ...    ${horizontal_angle}    ${mcs_alias}
    FOR    ${B_value}    IN    ${${begin_output_port}}    ${${end_output_port}}
      input_port_value gather    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}    vertical_angle=${vertical_angle}
      ...    horizontal_angle=${horizontal_angle}    B_value=${B_value}    mcs_alias=${mcs_alias}
    END

input_port_value gather
    [Arguments]    ${begin_input_port}    ${end_input_port}    ${vertical_angle}    ${horizontal_angle}    ${B_value}    ${mcs_alias}
    FOR    ${A_value}    IN RANGE    ${${begin_input_port}}    ${${end_input_port}}+1
      MCS Set Phases According to Angles    vertical_angle=${vertical_angle}    horizontal_angle=${horizontal_angle}
      ...    vertical_distance=${3.2}    horizontal_distance=${0.5}    output_group_id=${B_value}    input_group_id=${A_value}
      ...    mcs_alias=${mcs_alias}
    END

MCS Set Phases According to Angles
    [Arguments]    ${vertical_angle}    ${horizontal_angle}    ${vertical_distance}    ${horizontal_distance}
    ...    ${output_group_id}    ${input_group_id}    ${mcs_alias}
    mcs.set_phases_according_to_angles    vertical_angle=${vertical_angle}    horizontal_angle=${horizontal_angle}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    ...    output_group_id=${output_group_id}    input_group_id=${input_group_id}    mcs_device=${mcs_alias}

MCS Set Odd Attenuations
    [Arguments]     ${attenuation}    ${begin_input_port}    ${end_input_port}    ${output_port}    ${mcs_alias}
    MCS.set_odd_attenuations    attenuation=${attenuation}    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    ...     output_port=${output_port}    mcs_device=${mcs_alias}

MCS Set Even Attenuations
    [Arguments]     ${attenuation}    ${begin_input_port}    ${end_input_port}    ${output_port}    ${mcs_alias}
    MCS.set_even_attenuations    attenuation=${attenuation}    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    ...     output_port=${output_port}    mcs_device=${mcs_alias}

Set TOPYOUNG ATT TO LOCK AZQO
    Set Odd ATT By Output_port    begin_output_port=5    end_output_port=8    attenuation=90    B_Odd=True
    Set Even ATT By Output_port    begin_output_port=5    end_output_port=8    attenuation=90    B_Odd=True
    Set Odd ATT By Output_port    begin_output_port=5    end_output_port=8    attenuation=90    B_Odd=False
    Set Even ATT By Output_port    begin_output_port=5    end_output_port=8    attenuation=90    B_Odd=False

Set TOPYOUNG ATT
    [Arguments]    ${att_value}
    Set Odd ATT By Output_port    begin_output_port=1    end_output_port=4    attenuation=${att_value}    B_Odd=True
    Set Even ATT By Output_port    begin_output_port=1    end_output_port=4    attenuation=90    B_Odd=True
    Set Odd ATT By Output_port    begin_output_port=1    end_output_port=4    attenuation=90    B_Odd=False
    Set Even ATT By Output_port    begin_output_port=1    end_output_port=4    attenuation=${att_value}    B_Odd=False

Set θ poll for horizontal
    [Arguments]    ${begin_θ_h}    ${end_θ_h}    ${B1_port}    ${B4_port}    ${B2_port}    ${B3_port}    ${begin_input_port}    ${end_input_port}
    ...    ${vertical_angle}    ${vertical_x}    ${csv_path}    ${mcs_alias}=TPY
    FOR    ${θ_horizontal}    IN RANGE    ${${begin_θ_h}}    ${${end_θ_h}}    5
      Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${B1_port}    end_output_port=${B4_port}
      ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}    vertical_angle=${vertical_angle}
      ...    horizontal_angle=${θ_horizontal}    mcs_alias=${mcs_alias}
      ${θ_horizontal_x}    BuiltIn.Evaluate    ${θ_horizontal}+5
      Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${B2_port}    end_output_port=${B3_port}
      ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}    vertical_angle=${vertical_angle}
      ...    horizontal_angle=${θ_horizontal_x}    mcs_alias=${mcs_alias}
      sleep    10s
      ${tput}    Power UE check throughput with nrcellid     cellid=${2}     dlexpect=${dlexpect}
      Append To List    ${list}    ${tput}
      tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=${vertical_x}    value2=${θ_horizontal}    value3=${tput}
      log    ${list}
      ${i}=    BuiltIn.Evaluate    ${i}+1
    END


Set θ poll for vertical and get UE info
    [Arguments]    ${begin_θ_v}    ${end_θ_v}    ${begin_θ_h}    ${end_θ_h}    ${B1_port}    ${B4_port}    ${B2_port}    ${B3_port}
    ...    ${begin_input_port}    ${end_input_port}    ${csv_path}
    FOR    ${θ_vertical}    IN RANGE    ${${begin_θ_v}}    ${${end_θ_v}}    5
      Set θ poll for horizontal    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    B1_port=${B1_port}    B4_port=${B4_port}
      ...    B2_port=${B2_port}    B3_port=${B3_port}    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
      ...    vertical_angle=${θ_vertical}    vertical_x=${θ_vertical}    csv_path=${csv_path}
    END

TEST with different ATTs
    [Arguments]     ${att_goodpoint}    ${att_medialpoint}    ${att_poorpoint}    ${begin_θ_v}    ${end_θ_v}    ${begin_θ_h}
    ...    ${end_θ_h}    ${B1_port}    ${B4_port}    ${B2_port}    ${B3_port}    ${begin_input_port}    ${end_input_port}
    ...    ${csv_path}
    ${list}=    create list
    set test variable    ${i}    ${1}
    set test variable    ${list}
    tput_output.create_new_file_csv    csv_file_path=${csv_path}
    FOR    ${att}    IN    ${${att_goodpoint}}    ${${att_medialpoint}}    ${${att_poorpoint}}
      Set TOPYOUNG ATT    att_value=${att}
      tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
      Set θ poll for vertical and get UE info    begin_θ_v=${begin_θ_v}    end_θ_v=${end_θ_v}    begin_θ_h=${begin_θ_h}
      ...    end_θ_h=${end_θ_h}    B1_port=${B1_port}    B4_port=${B4_port}    B2_port=${B2_port}    B3_port=${B3_port}
      ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}    csv_path=${csv_path}
    END

TEST with one ATT
    [Arguments]    ${att}     ${begin_θ_v}    ${end_θ_v}    ${begin_θ_h}    ${end_θ_h}    ${B1_port}    ${B4_port}    ${B2_port}
    ...    ${B3_port}    ${begin_input_port}    ${end_input_port}    ${csv_path}
    ${list}=    create list
    set test variable    ${i}    ${1}
    set test variable    ${list}
    tput_output.create_new_file_csv    csv_file_path=${csv_path}
    Set TOPYOUNG ATT    att_value=${att}
    Set θ poll for vertical and get UE info    begin_θ_v=${begin_θ_v}    end_θ_v=${end_θ_v}    begin_θ_h=${begin_θ_h}
    ...    end_θ_h=${end_θ_h}    B1_port=${B1_port}    B4_port=${B4_port}    B2_port=${B2_port}    B3_port=${B3_port}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}    csv_path=${csv_path}
    log    sampling points: ${list}

Caculate average tput
    [Arguments]    ${csv_path}
    ${count}    BuiltIn.Get Length    ${list}
    ${sum}     set variable    ${0}
    FOR    ${j}    IN RANGE    ${count}
      ${sum}=    BuiltIn.Evaluate    ${sum}+${list[${j}]}
    END
    ${ave}    BuiltIn.Evaluate    round(${sum}/${count},2)
    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=ave_tput    value2=is    value3=${ave}
    Log    average_tput is ${ave}
    Set test variable    ${ave_tput}    ${ave}
    [Return]    ${ave}

MCS teardown
    [Arguments]    ${mcs_alias}
    MCS.teardown    mcs_device=${mcs_alias}

