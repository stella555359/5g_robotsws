*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_LO_AP_LOOO    team-PZ3_6
...    owner-delun.li    release-SBTS24R3    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_STARTUP_RETRY}    2
${SYSCOM_FLAG}    ${True}
@{PARAMS_IN_IPHY_XML}
...    GeneralSettings:l3Timeout=30

${SA_Capa_perCC4allCC4}    SEPARATOR=
...    E1A09000575F7A13160003C420005820020301262E003387A12013641873E618F28581C130180623803546C4DD608C21A08107483401F5B2E
...    2AC68F3E238F40CFB027C66471E439F40CFB027D473E618F28583F87FE2E000BE0038002F8002E40007001B280002800003A8D85181AC1184
...    341020E906803EB65C558D0E7C471E819F604F8CC8E3C873E819F604FA8E7CC31E50B0381C3C5C0017C0070005F0005C0000E0030C1C28080
...    0001C61E14000613400021C61E1400060A000041C61C1401C4D0000061C60E268400000E31713400389A001C4D0000082E006014404D17000
...    47034089B1CF870A24ED8E7C3851226C73E1C29D13639F0E044D8E7C38912244D86BC701FAAAAAA0B800F800E070500703009401C00180F84
...    E00800000004000008020000000100000200800002004000018020000100100000A008004010040100000C008000060040000380200001C01
...    00080000002000020010008060180200002401000014008004040100100080E0380200002E49400818061724A0000C2E49401818060180617
...    24A0080C0300C2E494030180601806018060185C928040300C0300C030B92500E060180601806018060185C12800030B925000062724A0040
...    C031392500406018062704A0000C4E49403818060180601806018062724A00C0C0300C0313925000060724A01C0C0300C0300C0300C030392
...    500606018060181C1280003030040000681BCA9ACA9AC14AC0CAC0DAC19ACA5AC99AC05AC04AC08AC8DADD2305681A0800004B29282000032
...    CA480800014B29282000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B292020001
...    72CA4A0802060192CA4A0800064B292818A55554AA2E9555D2A8AA0B1540E2A83455298AA4D154062A8145523AAAED40B017C09E8140A0502
...    8140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A050000800101C00C20200C01808030001010
...    0600C04008000808030000200C018804018030100600C04018031AA06000102030406074200

${SA_Capa_perCC2}    SEPARATOR=
...    E1A09000575F7A13160003C420005820020301262E003387A12013641873E618F28581C130180623803546C4DD608C21A08107483401F5B2E2
...    AC68F3E238F40CFB027C66471E439F40CFB027D473E608F28581F87FE2E000BE0038002F8002E40007001B280002800003A8D85181AC118434
...    1020E906803EB65C558D0E7C471E819F604F8CC8E3C873E819F604FA8E7CC31E50B0381C3C5C0017C0070005F0005C0000E0030C1C28080000
...    1C61E14000613400021C61E1400060A000041C61C1401C4D0000061C60E268400000E31713400389A001C4D0000082E006014404D170004703
...    4089B1CF870A24ED8E7C3851226C73E1C29D13611F0E044D847C38912244D84BC701E82E003E0028101401C0C025007000603E138020000000
...    1000002008000000040000080200000801000006008000040040000280200100401004000030020000180100000E0080000700400200000008
...    00008004002018060080000900400005002001010040040020380E0080000B925002060185C92800030B92500606018060185C928020300C03
...    0B92500C060180601806018061724A0100C0300C0300C2E49403818060180601806018061704A0000C2E494000189C928010300C4E49401018
...    060189C12800031392500E060180601806018060189C928030300C0300C4E494000181C928070300C0300C0300C0300C0E4940181806018060
...    704A0000C0C0100001A06F2A6B2A6B052B032B036B066B296B266B016B012B022B236B748C15A0682000012CA4A080000CB29202000052CA4A
...    080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB2928200818064B
...    29282000192CA4A062955552A8BA55574AA2A82C55038AA0D154A62A93455018AA051548EAABB502C05F027A05028140A05028140A05028140
...    A05028140A05028140A05028140A05028140A05028140A05028140A050281400020004070030808030060200C000404018030100200020200C
...    000080300620100600C04018030100600C6A8180004080C10181D080

