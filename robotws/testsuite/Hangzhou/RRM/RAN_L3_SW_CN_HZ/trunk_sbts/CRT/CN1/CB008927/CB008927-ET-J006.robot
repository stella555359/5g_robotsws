*** Settings ***
Documentation
...    author:  kang.xiang@nokia-sbell.com
...    contact: kang.xiang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]    team-VRF_HAZ3_T06
...    owner-lijun.j.jia    release-SBTS25R1    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}
${rdEnableUeMappingRemovalFromCpIf}    0x89001E=1

@{PARAMS_IN_SWCONFIG}
...    ${rdEnableUeMappingRemovalFromCpIf}

@{PARAMS_IN_SWCONFIG_GNB2}
...    ${rdEnableUeMappingRemovalFromCpIf}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{gscn_Arfcn}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRDU-1:actInterGnbCa=DLOnly

@{PARAMS_FOR_GNB1}
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL:nrCellType=2DL2UL
...    NRCELL-11:maxNumScellsDlFr1=3
...    NRCELL-11:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRCELL-12:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRCELL-11:a5MeasEnabled=rsrpCombined
...    NRCELL-11:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-11:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    NRCELL-11:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL-11:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40
...    NRCELL-11:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL-11:a5MeasSsbRsrq:a5Threshold1SsbRsrq=50
...    NRCELL-11:a5MeasSsbRsrq:a5Threshold2SsbRsrq=70
...    NRCELL-11:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms40
...    NRBTS:actFdmScheduling=true
...    NRCELL:actFdmSchedulingInitialBWP=true
...    NRCELL:actFdmInitialDedicatedFdd=true
...    NRCELL:minRbReservedForNonSiPaging=34
...    NRCELL:raMsg2TargetRate=MCS0_SF0
...    NRBTS:actLteNrDss=false
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actRat1Alloc=true
...    NRCELL:actDlDynSwitchAlloc=true

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=0
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663000
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:ssbFrequency=663360
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:ssbFrequency=657984
...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:gNbId=2
...    NRBTS/NRADJNRCELL-13:gNbIdLength=22
...    NRBTS/NRADJNRCELL-13:lcrId=13
...    NRBTS/NRADJNRCELL-13:nrarfcn=364000
...    NRBTS/NRADJNRCELL-13:physCellId=62
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-13:ssbFrequency=363850
...    NRBTS/NRADJNRCELL-14:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-14:fiveGsTac=200
...    NRBTS/NRADJNRCELL-14:gNbId=2
...    NRBTS/NRADJNRCELL-14:gNbIdLength=22
...    NRBTS/NRADJNRCELL-14:lcrId=14
...    NRBTS/NRADJNRCELL-14:nrarfcn=153400
...    NRBTS/NRADJNRCELL-14:physCellId=63
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-14:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-14:ssbFrequency=153370
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-13:gNbId=2
...    NRCELL-11/NRREL-13:gNbIdLength=22
...    NRCELL-11/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-13:lcrId=13
...    NRCELL-11/NRREL-13:removeNotAllowed=false
...    NRCELL-11/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=2
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=2
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-14:gNbId=2
...    NRCELL-11/NRREL-14:gNbIdLength=22
...    NRCELL-11/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-14:lcrId=14
...    NRCELL-11/NRREL-14:removeNotAllowed=false
...    NRCELL-11/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-14:sCellOperationalMode=dlOnly

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=0
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRMOPR_SA-1:a5MeasEnabled=rsrp
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-13:sCellDeactivationTimerGNB=infinity
...    NRCELL-14:sCellDeactivationTimerGNB=infinity
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRCELL-13:a5MeasEnabled=rsrq
...    NRCELL-13:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-13:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    NRCELL-13:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL-13:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40
...    NRCELL-13:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL-13:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRCELL-13:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRCELL-13:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms40
...    NRBTS:actFdmScheduling=true
...    NRBTS:actLteNrDss=false
...    NRCELL-13:actFdmSchedulingInitialBWP=true
...    NRCELL-13:actFdmInitialDedicatedFdd=true
...    NRCELL-13:minRbReservedForNonSiPaging=34
...    NRCELL-13:raMsg2TargetRate=MCS0_SF0
...    NRCELL-13:pucchModeSelect=longPucch
# ...    NRCELL-13:actRat1Alloc=true
...    NRCELL-14:actFdmSchedulingInitialBWP=true
...    NRCELL-14:actFdmInitialDedicatedFdd=true
...    NRCELL-14:minRbReservedForNonSiPaging=34
...    NRCELL-14:raMsg2TargetRate=MCS0_SF0
...    NRCELL-14:pucchModeSelect=longPucch
...    NRCELL:actRat1Alloc=true
...    NRCELL:actDlDynSwitchAlloc=true

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:gNbId=1
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=364000
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:ssbFrequency=363850
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-12:gNbId=1
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=374000
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:ssbFrequency=373970
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=2
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-11:gNbId=1
...    NRCELL-13/NRREL-11:gNbIdLength=22
...    NRCELL-13/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-11:lcrId=11
...    NRCELL-13/NRREL-11:removeNotAllowed=false
...    NRCELL-13/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-11:gnbPlmn:mncLength=3

