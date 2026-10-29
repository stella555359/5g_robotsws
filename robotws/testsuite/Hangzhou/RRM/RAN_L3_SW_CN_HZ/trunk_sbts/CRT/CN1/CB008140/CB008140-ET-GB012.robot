*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    team-rock    LOLO_LOO
...    owner-xiaowen.xu    release-SBTS23R3    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB1_CA_rel_for_NRCELL_1}
...    @{MFBI_gnb1_cell1}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_CA_rel_for_NRCELL_3}
...    @{A2_scell_release_enable}
...    @{MFBI_gnb2_cell3}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=1
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:weightForSCellSelection=50
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:actConnectedModeMobilityCA=true

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0

@{MFBI_gnb1_cell1}
...    @{MFBI}
...    NRBTS/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=78
...    NRBTS/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    NRBTS/NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78

@{MFBI_gnb2_cell3}
...    @{MFBI}
...    NRBTS/NRCELL-4:freqBandIndicatorNR=78
...    NRBTS/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
...    NRBTS/NRCELL-4:nrConnectModeProfileDN=MRBTS-1/NRBTS-2/NRCONNECTMODE_PROFILE-0
...    NRBTS/NRCELL-4:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-2/NRMULTIBANDINFO_PROFILE-1
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-2/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-2/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78

@{MFBI}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalPmax=1
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=1
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1

@{PARAMS_FOR_GNB1}
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL:chBw=40MHz

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=1
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
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=78
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

@{GNB1_CA_rel_for_NRCELL_1}
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:lcrId=4
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-3:chBw=40MHz
...    NRCELL-4:chBw=40MHz
...    NRCELL-3:gscnOrSsPbchArfcn=8060
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:measGapSelectionSA=favourUeThroughput
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms

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
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:ssbFrequency=663360
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:ssbFrequency=657984
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77

@{GNB2_CA_rel_for_NRCELL_3}
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-1:gNbId=1
...    NRCELL-4/NRREL-1:gNbIdLength=22
...    NRCELL-4/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-1:removeNotAllowed=false
...    NRCELL-4/NRREL-1:lcrId=1
...    NRCELL-4/NRREL-1:sCellAdditionMethod=covBasedA1

@{A2_scell_release_enable}
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms

${SA_Capa_Support_n77_n78_n78(2A)}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C06C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D805AC1184341020F10480CAD931562439F604F88
...    E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA36266B04610D04083A412030B64C55110E7C471E238F40CFB027C
...    639F30C7942C0E070F05C00FFC007003FF0004C000381506C1BD608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B
...    0381C3C27FFC00001FFF00000130000E0551B13758230868000010090185B24CA88873E238F20C7A067D813E01CF9863CA1607038782F5555
...    5553D5555554260001C00458B804001C4D000E268000020B02B1F008003836001C4D000E268000030B02B0F0080038360000182C0AC3C0200
...    0E260000070B0201200DC0068099000A02687A01B8122448913639F0E344891226C73E1C28913639F0E14489B1CF86004820C6318F413003C
...    00281C1401C0C02500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100000A00800401
...    0040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C03395359535829581958335
...    82B594B7933780B581B58095811583B40D040000259490100001965260400006594901000039652404000125949010000596526040001A594
...    901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AA2E955552A8BA55154162A82C5
...    5068AA531549A2A80C55028AA4D5541E284803C00E8140A0500000E101002004040080110080100202004008080100220100C014040080101
...    002004602018028080600A02004008080100220101001404040050101602C602018030080600A02018030080100210100C014040300508080
...    600A02004008D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${SA_Capa_Support_n77_n78_n77(2A)}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C06C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D805AC1184341020F10480CAD931562439F604F88
...    E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA36266B04610D04083A412030B64C55110E7C471E238F40CFB027C
...    639F30C7942C0E070F05C00FFC007003FF0004C000381506C1BD608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B
...    0381C3C27FFC00001FFF00000130000E0551B13758230868000010090185B24CA88873E238F20C7A067D813E01CF9863CA1607038782F5555
...    5553D5555554260001C00458B804001C4C000E260000020B02B1F008003836001C4C000E260000030B02B0F0080038360000182C0AC3C0200
...    0E260000070B0201200DC0068099000A02687A01B8122448913639F0E344891226C73E1C28913639F0E14489B1CF86004820C6318F413003C
...    00281C1401C0C02500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100000A00800401
...    0040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C03395359535829581958335
...    82B594B7933780B581B58095811583B40D040000259490100001965260400006594901000039652404000125949010000596526040001A594
...    901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AA2E955552A8BA55154162A82C5
...    5068AA531549A2A80C55028AA4D5541E284803C00E8140A0500000E101002004040080110080100202004008080100220100C014040080101
...    002004602018028080600A02004008080100220101001404040050101602C602018030080600A02018030080100210100C014040300508080
...    600A02004008D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${SA_Capa_Support_n77_n77(2A)}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C06C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D805AC1184341020F10480CAD931562439F604F88
...    E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA36266B04610D04083A412030B64C55110E7C471E238F40CFB027C
...    639F30C7942C0E070F05C00FFC007003FF0004C000381506C1BD608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B
...    0381C3C27FFC00001FFF00000130000E0551B0A358230868000010090185B24CA88873E238F20C7A067D813E01CF9863CA1607038782F5555
...    5553D5555554260001C00458B804001C4C000E260000020B02B1F008003836001C4C000E260000030B02B0F0080038360000182C0AC3C0200
...    0E260000070B0201200DC0068099000A02687A01B8122448913639F0E344891226C73E1C28913639F0E14489B1CF86004820C6318F413003C
...    00281C1401C0C02500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100000A00800401
...    0040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C03395359535829581958335
...    82B594B7933780B581B58095811583B40D040000259490100001965260400006594901000039652404000125949010000596526040001A594
...    901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AA2E955552A8BA55154162A82C5
...    5068AA531549A2A80C55028AA4D5541E284803C00E8140A0500000E101002004040080110080100202004008080100220100C014040080101
...    002004602018028080600A02004008080100220101001404040050101602C602018030080600A02018030080100210100C014040300508080
...    600A02004008D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

