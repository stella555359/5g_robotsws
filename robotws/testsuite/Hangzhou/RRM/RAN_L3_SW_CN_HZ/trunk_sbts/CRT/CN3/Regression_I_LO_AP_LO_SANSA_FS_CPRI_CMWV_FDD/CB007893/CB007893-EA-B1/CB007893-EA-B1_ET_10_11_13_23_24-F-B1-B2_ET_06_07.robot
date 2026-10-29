*** Settings ***
Documentation    Suite description
...   Author:      Geng Lishuo
...   Contact:     lishuo.geng@nokia-sbell.com
...   Squad Group: MMW_SG7
...   Feature:     CB007893
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...               team-DevHZ5_SG1  owner-pei.han  release-5G21B
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    fddtdd_sansa_cmwv/3cells_1T2F
@{PARAMS_IN_SCF}    @{CA_Basic}    @{CB007893}    @{Mobility}    @{NSA_CONF}    @{other}

@{CA_Basic}       NRDU-1:actInterNumerologyCa=true    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Nsa
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
...    NRCELL-1/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
${ue_eutra_nr_capabilities}    SEPARATOR=
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
...    NRCELL-2:a1MeashoEnabled=rsrp    NRCELL-2:a2MeashoEnabled=rsrp    NRCELL-2:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60
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
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true    NRCELL-2:a3MeasEnabled=rsrp    NRCELL-2:absThreshSsbRsrpConsolidation=1
...    NRCELL-2:sMeasConfigSsbRsrp=1    NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms512
...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-3:a1MeasSCellAddEnabled=rsrp    NRCELL-3:a3MeasEnabled=rsrp
...    NRCELL-3:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60    NRCELL-3:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-3:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0    NRCELL-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms512
...    NRCELL-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-3/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-1:cellDepType=NSA    NRCELL-3/NRHOIF-1:freqBandIndicatorNR=41    NRCELL-3/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcDuration=sf5    NRCELL-3/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-3/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam    NRCELL-3/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-1:ssbFrequency=518670
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...    NRCELL-1/NRREL-2:gNbId=2    NRCELL-1/NRREL-2:gNbIdLength=22    NRCELL-1/NRREL-2:lcrId=3    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:gNbId=2    NRCELL-3/NRREL-1:gNbIdLength=22    NRCELL-3/NRREL-1:lcrId=1    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS:timerX2UeProcGuard=15000
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-2:pucchModeSelect=longPucch
...    NRCELL:reportAmountCA=r2    #PR630713,5G_RAN_OP_2182
@{PM_Counters_Check_EA_Case10}    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=2    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=2
@{PM_Counters_Check_EA_Case11}    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=0    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=0
@{PM_Counters_Check_EA_Case23}    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=2    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
@{PM_Counters_Check_EA_Case24}    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=0
@{PM_Counters_Check_F_Case06}    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=2    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_NSA}=1    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_NSA}=1
@{PM_Counters_Check_F_Case07}    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_NSA}=1    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_NSA}=1
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
${A2MEAS_REL1DLSCELL_ATT_NSA}    M55118C06503
${A2MEAS_REL1DLSCELL_SUCC_NSA}    M55118C06504
${Update_Cfg_1}    set_cell id=2 enb=1 eci=0x1234602 pci=3:1 tac=222 proxy=10.0.2.1:12220|10.0.2.1:8890 earfcn=2000:20000
...    mandatory_for_activation=off
${Update_Cfg_2}    set_enb id=11 plmn=250:255 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.127 x2u=10.0.1.137
...    type=simulated x2_peers=none
${Update_Cfg_3}    set_cell id=3 gnb=3 tac=3 pci=127:0 proxy=10.0.2.1:12221|10.0.2.1:8891 nrci=0x1 nr_arfcn=134044:126244 gscn=1589
...    mandatory_for_activation=off
${normal_report_A2}    6s
@{OnlineParam_maxNumOfCaUsersNRCell}    NRCELL-1:maxNumOfCaUsersNRCell=1    NRCELL-2:maxNumOfSCellAlloc=250
@{OnlineParam_maxNumOfSCellAlloc}    NRCELL-1:maxNumOfCaUsersNRCell=250    NRCELL-2:maxNumOfSCellAlloc=1
@{NSA_CONF}
...    NRBTS:gNbCuType=NSA
...    NRBTS:actSACallProcessingDU=false
...    NRCELL:cellDepType=NSA
...    delete:NRCELL:trackingAreaDN
...    delete:NRBTS-2/TRACKINGAREA-200:snssaiList
...    delete:NRBTS-2/SNSSAI-1:ngUplane
...    delete:NRBTS-2/NRSYSINFO_PROFILE-1/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-2/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-3/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-4/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-11/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-12/NRLIM-1

