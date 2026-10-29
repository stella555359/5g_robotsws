*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Library     testsuite/Wroclaw/RRM/VRF_WRO2_T06/CB008490/resources/KeywordsCB008490.py
Resource    ../verify_ta_messaging/verify_common_keywords.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/UnparsedContainers.py

*** Keywords ***

Verify In F1AP ${message}_${n:\d+} Out Of ${all:\d+} That ${field} Is Present For GNB${gnb:\d+}
    ${procedure}=     Set variable if
    ...     '${message}'=='UEContextModificationRequest'             uEContextModification
    ...     '${message}'=='UEContextModificationResponse'            uEContextModification
    ...     '${message}'=='UEContextSetupRequest'                    uEContextSetup
    ...     '${message}'=='UEContextSetupResponse'                   uEContextSetup
    ...     '${message}'=='UEContextReleaseCommand'                  uEContextRelease
    ...     '${message}'=='UEContextReleaseComplete'                 uEContextRelease

    Verify In Message That Field Is Present
    ...    procedure=${procedure}    device=gNB${gnb}    protocol=F1AP    message=${message}
    ...    n=${n}   all=${all}   field=${field}


Verify In F1AP ${message}_${n:\d+} Out Of ${all:\d+} That ${field} Is Not Present For GNB${gnb:\d+}
    ${procedure}=     Set variable if
    ...     '${message}'=='UEContextModificationRequest'             uEContextModification
    ...     '${message}'=='UEContextModificationResponse'            uEContextModification

    Verify In Message That Field Is Not Present
    ...    procedure=${procedure}    device=gNB${gnb}    protocol=F1AP    message=${message}
    ...    n=${n}    all=${all}    field=${field}

Verify In F1AP ${message}_${n:\d+} Out Of ${all:\d+} That ${field_1:\S+} Contains ${field_2:\S+} Set To ${value:\S+} For GNB${gnb:\d+}
    ${procedure}=     Set variable if
    ...     '${message}'=='UEContextModificationRequest'             uEContextModification
    ...     '${message}'=='UEContextModificationResponse'            uEContextModification
    ...     '${message}'=='UEContextReleaseCommand'                  uEContextRelease
    ...     '${message}'=='UEContextReleaseComplete'                 uEContextRelease
    ...     '${message}'=='UEContextSetupRequest'                    uEContextSetup
    ...     '${message}'=='UEContextSetupResponse'                   uEContextSetup
    ...     '${message}'=='UEContextModificationRequired'            uEContextModificationRequired

   Verify In Message That Field_1 Is Present And Has Field_2 Set To Specific Value
    ...    procedure=${procedure}    device=gNB${gnb}   protocol=F1AP    message=${message}
    ...    n=${n}    all=${all}    field_1=${field_1}    field_2=${field_2}    value=${value}

Verify In F1AP ${message}_${n:\d+} Out Of ${all:\d+} That ${field_1:\S+} Contains Field ${field_2} For GNB${gnb:\d+}
    ${procedure}=     Set variable if
    ...     '${message}'=='UEContextModificationRequest'             uEContextModification
    ...     '${message}'=='UEContextModificationResponse'            uEContextModification
    ...     '${message}'=='UEContextSetupRequest'                    uEContextSetup
    ...     '${message}'=='UEContextSetupResponse'                   uEContextSetup

    Verify In Message That Field_1 Is Present And Has Field_2
    ...    procedure=${procedure}    device=gNB${gnb}    protocol=F1AP    message=${message}
    ...    n=${n}   all=${all}   field_1=${field_1}    field_2=${field_2}

Verify In F1AP ${message}_${n:\d+} Out Of ${all:\d+} That ${field:\S+} Is Set To ${value:\S+} For GNB${gnb:\d+}
    ${procedure}=     Set variable if
    ...     '${message}'=='UEContextModificationRequest'             uEContextModification
    ...     '${message}'=='UEContextModificationResponse'            uEContextModification
    ...     '${message}'=='UEContextSetupRequest'                    uEContextSetup
    ...     '${message}'=='UEContextSetupResponse'                   uEContextSetup

    Verify That Field In Message Is Set To Specific Value
    ...    procedure=${procedure}    device=gNB${gnb}    protocol=F1AP    message=${message}
    ...    n=${n}    all=${all}    field=${field}     value=${value}

