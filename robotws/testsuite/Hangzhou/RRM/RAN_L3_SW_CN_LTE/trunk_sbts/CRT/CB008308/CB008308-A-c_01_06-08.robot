*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_2MAPO_2CUS
...               team-SG4    release-SBTS22R1    owner-yang.yinhu
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${UTE_WIRESHARK_FLAG}    ${False}

@{PARAMS_IN_VENDOR}
...    LNBTS:reportTimerEndcA5=5000ms

@{PARAMS_IN_SCF}
...    @{x2_link_with_NR}
...    @{x2_link_with_ENB2}
...    @{LTE4088_ENDC}
...    @{LTE4193_Dynamic_ENDC}
...    @{LTE4281_Intra-eNB_HO_ENDC}
...    @{CB008308}

@{PARAMS_IN_SCF_ENB2}
...    @{x2_link_with_NR_ENB2}
...    @{LTE4088_ENDC_ENB2}
...    @{LTE4193_Dynamic_ENDC_ENB2}
...    @{LTE4281_Intra-eNB_HO_ENDC_ENB2}
...    @{CB008308_ENB2}

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

@{x2_link_with_ENB2}
...    LNBTS/LNADJ-2:adjEnbId=2
...    LNBTS/LNADJ-2:cPlaneIpAddr=10.0.1.4
...    LNBTS/LNADJ-2:cPlaneIpAddrCtrl=oamControlled
...    LNBTS/LNADJ-2:rlfBasedRCRsupported=false
...    LNBTS/LNADJ-2:plmnId:mcc=262
...    LNBTS/LNADJ-2:plmnId:mnc=3
...    LNBTS/LNADJ-2:plmnId:mncLength=2

@{x2_link_with_NR_ENB2}
...    LNBTS-2/LNADJGNB-1:administrativeState=unlocked
...    LNBTS-2/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNBTS-2/LNADJGNB-2:administrativeState=unlocked
...    LNBTS-2/LNADJGNB-2:cPlaneIpAddr=10.0.1.12
...    LNCEL/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-2:nrCellId=132354
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
...    LNBTS-2/LNADJGNB-1:adjGnbId=7
...    LNBTS-2/LNADJGNB-1:adjGnbIdLength=22
...    LNBTS-2/LNADJGNB-2:adjGnbId=8
...    LNBTS-2/LNADJGNB-2:adjGnbIdLength=22

@{LTE4088_ENDC}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:actTransmittedBelowGap=false
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:tLteNrDualConnectPrep=5000
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

@{LTE4088_ENDC_ENB2}
...    LNBTS-2:actLteNrDualConnectivity=true
...    LNBTS-2:actTransmittedBelowGap=false
...    LNBTS-2:tS1eRABModInd=2000
...    LNBTS-2:tLteNrDualConnectPrep=5000
...    LNBTS-2:qciTab6:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS-2:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNCEL-2:defaultLnRelGnbCellId=1
...    LNCEL-3:defaultLnRelGnbCellId=1
...    LNBTS-2:actIfHo=enabled
...    LNBTS-2:actSelMobPrf=false
...    LNBTS-2/MODPR-0:autoAdapt=false
...    LNBTS-2:actMultBearers=true
...    LNBTS-2/LNBTS_FDD-0:actConvVoice=true
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

@{LTE4193_Dynamic_ENDC_ENB2}
...    LNBTS-2:actDynTrigLteNrDualConnectivity=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNBTS-2:actEndcSpidFwd=false
...    LNBTS-2:endcSchedWeightBoostDl=4
...    LNBTS-2:endcSchedWeightBoostUl=4
...    LNBTS-2:nrRestrictionOverride=disabled
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
...    LNBTS-2/LBPUCCHRPR-1:countdownPucchCompr=60min
...    LNBTS-2/LBPUCCHRPR-1:countdownPucchExp=1min
...    LNBTS-2/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNBTS-2/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...    LNBTS-2/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS-2/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS-2/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS-2/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS-2/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS-2/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS-2/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN531000}
...    LNBTS-2/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS-2/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS-2/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS-2/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS-2/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...    LNBTS-2/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS-2/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS-2/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS-2/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc1
...    LNBTS-2/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS-2/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS-2/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS-2/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS-2/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS-2/NRDCDPR-0:tProhibitPhr=0sf

