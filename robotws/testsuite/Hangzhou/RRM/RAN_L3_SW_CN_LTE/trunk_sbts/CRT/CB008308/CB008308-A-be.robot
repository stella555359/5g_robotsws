*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags		  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4P
...               team-DEVHZ5_SG4    release-SBTS22R2    owner-kexin.zhou
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{LTE4088}
...    @{LTE4193}
...    @{CA}
...    @{NRDCPR}
...    @{NRDCDPR}
...    @{PARAMS_FOR_CELL_CONFIG}
...    @{CB008308}
...    @{LTE1170}
...    @{LBHO}
...    LNCEL:actFlowCtrlEnh=true
...    LNBTS:actMultBearers=true
...    LNCEL:tac=33
...    LNBTS:mcc=262
...    LNBTS:mnc=3
...    LNBTS:mncLength=2
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNBTS/LNADJGNB-1:adjGnbId=7
...    LNBTS/LNADJGNB-1:adjGnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNBTS/LNADJGNB-2:administrativeState=unlocked
...    LNBTS/LNADJGNB-2:cPlaneIpAddr=10.0.1.12
...    LNBTS/LNADJGNB-2:adjGnbId=8
...    LNBTS/LNADJGNB-2:adjGnbIdLength=22
...    LNCEL/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-2:nrCellId=132354
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
...    LNCEL:moPrMappingList:lteNrDualConnectSupport=all|moPrId=1
...    LNCEL:moPrMappingList:spid=11|moPrId=1
...    LNCEL:moPrMappingList:spidLast=20|moPrId=1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference

@{CB008308}
...    LNBTS/MODPR-0:enDcBlockingAllowed=allowed
...    LNBTS/MODPR-0:caBlockingAllowed=forbidden
...    LNBTS/MOPR-1:enDcBlockingAllowed=forbidden
...    LNCEL:actEnDcBlocking=true
...    LNCEL:loadBasedBlockThreshold:blockNumRrcConn=10
...    LNCEL:loadBasedBlockThreshold:blockThresholdGbrDl=60
...    LNCEL:loadBasedBlockThreshold:blockThresholdNonGbrDl=15
...    LNCEL:loadBasedBlockThreshold:blockThresholdPdcch=80
...    LNCEL:loadSettings:cellCapClass=100
...    LNCEL:loadSettings:mlbEicicOperMode=allUes
...    LNCEL:loadSettings:targetLoadGbrDl=60
...    LNCEL:loadSettings:targetLoadNonGbrDl=2
...    LNCEL:loadSettings:targetLoadPdcch=80
...    LNCEL:loadSettings:ulCacIgnore=false
...    LNCEL:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL:loadSettings:ulStaticCac=100
...    LNCEL/LNCEL_FDD-0:maxNumActUE=95
#NONGBR Weight
...    LNCEL:loadSettings:nomNumPrbNonGbr=0.2
...    LNBTS:qciTab8:schedulWeight=85
#set GBR QCI
...    LNBTS:qciTab5:schedulType=SIGNALLING
...    LNBTS:qciTab5:lcgid=0

@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19500
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL/LNCEL_FDD-0:ulChBw=20 MHz
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnEarfcn=1400
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnChBw=20 MHz


@{NRDCDPR}
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:mrWaitTimer=2000
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:tPeriodicPhr=1000sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=1000sf
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=1|method=coverageAndBufferBased
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=2|method=coverageBased
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN531000}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:nrCarPrio=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:priority=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1NrMaxNumBeams=32
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1NrBeamReportQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1NrBeamThreshRsrp=90

@{NRDCPR}
...    LNBTS/NRMEASPR-0:cellList=1,2
...    LNBTS/NRMEASPR-0:mrWaitTimer=2000
...    LNBTS/NRMEASPR-0:measGapEnabledNRMeas=FR1AndFR2
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:lcrId=1|method=coverageAndBufferBased
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:lcrId=2|method=coverageBased
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1ThresholdNrRsrp=80
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrp=128ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrq=128ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:carrierFreqNrCell=${NRARFCN531000}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:freqBandIndicatorNrL:priority=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrp=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrq=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:nrCarPrio=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbOffset=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:nrPciNbrRelAddHyst=998
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:nrPciNbrRelAddThresh=10
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1NrMaxNumBeams=32
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1NrBeamReportQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1NrBeamThreshRsrp=127

