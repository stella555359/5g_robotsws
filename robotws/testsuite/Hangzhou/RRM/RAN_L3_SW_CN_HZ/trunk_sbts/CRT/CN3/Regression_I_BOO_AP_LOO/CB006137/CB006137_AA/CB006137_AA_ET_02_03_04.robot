*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-DevHZ5_SG1    owner-feng.2.chen    release-5G22R4    CB006137
Resource    ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}  ${True}
@{PARAMS_IN_SCF}    @{5GC001765_CB007877}    @{CB008015}    @{5GC001390}
...    @{CB006138}    @{long_pucch_parameter}    @{consistency_param}    @{CA_Basic}     @{5QI}
...    NRCELL:actCDrx=false
...    NRBTS-1:actExtN77Support=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRBTS:cipherPrefL:nea3_128=0
...    MRBTS-1/NRBTS-1/NRCELL-2:ulPowerControlCommon:alphaSrs=alpha09
...    MRBTS-1/NRBTS-1/NRCELL-2:ulPowerControlCommon:p0NominalSrs=-202
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL:timingAdvanceOffset=n25600
${cell2_PHY_TDD}    50
${PM_debug_print}    0x340002
${PM_debug_specific}    0x340006
@{PARAMS_IN_SWCONFIG}
...    ${PM_debug_print}=1
...    ${PM_debug_specific}=55139

@{5GC001765_CB007877}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actHoOptimizationCa=true
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=65
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
@{CB008015}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=false
...    NRBTS:sCellMeasCycle=sf320
...    NRCELL:actK1Opt=intra-gNB
...    delete:NRCELL-1/NRREL-10
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:ssbFrequency=127450
...    NRCELL-1/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-2:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-2:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=77
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:ssbFrequency=632736

@{add_NRREL_but_no_scellAdditionMethod}
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl

@{add_NRREL}
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind

@{add_scellAdditionMethod}
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind

@{delete_scellAdditionMethod}
...    delete:NRCELL-1/NRREL-1:sCellAdditionMethod

@{5GC001390}    NRBTS/NRDU-1:actInterNumerologyCa=true

@{CA_Basic}
...    NRBTS-1:cipherPrefL:nea0=9
...    NRCELL:primaryPathMaxQueueingDelay=10
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
...    NRCELL:actK1Opt=intra-gNB
...    NRBTS-1:sCellActivationMethod=blind
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{CB006138}
...    NRBTS/NRDU-1:flexibleCAMode=MixedCAMode     #MixedCAMode ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=120
...    NRCELL-2:a2MeasPCellSwitchEnabled=none
...    NRCELL-1:a2MeasPCellSwitchEnabled=none
...    NRCELL-3:a2MeasPCellSwitchEnabled=none
...    NRCELL-4:a2MeasPCellSwitchEnabled=none

@{long_pucch_parameter}
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL:pucchModeSelect=longPucch
@{consistency_param}


...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:filterCoeffSsbRsrq=fc4
${CA_support_list}    ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Sa
${CA_support_list1}    ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Sa_WithUl
@{relation error}

...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40


@{enable_UL}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list1}
...    NRBTS/NRDU-1:dlToUlContributionRatio=2
...    @{relation error}

@{enable_UL_02}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list1}
...    NRBTS/NRDU-1:dlToUlContributionRatio=2
...    NRREL-1:sCellOperationalMode=dlAndUl
...    @{relation error}

@{disable_UL}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRBTS/NRDU-1:dlToUlContributionRatio=101

@{disable_UL_02}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRBTS/NRDU-1:dlToUlContributionRatio=101
...    NRREL-1:sCellOperationalMode=dlOnly
@{5QI}
...    NRDRB_5QI-1:fiveqiValueList=5
...    NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-2:fiveqiValueList=6
...    NRDRB_5QI-2:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-3:fiveqiValueList=1
...    NRDRB_5QI-3:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...    NRDRB_5QI-5:fiveqiValueList=9
...    NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-6:fiveqiValueList=7
...    NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-7:fiveqiValueList=3
...    NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...    NRDRB_5QI-8:fiveqiValueList=4
...    NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...    MRBTS-1/NRBTS-1/NRDRB_PDCP-1:pdcpBufDiscardEnabled=false
...    MRBTS-1/NRBTS-1/NRDRB-3:queuingDelayDiscarding=Disabled

