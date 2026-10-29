*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4A_CUS
...               team-CN3ET    release-SBTS22R1    owner-tom.li
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NRARFCN524100}    524128
${NRARFCN630000}    629984
@{PARAMS_IN_SCF}
...    LNCEL-1:cqiAperEnable=false
...    LNCEL-2:cqiAperEnable=false
...    LNCEL-3:cqiAperEnable=false
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:actTransmittedBelowGap=false
...    @{CA}
...    @{x2link}
...    @{LTE4088}
...    @{LTE4193}
...    @{LTE4549}
...    @{LTE4804}
...    @{dlSectorBFWeight}
...    @{Throughput}
...    @{Closed_Loop_MIMO_8x4}
...    @{TM_Switch}
...    @{others}
...    @{CB006882}
@{CA}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAdvScellMeas=true
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=20
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL:actFlowCtrlEnh=false
...    LNCEL-1/LNCEL_TDD-0:earfcn=40452
...    LNCEL-2/LNCEL_TDD-0:earfcn=40650
...    LNCEL-3/LNCEL_TDD-0:earfcn=40848
...    LNCEL:maxNumScells=2
...    LNBTS-1/CADPR-0:maxNumMimoLayerTdd=12
...    LNBTS-1:sCellDeactivationTimereNB=rf128
...    LNBTS-1:actAdvStepwiseScellAdd=buffer-based
...    LNBTS-1:actFlexCaMgmt=false
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actScellConfigForHiDemand=false
@{x2link}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-2:nrCellId=115970
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=10000
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
@{LTE4193}
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNCEL/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchAddAUeRrHo=10
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchAddAUeTcHo=15
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrc=10
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:actLbPucchReg=true
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:lbPucchRPrId=1
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:selectPrachRegion=None
...    LNBTS/LBPUCCHRPR-1:countdownPucchCompr=60min
...    LNBTS/LBPUCCHRPR-1:countdownPucchExp=1min
...    LNBTS/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNBTS/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN524100}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=41
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNCEL/LNCEL_TDD-0:measGapPattern=gap0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=${NRARFCN630000}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=15kHz
@{LTE4549}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=max MIMO layers
@{LTE4804}
...    LNBTS:actRCREnDc=RCR-servingCell
${ue_nr_capabilities}    SEPARATOR=    CE00000001C8F5C0302800001939980000CC00100001400001349880000018060010000001
@{dlSectorBFWeight}
...    LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:dlSectorBFWeightProfName=customized profile 1
...    LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:modulusOfWeighforAntGrp0=100
...    LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:modulusOfWeighforAntGrp1=50
...    LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:modulusOfWeighforAntGrp2=100
...    LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:modulusOfWeighforAntGrp3=50
...    LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:phaseOfWeighforAntGrp0=0
...    LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:phaseOfWeighforAntGrp1=180
...    LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:phaseOfWeighforAntGrp2=0
...    LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:phaseOfWeighforAntGrp3=180
...    LNCEL/LNCEL_TDD-0:dlSectorBFWeightProfName=customized profile 1
@{Throughput}
...    LNCEL:actModulationSchemeDl=256QAM
...    LNCEL:actLdPdcch=true
...    LNCEL/LNCEL_TDD-0:maxNrSymPdcch=3
...    LNCEL:adaptPdcchDwellTime=0
...    LNCEL:mbrSelector=ueCapability
...    LNCEL:actDl256QamChQualEst=false
...    LNBTS:pdcpProf2:snSize=15bit
...    LNBTS:rlcProf7:tReord=15ms
...    LNCEL:puschAckOffI=10
...    LNCEL:puschCqiOffI=8
...    LNCEL:puschRiOffI=10
@{Closed_Loop_MIMO_8x4}
...    LNCEL/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (8x4)
...    LNCEL/LNCEL_TDD-0:activatedMimoTM=TM9
...    LNCEL/LNCEL_TDD-0:csiRsConfigInfo:csiRsPwrOffset=0
...    LNCEL/LNCEL_TDD-0:csiRsConfigInfo:csiRsResourceConf=rsc0
...    LNCEL/LNCEL_TDD-0:csiRsConfigInfo:csiRsSubfrConf=14
...    LNCEL/LNCEL_TDD-0:csiRsConfigInfo:numOfCsiRsAntennaPorts=8
...    LNCEL/LNCEL_TDD-0:fourLayerMimoAvSpectralEff=1
...    LNCEL/LNCEL_TDD-0:srsDlMimoModeDepConf:srsBandwidth=3hbw|beamformingType=beamforming
...    LNCEL/LNCEL_TDD-0:srsDlMimoModeDepConf:srsBandwidth=3hbw|beamformingType=nonBeamforming
...    LNCEL/LNCEL_TDD-0:csiRepSubmode=submode1
@{PARAMS_IN_IPHY_XML}
...    GeneralSettings:SelectAntCnt=4
@{TM_Switch}
...    LNCEL/LNCEL_TDD-0:actTmSwitch=true
...    LNCEL/LNCEL_TDD-0:tmSwitchProfileId=0
...    LNBTS/TMSWPR-0:tmSwitchThresholdDef:tm3to9CqiTh=115
...    LNBTS/TMSWPR-0:tmSwitchThresholdDef:tm9to3CqiTh=140
...    LNBTS/TMSWPR-0:tmSwitchThresholdDef256Qam:tm3to7CqiTh256Qam=50
...    LNBTS/TMSWPR-0:tmSwitchThresholdDef256Qam:tm3to8CqiTh256Qam=100
...    LNBTS/TMSWPR-0:tmSwitchThresholdDef256Qam:tm3to9CqiTh256Qam=115
...    LNBTS/TMSWPR-0:tmSwitchThresholdDef256Qam:tm7to3CqiTh256Qam=90
...    LNBTS/TMSWPR-0:tmSwitchThresholdDef256Qam:tm8to3CqiTh256Qam=140
...    LNBTS/TMSWPR-0:tmSwitchThresholdDef256Qam:tm9to3CqiTh256Qam=140
@{PARAMS_IN_EMIL}
...    0x269D
...    0x269B
...    0x4ef0
@{others}
...    LNBTS-1:actEndcSpidFwd=false
...    LNBTS-1:endcSchedWeightBoostDl=2
...    LNBTS-1:endcSchedWeightBoostUl=2
...    LNBTS-1:nrRestrictionOverride=disabled
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    delete:LNCEL-1/MBSFNCEL-0
...    LNBTS-1:actAmbrModCaTrigger=false
...    LNCEL-2/CAREL-1:lcrId=3
...    LNCEL-2/CAREL-1:lnBtsId=1
...    LNCEL-2/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-2/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-3/CAREL-1:lcrId=2
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-3/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL:dlCaMinPcellCqi=0
...    LNCEL:dlCaMinPcellCqiQci1=0
...    LNCEL:ulCaMinPcellSinr=0
...    LNCEL:ulCaMinPcellSinrQci1=0
...    LNCEL:actScellConfigForHiDemand=false
...    LNCEL:scellFastSchedulingSelect=normal
${ue_eutra_nr_capabilities_05}
...    SEPARATOR=
...    C10060B71B280045008A038500000000FD00000002080405001B85941870A00000081FA000000001037132830E2680060A0000407E8000000
...    1040202800DC2CA08385000000C0FD00000002080405001B89941060A00E2680000403F4000000002040200200C012026C028010600010080
...    004020001008080100210002004040080110001002020040080801002100010040400801100008020200400808010020
${ue_eutra_capabilities_05}
...    SEPARATOR=
...    DD9FF440830008A0102E0B82EFC1BF335942004408020A540000A0CCBE7F83762697864045EFC1BB135646084308210C20843042182104100
...    6084300300304018200C10860060044208005A3EAA30A0103A020082074040125902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82
...    E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82EFC50000199110F0F0F1708FE2E43C3C3
...    F060000102020880CD0007CE3C0004080C10181C2C4C6C707507EFF896B4D03217F9A10EA000600DB24000080000412E780C000048080C260
...    9A143C0F7FC0001BFE00410B7FC0007BFE00800421F4E9D1000000184002200010
@{cleanup}
...    delete:LNBTS/NRDCDPR-0:frequencyConfigNrList
...    LNBTS:actEndcAdjCarrierChk=disabled
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
@{CB006882}
...    LNBTS:actEndcAdjCarrierChk=eNBConfig_PCellAndSCellContiguity
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:carrierCenterFreqNr=519240|ssbFreqNrCell=524128
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:chBwDlNrCell=20 MHz|ssbFreqNrCell=524128
@{param_case07_0}
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:carrierCenterFreqNr=530260|ssbFreqNrCell=524128
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:chBwDlNrCell=50 MHz|ssbFreqNrCell=524128
@{param_case07_1}
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:carrierCenterFreqNr=526300|ssbFreqNrCell=524128
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:chBwDlNrCell=50 MHz|ssbFreqNrCell=524128
@{param_case07_2}
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:carrierCenterFreqNr=508240|ssbFreqNrCell=524128
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:chBwDlNrCell=50 MHz|ssbFreqNrCell=524128
${PM_SPEED_UP_FLAG}    ${True}
${SCELL_REL_ATT_IA_BAND_ENDC}    M8080C150
@{pm_counters_case7}
...    LNCEL-1/MCC-262/MNC-03:${SCELL_REL_ATT_IA_BAND_ENDC}=1
${addscell}
...    sCellIndex-r10 eq 1 and
...    physCellId-r10 eq 2 and
...    dl-CarrierFreq-r10 eq 40650
${add3scell}
...    sCellToAddModList-r10 contains (sCellIndex-r10 eq 2 and
...    physCellId-r10 eq 3 and
...    dl-CarrierFreq-r10 eq 40848)
${sgnbaddition}
...    allowedBC-ListMRDC contains (
...    bandCombinationIndex eq 3 and
...    allowedFeatureSetsList contains (1),
...    bandCombinationIndex eq 4 and
...    allowedFeatureSetsList contains (1))
${selectedBandCombination}
...    selectedBandCombination contains (
...    bandCombinationIndex eq 3 and
...    requestedFeatureSets eq 1)
${sgnbaddition1}
...    allowedBC-ListMRDC contains (
...    bandCombinationIndex eq 2 and
...    allowedFeatureSetsList contains (1),
...    bandCombinationIndex eq 3 and
...    allowedFeatureSetsList contains (1))
${selectedBandCombination1}
...    selectedBandCombination contains (
...    bandCombinationIndex eq 3 and
...    requestedFeatureSets eq 1)