@{other}
...    delete:MRBTS-2/NRBTS-2/NRCELL:ranAC

*** Test Cases ***
CB007893-EA-B1_ET_10_01_A3 or A5 mobility measurement report received while SCell addition is in progress
    [Tags]    TC10
    Clear Counter files
    Set UE Parameters Before Attach
    OnlineParamChange    ${OnlineParam_maxNumOfCaUsersNRCell}
    UE Attach and establish EN-DC
    Scell Addition ongoing meantime receive A3 measurement report
    Trigger SN change from Sim gNB to Real gNB with allowedBC-ListMRDC Change
    Pcell A1 report to trigger Scell Addition    meas_id=7
    Check RRC Log    ${CURDIR}${/}a2a_CB007893-EA-B1_ET_10${/}a2a.ini
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007893-EA-B1_ET_10${/}a2a.ini
    Check Counters    ${PM_Counters_Check_EA_Case10}

CB007893-EA-B1_ET_11_01_Pcell A1 measurement report for SCell addition is received during an ongoing mobility procedure but HO failed
    [Tags]
    Clear Counter files
    Set UE Parameters Before Attach
    UE Attach and establish EN-DC
    Ignore Pcell A1 report when SN change ongoing
    Check Counters    ${PM_Counters_Check_EA_Case11}

CB007893-EA-B1_ET_13_02_When PCell A1 triggered SCell addition for NSA meantime receive SgNB release
    [Tags]
    Set UE Parameters Before Attach
    UE Attach and establish EN-DC
    Scell Addition ongoing meantime receive SgNB Release

CB007893-EA-EC1_ET_23_02_SCell addition failure due to MeNB refusal
    [Tags]
    Clear Counter files
    Set UE Parameters Before Attach
    OnlineParamChange    ${OnlineParam_maxNumOfSCellAlloc}
    UE Attach and establish EN-DC
    SCell addition failure due to MeNB refusal
    Check Counters    ${PM_Counters_Check_EA_Case23}

CB007893-EA-EC1_ET_24_02_SCell addition failure due to MeNB no response the SgNB modification required
    [Tags]
    Clear Counter files
    Set UE Parameters Before Attach
    UE Attach and establish EN-DC
    SCell addition failure due to MeNB no response then trigger SN change
    Check Counters    ${PM_Counters_Check_EA_Case24}

CB007893-F-B1-B2_ET_06_01_UE report Scell A2 measurement report then report A3 mobility report
    [Tags]
    Clear Counter files
    Set UE Parameters Before Attach
    UE Attach and establish EN-DC
    Pcell A1 report to trigger Scell Addition
    Scell Release ongoing meantime receive A3 measurement report But HO Reject
    Pcell A1 report to trigger Scell Addition    meas_id=3
    Check RRC Log    ${CURDIR}${/}a2a_CB007893-F-B1-B2_ET_06${/}a2a.ini
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007893-F-B1-B2_ET_06${/}a2a.ini
    Check Counters    ${PM_Counters_Check_F_Case06}

