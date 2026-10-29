*** Settings ***
Documentation
...    author: Susana Yan
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_FDD    SBTS00    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...        owner-cathy.mao    team-SG2    release-SBTS23R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}


${ue_id}    1
${pdu_id}    1

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{ANR_gnb}
...    @{Enable_Xn}
...    @{GNB1_CELL-11_A1}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{gscn_Arfcn}
...    @{ANR_gnb2}
...    @{Enable_Xn}


@{Enable_Xn}
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true

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
...    NRDU-1:actInterGnbCa=disabled

@{PARAMS_FOR_GNB1}
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:nrCellType=2DL2UL
#...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRCELL:actCDrx=true
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
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=10
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL/NRHOIF-1:ssbFrequency=663360
...    NRCELL/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    @{GNB1_InraFreq_Drx}



@{GNB1_InraFreq_Drx}
...    NRCELL-11:drxProfileNrAnr:drxControl=intraNRSA
...    NRCELL-11:drxProfileNrAnr:nrDrxDN=NRDRX-3
...    NRDRX-3:drxInactivityTimer=80ms
...    NRDRX-3:drxLongCycle=320ms
...    NRDRX-3:drxOnDurationTimer=20ms
...    NRDRX-3:drxRetransTimerDl=0slot
...    NRDRX-3:drxRetransTimerUl=0slot

@{GNB1_CELL-11_A1}
...    NRCELL-11:a1MeasSCellAddEnabled=rsrq
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=111
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=320ms

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
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
...    NRCELL-13:actCDrx=true
...    NRCELL-13:drxProfileNrAnr:drxControl=intraNRSA
...    NRCELL-13:drxProfileNrAnr:nrDrxDN=NRDRX-3
...    NRCELL-1:a5MeasEnabled=rsrq
...    NRCELL-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40
...    NRCELL-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRCELL-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRCELL-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms40
...    NRCELL-1:actCDrx=true
...    NRCELL-1:drxProfileNrAnr:drxControl=intraNRSA
...    NRCELL-1:drxProfileNrAnr:nrDrxDN=NRDRX-3
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=10
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL/NRHOIF-1:freqBandIndicatorNR=3
...    NRCELL/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL/NRHOIF-1:ssbFrequency=363850
...    NRCELL/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL-1:absThreshSsbRsrqConsolidation=1


@{gscn_Arfcn}
...    NRCELL-13:gscnOrSsPbchArfcn=4547
...    NRCELL-13/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=364000
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=345000

@{PARAMS_FOR_OTHERS}
#...    NRBTS:actGeneralConnectivityGold=true
#...    NRBTS:actGeneralConnectivitySilver=true
...    NRBTS:actRanSharing=false
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min

@{ANR_gnb}
...    NRBTS:actSaUeBasedAnrNr=true
...    NRBTS:actDedicatedAnrDrxProfile=true
...    NRBTS:actSaIntraFreqAnrDrxProf=true
...    NRANR-1:actAutoEutraNbRemoval=false
...    NRANR-1:actAutoNrNbRemoval=true
...    NRANR-1:consecHoFailThres=0
...    NRANR-1:consecHoFailThresEutra=3
...    NRANR-1:consecXnResolveFailThres=3
...    NRANR-1:gNbIdLengthConfig:gNbIdLength=22
...    NRANR-1:gNbIdLengthConfig:priorityIndex=1
...    NRANR-1:nrAnrId=1
...    NRANRPR-1:anrThresholdSelector=RSRP
...    NRANRPR-1:anrThresRsrpNbCell=-90
...    NRANRPR-1:anrThresRsrqNbCell=-12
...    NRANRPR-1:cellDepMode=SA+NSA
...    NRANRPR-1:consecRecheckForNrNbRemoval=5
...    NRANRPR-1:idleTimeForNrNbRemoval=72
...    NRANRPR-1:maxNumAnrNrrelAllowed=50
...    NRANRPR-1:nrAnrPrId=1
...    NRBTS:actSaUeBasedInterFreqAnrNr=true
...    NRANRPR-2:anrThresholdSelector=RSRP
...    NRANRPR-2:anrThresRsrpNbCell=-90
...    NRANRPR-2:anrThresRsrqNbCell=-12
...    NRANRPR-2:cellDepMode=SA+NSA
...    NRANRPR-2:consecRecheckForNrNbRemoval=5
...    NRANRPR-2:idleTimeForNrNbRemoval=72
...    NRANRPR-2:maxNumAnrNrrelAllowed=50
...    NRANRPR-2:nrAnrPrId=2
...    NRANRPR-2:nrarfcn=663400
...    NRANRPR-2:ssbFrequency=663360

