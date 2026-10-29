*** Settings ***
Suite Setup    Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4A_CUS
...    owner-yin.zhang    release-SBTS20A    team-DEVHZ5_SG6
Resource    ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CA}
...    @{x2link}
...    @{LTE4088}
...    @{LTE4193}
...    @{LTE4549}
...    @{dlSectorBFWeight}
...    @{Throughput}
...    @{Closed_Loop_MIMO_8x4}
...    @{LTE5515}
...    LNBTS:actSnChangeSnInit=true
...    @{PARAMS_FIX_RELATION_ERROR}
#temporary workaround for LTE4193-B for supporting MeasTimingConf in X2SetupReponse for gNB
${LTE4193B_SUPPORTING_MeasTimingConf}    0x00130060
@{PARAMS_IN_SWCONFIG}
...    ${LTE4193B_SUPPORTING_MeasTimingConf} = 1

@{CA}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAdvScellMeas=true
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=20
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL:actFlowCtrlEnh=false
...    LNCEL-1/LNCEL_TDD-0:earfcn=39777
...    LNCEL-2/LNCEL_TDD-0:earfcn=39948
...    LNCEL-3/LNCEL_TDD-0:earfcn=40146
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
...    LNBTS/LNADJGNB-2:administrativeState=unlocked
...    LNBTS/LNADJGNB-2:cPlaneIpAddr=10.0.1.12
...    LNCEL/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-2:nrCellId=132354
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=10000
...    LNCEL:defaultLnRelGnbCellId=1
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
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
@{LTE4549}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference
@{LTE5515}
...    LNBTS:actEnhFlexCaWithEnDc=true
...    LNBTS:enableBwComSetChkEnDc=true
${ue1_nr_capabilities}
...    SEPARATOR=
...    CF00000001C8F5C0302800001939980000CCC02000014000013400009C020070003080000280510136027131000000300C0020000002C00000
...    001000000000020040
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
${ue2_nr_capabilities}    CE00000001C8F5C0302800001939980000CC00100001400000989880000018060010000001
${ue2_eutra_nr_capabilities}
...    SEPARATOR=
...    C10060F70B2832E1400000003F8000000080010150FA00000005C2CA0CB84C0000040FE0000000200040543E8000000131328004505C280000
...    0407F000000000CC4CA0C914070A00000181FC00000000331328224501C2800000807F000000000CC4CA08914170A00000281FC00000000371
...    B280045008A038500000180FE000000020004054010040A2014402601820004010080100210002008040080110000402000100808010022040
...    50080B01012020403000010000C000500200600400C0100210000804000100008010022020380802010102000010000C008018020043020300
...    40100810180003000080200018000600400C008010
${ue2_eutra_capabilities}
...    SEPARATOR=
...    DDB80501A1F8285CCFFFC2E67FFE1733FFEFF9FFD7D10800443214E8820CA74A92E3F52FC00000000040978480C18EF8000000167A00600504
...    21801841082100218410821040184008610420840086084304218210C1086084304218210C1086084304218210C10860843042180180180180
...    18012D0FAA8C20700E80004D03FC001041E8000416808207400C2685D00008AD0105A02005D000090D0105A02084D0127A000105A02004D012
...    7A000101A02084D0123A000105A02085D000082D0105A02005D000080D0105A02083D0000A2D01041680A3D0000820F400826B404907A00013
...    5A02482D0137A00412416809BD0000920F400826B404107A000135A02082D0137A0001041E801049680920F400024B404907A004125A02083D
...    000092D0104168093D0000820740002A81D0000A20740082681D0020927A1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E6
...    7FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2
...    E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFB67600007EC40D9D8000047CEC00003C21E3F00000047FCF0000808083
...    02000100100100100100100100080200802008020080200802008020080200000000001F04012003E700515E681005217F9A52EF1403E00108
...    00669200004000A219734040A04D40103411E14000082086080000102080182082080082080080004082084000004080005190100010000880
...    0042020010
@{LTE5515-A-c_04_01}
...    LNCEL/LNCEL_TDD-0:chBw=20 MHz
...    LNCEL-1/LNCEL_TDD-0:earfcn=39750    # 2506Mhz
...    LNCEL-2/LNCEL_TDD-0:earfcn=39948    # 2525.80Mhz
...    LNCEL-3/LNCEL_TDD-0:earfcn=40146    # 2545.60Mhz
@{LTE5515-A-d_04_02}
...    LNCEL-1/LNCEL_TDD-0:chBw=20 MHz
...    LNCEL-2/LNCEL_TDD-0:chBw=15 MHz
...    LNCEL-3/LNCEL_TDD-0:chBw=20 MHz
...    LNCEL-1/LNCEL_TDD-0:earfcn=39777    # 2508.70Mhz
...    LNCEL-2/LNCEL_TDD-0:earfcn=39948    # 2525.80Mhz
...    LNCEL-3/LNCEL_TDD-0:earfcn=40119    # 2542.90Mhz
${ue3_nr_capabilities}    CE00000001C8F5C0302800001939980000CC00100001400000989880000018060010000001
${ue3_eutra_nr_capabilities}
...    SEPARATOR=
...    C10060F70B2832E1400000003F800000008001015006E165065C2600000207F00000001000202A00CC4CA00114170A00000101FC0000000033
...    1328324501C2800000607F000000000CC4CA08914070A00000201FC00000000331328224505C2800000A07F000000000DC6CA0011402280E14
...    00000603F80000000800101500401028805100980608001004020040084000802010020044000100800040202004008810140202C040480810
...    0C000040003000140080180100300400840002010000400020040088080E02008040408000040003002006008010C080C010040204060000C0
...    00200800060001801003002004
${ue3_eutra_capabilities}
...    SEPARATOR=
...    DDB80501A1F8285CCFFFC2E67FFE1733FFEFF9FFD7D10800443214E8820CA74A92E3F52FC00000000040978480C18EF8000000167A00600504
...    21801841082100218410821040184008610420840086084304218210C1086084304218210C1086084304218210C10860843042180180180180
...    18012D0FAA8C20700E80004D03FC001041E8000416808207400C2685D00008AD0105A02005D000090D0105A02084D0127A000105A02004D012
...    7A000101A02084D0123A000105A02085D000082D0105A02005D000080D0105A02083D0000A2D01041680A3D0000820F400826B404907A00013
...    5A02482D0137A00412416809BD0000920F400826B404107A000135A02082D0137A0001041E801049680920F400024B404907A004125A02083D
...    000092D0104168093D0000820740002A81D0000A20740082681D0020927A1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E6
...    7FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2
...    E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFB67600007EC40D9D8000047CEC00003C21E3F00000047FCF0000808083
...    02000100100100100100100100080200802008020080200802008020080200000000001F04012003E700515E681005217F9A52EF1403E00108
...    00669200004000A219734040A04D40103411E14000082086080000102080182082080082080080004082084000004080005190100010000880
...    0042020010

