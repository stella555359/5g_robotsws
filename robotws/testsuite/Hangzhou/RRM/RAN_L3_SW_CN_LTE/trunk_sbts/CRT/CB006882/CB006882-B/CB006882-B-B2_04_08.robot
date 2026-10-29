*** Settings ***
Suite Setup       Common Suite Setup and Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4A_CUS
...               team-ETCN3    release-SBTS22R1    owner-tom.li
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  @{CA}
...  @{x2link}
...  @{LTE4088}
...  @{LTE4193}
...  @{modulation}
...  @{pcellswap}
...  @{LTE4804}
...  @{LTE4549}
...  @{otherrelation}
...  @{CB006882}
...  @{LTE5761}
...  @{LTE5679}
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:actTransmittedBelowGap=false
...    LNCEL:actFlowCtrlEnh=true
...    LNCEL-3/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=40
...    LNCEL-4/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=40
...    LNCEL-5/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=40
...    LNCEL-6/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=40
...    LNBTS:actInterEnbDLCAggr=true
...    LNBTS:caClusterId=1
...    LNBTS:caClusterId=1
...    LNBTS:actIscaHarqEnh=false
@{CA}
...  LNBTS-1:actDLCAggr=true
...  LNBTS-1:actAdvScellMeas=true
...  LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...  LNCEL-1/CAREL-1:lcrId=2
...  LNCEL-1/CAREL-1:lnBtsId=1
...  LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...  LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...  LNCEL-1/CAREL-2:lcrId=3
...  LNCEL-1/CAREL-2:lnBtsId=1
...  LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...  LNCEL-1/CAREL-2:pcellSwapAllowed=allowed
...  LNCEL-1/CAREL-3:lcrId=4
...  LNCEL-1/CAREL-3:lnBtsId=1
...  LNCEL-1/CAREL-3:maxNumOfSuppMimoLayer=2-layer
...  LNCEL-1/CAREL-3:pcellSwapAllowed=allowed
...  LNCEL-1/CAREL-4:lcrId=5
...  LNCEL-1/CAREL-4:lnBtsId=1
...  LNCEL-1/CAREL-4:maxNumOfSuppMimoLayer=2-layer
...  LNCEL-1/CAREL-4:pcellSwapAllowed=allowed
...  LNCEL-2/CAREL-1:lcrId=3
...  LNCEL-2/CAREL-1:lnBtsId=1
...  LNCEL-2/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...  LNCEL-2/CAREL-1:pcellSwapAllowed=allowed
...  LNCEL-2/CAREL-2:lcrId=1
...  LNCEL-2/CAREL-2:lnBtsId=1
...  LNCEL-2/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...  LNCEL-2/CAREL-2:pcellSwapAllowed=allowed
...  LNCEL:caPoolId=1
...  LNCEL:maxNumScells=2
...  LNBTS-1:actFlexScellSelect=true
...  LNCEL-1/LNCEL_FDD-0:earfcnDL=2450
...  LNCEL-1/LNCEL_FDD-0:earfcnUL=20450
...  LNCEL:actFlowCtrlEnh=false
...  delete:LNBTS-1/LNADJ-255
...  LNCEL-1/CAREL-1:scellPrio=3
...  delete:LNCEL-1/CAREL-2:beamformingInScellAllowed
...  delete:LNCEL-2/CAREL-1:beamformingInScellAllowed
...  delete:LNCEL-2/CAREL-2:beamformingInScellAllowed
...  LNBTS-1:actFlexCaMgmt=true
...  LNCEL:actCaArchEnhImp=off
...  LNCEL:actScellConfigForHiDemand=false
...  LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...  LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=1
...  LNBTS-1/CADPR-0:maxNumMimoLayerFdd=12
...  LNCEL:scellFastSchedulingSelect=normal
...  LNCEL:dlCaMinPcellCqi=0
...  LNCEL:dlCaMinPcellCqiQci1=0
...  LNCEL:ulCaMinPcellSinr=0
...  LNCEL:ulCaMinPcellSinrQci1=0
...  LNCEL/LNCEL_FDD-0:dlChBw=10 MHz
...  LNCEL/LNCEL_FDD-0:ulChBw=10 MHz
...  LNCEL-5/LNCEL_FDD-0:dlChBw=20 MHz
...  LNCEL-5/LNCEL_FDD-0:ulChBw=20 MHz
@{x2link}
...  LNBTS/LNADJGNB-1:administrativeState=unlocked
...  LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...  LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...  LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...  LNCEL/LNRELGNBCELL-1:nrCellId=115969
...  LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...  LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...  LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...  LNCEL/LNRELGNBCELL-2:gnbIdLength=22
...  LNCEL/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...  LNCEL/LNRELGNBCELL-2:nrCellId=115970
...  LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...  LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...  LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
@{LTE4088}
...  LNBTS:actLteNrDualConnectivity=true
...  LNBTS:tLteNrDualConnectPrep=10000
...  LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
@{LTE4193}
...  LNBTS:actDynTrigLteNrDualConnectivity=true
...  LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...  LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...  LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...  LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...  LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...  LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...  LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...  LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=true
...  LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...  LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
...  LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:pucchArRateEvalWinLength=0
...  LNBTS/LBPUCCHRPR-1:countdownPucchCompr=60min
...  LNBTS/LBPUCCHRPR-1:countdownPucchExp=1min
...  LNBTS/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...  LNBTS/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...  LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...  LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=176320
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=5
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...  LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...  LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4
...  LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...  LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...  LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...  LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...  LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...  LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=56
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=392032
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=2
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=0
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=1
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=15kHz
@{LTE4549}
...  LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...  LNBTS:enableBwCombCheck=true
...  LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...  LNBTS/NRDCDPR-0:allowedBcSelectMethod=max MIMO layers
@{modulation}
...  LNCEL:actModulationSchemeDl=64QAM
...  LNCEL:actLdPdcch=true
...  LNCEL/LNCEL_FDD-0:maxNrSymPdcch=3
...  LNCEL:adaptPdcchDwellTime=0
...  LNCEL:mbrSelector=ueCapability
${ue_eutra_capabilities_01}
...  SEPARATOR=
...  DD9FF44300BF08A0102E0B82EFC1BF335942004408020A540000A0CCBE7F83762697884042F7E0DD89AB230421841086104218210C1082080
...  304218018018200C100608430030022104002D3EAA30A020304200820E0840105042085981004141082FE105902E0B82E0B82E0B82E0B82E0
...  B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82EFC5000019
...  9110F0F0F1708FE2E43C3C3F04000804080CD0007CE3C0004080C10181C2C4C6C707507EFF896B4D03217F9A10EA000600DB2400008000041
...  2E780C008048080C0209A143C0F7FC0001BFE00410B7FC0007BFE00800421F460C100000018400220001
${ue_nr_capabilities}    SEPARATOR=    CE00000001C8F5C0302800001939980000CC0030000140000134000002000004262000000601800400000040
${ue_eutra_nr_capabilities_01}
...  SEPARATOR=
...  C100609713010060201C0400000007E80000001040202800DC4C0401820070100000081FA0000000410080A00370B2820E1400000203F4000
...  00000206E165041C4D00000607E8000000104020280080400401802404D805001880002010001804040080110000402000100808010021000
...  1004040080108000802020040080
${ue_eutra_capabilities_02}
...  SEPARATOR=
...  DD9FF44300BF08A0102E0B82EFC1BF335942004408020A540000A0CCBE7F83762697884042F7E0DD89AB230421841086104218210C1082080
...  304218018018200C100608430030022104002D3EAA30A020330200820E6040105042085981004141082FE105902E0B82E0B82E0B82E0B82E0
...  B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82EFC5000019
...  9110F0F0F1708FE2E43C3C3F04000804080CD0007CE3C0004080C10181C2C4C6C707507EFF896B4D03217F9A10EA000600DB2400008000041
...  2E780C008048080C2609A143C0F7FC0001BFE00410B7FC0007BFE00800421F460C100000018400220001
${ue_eutra_nr_capabilities_02}
...  SEPARATOR=
...  C10060971B0C006020090438020000000FD00000002080405001B8D86003410068201C0100000207E80000001040202800DC2CA0838500000
...  080FD00000000081B85941071340000181FA0000000410080A002010010060090136014006300018040002010001804040080118000C02000
...  3008000C0202004008400040101002004200020080801002
@{pcellswap}
...  LNBTS:actPcellSwap=true
...  LNBTS:actIfHo=enabled
...  LNCEL-1:pcellSwapConfig:numCaUeThreshold=5|puschLoadIndexThr=0.01
...  LNCEL:loadSettings:cellCapClass=100
...  LNCEL:loadSettings:mlbEicicOperMode=allUes
...  LNCEL:loadSettings:nomNumPrbNonGbr=0.01
...  LNCEL:loadSettings:targetLoadGbrDl=50
...  LNCEL:loadSettings:targetLoadNonGbrDl=75
...  LNCEL:loadSettings:targetLoadPdcch=90
...  LNCEL:loadSettings:ulCacIgnore=false
...  LNCEL:loadSettings:ulCacSelection=ulReflectDlCac
...  LNCEL:loadSettings:ulStaticCac=100
...  LNCEL-2:pcellSwapConfig:numCaUeThreshold=10|puschLoadIndexThr=10
...  LNCEL-3:pcellSwapConfig:numCaUeThreshold=10|puschLoadIndexThr=10
...  LNCEL-4:pcellSwapConfig:numCaUeThreshold=10|puschLoadIndexThr=10
...  LNCEL-3/CAREL-2:lcrId=2
...  LNCEL-3/CAREL-2:lnBtsId=1
...  LNCEL-3/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...  LNCEL-3/CAREL-2:pcellSwapAllowed=allowed
...  LNCEL-3/CAREL-2:scellPrio=3
@{PARAMS_IN_EMIL}
...  0x400e
...  0x7509
...  0x74dc
${ENABLE_STATIC_DSS}    0x001200F3
@{PARAMS_IN_SWCONFIG}
...  ${ENABLE_STATIC_DSS}=1
@{LTE4804}
...  LNBTS:actRCREnDc=RCR-servingCell
@{otherrelation}
...  LNBTS-1:actEndcSpidFwd=false
...  LNBTS-1:endcSchedWeightBoostDl=2
...  LNBTS-1:endcSchedWeightBoostUl=2
...  LNCEL:eTputInitMcs=20
...  LNCEL:eTputFilterConfig=51
...  LNBTS-1:actAmbrModCaTrigger=false
...  LNBTS-1:nrRestrictionOverride=disabled
@{cleanup}
...  delete:LNBTS/NRDCDPR-0:frequencyConfigNrList
...  LNBTS:actEndcAdjCarrierChk=disabled
...  LNBTS:actEnDcLteDlMimoOptBcSel=false
...  LNBTS:actEnDcLteDlTputBcSel=false
...  LNCEL-1/LNCEL_FDD-0:earfcnDL=5230
...  LNCEL-1/LNCEL_FDD-0:earfcnUL=23230
...  @{LTE5407}
@{LTE5761}
...  LNBTS:actEnDcLteDlMimoOptBcSel=false
@{LTE5679}
...  LNBTS:actEnDcLteDlTputBcSel=false
@{LTE5407}
...  LNBTS:actLteNrDss=true
...  LNBTS:actBbPooling=true
...  LNCEL-2:lteNrDssMode=DSS_Phase_I
...  LNCEL-2/LNCEL_FDD-0:blankedPucch=12
#...  LNCEL-2/LNCEL_FDD-0:activatedMimoTM=TM4
...  delete:LNCEL-2/LNCEL_FDD-0:csiRsConfigInfo
...  LNCEL-2/LNRELGNBCELL-1:lteNrDualConnectAllowed=forbidden
...  LNCEL-2/DSSNR-0:dssNrCellId=1
...  LNCEL-3:lteNrDssMode=DSS_Phase_I
...  LNCEL-3/LNCEL_FDD-0:blankedPucch=12
#...  LNCEL-3/LNCEL_FDD-0:activatedMimoTM=TM4
...  delete:LNCEL-3/LNCEL_FDD-0:csiRsConfigInfo
...  LNCEL-3/LNRELGNBCELL-1:lteNrDualConnectAllowed=forbidden
...  LNCEL-3/DSSNR-0:dssNrCellId=1
@{CB006882}
...  LNBTS:actEndcAdjCarrierChk=eNBConfig_PCellAndSCellContiguity
...  LNBTS/NRDCDPR-0:frequencyConfigNrList:carrierCenterFreqNr=172000|ssbFreqNrCell=176320
...  LNBTS/NRDCDPR-0:frequencyConfigNrList:chBwDlNrCell=20 MHz|ssbFreqNrCell=176320
@{LTE5761_ON}
...  LNBTS:actEnDcLteDlMimoOptBcSel=true
@{LTE5679_ON}
...  LNBTS:actEnDcLteDlTputBcSel=true
@{cell3_4layer}
...  LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
@{param_case04_1}
...  LNBTS/NRDCDPR-0:frequencyConfigNrList:carrierCenterFreqNr=177340|ssbFreqNrCell=176320
...  LNBTS/NRDCDPR-0:frequencyConfigNrList:chBwDlNrCell=15 MHz|ssbFreqNrCell=176320
@{param_case04_2}
...  LNBTS/NRDCDPR-0:frequencyConfigNrList:carrierCenterFreqNr=177798|ssbFreqNrCell=176320
...  LNBTS/NRDCDPR-0:frequencyConfigNrList:chBwDlNrCell=20 MHz|ssbFreqNrCell=176320
@{param_case08_0}
...  LNBTS:actEndcAdjCarrierChk=eNBConfig_PCellAndSCellContiguity
...  LNBTS/NRDCDPR-0:frequencyConfigNrList:carrierCenterFreqNr=386980|ssbFreqNrCell=392032
...  LNBTS/NRDCDPR-0:frequencyConfigNrList:chBwDlNrCell=40 MHz|ssbFreqNrCell=392032
@{LTE5761_ON}
...  LNBTS:actEnDcLteDlMimoOptBcSel=true
@{LTE5679_ON}
...  LNBTS:actEnDcLteDlTputBcSel=true
@{cell3_4layer}
...  LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
${scell_900}
...    sCellToAddModList-r10 contains (
...    sCellIndex-r10 eq 1 and
...    physCellId-r10 eq 3 and
...    dl-CarrierFreq-r10 eq 900)
${scell_2450}
...    sCellToAddModList-r10 contains (
...    sCellIndex-r10 eq 1 and
...    physCellId-r10 eq 1 and
...    dl-CarrierFreq-r10 eq 2450)