${SA_Capa_perUE_Full_old}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA36266B04610D04083A412030B64C55110E7C471E238F40CFB0
...    27C639F30C7942C0E070F05C007FC007001FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31
...    E50B0381C3C27FFC00001FFF00000130000E007BC3C28000E230000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A0
...    0038820000042C0AC3C4C000E230000010B02B17118003882001C4100000A160561E26000713000003058158B898001C41000E140000040B
...    02B1713000388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B898001C41000E230000020B0
...    2B170A000388C001C46000004160562E2600071180038500000102C0AC3C46000E230000030B0200E0234028809B01043D0AEC1F0A244D8E
...    7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E04
...    4810206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C631800C07A09801E00140E0A00E06
...    01280380030120020301F0480100000000800001004000000020000040100000400800003004000020020000140100080200802000018010
...    0000E00800400000010000100080000900400001802000028010000160080040902401000018063266B2A6B052B032B066B056B296B266B0
...    16B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA4
...    80800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480629355526AAA55174AA2A82C55058AA0D154A62A9
...    3455018AA051549AAA83C5090178095028140A05028140A05028140A05028140A05028140018202018030080100210100200804030061008
...    0100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E0002040
...    6080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C830E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E
...    7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0003C000E0541B107582308682041E207032B64C55890E7D813E2
...    38F1891C790E7D473E618F28581C0E1E13FB000000FEC00000078001C0AA36266B04610D04083A40E0616C98AA221CF88E3C471E819F604F
...    8C73E618F28581C0E1E0B800FF800E003FE00078001C0A836236B04610D04083C40E0656C98AB121CF88E3D813E31238F21CFA8E7CC31E50
...    B0381C3C27FFC00001FFF000000F0003801EF0F0A000388C0000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E
...    208000010B02B0F13000388C0000042C0AC5C46000E208007104000028581587898001C4C00000C160562E2600071040038500000102C0AC
...    5C4C000E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26000710400388C0000082C0AC5
...    C28000E23000711800001058158B898001C46000E140000040B02B0F11800388C00000C2C0803808D00A2026C0410B42EC1F0A244D8E7C38
...    51226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E044810
...    206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A09801E00140E0A00E0601280380
...    030120020301F04801000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000E008
...    00400000010000100080000900400001802000028010000160080040902401000018063266B2A6B052B032B066B056B296B266B016B036B0
...    12B022B07681A0800004B29202000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044
...    B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480629345526AAA55174AA2A82C55058AA0D154A62A93455018A
...    A051549AAA83C5090178095028140A05028140A05028140A05028140A05028140018202018030080100210100200804030061008010020201
...    8030080600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E141
...    6181A2022242628303236383A3E424A4C4E5052545A5E828305A


${nr_capability_with_no_UL}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA36266B04610D04083A412030B64C55110E7C471E238F40CFB0
...    27C639F30C7942C0E070F05C007FC007001FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31
...    E50B0381C3C27FFC00001FFF00000130000E007BC38280388C0000042C040A838280388C0000042C0AC3C46000E208000030B02B0F0A0003
...    8820000042C0AC3C4C000E230000010B02B17118003882001C4100000A160561E26000713000003058158B898001C41000E140000040B02B
...    1713000388C001C46000004160562C1401C41000E230000020B02B170A0003882001C41000004160562E26000710400388C0000082C0AC58
...    280388C001C46000004160562E26000711800305000040B02B0F11800388C00000C2C0803808D00A2026C0410F42BB07C28913639F0E1448
...    9B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B
...    1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C600301E8260078005038280381804A00E0
...    00C0480080C07C120040000000200000401000000008000010040000100200000C0100000800800005004002008020080000600400003802
...    0010000000400004002000024010000060080000A004000058020010240900400006018C99ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC
...    04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB2920200011
...    2CA48080004CB29202000152CA48080005CB29282000192CA480800018B292018A4D5549AAA9545D2A8AA0B154162A83455298AA4D154062
...    A8145526AAA0F142405E02540A05028140A05028140A05028140A05028140A05000608080600C02004008404008020100C01840200400808
...    0600C02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D50F800081018203038
...    5058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${GNB_SCELL_1_ADMI_REQ_SA}    M55138C01501
${GNB_SCELL_1_ADMI_SUCC_SA}    M55138C01502
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002
${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003
${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
${SCELL_CHANGE_ATT_SA}    M55118C06506
${SCELL_CHANGE_SUCC_SA}    M55118C06507

@{PM_Counters_Check_case2}
...    NRCELL-1:RSACU:${GNB_SCELL_1_ADMI_REQ_SA}=3
...    NRCELL-1:RSACU:${GNB_SCELL_1_ADMI_SUCC_SA}=3
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=3
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=3
...    NRCELL-1:NCAC:${SCELL_CHANGE_SUCC_SA}=0
...    NRCELL-1:NCAC:${SCELL_CHANGE_ATT_SA}=0
...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}>=1
...    NRCELL-2:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=3
...    NRCELL-2:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=3
...    NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_DL_SA}>=1

