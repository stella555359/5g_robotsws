*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...      - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...      - Michał Szymakowski <michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ./5GC001756-common_keywords.robot
Library     ../../../resources/Python/utilities.py

*** Keywords ***
Verify number of elements on the list within NGAP message
    [Arguments]     ${amf_id}  ${procedure_name}  ${message}  ${list_name}  ${element_num}
    ${flow}=      Get Flow Name
    ...     procedure=${procedure_name}
    ...     device=AMF${amf_id}
    Verify That Message Fulfills Query
    ...     (${list_name} is present)
    ...     message_alias=${message}
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     (length(${list_name}) eq ${element_num})
    ...     message_alias=${message}
    ...     flow_alias=${flow}

Verify single field in NGAP message
    [Arguments]     ${amf_id}  ${procedure_name}  ${message}  ${field}  ${value}
    ${new_value}=   map_message_value_to_ta_messaging_used_value    ${value}
    Log     ${new_value}
    ${flow}=      Get Flow Name
    ...     procedure=${procedure_name}
    ...     device=AMF${amf_id}
    Verify That Message Fulfills Query
    ...     (${field} is present)
    ...     message_alias=${message}
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     (${field} eq ${new_value})
    ...     message_alias=${message}
    ...     flow_alias=${flow}
