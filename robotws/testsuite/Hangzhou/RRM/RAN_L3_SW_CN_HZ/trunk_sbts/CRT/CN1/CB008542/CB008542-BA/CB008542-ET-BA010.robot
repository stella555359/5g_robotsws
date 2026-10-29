*** Settings ***
Documentation    Suite documentation
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    BA010 Test Teardown
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_BOO_AP_LOO    team-CN1ET
...    owner-lingyan.zhou   release-5G22R3    CB008542
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${UTE_WIRESHARK_FLAG}    ${False}
${RECREATE_WIRESHARK_FLAG}    ${True}
${BTS_STARTUP_RETRY}    2
@{PARAMS_IN_SWCONFIG_AP}    ${EnableSrsBasedBeamForming}=1
${EnableSrsBasedBeamForming}    0x70690
@{PARAMS_IN_SCF}
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:actCDrx=true
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:nrCellType=4DL2UL
...    NRCELL-1:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=2 beams
...    NRCELL-2:actK1Opt=intra-gNB
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:nrCellType=4DL2UL
...    NRCELL-2:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-4:numberOfTransmittedSsBlocks=2 beams
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-10:lcrId=2
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-13/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=12
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=13
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=1
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-10:lcrId=1
...    NRCELL-2/NRREL-10:removeNotAllowed=false
...    NRCELL-2/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-2:lcrId=12
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:gNbId=1
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-3:lcrId=13
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-10:lcrId=1
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-10:lcrId=12
...    NRCELL-13/NRREL-10:gNbId=1
...    NRCELL-13/NRREL-10:gNbIdLength=22
...    NRCELL-13/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-10:removeNotAllowed=false
...    NRCELL-13/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12:actK1Opt=intra-gNB
...    NRCELL-13:actK1Opt=intra-gNB
...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-13:a2MeasSCellRelEnabled=rsrp
...    @{BOO_AP_LOO}

@{BOO_AP_LOO}
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8


${CA_support_list}  ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd

@{OnlineParam_BA009}  #Update maxNumofScellAlloc for NRCELL1 and NRCELL12
...    NRCELL-11:weightForSCellSelection=30
...    NRCELL-13:weightForSCellSelection=30
...    NRCELL-1:maxNumOfSCellAlloc=1
...    NRCELL-12:maxNumOfSCellAlloc=1

@{OnlineParam_BA010}
...    NRCELL-1:weightForSCellSelection=100    #chbw 60m
...    NRCELL-2:weightForSCellSelection=100    #chbw 50m
...    NRCELL-11:weightForSCellSelection=30    #chbw 20m
...    NRCELL-12:weightForSCellSelection=90    #chbw 15m
...    NRCELL-13:weightForSCellSelection=20    #chbw 20m
...    NRCELL-14:weightForSCellSelection=10    #chbw 15m
...    NRCELL-12:maxNumOfSCellAlloc=250

@{PM_Counters_Check_BA010}
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-2:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=0
...    NRCELL-2:RACDU:${SGNB_DU_NSA_ADMISSION_SUCC}=1
...    NRCELL-2:RACDU:${SGNB_DU_NSA_ADMISSION_REQ}=1
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_NSA}=2
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_NSA}=2
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISSION_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISSION_SUCC}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=0
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=3
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=3
...    NRCELL-12:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021    #The number of radio admission requests for 1 Scell
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028    #The number of successful radio admissions for 1 Scell additions.
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000    #RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000    #Successful RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000    #Number of CA UEs in the current cell configured as a PSCell, which have 1 configured SCell in DL
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008    #The number of radio admission requests for 1 Scell
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015    #The number of successful radio admissions for 1 Scell additions.
${A2MEAS_REL1DLSCELL_ATT_NSA}    M55118C06503    #Nbr of RRC Reconfiguration attempts releasing 1 SCell in DL triggered by A2 measurement for NSA
${A2MEAS_REL1DLSCELL_SUCC_NSA}    M55118C06504    #Nbr of successful RRC Reconfigurations releasing 1 SCell in DL triggered by A2 measurement for NSA
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006    #The number of radio admission requests for the Scell
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007    #The number of successful radio admissions for the Scell
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000    #Number of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
${SGNB_DU_NSA_ADMISSION_REQ}    M55115C00002    #The number of admission requests for NSA user
${SGNB_DU_NSA_ADMISSION_SUCC}    M55115C00003   #The number of successful radio admitted NSA users


