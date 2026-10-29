*** Settings ***
Documentation
...    author: yuegong
...    contact: yue.1.gong@nokia-sbell.com
...    squad group: SG_03

Library      taf.hw.rf_attenuator    WITH NAME    att
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/mcs_common.robot

*** Variables ***
${att_ipaddr}      ${tl.attenuator[0].ip_addr}
${att_ipaddr_1}    ${tl.attenuator[1].ip_addr}
${att_connection_port}       ${tl.attenuator[0].attenuator_ports[5]}
${att_api_port}              ${tl.attenuator[0].port}
${vendor}                    ${tl.attenuator[0].vendor}
${model}                     ${tl.attenuator[0].model}
${max_attenuation_value}     ${127}
${max_attenuation_value_topyoung}     ${120}

*** Keywords ***
Set the attenuation value
    [Arguments]    ${att_ports}    ${values}    ${att_connection_port}=${att_connection_port}    ${att_ipaddr}=${att_ipaddr}
    ...    ${max_attenuation_value}=${127}    ${model}=${model}    ${att_api_port}=${att_api_port}    ${vendor}=${vendor}
    [Documentation]    This keyword is to set the test environment PA values, HBTE and topyoung.
    ...    ${att_port}:List all the attenuator ports as int list
    ...    ${value}:List the value of attenuator ports  int list
    ...    ${att_connection_port}:if PA is HBTE, the port is any one port.
    ...                           if PA is topyoung, the port is a List all the attenuator ports as int list
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    ${Num_att_port}=    get length    ${att_ports}
    FOR    ${Num}    IN RANGE    ${0}    ${Num_att_port}
        att.set_attenuation     port=${att_ports[${Num}]}    value=${values[${Num}]}
        sleep    1s
        ${value_port}    att.read_attenuation    port=${att_ports[${Num}]}
        ${value_port}=    Convert To Integer    ${value_port}
        should be equal    ${value_port}    ${values[${Num}]}
    END

Set the attenuation value of ports simultaneously
    [Arguments]    ${att_ports}    ${values}    ${att_connection_port}=${att_connection_port}    ${att_ipaddr}=${att_ipaddr}
    ...    ${max_attenuation_value}=${127}    ${model}=${model}    ${att_api_port}=${att_api_port}    ${vendor}=${vendor}
    [Documentation]    ming.shi@nokia-sbell.com
    ...    This keyword is to set the test environment PA values, HBTE and topyoung.
    ...    ${att_ports}:List all the attenuator ports as int list (list[int])
    ...    ${value}:List the value of attenuator ports  int list  (list[Union[str,int,float]])
    ...    ${att_connection_port}:if PA is HBTE, the port is any one port.
    ...                           if PA is topyoung, the port is a List all the attenuator ports as int list
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    att.set_ports_attenuation    ports=${att_ports}    values=${values}
    ${ports_values}=    att.read_ports_attenuation    ports=${att_ports}
    Lists Should Be Equal    list1=${values}    list2=${ports_values}    msg=Inconsistencies before and after modification


Set the attenuation value topyoung
    [Arguments]    ${att_ports}    ${values}    ${att_ipaddr}=${att_ipaddr}    ${att_api_port}=${att_api_port}
    ...    ${model}=${model}
    [Documentation]    This keyword is to set the test environment PA values.
    ...    ${att_port}:List all the attenuator ports as int list
    ...    ${value}:List the value of attenuator ports  int list
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_ports}    max_attenuation=${max_attenuation_value_topyoung}    vendor=${vendor}
    ...    model=${model}
    ${Num_att_port}=    get length    ${att_ports}
    FOR    ${Num}    IN RANGE    ${0}    ${Num_att_port}
        att.set_attenuation     port=${att_ports[${Num}]}    value=${values[${Num}]}
        sleep    1s
        ${value_port}    att.read_attenuation    port=${att_ports[${Num}]}
        ${value_port}=    Convert To Integer    ${value_port}
        should be equal    ${value_port}    ${values[${Num}]}
    END

