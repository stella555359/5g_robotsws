*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    verify_RRC_Reconfiguration.robot
Resource    verify_PDUSessionSetupModifyRelease.robot

*** Variables ***
&{session_name_to_pdu}=     initial=1       first=1      second=2      third=3      fourth=4
${current_gw_id}=           1
# below variable must be overwritten in you suite with values matching lua configuration!
&{5QI_TO_EGATE_QOS_FLOW_ID}=  1=1  2=2  3=3  4=4  71=5  72=6  76=7  128=8  212=9  254=10  5=11  6=12  7=13  8=14  9=15  170=16

*** Keywords ***
Add to UE${ue_id:\d+} ${session_type:(initial|second|third)} PDU session after ICS
    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

    ${pdu_id}    Get From Dictionary    ${session_name_to_pdu}   ${session_type}
    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Run keyword and continue on failure
    ...     Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} gw=${current_gw_id} nwslice=1
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=${pdu_id} using PDU Gateway ID
    ${current_gw_id}     Evaluate  ${current_gw_id} + 1
    Set Test Variable    ${current_gw_id}

    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

Add to UE${ue_id:\d+} ${session_type:(initial|second|third)} PDU session with ICS
    EXPECT FLOW[timeout=3]: AMF1 NGAP pDUSessionResourceSetup - messages not occur due to ICS with PDU session setup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

    ${pdu_id}    Get From Dictionary    ${session_name_to_pdu}   ${session_type}
    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Run keyword and continue on failure
    ...     Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} gw=${current_gw_id} nwslice=1
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=${pdu_id} using PDU Gateway ID
    ${current_gw_id}     Evaluate  ${current_gw_id} + 1
    Set Test Variable    ${current_gw_id}

    FAIL FLOW[timeout=3]: AMF1 NGAP pDUSessionResourceSetup - messages not occur due to ICS with PDU session setup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

Release ${session_type:(initial|first|second|third|fourth)} PDU session for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceRelease
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

    ${pdu_id}       Get From Dictionary         ${session_name_to_pdu}         ${session_type}
    Run keyword and continue on failure
    ...     Run command    ue_pdu_session_release  ue=${ue_id}  pdu=${pdu_id}  by=amf

    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceRelease
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [${qos_add}] and delete QoS flows with 5QI from list [${qos_del}]${via}
    @{qos_to_add_list}=   Split To List       ${qos_add}
    @{qos_to_del_list}=   Split To List       ${qos_del}
    ${length_of_qos_to_add_list}=  Get length    ${qos_to_add_list}
    ${length_of_qos_to_del_list}=  Get length    ${qos_to_del_list}

    ${qos_ids_add}=    Set Variable
    ${qos_ids_del}=    Set Variable

    ${via_type}=            Set variable if     '${via}'==' via amf'    amf      ue
    ${mapping}=    get variable value           ${USER_5QI_TO_EGATE_QOS_FLOW_ID}        ${5QI_TO_EGATE_QOS_FLOW_ID}
    FOR  ${5qi}  IN  @{qos_to_add_list}
        ${qos_flow_id}    Get From Dictionary    ${mapping}   ${5qi}
        ${qos_ids_add}=   Add To String    ${qos_ids_add}    ${qos_flow_id}
    END

    FOR  ${5qi}  IN  @{qos_to_del_list}
        ${qos_flow_id}    Get From Dictionary    ${mapping}   ${5qi}
        ${qos_ids_del}=   Add To String    ${qos_ids_del}    ${qos_flow_id}
    END

    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    ${add_del_cmd}=     Catenate   ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_ids_add}
    ...                            qosflows_to_del=${qos_ids_del} by=${via_type}
    Run Keyword If    ${length_of_qos_to_add_list} > 0 and ${length_of_qos_to_del_list} > 0
    ...  Execute egate command   cmd=${add_del_cmd}

    Run Keyword If    ${length_of_qos_to_add_list} > 0 and ${length_of_qos_to_del_list} == 0
    ...  Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_ids_add} by=${via_type}

    Run Keyword If    ${length_of_qos_to_add_list} == 0 and ${length_of_qos_to_del_list} > 0
    ...  Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qos_ids_del} by=${via_type}

    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    Verify in NGAP that QoS flows for 5QIs [${qos_add}] were successfully added to existing PDU session
    Verify in NGAP that QoS flows for 5QIs [${qos_del}] were successfully released from existing PDU session

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    Verify in RRCReconfiguration that UE${ue_id} ${length_of_qos_to_add_list} DRBs were added
    Verify in RRCReconfiguration that UE${ue_id} ${length_of_qos_to_del_list} DRBs were released