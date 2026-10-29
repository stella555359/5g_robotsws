*** Settings ***

Documentation    :copyright: Nokia

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_ue_measurements
Library      ta5g_pm_counters
Library      ta5g_cell_operations
Library      ta5g_delta

*** Variables ***

######################### AREA OF INTEREST CONFIGURATION AND REPORTING VARIABLES ########################
${AOI_EVENT} =  event_type=ue-presence-in-area-of-interest
${AOI_STOP_EVENT} =  event_type=stop-ue-presence-in-area-of-interest
${AOI_OBJECT_1} =  object_id=1 location_reporting_reference_id=1
${AOI_OBJECT_2} =  object_id=2 location_reporting_reference_id=2
${AOI_IN_HANDOVER_REQUEST} =  Adding Location Reporting Control IE to Xn Handover Request
${AOI_REPORT_AFTER_HANDOVER} =  Received Location Report from GNB-2
${XNAP_WITH_LOCATION_REPORTING_ELEMENT} =  ${XNAP_UE_PRESENCE_IN_AOI_IE}  &&  ${XNAP_REQUEST_REFERENCE_IDS}

######################### USER LOCATION INFORMATION IES ########################
${DIRECT_IE} =  ngap.eventType == 0
${CHANGE_CELL_IE} =  ngap.eventType == 1
${UE_PRESENCE_IN_AOI_IE} =  ngap.eventType == 2
${STOP_IE} =  ngap.eventType == 3
${STOP_AOI_IE} =  ngap.eventType == 4
${CANCEL_IE} =  ngap.eventType == 5
${XNAP_UE_PRESENCE_IN_AOI_IE} =  ${XNAP}eventType == 2
${XNAP_REQUEST_REFERENCE_IDS} =  ${XNAP}requestReferenceID == 1 && ${XNAP}requestReferenceID == 2

######################### LOCATION REPORTING NGAP MESSAGES ######################
${NGAP_LOCATION_REPORTING_CONTROL} =  ngap.LocationReportingControl_element
${NGAP_LOCATION_REPORT} =             ngap.LocationReport_element
${ULI_IE} =                           ngap.UserLocationInformation

${NGAP_LOCATION_REPORT_ULI} =         ${ULI_IE} && ${NGAP_LOCATION_REPORT}
${NGAP_LOCATION_REPORTING_CONTROL_DIRECT} =  ${NGAP_LOCATION_REPORTING_CONTROL} && ${DIRECT_IE}
${NGAP_LOCATION_REPORTING_CONTROL_CHANGE_CELL} =  ${NGAP_LOCATION_REPORTING_CONTROL} && ${CHANGE_CELL_IE}
${NGAP_LOCATION_REPORTING_CONTROL_AOI} =  ${NGAP_LOCATION_REPORTING_CONTROL} && ${UE_PRESENCE_IN_AOI_IE}
${NGAP_LOCATION_REPORTING_CONTROL_STOP_AOI} =  ${NGAP_LOCATION_REPORTING_CONTROL} && ${STOP_AOI_IE}
${NGAP_LOCATION_REPORTING_CONTROL_STOP_CHANGE_CELL} =  ${NGAP_LOCATION_REPORTING_CONTROL} && ${STOP_IE}
${NGAP_LOCATION_REPORTING_CONTROL_CANCEL_REPORTING} =  ${NGAP_LOCATION_REPORTING_CONTROL} && ${CANCEL_IE}
${NGAP_LOCATION_REPORTING_FAILURE} =  ngap.LocationReportingFailureIndication_element
${ICS_LOCATION_REPORTING_IE_DIRECT} =  ngap.InitialContextSetupRequest_element && ${DIRECT_IE}
${ICS_LOCATION_REPORTING_IE_CHANGE_CELL} =  ngap.InitialContextSetupRequest_element && ${CHANGE_CELL_IE}
${ICS_LOCATION_REPORTING_IE_AOI} =  ngap.InitialContextSetupRequest_element && ${UE_PRESENCE_IN_AOI_IE}

${NGAP_UE_CONTEXT_MODIFICATION_RESPONSE} =     ngap.UEContextModificationResponse_element
${ULI_IN_PDU_SESSION_RESOURCE_RELEASE_RESPONSE} =    ${NGAP_PDU_SESSION_RESOURCE_RELEASE_RESPONSE} && ${ULI_IE}
${ULI_IN_PDU_SESSION_RESOURCE_MODIFY_RESPONSE} =    ${NGAP_PDU_SESSION_RESOURCE_MODIFY_RESPONSE} && ${ULI_IE}
${ULI_IN_UE_CONTEXT_MODIFICATION_RESPONSE} =    ${NGAP_UE_CONTEXT_MODIFICATION_RESPONSE} && ${ULI_IE}
${ULI_IN_UE_CONTEXT_RELEASE_COMPLETE} =    ${NGAP_UE_CONTEXT_RELEASE_COMPLETE} && ${ULI_IE}

*** Keywords ***

Configure Area Of Interest IEs
    Execute Egate Command
    ...  cmd=area_of_interest_configuration object_id=1 plmn_cellid=311:489 nrcellidentitylist=16385
    Execute Egate Command
    ...  cmd=area_of_interest_configuration object_id=2 plmn_cellid=311:489 nrcellidentitylist=16386

Trigger Location Reporting
    [Arguments]  ${ue_id}  ${event_type}
    Execute Egate Command
    ...  cmd=ue_send_location_reporting_control ue=${ue_id} event_type=${event_type}
    ...  timeout=3

Trigger Location Reporting After ICS
    [Arguments]  ${ue_id}  ${event_type}
    Execute Egate Command
    ...  cmd=amf_ue_ics_param id=1 ue=${ue_id} location_request=on event_type=${event_type}
    ...  timeout=7

Trigger Location Reporting Upon AOI
    [Arguments]  ${ue_id}
    Execute Egate Command
    ...  cmd=ue_send_location_reporting_control ue=${ue_id} ${AOI_EVENT} ${AOI_OBJECT_1} ${AOI_OBJECT_2}
    ...  timeout=7

Trigger Location Reporting Upon AOI After ICS
    [Arguments]  ${ue_id}
    Execute Egate Command
    ...  cmd=amf_ue_ics_param id=1 ue=${ue_id} location_request=on ${AOI_EVENT} ${AOI_OBJECT_1} ${AOI_OBJECT_2}
    ...  timeout=7

Stop Location Reporting Upon AOI
    [Arguments]  ${ue_id}  ${reference_to_stop}
    Execute Egate Command
    ...  cmd=ue_send_location_reporting_control ue=${ue_id} ${AOI_STOP_EVENT} location_reporting_reference_id_to_be_cancelled=${reference_to_stop}
    ...  timeout=3

Add Item To UE History Information List
    [Arguments]  ${gnb_id}
    [Documentation]  Updates UE History Information list: adds an item to the list, commits prepared list
    Execute Egate Command
    ...  cmd=ue_history_information_list_add_ngran id=1 gnb_id=${gnb_id} cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute Egate Command
    ...  cmd=ue_history_information_list id=1 action=commit
    Execute Egate Command
    ...  cmd=ue_enb_param id=1 ue_history_list=1

Wait For Location Reporting Control To Be Processed
    Sleep  30s

Set Emergency Fallback On
    Execute Egate Command    cmd=amf_param id=1 emergency_service_fallback=on target_cn=epc

Trigger Emergency Fallback
    Execute Egate Command    cmd=ue_conn_service_req id=3 service_type=emergency_services_fallback
