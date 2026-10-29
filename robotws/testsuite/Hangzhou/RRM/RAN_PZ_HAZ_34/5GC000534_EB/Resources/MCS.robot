*** Settings ***
Documentation     author: Wang Ming
...               contact: ming.5.wang@nokia-sbell.com
...               squad group: SG_02

Library           taf.hw.mcs    WITH NAME    mcs
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String

*** Keywords ***
MCS Setup
    [Arguments]    ${ip}    ${vendor}=HBTE    ${model}=PPSAM-64X16-2.3-3.8-90-0.5-360-1-A
    mcs.setup    ip=${ip}    vendor=${vendor}    model=${model}

MCS Teardown
    mcs.teardown

MCS Set Odd Attenuations
    [Arguments]    ${attenuation}    ${begin_input_port}    ${end_input_port}    ${output_port}
    [Documentation]    for example:
    ...    ${attenuation} =${90.0}
    ...    ${begin_input_port}=${1}
    ...    ${end_input_port}=${64}
    ...    ${output_port}=${1}
    mcs.set_odd_attenuations    attenuation=${attenuation}    begin_input_port=${begin_input_port}    
    ...    end_input_port=${end_input_port}    output_port=${output_port}

MCS Set Attenuation
    [Arguments]    ${attenuation}    ${input_port}    ${output_port}
    [Documentation]    ${attenuation}=${90.0}
    ...    ${input_port}=${2}
    ...    ${output_port}=${2}
    mcs.set_attenuation    attenuation=${attenuation}    input_port=${input_port}    output_port=${output_port}

MCS Set Even Attenuations
    [Arguments]    ${attenuation}    ${begin_input_port}    ${end_input_port}    ${output_port}
    mcs.set_even_attenuations    attenuation=${attenuation}    begin_input_port=${begin_input_port}    
    ...    end_input_port=${end_input_port}    output_port=${output_port}

MCS Set Frequency
    [Arguments]    ${frequency}
    mcs.set_frequency    frequency=${frequency}

MCS Set Phases According to Angles
    [Arguments]    ${vertical_angle}    ${horizontal_angle}    ${vertical_distance}    ${horizontal_distance}    
    ...    ${output_group_id}=${null}    ${input_group_id}=${null}
    mcs.set_phases_according_to_angles    vertical_angle=${vertical_angle}    horizontal_angle=${horizontal_angle}    
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}    
    ...    output_group_id=${output_group_id}    input_group_id=${input_group_id}

MCS Set Phase
    [Arguments]    ${phase}    ${input_port}    ${output_port}
    mcs.set_phase    phase=${phase}    input_port=${input_port}    output_port=${output_port}