Adjust attenuation value via steps
    [Arguments]    ${att_ports}    ${origin_value}    ${target_value}    ${step}=${2}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    ${Num_att_port}=    get length    ${att_ports}
    FOR    ${Num}    IN RANGE    ${0}    ${Num_att_port}
        att.set_attenuation     port=${att_ports[${Num}]}    value=${origin_value}
        sleep    1s
        ${value_port}    att.read_attenuation    port=${att_ports[${Num}]}
        ${value_port}=    Convert To Integer    ${value_port}
        should be equal    ${value_port}    ${origin_value}
    END
    ${target_value}=    evaluate     ${target_value} + ${step}
    FOR    ${step_value}    IN RANGE    ${origin_value}    ${target_value}    ${step}
        Change the att_port via steps    step_value=${step_value}    att_ports=${att_ports}
    END

Change the att_port via steps
    [Arguments]    ${step_value}    ${att_ports}
    ${Num_att_port}=    get length    ${att_ports}
    FOR    ${Num}    IN RANGE    ${0}    ${Num_att_port}
            att.set_attenuation     port=${att_ports[${Num}]}    value=${step_value}
            sleep    1s
            ${value_port}    att.read_attenuation    port=${att_ports[${Num}]}
            ${value_port}=    Convert To Integer    ${value_port}
            should be equal    ${value_port}    ${step_value}
    END


###### MCS Keyword #######
HAOJIN MCS change UE Phases
    [Arguments]     ${mcs_type}
    ...    ${begin_output_port_1}    ${end_output_port_2}    ${vertical_angle_1}     ${horizontal_angle_1}
    ...    ${begin_output_port_3}    ${end_output_port_4}    ${vertical_angle_2}     ${horizontal_angle_2}
    ...    ${vertical_distance}=${2.0}    ${horizontal_distance}=${0.5}    ${input_group_id}=${0}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...    begin_output_port=${begin_output_port_1}    end_output_port=${end_output_port_2}     input_group_id=${input_group_id}
    ...    vertical_angle=${vertical_angle_1}    horizontal_angle=${horizontal_angle_1}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...    begin_output_port=${begin_output_port_3}    end_output_port=${end_output_port_4}     input_group_id=${input_group_id}
    ...    vertical_angle=${vertical_angle_2}    horizontal_angle=${horizontal_angle_2}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}

HAOJIN MCS SET Range Output ATT
    [Arguments]    ${mcs_type}    ${att_value}     ${begin_out}    ${end_out}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value}
    ...    begin_output_port=${begin_out}    end_output_port=${end_out}

HAOJIN MCS SET Four Output ATT
    [Arguments]    ${mcs_type}    ${att_value_1}    ${att_value_2}
    ...    ${P1_out}    ${P2_out}    ${P3_out}    ${P4_out}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_1}
    ...    begin_output_port=${P1_out}    end_output_port=${P2_out}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_2}
    ...    begin_output_port=${P3_out}    end_output_port=${P4_out}

HAOJIN MCS SETUP AND SET ATT for ONE UE
    [Arguments]    ${mcs_type}        ${att_value_1}    ${att_value_2}
    ...    ${P1_out}    ${P2_out}    ${vertical_1}    ${horizontal_1}
    ...    ${P3_out}    ${P4_out}    ${vertical_2}    ${horizontal_2}
    ...    ${vertical_distance}=${0.5}    ${horizontal_distance}=${2.1}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    vendor=HAOJIN
    HAOJIN MCS change UE Phases    mcs_type=${mcs_type}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    ...    begin_output_port_1=${P1_out}    end_output_port_2=${P2_out}    vertical_angle_1=${vertical_1}    horizontal_angle_1=${horizontal_1}
    ...    begin_output_port_3=${P3_out}    end_output_port_4=${P4_out}    vertical_angle_2=${vertical_2}    horizontal_angle_2=${horizontal_2}
    Log to console    /n*** set all port at_value to 90 ***/n
    HAOJIN MCS SET Range Output ATT    mcs_type=${mcs_type}    att_value=90    begin_out=1    end_out=16
    Log to console    /n*** set AT_value for used port ***/n
    HAOJIN MCS SET Four Output ATT    mcs_type=${mcs_type}    att_value_1=${att_value_1}    att_value_2=${att_value_2}
    ...    P1_out=${P1_out}    P2_out=${P2_out}    P3_out=${P3_out}    P4_out=${P4_out}
    HAOJIN MCS SET Range Output ATT    mcs_type=${mcs_type}    att_value=90    begin_out=1    end_out=12



