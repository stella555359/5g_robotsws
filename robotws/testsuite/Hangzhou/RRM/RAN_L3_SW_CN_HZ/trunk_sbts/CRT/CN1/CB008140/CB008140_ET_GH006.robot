*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN1_SG02
...    owner-nanxiao.ge    release-SBTS23R4    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_STARTUP_RETRY}    3
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
@{PARAMS_IN_SWCONFIG}
...    ${DisableL2PS_XPU_monitoring}=0
${DisableL2PS_XPU_monitoring}    0x580647

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_Inter_Freq_HO_For_GNB1}
...    @{PARAMS_FOR_OTHERS}
@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=50
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=3
...    NRBTS:maxNumScellsUl=3
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Any_Sa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:maxNumScellsDlFr1=3
@{PARAMS_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-1:a1MeasSCellAddEnabled=rsrpCombined
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=31
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=31
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=40ms
...    NRCELL-1:a1MeashoEnabledSA=rsrpCombined
...    NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=60
...    NRCELL-1:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-1:a2MeashoEnabledSA=rsrpCombined
...    NRCELL-1:a3MeasEnabled=rsrpCombined
...    NRCELL-2:gscnOrSsPbchArfcn=8159
...    NRCELL-2:nrarfcn=663400
...    NRCELL-2:chBw=100MHz
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:ipAddress=10.0.1.124
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:remoteNeType=GNB
@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/XNLINK-2:cPlaneIpAddr=10.0.1.124
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJGNB-3:administrativeState=Unlocked
...    NRBTS/NRADJGNB-3:gNbIdLength=22
...    NRBTS/NRADJGNB-3:gNodeBId=35
...    NRBTS/NRADJGNB-3:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-3:xnLinkRef=2
...    NRBTS/NRADJGNB-3:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-3:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=653400
...    NRBTS/NRADJNRCELL-3:ssbFrequency=655008
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-63:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-63:fiveGsTac=200
...    NRBTS/NRADJNRCELL-63:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-63:gNbId=35
...    NRBTS/NRADJNRCELL-63:gNbIdLength=22
...    NRBTS/NRADJNRCELL-63:lcrId=5
...    NRBTS/NRADJNRCELL-63:nrarfcn=368400
...    NRBTS/NRADJNRCELL-63:ssbFrequency=368430
...    NRBTS/NRADJNRCELL-63:physCellId=63
...    NRBTS/NRADJNRCELL-63:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-63:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-63:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-64:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-64:fiveGsTac=200
...    NRBTS/NRADJNRCELL-64:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-64:gNbId=35
...    NRBTS/NRADJNRCELL-64:gNbIdLength=22
...    NRBTS/NRADJNRCELL-64:lcrId=6
...    NRBTS/NRADJNRCELL-64:nrarfcn=153400
...    NRBTS/NRADJNRCELL-64:ssbFrequency=153370
...    NRBTS/NRADJNRCELL-64:physCellId=64
...    NRBTS/NRADJNRCELL-64:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-64:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-64:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-63:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-63:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-63:gNbId=35
...    NRCELL-1/NRREL-63:gNbIdLength=22
...    NRCELL-1/NRREL-63:handoverAllowedSA=XnHoNotAllowed
...    NRCELL-1/NRREL-63:lcrId=5
...    NRCELL-1/NRREL-63:removeNotAllowed=false
...    NRCELL-1/NRREL-63:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-63:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-63:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-63:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-63:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-64:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-64:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-64:gNbId=35
...    NRCELL-1/NRREL-64:gNbIdLength=22
...    NRCELL-1/NRREL-64:handoverAllowedSA=XnHoNotAllowed
...    NRCELL-1/NRREL-64:lcrId=6
...    NRCELL-1/NRREL-64:removeNotAllowed=false
...    NRCELL-1/NRREL-64:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-64:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-64:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-64:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-64:gnbPlmn:mncLength=3
@{PARAMS_FOR_Inter_Freq_HO_For_GNB1}
...    NRCELL-1:ifhoSsbSmtcOffset=0
...    NRCELL-1:gapOffset=0
...    NRCELL-1:mgta=ms0
...    NRBTS/NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS:actInterFreqHoSA=true
...    NRCELL-1:a1MeashoEnabledSA=rsrpCombined
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0
...    NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=49
...    NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480
...    NRCELL-1:a3MeasEnabled=rsrpCombined
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=30
...    NRCELL-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    NRCELL-1:absThreshSsbRsrqConsolidation=20
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=XnHoNotAllowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpCombined
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=655008
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms1024
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms1024
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=6
@{PARAMS_FOR_GNB2}
...    NRBTS/NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:weightForSCellSelection=50
...    NRCELL-3:a1MeashoEnabledSA=rsrpCombined
...    NRCELL-3:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-3:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-3:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-3:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    NRCELL-3:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=60
...    NRCELL-3:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480
...    NRCELL-3:a1MeasSCellAddEnabled=rsrpCombined
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=60
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=100
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL-3:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=100
...    NRCELL-3:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=40ms
@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRMOPR_SA-1:a1MeashoEnabledSA=rsrpCombined
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=663400
...    NRBTS/NRADJNRCELL-2:ssbFrequency=657984
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:handoverAllowedSA=XnHoNotAllowed
...    NRCELL-3/NRREL-2:lcrId=2
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlOnly
@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=0
...    NRBTS:integrityProtPrefL:nia3_128=9
...    NRCELL:actCDrx=false
...    NRBTS:actIntraNrNgHo=sourceAndTarget
...    NRBTS:tNgRelocCancelN=2000
...    NRBTS:tNgRelocExecDeltN=3000
...    NRBTS:tNgRelocOverallN=2000
...    NRBTS:tNgRelocPrepN=2000

#UE_Capa nr-CGI-Reporting supported
${SA_Capa_Support_2CC_n77_n3_n28_n78_CA}    SEPARATOR=
...    E9A09000575F5A13160003C0A02C1262E003387A0609B20C39F30C7942C0E098040623809DC6C06C0D608C21A0810748046D6C98AB1A1CF88E3D033EC09F1891C790E7D473E6
...    18F28581C0E1E0BFFFFF800E000BE000280381506C02D608C21A081078804656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000500702A8D
...    899AC1184341020E9008C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000500702A0D837AC1184341020F1008CAD931562439F11C7B027C6
...    2471E439F51CF9863CA1607038784FFF800003FFE000000A00E0551B1375823086800001001185B24CA88873E238F20C7A067D813E01CF9863CA1607038782F55555553D5555
...    5540A00E0092C3C4C000E268000000B02B17130003898001C4C000002160562E0100061300C26000082C0AC7C02000E03000701800389A00000C2C0AC5C02000C010181B0002
...    058158F804001C06000E0D800713400002858158B80400181B0309800060B02B0F00800309800070B02B0F00800300400080B02B0F06C00303600090B02B0F00800300C000A0
...    B02B0F018003036000B0B02B1700800300C0606C0018160561E0D800713000006858158B89800184C03004000E0B02B1F130003098060080C0D8003C2C0AC5C4C000C010181B
...    0008058158F89A001C1B000E030007018000088581009006E003404C80050134157484A14489B1CF871224489B1CF871224489B1CF871A2448913639F0E2448913639F0E3448
...    91226C73E1C4891226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14489B1CF871224489B1CF871A2448913639F0E24489136
...    39F0E344891226C73E180D890C6318C6318C6318C6318C60F40B00F000A070300E0600A80E000C0480080C07C120040000000200100000004000018020000040100000400800
...    0030040000200200001401000802008020000180100000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066
...    B056B296F266F016B036B012B022B07681A0800004B29282000032CA4C080000CB29202000072CA480800024B292020000B2CA4C0800034B292020000F2CA480800044B29202
...    000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C501178095028140A05028
...    140A05028140A05028140A050281400442020040080801002201002004040080101002004402018028080100202004008C04030050100C014040080101002004402020028080
...    800A0202C058C04030060100C014040300601002004402018028080600A020040084040300501002004202018028080600A10100C018040300608080600C0201802840403005
...    0100C014402018028080600C020180284040300601002004402004008080100202018028C04008010100200404030050100C014402004008080600C02018030C04008010100C
...    01404030060100C0146A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B4


#IGNB_CA_ATT_SA_REL    M55118C11008
${IGNB_CA_ATT_SA_REL}    M55118C11008
${IGNB_CA_ATT_2_SCELL_SA_SUCC}    M55118C11005

${NG_HO_PREP_ATT_SRC_IEF}           M55125C07501
${NG_HO_PREP_SUCC_SRC}           M55125C07512
${NG_HO_EXEC_ATT_SRC_IEF}           M55125C07513
${NNGCC_UE_CTXT_REL_CMD_RECD}      M55125C00501
${NG_FLOW_REL_IANR_SUC_HO}      M55125C09015
${NG_HO_EXEC_SUCC_SRC_IEF}      M55125C07522
${NF1CC_UE_CTXT_REL_CMP_RECD}      M55113C01010
${NNGCC_UE_CTXT_REL_CMP_SENT}      M55125C00502

${NG_HO_RES_ALC_ATT_TRG}      M55125C07503
${NG_HO_RES_ALC_SUCC_TRG}      M55125C07504
${NG_HO_EXEC_NOTIFY_TRG}      M55125C07520
${NG_FLOW_STP_SUC_INC_HO}      M55125C09014

@{PM_Counters_Check_GNB1}
...    NRCELL-1:NCAC:${IGNB_CA_ATT_SA_REL}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_2_SCELL_SA_SUCC}=1
...    NRCELL-1:NNGCC:${NG_HO_PREP_ATT_SRC_IEF}=1
...    NRCELL-1:NNGCC:${NG_HO_PREP_SUCC_SRC}=1
...    NRCELL-1:NNGCC:${NG_HO_EXEC_ATT_SRC_IEF}=1
...    NRCELL-1:NNGCC:${NNGCC_UE_CTXT_REL_CMD_RECD}=1
...    NRCELL-1:NNGCC:${NG_FLOW_REL_IANR_SUC_HO}=1
...    NRCELL-1:NNGCC:${NG_HO_EXEC_SUCC_SRC_IEF}=1
...    NRCELL-1:NF1CC:${NF1CC_UE_CTXT_REL_CMP_RECD}=1
...    NRCELL-1:NNGCC:${NNGCC_UE_CTXT_REL_CMP_SENT}=1

