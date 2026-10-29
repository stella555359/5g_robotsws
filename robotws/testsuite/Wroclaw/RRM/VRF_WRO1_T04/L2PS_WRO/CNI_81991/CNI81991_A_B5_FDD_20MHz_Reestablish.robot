*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CNI_81991/CNI81991_keywords.robot

*** Variables ***
${TSHARK_ALIAS_A_B5_FDD}=                   tshark_uu_alias_01
${TSHARK_DIR_A_B5_FDD}=                     ${OUTPUT_DIR}/Tshark_logs_A_B5_FDD
${TSHARK_FILENAME_uu}=                      81991_uu.pcapng

${BWP_DEDICATED_RRC_SETUP_A_B5_FDD}      ((nr-rrc.criticalExtensions == 0) && (nr-rrc.pdcch_Config == 1)) && (nr-rrc.c1 == 1)
${RRCSETUP_NO_DEDICATED_BWP_A_B5_FDD}    ((nr-rrc.c1 == 1) && (nr-rrc.pdcch_Config == 1)) && (nr-rrc.pdsch_Config == 1)
${RRCSETUP_SRB1_MAND_PARAMS_A_B5_FDD}
...    ((((nr-rrc.c1 == 1)) && (nr-rrc.srb_Identity == 1)) && (nr-rrc.firstActiveDownlinkBWP_Id == 0)) && (nr-rrc.firstActiveUplinkBWP_Id == 0)
${RRC_RECONF_BWP_SWITCH_A_B5_FDD}        ((((nr-rrc.c1 == 0) && (nr-rrc.srb_Identity == 2)) && (nr-rrc.bwp_Id == 1)) )
${RRC_RECONF_DEDICATED_BWP_A_B5_FDD}
...    ((((nr-rrc.c1 == 0)) && (nr-rrc.bwp_Id == 0)) && (nr-rrc.firstActiveUplinkBWP_Id == 0)) && (nr-rrc.firstActiveDownlinkBWP_Id == 0)

*** Keywords ***
CNI-81991-A_B5_RRC_connection_estab_with_smallest_RRCSetup_IWK_with_RRC_reestablishment_FDD
    Start Tshark With Alias  ${TSHARK_FILENAME_uu}  ${TSHARK_ALIAS_A_B5_FDD}  ${TSHARK_DIR_A_B5_FDD}
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Verify If RRCSetup Msg Does Not Contain The Dedicated Part Of BWP-0    ${TSHARK_ALIAS_A_B5_FDD}    ${RRCSETUP_NO_DEDICATED_BWP_A_B5_FDD}
    Verify RRC setup message contains SRB1 and mandatory parameters    ${TSHARK_ALIAS_A_B5_FDD}    ${RRCSETUP_SRB1_MAND_PARAMS_A_B5_FDD}
    Verify If 1st RRC_Reconfiguration Message Includes Dedicated Part Of BWP-0    ${TSHARK_ALIAS_A_B5_FDD}    ${RRC_RECONF_DEDICATED_BWP_A_B5_FDD}
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Verify PM counters And Check If M55124C01031 Is Incremented
    Verify If UE Switched To Use BWP-1 And Setup With SRB2    ${TSHARK_ALIAS_A_B5_FDD}    ${RRC_RECONF_BWP_SWITCH_A_B5_FDD}
    Send RRC Reestablishment Request With Invalid Short MAC-I
    Verify PM counters And Check If M55124C01031 Not Incremented After RRC Reestab Request