${sgnbaddition1}
...    allowedBC-ListMRDC contains (bandCombinationIndex eq 2 and allowedFeatureSetsList contains (1))
${sgnbadditionack1}
...    selectedBandCombination contains (bandCombinationIndex eq 2 and requestedFeatureSets eq 1)
${sgnbaddition2}
...    allowedBC-ListMRDC contains (bandCombinationIndex eq 1 and allowedFeatureSetsList contains (1))
${sgnbadditionack2}
...    selectedBandCombination contains (bandCombinationIndex eq 1 and requestedFeatureSets eq 1)

*** Test Cases ***
CB006882-B-B2_ET_04_01_add scell mimo layer which has invalid FrequencyConfigNrList when calculate the max mimo layer
    [Tags]
    Set ue parameters before ENDC setup
    setup ENDC with ssb and centra not the same band
    setup ENDC with centra non-contiguous
    setup ENDC with centra contiguous

*** Keywords ***
Common Suite Setup and Setup CUS Env
    Common Suite Setup
    Execute Cmd On Pc    sudo ifconfig eth4:1 add 10.0.2.11
    Setup CUS Env    tl_type=6CELLs_FDD_4PIPE_B13_2B2_2B66_B71_Non_TMO
    execute egate command    proxy_log GEN=debug
    execute egate command    trace_sim on mme=1 protocol=s1
    execute egate command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Create Alias

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Set ue parameters before ENDC setup
    execute uex command    ue_param id=1-3 dual_conn=eutra_nr pdcp_sn_extension=18bit nr_supported_bands=5,2
    execute egate command    gnb_endc_param id=7 use_nr_ran_cont=true scg_dl_dist_percent=0 include_reestablish_pdcp=on
    execute egate command    gnb_endc_param id=7 selected_band_combination_nr=1:1
    execute uex command    ue_cqi_param id=1-3 scell=0-2 rank=4 ri_i1=18
    execute uex command    ue_cqi_param id=1-3 scell=0-3 rank=4 cell=both
    execute egate command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    execute egate command    enb_timer T_DC_Overall=5000ms

