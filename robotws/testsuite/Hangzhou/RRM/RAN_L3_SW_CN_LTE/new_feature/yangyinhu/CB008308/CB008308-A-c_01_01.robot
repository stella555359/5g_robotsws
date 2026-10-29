*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               team-SG4    release-SBTS22R1    owner-yang.yinhu
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

@{PARAMS_IN_VENDOR}
...    LNBTS:reportTimerEndcA5=5000ms

@{PARAMS_IN_SCF}
...    @{x2_link_with_NR}
...    @{LTE4088_ENDC}
...    @{LTE4193_Dynamic_ENDC}
...    @{LTE4281_Intra-eNB_HO_ENDC}
...    @{CB008308}
...    @{fix_thoughtput_too_low_issue}

${ERadCcs_AaSysLogOutputMode}    0x10041
${ERadCcs_AaSysLogOutputLevel}    0x10040
${ERadCcs_AaSysLogInputLevel}    0x1003F
${BSTAT_PM_debug_prints}    0x340003
${BSTAT_mcounter_debug_prints}    0x340005
${enable_measurement_reporting_prints}    0x34000E
${AaTrace_debug_print}    0x10023
${Message_trace_debug_print}    0x1002
${AaTrace_SwConfig_used+flag}    0x1002A

@{PARAMS_IN_SWCONFIG}
...    ${ERadCcs_AaSysLogOutputMode}=5    
...    ${ERadCcs_AaSysLogOutputLevel}=1
...    ${ERadCcs_AaSysLogInputLevel}=1
...    ${BSTAT_PM_debug_prints}=1
...    ${BSTAT_mcounter_debug_prints}=1
...    ${enable_measurement_reporting_prints}=8080
...    ${AaTrace_debug_print}=1
...    ${Message_trace_debug_print}=1
...    ${AaTrace_SwConfig_used+flag}=1

${CELLC_ENDC_BLOCKING_CHECK_REQ_MSG}    0x76E2
${CELLC_ENDC_BLOCKING_CHECK_RESP_MSG}    0x76E3

@{PARAMS_IN_EMIL}
...    ${CELLC_ENDC_BLOCKING_CHECK_REQ_MSG}
...    ${CELLC_ENDC_BLOCKING_CHECK_RESP_MSG}
...    0x2381
...    0x2382
...    0x74EB
...    0x74F2
...    0x74F3
...    0x74F4
...    0x2495
...    0x7560
...    0x7561
...    0x7562
...    0x7563
...    0x759C
...    0x759D
...    0x75DC
...    0x75DD
...    0x75DE
...    0x75DF
...    0x75E7
...    0x75E8
...    0x7539
...    0x753A

@{x2_link_with_NR}
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

@{LTE4088_ENDC}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:actTransmittedBelowGap=false
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:tLteNrDualConnectPrep=8000
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNCEL-2:defaultLnRelGnbCellId=1
...    LNCEL-3:defaultLnRelGnbCellId=1
...    LNBTS:actIfHo=enabled
...    LNBTS:actSelMobPrf=false
...    LNBTS/MODPR-0:autoAdapt=false
...    LNBTS:actMultBearers=true
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNCEL-1/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-2/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-3/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-1/LNCEL_FDD-0:maxNumActDrb=265
...    LNCEL-2/LNCEL_FDD-0:maxNumActDrb=265
...    LNCEL-3/LNCEL_FDD-0:maxNumActDrb=265
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1700
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=1700
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1700
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19700
...    LNCEL-1:threshold1=75
...    LNCEL-2:threshold1=76
...    LNCEL-3:threshold1=77

@{LTE4193_Dynamic_ENDC}
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:endcSchedWeightBoostDl=4
...    LNBTS:endcSchedWeightBoostUl=4
...    LNBTS:nrRestrictionOverride=disabled
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
...    LNBTS/LBPUCCHRPR-1:countdownPucchCompr=60min
...    LNBTS/LBPUCCHRPR-1:countdownPucchExp=1min
...    LNBTS/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNBTS/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN531000}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf

