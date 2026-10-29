*** Settings ***
Documentation    Suite documentation
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_FDD    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...               release-SBTS23R3    owner-jolin.fan    team-jazz    CRT
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{CA_basic_config}
...    @{CB008140_config_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1_to_simGNB4}

@{PARAMS_IN_SCF_GNB2}
...    @{CB008140_config_GNB2}
...    @{CA_basic_config}

@{CB008140_config_GNB1}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=2
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:lcrId=11
...    NRBTS/NRADJNRCELL-1:nrarfcn=368400
...    NRBTS/NRADJNRCELL-1:physCellId=60
...    NRBTS/NRADJNRCELL-1:ssbFrequency=368430
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:lcrId=12
...    NRBTS/NRADJNRCELL-2:nrarfcn=153400
...    NRBTS/NRADJNRCELL-2:physCellId=61
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=653400
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=4
...    NRBTS/NRADJNRCELL-4:nrarfcn=648000
...    NRBTS/NRADJNRCELL-4:physCellId=53
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRCELL:maxNumScellsDlFr1=3
...    NRBTS:iGnbCaXnSetupReqTmr=30
...    NRCELL:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL

@{CB008140_config_GNB2}
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
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS:iGnbCaXnSetupReqTmr=40
...    NRCELL:trackingAreaDN=MRBTS-1/NRBTS-2/TRACKINGAREA-200
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRCELL-4:a2MeasSCellRelEnabled=rsrp
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=45
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=45
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=45
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms

@{CA_basic_config}
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIncXn=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actCarrierAggregation=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actChannelMapVal=Disabled
...    NRBTS:actRanSharing=false
...    NRBTS:maxNumScellsDl=4
...    NRBTS:maxNumScellsUl=4
...    NRBTS:iGnbCaXnCfUpBackOffTmr=0
...    NRBTS:iGnbCaXnSetupRespTmr=1
...    NRBTS:weightForIgnbCaSelection=1

...    NRBTS:intGnbScellTempBlockTmr=60
...    delete:NRCELL/NRPLMNSET_NSA-1
...    delete:NRCELL/NRPLMNSET_SA-1
...    NRCELL:configuredEpsTac=200
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{PARAMS_ADJ_REL_FOR_GNB1_to_simGNB4}
...    NRBTS/XNLINK-2:cPlaneIpAddr=10.0.1.124
...    NRBTS/NRADJGNB-3:administrativeState=Unlocked
...    NRBTS/NRADJGNB-3:gNbIdLength=22
...    NRBTS/NRADJGNB-3:gNodeBId=35
...    NRBTS/NRADJGNB-3:weightForIgnbCaSelection=10
...    NRBTS/NRADJGNB-3:xnLinkRef=2
...    NRBTS/NRADJGNB-3:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-3:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-44:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-44:fiveGsTac=200
...    NRBTS/NRADJNRCELL-44:gNbId=35
...    NRBTS/NRADJNRCELL-44:gNbIdLength=22
...    NRBTS/NRADJNRCELL-44:lcrId=5
...    NRBTS/NRADJNRCELL-44:nrarfcn=648000
...    NRBTS/NRADJNRCELL-44:physCellId=54
...    NRBTS/NRADJNRCELL-44:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-44:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-44:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-44:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-411:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-411:fiveGsTac=200
...    NRBTS/NRADJNRCELL-411:gNbId=35
...    NRBTS/NRADJNRCELL-411:gNbIdLength=22
...    NRBTS/NRADJNRCELL-411:lcrId=6
...    NRBTS/NRADJNRCELL-411:nrarfcn=368400
...    NRBTS/NRADJNRCELL-411:physCellId=63
...    NRBTS/NRADJNRCELL-411:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-411:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-411:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-411:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-412:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-412:fiveGsTac=200
...    NRBTS/NRADJNRCELL-412:gNbId=35
...    NRBTS/NRADJNRCELL-412:gNbIdLength=22
...    NRBTS/NRADJNRCELL-412:lcrId=7
...    NRBTS/NRADJNRCELL-412:nrarfcn=153400
...    NRBTS/NRADJNRCELL-412:physCellId=64
...    NRBTS/NRADJNRCELL-412:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-412:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-412:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-412:freqBandIndicatorNR=28