Modify Yaml
    ${GNB2_CELL1}    catenate    - {id: 21, technology: lte, pci: '1:1', tac: 33, earfcn: '1400:19400', status: enabled}
    ${GNB7_CELL1}    catenate    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '167300:176300',
    ...    tdd_cell: yes, nr_scs: 30kHz, bs_channel_bandwidth: 50MHz}
    ${GNB7_CELL2}    catenate    - {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x0000502', nr_arfcn: '376000:376000',
    ...    tdd_cell: yes, nr_scs: 30kHz, bs_channel_bandwidth: 50MHz}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      cells:
    ...         ${GNB7_CELL1}
    ...         ${GNB7_CELL2}
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      enb_id: '0x00002'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.3
    ...      x2: 10.0.1.3
    ...      cells:
    ...         ${GNB2_CELL1}
    add yaml    EPC
    ...    UEC:
    ...    - id: 1
    ...    peer_uplane: '10.0.2.11:2152'

UE attach to cell
    [Arguments]    ${ue_id}=1    ${ue_eutra_nr_capabilities}=${ue_eutra_nr_capabilities_01}    ${ue_eutra_capabilities}=${ue_eutra_capabilities_01}
    ${V_1}  catenate  ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...  ue_eutra_capabilities=${ue_eutra_capabilities} enb=1 cell=2
    execute uex command    ${V_1}

