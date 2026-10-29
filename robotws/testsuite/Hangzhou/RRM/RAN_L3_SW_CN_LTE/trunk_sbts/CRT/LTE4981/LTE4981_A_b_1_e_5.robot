*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CRT
...               CLOUD_R4BANO_CUS    owner-KRK    team-DEVHZ5_SG6    release-SBTS20B    NEW_HW_ABION
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${SOS_REPORT_FLAG}    pass:False,fail:False
${SNAPSHOT_FLAG}     pass:False,fail:False
${SOS_REPORT_STARTUP_1_FLAG}   pass:False,fail:False
@{Precondition_A_b_1}
...    LNBTS-1:actDrxCoordEnDc=basic DRX coordination
...    LNBTS-1:actDynTrigLteNrDualConnectivity=true
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1/NRMEASDPR-0:measGapEnabledNRMeas=Disable
...    LNBTS-1:actMeasGapCoordEnDc=eNB initiated
...    LNBTS-1:actMeasGapIfEnDc=true
...    LNBTS-1:actMultiSCGSplit=true
...    LNBTS-1:actStepAddBearENDC=true
...    LNCEL-1:actDrx=true
...    LNCEL-1:actDrxDuringMeasGap=true
@{Precondition_A_e_5}
...    LNBTS-1:actDrxCoordEnDc=basic DRX coordination
...    LNBTS-1:actDynTrigLteNrDualConnectivity=true
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1:actMeasGapCoordEnDc=eNB initiated
...    LNBTS-1:actMeasGapIfEnDc=true
...    LNCEL-1:actDrx=true
...    LNCEL-1:actDrxDuringMeasGap=true
...    LNBTS-1:actDLCAggr=false
...    LNBTS-1/NRMEASDPR-0:measGapEnabledNRMeas=Disable
${ue_eutra_capabilities}
...    SEPARATOR=
...    DE3804820830704080200837F7FFD900100383C800000002A54ADC6020E1000018C00000384000023000082008141000000A3886
...    380252980602FFA15000300452E00004000020963400135E000001880000009000020840
${ue_nr_capabilities}
...    SEPARATOR=
...    0000000001010040000060000038000134040360401C06000E0380071340000000
${ue_eutra_nr_capabilities}
...    SEPARATOR=
...    0108080160401C4D000000013020040C1C4D0000020084000201010020044000100800040202004008

*** Test Cases ***
LTE4981-A-b_1 DRX and MGAP not coordinated when additional SCG split bearers are configured for UE already in EN-DC
    [Tags]
	Online commission    ${Precondition_A_b_1}
    Prepare test environment for UE    2
    Trigger MME to setup new EN-DC eligible bearer for UE_2
    Verify if MeNB configures EN-DC eligible bearer without change of measGapConfig or drx-Config at UE_2
	Verify if SgNBModificationRequest do not contain measGapConfig and drx-InfoMCG at UE_2
    Verify if MeNB changes bearer type to SCG without change of measGapConfig or drx-Config at UE_2

LTE4981-A-e_5 MGAP and DRX configuration reevaluated at takeback despite actMeasGapIfEnDc on-line reconfiguration
    [Tags]
	Online commission    ${Precondition_A_e_5}
    Prepare test environment for UE    9
	Prepare test environment for UE    10
    Trigger SgNB_2 to perform bearer take back on UE_9 with cause:RN_switch_off_ongoing
    Verify if UE_9 RRC Connection Reconfiguration with take back, B1-NR measurement activation, drxProfile3 and measGapConfig release
    Set LNBTS/actMeasGapIfEnDc to FALSE
    Trigger SgNB_2 to perform bearer take back on UE_10 with cause:RN_switch_off_ongoing
    Verify if UE_10 RRC Connection Reconfiguration with take back, B1-NR measurement activation, drxProfile3 and measGapConfig release
	
*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=LTE4981_A_b_BANO
    Create Ue Alias     UE_2    id_type=cus    ue_id=2
	Create Ue Alias     UE_9    id_type=cus    ue_id=9
	Create Ue Alias     UE_10    id_type=cus    ue_id=10
    Create mme alias    alias=MME_1     mme_id=1    id_type=wts
    Create enb alias    alias=MeNB      enb_id=1    id_type=wts
    Create enb alias    alias=SgNB_1    enb_id=2    id_type=wts
    Create enb alias    alias=SgNB_2    enb_id=3    id_type=wts

