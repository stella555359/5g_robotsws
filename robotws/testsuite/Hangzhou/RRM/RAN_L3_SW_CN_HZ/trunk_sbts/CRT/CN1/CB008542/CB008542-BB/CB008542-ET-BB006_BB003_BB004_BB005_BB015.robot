*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-CN1ET    owner-dandan.chen    release-5G22R3    CB008542
Resource  ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
#${AP_BIP_FLAG}    ${True}
#${GNB_BIP_FLAG}    ${True}

#${TTITRACE_FLAG}    ${True}
#${AP_TTITRACE_FLAG}    ${True}

${UTE_WIRESHARK_FLAG}  ${False}
@{PARAMS_IN_SWCONFIG_AP}  ${EnableSrsBasedBeamForming}=1
${EnableSrsBasedBeamForming}    0x70690
${candidate_cells_mn_hex_for_menb_ho_to_PCI51}    091FABF82198
${candidate_cells_mn_hex_for_menb_ho_to_PCI50}    091FABF82190
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
...    NRCELL-1:actAperCsi=true
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:filterCoeffSsbRsrp=fc4
...    NRCELL-1:filterCoeffSsbRsrq=fc4
...    NRCELL-1:prachConfigurationIndex=97
...    NRCELL-2:pucchModeSelect=longPucch
...    NRCELL-2:actK1Opt=intra-gNB
...    NRCELL-2:filterCoeffSsbRsrp=fc4
...    NRCELL-2:filterCoeffSsbRsrq=fc4
...    NRCELL-2:prachConfigurationIndex=97
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-10:lcrId=11
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
${CA_support_list}  ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa

@{PM_Counters_Check_BB}
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_NSA}=1
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_NSA}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0

@{PM_Counters_Check_BB005}
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_NSA}=1
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_NSA}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-2:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-12:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0

@{PM_Counters_Check_BB015}
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-2:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-1:NX2CC:${X2_SGNB_MOD_REQ_ACK_SNT}=1
...    NRCELL-1:NX2CC:${X2_SGNB_MOD_REQ_RECEIVD}=1
...    NRCELL-2:NX2CC:${X2_SGNB_MOD_REQ_ACK_SNT}=1
...    NRCELL-2:NX2CC:${X2_SGNB_MOD_REQ_RECEIVD}=1
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISSION_REQ}=2
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISSION_SUCC}=2
...    NRCELL-2:RACDU:${SGNB_DU_NSA_ADMISSION_SUCC}=1
...    NRCELL-2:RACDU:${SGNB_DU_NSA_ADMISSION_REQ}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=3
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=3
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021
#The number of radio admission requests for 1 Scell
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028
#The number of successful radio admissions for 1 Scell additions.
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
#RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
#Successful RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000
#Number of CA UEs in the current cell configured as a PSCell, which have 1 configured SCell in DL
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
#The number of radio admission requests for 1 Scell
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
#The number of successful radio admissions for 1 Scell additions.
${A2MEAS_REL1DLSCELL_ATT_NSA}    M55118C06503
#Nbr of RRC Reconfiguration attempts releasing 1 SCell in DL triggered by A2 measurement for NSA
${A2MEAS_REL1DLSCELL_SUCC_NSA}    M55118C06504
#Nbr of successful RRC Reconfigurations releasing 1 SCell in DL triggered by A2 measurement for NSA
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
#The number of radio admission requests for the Scell
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007
#The number of successful radio admissions for the Scell
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000
#Number of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
${X2_SGNB_MOD_REQ_RECEIVD}    M55112C04001    #Number of incoming SGNB MODIFICATION REQUEST received from LTE eNB
${X2_SGNB_MOD_REQ_ACK_SNT}    M55112C04002    #Number of outgoing SGNB MODIFICATION REQUEST ACKNOWLEDGE sent to LTE eNB
${SGNB_DU_NSA_ADMISSION_REQ}    M55115C00002    #The number of admission requests for NSA user
${SGNB_DU_NSA_ADMISSION_SUCC}    M55115C00003   #The number of successful radio admitted NSA users

