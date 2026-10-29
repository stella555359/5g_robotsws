*** Settings ***
Documentation
...    contact:jia-rebecca.liu@nokia-sbell.com


Library     OperatingSystem
Library     Collections
Library     String
Library     BuiltIn
Library     taf.hw.mcs    WITH NAME    MCS


*** Keywords ***
################################## STEP: Setup MCS ##################################
Setup MCS
    [Arguments]    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...            ${server_ip}=${tl.attenuator[${mcs_index}].ip_addr}
    ...            ${server_port}=${tl.attenuator[${mcs_index}].port}
    ...            ${vendor}=${tl.attenuator[${mcs_index}].vendor}
    ...            ${model}=${tl.attenuator[${mcs_index}].model}
    ...            &{kwargs}
    [Documentation]    MCS Prepare for HBTE
    MCS.Setup     alias=${mcs_alias}    vendor=${vendor}    model=${model}    ip=${server_ip}    server_port=${server_port}


####################### STEP:Set horizontal and vertical Phases by output_port ##################################
Set Phases According To Angles For Input And Output Groups
    [Arguments]    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_output_port}=${None}    ${end_output_port}=${None}
    ...    ${vertical_angle}=${None}    ${horizontal_angle}=${None}
    ...    ${vertical_distance}=${None}    ${horizontal_distance}=${None}    &{kwargs}
    FOR    ${B_value}    IN    ${${begin_output_port}}    ${${end_output_port}}
      hbte.Set Input Group Phases According To Angles
      ...    B_value=${B_value}    mcs_alias=${mcs_alias}
      ...    vertical_angle=${vertical_angle}    horizontal_angle=${horizontal_angle}
      ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    END


####################### STEP:Set Odd And Even ATT For Output Port ##################################
Set Odd And Even ATT For Output Port
    [Arguments]    ${att_value}    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_output_port}=${1}    ${end_output_port}=${4}
    ...    ${begin_input_port}=${1}    ${end_input_port}=${64}    &{kwargs}
    hbte.Set Odd Attenuations For Output Port    begin_output_port=${begin_output_port}    end_output_port=${end_output_port}
    ...    attenuation=${att_value}    B_Odd=True    mcs_alias=${mcs_alias}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    hbte.Set Even Attenuations For Output Port    begin_output_port=${begin_output_port}    end_output_port=${end_output_port}
    ...    attenuation=90    B_Odd=True    mcs_alias=${mcs_alias}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    hbte.Set Odd Attenuations For Output Port    begin_output_port=${begin_output_port}    end_output_port=${end_output_port}
    ...    attenuation=90    B_Odd=False    mcs_alias=${mcs_alias}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    hbte.Set Even Attenuations For Output Port    begin_output_port=${begin_output_port}    end_output_port=${end_output_port}
    ...    attenuation=${att_value}    B_Odd=False    mcs_alias=${mcs_alias}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}


####################### STEP:Set θ poll for horizontal ##################################
Set θ Poll For Horizontal Angle
    [Arguments]    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_input_port}=${None}    ${end_input_port}=${None}
    ...    ${begin_θ_h}=${None}    ${end_θ_h}=${None}
    ...    ${B1_port}=${None}    ${B4_port}=${None}    ${B2_port}=${None}    ${B3_port}=${None}
    ...    ${vertical_angle}=${None}    ${vertical_x}=${None}    &{kwargs}
    FOR    ${θ_horizontal}    IN RANGE    ${${begin_θ_h}}    ${${end_θ_h}}    5
      hbte.Set Phases According To Angles For Input And Output Groups    begin_output_port=${B1_port}    end_output_port=${B4_port}
      ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}    vertical_angle=${vertical_angle}
      ...    horizontal_angle=${θ_horizontal}    mcs_alias=${mcs_alias}
      ${θ_horizontal_x}    BuiltIn.Evaluate    ${θ_horizontal}+5
      hbte.Set Phases According To Angles For Input And Output Groups    begin_output_port=${B2_port}    end_output_port=${B3_port}
      ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}    vertical_angle=${vertical_angle}
      ...    horizontal_angle=${θ_horizontal_x}    mcs_alias=${mcs_alias}
    END

####################### STEP:Set θ Poll For Vertical Angel ##################################
Set θ Poll For Vertical Angel
    [Arguments]    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_input_port}=${None}    ${end_input_port}=${None}
    ...    ${begin_θ_h}=${None}    ${end_θ_h}=${None}
    ...    ${begin_θ_v}=${None}    ${end_θ_v}=${None}
    ...    ${B1_port}=${None}    ${B4_port}=${None}    ${B2_port}=${None}    ${B3_port}=${None}
    ...    &{kwargs}
    FOR    ${θ_vertical}    IN RANGE    ${${begin_θ_v}}    ${${end_θ_v}}    5
      hbte.Set θ Poll For Horizontal Angle    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    B1_port=${B1_port}    B4_port=${B4_port}
      ...    B2_port=${B2_port}    B3_port=${B3_port}    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
      ...    vertical_angle=${θ_vertical}    vertical_x=${θ_vertical}    mcs_alias=${mcs_alias}
    END

####################### STEP:Teardown MCS ##################################
Teardown MCS
    [Arguments]     ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    MCS.teardown    mcs_device=${mcs_alias}


####################################### Related Keywords #########################################
Set Input Group Phases According To Angles
    [Arguments]    ${vertical_angle}    ${horizontal_angle}    ${B_value}    ${mcs_alias}
    ...    ${vertical_distance}    ${horizontal_distance}
    mcs.set_phases_according_to_angles    vertical_angle=${vertical_angle}    horizontal_angle=${horizontal_angle}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    ...    output_group_id=${B_value}    mcs_device=${mcs_alias}

Set Phases According To Angles
    [Arguments]    ${vertical_angle}    ${horizontal_angle}    ${vertical_distance}    ${horizontal_distance}
    ...    ${output_group_id}    ${mcs_alias}
    MCS.set_phases_according_to_angles    vertical_angle=${vertical_angle}    horizontal_angle=${horizontal_angle}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    ...    output_group_id=${output_group_id}    mcs_device=${mcs_alias}

Set Odd Attenuations For Output Port
    [Arguments]    ${begin_output_port}    ${end_output_port}    ${attenuation}    ${B_Odd}
    ...    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_input_port}=${1}    ${end_input_port}=${64}
    FOR    ${num}    IN RANGE    ${${begin_output_port}}    ${${end_output_port}}+1
      Run keyword if    ${num}%2 and '${B_Odd}'=='True'    hbte.Set Odd Attenuations    attenuation=${${attenuation}}
      ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}    output_port=${${num}}    mcs_alias=${mcs_alias}
      Run keyword if    ${num}%2==0 and '${B_Odd}'=='False'    hbte.Set Odd Attenuations    attenuation=${${attenuation}}
      ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}    output_port=${${num}}    mcs_alias=${mcs_alias}
    END

Set Even Attenuations For Output Port
    [Arguments]    ${begin_output_port}    ${end_output_port}    ${attenuation}    ${B_Odd}
    ...    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_input_port}=${1}    ${end_input_port}=${64}
    FOR    ${num}    IN RANGE    ${${begin_output_port}}    ${${end_output_port}}+1
      Run keyword if    ${num}%2 and '${B_Odd}'=='True'    hbte.Set Even Attenuations    attenuation=${${attenuation}}
      ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}    output_port=${${num}}    mcs_alias=${mcs_alias}
      Run keyword if    ${num}%2==0 and '${B_Odd}'=='False'    hbte.Set Even Attenuations    attenuation=${${attenuation}}
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