@{LTE4281_Intra-eNB_HO_ENDC}
...    LNBTS:enableBwCombCheck=true
...    LNBTS:actHoWoSnChg=intraEnbHoEnabled
...    LNBTS:sCellActivationCyclePeriod=2s
...    LNCEL-1/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNCEL-2/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-2/LNHOIF-1:thresholdRsrqEndcFilt=-120

@{CB008308}
...    LNBTS/MODPR-0:enDcBlockingAllowed=allowed
...    LNBTS/MODPR-0:caBlockingAllowed=forbidden
...    LNBTS/MOPR-1:enDcBlockingAllowed=allowed
...    LNCEL:actEnDcBlocking=true
...    LNCEL:loadBasedBlockThreshold:blockNumRrcConn=10
...    LNCEL:loadBasedBlockThreshold:blockThresholdGbrDl=80
...    LNCEL:loadBasedBlockThreshold:blockThresholdNonGbrDl=95
...    LNCEL:loadBasedBlockThreshold:blockThresholdPdcch=80
...    LNCEL:loadSettings:cellCapClass=100
...    LNCEL:loadSettings:mlbEicicOperMode=allUes
...    LNCEL:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL:loadSettings:targetLoadGbrDl=50
...    LNCEL:loadSettings:targetLoadNonGbrDl=75
...    LNCEL:loadSettings:targetLoadPdcch=90
...    LNCEL:loadSettings:ulCacIgnore=false
...    LNCEL:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL:loadSettings:ulStaticCac=100
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrc=270  # no use in CB008308

@{CB008308_default_parameters}
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdGbrDl=80
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdNonGbrDl=95
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdPdcch=80
...    LNBTS:qciTab5:schedulType=NON-GBR
...    LNBTS:qciTab5:lcgid=2

@{fix_thoughtput_too_low_issue}
...   LNCEL:cqiAperEnable=false
...   LNCEL/LNCEL_FDD-0:actUciOnlyGrants=false

@{Enable_blind_EN-DC}
...    LNBTS:actDynTrigLteNrDualConnectivity=false

@{Enable_Dynamic_EN-DC}
...    LNBTS:actDynTrigLteNrDualConnectivity=true

${PM_SPEED_UP_FLAG}    ${True}

${ue_nr_capabilities}  0000000001010000000060100581007018000000
${ue_eutra_nr_capabilities}  0108040160401C06000000000400020101002004
${ue_eutra_capabilities}  SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFEC800801C364000000017BA000000080952A0E2740400000820001080002180004400008A000118000238000480000920001280002580004
...    C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A0000000141000000F3A0000000000000000000000000000000000000000000000000000000000020238
...    8425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C2800033C000001800000080

@{A-c_01_01_blockThresholdNonGbrDl_step1}
...    LNBTS/LNCEL-1:actEnDcBlocking=false
...    LNBTS/LNCEL-2:actEnDcBlocking=true
...    LNBTS/LNCEL-3:actEnDcBlocking=false
...    LNBTS:actDynTrigLteNrDualConnectivity=false
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockNumRrcConn=100  # 3*(95+5)/100=3,allow 2 UEs not block ENDC
...    LNCEL/LNCEL_FDD-0:maxNumActUE=95
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:minNumRrcNoDrb=5
...    LNBTS/LNCEL-2:loadSettings:nomNumPrbNonGbr=1
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdGbrDl=80
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdNonGbrDl=1
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdPdcch=80

@{A-c_01_01_blockThresholdNonGbrDl_step2}
...    LNBTS/LNCEL-1:actEnDcBlocking=false
...    LNBTS/LNCEL-2:actEnDcBlocking=true
...    LNBTS/LNCEL-3:actEnDcBlocking=false
...    LNBTS:actDynTrigLteNrDualConnectivity=false
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockNumRrcConn=100  # 4*(95+5)/100=4,allow 3 UEs not block ENDC
...    LNCEL/LNCEL_FDD-0:maxNumActUE=95
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:minNumRrcNoDrb=5
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdGbrDl=80
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdNonGbrDl=2
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdPdcch=80

