*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Library     testsuite/Wroclaw/RRM/VRF_WRO2_T06/CB008490/resources/KeywordsCB008490.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/UnparsedContainers.py
Resource    ../verify_ta_messaging/verify_common_keywords.robot

*** Keywords ***
Verify In XNAP ${message}_${n:\d+} Out Of ${all:\d+} That ${field} Is Set To ${value:\S+} For GNB${gnb:\d+}

    ${procedure}=     Set variable if
    ...     '${message}'=='SNodeAdditionRequest'                       sNGRANnodeAdditionPreparation
    ...     '${message}'=='SNodeAdditionRequestAcknowledge'            sNGRANnodeAdditionPreparation
    ...     '${message}'=='XnUAddressIndication'                       xnUAddressIndication
    ...     '${message}'=='SNStatusTransfer'                           sNStatusTransfer
    ...     '${message}'=='SNodeReleaseRequest'                        mNGRANnodeinitiatedSNGRANnodeRelease
    ...     '${message}'=='SNodeReleaseRequestAcknowledge'             mNGRANnodeinitiatedSNGRANnodeRelease
    ...     '${message}'=='SNodeAdditionRequestReject'                 sNGRANnodeAdditionPreparationFailure

   Verify That Field In Message Is Set To Specific Value
    ...    procedure=${procedure}    device=gNB${gnb}    protocol=XNAP    message=${message}
    ...    n=${n}    all=${all}    field=${field}    value=${value}

Verify In XNAP ${message}_${n:\d+} Out Of ${all:\d+} That ${field} Is Present For GNB${gnb:\d+}
    ${procedure}=     Set variable if
    ...     '${message}'=='SNodeAdditionRequest'                       sNGRANnodeAdditionPreparation
    ...     '${message}'=='SNodeAdditionRequestAcknowledge'            sNGRANnodeAdditionPreparation
    ...     '${message}'=='XnUAddressIndication'                       xnUAddressIndication
    ...     '${message}'=='SNStatusTransfer'                           sNStatusTransfer
    ...     '${message}'=='SNodeReleaseRequest'                        mNGRANnodeinitiatedSNGRANnodeRelease
    ...     '${message}'=='SNodeReleaseRequestAcknowledge'             mNGRANnodeinitiatedSNGRANnodeRelease

    Verify In Message That Field Is Present
    ...    procedure=${procedure}   device=gNB${gnb}   protocol=XNAP    message=${message}
    ...    n=${n}    all=${all}    field=${field}

Verify In XNAP ${message}_${n:\d+} Out Of ${all:\d+} That ${field_1:\S+} Contains ${field_2:\S+} Set To ${value:\S+} For GNB${gnb:\d+}
    ${procedure}=     Set variable if
    ...     '${message}'=='SNodeAdditionRequest'                       sNGRANnodeAdditionPreparation
    ...     '${message}'=='SNodeAdditionRequestAcknowledge'            sNGRANnodeAdditionPreparation
    ...     '${message}'=='XnUAddressIndication'                       xnUAddressIndication
    ...     '${message}'=='SNStatusTransfer'                           sNStatusTransfer
    ...     '${message}'=='SNodeReleaseRequest'                        mNGRANnodeinitiatedSNGRANnodeRelease
    ...     '${message}'=='SNodeReleaseRequestAcknowledge'             mNGRANnodeinitiatedSNGRANnodeRelease

   Verify In Message That Field_1 Is Present And Has Field_2 Set To Specific Value
    ...    procedure=${procedure}    device=gNB${gnb}   protocol=XNAP    message=${message}
    ...    n=${n}    all=${all}    field_1=${field_1}    field_2=${field_2}    value=${value}

Verify In XNAP ${message}_${n:\d+} Out Of ${all:\d+} That ${field_1:\S+} Contains ${field_2:\S+} For GNB${gnb:\d+}
    ${procedure}=     Set variable if
    ...     '${message}'=='SNodeAdditionRequest'                       sNGRANnodeAdditionPreparation
    ...     '${message}'=='SNodeAdditionRequestAcknowledge'            sNGRANnodeAdditionPreparation
    ...     '${message}'=='XnUAddressIndication'                       xnUAddressIndication
    ...     '${message}'=='SNStatusTransfer'                           sNStatusTransfer
    ...     '${message}'=='SNodeReleaseRequest'                        mNGRANnodeinitiatedSNGRANnodeRelease
    ...     '${message}'=='SNodeReleaseRequestAcknowledge'             mNGRANnodeinitiatedSNGRANnodeRelease

   Verify In Message That Field_1 Is Present And Has Field_2
    ...    procedure=${procedure}    device=gNB${gnb}    protocol=XNAP    message=${message}
    ...    n=${n}    all=${all}    field_1=${field_1}    field_2=${field_2}

