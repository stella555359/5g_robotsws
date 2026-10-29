*** Settings ***
Suite Setup       Common Suite Setup and Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO    team-CN3ET
...               owner-pei.han    release-SBTS20C
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${GSCN7881}    636672
@{PARAMS_IN_SCF}
...    LNBTS:actAmbrModCaTrigger=false
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:actTransmittedBelowGap=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    @{CA}
...    @{x2link}
...    @{LTE4088}
...    @{LTE4193}
...    @{LTE4549}
...    ${EMPTY}
...    @{MFBI}
...    @{Tput_parameter}
...    @{nrRestrictionOverride}
...    @{SelectScellMappedBand}
...    @{Handover}
...    @{LTE4530}
...    LNCEL-1/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-2/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-2/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-3/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=700
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=2050
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=5100
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=18700
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=20050
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=23100
@{CA}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAdvScellMeas=true
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=5
...    LNCEL:maxNumScells=2
...    LNBTS-1/CADPR-0:maxNumMimoLayerFdd=10
...    LNCEL:caPoolId=1
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    delete:LNCEL-1/CAREL-2:beamformingInScellAllowed
...    LNCEL-3/CAREL-1:lcrId=1
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-3/CAREL-2:lcrId=2
...    LNCEL-3/CAREL-2:lnBtsId=1
...    LNCEL-3/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    delete:LNCEL-3/CAREL-1:beamformingInScellAllowed
...    delete:LNCEL-3/CAREL-2:beamformingInScellAllowed
...    LNBTS-1:actFlexScellSelect=true
...    LNBTS:sCellDeactivationTimereNB=rf128
...    LNBTS-1:actAdvStepwiseScellAdd=buffer-based
...    LNBTS-1:actFlexCaMgmt=false
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actScellConfigForHiDemand=false
...    LNCEL:actFlowCtrlEnh=false
...    LNCEL:scellFastSchedulingSelect=normal
...    LNCEL:dlCaMinPcellCqi=0
...    LNCEL:dlCaMinPcellCqiQci1=0
...    LNCEL:ulCaMinPcellSinr=0
...    LNCEL:ulCaMinPcellSinrQci1=0
@{x2link}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNBTS/LNADJGNB-2:administrativeState=unlocked
...    LNBTS/LNADJGNB-2:cPlaneIpAddr=10.0.1.12
...    LNCEL/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-2:nrCellId=132354
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
...    LNBTS/LNADJGNB-1:adjGnbId=7
...    LNBTS/LNADJGNB-1:adjGnbIdLength=22
...    LNBTS/LNADJGNB-2:adjGnbId=8
...    LNBTS/LNADJGNB-2:adjGnbIdLength=22
@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=5000
...    LNCEL:defaultLnRelGnbCellId=1
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
@{LTE4193}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${GSCN7881}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=30kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
@{LTE4549}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=max MIMO layers
@{Tput_parameter}
...    LNCEL:actModulationSchemeDl=64QAM
...    LNCEL:actModulationSchemeUL=16QAMHighMCS
...    LNCEL:actLdPdcch=true
...    LNCEL/LNCEL_FDD-0:maxNrSymPdcch=3
...    LNCEL:adaptPdcchDwellTime=0
...    LNCEL:mbrSelector=ueCapability
...    LNCEL:actDl256QamChQualEst=false
...    LNCEL:dlTargetBler=100
...    LNBTS:pdcpProf2:snSize=15bit
...    LNBTS:rlcProf7:tReord=15ms
@{nrRestrictionOverride}
...    LNBTS:nrRestrictionOverride=disabled
@{MFBI}
...    LNBTS:actMFBI=true
...    LNBTS:caIntraCellHoMode=moreDLCACapacity
...    LNBTS/MFBIPR-0:addFreqBandInd=66
...    LNBTS/MFBIPR-0:addSpectrEmissReq=2
...    LNBTS/MFBIPR-0:eutraCarrierFreq=2050
...    LNBTS/MFBIPR-0:freqBandIndPrio=broadcasted
@{SelectScellMappedBand}
...    LNBTS-1:selectScellMappedBand=false
@{Handover}
...    LNBTS-1:actHoWoSnChg=intraEnbAndX2HoEnabled
...    LNBTS-1:actIfHo=enabled
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw50
...    LNCEL-1/LNHOIF-1:measQuantInterFreq=rsrp
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=5100
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreq=6
...    LNCEL-1:threshold2InterFreq=65
...    LNCEL-1:threshold1=90
@{LTE4530}
...    LNBTS:actSnChangeSnInit=true
${ue_eutra_capabilities_02}
...    SEPARATOR=
...    DD98003045BF0600177E0DD89A0028371197E0DD89A5E190117BF06EC4D5808012D0EAA8C28101C1000414308016080020A18404B080160800
...    20A58417F0820E080020BF840072C001010C203F14000066C843C3C3C5C23F8B90F0F0F0F0F0F0F0F0F0F0E21E1E1E1C000117E10000020404
...    110104268003E71E00020406080C0E162636383A83F7FC4B5A60190BFCDEA000600DB24000080000412E380626A0081A08F010000010E50000
...    00080000
${ue_nr_capabilities}    CE00000001C8F5C0302800001939980000CC00100002600001349880000018060010000001
${ue_eutra_nr_capabilities_Case02}
...    SEPARATOR=
...    C10060941301004821C4D0000000008026020080C389A000004026160080C389A0000040261600904389A0000040200100602C20C04D004404
...    01008040102010000100018010030020044000100800040002004008
${Wait_For_Throughtput_stable}    5s
@{Online_Case02}
...    LNBTS-1:selectScellMappedBand=true
${attachcheck}
...    measObjectToAddModList contains (carrierFreq eq 65535) and
...    measIdToAddModList contains (measId eq 7) and
...    carrierFreq-v9e0 eq 66536 and
...    transmissionMode-r10 eq 'tm3' and
...    cqi-ReportModeAperiodic-r10 eq 'rm30'
${dynamic_endc}
...    measConfig contains (
...    measIdToRemoveList contains (17) and
...    measGapConfig contains (release is present)
...    ) and
...    reestablishRLC-r15 eq 'true' and 
...    endc-ReleaseAndAdd-r15 eq 'FALSE'