@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=8000
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:actTransmittedBelowGap=false
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNCEL:defaultLnRelGnbCellId=1
...    LNBTS:actIfHo=enabled
...    LNBTS:actSelMobPrf=true
...    LNBTS/MODPR-0:autoAdapt=false
...    LNBTS:actMultBearers=true
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNCEL/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL/LNCEL_FDD-0:maxNumActDrb=265
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1700
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=1700
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1700
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19700

@{LTE4193}
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:endcSchedWeightBoostDl=4
...    LNBTS:endcSchedWeightBoostUl=4
...    LNBTS:nrRestrictionOverride=disabled
...    LNBTS/LBPUCCHRPR-1:countdownPucchCompr=60min
...    LNBTS/LBPUCCHRPR-1:countdownPucchExp=1min
...    LNBTS/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNBTS/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
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

@{CA}
...    LNBTS:actDLCAggr=true
...    LNBTS:actAdvScellMeas=true
...    LNBTS:actAdvStepwiseScellAdd=off
...    LNBTS:actFlexScellSelect=true
...    LNCEL:actScellConfigForHiDemand=true
...    LNBTS:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNCEL:maxNumScells=3
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:caPoolId=1
...    LNCEL-1:dlScellConfigLevel=20
...    LNCEL-1/CAPR-1:earfcnDL=1500
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNBTS/CADPR-0:maxNumMimoLayerFdd=16
...    LNBTS:actFlexCaMgmt=true
...    LNCEL:actModulationSchemeDl=64QAM
...    LNCEL-2:dlCaMinPcellCqi=0
...    LNCEL-2:ulCaMinPcellSinr=0
...    LNCEL-2:dlCaMinPcellCqiQci1=0
...    LNCEL-2:ulCaMinPcellSinrQci1=0
...    LNCEL-2:dlScellConfigLevel=20
...    LNCEL-2/CAPR-1:earfcnDL=1500
...    LNCEL-2/CAREL-1:lnBtsId=1
...    LNCEL-2/CAREL-1:lcrId=1
...    LNCEL-2/CAREL-1:maxNumOfSuppMimoLayer=4-layer

####relation config####
...    LNBTS/LNBTS_FDD-0:numTxWithHighNonGbr=200
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS:actAmbrModCaTrigger=false


@{LTE1170}
...    LNBTS/MODPR-0:freqLayListLte=1700
...    LNBTS/MOPR-1:freqLayListLte=1
...    LNCEL:actInterFreqLB=true
...    LNCEL:actServRlqInterFreqLB=false
...    LNCEL:iFLBA4ActLim=20
...    LNCEL:iFLBLoadThresholds:iFLBBearCheckTimer=0
...    LNCEL:iFLBLoadThresholds:iFLBHighLoadGBRDL=60
...    LNCEL:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=10
...    LNCEL:iFLBLoadThresholds:iFLBHighLoadPdcch=80
...    LNCEL:iFLBLoadThresholds:iFLBRetryTimer=60
...    LNCEL:iFLBLoadThresholds:maxNumAmleNeigh=16
...    LNCEL:intraFreqLbLoadThresholds:hysteresisLoadDlGbr=1
...    LNCEL:intraFreqLbLoadThresholds:hysteresisLoadDlNonGbr=1
...    LNCEL:intraFreqLbLoadThresholds:hysteresisLoadPdcch=1
...    LNCEL:intraFreqLbLoadThresholds:highLoadGbrDl=80
...    LNCEL:intraFreqLbLoadThresholds:highLoadNonGbrDl=80
...    LNCEL:intraFreqLbLoadThresholds:highLoadPdcch=80
...    LNCEL:scellFastSchedulingSelect=normal

