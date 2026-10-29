*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CIT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    owner-delun.li    team-jazz    release-SBTS23R3    CB008140-GH    CB008140-GA    CDRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${DEBUG_LOG_LEVEL}    4
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1_Neighbor}
...    @{PARAMS_FOR_OTHERS}
...    @{DRX_FOR_CELL}
...    @{PARAMS_FOR_GNB1_A1_scelladd}
...    @{PARAMS_FOR_6137}
...    @{PARAMS_FOR_Patial_CSI_RS}
@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{DRX_FOR_CELL}
...    @{PARAMS_FOR_GNB2_Neighbor}
...    @{PARAMS_FOR_6137}
...    @{PARAMS_FOR_Patial_CSI_RS}
@{DRX_FOR_CELL}
...    NRCELL:actCDrx=true
...    NRCELL:drxProfileNrAnr:nrDrxDN=NRDRX-3
...    NRCELL:drxProfileNrAnr:drxControl=intraNRSA
...    NRCELL:drxProfileNrAnr:drxInactivityTimer=80ms
...    NRCELL:drxProfileNrAnr:drxLongCycle=320ms
...    NRCELL:drxProfileNrAnr:drxOnDurationTimer=20ms
...    NRCELL:drxProfileNrAnr:drxRetransTimerDl=0slot
...    NRCELL:drxProfileNrAnr:drxRetransTimerUl=0slot
@{PARAMS_FOR_Patial_CSI_RS}
...    NRCELL:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=4
...    NRCELL:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots320    # if Period is too small such as slot160, it can't include 4 csris resource.
...    NRCELL:actCellCsirsTddOnSsbBf=false
...    NRCELL:actPerCsiReportBundlingTddFr1=false
...    NRCELL:actCsirsMultiplexing=true
...    NRCELL:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
@{PARAMS_FOR_6137}
...    NRDU-1:dlToUlContributionRatio=80

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Fdd_Sa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:configuredEpsTac=200
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRCELL:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=4
...    NRCELL:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots320    # if Period is too small such as slot160, it can't include 4 csris resource.
...    NRCELL:actCellCsirsTddOnSsbBf=false
...    NRCELL:actPerCsiReportBundlingTddFr1=false
...    NRCELL:actAperCsi=false
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based

@{PARAMS_FOR_GNB1_Neighbor}
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
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
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
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly

@{PARAMS_FOR_GNB1_A1_scelladd}
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=60|a1TimeToTriggerSCellAddSsbRsrq=320ms

@{PARAMS_FOR_GNB2}
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:weightForSCellSelection=10
...    NRCELL-3:weightForSCellSelection=30
...    NRCELL-2:a2MeasSCellRelEnabled=rsrq
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-2:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-2:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-2:configuredEpsTac=200
...    NRCELL-2:trackingAreaDN=MRBTS-1/NRBTS-2/TRACKINGAREA-200
...    NRCELL-3:a2MeasSCellRelEnabled=rsrq
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-3:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-3:configuredEpsTac=200
...    NRCELL-3:trackingAreaDN=MRBTS-1/NRBTS-2/TRACKINGAREA-200

@{PARAMS_FOR_GNB2_Neighbor}
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
@{PARAMS_FOR_OTHERS}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60


...    NRBTS:actRanSharing=false

...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1


${SA_Capa_Support_3CC_TTT_CA}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47017B8D80D81AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B00B582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607038782E007FE003801FF8002E0000702A0D837AC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473E618
...    F28581C0E1E13FFE00000FFF800000B80001C0AA3626EB04610D00000201A00C2D926544439F11C79063D033EC09F00E7CC31E50B0381C3C1
...    7AAAAAAA9EAAAAAAA170000381DC6C28AAD608C21A00107483401B5B262AC68B5E25AF42D7B16BC628B5E45AF52D7996BCA1607038782F555
...    55553D55555542E00007004961E26000713000000058158B850001C28000E140000010B02B17008003098061300004160563E01000606C0C2
...    60184C0001858158B8040018020303600040B02B1F00800300C0606C0C26800142C0AC5C02000C0D8184C0003058158780400184C00038581
...    5878040018020004058158783600181B000485815878040018060005058158780C00181B0005858158B80400180603036000C0B02B0F06C00
...    38980000342C0AC5C4C000C26018020007058158F89800184C030040606C001E160562E2600060080C0D800402C0AC7C4D000C01018060303
...    600110B0201600DC0068099000A026C02817400E909428913639F0E244891362130E2448913639F0E344891226C73E1C4891226C73E1C6891
...    2244D8E7C38912244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28913639F0E244891363
...    9F0E344891226C73E1C4891226C73E1C68912244D8E7C301B1218C6318C6318C6318C6318C1E82E003C00281C1401C0C02500700060240040
...    603E09002000000010008000000200000C0100000200800002004000018020000100100000A008004010040100000C0080000700400200000
...    008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B7933780B581B58095811583
...    B40D040000259494100001965260400006594901000039652404000125949010000596526040001A594901000079652404000225949010000
...    996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D554
...    1E285805E02540A05028140A05028140A05028140A05028140A050011080801002020040088040080101002004040080110080600A0200400
...    8080100230100C014040300501002004040080110080800A02020028080B01630100C01804030050100C018040080110080600A0201802808
...    0100210100C014040080108080600A02018028404030060100C018202018030080600A10100C014040300510080600A02018030080600A101
...    00C018040080110080100202004008080600A30100200404008010100C014040300510080100202018030080600C30100200404030050100C
...    01804030051AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