@{PM_Counters_Check_GNB2}
...    NRCELL-3:NNGCC:${NG_HO_RES_ALC_ATT_TRG}=1
...    NRCELL-3:NNGCC:${NG_HO_RES_ALC_SUCC_TRG}=1
...    NRCELL-3:NNGCC:${NG_HO_EXEC_NOTIFY_TRG}=1
...    NRCELL-3:NNGCC:${NG_FLOW_STP_SUC_INC_HO}=1

@{expect}
...    GNB-4: XpAP Link with GNB-2

${DU-to-CU-RRCInfo}    SEPARATOR=
...    100200c0000100c1400302001000c240020100

# include scell id information
${ExtDu-to-PrimeDu-RrcInf}    SEPARATOR=
...    0144002880A26063107ED167CB80042CDB40000019B193E8A81D29C028806B010A02190A20860C03286D9220064401B90018000080B29020251003F0200240400498118140D48
...    4362194088512F08E54140188AA88008C00609D500070887F400E0402188001C221FB8005C0C045100038443F7000B820086200070887EE08170501144000E110FDC102080000
...    0286181018202C0E0BA000E5000000001002000C04803305C0030000000280059F10082320400000000002800554D80800800000013D0050A51451E52853253C5463857FFD102
...    0A080A261631080D095C68036128D50000027319448A81D29C028806B010A02190A20860C0328A79420064401B90018000080B2902025100400200240400498118140D4843621
...    94088512F08E54140188AA88008C00609D5000E04881400E04021880038122038005C0C04510007024407000B8200862000E04880E08170501144001C09101C10208000002861
...    81018202C0E0BA001C5000000001002000C04803305C0030000001B8002573810232040000000001B800230281000800000013D0050A51451E52853253C546383FFE0


