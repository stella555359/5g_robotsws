*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia

Resource    ../5GC001167/feature_keywords.robot
Variables   ../5GC001167/feature_variables.py
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library      ta5g_iphy
Library      taf.ul.ettf.setups

Suite Setup       Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_AA_B4d_FTF.xml
...               AND             With Swconfig Flags        flags=@{SWCONFIG_FLAGS_LIST}
...               AND             With Gnb Configuration    commissioning=${scfc}
...               AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}
...               AND             Reach Onair    lua_cfg=${CURDIR}/config/config_FTF_degraded.cfg
Suite Teardown    Run Keywords    Stop Default Logging
...               AND             Release Ue
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${scfc}=                                          scfc_AA_B4d_FTF.xml
${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}=               f1ap.SCell_ToBeSetupMod_List == 2
${F1AP_SCELL_TO_ADD_MOD_LIST}=                    nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 52 &&
                                             ...  nr-rrc.physCellId == 54
${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE}=      ngap.pDUSessionResourceModifyResponseTransfer &&
                                             ...  ngap.qosFlowIdentifier == 1
${F1AP_SCELL_MAXMIMOLAYER_CONFIGURATION}=         nr-rrc.sCellToAddModList && nr-rrc.physCellId == 52 &&
                                             ...  nr-rrc.physCellId == 54 && nr-rrc.maxMIMO_Layers == 4 &&
                                             ...  !nr-rrc.maxMIMO_Layers ==2

${F1AP_CSI_REPORTING_CONFIG_FOR_SCELLS}=          nr-rrc.reportConfigId == 13 && nr-rrc.reportConfigId == 14
${F1AP_CSI_RS_BEAM_REFINEMENT}=                   nr-rrc.reportConfigId == 21 && nr-rrc.reportQuantity == 6 &&
                                             ...  (nr-rrc.uplinkBandwidthPartId == 1) && (nr-rrc.pucch_Resource == 20)
${F1AP_RESOURCE_SET_TO_ADD_MOD_LIST}=             (((nr-rrc.pucch_ResourceSetId == 1) &&
                                             ...  (nr-rrc.PUCCH_ResourceId == 10) &&
                                             ...  (nr-rrc.PUCCH_ResourceId == 11) && (nr-rrc.maxPayloadSize == 8)) &&
                                             ...  ((nr-rrc.pucch_ResourceSetId == 2) &&
                                             ...  (nr-rrc.PUCCH_ResourceId == 9) && (nr-rrc.PUCCH_ResourceId == 19)) &&
                                             ...  (nr-rrc.pucch_ResourceId == 20) && (nr-rrc.pucch_ResourceId == 21))
${F1AP_CSI_MEAS_CONFIG}=                          (nr-rrc.csi_ResourceConfigId == 10) &&
                                             ...  (nr-rrc.CSI_SSB_ResourceSetId == 0)
@{SWCONFIG_FLAGS_LIST}=       ${rdMergedMeasGapSetupAndDrxRelease}

*** Test Cases ***
5GC002640-AA-B4d_SCell_Addition_of_FDD_and_TDD_SCell_With_Beamforming_Enabled_And_Beam_Refinement_Activated_FTF_Refinement_Degraged
    Attach_UE2_With_PDU_Session_Setup
    Verify_Successful_3CC_On_NGAP_And_F1AP_Messages_FTF
    Verify_Beam_Refinement_On_F1AP_UE_Contex_Modification_Resposne

*** Keywords ***
Attach_UE2_With_PDU_Session_Setup
    Set Internal Traffic Type To UEs    ue_id=2
    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=2    pdu_id=1    gw_id=1    nwslice=1

Verify_Successful_3CC_On_NGAP_And_F1AP_Messages_FTF
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}    continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}        continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST}             number_of_messages=2
                                                                               ...  continue_on_failure=False

Verify_Beam_Refinement_On_F1AP_UE_Contex_Modification_Resposne
    Verify Tcpdump Log      packet_filter=${F1AP_CSI_REPORTING_CONFIG_FOR_SCELLS}        number_of_messages=2
                                                                                    ...  continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_CSI_RS_BEAM_REFINEMENT}                 number_of_messages=2
                                                                                    ...  continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_RESOURCE_SET_TO_ADD_MOD_LIST}           number_of_messages=2
                                                                                    ...  continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_CSI_MEAS_CONFIG}                        number_of_messages=2
                                                                                    ...  continue_on_failure=False
Wait For Airphone To Stabilize
    Sleep    180s

Release Ue
    Release PDU session    ue_id=2
    Deregister UE    ue_id=2