Verify in XNAP ${message}_${n:\d+} Out Of ${all:\d+} That ${field_1:\S+} Has ${field_2:\S+} Set To ${value:\S+} For GNB${gnb:\d+}

    ${procedure}=     Set variable if
    ...     '${message}'=='SNodeAdditionRequest'                       sNGRANnodeAdditionPreparation
    ...     '${message}'=='SNodeAdditionRequestAcknowledge'            sNGRANnodeAdditionPreparation
    ...     '${message}'=='XnUAddressIndication'                       xnUAddressIndication
    ...     '${message}'=='SNStatusTransfer'                           sNStatusTransfer
    ...     '${message}'=='SNodeReleaseRequest'                        mNGRANnodeinitiatedSNGRANnodeRelease
    ...     '${message}'=='SNodeReleaseRequestAcknowledge'             mNGRANnodeinitiatedSNGRANnodeRelease
    ...     '${message}'=='SNodeReleaseRequired'                       sNGRANnodeinitiatedSNGRANnodeRelease
    ...     '${message}'=='ErrorIndication'                            errorIndication

   Verify In Message That Field_1 Is Present And Has Field_2 Set To Specific Value
    ...    procedure=${procedure}    device=gNB${gnb}    protocol=XNAP    message=${message}
    ...    n=${n}    all=${all}    field_1=${field_1}    field_2=${field_2}    value=${value}

Verify In XNAP ${message}_${n:\d+} Out Of ${all:\d+} That List ${list:\S+} Has ${x:\d+} Element/s For GNB${gnb:\d+}
        ${procedure}=     Set variable if
    ...     '${message}'=='SNodeAdditionRequest'                       sNGRANnodeAdditionPreparation
    ...     '${message}'=='SNodeAdditionRequestAcknowledge'            sNGRANnodeAdditionPreparation
    ...     '${message}'=='XnUAddressIndication'                       xnUAddressIndication
    ...     '${message}'=='SNStatusTransfer'                           sNStatusTransfer

    Verify Length Of List In Message    procedure=${procedure}    device=gNB${gnb}    protocol=XNAP    message=${message}    n=${n}    all=${all}
    ...    list=${list}    length=${x}

Verify In XNAP ${message}_${n:\d+} Out Of ${all:\d+} That ${field:\S+} Has ${value:\S+} For GNB${gnb:\d+}
        ${procedure}=     Set variable if
    ...     '${message}'=='SNodeAdditionRequest'                       sNGRANnodeAdditionPreparation
    ...     '${message}'=='SNodeAdditionRequestAcknowledge'            sNGRANnodeAdditionPreparation
    ...     '${message}'=='XnUAddressIndication'                       xnUAddressIndication
    ...     '${message}'=='SNStatusTransfer'                           sNStatusTransfer
    ...     '${message}'=='XnSetupRequest'                             xnSetup
    ...     '${message}'=='XnSetupResponse'                            xnSetup

    Verify That Field In Message Has Value    procedure=${procedure}    device=gNB${gnb}    protocol=XNAP    message=${message}    n=${n}
    ...    all=${all}    field=${field}    value=${value}

Verify In XNAP ${message}_${n:\d+} Out Of ${all:\d+} That ${field:\S+} Does NOT Contain ${value:\S+} For GNB${gnb:\d+}
        ${procedure}=     Set variable if
    ...     '${message}'=='SNodeAdditionRequest'                       sNGRANnodeAdditionPreparation
    ...     '${message}'=='SNodeAdditionRequestAcknowledge'            sNGRANnodeAdditionPreparation
    ...     '${message}'=='XnUAddressIndication'                       xnUAddressIndication
    ...     '${message}'=='SNStatusTransfer'                           sNStatusTransfer
    ...     '${message}'=='XnSetupRequest'                             xnSetup
    ...     '${message}'=='XnSetupResponse'                            xnSetup

    Verify That Field Does NOT Contain Value Is Message    procedure=${procedure}    device=gNB${gnb}    protocol=XNAP    message=${message}    n=${n}
    ...    all=${all}    field=${field}    value=${value}

Verify In XNAP ${message}_${n:\d+} Out Of ${all:\d+} ${field} Is Set To "${cause_type}: ${cause_message}" For GNB${gnb:\d+}
     ${procedure}=     Set variable if
    ...     '${message}'=='SNodeAdditionRequest'                       sNGRANnodeAdditionPreparationFailure
    ...     '${message}'=='SNodeAdditionRequestReject'                 sNGRANnodeAdditionPreparationFailure

    Verify In Message That Cause Is Set To
    ...    procedure=${procedure}   device=gNB${gnb}   protocol=XNAP    message=${message}     field=${field}
    ...    n=${n}    all=${all}     cause_type=${cause_type}    cause_message=${cause_message}

