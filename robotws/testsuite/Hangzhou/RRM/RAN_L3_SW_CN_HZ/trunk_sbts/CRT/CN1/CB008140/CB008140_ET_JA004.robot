*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOOO]_SANSA_FS_ECPRI_CMWV_TDD    team-Jazz
...    owner-lingyan.zhou    release-SBTS23R3    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    True
@{FAULTS_EXCLUDED_CHECKING}
...    6450
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB1_A2_for_NRCELL_1}
...    @{LOLO_LOO}
@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_CA_for_NRCELL_A2rel}
@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
@{PARAMS_FOR_GNB1}
...    NRBTS:actGnbInitRlf=false
...    NRBTS:ngInducedCellDeactDelayTimer=60
...    NRCELL-1:sCellDeactivationTimerGNB=ms1280
...    NRCELL-1:maxNumScellsDlFr1=3
...    NRCELL-2:maxNumScellsDlFr1=3
...    NRCELL-2:sCellDeactivationTimerGNB=ms1280
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa
...    NRDRB_RLC_AM-1:dlMaxRetxThreshold=t32
...    NRDRB_RLC_AM-1:dlTPollRetr=ms250
...    NRDRB_RLC_AM-2:dlMaxRetxThreshold=t32
...    NRDRB_RLC_AM-2:dlTPollRetr=ms250
...    NRCELL-1:gscnOrSsPbchArfcn=8157
...    NRCELL-1:nrarfcn=662772

@{LOLO_LOO}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=10
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=653400
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=4
...    NRBTS/NRADJNRCELL-4:nrarfcn=648000
...    NRBTS/NRADJNRCELL-4:physCellId=53
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=2
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=153400
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=28
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=4
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=2
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=2
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=60|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-1:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-1:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:nrCellType=4DL2UL
...    NRCELL-1:beamSet:basicBeamSet=beamSet_2
...    NRCELL-2:beamSet:basicBeamSet=beamSet_2
...    NRBTS/NRCELLGRP-0:numberOfTransmittedSsBlocks=2 beams
...    NRBTS/NRCELLGRP-1:numberOfTransmittedSsBlocks=2 beams
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly

@{PARAMS_FOR_GNB2}
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actGnbInitRlf=false
...    NRCELL-3:sCellDeactivationTimerGNB=ms1280
...    NRCELL-4:sCellDeactivationTimerGNB=ms1280
...    NRCELL-11:sCellDeactivationTimerGNB=ms1280
...    NRCELL-12:sCellDeactivationTimerGNB=ms1280
...    NRCELL-3:weightForSCellSelection=10
...    NRCELL-4:weightForSCellSelection=30
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=60
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRDU-1:actConnectedModeMobilityCA=false
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa
...    NRDRB_RLC_AM-1:dlMaxRetxThreshold=t32
...    NRDRB_RLC_AM-1:dlTPollRetr=ms250
...    NRDRB_RLC_AM-2:dlMaxRetxThreshold=t32
...    NRDRB_RLC_AM-2:dlTPollRetr=ms250

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=662772
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0

@{GNB2_CA_for_NRCELL_A2rel}
...    NRCELL-4:a2MeasSCellRelEnabled=rsrp
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=33|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-4:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=23|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrq
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=31|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=21|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-12:a2MeasSCellRelEnabled=rsrpAndRsrq
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=32|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-12:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=22|a2TimeToTriggerSCellRelSsbRsrq=0ms

@{GNB1_A2_for_NRCELL_1}
...    NRCELL-1:a2MeasSCellRelEnabled=rsrq
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=5120ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=5120ms
...    NRCELL-1:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=5120ms
...    NRCELL-1:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=35|a2TimeToTriggerSCellRelSsbRsrq=5120ms