...    NRCELL-14/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-11:gNbId=1
...    NRCELL-14/NRREL-11:gNbIdLength=22
...    NRCELL-14/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-14/NRREL-11:lcrId=11
...    NRCELL-14/NRREL-11:removeNotAllowed=false
...    NRCELL-14/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-14/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-12:gNbId=1
...    NRCELL-14/NRREL-12:gNbIdLength=22
...    NRCELL-14/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-14/NRREL-12:lcrId=12
...    NRCELL-14/NRREL-12:removeNotAllowed=false
...    NRCELL-14/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-12:sCellOperationalMode=dlOnly

...    NRCELL-13:a1MeasSCellAddEnabled=rsrp
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
...    NRCELL-13:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms

@{gscn_Arfcn}
...    NRCELL-13:gscnOrSsPbchArfcn=4547
...    NRCELL-13/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=364000
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=345000

@{PARAMS_FOR_OTHERS}
...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min

@{PM_Counters_Check_PRIM}
...    NRBTS-1:${UE_SUPP_DL_DYNAMIC_RAT}>0
...    NRBTS-1:${UE_SUPP_DL_NO_DYNAMIC_RAT}>0
...    NRBTS-1:${DENOM_UE_RAT_SUPP}>0
...    NRBTS-1:${ATT_INTER_GNB_HO_SLICE}=2
...    NRBTS-1:${HO_REQ_PDU_SESS_RES_SENT_SLICE}=2
...    NRBTS-1:${SUCC_OG_INTER_GNB_HO_SLICE}=2
...    NRCELL-11:${ATT_OG_INTER_GNB_HO_SA_PLMN}=2
...    NRCELL-11:${SUCC_OG_INTER_GNB_HO_SA_PLMN}=2
...    NRCELL-11:${XN_HO_REQ_ACK_RECEIVED}=2

@{PM_Counters_Check_EXT}
...    NRBTS-2:${UE_SUPP_DL_DYNAMIC_RAT}>0
...    NRBTS-2:${UE_SUPP_DL_NO_DYNAMIC_RAT}>0
...    NRBTS-2:${DENOM_UE_RAT_SUPP}>0
...    NRCELL-13:${NF1CC_UECTXT_STP_REQSENT}=2
...    NRCELL-13:${NF1CC_UECTXT_STP_RESPRECD}=2
...    NRCELL-13:${XN_HO_REQ_ACK_SENT}=2
...    NRCELL-13:${SUCC_IC_INTER_GNB_HOP_SA_PLMN}=2
...    NRCELL-13:${UE_PCELL_1_CONF_SCELL_DL_SA}>0

@{scelladded}
...    physCellId 50
...    physCellId 51
...    physCellId 63

${ATT_INTER_GNB_HO_SLICE}    M55149C00008
#The number of Intra-Frequency Inter-gNB HOs attempted, for the given slice and PLMN.
${HO_REQ_PDU_SESS_RES_SENT_SLICE}    M55149C02004
#The number of total Xn Handover attempts of PDU session for the given slice and PLMN..
${SUCC_OG_INTER_GNB_HO_SLICE}    M55149C00009
#The number of Intra-Frequency Inter-gNB Outgoing HO successful, for the given slice and PLMN.
${ATT_OG_INTER_GNB_HO_SA_PLMN}    M55145C00341
#The number of outgoing intra-frequency inter-gNB HO execution attempts for SA per PLMN-ID.
${SUCC_OG_INTER_GNB_HO_SA_PLMN}    M55145C00342
#The number of successful outgoing intra-frequency inter-gNB HO executions for SA per PLMN-ID.
${XN_HO_REQ_ACK_RECEIVED}    M55143C00001
#The number of XnAP: Handover Request Acknowledge received.
${NF1CC_UECTXT_STP_REQSENT}    M55113C01001
#Number of F1AP: UE Context Setup ReqUEst messages sent from gNB-CU to gNB-DU
${NF1CC_UECTXT_STP_RESPRECD}    M55113C01002
#Number of F1AP: UE Context Setup Response messages received at gNB-CU from gNB-DU.
${XN_HO_REQ_ACK_SENT}    M55143C00006
#The sending of an XnAP: Handover Request Acknowledge. Updated in target gNB.
${SUCC_IC_INTER_GNB_HOP_SA_PLMN}    M55145C00361
#The number of successful incoming inter-gNB HO preparations for SA per PLMN-ID.
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
#The sum of samples for total number of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in DL.
${UE_SUPP_DL_DYNAMIC_RAT}    M55139C00029
#Number of UEs that support dynamic switching for resource allocation type in downlink
${UE_SUPP_DL_NO_DYNAMIC_RAT}    M55139C00030
#Number of UEs that don't support dynamic switching for resource allocation type
${DENOM_UE_RAT_SUPP}    M55139C00031
#UE capability denominator for RAT type