@{ANR_gnb2}
...    NRBTS:actSaUeBasedAnrNr=true
...    NRBTS:actDedicatedAnrDrxProfile=true
...    NRBTS:actSaIntraFreqAnrDrxProf=true
...    NRANR-1:actAutoEutraNbRemoval=false
...    NRANR-1:actAutoNrNbRemoval=true
...    NRANR-1:consecHoFailThres=0
...    NRANR-1:consecHoFailThresEutra=3
...    NRANR-1:consecXnResolveFailThres=3
...    NRANR-1:gNbIdLengthConfig:gNbIdLength=22
...    NRANR-1:gNbIdLengthConfig:priorityIndex=1
...    NRANR-1:nrAnrId=1
...    NRANRPR-1:anrThresholdSelector=RSRP
...    NRANRPR-1:anrThresRsrpNbCell=-90
...    NRANRPR-1:anrThresRsrqNbCell=-12
...    NRANRPR-1:cellDepMode=SA+NSA
...    NRANRPR-1:consecRecheckForNrNbRemoval=5
...    NRANRPR-1:idleTimeForNrNbRemoval=72
...    NRANRPR-1:maxNumAnrNrrelAllowed=50
...    NRANRPR-1:nrAnrPrId=1
...    NRBTS:actSaUeBasedInterFreqAnrNr=true
...    NRANRPR-2:anrThresholdSelector=RSRP
...    NRANRPR-2:anrThresRsrpNbCell=-90
...    NRANRPR-2:anrThresRsrqNbCell=-12
...    NRANRPR-2:cellDepMode=SA+NSA
...    NRANRPR-2:consecRecheckForNrNbRemoval=5
...    NRANRPR-2:idleTimeForNrNbRemoval=72
...    NRANRPR-2:maxNumAnrNrrelAllowed=50
...    NRANRPR-2:nrAnrPrId=2
...    NRANRPR-2:nrarfcn=364000
...    NRANRPR-2:ssbFrequency=363850

@{add_nrrel-255_to_gnb1_cell-12}
...    NRCELL-11/NRREL-255:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-255:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-255:gNbId=1
...    NRCELL-11/NRREL-255:gNbIdLength=22
...    NRCELL-11/NRREL-255:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-255:lcrId=12
...    NRCELL-11/NRREL-255:removeNotAllowed=false
...    NRCELL-11/NRREL-255:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-255:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-255:gnbPlmn:mncLength=3
#...    NRCELL-11/NRREL-255:sCellOperationalMode=dlOnly

@{ANR_ho_succ}
...    reportType reportCGI
...    Inter-eNB handover from EXT_ENB

@{ANR_ho_back_succ}
...    reportType reportCGI
...    Inter-eNB handover from EXT_ENB

@{interGNB_ho_succ}
...    Inter-eNB handover from EXT_ENB

@{delete_gnb1_xn}
...    delete:MRBTS-1/NRBTS-1/XNLINK-1
...    delete:MRBTS-1/NRBTS-1/NRADJGNB-1

@{delete_gnb2_xn}
...    delete:XNLINK-1
...    delete:NRADJGNB-1

@{max_ANR_REL_1}
...    NRANRPR-1:maxNumAnrNrrelAllowed=0
...    NRANRPR-2:maxNumAnrNrrelAllowed=1


@{Act_InterGnbCa}
...    NRDU-1:actInterGnbCa=DLOnly