@{PARAMS_FIX_RELATION_ERROR}
...    LNBTS:actAmbrModCaTrigger=false
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:actTransmittedBelowGap=false
...    LNBTS:enableNonCompBcsChkEnDc=false
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:nrRestrictionOverride=disabled
...    LNBTS:tS1eRABModInd=2000
...    LNCEL:eTputFilterConfig=51
...    LNCEL:eTputInitMcs=20

${ALLOW_BC_LIST_2}    allowedBC-ListMRDC contains (
    ...    bandCombinationIndex eq 1 and allowedFeatureSetsList contains (1),
    ...    bandCombinationIndex eq 2 and allowedFeatureSetsList contains (1)) and
    ...    length(allowedBC-ListMRDC) eq 2
${SNAPSHOT_FLAG}   pass:True,fail:True

*** Test Cases ***
LTE5515-A-c_ET_04_01_Bandwidth combination set checking with sgnb change successfully for non-contiguous inter-band EN-DC setup
    [Tags]    owner-alex.2.wang
    Delta Commission Parameters And Wait Cells Onair    ${LTE5515-A-c_04_01}
    UE attach    ue=2
    Start traffic To Trigger 3CC CA    ue=2
    Trigger ENDC And CA Still 3CC    ue=2
    Trigger SgNB Change And CA Still 3CC    ue=2