@{LBHO}
...    LNBTS/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNBTS/LNADJ-1:cPlaneIpAddr=10.0.1.3
...    LNBTS/ANRPRL-1:targetCarrierFreq=1700
...    LNCEL/LNREL-1:ecgiAdjEnbId=42
...    LNCEL/LNREL-1:ecgiLcrId=1
...    LNCEL/LNREL-1:handoverAllowed=allowed
...    LNCEL/LNREL-1:removeAllowed=false
...    LNCEL/LNREL-1:cellIndOffNeigh=0dB

@{Dynamic_method}
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageBased|lcrId=1
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased|lcrId=2
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased|lcrId=1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased|lcrId=2

#cell load condition blockNumRrcConn*(maxNumActUE+aPucchMinNumRrcNoDrb)/100
@{CHANGE_CELL_LOAD_CONDITION}
...    LNCEL:loadBasedBlockThreshold:blockNumRrcConn=10
...    LNCEL:loadBasedBlockThreshold:blockThresholdGbrDl=99
...    LNCEL:loadBasedBlockThreshold:blockThresholdNonGbrDl=99
...    LNCEL:loadBasedBlockThreshold:blockThresholdPdcch=99

@{PARAMS_IN_EMIL}    0x2381    0x2382    0x74EB    0x74F2    0x74F3    0x74F4    0x2495
...               0x7560    0x7561    0x7562    0x7563    0x759C    0x759D    0x75DC
...               0x75DD    0x75DE    0x75DF    0x75E7    0x75E8    0x7539    0x753A

#UE capability
${ue_eutra_capabilities_Blind}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E80000000740000
...    0003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000
...    007400000003A00000001D00000001BFBFFEC800801C364000000017BA000000080952A0E27004000008200010C000220000450
...    0008C00011C0002400004900009400012C0002600004D0000A0000144000290000530000A80001540002B0000570000B0000164
...    0002D00005B0000BA0001780003680007F001D3A00000001D00000000E800000007400000003A00000001D00000000E80000000
...    7400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E
...    800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D0
...    0000000A080000079D000000000000000000000000000000000000000000000000000000000001011C421298061CFFFFFFFFFFF
...    FFFFA15000300452E00004000020961400019E000000C00000040

${ue_eutra_capabilities_Dynamic}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A0000
...    0001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000000074000000
...    03A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007
...    400000003A00000001D00000001BFBFFEC800801C364000000017BA000000080952A0E27004000008200010C0002200004500008
...    C00011C0002400004900009400012C0002600004D0000A0000144000290000530000A80001540002B0000570000B00001640002D
...    00005B0000BA0001780003680007F001D3A00000001D00000000E800000007400000003A00000001D00000000E80000000740000
...    0003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000000
...    07400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000A
...    080000079D000000000000000000000000000000000000000000000000000000000001011C421298061CFFFFFFFFFFFFFFFA1500
...    0300452E00004000020961400019E000000C00000040

${ue_eutra_nr_capabilities}  0108040160401C06000000000400020101002004

${ue_nr_capabilities}  0000000001010000000060100581007018000000

#PM counter

${ENDC_BLOCK_RRC_CELL}  M8080C152
${ENDC_BLOCK_CELL_LOAD}    M8080C151
${ENDC_BLOCK_INC_HO_CELL_LOAD}  M8080C153
${ENDC_BLOCK_INC_HO_RRC_CELL}  M8080C154
${SGNB_CHANGE_RQRD}    M8080C17
${SGNB_ADD_CHANGE_COMPL_SUCC}    M8080C20

@{PM_A-b_01_03}
...    LNCEL-1:${ENDC_BLOCK_RRC_CELL}=0
...    LNCEL-2:${ENDC_BLOCK_RRC_CELL}=0
...    LNCEL-1:${ENDC_BLOCK_CELL_LOAD}=3
...    LNCEL-2:${ENDC_BLOCK_CELL_LOAD}=3
...    LNCEL-1:${ENDC_BLOCK_INC_HO_RRC_CELL}=0
...    LNCEL-1:${ENDC_BLOCK_INC_HO_CELL_LOAD}=0
...    LNCEL-2:${ENDC_BLOCK_INC_HO_RRC_CELL}=0
...    LNCEL-2:${ENDC_BLOCK_INC_HO_CELL_LOAD}=0