@{CELL-11_NRREL-255-254_covBasedA1}
...    NRCELL-11/NRREL-255:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-255:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-254:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-254:sCellOperationalMode=dlOnly


${SA_Capa_Support_4CC_CA_n3A-n28A-n77(2A)_ANR}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D80D81AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B00B582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607038782E007FE003801FF8002E0000702A0D837AC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473E618
...    F28581C0E1E13FFE00000FFF800000B80001C0AA3626EB04610D00000201A00C2D926544439F11C79063D033EC09F00E7CC31E50B0381C3C1
...    7AAAAAAA9EAAAAAAA17000038024B0F1300038980000002C0AC5C4C000E26000713000000858158B80400184C0309800020B02B1F00800303
...    6061300C260000C2C0AC5C02000C010181B0002058158F8040018060303606134000A160562E01000606C0C26000182C0AC3C02000C260001
...    C2C0AC3C02000C01000202C0AC3C1B000C0D800242C0AC3C02000C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B000605815878
...    36001C4C00001A160562E2600061300C01000382C0AC7C4C000C260180203036000F0B02B171300030040606C0020160563E2680060080C03
...    0181B00088581009006E003404C800501345D003A4250A244D8E7C38912244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF871A24
...    48913639F0E2448913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A244D8E7C38912244D8
...    E7C38D1224489B1CF871224489B1CF871A2448913639F0C06C486318C6318C6318C6318C6307A0B800F800A070500703009401C0018090010
...    180F82400800000004002000000080000300400000802000008010000060080000400400002802001004010040000300200001C0100080000
...    00200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652DE4CDE02D606D6025604560
...    ED0341000009652504000065949810000196524040000E594901000049652404000165949810000696524040001E594901000089652404000
...    265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555
...    078A160178095028140A05028140A05028140A05028140A050281400442020040080801002201002004040080101002004402018028080100
...    202004008C04030050100C014040080101002004402020028080800A0202C058C04030060100C014040300601002004402018028080600A02
...    0040084040300501002004202018028080600A10100C018040300608080600C02018028404030050100C014402018028080600C0201802840
...    40300601002004402004008080100202018028C04008010100200404030050100C014402004008080600C02018030C04008010100C0140403
...    0060100C0146A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