${SA_Capa_bigenough}    SEPARATOR=
...    E1A09000575F7A13160003C420005820020301262E003387A12013641873E618F28581C130180623803546C4DD608C21A08107483401F5B2E
...    2AC68F7E238F40CFB027C66471E439F40CFB027D473E618F28583F87FE2E000BE0038002F8002E40007001B280002800003A8D85181AC1184
...    341020E906803EB65C558D0E7C471E819F604F8CC8E3C873E819F604FA8E7CC31E50B0381C3C5C0017C0070005F0005C0000E0030C1C28080
...    0001C61E14000613400021C61E1400060A000041C61C1401C4D0000061C60E268400000E31713400389A001C4D0000082E006014404D17000
...    47034089B1CF870A24ED8E7C3851226C73E1C29D13639F0E044D8E7C38912244D8EBC701FAAAAAA0B800F800E070500703009401C00180F84
...    E00800000004000008020000000100000200800002004000018020000100100000A008004010040100000C008000060040000380200001C01
...    00080000002000020010008060180200002401000014008004040100100080E0380200002E49400818061724A0000C2E49401818060180617
...    24A0080C0300C2E494030180601806018060185C928040300C0300C030B92500E060180601806018060185C12800030B925000062724A0040
...    C031392500406018062704A0000C4E49403818060180601806018062724A00C0C0300C0313925000060724A01C0C0300C0300C0300C030392
...    500606018060181C1280003030040000681BCA9ACA9AC14AC0CAC0DAC19ACA5AC99AC05AC04AC08AC8DADD2305681A0800004B29282000032
...    CA480800014B29282000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B292020001
...    72CA4A0802060192CA4A0800064B292818A55554AA2E9555D2A8AA0B1540E2A83455298AA4D154062A8145523AAAED40B017C09E8140A0502
...    8140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A050000800101C00C20200C01808030001010
...    0600C04008000808030000200C018804018030100600C04018031AA06000102030406074200

@{PARAMS_IN_SCF}
...    @{PARAMS_USA1_pre}
...    @{PARAMS_FOR_CA}

@{PARAMS_USA1_pre}
...    NRBTS:actTddCsiRsOpt=true
...    NRBTS:actExplicitCsirsPoolSolution=true
...    NRCELL:actUeCsirsCoexistCellCsirs=false
...    NRBTS:actBbPoolExtensionTddFr1=true
...    NRBTS:actTddCsiImRm=false
...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL:actSubTRSRateMatch=true
...    NRCELL:actCsiRsMuting=true
...    NRCELL:numOfSubSectors=0sub-sector
...    NRCELL:actCsirsMultiplexing=true
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=3
...    NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-3:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=3
...    NRCELL:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL:csirsForTracking:csirsTrackingPeriod=80ms
...    NRCELL:csirsForTracking:rbAllocation=52RB
...    NRCELL-1:csirsForTracking:firstRE=0
...    NRCELL-1:csirsForTracking:startRB=160
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-1:beamSet:basicBeamSet=beamSet_6
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=2 beams
...    NRCELL-2:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-3:beamSet:basicBeamSet=beamSet_4
...    NRCELL-2:csirsForTracking:firstRE=1
...    NRCELL-2:csirsForTracking:startRB=100
...    NRCELL-3:csirsForTracking:firstRE=1
...    NRCELL-3:csirsForTracking:startRB=0
...    NRBTS-1:rrcReestabTypeSA=sameGNB


@{PARAMS_FOR_CA}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:actBcsCheck=disabled
...    NRCELL:actCDrx=false
...    @{PARAMS_FOR_A1sCellAdd_A2_for_NRCELL}

${CA_support_list}    SEPARATOR=,
...    ca_Fr1Tdd_Fdd_Nsa
...    ca_Fr1Tdd_Nsa
...    ca_Fdd_Fr1Tdd_Nsa
...    ca_Fdd_Fr1Tdd_Sa
...    ca_Fdd_Fdd
...    ca_Fdd_Any_Sa
...    ca_Fr1Tdd_Fdd_Sa
...    ca_Fr1Tdd_Sa
...    ca_Fr1Tdd_Any_Sa

