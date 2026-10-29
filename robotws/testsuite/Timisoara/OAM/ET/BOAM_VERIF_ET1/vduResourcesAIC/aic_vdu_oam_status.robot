*** Settings ***
Documentation
...     2.04.2025 -- RF5.0 issues

Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Resource          aic_vdu_collect_log.robot
Resource          aic_vdu_ru_status.robot

*** Variables ***
${G_VDU_NAME}           vdu1
${CLUSTER_NAME}         cran1
${G_USER}               core

*** Keywords ***
Get Active Alarm Fault by REST API
    [Documentation]  Login WebUI And Get Alarm Fault by Jenknis
    ...  can be used on jenkins
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    alarms
    ...
    ...    Example
    ...    | ${alarms} | Get Active Alarm Fault by REST API |
    ${vdu_get_active_alarms}    vdu.vdu_get_active_alarms
    Log To Console    Active alarms:
    ${alarms}    Get From Dictionary    ${vdu_get_active_alarms}    alarms
    FOR    ${his_alarm}    IN    @{alarms}
        Log To Console   FaultId: ${his_alarm['fault_id']}; FaultName: ${his_alarm['fault_name']}; AlarmId: ${his_alarm['alarm_id']};
        ...     AlarmName: ${his_alarm['alarm_name']}; AlarmingObject: ${his_alarm['alarming_object']}; Severity: ${his_alarm['severity']}
    END
    [Return]        ${alarms}

Get Historical Alarm Fault By REST API
    [Documentation]  Login WebUI And Get Alarm Fault by Jenknis
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | OAM_IP | yes | e.g, 10.56.126.210 |
    ...    | USER | yes | e.g, Nemuadmin |
    ...    | PASSWORD | yes | e.g, nemuuser |
    ...
    ...    *RETURN VALUE*
    ...    alarms
    ...
    ...    Example
    ...   | alarms= Login WebUI And Get Historical Alarm Fault by Jenknis | OAM_IP=10.56.125.210 | USER=Nemuadmin | PASSWORD=nemuuser |
    ${vdu_get_historical_alarms}    vdu.vdu_get_historical_alarms
    Log To Console    Historical alarms:
    ${alarms}    Get From Dictionary    ${vdu_get_historical_alarms}    alarms
    FOR    ${his_alarm}    IN    @{alarms}
       Log To Console   FaultId: ${his_alarm['fault_id']}; FaultName: ${his_alarm['fault_name']}; AlarmId: ${his_alarm['alarm_id']};
     ...   AlarmName: ${his_alarm['alarm_name']}; AlarmingObject: ${his_alarm['alarming_object']}; Severity: ${his_alarm['severity']}
    END
    [Return]        ${alarms}

Check Active Alarm Should Contain Fault
    [Arguments]     ${FAULT_ID}
    [Documentation]  Check Active Alarm Should contain Fault
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check Active Alarm Should contain Fault | FAULT_ID=23 |
    ${alarm_list}=  Get Active Alarm Fault by REST API
    should contain    '@{alarm_list}'    'fault_id': u'${FAULT_ID}'

Check Active Alarm Should Not Contain Fault
    [Arguments]     ${FAULT_ID}
    [Documentation]  Check Active Alarm Should Not contain Fault
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check Active Alarm Should Not contain Fault | FAULT_ID=23 |
    ${alarm_list}=  Get Active Alarm Fault by REST API
    should not contain    '@{alarm_list}'    'fault_id': u'${FAULT_ID}'

Check Active Alarm No Fault
    ${alarm_list}=  Get Active Alarm Fault by REST API
    should not contain    '@{alarm_list}'    'fault_id'

Check Historical Alarm Should Contain Fault
    [Arguments]     ${FAULT_ID}
    [Documentation]  Check Historical Alarm Should contain Fault
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check Historical Alarm Should contain Fault | FAULT_ID=23 |
    ${alarm_list}=  Get Historical Alarm Fault By REST API
    should contain    '@{alarm_list}'    'fault_id': '${FAULT_ID}'

Check Historical Alarm Should Not Contain Fault
    [Arguments]     ${FAULT_ID}
    [Documentation]  Check Historical Alarm Should Not contain Fault
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check Historical Alarm Should Not contain Fault | FAULT_ID=23 |
    ${alarm_list}=  Get Historical Alarm Fault By REST API
    should not contain    '@{alarm_list}'    'fault_id': '${FAULT_ID}'
