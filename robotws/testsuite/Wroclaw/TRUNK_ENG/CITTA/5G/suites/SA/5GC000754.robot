*** Settings ***
Documentation
...    This test case verifies packet flow of the Successful PDU Session Modification for adding or deleting
...    one or more QoS flow to one or more PDU session.

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LO_AP_LO
Metadata    variant    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_AP_WTS    PY310    RF50


Resource    ../../resources/main_resources.robot

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms
...    AND    Test suite preconditions

Suite Teardown  RUN KEYWORDS
...    Stop WTS    AND
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/5GC000754.resources

# -- test scenario variables --
${LUA_CONFIG}    ${RESOURCES}/epcsim.cfg

*** Test Cases ***
5GC000754-A_-_PDU_Session_Modification_Success_Add_One_QoS_Flow_To_One_PDU
    [Documentation]    This test case verifies packet flow of the Successful PDU Session Modification while
    ...     adding one Qos flow to one PDU Session.
    [Setup]    [PRE]5GC000754-A_-_PDU_Session_Modification_Success_Add_One_QoS_Flow_To_One_PDU
    [Teardown]    [POST]5GC000754-A_-_PDU_Session_Modification_Success_Add_One_QoS_Flow_To_One_PDU

    Add one QoS flow to PDU session 1 for UE 1
    Verify Qos flow addition to PDU Session 1 for UE 1

5GC000754-A_-PDU_Session_Modification_Success_Add_Two_QoS_Flows_To_One_PDU
    [Documentation]    This test case verifies packet flow of the Successful PDU Session Modification while
    ...    adding two Qos flows to one PDU Session.
    [Setup]    [PRE]5GC000754-A_-PDU_Session_Modification_Success_Add_Two_QoS_Flows_To_One_PDU
    [Teardown]    [POST]5GC000754-A_-PDU_Session_Modification_Success_Add_Two_QoS_Flows_To_One_PDU

    Add two QoS flows to PDU session 1 for UE 2
    Verify Qos flow addition to PDU Session 1 for UE 2

5GC000754-A_-_PDU_Session_Modification_Success_Add_Two_QoS_Flows_To_Two_PDUs
    [Documentation]    This test case verifies packet flow of the Successful PDU Session Modification while
    ...    adding two Qos flows to two PDU Sessions.
    [Setup]    [PRE]5GC000754-A_-_PDU_Session_Modification_Success_Add_Two_QoS_Flows_To_Two_PDUs
    [Teardown]    [POST]5GC000754-A_-_PDU_Session_Modification_Success_Add_Two_QoS_Flows_To_Two_PDUs

    Add two QoS flows to PDU sessions 1 and 2 for UE 3
    Verify Qos flow addition to PDU Sessions 1 and 2 for UE 3

5GC000754-B_-_PDU_Session_Modification_Success_Delete_QoS_Flows_in_Multi_PDU_Sessions
    [Documentation]      This test case verifies packet flow of the Successful PDU Session Modification while
    ...    adding and deleting QoS flows from each of three PDU Sessions.
    [Setup]    [PRE]5GC000754-B_-_PDU_Session_Modification_Success_Delete_QoS_Flows_in_Multi_PDU_Sessions
    [Teardown]    [POST]5GC000754-B_-_PDU_Session_Modification_Success_Delete_QoS_Flows_in_Multi_PDU_Sessions
    Add one QoS flow to PDU session 1 for UE 4
    Add two QoS flows to PDU session 2 for UE 4
    Add two QoS flows to PDU session 3 for UE 4
    Verify Qos flow addition to PDU Session 1 for UE 4
    Verify QoS flow addition to PDU Session 2 for UE 4
    Verify Qos flow addition to PDU Session 3 for UE 4
    Delete one QoS flow from PDU session 1 for UE 4
    Delete two QoS flows from PDU session 2 for UE 4
    Delete two QoS flows from PDU session 3 for UE 4
    Verify QoS flow deletion from PDU Session 1 for UE 4
    Verify QoS flow deletion from PDU Session 2 for UE 4
    Verify QoS flow deletion from PDU Session 3 for UE 4


*** Keywords ***
Test suite preconditions
    Commission eNB To SA Mode
    Start WTS    ${LUA_CONFIG}    check_version=False
    Check if BTS is OnAir

[PRE]5GC000754-A_-_PDU_Session_Modification_Success_Add_One_QoS_Flow_To_One_PDU
    SA 5G Attach UE"1"
    SA Setup Primary PDU Session For PDU"1" UE"1" GW"1" NWSLICE"1"

