*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4A_CUS
...               team-SG1    release-SBTS19A    owner-chunjian.yang
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${DEBUG}  ${False}
${SNAPSHOT_FLAG}   pass:False,fail:True
${BTSLOG_FLAG}  ${True}
${WIRESHARK_FLAG}  ${False}
${NSETAP_PLUGIN_VERSION}  ${EMPTY}  # for exampe: 1.7.2
${TTITRACE_FLAG}  ${False}
${EMIL_FLAG}  ${True}
${IM_FLAG}  ${True}
${ONLY_REPORT_REP}  ${False}
${UTE_WIRESHARK_FLAG}  ${False}
${UTE_CPU_MEM_FLAG}  ${False}
${SOS_REPORT_FLAG}  pass:False,fail:False
${SOS_REPORT_STARTUP_1_FLAG}   pass:False,fail:False

@{PARAMS_IN_SCF}
...  @{CA}
...  @{x2link}
...  @{LTE4088}
...  @{LTE4193}
...  @{LTE4575}
...  @{dlSectorBFWeight}
...  @{Other}
...  @{Closed_Loop_MIMO_8x4}
...  @{CTRLTS-1}
...  @{enable_PCMD_REPORT}

@{CA}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAmbrModCaTrigger=false
...    LNBTS-1:actFlexCaMgmt=false
...    LNBTS-1:actEndcSpidFwd=false
...    LNBTS-1:tS1eRABModInd=2000
...    LNBTS-1:actAdvScellMeas=true
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=100
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL:actFlowCtrlEnh=false
...    LNCEL-1/LNCEL_TDD-0:earfcn=39750
...    LNCEL-2/LNCEL_TDD-0:earfcn=39948
...    LNCEL-3/LNCEL_TDD-0:earfcn=40146
...    LNCEL:maxNumScells=2
...    LNBTS-1/CADPR-0:maxNumMimoLayerTdd=12
...    LNCEL:actScellConfigForHiDemand=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNCEL/LNCEL_TDD-0:measGapPattern=gap0
...    LNCEL:actCaArchEnhImp=off

@{x2link}
...  LNBTS/LNADJGNB-1:administrativeState=unlocked
...  LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...  LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...  LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...  LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...  LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...  LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...  LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2

@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS-1:endcSchedWeightBoostDl=2
...    LNBTS-1:endcSchedWeightBoostUl=2
...    LNBTS-1:nrRestrictionOverride=disabled
...    LNBTS-1:actTransmittedBelowGap=false
...    LNBTS:tLteNrDualConnectPrep=10000
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001

