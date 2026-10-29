*** Settings ***

Documentation    :copyright: Nokia

*** Variables ***

${SETUP_TL}=    ${TRUE}
${ADDITIONAL_RESET}=    ${TRUE}
${RESTORE_DEFAULT_CONFIG}=    ${FALSE}


${MEAS_GAP_RELEASE}=    x2ap.SgNBModificationRequest_element && nr-rrc.measGapConfig == 0
${DRX_SETUP}=    x2ap.SgNBModificationRequired_element && nr-rrc.drx_Config == 1
${EXPECTED_NRADJNRCELL_OBJECTID}=    256
${FAILED_HO_REGEXP}=    Bearer-type change from SCG-split to MCG is successful
${SUCCESSFUL_HO_REGEXP}=    Proxy \\(eNB 2 cell 2\\) reported successful RA
${SGNBADDITION_REQ_WITH_CGI_REPORTING_ENDC}=
...    ${X2AP_SGNB_ADDITION_REQUEST} && nr-rrc.nr_CGI_Reporting_ENDC == 0
${NRREL_OBJECT_CREATION_TIME} =    120
${SPCELL_CONFIG_AND_PHYS_CELL_ID}=    nr-rrc.spCellConfigCommon_element && nr-rrc.physCellId == 51
${NRRRC_MCC}=  (nr-rrc.MCC_MNC_Digit == 3 && nr-rrc.MCC_MNC_Digit == 1 && nr-rrc.MCC_MNC_Digit == 1)
${NRRRC_MNC}=  (nr-rrc.MCC_MNC_Digit == 4 && nr-rrc.MCC_MNC_Digit == 8 && nr-rrc.MCC_MNC_Digit == 9)
${SgNBAdditionReqWitchCGIReportingENDC}=  ${X2AP_SGNB_ADDITION_REQUEST} && nr-rrc.nr_CGI_Reporting_ENDC == 0
${SgNBModifReq_RRCReconf}=  ${X2AP_SGNB_MODIFICATION_REQUIRED} && nr-rrc.cellForWhichToReportCGI == 51
${SgNBModif_RRC_ReconfCompl}=  ${X2AP_SGNB_MODIFICATION_CONFIRM}
${NRRRC_MeasReap}=   nr-rrc.physCellId == 50 && nr-rrc.physCellId == 51 && nr-rrc.cellIdentity == 00:00:04:00:20
${NRRRC_Reconf_reconfigurationWithSync}=  ${RECONFIGURATION_WITH_SYNC} && ${SPCELL_CONFIG_AND_PHYS_CELL_ID}
${NRRRC_ReconfComp} =   ${RRC_RECONFIGURATION_COMPLETE} && x2ap.MeNBtoSgNBContainer == 40
${HANDOVER_SUCCESS}=    ${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ${SUCCESSFUL_HANDOVER}
${REPORT_EUTRA_CGI} =    nr-rrc.reportType == reportCGI && nr-rrc.cellForWhichToReportCGI == 30
${REPORT_MEASUREMENT_GAP} =    nr-rrc.gapUE == 0


${NRRELE_OBJECT_CREATION_TIME} =    120
${NRADJECELL_OBJECT_CREATION_TIME} =    120
${NRRELE_ID} =    256
${NRADJECELL_ID} =    5000
${EXPECTED_NRREL_OBJECTID_2ND}=    255
${EXPECTED_NRREL_OBJECTID_1ST}=    256
${FAULT_ID_MAX_RELATION_ANR} =    8300
${SECOND_NRREL_ID}=       255
${FIRST_NRREL_ID}=       256
${NRADJCELL_ID} =    12288


${NSA_UE1_CELL1}=    11
${NSA_UE2_CELL1}=    12
${NSA_UE3_CELL1}=    13
${SA_UE1_CELL1}=    1
${SA_UE2_CELL1}=    2
${SA_UE3_CELL1}=    3
${SA_UE4_CELL1}=    4
${SA_UE5_CELL1}=    5
${SA_UE6_CELL1}=    6