@{L007_Precondition_GNB1}
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=2
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-11:gNbId=2
...    NRCELL-2/NRREL-11:gNbIdLength=22
...    NRCELL-2/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-11:lcrId=11
...    NRCELL-2/NRREL-11:removeNotAllowed=false
...    NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3

@{L013_Precondition_GNB1}
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=4
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
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
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
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
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3

@{ADD_CELL2_NRREL3}
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-3:gNbId=2
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-3:lcrId=3
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3

@{Deac_InterGnbCa}
...    NRDU-1:actInterGnbCa=disabled

${SA_NonCA_UE}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C790E7D4
...    73E618F28581C0E1E0B801FF800E000BE00088000E0541B00B582308682041E2090195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000044
...    000702A8D899AC1184341020E90480C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC00110001C0A8360DEB04610D04083C412032B64C5589
...    0E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000088000E001BC1C4C00000016020400E0100000100383600000401C01B8051013200106A02301C289
...    13639F0E040D8E7C08103639F000070318C7E8260078005038280381804A00E000C0480080C07C1200400000002001000000040000100200000401000004008000030040000
...    200200001401000802008020000180100000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B
...    266B016B036B012B022B07681A0800004B29282000032CA4C0800024B29202000072CA480800024B292020000B2CA4C0800034B292020000F2CA480800044B29202000132CA
...    480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C5090038005000040020040080040
...    18031AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D

@{CA_CELL2_CELL11_12}
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully
...    pcid:51, scellIdx:0
...    pcid:60, scellIdx:1
...    pcid:61, scellIdx:2

@{Scell_Release}
...    rrcReconfigurationComplete
...    sCellToReleaseList

@{recover_env_gnb1}
...    delete:NRCELL-.*/NRREL-.*
...    NRDU-1:actInterGnbCa=DLOnly

@{recover_env_gnb2}
...    delete:NRCELL-.*/NRREL-.*
...    NRDU-1:actInterGnbCa=DLOnly

@{cellssbFrequency}
...    648096
...    368430
...    153370

@{CA_TTFF}
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully
...    SCellIndex 3 activated successfully
...    pcid:50, scellIdx:0
...    pcid:53, scellIdx:1
...    pcid:60, scellIdx:2
...    pcid:61, scellIdx:3

@{ADD_Qos3}
...    Added QosFlow with QFI:2 5QI:7
...    QoS Routing Table

@{Setup_PDU2}
...    Setup QosFlow with QFI:1 5QI:6
...    QoS Routing Table

@{Dele_Qos3}
...    Deleting QosFlow with QFI:2 5QI:7
...    QoS Routing Table

@{L029_Precondition_GNB1}
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:ipAddress=10.0.1.124
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:remoteNeType=GNB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-11:gNbId=2
...    NRCELL-2/NRREL-11:gNbIdLength=22
...    NRCELL-2/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-11:lcrId=11
...    NRCELL-2/NRREL-11:removeNotAllowed=false
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3

@{LOCK_CELL2_11}
...    NRCELL-11:administrativeState=Locked

@{UNLOCK_CELL2_11}
...    NRCELL-11:administrativeState=Unlocked

@{ADD_scellmethod}
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-11:sCellOperationalMode=dlOnly

@{ADD_CELL2_NRREL12}
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-12:gNbId=2
...    NRCELL-2/NRREL-12:gNbIdLength=22
...    NRCELL-2/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-12:lcrId=12
...    NRCELL-2/NRREL-12:removeNotAllowed=false
...    NRCELL-2/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-12:gnbPlmn:mncLength=3

@{ADD_CELL1_NRREL4}
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=4
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3

@{ADD_CELL1_NRREL6}
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=35
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=6
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3

