*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    	CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    release-SBTS23R3    owner-jolin.fan    team-jazz
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}


@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:actCDrx=false
...    NRCELL:configuredEpsTac=200
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0

@{PARAMS_FOR_GNB1}
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=41
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=519000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:ssbFrequency=518670
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=41
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=531960
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:ssbFrequency=531870
#...    NRDU-1:interNodeUplaneIpConfig:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/NRCELL-1:a1MeasSCellAddEnabled=rsrq
...    NRBTS/NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=3
...    NRBTS/NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=70
...    NRBTS/NRCELL-1:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=64ms
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=2
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3

@{PARAMS_FOR_GNB2}
...    NRBTS/NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRBTS/NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRBTS/NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=98
...    NRBTS/NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=40ms
...    NRCELL:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:weightForSCellSelection=10
...    NRCELL-3:weightForSCellSelection=30
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=2
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=506010
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=41
...    NRBTS/NRADJNRCELL-1:ssbFrequency=505950
#...    NRDU-1:interNodeUplaneIpConfig:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

@{PARAMS_FOR_OTHERS}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60


...    NRBTS:actRanSharing=false
...    NRCELL:actCsirsMultiplexing=true
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{OnlineParam_GA009_PRI}
...    NRBTS:actMeasBasedSCellAdditionSa=disabled
...    NRBTS/NRCELL-1:a1MeasSCellAddEnabled=none
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind

@{OnlineParam_GA009_EXT}
...    NRBTS:actMeasBasedSCellAdditionSa=disabled
...    NRCELL-2:a2MeasSCellRelEnabled=none
...    NRCELL-3:a2MeasSCellRelEnabled=none

${SA_Capa_Support_3CC_TTT_CA}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47017B8D80D81AC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA
...    39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B00B582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD80000017
...    0000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007FE003801FF8002E0000702A0D837AC1184341020F1068032B64C55
...    890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA3626EB04610D00000201A00C2D926544439F11C79063D033EC09F00E7CC31E50B038
...    1C3C17AAAAAAA9EAAAAAAA170000381DC6C28AAD608C21A00107483401B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1605038782F55555553D55555542E0000700
...    4961E26000713000000058158B850001C28000E140000010B02B17008003098061300004160563E01000606C0C260184C0001858158B8040018020303600040B02B1F0080030
...    0C0606C0C26800142C0AC5C02000C0D8184C0003058158780400184C000385815878040018020004058158783600181B000485815878040018060005058158780C00181B0005
...    858158B80400180603036000C0B02B0F06C0038980000342C0AC5C4C000C26018020007058158F89800184C030040606C001E160562E2600060080C0D800402C0AC7C4D000C0
...    1018060303600110B0201600DC0068099000A026C02817400E909428913639F0E244891360870E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7C38912244
...    D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28913639F0E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7
...    C301B1218C6318C6318C6318C6318C1E82E003C00281C1401C0C02500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100
...    000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B7933780B
...    581B58095811583B40D040000259494100001965260400006594901000039652404000125949010000596526040001A594901000079652404000225949010000996524040002
...    A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E285805E02540A05028140A05028140A050281
...    40A05028140A050011080801002020040088040080101002004040080110080600A02004008080100230100C014040300501002004040080110080800A02020028080B016301
...    00C01804030050100C018040080110080600A02018028080100210100C014040080108080600A02018028404030060100C018202018030080600A10100C01404030051008060
...    0A02018030080600A10100C018040080110080100202004008080600A30100200404008010100C014040300510080100202018030080600C30100200404030050100C0180403
...    0051AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0
#Maximum number of CSI-RS supported among all CCs are limited with 2:
#RF-Parameters::BandCombination-v1540::CA-ParametersNR-v1540::csi-RS-IM-ReceptionForFeedbackPerBandComb{
#          maxNumberSimultaneousNZP-CSI-RS-ActBWP-AllCC = 2;
#          totalNumberPortsSimultaneousNZP-CSI-RS-ActBWP-AllCC = 16;
#    }

