*** Settings ***
Documentation
...    Author: Yang mengli
...    Email address: mengli.yang@nokia-sbell.com
...    Maintainer: Yang mengli;    Liu Renhui
...    Email address: mengli.yang@nokia-sbell.com;    renhui-david.liu@nokia-sbell.com;
...    Common KWs related to PA.
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guideline: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/09.+AIC+Common+Resource+Supporting+Mode+Improvement




*** Keywords ***
Get Attenuation port
    [Arguments]    ${RU_id}=0    ${du_id}=0
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                To get channel ports of attenuation which connect to RU.
    ...                The attenuation port calculation: e.g. HBTE PAM-16X16-4-63-0.5, A2B2 port equals 18(16*1 + 2 = 18)
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${RU_id} | No | RU id which is fetched from Testline Configuration, default value is 0 |
    ...    | ${du_id} | No | gnb id which is fetched from Testline Configuration, default value is 0 |
    ...
    ...    | Return Value | Description |
    ...    | ${attenuation_port_numbers}<list> | The attenuation port numbers list, e.g. [9:10] |
    ...
    ...    Example
    ...    | ${port_list} | Get Attenuation port | RU_id=${0} | du_id=${0} |
    ...
    ${attenuation_channels}    set variable    ${tl.gnbs[0].dus[${du_id}].fhgws[0].rus[${RU_id}].attenuation_ports}
    @{attenuation_port_numbers}    create list
    ${channel_numbers}    Get Length    ${attenuation_channels}
    FOR    ${index}    IN RANGE    ${channel_numbers}
        ${channel_port}    set variable    ${tl.gnbs[0].dus[${du_id}].fhgws[0].rus[${RU_id}].attenuation_ports[${index}].port_no}
        Append To List    ${attenuation_port_numbers}    ${channel_port}
    END
    [Return]    ${attenuation_port_numbers}

Get Initial Attenuation Values
    [Arguments]    ${RU_id}=0    ${vendor}=TOPYOUNG    ${du_id}=0   ${max_attenuation}=${None}   ${attenuator_id}=${None}
    ...            ${model}=${tl.attenuator.model}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                The KW is to get initial attenuation values based on channel port numbers get form testline config.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${RU_id} | No | RU id which is fetched from Testline Configuration, default value is 0 |
    ...    | ${vendor} | No | The attenuation vendor name, default value is HBTE |
    ...    | ${du_id} | No | gnb id which is fetched from Testline Configuration, default value is 0 |
    ...    | ${max_attenuation} | No | set PA's max attenuation value, default value is 127 |
    ...    | ${attenuator_id} | No | The attenuator id, default value is None, mean default PA  |
    ...
    ...    | Return Value | Description |
    ...    | ${initial_att_values} | The initial attenuation values are returned. |
    ...
    ...    Example
    ...    | ${initial_att_values} | Get Initial Attenuation Values | RU_id=0 | vendor=HBTE | du_id=0 | attenuator_id=1|
    ...    | ${back_att_ports_cell2} | Get Initial Attenuation Values | vendor=TOPYOUNG |  |  |
    ...
    ${attenuation_port_numbers} =    Get Attenuation port    RU_id=${RU_id}    du_id=${du_id}
    ${channel_numbers}    Get Length    ${attenuation_port_numbers}
    ${attenuator_ip}    Set Variable If    ${attenuator_id}!=None    ${tl.attenuators[${attenuator_id}].ip_addr}
    ...    ${tl.attenuator.ip_addr}
    Log To Console   ${attenuator_ip}
    ${attenuator_port}    Set Variable If    ${attenuator_id}!=None    ${tl.attenuators[${attenuator_id}].port}
    ...    ${tl.attenuator.port}
    attenuator.setup_attenuator
    ...    ip_addr=${attenuator_ip}
    ...    port=${attenuator_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}
    ...    max_attenuation=${max_attenuation}
    ...    vendor=${vendor}
    ...    model=${model}
    ${initial_att_values}    Create List
    FOR    ${index}    IN RANGE    ${channel_numbers}
        ${values}=    attenuator.read_attenuation    port=${attenuation_port_numbers[${index}]}
        Append To List    ${initial_att_values}    ${values}
    END
    [Return]    ${initial_att_values}

