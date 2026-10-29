*** Settings ***

Resource    ta_messaging/flow.robot
Library    CB006733.py

*** Keywords ***

Verify that PrivateMessage_${msg_num:\d+} of ${all:\d+} is BufferMonitoringNotification for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*privateMessage
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP
    ${message_alias}    Set Variable If    ${all} != 1    PrivateMessage_${msg_num}    PrivateMessage

    Verify That Message Fulfills Query
    ...     ${buffer_monitoring_activate_dl}
    ...     message_alias=${message_alias}
    ...     flow_alias=${flow_alias}

Verify that PrivateMessage_${msg_num:\d+} of ${all:\d+} is BufferCriterionNotification for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*privateMessage
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP
    ${message_alias}    Set Variable If    ${all} != 1    PrivateMessage_${msg_num}    PrivateMessage

    Verify That Message Fulfills Query
    ...     ${buffer_criterion_downlink}
    ...     message_alias=${message_alias}
    ...     flow_alias=${flow_alias}