CB007893-F-B1-B2_ET_07_01_UE report A3 mobility report then report Scell A2 measurement report but HO canceled
    [Tags]
    Clear Counter files
    Set UE Parameters Before Attach
    UE Attach and establish EN-DC
    Pcell A1 report to trigger Scell Addition
    Ignore Scell A2 report when SN change ongoing But HO failed
    Scell A2 report to trigger Scell Release
    Check Counters    ${PM_Counters_Check_F_Case07}

*** Keywords ***
Start BTS With Specified Config Files
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}    ue_count=1

Modify Cfg
    Update Cfg    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Update Cfg    ${Update_Cfg_1}
    Update Cfg    ${Update_Cfg_2}
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    set_cell id=1 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:8887 earfcn=2000:20000 mandatory_for_activation=off
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Update Cfg    gnb_set id=3 s1u=10.0.1.122 plmn=250:255 gnb_id=0x3 type=simulated daemon=10.0.2.1:22222 x2=10.0.1.122:36422 x2_peers=none
    Update Cfg    ${Update_Cfg_3}
    Update Cfg    gnb_endc_param id=3 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0
    Update Cfg    gnb_param id=3 x2_listening_socket=1 measEvent=A3
    Update Cfg    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 gnb_id=0x2:22 x2=10.0.1.2:36422

Set UE Parameters Before Attach
    Execute Egate Command    enb_x2_link_up enb=11 target=2    ENB-11: X2AP Link with GNB-2
    Execute Egate Command    enb_x2_link_up enb=1 target=3    ENB-1: X2AP Link with GNB-3
    Execute Egate Command    enb_timer T_RRC_TRANSACTION=4s
    Execute Egate Command    link_x2_management_abnormal_cases id=1 partner=2 sgnb_modification_reqd_rsp=normal_rsp
    Execute Egate Command    link_x2_management_abnormal_cases id=1 partner=2 sgnb_change_rsp=normal_rsp
    Execute Egate Command    ue_rrc_reconf_param id=11 reset
    Execute Egate Command    enb_endc_param id=1 reset
    Execute Egate Command    enb_endc_param id=1 serving_cell_index_range_scg=8:14

UE Attach and establish EN-DC
    [Arguments]    ${ue_id}=11    ${target_cell}=1
    Start RRC Log    establish_EN-DC
    Execute Egate Command    ue_attach id=${ue_id} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cell} bearer=2 type=split_scg
    ...    Proxy \\(eNB 2 cell 1\\) reported successful RA
    Get RRC Log

Pcell A1 report to trigger Scell Addition
    [Arguments]    ${ue_id}=11    ${meas_id}=3
    Start RRC Log     Scell_Addition
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=60 event=A1 srsrp_nr=80 srsrq_nr=40
    ...    SgNBModificationConfirm
    Should Contain    ${ret1}    Successfully reconfigured dual connectivity
    Should Contain    ${ret1}    rrcConnectionReconfigurationComplete
    Should Contain    ${ret1}    eventA2
    Should Contain    ${ret1}    sCellToAddModList
    Get RRC Log

Scell A2 report to trigger Scell Release
    [Arguments]    ${ue_id}=11    ${meas_id}=4
    Start RRC Log     Scell_Release
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} scell=9 scell_rsrp=40 scell_rsrq=0 event=A2
    ...    SgNBModificationConfirm
    Should Contain    ${ret1}    eventA1
    Should Contain    ${ret1}    sCellToReleaseList
    Get RRC Log