${SA_Capa_GA009}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47017B8D80D81AC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA
...    39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B00B582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD80000017
...    0000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007FE003801FF8002E0000702A0D837AC1184341020F1068032B64C55
...    890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA3626EB04610D00000201A00C2D926544439F11C79063D033EC09F00E7CC31E50B038
...    1C3C17AAAAAAA9EAAAAAAA170000381DC6C28AAD608C21A00107483401B5B262AC68006238F40CFB027C62471E439F51CF9801CA160F038782F55555553D55555542E0000700
...    4961E26000713000000058158B850001C28000E140000010B02B17008003098061300004160563E01000606C0C260184C0001858158B8040018020303600040B02B1F0080030
...    0C0606C0C26800142C0AC5C02000C0D8184C0003058158780400184C000385815878040018020004058158783600181B000485815878040018060005058158780C00181B0005
...    858158B80400180603036000C0B02B0F06C0038980000342C0AC5C4C000C26018020007058158F89800184C030040606C001E160562E2600060080C0D800402C0AC7C4D000C0
...    1018060303600110B0201600DC0068099000A026C02817400E909428913639F0E244891360090E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7C38912244
...    D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28913639F0E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7
...    C301B1218C6318C6318C6318C6318C1E82E003C00281C1401C0C02500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100
...    000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B7933780B
...    581B58095811583B40D040000259494100001965260400006594901000039652404000125949010000596526040001A594901000079652404000225949010000996524040002
...    A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E285805E02540A05028140A05028140A050281
...    40A05028140A050011080801002020040088040080101002004040080110080600A02004008080100230100C014040300501002004040080110080800A02020028080B016301
...    00C01804030050100C018040080110080600A02018028080100210100C014040080108080600A02018028404030060100C018202018030080600A10100C01404030051008060
...    0A02018030080600A10100C018040080110080100202004008080600A30100200404008010100C014040300510080100202018030080600C30100200404030050100C0180403
...    0051AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0
#Maximum number of CSI-RS supported among all CCs are limited with 1:
#RF-Parameters::BandCombination-v1540::CA-ParametersNR-v1540::csi-RS-IM-ReceptionForFeedbackPerBandComb{
#          maxNumberSimultaneousNZP-CSI-RS-ActBWP-AllCC = 1;
#          totalNumberPortsSimultaneousNZP-CSI-RS-ActBWP-AllCC = 20;
#    }

@{PM_Counters_Check_GA007_PRIM}
...    NRCELL-1:RSADU:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_2_SCELL_SA}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_2_SCELL_SA_SUCC}=0
...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}>0

@{PM_Counters_Check_GA007_EXT}
...    NRCELL-2:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-2:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRBTS-1:ADJNB:${IGNB_CA_ADD_REQ_SA_NRADJ}=1
...    NRCELL-2:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-2:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=1

@{PM_Counters_GA009_PRIM}
...    NRCELL-1:RSADU:${GNB_DU_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_2_SCELL_SA}=1

@{PM_Counters_GA009_EXT}
...    NRCELL-2:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-3:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRBTS-1:ADJNB:${IGNB_CA_ADD_REQ_SA_NRADJ}=1
...    NRCELL-2:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-3:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRBTS-1:ADJNB:${IGNB_CA_ADD_REQ_SA_REJ_NRADJ}=1

#@{RD_Counters_GA009_EXT}
#...    NRBTS-1:ADJNB:IGNB_CA_ADD_REQ_SA_REJ_NRADJ=1

${IGNB_CA_ADD_REQ_SA_REJ_NRADJ}    M55175C00002

${GNB_DU_SCELL_2_ADMI_REQ_SA}     M55139C01501
#This counter describes the number of radio admission requests for exactly 2 SCells before the CA configuration on RRC.
#It is measured in PCell in SA mode in DU only
${IGNB_CA_ATT_2_SCELL_SA}     M55118C11002
#Counts the number of inter gNB CA attempts for SA to add two S-Cell
${IGNB_CA_SCELL_ADMI_REQ_SA}     M55138C03501
#The number of radio admission requests for Inter gNB S-Cell setup
${IGNB_CA_SCELL_ADMI_SUCC_SA}     M55138C03502
#The number of successful radio admissions for Inter gNB S-Cell additions in SA mode
${IGNB_CA_ADD_REQ_SA_NRADJ}    M55175C00001
#Counts the number of inter gNB CA addition requests from prime-gNB-CU in ext-gNB-CU for SA
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
#This counter describes the total number of radio admission requests for SCell
${IGNB_CA_ATT_2_SCELL_SA_SUCC}    M55118C11005
#This counter describes the total number of radio admission requests for SCell
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002
#The number of successful radio admissions for the SCell in SA mode in DU
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
#Sum of CA UEs in the current cell configured as a PCell, which have 2 configured SCells in DL

