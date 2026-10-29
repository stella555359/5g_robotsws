*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4A_CUS
...               owner-kang.xiang    team-SG4
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    LNBTS-1:actLteNrDualConnectivity=false    LNBTS-1:actDynTrigLteNrDualConnectivity=false    LNBTS-1:actIfHo=enabled
...    LNBTS-1:actSelMobPrf=false    LNBTS-1/MODPR-0:autoAdapt=false    LNBTS-1:actMultBearers=true    LNBTS-1/LNBTS_FDD-0:actConvVoice=true
...    LNCEL-1/LNCEL_FDD-0:maxNumQci1Drb=100    LNCEL-2/LNCEL_FDD-0:maxNumQci1Drb=100    LNCEL-3/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-1/LNCEL_FDD-0:maxNumActDrb=265    LNCEL-2/LNCEL_FDD-0:maxNumActDrb=265    LNCEL-3/LNCEL_FDD-0:maxNumActDrb=265
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1700    LNCEL-3/LNCEL_FDD-0:earfcnUL=19700    LNCEL-1:threshold1=75    LNCEL-2:threshold1=76
...    LNCEL-3:threshold1=77    LNCEL-2:t301Guard=100    LNCEL-3:t301Guard=100    LNCEL-1:inactivityTimer=10
@{Delta_for_case_REDRT}    LNBTS-1:actRedirect=enabled
...    LNCEL-1/REDRT-0:csFallBPrio=1    LNCEL-1/REDRT-0:emerCallPrio=1    LNCEL-1/REDRT-0:redirectPrio=1    LNCEL-1/REDRT-0:redirBandCdma=bc0
...    LNCEL-1/REDRT-0:redirFreqCdma=81    LNCEL-1/REDRT-0:redirFreqEutra=0    LNCEL-1/REDRT-0:redirFreqUtra=0
...    LNCEL-1/REDRT-0:redirRat=cdma20001xRTT    LNCEL-1/REDRT-1:redirRat=cdma2000HRPD    LNCEL-1/REDRT-1:csFallBPrio=5
...    LNCEL-1/REDRT-1:emerCallPrio=5    LNCEL-1/REDRT-1:redirFreqCdma=81
...    delete:LNCEL-1/REDRT-0:redirGeranArfcnStructL    delete:LNCEL-1/REDRT-0:redirGeranBandIndicator
...    delete:LNCEL-1/REDRT-1:redirGeranArfcnStructL    delete:LNCEL-1/REDRT-1:redirGeranBandIndicator
@{Delta_for_1xRtt}
...    @{Delta_for_case_REDRT}
...    LNBTS-1:act1xCsfb=true    LNBTS-1:actCSFBRedir=Disabled    LNBTS-1:actCsfbPsHoToUtra=false    LNCEL-1:rttCsfbType=R9e1xCsfb
...    LNBTS-1/MODPR-0:autoAdapt=false    LNCEL-1:rttCellIdInfo=0    LNCEL-1:rand=1    LNCEL-1:c2KTimers:tC2KMeasReport=9000
...    LNCEL-1:c2KTimers:tC2KRelocPrep=5000    LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB8
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB8
...    LNCEL-1/LNHOX-1:rttCarrierFreq:rttBandClass=bc0    LNCEL-1/LNHOX-1:rttCarrierFreq:rttArfcn=2
...    LNBTS-1/LNADJX-1:bandClass=bc0    LNBTS-1/LNADJX-1:arfcn=2    LNBTS-1/LNADJX-1:cellId=1    LNBTS-1/LNADJX-1:marketId=1
...    LNBTS-1/LNADJX-1:pnOffset=1    LNBTS-1/LNADJX-1:sectorId=1    LNBTS-1/LNADJX-1:swNo=1    LNCEL-1/LNRELX-1:bandClass=bc0
...    LNCEL-1/LNRELX-1:arfcn=2    LNCEL-1/LNRELX-1:e1xCsfbAllowed=allowed    LNCEL-1/LNRELX-1:cellId=1    LNCEL-1/LNRELX-1:marketId=1
...    LNCEL-1/LNRELX-1:pnOffset=1    LNCEL-1/LNRELX-1:sectorId=1    LNCEL-1/LNRELX-1:swNo=1
...    delete:LNBTS-1/MODPR-0/MODRED-1
${1xRTT_r8}    85000060E34295472E78D18006B18006B18006B18006B18006B18006B18006A941921000C200C04018
${1xRTT_r9}    C5000060E34295472E78D18006B18006B18006B18006B18006B18006B18006A943F23800C200C040184000