[POST]5GC000754-A_-_PDU_Session_Modification_Success_Add_One_QoS_Flow_To_One_PDU
    SA 5G Detach UE"1"
    Report miscellaneous KPIs
    ute_tshark.teardown_all_aliases_for_tshark

[PRE]5GC000754-A_-PDU_Session_Modification_Success_Add_Two_QoS_Flows_To_One_PDU
    SA 5G Attach UE"2"
    SA Setup Primary PDU Session For PDU"1" UE"2" GW"2" NWSLICE"1"

[POST]5GC000754-A_-PDU_Session_Modification_Success_Add_Two_QoS_Flows_To_One_PDU
    SA 5G Detach UE"2"
    Report miscellaneous KPIs
    ute_tshark.teardown_all_aliases_for_tshark

[PRE]5GC000754-A_-_PDU_Session_Modification_Success_Add_Two_QoS_Flows_To_Two_PDUs
    SA 5G Attach UE"3"
    SA Setup Primary PDU Session For PDU"1" UE"3" GW"3" NWSLICE"1"
    SA Setup Additional PDU Session For PDU"2" UE"3" GW"4" NWSLICE"1"

[POST]5GC000754-A_-_PDU_Session_Modification_Success_Add_Two_QoS_Flows_To_Two_PDUs
    SA 5G Detach UE"3"
    Report miscellaneous KPIs
    ute_tshark.teardown_all_aliases_for_tshark

[PRE]5GC000754-B_-_PDU_Session_Modification_Success_Delete_QoS_Flows_in_Multi_PDU_Sessions
    SA 5G Attach UE"4"
    SA Setup Primary PDU Session For PDU"1" UE"4" GW"5" NWSLICE"1"
    SA Setup Additional PDU Session For PDU"2" UE"4" GW"6" NWSLICE"1"
    SA Setup Additional PDU Session For PDU"3" UE"4" GW"7" NWSLICE"1"

[POST]5GC000754-B_-_PDU_Session_Modification_Success_Delete_QoS_Flows_in_Multi_PDU_Sessions
    SA 5G Detach UE"4"
    Report miscellaneous KPIs

# -- test steps --
Add one QoS flow to PDU session 1 for UE 1
    [Tags]    DESIGNSTEP
    SA Modify PDU Session"1" with UE"1" - "add" QoS Flow"2" And Collect PCAP

Verify Qos flow addition to PDU Session 1 for UE 1
    [Tags]    DESIGNSTEP
    Verify PDU Session Modification for PDU Session"1" UE"1" - "add" QoS Flow"2"

Add two QoS flows to PDU session 1 for UE 2
    [Tags]    DESIGNSTEP
    SA Modify PDU Session"1" with UE"2" - "add" QoS Flow"2,3" And Collect PCAP

Verify Qos flow addition to PDU Session 1 for UE 2
    [Tags]    DESIGNSTEP
    Verify PDU Session Modification for PDU Session"1" UE"2" - "add" QoS Flow"2,3"

Add two QoS flows to PDU sessions 1 and 2 for UE 3
    [Tags]    DESIGNSTEP
    SA Modify PDU Session"1,2" with UE"3" - "add" QoS Flow"2,3" And Collect PCAP

Verify Qos flow addition to PDU Sessions 1 and 2 for UE 3
    [Tags]    DESIGNSTEP
    Verify PDU Session Modification for PDU Session"1,2" UE"3" - "add" QoS Flow"2,3"

Add one QoS flow to PDU session 1 for UE 4
    [Tags]    DESIGNSTEP
    SA Modify PDU Session"1" with UE"4" - "add" QoS Flow"2" And Collect PCAP

Add two QoS flows to PDU session 2 for UE 4
    [Tags]    DESIGNSTEP
    SA Modify PDU Session"2" with UE"4" - "add" QoS Flow"2,3" And Collect PCAP

Add two QoS flows to PDU session 3 for UE 4
    [Tags]    DESIGNSTEP
    SA Modify PDU Session"3" with UE"4" - "add" QoS Flow"2,3" And Collect PCAP

Verify Qos flow addition to PDU Session 1 for UE 4
    [Tags]    DESIGNSTEP
    Verify PDU Session Modification for PDU Session"1" UE"4" - "add" QoS Flow"2"

Verify QoS flow addition to PDU Session 2 for UE 4
    [Tags]    DESIGNSTEP
    Verify PDU Session Modification for PDU Session"2" UE"4" - "add" QoS Flow"2,3"

