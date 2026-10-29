*** Settings ***
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    Regression_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...               team-DevHZ5_SG1    owner-pei.han    release-5G21B
Resource    ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    fddtdd_sansa_cmwv/3cells_1T2F
@{PARAMS_IN_CP_UE_RD}    rdA2SCellRelWaitTimer=10.0
@{PARAMS_IN_SCF}    @{CA_Basic}    @{CB007893}    @{Mobility}    @{SRB3}    @{NSA_CONF}
@{CA_Basic}       NRDU-1:actInterNumerologyCa=true    NRDU-1:flexibleCAMode=MixedCAMode
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Nsa
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
...    NRCELL-1:pucchModeSelect=longPucch    NRBTS:cipherPrefL:nea0=9    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:primaryPathMaxQueueingDelay=10    NRCELL:sCellDeactivationTimerGNB=ms1280
@{CB007893}       NRBTS:actMeasBasedSCellAdditionSa=A1-based    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=20|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-2:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL-2:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=5|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=2
...    NRCELL-1/NRREL-10:gNbIdLength=22    NRCELL-1/NRREL-10:lcrId=2    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489|mncLength=3    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-10:gNbId=2    NRCELL-3/NRREL-10:gNbIdLength=22
...    NRCELL-3/NRREL-10:lcrId=2    NRCELL-3/NRREL-10:sCellAdditionMethod=covBasedA1    NRCELL-3/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-10:gnbPlmn:mcc=311    NRCELL-3/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
${ue_eutra_nr_capabilities}    SEPARATOR=
...    A11FF82382C0C0388C00000404440B84C0C030500711800001048881709818070A000308C0003091102E130300E1400071180000004888100
...    5011A0140030505D04853A76C73E1C49D1276C73E1C403639F0E201B1CF860801880002010100200804030060800040202018030800020101
...    002000040300610000402020040100806000
${ue_eutra_nr_capabilities_SRB3}    SEPARATOR=
...    A11FF82382C0C0388C00000404440B84C0C030500711800001048881709818070A000308C0003091102E130300E1400071180000004888100
...    5011A0140030505D04853A76C73E1C49D1276C73E1C403639F0E201B1CF860C01880002010100200804030060800040202018030800020101
...    002000040300610000402020040100806000
@{Mobility}       NRBTS:actIntraFreqInterGnbMobilityNSA3x=true    NRBTS:tDCoverall=10000    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea2_128=0    NRBTS:cipherPrefL:nea1_128=0    NRBTS:cipherPrefL:nea3_128=9
...    NRBTS/NRADJNRCELL-4915:cellDepType=NSA
...    NRBTS/NRADJNRCELL-4915:gNbId=3    NRBTS/NRADJNRCELL-4915:gNbIdLength=22    NRBTS/NRADJNRCELL-4915:lcrId=3
...    NRBTS/NRADJNRCELL-4915:nrarfcn=126244
...    NRBTS/NRADJNRCELL-4915:ssbFrequency=127210
...    NRBTS/NRADJNRCELL-4915:physCellId=381    NRBTS/NRADJNRCELL-4915:gnbPlmn:mnc=255
...    NRBTS/NRADJNRCELL-4915:gnbPlmn:mcc=250
...    NRBTS/NRADJNRCELL-4915:gnbPlmn:mncLength=3    delete:NRBTS/NRADJNRCELL-4915:freqBandIndicatorNR
...    NRCELL-1/NRREL-1:gNbId=3
...    NRCELL-1/NRREL-1:gNbIdLength=22    NRCELL-1/NRREL-1:lcrId=3    NRCELL-1/NRREL-1:gnbPlmn:mnc=255
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=250
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3    NRCELL-1:a3MeasEnabled=rsrp    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:sMeasConfigSsbRsrp=1    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms512
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actInterMeNBMobility=true
...    NRBTS:actIntraMeNBMobility=true    NRCELL-1:a1MeashoEnabled=rsrp    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60
...    NRCELL-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480    NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=40    NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp    NRCELL-1/NRHOIF-1:cellDepType=NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=518670
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...    NRCELL-2:a1MeashoEnabled=rsrp    NRCELL-2:a2MeashoEnabled=rsrp
...    NRCELL-2:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60
...    NRCELL-2:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-2:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0    NRCELL-2:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL-2:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=40
...    NRCELL-2:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:cellDepType=NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=71    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf5    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=127210    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3    NRCELL-2/NRREL-10:gNbId=2    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:lcrId=1    NRCELL-2/NRREL-10:gnbPlmn:mnc=489    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:absThreshSsbRsrpConsolidation=1
...    NRCELL-2:sMeasConfigSsbRsrp=1    NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms512
...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-3:a1MeasSCellAddEnabled=rsrp    NRCELL-3:a3MeasEnabled=rsrp
...    NRCELL-3:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60    NRCELL-3:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-3:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0    NRCELL-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms512
...    NRCELL-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-3/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-1:cellDepType=NSA    NRCELL-3/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-3/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcDuration=sf5    NRCELL-3/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-3/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam    NRCELL-3/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-1:ssbFrequency=518670
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...    NRCELL-1/NRREL-2:gNbId=2    NRCELL-1/NRREL-2:gNbIdLength=22    NRCELL-1/NRREL-2:lcrId=3
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:gNbId=2    NRCELL-3/NRREL-1:gNbIdLength=22    NRCELL-3/NRREL-1:lcrId=1
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS:timerX2UeProcGuard=15000
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-2:pucchModeSelect=shortPucch
...    NRCELL-3:a1MeashoEnabled=rsrp
...    NRCELL-3:a2MeashoEnabled=rsrp
...    NRCELL-3:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL-3:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-3:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    delete:NRCELL-2:a1MeasSCellAddEnabled
...    NRCELL:reportAmountCA=r2    #PR630713,5G_RAN_OP_2182
@{NSA_CONF}
...    NRBTS:gNbCuType=NSA
...    NRBTS:actSACallProcessingDU=false
...    NRCELL:cellDepType=NSA
...    delete:NRCELL:trackingAreaDN
#...    delete:NRBTS-2/TRACKINGAREA-200:snssaiDNList
...    delete:NRBTS-2/TRACKINGAREA-200:snssaiList:snssaiDN
...    delete:NRBTS-2/SNSSAI-1:ngUplane
...    delete:NRBTS-2/NRSYSINFO_PROFILE-1/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-2/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-3/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-4/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-11/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-12/NRLIM-1
@{SRB3}    NRBTS:srb3SupportEnabled=true
@{PM_Counters_Check_F_Case11}    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=8
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=8
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_NSA}=6    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_NSA}=6
...    NRCELL-1:NCAC:${A2MEAS_IMMEDIATE_REL_SCELL}=5
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=8    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=8
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=8    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=8
@{PM_Counters_Check_F_Case12}    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=7
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=7
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_NSA}=7    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_NSA}=7
...    NRCELL-1:NCAC:${A2MEAS_IMMEDIATE_REL_SCELL}=6
@{PM_Counters_Check_F_Case13}    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=6
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=6
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_NSA}=5    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_NSA}=5
...    NRCELL-1:NCAC:${A2MEAS_IMMEDIATE_REL_SCELL}=5
...    NRCELL-3:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=2    NRCELL-3:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-3:NCAC:${A2MEAS_REL1DLSCELL_ATT_NSA}=2    NRCELL-3:NCAC:${A2MEAS_REL1DLSCELL_SUCC_NSA}=2
...    NRCELL-3:NCAC:${A2MEAS_IMMEDIATE_REL_SCELL}=2
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=6    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=6
...    NRCELL-3:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2    NRCELL-3:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=8    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=8
@{PM_Counters_Check_F_Case14}    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=3
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=3
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_NSA}=3    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_NSA}=3
...    NRCELL-1:NCAC:${A2MEAS_IMMEDIATE_REL_SCELL}=3
...    NRCELL-3:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=3    NRCELL-3:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=3
...    NRCELL-3:NCAC:${A2MEAS_REL1DLSCELL_ATT_NSA}=3    NRCELL-3:NCAC:${A2MEAS_REL1DLSCELL_SUCC_NSA}=3
...    NRCELL-3:NCAC:${A2MEAS_IMMEDIATE_REL_SCELL}=3
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=3    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=3
...    NRCELL-3:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=3    NRCELL-3:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=3
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=6    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=6
@{PM_Counters_Check_F_Case16}    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=7
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=7
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_NSA}=5    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_NSA}=5
...    NRCELL-1:NCAC:${A2MEAS_IMMEDIATE_REL_SCELL}=5
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=7    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=7
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=7    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=7
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
${A2MEAS_REL1DLSCELL_ATT_NSA}    M55118C06503
${A2MEAS_REL1DLSCELL_SUCC_NSA}    M55118C06504
${A2MEAS_IMMEDIATE_REL_SCELL}    M55118C06505
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007
${Update_Cfg_1}    set_cell id=2 enb=1 eci=0x1234602 pci=3:1 tac=222 proxy=10.0.2.1:12220|10.0.2.1:8890
...    earfcn=2000:20000 mandatory_for_activation=off
${Update_Cfg_2}    set_enb id=11 plmn=250:255 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.127
...    x2u=10.0.1.137 type=simulated x2_peers=none
${Update_Cfg_3}    set_cell id=3 gnb=3 tac=3 pci=127:0 proxy=10.0.2.1:12221|10.0.2.1:8891 nrci=0x1
...    nr_arfcn=134044:126244 gscn=1589 mandatory_for_activation=off
${Update_Cfg_4}    set_cell id=1 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:8887 earfcn=2000:20000
...    mandatory_for_activation=off
${Update_Cfg_5}    gnb_set id=3 s1u=10.0.1.122 plmn=250:255 gnb_id=0x3 type=simulated daemon=10.0.2.1:22222
...    x2=10.0.1.122:36422 x2_peers=none
@{OnlineParam_maxNumOfCaUsersNRCell}    NRCELL-1:maxNumOfCaUsersNRCell=1    NRCELL-2:maxNumOfSCellAlloc=250
@{OnlineParam_maxNumOfSCellAlloc}    NRCELL-1:maxNumOfCaUsersNRCell=250    NRCELL-2:maxNumOfSCellAlloc=1    NRBTS-2:actHighestEstNrTputBcSel=false
${normal_report_A2}    11s
${candidate_cells_mn_hex_for_menb_ho_to_PCI61}    0907C3A821E8