*** Test Cases ***
LTE1441B_4_C_3-R8_and_R9_1xCSFB_MOCall_UE_Idle_and_Connected
    [Tags]
    #UE1
    Delta Commission Parameters And Wait Cells Onair    ${Delta_for_1xRtt}
    Execute Uex Command    ue_attach id=1 cell=1 ue_eutra_capabilities=${1xRTT_r8} ue_cdma2k_1x_rtt_capabilities=123456
    Check CDMA2000 preregistration for UE    csfb_ue=1
    Wait for IDLE state for UE_1
    Trigger CSFB for UE_1 direction mt
    #UE2
    Define Call Flow For UE2
    Setting ue params and configuring measurments for CSFB R9 for UE    csfb_ue=2
    Execute Uex Command    ue_attach id=2 cell=1 ue_eutra_capabilities=${1xRTT_r9} ue_cdma2k_1x_rtt_capabilities=123456
    Check CDMA2000 preregistration for UE    csfb_ue=2
    Trigger CSFB for UE direction mo    csfb_ue=2
    Verify Message For UE2
    #UE3
    Define Call Flow For UE3
    Configure MME to send fail for 1X CSFB HO for UE_3
    Turn on UE Radio Capability IE in S1 InitialCtxSetupReq during attach for UE_3
    Setting ue params and configuring measurments for CSFB R9 for UE    csfb_ue=3
    Execute Uex Command    ue_attach id=3 cell=1 ue_eutra_capabilities=${1xRTT_r9} ue_cdma2k_1x_rtt_capabilities=123456
    Check CDMA2000 preregistration for UE    csfb_ue=3
    Run Keyword And Ignore Error    Trigger CSFB for UE direction mo    csfb_ue=3
    Verify Message For UE3


*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc on
    Execute Egate Command    trace_sim on mme=1 protocol=s1

Wait for IDLE state for UE_1
    Expect Message Flow    MME_1:S1AP_UEContextReleaseRequest (Cause contains (radioNetwork eq "user-inactivity"))
    ...    UE_1:RRC_RRCConnectionRelease
    ...    alias=WAIT_IDLE    overall_timeout=30
    Flow occurred as expected    WAIT_IDLE

Trigger CSFB for UE_1 direction mt
    #Execute Uex command    ue_csfb    id=${csfb_ue}    ran=cdma_r8     cause=mt-Access
    Expect Message Flow    MME_1:S1AP_Paging (CNDomain eq "ps")    alias=Paging_from_MME    overall_timeout=60
    Expect Message Flow    UE_1:RRC_RRCConnectionReconfiguration    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    MME_1:S1AP_InitialContextSetupResponse    MME_1:S1AP_DownlinkS1cdma2000tunnelling (Cdma2000RATType eq "onexRTT")
    ...    alias=RRC_RRCConnReconf_and_S1AP_DownlinkS1cdma2000tunnelling
    ...    overall_timeout=60
    Expect Message Flow    UE_1:RRC_DLInformationTransfer (dedicatedInfoType contains (dedicatedInfoCDMA2000-1XRTT is present))
    ...    UE_1:RRC_ULInformationTransfer (dedicatedInfoType contains (dedicatedInfoNAS is present))
    ...    alias=RRC_InformationTransfer    overall_timeout=60
    Expect Message Flow    MME_1:S1AP_UEContextModificationRequest (CSFallbackIndicator eq "cs-fallback-required")
    ...    MME_1:S1AP_UEContextModificationResponse    UE_1:RRC_RRCConnectionRelease (cdma2000-1xRTT is present)
    ...    alias=S1AP_UEContextModification_and_RRC_RRCConnReconf    overall_timeout=60
    Expect Message Flow    MME_1:S1AP_UEContextReleaseRequest (radioNetwork eq "redirection-towards-1xRTT")
    ...    MME_1:S1AP_UEContextReleaseCommand    alias=S1AP_UEContextReleaseRequest    overall_timeout=60
    Expect Message Flow    MME_1:S1AP_UEContextReleaseComplete    alias=S1AP_UEContextReleaseComplete    overall_timeout=60
    Execute Egate Command    ue_csfb id=1 direction=mt type=1xcsfb priority=off
    Sleep    1
    Check S1 Paging from MME
    Check RRCConnReconf messages and S1AP DOWNLINK S1 CDMA2000 TUNNELING
    Check DL and UL InformationTransfer
    Verify UE Context Modification and RRCConnReconf for CDMA2000-1XRTT
    Check S1AP UE CONTEXT RELEASE REQUEST with Cause = Redirection towards 1xRTT
    Verify S1AP UE CONTEXT RELEASE COMPLETE