${SA_Capa_perUE_Full_ue91_csirs9}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C98AB1A1CF
...    88E3D033EC09F1891C790E7D473E642328581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98AB121CFB027C471
...    E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E
...    7CC31E50B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD931562439F11C7B027C62471E439F51CF9863CA16070
...    38784FFF800003FFE0000016001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E14000710400
...    000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E268
...    00711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E1400
...    0711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C0468051013602083A5D83E14489B1CF870A244D
...    908C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E
...    7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C01D00E000C048
...    0080C07C120040000000200000401000000008000010040000100200000C0100000800800005004002008020080000600400003802001000
...    0000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08
...    AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA480
...    80004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A81455
...    26AAA0F1414178095028140A05028140A05028140A05028140A0502814001820201803008010021010020080403006100801002020180300
...    80600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E1416181
...    A2022242628303236383A3E424A4C4E5052545A5E828305A

${SA_Capa_perUE_Full_ue91_csirs5}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C98AB1A1CF
...    88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98AB121CFB027C471
...    E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E
...    7CC31E50B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD931562439F11C7B027C62471E439F51CF9863CA16070
...    38784FFF800003FFE0000016001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E14000710400
...    000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E268
...    00711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E1400
...    0711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C0468051013602083A5D83E14489B1CF870A244D
...    884C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E
...    7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C01D00E000C048
...    0080C07C120040000000200000401000000008000010040000100200000C0100000800800005004002008020080000600400003802001000
...    0000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08
...    AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA480
...    80004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A81455
...    26AAA0F1414178095028140A05028140A05028140A05028140A0502814001820201803008010021010020080403006100801002020180300
...    80600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E1416181
...    A2022242628303236383A3E424A4C4E5052545A5E828305A

${SA_Capa_perUE_Full_ue91_csirs4}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F
...    11C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC0
...    9F18E7CC31E50B0381C3C17003FF001C00FFC00110001C0A836236B04610D04083C412032B64C55890E7C471EC09F1891C790E7D473E618F
...    28581C0E1E13FFE00000FFF80000088000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A00
...    038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E140000040B0
...    2B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02
...    B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B01043505D83E14489B1CF
...    870A244D863C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C089
...    02040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C02500
...    700060240040603E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C
...    010008000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606
...    D6025604560ED0341000009652504000065949410000296524040000E594901000049652404000165949010000696524040001E594901000
...    089652404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA0
...    31540A2A93555078A1202F012A05028140A05028140A05028140A05028140A0502800304040300601002004202004010080600C201002004
...    04030060100C018202018030080600C201002004040300601002004402018030080600C0201803040400802010020086A87C0004080C1018
...    1C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${SA_Capa_perUE_Full_ue91_csirs8}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C98AB1A1CF
...    88E3D033EC09F1891C790E7D473E639F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98AB121CFB027C471
...    E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E
...    7CC31E50B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD931562439F11C7B027C62471E439F51CF9863CA16070
...    38784FFF800003FFE0000016001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E14000710400
...    000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E268
...    00711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E1400
...    0711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C0468051013602083A5D83E14489B1CF870A244D
...    8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E
...    7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C01D00E000C048
...    0080C07C120040000000200000401000000008000010040000100200000C0100000800800005004002008020080000600400003802001000
...    0000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08
...    AC1DA0682000012CA4A080000CB29202000052CA4A080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA480
...    80004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AA2A9555D2A8AA0B154162A83455298AA4D154062A81455
...    26AAA0F1414178095028140A05028140A05028140A05028140A0502814001820201803008010021010020080403006100801002020180300
...    80600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E1416181
...    A2022242628303236383A3E424A4C4E5052545A5E828305A

${Capa_LTE_ue91_csirs9}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A0003882000
...    0002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001
...    C041809A1E80B907893A244D908C0893A244D8E7C3893A244D8E7C3893A244D8E7C3893A24498E7D1A7448912639F449D1224C73E01A0718
...    C6318C60C02080002010100200804030061000040202004008080600C3000080404030060100C01804030061000040202004010080100400
...    000000

${Capa_LTE_ue91_csirs5}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A0003882000
...    0002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001
...    C041809A1E80B907893A244D884C1893A244D8E7C3893A244D8E7C3893A244D8E7C3893A24498E7D1A7448912639F449D1224C73E01A0718
...    C6318C60C02080002010100200804030061000040202004008080600C3000080404030060100C01804030061000040202004010080100400
...    000000

