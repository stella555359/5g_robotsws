*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BLLL_AP_LOO
...    team-DevHZ5_SG4    owner-eric.jiang    release-5G22R3    CB008001
Resource    ..${/}..${/}..${/}..${/}resources${/}DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CA_A1ScellAddition}
...    @{MixedMode_CA}
...    @{2T4F_N66B}
...    @{CASupportList}
@{CA_A1ScellAddition}
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actGrflShdn=true
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actFdmScheduling=true
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
@{MixedMode_CA}
...    NRCELL-11/NRREL-10:lcrId=2
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-2:lcrId=13
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-12/NRREL-10:lcrId=2
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-2:lcrId=11
...    NRCELL-12/NRREL-3:lcrId=13
...    NRCELL-13/NRREL-10:lcrId=2
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-2:lcrId=11
...    NRCELL-13/NRREL-3:lcrId=12
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-2/NRREL-1:lcrId=11
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:nrDcAllowed=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:nrDcAllowed=false
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:nrDcAllowed=false
...    NRCELL-12/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:nrDcAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:nrDcAllowed=false
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:nrDcAllowed=false
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-10:gNbId=1
...    NRCELL-13/NRREL-10:gNbIdLength=22
...    NRCELL-13/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-10:removeNotAllowed=false
...    NRCELL-13/NRREL-10:nrDcAllowed=false
...    NRCELL-13/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:nrDcAllowed=false
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-2:nrDcAllowed=false
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-3:gNbId=1
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-3:removeNotAllowed=false
...    NRCELL-13/NRREL-3:nrDcAllowed=false
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:nrDcAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:ssbFrequency=126750
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:ssbFrequency=424090
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=518910
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
@{2T4F_N66B}
...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=431960
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=351960
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-11:gscnOrSsPbchArfcn=5398
${casl_value}
...    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa
@{CASupportList}
...    NRDU-1:carrierAggregationSupportList=${casl_value}
${active_all_syslogs}    0x10041
${rad_flag_in_gnb}    0x20109
${BSTAT_mcounter_debug}    0x340003
${enable_measurement_new_flag}    0x34000E
${disable_CNI48216}    0x59004D
@{PARAMS_IN_SWCONFIG}
...    ${active_all_syslogs}=5
...    ${rad_flag_in_gnb}=1
...    ${BSTAT_mcounter_debug}=1
...    ${enable_measurement_new_flag}=55120
...    ${disable_CNI48216}=1
${deploy_L2RT_in_container}    0x420028
${ps_rel}    0x200f0
@{PARAMS_IN_SWCONFIG_AP}
...    ${deploy_L2RT_in_container}=0
...    ${ps_rel}=0
@{allowUnsuppBcOrBcs_0}
...    NRCELL:allowUnsuppBcOrBcs=complete BCS check
@{enable_bcs}
...    NRBTS-1:actBcsCheck=enabled_FR1
@{disable_bcs}
...    NRBTS-1:actBcsCheck=disabled
@{scell_pci_ue81_82}
...    62                                  # cell13 pci is 62
@{scell_pci_ue83}
...    61                                  # cell12 pci is 61
...    62                                  # cell13 pci is 62
${Capa_UE81_UE82}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C830E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E7C471E819F604F8C48E3C873
...    EA39F30C7942C0E070F05C00FFC0070005F0003C000E0541B107582308682041E207032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000
...    00078001C0AA3626EB04610D04083A40E0616C98AA221CF88E3C471E819F604F8C73E618F28581C0E1E0B801FF800E007FE00078001C0A836236B04610D04083C40E0656
...    C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000000F00038002F07104100009D80BE8000000000E0234028809B01042D00D00C089B1CF86
...    050119E8260078005038280381804A00E000C0480080C07C12104000000820010000010400200802008000010040000100200000C0100000800800005004002008020080
...    0006004000038020010000000400004002000024010000060080000A004000058020010240900400006018C1DBCA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1
...    DA0682000012CB2A080000CB2CA82000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA4808000
...    5CB29282000192CA480800018B292018A0F574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142405E02540A05028140A05028140A05028140A0502
...    8140A0500010008010020010040046A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40
${Capa_UE83}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C830E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E7C471E819F604F8C48E3C873
...    EA39F30C7942C0E070F05C00FFC0070005F0003C000E0541B107582308682041E207032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000
...    00078001C0AA3626EB04610D04083A40E0616C98AA221CF88E3C471E819F604F8C73E618F28581C0E1E0B801FF800E007FE00078001C0A836236B04610D04083C40E0656
...    C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000000F00038002F0F10410388C000008EC05F80000000007011A014404D808216807806144
...    89B1CF8602808CF413003C00281C1401C0C02500700060240040603E0908200000041000800000820000040100000200800002004000018020000100100000A008004010
...    040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C03183B7953795158195833582B594B5933580B581B58095
...    811583B40D04000025965410000196595040000A594901000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949
...    010000B965250400032594901000031652403141EAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28480BC04A8140A05028140A05028140A05028
...    140A05028140A000400100200400200800840401001010020046A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

