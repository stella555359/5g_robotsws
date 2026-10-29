*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot

*** Variables ***
${ATTENUATOR_ADDR}             ${tl.attenuator.ip_addr}
${attenuation_port}            ${tl.attenuator.port}

*** Keywords ***
New Get Attenuation Channels For RU For Cloud
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                To get channel ports  of attenuation which connect to RU.
    ...                :param RU_id <str> : ru id which get form Testline Configuration, default is 0
    ...                :Return attenuation_port_numbers<list> : eg [9:10]
    [Arguments]    ${RU_id}=0    ${gnb_id}=0
    ${attenuation_channels}     set variable    ${tl.gnbs[${gnb_id}].dus[0].fhgws[0].rus[${RU_id}].attenuation_ports}
    @{attenuation_port_numbers}    create list
    ${channel_numbers}     Get Length       ${attenuation_channels}
    FOR  ${index}    IN RANGE    ${channel_numbers}
        ${channel_port}   set variable    ${tl.gnbs[${gnb_id}].dus[0].fhgws[0].rus[${RU_id}].attenuation_ports[${index}].port_no}
        Append To List     ${attenuation_port_numbers}    ${channel_port}
    END
    [Return]    ${attenuation_port_numbers}

New Modify Attenuation For Cloud
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    ...                <<Keyword>> is to modify values of attenuation which connect to RU.
    ...                :param channels_to_modify <dict>:channel ports and values which need to modify in programmable attenuation.
    ...                 for example: &{channels_to_modify}    create dictionary   9=20   10=20
    ...                 in this way, you want to set Port "9" to value "20".
    [Arguments]    ${channels_to_modify}    ${attenuator_device}=${None}    ${RU_id}=0    ${gnb_id}=0
    ${attenuation_port_numbers} =     New Get Attenuation Channels For RU For Cloud    RU_id=${RU_id}    gnb_id=${gnb_id}
    @{channelports_to_modify}    get dictionary keys      ${channels_to_modify}
    @{ports}    Create List
    @{values}    Create List
    FOR    ${item}    IN    @{channelports_to_modify}
        ${item} =    Convert To Integer    ${item}
        ${channelport_value}    Evaluate    float(${channels_to_modify['${item}']})
        List Should Contain Value    ${attenuation_port_numbers}    ${item}
        ${index} =    Get Index From List    ${attenuation_port_numbers}    ${item}
        ${port} =    Convert To Integer    ${attenuation_port_numbers[${index}]}
        Append To List    ${ports}    ${port}
        Append To List    ${values}    ${channelport_value}
    END
    Run Keyword If    '${attenuator_device}' is '${None}'
    ...    Modify Attenuation Port One By One And Verify    ports=${ports}    values=${values}    attenuator_device=${attenuator_device}
    ...    ELSE IF     'topyoung' in '${attenuator_device}'
    ...             Modify Attenuation Port One By One And Verify   ports=${ports}    values=${values}    attenuator_device=${attenuator_device}
    ...    ELSE    Modify Attenuation Ports And Verify    ports=${ports}    values=${values}    attenuator_device=${attenuator_device}
    Log To Console    \n change attenuation to ${channels_to_modify}


Modify All Attenuation Ports Value For Specific RU For Cloud
    [Documentation]   lei.jia@nokia-sbell.com
    ...           Modify all atteuation ports for specific RU to some value.
    ...           :param RU_id <str> : ru id which you want to operate
    ...           :param att_id <str> : <id> for example 0 or 1, if several attenuators used and RU id is not the same with att id.
    ...                                ${None} as default, if more than one PAs and RUs defined in init.py.
    ...                                        please set RU id the same with Attenuator id in init.py,
    ...                                               even attenuator0 and attenuator1 has the same ip.
    ...                                         for example, RU0 use _attenuator_0(10.57.232.105, port 3&4)
    ...                                                      RU1 use _attenuator_1(10.57.232.105, port 7&8)
    ...           :param ${value}: <list> or <string>, it can be several values or only one.
    ...           for example:
    ...           if ${value} = [10, 20, 20, 30], it means port 5=10, 6=20, 7=20, 9=30.
    ...           if ${value} = 10, it will set all ports under RU to value 10.
    [Arguments]    ${value}    ${RU_id}=0    ${gnb_id}=0    ${att_id}=${None}
    ${all_channels}    New Get Attenuation Channels For RU For Cloud    RU_id=${RU_id}    gnb_id=${gnb_id}
    ${att_obj_in_ru_port}    Set Variable    ${tl.gnbs[${gnb_id}].dus[0].fhgws[0].rus[${RU_id}].attenuation_ports[0].attenuator}
    ${att_index}    Get Index From List    ${tl.attenuators}    ${att_obj_in_ru_port}
    ${is_single_att_used}    Get Variable Value    ${tl.attenuator.vendor}
    ${ip_addr}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.ip_addr}    ${tl.attenuators[${att_index}].ip_addr}
    ${port}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.port}    ${tl.attenuators[${att_index}].port}
    ${vendor}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.vendor}    ${tl.attenuators[${att_index}].vendor}
    ${model}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.model}    ${tl.attenuators[${att_index}].model}
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${ip_addr}
    ...    port=${port}
    ...    attenuation_port_numbers=${all_channels}
    ...    vendor=${vendor}
    ...    model=${model}
    ${value_type}    Evaluate    type(${value}).__name__
    ${channels_to_modify}    Create Dictionary
    FOR    ${channel}    IN    @{all_channels}
        ${index} =    get index from list    ${all_channels}    ${channel}
        ${value_dict}    set variable if    'list' in '${value_type}'    ${value}[${index}]    ${value}
        ${channel}    Convert To String    ${channel}
        Set To Dictionary    ${channels_to_modify}    ${channel}    ${value_dict}
    END
    Log To Console    ${channels_to_modify}
    New Modify Attenuation For Cloud    channels_to_modify=${channels_to_modify}
    ...    RU_id=${ru_id}    gnb_id=${gnb_id}    attenuator_device=${configured_attenuator}