HAOJIN MCS SETUP AND SET ATT for Two UEs
    [Arguments]    ${mcs_type}    ${att_value_UE0}    ${att_value_UE1}
    ...    ${P1_out}    ${P2_out}    ${P3_out}    ${P4_out}    ${vertical_1}    ${horizontal_1}    ${horizontal_2}    ${vertical_2}
    ...    ${P5_out}    ${P6_out}    ${P7_out}    ${P8_out}    ${vertical_3}    ${horizontal_3}    ${horizontal_4}    ${vertical_4}
    ...    ${begin_output_port_UE1}=${13}    ${end_output_port_UE1}=${16}
    ...    ${begin_output_port_UE2}=${9}     ${end_output_port_UE2}=${12}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    vendor=HAOJIN
    HAOJIN MCS change UE Phases    mcs_type=${mcs_type}
    ...    begin_output_port_1=${P1_out}    end_output_port_2=${P2_out}    vertical_angle_1=${vertical_1}    horizontal_angle_1=${horizontal_1}
    ...    begin_output_port_3=${P3_out}    end_output_port_4=${P4_out}    vertical_angle_2=${vertical_2}    horizontal_angle_2=${horizontal_2}
    HAOJIN MCS change UE Phases    mcs_type=${mcs_type}
    ...    begin_output_port_1=${P5_out}    end_output_port_2=${P6_out}    vertical_angle_1=${vertical_3}    horizontal_angle_1=${horizontal_3}
    ...    begin_output_port_3=${P7_out}    end_output_port_4=${P8_out}    vertical_angle_2=${vertical_4}    horizontal_angle_2=${horizontal_4}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_UE0}
    ...    begin_output_port=${begin_output_port_UE1}    end_output_port=${end_output_port_UE1}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_UE1}
    ...    begin_output_port=${begin_output_port_UE2}    end_output_port=${end_output_port_UE2}
    HAOJIN MCS SET Range Output ATT    mcs_type=${mcs_type}    att_value=90    begin_out=1    end_out=8

HAOJIN MCS SETUP AND SET ATT for Two UEs with different ATT
    [Arguments]    ${mcs_type}    ${att_value_UE0_1}    ${att_value_UE0_2}    ${att_value_UE1_1}    ${att_value_UE1_2}
    ...    ${P1_out}    ${P2_out}    ${P3_out}    ${P4_out}    ${vertical_1}    ${horizontal_1}    ${horizontal_2}    ${vertical_2}
    ...    ${P5_out}    ${P6_out}    ${P7_out}    ${P8_out}    ${vertical_3}    ${horizontal_3}    ${horizontal_4}    ${vertical_4}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    vendor=HAOJIN
    HAOJIN MCS change UE Phases    mcs_type=${mcs_type}
    ...    begin_output_port_1=${P1_out}    end_output_port_2=${P2_out}    vertical_angle_1=${vertical_1}    horizontal_angle_1=${horizontal_1}
    ...    begin_output_port_3=${P3_out}    end_output_port_4=${P4_out}    vertical_angle_2=${vertical_2}    horizontal_angle_2=${horizontal_2}
    HAOJIN MCS change UE Phases    mcs_type=${mcs_type}
    ...    begin_output_port_1=${P5_out}    end_output_port_2=${P6_out}    vertical_angle_1=${vertical_3}    horizontal_angle_1=${horizontal_3}
    ...    begin_output_port_3=${P7_out}    end_output_port_4=${P8_out}    vertical_angle_2=${vertical_4}    horizontal_angle_2=${horizontal_4}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_UE0_1}
    ...    begin_output_port=${P1_out}    end_output_port=${P2_out}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_UE0_2}
    ...    begin_output_port=${P3_out}    end_output_port=${P4_out}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_UE1_1}
    ...    begin_output_port=${P5_out}    end_output_port=${P6_out}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_UE1_2}
    ...    begin_output_port=${P7_out}    end_output_port=${P8_out}
    HAOJIN MCS SET Range Output ATT    mcs_type=${mcs_type}    att_value=90    begin_out=1    end_out=8