${SA_Capa_perUE_Full_ue92}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387E0E026C830E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E7
...    C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0003C000E0541B107582308682041E207032B64C55890E7D813E238
...    F1891C790E7D473E618F28581C0E1E13FB000000FEC00000078001C0AA3626EB04610D04083A40E0616C98AA221CF88E3C471E819F604F8C7
...    3E618F28581C0E1E0B801FF800E007FE00078001C0A836236B04610D04083C40E0656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B038
...    1C3C27FFC00001FFF000000F0003801EF0F1340038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E20800
...    0010B02B0F13400388C0000042C0AC5C46000E208007104000028581587850001C4D00000C160562E2680071040038500000102C0AC5C4D00
...    0E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26800710400388C0000082C0AC5C28000E
...    23000711800001058158B89A001C46000E140000040B02B0F11800388C00000C2C0803808D00A2026C0410B42EC1F0A244D8E7C3851226C73
...    E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E044810206C73E04
...    4810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A09801E00140E0A00E06012803800301200203
...    01F04801000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000E00800400000010
...    0001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B016B036B012B022B07681
...    A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132C
...    A480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C5
...    090178095028140A05028140A05028140A05028140A050281400182020180300801002101002008040300610080100202018030080600C101
...    00C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E1416181A202224262
...    8303236383A3E424A4C4E5052545A5E828305A

${Capa_LTE_ue92}    SEPARATOR=
...    a11ff83bc4c0c03850001c46000000162205e260601c4d000e230000000b1102f130300e26800710400000058881789818070a00038820000
...    002c040bc4c0c03882001c46000002160205e360601c46000e208007104000010580817898180713400385000000c2c040804808d00a001c0
...    41809a1e80b907893a244d8e7c3893a244d8e7c3893a244d8e7c3893a244d8e7c3893a24498e7d1a7448912639f449d1224c73e01a0718c63
...    18c60c02080002010100200804030061000040202004008080600c3000080404030060100c018040300610000402020040100801004000000
...    00

${SA_Capa_perUE_Full_ue3}    SEPARATOR=
...    e9a09000575f5a13160003c1a00b0498b800ce1e82813641873e618f28581c130080c4700fb8d85181ac1184341020e90186d6c98ab1a1cf8
...    8e3d033ec09f1891c790e7d473e618f28581c0e1e0b801ff800e000be0005800702a0d883ac1184341020f1018656c98ab121cfb027c471e3
...    1238f21cfa8e7cc31e50b0381c3c27f6000001fd8000000b000e0551b137582308682041d2030c2d931544439f11c788e3d033ec09f18e7cc
...    31e50b0381c3c17003ff001c00ffc000b000e0541b11b582308682041e2030cad931562439f11c7b027c62471e439f51cf9863ca160703878
...    4fff800003ffe0000016001c00f78789a001c4100000216020541e14000711800000858158788c001c41000006160561e1400071040000085
...    8158789a001c46000002160562e2300071040038820000142c0ac3c28000e268000060b02b17134003882001c28000008160562e268007118
...    00388c0000082c0ac5c28000e20800711800001058158b850001c41000e208000020b02b17134003882001c46000004160562e14000711800
...    388c0000082c0ac5c4d000e2300070a000002058158788c001c46000006160401c0468051013602083a5d83e14489b1cf870a244d8e7c3851
...    226c73e1c28913639f0e14489b1cf871224489b1cf870a040d8e7c08902040d8e7c08902040d8e7c08902040d8e7c08902040d8e7c0890204
...    0d8e7c08902040d8e7c08902040d8e7c0850206c73e000b878c6318c6318c6318c630f413003c00281c1401c0c01d00e000c0480080c07c12
...    0040000000200000401000000008000010040000100200000c010000080080000500400200802008000060040000380200100000004000040
...    02000024010000060080000a004000058020010240900400006019ca9aca9ac14ac0cac19ac15aca5ac99ac05ac0dac04ac08ac1da0682000
...    012ca4a080000cb29282000052ca48080001cb29202000092ca48080002cb292020000d2ca48080003cb29202000112ca48080004cb292020
...    00152ca48080005cb29282000192ca480800018b292019a55574aaaa9545d2a8aa0b154162a83455298aa4d154062a8145526aaa0f1414178
...    095028140a05028140a05028140a05028140a050281400182020180300801002101002008040300610080100202018030080600c10100c018
...    040300610080100202018030080100220100c01804030060100c01820200401008010043543e00020406080c0e1416181a202224262830323
...    6383a3e424a4c4e5052545a5e828305a