*** Test Cases ***
CB008140-ET-L021_extGNB_actInterGnbCa_disabled_ue_setup_noscelladded_then_modifyto_Dlonly_then_resetup_UE_A1report_scelladded_TF
    [Documentation]
    ...    1. This user scenario verify actInterGnbCa interworking with ANR.
    ...    2. Configuration
    ...       GNB1 cell1_11, cell1_12 F+F
    ...       GNB2 cell2_1, cell2_2, cell2_13, cell2_14 T+T+F+F
    ...    [TL seting]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140-L
    ...    [Configuration]:
    ...    GNB-1 Pri: cell11-FDD(n3)(pci:60) cell12-FDD(n3)(pci:61)
    ...    set_cell id=11 gnb=2 pci=20:0 tac=200 nrci=0x0B tdd_cell=off nr_arfcn=345000:364000 gscn=4547
    ...    set_cell id=12 gnb=2 pci=20:1 tac=200 nrci=0x0C tdd_cell=off nr_arfcn=355000:374000 gscn=4675
    ...    GNB-2 ext: cell1-TDD(n77)(pci:50) cell2-TDD(n77)(pci:51) cell13-FDD(n3)(pci:62) cell14-FDD(n28)(PCI63)
    ...    set_cell id=1 gnb=3 pci=16:2 tac=200 nrci=0x01 tdd_cell=on nr_arfcn=663400:663400 gscn=8159
    ...    set_cell id=2 gnb=3 pci=17:0 tac=200 nrci=0x02 tdd_cell=on nr_arfcn=658000:658000 gscn=8103
    ...    set_cell id=13 gnb=3 pci=20:2 tac=200 nrci=0x0D tdd_cell=off nr_arfcn=349400:368400 gscn=4605
    ...    set_cell id=14 gnb=3 pci=21:0 tac=200 nrci=0x0E tdd_cell=off nr_arfcn=143400:153400 gscn=1916
    ...    scell gnb2-cell1 gnb2-cell2 and gnb2-cell14
    ...    [Pre-Condition]
    ...         a. when no NRADJGNB/NRADJNRCELL/XNLINK MO,enable ANR
    ...    [Test Case Steps]
    ...         a. UE1 Attach Then Send And Verify Throughput
    ...         b. UE1 send A5 MR to trigger intra-frequency intergnb ANR with Xnlink Setup
    ...         c. UE1 send A5 MR again to trigger Intrafreq InterGNB ANR Handover and Handover Back.
    ...         d. change maxNumAnrNrrelAllowed=1
    ...         e. Add NRREL-255 to gnb1_cell-12
    ...         f. UE1 send A5 MR to trigger Intrafreq InterGNB Handover and Handover Back.
    ...         g. UE1 send A5 MR to trigger Interfreq InterGNB Handover and Handover Back.
    ...         h. OnlineParamChange CELL-11's NRREL-255-254 to covBasedA1,enable actInterGnbCa=DLOnly on two gnb.
    ...         i. UE2 Attach And A1 ScellAddition
    ...    [Expected Results]:
    ...         a. UE1 Attach Then Send And Verify Throughput
    ...         b. UE1 send A5 MR to trigger intra-frequency intergnb ANR with Xnlink Setup
    ...         c. UE1 send A5 MR again to trigger Intrafreq InterGNB ANR Handover and Handover Back.
    ...         d. change maxNumAnrNrrelAllowed=1
    ...         e. Add NRREL-255 to gnb1_cell-12
    ...         f. UE1 send A5 MR to trigger Intrafreq InterGNB Handover and Handover Back.
    ...         g. UE1 send A5 MR to trigger Interfreq InterGNB Handover and Handover Back.
    ...         h. OnlineParamChange CELL-11's NRREL-255-254 to covBasedA1,enable actInterGnbCa=DLOnly on two gnb.
    ...         i. UE2 Attach And A1 ScellAddition
    [Tags]    L021    QC_325706    CA_LABEL-FTTF(20Mhz_FDD_n3+100Mhz_TDD_n77+40Mhz_TDD_n77+15Mhz_FDD_n28)
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-1:xnLinkStatus=available
    OnlineParamChange    ${delete_gnb1_xn}
    OnlineParamChangeGnb2    ${delete_gnb2_xn}
    Object Should not Exist    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddr=10.0.1.3
    UE Attach Then Send And Verify Throughput
    Trigger Xnlink
    Intrafreq InterGNB Handover
    Intrafreq InterGNB Handover Back
    Wait Until Keyword Succeeds    120s    2s    Object Should Exist    NRBTS-1/NRCELL-11/NRREL-256:lcrId=13
    OnlineParamChange    ${max_ANR_REL_1}
    OnlineParamChange    ${add_nrrel-255_to_gnb1_cell-12}
    Intrafreq InterGNB Handover
    Intrafreq InterGNB Handover Back    expect_ho_regexp=${interGNB_ho_succ}
    Interfreq InterGNB Handover
    Interfreq InterGNB Handover Back
    OnlineParamChange    ${CELL-11_NRREL-255-254_covBasedA1}
    OnlineParamChange    ${Act_InterGnbCa}
    OnlineParamChangeGnb2    ${Act_InterGnbCa}
    UE Attach And A1 ScellAddition    ue_id=2
    Verify Throuput    ue_id=1


*** Keywords ***
Trigger Xnlink
    [Arguments]    ${ue_id}=1    ${carrierfreq}=363850
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A5
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=62 nrsrp_nr=110 nrsrq_nr=110
    ...    pass_regexp=rrcReconfigurationComplete
    Wait Until Keyword Succeeds    120s    2s    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK:xnLinkStatus=available
#    Wait Until Keyword Succeeds    60s    2s    Object Should Not Exist    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddr=10.0.1.3

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F