${Capa_LTE_ue91_csirs4}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A0003882000
...    0002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001
...    C041809A26802E41E24E8913618F0224E8913639F0E24E8913639F0E24E8913639F0E24E8912639F469D1224498E7D127448931CF80681C6
...    318C631830082000080404008020100C01840001008080100202018030C0002010100C01804030060100C018400010080801004020040100
...    000000

${Capa_LTE_ue91_csirs8}    SEPARATOR=
...    A11FF83BC2C0C038500000142C440BC4C0C0389A001C46000000162205E260601C4D000E208000000B1102F130300E140007118000000580
...    817898180710400388C0000042C040BC6C0C0388C001C41000E208000020B0102F130300E2680070A000001858081009011A014003808301
...    343D01720F1274489B1CF871274489B1CF871274489B1CF871274489B1CF87127448931CFA34E891224C73E893A24498E7C0340E318C6318
...    C18051000040202004010080600C2000080404008010100C01860001008080600C02018030080600C2000080404008020100200800000000
...    40002010100200C0

${Capa_LTE_ue11_csirs9}    SEPARATOR=
...    A11FF83BC2C0C038500000142C440BC4C0C0389A001C46000000162205E260601C4D000E208000000B1102F130300E140007104000000580
...    817898180710400388C0000042C040BC6C0C0388C001C41000E208000020B0102F130300E2680070A000001858081009011A014003808301
...    343D016A0F0A744D908C0893A244D8E7C3893A244D8E7C3893A244D8E7C3893A24498E7D1A7448912639F449D1224C73E0340E318C6318C1
...    8051000040202004010080600C2000080404008010100C01860001008080600C02018030080600C200008040400802010020080000000040
...    00201010020080

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

@{OnlineParam_BB015}
...    NRBTS:srb3SupportEnabled=true
...    NRCELL-2:actCDrx=false
...    NRCELL-1/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=1
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-10:lcrId=11
...    NRCELL-2/NRREL-10:removeNotAllowed=false
...    NRCELL-2/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:absThreshSsbRsrpConsolidation=15
...    NRCELL-1:sMeasConfigSsbRsrp=15
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-2:absThreshSsbRsrpConsolidation=15
...    NRCELL-2:sMeasConfigSsbRsrp=15
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-11:absThreshSsbRsrpConsolidation=15
...    NRCELL-11:sMeasConfigSsbRsrp=15
...    NRCELL-12:a3MeasEnabled=rsrp
...    NRCELL-12:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-12:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12:absThreshSsbRsrpConsolidation=15
...    NRCELL-12:sMeasConfigSsbRsrp=15


@{OnlineParam_BB015_recovery}
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=false
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-2:actCDrx=true
...    NRBTS:srb3SupportEnabled=false
...    NRCELL-1:a3MeasEnabled=none
...    NRCELL-11:a3MeasEnabled=none
...    NRCELL-12:a3MeasEnabled=none

@{OnlineParam_BB005_blindadd_scell}
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=1
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-10:lcrId=12
...    NRCELL-2/NRREL-10:removeNotAllowed=false
...    NRCELL-2/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3