Verify In XNAP ${message}_${n:\d+} Out Of ${all:\d+} In ${container:\S+} That ${field:\S+} Set To ${value:\S+} For GNB${gnb:\d+}
    ${flow_alias}=    Get Flow Alias    device=gNB${gnb}    all=${all}    procedure=sNGRANnodeAdditionPreparation    protocol=XNAP
    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    UnparsedContainers.Verify If Rrc5g Container Contains
    ...    flow_alias=${flow_alias}
    ...    message_alias=${message}${suffix}
    ...    field=${field}
    ...    value=${value}
    ...    unparsed_container_key=STRING
    ...    IE_name=${container}

Verify In XNAP ${message}_${n:\d+} Out Of ${all:\d+} That ${field:\S+} Is Present In ${container:\S+} For GNB${gnb:\d+}
    ${flow_alias}=    Get Flow Alias    device=gNB${gnb}     all=${all}    procedure=sNGRANnodeAdditionPreparation    protocol=XNAP
    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    UnparsedContainers.Verify If Rrc5g Container Contains
    ...    flow_alias=${flow_alias}
    ...    message_alias=${message}${suffix}
    ...    field=${field}
    ...    value=is present
    ...    unparsed_container_key=STRING
    ...    IE_name=${container}

Verify In XNAP ${message}_${n:\d+} Out Of ${all:\d+} That ${field:\S+} On Index ${index:\d+} Is Set To ${value:\S+} In ${cont:\S+} For GNB${gnb:\d+}
    ${flow_alias}=    Get Flow Alias    device=gNB${gnb}    all=${all}    procedure=sNGRANnodeAdditionPreparation    protocol=XNAP
    ${suffix}=    Set Index    all=${all}    msg_index=${n}
    UnparsedContainers.Verify If Rrc5g Container Contains Non Unique Value
    ...    flow_alias=${flow_alias}
    ...    message_alias=${message}${suffix}
    ...    field=${field}
    ...    value=${value}
    ...    unparsed_container_key=STRING
    ...    IE_name=${cont}
    ...    index_of_value=${index}

Verify In XNAP ${message}_${n:\d+} Out Of ${all:\d+} That ${field:\S+} Is Equal To ${list} In ${cont:\S+} For GNB${gnb:\d+}
    ${flow_alias}=    Get Flow Alias    device=gNB${gnb}    all=${all}    procedure=sNGRANnodeAdditionPreparation    protocol=XNAP
    ${suffix}=    Set Index    all=${all}    msg_index=${n}
    UnparsedContainers.Verify Multiple Values Of Field In RRC5G Container
    ...    flow_alias=${flow_alias}
    ...    message_alias=${message}${suffix}
    ...    field=${field}
    ...    list_to_compare=${list}
    ...    unparsed_container_key=STRING
    ...    IE_name=${cont}

Verify In XNAP ${message}_${n:\d+} Out Of ${all:\d+} That ${field:\S+} Is Not Present In ${cont:\S+} For GNB${gnb:\d+}
    ${flow_alias}=    Get Flow Alias    device=gNB${gnb}    all=${all}    procedure=sNGRANnodeAdditionPreparation    protocol=XNAP
    ${suffix}=    Set Index    all=${all}    msg_index=${n}
    UnparsedContainers.Verify If Rrc5g Container Doesnt Contain Field
    ...    flow_alias=${flow_alias}
    ...    message_alias=${message}${suffix}
    ...    field=${field}
    ...    unparsed_container_key=STRING
    ...    IE_name=${cont}

Verify In XNAP ${message}_${n:\d+} Out Of ${all:\d+} That ${field:\S+} Is Present ${x:\d+} Times In ${cont:\S+} For GNB${gnb:\d+}
    ${flow_alias}=    Get Flow Alias    device=gNB${gnb}    all=${all}    procedure=sNGRANnodeAdditionPreparation    protocol=XNAP
    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    UnparsedContainers.Verify That Field Is Present X Times In RRC5G Container
    ...    flow_alias=${flow_alias}
    ...    message_alias=${message}${suffix}
    ...    field=${field}
    ...    expected_occurrences=${x}
    ...    unparsed_container_key=STRING
    ...    IE_name=${cont}

Verify In XNAP ${message}_${n:\d+} Out Of ${all:\d+} That ${field:\S+} Is Not Present ${x:\d+} Times In ${cont:\S+} For GNB${gnb:\d+}
    ${flow_alias}=    Get Flow Alias    device=gNB${gnb}    all=${all}    procedure=sNGRANnodeAdditionPreparation    protocol=XNAP
    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    UnparsedContainers.Verify That Field Is Not Present X Times In RRC5G field
    ...    flow_alias=${flow_alias}
    ...    message_alias=${message}${suffix}
    ...    field=${field}
    ...    expected_occurrences=${x}
    ...    unparsed_container_key=STRING
    ...    IE_name=${cont}