@{UE_expect}
...    sCellIndex 1,    physCellId 63
...    sCellIndex 2,    physCellId 64

@{UE_expect_2}
...    pcid:51, scellIdx:1
...    SCellIndex 1 activated successfully at airphone

*** Test Cases ***
CB008140-ET-GH006_NG inter-freq Handover outgoing to 3rd gnb in IgNB-CA mode TFF to inter-gNB CA covBasedA1_rsrpCombined
    [Documentation]
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz Cellid=0x4001
    ...    type0coresetconfigurationIn
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz type0coresetconfigurationIndex=10
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=50
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=50 scs=15kHz
    ...    type0coresetconfigurationIndex=10
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz SCellWeight=50 Cellid=0x800C/32780
    ...    Cell id=5 gnb=4 pci=21:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=50 Cellid=0x8C005/573445
    ...    Cell id=6 gnb=4 pci=21:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz SCellWeight=50 Cellid=0x8C006/573446
    ...    2.Test Case Steps:
    ...    a. UE1 Register And PDU Session Setup On Cell1_1
    ...    b. UE1 trigger A2
    ...    c. UE1 trigger A3 handover from Cell1_1 to Cell3_3
    ...    d. UE1 trigger A1 add Cell1_2
    ...    3. Expected Results:
    ...    Step a: UE1 Register And PDU Session Setup Successful, covBasedA1_rsrpCombined Add Cell5 and Cell6 as Scell
    ...    counter:IGNB_CA_ATT_2_SCELL_SA_SUCC
    ...    Step b: UE1 A2 trigger success and A3 measid 4
    ...    Step c: UE1 handover success, and
    ...    NGAP UEContextReleaseCommand
    ...    NGAP UEContextReleaseComplete
    ...    XnAP IgNBCAReleaseRequest counter:IGNB_CA_ATT_SA_REL
    ...    XnAP IgNBCAReleaseRequestAcknowledge
    ...    Step d: UE1 add scell success
    [Tags]    GH006    QC_277931    CA_LABEL-TFF (100MHz_TDD_n77+ 10MHz_FDD_n3+ 15MHz_FDD_n28)
    Clear Counter Files for 2GNB
    Setup XpAP Link
    Set Sim gNB ignb CA Addition Param
    Ue Register And PDU Session Setup Without Scell Addition    ue_id=1
    UE Send A1 To Trigger 3CC CA setup
    InterGnb InterFreq Handover From Phy50 to Phy52
    UE Send A1 To Trigger 2CC CA setup
    Release UEs    ue_type=all
    Check Counters    ${PM_Counters_Check_GNB1}
    Check Counters GNB2    ${PM_Counters_Check_GNB2}


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F    ue_count=2