@{LTE4281_Intra-eNB_HO_ENDC}
...    LNBTS:enableBwCombCheck=true
...    LNBTS:actHoWoSnChg=intraEnbAndX2HoEnabled
...    LNBTS:sCellActivationCyclePeriod=2s
...    LNCEL-1/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNCEL-2/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-2/LNHOIF-1:thresholdRsrqEndcFilt=-120

@{LTE4281_Intra-eNB_HO_ENDC_ENB2}
...    LNBTS-2:enableBwCombCheck=true
...    LNBTS-2:actHoWoSnChg=intraEnbAndX2HoEnabled
...    LNBTS-2:sCellActivationCyclePeriod=2s
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
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrc=270

@{CB008308_ENB2}
...    LNBTS-2/MODPR-0:enDcBlockingAllowed=allowed
...    LNBTS-2/MODPR-0:caBlockingAllowed=forbidden
...    LNBTS-2/MOPR-1:enDcBlockingAllowed=allowed
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
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrc=270

@{Enable_Dynamic_EN-DC}
...    LNBTS:actDynTrigLteNrDualConnectivity=true

@{Enable_Dynamic_EN-DC_ENB2}
...    LNBTS-2:actDynTrigLteNrDualConnectivity=true
...    LNBTS-2:actLteNrDualConnectivity=true

${PM_SPEED_UP_FLAG}    ${True}

${ue_nr_capabilities}    0000000001010000000060100581007018000000
${ue_eutra_capabilities}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFEC800801C364000000017BA000000080952A0E2740400000820001080002180004400008A000118000238000480000920001280002580004
...    C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A0000000141000000F3A0000000000000000000000000000000000000000000000000000000000020238
...    8425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C2800033C000001800000080
${ue_eutra_nr_capabilities}    0108040160401C06000000000400020101002004

@{A-c_01_08_blockNumRrcConn_step1}
...    LNBTS/LNCEL-1:actEnDcBlocking=false
...    LNBTS/LNCEL-2:actEnDcBlocking=true
...    LNBTS/LNCEL-3:actEnDcBlocking=false
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockNumRrcConn=3    # 3*(95+5)/100=3,allow 2 UEs not block ENDC
...    LNCEL/LNCEL_FDD-0:maxNumActUE=95
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdGbrDl=80
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdNonGbrDl=95
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdPdcch=80
...    LNBTS:qciTab5:schedulType=NON-GBR
...    LNBTS:qciTab5:lcgid=2
...    MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1:sbsTotal=8000

@{A-c_01_08_blockNumRrcConn_step2}
...    LNBTS/LNCEL-1:actEnDcBlocking=false
...    LNBTS/LNCEL-2:actEnDcBlocking=true
...    LNBTS/LNCEL-3:actEnDcBlocking=false
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockNumRrcConn=4    # 4*(95+5)/100=4,allow 3 UEs not block ENDC
...    LNCEL/LNCEL_FDD-0:maxNumActUE=95
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdGbrDl=80
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdNonGbrDl=95
...    LNBTS/LNCEL-2:loadBasedBlockThreshold:blockThresholdPdcch=80
...    LNBTS:qciTab5:schedulType=NON-GBR
...    LNBTS:qciTab5:lcgid=2

${ENDC_BLOCK_CELL_LOAD_M8080C151}    M8080C151
${ENDC_BLOCK_RRC_CELL_M8080C152}    M8080C152
${ENDC_BLOCK_INC_HO_CELL_LOAD_M8080C153}    M8080C153
${ENDC_BLOCK_INC_HO_RRC_CELL_M8080C154}    M8080C154

@{A-c_01_08_step1}
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_CELL_LOAD_M8080C151}=0
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_RRC_CELL_M8080C152}=0
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_INC_HO_CELL_LOAD_M8080C153}=0
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_INC_HO_RRC_CELL_M8080C154}=2

@{A-c_01_08_step2}
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_CELL_LOAD_M8080C151}=0
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_RRC_CELL_M8080C152}=0
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_INC_HO_CELL_LOAD_M8080C153}=0
...    LNCEL-2:LTE_X2_gNB_per_LNCEL:${ENDC_BLOCK_INC_HO_RRC_CELL_M8080C154}=1