*** Test Cases ***
CB006882-B-B2_ET_07_01_count scell mimo layer in sscell addition and release condition
    [Tags]
    Set ue parameters before attach
    clean up to commition
    Delta Commission Parameters    ${param_case07_0}
    set sscell before endc setup    gnb_id=7
    Clear Counter Files
    setup ENDC with centra non-contiguous with all cell
    setup ENDC with centra overlap with cell3 and contain sscell add and release
    setup ENDC with centra contiguous with all cell
    Check Counters    ${pm_counters_case7}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Execute Cmd On Pc    sudo ifconfig eth4:1 add 10.0.2.11
    Setup CUS Env    tl_type=3CELLs_TDD_8PIPEs
    Comment    Debug Enter Into Egate
    Create Alias
    execute egate command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    execute egate command    trace_sim on mme=1 protocol=s1

Modify Yaml
    ${GNB7_CELL1}    catenate    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '524100:524100',
    ...    tdd_cell: yes}
    ${GNB7_CELL2}    catenate    - {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x0000502', nr_arfcn: '630000:630000',
    ...    tdd_cell: yes}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2_peers: none
    ...      cells:
    ...         ${GNB7_CELL1}
    ...         ${GNB7_CELL2}
    add yaml    EPC
    ...    UEC:
    ...    - id: 1
    ...    peer_uplane: '10.0.2.11:2152'