*** Test Cases ***
CB008308-A-b_01_03_Block_EN-DC_Setup_due_to_Cell_OverFlow_Dynamic_EN-DC_setup
    [Documentation]
    ...    UE1-2 attach to eNB1 cell1 and cell2 trigger Dynamic ENDC successful
    ...    add cell1 2 load
    ...    UE1-2 release ENDC and trigger Dynamic ENDC blocked cause CB008308
    ...    UE3-4 attach to eNB1 cell1 2 trigger Dynamic ENDC blocked cause CB008308
    ...    Change cell1&2 dynamic method
    ...    UE5-6 attach to eNB1 cell1 2 trigger Dynamic ENDC blocked cause CB008308
    ...    change cell load condition - add capacity load
    ...    UE3-6 attach to eNB1 cell1 and cell2 trigger ENDC successful
    [Tags]
    Attach UEs to ENB to trigger Dynamic_EN-DC successful  UE_ID1=1  UE_ID2=2  CELL_ID1=1  CELL_ID2=2
    Start data traffic to add cell load
    UE release Dynamic ENDC and trigger ENDC again  UE_ID1=1  UE_ID2=2  CELL_ID1=1  CELL_ID2=2
    Attach UEs to ENB to trigger Dynamic_EN-DC blocked  UE_ID1=3  UE_ID2=4  CELL_ID1=1  CELL_ID2=2
    Change Cell Dynamic method
    Attach UEs to ENB to trigger Dynamic_EN-DC blocked  UE_ID1=6  UE_ID2=5  CELL_ID1=2  CELL_ID2=1
    Change Cell Load Condition and trigger ENDC again
    Check Rtpm Counters  ${PM_A-b_01_03}


*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Alias for multi UEs
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create Enb Alias    GNB_8    enb_id=8    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
    Set Ue Parameters Before Attach
    Set gNB parameters for ENDC Setup

Create UE Alias for multi UEs
    FOR    ${ue_id}    IN RANGE    1    9
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END

Set Ue Parameters Before Attach
    Execute Uex Command    ue_param id=1-8 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=1-8 nr_supported_bands=7,8
    Execute Uex Command    ue_param id=1-8 nr_supported_bands=41
    Execute Egate Command    ue_mme_param id=7-8 spid=11

Set gNB parameters for ENDC Setup
    Execute Egate Command    trace_sim enb=7 protocol=x2,s1 on
    Execute Egate Command    trace_sim enb=8 protocol=x2,s1 on
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=1:1
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=8 selected_band_combination_nr=1:1
    Execute Egate Command    gnb_endc_param id=8 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=8 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=8 include_reestablish_pdcp=on
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command    enb_timer T_DC_Overall=5000ms
    Execute Egate Command    enb_x2_link_up enb=7 target=1    X2 link with eNB-1 is activated already
    Execute Egate Command    enb_x2_link_up enb=8 target=1    X2 link with eNB-1 is activated already

Modify Yaml
    ${GNB7_CELL1}    catenate
    ...    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501',
    ...    suggested_band: 7, nr_arfcn: '507000:531000'}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB7_CELL1}
    ${GNB8_CELL1}    catenate
    ...    - {id: 81, technology: nr , tac: 33, pci: '1:0', nrci: '0x0000502',
    ...    suggested_band: 7, nr_arfcn: '507000:531000'}
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
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 6, pdn: 1}
    ...     - {qci: 5, preprovisioned: on, filter: 2, precedence: 2, pdn: 1}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, preprovisioned: on, filter: 3, precedence: 3, pdn: 1}
    FOR    ${ue_id}     IN RANGE    1    7
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_2    rohc: '16'
    END
    Update Yaml    UEs/UE_sets/7    bearer: bearer_set_3    rohc: '16'
    Update Yaml    UEs/UE_sets/8    bearer: bearer_set_3    rohc: '16'

