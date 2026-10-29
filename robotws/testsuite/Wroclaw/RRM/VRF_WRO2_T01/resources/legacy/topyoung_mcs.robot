*** Settings ***
Documentation
...    KW for Topyoung MCS. It is a taf.hw.mcs bundler.


Library     OperatingSystem
Library     Collections
Library     String
Library     BuiltIn
Library     taf.hw.mcs    WITH NAME    MCS


*** Keywords ***
Setup MCS
    [Arguments]    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...            ${server_ip}=${tl.attenuator[${mcs_index}].ip_addr}
    ...            ${server_port}=${tl.attenuator[${mcs_index}].port}
    ...            ${vendor}=${tl.attenuator[${mcs_index}].vendor}
    ...            ${model}=${tl.attenuator[${mcs_index}].model}
    [Documentation]    MCS Prepare and set frequency for Topyoung. MCS's addresses are taken from __init__ file.
    MCS.Setup     alias=${mcs_alias}    vendor=${vendor}    model=${model}    server_ip=${server_ip}    server_port=${server_port}


Set Phases According To Angles For Input And Output Groups
    [Arguments]    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_output_port}=${None}    ${end_output_port}=${None}
    ...    ${begin_input_port}=${None}    ${end_input_port}=${None}
    ...    ${vertical_angle}=${None}    ${horizontal_angle}=${None}
    ...    ${vertical_distance}=${None}    ${horizontal_distance}=${None}
    FOR    ${B_value}    IN    ${${begin_output_port}}    ${${end_output_port}}
      topyoung.Set Input Group Phases According To Angles    begin_input_port=${begin_input_port}
      ...    end_input_port=${end_input_port}    vertical_angle=${vertical_angle}
      ...    horizontal_angle=${horizontal_angle}    B_value=${B_value}    mcs_alias=${mcs_alias}
      ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    END



Set Odd And Even ATT For Output Port
    [Arguments]    ${att_value}    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_output_port}=${1}    ${end_output_port}=${4}
    ...    ${begin_input_port}=${1}    ${end_input_port}=${64}    &{kwargs}
    topyoung.Set Odd Attenuations For Output Port    begin_output_port=${begin_output_port}    end_output_port=${end_output_port}
    ...    attenuation=${att_value}    B_Odd=True    mcs_alias=${mcs_alias}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    topyoung.Set Even Attenuations For Output Port    begin_output_port=${begin_output_port}    end_output_port=${end_output_port}
    ...    attenuation=90    B_Odd=True    mcs_alias=${mcs_alias}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    topyoung.Set Odd Attenuations For Output Port    begin_output_port=${begin_output_port}    end_output_port=${end_output_port}
    ...    attenuation=90    B_Odd=False    mcs_alias=${mcs_alias}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    topyoung.Set Even Attenuations For Output Port    begin_output_port=${begin_output_port}    end_output_port=${end_output_port}
    ...    attenuation=${att_value}    B_Odd=False    mcs_alias=${mcs_alias}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}



Set θ Poll For Horizontal Angle
    [Arguments]    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_input_port}=${None}    ${end_input_port}=${None}
    ...    ${begin_θ_h}=${None}    ${end_θ_h}=${None}
    ...    ${B1_port}=${None}    ${B4_port}=${None}    ${B2_port}=${None}    ${B3_port}=${None}
    ...    ${vertical_angle}=${None}
    FOR    ${θ_horizontal}    IN RANGE    ${${begin_θ_h}}    ${${end_θ_h}}    5
      topyoung.Set Phases According To Angles For Input And Output Groups    begin_output_port=${B1_port}    end_output_port=${B4_port}
      ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}    vertical_angle=${vertical_angle}
      ...    horizontal_angle=${θ_horizontal}    mcs_alias=${mcs_alias}
      ${θ_horizontal_x}    BuiltIn.Evaluate    ${θ_horizontal}+5
      topyoung.Set Phases According To Angles For Input And Output Groups    begin_output_port=${B2_port}    end_output_port=${B3_port}
      ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}    vertical_angle=${vertical_angle}
      ...    horizontal_angle=${θ_horizontal_x}    mcs_alias=${mcs_alias}
    END