Set ue parameters before attach
    execute uex command    ue_param id=1-3 dual_conn=eutra_nr pdcp_sn_extension=18bit nr_supported_bands=41
    execute egate command    gnb_endc_param id=7 use_nr_ran_cont=true scg_dl_dist_percent=0 include_reestablish_pdcp=on
    execute egate command    gnb_endc_param id=7 selected_band_combination_nr=2:1
    execute uex command    ue_cqi_param id=1 scell=0-2 rank=4 ri_i1=18
    execute uex command    ue_cqi_param id=1 scell=0-3 rank=4 cell=both
    execute egate command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    execute egate command    enb_timer T_DC_Overall=5000ms

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

UE attach
    [Arguments]    ${ue_eutra_nr_capabilities}    ${ue_eutra_capabilities}    ${ue_id}=1    ${UE IS ACTIVE}=UE IS ACTIVE
    ${V_1}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} enb=1 cell=1
    execute uex command    ${V_1}

send B1NR to setup ENDC without scell release
    [Arguments]    ${ue_id}=1    ${measid_blacklist}=18    ${pci}=1
    execute uex command    ue_measurement_send id=${ue_id} event=B1_NR meas_id_blacklist=${measid_blacklist} phycell_id=${pci} nrsrp=70

send B1NR to setup ENDC then scell2 added
    [Arguments]    ${ue_id}=1    ${measid_blacklist}=18    ${pci}=1
    execute uex command    ue_measurement_send id=${ue_id} event=B1_NR meas_id_blacklist=${measid_blacklist} phycell_id=${pci} nrsrp=70

