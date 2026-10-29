*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_LO_AP_LOOO    team-PZ3_6
...    owner-lingyan.zhou    release-SBTS24R3    CRT
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
...   E1A09000575F7A13160003C420005820020301262E003387A12013641873E618F28581C130180623803546C4DD608C21A08107483401F5B2E2
...   AC68F3E238F40CFB027C66471E439F40CFB027D473E608F28581F87FE2E000BE0038002F8002E40007001B280002800003A8D85181AC118434
...   1020E906803EB65C558D0E7C471E819F604F8CC8E3C873E819F604FA8E7CC31E50B0381C3C5C0017C0070005F0005C0000E0030C1C28080000
...   1C61E14000613400021C61E1400060A000041C61C1401C4D0000061C60E268400000E31713400389A001C4D0000082E006014404D170004703
...   4089B1CF870A24ED8E7C3851226C73E1C29D13639F0E044D8E7C38912244D96BC701E82E003E0028101401C0C025007000603E138020000000
...   1000002008000000040000080200000801000006008000040040000280200100401004000030020000180100000E0080000700400200000008
...   00008004002018060080000900400005002001010040040020380E0080000B925002060185C92800030B92500606018060185C928020300C03
...   0B92500C060180601806018061724A0100C0300C0300C2E49403818060180601806018061704A0000C2E494000189C928010300C4E49401018
...   060189C12800031392500E060180601806018060189C928030300C0300C4E494000181C928070300C0300C0300C0300C0E4940181806018060
...   704A0000C0C0100001A06F2A6B2A6B052B032B036B066B296B266B016B012B022B236B748C15A0682000012CA4A080000CB29202000052CA4A
...   080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB2928200818064B
...   29282000192CA4A062955552A8BA55574AA2A82C55038AA0D154A62A93455018AA051548EAABB502C05F027A05028140A05028140A05028140
...   A05028140A05028140A05028140A05028140A05028140A05028140A050281400020004070030808030060200C000404018030100200020200C
...   000080300620100600C04018030100600C6A8180004080C10181D080

${SA_Capa_perCC1}    SEPARATOR=
...    E1A09000575F7A13160003C420005820020301262E003387A12013641873E618F28581C130180623803546C4DD608C21A08107483401F5B2E
...    2AC68F3E238F40CFB027C66471E439F40CFB027D473E600F28581F87FE2E000BE0038002F8002E40007001B280002800003A8D85181AC1184
...    341020E906803EB65C558D0E7C471E819F604F8CC8E3C873E819F604FA8E7CC31E50B0381C3C5C0017C0070005F0005C0000E0030C1C28080
...    0001C61E14000613400021C61E1400060A000041C61C1401C4D0000061C60E268400000E31713400389A001C4D0000082E006014404D17000
...    47034089B1CF870A24ED8E7C3851226C73E1C29D13639F0E044D8E7C38912244D96BC701E82E003E0028101401C0C025007000603E1380200
...    000001000002008000000040000080200000801000006008000040040000280200100401004000030020000180100000E0080000700400200
...    00000800008004002018060080000900400005002001010040040020380E0080000B925002060185C92800030B92500606018060185C92802
...    0300C030B92500C060180601806018061724A0100C0300C0300C2E49403818060180601806018061704A0000C2E494000189C928010300C4E
...    49401018060189C12800031392500E060180601806018060189C928030300C0300C4E494000181C928070300C0300C0300C0300C0E4940181
...    806018060704A0000C0C0100001A06F2A6B2A6B052B032B036B066B296B266B016B012B022B236B748C15A0682000012CA4A080000CB29202
...    000052CA4A080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB292
...    8200818064B29282000192CA4A062955552A8BA55574AA2A82C55038AA0D154A62A93455018AA051548EAABB502C05F027A05028140A05028
...    140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A050281400020004070030808030060200C000404018030
...    100200020200C000080300620100600C04018030100600C6A8180004080C10181D080

${ue_eutra_nr_capabilities}    SEPARATOR=
...    AD1FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A00038820000
...    002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400389A00000C2C040804808D00A001C0
...    41809A2E800B907893A244D8E7C3893A244D8E7C3893A244D8E7C3893A244D8E7C3893A24498E7D1A7448912639F449D1224C33E01A0718C6
...    318C60D00104000100808010040201803080002010100600C04018031800040202018030080600C0201803080002010100600C04018030000
...    0000

@{PARAMS_IN_SCF}
...    @{PARAMS_USA1_pre}


