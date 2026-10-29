*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Library        ../resources/KeywordsCB008490.py

*** Keywords ***
Get Flow Alias
    [Arguments]    ${device}    ${all}    ${procedure}    ${protocol}

            ${flow_alias_other}=   Run Keyword If    '${protocol}'!='NR-RRC'    Get Flow Name
                ...    procedure=${all}*${procedure}
                ...    device=${device}
                ...    protocol=${protocol}

            ${flow_alias_RRC}=    Run Keyword If    '${protocol}'=='NR-RRC'    Get Flow Name
                   ...    ${all}*${procedure}
                   ...    device=${device}
                   ...    protocol=NR-RRC
        ${flow_alias}=    Set Variable if    '${protocol}'=='NR-RRC'     ${flow_alias_RRC}    ${flow_alias_other}
        [Return]    ${flow_alias}

Get Value Of Parameter From Message
    [Arguments]      ${procedure}    ${message}    ${num_of_message}    ${all}    ${protocol}    ${device}    ${parameter}

    ${flow_alias}=    Get Flow Alias    device=${device}    all=${all}    procedure=${procedure}    protocol=${protocol}
    ${suffix}=    Set variable if    ${all}==1    ${EMPTY}    _${num_of_message}

    ${parameter_value}=    Get Values Of Parameter From Message Flow    flow_alias=${flow_alias}
    ...     message_alias=${message}${suffix}    parameter_name=${parameter}
    [Return]    ${parameter_value}

Verify In Message That Field Is Present
    [Arguments]    ${procedure}    ${device}    ${protocol}    ${message}    ${n}    ${all}    ${field}

    ${flow_alias}=    Get Flow Alias    device=${device}    all=${all}    procedure=${procedure}    protocol=${protocol}
    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     ${field} is present
    ...     message_alias=${message}${suffix}
    ...     flow_alias=${flow_alias}


Verify In Message That Field Is Not Present
    [Arguments]    ${procedure}    ${device}    ${protocol}    ${message}    ${n}    ${all}    ${field}

    ${flow_alias}=    Get Flow Alias    device=${device}    all=${all}    procedure=${procedure}    protocol=${protocol}
    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     ${field} is not present
    ...     message_alias=${message}${suffix}
    ...     flow_alias=${flow_alias}

Verify That Field In Message Is Set To Specific Value
    [Arguments]    ${procedure}    ${device}    ${protocol}    ${message}    ${n}    ${all}    ${field}    ${value}

    ${flow_alias}=    Get Flow Alias    device=${device}    all=${all}    procedure=${procedure}    protocol=${protocol}
    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     ${field} eq ${value}
    ...     message_alias=${message}${suffix}
    ...     flow_alias=${flow_alias}

Verify In Message That Field_1 Is Present And Has Field_2
    [Arguments]    ${procedure}    ${device}    ${protocol}    ${message}    ${n}    ${all}    ${field_1}    ${field_2}

    ${flow_alias}=    Get Flow Alias    device=${device}    all=${all}    procedure=${procedure}    protocol=${protocol}
    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     ${field_1} contains (${field_2} is present)
    ...     message_alias=${message}${suffix}
    ...     flow_alias=${flow_alias}

Verify In Message That Field_1 Is Present And Has Field_2 Set To Specific Value
    [Arguments]    ${procedure}    ${device}    ${protocol}    ${message}    ${n}    ${all}    ${field_1}    ${field_2}    ${value}

    ${flow_alias}=    Get Flow Alias    device=${device}    all=${all}    procedure=${procedure}    protocol=${protocol}
    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     ${field_1} contains (${field_2} eq ${value})
    ...     message_alias=${message}${suffix}
    ...     flow_alias=${flow_alias}

Verify That Field In Message Has Value
    [Arguments]    ${procedure}    ${device}    ${protocol}    ${message}    ${n}    ${all}    ${field}    ${value}

    ${flow_alias}=    Get Flow Alias    device=${device}    all=${all}    procedure=${procedure}    protocol=${protocol}
    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     (${field} contains (${value}))
    ...     message_alias=${message}${suffix}
    ...     flow_alias=${flow_alias}

Verify That Field Does NOT Contain Value Is Message
    [Arguments]    ${procedure}    ${device}    ${protocol}    ${message}    ${n}    ${all}    ${field}    ${value}

    ${flow_alias}=    Get Flow Alias    device=${device}    all=${all}    procedure=${procedure}    protocol=${protocol}
    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     not (${field} contains (${value}))
    ...     message_alias=${message}${suffix}
    ...     flow_alias=${flow_alias}

Verify Length Of List In Message
    [Arguments]    ${procedure}    ${device}    ${protocol}    ${message}    ${n}    ${all}    ${list}    ${length}

    ${flow_alias}=    Get Flow Alias    device=${device}    all=${all}    procedure=${procedure}    protocol=${protocol}
    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     length(${list}) eq ${length}
    ...     message_alias=${message}${suffix}
    ...     flow_alias=${flow_alias}

Verify In Message That Field_1 Is Present And Contains Field_2 And Field_3
    [Arguments]    ${procedure}    ${device}    ${protocol}    ${message}    ${n}    ${all}    ${field_1}    ${field_2}    ${field_3}

    ${flow_alias}=    Get Flow Alias    device=${device}    all=${all}    procedure=${procedure}    protocol=${protocol}
    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     ${field_1} contains (${field_2} is present)
    ...     and ${field_1} contains (${field_3} is present)
    ...     message_alias=${message}${suffix}
    ...     flow_alias=${flow_alias}

Verify In Message That Field_1 Is Present And Contains Field_2 Which Contains List Value/s
    [Arguments]    ${procedure}    ${device}    ${protocol}    ${message}    ${n}    ${all}    ${field_1}    ${field_2}    ${list_values}

    ${flow_alias}=    Get Flow Alias    device=${device}    all=${all}    procedure=${procedure}    protocol=${protocol}
    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     ${field_1} contains (${field_2} contains (${list_values}))
    ...     message_alias=${message}${suffix}
    ...     flow_alias=${flow_alias}

Set Index
    [Arguments]    ${all}    ${msg_index}
    ${suffix}=    Set variable if    ${all}==1    ${EMPTY}    _${msg_index}
    [Return]    ${suffix}

Verify In Message That Cause Is Set To
    [Arguments]    ${procedure}    ${device}    ${protocol}    ${message}    ${n}    ${all}     ${cause_type}    ${cause_message}    ${field}

    ${flow_alias}=    Get Flow Alias    device=${device}    all=${all}    procedure=${procedure}    protocol=${protocol}
    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     ${field} contains (${cause_type} eq '${cause_message}')
    ...     message_alias=${message}${suffix}
    ...     flow_alias=${flow_alias}