*** Test Cases ***
CB008140-ET-L007_L011_prignb_actInterGnbCa_disable_exist_nonCAUE_unaffected_then_newUE_setup_then_addnew_ext_CAREL
    [Documentation]
    ...    [purpose]:
    ...        This user scenario verifies gNB's behavior to support the online modification of actInterGnbCa from 'DLOnly' to 'disabled' and nrrel.
    ...    [Configuration]:
    ...    GNB-1 Pri: cell1-TDD(n77)(pci:50) cell2-TDD(n77)(pci:51)
    ...    GNB-2 ext: cell3-TDD(n77)(pci:52) cell4-TDD(n77)(pci:53) cell11-FDD(n3)(pci:60) cell12-FDD(n28)(pci:61)
    ...    TF CA blind cell1-1+cell2-11, covBasedA1 cell1-2+cell2-11, FT CA blind cell2-11+cell1-1, covBasedA1 cell2-12+cell1-2
    ...    [Test Case Steps]:
    ...         a.None_CA UE4 register to gnb1-cell1, and PDU Session Setup, blind scell additon is not triggered.
    ...         b.CA UE2 register to gnb1-cell2, and PDU Session Setup, A1 meas for scell add is configured.
    ...         c.online modify to add another NRREL gnb2-cell12 for cell1-2.
    ...         d.UE2 send A1 MR to trigger scell addition, scells cell2-11 and cell2-12 is added
    ...         e.run and check dl/ul traffic for UE1 and UE2
    ...         f.trigger A2 MR to release all scells And Verify Throughput for UE 2, sells release successfully, and A1 meas is configured.
    ...         g.online modify for ext GNB2 'actInterGnbCa=disabled'
    ...         h.UE1,2 are not affected
    ...         i.CA UE3 register to gnb1-cell1, blind scell is not added.
    ...         j.online modify for Pri GNB1 'actInterGnbCa=disabled'
    ...         k.online modify to add another NRREL gnb2-cell3 for cell1-2.
    ...         l.UE2 send A1 MR to trigger scell addition, scells cell2-11, cell2-12 and cell2-3 are not added.
    ...         m.release all UEs
    ...         n.Check logs
    [Tags]    QC_47061    L007    L011    CA_LABLE-TF(100MHz_TDD_n77+10MHz_FDD_n3)    CA_LABLE-TF(100MHz_TDD_n77+15MHz_FDD_n28)
    [Setup]    Preconfiguration for case    ${L007_Precondition_GNB1}
    Make call for none CA UE4 to cell1-1 and start traffic
    Ue Register And PDU Session Setup    ue_id=2    gateway=2    enb_id=2    cell_id=2
    OnlineParamChange for pri GNB1    ${ADD_CELL2_NRREL12}
    UE Send A1 Trigger Scell Activation And Verify Throughput    ue_id=2    cellfreq=657984    pass_reg_ca=${CA_CELL2_CELL11_12}    fail_reg=error
    ...    T_dl=380    T_ul=20
    trigger A2 MR to release two scells And Verify Throughput    ue_id=2    cellfreq1=368430    cellfreq2=153370    pass_reg=${Scell_Release}
    OnlineParamChange for ext GNB2    ${Deac_InterGnbCa}
    Verify Throughput for UE4 and UE2
    Ue Register And PDU Session Setup without blind scell addition    ue_id=3    gateway=3    enb_id=2    cell_id=1
    OnlineParamChange for pri GNB1    ${Deac_InterGnbCa}
    OnlineParamChange for pri GNB1    ${ADD_CELL2_NRREL3}
    UE Send A1 Trigger Scell Activation And Verify Throughput    ue_id=2    cellfreq=657984    pass_reg_ca=None    fail_reg=SCellIndex 2 activated
    ...    T_dl=200    T_ul=20
    Release UEs    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}A2A_L_007_011${/}a2a.ini    wait_string=UEContextRelease::30
    [Teardown]    case recover