*** Test Cases ***
CB007893-F-B3_ET_12_01_numImmediateSCellRel reset after Scell A2 measurement normal report when Ping-pong SCell addition and release with SRB3
    [Tags]
    Clear Counter files
    Set UE Parameters Before Attach
    UE Attach and establish EN-DC    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_SRB3}
    UE report A1 and A2 immediately    meas_id=3,3,3
    UE report A1 and A2 normally    meas_id=3
    UE report A1 and A2 immediately    meas_id=3,3,3
    Check Counters    ${PM_Counters_Check_F_Case12}

CB007893-F-B3_ET_14_01_numImmediateSCellRel reset after MeNB triggered PSCell change when Ping-pong SCell addition and release with SRB3 enabled
    [Tags]
    Clear Counter files
    OnlineParamChange    ${OnlineParam_maxNumOfSCellAlloc}
    Set UE Parameters Before Attach
    UE Attach and establish EN-DC    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_SRB3}
    UE report A1 and A2 immediately    meas_id=3,3,3
    Intra MeNB HO triggered PSCell Change
    UE report A1 and A2 immediately CASE14    meas_id_1st=5    meas_id_2nd=3    meas_id_3rd=3    phycell_id=61
    Check RRC Log    ${CURDIR}${/}a2a_CB007893-F-B3_ET_14${/}a2a.ini
    Check Counters    ${PM_Counters_Check_F_Case14}