#4cc TTFF ue capa srs is 1, rank is 1
${SA_Capa_Support_CA}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C47013B8D80D81AC1184341020E90186D6C98AB1A1CF
...    88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D805AC1184341020F1018656C98AB121CFB027C471
...    E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B133582308682041D2030C2D931544439F11C788E3D033EC09F18E
...    7CC31E50B0381C3C17003FF001C00FFC000B000E0541B06F582308682041E2030CAD931562439F11C7B027C62471E439F51CF9863CA16070
...    38784FFF800003FFE0000016001C0AA3626EB04610D000002006185B24CA88873E238F20C7A067D813E01CF9863CA1607038782F55555553
...    D555555416001C012587898001C4C000000160562E2600071300038980000042C0AC5C02000C260184C0001058158F80400181B030980613
...    00006160562E0100060080C0D800102C0AC7C02000C030181B0309A00050B02B1700800303606130000C160561E010006130000E160561E0
...    100060080010160561E0D800606C0012160561E0100060180014160561E03000606C0016160562E0100060180C0D800302C0AC3C1B000E26
...    00000D0B02B1713000309806008001C160563E2600061300C010181B0007858158B8980018020303600100B02B1F134003004060180C0D80
...    0442C08048037001A0264002809A0E9D212851226C73E1C4891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C38D1224489B1C
...    F871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3851226C73E1C4891226C73E1C68
...    912244D8E7C38912244D8E7C38D1224489B1CF8603624318C6318C6318C6318C63183D04C00F000A07050070300740380030120020301F04
...    8010000000080040000001000002008000010040000100200000C01000008008000050040020080200800006004000038020010000000400
...    004002000024010000060080000A004000058020010240900400006019CA9BCA9AC14AC0CAC19AC15ACA5BC99BC05AC0DAC04AC08AC1DA06
...    82000012CA4A080000CB29202000032CA48080001CB29202000092CA48080002CB293020000D2CA48080003CB29202000112CA48080004CB
...    29202000152CA48080005CB29282000192CA480800018B292019A55574AA2A9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F
...    1414178095028140A05028140A05028140A05028140A05028140044202004008080100220100200404008010100200440201802808010020
...    2004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C014040300601002004402018028080600A020
...    040084040300501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C0201802840
...    40300601002004402004008080100202018028C04010020100400804030050100C014402004008080600C02018030C04008010100C014040
...    30060100C0146A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B4

${Capa_LTE}    SEPARATOR=
...    A11FF82384C0C03898001C46000000122205C160601C46000002022205C16060184C00010488817078500018460001848881007011A014003
...    80982E0006504893A24ED8E7C3853A76C0000449D1276C000044036000000C018800020101002008040300608000402020180304000201010
...    0200020200401008060000

${F1_DU_P_RESET_RCV}           M55117C01512
${F1_DU_P_RESET_ACK_SENT}      M55117C01513
${E1_RESET_SENT_CUCP}       M55121C00501
${E1_RESET_ACK_RECD_CUCP}      M55121C00502
${XN_RESET_REQUEST_SENT}         M55126C00012
${XN_RESET_REQUEST_RECEIVED}        M55126C00010
${XN_RESET_RESPONSE_SENT}       M55126C00011
${XN_RESET_RESPONSE_RECEIVED}         M55126C00013
#F1_DU_P_RESET_RCV (M55117C01512) shall be increased by gNB-DU when a RESET message for Partial Reset is received on F1.
#F1_DU_P_RESET_ACK_SENT (M55117C01513) shall be increased by gNB-DU when a RESET ACKNOWLEDGE for Partial Reset is sent out on F1.
#E1_RESET_SENT_CUCP (M55121C00501) shall be increased by gNB-CU-CP when a RESET message for is sent out on E1.
#E1_RESET_ACK_RECD_CUCP (M55121C00502) shall be increased by gNB-CU-CP when a RESET ACKNOWLEDGE message is received on E1.
#XN_RESET_REQUEST_SENT(M55126C00012) shall be increased by gNB-CU-CP when a RESET REQUEST message for Partial Reset is sent out on XN.
#XN_RESET_REQUEST_RECEIVED(M55126C00010) shall be increased by gNB-CU-CP when a RESET REQUEST message for Partial Reset is received on XN.
#XN_RESET_RESPONSE_SENT(M55126C00011) shall be increased by gNB-CU-CP when a RESET RESPONSE for Partial Reset is sent out on XN.
#XN_RESET_RESPONSE_RECEIVED(M55126C00013) shall be increased by gNB-CU-CP when a RESET RESPONSE for Partial Reset is received on XN.
${NG_CU_RESET_REQ_SENT}           M55119C00011
${NG_CU_RESET_ACK_RCV}      M55119C00014
${F1_CU_P_RESET_RCVD}       M55150C00006
${F1_CU_P_RESET_ACK_MSG_SENT}    M55150C00007
${F1_DU_P_RESET_ATT}             M55117C01514
${F1_DU_P_RESET_SUCC}             M55117C01515
${XN_UEREL_OUTGOING_RESET}        M55126C00019
#NG_CU_RESET_REQ_SENT (M55119C00011) shall be incremented every time an NGAP : NG Reset message is sent by the gNB-CU.
#NG_CU_RESET_ACK_RCV (M55119C00014) shall be incremented every time an NGAP : NG Reset Acknowledge message is received by the gNB-CU.
#F1_DU_P_RESET_ATTM (M55117C01514) shall be incremented when partial F1AP: Reset is sent by gNB-DU.
#F1_CU_P_RESET_RCVD(M55150C00006) shall be incremented when partial F1AP: Reset message is received by gNB-CU.
#F1_DU_P_RESET_SUCC (M55117C01515) shall be incremented when F1AP: F1 Reset Acknowledge message is received by gNB-DU.
#XN_UEREL_OUTGOING_RESET (M55126C00019) shall be incremented UE context releases due to outgoing Xn Reset
@{PM_Counters_Check_GNB1}
...    NRDU-1:NF1CD:${F1_DU_P_RESET_RCV}=2
...    NRDU-1:NF1CD:${F1_DU_P_RESET_ACK_SENT}=2
...    NRBTS-1:NE1CB:${E1_RESET_SENT_CUCP}=2
...    NRBTS-1:NE1CB:${E1_RESET_ACK_RECD_CUCP}=2
...    NRBTS-1:NXNCB:${XN_RESET_REQUEST_SENT}=2
...    NRBTS-1:NXNCB:${XN_RESET_REQUEST_RECEIVED}=0
...    NRBTS-1:NXNCB:${XN_RESET_RESPONSE_SENT}=0
...    NRBTS-1:NXNCB:${XN_RESET_RESPONSE_RECEIVED}=2