@{PARAMS_FOR_A1sCellAdd_A2_for_NRCELL}
...    NRCELL-3/NRREL-31:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-31:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-31:gNbId=1
...    NRCELL-3/NRREL-31:gNbIdLength=22
...    NRCELL-3/NRREL-31:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-31:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-31:lcrId=1
...    NRCELL-3/NRREL-31:nrDcAllowed=false
...    NRCELL-3/NRREL-31:removeNotAllowed=false
...    NRCELL-3/NRREL-31:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-31:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-31:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-31:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-31:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=60|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{actTddCsiImRm_modify_to_true}
...    NRBTS:actTddCsiImRm=true

@{maxCsirsNumber_modify_to_2}
...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=2

@{maxCsirsNumber_modify_back_to_4}
...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=4
...    NRBTS:actTddCsiImRm=false

@{parameter_disable_12269_all_flag}
...    NRBTS:actTddCsiRsOpt=false
...    NRBTS:actTddCsiImRm=false
...    NRCELL:actSubTRSRateMatch=false
...    NRCELL:actCsiRsMuting=false

@{parameter_enable_C012}
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL:actPerCsiReportBundlingTddFr1=true
...    NRCELL:allowCsiRsOutsideDRX=true
...    NRCELL:actCDrx=true
#remove as CB009109
#...    NRCELL:drxProfile1:drxLongCycle=20ms
#...    NRCELL:drxProfile1:drxOnDurationTimer=2ms
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2|a2ThresholdhoSsbRsrpSA=5|a2TimeToTriggerhoSsbRsrpSA=ms128
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1ThresholdhoSsbRsrpSA=30|a1TimeToTriggerhoSsbRsrpSA=ms100
...    NRCELL-3:gapOffset=33
...    NRCELL-3:ifhoSsbSmtcOffset=34
...    NRCELL-3:actFlexGapOffset=none
...    NRCELL-3:actCsiResAllocOptList=csiRepAllCcHighCsiRs,sCellCsiAllocAlgoOpt
...    NRBTS/NRDRX-4:drxLongCycle=20ms
...    NRBTS/NRDRX-4:drxOnDurationTimer=2ms
...    @{parameter_12269}
...    @{IRAT_Config_GNB}

@{parameter_enable_C012_rollback}
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=3
...    NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-3:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=3
...    NRCELL:actPerCsiReportBundlingTddFr1=false
...    NRCELL:allowCsiRsOutsideDRX=false
...    NRCELL:actCDrx=false
...    NRBTS:actTddCsiImRm=false

@{parameter_12269}
...    NRBTS:actTddCsiImRm=true
...    NRBTS:actTddCsiRsOpt=true
...    NRCELL:actSubTRSRateMatch=true
...    NRCELL:actCsiRsMuting=true

@{IRAT_Config_GNB}
...    NRBTS:actInterRatHoFromEutraToSA=true
...    NRBTS:nonContentRachAcFullConfigHo=true
...    NRBTS:tNgRelocExecDeltL=5000
...    NRCELL:measGapSelectionSA=favorFastMeasurements
...    NRBTS:actInterRatHoSA=true
...    NRCELL:actCDrx=true
...    NRBTS/NRHOIR-1:allowedMeasBandwidth=mbw100
...    NRBTS/NRHOIR-1:b2MeashoEnabled=rsrp
...    NRBTS/NRHOIR-1:b2Threshold1hoRsrp=35
...    NRBTS/NRHOIR-1:b2Threshold1hoRsrq=50
...    NRBTS/NRHOIR-1:earfcnValue=1
...    NRBTS/NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480
...    NRBTS/NRCELL-3:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    NRBTS/NRADJECELL-8:eNodeBId=18
...    NRBTS/NRADJECELL-8:ePSTrackingAreaCode=0
...    NRBTS/NRADJECELL-8:earfcnValue=1
...    NRBTS/NRADJECELL-8:lcrId=1
...    NRBTS/NRADJECELL-8:physCellId=11
...    NRBTS/NRADJECELL-8:ecgiPlmn:mcc=311
...    NRBTS/NRADJECELL-8:ecgiPlmn:mnc=489
...    NRBTS/NRADJECELL-8:ecgiPlmn:mncLength=3
...    NRBTS/NRADJECELL-8:enbPlmn:mcc=311
...    NRBTS/NRADJECELL-8:enbPlmn:mnc=489
...    NRBTS/NRADJECELL-8:enbPlmn:mncLength=3
...    NRCELL-3/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-3/NRRELE-1:eNodeBId=18
...    NRCELL-3/NRRELE-1:eutranCellExcluded=false
...    NRCELL-3/NRRELE-1:lcrId=1
...    NRCELL-3/NRRELE-1:removeNotAllowed=false
...    NRCELL-3/NRRELE-1:ecgiPlmn:mcc=311
...    NRCELL-3/NRRELE-1:ecgiPlmn:mnc=489
...    NRCELL-3/NRRELE-1:ecgiPlmn:mncLength=3
...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=15
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=20
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms

@{parameter_online_modify_gapoffset_12}
...    NRCELL-3:gapOffset=12
...    NRCELL-3:ifhoSsbSmtcOffset=13

@{expect_regexp_NRCELL1_3cc}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{expect_regexp_NRCELL3_2cc}
...    pcid:52, scellIdx:0] configure_0_1
...    pcid:52, scellIdx:0] configure_1_1
...    pcid:50, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone

${cellsetup_15M_nrcell-1}    SEPARATOR=
...    itf_l2_ps_cell_CellSetupReq_t.zpCsiRsResources.Length == 15 &&
...    itf_l2_ps_cell_TddCsirsOptConfig.actTddCsiImRm == 1 &&
...    itf_l2_ps_cell_CellSetupReq_t.nrCellIdentity == 16385

${cellsetup_15M_nrcell-2}    SEPARATOR=
...    itf_l2_ps_cell_CellSetupReq_t.zpCsiRsResources.Length == 15 &&
...    itf_l2_ps_cell_TddCsirsOptConfig.actTddCsiImRm == 1 &&
...    itf_l2_ps_cell_CellSetupReq_t.nrCellIdentity == 16386

${cellsetup_15M_nrcell-2-1}    SEPARATOR=
...    itf_l2_ps_cell_CellSetupReq_t.zpCsiRsResources.Length == 14 &&
...    itf_l2_ps_cell_TddCsirsOptConfig.actTddCsiImRm == 1 &&
...    itf_l2_ps_cell_CellSetupReq_t.nrCellIdentity == 16386

${cellsetup_15M_nrcell-3}    SEPARATOR=
...    itf_l2_ps_cell_CellSetupReq_t.zpCsiRsResources.Length == 15 &&
...    itf_l2_ps_cell_TddCsirsOptConfig.actTddCsiImRm == 1 &&
...    itf_l2_ps_cell_CellSetupReq_t.nrCellIdentity == 16387

${3cell_actTddCsirsOpt_false}    SEPARATOR=
...    (itf_l2_ps_cell_cellsetupreq) && (itf_l2_ps_cell_CellSetupReq_t.actTddCsirsOpt == 0)

${3cell_actTddCsirsOpt_true}    SEPARATOR=
...    (((((itf_l2_ps_cell_cellsetupreq) && (itf_l2_ps_cell_CellSetupReq_t.actTddCsirsOpt == 1)) &&
...    (itf_l2_ps_csi_ZpCsiRsResource.zpCsiRsAssociation == 2)) && (itf_l2_ps_cell_TddCsirsOptConfig.actTddCsiImRm == 1)) &&
...    (itf_l2_ps_cell_TddCsirsOptConfig.actSubTrsRateMatch == 1)) && (itf_l2_ps_cell_TddCsirsOptConfig.actCsiRsMuting == 1)

@{A2_expect}
...    gapFR1 setup
...    drx-Config release
...    rrcReconfigurationComplete

@{A1_expect}
...    drx-Config setup
...    gapFR1 release

@{B2_expect}
...    HandoverRequired
...    Successful handover from EXT_ENB-2.3 to ENB-4.1
...    UeContextReleaseComplete

@{ENBTo5G}
...    HandoverRequest
...    ENB-4.1 to EXT_ENB-2.3