TOPYOUNG MCS SETUP Phases AND SET ATT
    [Arguments]    ${mcs_type}    ${att_value1}    ${att_value2}    ${vertical_angle}
    ...    ${first_beam_begin_output_port}     ${first_beam_end_output_port}     ${first_beam_horizontal_angle}
    ...    ${second_beam_begin_output_port}    ${second_beam_end_output_port}    ${second_beam_horizontal_angle}
    ...    ${vertical_distance}=${3.2}    ${horizontal_distance}=${0.5}    ${begin_input_port}=${1}    ${end_input_port}=${16}
    ...    ${frequency}=3500_1_ALL
    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=${frequency}
    TOPYOUNG MCS change UE Phases    mcs_type=${mcs_type}    vertical_angle=${vertical_angle}
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}      first_beam_end_output_port=${first_beam_end_output_port}
    ...    first_beam_horizontal_angle=${first_beam_horizontal_angle}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ...    second_beam_horizontal_angle=${second_beam_horizontal_angle}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    ...    begin_input_port=${begin_input_port}      end_input_port=${end_input_port}
    TOPYOUN SET Four Output Ports With Different Values    mcs_type=${mcs_type}    att_value1=${att_value1}    att_value2=${att_value2}
    ...     first_beam_begin_output_port=${first_beam_begin_output_port}      first_beam_end_output_port=${first_beam_end_output_port}
    ...     second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}


TOPYOUNG MCS change UE Phases
    [Arguments]    ${mcs_type}
    ...    ${first_beam_begin_output_port}     ${first_beam_end_output_port}     ${first_beam_horizontal_angle}     ${vertical_angle}
    ...    ${second_beam_begin_output_port}    ${second_beam_end_output_port}    ${second_beam_horizontal_angle}
    ...    ${vertical_distance}=${3.2}    ${horizontal_distance}=${0.5}    ${begin_input_port}=${1}    ${end_input_port}=${16}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...    begin_output_port=${first_beam_begin_output_port}     end_output_port=${first_beam_end_output_port}
    ...    begin_input_port=${begin_input_port}                  end_input_port=${end_input_port}
    ...    vertical_angle=${vertical_angle}                      horizontal_angle=${first_beam_horizontal_angle}
    ...    vertical_distance=${vertical_distance}                horizontal_distance=${horizontal_distance}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...    begin_output_port=${second_beam_begin_output_port}    end_output_port=${second_beam_end_output_port}
    ...    begin_input_port=${begin_input_port}                  end_input_port=${end_input_port}
    ...    vertical_angle=${vertical_angle}                      horizontal_angle=${second_beam_horizontal_angle}
    ...    vertical_distance=${vertical_distance}                horizontal_distance=${horizontal_distance}

TOPYOUN SET Four Output Ports With Different Values
    [Arguments]    ${mcs_type}    ${att_value1}    ${att_value2}
    ...     ${first_beam_begin_output_port}     ${first_beam_end_output_port}
    ...     ${second_beam_begin_output_port}    ${second_beam_end_output_port}
    ...     ${begin_input_port}=${1}    ${end_input_port}=${64}
    mcs_common.Set Odd And Even ATT For Output Port     mcs_type=${mcs_type}    att_value=${att_value1}
    ...    begin_output_port=${first_beam_begin_output_port}    end_output_port=${first_beam_end_output_port}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    mcs_common.Set Odd And Even ATT For Output Port     mcs_type=${mcs_type}    att_value=${att_value2}
    ...    begin_output_port=${second_beam_begin_output_port}    end_output_port=${second_beam_end_output_port}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}