Recover Attenuation Values
    [Arguments]    ${initial_att_values}    ${RU_id}=0    ${vendor}=TOPYOUNG    ${du_id}=0
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This KW is to restore the initial values based on channel port numbers get form testline config.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${initial_att_values} | Yes | initial attenuation values. Should be a list. |
    ...    | ${RU_id} | No | RU id which is fetched from Testline Configuration, default value is 0 |
    ...    | ${vendor} | No | The attenuation vendor name, default value is HBTE |
    ...    | ${du_id} | No | gnb id which is fetched from Testline Configuration, default value is 0 |
    ...
    ...    | Return Value | Description |
    ...    | NA | NA |
    ...
    ...    Example
    ...    | Recover Attenuation Values | initial_att_values=${initial_att_values} | RU_id=0 | vendor=HBTE | du_id=0 |
    ...
    ${attenuation_port_numbers} =    Get Attenuation port    RU_id=${RU_id}    du_id=${du_id}
    attenuator.setup_attenuator
    ...    ip_addr=${ATTENUATOR_ADDR}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}
    ...    vendor=${vendor}
    ${channel_index}    Set Variable    ${0}
    FOR    ${item}    IN    @{initial_att_values}
        wait until keyword succeeds    5 min    5 sec    attenuator.set_attenuation    @{attenuation_port_numbers}[${channel_index}]    ${item}
        ${channel_index}=    Evaluate    ${channel_index}+${1}
    END

Modify Attenuation Value
    [Arguments]    ${channels_to_modify}    ${RU_id}=0    ${du_id}=0
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword is to modify values of attenuation which connect to RU.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${channels_to_modify} | Yes | channel ports and values which need to modify in programmable attenuation |
    ...    |                       |     | for example: &{channels_to_modify}    create dictionary    9=20    10=20 |
    ...    |                       |     | in this way, you want to set Port "9" to value "20". |
    ...    |                       |     | The attenuation port calculation: e.g. HBTE PAM-16X16-4-63-0.5, A2B2 port equals 18(16*1 + 2 = 18) |
    ...    | ${RU_id} | No | RU id which is fetched from Testline Configuration, default value is 0 |
    ...    | ${du_id} | No | gnb id which is fetched from Testline Configuration, default value is 0 |
    ...
    ...    | Return Value | Description |
    ...    | NA | NA |
    ...
    ...    Example
    ...    | &{channels_to_modify}    | create dictionary     | ${attenuation_channels[0]}=0 | ${attenuation_channels[1]}=0 |
    ...    | ...                      |                       | ${attenuation_channels[2]}=0 | ${attenuation_channels[3]}=0 |
    ...    | Modify Attenuation Value | ${channels_to_modify} | RU_id=0                      | du_id=0                     |
    ...
    ${attenuation_port_numbers} =    Get Attenuation port    RU_id=${RU_id}    du_id=${du_id}
    @{channelports_to_modify}    get dictionary keys    ${channels_to_modify}
    FOR    ${item}    IN    @{channelports_to_modify}
        ${item} =    convert to integer    ${item}
        ${channelport_value} =    convert to integer    ${channels_to_modify[${item}]}
        list should contain value    ${attenuation_port_numbers}    ${item}
        ${index} =    get index from list    ${attenuation_port_numbers}    ${item}
        wait until keyword succeeds    5 min    5 sec    attenuator.set_attenuation
        ...    port=${attenuation_port_numbers[${index}]}    value=${channelport_value}
        Verify Attenuation Value is updated
        ...    port=${attenuation_port_numbers[${index}]}    value=${channelport_value}
    END

Modify Attenuation Value With Stage
    [Arguments]    ${channelport_value}    ${RU_id}=0    ${du_id}=0    ${vendor}=TOPYOUNG
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword is to modify values of attenuation which connect to RU.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${RU_id} | No | RU id which is fetched from Testline Configuration, default value is 0 |
    ...    | ${du_id} | No | gnb id which is fetched from Testline Configuration, default value is 0 |
    ...
    ...    | Return Value | Description |
    ...    | NA | NA |
    ...
    ...    Example
    ...    | Modify Attenuation Value With Stage | ${channelport_value} | RU_id=0 | du_id=0 |
    ...
    ${attenuation_port_numbers} =    Get Attenuation port    RU_id=${RU_id}    du_id=${du_id}
    ${attenuation_port_length}    Get length    ${attenuation_port_numbers}
    attenuator.setup_attenuator
    ...    ip_addr=${tl.attenuator.ip_addr}
    ...    port=${tl.attenuator.port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}
    ...    vendor=${vendor}
    FOR    ${index}    IN RANGE    ${attenuation_port_length}
        wait until keyword succeeds    5 min    5 sec    attenuator.set_attenuation
        ...    port=${attenuation_port_numbers[${index}]}    value=${channelport_value}
        Verify Attenuation Value is updated
        ...    port=${attenuation_port_numbers[${index}]}    value=${channelport_value}
    END

Verify Attenuation Value is updated
    [Arguments]    ${port}    ${value}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword is to veirfy whether values of attenuation are updated successfully.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${port} | Yes | The attenuation port need to verify the value |
    ...    | ${value} | Yes | The value need expected |
    ...
    ...    | Return Value | Description |
    ...    | NA | NA |
    ...
    ...    Example
    ...    | Verify Attenuation Value is updated | port=0 | value=0 |
    ...
    ${new_value}=    attenuator.read_attenuation    port=${port}
    should be equal as integers    ${new_value}    ${value}    msg=Attenuation set failed.
    log to console  change attenuation to ${value}
