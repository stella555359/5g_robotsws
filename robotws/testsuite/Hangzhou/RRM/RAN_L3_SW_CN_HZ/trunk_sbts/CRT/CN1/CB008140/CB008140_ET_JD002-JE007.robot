*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN1_SG14
...    owner-jun.15.zhang    release-SBTS23R3    CRT
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
...    NRBTS:weightForIgnbCaSelection=30
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
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:weightForSCellSelection=50
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
...    NRCELL:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=160ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/XNLINK-2:cPlaneIpAddr=10.0.1.124
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:ipAddress=10.0.1.124
...    MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2:remoteNeType=GNB
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
...    NRBTS/NRADJGNB-3:weightForIgnbCaSelection=20
...    NRBTS/NRADJGNB-3:xnLinkRef=2
...    NRBTS/NRADJGNB-3:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-3:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-12:gNbId=2
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=153400
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
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
...    NRBTS/NRADJNRCELL-5:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-5:fiveGsTac=200
...    NRBTS/NRADJNRCELL-5:gNbId=35
...    NRBTS/NRADJNRCELL-5:gNbIdLength=22
...    NRBTS/NRADJNRCELL-5:lcrId=5
...    NRBTS/NRADJNRCELL-5:nrarfcn=648000
...    NRBTS/NRADJNRCELL-5:physCellId=54
...    NRBTS/NRADJNRCELL-5:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-5:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-5:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-5:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:gNbId=35
...    NRBTS/NRADJNRCELL-13:gNbIdLength=22
...    NRBTS/NRADJNRCELL-13:lcrId=13
...    NRBTS/NRADJNRCELL-13:nrarfcn=368400
...    NRBTS/NRADJNRCELL-13:physCellId=63
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-14:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-14:fiveGsTac=200
...    NRBTS/NRADJNRCELL-14:gNbId=35
...    NRBTS/NRADJNRCELL-14:gNbIdLength=22
...    NRBTS/NRADJNRCELL-14:lcrId=14
...    NRBTS/NRADJNRCELL-14:nrarfcn=153400
...    NRBTS/NRADJNRCELL-14:physCellId=64
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-14:freqBandIndicatorNR=28
...    NRCELL-2/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-5:gNbId=35
...    NRCELL-2/NRREL-5:gNbIdLength=22
...    NRCELL-2/NRREL-5:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-5:lcrId=5
...    NRCELL-2/NRREL-5:removeNotAllowed=false
...    NRCELL-2/NRREL-5:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-5:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-5:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-13:gNbId=35
...    NRCELL-2/NRREL-13:gNbIdLength=22
...    NRCELL-2/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-13:lcrId=13
...    NRCELL-2/NRREL-13:removeNotAllowed=false
...    NRCELL-2/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-14:gNbId=35
...    NRCELL-2/NRREL-14:gNbIdLength=22
...    NRCELL-2/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-14:lcrId=14
...    NRCELL-2/NRREL-14:removeNotAllowed=false
...    NRCELL-2/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-14:gnbPlmn:mncLength=3

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:weightForSCellSelection=50
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-11:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=160ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms

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
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3

@{PARAMS_FOR_OTHERS}

...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:ngInducedCellDeactDelayTimer=60
...    NRCELL:actCDrx=false

${DU-to-CU-RRCInfo}    SEPARATOR=
...    100200c0000100c1400302000f00c240020100

${ExtDu-to-PrimeDu-RrcInfo}    SEPARATOR=
...    0254042880b46063186ad278e800984ef240000134b19501a82929c028806d00d6021b00842a03a0093f0c184651c32cc00ca8048fffff800
...    00008001d0821b90218000140b2902025100350200240400498118140d86a4330190c6562f88e54140198aa88008c006097500151e86b6007
...    02010c4002a3d0d68000b81808a200151e86b40005c100431000a8f435a0102e0a0228800547a1ad008104000001430c080c1016070570015
...    2c00000000400800301200cc17000c02000004c8009e34038a340401000202200004c8009e3403880800000010580000070bfffd1020a80a3
...    61631078d167cb80042cdb40000019b193e8a81d29c028806b010a02190a20860c23286d9220064401b90018000080b29020251003c020024
...    0400498118140d484362194088512f08e54140188aa88008c00609d5000708879400e0402188001c221e38005c0c045100038443c7000b820
...    0862000708878e08170501144000e110f1c1020800000286181018202c0e0ba000e5000000001002000c04803305c003010000000280059f1
...    0082320400000000002800554d80800800000013d0050a51451e52853253c5463857ffd1040a080a36263107ad095c68036128d5000002731
...    9448a81d29c028806b010a02190a20860c2328a79420064401b90018000080b29020251003d0200240400498118140d484362194088512f08
...    e54140188aa88008c00609d5000e0487b400e04021880038121eb8005c0c045100070243d7000b8200862000e0487ae08170501144001c090
...    f5c1020800000286181018202c0e0ba001c5000000001002000c04803305c003018000001b8002573810232040000000001b8002302810008
...    00000013d0050a51451e52853253c546383ffe0