Ignore Pcell A1 report when SN change ongoing
    [Arguments]    ${ue_id}=11    ${meas_id_A3}=1    ${meas_id_A1}=3    ${timeout}=5s
    Execute Egate Command    link_x2_management_abnormal_cases id=1 partner=2 sgnb_change_rsp=no_rsp
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=381 nrsrp_nr=60 nrsrq_nr=30
    ...    fail_regexp=Bearer-type change from MCG to SCG-split is successful    timeout=${timeout}
    Should Not Contain    ${ret1}    rrcConnectionReconfigurationComplete
    ${ret2}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A1} phycell_id=60 event=A1 srsrp_nr=80 srsrq_nr=40
    ...    fail_regexp=SgNBModificationConfirm
    Should Not Contain    ${ret2}    Successfully reconfigured dual connectivity
    Should Not Contain    ${ret2}    rrcConnectionReconfigurationComplete

SCell addition failure due to MeNB no response then trigger SN change
    [Arguments]    ${ue_id}=11    ${meas_id_A1}=3    ${meas_id_A3}=1    ${timeout}=5s
    Execute Egate Command    link_x2_management_abnormal_cases id=1 partner=2 sgnb_modification_reqd_rsp=no_rsp
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A1} phycell_id=60 event=A1 srsrp_nr=80 srsrq_nr=40
    ...    fail_regexp=SgNBModificationConfirm    timeout=${timeout}
    #Should Not Contain    ${ret1}    Successfully reconfigured dual connectivity
    #Should Not Contain    ${ret1}    rrcConnectionReconfigurationComplete
    ${ret2}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=381 nrsrp_nr=60 nrsrq_nr=30
    ...    pass_regexp=Bearer-type change from SCG-split to MCG is successful
    Should Contain    ${ret2}    SgNBReleaseRequired
    Should Not Contain    ${ret2}    Bearer-type change from MCG to SCG-split is successful
    Should Not Contain    ${ret2}    SgNB Change Confirm

Trigger Sim gNB to Add Scell
    [Arguments]    ${ue_id}=11
    Execute Egate Command    gnb_endc_param id=3 enable_ca_scells_addition_or_deletion=on
    ${ret1}=    Execute Egate Command    ue_nr_rrc_reconf id=${ue_id} scells_to_add=9    pass_regexp=SgNB Modification is successful
    Should Contain    ${ret1}    sCellToAddModList
    Should Contain    ${ret1}    sCellIndex 9

Trigger SN change from Sim gNB to Real gNB with allowedBC-ListMRDC Change
    [Arguments]    ${ue_id}=11
    Trigger Sim gNB to Add Scell
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=4:1
    Start RRC Log    Incoming_HO
    ${ret1}=    Execute Egate Command    gnb_ue_dc_change ue=${ue_id} gnb=2 target_sgnb_cells=1 cause=RN_sCG_Mobility
    ...    pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Should Contain    ${ret1}    Successfully reconfigured dual connectivity
    Should Contain    ${ret1}    Inter Sgnb Handover is successful
    Should Contain    ${ret1}    SgNBChangeConfirm
    Should Contain    ${ret1}    eventId eventA1
    Get RRC Log

Scell Addition ongoing meantime receive A3 measurement report
    [Arguments]    ${ue_id}=11    ${meas_id_A1}=3    ${meas_id_A3}=1
    Start RRC Log     Scell_Addition_And_HO
    Execute Egate Command    ue_rrc_reconf_param id=${ue_id} if_contains=any delay=800ms action=none
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A1} phycell_id=60 event=A1 srsrp_nr=80 srsrq_nr=40
    ...    pass_regexp=Hit on RRC Reconfiguration Rule presence=any delay=800 action=none
    ${ret1}    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=381 nrsrp_nr=60 nrsrq_nr=30
    ...    pass_regexp=Bearer-type change from MCG to SCG-split is successful
    Should Contain    ${ret1}    Successfully reconfigured dual connectivity
    Should Contain    ${ret1}    SgNB Modification Confirm
    Should Contain    ${ret1}    Proxy (eNB 3 cell 3) reported successful RA
    Should Contain    ${ret1}    SgNB Change Confirm
    Get RRC Log

