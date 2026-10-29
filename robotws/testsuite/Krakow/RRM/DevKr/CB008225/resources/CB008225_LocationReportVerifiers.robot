*** Settings ***
Library  location_report_queries.py
Library  verify_gnbid_in_areaofinterest.py

*** Variables ***
${tac_hex}=         0x0000C8
*** Keywords ***

Verify that ${msg:\S+} contains NRCELL-${cell_id:[1-3]} identity in ${field_type:(userLocationInformationNR|areaOfInterestList)}
    ${message_name}=    get_procedure_or_name_from_message_name   ${msg}    what=message
    ${procedure_name}=    get_procedure_or_name_from_message_name   ${msg}    what=procedure
    ${bin_cell_value_non_32}=      get_bin_value_from_dec      ${nrcell_ids}[NRCELL-${cell_id}]     36
    ${bin_cell_value_32_bit}=      get_bin_value_from_dec      ${nrcell_ids_32_bit}[NRCELL-${cell_id}]     36
    ${bin_cell_value}=     set variable if         ${GNB_ID_LENGTH_32}==${True}        ${bin_cell_value_32_bit}  ${bin_cell_value_non_32}
    ${location_report}=  Get Flow Name
    ...     procedure=${procedure_name}
    ...     device=AMF1
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     ${field_type} contains (nRCellIdentity eq "0b${bin_cell_value}")
    ...     message_alias=${message_name}
    ...     flow_alias=${location_report}

    Verify That Message Fulfills Query
    ...     (nR-CGI is present) and (tAI is present)
    ...     message_alias=${message_name}
    ...     flow_alias=${location_report}


Verify that ${msg:\S+} contains pLMNIdentity ${plmn:0x134198} in ${field_type:(userLocationInformationNR|areaOfInterestList)}
    [Documentation]     Can be used only when nrcellidentity list is used, not tailist due to hardcoded tac
    ${message_name}=    get_procedure_or_name_from_message_name   ${msg}    what=message
    ${procedure_name}=    get_procedure_or_name_from_message_name   ${msg}    what=procedure
    ${location_report}=  Get Flow Name
    ...     procedure=${procedure_name}
    ...     device=AMF1
    ...     protocol=NGAP

    Run Keyword if  '${field_type}' == 'userLocationInformationNR'
    ...     Verify That Message Fulfills Query
    ...     ${field_type} contains (nR-CGI contains (pLMNIdentity eq "${plmn}")) and
    ...     ${field_type} contains (tAI contains (pLMNIdentity eq "${plmn}")) and
    ...     ${field_type} contains (tAI contains (tAC eq "${tac_hex}"))
    ...     message_alias=${message_name}
    ...     flow_alias=${location_report}

    Run Keyword if  '${field_type}' == 'areaOfInterestList'
    ...     Verify That Message Fulfills Query
    ...     ${field_type} contains (nR-CGI contains (pLMNIdentity eq "${plmn}"))
    ...     message_alias=${message_name}
    ...     flow_alias=${location_report}

Verify that ${msg:\S+} contains pLMNIdentity ${plmn:0x134198} and tAC ${tac:0x\d+} in areaOfInterestList
    ${message_name}=    get_procedure_or_name_from_message_name   ${msg}    what=message
    ${procedure_name}=    get_procedure_or_name_from_message_name   ${msg}    what=procedure
    ${location_report}=  Get Flow Name
    ...     procedure=${procedure_name}
    ...     device=AMF1
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     areaOfInterestList contains (tAI  contains (pLMNIdentity eq "${plmn}" and tAC eq "${tac}"))
    ...     message_alias=${message_name}
    ...     flow_alias=${location_report}


Verify that ${msg:\S+} contains NRCELL-locationReportingReferenceID mapping ${mapping:(\S+)}
    [Documentation]         mapping=cell_number_int:location_reference_id_int
    ${message_name}=    get_procedure_or_name_from_message_name   ${msg}    what=message
    ${procedure_name}=    get_procedure_or_name_from_message_name   ${msg}    what=procedure
    ${location_report}=  Get Flow Name
    ...     procedure=${procedure_name}
    ...     device=AMF1
    ...     protocol=NGAP

    ${cell_mapping}=   Set variable if   ${GNB_ID_LENGTH_32}==${True}     ${nrcell_ids_32_bit}     ${nrcell_ids}

    ${query}=       generate_query_from_nrcell_ref_id_mapping           ${mapping}      ${cell_mapping}

    Verify That Message Fulfills Query
    ...    ${query}
    ...     message_alias=${message_name}
    ...     flow_alias=${location_report}

Verify that ${msg:\S+} contains TAC-locationReportingReferenceID mapping ${tac:\d+}:${ref_id:\d+}
    [Documentation]         mapping=tac:location_reference_id_int
    ${message_name}=    get_procedure_or_name_from_message_name   ${msg}    what=message
    ${procedure_name}=    get_procedure_or_name_from_message_name   ${msg}    what=procedure
    ${location_report}=  Get Flow Name
    ...     procedure=${procedure_name}
    ...     device=AMF1
    ...     protocol=NGAP

    ${tac_hex}=     Set variable     ${tacs}[${tac}]

    Verify That Message Fulfills Query
    ...    areaOfInterestList contains (tAC eq "${tac_hex}" and locationReportingReferenceID eq ${ref_id})
    ...     message_alias=${message_name}
    ...     flow_alias=${location_report}