*** Keywords ***
Start BTS With Specified Config Files
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}    ue_count=1

Modify Cfg
    Update Cfg    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Update Cfg    ${Update_Cfg_1}
    Update Cfg    ${Update_Cfg_2}
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    ${Update_Cfg_3}
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Update Cfg    ${Update_Cfg_4}
    Update Cfg    ${Update_Cfg_5}
    Update Cfg    gnb_endc_param id=3 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0
    Update Cfg    gnb_param id=3 x2_listening_socket=1 measEvent=A3

Set UE Parameters Before Attach
    Execute Egate Command    enb_x2_link_up enb=11 target=2    ENB-11: X2AP Link with GNB-2
    Execute Egate Command    enb_x2_link_up enb=1 target=3    ENB-1: X2AP Link with GNB-3
    Execute Egate Command    enb_timer T_RRC_TRANSACTION=4s
    Execute Egate Command    link_x2_management_abnormal_cases id=1 partner=2 sgnb_modification_reqd_rsp=normal_rsp
    Execute Egate Command    link_x2_management_abnormal_cases id=1 partner=2 sgnb_change_rsp=normal_rsp
    Execute Egate Command    ue_rrc_reconf_param id=11 reset
    Execute Egate Command    enb_endc_param id=1 reset
    Execute Egate Command    enb_endc_param id=1 serving_cell_index_range_scg=8:14
    Execute Egate Command    ue_enb_endc_param id=11 reset
    Execute Egate Command    ue_change_location id=11 enb=1 cell=1

