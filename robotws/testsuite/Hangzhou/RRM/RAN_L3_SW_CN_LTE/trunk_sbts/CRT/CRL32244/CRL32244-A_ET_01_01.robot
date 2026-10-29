*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs And Set UE parameters before ENDC setup
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS    owner-yu.1.zhou
...               release-SBTS20B    team-SG3
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS:mcc=262
...    LNBTS:mnc=3
...    LNBTS:mncLength=2
...    LNBTS:actMultBearers=true
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1:harqMaxTrVoLteDl=4
...    LNCEL-2:harqMaxTrVoLteDl=4
...    LNCEL-3:harqMaxTrVoLteDl=4
...    LNCEL-1/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-2/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-3/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-1:tac=33
...    LNCEL-2:tac=33
...    LNCEL-3:tac=33
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1450
...    @{NRDCDPR}
...    @{pMaxOwnCell}
...    @{actDynTrigLteNrDualConnectivity}
...    @{NRDCPR}
...    @{LNADJGNB}
...    @{LNRELGNBCELL}
...    @{qciTab6}
...    @{qciTab8}
...    @{pdcpProfileId}
@{NRDCDPR}
...    LNBTS/NRDCDPR-0:tPeriodicPhr=1000sf
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=531000
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=100
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrq=-87
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=6
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=7
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4
@{pMaxOwnCell}
...    LNCEL-1/SIB-0:pMaxOwnCell=-10
@{actDynTrigLteNrDualConnectivity}
...    LNBTS:tmpActFeat1=1
...    LNBTS:actDynTrigLteNrDualConnectivity=false
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=500
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNBTS:imsEmerPlmnConfig:emerSessArpPrioLev=1
...    LNBTS/LNBTS_FDD-0:actIMSEmerSessR9=true
...    LNBTS-1:actEndcSpidFwd=false
...    LNBTS-1:tS1eRABModInd=2000
...    LNBTS-1:endcSchedWeightBoostDl=2
...    LNBTS-1:endcSchedWeightBoostUl=2
...    LNBTS-1:nrRestrictionOverride=disabled
...    LNBTS-1:actTransmittedBelowGap=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
@{NRDCPR}
...    LNBTS/NRMEASPR-0:cellList=1
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:carrierFreqNrCell=531000
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrp=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrq=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbOffset=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS/NRDCPR-0:enDCpMaxEUTRApowerOffset=4
...    LNBTS/NRDCPR-0:enDCpMaxNRpowerOffset=5
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1ThresholdNrRsrp=100
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1ThresholdNrRsrq=-87
${ue_nr_capabilities}    0000000001010000000060100581007018000000
${ue_eutra_nr_capabilities}    0108040160401C06000000000400020101002004
@{LNADJGNB}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
@{LNRELGNBCELL}
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
@{qciTab6}
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC
...    LNBTS:qciTab6:nrPdcpProfIdx=1001
@{qciTab8}
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC
...    LNBTS:qciTab8:nrPdcpProfIdx=1001
@{pdcpProfileId}
...    LNBTS:pdcpProf1001:pdcpProfileId=1001
...    LNBTS:pdcpProf1001:snSizeDl=18bit
...    LNBTS:pdcpProf1001:snSizeUl=18bit
...    LNBTS:pdcpProf1001:statusRepReq=0
...    LNBTS:pdcpProf1001:tDiscard=300ms
${gnb7_cell1}    SEPARATOR=
...    {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x501', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', 
...    meas_timing_carrier_freq: ${NRARFCN2036667}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell2}    SEPARATOR=
...    {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x502', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', 
...    meas_timing_carrier_freq: ${NRARFCN2036667}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

*** Test Cases ***
CRL32244-A_ET_01_01_RCR to target accept during X2 deltaConfig HO with MCG bearer and source context
    [Tags]
    UE1 attach to sim eNB2 cell21 with QCI6
    UE2 attach to sim eNB2 cell21 with QCI6 and setup QCI8
    RCR to target accept for UE1 with 1 MCG bearer during X2 deltaConfig HO before HO confirm
    RCR to target accept for UE2 with 2 MCG bearer during X2 deltaConfig HO before HO confirm
    [Teardown]    Common Test Teardown And Stop Capture Logs And Release UEs

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD_ABIO
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,s1 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    ENB_2    enb_id=2    id_type=wts
    Create Enb alias    alias=gNB    enb_id=7    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Common Test Setup And Start To Capture Logs And Set UE parameters before ENDC setup
    Common Test Setup And Start To Capture Logs
    Set UE parameters before ENDC setup

Common Test Teardown And Stop Capture Logs And Release UEs
    Release All UEs	
    Common Test Teardown And Stop Capture Logs
	
Set UE parameters before ENDC setup
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=7 protocol=x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2 on
    Execute Egate Command    ue_param id=1-4,11-15 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Egate Command    ue_param id=1-4,11-15 nr_supported_bands=7
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    enb_param id=2 endc_capable_qci=6,8
    Execute Egate Command    enb_x2_link_up enb=2 target=7    is up
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command    enb_timer T_DC_Overall=5000ms

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 320, mbr_ul: 32, mbr_dl: 320, preemption: off, vulnerability: off, pdn: 1}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 5, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    ...     - {qci: 7, pdn: 1}
    ...     - {qci: 9, pdn: 1}
    Update Yaml    UEs/UE_sets/1     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2     bearer: bearer_set_2
    # add sim enb2
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.3
    ...      cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '7:0', earfcn: '1400:19400', bw: 20}
    ...        - {id: 22, technology: lte, tac: 33, pci: '7:1', earfcn: '1600:19600', bw: 20}
    ...        - {id: 23, technology: lte, tac: 33, pci: '7:2', earfcn: '1800:19800', bw: 20}
    # add sim gnb7
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2_peers: 1
    ...      cells:
    ...        - ${gnb7_cell1}
    ...        - ${gnb7_cell2}