*** Test Cases ***
CB008542-ET-BB006_NSA_Single_UE_TFCA_covBasedA1_with_UE_CSIRS_9_with_Beamforming_with_ACSI_enable
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         US CB008542-BB#B1: Support FR1 TDD-FDD CA with 5GC002200 enabled in PSCell in NSA option 3x
    ...    2. Test Case Steps:
    ...         a. CA NSA UE91 with AllCC csirs 9 attach to NR Cell 1,
    ...         b. trigger A1 MR to add scell FDD CELL-11
    ...         c. then trigger A2 MR to release scell FDD
    ...         d. non CA NSA UE11 attach to NR Cell 1, no scell added
    ...         e. all UE detach
    ...    3. Expected Results:
    ...         Step a: NSA UE91 call setup successfully. traffic is ok.
    ...                 IE: on message: SgNBAdditionRequestAcknowledge
    ...                 check SRS port should be 2(nr-rrc.nrofSRS_Ports == 1), maxrank=2
    ...                 check resourceSetToAddModList=2, resourceToAddModList =19
    ...                 check nr-rrc.pucch_ResourceId=18 for beamforming and
    ...                 CSI-ReportConfig.reportQuantity:ssb-Index-RSRP(6)
    ...                 nrofPorts should contain 4p8, nr-rrc.nzp_CSI_RS_ResourceId 0, 181, 182, 183
    ...                 reportConfigType is aperiodic, drx setup
    ...         Step b: FDD scell added. Traffic share on scell.
    ...                 IE: on RRC:
    ...                 check SRS port should be 2(nr-rrc.nrofSRS_Ports == 1), maxrank=2
    ...                 check resourceSetToAddModList=2, resourceToAddModList =20
    ...                 nr-rrc.pucch_ResourceId=19 for scell
    ...                 nrofPorts should contain 4p8, nr-rrc.nzp_CSI_RS_ResourceId 0, 181, 182, 183
    ...                 reportConfigType is aperiodic, drx setup
    ...         Step c: FDD scell released.
    ...                 IE: on RRC:
    ...                 check nr-rrc.csi_ReportConfigToReleaseList == 1
    ...                 check nr-rrc.sCellToReleaseList == 1
    ...                 check check resourceSetToAddModList=2, resourceToAddModList =19
    ...                 check SRS port should be 2(nr-rrc.nrofSRS_Ports == 1), , maxrank=2
    ...                 nrofPorts should contain 4p8, nr-rrc.nzp_CSI_RS_ResourceId 0, 181, 182, 183
    ...                 reportConfigType is aperiodic, drx setup
    ...         Step d: Non CA UE11 attach to NRCELL-1, and no eventA1 configured for scelladd function.
    ...         Step e: ALL call can be released successfully.
	[Tags]    QC_164117    BB006    dandchen
	Clear Counter Files
	NSA CA UE Attach To Cell and Initial covBaseA1 scelladd and a2scellrelease    91    1
	NSA non CA UE Attach to Cell
	Stop Traffic And Detach Ue
	check wireshark log    ${CURDIR}${/}a2a_BB006${/}a2a.ini
	Check Counters    ${PM_Counters_Check_BB}

CB008542-ET-BB003_NSA_Single_UE_TFCA_covBasedA1_with_UE_CSIRS_5_with_Beamforming_then_A2_scell_release
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         US CB008542-BB#B1: Support FR1 TDD-FDD CA with 5GC002200 enabled in PSCell in NSA option 3x
    ...    2. Test Case Steps:
    ...         a. CA NSA UE91 with AllCC csirs 5 attach to NR Cell 1,
    ...         b. trigger A1 MR to add scell FDD CELL-11
    ...         c. then trigger A2 MR to release scell FDD
    ...         d. UE detach
    ...    3. Expected Results:
    ...         Step a: NSA UE91 call setup successfully. traffic is ok.
    ...                 IE: on message: SgNBAdditionRequestAcknowledge
    ...                 check SRS port should be 2(nr-rrc.nrofSRS_Ports == 1), maxrank=2
    ...                 check resourceSetToAddModList=2, resourceToAddModList =19
    ...                 check nr-rrc.pucch_ResourceId=18 for beamforming and
    ...                 CSI-ReportConfig.reportQuantity:ssb-Index-RSRP(6)
    ...                 nrofPorts should contain 4p8, nr-rrc.nzp_CSI_RS_ResourceId 0, 181, 182, 183
    ...                 drx setup
    ...         Step b: FDD scell added. Traffic share on scell.
    ...                 IE: on RRC:
    ...                 check SRS port should be 2(nr-rrc.nrofSRS_Ports == 1), maxrank=2
    ...                 check resourceSetToAddModList=2, resourceToAddModList =20
    ...                 nr-rrc.pucch_ResourceId=19 for scell
    ...                 nrofPorts should contain 4p8, nr-rrc.nzp_CSI_RS_ResourceId 0, 181, 182, 183
    ...                 drx setup
    ...         Step c: FDD scell released.
    ...                 IE: on RRC:
    ...                 check nr-rrc.csi_ReportConfigToReleaseList == 1
    ...                 check nr-rrc.sCellToReleaseList == 1
    ...                 check check resourceSetToAddModList=2, resourceToAddModList =19
    ...                 check SRS port should be 2(nr-rrc.nrofSRS_Ports == 1), , maxrank=2
    ...                 nrofPorts should contain 4p8, nr-rrc.nzp_CSI_RS_ResourceId 0, 181, 182, 183
    ...                 drx setup
    ...         Step d: UE can be released successfully.
	[Tags]    QC_164079    BB003    dandchen
	Clear Counter Files
	NSA CA UE Attach To Cell and Initial covBaseA1 scelladd and a2scellrelease    91    1
	...    ${SA_Capa_perUE_Full_ue91_csirs5}    ${Capa_LTE_ue91_csirs5}
	Stop Traffic And Detach Ue for UE91
	check wireshark log    ${CURDIR}${/}a2a_BB003${/}a2a.ini
	Check Counters    ${PM_Counters_Check_BB}