CB008140-ET-L013_L014_prignb_actInterGnbCa_disable_exist_CATTFF_UE_unaffected_then_pdumodify_scellrelease_working_whethercantriggerscelladd_again
    [Documentation]
    ...    [purpose]:
    ...        This user scenario verifies gNB's behavior to support the online modification of actInterGnbCa from 'DLOnly' to 'disabled'.
    ...    Then Modify,add,Delete QoS Flow with multi PDUs.
    ...    [Configuration]:
    ...    GNB-1 Pri: cell1-TDD(n77)(pci:50) cell2-TDD(n77)(pci:51)
    ...    GNB-2 ext: cell3-TDD(n77)(pci:52) cell4-TDD(n77)(pci:53) cell11-FDD(n3)(pci:60) cell12-FDD(n28)(pci:61)
    ...    scell gnb2-cell4 gnb2-cell11 and gnb2-cell12
    ...    [Test Case Steps]
    ...         a.UE1 register to gnb1-cell1, PDU1 session with QosFlow1 setup
    ...         b.UE1 send A1 MR to trigger scell addition, 4CC TTFF succeed
    ...         c.run and check dl/ul traffic for UE1
    ...         d.online modify actInterGnbCa=disabled for GNB2
    ...         e.stop traffic and modify UE1 pdu1 by add QosFlow 3, setup pdu2 successfully, then run and check dl/ul traffic for UE1
    ...          with pdu1 and pdu2
    ...         f.UE2 register to gnb2-cell3, PDU1 session with QosFlow1 setup
    ...         g.run and check dl/ul traffic for UE2
    ...         h.online modify actInterGnbCa=disabled for GNB1
    ...         i.stop traffic and modify UE1 pdu1 by delete QosFlow 3, modify UE1 pdu2 by add QosFlow 3, then run and check dl/ul traffic for
    ...           UE1 with pdu1 and pdu2.
    ...         j.UE1 send A2 MR to trigger scell release, all scells are released and A1 is not configured.
    ...         k.Release UE1 and UE2
    [Tags]    QC_47060    L013    L014    CA_LABLE-TTFF(100MHz_TDD_n77+40MHz_TDD_n77+10MHz_FDD_n3+15MHz_FDD_n28)
    [Setup]    Preconfiguration for case    ${L013_Precondition_GNB1}
    Ue Register And PDU Session Setup    ue_id=1    gateway=1    enb_id=2    cell_id=1
    UE Send A1 Trigger 4CC Scell Activation And Verify Throughput    ue_id=1    cellfreq=663168    pass_regexp_ca=${CA_TTFF}    T_dl=30    T_ul=2
    OnlineParamChange for ext GNB2    ${Deac_InterGnbCa}
    PDU1 Modify QoS and add PDU2    ue_id=1    qosadd=3
    Ue Register And PDU Session Setup    ue_id=2    gateway=2    enb_id=3    cell_id=3
    Run Traffic And Verify Throughput    ue_id=2    tput_dl=30    tput_ul=2
    OnlineParamChange for pri GNB1    ${Deac_InterGnbCa}
    PDU Modify QoS add delete and Verify Throughput
    trigger A2 MR to release all scells And Verify Throughput    ue_id=1    scell_release_regexp=${scell_release}
    Check UE not configured with A1 And Verify Throughput     ue_id=1    cellfreq=663168
    Release UEs    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}A2A_L_013_014${/}a2a.ini    wait_string=UEContextRelease::10
    [Teardown]    case recover

CB008140-ET-L029_Online_modification_cell_status_message_resouceupdate_with_flagdisable
    [Documentation]
    ...    [purpose]:
    ...        This user scenario verifies gNB's behavior to support the online modification of actInterGnbCa from 'DLOnly' to 'disabled' and nrrel
    ...        or lock unlock nrcell.
    ...    [Configuration]:
    ...    GNB-1 Pri: cell1-TDD(n77)(pci:50) cell2-TDD(n77)(pci:51)
    ...    GNB-2 ext: cell3-TDD(n77)(pci:52) cell4-TDD(n77)(pci:53) cell11-FDD(n3)(pci:60) cell12-FDD(n28)(pci:61)
    ...    TT CA blind cell1-1+cell2-3, TF CA covBasedA1 cell1-2+cell2-11
    ...    [Test Case Steps]:
    ...         a.online modify for GNB2 to lock scell cell2-11, for GNB1 set sCellAdditionMethod=blind for scell cell2-3 and sCellAdditionMethod
    ...           =covBasedA1 for scell cell2-11, GNB1 send to GNB2 with 'IgNBCASetupRequest' :CellToReportList contain two scells.
    ...         b.UE1 register to gnb1-cell1, and PDU Session Setup with blind scell cell2-3 addition successful.
    ...         c.UE2 register to gnb1-cell2, and PDU Session Setup, A1 meas for scell add is not configured because scell cell2-11 is locked.
    ...         d.online modify to add another NRREL gnb2-cell12 for cell1-2.
    ...         e.release UE2
    ...         f.re-attach UE2 to cell1-2, setup PDU Session and send A1 MR to trigger scell addition, scell cell2-12 is added. then run and check
    ...           dl/ul traffic for UE2
    ...         g.online modify for ext GNB2 set cell2-11 'Unlocked'.
    ...         h.UE1,2 are not affected,dl/ul traffic for UE1,2 is stable.
    ...         i.online modify for Pri GNB1 'actInterGnbCa=disabled'
    ...         j.online modify to add another NRREL gnb2-cell4 for cell1-1.
    ...           GNB1 send to GNB2 with 'IgNBCAConfigurationUpdateIndication':CellToReportListUpdate cellsToAdd cell2-4.
    ...         k.online modify to add another NRREL gnb4-cell6 for cell1-1.
    ...           GNB1 will not send 'IgNBCASetupRequest' when GNB1 'actInterGnbCa=disabled'
    ...         l.Check logs
    [Tags]    QC_281773    L029    CA_LABLE-TF(40MHz_TDD_n77+10MHz_FDD_n3)    CA_LABLE-TT(100MHz_TDD_n77+100MHz_TDD_n77)
    [Setup]    Preconfiguration for case L029    ${L029_Precondition_GNB1}
    Online Modify to lock scell cell2-11 and add scell addition method
    Make call for CA UE1 to cell1-1 and start traffic
    Make call for CA UE2 to cell1-2 and start traffic
    OnlineParamChange for pri GNB1    ${ADD_CELL2_NRREL12}
    Release and Make call for CA UE2 to cell1-2 again and add scell cell2-12 successfully
    OnlineParamChange for ext GNB2    ${UNLOCK_CELL2_11}
    OnlineParamChange for pri GNB1    ${Deac_InterGnbCa}
    OnlineParamChange for pri GNB1    ${ADD_CELL1_NRREL4}
    Online Modify for GNB1 to add sim GNB cell4-6 as NRREL
    Verify Throughput for UE1 and UE2
    Check Wireshark Log    ${CURDIR}${/}A2A_L_029${/}a2a.ini    wait_string=UEContextRelease::10
    [Teardown]    case recover

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup    #wait for XNAP setup
    Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Preconfiguration for case
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Common Test Setup And Start To Capture Logs