Start DL Data to trigger 2CC
    [Arguments]    ${ue_id}=1
    execute uex command  trf_data_start ue=${ue_id} qci=8 Mbps=100 dir=dl protocol=udp

send B1NR to setup ENDC
    [Arguments]    ${ue_id}=1    ${meas_id_blacklist}=17    ${pci}=1
    execute uex command  ue_measurement_send id=${ue_id} event=B1_NR meas_id_blacklist=${meas_id_blacklist} phycell_id=${pci} nrsrp=70

set combination select
    [Arguments]    ${gnb_id}=7    ${X:Y}=1:1
    execute egate command    gnb_endc_param id=${gnb_id} selected_band_combination_nr=${X:Y}

setup ENDC with ssb and centra not the same band
    UE attach to cell    ue_id=1
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${scell_900})
    ...    alias=2ccsetup    overall_timeout=30
    Start DL Data to trigger 2CC    ue_id=1
    flow occurred as expected    alias=2ccsetup
    set combination select    gnb_id=7    X:Y=2:1
    expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest(${sgnbaddition1})
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge(${sgnbadditionack1})
    ...    UE_1:RRC_RRCConnectionReconfiguration(sCellToReleaseList-r10 contains (1))
    ...    UE_1:RRC_RRCConnectionReconfiguration(${scell_2450})
    ...    alias=endcsetupandscell1release    overall_timeout=30
    send B1NR to setup ENDC    ue_id=1    meas_id_blacklist=18    pci=1
    flow occurred as expected    alias=endcsetupandscell1release