@{UE1_expect}
...    pcid:60, scellIdx:1
...    pcid:61, scellIdx:2
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{UE2_expect}
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{UE3_expect}
...    sCellIndex 1
...    sCellIndex 2
...    sCellIndex 3

${Xn-c_link_unavailable}    7311

${Xp-c_link_unavailable}    62003

${Inter-gNB_CA_Xp_communication_failure}    7331


*** Test Cases ***
CB008140-ET-JD02_Xn-c link unavailable between gNB1-gNB4 no affect to intergNB CA UE between gNB1-gNB2
    [Documentation]
    ...    The purpose of this test case is to verify Xn-c link unavailable between gNB2-gNB4, no affect to intergNB CA UE between gNB2-gNB3
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_19082, fully covered
    ...    CB008140-JD#B2: CA relations from neighbor gNB to which Xn link failed are not considered as ext-SCell candidates
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz SCellWeight=50 Cellid=0x4001
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz SCellWeight=50
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz SCellWeight=50 Cellid=0x8003/32771
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=50 Cellid=0x8004/32772
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=50 Cellid=0x800b/32779
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz SCellWeight=50 Cellid=0x800c/32780
    ...    Cell id=5 gnb=4 pci=18:0 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=40 Cellid=0x8c005/573445
    ...    Cell id=13 gnb=4 pci=21:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=40 Cellid=0x8c00d/573453
    ...    Cell id=14 gnb=4 pci=21:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz SCellWeight=40 Cellid=0x8c00e/573454
    ...    UE1 inter gNB-2+gNB-3 TFF 3CC CA
    ...    UE2 inter gNB-3+gNB-2 FTT 3CC CA
    ...    UE3 inter gNB-2+gNB-4 TFF 3CC CA
    ...    2.Test Case Steps:
    ...         Step a. Setup xp link between gNB-2 and sim gNB-4
    ...         Step b: UE1 register and PDU session Setup On Cell2_1,UE2 Register And PDU Session Setup On Cell3_11,then trigger A1 to add scells
    ...         Step c. UE3 register and PDU session Setup On Cell2_2,then deregister
    ...         Step d. Drop xn link between gNB-2 and sim gNB-4,then UE3 register and PDU session Setup On Cell2_2 and later deregister
    ...         Step e. Check Xn auto recover and fault id 7311 is cleared,one more time UE3 register and PDU session Setup On Cell2_2
    ...         Step f. UE1 and UE2 start trafiic and verify
    ...    3. Expected Results:
    ...         Step a: XP link setups successfully
    ...         Step b: UE1 add Cell3_11 and Cell3_12 as scells,UE2 add Cell2_1 and Cell2_2 as scells
    ...         Step c: UE3 blindly add Cell4_13 and Cell4_14 as scells and then deregistered successfully
    ...         Step d: XN link droped is successfully and fault id 7311 raises,UE3 fails to add Cell4_13 and Cell4_14 as scells and then
    ...                  deregistered successfully
    ...         Step e: UE3 blindly add Cell4_13 and Cell4_14 as scells and then deregistered successfully
    ...         Step f. Traffic is ok,seems XN dorp between gNB-2 and sim gNB-4 no impact on UE1 and UE2
    [Tags]    QC_278866    JD002    CA_LABEL-TFF(100MHz_TDD_n77+10MHz_FDD_n3+15MHz_FDD_n28)    CA_LABEL-FTT(10MHz_FDD_n3+100MHz_TDD_n77+40MHz_TDD_n77)
    ...    CA_LABEL-TFF(40MHz_TDD_n77+10MHz_FDD_n3+15MHz_FDD_n28)
    Setup XPAP Link
    Set Sim gNB ignb CA Addition Param
    SA UE1 And UE2 Register And Trigger Inter-gNB CA By A1
    UE3 Register And PDU Session Setup With Blind 2 Scells Addition
    Check Xn Link Status Then Drop Xn And Check Alarm
    UE3 Register And PDU Session Setup With no Scell Addition
    Check Xn Auto Recover And Check Alarm
    UE3 Register And PDU Session Setup With Blind 2 Scells Addition
    Check No Effect For UE1 And UE2
    Release UEs    ue_type=all

