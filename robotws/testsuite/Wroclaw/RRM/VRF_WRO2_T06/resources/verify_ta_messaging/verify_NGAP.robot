*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Resource    ../verify_ta_messaging/verify_common_keywords.robot
*** Keywords ***

Verify In NGAP ${message}_${n:\d+} Out Of ${all:\d+} That ${field} Is Set To ${value} For AMF${amf_id:\d+}
        ${procedure}=     Set variable if
    ...     '${message}'=='PDUSessionResourceModifyIndication'         pDUSessionResourceModifyIndication
    ...     '${message}'=='PDUSessionResourceModifyConfirm'            pDUSessionResourceModifyIndication
    ...     '${message}'=='PDUSessionResourceModifyRequest'            pDUSessionResourceModify
    ...     '${message}'=='PDUSessionResourceModifyResponse'           pDUSessionResourceModify
    ...     '${message}'=='InitialContextSetupRequest'                 initialContextSetup
    ...     '${message}'=='InitialContextSetupResponse'                initialContextSetup
    ...     '${message}'=='PDUSessionResourceReleaseCommand'           pDUSessionResourceRelease
    ...     '${message}'=='PDUSessionResourceReleaseResponse'          pDUSessionResourceRelease
    ...     '${message}'=='UEContextReleaseCommand'                    UEContextRelease
    ...     '${message}'=='SNodeAdditionRequest'                       sNGRANnodeAdditionPreparationFailure
    ...     '${message}'=='SNodeAdditionRequestReject'                 sNGRANnodeAdditionPreparationFailure

   Verify That Field In Message Is Set To Specific Value
    ...    procedure=${procedure}    device=AMF${amf_id}   protocol=NGAP    message=${message}
    ...    n=${n}    all=${all}    field=${field}    value=${value}

Verify In NGAP ${message}_${n:\d+} Out Of ${all:\d+} That ${field} Is Present For AMF${amf_id:\d+}
       ${procedure}=     Set variable if
    ...     '${message}'=='PDUSessionResourceModifyIndication'         pDUSessionResourceModifyIndication
    ...     '${message}'=='PDUSessionResourceModifyConfirm'            pDUSessionResourceModifyIndication
    ...     '${message}'=='PDUSessionResourceModifyRequest'            pDUSessionResourceModify
    ...     '${message}'=='PDUSessionResourceModifyResponse'           pDUSessionResourceModify
    ...     '${message}'=='InitialContextSetupRequest'                 initialContextSetup
    ...     '${message}'=='InitialContextSetupResponse'                initialContextSetup
    ...     '${message}'=='UEContextReleaseCommand'                    UEContextRelease

    Verify In Message That Field Is Present
    ...    procedure=${procedure}   device=AMF${amf_id}   protocol=NGAP    message=${message}
    ...    n=${n}    all=${all}    field=${field}

Verify In NGAP ${message}_${n:\d+} Out Of ${all:\d+} That ${field_1:\S+} Has ${field_2:\S+} Set To ${value:\S+} For AMF${amf_id:\d+}
       ${procedure}=     Set variable if
    ...     '${message}'=='PDUSessionResourceModifyIndication'         pDUSessionResourceModifyIndication
    ...     '${message}'=='PDUSessionResourceModifyConfirm'            pDUSessionResourceModifyIndication
    ...     '${message}'=='PDUSessionResourceModifyRequest'            pDUSessionResourceModify
    ...     '${message}'=='PDUSessionResourceModifyResponse'           pDUSessionResourceModify
    ...     '${message}'=='InitialContextSetupRequest'                 initialContextSetup
    ...     '${message}'=='InitialContextSetupResponse'                initialContextSetup
    ...     '${message}'=='UEContextReleaseRequest'                    uEContextReleaseRequest
    ...     '${message}'=='UEContextReleaseCommand'                    uEContextRelease

   Verify In Message That Field_1 Is Present And Has Field_2 Set To Specific Value
    ...    procedure=${procedure}    device=AMF${amf_id}    protocol=NGAP    message=${message}
    ...    n=${n}    all=${all}    field_1=${field_1}    field_2=${field_2}    value=${value}

Verify In NGAP ${message}_${n:\d+} Out Of ${all:\d+} That List ${list:\S+} Has ${x:\d+} Element/s For AMF${amf_id:\d+}
     ${procedure}=     Set variable if
    ...     '${message}'=='PDUSessionResourceModifyIndication'         pDUSessionResourceModifyIndication
    ...     '${message}'=='PDUSessionResourceModifyConfirm'            pDUSessionResourceModifyIndication
    ...     '${message}'=='InitialContextSetupRequest'                 initialContextSetup
    ...     '${message}'=='InitialContextSetupResponse'                initialContextSetup

    Verify Length Of List In Message
    ...    procedure=${procedure}    device=AMF${amf_id}   protocol=NGAP    message=${message}
    ...    n=${n}    all=${all}    list=${list}    length=${x}

Verify In NGAP ${message}_${n:\d+} Out Of ${all:\d+} That ${field} Is Not Present For AMF${amf_id:\d+}
     ${procedure}=     Set variable if
    ...     '${message}'=='PDUSessionResourceModifyIndication'         pDUSessionResourceModifyIndication
    ...     '${message}'=='PDUSessionResourceModifyConfirm'            pDUSessionResourceModifyIndication
    ...     '${message}'=='InitialContextSetupRequest'                 initialContextSetup
    ...     '${message}'=='InitialContextSetupResponse'                initialContextSetup

    Verify In Message That Field Is Not Present
    ...    procedure=${procedure}   device=AMF${amf_id}   protocol=NGAP    message=${message}
    ...    n=${n}    all=${all}    field=${field}

Verify In NGAP ${message}_${n:\d+} Out Of ${all:\d+} ${field} Is Set To "${cause_type}: ${cause_message}" For AMF${amf_id:\d+}
     ${procedure}=     Set variable if
    ...     '${message}'=='PDUSessionResourceReleaseCommand'           pDUSessionResourceRelease
    ...     '${message}'=='PDUSessionResourceReleaseResponse'          pDUSessionResourceRelease
    ...     '${message}'=='UEContextReleaseCommand'                    uEContextRelease
    ...     '${message}'=='UEContextReleaseRequest'                    uEContextReleaseRequest

    Verify In Message That Cause Is Set To
    ...    procedure=${procedure}   device=AMF${amf_id}    protocol=NGAP    message=${message}     field=${field}
    ...    n=${n}    all=${all}     cause_type=${cause_type}    cause_message=${cause_message}