CB008542-ET-BB004_NSA_Single_UE_TFCA_covBasedA1_with_UE_CSIRS_4_with_Beamforming_then_A2_scell_release
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         US CB008542-BB#B1: Support FR1 TDD-FDD CA with 5GC002200 enabled in PSCell in NSA option 3x
    ...    2. Test Case Steps:
    ...         a. CA NSA UE91 with AllCC csirs 4 attach to NR Cell 1,
    ...         b. trigger A1 MR to add scell FDD CELL-11
    ...         c. then trigger A2 MR to release scell FDD
    ...         d. UE detach
    ...    3. Expected Results:
    ...         Step a: NSA UE91 call setup successfully. traffic is ok.
    ...                 IE: on message: SgNBAdditionRequestAcknowledge
    ...                 check SRS port should be 2(nr-rrc.nrofSRS_Ports == 1), maxrank=2
    ...                 check resourceSetToAddModList=2, resourceToAddModList =19
    ...                 check nr-rrc.pucch_ResourceId=18 for beamforming and
    ...                 CSI-ReportConfig.reportQuantity:ssb-Index-RSRP(6)
    ...                 nrofPorts should contain 4p8, nr-rrc.nzp_CSI_RS_ResourceId 0, 181, 182, 183
    ...                 drx setup
    ...         Step b: FDD scell added. Traffic share on scell.
    ...                 IE: on RRC:
    ...                 check SRS port should be 2(nr-rrc.nrofSRS_Ports == 1), maxrank=2
    ...                 check resourceSetToAddModList=2, resourceToAddModList =20
    ...                 nr-rrc.pucch_ResourceId=19 for scell
    ...                 nrofPorts should contain 4p8, nr-rrc.nzp_CSI_RS_ResourceId 0, 181,
    ...                 should contain resource release 182, 183
    ...                 drx setup
    ...         Step c: FDD scell released.
    ...                 IE: on RRC:
    ...                 check nr-rrc.csi_ReportConfigToReleaseList == 1
    ...                 check nr-rrc.sCellToReleaseList == 1
    ...                 check check resourceSetToAddModList=2, resourceToAddModList =19
    ...                 check SRS port should be 2(nr-rrc.nrofSRS_Ports == 1), , maxrank=2
    ...                 nrofPorts should contain 4p8, nr-rrc.nzp_CSI_RS_ResourceId 0, 181, 182, 183
    ...                 drx setup
    ...         Step d: UE can be released successfully.
	[Tags]    QC_164093    BB004    dandchen
	Clear Counter Files
	NSA CA UE Attach To Cell and Initial covBaseA1 scelladd and a2scellrelease    91    1
	...    ${SA_Capa_perUE_Full_ue91_csirs4}    ${Capa_LTE_ue91_csirs4}
	Stop Traffic And Detach Ue for UE91
	check wireshark log    ${CURDIR}${/}a2a_BB004${/}a2a.ini
	Check Counters    ${PM_Counters_Check_BB}