*** Test Cases ***
CB012269-ET-A009_US4_3CELL_actTddCsiImRm_enable_for_Cell_specific_CSI-IM_optimizationwith_semistat_14
    [Documentation]
    ...    1. This user scenario validates the slots allocation for sub-band TRS and cell specific CSI-RS
    ...    2. Configuration
    ...       NRCELL-1_csirsTrackingPeriod-80ms, rbAllocation-52RB, startRB-160,
    ...                csiReportPeriod_slots320, csirsNumberSet1_1, maxCsirsNumber_4,beams_6
    ...       NRCELL-2_csirsTrackingPeriod-80ms, rbAllocation-52RB, startRB-100,
    ...                csiReportPeriod_slots320, csirsNumberSet1_3, maxCsirsNumber_4,beams_2
    ...       NRCELL-3_csirsTrackingPeriod-40ms, rbAllocation-52RB, startRB-0,
    ...                csiReportPeriod_slots80, csirsNumberSet1_3, maxCsirsNumber_4,beams_4
    ...       NRCELL-2 configured NRCELL-1, NRCELL-3 as scells
    ...    2. Test Case Steps:
    ...           a. UE1_percc2 attach to PCI 50.
    ...           b. make traffic.
    ...           c. UE2_percc2 attach to PCI 52.
    ...           d. make traffic.
    ...           e. UE3_percc4ALLCC4 attach to PCI 51.
    ...           f. make traffic.

    ...     3. Expected result:
    ...           a. UE1 attach success, CSIRS and CSIIM period is slots320.
    ...           b. traffic is ok.
    ...              UE1 3CC setup success, and then UE1 downgrade from RS2 to RS1 because of maxNumberSimultaneousNZP-CSI-RS-ActBWP-AllCC=3
    ...           c. UE2 attach success, CSIRS and CSIIM period is slots80.
    ...           d. traffic is ok.
    ...              UE2 2CC setup success, and then UE have not downgrade because of maxNumberSimultaneousNZP-CSI-RS-ActBWP-AllCC=3
    ...           e. UE3 attach success, CSIRS and CSIIM period is slots40.
    ...           f. traffic is ok.
    ...              UE3 CA setup success, UE3 downgrade from RS4 to RS2 because of maxCsirsNumber_modify_to_2.

    [Tags]    A009    QC_363599    CA_LABEL-TTT(80M_TDD_n78+60M_TDD_n78+80M_TDD_n78)
    OnlineParamChange    ${actTddCsiImRm_modify_to_true}
    UE1_perCC2_RS2DowntoRS1_csirsreportperiod320
    UE2_perCC2_NoDown_csirsreportperiod80
    OnlineParamChange    ${maxCsirsNumber_modify_to_2}
    UE3_percc4Allcc4_RS4DowntoRS2_csirsreportperiod40
    Check Wireshark Log    ${CURDIR}${/}A2A_A_009${/}a2a.ini    wait_string=UEContextRelease::0
    Check L2PS syscom message
    [Teardown]    Test teardown

CB012269-ET-C012_IWK_measurementgaps_check_when_CSI_RS4_CSI_IM_move_to_other_slot_A2B2_IRAT_HO
    [Documentation]
    ...    1. This user scenario validates the CB101229 IWK with 2CC and Measgap.
    ...    2. Configuration
    ...       refer to parameter_enable_C012
    ...    2. Test Case Steps:
    ...           a. UE1_csirs_Allcc4 attach to nrcell-3 and scell nrcell-1
    ...           b. trigger A2
    ...           c. trigger A1
    ...           d. UE1 release
    ...           e. UE_2 has enough csirs allcc ue capa
    ...           f. trigger A2
    ...           g. trigger B2 to handover to lte and HO back
    ...           h. UE2 release
    ...     3. Expected result:
    ...           a. UE1 attach success, check CSIIM slot and use RS4 when non CA, then degrade to RS2 when CA,traffic is ok.
    ...           b. after A2,measgap setup, and conflict with RS2, so degrade to RS1---this step not stable as CSIRS slot is not fixed.
    ...           c. after A1, gap release, no csirs update.
    ...           d. ue released
    ...           e. UE2 attach success, pcell and scell use RS4. check CSIIM slot
    ...           f. after A2, gap setup, conflict with pcell csirs or IM, degrade to RS2
    ...           g. HO between 5G and LTE are ok
    ...           h. ue released
    [Tags]    C012    QC_363802    CA_LABEL-TT(80M_TDD_n78+80M_TDD_n78)
    OnlineParamChange    ${parameter_disable_12269_all_flag}
    OnlineParamChange    ${parameter_enable_C012}
    UE1_percc4Allcc4_attach_NRCELL_3_add_scell_nrcell_1_triggerA2A1
    OnlineParamChange    ${parameter_online_modify_gapoffset_12}
    UE2_with_bigUEcapa_attach_NRCELL_3_add_scell_nrcell_1_triggerA2B2
    Check Wireshark Log    ${CURDIR}${/}A2A_C_012${/}a2a.ini    wait_string=UEContextRelease::36
    Check L2PS syscom message C012
    [Teardown]    Test teardown    ${parameter_enable_C012_rollback}