Verify that ${msg:\S+} contains gNBID-locationReportingReferenceID mapping ${gnb_id:\d+}:${ref_id:\d+}
    [Documentation]         mapping=gnb_id:location_reference_id_int
    ${message_name}=    get_procedure_or_name_from_message_name   ${msg}    what=message
    ${procedure_name}=    get_procedure_or_name_from_message_name   ${msg}    what=procedure
    ${location_report}=  Get Flow Name
    ...     procedure=${procedure_name}
    ...     device=AMF1
    ...     protocol=NGAP

    ${nodeid_bin}=    Set variable        ${nodeids}[${gnb_id}]
    verify_that_gNBId_corresponds_to_locationReportingReferenceID
    ...    message_alias=${message_name}
    ...    flow_alias=${location_report}
    ...    gnbid_value=0b${nodeid_bin}
    ...    ref_id=${ref_id}



Verify that ${msg:\S+} contains uEPresence equal to ${where:(in|out)} for locationReportingReferenceID ${ref_id:[1-8]}
    ${message_name}=    get_procedure_or_name_from_message_name   ${msg}    what=message
    ${procedure_name}=    get_procedure_or_name_from_message_name   ${msg}    what=procedure
    ${location_report}=  Get Flow Name
    ...     procedure=${procedure_name}
    ...     device=AMF1
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     (eventType eq 'ue-presence-in-area-of-interest') and
    ...     (UEPresenceInAreaOfInterestList contains (locationReportingReferenceID eq ${ref_id} and uEPresence eq '${where}'))
    ...     message_alias=${message_name}
    ...     flow_alias=${location_report}

Verify that ${msg:\S+} does not contain locationReportingReferenceID ${ref_id:[1-8]} in UEPresenceInAreaOfInterestList
    ${message_name}=    get_procedure_or_name_from_message_name   ${msg}    what=message
    ${procedure_name}=    get_procedure_or_name_from_message_name   ${msg}    what=procedure
    ${location_report}=  Get Flow Name
    ...     procedure=${procedure_name}
    ...     device=AMF1
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     (eventType eq 'ue-presence-in-area-of-interest') and
    ...     not (UEPresenceInAreaOfInterestList contains (locationReportingReferenceID eq ${ref_id}))
    ...     message_alias=${message_name}
    ...     flow_alias=${location_report}

Verify that gNB sends ${msg:\S+} without timestamp
    ${message_name}=    get_procedure_or_name_from_message_name   ${msg}    what=message
    ${procedure_name}=    get_procedure_or_name_from_message_name   ${msg}    what=procedure
    ${location_report}=  Get Flow Name
    ...     procedure=${procedure_name}
    ...     device=AMF1
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     timeStamp is not present
    ...     message_alias=${message_name}
    ...     flow_alias=${location_report}

Verify that ${msg:\S+} contains eventType equal to ${event_type:(direct|change-of-serve-cell)}
    ${message_name}=    get_procedure_or_name_from_message_name   ${msg}    what=message
    ${procedure_name}=    get_procedure_or_name_from_message_name   ${msg}    what=procedure
    ${location_report}=  Get Flow Name
    ...     procedure=${procedure_name}
    ...     device=AMF1
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     (eventType eq '${event_type}') and
    ...     (UEPresenceInAreaOfInterestList is not present)
    ...     message_alias=${message_name}
    ...     flow_alias=${location_report}

Verify that gNB sends ${msg:\S+} with timestamp for UE${ue_id:\d+}
    ${message_name}=    get_procedure_or_name_from_message_name   ${msg}    what=message
    ${procedure_name}=    get_procedure_or_name_from_message_name   ${msg}    what=procedure

    ${location_report}=  Get Flow Name
    ...     procedure=${procedure_name}
    ...     device=AMF1
    ...     protocol=NGAP

    ${rrc_release}=     Get Flow Name
    ...     RRCRelease
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     timeStamp is present
    ...     message_alias=${message_name}
    ...     flow_alias=${location_report}

    ${ntp_rrcrelease}=    get_message_occurence_time
    ...     flow_alias=${rrc_release}
    ...     message_alias=RRCRelease
    ...     time_format=ntp_32bit
    ...     output_format=hex_uppercase

    verify_difference_between_timestamp_inside_location_report_and_rrc_release_occurrence
    ...     message_alias=${message_name}
    ...     flow_alias=${location_report}
    ...     rrc_release_timestamp=${ntp_rrcrelease}

    ${difference}=    get_difference_between_timestamp_inside_location_report_and_rrc_release_occurrence

    Run Keyword If  ${difference} > ${timestamp_toleration}
    ...     Fail    Difference ${difference} [s] between RRCRelease occurence time and timestamp inside NGAP: Location Report is too big.
    ...     ELSE    Log To Console
    ...     Difference ${difference} [s] between RRCRelease occurence time and timestamp inside NGAP: Location Report is OK.

Verify that gNB sends ${msg:\S+} containing NRCELL-${cell_id:[1-3]} identity
    ${bin_cell_value_non_32}=      get_bin_value_from_dec      ${nrcell_ids}[NRCELL-${cell_id}]     36
    ${bin_cell_value_32_bit}=      get_bin_value_from_dec      ${nrcell_ids_32_bit}[NRCELL-${cell_id}]     36
    ${bin_cell_value}=     set variable if         ${GNB_ID_LENGTH_32}==${True}        ${bin_cell_value_32_bit}  ${bin_cell_value_non_32}


    ${message_name}=    get_procedure_or_name_from_message_name   ${msg}    what=message
    ${procedure_name}=    get_procedure_or_name_from_message_name   ${msg}    what=procedure

    ${location_report}=  Get Flow Name
    ...     procedure=${procedure_name}
    ...     device=AMF1
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     userLocationInformationNR contains (nRCellIdentity eq '0b${bin_cell_value}')
    ...     message_alias=${message_name}
    ...     flow_alias=${location_report}

    Verify That Message Fulfills Query
    ...     (nR-CGI is present) and (tAI is present)
    ...     message_alias=${message_name}
    ...     flow_alias=${location_report}