CB008542-ET-BB005_NSA_TFCA_blind_or_covBasedA1_with_UE_CSIRS_8_with_Beamforming_with_ACSI_enable
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         US CB008542-BB#B1: Support FR1 TDD-FDD CA with 5GC002200 enabled in PSCell in NSA option 3x
    ...    2. Test Case Steps:
    ...         a. CA NSA UE91 with AllCC csirs 8 attach to NR Cell 1
    ...         b. trigger A1 MR to add scell FDD CELL-11
    ...         c. then trigger A2 MR to release scell FDD
    ...         d. CA NSA UE91 with AllCC csirs 8 attach to NR Cell 1, blind scell added
    ...         e. UE detach
    ...    3. Expected Results:
    ...         Step a: NSA UE91 call setup successfully. traffic is ok.
    ...                 IE: on message: SgNBAdditionRequestAcknowledge
    ...                 check SRS port should be 2(nr-rrc.nrofSRS_Ports == 1), maxrank=2
    ...                 check resourceSetToAddModList=2, resourceToAddModList =19
    ...                 check nr-rrc.pucch_ResourceId=18 for beamforming and
    ...                 CSI-ReportConfig.reportQuantity:ssb-Index-RSRP(6)
    ...                 nrofPorts should contain 4p8, nr-rrc.nzp_CSI_RS_ResourceId 0, 181, 182, 183
    ...                 drx setup, apercsi setup
    ...         Step b: FDD scell added. Traffic share on scell.
    ...                 IE: on RRC:
    ...                 check SRS port should be 2(nr-rrc.nrofSRS_Ports == 1), maxrank=2
    ...                 check resourceSetToAddModList=2, resourceToAddModList =20
    ...                 nr-rrc.pucch_ResourceId=19 for scell
    ...                 nrofPorts should contain 4p8, nr-rrc.nzp_CSI_RS_ResourceId 0, 181, 182, 183
    ...                 drx setup, apercsi release
    ...         Step c: FDD scell released.
    ...                 IE: on RRC:
    ...                 check nr-rrc.csi_ReportConfigToReleaseList == 1
    ...                 check nr-rrc.sCellToReleaseList == 1
    ...                 check check resourceSetToAddModList=2, resourceToAddModList =19
    ...                 check SRS port should be 2(nr-rrc.nrofSRS_Ports == 1), , maxrank=2
    ...                 nrofPorts should contain 4p8, nr-rrc.nzp_CSI_RS_ResourceId 0, 181, 182, 183
    ...                 drx setup, apercsi setup
    ...         Step d: NSA UE91 call setup successfully. scell added, traffic is ok.
    ...                 IE: on message: SgNBAdditionRequestAcknowledge
    ...                 check SRS port should be 2(nr-rrc.nrofSRS_Ports == 1), maxrank=2
    ...                 check resourceSetToAddModList=2, resourceToAddModList =19
    ...                 check nr-rrc.pucch_ResourceId=18 for beamforming and
    ...                 CSI-ReportConfig.reportQuantity:ssb-Index-RSRP(6)
    ...                 nrofPorts should contain 4p8, nr-rrc.nzp_CSI_RS_ResourceId 0, 181, 182, 183
    ...                 drx setup, apercsi not setup
    ...         Step e: UE can be released successfully.

	[Tags]    QC_164116    BB005    dandchen
	Clear Counter Files
	NSA CA UE Attach To Cell and Initial covBaseA1 scelladd and a2scellrelease    91    1
	...    ${SA_Capa_perUE_Full_ue91_csirs8}    ${Capa_LTE_ue91_csirs8}
	Stop Traffic And Detach Ue for UE91
	NSA CA UE Attach To Cell and Initial blind scell addition
	check wireshark log    ${CURDIR}${/}a2a_BB005${/}a2a.ini
	Check Counters    ${PM_Counters_Check_BB005}

CB008542-ET-BB015_Verify_IntraMeNB_HO_without_SgNB_change_with_PSCell_change_intraFreq_from_CA_to_CA_with_blind_SRB3
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         a.US CB008542-BB#B5A: Intra-MeNB LTE HO without SgNB change triggering UE reconfiguration with PSCell
    ...           change (CA + NSA Opt 3x)
    ...    2. Test Case Steps:
    ...         Preconditions: NRCELL-2 has NRREL as scell_blind: NRCELL11.
    ...                        NRCELL-1 has NRREL as scell_blind: NRCELL11
     ...        a. CA NSA UE92 attach to NR Cell 1 PCI 50 and blind scell is added NRCELL 11 PCI 60.
    ...         b. trigger intra-eNB HO with PScell change to eNB 1 cell 2 and gNB NR Cell 2 PCI 51
    ...         c. CA NSA UE92 attach to NR Cell 2 PCI 51 and blind scell is added NRCELL 11 PCI 60.
    ...         d. Trigger intra-eNB HO back to NR Cell 1 PCI 50 and blind scell is added NRCELL 11 PCI 60.
    ...         e. CA  NSA UE92 Detach.
    ...    3. Expected Results:
    ...         Step a: UE92 CA TF is successful. Traffic is normal.
    ...         Step b: UE92 HO successfully. Traffic is normal.
    ...         Step c: UE92 CA TF is successful. Traffic is normal.
    ...         Step d: HO back successfully.UE92 CA TF is successful. Traffic is normal.
	[Tags]    QC_164089    BB015    zhoulingyan
    Precondition UE setting with OnlineParameter Modification to add NRREL
	NSA UE attach with traffic    92    1
    MeNB1 Cell1 HO to MeNB1 Cell2 with PScellchange from PCI50 to PCI51
    Verify Throuput on Pscell and Scell    92
    MeNB1 Cell2 HO to MeNB1 Cell1 with PScellchange from PCI51 to PCI50
    Verify Throuput on Pscell and Scell    92
    NSA UE Detach From GNB
    check wireshark log    ${CURDIR}${/}a2a_BB015${/}a2a.ini
	Check Counters    ${PM_Counters_Check_BB015}
	[Teardown]    BB015 TestTeardown

