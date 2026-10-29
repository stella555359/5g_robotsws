*** Settings ***

Documentation    :copyright: Nokia

*** Variables ***
############## MAIN ###################
${SETUP_TL}=    ${FALSE}
${ADDITIONAL_RESET}=    ${FALSE}
${RESTORE_DEFAULT_CONFIG}=    ${FALSE}

######### GENERAL VARIABLES ###########
${UE_ID_1}          60
${UE_ID_2}          61
${UE_ID_3}          62
${UE_ID_4}          63
${UE_ID_5}          64
${UE_ID_6}          65
${UE_ID_7}          66
${UE_ID_8}          67
${UE_ID_9}          68

############# WIRESHARK #############
${RRC_RECONFIG_A1_MEAS_ADD}
...    nr-rrc.c1 == 0 && nr-rrc.eventId == 0 && !nr-rrc.eventId == 4
${UE_CAPA_ENQUIRY}
...    nr-rrc.c1 == 6
${RRC_RECONFIG_SCELL_ADD}
...    nr-rrc.sCellToAddModList == 1 && nr-rrc.criticalExtensions == 0
${RRC_RECONFIG_A1_MEAS_ADD_CAPA_NOID}
...    nr-rrc.c1 == 0 && nr-rrc.eventId == 0
${RRC_UE_CAPA_INF}
...    nr-rrc.c1 == 9