Online commission
    [Arguments]    ${parameters}
    Delta Commission Parameters    ${parameters}
    Cells should be onair
	
Prepare test environment for UE
    [Arguments]    ${ue_id}=2
	UE attach    ue_id=${ue_id}
    Verify if MeNB configures A2 measurement, B1-NR measurement, drx-Config set to drxProfile3 and no MGAP at UE    ${ue_id}
    Trigger UE to send A2 report with RSRP below threshold2InterFreq    ${ue_id}
    Verify if MeNB configures InterFreq measurements without changing measGapConfig nor drx-Config    ${ue_id}
    Trigger UE to send B1-NR report with RSRP above b1ThresholdNrRsrp    ${ue_id}
    Verify if SgNBAdditionRequest contains measGapConfig, gapPurpose and drx-LongCycleStartOffset based on drxProfile2 at UE    ${ue_id}
    Verify if MeNB deactivates B1-NR measurement,sets measGapConfig and LongDRX-CycleStartOffset based on drxProflie2 at UE    ${ue_id}

UE attach
    [Arguments]    ${ue_id}=2
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionRequest
    ...    UE_${ue_id}:RRC_RRCConnectionSetup
    ...    UE_${ue_id}:RRC_RRCConnectionSetupComplete
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupItemCtxtSUReq contains (e-RABlevelQoSParameters contains (qCI eq 8)))
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    alias=UE_ATTACH_UE_${ue_id}    overall_timeout=10
    ${reconfig_1}   catenate
	...    eventA2 is present and
	...    eventB1-NR-r15 is present and
	...    measGapConfig contains (release is present) and
	...    drx-Config contains (setup contains (
    ...    onDurationTimer eq 'psf6' and
    ...    drx-InactivityTimer eq 'psf10' and
    ...    drx-RetransmissionTimer eq 'psf4' and
    ...    longDRX-CycleStartOffset contains (sf80 is present)))
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${reconfig_1})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=FIRST_RRCCONNRECONF_UE_${ue_id}    overall_timeout=60
	${V_1}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} \ ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} cell=11
    Execute Uex Command    ${V_1}
	Flow occurred as expected    alias=UE_ATTACH_UE_${ue_id}
	
Verify if MeNB configures A2 measurement, B1-NR measurement, drx-Config set to drxProfile3 and no MGAP at UE
    [Arguments]    ${ue_id}=2  
    Flow occurred as expected    alias=FIRST_RRCCONNRECONF_UE_${ue_id}

Trigger UE to send A2 report with RSRP below threshold2InterFreq
    [Arguments]    ${ue_id}=2
    Expect message flow
    ...    UE_${ue_id}:RRC_MeasurementReport
    ...    alias=MeasReport_UE_${ue_id}   overall_timeout=10
	#drxProfile3
	${InterFreq_reconf}   catenate
	...    eventA1 is present and
	...    eventA3 is present and
	...    eventA5 is present and
	...    measGapConfig is not present and
	...    drx-Config is not present and
	...    measIdToRemoveList contains (7)
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${InterFreq_reconf})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_RECONF_AFTER_A2_UE_${ue_id}   overall_timeout=10
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=30 srsrq=8
    Flow occurred as expected  alias=MeasReport_UE_${ue_id}
	
Verify if MeNB configures InterFreq measurements without changing measGapConfig nor drx-Config
    [Arguments]    ${ue_id}=2
    Flow occurred as expected  alias=UE_RECONF_AFTER_A2_UE_${ue_id}

Trigger UE to send B1-NR report with RSRP above b1ThresholdNrRsrp
    [Arguments]    ${ue_id}=2
    Expect message flow
    ...    UE_${ue_id}:RRC_MeasurementReport
    ...    alias=MeasReportB1_UE_${ue_id}   overall_timeout=10
	#drxProfile2
	${addReq}   catenate
	...    drx-LongCycleStartOffset contains (ms40 is present) and
	...    measGapConfig is present and
	...    gapPurpose eq 'perUE'
    Expect message flow
    ...    SgNB_1:X2AP_SgNBAdditionRequest (${addReq})
    ...    MeNB:X2AP_SgNBAdditionRequestAcknowledge
    ...    alias=SGNB_ADD_REQ_UE_${ue_id}   overall_timeout=50
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (drx-Config is present and measGapConfig is present and measIdToRemoveList contains (17))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=RECONF_AFTER_SPLIT_UE_${ue_id}   overall_timeout=50
    Sleep   1s
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=381 nrsrp=120 srsrp=30
    Flow occurred as expected  alias=MeasReportB1_UE_${ue_id}