CB008140-ET-JE07_Xp-c link unavailable between gNB1-gNB4 no affect to intergNB CA UE between gNB1-gNB2
    [Documentation]
    ...    The purpose of this test case is to verify CA relations from neighbor gNB to which Xp-C link failed
    ...      Such relations are filtered out during SCell selection
    ...      Xp-c link unavailable between gNB1-gNB4, no affect to intergNB CA UE between gNB1-gNB2
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_19087, fully covered
    ...    CB008140-JE#B2: CA relations from neighbor gNB to which Xp-C link failed are not considered as ext-SCell candidates
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz SCellWeight=50 Cellid=0x4001
    ...    Cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on and=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz SCellWeight=50
    ...    Cell id=3 gnb=3 pci=17:1 tac=200 tdd_cell=on band=n77 nr_arfcn=653400:653400 gscn=8072 chBw=100MHz SCellWeight=50 Cellid=0x8003/32771
    ...    Cell id=4 gnb=3 pci=17:2 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=50 Cellid=0x8004/32772
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=50 Cellid=0x800b/32779
    ...    Cell id=12 gnb=3 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz SCellWeight=50 Cellid=0x800c/32780
    ...    Cell id=5 gnb=4 pci=18:0 tac=200 tdd_cell=on band=n77 nr_arfcn=648000:648000 gscn=8000 chBw=40MHz SCellWeight=40 Cellid=0x8c005/573445
    ...    Cell id=13 gnb=4 pci=21:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz SCellWeight=40 Cellid=0x8c00d/573453
    ...    Cell id=14 gnb=4 pci=21:1 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz SCellWeight=40 Cellid=0x8c00e/573454
    ...    UE1 inter gNB-2+gNB-3 TFF 3CC CA
    ...    UE2 inter gNB-3+gNB-2 FTT 3CC CA
    ...    UE3 inter gNB-2+gNB-4 TFF 3CC CA
    ...    2.Test Case Steps:
    ...         Step a. UE1 register and PDU session Setup On Cell2_1,UE2 Register And PDU Session Setup On Cell3_11,then trigger A1 to add scells
    ...         Step b: UE3 register and PDU session Setup On Cell2_2,then deregister
    ...         Step c. Drop XP link between gNB-2 and sim gNB-4,then UE3 register and PDU session Setup On Cell2_2 and later deregister
    ...         Step d. Setup XP link between gNB-2 and sim gNB-4 again and fault id 62003/7311 are cleared,one more time UE3 register and PDU
    ...                 session Setup On Cell2_2
    ...         Step e. UE1 and UE2 start trafiic and verify
    ...    3. Expected Results:
    ...         Step a: UE1 add Cell3_11 and Cell3_12 as scells,UE2 add Cell2_1 and Cell2_2 as scells
    ...         Step b: UE3 blindly add Cell4_13 and Cell4_14 as scells and then deregistered successfully
    ...         Step c: XP link droped is successfully and fault id 62003/7311 raises,UE3 fails to add Cell4_13 and Cell4_14 as scells and then
    ...                  deregistered successfully
    ...         Step d: UE3 blindly add Cell4_13 and Cell4_14 as scells and then deregistered successfully
    ...         Step f. Traffic is ok,seems XP dorp between gNB-2 and sim gNB-4 no impact on UE1 and UE2
    [Tags]    QC_278851    JE007    CA_LABEL-TFF(100MHz_TDD_n77+10MHz_FDD_n3+15MHz_FDD_n28)    CA_LABEL-FTT(10MHz_FDD_n3+100MHz_TDD_n77+40MHz_TDD_n77)
    ...    CA_LABEL-TFF(40MHz_TDD_n77+10MHz_FDD_n3+15MHz_FDD_n28)
    SA UE1 And UE2 Register And Trigger Inter-gNB CA By A1
    UE3 Register And PDU Session Setup With Blind 2 Scells Addition
    Drop XP And Trigger XP Setup With Sim GNB XP Ignore And Check Alarm
    UE3 Register And PDU Session Setup With No Scell Addition
    Clear XP Ignore And Trigger XP Setup And Check Alarm
    UE3 Register And PDU Session Setup With Blind 2 Scells Addition
    Check No Effect For UE1 And UE2
    Release UEs    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F    ue_count=3