case recover
    Delta Commission Parameters    ${recover_env_gnb1}
    Delta Commission Parameters GNB2    ${recover_env_gnb2}
    Common Test Teardown And Stop Capture Logs

Modify Cfg
    Update Cfg    ue_param id=4 ue_nr_capabilities=${SA_NonCA_UE}
    Update Cfg    set_qosflow id=3 5qi=7
    Update Cfg    set_qosrule id=1 proto=udp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=1,3 qos_rules=1,2
    ${gNB4_sim_configuration}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124
    ...    nssai=0x1:0xd143a5 amf=1 xp=10.0.1.124:32742 xpu=10.0.1.124:32742 xp_management=on
    Update Cfg    ${gNB4_sim_configuration}
    ${gNB4_Cell11_sim_configuration}    catenate
    ...    set_cell id=6 gnb=4 pci=21:0 tac=200 nrci=0x06 tdd_cell=off proxy=10.0.2.90:9999 nr_arfcn=349400:368400 gscn=4605
    ...    nr_scs=15kHz bs_channel_bandwidth=10MHz mandatory_for_activation=off
    Update Cfg    ${gNB4_Cell11_sim_configuration}

Make call for none CA UE4 to cell1-1 and start traffic
    Ue Register And PDU Session Setup    ue_id=4    gateway=1    enb_id=2    cell_id=1
    Run Traffic And Verify Throughput    ue_id=4    tput_dl=400    tput_ul=20

Verify Throughput for UE4 and UE2
    Verify Throughput    ue_id=4    Tput_dl=400    Tput_ul=20
    Verify Throughput    ue_id=2    Tput_dl=200    Tput_ul=20

OnlineParamChange for pri GNB1
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}

OnlineParamChange for ext GNB2
    [Arguments]    ${Online_Param}
    Delta Commission Parameters GNB2    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}

Ue Register And PDU Session Setup
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table
    Sleep    5s    #wait all sysinfo

Ue Register And PDU Session Setup without blind scell addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    fail_regexp=SCellIndex 1 activated
    Sleep    5s    #wait all sysinfo

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1    ${tput_dl}=200    ${tput_ul}=20
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=25 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throughput    ue_id=${ue_id}    Tput_dl=${tput_dl}    Tput_ul=${tput_ul}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=270    ${Tput_ul}=20    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput
    #Should Not Match Regexp    ${scell_tput}    CellIndex-. *0 *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