${GNB_DU_SCELL_2_ADMI_REQ_SA}    M55139C01501
${GNB_DU_SCELL_2_ADMI_SUCC_SA}    M55139C01502
${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002
#gNB1:
${IGNB_CA_ATT_2_SCELL_SA}    M55118C11002
${IGNB_CA_ATT_2_SCELL_SA_SUCC}    M55118C11005
#gNB2:
${IGNB_CA_ADDREQ_SA_ADJ}    M55199C00001
${IGNB_CA_SCELL_ADMI_REQ_SA}    M55138C03501
${IGNB_CA_SCELL_ADMI_SUCC_SA}    M55138C03502

@{PM_Counters_Check_prime_gNB1}
...    NRCELL-1:RSADU:${GNB_DU_SCELL_2_ADMI_REQ_SA}=2
...    NRCELL-1:RSADU:${GNB_DU_SCELL_2_ADMI_SUCC_SA}=2
...    NRCELL-1:NCAC:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-1:NCAC:${IGNB_CA_ATT_2_SCELL_SA}=2
...    NRCELL-1:NCAC:${IGNB_CA_ATT_2_SCELL_SA_SUCC}=2

@{PM_Counters_Check_ext_GNB2}
...    NRCELL-2:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=2
...    NRCELL-2:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=2
...    NRCELL-3:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=2
...    NRCELL-3:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=2
...    NRBTS-2:AGNBM:${IGNB_CA_ADDREQ_SA_ADJ}=2
...    NRCELL-2:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=2
...    NRCELL-2:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=2
...    NRCELL-3:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=2
...    NRCELL-3:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=2

${SA_Capa_Support_3CC_TTT_CA_FULL}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47017B8D80D81AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B00B582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607038782E007FE003801FF8002E0000702A0D837AC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473E618
...    F28581C0E1E13FFE00000FFF800000B80001C0AA3626EB04610D00000201A00C2D926544439F11C79063D033EC09F00E7CC31E50B0381C3C1
...    7AAAAAAA9EAAAAAAA170000381DC6C28AAD608C21A00107483401B5B262AC68B5E25AF42D7B16BC628B5E45AF52D7996BCA160F038782F555
...    55553D55555542E00007004961E26000713000000058158B850001C28000E140000010B02B17008003098061300004160563E01000606C0C2
...    60184C0001858158B8040018020303600040B02B1F00800300C0606C0C26800142C0AC5C02000C0D8184C0003058158780400184C00038581
...    5878040018020004058158783600181B000485815878040018060005058158780C00181B0005858158B80400180603036000C0B02B0F06C00
...    38980000342C0AC5C4C000C26018020007058158F89800184C030040606C001E160562E2600060080C0D800402C0AC7C4D000C01018060303
...    600110B0201600DC0068099000A026C02817400E909428913639F0E244891365AF1E2448913639F0E344891226C73E1C4891226C73E1C6891
...    2244D8E7C38912244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28913639F0E244891363
...    9F0E344891226C73E1C4891226C73E1C68912244D8E7C301B1218C6318C6318C6318C6318C1E82E003C00281C1401C0C02500700060240040
...    603E09002000000010008000000200000C0100000200800002004000018020000100100000A008004010040100000C0080000700400200000
...    008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B7933780B581B58095811583
...    B40D040000259494100001965260400006594901000039652404000125949010000596526040001A594901000079652404000225949010000
...    996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D554
...    1E285805E02540A05028140A05028140A05028140A05028140A050011080801002020040088040080101002004040080110080600A0200400
...    8080100230100C014040300501002004040080110080800A02020028080B01630100C01804030050100C018040080110080600A0201802808
...    0100210100C014040080108080600A02018028404030060100C018202018030080600A10100C014040300510080600A02018030080600A101
...    00C018040080110080100202004008080600A30100200404008010100C014040300510080100202018030080600C30100200404030050100C
...    01804030051AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

*** Test Cases ***
5GSW-CP-CIT035_Verify_SCell_addition_and_SCell_release_success_for_full_and_Patial_CSI_RS_UEs
    [Documentation]
    ...    5G UE capability:
    ...    simultaneousCSI-ReportsPerCC=4 for each band, simultaneousCSI-ReportsAllCC=8, Maximum number of CSI-RS reports supported
    ...    This case has no related to CSI Report, here just describle UE Cap for CSI-Report	
    ...    among all CCs are limited with 5:
    ...    RF-Parameters::BandCombination-v1540::CA-ParametersNR-v1540::csi-RS-IM-ReceptionForFeedbackPerBandComb{
    ...    maxNumberSimultaneousNZP-CSI-RS-ActBWP-AllCC = 5;
    ...    totalNumberPortsSimultaneousNZP-CSI-RS-ActBWP-AllC = 40; (this value at least >=5*8=40, but >40 
    ...    doesn't make much sense, here 8 is port's number, such as p8 (port 8)is using 8 ports.)
    ...    Notes: 1. Full in second UE 2. Patial CSI-RS in first UE
    ...    This case is to Verify SCell addition and SCell release success
    ...    [Configuration]:
    ...    cell id=1 gnb=1 pci=16:2 tac=200 tdd_cell=on band=n41 nr_arfcn=506010:506010 gscn=6324 chBw=60MHz ssb=505950
    ...    cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n41 nr_arfcn=519000:519000 gscn=6483 chBw=60MHz ssb=518670
    ...    cell id=3 gnb=2 pci=17:1 tac=200 tdd_cell=on band=n41 nr_arfcn=531960:531960 gscn=6648 chBw=60MHz ssb=531870

    ...    2.Test Case Steps:
    ...         a. UE1 and UE2 Register And PDU Session Setup On NRCELL-1
    ...         b. Trigger A1 to add scell2 and scell3 FOR UE1 and Start Traffic And Verify Throughput
    ...         c. Trigger A1 to add scell2 and scell3 FOR UE2 and Start Traffic And Verify Throughput
    ...         d. Trigger A2 to release scell One By One for UE1
     ...        e. UE Deregister
	 
    ...    3.Expect Result:
    ...         a. 4csirs with p8 for PCell(NRCell-1)
    ...         b. 2 csirs for Pcell + 2 csirs for Scell-2 +1 csir for Scell-3 for UE1
    ...         c. 4 csirs for Pcell + 4 csirs for Scell-2 +4 csir for Scell-3 for UE2------------?
    ...         d. Trigger A2 to release scell One By One, when Scell2 is released, Pcell csirs upgrade back to 4 csirs.
    ...            when Scell3 is release, no change for Pcell csirs resource.	
     ...        e. UE Deregister	 
	 
    [Tags]    QC_320995
    Clear Counter Files for 2GNB
    Make Normal CA SA UE
    trigger A1 MR to add scell    rsrp=95    ue_id=1
    trigger A1 MR to add scell    rsrp=95    ue_id=2
    Trigger A2 MR To Release Scell One By One    ue_id=1
    UE1 Deregister From gNB
    UE2 Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}a2a_cit035${/}a2a.ini    wait_string=UEContextRelease::10
    Check Counters    ${PM_Counters_Check_prime_gNB1}
    Check Counters GNB2    ${PM_Counters_Check_ext_GNB2}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/3cells_gnb1_1T_gnb2_2T

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_3CC_TTT_CA}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_Support_3CC_TTT_CA_FULL}