*** Test Cases ***
CB008542-ET-BA010_Verify_NSA_TF_2CC_scell_selection_based_on_different_weighted_cell_bandwidth_and_same_cell_load_within_unlocked_cells
    [Documentation]
    ...                                nrarfcn        gscn   ssbFrequency   phycell_id
    ...    GNB-2(id=1)     CELL-1       518580        6486         518910          50
    ...                    CELL-2       633508        7845         633408          51
    ...                    CELL-11  424000/344000     5300         424090          60
    ...                    CELL-12  126900/136100     1584         126750          61
    ...                    CELL-13  428000/348000     5350         427970          62
    ...    1. The purpose of this test case is to check following scenarios:
    ...         a.US CB008542-BA#B4: Single UE EN-DC connection setup and DL/UL data scheduling in NSA option 3X with
    ...           BF and A1/A2 measurement based SCell Addition/Release
    ...    2. Test Case Steps:
    ...         Preconditions: NRCELL-2 has NRREL as scell: NRCELL1, NRCELL12, NRCELL13.
    ...                        NRCELL-1 has NRREL as scell: NRCELL2, NRCELL11, NRCELL12, NRCELL13.
    ...         a. CA NSA UE92 attach to NR Cell 2 and scell addition blind to NR Cell 12.
    ...         b. UE92 detach
    ...         c. CA NSA UE92 attach to NR Cell 1 and scell addtion coverbasedA1 to NR Cell 12.
    ...         d. CA NSA UE92 scell release_NR Cell 2 as A2 event. Trigger A1 event to add scell NR Cell 12.
    ...         e. CA  NSA UE92 scell release_NR Cell 12 as A2 event.
    ...    3. Expected Results:
    ...         Step a: UE92 scell added successfully. Traffic is normal.
    ...         Step c: UE92 scell added successfully. Traffic is normal. A2 of scell release is configured to UE.
    ...         Step d: UE92: scell released_NRCELL 12. A1 of scell addition is configured to UE. After A1 event, scell added successfully.
    ...         Step g: UE92: scell released_NRCELL 12.
	[Tags]    QC_47001    BA010    zhoulingyan    CRT
    Precondition and Lock Cell 1 and Cell 11
    NSA UE CA blind scell add and release successfully
	sleep    120s
    Unlock Cell 1 and Cell 11 and Lock Cell 2
    NSA UE Coverbased Scell add same cell and release successfully
	check wireshark log    ${CURDIR}${/}a2a_BA010${/}a2a.ini
	Check Counters    ${PM_Counters_Check_BA010}

*** Keywords ***
NSA UE Coverbased Scell add same cell and release successfully
    NSA UE attach    92    1
	Add gNB Cell1 As Scell By A1    92    518910    120    120
	Verify Throuput on Pscell and Scell    92
	Release gNB Cell1 Scell By A2    92    126750
	Verify Throuput on Pscell    92
	Add gNB Cell1 As Scell By A1    92    518910    90    90
	Verify Throuput on Pscell and Scell    92
	Release gNB Cell1 Scell By A2    92    126750
	Verify Throuput on Pscell    92
	NSA UE Detach From GNB    92

Unlock Cell 1 and Cell 11 and Lock Cell 2
    Unlock Cell1
    Unlock Cell11
    Lock Cell2

NSA UE CA blind scell add and release successfully
	Update UE capa    92    ${SA_Capa_perUE_Full_ue92}    ${Capa_LTE_ue92}
	NSA UE attach    92    2
	Verify Throuput on Pscell and Scell    92
	NSA UE Detach From GNB    92

Precondition and Lock Cell 1 and Cell 11
	Clear Counter Files
	OnlineParamChange    ${OnlineParam_BA010}
	Lock Cell1
	Lock Cell11

UE92 CA covbased scell add and release by diff rsrp successfully
	NSA UE attach    92    1
	Add gNB Cell1 As Scell By A1    92    518910    120    120
	Verify Throuput UE92Pcell and UE91Scell
	Release gNB Cell1 Scell By A2    92    633216
	Verify Throuput UE92Pcell and UE91Scell
	Add gNB Cell1 As Scell By A1    92    518910    90    90
	Verify Throuput UE92 and UE91
	Release gNB Cell1 Scell By A2    92    424090
    Verify Throuput UE92Pcell and UE91Scell