Modify Cfg
    ${gNB4_sim_configuration}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124
    ...    nssai=0x1:0xd143a5 amf=1 xp=10.0.1.124:32742 xpu=10.0.1.124:32742 xp_management=on
    Update Cfg    ${gNB4_sim_configuration}
    ${gNB4_Cell5_sim_configuration}    catenate
    ...    set_cell id=5 gnb=4 pci=18:0 tac=200 nrci=0x05 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=648000:648000 gscn=8000
    ...    nr_scs=30kHz bs_channel_bandwidth=40MHz
    Update Cfg    ${gNB4_Cell5_sim_configuration}
    ${gNB4_Cell13_sim_configuration}    catenate
    ...    set_cell id=13 gnb=4 pci=21:0 tac=200 nrci=0x0d tdd_cell=off proxy=10.0.2.91:9999 nr_arfcn=349400:368400 gscn=4605
    ...    nr_scs=15kHz bs_channel_bandwidth=10MHz mandatory_for_activation=off
    Update Cfg    ${gNB4_Cell13_sim_configuration}
    ${gNB4_Cell14_sim_configuration}    catenate
    ...    set_cell id=14 gnb=4 pci=21:1 tac=200 nrci=0x0e tdd_cell=off proxy=10.0.2.92:9999 nr_arfcn=143400:153400 gscn=1916
    ...    nr_scs=15kHz bs_channel_bandwidth=15MHz mandatory_for_activation=off
    Update Cfg    ${gNB4_Cell14_sim_configuration}

Perform Steps After Onair
    Get Correct Xp XgU Version

Get Correct Xp XgU Version
    ${IgNBCAXpProtocol_Version}    Get Xp Version
    ${IgNBCAXgUProtocol_Version}    Get Xgu Version
    Set Suite Variable    ${IgNBCAXpVersion}    ${IgNBCAXpProtocol_Version}
    Set Suite Variable    ${IgNBCAXgUVersion}    ${IgNBCAXgUProtocol_Version}

Setup XPAP Link
    Execute Egate Command    sim_trace enb=4 protocol=xn on
    Execute Egate Command    enb_xp_param xp_peers=2 id=4
    ...    pass_regexp=GNB-4: XpAP Link with GNB-2.*is up    timeout=100

Set Sim gNB ignb CA Addition Param
    ${gNB4_param}    catenate
    ...    gnb_param id=4 bwp_profile_id=1 bwp_profile_type=powersaving act_multiple_dedicated_bwps=yes location_bw_ul=1:2 location_bw_dl=3:4
    ...    Inter_gNB_CA_Allowed=yes CellLoadReportingPeriodicity=000
    ...    IgNBCAXpProtocolVersion=${IgNBCAXpVersion} IgNBCAXgUProtocolVersion=${IgNBCAXgUVersion}
    Execute Egate Command    ${gNB4_param}
    ${gNB4_cell_param}    Set Variable    Cell_BWP_List=1,2 cell_Available=yes weightForSCellSelection=40 lteNrDssMode=lteNrDssModeNone
    Execute Egate Command    gnb_cell_param gnb=4 id=5 ${gNB4_cell_param}
    Execute Egate Command    gnb_cell_param gnb=4 id=13 ${gNB4_cell_param}
    Execute Egate Command    gnb_cell_param gnb=4 id=14 ${gNB4_cell_param}
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=4 target=2    IgNBCAConfigurationUpdateIndication
    ${gNB4_ca_param}    catenate    ignb_ca_addition_param gnb_id=4 DU-to-CU-RRCInfo=${DU-to-CU-RRCInfo}
    ...    ExtDu-to-PrimeDu-RrcInfo=${ExtDu-to-PrimeDu-RrcInfo}
    Execute Egate Command    ${gNB4_ca_param}