@{PM_Counters_Check_GNB2}
...    NRDU-1:NF1CD:${F1_DU_P_RESET_RCV}=2
...    NRDU-1:NF1CD:${F1_DU_P_RESET_ACK_SENT}=2
...    NRBTS-2:NXNCB:${XN_RESET_REQUEST_RECEIVED}=2
...    NRBTS-2:NXNCB:${XN_RESET_RESPONSE_SENT}=2

@{JB02_PM_Counters_Check_GNB1}
...    NRBTS-1:NNGCB:${NG_CU_RESET_REQ_SENT}=1
...    NRBTS-1:NNGCB:${NG_CU_RESET_ACK_RCV}=1
...    NRDU-1:NF1CD:${F1_DU_P_RESET_RCV}=1
...    NRDU-1:NF1CD:${F1_DU_P_RESET_ACK_SENT}=1
...    NRDU-1:NF1UU:${F1_CU_P_RESET_RCVD}=1
...    NRDU-1:NF1UU:${F1_CU_P_RESET_ACK_MSG_SENT}=1
...    NRDU-1:NF1CD:${F1_DU_P_RESET_ATT}=1
...    NRDU-1:NF1CD:${F1_DU_P_RESET_SUCC}=1
...    NRBTS-1:NXNCB:${XN_RESET_REQUEST_SENT}=1
...    NRBTS-1:NXNCB:${XN_RESET_RESPONSE_RECEIVED}=1
...    NRBTS-1:NXNCB:${XN_UEREL_OUTGOING_RESET}=1

@{JB02_PM_Counters_Check_GNB2}
...    NRBTS-2:NXNCB:${XN_RESET_RESPONSE_SENT}=1
...    NRBTS-2:NXNCB:${XN_RESET_REQUEST_RECEIVED}=1
...    NRDU-1:NF1CD:${F1_DU_P_RESET_RCV}=1
...    NRDU-1:NF1CD:${F1_DU_P_RESET_ACK_SENT}=1

@{expected_for_UE2}
...    sCellIndex 1
...    physCellId 53
...    sCellIndex 2
...    physCellId 60
...    sCellIndex 3
...    physCellId 61

