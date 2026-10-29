*** Settings ***
Documentation
...    Author:    Wu Amy;Zhou Qiang;Ding Lisa
...    Maintainer:    Wu Amy;Zhou Qiang;Ding Lisa

Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    ./admin_alarms.py
*** Keywords ***
Get R Object Distname
    [Arguments]    ${class_name}   ${id}   ${connection}   ${timeout}=10
    ${require_objects}    coam.Get Managed Objects    class_name=${class_name}
    ...                   timeout=${timeout}    connection=${connection}
    ${require_object_name}    Set Variable      ${class_name}-${id}

    FOR    ${object_info}   IN    @{require_objects}
        ${object_name}    fetch_from_right     ${object_info['distName']}     /
        Return From Keyword If    '${object_name}'=='${require_object_name}'    ${object_info['distName']}
    END
    Fail

Get RRU Object Info With Serialnum
    [Arguments]    ${class_name}   ${serial_num}   ${connection}   ${timeout}=10
    ${require_objects}    coam.Get Managed Objects    class_name=${class_name}
    ...                   timeout=${timeout}    connection=${connection}

    FOR    ${object_info}   IN    @{require_objects}
        Continue For Loop If     "${object_info['parameters']['serialNumber']}" != "${serial_num}"
        Continue For Loop If     "${object_info['parameters']['stateInfo']['proceduralState']}" != "ethernetEnabled"
        Return From Keyword    ${object_info}
    END
    Fail

Get R_RRU Object Info With Serialnum
    [Arguments]    ${class_name}   ${serial_num}   ${connection}   ${timeout}=10
    ${require_objects}    coam.Get Managed Objects    class_name=${class_name}
    ...                   timeout=${timeout}    connection=${connection}

    FOR    ${object_info}   IN    @{require_objects}
        Continue For Loop If     "${object_info['parameters']['serialNumber']}" != "${serial_num}"
        Return From Keyword    ${object_info}
    END
    Fail

Admin Alarms Get And Check
    [Arguments]    ${allowed}=${EMPTY}    ${mandatory}=${EMPTY}    ${alias}=default
    [Documentation]  Keyword gets and checks Admin mandatory and allowed alarms.
    ...  Optional arguments:
    ...     allowed - list of allowed alarms defined by faultName/alarmDetail attribute (regex is supported).
    ...     mandatory - list of dictionaries with mandatory alarms defined by faultName/alarmDetail, faultId, severity/alarmSeverity, impactedCells
    ...                 alarmingResource/alarmingResourceDN, alarmCounter or any other attribute matching to first level key name of active alarm.
    ...                 At least alarmDetail or faultId dictionary key and its value has to be defined (regex is supported in Value)
    ...  Example:
    ...     @{allowed}=      (?i)vendor bts certificate
    ...     ...              Synchronization lost
    ...     ...              .*BTS booted at.+
    ...     @{mandatory}=    {'faultName': 'Unit blocked', 'faultId': '48', 'severity': 'Major', 'impactedCells': '.*/LNCEL-(?:_[LR])?-1(?:$|\\D).*'}
    ...     ...              {'faultName': 'Unit blocked', 'faultId': '48', 'impactedCells': '.*/LNCEL-(?:_[LR])?-2(?:$|\\D).*'}
    ...     ...              {'alarmDetail': 'Unit blocked', 'alarmSeverity': 'Major', 'impactedCells': '.*/LNCEL(?:_[LR])?-3(?:$|\\D).*'}
    ...     ...              {'faultId': '48', 'alarmSeverity': 'Major', 'impactedCells': '.*/LNCEL(?:_[LR])?-4(?:$|\\D).*'}
    ...     ...              {'faultName': 'Transmission path failure', 'alarmCounter': 3}
    ...     Author:         artur.dobosz@nokia.com
    ...     Maintainer:     Author
    ${out_active_alarms_list}=    coam.Get Active Alarms   connection=${alias}
    Admin Alarms Check    available=${out_active_alarms_list}    allowed=${allowed}    mandatory=${mandatory}

Admin Historical Alarms Get And Check
    [Arguments]    ${allowed}=${EMPTY}    ${mandatory}=${EMPTY}    ${alias}=default
    ${out_history_alarms_list}    coam.Get Historic Alarms    connection=${alias}    timeout=60
    Admin Alarms Check    available=${out_history_alarms_list}    allowed=${allowed}    mandatory=${mandatory}

Get R Object Distname By SN
    [Arguments]    ${class_name}   ${sn}   ${connection}   ${timeout}=10
    ${require_objects}    coam.Get Managed Objects    class_name=${class_name}
    ...                   timeout=${timeout}    connection=${connection}
    #${require_object_name}    Set Variable      ${class_name}-${id}

    FOR    ${object_info}   IN    @{require_objects}
        Return From Keyword If    '${object_info['parameters']['serialNumber']}'=='${sn}'    ${object_info['distName']}
    END
    Fail
