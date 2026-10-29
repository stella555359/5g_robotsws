*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    verify_RRC_Reconfiguration.robot
Resource    verify_PDUSessionSetupModifyRelease.robot
Library    ../../Python/pdu_session_qosflow_modification.py

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
    EXPECT FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCReconfiguration

    ${pdu_id}    Get From Dictionary    ${session_name_to_pdu}   ${session_type}
    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Run keyword and continue on failure
    ...     Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} gw=${current_gw_id} nwslice=1
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=${pdu_id} using PDU Gateway ID
    ${current_gw_id}     Evaluate  ${current_gw_id} + 1
    Set Test Variable    ${current_gw_id}

    FAIL FLOW[timeout=3]: AMF1 NGAP pDUSessionResourceSetup - messages not occur due to ICS with PDU session setup
    PASS FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCReconfiguration

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
    Verify in NGAP that QoS flows for 5QIs [${qos_add}] were successfully added to PDU${pdu_id} session
    Verify in NGAP that QoS flows for 5QIs [${qos_del}] were successfully released from PDU${pdu_id} session

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    Verify in RRCReconfiguration that UE${ue_id} ${length_of_qos_to_add_list} DRBs were added
    Verify in RRCReconfiguration that UE${ue_id} ${length_of_qos_to_del_list} DRBs were released

Trigger PDU session modification
    [Documentation]    Trigger multiple PDU session modification.
    ...    ue_id:       one UE ID, eg: '1'
    ...    pdu:         one or multiple PDU sessions, eg: '2' or '1;2'
    ...    success:     bool, set to 'True' if not all qosflow addition/release/modification is accepted by gNB
    ...    params qos_to_add, qos_to_del, qos_to_mod, ul_tnl, dl_tnl_ip must have number of entries the same as param pdu
    ...    entries for the same PDU are separated by ','
    ...    entries fo next PDU are separated by ';'
    ...         usage example:
	...         ue_id=1
	...         pdu=1;2
	...         qos_to_add=1(5QI1),2(5QI2);2(5QI2)
	...         qos_to_del=;4(5QI4)
	...         qos_to_mod=;5(5QI6->5QI7),8(5QI8->GBR_5QI1),1(GBR_5QI1->5QI5)
	...         ul_tnl=teid_only;ip_only
	...         dl_tnl_ip=1.2.3.200;1.2.3.201
	...   When 5QI is requested to be modified (via qos_to_mod param), this keyword executes qosflow_modify command and
	...   disturb initial qosflow configuration from lua/cfg file. To restore it, please use additional keywords:
	...   save_initial_qosflow_configuration_from_egate - in suite setup or in TC setup
	...   restore_initial_qosflow_configuration_in_egate - in TC teardown, or after this keyword execution

    [Arguments]    ${ue_id}    ${pdu}
    ...            ${qos_to_add}=${EMPTY}    ${qos_to_del}=${EMPTY}    ${qos_to_mod}=${EMPTY}
    ...            ${ul_tnl}=${EMPTY}    ${dl_tnl_ip}=${EMPTY}
    ...            ${by}=amf    ${amf_id}=1    ${validation}=on
    ...            ${success}=${True}

    &{params}=    Create dictionary    pdu=${pdu}    qos_to_add=${qos_to_add}    qos_to_del=${qos_to_del}
    ...                                qos_to_mod=${qos_to_mod}    ul_tnl=${ul_tnl}    dl_tnl_ip=${dl_tnl_ip}
    ${qosflow_mod_cmd}=    prepare_qosflow_modify_cmd_for_5qi_change    qos_to_mod=${qos_to_mod}
    FOR    ${cmd}    IN    @{qosflow_mod_cmd}
        Execute egate command    cmd=${cmd}
    END

    ${pdu_mod}=    prepare_part_of_ue_pdu_session_modification_cmd    &{params}
    ${ue_pdu_session_mod}=    Add Strings    ue_pdu_session_modify ue=${ue_id}    ${pdu_mod}    by=${by}    validation=${validation}

    Run Keyword If  '${success}' == '${True}'
    ...    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP pDUSessionResourceModify
    Execute egate command   cmd=${ue_pdu_session_mod}
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP pDUSessionResourceModify

    Return From Keyword If  '${success}' != '${True}'
    @{pdu_list}=   Split To List       ${pdu}    separator=;
    ${5qi_mod_add_all_pdus}=    set variable
    ${5qi_rel_all_pdus}=    set variable
    FOR    ${pdu_id}    IN    @{pdu_list}
        ${5qi_mod_add}=    get_5qi_add_mod_per_pdu    ${pdu_id}    &{params}
        ${5qi_rel}=        get_5qi_rel_per_pdu    ${pdu_id}    &{params}
        ${5qi_changed}=    get_old_5qi_changed_per_pdu    ${pdu_id}    &{params}
        Verify in NGAP that QoS flows for 5QIs [${5qi_mod_add}] were successfully added to PDU${pdu_id} session
        Verify in NGAP that QoS flows for 5QIs [${5qi_rel}] were successfully released from PDU${pdu_id} session
        ${5qi_mod_add_all_pdus}    add to string    ${5qi_mod_add_all_pdus}    ${5qi_mod_add}
        ${5qi_rel_all_pdus}        add_strings    SEPARATOR=,    ${5qi_rel_all_pdus}    ${5qi_rel}    ${5qi_changed}
    END
    @{qos_to_add_mod_list}=   Split To List       ${5qi_mod_add_all_pdus}
    @{qos_to_del_list}=       Split To List       ${5qi_rel_all_pdus}
    ${length_of_5qi_to_add_mod_list}=  Get length    ${qos_to_add_mod_list}
    ${length_of_5qi_to_del_list}=      Get length    ${qos_to_del_list}

    Return From Keyword If  '${length_of_5qi_to_add_mod_list}' == '0' and '${length_of_5qi_to_del_list}' == '0'
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    Verify in RRCReconfiguration that UE${ue_id} ${length_of_5qi_to_add_mod_list} DRBs were added
    Verify in RRCReconfiguration that UE${ue_id} ${length_of_5qi_to_del_list} DRBs were released

