*** Settings ***
Documentation
...    VRF HAZ 1 Common Resources.




*** Keywords ***
Restart BTS By PowerBreak
    ${gnb_pdu_ip}=    set variable    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    ${gnb_pdu_port}=    set variable    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    ${gnb_pdu_type}=    set variable    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
    pdu.setup_pdu    model=${gnb_pdu_type}    host=${gnb_pdu_ip}    alias=gnb_pdu
    pdu.power_off    port=${gnb_pdu_port}    pdu_device=gnb_pdu
    Sleep    5s
    pdu.power_on    port=${gnb_pdu_port}    pdu_device=gnb_pdu

Restart RRU By PowerBreak
    ${gnb_rru_pdu_ip}=    set variable    ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
    ${gnb_rru_pdu_port}=    set variable    ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
    ${gnb_rru_type}=    set variable    ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.vendor}
    pdu.setup_pdu    model=${gnb_rru_type}    host=${gnb_rru_pdu_ip}    alias=gnb_rru_pdu
    pdu.power_off    port=${gnb_rru_pdu_port}    pdu_device=gnb_rru_pdu
    Sleep    5s
    pdu.power_on    port=${gnb_rru_pdu_port}    pdu_device=gnb_rru_pdu

#-------------------PA---------------------------------------------------------------------------------
Modify Attenuation For One BTS
    [Arguments]    ${ru_id}=${0}    ${gnb_id}=${0}    ${value}=${PA_NormalValue}
    Log to console    open gNB ${gnb_id} RRU ${ru_id}  attenuation value ${value}
    ${attenuation_channels}     Get Attenuation port    RU_id=${ru_id}    gnb_id=${gnb_id}
    &{channels_to_modify}    create dictionary
    log    ${attenuation_channels}
    FOR    ${channels}    IN    @{attenuation_channels}
        Set To Dictionary    ${channels_to_modify}    ${channels}    ${value}
        Wait Until Keyword Succeeds    2min    10s
        ...    Modify Attenuation Value    ${channels_to_modify}    RU_id=${ru_id}    gnb_id=${gnb_id}
    END
    Log to console    attenuation change complete

Modify Attenuation For One RRU Of One Site
    [Arguments]    ${ru_id}=${0}    ${gnb_id}=${0}    ${value}=${PA_NormalValue}
    Log to console    open gNB ${gnb_id} RRU ${ru_id}  attenuation value ${value}
    ${attenuation_channels}     Get Attenuation port    ${ru_id}    ${gnb_id}
    &{channels_to_modify}    create dictionary
    log    ${attenuation_channels}
    FOR    ${channels}    IN    @{attenuation_channels}
        Set To Dictionary    ${channels_to_modify}    ${channels}    ${value}
        Wait Until Keyword Succeeds    2min    10s
        ...     Modify Attenuation Value    ${channels_to_modify}    ${ru_id}    ${gnb_id}
    END
    Log to console    attenuation change complete


Get Attenuator Port Value Dictory
    [Arguments]    ${increase_decrease_ports_dict}    ${increase_value}    ${decrease_value}
    &{channels_to_modify}    Create Directory
    FOR    ${port}    IN    &{increase_decrease_ports_dict['increase']}
        Set To Dictionary    ${channels_to_modify}    ${port}    ${increase_value}
    END
    FOR    ${port}    IN    &{increase_decrease_ports_dict['decrease']}
        Set To Dictionary    ${channels_to_modify}    ${port}    ${decrease_value}
    END
    [Return]    ${channels_to_modify}

_Change PA Port For HandOver
    [Arguments]    ${port_lists}    ${value}
    ${index}    Set Variable    ${0}
    Log    ${port_lists}
    FOR    ${port}    IN    @{port_lists}
        wait until keyword succeeds   1 min   5 sec   attenuator.set_attenuation
        ...    port=${port}   value=${value}
        Verify Attenuation Value is updated
        ...    port=${port}    value=${value}
        ${index}    Evaluate    ${index} + ${1}
    END