*** Test Cases ***
CB008140-ET-GA007_Partial_scell_coverbased_added_for_TTT_3CC_2200enable_withoutACSI_Bundling_withmaxNumberallcccsir2
    [Documentation]
    ...    [purpose]:
    ...    This user scenario verifies the case that not all the SCells can be added due to limited CSI-RS capability for UE capability
    ...    (maxNumberSimultaneousNZP-CSI-RS-ActBWP-AllCC = 2).
    ...    Partial SCell addition success for one SA connection when there are more than one SCell candidate to be added.
    ...    [TL seting]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140 GA
    ...    [Configuration]:
    ...    GNB-1 Pri: cell1-TDD(n41)(pci:50)
    ...    GNB-2 ext: cell2-TDD(n41)(pci:51) cell3-TDD(n41)(pci:52)
    ...    scell gnb2-cell12 and gnb2-cell13
    ...    [Test Case Steps]
    ...         a.UE register to gnb1-cell1
    ...         b.PDU1 setup, scell gnb2-cell12 added and scell gnb2-cell13 addition failed due to insufficient-ue-capabilities
    ...         c.run dl/ul traffic for UE,
    ...         d.stop traffic
    ...         e.UE context release
    ...         f.Check counters and logs
    ...    [Expected Results]:
    ...         b. 1 csirs and P8 for both Pcell and Scell
    ...         c. Traffic ok

    [Tags]    QC_252606    GA007
    Ue register and pdu session setup    ue_id=1    enb_id=2    cell_id=1
    Trigger A1 based Scell addition    ue_id=1
    Run Traffic And Verify Throughput    ue_id=1
    UE send A2 MR to Release one Scell    ue_id=1
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}A2A_GA_007${/}a2a.ini    wait_string=UEContextRelease::10
    Check Counters    ${PM_Counters_Check_GA007_PRIM}
    Check Counters GNB2    ${PM_Counters_Check_GA007_EXT}
    Check userstop cause shall be correct

CB008140-ET-GA009_scell_addtion_failed_dueto_notenough_csirs_for_TTT_3CC_2200enable
    [Documentation]
    ...    [purpose]:
    ...    This user scenario verifies the case that SCells can not be added due to limited UE capability CSI-RS supported all CC are limited with 1.
    ...    [TL seting]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140 GA
    ...    [Configuration]:
    ...    GNB-1 Pri: cell1-TDD(n41)(pci:50)
    ...    GNB-2 ext: cell2-TDD(n41)(pci:51) cell3-TDD(n41)(pci:52)
    ...    scell gnb2-cell12 and gnb2-cell13
    ...    [Test Case Steps]
    ...         a.UE register to gnb1-cell1
    ...         b.PDU1 setup, scell addition failed
    ...         c.run dl/ul traffic for UE
    ...         d.stop traffic
    ...         e.UE context release
    ...         f.Check counters and logs
    ...    [Expected Results]:
    ...         a. 1 csirs and P8 for Pcell
    ...         b. IgNBCAAdditionRequestReject cause 'insufficient-ue-capabilities'
    ...         c. Traffic ok

    [Tags]    QC_252620    GA009
    Clear Counter Files for 2GNB
    OnlineParamChange    ${OnlineParam_GA009_PRI}    ${OnlineParam_GA009_EXT}
    Ue Register And PDU Session Setup With Blind Scell Addition failed    ue_id=2    enb_id=2    cell_id=1
    Run Traffic And Verify Throughput    ue_id=2
    UE Deregister From gNB    ue_id=2
    Check Wireshark Log    ${CURDIR}${/}A2A_GA_009${/}a2a.ini    wait_string=UEContextRelease::10
    Check Counters    ${PM_Counters_GA009_PRIM}
    Check Counters GNB2    ${PM_Counters_GA009_EXT}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/3cells_gnb1_1T_gnb2_2T

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_3CC_TTT_CA}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_GA009}

OnlineParamChange
    [Arguments]    ${Online_Param1}    ${Online_Param2}
    Delta Commission Parameters    ${Online_Param1}
    Delta Commission Parameters GNB2    ${Online_Param2}
    Cells Should Be Onair    check_sib=${False}

Ue register and pdu session setup
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=1    ${cmd_regexp}=UE now in NG RM Registere    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    ${cmd_pdu_regexp}

Trigger A1 based Scell addition
    [Arguments]    ${ue_id}=1    ${cmd_A1_regexp}=SCellIndex 1 activated successfully
    ${meas_cfg}    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A1 srsrp_nr=100 srsrq_nr=100
    ...    pass_regexp=${cmd_A1_regexp}
    Should not Contain    ${ret1}    SCellIndex 2

Ue Register And PDU Session Setup With Blind Scell Addition failed
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=1    ${cmd_regexp}=UE now in NG RM Registere    ${cmd_pdu_regexp}=SCellIndex 1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    fail_regexp=${cmd_pdu_regexp}

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throughput    ${ue_id}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=270    ${Tput_ul}=45    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

UE send A2 MR to Release one Scell
    [Arguments]    ${ue_id}=1    ${cmd_A2_regexp}=rrcReconfigurationComplete
    ${meas_cfg}    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A2 scell=1 scell_rsrp=80    pass_regexp=${cmd_A2_regexp}

Check userstop cause shall be correct
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    itf_l2_ps_user_UserStopReq_t.cause == 1
    should be equal As Numbers    ${number}    1

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    Traffic was stopped
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
    