UE Send A1 Trigger Scell Activation And Verify Throughput
    [Arguments]    ${ue_id}    ${cellfreq}    ${pass_reg_ca}    ${fail_reg}    ${T_dl}    ${T_ul}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${pass_reg_ca}
    Should Not Contain    ${ret1}    ${fail_reg}
    Run Traffic And Verify Throughput    ue_id=${ue_id}    tput_dl=${T_dl}    tput_ul=${T_ul}

trigger A2 MR to release two scells And Verify Throughput
    [Arguments]    ${ue_id}    ${cellfreq1}    ${cellfreq2}    ${pass_reg}
    ${meas_id_scell1}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq1}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell1} event=A2 scell=1 scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=${pass_reg}
    ${meas_id_scell2}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq2}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell2} event=A2 scell=2 scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=${pass_reg}
    Verify Throughput    ue_id=${ue_id}    Tput_dl=200    Tput_ul=20

PDU1 Modify QoS and add PDU2
    [Arguments]    ${ue_id}=1    ${qosadd}=3
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qosadd} by=amf
    ...    pass_regexp=${ADD_Qos3}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 nwslice=1 gw=2    pass_regexp=${Setup_PDU2}
    Run Traffic And Verify Throughput with Multi PDU

PDU Modify QoS add delete and Verify Throughput
    [Arguments]    ${ue_id}=1    ${qos}=3
    PDU_Modify_QoS_add_delete    ue_id=${ue_id}    qos=${qos}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=2 dir=dl mbps=100 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=2 dir=dl mbps=100 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=8    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=25 trf_id=1    UE ${ue_id}: UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=ul mbps=25 trf_id=2    UE ${ue_id}: UDP UL
    Verify Throughput with Multi PDU    ue_id=${ue_id}

PDU_Modify_QoS_add_delete
    [Arguments]    ${ue_id}=1    ${qos}=3
    Stop traffic
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=${qos} by=amf
    ...    pass_regexp=${ADD_Qos3}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qos} by=amf
    ...    pass_regexp=${Dele_Qos3}

Run Traffic And Verify Throughput with Multi PDU
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=dl mbps=100 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=dl mbps=100 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl mbps=150 trf_id=8    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=25 trf_id=1    UE ${ue_id}: UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=ul mbps=25 trf_id=2    UE ${ue_id}: UDP UL
    Verify Throughput with Multi PDU    ue_id=${ue_id}

Verify Throughput with Multi PDU
    [Arguments]    ${ue_id}=1    ${sleep_time}=15s
    sleep    ${sleep_time}
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-. *0 *0 *0 *0
    verify_pscell_tput    ue_id=${ue_id}
    ${ul_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${ul_throughput2}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput1}/1000>5
    Should Be True    ${ul_throughput2}/1000>5

verify_pscell_tput
    [Arguments]    ${ue_id}=1
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    ${scell3_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    (${scell0_tput}+${scell1_tput}+${scell2_tput}+${scell3_tput})/1000>640

UE Send A1 Trigger 4CC Scell Activation And Verify Throughput
    [Arguments]    ${ue_id}    ${cellfreq}    ${pass_regexp_ca}    ${T_dl}    ${T_ul}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${pass_regexp_ca}
    Run Traffic And Verify Throughput    ue_id=${ue_id}    tput_dl=${T_dl}    tput_ul=${T_ul}

trigger A2 MR to release all scells And Verify Throughput
    [Arguments]    ${ue_id}    ${scell_release_regexp}
    set test variable    ${scell_index}    1
    FOR    ${item}    IN    @{cellssbFrequency}
        ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${item}    event_type=A2
        Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_index} scell_rsrp=20 scell_rsrq=20
        ...    pass_regexp=${scell_release_regexp}
        ${scell_index}    evaluate    ${scell_index}+1
    END
    verify_pcell_tput    ue_id=${ue_id}

verify_pcell_tput
    [Arguments]    ${ue_id}=1
    sleep    5s    sleep for Tput stable
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-. *0 *0 *0 *0
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>500
    ${ul_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${ul_throughput2}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput1}/1000>8
    Should Be True    ${ul_throughput2}/1000>8

Check UE not configured with A1 And Verify Throughput
    [Arguments]    ${ue_id}    ${cellfreq}
    ${result}=    Run Keyword And Return Status    get_nr_meas_id_for_specific_type_and_frequency
    ...    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Should Be True    '${result}' == 'False'

Stop traffic
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2

Preconfiguration for case L029
    [Arguments]    ${Online_Param_GNB1}
    Delta Commission Parameters    ${Online_Param_GNB1}
    Common Test Setup And Start To Capture Logs