Check S1 Paging from MME
    Flow Occurred As Expected    Paging_from_MME

Check RRCConnReconf messages and S1AP DOWNLINK S1 CDMA2000 TUNNELING
    Flow Occurred As Expected    RRC_RRCConnReconf_and_S1AP_DownlinkS1cdma2000tunnelling

Check DL and UL InformationTransfer
    Flow Occurred As Expected    RRC_InformationTransfer

Verify UE Context Modification and RRCConnReconf for CDMA2000-1XRTT
    Flow Occurred As Expected    S1AP_UEContextModification_and_RRC_RRCConnReconf

Check S1AP UE CONTEXT RELEASE REQUEST with Cause = Redirection towards 1xRTT
    Flow Occurred As Expected    S1AP_UEContextReleaseRequest

Verify S1AP UE CONTEXT RELEASE COMPLETE
    Flow Occurred As Expected    S1AP_UEContextReleaseComplete

Setting ue params and configuring measurments for CSFB R9 for UE
    [Arguments]    ${csfb_ue}
    ### ue_param id=2 csfb_rat=cdma2000_1xrtt voice_domain_preference=lte_preferred
    ### ue_meas_param    id=2    rsrp=90    rsrq=30    eutran_neigh_cell=cfgd:1:1
    ### ue_meas_param    id=2    pilot_strength=6    pilot_phase=3333    cdma2000_neigh_cell=non_cfgd:1:81
    Execute Uex Command    ue_param id=${csfb_ue} csfb_rat=cdma2000_1xrtt voice_domain_preference=lte_preferred
    Execute Egate Command    ue_meas_param id=${csfb_ue} rsrp=90 rsrq=30 eutran_neigh_cell=cfgd:1:1
    Execute Egate Command    ue_meas_param id=${csfb_ue} pilot_strength=6 pilot_phase=3333 cdma2000_neigh_cell=non_cfgd:1:81

Check CDMA2000 preregistration for UE
    [Arguments]    ${csfb_ue}
    ${CSFBParametersResponseCDMA2000}    catenate
    ...    csfbParametersResponseCDMA2000-r8 contains ((rand is present) and (mobilityParameters is present))
    ${UplinkS1cdma2000tunnelling}    catenate
    ...    protocolIEs contains (Cdma2000RATType eq "onexRTT") and (Cdma2000SectorID is present) and (Cdma2000PDU is present)
    Expect Message Flow
    ...    UE_${csfb_ue}:RRC_CSFBParametersRequestCDMA2000
    ...    UE_${csfb_ue}:RRC_CSFBParametersResponseCDMA2000 ( ${CSFBParametersResponseCDMA2000} )
    ...    UE_${csfb_ue}:RRC_ULInformationTransfer (dedicatedInfoType contains (dedicatedInfoCDMA2000-1XRTT is present))
    ...    MME_1:S1AP_UplinkS1cdma2000tunnelling ( ${UplinkS1cdma2000tunnelling} )
    ...    MME_1:S1AP_DownlinkS1cdma2000tunnelling
    ...    UE_${csfb_ue}:RRC_DLInformationTransfer (dedicatedInfoType contains (dedicatedInfoCDMA2000-1XRTT is present))
    ...    alias=S1AP_DownlinkS1cdma2000tunnelling    overall_timeout=30    # preregister
    Execute Uex Command    ue_ul_dcch id=${csfb_ue} send=0280
    Execute Uex Command    ue_ul_dcch id=${csfb_ue} send=48209FE0802020
    Flow Occurred As Expected    S1AP_DownlinkS1cdma2000tunnelling