Set θ Poll For Vertical Angel
    [Arguments]    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_input_port}=${None}    ${end_input_port}=${None}
    ...    ${begin_θ_h}=${None}    ${end_θ_h}=${None}
    ...    ${begin_θ_v}=${None}    ${end_θ_v}=${None}
    ...    ${B1_port}=${None}    ${B4_port}=${None}    ${B2_port}=${None}    ${B3_port}=${None}
    FOR    ${θ_vertical}    IN RANGE    ${${begin_θ_v}}    ${${end_θ_v}}    5
      topyoung.Set θ Poll For Horizontal Angle    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    B1_port=${B1_port}    B4_port=${B4_port}
      ...    B2_port=${B2_port}    B3_port=${B3_port}    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
      ...    vertical_angle=${θ_vertical}    vertical_x=${θ_vertical}    mcs_alias=${mcs_alias}
    END


Teardown MCS
    [Arguments]     ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    MCS.teardown    mcs_device=${mcs_alias}

######

Set Input Group Phases According To Angles
    [Arguments]    ${begin_input_port}    ${end_input_port}    ${vertical_angle}    ${horizontal_angle}
    ...    ${B_value}    ${mcs_alias}    ${vertical_distance}    ${horizontal_distance}
    FOR    ${A_value}    IN RANGE    ${${begin_input_port}}    ${${end_input_port}}+1
      topyoung.Set Phases According To Angles    vertical_angle=${vertical_angle}    horizontal_angle=${horizontal_angle}
      ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}    output_group_id=${B_value}
      ...    input_group_id=${A_value}    mcs_alias=${mcs_alias}
    END

Set Phases According To Angles
    [Arguments]    ${vertical_angle}    ${horizontal_angle}    ${vertical_distance}    ${horizontal_distance}
    ...    ${output_group_id}    ${input_group_id}    ${mcs_alias}
    MCS.set_phases_according_to_angles    vertical_angle=${vertical_angle}    horizontal_angle=${horizontal_angle}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    ...    output_group_id=${output_group_id}    input_group_id=${input_group_id}    mcs_device=${mcs_alias}

Set Odd Attenuations For Output Port
    [Arguments]    ${begin_output_port}    ${end_output_port}    ${attenuation}    ${B_Odd}
    ...    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_input_port}=${1}    ${end_input_port}=${64}
    FOR    ${num}    IN RANGE    ${${begin_output_port}}    ${${end_output_port}}+1
      Run keyword if    ${num}%2 and '${B_Odd}'=='True'    topyoung.Set Odd Attenuations    attenuation=${${attenuation}}
      ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}    output_port=${${num}}    mcs_alias=${mcs_alias}
      Run keyword if    ${num}%2==0 and '${B_Odd}'=='False'    topyoung.Set Odd Attenuations    attenuation=${${attenuation}}
      ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}    output_port=${${num}}    mcs_alias=${mcs_alias}
    END

Set Even Attenuations For Output Port
    [Arguments]    ${begin_output_port}    ${end_output_port}    ${attenuation}    ${B_Odd}
    ...    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_input_port}=${1}    ${end_input_port}=${64}
    FOR    ${num}    IN RANGE    ${${begin_output_port}}    ${${end_output_port}}+1
      Run keyword if    ${num}%2 and '${B_Odd}'=='True'    topyoung.Set Even Attenuations    attenuation=${${attenuation}}
      ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}    output_port=${${num}}    mcs_alias=${mcs_alias}
      Run keyword if    ${num}%2==0 and '${B_Odd}'=='False'    topyoung.Set Even Attenuations    attenuation=${${attenuation}}
      ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}    output_port=${${num}}    mcs_alias=${mcs_alias}
    END

Set Odd Attenuations
    [Arguments]     ${attenuation}    ${begin_input_port}    ${end_input_port}    ${output_port}
    ...              ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    MCS.set_odd_attenuations    attenuation=${attenuation}    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    ...     output_port=${output_port}    mcs_device=${mcs_alias}

Set Even Attenuations
    [Arguments]     ${attenuation}    ${begin_input_port}    ${end_input_port}    ${output_port}
    ...    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    MCS.set_even_attenuations    attenuation=${attenuation}    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    ...     output_port=${output_port}    mcs_device=${mcs_alias}