*** Test Cases ***
CB008001-ET-A004_Verify_BC_Accepted_when_UE_report_known_Contiguous_2CC_with_unknown_BCS_after_actBcsCheck_onlineChanged_SA_based
    [Documentation]
    ...    1. The purpose of this test case is to 2CC CA successful when actBcsCheck online change
    ...       and UE report Contiguous intraBand with unknown BCs
    ...       UE 81: support n66B(known), supportedBandwidthCombinationSet to BCS1(Unknown)
    ...       UE 82: support n66B(known), supportedBandwidthCombinationSet to BCS0(known), 20M+20M is not support BW Combination
    ...       UE 83: support n71A+n66B(known), supportedBandwidthCombinationSet to BCS0(known), 20M+20M is not support BW Combination
    ...    2. Test Configuration:
    ...       NRCELL-11(FDD, n66A, 20M)
    ...       NRCELL-11/NRREL-10(cell2: TDD, n78A, 50M)
    ...       NRCELL-11/NRREL-1(cell1: TDD, n41A, 60M)
    ...       NRCELL-11/NRREL-2(cell13: FDD, n66A, 20M)
    ...       NRCELL-11/NRREL-3(cell12: FDD, n71A, 15M)
    ...    3. Test Case Steps:
    ...       step1. set actBcsCheck=enabled_FR1 and allowUnsuppBcOrBcs=complete BCS check
    ...              Make SA UE-81 attach to cell 11, start data transfer, check A1 meas config in RRC Reconfig
    ...              Expected Results:no A1 meas config in RRC Reconfig since unknown BCS
    ...       step2. Release SA UE-81
    ...              Expected Results:Call release successfully
    ...       step3. set actBcsCheck=disabled
    ...              Make SA UE-81 attach to cell 11, start data transfer, check A1 meas config in RRC Reconfig
    ...              Expected Results:A1 meas config in RRC Reconfig
    ...       step4. A1 measurement report based SCell addition is triggered
    ...              Expected Results:Cell13 is added as scell. Cell11+cell13 n66B 2CC CA successful
    ...       step5. Release SA UE-81
    ...              Expected Results:Call release successfully
    ...       step6. set actBcsCheck=enabled_FR1
    ...              Make SA UE-82 attach to cell 11, start data transfer, check A1 meas config in RRC Reconfig
    ...              Expected Results:no A1 meas config in RRC Reconfig since unsupported BW Combination
    ...       step7. Release SA UE-82
    ...              Expected Results:Call release successfully
    ...       step8. set actBcsCheck=disabled
    ...              Make SA UE-82 attach to cell 11, start data transfer, check A1 meas config in RRC Reconfig
    ...              Expected Results:A1 meas config in RRC Reconfig
    ...       step9. A1 measurement report based SCell addition is triggered
    ...              Expected Results:Cell13 is added as scell. Cell11+cell13 n66B 2CC CA successful
    ...       step10. Release SA UE-82
    ...               Expected Results:Call release successfully
    ...       step11. set actBcsCheck=enabled_FR1
    ...               Make SA UE-83 attach to cell 11, start data transfer, check A1 meas config in RRC Reconfig
    ...               Expected Results:no A1 meas config in RRC Reconfig since unsupported BW Combination
    ...       step12. Release SA UE-83
    ...               Expected Results:Call release successfully
    ...       step13. set actBcsCheck=disabled
    ...               Make SA UE-83 attach to cell 11, start data transfer, check A1 meas config in RRC Reconfig
    ...               Expected Results:A1 meas config in RRC Reconfig
    ...       step14. A1 measurement report based SCell addition is triggered
    ...               Expected Results:Cell12 and Cell13 is added as scell. Cell11+cell12+cell13 n66+n66+n71 3CC CA successful
    ...       step15. Release SA UE-83
    ...               Expected Results:Call release successfully
    [Tags]    QC_134687
    Delta Commission Parameters    ${allowUnsuppBcOrBcs_0}
    Verify BCS Reported UE Enable BCS    ue_id=81
    Verify BCS Reported UE Disable BCS    ue_id=81    scell_pci=${scell_pci_ue81_82}
    Verify BCS Reported UE Enable BCS    ue_id=82
    Verify BCS Reported UE Disable BCS    ue_id=82    scell_pci=${scell_pci_ue81_82}
    Verify BCS Reported UE Enable BCS    ue_id=82
    Verify BCS Reported UE Disable BCS    ue_id=83    scell_pci=${scell_pci_ue83}
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F    match_string=${EMPTY}    cfg=auto    ue_count=5
    #Debug Enter Into Egate

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3 qos_rules=1,2,3 default=on ue=all amf=1
    Update Cfg Param    set_cell id=11 gnb=2 nr_arfcn=351960:431960
    ${ue81_cmd}=    Catenate    set_ue simulated id=81 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645481
    ...    enb=2 cell=11 mode=nr
    Update Cfg    ${ue81_cmd}
    Update Cfg    ue_param id=81 ue_nr_capabilities=${Capa_UE81_UE82}
    ${ue82_cmd}=    Catenate    set_ue simulated id=82 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645482
    ...    enb=2 cell=11 mode=nr
    Update Cfg    ${ue82_cmd}
    Update Cfg    ue_param id=82 ue_nr_capabilities=${Capa_UE81_UE82}
    ${ue83_cmd}=    Catenate    set_ue simulated id=83 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645483
    ...    enb=2 cell=11 mode=nr
    Update Cfg    ${ue83_cmd}
    Update Cfg    ue_param id=83 ue_nr_capabilities=${Capa_UE83}