TOPYOUNG MCS SETUP AND SET ATT for Two UEs with different ATT
    [Arguments]    ${mcs_type}    ${att_value_UE0}    ${att_value_UE1}
    ...    ${vertical_1}    ${horizontal_1}    ${horizontal_2}    ${vertical_2}
    ...    ${vertical_3}    ${horizontal_3}    ${horizontal_4}    ${vertical_4}
    ...    ${P1_out}=${5}    ${P2_out}=${6}    ${P3_out}=${7}    ${P4_out}=${8}
    ...    ${P5_out}=${13}    ${P6_out}=${14}    ${P7_out}=${15}    ${P8_out}=${16}
    ...    ${begin_output_port_UE1}=${5}    ${end_output_port_UE1}=${8}
    ...    ${begin_output_port_UE2}=${13}    ${end_output_port_UE2}=${16}
    ...    ${vertical_distance}=${2.1}    ${horizontal_distance}=${0.5}    ${begin_input_port}=${1}    ${end_input_port}=${64}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...    begin_output_port=${P1_out}     end_output_port=${P2_out}
    ...    vertical_angle=${vertical_1}    horizontal_angle=${horizontal_1}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...    begin_output_port=${P3_out}     end_output_port=${P4_out}
    ...    vertical_angle=${vertical_2}    horizontal_angle=${horizontal_2}
    ...    vertical_distance=${vertical_distance}                horizontal_distance=${horizontal_distance}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...    begin_output_port=${P5_out}     end_output_port=${P6_out}
    ...    vertical_angle=${vertical_3}    horizontal_angle=${horizontal_3}
    ...    vertical_distance=${vertical_distance}                horizontal_distance=${horizontal_distance}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...    begin_output_port=${P7_out}     end_output_port=${P8_out}
    ...    vertical_angle=${vertical_4}    horizontal_angle=${horizontal_4}
    ...    vertical_distance=${vertical_distance}                horizontal_distance=${horizontal_distance}
    TOPYOUN SET Four Output Ports With Different Values    mcs_type=${mcs_type}    att_value1=${att_value_UE0}    att_value2=${att_value_UE1}
    ...     first_beam_begin_output_port=${begin_output_port_UE1}      first_beam_end_output_port=${end_output_port_UE1}
    ...     second_beam_begin_output_port=${begin_output_port_UE2}    second_beam_end_output_port=${end_output_port_UE2}

HBTE MCS SETUP Phases AND SET ATT
    [Arguments]    ${mcs_type}    ${att_value1}    ${att_value2}    ${vertical_angle}
    ...    ${first_beam_begin_output_port}     ${first_beam_end_output_port}     ${first_beam_horizontal_angle}
    ...    ${second_beam_begin_output_port}    ${second_beam_end_output_port}    ${second_beam_horizontal_angle}
    ...    ${vertical_distance}=${2.0}    ${horizontal_distance}=${0.5}
    ...    ${begin_output_port}=${1}           ${end_output_port}=${16}
    mcs_common.Setup MCS    mcs_type=${mcs_type}
    HBTE MCS change UE Phases    mcs_type=${mcs_type}    vertical_angle=${vertical_angle}
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}      first_beam_end_output_port=${first_beam_end_output_port}
    ...    first_beam_horizontal_angle=${first_beam_horizontal_angle}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ...    second_beam_horizontal_angle=${second_beam_horizontal_angle}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    HBTE SET Four Output Ports With Different Values    mcs_type=${mcs_type}    att_value1=${att_value1}    att_value2=${att_value2}
    ...     first_beam_begin_output_port=${first_beam_begin_output_port}      first_beam_end_output_port=${first_beam_end_output_port}
    ...     second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ...     begin_output_port=${begin_output_port}    end_output_port=${end_output_port}

HBTE MCS change UE Phases
    [Arguments]    ${mcs_type}
    ...    ${first_beam_begin_output_port}     ${first_beam_end_output_port}     ${first_beam_horizontal_angle}     ${vertical_angle}
    ...    ${second_beam_begin_output_port}    ${second_beam_end_output_port}    ${second_beam_horizontal_angle}
    ...    ${vertical_distance}=${3.36}    ${horizontal_distance}=${0.42}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...    begin_output_port=${first_beam_begin_output_port}     end_output_port=${first_beam_end_output_port}
    ...    vertical_angle=${vertical_angle}                      horizontal_angle=${first_beam_horizontal_angle}
    ...    vertical_distance=${vertical_distance}                horizontal_distance=${horizontal_distance}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...    begin_output_port=${second_beam_begin_output_port}    end_output_port=${second_beam_end_output_port}
    ...    vertical_angle=${vertical_angle}                      horizontal_angle=${second_beam_horizontal_angle}
    ...    vertical_distance=${vertical_distance}                horizontal_distance=${horizontal_distance}