@{A-c_01_03_blockThresholdPdcch_step1}
...    LNBTS/LNCEL-1:actEnDcBlocking=false
...    LNBTS/LNCEL-2:actEnDcBlocking=true
...    LNBTS/LNCEL-3:actEnDcBlocking=false
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockNumRrcConn=100
...    LNCEL/LNCEL_FDD-0:maxNumActUE=95
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:minNumRrcNoDrb=5
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdGbrDl=80
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdNonGbrDl=95
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdPdcch=2
...    LNBTS:qciTab5:schedulType=NON-GBR
...    LNBTS:qciTab5:lcgid=2

@{A-c_01_03_blockThresholdPdcch_step2}
...    LNBTS/LNCEL-1:actEnDcBlocking=false
...    LNBTS/LNCEL-2:actEnDcBlocking=true
...    LNBTS/LNCEL-3:actEnDcBlocking=false
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockNumRrcConn=100
...    LNCEL/LNCEL_FDD-0:maxNumActUE=95
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:minNumRrcNoDrb=5
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdGbrDl=80
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdNonGbrDl=95
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdPdcch=6
...    LNBTS:qciTab5:schedulType=NON-GBR
...    LNBTS:qciTab5:lcgid=2

@{LNRELGNBCELL_delete}
...    delete:LNCEL-1:defaultLnRelGnbCellId
...    delete:LNCEL-1/LNRELGNBCELL-1
...    delete:LNCEL-1/LNRELGNBCELL-2

@{eNB1_cell1_without_ENDC}
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=123456  # not set in lua
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-1/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-2:nrCellId=1234567  # not set in lua
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
...    LNCEL-2:defaultLnRelGnbCellId=1
...    LNCEL-2/LNRELGNBCELL-1:nrCellId=115969  # 115969, in lua enb_id=7 + nrci=0x0000501
...    LNCEL-2/LNRELGNBCELL-2:nrCellId=132354  # 132354, in lua enb_id=8 + nrci=0x0000502

@{cell1_with_ENDC}
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969  # 115969, in lua enb_id=7 + nrci=0x0000501
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-1/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-2:nrCellId=123456  # not set in lua
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
...    LNCEL-2:defaultLnRelGnbCellId=1
...    LNCEL-2/LNRELGNBCELL-1:nrCellId=115969  # 115969, in lua enb_id=7 + nrci=0x0000501
...    LNCEL-2/LNRELGNBCELL-2:nrCellId=132354  # 132354, in lua enb_id=8 + nrci=0x0000502

${ENDC_BLOCK_CELL_LOAD_M8080C151}    M8080C151
${ENDC_BLOCK_RRC_CELL_M8080C152}    M8080C152
${ENDC_BLOCK_INC_HO_CELL_LOAD_M8080C153}    M8080C153
${ENDC_BLOCK_INC_HO_RRC_CELL_M8080C154}    M8080C154

@{A-c_01_01_step1}
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_CELL_LOAD_M8080C151}=1
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_RRC_CELL_M8080C152}=0
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_INC_HO_CELL_LOAD_M8080C153}=0
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_INC_HO_RRC_CELL_M8080C154}=0

@{A-c_01_01_step2}
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_CELL_LOAD_M8080C151}=3
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_RRC_CELL_M8080C152}=0  # add 1 block UE
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_INC_HO_CELL_LOAD_M8080C153}=0
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_INC_HO_RRC_CELL_M8080C154}=0

@{A-c_01_03_step1}
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_CELL_LOAD_M8080C151}=3
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_RRC_CELL_M8080C152}=0
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_INC_HO_CELL_LOAD_M8080C153}=0
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_INC_HO_RRC_CELL_M8080C154}=0

