*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Library     ../resources/KeywordsCB008490.py
Resource    ../verify_ta_messaging/verify_common_keywords.robot
*** Keywords ***

Verify In E1AP ${message}_${n:\d+} Out Of ${all:\d+} That ${field} Is Set To ${value} For GNB${gnb:\d+}
        ${procedure}=     Set variable if
    ...     '${message}'=='BearerContextModificationRequest'             bearerContextModification
    ...     '${message}'=='BearerContextModificationResponse'            bearerContextModification

   Verify That Field In Message Is Set To Specific Value
    ...    procedure=${procedure}    device=gNB${gnb}    protocol=E1AP    message=${message}
    ...    n=${n}    all=${all}    field=${field}    value=${value}

Verify In E1AP ${message}_${n:\d+} Out Of ${all:\d+} That ${field} Is Present For GNB${gnb:\d+}
    ${procedure}=     Set variable if
    ...     '${message}'=='BearerContextModificationRequest'             bearerContextModification
    ...     '${message}'=='BearerContextModificationResponse'            bearerContextModification

    Verify In Message That Field Is Present
    ...    procedure=${procedure}   device=gNB${gnb}   protocol=E1AP    message=${message}
    ...    n=${n}    all=${all}    field=${field}

Verify In E1AP ${message}_${n:\d+} Out Of ${all:\d+} That List ${list:\S+} Has ${x:\d+} Element/s For GNB${gnb:\d+}
        ${procedure}=     Set variable if
    ...     '${message}'=='BearerContextModificationRequest'              bearerContextModification
    ...     '${message}'=='BearerContextModificationResponse'             bearerContextModification

    Verify Length Of List In Message
    ...    procedure=${procedure}    device=gNB${gnb}    protocol=E1AP    message=${message}
    ...    n=${n}    all=${all}    list=${list}    length=${x}

Verify In E1AP ${message}_${n:\d+} Out Of ${all:\d+} That ${field_1:\S+} Has ${field_2:\S+} Set To ${value:\S+} For GNB${gnb:\d+}
    ${procedure}=     Set variable if
    ...     '${message}'=='BearerContextModificationRequest'              bearerContextModification
    ...     '${message}'=='BearerContextModificationResponse'             bearerContextModification
    ...     '${message}'=='BearerContextReleaseCommand'                   bearerContextRelease
    ...     '${message}'=='BearerContextReleaseComplete'                  bearerContextRelease
    ...     '${message}'=='BearerContextModificationRequired'             bearerContextModificationRequired
    ...     '${message}'=='BearerContextModificationRequired'             bearerContextModificationRequired

   Verify In Message That Field_1 Is Present And Has Field_2 Set To Specific Value
    ...    procedure=${procedure}    device=gNB${gnb}    protocol=E1AP    message=${message}
    ...    n=${n}    all=${all}    field_1=${field_1}    field_2=${field_2}    value=${value}

Verify In E1AP ${message}_${n:\d+} Out Of ${all:\d+} That ${field_1:\S+} Contains ${field_2:\S+} And ${field_3:\S+} For GNB${gnb:\d+}
    ${procedure}=     Set variable if
    ...     '${message}'=='BearerContextModificationRequest'              bearerContextModification
    ...     '${message}'=='BearerContextModificationResponse'             bearerContextModification

   Verify In Message That Field_1 Is Present And Contains Field_2 And Field_3
    ...    procedure=${procedure}    device=gNB${gnb}    protocol=E1AP    message=${message}
    ...    n=${n}    all=${all}    field_1=${field_1}    field_2=${field_2}    field_3=${field_3}

Verify In E1AP ${message}_${n:\d+} Out Of ${all:\d+} That ${field_1} Is Present And Has ${field_2} For GNB${gnb:\d+}
    ${procedure}=     Set variable if
    ...     '${message}'=='BearerContextModificationRequest'             bearerContextModification
    ...     '${message}'=='BearerContextModificationResponse'            bearerContextModification

    Verify In Message That Field_1 Is Present And Has Field_2
    ...    procedure=${procedure}   device=gNB${gnb}   protocol=E1AP    message=${message}
    ...    n=${n}    all=${all}    field_1=${field_1}    field_2=${field_2}

Verify In E1AP ${message}_${n:\d+} Out Of ${all:\d+} ${field} Is Set To "${cause_type}: ${cause_message}" For GNB${gnb:\d+}
     ${procedure}=     Set variable if
    ...     '${message}'=='BearerContextReleaseCommand'                   bearerContextRelease
    ...     '${message}'=='BearerContextReleaseComplete'                  bearerContextRelease

    Verify In Message That Cause Is Set To
    ...    procedure=${procedure}   device=gNB${gnb}   protocol=E1AP    message=${message}     field=${field}
    ...    n=${n}    all=${all}     cause_type=${cause_type}    cause_message=${cause_message}