HBTE SET Four Output Ports With Different Values
    [Arguments]    ${mcs_type}    ${att_value1}    ${att_value2}
    ...     ${first_beam_begin_output_port}     ${first_beam_end_output_port}
    ...     ${second_beam_begin_output_port}    ${second_beam_end_output_port}
    ...     ${begin_output_port}=${1}           ${end_output_port}=${16}    ${is_need_recover}=True
    Log to console    /n*** set all port at_value to 90 ***/n
    Run keyword if    ${is_need_recover}    mcs_common.Set Odd And Even ATT For Output Port     mcs_type=${mcs_type}    att_value=${90}
    ...    begin_output_port=${begin_output_port}    end_output_port=${end_output_port}
    Log to console    /n*** set AT_value for used port ***/n
    mcs_common.Set Odd And Even ATT For Output Port     mcs_type=${mcs_type}    att_value=${att_value1}
    ...    begin_output_port=${first_beam_begin_output_port}    end_output_port=${first_beam_end_output_port}
    mcs_common.Set Odd And Even ATT For Output Port     mcs_type=${mcs_type}    att_value=${att_value2}
    ...    begin_output_port=${second_beam_begin_output_port}    end_output_port=${second_beam_end_output_port}

HBTE MCS SETUP Phases AND SET ATT for multiUES
    [Arguments]    ${mcs_type}    ${att_value1}    ${att_value2}    ${att_value3}    ${att_value4}
    ...    ${first_beam_begin_output_port}     ${first_beam_end_output_port}     ${first_beam_horizontal_angle}
    ...    ${second_beam_begin_output_port}    ${second_beam_end_output_port}    ${second_beam_horizontal_angle}
    ...    ${third_beam_begin_output_port}     ${third_beam_end_output_port}     ${third_beam_horizontal_angle}
    ...    ${fourth_beam_begin_output_port}    ${fourth_beam_end_output_port}    ${fourth_beam_horizontal_angle}
    ...    ${vertical_angle_1}=${96}     ${vertical_angle_2}=${96}
    ...    ${vertical_distance}=${2.0}    ${horizontal_distance}=${0.5}
    ...    ${begin_output_port}=${1}           ${end_output_port}=${16}    ${is_need_recover}=False
    mcs_common.Setup MCS    mcs_type=${mcs_type}
    HBTE MCS change UE Phases    mcs_type=${mcs_type}    vertical_angle=${vertical_angle_1}
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}      first_beam_end_output_port=${first_beam_end_output_port}
    ...    first_beam_horizontal_angle=${first_beam_horizontal_angle}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ...    second_beam_horizontal_angle=${second_beam_horizontal_angle}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    HBTE MCS change UE Phases    mcs_type=${mcs_type}    vertical_angle=${vertical_angle_2}
    ...    first_beam_begin_output_port=${third_beam_begin_output_port}      first_beam_end_output_port=${third_beam_end_output_port}
    ...    first_beam_horizontal_angle=${third_beam_horizontal_angle}
    ...    second_beam_begin_output_port=${fourth_beam_begin_output_port}    second_beam_end_output_port=${fourth_beam_end_output_port}
    ...    second_beam_horizontal_angle=${fourth_beam_horizontal_angle}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    HBTE SET Four Output Ports With Different Values    mcs_type=${mcs_type}    att_value1=${att_value1}    att_value2=${att_value2}
    ...     first_beam_begin_output_port=${first_beam_begin_output_port}      first_beam_end_output_port=${first_beam_end_output_port}
    ...     second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ...     begin_output_port=${begin_output_port}    end_output_port=${end_output_port}
    ...     is_need_recover=${is_need_recover}
    HBTE SET Four Output Ports With Different Values    mcs_type=${mcs_type}    att_value1=${att_value3}    att_value2=${att_value4}
    ...     first_beam_begin_output_port=${third_beam_begin_output_port}      first_beam_end_output_port=${third_beam_end_output_port}
    ...     second_beam_begin_output_port=${fourth_beam_begin_output_port}    second_beam_end_output_port=${fourth_beam_end_output_port}
    ...     begin_output_port=${begin_output_port}    end_output_port=${end_output_port}    is_need_recover=${is_need_recover}

MCS Teardown with mcs_type
    [Arguments]    ${mcs_type}
    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}