*** Test Cases ***
CB008140-ET-JA004_SCTP link failure with oneAMF_caused_related_UE_bulk release then cell lock and recovery
    [Documentation]
    ...    SCTP link failure with oneAMF_caused_related_UE_bulk release then cell lock and recovery
    ...    [Configuration]:
    ...    Cell id=1  gnb=2 pci=16:2 tac=200 tdd_cell=on  band=n77 nr_arfcn=662772:662772 gscn=8159 chBw=100MHz #SCF_gNB1
    ...    Cell id=2  gnb=2 pci=17:0 tac=200 tdd_cell=on  band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz  #SCF_gNB1
    ...    Cell id=3  gnb=3 pci=17:1 tac=200 tdd_cell=on  band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz SCellWeight=50 #SCF_gNB2
    ...    Cell id=4  gnb=3 pci=17:2 tac=200 tdd_cell=on  band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz  SCellWeight=50 #SCF_gNB2
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3  nr_arfcn=349400:368400 gscn=4605 chBw=10MHz  SCellWeight=50 #SCF_gNB2
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz  SCellWeight=50 #SCF_gNB2
    ...    2.Test Case Steps:
    ...         a. NSA UE attach as background UE and ENDC to gNB1 NRCELL_1
    ...         b. 4cc UE2 attach to gNB1_cell1 and make igNB CA with gNB2_cell4, 11, 12 Start Traffic And Verify Throughput
    ...         c. 2cc UE3 attach to gNB2_cell12 and make igNB CA with gNB1_cell1 Start Traffic And Verify Throughput
    ...         d. SCTP failure happend on gNB1_AMF1. UE1, UE2 Bulk release happen. No affect to UE3, NSA UE.
    ...         e. Lock gNB1 cell1 and cell2, UE3 and NSA UE are released as gNB1 cells are deactivation.
    ...         e. unLock gNB1 cell1 and cell2
    ...         f. Make UE2 and UE3 again. igNB CA successful.
    ...    3. Expected Results:
    ...         Step a: Bulk release precedure correct, NG SCTP failure caused E1/F1/X2/XN partial reset.
    ...         Step B: After recover SCTP link and cell unlock, igNB CA functions normal.
    [Tags]    QC_47093    JA004    CA_LABLE-TTFF(100Mhz_TDD_n77+40Mhz_TDD_n77+10Mhz_FDD_n3+15Mhz_FDD_n28)
    Clear Counter Files for 2GNB
    NSA UE attach with traffic
    Make Normal CA SA UE2 with gNB2_PrimGNB1
    Make Normal CA SA UE3 with gNB1_PrimGNB2
    NG SCTPFailure between AMF and GNB1 then lock gNB1 cells
    Recover and igNB CA UE success
    Check Counters    ${PM_Counters_Check_GNB1}
    Check Counters GNB2    ${PM_Counters_Check_GNB2}
    Check Wireshark Log    ${CURDIR}${/}A2A_JA004${/}a2a.ini        wait_string=UEContextRelease::0
    [Teardown]    Restore scf to unlock cells

*** Keywords ***
Recover and igNB CA UE success
    Release UEs    ue_type=all
    Unlock_RecoverCell
    NSA UE attach with traffic    32
    Make Normal CA SA UE2 with gNB2_PrimGNB1
    Make Normal CA SA UE3 with gNB1_PrimGNB2
    Trigger stepwise A2releaes scells213 and check traffic

Restore scf to unlock cells
    Unlock_RecoverCell
    Common Test Teardown And Stop Capture Logs

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Modify Cfg
    ${gNB2_cell1_configuration}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=662772:662772 mandatory_for_activation=off gscn=8157
    Update Cfg    ${gNB2_cell1_configuration}
    ${gNB4_sim_configuration}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124
    ...    nssai=0x1:0xd143a5 amf=1 xp=10.0.1.124:32742 xpu=10.0.1.124:32742 xp_management=on
    Update Cfg    ${gNB4_sim_configuration}
    ${gNB4_Cell11_sim_configuration}    catenate
    ...    set_cell id=6 gnb=4 pci=21:0 tac=200 nrci=0x06 tdd_cell=off proxy=10.0.2.90:9999 nr_arfcn=349400:368400 gscn=4605
    ...    nr_scs=15kHz bs_channel_bandwidth=10MHz mandatory_for_activation=off
    Update Cfg    ${gNB4_Cell11_sim_configuration}
    ${gNB4_Cell12_sim_configuration}    catenate    set_cell id=7 gnb=4 pci=21:1 tac=200 nrci=0x07 tdd_cell=off proxy=10.0.2.91:9999
    ...    nr_arfcn=143400:153400 gscn=1916 nr_scs=15kHz bs_channel_bandwidth=15MHz mandatory_for_activation=off
    Update Cfg    ${gNB4_Cell12_sim_configuration}
    ${gNB4_Cell4_sim_configuration}    catenate    set_cell id=5 gnb=4 pci=18:0 tac=200 nrci=0x05 tdd_cell=on proxy=10.0.2.92:9999
    ...    nr_arfcn=648000:648000 gscn=8000 nr_scs=30kHz bs_channel_bandwidth=40MHz
    Update Cfg    ${gNB4_Cell4_sim_configuration}
    Update Cfg    ue_param id=1-10 ue_nr_capabilities=${SA_Capa_Support_CA}

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2