UE Attach and establish EN-DC
    [Arguments]    ${ue_id}=11    ${target_cell}=1    ${ue_eutra_nr_capabilities}=${ue_eutra_nr_capabilities}
    Start RRC Log    establish_EN-DC
    Execute Egate Command    ue_attach id=${ue_id} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cell} bearer=2 type=split_scg
    ...    Proxy \\(eNB 2 cell 1\\) reported successful RA
    Get RRC Log

Set UE Parameters then UE Attach and establish EN-DC
    [Arguments]    ${ue_eutra_nr_capabilities}=${ue_eutra_nr_capabilities}
    Set UE Parameters Before Attach
    UE Attach and establish EN-DC    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}

Pcell A1 report to trigger Scell Addition
    [Arguments]    ${ue_id}=11    ${meas_id}=3    ${phycell_id}=60
    ${A1_Scell_addition}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} event=A1
    ...    srsrp_nr=80 srsrq_nr=40
    ${ret1}=    Execute Egate Command    ${A1_Scell_addition}    SgNBModificationConfirm
    Should Contain    ${ret1}    Successfully reconfigured dual connectivity
    Should Contain    ${ret1}    rrcConnectionReconfigurationComplete
    Should Contain    ${ret1}    eventA2
    Should Contain    ${ret1}    sCellToAddModList

Scell A2 report normally to trigger Scell Release
    [Arguments]    ${ue_id}=11    ${meas_id}=4
    sleep    ${normal_report_A2}
    ${A2_Scell_Release}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} scell=9 scell_rsrp=40 scell_rsrq=0 event=A2
    ${ret1}=    Execute Egate Command    ${A2_Scell_Release}    SgNBModificationConfirm
    Should Contain    ${ret1}    eventId eventA1
    Should Contain    ${ret1}    sCellToReleaseList
    Should Contain    ${ret1}    timeToTrigger ms320

UE report A1 and A2 normally
    [Arguments]    ${meas_id}=3    ${phycell_id}=60
    FOR    ${meas_ids}    IN    @{meas_id.split(",")}
        Pcell A1 report to trigger Scell Addition    meas_id=${meas_ids}    phycell_id=${phycell_id}
        Scell A2 report normally to trigger Scell Release    meas_id=${${meas_ids}+1}
    END

Scell A2 report immediately to trigger Scell Release
    [Arguments]    ${ue_id}=11    ${meas_id}=4
    ${A2_Scell_Release}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} scell=9 scell_rsrp=40 scell_rsrq=0 event=A2
    ${ret1}=    Execute Egate Command    ${A2_Scell_Release}    SgNBModificationConfirm
    Should Contain    ${ret1}    eventA1
    Should Contain    ${ret1}    sCellToReleaseList
    Should Contain    ${ret1}    timeToTrigger ms5120

