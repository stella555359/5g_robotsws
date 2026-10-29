*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]    team-L3CN1_SG14
...    owner-jun.15.zhang    release-SBTS23R4    CRT
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
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Any_Sa
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:maxNumScellsDlFr1=3
@{PARAMS_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actBcsCheck=enabled_FR1
...    NRBTS:rejectSuppBcs=none
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:allowUnsuppBcOrBcs=complete BCS check
...    NRCELL:tddFrameStructure:frameStructureType=tdLte
...    NRCELL:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/9
...    NRCELL:prachConfigurationIndex=156
...    NRBTS/SNSSAI-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL-1:fPdcchMonOccsnPo=2
...    NRCELL-2:fPdcchMonOccsnPo=2
...    NRBTS/NRSYSINFO_PROFILE-1:systemInformationTargetRate=157
...    NRBTS/NRSYSINFO_PROFILE-2:systemInformationTargetRate=157
...    NRCELL-1:msg1FrequencyStart=0

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=40
...    delete:NRBTS/NRADJGNB-2:xnLinkRef
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=3
...    NRBTS/NRADJNRCELL-1:nrarfcn=653400
...    NRBTS/NRADJNRCELL-1:physCellId=52
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=4
...    NRBTS/NRADJNRCELL-2:nrarfcn=648000
...    NRBTS/NRADJNRCELL-2:physCellId=53
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=11
...    NRBTS/NRADJNRCELL-3:nrarfcn=368400
...    NRBTS/NRADJNRCELL-3:physCellId=60
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=12
...    NRBTS/NRADJNRCELL-4:nrarfcn=153400
...    NRBTS/NRADJNRCELL-4:physCellId=61
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=2
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=4
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=11
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=12
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:weightForSCellSelection=50
...    NRCELL-3:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-3:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-3:tddFrameStructure:lteToNrFrameShift=${EMPTY}
...    NRCELL-3:tddFrameStructure:tdLteUlDlConfig=${EMPTY}
...    NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-4:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-4:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-4:tddFrameStructure:lteToNrFrameShift=${EMPTY}
...    NRCELL-4:tddFrameStructure:tdLteUlDlConfig=${EMPTY}
...    NRCELL-4:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRBTS/SNSSAI-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=40
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
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:lcrId=1
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-1:gNbId=1
...    NRCELL-4/NRREL-1:gNbIdLength=22
...    NRCELL-4/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-1:lcrId=1
...    NRCELL-4/NRREL-1:removeNotAllowed=false
...    NRCELL-4/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-4/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-4/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-1:gnbPlmn:mncLength=3
@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false

@{ADD_XNLINK}
...    NRBTS/NRADJGNB-2:xnLinkRef=1

#UE_Capa: CA_n3A-n41A-n77(2A) with BCS0 and simultaneousRxTxInterBandCA
${SA_Capa_Support_4CC_n3_n41_n77_n77_CA_BCS0_simultaneousRxTxInterBandCA}    SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C04EE3603606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C790E7D
...    473E618F28581C0E1E0B801FF800E000BE000C80000E0541B00B582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000
...    C80000E0551B133582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0D837AC1184341020F10780195B26
...    2AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC00000640000703B8D851FFAC1184341020E907801B5B262AC6873E238F40CFB027C62471E439F51CF
...    9863CA1607038782F557FF553D55FFD5432000038024B0F1300038980000002C0AC5C4C000E26000713000000858158B80400184C0309800020B02B1F008003036061300C260
...    000C2C0AC5C02000C010181B0002058158F8040018060303606134000A160562E01000606C0C26000182C0AC3C02000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D80
...    0242C0AC3C02000C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B00060581587836001C4C00001A160562E2600061300C01000382C0AC78020385000184C030980
...    00F0B02B171300030040606C0020160563E2680060080C030181B00088581009006E003404C800500A065001D212851226C73E1C4891226C73E1C4891226C73E1C68912244D8
...    E7C38912244D8E7C38D1224489B1CF871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3851226C73E1C4891226C73E1C6
...    8912244D8E7C38912244D8E7C38D1224489B1CF8603624318C6318C6318C6318C63183D06C003C00281C1401C0C02500700060240040603E0900200000001000800000020000
...    0C0100000200800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000
...    C0339535953582958195833582B594B7933780B581B58095811583B40D040000259494100001965260400006594901000039652404000125949010000596526040001A594901
...    000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D554
...    1E286802F012A05028140A05028140A05028140A05028140A05028008840400801010020044020040080801002020040088040300501002004040080118080600A0201802808
...    01002020040088040400501010014040580B18080600C02018028080600C02004008804030050100C014040080108080600A02004008404030050100C014202018030080600C
...    10100C018040300508080600A02018028804030050100C018040300508080600C020040088040080101002004040300518080600A02004008080100202004008804008010100
...    C018040300618080100202018028080600C02018028D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680
#UE_Capa: CA_n3A-n41A-n77(2A) with BCS0 and no simultaneousRxTxInterBandCA but simultaneousRxTxInterBandCAPerBandPair has value [011110]
${SA_Capa_Support_4CC_n3_n41_n77_n77_CA_BCS0_simultaneousRxTxInterBandCAPerBandPair_011110}    SEPARATOR=
...    E9E09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C04EE3603606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C790E7D4
...    73E618F28581C0E1E0B801FF800E000BE000C80000E0541B00B582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000C8
...    0000E0551B133582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0D837AC1184341020F10780195B262AC
...    4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC00000640000703B8D851FFAC1184341020E907801B5B262AC6873E238F40CFB027C62471E439F51CF9863
...    CA1607038782F557FF553D55FFD5432000038024B0F1300038980000002C0AC5C4C000E26000713000000858158B80400184C0309800020B02B1F008003036061300C260000C2
...    C0AC5C02000C010181B0002058158F8040018060303606134000A160562E01000606C0C26000182C0AC3C02000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D800242C0
...    AC3C02000C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B00060581587836001C4C00001A160562E2600061300C01000382C0AC78020385000184C03098000F0302
...    B171300030040606C0020160563E2680060080C030181B00088581009006E003404C800500A065001D212851226C73E1C4891226C73E1C4891226C73E1C68912244D8E7C38912
...    244D8E7C38D1224489B1CF871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3851226C73E1C4891226C73E1C68912244D8
...    E7C38912244D8E7C38D1224489B1CF8603624318C6318C6318C6318C63183D06C003C00281C1401C0C02500700060240040603E09002000000010008000000200000C01000002
...    00800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C0339535953
...    582958195833582B594B7933780B581B58095811583B40D040000259494100001965260400006594901000039652404000125949010000596526040001A594901000079652404
...    000225949010000996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E286802F012A
...    05028140A05028140A05028140A05028140A05028008840400801010020044020040080801002020040088040300501002004040080118080600A020180280801002020040088
...    040400501010014040580B18080600C02018028080600C02004008804030050100C014040080108080600A02004008404030050100C014202018030080600C10100C018040300
...    508080600A02018028804030050100C018040300508080600C020040088040080101002004040300518080600A02004008080100202004008804008010100C018040300618080
...    100202018028080600C0201802859A2400000000000900DE000D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

@{GF19_expect}
...    pcid:52, scellIdx:1
...    pcid:53, scellIdx:2
...    pcid:60, scellIdx:3
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
@{GF20_expect}
...    pcid:52, scellIdx:1
...    pcid:53, scellIdx:2
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
@{GF20_unexpect}    sCellIndex3

*** Test Cases ***
CB008140-ET-GF019_Verify successful 4CC TTTF scell addition ext-SCells with different frame structure than PCell with simultaneousRxTxInterBandCA
    [Documentation]
    ...    The successful blind inter-gNB 4CC TTTF SCell addition ext-SCells with different frame structure than PCell.
    ...    [Configuration]:
    ...    Cell id=1  gnb=2 pci=16:2 tac=200 tdd_cell=on  band=n41 nr_arfcn=513300:513300 gscn=6480 chBw=100MHz Cellid=0x4001
    ...    Cell id=2  gnb=2 pci=17:0 tac=200 tdd_cell=on  band=n41 nr_arfcn=510000:510000 gscn=6345 chBw=40MHz  Cellid=0x4002
    ...    Cell id=3  gnb=3 pci=17:1 tac=200 tdd_cell=on  band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz SCellWeight=50 Cellid=0x8003/32771
    ...    Cell id=4  gnb=3 pci=17:2 tac=200 tdd_cell=on  band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz  SCellWeight=50 Cellid=0x8004/32772
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3  nr_arfcn=349400:368400 gscn=4605 chBw=10MHz  SCellWeight=50 Cellid=0x800b/32779
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz  SCellWeight=50 Cellid=0x800c/32780
    ...    GNB1 Cell1_1 tddFrameStructure=1116_0ms: DDDS UUDD DDDD DSUU DDDD, slotIndex:3,13
    ...    GNB2 Cell2_3 tddFrameStructure=1208: DDDS UDDD SUDD DSUD DDSU, slotIndex:3,8,13,18
    ...    GNB2 Cell2_4 tddFrameStructure=1208: DDDS UDDD SUDD DSUD DDSU, slotIndex:3,8,13,18
    ...    UE1 Capa: CA_n3A-n41A-n77(2A) with BCS0 and simultaneousRxTxInterBandCA
    ...    2.Test Case Steps:
    ...         a. Setup XN XP
    ...         b. UE1 Register And PDU Session Setup On Cell1_1
    ...         c. UE1 Start Traffic And Verify Throughput
    ...    3. Expected Results:
    ...         Step a: Pri gNB and ext gNB will exchange Cell tddFrameStructure info
    ...         Step b: UE1 Register And PDU Session Setup Successful, Blind Add Cell2_3, Cell2_4 and Cell2_11 as Scell
    ...         Step c: UE1 Traffic And Throughput is OK
    [Tags]    QC_281423
    UE Register And PDU Session Setup With Blind 3 Scell Addition    ue_id=1
    Run Traffic And Verify Throughput
    Release UEs    ue_type=all

CB008140-ET-GF020_Verify successful 3CC TTT scell addition ext-SCells with different frame structure than PCell with InterBandCAPerBandPair
    [Documentation]
    ...    The successful blind inter-gNB 4CC TTTF SCell addition ext-SCells with different frame structure than PCell.
    ...    [Configuration]:
    ...    Same as CB008140-ET-GF019
    ...    UE2 Capa: CA_n3A-n41A-n77(2A) with BCS0 and no simultaneousRxTxInterBandCA
    ...              UE with bandList [n3,n41,n77,n77] and simultaneousRxTxInterBandCAPerBandPair under lateNonCriticalExtension has value [011110]
    ...              Then:[n3,n41]=>0, [n3,n77]=>1, [n3,n77]=>1, [n41,n77]=>1, [n41,n77]=>1, [n77,n77]=>0
    ...    2.Test Case Steps:
    ...         a. UE2 Register And PDU Session Setup On Cell1_1
    ...         b. UE2 Start Traffic And Verify Throughput
    ...    3. Expected Results:
    ...         Step a: UE2 Register And PDU Session Setup Successful, Blind Add Cell2_1 and Cell2_2 as Scell
    ...         Step b: UE2 Traffic And Throughput is OK
    [Tags]    QC_281424
    UE Register And PDU Session Setup With Blind 2 Scell Addition    ue_id=2    gateway=2
    Run Traffic And Verify Throughput    ue_id=2
    Release UEs    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_N41_gnb2_2T2F

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_4CC_n3_n41_n77_n77_CA_BCS0_simultaneousRxTxInterBandCA}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_Support_4CC_n3_n41_n77_n77_CA_BCS0_simultaneousRxTxInterBandCAPerBandPair_011110}

Delta Commission To Setup XN XP
    Delta Commission Parameters    ${ADD_XNLINK}
    Wait Until Keyword Succeeds    180s    2s    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-1:xnLinkStatus=available
    Sleep    60s    #wait Xp setup

UE Register And PDU Session Setup With Blind 3 Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=${GF19_expect}    timeout=20s
    Sleep    5s    #wait all Scell info print

UE Register And PDU Session Setup With Blind 2 Scell Addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=${GF20_expect}
    ...    fail_regexp=${GF20_unexpect}    timeout=20s
    Sleep    5s    #wait all Scell info print

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=3 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=4 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=50 dir=ul
    ...    pass_regexp=Started Uplink Internal traffic over TCP on Ue
    Verify Throughput    ${ue_id}    ${pdu}    ${qfi}    540    45
    [teardown]    Stop Traffic    ${ue_id}    ${pdu}

Stop Traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=1
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=2
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=3
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=4
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=ul trf_id=1
    ...    pass_regexp=Stopping Uplink Internal traffic on Ue

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