Define Call Flow For UE2
    ${HandoverFromEUTRAPreparationRequest}    catenate
    ...    handoverFromEUTRAPreparationRequest-r8 contains ((cdma2000-Type eq "type1XRTT")
    ...    and (rand is present) and (mobilityParameters is present))
    ${ULHandoverPreparationTransfer}    catenate
    ...    ulHandoverPreparationTransfer-r8 contains ((cdma2000-Type eq "type1XRTT") and (meid is present) and (dedicatedInfo is present))
    ${UplinkS1cdma2000tunnelling}    catenate
    ...    protocolIEs contains (Cdma2000RATType eq "onexRTT") and (Cdma2000SectorID is present)
    ...    and (Cdma2000HORequiredIndication eq "true") and (Cdma2000OneXSRVCCInfo is present)
    ...    and (Cdma2000OneXRAND is present) and (Cdma2000PDU is present)
    ${DownlinkS1cdma2000tunnelling}    catenate
    ...    (Cdma2000HOStatus eq "hOSuccess") and (Cdma2000RATType eq "onexRTT") and (Cdma2000PDU is present)
    Expect Message Flow    UE_2:RRC_ULInformationTransfer (dedicatedInfoType contains (dedicatedInfoNAS is present))
    ...    alias=RRC_ULInformationTransfer    overall_timeout=60
    Expect Message Flow    MME_1:S1AP_UplinkNASTransport    alias=S1AP_UplinkNASTransport    overall_timeout=60
    Expect Message Flow    MME_1:S1AP_UEContextModificationRequest (CSFallbackIndicator eq "cs-fallback-required")
    ...    UE_2:RRC_RRCConnectionReconfiguration (measObjectToAddModList contains (cdma2000-Type eq "type1XRTT"))
    ...    UE_2:RRC_RRCConnectionReconfigurationComplete
    ...    alias=S1AP_UEContextModificationRequest_AND_RRC_RRCConnectionReconfiguration    overall_timeout=60
    Expect Message Flow    MME_1:S1AP_UEContextModificationResponse
    ...    UE_2:RRC_MeasurementReport (measResultNeighCells contains (measResultListCDMA2000 is present))
    ...    alias=RRC_MeasurementReport    overall_timeout=60
    Expect Message Flow    UE_2:RRC_HandoverFromEUTRAPreparationRequest ( ${HandoverFromEUTRAPreparationRequest} )
    ...    alias=RRC_HandoverFromEUTRAPreparationRequest    overall_timeout=60
    Expect Message Flow    UE_2:RRC_ULHandoverPreparationTransfer ( ${ULHandoverPreparationTransfer} )
    ...    alias=RRC_ULHandoverPreparationTransfer    overall_timeout=60
    Expect Message Flow    MME_1:S1AP_UplinkS1cdma2000tunnelling ( ${UplinkS1cdma2000tunnelling} )
    ...    MME_1:S1AP_DownlinkS1cdma2000tunnelling ( ${DownlinkS1cdma2000tunnelling} )
    ...    alias=S1AP_UL_and_DL_cdma2000tunnelling    overall_timeout=60
    Expect Message Flow    UE_2:RRC_MobilityFromEUTRACommand (purpose contains (e-CSFB-r9 is present))
    ...    alias=RRC_MobilityFromEUTRACommand    overall_timeout=60
    Expect Message Flow    MME_1:S1AP_UEContextReleaseRequest (radioNetwork eq "redirection-towards-1xRTT")
    ...    MME_1:S1AP_UEContextReleaseCommand    alias=S1AP_UEContextReleaseRequest    overall_timeout=60
    Expect Message Flow    MME_1:S1AP_UEContextReleaseComplete    alias=S1AP_UEContextReleaseComplete    overall_timeout=60

Trigger CSFB for UE direction mo
    [Arguments]    ${csfb_ue}
    Execute Uex Command    ue_csfb id=${csfb_ue} ran=cdma_r9 cause=mo_VoiceCall_v1280
    Sleep    1