*** Test Cases ***
CB008140-ET-GB012_IgNB-CA SCell Addition not attempted with only alternative band supported by UE
    [Documentation]
    ...    This case is to Verify scell addition not attempted with neither ext-scell alternative band nor pcell alternative band selected.
    ...    [Configuration for gnb1]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=40MHz ssb=663360
    ...    alternative band for cell1 is n78
    ...    cell 1 have 1 interGNB CA relationship , gnb2 cell4
    ...    [Configuration for gnb2]:
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n78 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz ssb=648096
    ...    alternative band for cell4 is n77
    ...    cell 4 have 1 interGNB CA relationship , gnb1 cell1
    ...    [Configuration for UEs]:
    ...    ue 1 support n77,n78; bc with n78(2A)
    ...    ue 2 support n77,n78; bc with n77(2A)
    ...    ue 3 support n77,not support n78; bc with n77(2A)
    ...    2.Test Case Steps:
    ...         a. UE1 attach to gnb1 cell1 , no scell added with blind method.
    ...         b. UE2 attach to gnb2 cell4 , no A1 configured for UE with coverbased method.
    ...         a. UE3 attach to gnb1 cell1 , no scell added with blind method.
    [Tags]    GB012    QC_251916
    repeat keyword    5 times    GB012

*** Keywords ***
GB012
    ue attach and send Throuput    ue_id=1    enb_id=2    cell_id=1
    ue attach and send Throuput    ue_id=2    enb_id=3    cell_id=4
    check measurements for coverbasedCA    ue_id=2
    ue attach and send Throuput    ue_id=3    enb_id=2    cell_id=1
    ue deregister from gnb    ue_id=1
    ue deregister from gnb    ue_id=2
    ue deregister from gnb    ue_id=3
    
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_n77_n78_n78(2A)}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_Support_n77_n78_n77(2A)}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${SA_Capa_Support_n77_n77(2A)}

ue attach and send Throuput
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=2
    Sa Ue Attach    ue_id=${ue_id}    gateway=${ue_id}    enb_id=${enb_id}    cell_id=${cell_id}
    Setup pdu session    ue_id=${ue_id}    gateway=${ue_id}
    Send Throuput    ue_id=${ue_id}    pdu_id=${ue_id}
    Verify Throuput    ue_id=${ue_id}

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2
    ...    ${pass_regexp}=now Registered
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}

Setup pdu session
    [Arguments]    ${ue_id}=1    ${gateway}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${gateway} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${gateway} nwslice=1 gw=${gateway}    pass_regexp=Initial Context Setup Successful
    ...    fail_regexp=sCellToAddModList

Get the measurement id
    [Arguments]    ${event_type}=A3    ${ue_id}=1    ${carrierfreq}=648096    ${threshold}=0
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_type}
    ...    threshold=${threshold}
    [Return]    ${meas_id}

check measurements for coverbasedCA
    [Arguments]    ${ue_id}=1
    run keyword and expect error    *    Get the measurement id    ue_id=${ue_id}    event_type=A1    carrierfreq=648096    threshold=70

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${ue_id}    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${ue_id}    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Send Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=20 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput
    [Arguments]    ${ue_id}=1    ${pcell_dl}=60    ${ul}=10    ${scell_id}=0
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

