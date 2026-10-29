*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CNI_81991/CNI81991_keywords.robot

*** Variables ***
${TSHARK_ALIAS_A_B1_FDD_5MHz}=                   tshark_uu_alias_01
${TSHARK_DIR_A_B1_FDD_5MHz}=                     ${OUTPUT_DIR}/Tshark_logs_A_B1_FDD_5MHz
${TSHARK_FILENAME}=                              CNI81991.pcapng

${BWP_DEDICATED_RRC_SETUP_A_B1_FDD}    ((nr-rrc.firstActiveDownlinkBWP_Id == 0) && (nr-rrc.srb_Identity == 1) && (nr-rrc.c1 == 1))
${BWP_DEDICATED_RRC_RECO_A_B1_FDD}
...    ((nr-rrc.firstActiveDownlinkBWP_Id == 0) && (nr-rrc.firstActiveUplinkBWP_Id == 0) && (nr-rrc.pdcch_Config == 1) && (nr-rrc.pucch_Config == 1))

*** Keywords ***
CNI-81991-A_B1_RRC_connection_estab_with_smallest_RRCSetup_FDD_5MHz
    Start Tshark With Alias  ${TSHARK_FILENAME}  ${TSHARK_ALIAS_A_B1_FDD_5MHz}  ${TSHARK_DIR_A_B1_FDD_5MHz}
    Attach Ue    ue_id=1
    Verify if RRCSetup or RRCReconfiguration Contain the dedicated part of BWP  ${TSHARK_ALIAS_A_B1_FDD_5MHz}  ${BWP_DEDICATED_RRC_SETUP_A_B1_FDD}
    Verify if RRCSetup or RRCReconfiguration Contain the dedicated part of BWP  ${TSHARK_ALIAS_A_B1_FDD_5MHz}  ${BWP_DEDICATED_RRC_RECO_A_B1_FDD}