Online Modify to lock scell cell2-11 and add scell addition method
    Delta Commission Parameters GNB2    ${LOCK_CELL2_11}
    Object Should Exist Gnb2    NRCELL-11:administrativeState=Locked
    OnlineParamChange for pri GNB1    ${ADD_scellmethod}

Ue Register And PDU Session Setup with blind scell addition
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1    ${regexp}=SCellIndex 1 activated
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=${regexp}
    Sleep    5s    #wait all sysinfo

Make call for CA UE1 to cell1-1 and start traffic
    Ue Register And PDU Session Setup with blind scell addition    ue_id=1    gateway=1    enb_id=2    cell_id=1
    ...    regexp=PhysCellId: 52] SCellIndex 1 activated
    Run Traffic And Verify Throughput    ue_id=1    tput_dl=400    tput_ul=20

Make call for CA UE2 to cell1-2 and start traffic
    Ue Register And PDU Session Setup    ue_id=2    gateway=2    enb_id=2    cell_id=2
    Check UE not configured with A1 And Verify Throughput     ue_id=2    cellfreq=657984
    Run Traffic And Verify Throughput    ue_id=2    tput_dl=200    tput_ul=20

Release and Make call for CA UE2 to cell1-2 again and add scell cell2-12 successfully
    Release UEs    ue_id=2
    Ue Register And PDU Session Setup    ue_id=2    gateway=2    enb_id=2    cell_id=2
    UE Send A1 Trigger Scell Activation And Verify Throughput    ue_id=2    cellfreq=657984    pass_reg_ca=PhysCellId: 61] SCellIndex 1 activated
    ...    fail_reg=error    T_dl=300    T_ul=20

Online Modify for GNB1 to add sim GNB cell4-6 as NRREL
    Get correct xp xgu version
    Setup XpAP Link
    Set Sim gNB ignb CA Addition Param    IgNBCAXpProtocolVersion=${C_XpVersion}    IgNBCAXgUProtocolVersion=${C_XgUVersion}
    Check alarm of Xp Xg version with simGNB mismatch is not raised    xpfaultid=7108    xgfaultid=7109
    OnlineParamChange for pri GNB1    ${ADD_CELL1_NRREL6}

Verify Throughput for UE1 and UE2
    Verify Throughput    ue_id=1    Tput_dl=400    Tput_ul=20
    Verify Throughput    ue_id=2    Tput_dl=300    Tput_ul=20

Get correct xp xgu version
    ${IgNBCAXpProtocol_Version}    Get Xp Version
    ${IgNBCAXgUProtocol_Version}    Get Xgu Version
    set test variable    ${C_XpVersion}    ${IgNBCAXpProtocol_Version}
    set test variable    ${C_XgUVersion}    ${IgNBCAXgUProtocol_Version}

Check alarm of Xp Xg version with simGNB mismatch is not raised
    [Arguments]    ${xpfaultid}=7108    ${xgfaultid}=7109
    FM Fault Should Be Cleared    fault_id=${xpfaultid}
    FM Fault Should Be Cleared    fault_id=${xgfaultid}

Setup XpAP Link
    Execute Egate Command    sim_trace enb=4 protocol=xp,xn on
    Execute Egate Command    enb_xp_param xp_peers=2 id=4    pass_regexp=is up    timeout=120s

Set Sim gNB ignb CA Addition Param
    [Arguments]    ${IgNBCAXpProtocolVersion}=12    ${IgNBCAXgUProtocolVersion}=1
    ${gNB4_param}    catenate
    ...    gnb_param id=4 bwp_profile_id=1 bwp_profile_type=powersaving act_multiple_dedicated_bwps=yes location_bw_ul=1:2 location_bw_dl=3:4
    ...    Inter_gNB_CA_Allowed=yes CellLoadReportingPeriodicity=000 IgNBCAXpProtocolVersion=${IgNBCAXpProtocolVersion}
    ...    IgNBCAXgUProtocolVersion=${IgNBCAXgUProtocolVersion}
    Execute Egate Command    ${gNB4_param}
    Execute Egate Command    gnb_cell_param gnb=4 id=6 Cell_BWP_List=1,2 cell_Available=yes weightForSCellSelection=50
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=4 target=2    pass_regexp=Sent to GNB-2