Scell A2 report to trigger Scell Release when rdLimitNumImmediateSCellRel reached
    [Arguments]    ${ue_id}=11    ${meas_id}=4
    ${A2_Scell_Release}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} scell=9 scell_rsrp=40 scell_rsrq=0 event=A2
    ${ret1}=    Execute Egate Command    ${A2_Scell_Release}    fail_regexp=SgNBModificationConfirm
    Should Not Contain    ${ret1}    eventA1
    Should Not Contain    ${ret1}    sCellToReleaseList
    Should Not Contain    ${ret1}    timeToTrigger ms5120
    Should Not Contain    ${ret1}    nr-Config-r15 release : NULL
    Should Not Contain    ${ret1}    SgNBModificationRequestReject

Pcell A1 report to trigger Scell Addition then Scell A2 report to trigger Scell Release when rdLimitNumImmediateSCellRel reached
    [Arguments]    ${ue_id}=11    ${meas_id}=3
    Pcell A1 report to trigger Scell Addition    meas_id=${meas_id}
    Scell A2 report to trigger Scell Release when rdLimitNumImmediateSCellRel reached    meas_id=${${meas_id}+1}

Pcell A1 report to trigger Scell Addition then Scell A2 report to trigger Scell Release when rdLimitNumImmediateSCellRel reached NEW
    [Arguments]    ${ue_id}=11    ${meas_id}=3
    Pcell A1 report to trigger Scell Addition    meas_id=${meas_id}
    Scell A2 report to trigger Scell Release when rdLimitNumImmediateSCellRel reached    meas_id=${${meas_id}-1}

Ignore Scell A2 report when SN change ongoing But HO failed
    [Arguments]    ${ue_id}=11    ${meas_id_A2}=14   ${meas_id_A3}=1
    Execute Egate Command    link_x2_management_abnormal_cases id=1 partner=2 sgnb_change_rsp=reject
    ${A2_A3_HO_Reject}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=60 srsrq_nr=30 phycell_id=381
    ...    nrsrp_nr=60 nrsrq_nr=30;ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A2} scell=9 scell_rsrp=40
    ...    scell_rsrq=0 event=A2
    ${ret1}    Execute Egate Command    ${A2_A3_HO_Reject}
    ...    fail_regexp=SgNB Modification Confirm
    Should Not Contain    ${ret1}    Successfully reconfigured dual connectivity
    Should Not Contain    ${ret1}    Bearer-type change from MCG to SCG-split is successful
    Should Not Contain    ${ret1}    Proxy (eNB 3 cell 3) reported successful RA
    Should Contain    ${ret1}    SgNBChangeRequired
    Should Contain    ${ret1}    SgNBChangeRefuse
    Should Not Contain    ${ret1}    SgNB Change Confirm

OnlineParamChange
    [Arguments]  ${Online_Param}
    Delta Commission Parameters  ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

UE report A1 and A2 immediately
    [Arguments]    ${meas_id}=3    ${phycell_id}=60
    FOR    ${meas_ids}    IN    @{meas_id.split(",")}
        Pcell A1 report to trigger Scell Addition    meas_id=${meas_ids}    phycell_id=${phycell_id}
        Scell A2 report immediately to trigger Scell Release    meas_id=${${meas_ids}+1}
    END

UE report A1 and A2 immediately CASE13
    [Arguments]    ${meas_id_1st}=3    ${meas_id_2nd}=3    ${phycell_id}=60
    Pcell A1 report to trigger Scell Addition    meas_id=${meas_id_1st}    phycell_id=${phycell_id}
    Scell A2 report immediately to trigger Scell Release    meas_id=${${meas_id_1st}-3}
    Pcell A1 report to trigger Scell Addition    meas_id=${meas_id_2nd}    phycell_id=${phycell_id}
    Scell A2 report immediately to trigger Scell Release    meas_id=${${meas_id_2nd}-2}

UE report A1 and A2 immediately CASE14
    [Arguments]    ${meas_id_1st}=5    ${meas_id_2nd}=3    ${meas_id_3rd}=3    ${phycell_id}=60
    Pcell A1 report to trigger Scell Addition    meas_id=${meas_id_1st}    phycell_id=${phycell_id}
    Scell A2 report immediately to trigger Scell Release    meas_id=${${meas_id_1st}-3}
    Pcell A1 report to trigger Scell Addition    meas_id=${meas_id_2nd}    phycell_id=${phycell_id}
    Scell A2 report immediately to trigger Scell Release    meas_id=${${meas_id_2nd}-1}
    Pcell A1 report to trigger Scell Addition    meas_id=${meas_id_3rd}    phycell_id=${phycell_id}
    Scell A2 report immediately to trigger Scell Release    meas_id=${${meas_id_3rd}-1}