Verify Qos flow addition to PDU Session 3 for UE 4
    [Tags]    DESIGNSTEP
    Verify PDU Session Modification for PDU Session"3" UE"4" - "add" QoS Flow"2,3"

Delete one QoS flow from PDU session 1 for UE 4
    [Tags]    DESIGNSTEP
    SA Modify PDU Session"1" with UE"4" - "del" QoS Flow"2" And Collect PCAP

Delete two QoS flows from PDU session 2 for UE 4
    [Tags]    DESIGNSTEP
    SA Modify PDU Session"2" with UE"4" - "del" QoS Flow"2,3" And Collect PCAP

Delete two QoS flows from PDU session 3 for UE 4
    [Tags]    DESIGNSTEP
    SA Modify PDU Session"3" with UE"4" - "del" QoS Flow"2,3" And Collect PCAP

Verify QoS flow deletion from PDU Session 1 for UE 4
    [Tags]    DESIGNSTEP
    Verify PDU Session Modification for PDU Session"1" UE"4" - "del" QoS Flow"2"

Verify QoS flow deletion from PDU Session 2 for UE 4
    [Tags]    DESIGNSTEP
    Verify PDU Session Modification for PDU Session"2" UE"4" - "del" QoS Flow"2,3"

Verify QoS flow deletion from PDU Session 3 for UE 4
    [Tags]    DESIGNSTEP
    Verify PDU Session Modification for PDU Session"3" UE"4" - "del" QoS Flow"2,3"


# -- internals --
Verify PDU Session Modification for PDU Session"${pdu_id}" UE"${ue_id}" - "${procedure}" QoS Flow"${qosflows_nr}"
    ${PDU_session_req}    ${PDU_session_resp}    Prepare Packet Filters
    ...    qosflows_nr=${qosflows_nr}
    ...    pdu_id=${pdu_id}
    ...    procedure=${procedure}
    ${PDU_session_resource_modify_req}    ute_tshark.get_packets_count
    ...    packet_filter=${PDU_session_req}
    ...    alias=${procedure}_pdu_session_${pdu_id}pdu_${ue_id}ue_${qosflows_nr}qos
    ${PDU_session_resource_modify_resp}    ute_tshark.get_packets_count
    ...    packet_filter=${PDU_session_resp}
    ...    alias=${procedure}_pdu_session_${pdu_id}pdu_${ue_id}ue_${qosflows_nr}qos
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${PDU_session_resource_modify_req}==${1}
    ...    msg=Number of PDU Session Resource Modify Request messages (${PDU_session_resource_modify_req}) is not equal to 1
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${PDU_session_resource_modify_resp}==${1}
    ...    msg=Number of PDU Session Resource Modify Response messages (${PDU_session_resource_modify_resp}) is not equal to 1

Prepare Packet Filters
    [Arguments]    ${qosflows_nr}    ${pdu_id}    ${procedure}
    @{pdu_list}    String.SPLIT STRING    ${pdu_id}    ,
    @{qosflows_list}    String.SPLIT STRING    ${qosflows_nr}    ,
    ${PDU_session_req}    SET VARIABLE
    ...    ngap.PDUSessionResourceModifyRequest_element
    ${PDU_session_resp}    SET VARIABLE
    ...    ngap.PDUSessionResourceModifyResponse_element
    FOR    ${pdu}    IN    @{pdu_list}
        ${PDU_session_req}    SET VARIABLE    ${PDU_session_req} && ngap.pDUSessionID == ${pdu}
        ${PDU_session_resp}    SET VARIABLE    ${PDU_session_resp} && ngap.pDUSessionID == ${pdu}
    END
    IF      "${procedure}" == "add"
        FOR    ${qosflows}    IN    @{qosflows_list}
            ${PDU_session_req}    SET VARIABLE    ${PDU_session_req} && ngap.qosFlowIdentifier == ${qosflows}
            ${PDU_session_resp}    SET VARIABLE    ${PDU_session_resp} && ngap.qosFlowIdentifier == ${qosflows}
        END
    ELSE
         FOR    ${qosflows}    IN    @{qosflows_list}
            ${PDU_session_req}    SET VARIABLE    ${PDU_session_req} && ngap.qosFlowIdentifier == ${qosflows}
            ${PDU_session_resp}    SET VARIABLE    ${PDU_session_resp} && !ngap.qosFlowIdentifier == ${qosflows}
        END
    END
    [Return]    ${PDU_session_req}    ${PDU_session_resp}