@{A-c_01_03_step2}
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_CELL_LOAD_M8080C151}=1
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_RRC_CELL_M8080C152}=0
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_INC_HO_CELL_LOAD_M8080C153}=0
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_INC_HO_RRC_CELL_M8080C154}=0

*** Test Cases ***
CB008308-A-c_01_01 Block Blind EN-DC due to Cell Load Overflow during intra-eNB HO
    [Documentation]
    ...  Precondition: CELL1 have wrong configuration of nrCellId so cann‘t create ENDC.
    ...  Scenario_1. cfg load limit 3 UEs(blockThresholdNonGbrDl=1), 
    ...              current load was 0, 4UEs HO without ENDC, 3UEs successful, 1UEs block ENDC;
    ...  Scenario_2. cfg load limit 6 UEs(blockThresholdNonGbrDl=2), 
    ...              current load was 1, 8UEs HO without ENDC, 5UEs successful, 3UEs block ENDC.
    [Tags]  QC_346170
    Enable Blind EN-DC and set eNB1 Cell1 without ENDC
	Set blockThreshold allow 2 UEs not block ENDC
    Verify 4 UEs attach without ENDC then do intra HO successful but 1 UE block ENDC other 3 successful
    UE detach then current blocked EN-DC UE number change to one    start_ue=2    end_ue=4
    Set loadBasedBlockThreshold of ENDC    ${A-c_01_01_blockThresholdNonGbrDl_step2}
    Verify eight UEs attach without ENDC then do intra HO successful but three UEs block ENDC other five successful

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
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

Set blockThreshold allow 2 UEs not block ENDC
    Set loadBasedBlockThreshold of ENDC    ${A-c_01_01_blockThresholdNonGbrDl_step1}
	
Set loadBasedBlockThreshold of ENDC
    [Arguments]    ${parameters}
    Delta Commission Parameters    ${parameters}
    cells should be onair

check nrStatus
    [Arguments]    ${Object}
    ${object_list}    Create List    ${Object}
    Object Should Exist    params=${object_list}    scf=None    timeout=300

Enable Blind EN-DC and set eNB1 Cell1 without ENDC
    Set ue parameters before ENDC setup
    Delta Commission Parameters    ${Enable_blind_EN-DC}
    cells should be onair
    Delta Commission Parameters    ${LNRELGNBCELL_delete}
    cells should be onair
    Delta Commission Parameters    ${eNB1_cell1_without_ENDC}
    cells should be onair
    check nrStatus    Object=LNBTS-1/LNCEL-1/LNRELGNBCELL-1:nrStatus=unavailable

Enable_Dynamic_EN-DC and Set Cell1 without ENDC
    Set ue parameters before ENDC setup
    Delta Commission Parameters    ${Enable_Dynamic_EN-DC}
    cells should be onair
    Delta Commission Parameters    ${LNRELGNBCELL_delete}
    cells should be onair
    Delta Commission Parameters    ${cell1_without_ENDC}
    cells should be onair
    check nrStatus    Object=LNBTS-1/LNCEL-1/LNRELGNBCELL-1:nrStatus=unavailable

Verify 4 UEs attach without ENDC then do intra HO successful but 1 UE block ENDC other 3 successful
    Stop Capture BTS UdpLogs
    Start To Capture BTS UdpLogs    rest1
    Clear Counter Files
    UE attach to eNB1 cell1 without ENDC    start_ue=1    end_ue=6    bearer_id=1
    UE Intra X2 HO from eNB1 cell1 to eNB1 cell2    start_ue=1    end_ue=6
    Check Counters  ${A-c_01_01_step1}

Verify eight UEs attach without ENDC then do intra HO successful but three UEs block ENDC other five successful
    Stop Capture BTS UdpLogs
    Start To Capture BTS UdpLogs    rest2
    Clear Counter Files
    UE attach to eNB1 cell1 without ENDC    start_ue=2    end_ue=9
    UE Intra X2 HO from eNB1 cell1 to eNB1 cell2    start_ue=2    end_ue=9
    Check Counters  ${A-c_01_01_step2}