Make Normal CA SA UE2 with gNB2_PrimGNB1
    Sa Ue Attach    2    2   1
    Setup pdu session with no scelladd    2    2    2
    trigger A1 MR to add scell    85    2
    Send And Verify Throuput    2


Make Normal CA SA UE3 with gNB1_PrimGNB2
    Sa Ue Attach    3    3    12
    Setup pdu session with with scelladd    3    3    2
    Send And Verify Throuput_2cc

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=2    ${pass_regexp}=NG RM Register
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_Support_CA}
    Execute Egate Command    sim_debug_log level=4
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}

Setup pdu session with no scelladd
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${pdu_id}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gateway}
    ...    pass_regexp=QoS Routing Table
    Should Not Contain    ${ret1}    sCellIndex 1

Setup pdu session with with scelladd
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${pdu_id}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gateway}    pass_regexp=sCellIndex 1

Send And Verify Throuput_2cc
    [Arguments]    ${ue_id}=3
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throuput on 2cc    sleep_time=30s

Update NSAUE capa
    [Arguments]    ${ue_id}=31    ${Capa_LTE}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_Support_CA}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Execute Egate Command    ${cmd}

NSA UE attach with traffic
    [Arguments]    ${ue_id}=31    ${target_cells}=1    ${Capa_LTE}=${Capa_LTE}
    Update NSAUE capa    ${ue_id}    ${Capa_LTE}
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    ${cmd}    catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}    successful RA
    NSA UE Sent TP    ${ue_id}

NSA UE Sent TP
    [Arguments]    ${ue_id}=31
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=10 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    sleep for traffic stable
    NSA UE Verify TP    ${ue_id}

NSA UE Verify TP
    [Arguments]    ${ue_id}=31
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>9

NG SCTPFailure between AMF and GNB1 then lock gNB1 cells
    Execute Egate Command    link_drop link=ng by=amf:1 to=gnb:2 msg_type=shutdown     pass_regexp=Link drop
    Check BTS state
    Check UE3 and NSA UE should be alive
    Lock gNB1 Cells

Lock gNB1 Cells
    Lock Cell1
    Lock Cell2

Unlock_RecoverCell
    Unlock Cell1
    Cells Should Be Onair    1
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:administrativeState=Unlocked
    Unlock Cell2
    Cells Should Be Onair    2
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-2:administrativeState=Unlocked
    Sleep    120s    sleep for igNBCASetup/igNBXPsetup


Check BTS state
    [Arguments]    ${operationalState}=onAir
    Object Should Exist    NRBTS:operationalState=${operationalState}


Check UE3 and NSA UE should be alive
    Execute Egate Command    ue_disp id=3    pass_regexp=ACTIVE
    Verify Throuput on 2cc
    NSA UE Verify TP    31


Verify Throuput on 2cc
    [Arguments]    ${ue_id}=3    ${sleep_time}=30s
    sleep    ${sleep_time}    sleep for traffic stable
    ${ret0}=    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>0
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000>0
    ${total_dl}    Evaluate    ${scell0_tput}+${scell1_tput}
    Should Be True    ${total_dl}/1000>140