@{LTE4193}
...  LNBTS:actDynTrigLteNrDualConnectivity=true
...  LNCEL/LNCEL_TDD-0:actAutoPucchAlloc=true
...  LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchAddAUeRrHo=10
...  LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchAddAUeTcHo=15
...  LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumEmergencySessions=10
...  LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrc=10
...  LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrcNoDrb=5
...  LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchSrPeriodUpperLimit=20
...  LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:actLbPucchReg=true
...  LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:lbPucchRPrId=1
...  LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:selectPrachRegion=None
...  LNBTS/LBPUCCHRPR-1:countdownPucchCompr=60min
...  LNBTS/LBPUCCHRPR-1:countdownPucchExp=1min
...  LNBTS/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...  LNBTS/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...  LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...  LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...  LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN630000}
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=78
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...  LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...  LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc1
...  LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...  LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...  LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...  LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...  LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...  LNBTS/NRDCDPR-0:tProhibitPhr=0sf
@{LTE4575}
...  LNBTS:actCAggrLteNrDualConnectivity=blind_CA_LTE_NR
...  LNBTS:enableBwCombCheck=true
${ue_nr_capabilities}    CE00000001C8F5C0302800001939980000CC00100002600001349880000018060010000001
${ue_eutra_nr_capabilities}    C18040240B2800E2680000102008200030080801002100008040400801080008020200400E
${ue_eutra_capabilities}
...  SEPARATOR=
...  DD98001A1F81839BFFFC1CDFFFDFF3FFAFA21200886429D0A820CA74A92E3F3DFC0000000004097828097E000000059B8018018210C00C1086
...  006006004208410401821041006084104018210C108500300304218210C108608430025AFAA8C18101D0000920740002681D0000826E0E6FFF
...  F0737FFF839BFFFC1CDFFFE0E6FFFF0737FFF839BFFFC1CDFFFE0E6FFFF0737FFF839BFFFC1CDFFFE0E6FFFF0737FFF839BFFFC1CDFFFE0E6F
...  FFF0737FFF839BFFFC1CDFFFE0E6FFFF0737FFF839BFFFC1CDFFFE0E6FFFF0737FFF839BFFFC1CDFFFD80B00003F620602C00002387600001B
...  21E3F11F8000073600020208000280A0202020202000802008020080200802008020080200000000A02808280A020A02808280A02020330401
...  F32B4C0320FE6F50003006D9200004000020971C0500002010061304D7816FF9020077FC810820EFF9022041043C38000010220000
${ue_eutra_nr_capabilities_ue2}    C18040240B2820E2680000002008200020080801002100008040400801080008020200400E
@{dlSectorBFWeight}
...  LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:dlSectorBFWeightProfName=customized profile 1
...  LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:modulusOfWeighforAntGrp0=100
...  LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:modulusOfWeighforAntGrp1=50
...  LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:modulusOfWeighforAntGrp2=100
...  LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:modulusOfWeighforAntGrp3=50
...  LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:phaseOfWeighforAntGrp0=0
...  LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:phaseOfWeighforAntGrp1=180
...  LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:phaseOfWeighforAntGrp2=0
...  LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:phaseOfWeighforAntGrp3=180
...  LNCEL/LNCEL_TDD-0:dlSectorBFWeightProfName=customized profile 1
@{Other}
...  LNCEL:actModulationSchemeDl=64QAM
...  LNCEL:actLdPdcch=true
...  LNCEL/LNCEL_TDD-0:maxNrSymPdcch=3
...  LNCEL:adaptPdcchDwellTime=0
...  LNCEL:mbrSelector=ueCapability
@{Closed_Loop_MIMO_8x4}
...  LNCEL/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (8x4)
...  LNCEL/LNCEL_TDD-0:activatedMimoTM=TM9
...  LNCEL/LNCEL_TDD-0:csiRsConfigInfo:csiRsPwrOffset=0
...  LNCEL/LNCEL_TDD-0:csiRsConfigInfo:csiRsResourceConf=rsc0
...  LNCEL/LNCEL_TDD-0:csiRsConfigInfo:csiRsSubfrConf=14
...  LNCEL/LNCEL_TDD-0:csiRsConfigInfo:numOfCsiRsAntennaPorts=8
...  LNCEL/LNCEL_TDD-0:fourLayerMimoAvSpectralEff=30
...  LNCEL/LNCEL_TDD-0:srsDlMimoModeDepConf:srsBandwidth=3hbw|beamformingType=beamforming
...  LNCEL/LNCEL_TDD-0:srsDlMimoModeDepConf:srsBandwidth=3hbw|beamformingType=nonBeamforming
...  LNCEL/LNCEL_TDD-0:csiRepSubmode=submode1
@{CTRLTS-1}
...  CTRLTS-1:tceTracePortNum=49150
...  CTRLTS-1:maxUeTraceSessions=60
...  CTRLTS-1:subscriberMDTObtainLocation=false
...  CTRLTS-1:netActIpAddr=1.1.1.1
...  CTRLTS-1:omsTracePortNum=49392
...  CTRLTS-1:extTraceReporting:extCellTraceRep=true
...  CTRLTS-1:extTraceReporting:extUeTraceRep=false
...  CTRLTS-1:traceRepMode:cellTraceRepMode=Offline
...  CTRLTS-1:traceRepMode:ueTraceRepMode=Online
...  CTRLTS-1:vendorSpecTracing:taTracing=false
...  CTRLTS-1/MTRACE-0:tceCellTracePortNum=49150
...  CTRLTS-1/MTRACE-0:actPCMDReporting=true
...  CTRLTS-1/MTRACE-0:actUeThroughputMR=false
...  CTRLTS-1/MTRACE-0:cellMaxActiveUEsTraced=10000
...  CTRLTS-1/MTRACE-0:cellTrcMode=true
...  CTRLTS-1/MTRACE-0:forceUeIdsRepetition=false
...  CTRLTS-1/MTRACE-0:interfaceSelection=NSETAP
...  CTRLTS-1/MTRACE-0:jobType=TraceOnly
...  CTRLTS-1/MTRACE-0:lcrId=1
...  CTRLTS-1/MTRACE-0:maxBufferingTime=2000
...  CTRLTS-1/MTRACE-0:tceIpAddress=10.0.1.1
...  CTRLTS-1/MTRACE-0:traceS1Setting=None
...  CTRLTS-1/MTRACE-0:traceX2Setting=None
...  CTRLTS-1/MTRACE-0:cellVendorSpecTracing:cellTaTracing=false
...  CTRLTS-1/MTRACE-0:eutranTraceId:eutranTraceIdMcc=262
...  CTRLTS-1/MTRACE-0:eutranTraceId:eutranTraceIdMnc=3
...  CTRLTS-1/MTRACE-0:eutranTraceId:eutranTraceIdMncLen=2
...  CTRLTS-1/MTRACE-0:eutranTraceId:traceId=0
...  CTRLTS-1/MTRACE-0:eutranTraceId:trcRecSessionRef=0
...  CTRLTS-1/MTRACE-2:tceCellTracePortNum=49150
...  CTRLTS-1/MTRACE-2:actPCMDReporting=false
...  CTRLTS-1/MTRACE-2:actUeThroughputMR=false
...  CTRLTS-1/MTRACE-2:cellMaxActiveUEsTraced=100000
...  CTRLTS-1/MTRACE-2:cellTrcMode=true
...  CTRLTS-1/MTRACE-2:forceUeIdsRepetition=false
...  CTRLTS-1/MTRACE-2:interfaceSelection=NSNTI
...  CTRLTS-1/MTRACE-2:jobType=TraceOnly
...  CTRLTS-1/MTRACE-2:maxBufferingTime=2000
...  CTRLTS-1/MTRACE-2:tceIpAddress=10.0.1.1
...  CTRLTS-1/MTRACE-2:traceRrcSetting=All
...  CTRLTS-1/MTRACE-2:traceS1Setting=All
...  CTRLTS-1/MTRACE-2:traceX2Setting=All
...  CTRLTS-1/MTRACE-2:lcrId=1
...  CTRLTS-1/MTRACE-2:cellVendorSpecTracing:cellTaTracing=false
...  CTRLTS-1/MTRACE-2:eutranTraceId:eutranTraceIdMcc=262
...  CTRLTS-1/MTRACE-2:eutranTraceId:eutranTraceIdMnc=3
...  CTRLTS-1/MTRACE-2:eutranTraceId:eutranTraceIdMncLen=2
...  CTRLTS-1/MTRACE-2:eutranTraceId:traceId=2
...  CTRLTS-1/MTRACE-2:eutranTraceId:trcRecSessionRef=2
@{enable_PCMD_REPORT}
...  LNBTS-1:actPCMDReport=true
...  LNBTS-1:actCellTrace=true
@{PARAMS_IN_IPHY_XML}
...  GeneralSettings:SelectAntCnt=4
${Wait_For_Throughtput_stable_ENDC}    60s
${Wait_For_Throughtput_stable_Legacy}    30s