${addscell}
...    codebookSubsetRestriction-r10 eq '0b11' and
...    cqi-ReportAperiodic-r10 contains (cqi-ReportModeAperiodic-r10 eq 'rm30') and
...    cqi-ReportConfigSCell-r10 contains (cqi-ReportModeAperiodic-r10 eq 'rm30') and
...    transmissionMode-r10 eq 'tm3' and
...    cellIdentification-r10 contains (physCellId-r10 eq 2 and dl-CarrierFreq-r10 eq 65535 ) and
...    dl-CarrierFreq-v1090 eq 66536
${mobility}
...    mobilityControlInfo contains (
...    targetPhysCellId eq 3 and
...    dl-CarrierFreq eq 5100) and
...    endc-ReleaseAndAdd-r15 eq 'FALSE'
${addscellaftermobility}
...    sCellToAddModList-r10 contains (
...    sCellIndex-r10 eq 1 and
...    physCellId-r10 eq 2 and
...    dl-CarrierFreq-r10 eq 2050) and
...    transmissionMode-r10 eq 'tm3' and
...    codebookSubsetRestriction-r10 eq '0b11' and
...    cqi-ReportAperiodic-r10 contains (cqi-ReportModeAperiodic-r10 eq 'rm30') and
...    cqi-ReportConfigSCell-r10 contains (cqi-ReportModeAperiodic-r10 eq 'rm30')

*** Test Cases ***
CNI-56104-A-a_ET_02_01_Mapped Scell band used when LTE4549 interwork with CNI56104 then Intra eNB HO and SN change
    [Tags]    QC_26038
    OnlineParamChange    ${Online_Case02}
    Set ue parameters before attach
    UE attach    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_Case02}    ue_eutra_capabilities=${ue_eutra_capabilities_02}
    Trigger Dynamic ENDC    X:Y=1:1
    Start traffic
    Trigger IFHO    X:Y=3:1
    SGNB CHANGE    X:Y=3:1

*** Keywords ***
Common Suite Setup and Setup CUS Env
    Common Suite Setup
    Execute Cmd On Pc    sudo ifconfig eth4:1 add 10.0.2.11
    Setup CUS Env    tl_type=3CELLs_FDD_band2band4band12
    Object Should Exist    LNBTS/LNADJGNB-1:x2ToGnbLinkStatus=available
    execute egate command    trace_sim uec=1 protocol=rrc on
    execute egate command    trace_sim on mme=1 protocol=s1

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create Enb Alias    GNB_8    enb_id=8    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    ${GNB7_CELL1}    catenate    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '636666:636666',
    ...    tdd_cell: yes, gscn: 7881}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB7_CELL1}
    ${GNB8_CELL1}    catenate    - {id: 81, technology: nr, tac: 33, pci: '0:2', nrci: '0x0000502', nr_arfcn: '636666:636666',
    ...    tdd_cell: yes, gscn: 7881}
    Add Yaml    BASE_STATIONS
    ...    - id: 8
    ...      gnb_id: '0x00008'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.12
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB8_CELL1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 6, pdn: 1}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    add yaml    EPC
    ...    UEC:
    ...    - id: 1
    ...    peer_uplane: '10.0.2.11:2152'