@{PARAMS_USA1_pre}
...    NRBTS:actTddCsiRsOpt=true
...    NRBTS:actExplicitCsirsPoolSolution=true
...    NRCELL:actUeCsirsCoexistCellCsirs=false
...    NRCELL:actSubTRSRateMatch=false
...    NRBTS:actBbPoolExtensionTddFr1=true
...    NRCELL:actCsiRsMuting=true
...    NRCELL:numOfSubSectors=0sub-sector
...    NRCELL:actCsirsMultiplexing=true
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=3
...    NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-3:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=4
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



@{PM_Counters_Check_A001}
...    NRCELL-3:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-3:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-3:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-3:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-3:${SGNB_DU_NSA_ADMISSION_REQ}=1
...    NRCELL-3:${SGNB_DU_NSA_ADMISSION_SUCC}=1
...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-3:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-3:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-3:${SGNB_SCELL_ADMISSION_UNSUCC}=0
...    NRDU-1:${RRC_REESTAB_RECONF_FAILURE_DU}=2
...    NRDU-1:${REESTAB_ACC_RECONF_FAIL_DU}=2
...    NRCELL-1:${RRC_REESTAB_RECONF_FAILURE}=0
...    NRCELL-1:${REESTAB_ACC_RECONF_FAIL}=0
...    NRCELL-2:${RRC_REESTAB_RECONF_FAILURE}=1
...    NRCELL-2:${REESTAB_ACC_RECONF_FAIL}=1
...    NRCELL-3:${RRC_REESTAB_RECONF_FAILURE}=1
...    NRCELL-3:${REESTAB_ACC_RECONF_FAIL}=1
...    NRCELL-1:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-3:${UE_PCELL_2_CONF_SCELL_DL_SA}=0
...    NRCELL-2:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-3:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${UE_SCELL_2_CONF_SCELL_DL_SA}=0
...    NRCELL-1:${RRC_RECONF_ADD2DLSCELL_SUCC_SA}=3
...    NRCELL-1:${RRC_RECONF_ADD2DLSCELL_ATT_SA}=3