Verify Message For UE2
    UE responds RRC ULInformationTransfer with NAS EXTENDED SERVICE REQUEST with Service Type 1xCS fallback
    eNB sends UPLINK NAS TRANSPORT
    Check RRCConnReconf and RRCConnReconfCompl message after CS Fallback required
    UE sends MeasurementReport with measResultListCDMA2000
    Verify RRC HandoverFromEUTRAPreparationRequest with CDMA2000-Type=type1XRTT
    UE respones with RRC ULHandoverPreparationTransfer
    eNB sends S1AP UPLINK and DOWNLINK CDMA2000 TUNNELING with CDMA2000 HO Success
    Verify RRC MobilityFromEUTRACommand with mobilityFromEUTRACommand-r9=e-CSFB-r9
    Check S1AP UE CONTEXT RELEASE REQUEST with Cause = Redirection towards 1xRTT
    Verify S1AP UE CONTEXT RELEASE COMPLETE

UE responds RRC ULInformationTransfer with NAS EXTENDED SERVICE REQUEST with Service Type 1xCS fallback
    Flow Occurred As Expected    RRC_ULInformationTransfer

eNB sends UPLINK NAS TRANSPORT
    Flow Occurred As Expected    S1AP_UplinkNASTransport

Check RRCConnReconf and RRCConnReconfCompl message after CS Fallback required
    Flow Occurred As Expected    S1AP_UEContextModificationRequest_AND_RRC_RRCConnectionReconfiguration

UE sends MeasurementReport with measResultListCDMA2000
    Flow Occurred As Expected    RRC_MeasurementReport

Verify RRC HandoverFromEUTRAPreparationRequest with CDMA2000-Type=type1XRTT
    Flow Occurred As Expected    RRC_HandoverFromEUTRAPreparationRequest

UE respones with RRC ULHandoverPreparationTransfer
    Flow Occurred As Expected    RRC_ULHandoverPreparationTransfer

eNB sends S1AP UPLINK and DOWNLINK CDMA2000 TUNNELING with CDMA2000 HO Success
    Flow Occurred As Expected    S1AP_UL_and_DL_cdma2000tunnelling

Verify RRC MobilityFromEUTRACommand with mobilityFromEUTRACommand-r9=e-CSFB-r9
    Flow Occurred As Expected    RRC_MobilityFromEUTRACommand

Define Call Flow For UE3
    Expect Message Flow
    ...    MME_1:S1AP_UplinkS1cdma2000tunnelling
    ...    MME_1:S1AP_DownlinkS1cdma2000tunnelling (Cdma2000HOStatus eq "hOFailure")
    ...    alias=S1AP_CDMA2000_HOFailure   overall_timeout=30
    Expect Message Flow
    ...    UE_3:RRC_DLInformationTransfer (dedicatedInfoType contains (dedicatedInfoCDMA2000-1XRTT is present))
    ...    alias=RRC_DLInformationTransfer   overall_timeout=30
    Expect Message Flow
    ...    UE_3:RRC_RRCConnectionReconfiguration (measConfig contains (measIdToRemoveList is present))
    ...    UE_3:RRC_RRCConnectionReconfigurationComplete
    ...    alias=RRC_RRCConnectionReconfiguration_with_removal   overall_timeout=30

Configure MME to send fail for 1X CSFB HO for UE_3
    ### ue_mme_param id=2 1x_csfb_ho_action=sendFail
    Execute Egate Command    ue_mme_param id=3 1x_csfb_ho_action=sendFail

Turn on UE Radio Capability IE in S1 InitialCtxSetupReq during attach for UE_3
    Execute Egate Command    ue_mme_param id=3 ue_capa_attach=on

MME responds with HO Failure in S1 DOWNLINK CDMA2000 TUNNELLING
    Flow Occurred As Expected       S1AP_CDMA2000_HOFailure

Verify RRC Connection Reconfiguration with removal of 1xCSFB measurment configuration
    Flow Occurred As Expected       RRC_RRCConnectionReconfiguration_with_removal

eNB sends RRC DLInformationTransfer with dedicatedInfoType equal to dedicatedInfoCDMA2000-1XRTT
    Flow Occurred As Expected       RRC_DLInformationTransfer

Verify Message For UE3
    MME responds with HO Failure in S1 DOWNLINK CDMA2000 TUNNELLING
    eNB sends RRC DLInformationTransfer with dedicatedInfoType equal to dedicatedInfoCDMA2000-1XRTT
    Verify RRC Connection Reconfiguration with removal of 1xCSFB measurment configuration


