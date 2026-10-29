*** Settings ***

Documentation    :copyright: Nokia

*** Variables ***

${FULL_COMMISSIONING}=        ${TRUE}
${RESET_TL}=                  ${FALSE}
${RESTORE_DEFAULT_CONFIG}=    ${TRUE}

${LUA_FILEPATH_3CC}           ${CURDIR}/../../../../resources/airphone/egate_CA_4FDD_2TDD.lua
${delta_set_collecting_counters_to_five_minutes}
...   /home/ute/robotws/testsuite/Wroclaw/RRM/resources/airphone/config/default/delta_set_collecting_counters_to_five_minutes.json

############# WIRESHARK ################
${DEFAULT_S1_MME_ALIAS}       default_s1_x2
${DEFAULT_UU_ALIAS}           default_uu

${event_A1}                   nr-rrc.eventId == 0
${event_A2}                   nr-rrc.eventId == 1

${UE1_CELL1}                  10
${UE2_CELL1}                  11
${UE3_CELL1}                  12
${UE4_CELL1}                  13
${UE5_CELL1}                  14
${UE6_CELL1}                  15
${UE1_CELL2}                  20
${UE_ID2}                     21
${UE_ID3}                     22
${UE_ID4}                     23
${UE_ID5}                     24
${UE_ID6}                     25
${UE_ID7}                     26
${UE_ID8}                     27
${UE_ID9}                     28
${UE1_CELL6}                  60
${UE2_CELL6}                  61
${WIRESHARK_U_ID}             and iphy.ue_id ==

${RRC_RECONF_2SCELL_ADDITION_A2_REL_CONFIGURATION}
...    nr-rrc.eventId == 1 && nr-rrc.sCellToAddModList == 2 && nr-rrc.measObjectToAddModList == 2
...    && nr-rrc.reportConfigToRemoveList == 2 && nr-rrc.reportConfigToAddModList == 4
${RRC_RECONF_A2_SCELL_RELEASE_SCELL_ID2}
...    nr-rrc.sCellToReleaseList == 1 && nr-rrc.SCellIndex == 2 && nr-rrc.measObjectToRemoveList == 1
${RRC_RECONF_A2_SCELL_RELEASE_SCELL_ID1}
...    nr-rrc.measObjectToRemoveList == 1 && nr-rrc.sCellToReleaseList == 1 && nr-rrc.SCellIndex == 1
...    && nr-rrc.measIdToAddModList == 2
${RRC_RECONF_A1_PCELL_SWITCH_CONFIGURATION}
...    nr-rrc.measObjectToAddModList == 2 && nr-rrc.reportConfigToAddModList == 4
...    && nr-rrc.measIdToAddModList == 4 && nr-rrc.sCellToAddModList == 2
${RRC_RELEASE}
...    f1ap.procedureCode == 6 && nr-rrc.criticalExtensions == 0
${RRC_RELEASE_RADIONETWORK}
...    f1ap.radioNetwork == 0
${RRC_RECONF_ONLY_ONE_SCELL}
...    nr-rrc.measIdToRemoveList == 2 && nr-rrc.sCellToAddModList == 1 && nr-rrc.physCellId == 53
${RRC_RECONF_PCELL_SWITCH}
...    nr-rrc.sCellToReleaseList == 2 && nr-rrc.c1 == 0 && nr-rrc.reportConfigToRemoveList == 5
${B3_RRC_RECONF_SCELLREL}
...    nr-rrc.SCellIndex == 1 && nr-rrc.sCellToReleaseList == 1 && nr-rrc.c1 == 0
${RRC_RECONF_A2_MEAS_CONFIG}
...    nr-rrc.reportConfigToAddModList == 3 && nr-rrc.eventId == 1 && nr-rrc.sCellToAddModList == 1
${RRC_RECONF_COMPLETE_FILTER}
...   nr-rrc.rrcReconfigurationComplete_element
${RRC_RECONF_REMOVE_SCELL}
...    nr-rrc.sCellToReleaseList == 1 && nr-rrc.SCellIndex == 1 && nr-rrc.eventId == 0
...    && nr-rrc.reportConfigToRemoveList == 3
${RRC_RECONF_A1_FOR_PCELL_SWITCH_DECONF}
...    nr-rrc.sCellToReleaseList == 1 && nr-rrc.SCellIndex == 1 && nr-rrc.measObjectToRemoveList == 1
${UE_RELEASE_RRCTIMEOUT}
...    f1ap.radioNetwork == 10 && f1ap.procedureCode == 6
${RRC_RECONF_SCELLADD}
...    nr-rrc.sCellToAddModList == 1 && nr-rrc.measObjectToAddModList == 1