${RRC_REESTAB_RECONF_FAILURE_DU}    M55127C00501    #Number of RRC Re-establishment Request caused by reconfiguration failure
${RRC_REESTAB_RECONF_FAILURE}       M55124C00503    #Number of RRC Re-establishment Request caused by reconfiguration failure
${REESTAB_ACC_RECONF_FAIL_DU}       M55127C00510    #Number of accepted RRC Re-establishment when reestablishment cause is reconfiguration failure
${REESTAB_ACC_RECONF_FAIL}          M55124C00510    #Number of accepted RRC Re-establishment when reestablishment cause is reconfiguration failure
${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001    #Sum of CA UEs in the current cell configured as a PCell, which have 2 configured SCells in DL
${RRC_RECONF_ADD2DLSCELL_SUCC_SA}    M55118C07003    #Successful RRC Reconfigurations attempts for 2 SCells Addition in DL for SA mode
${RRC_RECONF_ADD2DLSCELL_ATT_SA}    M55118C07004    #RRC Reconfigurations attempts for 2 SCells Addition in DL for SA mode
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002    #Sum of CA UEs in the current cell configured as a SCell, which have 2 configured SCells in DL
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
${SGNB_DU_NSA_ADMISSION_REQ}    M55115C00002
${SGNB_DU_NSA_ADMISSION_SUCC}    M55115C00003
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007
${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028
${SGNB_SCELL_ADMISSION_UNSUCC}    M55114C00035

*** Test Cases ***
CB012269-ET-A001_US1_SANSA_subBandTRS_cell_specific_CSI_RS_with_diff_period_160_80_40_slots_with_semiStatic_37_with_246SsBlocks
    [Documentation]
    ...    1. This user scenario validates the slots allocation for sub-band TRS and cell specific CSI-RS
    ...    2. Configuration
    ...       NRCELL-1_csirsTrackingPeriod-80ms, firstRE-0, rbAllocation-52RB, startRB-160,
    ...                csiReportPeriod_slots160, csirsNumberSet1_1, maxCsirsNumber_4,beams_6
    ...       NRCELL-2_csirsTrackingPeriod-80ms, firstRE-1, rbAllocation-52RB, startRB-100,
    ...                csiReportPeriod_slots320, csirsNumberSet1_3, maxCsirsNumber_4,beams_2
    ...       NRCELL-3_csirsTrackingPeriod-80ms, firstRE-1, rbAllocation-52RB, startRB-0,
    ...                csiReportPeriod_slots320, csirsNumberSet1_4, maxCsirsNumber_4,beams_4
    ...       NRCELL-1 configured NRCELL-2, NRCELL-3 as scells
    ...    2. Test Case Steps:
    ...           a. UE1_percc4ALLCC4 attach to PCI 50, trigger A1 MR to add PCI 51, 52 as scells.
    ...              UE2_percc2ALLCC6 attach to PCI 50, trigger A1 MR to add PCI 51, 52 as scells.
    ...              UE3_percc1ALLCC6 attach to PCI 50, trigger A1 MR to add PCI 51, 52 as scells.
    ...           b. UE2 RRE from PCI 50 to 51. Then RRE from PCI 51 to 52.
    ...           c. UE1_percc4ALLCC4 attach to PCI 52, trigger A1 MR to add PCI 50 as scells.
    ...           d. NSA UE91 attach to PCI 52, trigger A1 MR to add PCI 50 as scells.
    ...              Then trigger A2 scell release.
    ...     3. Expected result:
    ...           a. UE1 attach to PCELL _RS4 then after scell addition to 3cc, PCELL_RS2, Scell1_RS1, Scell2_RS1.
    ...              PCELL_CSIRS period is slots160. SCELL1_CSIRS period is slots80. SCELL2_CSIRS period is slots160
    ...              UE2 3cc PSCELL_RS2, Scell1_RS2, Scell2_RS2
    ...              PCELL_CSIRS period is slots160. SCELL1_CSIRS period is slots80. SCELL2_CSIRS period is slots160
    ...              UE3 3cc PSCELL_RS1, Scell1_RS1, Scell2_RS1
    ...              PCELL_CSIRS period is slots160. SCELL1_CSIRS period is slots80. SCELL2_CSIRS period is slots160
    ...           b. UE2 RRE to PCI 51 PCELL_CSIRS period is slots80. then RRE to PCI 52, PCELL_CSIRS period is slots160.
    ...           c. UE1 attach to PCELL _RS4 then after scell addition to 2cc, PCELL_RS2, Scell1_RS2
    ...              PCELL_CSIRS period is slots40. after scell addition, SCELL1_CSIRS period is slots160. PCELL_CSIRS period is slots160
    ...           d. NSA UE91 attach to PCELL _RS4 then after scell addition to 2cc, PCELL_RS2, Scell1_RS2
    ...              after A2 scell release, upgrade from RS2 to RS4.
    ...              PCELL_CSIRS period is slots40. after scell addition, SCELL1_CSIRS period is slots160. PCELL_CSIRS period is slots160
    ...              after A2 scell release, PCELL_CSIRS period is slots40.
    [Tags]    A001    QC_362026    CA_LABEL-TTT(80M_TDD_n78+60M_TDD_n78+80M_TDD_n78)
    Clear Counter Files    ${True}
    Preconditions for A01
    Steps to Test UE1_percc4Allcc4_RS4DowntoRS2_csirsreportperiod160
    Steps to Test UE2_RREtoNRCELL-2_RREtoNRCELL-3
    Steps to Test UE1_percc4Allcc4_RS4DowntoRS2_csirsreportperiodfrom40to160_NRCELL-3
    NSA CA UE Attach To Cell and Initial covBaseA1 scelladd and a2scellrelease
    Check Wireshark Log    ${CURDIR}${/}A2A_A_001${/}a2a.ini    wait_string=UEContextRelease::48
    Check Counters    ${PM_Counters_Check_A001}
    [Teardown]    Test teardown for A01

*** Keywords ***
Steps to Test UE1_percc4Allcc4_RS4DowntoRS2_csirsreportperiod160
    UE attach and Scell added coverbase    expect_regexp=${expect_regexp_NRCELL1_3cc}    CC_num=3
    UE attach and Scell added coverbase    ue_id=2    UE_Capabilities=${SA_Capa_perCC2}    expect_regexp=${expect_regexp_NRCELL1_3cc}
    ...    CC_num=3
    UE attach and Scell added coverbase    ue_id=3    UE_Capabilities=${SA_Capa_perCC1}    expect_regexp=${expect_regexp_NRCELL1_3cc}
    ...    CC_num=3

Steps to Test UE1_percc4Allcc4_RS4DowntoRS2_csirsreportperiodfrom40to160_NRCELL-3
    Release UEs    ue_type=all
    UE attach and Scell added coverbase    cell_id=3    cellfreq=649920    expect_regexp=${expect_regexp_NRCELL3_2cc}    CC_num=2
    Release UEs    ue_type=all

Steps to Test UE2_RREtoNRCELL-2_RREtoNRCELL-3
    Trigger RRC Reestablish
    Trigger RRC Reestablish    cell_id=3

Preconditions for A01
    OnlineParamChange    ${PARAMS_FOR_CA}

Trigger RRC Reestablish
    [Arguments]    ${cell_id}=2    ${Tput_dl}=270    ${Tput_ul}=13    ${sleep_time}=15s
    Execute Egate Command    ue_rrc_reestablish id=2 gnb=2 cell=${cell_id} cause=reconfigurationFailure
    ...    pass_regexp=UE2: NR RRC Reestablishment sucessfully completed
    Check Specific UE State    ue_id=2    state=Active
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get Throuput On Specific Scell     ue_id=2    scell_id=0    type=pdsch    rate_type=ave
    ${ul_throughput}    Ap Get Throuput On Specific Scell     ue_id=2    scell_id=0    type=pusch    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=2 scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}


Sa CA UE Register
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    sleep_time=${wait_timer}    pass_regexp=NG RM Registered


Check Throughput with Type
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_expect}=80    ${CC_num}=2    ${type}=pdsch
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=${type}    pass_regexp=Average
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
    #Should Be True    ${scell_tput}/1000 > 0