gNB triggered PSCell change
    [Arguments]    ${ue_id}=11    ${meas_id_A3}=1
    Start RRC Log     PSCell_Change_A3
    ${A3_HO}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=60 srsrq_nr=30 phycell_id=61
    ...    nrsrp_nr=60 nrsrq_nr=30
    ${ret1}    Execute Egate Command    ${A3_HO}
    ...    pass_regexp=Proxy \\(eNB 2 cell 3\\) reported successful RA
#    Should Contain    ${ret1}    Successfully reconfigured dual connectivity
    Should Contain    ${ret1}    eventId eventA1
    Should Contain    ${ret1}    SgNB Modification Confirm
    Should Contain    ${ret1}    sCellToReleaseList
    Should Contain    ${ret1}    timeToTrigger ms320
    Get RRC Log

Intra MeNB HO triggered PSCell Change
    [Arguments]    ${ue_id}=11    ${cell_id_Target}=2
    ...    ${candidate_cells_mn_hex_for_menb_ho}=${candidate_cells_mn_hex_for_menb_ho_to_PCI61}
    Start RRC Log     PSCell_Change_IntraMeNB_HO
    Execute Egate Command    enb_cell_param enb=1 id=${cell_id_Target} allow_endc=on
    Execute Egate Command    ue_enb_endc_param id=${ue_id} candidate_cells_mn_hex_for_menb_ho=${candidate_cells_mn_hex_for_menb_ho}
    ${ret1}    Execute Egate Command    ue_ho enb=1 cell=2 id=${ue_id}
    ...    pass_regexp=Proxy \\(eNB 2 cell 3\\) reported successful RA
    Should Contain    ${ret1}    Dual Connectivity reconfiguration is successful
    Should Contain    ${ret1}    SgNBReconfigurationComplete
    Should Contain    ${ret1}    eventId eventA1
    Should Contain    ${ret1}    a1-Threshold rsrp : 70
    Should Contain    ${ret1}    timeToTrigger ms320
    Get RRC Log

Security Key Refresh
    [Arguments]    ${ue_id}=11    ${cell_id_Target}=1
    Start RRC Log     Security_Key_Refresh
    Execute Egate Command    enb_cell_param enb=1 id=${cell_id_Target} allow_endc=on
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=1:1|2:1|3:1|4:1
    ${ret1}    Execute Egate Command    ue_reauth id=${ue_id}
    ...    pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Should Contain    ${ret1}    Dual Connectivity reconfiguration is successful
    Should Contain    ${ret1}    REAUTHENTICATION PROCEDURE IS COMPLETED
    Should Contain    ${ret1}    sCellToAddModList
    Should Contain    ${ret1}    Intra-cell handover (key refresh) performed
    Get RRC Log

SCG Configuration Change to trigger Scell release then trigger Pcell A1 configure back
    [Arguments]    ${ue_id}=11
    Start RRC Log     SCG_Configuration_Change
    Execute Egate Command    enb_cell_param enb=1 id=2 allow_endc=on
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=1:1
    ${ret1}=    Execute Egate Command    ue_ho enb=1 cell=2 id=${ue_id}
    ...    SgNBReconfigurationComplete
    Should Not Contain    ${ret1}    a1-Threshold rsrp : 70
    Should Contain    ${ret1}    sCellToReleaseList
    Execute Egate Command    enb_endc_param id=1 reset
    Execute Egate Command    enb_endc_param id=1 serving_cell_index_range_scg=8:14
    Execute Egate Command    enb_cell_param enb=1 id=1 allow_endc=on
    ${ret2}=    Execute Egate Command    ue_ho enb=1 cell=1 id=${ue_id}
    ...     Proxy \\(eNB 2 cell 1\\) reported successful RA
    Should Contain    ${ret2}    eventId eventA1
    Should Contain    ${ret2}    timeToTrigger ms5120
    Should Contain    ${ret2}    a1-Threshold rsrp : 70
    Get RRC Log