Check No A1 Meas Config
    [Arguments]    ${ue_id}
    ${checkA1measconfig}=    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    timeout=10
    Should Not Contain Any    ${checkA1measconfig}    EventA1: Threshold: RSRP 31    EventA1: Threshold: RSRP 111

Check A1 Meas Config And Scell Addtion
    [Arguments]    ${ue_id}    ${scell_pci}
    ${checkA1measconfig}=    Execute Egate Command      ue_meas_cfg_disp id=${ue_id}    NR REPORT CONFIGURATIONS
    Should Contain Any    ${checkA1measconfig}    EventA1: Threshold: RSRP 31    EventA1: Threshold: RSRP 111
    ${addScell}=    Execute Egate Command      ue_measurement_send_nr id=${ue_id} meas_id=1 event=A1 srsrp_nr=112 srsrq_nr=80
    ...    SCellIndex 1 activated successfully at airphone
    FOR    ${pci}    IN    @{scell_pci}
        Should Contain    ${addScell}    sCellToAddModList    physCellId ${pci}
    END

Verify BCS Reported UE Enable BCS
    [Arguments]    ${ue_id}
    Delta Commission Parameters    ${enable_bcs}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    QoS Routing Table    timeout=20s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=5 trf_id=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=5 trf_id=1
    Check No A1 Meas Config    ue_id=${ue_id}
    Release Ues    ue_id=${ue_id}

Verify BCS Reported UE Disable BCS
    [Arguments]    ${ue_id}    ${scell_pci}
    Delta Commission Parameters    ${disable_bcs}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    QoS Routing Table    timeout=20s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=5 trf_id=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=5 trf_id=1
    Check A1 Meas Config And Scell Addtion    ue_id=${ue_id}    scell_pci=${scell_pci}
    Release Ues    ue_id=${ue_id}