*** Keywords ***
MeNB1 Cell1 HO to MeNB1 Cell2 with PScellchange from PCI50 to PCI51
    eNB HO with PScellChange

MeNB1 Cell2 HO to MeNB1 Cell1 with PScellchange from PCI51 to PCI50
    eNB HO with PScellChange    92    1    1    50    1    ${candidate_cells_mn_hex_for_menb_ho_to_PCI50}

BB015 TestTeardown
    OnlineParamChange    ${OnlineParam_BB015_recovery}
    Common Test Teardown And Stop Capture Logs

eNB HO with PScellChange
    [Arguments]    ${ue_id}=92    ${enb_id}=1    ${enbcell_Target}=2    ${gNB_Target_PCI}=51    ${gNBcell_Target}=2
    ...    ${candidate_cells_mn_hex_for_menb_ho}=${candidate_cells_mn_hex_for_menb_ho_to_PCI51}
    Execute Egate Command    enb_cell_param enb=${enb_id} id=${enbcell_Target} allow_endc=on
    Execute Egate Command    ue_enb_endc_param id=${ue_id} candidate_cells_mn_hex_for_menb_ho=${candidate_cells_mn_hex_for_menb_ho}
    ${ret1}=    Execute Egate Command    ue_ho id=${ue_id} enb=${enb_id} ho_mode=INTRA_LTE cell=${enbcell_Target}
    ...    handover from
    Should Contain    ${ret1}    physCellId ${gNB_Target_PCI}
    Should Contain    ${ret1}    Proxy (eNB 2 cell ${gNBcell_Target}) reported successful RA

Precondition UE setting with OnlineParameter Modification to add NRREL
    [Arguments]    ${ue_id}=92    ${Online_Param}=${OnlineParam_BB015}
    Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full_ue92}    ${Capa_LTE_ue92}
    Execute Egate Command    ue_enb_endc_param id=${ue_id} reset
    Execute Egate Command    enb_endc_param id=1 reset
    Execute Egate Command    enb_endc_param id=11 reset
    Execute Egate Command    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Execute Egate Command    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Execute Egate Command    enb_x2_link_up enb=11 target=2    ENB-11: X2AP Link with GNB-2
    Execute Egate Command    ue_change_location id=${ue_id} cell=1 enb=1
    OnlineParamChange    ${Online_Param}
	Clear Counter Files

OnlineParamChange
  [Arguments]  ${Online_Param}
  Delta Commission Parameters  ${Online_Param}
  Cells Should Be Onair    check_sib=${False}

NSA UE attach with traffic
    [Arguments]    ${ue_id}=92    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    ${cmd}    catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}    successful RA
    Should Not Contain    ${ret1}    aperiodicTriggerStateList setup
    Execute Egate Command    debug_log level=4
    Send Throuput    ${ue_id}
    Verify Throuput on Pscell and Scell    ${ue_id}

Send Throuput
    [Arguments]    ${ue_id}=92
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
	Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
	Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
	Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic


Stop Traffic
    [Arguments]    ${ue_id}=92
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=dl trf_id=2
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=dl trf_id=3
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=dl trf_id=4
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=ul trf_id=1

NSA UE Detach From GNB
    [Arguments]    ${ue_id}=92
    Stop Traffic    ${ue_id}
    Execute Egate Command  ue_detach id=${ue_id}    UE IS OFF

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/4cells_2F2T_8pipes    ue_count=1