Modify Cfg
    ${gNB4_sim_configuration}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124
    ...    nssai=0x1:0xd143a5 amf=1 xp=10.0.1.124:32742 xpu=10.0.1.124:32742 xp_management=on
    Update Cfg    ${gNB4_sim_configuration}
    ${gNB4_Cell5_sim_configuration}    catenate
    ...    set_cell id=5 gnb=4 pci=21:0 tac=200 nrci=0x05 tdd_cell=off proxy=10.0.2.90:9999 nr_arfcn=349400:368400 gscn=4605
    ...    nr_scs=15kHz bs_channel_bandwidth=10MHz mandatory_for_activation=off
    Update Cfg    ${gNB4_Cell5_sim_configuration}
    ${gNB4_Cell6_sim_configuration}    catenate
    ...    set_cell id=6 gnb=4 pci=21:1 tac=200 nrci=0x06 tdd_cell=off proxy=10.0.2.91:9999 nr_arfcn=143400:153400 gscn=1916
    ...    nr_scs=15kHz bs_channel_bandwidth=15MHz mandatory_for_activation=off
    Update Cfg    ${gNB4_Cell6_sim_configuration}
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_2CC_n77_n3_n28_n78_CA}
    ${gNB4_sim_configuration}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=663400:663400 mandatory_for_activation=off gscn=8159

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