setup ENDC with centra non-contiguous
    Delta Commission Parameters    ${param_case04_1}
    CUS Detach All Ues
    UE attach to cell    ue_id=1
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${scell_900})
    ...    alias=2ccsetup_1    overall_timeout=30
    Start DL Data to trigger 2CC    ue_id=1
    flow occurred as expected    alias=2ccsetup_1
    set combination select    gnb_id=7    X:Y=2:1
    expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest(${sgnbaddition1})
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge(${sgnbadditionack1})
    ...    UE_1:RRC_RRCConnectionReconfiguration(sCellToReleaseList-r10 contains (1))
    ...    UE_1:RRC_RRCConnectionReconfiguration(${scell_2450})
    ...    alias=endcsetupandscell1release_1    overall_timeout=30
    send B1NR to setup ENDC    ue_id=1    meas_id_blacklist=18    pci=1
    flow occurred as expected    alias=endcsetupandscell1release_1

CUS Detach All Ues
    [Arguments]    ${ue_id}=1
    execute uex command    ue_detach id=${ue_id}

setup ENDC with centra contiguous
    Delta Commission Parameters    ${param_case04_2}
    CUS Detach All Ues
    UE attach to cell    ue_id=1
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${scell_900})
    ...    alias=2ccsetup_2    overall_timeout=30
    Start DL Data to trigger 2CC    ue_id=1
    flow occurred as expected    alias=2ccsetup_2
    set combination select    gnb_id=7    X:Y=1:1
    expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest(${sgnbaddition2})
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge(${sgnbadditionack2})
    ...    UE_1:RRC_RRCConnectionReconfiguration(sCellToAddModList-r10 contains (sCellIndex-r10 eq 1))       #ENDC setup with CA
    ...    alias=endcsetupwithca    overall_timeout=30
    send B1NR to setup ENDC    ue_id=1    meas_id_blacklist=18    pci=1
    flow occurred as expected    alias=endcsetupwithca