Perform Steps After Onair
    @{LNADJGNB7}    Create List    LNADJGNB:cPlaneIpAddr=10.0.1.11    LNADJGNB:x2ToGnbLinkStatus=available
    Object Should Exist    ${LNADJGNB7}
    @{LNADJGNB8}    Create List    LNADJGNB:cPlaneIpAddr=10.0.1.12    LNADJGNB:x2ToGnbLinkStatus=available
    Object Should Exist    ${LNADJGNB8}

Attach UEs to ENB to trigger Dynamic_EN-DC successful
    [Arguments]     ${UE_ID1}   ${UE_ID2}   ${CELL_ID1}   ${CELL_ID2}
    UE Attach to eNB Cell_Dynamic_CB   ${UE_ID1}   ${CELL_ID1}
    UE Attach to eNB Cell_Dynamic_C   ${UE_ID2}   ${CELL_ID2}

UE Attach to eNB Cell_Dynamic_CB
    [Arguments]     ${UE_ID1}    ${CELL_ID1}
    UE Attach to eNB Cell_Dynamic Not Trigger ENDC  ${UE_ID1}  ${CELL_ID1}
    Trigger Dynamic ENDC_CB    ${UE_ID1}


UE Attach to eNB Cell_Dynamic_C
    [Arguments]     ${UE_ID1}    ${CELL_ID1}
    UE Attach to eNB Cell_Dynamic Not Trigger ENDC  ${UE_ID1}  ${CELL_ID1}
    Trigger Dynamic ENDC_C    ${UE_ID1}

Start data traffic to add cell load
    Start Rtpm Counter
    UE Attach to eNB Cell_Blind  7  1
    UE Attach to eNB Cell_Blind  8  2
    multi data traffic

multi data traffic
    Execute Uex Command    trf_data_start ue=7-8 dir=dl Mbps=120 protocol=udp trf_id=1
    Execute Uex Command    trf_data_start ue=7-8 dir=dl Mbps=120 protocol=udp trf_id=2
    Execute Uex Command    trf_data_start ue=7-8 dir=dl Mbps=120 protocol=udp trf_id=3
    Execute Uex Command    trf_data_start ue=7-8 dir=dl Mbps=120 protocol=udp trf_id=4
    Execute Uex Command    trf_data_start ue=7-8 dir=dl Mbps=120 protocol=udp trf_id=5
    Execute Uex Command    trf_data_start ue=7-8 dir=dl Mbps=120 protocol=udp trf_id=6

UE release Dynamic ENDC and trigger ENDC again
    [Arguments]    ${UE_ID1}    ${UE_ID2}   ${CELL_ID1}   ${CELL_ID2}
    gNB release ENDC    ${UE_ID1}
    Trigger Dynamic ENDC_CB_Block    ${UE_ID1}
    gNB release ENDC    ${UE_ID2}
    Trigger Dynamic ENDC_C_Block    ${UE_ID2}


gNB release ENDC
    [Arguments]    ${UE_ID1}
    Expect Message Flow
    ...    GNB_7:X2AP_SgNBReleaseRequired
    ...    ENB_1:X2AP_SgNBReleaseConfirm
    ...    MME_1:S1AP_E-RABModificationConfirm (E-RABModifyListBearerModConf contains (e-RAB-ID eq 5))
    ...    alias=UE_ENDC_released    overall_timeout=30
    Execute Egate Command    enb_ue_dc_release ue=${UE_ID1} by=gnb cause=RN_sCG_Mobility
    ...  pass_regexp=UEContextRelease
    Flow Occurred As Expected    alias=UE_ENDC_released

Attach UEs to ENB to trigger Dynamic_EN-DC blocked
    [Arguments]     ${UE_ID1}   ${UE_ID2}   ${CELL_ID1}   ${CELL_ID2}
    UE Attach to eNB Cell_Dynamic_CB_block   ${UE_ID1}   ${CELL_ID1}
    UE Attach to eNB Cell_Dynamic_C_block   ${UE_ID2}   ${CELL_ID2}