UE attach
    [Arguments]    ${ue_id}=1    ${enb_id}=1    ${cell_id}=1
    ${V_1}  catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} enb=${enb_id} cell=${cell_id}
    Execute Uex Command    ${V_1}

UE attach to eNB1 cell1 without ENDC
    [Arguments]    ${start_ue}=1    ${end_ue}=1    ${bearer_id}=1
    ${stop_ue}=    Evaluate    ${end_ue}+${1}
    FOR    ${i}    IN RANGE    ${start_ue}    ${stop_ue}
        Expect Message Will Not Occur
        ...    ENB_1:X2AP_SgNBAdditionRequest
        ...    alias=UE_attach_without_ENDC_UE${i}    overall_timeout=60
        UE attach    ue_id=${i}    enb_id=1    cell_id=1
        Start data traffic to add cell load    ue_id=${i}    bearer_id=${bearer_id}
		Flow Not Occurred For Message    alias=UE_attach_without_ENDC_UE${i}
    END

UE detach then current blocked EN-DC UE number change to one
    [Arguments]    ${start_ue}=1    ${end_ue}=1
    ${stop_ue}=    Evaluate    ${end_ue}+${1}
    FOR    ${i}    IN RANGE    ${start_ue}    ${stop_ue}
        Execute Uex Command    ue_detach id=${i}
    END

Trigger Intra-eNB Inter-Cell handover
    [Arguments]    ${ue_id}=1    ${enb_id}=1    ${cell_id}=1
    ${ret}    Execute Uex Command    ue_ho id=${ue_id} enb=${enb_id} cell=${cell_id} 
 
UE Intra X2 HO from eNB1 cell1 to eNB1 cell2
    [Arguments]    ${start_ue}=1    ${end_ue}=1    ${enb_id}=1    ${cell_id}=2
    ${stop_ue}=    Evaluate    ${end_ue}+${1}
    FOR    ${i}    IN RANGE    ${start_ue}    ${stop_ue}
        Expect Message Flow
        ...    ENB_1:X2AP_SgNBAdditionRequest (qCI eq 6)
        ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
        ...    UE_${i}:RRC_RRCConnectionReconfiguration
        ...    UE_${i}:RRC_RRCConnectionReconfigurationComplete
        ...    ENB_1:X2AP_SgNBReconfigurationComplete
        ...    ENB_1:X2AP_SNStatusTransfer
        ...    MME_1:S1AP_E-RABModificationIndication
        ...    MME_1:S1AP_E-RABModificationConfirm
        ...    alias=UE_HO_UE${i}    overall_timeout=60
        Trigger Intra-eNB Inter-Cell handover    ue_id=${i}    enb_id=${enb_id}    cell_id=${cell_id}
        Run Keyword And Ignore Error   Flow Occurred As Expected    alias=UE_HO_UE${i}
    END

Start data traffic to add cell load
    [Arguments]    ${ue_id}=1    ${bearer_id}=1    ${qci_id}=6    ${throughput}=120    ${retvalue}=${EMPTY}
    Execute Uex Command    bearer_add ue=${ue_id} qci=1 mbr_ul=31 mbr_dl=31 gbr_dl=31 gbr_ul=31
    Execute Uex Command    bearer_add ue=${ue_id} qci=5 mbr_ul=31 mbr_dl=31 gbr_dl=31 gbr_ul=31
    Execute Uex Command    trf_data_start qci=${qci_id} ue=${ue_id} Mbps=${throughput} dir=dl protocol=udp trf_id=1
    Execute Egate Command    ue_disp id=${ue_id}
	Execute Uex Command    get_ue_stats id=${ue_id} type=dl_mac scell=0..7 unit=Mbps