NSA CA UE Attach To Cell and Initial covBaseA1 scelladd and a2scellrelease
    [Arguments]    ${ue_id}=91    ${cell_id}=1    ${SA_Capa_perUE_Full_ue91}=${SA_Capa_perUE_Full_ue91_csirs9}
    ...    ${Capa_LTE_ue91}=${Capa_LTE_ue91_csirs9}
    Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full_ue91}    ${Capa_LTE_ue91}
    NSA UE attach    ${ue_id}    ${cell_id}
    Send And Verify Throuput
    Add gNB Cell1 As Scell By A1
    Release gNB Cell1 Scell By A2

NSA non CA UE Attach to Cell
    Update UE capa    11    ${SA_Capa_perUE_Full_ue91_csirs9}    ${Capa_LTE_ue11_csirs9}
    NSA UE attach    11    1
	Send And Verify Throuput for nonCA UE

NSA UE attach
    [Arguments]    ${ue_id}=91    ${target_cells}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    ${cmd}    catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    Execute Egate Command    ${cmd}    successful RA

Add gNB Cell1 As Scell By A1
    [Arguments]    ${ue_id}=91    ${carrierfreq}=518910
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A1 srsrp_nr=120 ssinr_nr=59 srsrq_nr=120
    ...   pass_regexp=SCellIndex 9 activated successfully
    Verify Throuput on Pscell and Scell

Release gNB Cell1 Scell By A2
    [Arguments]    ${ue_id}=91    ${carrierfreq}=127450
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=9 scell_rsrp=7 scell_rsrq=7
    ...   pass_regexp=Successfully reconfigured dual connectivity
    Verify Throuput And Scell Release    sleep_time=10s    target_dl_throuput=50

Stop Traffic And Detach Ue
    Stop Traffic And Detach Ue for UE91
    Stop Traffic And Detach Ue for UE11

Stop Traffic And Detach Ue for UE91
    Execute Egate Command    trf_data_stop ue=91 id=2 dir=ul trf_id=1
    Execute Egate Command    trf_data_stop ue=91 id=2 dir=dl trf_id=2
    Execute Egate Command    trf_data_stop ue=91 id=2 dir=dl trf_id=3
    Execute Egate Command    trf_data_stop ue=91 id=2 dir=dl trf_id=4
    Execute Egate Command    trf_data_stop ue=91 id=2 dir=dl trf_id=5
    Execute Egate Command    ue_detach id=91    UEC-1: UE91: detached

Stop Traffic And Detach Ue for UE11
    Execute Egate Command    trf_data_stop ue=11 id=2 dir=ul trf_id=1
    Execute Egate Command    trf_data_stop ue=11 id=2 dir=dl trf_id=2
    Execute Egate Command    ue_detach id=11    UEC-1: UE11: detached

Send And Verify Throuput
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
	Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1   UE ${ue_id}: UDP UL
    Verify Throuput on Pscell    sleep_time=30s

Send And Verify Throuput for nonCA UE
    [Arguments]    ${nonca_ue_id}=11    ${sleep_time}=30s
    sleep    ${sleep_time}
    Execute Egate Command    data_trf_start ue=${nonca_ue_id} id=2 dir=dl mbps=10 trf_id=2    UE ${nonca_ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${nonca_ue_id} id=2 dir=ul mbps=10 trf_id=1   UE ${nonca_ue_id}: UDP UL
    Verify Throuput on Pscell for nonCA UE    sleep_time=30s

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>200
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>200

Verify Throuput on Pscell for nonCA UE
    [Arguments]    ${nonca_ue_id}=11    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${nonca_ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>5
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${nonca_ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>8
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${nonca_ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>5

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=100 trf_id=5    UE ${ue_id}: UDP DL
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 250
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 50
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>200

Verify Throuput And Scell Release
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s    ${target_dl_throuput}=200
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 250
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=9 type=pdsch    fail_regexp=CellIndex-9
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${target_dl_throuput}

Update UE capa
    [Arguments]    ${ue_id}=91    ${SA_Capa_perUE_Full}=none    ${Capa_LTE}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Execute Egate Command    ${cmd}

NSA CA UE Attach To Cell and Initial blind scell addition
    Update UE capa    91    ${SA_Capa_perUE_Full_ue91_csirs8}    ${Capa_LTE_ue91_csirs8}
    OnlineParamChange    ${OnlineParam_BB005_blindadd_scell}
    NSA UE attach with traffic    91    2
    Verify Throuput on Pscell and Scell    91
    NSA UE Detach From GNB    91