UE Attach to eNB Cell_Blind
    [Arguments]     ${UE_ID1}    ${CELL_ID1}
    ${Blind_UE}    catenate
    ...    ue_attach id=${UE_ID1} cell=${CELL_ID1}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities_Blind}
    ...    ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    Execute Uex Command    ${Blind_UE}

UE Attach to eNB Cell_Dynamic_CB_block
    [Arguments]     ${UE_ID1}    ${CELL_ID1}
    UE Attach to eNB Cell_Dynamic Not Trigger ENDC  ${UE_ID1}  ${CELL_ID1}
    Trigger Dynamic ENDC_CB_Block    ${UE_ID1}

UE Attach to eNB Cell_Dynamic_C_block
    [Arguments]     ${UE_ID1}    ${CELL_ID1}
    UE Attach to eNB Cell_Dynamic Not Trigger ENDC  ${UE_ID1}  ${CELL_ID1}
    Trigger Dynamic ENDC_C_Block    ${UE_ID1}


UE Attach to eNB Cell_Dynamic Not Trigger ENDC
    [Arguments]     ${UE_ID1}    ${CELL_ID1}
    ${Dynamic_UE}    catenate
    ...    ue_attach id=${UE_ID1} cell=${CELL_ID1}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities_Dynamic}
    ...    ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    Execute Uex Command    ${Dynamic_UE}

Change Cell Dynamic Method
    Delta Commission Parameters And Wait Cells Onair   ${Dynamic_method}

Change Cell Load Condition and trigger ENDC again
    [Arguments]
    Delta Commission Parameters And Wait Cells Onair  ${CHANGE_CELL_LOAD_CONDITION}
    Trigger Dynamic ENDC_CB   1
    Trigger Dynamic ENDC_CB   3
    Trigger Dynamic ENDC_C  2
    Trigger Dynamic ENDC_C  4
    Trigger Dynamic ENDC_CB  6
    Trigger Dynamic ENDC_C   5

Trigger Dynamic ENDC_CB
    [Arguments]    ${UE_ID1}
    Expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest (E-RABs-ToBeAdded-SgNBAddReqList contains (qCI eq 6))
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    MME_1:S1AP_E-RABModificationConfirm (E-RABModifyListBearerModConf contains (e-RAB-ID eq 5))
    ...    alias=ENDC_setup    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${UE_ID1} event=B1_NR phycell_id=1 nrsrp=60
    Execute Uex Command    trf_data_start ue=${UE_ID1} dir=dl Mbps=120 protocol=udp trf_id=1
    Flow Occurred As Expected    alias=ENDC_setup
    Execute Uex Command    trf_data_stop ue=${UE_ID1}

Trigger Dynamic ENDC_CB_Block
    [Arguments]    ${UE_ID1}
    Expect Message Will Not Occur
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    alias=ENDC_setup    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${UE_ID1} event=B1_NR phycell_id=1 nrsrp=60
    Execute Uex Command    trf_data_start ue=${UE_ID1} dir=dl Mbps=120 protocol=udp trf_id=1
    Flow Not Occurred For Message    alias=ENDC_setup
    Execute Uex Command    trf_data_stop ue=${UE_ID1}

Trigger Dynamic ENDC_C
    [Arguments]    ${UE_ID1}
    Expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest (E-RABs-ToBeAdded-SgNBAddReqList contains (qCI eq 6))
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    MME_1:S1AP_E-RABModificationConfirm (E-RABModifyListBearerModConf contains (e-RAB-ID eq 5))
    ...    alias=ENDC_setup    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${UE_ID1} event=B1_NR phycell_id=1 nrsrp=60
    Flow Occurred As Expected    alias=ENDC_setup

Trigger Dynamic ENDC_C_Block
    [Arguments]    ${UE_ID1}
    Expect Message Will Not Occur
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    alias=ENDC_setup    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${UE_ID1} event=B1_NR phycell_id=1 nrsrp=60
    Flow Not Occurred For Message    alias=ENDC_setup