SA CA UE Setup PDU Session Successfully
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=${cell_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=PDU SESSION ID-1 setup/reestablishment complete

Traffic Send
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=5 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=15    UE ${ue_id}: UDP UL

Traffic stop
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_stop ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3    Traffic was stopped
    Execute Egate Command    data_trf_stop ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4    Traffic was stopped
    Execute Egate Command    data_trf_stop ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=5    Traffic was stopped


UE attach and Scell added coverbase
    [Arguments]    ${ue_id}=1    ${CC_num}=1    ${expect_regexp}=${EMPTY}    ${fail_reg_ca}=${EMPTY}    ${UE_Capabilities}=${SA_Capa_perCC4allCC4}
    ...    ${cell_id}=1    ${cellfreq}=636576
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${UE_Capabilities}
    SA CA UE Setup PDU Session Successfully    ue_id=${ue_id}    cell_id=${cell_id}
    UE Send A1 Trigger Scell Addition    ${ue_id}    ${cellfreq}    ${expect_regexp}    ${fail_reg_ca}
    Traffic Send    ue_id=${ue_id}
    sleep    15s    sleep for Tput stable
    wait until keyword succeeds    60s    5s    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=675    CC_num=${CC_num}    type=pdsch
    Traffic stop    ue_id=${ue_id}

UE Send A1 Trigger Scell Addition
    [Arguments]    ${ue_id}    ${cellfreq}    ${pass_reg_ca}=${EMPTY}    ${fail_reg_ca}=${EMPTY}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${pass_reg_ca}
    ...    fail_regexp=${fail_reg_ca}


NSA CA UE Attach To Cell and Initial covBaseA1 scelladd and a2scellrelease
    [Arguments]    ${ue_id}=91    ${cell_id}=3    ${UE_Capabilities}=${SA_Capa_perCC4allCC4}
    Update UE capa    ${ue_id}    ${UE_Capabilities}
    NSA UE attach    ${ue_id}    ${cell_id}
    Send And Verify Throuput
    Add gNB Cell1 As Scell By A1
    Release gNB Cell1 Scell By A2
    Verify Throuput And Scell Release

Add gNB Cell1 As Scell By A1
    [Arguments]    ${ue_id}=91    ${carrierfreq}=649920
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A1 srsrp_nr=120 ssinr_nr=59 srsrq_nr=120
    ...    pass_regexp=SCellIndex 9 activated successfully
    Verify Throuput on Pscell and Scell

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=100 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=100 trf_id=9    UE ${ue_id}: UDP DL
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 0
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 0
    Should Be True    ${scell8_tput}+ ${scell9_tput}> 585
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9

Release gNB Cell1 Scell By A2
    [Arguments]    ${ue_id}=91    ${carrierfreq}=636576
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=9 scell_rsrp=7 scell_rsrq=7
    ...    pass_regexp=Successfully reconfigured dual connectivity
    Verify Throuput And Scell Release    sleep_time=10s

Verify Throuput And Scell Release
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 585
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=9 type=pdsch    fail_regexp=CellIndex-9
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9


NSA UE attach
    [Arguments]    ${ue_id}=91    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    ${cmd}    catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    Execute Egate Command    ${cmd}    successful RA

Test teardown for A01
    Common Test Teardown And Stop Capture Logs

Send And Verify Throuput
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/3cells_ecpri_8pipes

Set UE Capability
    [Arguments]    ${ue_id}=1    ${UE_Capabilities}=${SA_Capa_perCC4allCC4}    ${wait_timer}=0.5
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}    sleep_time=${wait_timer}


Update UE capa
    [Arguments]    ${ue_id}=91    ${UE_Capabilities}=${SA_Capa_perCC4allCC4}    ${Capa_LTE}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    Execute Egate Command    ${cmd}


OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}    timeout=600




