*** Settings ***
Library     taf.analyzer.pcap    WITH NAME    pcap
Library     Collections
Library     BuiltIn

Documentation
...   Author: Ding Binmei
...   squad group: MMW_SG1
...   Verify VONR procedure in F1AP log


*** Keywords ***
Verify VoNR call is started successfully
    [Documentation]  Author: Ding Binmei
    ...    Verify VoNR call is started in tcpdump log
    ...    1. Verify fiveQI value is 1 in PDUSessionResourceModifyRequest
    ...    2. Verify qosFlowIdentifier value is not empty in PDUSessionResourceModifyResponse
    [Arguments]    ${log_file_path}
    pcap.setup    infile=${log_file_path}    display_filter=ngap    alias=test0
    ${XPATH_pduSessionResourceModifyReq_fiveQI}    Set variable    //ngap.PDUSessionResourceModifyRequest_element//*/ngap.fiveQI
    ${list_fiveQI_value}    pcap.get_field_value_by_xpath    xpath=${XPATH_pduSessionResourceModifyReq_fiveQI}    pcap_parser=test0
    Should Be Equal As Strings    ${list_fiveQI_value[-1]}    1
    ...    msg=Check VONR call started failed. fiveQI value is not 1 in PDUSessionResourceModifyRequest
    ${XPATH_pduSessionResourceModifyRes_qosFlowIdentifier}    Set variable
    ...    //ngap.PDUSessionResourceModifyResponse_element//*/ngap.qosFlowIdentifier
    ${list_qosFlowIdentifier_value}    pcap.get_field_value_by_xpath    xpath=${XPATH_pduSessionResourceModifyRes_qosFlowIdentifier}
    ...    pcap_parser=test0
    Should Not Be Empty    ${list_qosFlowIdentifier_value[-1]}
    ...    msg=Check VONR call started failed. qosFlowIdentifier should not be empty in PDUSessionResourceModifyResponse
    Log to console    VONR is started successfully from tcpdump log

Verify VoNR call is released successfully
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${log_file_path}
    pcap.setup    infile=${log_file_path}    display_filter=ngap    alias=test0
    ${XPATH_pduSessionResouceModifyReq_QosFlowWithCause}    Set Variable
    ...    //ngap.PDUSessionResourceModifyRequest_element//*/ngap.QosFlowWithCauseItem_element//*/ngap.nas
    ${list_QosFlowWithCause_value}    pcap.get_field_value_by_xpath    xpath=${XPATH_pduSessionResouceModifyReq_QosFlowWithCause}
    ...    pcap_parser=test0
    Should Be Equal As Strings    ${list_QosFlowWithCause_value[-1]}    0
    ...    msg=Check VONR call released failed. Cause value 0 means normal release, it's not normally released
    Log to console    VONR is released successfully from tcpdump log