@{enable_UL_delete_NRREL}
...    delete:NRCELL-1/NRREL-1
...    @{enable_UL}

*** Test Cases ***
CB006137-AA_ET_03_01_NRREL of Scell impact the CA configure
    [Documentation]
    ...    step1:no NRREL,Attach UE-1 to FDD Cell,No DL and UL Scell for UE-1;
    ...    step2:Configure NRREL of TDD Scell for FDD Cell, but without scellAdditionMethod,Attach UE-2,no DL and UL Scell
    ...    step3:Configure scellAdditionMethod to blind for FDD Cell,Attach UE-3,UE-3 F+T DL and UL CA blind configured;
    ...    step4:delete scellAdditionMethod,Attach UE-4,No DL and UL Scell
    ...    step5:Configure scellAdditionMethod to blind for FDD Cell,Attach UE-5,UE-5 F+T DL and UL CA blind configured;
    [Tags]    TC03
    Enable feature flag and delete NRREL to check no CA added    ue_id=1
    Delta commission and wait cells onair_wa_for_restart_params    ${add_NRREL_but_no_scellAdditionMethod}
    Ue Register And Pdu Session Setup At FDD Cell-1 and check no CA added    ue_id=2
    Delta commission parameters    ${add_scellAdditionMethod}
    Ue Register And Pdu Session Setup At FDD Cell-1 and check UL CA added    ue_id=3
    Online change parameters and wait cells onair    ${delete_scellAdditionMethod}
    Ue Register And Pdu Session Setup At FDD Cell-1 and check no CA added    ue_id=4
    Delta commission parameters    ${add_scellAdditionMethod}
    Ue Register And Pdu Session Setup At FDD Cell-1 and check UL CA added    ue_id=5
    Check Logs With Au2anlysis    ${CURDIR}${/}A2A_case3${/}a2a_01.ini    p
    [teardown]    Add NRREL and case teardown

CB006137-AA_ET_02_01_Feature activation and deactivation via change ca_Fdd_Fr1Tdd_Sa_WithUl
    [Documentation]    flexibleCAMode= ConfigurationIndependent and Beamforming is enabled
    ...    step1:Attach UE-1 to FDD Cell without ca_Fdd_Fr1Tdd_Sa_WithUl,UE-1 F+T DL CA blind configured only;
    ...    step2:Attach UE-2 to FDD Cell with ca_Fdd_Fr1Tdd_Sa_WithUl, UE-2 F+T DL and UL CA blind configured;
    ...    step3:Attach UE-3 to FDD Cell without ca_Fdd_Fr1Tdd_Sa_WithUl,UE-1 F+T DL CA blind configured only;
    [Tags]    TC02
    Delta commission parameters    ${disable_UL_02}
    Clear Counter Files
    Ue Register And Pdu Session Setup At FDD Cell-1 and check no UL CA added    ue_id=1
    Delta commission parameters    ${enable_UL_02}
    Ue Register And Pdu Session Setup At FDD Cell-1 and check UL CA added    ue_id=2
    Add qosflows    ue_id=2
    Delta commission parameters    ${disable_UL_02}
    Ue Register And Pdu Session Setup At FDD Cell-1 and check no UL CA added    ue_id=3
    Check Logs With Au2anlysis    ${CURDIR}${/}A2A_case2${/}a2a_01.ini    p
    Check Counters    ${PM_Counters_Check_case2}
    [teardown]    Test Teardown And Stop Capture Logs and detach UE123