Start traffic to setup 2CC
    [Arguments]    ${ue_id}=1
    execute uex command    trf_data_start ue=${ue_id} qci=8 Mbps=150 dir=dl protocol=udp

clean up to commition
    Delta Commission Parameters    ${cleanup}
    Delta Commission Parameters    ${CB006882}
    execute egate command    enb_timer T_SgnbAdditionReqAckDelay=0
    ${V_4}    catenate    gnb_endc_param id=7 serv_cell_index=disabled extra_fr_infos=0 fr_type_pattern=fixed scell_frequencies_sn_nr=none
    execute egate command    ${V_4}

set combination select
    [Arguments]    ${gnb_id}=7    ${X:Y}=1:1
    execute egate command    gnb_endc_param id=${gnb_id} selected_band_combination_nr=${X:Y}

set sscell before endc setup
    [Arguments]    ${gnb_id}=7
    execute egate command    gnb_endc_param id=${gnb_id} scell_frequencies_sn_nr=524128

trigger sscell release
    [Arguments]    ${ue_id}=1    ${gnb_id}=7
    ${V_2}    catenate    gnb_endc_param id=${gnb_id} serv_cell_index=1 extra_fr_infos=0 fr_type_pattern=fixed scell_frequencies_sn_nr=none
    execute egate command    ${V_2}
    execute egate command    enb_ue_dc_modify ue=${ue_id} by=gnb cause=RN_rRM_purpose

trigger sscell addition
    [Arguments]    ${ue_id}=1    ${gnb_id}=7
    ${V_3}    catenate    gnb_endc_param id=${gnb_id} serv_cell_index=1 extra_fr_infos=1 fr_type_pattern=fixed scell_frequencies_sn_nr=524128
    execute egate command    ${V_3}
    ${ret1}=    execute egate command    enb_ue_dc_modify ue=${ue_id} by=gnb cause=RN_rRM_purpose    #SgNB Modification is successful