Make Normal CA SA UE
    Sa Ue Attach    ue_id=1    gateway=1    enb_id=2    cell_id=1
    Setup pdu session with no scelladd    ue_id=1
    Sa Ue Attach    ue_id=2    gateway=1    enb_id=2    cell_id=1
    Setup pdu session with no scelladd    ue_id=2

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2
    ...    ${pass_regexp}=NG RM Register
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    ${ret2}=    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}
    Should Contain    ${ret2}    nrofPorts p8

Setup pdu session with no scelladd
    [Arguments]    ${ue_id}=1    ${gateway}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    fail_regexp=sCellIndex 1
    Run Traffic And Verify Throughput    ${ue_id}

trigger A1 MR to add scell
    [Arguments]    ${rsrp}=80    ${ue_id}=1
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=505950    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrq_nr=70 srsrp_nr=${rsrp}
    ...    pass_regexp=sCellIndex 1
    Should Contain    ${ret1}    physCellId 51
    Should Contain    ${ret1}    physCellId 52
    Run Traffic And Verify Throughput    ${ue_id}

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=150 dir=dl
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 protocol=tcp mbps=150 dir=dl
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=50 dir=ul
    Verify Throughput    ${ue_id}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=260    ${Tput_ul}=28    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Trigger A2 MR To Release Scell One By One
    [Arguments]    ${ue_id}=1
    trigger A2 MR to release scell    carrierfreq=518670    scell_index=1    ue_id=${ue_id}
    trigger A2 MR to release scell    carrierfreq=531870    scell_index=2    ue_id=${ue_id}

trigger A2 MR to release scell
    [Arguments]    ${carrierfreq}=663360    ${scell_index}=1    ${ue_id}=1
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${ret2}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 scell=${scell_index} scell_rsrp=20
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret2}    sCellToReleaseList

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2

UE1 Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

UE2 Deregister From gNB
    [Arguments]    ${ue_id}=2
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