CB006137-AA_ET_04_02_Only DL CA configure when UE does not support UL CA bandcombination with blind CA
    [Documentation]     attach UE capable of Fdd_Fr1Tdd DL CA but no UL CA; F+T DL CA blind configured only;
    [Tags]    TC04
    Delta commission parameters    ${enable_UL}
    Set UE not support UL CA bandcombination    ue_id=9
    Ue Register And Pdu Session Setup At FDD Cell-1 and check no UL CA added    ue_id=9
    Check Logs With Au2anlysis    ${CURDIR}${/}A2A_case4${/}a2a_01.ini    p
    [teardown]    Test Teardown And Stop Capture Logs and detach UE9

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/4cells_2F2T

Modify Cfg
    FOR    ${gateway_id}    IN RANGE    1    11
        Update Cfg    set_pdu_gateway id=${gateway_id} ue_nat_ip=72.23.${gateway_id}.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    END
    ${V2}    catenate
    ...    ue_param id=1-10 ue_nr_capabilities=${SA_Capa_perUE_Full}
    ${V3}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400
    ...    enb=2 cell=1 mode=nr
    Update Cfg    ${V2}
    Update Cfg    ${V3}
    Update Cfg    set_qosflow id=1 5qi=1 priority=1
    Update Cfg    set_qosflow id=2 5qi=2 priority=2
    Update Cfg    set_qosflow id=3 5qi=3 priority=3
    Update Cfg    set_qosflow id=4 5qi=4 priority=4
    Update Cfg    set_qosflow id=5 5qi=5 priority=5
    Update Cfg    set_qosflow id=6 5qi=6 priority=6
    Update Cfg    set_qosflow id=7 5qi=7 default=on priority=7
    Update Cfg    set_qosflow id=8 5qi=8 priority=8
    Update Cfg    set_qosflow id=9 5qi=9 priority=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1
    Update Cfg    set_nwslice id=2 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A6 default=off ue=all amf=1

Delta commission and wait cells onair_wa_for_restart_params
    [Arguments]    ${delta_para}
    delta commission parameters    ${delta_para}
    cells should be onair

Ue Register And Pdu Session Setup At FDD Cell-1 and check UL CA added
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Start rrc log    log_ue_${ue_id}
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    SCellIndex 1 activated successfully
    Should Contain    ${ret1}    physCellId ${cell2_PHY_TDD}
    Should Contain    ${ret1}    p-Max
    Get rrc log

Ue Register And Pdu Session Setup At FDD Cell-1 and check no UL CA added
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Start rrc log    log_ue_${ue_id}
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    SCellIndex 1 activated successfully
    Should Contain    ${ret1}    physCellId ${cell2_PHY_TDD}
    Should not Contain    ${ret1}    p-Max
    Get rrc log


Ue Register And Pdu Session Setup At FDD Cell-1 and check no CA added
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Start rrc log    log_ue_${ue_id}
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    fail_regexp=sCellToAddModList
    Should not Contain    ${ret1}    SCellIndex 1 activated successfully
    Should not Contain    ${ret1}    sCellToAddModList
    Should Contain    ${ret1}    QoS Routing Table
    Get rrc log

Add qosflows
   [Arguments]    ${ue_id}=1
   Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=5 by=amf    pass_regexp=Added QosFlow with QFI:
   Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=6 by=amf    pass_regexp=Added QosFlow with QFI:

Set UE not support UL CA bandcombination
   [Arguments]    ${ue_id}=1
   Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${nr_capability_with_no_UL}

Online change parameters and wait cells onair
    [Arguments]    ${parameter}
    delta commission parameters    ${parameter}
    sleep    10s    #delete NRREL will cause cell restart
    Cells Should Be Onair    check_sib=${False}

Add NRREL and case teardown
    delta commission parameters    ${add_NRREL}
    Execute Egate Command    ue_deregister id=1,2,3,4,5 ue_deregister_type=switch_off    detached
    Common Test Teardown And Stop Capture Logs

Test Teardown And Stop Capture Logs and detach UE123
    Execute Egate Command    ue_deregister id=1,2,3 ue_deregister_type=switch_off    detached
    Common Test Teardown And Stop Capture Logs

Test Teardown And Stop Capture Logs and detach UE9
    Execute Egate Command    ue_deregister id=9 ue_deregister_type=switch_off    detached
    Common Test Teardown And Stop Capture Logs

Enable feature flag and delete NRREL to check no CA added
    [Arguments]    ${ue_id}=1
    Online change parameters and wait cells onair    ${enable_UL_delete_NRREL}
    Ue Register And Pdu Session Setup At FDD Cell-1 and check no CA added    ue_id=${ue_id}