*** Test Cases ***
LTE5335-G-g_ET_02_01_PCMD record for SCell Release events during EN-DC setup rather than other Scell release reasons
    [Tags]    QC_26152
    [Setup]    Start TCE And Start To Capture Logs
    UE attach    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}    ue_eutra_capabilities=${ue_eutra_capabilities}
    Start traffic
    Add NR PDCP bearer
    Trigger B1 report setup ENDC
    UE attach    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_ue2}    ue_eutra_capabilities=${ue_eutra_capabilities}    ue_id=2
    Start traffic    ue_id=2
    Add NR PDCP bearer    ue_id=2
    Trigger B1 report setup ENDC    ue_id=2
    Block Cell2
    Check WireShark Log    ${CURDIR}/a2a_LTE5335-G-g_02/a2a.ini    wait_string=UEContextReleaseComplete::1
    [Teardown]    Stop TCE And Stop Capture Logs

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_TDD_8PIPEs
    Set ue parameters before ENDC setup
    Create Alias

Set ue parameters before ENDC setup
    execute uex command    ue_param id=1-13 dual_conn=eutra_nr pdcp_sn_extension=18bit
    execute uex command    ue_param id=1-13 nr_supported_bands=7
    execute egate command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    execute egate command    enb_timer T_DC_Overall=5000ms

Create Alias
    FOR    ${ue_id}    IN RANGE    1    7
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END
    Create Enb Alias    alias=ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
    Create Enb Alias    alias=GNB_7    enb_id=7    id_type=wts