Release ALL UEs
	NSA UE Detach From GNB    91
	NSA UE Detach From GNB    92
	SA UE Detach From GNB    81

UE92 CA blind scell add and release successfully
    Update UE capa    92    ${SA_Capa_perUE_Full_ue92}    ${Capa_LTE_ue92}
	NSA UE attach    92    2
	Verify Throuput UE3 and UE92
	NSA UE Detach From GNB    92

PreconditionUE81and91
    Clear Counter Files
	OnlineParamChange    ${OnlineParam_BA009}
	NSA UE attach    91    11
	Verify Throuput on Pscell and Scell    91    70    9
	SA UE attach    81    13

BA010 Test Teardown
    Unlock Cell2
    Common Test Teardown And Stop Capture Logs

OnlineParamChange
  [Arguments]  ${Online_Param}
  Delta Commission Parameters  ${Online_Param}
  Cells Should Be Onair    check_sib=${False}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F    ue_count=1

NSA UE attach
    [Arguments]    ${ue_id}=91    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    ${cmd}    catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    Execute Egate Command    ${cmd}    successful RA
    Execute Egate Command    debug_log level=4
    Send Throuput    ${ue_id}

SA UE attach
    [Arguments]    ${ue_id}=81    ${target_cells}=1
    Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full_ue3}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    Initial Context Setup Successful
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1

Add gNB Cell1 As Scell By A1
    [Arguments]    ${ue_id}=91    ${carrierfreq}=518910    ${srsrp_nr}=120    ${srsrq_nr}=120
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Start RRC Log    NSA_UE${ue_id}_covBaseA1_scelladd
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=${srsrq_nr}
    ...   pass_regexp=SCellIndex 9 activated successfully
    Get RRC Log

Release gNB Cell1 Scell By A2
    [Arguments]    ${ue_id}=91    ${carrierfreq}=424090
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Start RRC Log    NSA_UE${ue_id}_a2scellrelease
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=9 scell_rsrp=7 scell_rsrq=7
    ...   pass_regexp=Successfully reconfigured dual connectivity
    Get RRC Log


Stop Traffic
    [Arguments]    ${ue_id}=91
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=dl trf_id=2
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=dl trf_id=3
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=dl trf_id=4
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=ul trf_id=1

NSA UE Detach From GNB
    [Arguments]    ${ue_id}=91
    Stop Traffic    ${ue_id}
    Execute Egate Command  ue_detach id=${ue_id}    UE IS OFF


SA UE Detach From GNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command  ue_pdu_session_release ue=${ue_id} pdu=1    Successfully released PDU Session
    Execute Egate Command  ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE CONTEXT RELEASE COMPLETE

Send Throuput
    [Arguments]    ${ue_id}=91
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=91    ${pcell_dl}=235    ${ul}=8
    sleep    10s    #sleep for stable traffic
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>${pcell_dl}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>${ul}

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=91    ${scell_dl}=400    ${ul}=9
    sleep    10s     #sleep for stable traffic
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 0
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 >= 0
    Should Be True    ${scell8_tput}+ ${scell9_tput}> ${scell_dl}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>${ul}

Verify Throuput UE3 and UE92
    [Arguments]    ${ue_id}=92
    ${ue3pcell0_tput}    Ap Get Throuput On Specific Scell    ue_id=81    scell_id=0    type=pdsch    rate_type=ave
    ${ue92scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${ue3pcell0_tput}+ ${ue92scell9_tput}> 70
    Verify Throuput on Pscell    92

Verify Throuput UE92Pcell and UE91Scell
    ${ue91scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=9    type=pdsch    rate_type=ave
    ${ue92pcell8_tput}    Ap Get Throuput On Specific Scell    ue_id=92    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${ue91scell9_tput}+ ${ue92pcell8_tput}> 250

Verify Throuput UE92 and UE91
    [Arguments]    ${ue_id}=92
    ${ue92scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    ${ue91pcell8_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${ue92scell9_tput}+ ${ue91pcell8_tput}> 70
    Verify Throuput UE92Pcell and UE91Scell

Update UE capa
    [Arguments]    ${ue_id}=91    ${SA_Capa_perUE_Full}=none    ${Capa_LTE}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Execute Egate Command    ${cmd}
