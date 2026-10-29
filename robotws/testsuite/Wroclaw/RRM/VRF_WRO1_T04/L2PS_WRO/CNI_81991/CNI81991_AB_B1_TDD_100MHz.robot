*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CNI_81991/CNI81991_keywords.robot

*** Variables ***
${TSHARK_ALIAS_AB_B1_TDD}=                   tshark_uu_alias_01
${TSHARK_DIR_AB_B1_TDD}=                     ${OUTPUT_DIR}/Tshark_logs_AB_B1_TDD
${TSHARK_FILENAME}=                          CNI81991.pcapng

${BWP_DEDICATED_RRC_SETUP_AB_B1_TDD}    ((nr-rrc.firstActiveDownlinkBWP_Id == 0) && (nr-rrc.srb_Identity == 1) && (nr-rrc.c1 == 1))
${BWP_DEDICATED_RRC_RECO_AB_B1_TDD}
...    ((nr-rrc.bwp_Id == 1) && (nr-rrc.firstActiveDownlinkBWP_Id == 1) && (nr-rrc.firstActiveUplinkBWP_Id == 1) && (nr-rrc.pdcch_Config == 1))

*** Keywords ***
CNI-81991-AB_B1_RRC_connection_estab_with_smallest_RRCSetup_and_BWP-1_in1st_RRCreconf_TDD
    Start Tshark With Alias  ${TSHARK_FILENAME}  ${TSHARK_ALIAS_AB_B1_TDD}  ${TSHARK_DIR_AB_B1_TDD}
    Execute Egate Command And Wait For Data
    ...               cmd=ue_register id=1
    ...               pass_regexp=UE1: UE performed Registration type INITIAL_REGISTRATION
    ...               timeout=10
    Stop Capturing    alias=${TSHARK_ALIAS_AB_B1_TDD}
    Verify if RRCSetup or RRCReconfiguration Contain the dedicated part of BWP  ${TSHARK_ALIAS_AB_B1_TDD}    ${BWP_DEDICATED_RRC_SETUP_AB_B1_TDD}
    Verify if RRCSetup or RRCReconfiguration Contain the dedicated part of BWP  ${TSHARK_ALIAS_AB_B1_TDD}    ${BWP_DEDICATED_RRC_RECO_AB_B1_TDD}