*** Test Cases ***
CB008308-A-c_01_08 Take Back Dynamic EN-DC due to Cell Load Overflow during inter-eNB X2 HO
    [Documentation]
    ...    Procedure: inter-eNB X2 HO with ENDC, HO from ENB2 Cell1 to ENB1 Cell2
    ...    Threshold use NumRrcConn, step1 HO 4 UEs take back ENDC 2, counter 2.
    ...    Threshold use NumRrcConn, step2 HO 3 UEs take back ENDC 1, counter 1.
    [Tags]
    Enable_Dynamic_EN-DC and set ENB1 and ENB2 with ENDC
    Set loadBasedBlockThreshold of ENDC    ${A-c_01_08_blockNumRrcConn_step1}
    Verify four UEs attach with ENDC then do inter HO successful but two UEs Take Back Dynamic ENDC other two successful
    UE detach then current blocked EN-DC UE number change to one    start_ue=2    end_ue=4
    Set loadBasedBlockThreshold of ENDC    ${A-c_01_08_blockNumRrcConn_step2}
    Verify three UEs attach with ENDC then do inter HO successful but one UEs Take Back Dynamic ENDC other two successful

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup 2CUS Env    tl_type=3CELLs_FDD    tl_type_enb2=3CELLs_FDD
    Set ue parameters before ENDC setup
    Create Alias

Set ue parameters before ENDC setup
    execute uex command    ue_param id=1-13 dual_conn=eutra_nr pdcp_sn_extension=18bit
    execute uex command    ue_param id=1-13 nr_supported_bands=7
    execute egate command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    execute egate command    enb_timer T_DC_Overall=5000ms

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias    UE_4    ue_id=4    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    alias=ENB_2    enb_id=2    id_type=wts
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
    Update Yaml    UEs/UE_sets/1     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/3     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/4     bearer: bearer_set_2

Set loadBasedBlockThreshold of ENDC
    [Arguments]    ${parameters}
    Delta Commission Parameters    ${parameters}
    cells should be onair

check nrStatus
    [Arguments]    ${Object}
    ${object_list}    Create List    ${Object}
    Object Should Exist    params=${object_list}    scf=None    timeout=300

Enable_Dynamic_EN-DC and set ENB1 and ENB2 with ENDC
    Delta Commission Parameters    ${Enable_Dynamic_EN-DC}
    cells should be onair
    Delta Commission Parameters Enb2    ${Enable_Dynamic_EN-DC_ENB2}
    check nrStatus    Object=LNBTS-1/LNCEL-1/LNRELGNBCELL-1:nrStatus=available

Verify four UEs attach with ENDC then do inter HO successful but two UEs Take Back Dynamic ENDC other two successful
    Clear Counter Files
    Attach in A-c_01_08_step1
    Handover in A-c_01_08_step1
    Check Counters    ${A-c_01_08_step1}

Attach in A-c_01_08_step1
    UE attach to Real-eNB2 cell51 without ENDC    start_ue=1    end_ue=4
    Trigger Dynamic ENDC    start_ue=1    end_ue=1    X:Y=5:1
    Trigger Dynamic ENDC    start_ue=2    end_ue=2    X:Y=5:1
    Trigger Dynamic ENDC    start_ue=3    end_ue=3    X:Y=5:1
    Trigger Dynamic ENDC    start_ue=4    end_ue=4    X:Y=5:1

Handover in A-c_01_08_step1
    UE inter X2 HO to Enb1 Cell2 with ENDC    start_ue=1    end_ue=1
    UE inter X2 HO to Enb1 Cell2 with ENDC    start_ue=2    end_ue=2
    UE inter X2 HO to Enb1 Cell2 without ENDC    start_ue=3    end_ue=3
    UE inter X2 HO to Enb1 Cell2 without ENDC    start_ue=4    end_ue=4

Verify three UEs attach with ENDC then do inter HO successful but one UEs Take Back Dynamic ENDC other two successful
    Clear Counter Files
    Attach in A-c_01_08_step2
    Handover in A-c_01_08_step2
    Check Counters    ${A-c_01_08_step2}

Attach in A-c_01_08_step2
    UE attach to Real-eNB2 cell51 without ENDC    start_ue=2    end_ue=4
    Trigger Dynamic ENDC    start_ue=2    end_ue=2    X:Y=5:1
    Trigger Dynamic ENDC    start_ue=3    end_ue=3    X:Y=5:1
    Trigger Dynamic ENDC    start_ue=4    end_ue=4    X:Y=5:1

Handover in A-c_01_08_step2
    UE inter X2 HO to Enb1 Cell2 with ENDC    start_ue=2    end_ue=2
    UE inter X2 HO to Enb1 Cell2 with ENDC    start_ue=3    end_ue=3
    UE inter X2 HO to Enb1 Cell2 without ENDC    start_ue=4    end_ue=4