*** Keywords ***
UE1_perCC2_RS2DowntoRS1_csirsreportperiod320
    UE attach and Scell added coverbase    ue_id=1    UE_Capabilities=${SA_Capa_perCC2}    expect_regexp=${expect_regexp_NRCELL1_3cc}
    ...    CC_num=3
    Traffic stop    ue_id=1

UE2_perCC2_NoDown_csirsreportperiod80
    UE attach and Scell added coverbase    ue_id=2    UE_Capabilities=${SA_Capa_perCC2}    expect_regexp=${expect_regexp_NRCELL3_2cc}
    ...    CC_num=2    cell_id=3    cellfreq=649920
    Traffic stop    ue_id=2

UE3_percc4Allcc4_RS4DowntoRS2_csirsreportperiod40
    UE attach and send traffic    ue_id=3    cell_id=2    CC_num=1    UE_Capabilities=${SA_Capa_perCC4allCC4}

UE1_percc4Allcc4_attach_NRCELL_3_add_scell_nrcell_1_triggerA2A1
    UE attach and Scell added coverbase    ue_id=1    UE_Capabilities=${SA_Capa_perCC4allCC4}    expect_regexp=${expect_regexp_NRCELL3_2cc}
    ...    CC_num=2    cell_id=3    cellfreq=649920
    Trigger A2 HO    ue_id=1
    Trigger A1 MR    ue_id=1
    Ue Deregister    id=1

UE2_with_bigUEcapa_attach_NRCELL_3_add_scell_nrcell_1_triggerA2B2
    UE attach and Scell added coverbase    ue_id=2    UE_Capabilities=${SA_Capa_bigenough}    expect_regexp=${expect_regexp_NRCELL3_2cc}
    ...    CC_num=2    cell_id=3    cellfreq=649920
    Trigger A2 HO    ue_id=2
    Trigger B2 HO    ue_id=2
    trigger handover from ENB to 5G    ue_id=2
    Ue Deregister    id=2

Sa CA UE Register
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    sleep_time=${wait_timer}    pass_regexp=NG RM Registered

Check Throughput with Type
    [Arguments]    ${ue_id}=1    ${Tput_expect}=80    ${CC_num}=2    ${type}=pdsch
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=${type}    pass_regexp=Average
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check    ${ue_id}    ${id}    ${type}
        ${all_tput}    Evaluate    ${all_tput}+${cell_tput}
	END
    Should Be True    ${all_tput}/1000 > ${Tput_expect}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 13

Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0    ${type}=pdsch
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=${type}    rate_type=ave

