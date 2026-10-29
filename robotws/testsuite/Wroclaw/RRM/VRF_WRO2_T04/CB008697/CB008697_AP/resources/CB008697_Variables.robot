*** Settings ***

Documentation    :copyright: Nokia

*** Variables ***
############## MAIN ###################
${FULL_COMMISSIONING}=    ${TRUE}
${RESET_TL}=    ${FALSE}
${RESTORE_DEFAULT_CONFIG}=    ${TRUE}

${LUA_FILEPATH_3CC}    ${CURDIR}/../../../../resources/airphone/egate_CA_4FDD_2TDD.lua
${delta_set_collecting_counters_to_five_minutes}
...   /home/ute/MN/UTE/robotws/testsuite/RRM/5G_SW_WRO/resources/config/SBTS22R2/delta_set_collecting_counters_to_five_minutes.json

${SCELL_ACTIVATION_REGEXP}=    SCellIndex 1 activated successfully at airphone.*SCellIndex 2 activated successfully at airphone.|
...                            SCellIndex 2 activated successfully at airphone.*SCellIndex 1 activated successfully at airphone.
${SCELL_DEACTIVATION_REGEXP}=    SCellIndex 1 deactivated successfully at airphone.*SCellIndex 2 deactivated successfully at airphone.|
...                              SCellIndex 2 deactivated successfully at airphone.*SCellIndex 1 deactivated successfully at airphone.

############# WIRESHARK ################
${DEFAULT_S1_MME_ALIAS}    default_s1_x2
${DEFAULT_UU_ALIAS}    default_uu

${UE1_CELL1}    10
${UE2_CELL1}    11
${UE3_CELL1}    12
${UE4_CELL1}    13
${UE5_CELL1}    14
${UE6_CELL1}    15
${UE1_CELL2}    20
${UE2_CELL2}    21
${UE3_CELL2}    22
${UE4_CELL2}    23
${UE5_CELL2}    24
${UE1_CELL3}    30
${UE2_CELL3}    31
${UE3_CELL3}    32
${UE4_CELL3}    33
${UE1_CELL4}    40
${UE2_CELL4}    41
${UE3_CELL4}    42
${UE1_CELL5}    50
${UE2_CELL5}    51
${UE1_CELL6}    60

${RRC_OH_SETUP}=    ${RRC_RECONFIGURATION} && nr-rrc.overheatingAssistanceConfig == 1
${RRC_RECONF_1SCELL_ADDITION}=    nr-rrc.c1 == 0 && nr-rrc.criticalExtensions == 0 and nr-rrc.sCellToAddModList == 1
...                               && nr-rrc.physCellId == 50
${RRC_RECONF_2SCELLS_ADDITION}=    nr-rrc.c1 == 0 && nr-rrc.criticalExtensions == 0 and nr-rrc.sCellToAddModList == 2
...                                && nr-rrc.physCellId == 52 and nr-rrc.physCellId == 53
${RRC_RECONF_3SCELLS_ADDITION}=    nr-rrc.c1 == 0 && nr-rrc.criticalExtensions == 0 and nr-rrc.sCellToAddModList == 3
...                                && nr-rrc.physCellId == 50 and nr-rrc.physCellId == 52 and nr-rrc.physCellId == 55
${F1AP_1SCELL_ADDITION}=    f1ap.SCell_ToBeSetupMod_List == 1 && f1ap.sCellIndex == 1
${F1AP_2SCELLS_ADDITION}=    f1ap.SCell_ToBeSetupMod_List == 2 && f1ap.sCellIndex == 1 && f1ap.sCellIndex == 2
${F1AP_3SCELLS_ADDITION}=    f1ap.SCell_ToBeSetupMod_List == 3 && f1ap.sCellIndex == 1 && f1ap.sCellIndex == 2
...                          && f1ap.sCellIndex == 3
${RRC_RECONFIG_HANDOVER}=    nr-rrc.criticalExtensions == 0 && nr-rrc.physCellId == 56
...                          && nr-rrc.sCellToReleaseList == 1
${UE_ASSISTANCE_REDUCED_CC_0}=    f1ap.UEAssistanceInformation && nr-rrc.reducedCCsDL_r16 == 0
${UE_ASSISTANCE_REDUCED_CC_1}=    f1ap.UEAssistanceInformation && nr-rrc.reducedCCsDL_r16 == 1
${RRC_RECONFIGURATION_OH}=    ${RRC_RECONFIGURATION} && nr-rrc.overheatingAssistanceConfig == 1 &&
...                           nr-rrc.overheatingIndicationProhibitTimer == 3
${RRC_RECONFIGURATION_OH_UE2}=    ${RRC_RECONFIGURATION} && nr-rrc.overheatingAssistanceConfig == 1 &&
...                               nr-rrc.overheatingIndicationProhibitTimer == 4
${UE_CAPABILITIES_OH}=    nr-rrc.ueCapabilityInformation_element && nr-rrc.overheatingInd == 0
${RRC_SCELL_TO_RELEASE_1}=    ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.sCellToReleaseList == 1
${RRC_SCELL_TO_ADD_2}=    ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.sCellToAddModList == 2
${RRC_SCELL_TO_REMOVED_1}=    ${F1AP_UE_CONTEXT_MODIFICATION_REQUEST} && f1ap.SCell_ToBeRemoved_List == 1
${OH_RELEASE}=    ${RRC_RECONFIGURATION} && nr-rrc.overheatingAssistanceConfig == 0
${RRC_RECONF_CA_RELEASE}=    nr-rrc.sCellToReleaseList == 1 && nr-rrc.overheatingAssistanceConfig == 0
${OVERHEATING_UE_0_MAXCCS}=    nr-rrc.reducedCCsDL_r16 == 0 && nr-rrc.reducedCCsUL_r16 == 0