UE attach
    [Arguments]    ${ue_id}=1    ${enb_id}=1    ${cell_id}=1
    ${V_2}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} enb=${enb_id} cell=${cell_id}
    execute uex command    ${V_2}

UE attach to Real-eNB2 cell51 without ENDC
    [Arguments]    ${start_ue}=1    ${end_ue}=1    ${qci_id}=6
    ${stop_ue}=    Evaluate    ${end_ue}+${1}
    FOR    ${i}    IN RANGE    ${start_ue}    ${stop_ue}
        UE attach    ue_id=${i}    enb_id=2    cell_id=51
        Start data traffic to add cell load    ue_id=${i}    qci_id=${qci_id}
    END

UE detach then current blocked EN-DC UE number change to one
    [Arguments]    ${start_ue}=1    ${end_ue}=1
    ${stop_ue}=    Evaluate    ${end_ue}+${1}
    FOR    ${i}    IN RANGE    ${start_ue}    ${stop_ue}
        execute uex command    ue_detach id=${i}    #pass_regexp=UE IS OFF
    END

Trigger inter-eNB Inter-Cell handover
    [Arguments]    ${ue_id}=1    ${enb_id}=1    ${cell_id}=2
    ${ret}    execute uex command    ue_ho id=${ue_id} enb=${enb_id} cell=${cell_id} 

UE inter X2 HO to Enb1 Cell2 with ENDC
    [Arguments]    ${start_ue}=1    ${end_ue}=1    ${enb_id}=1    ${cell_id}=2
    ${stop_ue}=    Evaluate    ${end_ue}+${1}
    FOR    ${i}    IN RANGE    ${start_ue}    ${stop_ue}
        Expect Message Flow
        ...    ENB_1:X2AP_SgNBAdditionRequest (E-RABs-ToBeAdded-SgNBAddReqList contains (qCI eq 6))
        ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
        ...    alias=UE_attach_with_ENDC_UE${i}    overall_timeout=60
        Trigger inter-eNB Inter-Cell handover    ue_id=${i}    enb_id=${enb_id}    cell_id=${cell_id}
        Flow Occurred As Expected    alias=UE_attach_with_ENDC_UE${i}
    END

UE inter X2 HO to Enb1 Cell2 without ENDC
    [Arguments]    ${start_ue}=1    ${end_ue}=1    ${enb_id}=1    ${cell_id}=2
    ${stop_ue}=    Evaluate    ${end_ue}+${1}
    FOR    ${i}    IN RANGE    ${start_ue}    ${stop_ue}
        Expect Message Will Not Occur
        ...    ENB_1:X2AP_SgNBAdditionRequest
        ...    alias=UE_attach_without_ENDC_UE${i}    overall_timeout=60
        Trigger inter-eNB Inter-Cell handover    ue_id=${i}    enb_id=${enb_id}    cell_id=${cell_id}
        Flow Not Occurred For Message    alias=UE_attach_without_ENDC_UE${i}
    END

Trigger Dynamic ENDC
    [Arguments]    ${start_ue}=1    ${end_ue}=1    ${X:Y}=disable
    ${stop_ue}=    Evaluate    ${end_ue}+${1}
    FOR    ${i}    IN RANGE    ${start_ue}    ${stop_ue}
        expect message flow
        ...    ENB_2:X2AP_SgNBAdditionRequest (E-RABs-ToBeAdded-SgNBAddReqList contains (qCI eq 6))
        ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
        ...    alias=UE_attach_with_ENDC_UE${i}    overall_timeout=60
        ${ret1}=  execute uex command    ue_measurement_send id=${i} event=B1_NR phycell_id=1 nrsrp=60
        flow occurred as expected    alias=UE_attach_with_ENDC_UE${i}
    END

Start data traffic to add cell load
    [Arguments]    ${ue_id}=1    ${qci_id}=6    ${throughput}=120    ${retvalue}=${EMPTY}
    execute uex command    bearer_add ue=${ue_id} qci=1 mbr_ul=31 mbr_dl=31 gbr_dl=31 gbr_ul=31
    execute uex command    bearer_add ue=${ue_id} qci=5 mbr_ul=31 mbr_dl=31 gbr_dl=31 gbr_ul=31
    execute uex command    trf_data_start qci=${qci_id} ue=${ue_id} Mbps=${throughput} dir=dl protocol=udp trf_id=1	
    Execute Egate Command    ue_disp id=${ue_id}