Modify Yaml
    ${GNB7_CELL1}    catenate    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '507000:531000'}    #531040
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB7_CELL1}
    ${GNB8_CELL1}    catenate    - {id: 81, technology: nr, tac: 33, pci: '0:2', nrci: '0x0000502', nr_arfcn: '507020:531020'}    #531020
    ${GNB8_CELL2}    catenate    - {id: 82, technology: nr, tac: 33, pci: '1:0', nrci: '0x0000503', nr_arfcn: '507020:531000'}
    Add Yaml    BASE_STATIONS
    ...    - id: 8
    ...      gnb_id: '0x00008'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.12
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB8_CELL1}
    ...        ${GNB8_CELL2}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 5, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    ...     - {qci: 1, pdn: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31}
    FOR    ${ue_id}     IN RANGE    1    7
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_2
    END

UE attach
    [Arguments]    ${ue_eutra_nr_capabilities}    ${ue_eutra_capabilities}    ${ue_id}=1    ${enb_id}=1    ${cell_id}=1
    Execute Uex Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Uex Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Uex Command    gnb_endc_param id=7 include_reestablish_pdcp=on before UE attach
    Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=${ue_id} nr_supported_bands=78
    Execute Uex Command    ue_cqi_param id=2 scell=0-2 reset
    Execute Uex Command    ue_cqi_param id=${ue_id} scell=0-2 rank=4
    #${V_1}  catenate  ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} \ ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    #...  ue_eutra_capabilities=${ue_eutra_capabilities}
    ${V_1}  catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} enb=${enb_id} cell=${cell_id}
    Execute Uex Command    ${V_1}

Add NR PDCP bearer
    [Arguments]    ${ue_id}=1
    #${ret1}=  Execute Uex Command  bearer_add ue=${ue_id} id=7 filter=1 precedence=1
    #...  pass_regexp=PGW-initiated Bearer Creation. Bearer-7
    Execute Uex Command    bearer_add ue=${ue_id} qci=6 mbr_ul=31 mbr_dl=31 gbr_dl=31 gbr_ul=31
    #Should Contain    ${ret1}    qCI 6
    #Should Contain    ${ret1}    eventId eventB1-NR-r15
    #Should Contain    ${ret1}    bandNR-r15 setup : 78

Start traffic
    [Arguments]    ${ue_id}=1    ${qci_id}=6    ${throughput}=150
    #Execute Uex Command    data_trf_start id=1 dir=dl mbps=150 ue=${ue_id} trf_id=1    pass_regexp=scellIndex-2
    #Execute Uex Command    data_trf_start id=1 dir=dl mbps=150 ue=${ue_id} trf_id=2    150.0
    #Execute Uex Command    data_trf_start id=1 dir=dl mbps=150 ue=${ue_id} trf_id=3    150.0
    Execute Uex Command    trf_data_start qci=${qci_id} ue=${ue_id} Mbps=${throughput} dir=dl protocol=udp trf_id=1
    Execute Uex Command    trf_data_start qci=${qci_id} ue=${ue_id} Mbps=${throughput} dir=dl protocol=udp trf_id=2
    Execute Uex Command    trf_data_start qci=${qci_id} ue=${ue_id} Mbps=${throughput} dir=dl protocol=udp trf_id=3
    #Sleep    ${Wait_For_Throughtput_stable_Legacy}

Trigger B1 report setup ENDC
    [Arguments]    ${ue_id}=1
    Execute Uex Command  ue_measurement_send id=${ue_id} event=B1_NR phycell_id=1 nrsrp=60
    #...  pass_regexp=Bearer-type change from MCG to SCG-split is successful
    #Comment  ${ret1}=  Execute Uex Command  ue_measurement_send id=${ue_id} event=B1_NR phycell_id=1 nrsrp=60
    #...  pass_regexp=Bearer-type change from MCG to SCG-split is successful
    #Comment    Should Contain    ${ret1}    drb-ToReleaseList
    #Sleep    ${Wait_For_Throughtput_stable_ENDC}

Start TCE And Start To Capture Logs
    Common Test Setup And Start To Capture Logs
    Start TCE    ${TCE_PORT}

Stop TCE And Stop Capture Logs
    Stop TCE    ${TCE_PORT}
    Common Test Teardown And Stop Capture Logs