SA CA UE Setup PDU Session Successfully
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=${cell_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1
    ...    pass_regexp=PDU SESSION ID-1 setup/reestablishment complete

Traffic Send
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=5 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=6 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=7 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=1 mbps=15    UE ${ue_id}: UDP UL

Traffic stop
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_stop ue=${ue_id} pdu=1 qfi=1 dir=dl    Traffic was stopped
    Execute Egate Command    data_trf_stop ue=${ue_id} pdu=1 qfi=1 dir=ul    Stopping Uplink Internal traffic

UE attach and send traffic
    [Arguments]    ${ue_id}=1    ${CC_num}=1    ${UE_Capabilities}=${SA_Capa_perCC4allCC4}    ${cell_id}=1
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${UE_Capabilities}
    SA CA UE Setup PDU Session Successfully    ue_id=${ue_id}    cell_id=${cell_id}
    Traffic Send    ue_id=${ue_id}
    wait until keyword succeeds    60s    5s    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=840    CC_num=${CC_num}    type=pdsch
    Traffic stop    ue_id=${ue_id}

UE attach and Scell added coverbase
    [Arguments]    ${ue_id}=1    ${CC_num}=1    ${expect_regexp}=${EMPTY}    ${fail_reg_ca}=${EMPTY}
    ...    ${UE_Capabilities}=${SA_Capa_perCC4allCC4}    ${cell_id}=1    ${cellfreq}=636576
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${UE_Capabilities}
    SA CA UE Setup PDU Session Successfully    ue_id=${ue_id}    cell_id=${cell_id}
    UE Send A1 Trigger Scell Addition    ${ue_id}    ${cellfreq}    ${expect_regexp}    ${fail_reg_ca}
    Traffic Send    ue_id=${ue_id}
    wait until keyword succeeds    60s    5s    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=930    CC_num=${CC_num}    type=pdsch

UE Send A1 Trigger Scell Addition
    [Arguments]    ${ue_id}    ${cellfreq}    ${pass_reg_ca}=${EMPTY}    ${fail_reg_ca}=${EMPTY}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${pass_reg_ca}
    ...    fail_regexp=${fail_reg_ca}

Test teardown
    [Arguments]    ${onlineparameter}=${maxCsirsNumber_modify_back_to_4}
    OnlineParamChange    ${onlineparameter}
    Common Test Teardown And Stop Capture Logs

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/3cells_ecpri_8pipes

Set UE Capability
    [Arguments]    ${ue_id}=1    ${UE_Capabilities}=${SA_Capa_perCC4allCC4}    ${wait_timer}=0.5
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}    sleep_time=${wait_timer}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}    timeout=600

Check L2PS syscom message
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    ${cellsetup_15M_nrcell-1}
    should be equal As Numbers    ${number}    2
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    ${cellsetup_15M_nrcell-2}
    should be equal As Numbers    ${number}    1
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    ${cellsetup_15M_nrcell-2-1}
    should be equal As Numbers    ${number}    1
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    ${cellsetup_15M_nrcell-3}
    should be equal As Numbers    ${number}    2


Trigger A2 HO
    [Arguments]    ${ue_id}=1    ${freq}=649920
    ${A2_meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A2    carrierfreq=${freq}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=${A2_expect}
    sleep    5s    reason=wait timer

Trigger B2 HO
    [Arguments]    ${ue_id}=1    ${freq}=649920
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=B2    carrierfreq=1    carrierfreq_rat=EUTRAN
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=B2 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=11 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${cmd}    pass_regexp=${B2_expect}
    sleep    5s    reason=wait timer

trigger handover from ENB to 5G
    [Arguments]    ${ue_id}=1
    ${cmd}    Catenate    gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=3 plmn=311:489
    Execute Egate Command    ${cmd}    pass_regexp=${ENBTo5G}
    sleep    10s    reason=wait timer

Ue Deregister
    [Arguments]    ${id}=1
    Execute Egate Command    ue_deregister id=${id} ue_deregister_type=switch_off    detach

Modify Cfg
    ${C_1}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.138 daemon=10.0.2.1:22222 gnb_id=0x12:28 nssai=0x01:0xD143A5
    ${C_2}    catenate
    ...    set_cell id=1 gnb=4 pci=3:2 earfcn=1:18001 tac=0 proxy=10.0.2.92:12219 nrci=0x01
    ...    tdd_cell=on bw=20MHz technology=lte
    Update Cfg    ${C_1}
    Update Cfg    ${C_2}
    Update Cfg    gnb_param id=4 xn_listening_socket=true

Trigger A1 MR
    [Arguments]    ${ue_id}=1    ${carrierfreq}=649920    ${event}=A1
    Execute Egate Command     ue_meas_cfg_disp id=${ue_id}
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event}
    Execute Egate Command     ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${A1_expect}
    sleep    5s    reason=wait timer

Check L2PS syscom message C012
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    ${3cell_actTddCsirsOpt_false}
    should be equal As Numbers    ${number}    3
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark.pcap    ${3cell_actTddCsirsOpt_true}
    should be equal As Numbers    ${number}    3