trigger A1 MR to add scell
    [Arguments]    ${rsrp}=80    ${ue_id}=1    ${ssbfreq}=663168
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${ssbfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrq_nr=70 srsrp_nr=${rsrp}
    ...    pass_regexp=${expected_for_UE2}    timeout=20s


Send And Verify Throuput
    [Arguments]    ${ue_id}=91
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throuput on Pscell    sleep_time=30s


Trigger stepwise A2releaes scells213 and check traffic
    trigger A2 MR to stepwise release scells 213
    Verify Throuput on Pscell for common dlul    ue_id=2    sleep_time=20s    expect_dl_TP=438
    trigger A1 MR to add scell    85    ue_id=2
    start some traffic
    Verify Throuput on Pscell    sleep_time=20s

trigger A2 MR to stepwise release scells 213
    get scell A2 measid and trigger A2 to release cell    368430    2
    Check throught for 2scells    2    30s    3    50    1    150
    stop some traffic
    get scell A2 measid and trigger A2 to release cell    648096    1
    Check throught for 1scells    2    10    3    50    270
    get scell A2 measid and trigger A2 to release cell    153370    3

Verify Throuput on Pscell for common dlul
    [Arguments]    ${ue_id}=2    ${sleep_time}=30s    ${expect_dl_TP}=430
    sleep    ${sleep_time}    sleep for traffic stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${expect_dl_TP}
    Should Be True    ${ul_throughput}/1000>8

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=2    ${sleep_time}=30s
    sleep    ${sleep_time}    sleep for traffic stable
    ${ret0}=    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>0
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000>0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000>0
    ${scell3_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    Should Be True    ${scell3_tput}/1000>0
    ${total_dl}    Evaluate    ${scell0_tput}+${scell1_tput}+${scell2_tput}+${scell3_tput}
    Should Be True    ${total_dl}/1000>740

start some traffic
    Execute Egate Command    data_trf_start ue=2 pdu=2 qfi=1 dir=dl mbps=150 trf_id=6    UE 2: UDP DL
    Execute Egate Command    data_trf_start ue=2 pdu=2 qfi=1 dir=dl mbps=100 trf_id=7    UE 2: UDP DL
    sleep    4s    wait traffic stab

get scell A2 measid and trigger A2 to release cell
    [Arguments]    ${carrierfreq}=648096    ${id}=30s
    ${meas_id_scell}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=2    carrierfreq=${carrierfreq}    event_type=A2
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=${meas_id_scell} event=A2 scell=${id} scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    sCellToReleaseList


Check throught for 2scells
    [Arguments]    ${ue_id}=2    ${sleep_time}=30s    ${s1_id}=1    ${s1_tp}=40    ${s2_id}=2    ${s2_tp}=60
    sleep    ${sleep_time}    sleep for traffic stable
    ${ret0}=    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${scellN1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${s1_id}    type=pdsch    rate_type=current
    Should Be True    ${scellN1_tput}/1000>${s1_tp}
    ${scellN2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${s2_id}    type=pdsch    rate_type=current
    Should Be True    ${scellN2_tput}/1000>${s2_tp}
    Verify Throuput on Pscell for common dlul

stop some traffic
    Execute Egate Command    data_trf_stop ue=2 pdu=2 qfi=1 dir=dl trf_id=6    Traffic was stopped
    Execute Egate Command    data_trf_stop ue=2 pdu=2 qfi=1 dir=dl trf_id=7    Traffic was stopped
    sleep    4s    wait traffic stab

Check throught for 1scells
    [Arguments]    ${ue_id}=2    ${sleep_time}=30s    ${s_id}=1    ${s_tp}=60    ${expect_dl_TP}=270
    sleep    ${sleep_time}    sleep for traffic stable
    ${ret0}=    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${s_id}    type=pdsch    rate_type=current
    Should Be True    ${scell_tput}/1000>${s_tp}
    Verify Throuput on Pscell for common dlul    sleep_time=20s    expect_dl_TP=${expect_dl_TP}

F1 DU Partial Reset
    Execute Cmd On Gnb    bsh 1:0 ps -ef|grep /node_UPUE|grep -i lxc-start |awk '{print $2}'| bsh 1:0 xargs kill -9
    sleep    2s    wait for cmd take effect
    Check UE3 should be alive

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=3    ${sleep_time}=30s
    sleep    ${sleep_time}    sleep for traffic stable
    ${ret0}=    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>63

Check UE3 should be alive
    Execute Egate Command    ue_disp id=3    pass_regexp=ACTIVE
    Verify Throuput on Pcell

Wait Cell On Air then Make Normal CA SA UE2
    Sleep    120s    sleep for ABIO reboot and igNBCASetup/igNBXPsetup
    Release UEs    ue_type=all
    Make Normal CA SA UE2 with gNB2_PrimGNB1