SA UE1 And UE2 Register And Trigger Inter-gNB CA By A1
    UE Register And Setup PDU Session    ue_id=1
    UE1 Send A1 To Trigger Scell Addition
    Run Traffic And Verify Throughput
    UE Register And Setup PDU Session    ue_id=2    gateway=2    enb_id=3    cell_id=11
    UE2 Send A1 To Trigger Scell Addition
    Run Traffic And Verify Throughput    ue_id=2

UE Register And Setup PDU Session
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gateway}    pass_regexp=QoS Routing Table    timeout=20s

UE1 Send A1 To Trigger Scell Addition
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=663360    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${UE1_expect}    fail_regexp=SCellIndex 3 activated successfully at airphone    timeout=20s

UE2 Send A1 To Trigger Scell Addition
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=2    carrierfreq=368430    event_type=A1
    ...    threshold=RSRP\ 111
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${UE2_expect}    fail_regexp=SCellIndex 3 activated successfully at airphone    timeout=20s

UE3 Register And PDU Session Setup With Blind 2 Scells Addition
    [Arguments]    ${ue_id}=3    ${nwslice}=1    ${gateway}=3    ${enb_id}=2    ${cell_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gateway}    pass_regexp=${UE3_expect}
    ...    timeout=20s    sleep_time=5
    Execute Egate Command    ue_deregister id=3 ue_deregister_type=switch_off    pass_regexp=UE3: detached

UE3 Register And PDU Session Setup With no Scell Addition
    [Arguments]    ${ue_id}=3    ${nwslice}=1    ${gateway}=3    ${enb_id}=2    ${cell_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}
    ...    fail_regexp=sCellIndex 1    timeout=5s
    Execute Egate Command    ue_deregister id=3 ue_deregister_type=switch_off    pass_regexp=UE3: detached

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
    Verify Throughput    ${ue_id}    ${pdu}    ${qfi}    540    25
    [teardown]    Stop Traffic    ${ue_id}    ${pdu}

Stop Traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=1    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=2    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=3    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=4    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=ul trf_id=1    pass_regexp=Stopping Uplink Internal traffic on Ue

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Check Xn Link Status Then Drop Xn And Check Alarm
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-1:xnLinkStatus=available
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=available
    Execute Egate Command    link_drop link=xn by=gnb:4 to=gnb:2 msg_type=shutdown
    Wait Until Keyword Succeeds    60s    2s    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=unavailable
    FM Fault Should Be Raised    fault_id=${Xn-c_link_unavailable}
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-1:xnLinkStatus=available

Check Xn Auto Recover And Check Alarm
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-1:xnLinkStatus=available
    Wait Until Keyword Succeeds    60s    2s    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=available
    FM Fault Should Be Cleared    fault_id=${Xn-c_link_unavailable}
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-1:xnLinkStatus=available
    Sleep    60s    #wait Xp setup
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=4 target=2    IgNBCAConfigurationUpdateIndication

Drop XP And Trigger XP Setup With Sim GNB XP Ignore And Check Alarm
    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-1:xpLinkStatus=available
    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-2:xpLinkStatus=available
    Execute Egate Command    enb_xp_param id=4 ignore_xp=on
    Execute Egate Command    link_drop link=xp by=gnb:4 to=gnb:2 msg_type=shutdown
    Wait Until Keyword Succeeds    60s    2s    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-2:xpLinkStatus=unavailable
    FM Fault Should Be Raised    fault_id=${Xp-c_link_unavailable}
    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-1:xpLinkStatus=available
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=available
    Sleep    60s    #cpif:XnService start scheduling igNBCaXpAvailabilityWaitTimer: 60s. Timeout and report interGnbCaXpCommunicationFailureAl
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Raised    fault_id=${Inter-gNB_CA_Xp_communication_failure}

Clear XP Ignore And Trigger XP Setup And Check Alarm
    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-1:xpLinkStatus=available
    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-2:xpLinkStatus=unavailable
    Execute Egate Command    enb_xp_param ignore_xp=off id=4
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=4 target=2    IgNBCAConfigurationUpdateIndication
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=available
    Wait Until Keyword Succeeds    180s    2s    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-2:xpLinkStatus=available
    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-1:xpLinkStatus=available
    FM Fault Should Be Cleared    fault_id=${Xp-c_link_unavailable}
    FM Fault Should Be Cleared    fault_id=${Inter-gNB_CA_Xp_communication_failure}

Check No Effect For UE1 And UE2
    Run Traffic And Verify Throughput
    Run Traffic And Verify Throughput    ue_id=2