LTE5515-A-d_ET_04_02_Scell full release after SgNB addition ack is received due current BWC not support for intra band contiguous EN-DC
    [Documentation]    case name was:[LTE5515-A-d_ET_04_02_Scell full release after SgNB addition ack is received
    ...    due to second scell not support current Bandwidth combination for intra band contiguous EN-DC]
    [Tags]    owner-tom.li
    Delta Commission Parameters And Wait Cells Onair    ${LTE5515-A-d_04_02}
    UE attach    ue=3
    Start traffic To Trigger 3CC CA    ue=3
    Trigger ENDC And CA Changed From 3CC to 1CC    ue=3

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_TDD_8PIPEs
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=10    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create Enb Alias    GNB_8    enb_id=8    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Set ue parameters before attach

Perform Steps After Onair
    @{lnadjgnb7}    Create List    LNADJGNB:cPlaneIpAddr=10.0.1.11    LNADJGNB:x2ToGnbLinkStatus=available
    Object Should Exist    ${lnadjgnb7}
    @{lnadjgnb8}    Create List    LNADJGNB:cPlaneIpAddr=10.0.1.12    LNADJGNB:x2ToGnbLinkStatus=available
    Object Should Exist    ${lnadjgnb7}

Modify Yaml
    Update Yaml    LOGS/CUS    syslog_mode: WRN    syslog_mode_asia: DBG
    # update UE1~UE3, qci6 as default QCI
    Update Yaml    UEs/bearer_sets/bearer_set_1/1    qci: 6
    Update Yaml    UEs/bearer_sets/bearer_set_1/7    qci: 8
    FOR    ${ue}    IN RANGE    1    4
       Update Yaml    UEs/UE_sets/${ue}    bearer: bearer_set_1    release: 15    nea: null    nia: null
    END
    ${GNB7_CELL1}    catenate    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x501', nr_arfcn: '524100:524100',
    ...    meas_timing_carrier_freq: ${NRARFCN524100}, ssb_subcarrier_spacing: kHz15,
    ...    ssb_mtc_periodicity_and_offset: 'sf5:1', ssb_mtc_duration: 'sf1'}
    ${GNB8_CELL1}    catenate    - {id: 81, technology: nr , tac: 33, pci: '1:0', nrci: '0x502', nr_arfcn: '380000:380000',
    ...    meas_timing_carrier_freq: 380032, ssb_subcarrier_spacing: kHz15,
    ...    ssb_mtc_periodicity_and_offset: 'sf5:1', ssb_mtc_duration: 'sf1'}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...    gnb_id: '0x00007'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.11
    ...    x2u: 10.0.1.13
    ...    x2_peers: none
    ...    cells:
    ...    ${GNB7_CELL1}
    Add Yaml    BASE_STATIONS
    ...    - id: 8
    ...    gnb_id: '0x00008'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.12
    ...    x2_peers: none
    ...    cells:
    ...    ${GNB8_CELL1}

Set ue parameters before attach
    Execute Uex Command    ue_param id=1-10 dual_conn=eutra_nr pdcp_sn_extension=18bit nr_supported_bands=39-41
    Execute Uex Command    ue_cqi_param id=1-10 scell=0-2 rank=4 ri_i1=18
    Execute Uex Command    ue_cqi_param id=1-10 scell=0-3 rank=4 cell=both
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true scg_dl_dist_percent=0 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=8 use_nr_ran_cont=true scg_dl_dist_percent=0 include_reestablish_pdcp=on
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms T_DC_Overall=5000ms