Trigger Handover
    [Arguments]    ${increase_decrease_ports_dict}
    ...    ${len}    ${handover_max_value}    ${handover_min_value}    ${uprate}    ${downrate}
    ...    ${model}=${tl.attenuator.model}
    [Documentation]    This keywords is use to handover step by step
    ...    :param handover_type,'local to remote' means handover out,'remote to local' means handover in
    ...    the PA value need to decrease: handover_max_value - upgrade * i
    ...    the PA value need to increase: handover_min_value + downrate * i
    ...    handover_min_value + downrate * i, handover_max_value - upgrade * i
    ...    :paran len, the len is the range of i,handover_max_value > upgrade * len
    ${all_ports}    Combine Lists    ${increase_decrease_ports_dict['increase']}    ${increase_decrease_ports_dict['decrease']}
    attenuator.setup_attenuator
    ...    ip_addr=${ATTENUATOR_ADDR}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${all_ports}
    ...    vendor=${attenuation_vendor}
    ...    model=${model}
    FOR    ${i}    IN RANGE    ${len}
        ${decrease_value}    Set Variable    ${handover_max_value-${downrate}*${i}}
        ${increase_value}    Set Variable    ${handover_min_value+${uprate}*${i}}
        Run Keyword If     ${decrease_value}>=${0}
        ...    _Change PA Port For HandOver    port_lists=${increase_decrease_ports_dict['increase']}
        ...    value=${increase_value}
        Run Keyword If     ${increase_value}<=${PA_MaxValue}
        ...    _Change PA Port For HandOver    port_lists=${increase_decrease_ports_dict['decrease']}
        ...    value=${decrease_value}
    END
    @{attenuation_port_numbers}    Create List
    FOR  ${item}  IN  @{attenuation_ports}
        Append To List    ${attenuation_port_numbers}    ${attenuation_ports[${item}].port_no}
    END
    # todo should support multi PA
    attenuator.setup_attenuator
    ...    ip_addr=${ATTENUATOR_ADDR}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}
    ...    vendor=${attenuation_vendor}
    ...    max_attenuation=${PA_MaxValue}
    ...    min_attenuation=${PA_MinValue}
    ...    model=${model}
Trigger Handover By List
    [Arguments]    ${increase_decrease_ports_value_dict}    ${sleep_time}=1
    ...    ${model}=${tl.attenuator.model}
    [Documentation]    This keywords is use to handover step by step
    ...    :param handover_type,'local to remote' means handover out,'remote to local' means handover in
    ...    the PA value need to decrease: handover_max_value - upgrade * i
    ...    the PA value need to increase: handover_min_value + downrate * i
    ...    handover_min_value + downrate * i, handover_max_value - upgrade * i
    ...    :paran len, the len is the range of i,handover_max_value > upgrade * len
    ${all_ports}    Combine Lists    ${increase_decrease_ports_value_dict['increase']}
    ...     ${increase_decrease_ports_value_dict['decrease']}
    attenuator.setup_attenuator
    ...    ip_addr=${ATTENUATOR_ADDR}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${all_ports}
    ...    vendor=${attenuation_vendor}
    ...    model=${model}
    FOR    ${i}    IN RANGE    ${increase_decrease_ports_value_dict['len']}
        ${decrease_value}    Set Variable    ${increase_decrease_ports_value_dict['decrease_value_list'][${i}]}
        ${increase_value}    Set Variable    ${increase_decrease_ports_value_dict['increase_value_list'][${i}]}
        _Change PA Port For HandOver    port_lists=${increase_decrease_ports_value_dict['increase']}
        ...    value=${increase_value}
        _Change PA Port For HandOver    port_lists=${increase_decrease_ports_value_dict['decrease']}
        ...    value=${decrease_value}
        Sleep    ${sleep_time}
    END
    @{attenuation_port_numbers}    Create List
    FOR  ${item}  IN  @{attenuation_ports}
        Append To List    ${attenuation_port_numbers}    ${attenuation_ports[${item}].port_no}
    END
    # todo should support multi PA
    attenuator.setup_attenuator
    ...    ip_addr=${ATTENUATOR_ADDR}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}
    ...    vendor=${attenuation_vendor}
    ...    max_attenuation=${PA_MaxValue}
    ...    min_attenuation=${PA_MinValue}
    ...    model=${model}
Init Attenuation All Max
    [Documentation]    Author: He Winnie
    ...                 Init attenuation max value.
	...                :param max_value <int> : initial attenuation value.
    ...                :param vendor <str> : attenuation type
    [Timeout]    30 min
    [Arguments]    ${max_value}=${None}
    ...    ${model}=${tl.attenuator.model}
    Run Keyword If    '${max_value}'=='${None}'    Set Test Variable
    ...    ${PA_MaxValue}
    ...    ${PA_Vendor_Value}[${attenuation_vendor}][max]
    ${value}    Run Keyword If    '${max_value}'=='${None}'
    ...    Set Variable    ${PA_MaxValue}
    ...    ELSE    Set Variable    ${max_value}
    @{attenuation_port_numbers}    Create List
    @{initial_att_values}    Create List
    FOR  ${item}  IN  @{attenuation_ports}
        Append To List    ${attenuation_port_numbers}    ${attenuation_ports[${item}].port_no}
        Append To List    ${initial_att_values}    ${value}
    END
    # todo should support multi PA
    attenuator.setup_attenuator
    ...    ip_addr=${ATTENUATOR_ADDR}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}
    ...    vendor=${attenuation_vendor}
    ...    max_attenuation=${PA_MaxValue}
    ...    min_attenuation=${PA_MinValue}
    ...    model=${model}
    ${channel_index}   Set Variable     ${0}
    FOR  ${item}  IN  @{initial_att_values}
       wait until keyword succeeds   5 min   5 sec    attenuator.set_attenuation    ${attenuation_port_numbers}[${channel_index}]    ${item}
       ${channel_index}=    Evaluate    ${channel_index}+${1}
    END