Verify in F1AP ${message}_${n:\d+} Out Of ${all:\d+} That List ${list:\S+} Has ${x:\d+} Element/s For GNB${gnb:\d+}
    ${procedure}=     Set variable if
    ...     '${message}'=='UEContextModificationRequest'             uEContextModification
    ...     '${message}'=='UEContextModificationResponse'            uEContextModification
    ...     '${message}'=='UEContextSetupRequest'                    uEContextSetup
    ...     '${message}'=='UEContextSetupResponse'                   uEContextSetup

    Verify Length Of List In Message    procedure=${procedure}    device=gNB${gnb}    protocol=F1AP   message=${message}   n=${n}    all=${all}
    ...    list=${list}    length=${x}

Verify In F1AP ${message}_${n:\d+} Out Of ${all:\d+} That ${field:\S+} Has ${value:\S+} For GNB${gnb:\d+}
    ${procedure}=     Set variable if
    ...     '${message}'=='UEContextModificationRequest'             uEContextModification
    ...     '${message}'=='UEContextModificationResponse'            uEContextModification
    ...     '${message}'=='UEContextReleaseCommand'                  uEContextRelease
    ...     '${message}'=='UEContextReleaseComplete'                 uEContextRelease


    Verify That Field In Message Has Value
    ...    procedure=${procedure}    device=gNB${gnb}    protocol=F1AP    message=${message}
    ...    n=${n}    all=${all}    field=${field}     value=${value}


Verify In F1AP ${message}_${n:\d+} Out Of ${all:\d+} In MeasConfig That ${field:\S+} Eq ${id:\d+} On Index ${index:\d+} For GNB${gnb}
    ${flow_alias}=    Get Flow Alias    device=gNB${gnb}   all=${all}    procedure=uEContextModification    protocol=F1AP
    ${suffix}=    Set Index    all=${all}    msg_index=${n}
    UnparsedContainers.Verify If Rrc5g Container Contains Non Unique Value
    ...     flow_alias=${flow_alias}
    ...     message_alias=${message}${suffix}
    ...     field=${field}
    ...     value=${id}
    ...     unparsed_container_key=measConfig
    ...     IE_name=MeasConfig
    ...     index_of_value=${index}

Verify In F1AP ${message}_${n:\d+} Out Of ${all:\d+} That MeasConfig Doesnt Contain ${field:\S+} For GNB${gnb}
    ${flow_alias}=    Get Flow Alias    device=gNB${gnb}   all=${all}    procedure=uEContextModification    protocol=F1AP
    ${suffix}=    Set Index    all=${all}    msg_index=${n}
    UnparsedContainers.Verify If Rrc5g Container Doesnt Contain Field
    ...     flow_alias=${flow_alias}
    ...     message_alias=${message}${suffix}
    ...     field=${field}
    ...     unparsed_container_key=measConfig
    ...     IE_name=MeasConfig

Verify In F1AP ${message}_${n:\d+} Out Of ${all:\d+} In MeasConfig That ${field:\S+} Is Present For GNB${gnb}
    ${flow_alias}=    Get Flow Alias    device=gNB${gnb}   all=${all}    procedure=uEContextModification    protocol=F1AP
    ${suffix}=    Set Index    all=${all}    msg_index=${n}
    UnparsedContainers.Verify If Rrc5g Container Contains
    ...    flow_alias=${flow_alias}
    ...    message_alias=${message}${suffix}
    ...    field=${field}
    ...    value=is present
    ...    unparsed_container_key=measConfig
    ...    IE_name=MeasConfig

Verify In F1AP ${message}_${n:\d+} Out Of ${all:\d+} In MeasConfig That Fields ${field} Are Equal ${list_to_compare}
    ${flow_alias}=    Get Flow Alias    device=gNB2   all=${all}    procedure=uEContextModification    protocol=F1AP
    ${suffix}=    Set Index    all=${all}    msg_index=${n}
    UnparsedContainers.Verify Multiple Values Of Field In Rrc5g Container
    ...     flow_alias=${flow_alias}
    ...     message_alias=${message}${suffix}
    ...     field=${field}
    ...     list_to_compare=${list_to_compare}
    ...     unparsed_container_key=measConfig
    ...     IE_name=MeasConfig