${SA_Supp_dynSwitch_UECapa}    SEPARATOR=
...    E9A09000575F5A131E0003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D80D81AC1184341020E9068036B64C558D0E7C471E819F
...    604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B00B582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E7CC3
...    1E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007FE0038
...    01FF8002E0000702A0D837AC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA3626
...    EB04610D00000201A00C2D926544439F11C79063D033EC09F00E7CC31E50B0381C3C17AAAAAAA9EAAAAAAA17000038024B0F1300038980000002C0AC5C4C
...    000E26000713000000858158B80400184C0309800020B02B1F008003036061300C260000C2C0AC5C02000C0101C1B000008160563E0100060180C0D8184D
...    0002858158B80400181B0309800060B02B0F00800309800070B02B0F00800300400080B02B0F06C00303600090B02B0F00800300C000A0B02B0F01800303
...    6000B0B02B1700800300C0606C0018160561E0D800713000006858158B89800184C03004000E0B02B1F130003098060080C0D8003C2C0AC5C4C000C01018
...    1B0008058158F89A0018020300C0606C0022160402401B800D0132001404D17400E909428913639F0E2448913639F0E2448913639F0E344891226C73E1C4
...    891226C73E1C68912244D8E7C38912244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28913639F0E2448
...    913639F0E344891226C73E1C4891226C73E1C68912244D8E7C301B1218C6318C6318C6318C6318C1E82E003C00281C1401C0C02500700060240040603E09
...    002000000010008000000200000C0100000200800002004000018020000100100000A008004010040100000C008000070040020000000800008004000048
...    0200000C010000140080000B004002048120080000C0339535953582958195833581B594B581B780B581B58095811583B40D040000259494100001965260
...    400006594901000039652404000125949010000596526040001A594901000079652404000225949010000996524040002A5949010000B965250400032594
...    90100003165240334AAAE955552A8BA5515C0E0AA0B1541A2A94C55268AA0315C0E0AA4D5541E285805E02540A05028140A05028140A05028140A0502814
...    0A050011080801002020040088040080101002004040080110080600A02004008080100230100C014040300501002004040080110080800A02020028080B
...    01630100C01804030050100C018040080110080600A02018028080100210100C014040080108080600A02018028404030060100C018202018030080600A1
...    0100C014040300510080600A02018030080600A10100C018040080110080100202004008080600A30100200404008010100C014040300510080100202018
...    030080600C30100200404030050100C01804030051AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

*** Test Cases ***
CB008927-5G-ET-J006_IGNBFFTTCA_XnHOto_FTCA_DynamicSwitch
    [Documentation]
    ...    1. This user scenario describes the dynamicSwitch usage during inter-gNB CA and HO.
    ...    2. Configuration
    ...       GNB1 cell1_11, cell1_12 F+F
    ...       GNB2 cell2_1, cell2_2, cell2_13, cell2_14 T+T+F+F
    ...    [TL seting]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008927-J
    ...    [Configuration]:
    ...    GNB-1 Pri: cell11-FDD(n3)(pci:60) cell12-FDD(n3)(pci:61)
    ...    GNB-2 ext: cell1-TDD(n77)(pci:50) cell2-TDD(n77)(pci:51) cell13-FDD(n3)(pci:62) cell14-FDD(n28)(pci:63)
    ...    scell gnb2-cell1 gnb2-cell2 and gnb2-cell14
    ...    [Test Case Steps]
    ...         a. UE-1 register to gnb1-cell11
    ...         b. UE-1 blind 4CC FFTT scells add successful
    ...         c. UE-1 send A5 MR with RSRP satisfied to trigger intra-frequency intergnb handover
    ...         d. UE-1 coverBased add intraGnb cell as scell
    ...         e. UE-1 send A5 MR with NRMOPR_SA RSRP satisfied to trigger intra-frequency intergnb handover back
    ...         f. UE-1 context release
    ...         g. Repeat step a-g for UE-2 which not support dynamicSwitch
    ...         h. Check counters and logs
    ...    [Expected Results]:
    ...         b. scell: gnb2-cell1 gnb2-cell2 and gnb2-cell14 add successfully, DynamicSwitch used in scells
    ...         c. HO from gnb1-cell11 to gnb2-cell13 successfully, DynamicSwitch used in HO
    ...         d. scell: gnb2-cell1 add successfully, DynamicSwitch used in scells
    ...         e. HO back from gnb2-cell13 to gnb1-cell11 successfully, DynamicSwitch used in HO back
    ...         g. UE-2 uses RAT1 instead of DynamicSwitch during scelladd and HO.
    [Tags]    J006    QC_14387    lijun.j.jia@nokia-sbell.com
    Clear All Counter Files
    Common Procedure of CA and HO    ue_id=1
    Common Procedure of CA and HO    ue_id=2
    Check All Counters
    Check Wireshark Log    ${CURDIR}${/}A2A_J006${/}a2a.ini    wait_string=UEContextRelease::36

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

