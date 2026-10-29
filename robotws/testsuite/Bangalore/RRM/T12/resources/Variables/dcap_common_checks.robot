*** Settings ***
Documentation    This file Contains Common Variable used across the Feature folder

*** Variables ***
${UE_REG}               REGISTRATION COMPLETE
${RRC_RECON}            rrcReconfiguration
${RRC_RECON_COMP}       rrcReconfigurationComplete
${PDU_MOD_REQ}          PDUSessionResourceModifyRequest
${PDU_MOD_RESP}         PDUSessionResourceModifyResponse
${DRX_REL}              DRXConfigurationIndicator
${MEAS_REP}             measurementReport
${ICS_REQ}              InitialContextSetupRequest
${ICS_RESP}             InitialContextSetupResponse
${HO_REQ}               HandoverRequired
${NG_HO_SUC}            successful-handover
${HO_CMD}               HandoverCommand
${LTE_5G_REQ}           HandoverRequest
${LTE_5G_RESP}          HandoverRequestAcknowledge
${HO_NOTIFY}            HandoverNotify
${HO_PREP_INFO}         HandoverPreparationInformation
${DEREG_REQ}            DEREGISTRATION REQUEST
${SN_STATUS}            SNStatusTransfer
${PATH_SW_REQ}          PathSwitchRequest
${PATH_SW_ACK}          PathSwitchRequestAcknowledge
${IAGNB_SRC}            IntraGnbSourceHo
${IAGNB_TGT}            IntraGnbTargetHo
${RRE_REQ}              rrcReestablishmentRequest
${RRE_COMP}             rrcReestablishmentComplete
${X2_SETUP_REQ}         ENDCX2SetupRequest
${X2_SETUP_RESP}        ENDCX2SetupResponse
${SGNB_ADD_REQ}         SgNBAdditionRequest
${SGNB_ADD_REQ_ACK}     SgNBAdditionRequestAcknowledge
${SGNB_RECON_COMP}      SgNBReconfigurationComplete
${NSA_CALL}             InitialNsaCall
${SGNB_REL_REQ}         SgNBReleaseRequest
${SGNB_REL_ACK}         SgNBReleaseRequestAcknowledge
${GHOST_UE_CAUSE}       GHOSTUERELEASE
