*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]    team-L3CN1_SG14
...    owner-ye.3.ye    release-SBTS23R4    CRT    RAN_5G_FDD    RAN_5G_TDD
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

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

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=80
...    NRBTS:actIncXn=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB

@{PARAMS_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actBcsCheck=enabled_FR1
...    NRBTS:rejectSuppBcs=none
...    NRCELL-11:iniNumSCellsToActivate=3
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL-11:allowUnsuppBcOrBcs=complete BCS check

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=40
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=653400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=648000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=41
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=513300
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=41
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=4
...    NRBTS/NRADJNRCELL-4:nrarfcn=509220
...    NRBTS/NRADJNRCELL-4:physCellId=53
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=2
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=2
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=2
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-3:lcrId=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-4:gNbId=2
...    NRCELL-11/NRREL-4:gNbIdLength=22
...    NRCELL-11/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-4:lcrId=4
...    NRCELL-11/NRREL-4:removeNotAllowed=false
...    NRCELL-11/NRREL-4:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-4:gnbPlmn:mncLength=3

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL-3:chBw=80MHz
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:nrCellType=4DL2UL
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-3:actBeamforming=true
...    NRCELL-3:nrCellType=4DL2UL
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:actBeamforming=true
...    NRCELL-4:nrCellType=4DL2UL
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-4:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-3:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-3:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=3/7
...    NRCELL-1:weightForSCellSelection=60
...    NRCELL-2:weightForSCellSelection=10
...    NRCELL-3:weightForSCellSelection=60
...    NRCELL-4:weightForSCellSelection=20
...    @{LOLO_AP_LOO}

@{LOLO_AP_LOO}
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-2/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-2/EQM-1/APEQM-1/RMOD-4/PHYANT-1

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=40
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
@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false

#golden_not_suppoet_n3A_n41_n77_CA_BandCombination
${SA_Capa_Support_3CC_n3A_n41_n77_CA}    SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C05EE3603606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C790E7D4
...    73E618F28581C0E1E0BFFFFF800FFF8BE000C80000E0541B00B582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000C8
...    0000E0551B133582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0D837AC1184341020F10780195B262AC
...    4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC00000640000702A8D89BAC1184340000080780185B24CA88873E238F20C7A067D813E01CF9863CA160703
...    8782F557FF553D55FFD54320000381546C28D608C21A08707403C00C2D926544439F11C79063D033EC09F18E7CC31E50B0381C3C17AABFFAA9EAAFFEAA1900001C01558789800
...    1C4C000000160562E2600071300038980000042C0AC5C02000C260184C0001058158F80400181B03098061300006160562E0100060080C0D800102C0AC7C02000C030181B0309
...    A00050B0BAC5C02000C0D8184C0003058158780400184C000385815878040018020004058158783600181B000485815878040018060005058158780C00181B0005858158B8040
...    0180603036000C0B02B0F06C0038980000342C0AC5C4C000C26018020007058158F89800184C030040606C001E160562E2600060080C0D800402C0AC7C4D000C0101806030360
...    0110B02B0F1340038040800482C0AC7C02000C0D8184D0309A00130B0BAC5C02000C140184C000A0585C02C01B800D0132001404D80503280101110AC28913639F0E244891363
...    9F0E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1
...    C28913639F0E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7C3851226C73E1C68912244D8E7C38912244D8E7C3001F1518C6318C6318C6318C6318C63181E
...    836001E00140E0A00E0601280380030120020301F048010000000080040000001000006008000010040000100200000C010000080080000500400200802008000060040000380
...    20010000000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5BC19BC05AC0DAC04AC08AC1DA0682000012CA4A080
...    000CB29302000032CA48080001CB29202000092CA48080002CB293020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA48080001
...    8B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F14340178095028140A05028140A05028140A05028140A0502814005020200400808010022
...    01002004040080101002004402018028080100202004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C01404030060100200440201802
...    8080600A020040084040300501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C0201802840403006010020044020
...    04008080100202018028C04008010100200404030050100C014402004008080600C02018030C04008010100C01404030060100C014202004008081200A30100C0140403006010
...    02004040080110080600A0200400808010023543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

#set simultaneousRxTxInterBandCA to not support and simultaneousRxTxInterBandCAPerBandPair has value [1 1 0]
${SA_Capa_Support_3CC_n3A_n41_n77_CA_with_parameters_set}    SEPARATOR=
...    E9E09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C05EE3603606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C790E7D4
...    73E618F28581C0E1E0BFFFFF800FFF8BE000C80000E0541B00B582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000C8
...    0000E0551B133582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0D837AC1184341020F10780195B262AC
...    4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC00000640000702A8D89BAC1184340000080780185B24CA88873E238F20C7A067D813E01CF9863CA160703
...    8782F557FF553D55FFD54320000381546C28D608C21A08707403C00C2D926544439F11C79063D033EC09F18E7CC31E50B0381C3C17AABFFAA9EAAFFEAA1900001C01558789800
...    1C4C000000160562E2600071300038980000042C0AC5C02000C260184C0001058158F80400181B03098061300006160562E0100060080C0D800102C0AC7C02000C030181B0309
...    A00050B0BAC5C02000C0D8184C0003058158780400184C000385815878040018020004058158783600181B000485815878040018060005058158780C00181B0005858158B8040
...    0180603036000C0B02B0F06C0038980000342C0AC5C4C000C26018020007058158F89800184C030040606C001E160562E2600060080C0D800402C0AC7C4D000C0101806030360
...    0110B02B0F1340038040800482C0AC7C02000C0D8184D0309A00130B0BAC5C02000C140184C000A0185C02C01B800D0132001404D80503280101110AC28913639F0E244891363
...    9F0E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1
...    C28913639F0E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7C3851226C73E1C68912244D8E7C38912244D8E7C3001F1518C6318C6318C6318C6318C63181E
...    836001E00140E0A00E0601280380030120020301F048010000000080040000001000006008000010040000100200000C010000080080000500400200802008000060040000380
...    20010000000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5BC19BC05AC0DAC04AC08AC1DA0682000012CA4A080
...    000CB29302000032CA48080001CB29202000092CA48080002CB293020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA48080001
...    8B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F14340178095028140A05028140A05028140A05028140A0502814005020200400808010022
...    01002004040080101002004402018028080100202004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C01404030060100200440201802
...    8080600A020040084040300501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C0201802840403006010020044020
...    04008080100202018028C04008010100200404030050100C014402004008080600C02018030C04008010100C01404030060100C014202004008081200A30100C0140403006010
...    02004040080110080600A0200400808010021868A8000000000000004801803543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

@{activatedSuccessfullyAirphoneCheck}
...    pcid:52, scellIdx:2
...    pcid:50, scellIdx:1
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 1 activated successfully at airphone

*** Test Cases ***
CB008140_ET_GF017_Verify_successful_FTT_scell_addition_when_TDD_cells_has_different_frame_structure_with_simultaneousRxTxInterBandCA_supported_in_BC
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    a successful IgNB-CA SCell Addition procedure for UE1, with the configuration of two TDD ext-SCells with different frame structure.
    ...    a successful IgNB-CA SCell Addition procedure for UE2, with the configuration of two TDD ext-SCells with different frame structure and
    ...    simultaneousRxTxInterBandCA not supported in BC while simultaneousRxTxInterBandCAPerBandPair supported in BC pair
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_18345, partial covered
    ...    CB008140-GF#B6: Successful ext-SCell Addition of two TDD ext-SCells with different frame structure.  
    ...    [Configuration]:
    ...    Cell id=11 gnb=2 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=345000:364000 gscn=4547 chBw=15MHz
    ...    Cell id=12 gnb=2 pci=20:1 tac=200 tdd_cell=off band=n3 nr_arfcn=355000:374000 gscn=4675 chBw=15MHz
    ...    Cell id=1 gnb=3 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz weightForSCellSelection=60
    ...    frame structure set to 1208
    ...    Cell id=2 gnb=3 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz weightForSCellSelection=10
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=off band=n41 nr_arfcn=513300:513300 gscn=6480 chBw=80MHz weightForSCellSelection=60
    ...    frame structure set to 1070
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=off band=n41 nr_arfcn=509220:509220 gscn=6363 chBw=80MHz weightForSCellSelection=20
    ...    2.Test Case Steps:
    ...         Step a. Ue1 Register And PDU Session Setup On Cell1_11
    ...         Step b. UE1 Run Traffic And Verify Throughput
    ...         Step c. Stop PDU UE1 and release
    ...         Step d. Ue2 Register And PDU Session Setup On Cell1_11
    ...         Step e. UE2 Run Traffic And Verify Throughput
    ...         Step f. Stop UE2 PDU and release
    ...         Step g. wireshark logs check
    ...    3. Expected Results:
    ...         Step a: 
    ...         1).UE1 Register And PDU Session Setup Successful
    ...         2).UE1 adds Scell CELL2_3 and CELL2_5 successfully due to 2 TDD cells has different frame structure and simultaneousRxTxInterBandCA 
    ...            supported in BC
    ...         Step b. UE1 Start Traffic and Verify Throughput is OK
    ...         Step c. PDU and UE deregister successfully for UE1
    ...         Step d:
    ...         1).UE2 Register And PDU Session Setup Successful
    ...         2).UE2 adds Scell CELL2_3 and CELL2_5 successfully due to 2 TDD cells has different frame structure and 
    ...            simultaneousRxTxInterBandCA not supported in BC while simultaneousRxTxInterBandCAPerBandPair supported in BC pair
    ...         Step e. UE2 Start Traffic and Verify Throughput is OK
    ...         Step f. UE2 PDU and deregister successfully
    ...         Step g. wireshark check:
    ...         1).the IntendedTDD-DL-ULConfiguration-NR information provided by gNB-2 to gNB-1 during the Xn Setup procedure, with the 
    ...            XnAP: XN SETUP REQUEST or XnAP: XN SETUP RESPONSE message(it will check in CB008140_ET_GF019)
    ...         2).UE1 and UE2 F+T+T 3CC ingb CA setup properly

    [Tags]    QC_281422
    Ue Register And PDU Session Setup With 3CC Scell Addition    ue_id=1    enb_id=2    cell_id=1
    Run Traffic And Verify Throughput    ue_id=1
    Stop PDU and release UE    ue_id=1
    Ue Register And PDU Session Setup With 3CC Scell Addition    ue_id=2    enb_id=2    cell_id=1
    Run Traffic And Verify Throughput    ue_id=2
    Stop PDU and release UE    ue_id=2
    Check WireShark Log    ${CURDIR}${/}A2A_GF_017${/}a2a.ini    wait_string=UEContextModificationResponse::12
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_GF_017${/}a2a_gnb2.ini    wait_string=IgNBCAReleaseRequestAcknowledge::2
	
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_4T

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_3CC_n3A_n41_n77_CA}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_Support_3CC_n3A_n41_n77_CA_with_parameters_set}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Ue Register And PDU Session Setup With 3CC Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=11
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    
    ...    pass_regexp=${activatedSuccessfullyAirphoneCheck}
    Sleep    5s    #wait all Scell info print

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=3 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=4 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=50 dir=ul
    Verify Throughput    ue_id=${ue_id}    Tput_dl=540    Tput_ul=45

Stop PDU and release UE
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    pass_regexp=Stopped Downlink Internal traffic on Ue
    Release UEs    ue_type=all

#Perform Steps After Onair
#    Check WireShark Log    ${CURDIR}/A2A_GF_017/a2a_NG.ini    wait_string=IgNBCAXpSetupResponse::1