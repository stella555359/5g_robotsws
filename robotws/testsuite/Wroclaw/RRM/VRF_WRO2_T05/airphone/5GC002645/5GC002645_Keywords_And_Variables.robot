*** Settings ***
Documentation    :copyright: Nokia

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ta5g_cell_operations
Library      ta5g_pm_counters
Library      ta5g_tshark
Library      ta5g_delta
Library      ta5g_enb

*** Variables ***
${F1AP_PWS_FAILURE_INDICATION} =    f1ap.PWSFailureIndication_element
${F1AP_PWS_RESTART_INDICATION} =    f1ap.PWSRestartIndication_element

${F1AP_PWS_RESTART_INDICATION_TRANSACTIONID} =    f1ap.id == 78 && ${F1AP_PWS_RESTART_INDICATION}
${F1AP_PWS_RESTART_INDICATION_CELLIDLISTFORRESTART} =    f1ap.id == 152 && ${F1AP_PWS_RESTART_INDICATION}

${NGAP_PWS_RESTART_INDICATION_CELLIDLISTFORRESTART} =    ngap.NRCellIdentity == 0x0000004001 && ${NGAP_PWS_RESTART_INDICATION}
${NGAP_PWS_RESTART_INDICATION_GLOBALRANNODEID} =    ngap.gNB_ID == 00:00:04 && ${NGAP_PWS_RESTART_INDICATION}
${NGAP_PWS_RESTART_INDICATION_TAILISTFORRESTART} =    ngap.id == 104 && ${NGAP_PWS_RESTART_INDICATION}
${NGAP_PWS_RESTART_INDICATION_EMERGENCYAREAIDLISTFORRESTART} =    ngap.EmergencyAreaID == 00:00:01 && ${NGAP_PWS_RESTART_INDICATION}

*** Keywords ***
Verify NGAP Messages in Pcaps PWS Cancel
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_REQUEST}    number_of_messages=33
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_RESPONSE}    number_of_messages=33
    Verify Ngap Messages    packet_filter=${NGAP_PWS_CANCEL_REQUEST}
    Verify Ngap Messages    packet_filter=${NGAP_PWS_CANCEL_RESPONSE}

Verify F1AP Messages In Pcaps PWS Restart
    Verify Tcpdump Log    packet_filter=${F1AP_PWS_FAILURE_INDICATION}
    Verify Tcpdump Log    packet_filter=${F1AP_PWS_RESTART_INDICATION}
    Verify Tcpdump Log    packet_filter=${F1AP_PWS_RESTART_INDICATION_TRANSACTIONID}
    Verify Tcpdump Log    packet_filter=${F1AP_PWS_RESTART_INDICATION_CELLIDLISTFORRESTART}

Verify NGAP Messages In Pcaps PWS Restart
    Verify Ngap Messages    packet_filter=${NGAP_PWS_FAILURE_INDICATION}
    Verify Ngap Messages    packet_filter=${NGAP_PWS_RESTART_INDICATION}
    Verify Ngap Messages    packet_filter=${NGAP_PWS_RESTART_INDICATION_CELLIDLISTFORRESTART}
    Verify Ngap Messages    packet_filter=${NGAP_PWS_RESTART_INDICATION_GLOBALRANNODEID}
    Verify Ngap Messages    packet_filter=${NGAP_PWS_RESTART_INDICATION_TAILISTFORRESTART}
    Verify Ngap Messages    packet_filter=${NGAP_PWS_RESTART_INDICATION_EMERGENCYAREAIDLISTFORRESTART}
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_REQUEST}    number_of_messages=2
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_RESPONSE}    number_of_messages=2