Verify if SgNBAdditionRequest contains measGapConfig, gapPurpose and drx-LongCycleStartOffset based on drxProfile2 at UE
    [Arguments]    ${ue_id}=2
    Flow occurred as expected  alias=SGNB_ADD_REQ_UE_${ue_id}

Verify if MeNB deactivates B1-NR measurement,sets measGapConfig and LongDRX-CycleStartOffset based on drxProflie2 at UE
    [Arguments]    ${ue_id}=2
    Flow occurred as expected  alias=RECONF_AFTER_SPLIT_UE_${ue_id}

Trigger MME to setup new EN-DC eligible bearer for UE_${ue_id}
    #[Arguments]    ${ue_id}=2
    Expect message flow
    ...    SgNB_1:X2AP_SgNBModificationRequest (measGapConfig is not present and drx-InfoMCG is not present)
    ...    alias=SGNB_MOD_Request_UE_${ue_id}    overall_timeout=40
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration as scg_bearer_addition
    ...    SgNB_1:X2AP_SgNBModificationRequestAcknowledge
    ...    SgNB_1:X2AP_SgNBReconfigurationComplete
    ...    alias=SCG_BEARER_ADD_UE_${ue_id}    overall_timeout=20
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measGapConfig is not present and drx-Config is not present)
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_RECONF_AFTER_SCG_UE_${ue_id}   overall_timeout=120
    Execute Uex Command    bearer_add ue=${ue_id} qci=9

Verify if MeNB configures EN-DC eligible bearer without change of measGapConfig or drx-Config at ${ue_alias:([^\s]+)}
    Flow occurred as expected  alias=SCG_BEARER_ADD_${ue_alias}
    Verify That Message Does Not Have Field    flow_alias=SCG_BEARER_ADD_${ue_alias}  message_alias=scg_bearer_addition  field_name=measGapConfig
    Verify That Message Does Not Have Field    flow_alias=SCG_BEARER_ADD_${ue_alias}  message_alias=scg_bearer_addition  field_name=drx-Config
	
Verify if SgNBModificationRequest do not contain measGapConfig and drx-InfoMCG at ${ue_alias:([^\s]+)}
    Flow occurred as expected  alias=SGNB_MOD_Request_${ue_alias}
	
Verify if MeNB changes bearer type to SCG without change of measGapConfig or drx-Config at ${ue_alias:([^\s]+)}
    Flow occurred as expected  alias=UE_RECONF_AFTER_SCG_${ue_alias}

Trigger SgNB_2 to perform bearer take back on UE_${ue_id} with cause:${cause}
    Expect message flow
    ...    MeNB:X2AP_SgNBReleaseRequired
    ...    SgNB_1:X2AP_SgNBReleaseConfirm
    ...    MeNB:X2AP_SNStatusTransfer
    ...    alias=TAKEBACK   overall_timeout=50
	#drxProfile3
	${reconf_after_takeback}    catenate
	...    measIdToAddModList contains (measId eq 17 and measObjectId eq 2) and
    ...    onDurationTimer eq 'psf6' and
    ...    drx-InactivityTimer eq 'psf10' and
    ...    drx-RetransmissionTimer eq 'psf4' and
    ...    longDRX-CycleStartOffset contains (sf80 is present) and
    ...    measGapConfig contains (release is present)	
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${reconf_after_takeback})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=SgNBReleaseConfirmWithoutIE_UE_${ue_id}   overall_timeout=60
    Execute Egate Command    enb_ue_dc_release by=gnb cause=${cause} ue=${ue_id} bearer=8
    Flow occurred as expected  alias=TAKEBACK

Verify if ${ue_alias:([^\s]+)} RRC Connection Reconfiguration with take back, B1-NR measurement activation, drxProfile3 and measGapConfig release
    Flow occurred as expected  alias=SgNBReleaseConfirmWithoutIE_${ue_alias}
	
Set LNBTS/actMeasGapIfEnDc to FALSE
	Online commission    LNBTS-1:actMeasGapIfEnDc=false
