*** Settings ***
Documentation
...    KW for Topyoung MCS. It is a taf.hw.mcs bundler.


Library     OperatingSystem
Library     Collections
Library     String
Library     BuiltIn
Library     taf.hw.mcs    WITH NAME    MCS
Library     ps_csv.py


*** Keywords ***
Setup phase shifter
    [Arguments]    ${mcs_alias}=MCS_1
    ...            ${server_ip}=10.42.221.111
    ...            ${vendor}=TOPYOUNG
    ...            ${model}=MCS2350A2-64B16-A4
    ...            ${frequency}=3300
    ${ps_port} = 	Convert To Integer 	28888
    ${timeout} = 	Convert To Integer 	300
    [Documentation]    MCS Prepare and set frequency for Topyoung. MCS's addresses are taken from __init__ file.
    MCS.Setup     alias=${mcs_alias}    vendor=${vendor}    model=${model}    server_ip=${server_ip}    server_port=${ps_port}
    MCS.Set_frequency    frequency=${frequency}    mcs_device=${mcs_alias}   timeout=${timeout}


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

Create output channels lists
    [Arguments]   ${att}=0   ${phase}=0
    ...  ${file}=${OUTPUT DIR}/testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/phase_shifter/7477_controller.csv
    ${att}   ps_csv.Get Att Output Channel  ${file}
    ${phase}   ps_csv.Get Phase Output Channel  ${file}
    FOR   ${i}   IN RANGE  0  16
        Log to console  ${i}
        Set suite variable   ${att_B${i}}   ${att}[${i}]
        Set suite variable   ${phase_B${i}}   ${phase}[${i}]
    END


Update attenuations
    [Arguments]   ${mcs_alias}=MCS_1  ${length}=0
    FOR   ${i}   IN RANGE  0   ${length}
        MCS.set attenuation   ${att_B0}[${i}]   ${i+1}    ${1}   ${mcs_alias}
        MCS.set attenuation   ${att_B1}[${i}]   ${i+1}    ${2}   ${mcs_alias}
        MCS.set attenuation   ${att_B2}[${i}]   ${i+1}    ${3}   ${mcs_alias}
        MCS.set attenuation   ${att_B3}[${i}]   ${i+1}    ${4}   ${mcs_alias}
        MCS.set attenuation   ${att_B4}[${i}]   ${i+1}    ${5}   ${mcs_alias}
        MCS.set attenuation   ${att_B5}[${i}]   ${i+1}    ${6}   ${mcs_alias}
        MCS.set attenuation   ${att_B6}[${i}]   ${i+1}    ${7}   ${mcs_alias}
        MCS.set attenuation   ${att_B7}[${i}]   ${i+1}    ${8}   ${mcs_alias}
        MCS.set attenuation   ${att_B8}[${i}]   ${i+1}    ${9}   ${mcs_alias}
        MCS.set attenuation   ${att_B9}[${i}]   ${i+1}    ${10}   ${mcs_alias}
        MCS.set attenuation   ${att_B10}[${i}]   ${i+1}    ${11}   ${mcs_alias}
        MCS.set attenuation   ${att_B11}[${i}]   ${i+1}    ${12}   ${mcs_alias}
        MCS.set attenuation   ${att_B12}[${i}]   ${i+1}    ${13}   ${mcs_alias}
        MCS.set attenuation   ${att_B13}[${i}]   ${i+1}    ${14}   ${mcs_alias}
        MCS.set attenuation   ${att_B14}[${i}]   ${i+1}    ${15}   ${mcs_alias}
        MCS.set attenuation   ${att_B15}[${i}]   ${i+1}    ${16}   ${mcs_alias}
    END

Update phases
    [Arguments]   ${mcs_alias}=MCS_1  ${length}=0
    FOR   ${i}   IN RANGE   0  ${length}
        MCS.set phase   ${phase_B0}[${i}]   ${i+1}    ${1}   ${mcs_alias}
        MCS.set phase   ${phase_B1}[${i}]   ${i+1}    ${2}   ${mcs_alias}
        MCS.set phase   ${phase_B2}[${i}]   ${i+1}    ${3}   ${mcs_alias}
        MCS.set phase   ${phase_B3}[${i}]   ${i+1}    ${4}   ${mcs_alias}
        MCS.set phase   ${phase_B4}[${i}]   ${i+1}    ${5}   ${mcs_alias}
        MCS.set phase   ${phase_B5}[${i}]   ${i+1}    ${6}   ${mcs_alias}
        MCS.set phase   ${phase_B6}[${i}]   ${i+1}    ${7}   ${mcs_alias}
        MCS.set phase   ${phase_B7}[${i}]   ${i+1}    ${8}   ${mcs_alias}
        MCS.set phase   ${phase_B8}[${i}]   ${i+1}    ${9}   ${mcs_alias}
        MCS.set phase   ${phase_B9}[${i}]   ${i+1}    ${10}   ${mcs_alias}
        MCS.set phase   ${phase_B10}[${i}]   ${i+1}    ${11}   ${mcs_alias}
        MCS.set phase   ${phase_B11}[${i}]   ${i+1}    ${12}   ${mcs_alias}
        MCS.set phase   ${phase_B12}[${i}]   ${i+1}    ${13}   ${mcs_alias}
        MCS.set phase   ${phase_B13}[${i}]   ${i+1}    ${14}   ${mcs_alias}
        MCS.set phase   ${phase_B14}[${i}]   ${i+1}    ${15}   ${mcs_alias}
        MCS.set phase   ${phase_B15}[${i}]   ${i+1}    ${16}   ${mcs_alias}
    END


Teardown MCS
    [Arguments]     ${mcs_alias}=MCS_1
    MCS.teardown    mcs_device=${mcs_alias}