Perform Steps After Onair
    Get Correct Xp XgU Version

Get Correct Xp XgU Version
    ${IgNBCAXpProtocol_Version}    Get Xp Version
    ${IgNBCAXgUProtocol_Version}    Get Xgu Version
    Set Suite Variable    ${IgNBCAXpVersion}    ${IgNBCAXpProtocol_Version}
    Set Suite Variable    ${IgNBCAXgUVersion}    ${IgNBCAXgUProtocol_Version}

Setup XpAP Link
    Execute Egate Command    sim_trace enb=4 protocol=xp,xn on
    ${ret1}=    Execute Egate Command    enb_xp_param xp_peers=2 id=4    pass_regexp=${expect}    timeout=180s

Set Sim gNB ignb CA Addition Param
    ${gNB4_param}    catenate
    ...    gnb_param id=4 bwp_profile_id=1 bwp_profile_type=powersaving act_multiple_dedicated_bwps=yes location_bw_ul=1:2 location_bw_dl=3:4
    ...    Inter_gNB_CA_Allowed=yes CellLoadReportingPeriodicity=000 IgNBCAXpProtocolVersion=${IgNBCAXpVersion}
    ...    IgNBCAXgUProtocolVersion=${IgNBCAXgUVersion}
    Execute Egate Command    ${gNB4_param}
    Execute Egate Command    gnb_cell_param gnb=4 id=5 Cell_BWP_List=1,2 cell_Available=yes weightForSCellSelection=80 lteNrDssMode=lteNrDssModeNone
    Execute Egate Command    gnb_cell_param gnb=4 id=6 Cell_BWP_List=1,2 cell_Available=yes weightForSCellSelection=80 lteNrDssMode=lteNrDssModeNone
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=4 target=2    pass_regexp=Sent to GNB-2
    ${gNB4_param_ca_addition}    catenate
    ...    ignb_ca_addition_param gnb_id=4 DU-to-CU-RRCInfo=${DU-to-CU-RRCInfo} ExtDu-to-PrimeDu-RrcInfo=${ExtDu-to-PrimeDu-RrcInf}
    Execute Egate Command    ${gNB4_param_ca_addition}

Ue Register And PDU Session Setup Without Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table
    ...    fail_regexp=activated successfully at airphone
    Sleep    5s    #wait

UE Send A1 To Trigger 3CC CA setup
    [Arguments]    ${ue_id}=1    ${scell1pci}=60    ${scell2pci}=61
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A1 srsrp_nr=32 srsrq_nr=32
    ...    pass_regexp=@{UE_expect}

UE Send A1 To Trigger 2CC CA setup
    [Arguments]    ${ue_id}=1    ${scell1pci}=51
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=5 event=A1 srsrp_nr=101 srsrq_nr=101
    ...    pass_regexp=@{UE_expect_2}

InterGnb InterFreq Handover From Phy50 to Phy52
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=30 srsrq_nr=30
    ...    pass_regexp=eventA3
    Sleep    1s    #wait
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=4 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=52 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to EXT_ENB-3.3 performed
    Execute Egate Command    ue_disp state=ACTIVE    3.3