setup ENDC with centra non-contiguous with all cell
    UE attach    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_05}    ue_eutra_capabilities=${ue_eutra_capabilities_05}
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${addscell})
    ...    alias=addscell    overall_timeout=30
    Start traffic to setup 2CC
    flow occurred as expected    alias=addscell
    set combination select    gnb_id=7    X:Y=3:1
    expect message flow
    ...    UE_1:RRC_MeasurementReport(measId eq 18 and pci-r15 eq 2)
    ...    ENB_1:X2AP_SgNBAdditionRequest(${sgnbaddition})
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge(${selectedBandCombination})
    ...    UE_1:RRC_RRCConnectionReconfiguration(${add3scell})
    ...    alias=3cc    overall_timeout=30
    send B1NR to setup ENDC then scell2 added    ue_id=1    measid_blacklist=17    pci=2
    flow occurred as expected    alias=3cc
    CUS Detach All Ues

setup ENDC with centra overlap with cell3 and contain sscell add and release
    Delta Commission Parameters    ${param_case07_1}
    UE attach    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_05}    ue_eutra_capabilities=${ue_eutra_capabilities_05}
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${addscell})
    ...    alias=addscell1    overall_timeout=30
    Start traffic to setup 2CC
    flow occurred as expected    alias=addscell1
    set combination select    gnb_id=7    X:Y=3:1
    expect message flow
    ...    UE_1:RRC_MeasurementReport(measId eq 18 and pci-r15 eq 2)
    ...    ENB_1:X2AP_SgNBAdditionRequest(${sgnbaddition})
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge(${selectedBandCombination})
    ...    alias=endcsetup    overall_timeout=30
    send B1NR to setup ENDC without scell release    ue_id=1    measid_blacklist=17    pci=2
    flow occurred as expected    alias=endcsetup
    expect message flow
    ...    GNB_7:X2AP_SgNBModificationRequired(pSCellFrequency eq 629984)
    ...    UE_1:RRC_RRCConnectionReconfiguration(${add3scell})
    ...    alias=snnr_none    overall_timeout=30
    trigger sscell release    ue_id=1
    flow occurred as expected    alias=snnr_none
    expect message flow
    ...    GNB_7:X2AP_SgNBModificationRequired(pSCellFrequency eq 629984 and scellFrequenciesSN-NR contains (524128))
    ...    UE_1:RRC_RRCConnectionReconfiguration(sCellToReleaseList-r10 contains (2))
    ...    ENB_1:X2AP_SgNBModificationConfirm
    ...    alias=snnr_524128    overall_timeout=30
    trigger sscell addition    ue_id=1
    flow occurred as expected    alias=snnr_524128
    CUS Detach All Ues

setup ENDC with centra contiguous with all cell
    Delta Commission Parameters    ${param_case07_2}
    UE attach    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_05}    ue_eutra_capabilities=${ue_eutra_capabilities_05}
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${addscell})
    ...    alias=addscell2    overall_timeout=30
    Start traffic to setup 2CC
    flow occurred as expected    alias=addscell2
    set combination select    gnb_id=1    X:Y=3:1
    expect message flow
    ...    UE_1:RRC_MeasurementReport(measId eq 18 and pci-r15 eq 2)
    ...    ENB_1:X2AP_SgNBAdditionRequest(${sgnbaddition1})
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge(${selectedBandCombination1})
    ...    alias=endcsetup1    overall_timeout=30
    expect message will not occur
    ...    UE_1:RRC_RRCConnectionReconfiguration(sCellToReleaseList-r10 contains (2))
    ...    alias=noscellrelease    overall_timeout=30
    send B1NR to setup ENDC without scell release    ue_id=1    measid_blacklist=17    pci=2
    flow occurred as expected    alias=endcsetup1
    flow not occurred for message    alias=noscellrelease

CUS Detach All Ues
    [Arguments]    ${ue_id}=1
    execute uex command    ue_detach id=${ue_id}