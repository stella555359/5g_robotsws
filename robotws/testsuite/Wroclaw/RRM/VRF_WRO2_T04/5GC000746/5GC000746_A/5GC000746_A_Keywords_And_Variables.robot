*** Settings ***

Documentation    :copyright: Nokia

Variables    ta5g_global_var

Library      ta5g_egate
Library      ta5g_cell_operations

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot

*** Variables ***
${NGAP_WRITE_REPLACE_WARNING_REQUEST_NUMBER_OF_BROADCASTS} =    ngap.NumberOfBroadcastsRequested == 5
${NGAP_ERROR_INDICATION_MESSAGE_NOT_COMPATIBLE} =    ngap.protocol == 3 && ngap.ErrorIndication_element
${F1AP_PWS_FAILURE_INDICATION} =    f1ap.PWSFailureIndication_element
${NGAP_PWS_FAILURE_INDICATION} =    ngap.PWSFailureIndication_element
${NGAP_WRITE_REPLACE_WARNING_RESPONSE_WITHOUT_CELL_LIST_IE} =    ngap.protocolIEs == 2 && ${NGAP_WRITE_REPLACE_WARNING_RESPONSE}

*** Keywords ***

Trigger CMAS With Wrong NRCGI
    Trigger Concurrent CMAS    nrcgi=311:489|999
    ...    pass_regexp=Request failed in all cells of the NG-RAN node


Trigger Special Value CMAS Without Confirmation
    Trigger Concurrent CMAS       periodicity=0 repetition=2