UE1 attach to sim eNB2 cell21 with QCI6
    [Arguments]    ${ue_id}=1
    Execute Uex Command
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} cell=21 enb=2

UE2 attach to sim eNB2 cell21 with QCI6 and setup QCI8
    [Arguments]    ${ue_id}=2
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (drb-ToAddModList contains (eps-BearerIdentity eq 5))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (drb-ToAddModList contains (eps-BearerIdentity eq 6))
    ...    alias=setup_qci_6_8    overall_timeout=20
    Execute Uex Command
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} cell=21 enb=2
    Execute Uex Command    bearer_add ue=${ue_id} qci=8 mbr_ul=32 mbr_dl=320 gbr_ul=32 gbr_dl=320
    Flow Occurred As Expected    alias=setup_qci_6_8

RCR to target accept for UE1 with 1 MCG bearer during X2 deltaConfig HO before HO confirm
    [Arguments]    ${ue_id}=1
    Expect Message Will Not Occur
    ...    ENB_1:X2AP_HandoverRequestAcknowledge (fullConfig-r9 eq true)
    ...    alias=no_fullConfig_1    overall_timeout=20
    ${one_mcg_bearer}    catenate
	...    RadioBearerConfig contains (
    ...        drb-ToAddModList contains (
    ...            (drb-Identity eq 1) and 
    ...            (reestablishPDCP eq 'true'))
    ...    )
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishmentRequest (reestablishmentCause eq 'handoverFailure')
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishmentComplete
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${one_mcg_bearer})
    ...    alias=RCR_success_1    overall_timeout=20
    Execute Egate Command    ue_enb_param id=1 ue_config_release_r9=rel15
    Execute Egate Command    enb_param id=2 ho_source=x2
    Execute Uex Command    ue_ho id=1 enb=1 cell=1 fail=dest phase=T304_expiry
    Flow Occurred As Expected    alias=RCR_success_1
    Flow Not Occurred For Message    alias=no_fullConfig_1

RCR to target accept for UE2 with 2 MCG bearer during X2 deltaConfig HO before HO confirm
    [Arguments]    ${ue_id}=2
    Expect Message Will Not Occur
    ...    ENB_1:X2AP_HandoverRequestAcknowledge (fullConfig-r9 eq true)
    ...    alias=no_fullConfig_2    overall_timeout=20
    ${two_mcg_bearers}    catenate
    ...    RadioBearerConfig contains (
    ...        drb-ToAddModList contains (
    ...             (drb-Identity eq 1) and
    ...             (reestablishPDCP eq 'true'),
    ...             (drb-Identity eq 2) and
    ...             (reestablishPDCP eq 'true'))
    ...    )
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 1))
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishmentRequest (reestablishmentCause eq 'handoverFailure')
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishmentComplete
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${two_mcg_bearers})
    ...    alias=RCR_success_2    overall_timeout=20
    Execute Uex Command
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=mobilityControlInfo action=reestablish cell=1 cause=handoverFailure
    Execute Egate Command    ue_enb_param id=${ue_id} ue_config_release_r9=rel15
    Execute Egate Command    enb_param id=${ue_id} ho_source=x2
    Execute Uex Command And Expect Error    ue_ho id=${ue_id} enb=1 cell=1    sErrTransactionInProgress
    Flow Occurred As Expected    alias=RCR_success_2
    Flow Not Occurred For Message    alias=no_fullConfig_2