UE attach
    [Arguments]    ${ue}=1
    ${attach_cmd}    catenate
    ...    ue_attach id=${ue} cell=1 ue_nr_capabilities=${ue${ue}_nr_capabilities} ue_eutra_nr_capabilities=${ue${ue}_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue${ue}_eutra_capabilities}
    Execute Uex Command    ${attach_cmd}

Start traffic To Trigger 3CC CA
    [Arguments]    ${ue}
    ${3cc}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    physCellId-r10 eq 3,
    ...    physCellId-r10 eq 2)
    ...    and length(sCellToAddModList-r10) eq 2
    Expect Message Flow
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (${3cc})
    ...    alias=3cc_flow    overall_timeout=20
    Execute Uex Command    trf_data_start ue=${ue} Mbps=150 dir=dl protocol=udp
    Flow Occurred As Expected    alias=3cc_flow

Trigger ENDC And CA changed
    [Arguments]    ${ue}    ${allowed_bc_list}    ${selected_bc}    ${ca_conf}
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=${selected_bc}
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest (${allowed_bc_list})
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (${ca_conf})
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfigurationComplete
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    alias=b1_flow    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue} event=B1_NR phycell_id=1 nrsrp=62
    Flow Occurred As Expected    alias=b1_flow

Trigger ENDC And CA Still 3CC
    [Arguments]    ${ue}
    ${DC_41D_n41A_BCS1}    Set Variable    1:1    # support 20+20+20
    ${3cc_to_3cc}    Catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1, sCellIndex-r10 eq 2)
    ...    and length(sCellToAddModList-r10) eq 2
    Trigger ENDC And CA changed    ue=${ue}    allowed_bc_list=${ALLOW_BC_LIST_2}    selected_bc=${DC_41D_n41A_BCS1}    ca_conf=${3cc_to_3cc}

Trigger ENDC And CA Changed From 3CC to 1CC
    [Arguments]    ${ue}
    ${DC_41D_n41A_BCS0}    Set Variable    1:1    # only support 20+20+20, don't support 20+15+20
    ${3cc_to_1cc}    Catenate    sCellToReleaseList-r10 contains ( 1, 2)
    Trigger ENDC And CA changed    ue=${ue}    allowed_bc_list=${ALLOW_BC_LIST_2}    selected_bc=${DC_41D_n41A_BCS0}    ca_conf=${3cc_to_1cc}

Trigger SgNB Change And CA Still 3CC
    [Arguments]    ${ue}
    ${3cc_to_3cc}    Catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1, sCellIndex-r10 eq 2)
    ...    and length(sCellToAddModList-r10) eq 2
    Expect Message Flow
    ...    GNB_7:X2AP_SgNBChangeRequired
    ...    GNB_8:X2AP_SgNBAdditionRequest (${ALLOW_BC_LIST_2})
    ...    GNB_8:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (${3cc_to_3cc})
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfigurationComplete
    ...    GNB_7:X2AP_SgNBChangeConfirm
    ...    GNB_8:X2AP_SgNBReconfigurationComplete
    ...    GNB_7:X2AP_SNStatusTransfer
    ...    GNB_8:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    alias=inter_gnb_ho_flow    overall_timeout=20
    ${DC_41D_n39A_BCS0}    Set Variable    2:1    #support 20+20+20
    Execute Egate Command    gnb_endc_param id=8 selected_band_combination_nr=${DC_41D_n39A_BCS0}
    Execute Egate Command    gnb_ue_dc_change ue=${ue} gnb=8 target_sgnb_cells=81 cause=RN_sCG_Mobility    SgNBChangeRequired
    Flow Occurred As Expected    alias=inter_gnb_ho_flow