Set ue parameters before attach
    [Arguments]    ${ue_id}=1
    execute egate command    gnb_endc_param id=7 use_nr_ran_cont=true scg_dl_dist_percent=0 include_reestablish_pdcp=on
    Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit nr_supported_bands=78
    execute egate command    gnb_endc_param id=8 use_nr_ran_cont=true scg_dl_dist_percent=0 include_reestablish_pdcp=on
    execute egate command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    execute egate command    enb_timer T_DC_Overall=5000ms
    Create Alias

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

UE attach
    [Arguments]    ${ue_eutra_capabilities}    ${ue_eutra_nr_capabilities}    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${attachcheck})
    ...    alias=ue1attach    overall_timeout=30
    ${V_1}    catenate    ue_attach id=${ue_id} enb=1 cell=1 ue_eutra_capabilities=${ue_eutra_capabilities} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    execute uex command    ${V_1}
    flow occurred as expected    alias=ue1attach

Start traffic
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${addscell})
    ...    alias=addscell    overall_timeout=30
    Execute Uex Command    trf_data_start dir=dl Mbps=150 ue=${ue_id} protocol=udp trf_id=1
    Execute Uex Command    trf_data_start dir=dl Mbps=150 ue=${ue_id} protocol=udp trf_id=2
    Sleep    ${Wait_For_Throughtput_stable}
    flow occurred as expected    alias=addscell

Trigger Dynamic ENDC
    [Arguments]    ${ue_id}=1    ${X:Y}=disable
    expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest(bandCombinationIndex eq 1 and allowedFeatureSetsList contains (1,2))
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${dynamic_endc})
    ...    alias=uesetupendc    overall_timeout=30
    execute egate command    gnb_endc_param id=7 selected_band_combination_nr=${X:Y}
    execute uex command    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=1 nrsrp=60
    Sleep    ${Wait_For_Throughtput_stable}
    flow occurred as expected    alias=uesetupendc

Trigger IFHO
    [Arguments]    ${ue_id}=1    ${X:Y}=disable
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(carrierFreq eq 5100)
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=reportA2measid7    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=${ue_id} meas_id_blacklist=4 event=A2 srsrp=50
    flow occurred as expected    alias=reportA2measid7
    expect message flow
    ...    ENB_1:X2AP_SgNBModificationRequest(bandCombinationIndex eq 3 and allowedFeatureSetsList contains (1))
    ...    GNB_7:X2AP_SgNBModificationRequestAcknowledge
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${mobility})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${addscellaftermobility})
    ...    alias=uemobility    overall_timeout=30
    execute egate command    gnb_endc_param id=7 include_reestablish_pdcp=off
    execute egate command    gnb_endc_param id=7 selected_band_combination_nr=${X:Y}
    Execute Uex Command    ue_measurement_send id=${ue_id} meas_id_blacklist=1,2 event=A3 phycell_id=3 nrsrp=90 srsrq=34 srsrp=60 nrsrq=0
    Sleep    ${Wait_For_Throughtput_stable}
    flow occurred as expected    alias=uemobility

SGNB CHANGE
    [Arguments]    ${ue_id}=1    ${X:Y}=disable
    expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest(bandCombinationIndex eq 3 and allowedFeatureSetsList contains (1))
    ...    GNB_8:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_1:RRC_RRCConnectionReconfiguration(reestablishRLC-r15 eq 'true' and endc-ReleaseAndAdd-r15 eq 'FALSE')
    ...    ENB_1:X2AP_SgNBChangeConfirm
    ...    alias=sgnbchage    overall_timeout=30
    execute egate command    gnb_endc_param id=8 selected_band_combination_nr=${X:Y}
    execute egate command    gnb_ue_dc_change ue=${ue_id} gnb=8 target_sgnb_cells=81 cause=RN_sCG_Mobility
    Sleep    5s      #make sure sGNB change finish
    flow occurred as expected    alias=sgnbchage
