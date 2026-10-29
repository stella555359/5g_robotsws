*** Settings ***
Documentation   :copyright: Nokia
...             :authors: Izabela Prośniak
...             :contact: izabela.prosniak@nokia.com

Resource    ta_messaging/flow.robot
Library    testsuite/Wroclaw/RRM/WRO_2/resources/NotDecodedIEs.py

*** Variables ***

&{PROTOCOLS}=    uEContextModification=F1AP    MeasurementReport=NR-RRC    dLRRCMessageTransfer=F1AP
...    uLRRCMessageTransfer=F1AP    RRCReconfiguration=NR-RRC    handoverPreparation=XNAP

&{MESSAGES}=    UEContextModificationRequest=uEContextModification  UEContextModificationResponse=uEContextModification
...    RRCReconfiguration=RRCReconfiguration    MeasurementReport=MeasurementReport    HandoverRequest=handoverPreparation
...    HandoverRequestAcknowledge=handoverPreparation

&{PROCEDURES}=    UEContextModificationRequest=1    UEContextModificationResponse=1    HandoverRequest=1
...               HandoverRequestAcknowledge=1    MeasurementReport=0    RRCReconfiguration=0

*** Keywords ***

Verify ${device_id} message ${message_to_be_verified} number ${meas_number} of ${all_messages} fulfils ${verification_filter} content
    ${message_alias}    ${flow_alias}=    Obtain Message Alias And Flow Alias    device_id=${device_id}
                                          ...    message_to_be_verified=${message_to_be_verified}
                                          ...    meas_number=${meas_number}    all_messages=${all_messages}
    Verify That Message Fulfills Query
    ...  ${verification_filter}
    ...  message_alias=${message_alias}
    ...  flow_alias=${flow_alias}

Verify ${device_id} message ${message_to_be_verified} number ${meas_number} of ${all_messages} fulfils ${verification_filter} string filter
    ${message_alias}    ${flow_alias}=    Obtain Message Alias And Flow Alias    device_id=${device_id}
                                          ...    message_to_be_verified=${message_to_be_verified}
                                          ...    meas_number=${meas_number}    all_messages=${all_messages}
    verify_if_measConfig_contains  ${flow_alias}  ${message_alias}  ${verification_filter}

Verify ${device_id} message ${message_to_be_verified} number ${meas_number} of ${all_messages} fulfils ${verification_filter} hex ${inf_ele} filter
    ${message_alias}    ${flow_alias}=    Obtain Message Alias And Flow Alias    device_id=${device_id}
                                          ...    message_to_be_verified=${message_to_be_verified}
                                          ...    meas_number=${meas_number}    all_messages=${all_messages}
    verify_if_information_element_contains  ${inf_ele}  ${flow_alias}  ${message_alias}  ${verification_filter}

Obtain Message Alias And Flow Alias
    [Arguments]     ${device_id}    ${message_to_be_verified}    ${meas_number}    ${all_messages}
    ${if_procedure}    Set Variable    ${PROCEDURES}[${message_to_be_verified}]
    ${message_alias}    Set Variable If    ${all_messages} != 1    ${message_to_be_verified}_${meas_number}    ${message_to_be_verified}

    ${message_to_be_verified_aligned} =	Replace String Using Regexp
                                        ...    ${message_to_be_verified}
                                        ...    .*
                                        ...    ${MESSAGES}[${message_to_be_verified}]
                                        ...    count=1
    ${flow_reference}    Set Variable If    ${all_messages} != 1    ${all_messages}*${message_to_be_verified_aligned}
                         ...    ${message_to_be_verified_aligned}
#    ${flow_alias} =    Run Keyword If    ${all_messages} == 1    Get Flow Name

    Log to console    ${if_procedure} == 0
#    ${if_procedure_bool}    Should be equal as strings    not_procedure    ${MESSAGES}[${message_to_be_verified}]
    ${flow_alias} =    Run Keyword If    ${if_procedure} == 0   Get Flow Name
           ...     ${flow_reference}
           ...     device=${device_id}
           ...     protocol=${PROTOCOLS}[${message_to_be_verified_aligned}]
           ...     ELSE
           ...     Get Flow Name
           ...     procedure=${flow_reference}
           ...     device=${device_id}
           ...     protocol=${PROTOCOLS}[${message_to_be_verified_aligned}]

    [Return]    ${message_alias}    ${flow_alias}