Common Procedure of CA and HO
    [Arguments]    ${ue_id}=1
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=${ue_id}    pdu_id=1     enb_id=2    cell_id=11
    Intrafreq InterGNB Handover    ue_id=${ue_id}    pdu_id=1    carrierfreq=363850    target_phycell_id=62
    trigger A1 MR to add scell    ue_id=${ue_id}    src_cell_ssbfreq=363850
    Intrafreq InterGNB Handover Back    ue_id=${ue_id}    carrierfreq=363850    target_phycell_id=60
    UE Deregister From gNB First Time    ue_id=${ue_id}

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Supp_dynSwitch_UECapa}
    ${set_cell13_gscn}    catenate
    ...    set_cell id=13 gnb=3 pci=20:2 tac=200 nrci=0x0D tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=345000:364000
    ...    mandatory_for_activation=off gscn=4547
    Update Cfg    ${set_cell13_gscn}

Clear All Counter Files
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

UE Attach To Target Cell Then Send And Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${enb_id}=2    ${cell_id}=11
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=1 nwslice=1    pass_regexp=${scelladded}
    Send And Verify Throuput    ue_id=${ue_id}    pdu_id=${pdu_id}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${Tput_dl}=90    ${Tput_ul}=9.5    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Verify Throughput After Add Scell
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${Tput_dl}=585    ${Tput_ul}=9.5    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 90
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 450

UE Deregister From gNB First Time
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
    sleep    30s    reason=wait timer

Check All Counters
    Check Counters    ${PM_Counters_Check_PRIM}
    Check Counters GNB2    ${PM_Counters_Check_EXT}

Intrafreq InterGNB Handover
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${carrierfreq}=363850    ${target_phycell_id}=62
    Execute Egate Command    ue_disp
    ${meas_id_scell}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A5
    ${event_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell} event=A5
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=110 nrsrq_nr=110
    Execute Egate Command    ${event_cmd}
    ...    pass_regexp=Inter-eNB handover from EXT_ENB
    Verify Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}

Intrafreq InterGNB Handover Back
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${carrierfreq}=363850    ${target_phycell_id}=60
    Execute Egate Command    ue_disp
    ${meas_id_scell}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A5
    ${event_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell} event=A5
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=60 nrsrq_nr=60
    ${ret1}=    Execute Egate Command    ${event_cmd}    pass_regexp=${scelladded}
    Verify Throuput on Pcell and Scell    ue_id=${ue_id}    pdu_id=${pdu_id}    sleep_time=10s

trigger A1 MR to add scell
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${src_cell_ssbfreq}=363850
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${src_cell_ssbfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrq_nr=110 srsrp_nr=110
    ...    pass_regexp=sCellIndex 1    fail_regexp=scellIdx:2
    Should Contain    ${ret1}    physCellId 50
    Verify Throughput After Add Scell    ue_id=${ue_id}    pdu_id=${pdu_id}

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throuput on Pcell and Scell    ue_id=${ue_id}    pdu_id=${pdu_id}    sleep_time=10s

Scell traffic check
    [Arguments]    ${scell1_tput1}    ${scell2_tput2}    ${scell3_tput3}    ${scell1_tput1_except}=30
    ...    ${scell2_tput2_except}=30    ${scell3_tput3_except}=30
    Should Be True    ${scell1_tput1}/1000>${scell1_tput1_except}
    Should Be True    ${scell2_tput2}/1000>${scell2_tput2_except}
    Should Be True    ${scell3_tput3}/1000>${scell3_tput3_except}

Verify Throuput on Pcell and Scell
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${sleep_time}=10s    ${scell1_tput1_except}=470    ${scell2_tput2_except}=180
    ...    ${scell3_tput3_except}=70    ${pcell_tput_except}=70    ${pdu_id}=1
    sleep    ${sleep_time}
    ${scell1_tput1}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    ${scell2_tput2}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    ${scell3_tput3}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    Scell traffic check    ${scell1_tput1}    ${scell2_tput2}    ${scell3_tput3}    ${scell1_tput1_except}
    ...    ${scell2_tput2_except}    ${scell3_tput3_except}
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000>${pcell_tput_except}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>9