Scell Addition ongoing meantime receive SgNB Release
    [Arguments]    ${ue_id}=11    ${meas_id}=3    ${timeout}=5s
    Execute Egate Command    link_x2_management_abnormal_cases id=1 partner=2 sgnb_modification_reqd_rsp=no_rsp
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=60 event=A1 srsrp_nr=80 srsrq_nr=40
    ...    fail_regexp=SgNBModificationConfirm    timeout=${timeout}
#    Should Not Contain    ${ret1}    Successfully reconfigured dual connectivity
#    Should Not Contain    ${ret1}    rrcConnectionReconfigurationComplete
    ${ret2}=    Execute Egate Command    ue_dc_release_enb ue=${ue_id} by=enb cause=RN_mCG_Mobility
    ...    pass_regexp=Bearer-type change from SCG-split to MCG is successful
#    Should Contain    ${ret2}    Modification is aborted by SgNB Release Request, Partial Reset or timeout on SgnbReconfigurationComplete
    Should Contain    ${ret2}    Successfully reconfigured dual connectivity
    Should Contain    ${ret2}    nr-Config-r15 release : NULL
    Should Contain    ${ret2}    SgNBReleaseRequestAcknowledge

SCell addition failure due to MeNB refusal
    [Arguments]    ${ue_id}=11    ${meas_id}=3
    Execute Egate Command    link_x2_management_abnormal_cases id=1 partner=2 sgnb_modification_reqd_rsp=refuse
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=60 event=A1 srsrp_nr=80 srsrq_nr=40
    ...    pass_regexp=SgNBModificationRefuse
    Should Not Contain    ${ret1}    Successfully reconfigured dual connectivity
    Should Not Contain    ${ret1}    SgNBModificationConfirm
    Execute Egate Command    link_x2_management_abnormal_cases id=1 partner=2 sgnb_modification_reqd_rsp=normal_rsp
    ${ret2}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=60 event=A1 srsrp_nr=80 srsrq_nr=40
    ...    SgNBModificationConfirm
    Should Contain    ${ret2}    Successfully reconfigured dual connectivity
    Should Contain    ${ret2}    rrcConnectionReconfigurationComplete

Scell Release ongoing meantime receive A3 measurement report But HO Reject
    [Arguments]    ${ue_id}=11    ${meas_id_A2}=4    ${meas_id_A3}=1
    Execute Egate Command    link_x2_management_abnormal_cases id=1 partner=2 sgnb_change_rsp=reject
    Start RRC Log     Scell_Release_And_HO_Reject
    sleep    ${normal_report_A2}
    ${A2_A3_HO_Reject}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A2} scell=9 scell_rsrp=40 scell_rsrq=0
    ...    event=A2;ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=50 srsrq_nr=30
    ...    phycell_id=381 nrsrp_nr=60 nrsrq_nr=30
    ${ret1}    Execute Egate Command    ${A2_A3_HO_Reject}
    ...    pass_regexp=SgNBChangeRefuse
    Should Contain    ${ret1}    Successfully reconfigured dual connectivity
    Should Contain    ${ret1}    SgNB Modification Confirm
    Should Not Contain    ${ret1}    Proxy (eNB 3 cell 3) reported successful RA
    Should Not Contain    ${ret1}    SgNB Change Confirm
    Should Contain    ${ret1}    SgNBChangeRequired
    Should Contain    ${ret1}    eventA1
    Should Contain    ${ret1}    sCellToReleaseList
    Get RRC Log

Ignore Scell A2 report when SN change ongoing But HO failed
    [Arguments]    ${ue_id}=11    ${meas_id_A2}=4    ${meas_id_A3}=1
    Execute Egate Command    link_x2_management_abnormal_cases id=1 partner=2 sgnb_change_rsp=reject
    ${A2_A3_HO_Reject}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=381
    ...    nrsrp_nr=60 nrsrq_nr=30;ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A2} scell=9 scell_rsrp=40 scell_rsrq=0 event=A2
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
  Cells Should Be OnAir    check_sib=${False}