UE Attach Then Send And Verify Throughput
    [Arguments]    ${cell_id}=11    ${ue_id}=1    ${pdu_id}=1    ${gw}=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_Support_4CC_CA_n3A-n28A-n77(2A)_ANR}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw} nwslice=1
    ...    pass_regexp=Initial Context Setup Successful    timeout=10s
    Send traffic    ue_id=${ue_id}
    Verify Throuput    ue_id=${ue_id}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

OnlineParamChangeGnb2
    [Arguments]    ${Online_Param}
    Delta Commission Parameters Gnb2    ${Online_Param}
    cells should be onair gnb2

UE Attach And A1 ScellAddition
    [Arguments]    ${cell_id}=11    ${ue_id}=1    ${pdu_id}=1    ${gw}=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_Support_4CC_CA_n3A-n28A-n77(2A)_ANR}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw} nwslice=1
    ...    pass_regexp=Initial Context Setup Successful    timeout=10s
    UE Send A1 Trigger Scell Addition    ue_id=${ue_id}    cellfreq=363850    pass_reg_ca=SCellIndex 1 activated successfully
    Send traffic    ue_id=${ue_id}    dl_tp=150
    Verify Throuput on Pcell and Scell    ue_id=${ue_id}

UE Send A1 Trigger Scell Addition
    [Arguments]    ${ue_id}    ${cellfreq}    ${pass_reg_ca}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=120 srsrq_nr=125
    ...    pass_regexp=${pass_reg_ca}

Intrafreq InterGNB Handover
    [Arguments]    ${ue_id}=1    ${carrierfreq}=363850    ${target_phycell_id}=62    ${pass_regexp}=${interGNB_ho_succ}
    Execute Egate Command    ue_disp
    ${meas_id_scell}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A5
    ${event_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell} event=A5
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=110 nrsrq_nr=110
    Execute Egate Command    ${event_cmd}
    ...    pass_regexp=${pass_regexp}
    Verify Throuput    ue_id=${ue_id}

Intrafreq InterGNB Handover Back
    [Arguments]    ${ue_id}=1    ${carrierfreq}=363850    ${target_phycell_id}=60    ${expect_ho_regexp}=${ANR_ho_back_succ}
    Execute Egate Command    ue_disp
    ${meas_id_scell}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A5
    ${event_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell} event=A5
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=110 nrsrq_nr=110
    Execute Egate Command    ${event_cmd}
    ...    pass_regexp=${expect_ho_regexp}
    Verify Throuput    ue_id=${ue_id}

Interfreq InterGNB Handover
    [Arguments]    ${expect_ho_regexp}=${ANR_ho_succ}
    Report A2 Event
    Report A5 Event    pass_regexp=${expect_ho_regexp}
    Verify Throuput    ue_id=1

Interfreq InterGNB Handover Back
    [Arguments]    ${expect_ho_regexp}=${ANR_ho_succ}
    Report A2 Event    ssbfreq=663360
    Report A5 Event    carrierfreq=363850    pass_regexp=${expect_ho_regexp}    target_phycell_id=60
    Verify Throuput    ue_id=1

Report A2 Event
    [Arguments]    ${ue_id}=1    ${ssbfreq}=363850
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${ssbfreq}    A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    eventA5
    Sleep    2s    #wait

Report A5 Event
    [Arguments]    ${pass_regexp}    ${ue_id}=1    ${carrierfreq}=663360    ${target_phycell_id}=50
    ${meas_id_scell}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A5
    ${event_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell} event=A5
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=110 nrsrq_nr=110
    Execute Egate Command    ${event_cmd}
    ...    pass_regexp=${pass_regexp}
    #Inter-eNB handover from EXT_ENB
    Sleep    2s    #wait

Send traffic
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${dl_tp}=80
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=${dl_tp} trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL

Verify Throuput on Pcell and Scell
    [Arguments]    ${ue_id}=1    ${sleep_time}=15s
    sleep    ${sleep_time}
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000+${scell1_tput}/1000>135
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9

Verify Throuput
    [Arguments]    ${ue_id}=1    ${sleep_time}=15s
    sleep    ${sleep_time}
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    Should Be True    ${dl_throuput}/1000>10