Verify In F1AP ${message}_${n:\d+} Out Of ${all:\d+} That ${field_1:\S+} Contains ${field_2:\S+} And ${field_3:\S+} For GNB${gnb:\d+}
    ${procedure}=     Set variable if
    ...     '${message}'=='UEContextModificationRequest'             uEContextModification
    ...     '${message}'=='UEContextModificationResponse'            uEContextModification

   Verify In Message That Field_1 Is Present And Contains Field_2 And Field_3
    ...    procedure=${procedure}    device=gNB${gnb}    protocol=F1AP    message=${message}
    ...    n=${n}    all=${all}    field_1=${field_1}    field_2=${field_2}    field_3=${field_3}

Verify In F1AP ${message}_${n:\d+} Out Of ${all:\d+} That ${field_1:\S+} Contains ${field_2:\S+} With Value/s [${list_values:\S+}] For GNB${gnb:\d+}
    ${procedure}=     Set variable if
    ...     '${message}'=='UEContextModificationRequest'             uEContextModification
    ...     '${message}'=='UEContextModificationResponse'            uEContextModification

   Verify In Message That Field_1 Is Present And Contains Field_2 Which Contains List Value/s
    ...    procedure=${procedure}    device=gNB${gnb}    protocol=F1AP    message=${message}
    ...    n=${n}    all=${all}    field_1=${field_1}    field_2=${field_2}    list_values=${list_values}

Verify In F1AP ${message}_${n:\d+} Out Of ${all:\d+} That ${s:\d+}-SCells Have PLMN-${PLMN:\S+} And NRCellIDs-${nrcell:\d+} For GNB${gnb:\d+}
    ${flow_alias}=    Get Flow Alias    device=gNB${gnb}   all=${all}    procedure=uEContextSetup    protocol=F1AP
    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    ${expectation}=    KeywordsCB008490.Build Query For SCellToBeSetup With Given Number Of Scells And PLMN And NRCellId
    ...     num_of_scells=${s}
    ...     plmn=${PLMN}
    ...     nrcellidentities_list=${nrcell}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=${message}${suffix}
    ...     flow_alias=${flow_alias}

    ${expectation_2}=    KeywordsCB008490.Build Query For SCellToBeSetup With Given Number Of Scells And SCellULConfigured
    ...     num_of_scells=${s}

    Verify That Message Fulfills Query
    ...     ${expectation_2}
    ...     message_alias=${message}${suffix}
    ...     flow_alias=${flow_alias}

Verify In F1AP ${message}_${n:\d+} Out Of ${all:\d+} That ${s:\d+}-SCells Are to Be Setup With SCellULConfigured Set to None For GNB${gnb:\d+}
    ${expectation}=    KeywordsCB008490.Build Query For SCellToBeSetup With Given Number Of Scells And SCellULConfigured
    ...     num_of_scells=${s}

    ${flow_alias}=    Get Flow Alias    device=gNB${gnb}   all=${all}    procedure=uEContextSetup    protocol=F1AP
    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=${message}${suffix}
    ...     flow_alias=${flow_alias}

Verify In F1AP ${message}_${n:\d+} Out Of ${all:\d+} That sCellToAddModList Has ${s:\d+}-SCells With sCellConfigCommon Present For GNB${gnb:\d+}
    ${flow_alias}=    Get Flow Alias    device=gNB${gnb}   all=${all}    procedure=uEContextSetup    protocol=F1AP
    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    ${expectation}=    KeywordsCB008490.Build Query For SCellToAddModList With Given Number Of Scells
    ...     num_of_scells=${s}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=${message}${suffix}
    ...     flow_alias=${flow_alias}

Verify In F1AP ${message}_${n:\d+} Out Of ${all:\d+} ${field} Is Set To "${cause_type}: ${cause_message}" For GNB${gnb:\d+}
     ${procedure}=     Set variable if
    ...     '${message}'=='UEContextReleaseCommand'                  uEContextRelease
    ...     '${message}'=='UEContextReleaseComplete'                 uEContextRelease

    Verify In Message That Cause Is Set To
    ...    procedure=${procedure}   device=gNB${gnb}   protocol=F1AP    message=${message}     field=${field}
    ...    n=${n}    all=${all}     cause_type=${cause_type}    cause_message=${cause_message}
