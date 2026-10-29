*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    owner-zhanghao
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB005935
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
${GNB_BIP_FLAG}    ${True}
${TTITRACE_FLAG}    ${True}
${SNAPSHOT_FLAG}    pass:False,fail:True
${EMIL_FLAG}    ${True}
${SOS_REPORT_FLAG}    pass:False,fail:True
${BTS_STARTUP_RETRY}    0

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{same frequency}
...    @{NRREL}
...    @{8290_enable}
...    @{1630_enable}
...    @{5935_related}
...    @{PCMD_related}

@{NRREL}
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:lcrId=13
...    NRCELL-11/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-4:gNbId=1
...    NRCELL-11/NRREL-4:gNbIdLength=22
...    NRCELL-11/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-4:removeNotAllowed=false
...    NRCELL-11/NRREL-4:lcrId=2
...    NRCELL-11/NRREL-4:sCellPrio=1
...    NRCELL-11/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=1
...    NRCELL-11/NRREL-3:sCellPrio=2
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:lcrId=14
...    NRCELL-11/NRREL-2:sCellPrio=2
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=12
...    NRCELL-11/NRREL-1:sCellPrio=1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlAndUl

@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actCDrx=false
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=infinity
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=5|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-14:weightForSCellSelection=50
...    NRCELL-13:weightForSCellSelection=50
...    NRCELL-1:weightForSCellSelection=50
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-11:actProactUlScheduling=false
...    NRCELL-12:actProactUlScheduling=false
...    NRCELL-13:actProactUlScheduling=false
...    NRCELL-14:actProactUlScheduling=false

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-13:type0CoresetConfigurationIndex=8
...    MRBTS-1/NRBTS-1/NRCELL-12:gscnOrSsPbchArfcn=1565
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnDl=124900
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnUl=134100
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwDl=15MHz
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwUl=15MHz
...    MRBTS-1/NRBTS-1/NRCELL-12:type0CoresetConfigurationIndex=7
...    MRBTS-1/NRBTS-1/NRCELL-14:gscnOrSsPbchArfcn=1565
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:nrarfcnDl=124900
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:nrarfcnUl=134100
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:chBwDl=15MHz
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:chBwUl=15MHz
...    MRBTS-1/NRBTS-1/NRCELL-14:type0CoresetConfigurationIndex=7

@{1630_enable}
...    NRBTS-1:actRanSharing=true
...    delete:NRBTS-1/NRCELL:configuredEpsTac
...    delete:NRBTS-1/NRCELL:trackingAreaDN
...    MRBTS-1/NRBTS-1/NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    MRBTS-1/NRBTS-1/NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL/NRPLMNSET_NSA-1:nrPlmnSetNsaId=1
...    MRBTS-1/NRBTS-1/NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL/NRPLMNSET_SA-1:nrPlmnSetSaId=1
...    MRBTS-1/NRBTS-1/NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200

@{5935_related}
#1208 Frame Structure
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-1:prachConfigurationIndex=98
...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:prachConfigurationIndex=98
...    delete:NRCELL-1:tddFrameStructure:lteToNrFrameShift
...    delete:NRCELL-2:tddFrameStructure:lteToNrFrameShift
...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL:maxNumOfSCellAlloc=250
...    NRBTS-1:actFdmScheduling=true
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=30
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=30
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL-11:increaseK1ULCA=K1 not increased
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELL:allowUnsuppBcOrBcs=${allowUnsuppBcOrBcs}
${CA_support_list}    ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fdd_Any_Sa,
...                   ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd_Sa_WithUl,ca_Fdd_Fr1Tdd_Sa_WithUl
${allowUnsuppBcOrBcs}    accept unknown band combinations,accept unknown BCSs

@{PCMD_related}
...    @{TCE}
...    @{NRMTRACECU}
...    @{CellTrace_enable}
...    @{traceAll}
...    @{PCMD_enable}
...    @{PeriodicUeMeas}
...    @{PCMD_DU_enable}
...    @{NRSTRACECU}
@{TCE}
...    MRBTS/MNL-1/TCEADM-1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIpAddress=${TCE_IP}
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tcePortNumber=${TCE_PORT}
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tlsEnabled=false
...    NRBTS/NRCTRLTS-1
@{NRMTRACECU}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrTceIdentifier=1
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:scope=allResources
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mcc=311
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=489
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=3
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:traceId=1
@{CellTrace_enable}
...    NRBTS:actCellTraceReport=true
...    NRBTS:actSubscriberTraceReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all
@{PCMD_enable}
...    NRBTS:actPCMDReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=true
@{traceAll}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNRRRCSetting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceX2Setting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceXNSetting=all
@{PeriodicUeMeas}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=TraceOnly
@{PCMD_DU_enable}
...    NRBTS/NRDU-1/NRCTRLTSDU-1
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:actPCMDReporting=true
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:jobType=TraceOnly
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrTceIdentifier=1
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:scope=allResources
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mcc=311
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mnc=489
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mncLength=3
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:traceId=1
@{NRSTRACECU}
...    NRBTS/NRCTRLTS-1/NRSTRACECU-1
...    NRBTS/NRCTRLTS-1/NRSTRACECU-1:nrStraceCuId=1
...    NRBTS/NRCTRLTS-1/NRSTRACECU-1:applyDefNrTceForAllSessions=true
...    NRBTS/NRCTRLTS-1/NRSTRACECU-1:certTypeForTlsAuth=RSA
...    NRBTS/NRCTRLTS-1/NRSTRACECU-1:defaultNrTceIdentifier=1
...    NRBTS/NRCTRLTS-1/NRSTRACECU-1:nrTcePortNumber=49100
...    NRBTS/NRCTRLTS-1/NRSTRACECU-1:tlsEnabled=false

${SA_Capa_Support}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B2ABB08873E238F11C7A06
...    7D813E31CF9863CA1607FFFF82E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C0000000000000000
...    0040E1E027FFC00001FFF000001700003802CF0F1300038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000
...    E208000010B02B0F13000388C0000042C0AC5C46000E208007104000028581587850001C4C00000C160562E2600071040038500000102C0A
...    C5C4C000E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26000710400388C0000082C0AC
...    5C28000E23000711800001058158B898001C46000E140000040B02B0F11800388C00000C2C0AC9C28000E14000710400388C001C4C00000E
...    1617593850001C28000E20800710400389800001C2C3F593850001C41000E2080071180038980000202C0BC1C28000012160205E0E208000
...    0A0B0102F07118000050580817838980000242C040803808D00A202640411740101150B428913639F0E14489B1CF870A244D8E7C3851226C
...    73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081
...    B1CF811204081B1CF810A040D8E7C09502040810206CB5E1C8810204081B2D78722040810206CB5E1C089B1CF870206C00004081B0000102
...    06C0000001F1618C6318C6318C6318C6318C6318DE82E003C00281C1401C0C02500700060240040603E09002000000010000020080000000
...    400000802000008010000060080000400400002802001004010040000300200001C010008000000200002001000012008000030040000500
...    200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED03410000096524040000659494100002
...    96525040000E594901000049652404000165949010000696524040001E594901000089652404000265949010000A96524040002E59494100
...    00C96524040000C594900CD2A8BA55554AAAE95455058AA0B1541A2A94C55268AA031540A2A93555078A160178095028140A05028140A050
...    28140A05028140A050281400282020180300801002101002008040300610080100202018030080600C10100C018040300610080100202018
...    030080100220100C01804030060100C018202004010080100440100200404008010100C018040300601002004802004008080600C0201803
...    0080600C020040080040080300080600C3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828705A0

@{4CC_FFFT_checkpoint}
...    freqBandIndicatorNR 41
...    freqBandIndicatorNR 71
...    freqBandIndicatorNR 66
...    eventA2
...    eventA6
...    uplinkConfigCommon
...    frequencyBandList.*\{.*71.*\}\.
...    pcid:60, scellIdx:0] configure_0_1
...    pcid:60, scellIdx:0] configure_1_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:61, scellIdx:2] configure_0_1
...    pcid:61, scellIdx:2] configure_1_1
...    pcid:62, scellIdx:3] configure_1_1
...    rrcReconfigurationComplete

@{TDD_scellswap_checkpoint}
# TDD scellidx change from 1 to 4
...    pcid:60, scellIdx:0] configure_0_1
...    pcid:60, scellIdx:0] configure_1_1
...    pcid:50, scellIdx:4] configure_1_1
...    rrcReconfigurationComplete

@{FDD_scellswap_checkpoint}
# FDD scellidx change from 2 to 1
...    uplinkConfigCommon
...    frequencyBandList.*\{.*71.*\}\.
...    pcid:60, scellIdx:0] configure_1_1
...    pcid:60, scellIdx:0] configure_0_1
...    pcid:63, scellIdx:1] configure_0_1
...    pcid:63, scellIdx:1] configure_1_1
...    rrcReconfigurationComplete

@{PM_Counters}
...    NRCELL-11:${RRC_RECONF_ADD1ULSCELL_ATT_SA}=1
...    NRCELL-11:${RRC_RECONF_ADD1ULSCELL_SUCC_SA}=1
...    NRCELL-11:${UE_PCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-12:${UE_SCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-14:${UE_SCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-11:${MAX_UE_PCELL_1_CONF_SCEL_UL_SA}>=1
...    NRCELL-11:${SCELL_SWAP_1_ATT_SA}=2
...    NRCELL-11:${SCELL_SWAP_1_SUCC_SA}=2
${RRC_RECONF_ADD1ULSCELL_ATT_SA}    M55118C10001
${RRC_RECONF_ADD1ULSCELL_SUCC_SA}    M55118C10002
${UE_PCELL_1_CONF_SCELL_UL_SA}    M55118C10005
${UE_SCELL_1_CONF_SCELL_UL_SA}    M55118C10006
${MAX_UE_PCELL_1_CONF_SCEL_UL_SA}    M55156C10007
${SCELL_SWAP_1_ATT_SA}    M55118C10501
#The total number of SCell swap attempts for 1 SCell in the PCell for SA mode.
${SCELL_SWAP_1_SUCC_SA}    M55118C10502
#The total number of successful SCell swap attempts for 1 SCell in the PCell for SA mode.

${pdu_id}    1
${gw_id}    1
${nwslice}    1

*** Test Cases ***
CB005935-ET-AB03_scell_swap_under_same_operationMode_with_PCMD
    [Documentation]
    ...    1. This user scenario is to check the successful operation of the A6 based SCell swap with FDD FR1-FDD UL CA
    ...       configured for SA Option2 mode call.
    ...    2. Configuration
    ...            CA Cell ID  PCID    NRREL Duplex Band    BW  scellprio  arfcnSsbPbch  gscn sCellOperationalMode
    ...         pcell cell-11    60      NaN    FDD  N66 10MHz        NaN        424090  5300               dlOnly
    ...    scellIdx-1  cell-1    50  NRREL-3    TDD  N41 60MHz        2.0        518910  6486               dlOnly
    ...           NaN  cell-2    51  NRREL-4    TDD  N41 60MHz        1.0        518910  6486               dlOnly
    ...    scellIdx-2 cell-12    61  NRREL-1    FDD  N71 15MHz        1.0        125290  1565              dlAndUl
    ...           NaN cell-14    63  NRREL-2    FDD  N71 15MHz        2.0        125290  1565              dlAndUl
    ...    scellIdx-3 cell-13    62 NRREL-10    FDD  N66 10MHz        NaN        427970  5350               dlOnly
    ...    3. Test Case Steps:
    ...        a. Attach UE-1 to Cell-1 and make SA call, trigger A1 scell Addition MR, Start UL/DL data transfer for UE
    ...        b. trigger A6 scell swap MR one by one
    ...        c. release UE-1.
    ...    4. Expect result:
    ...        a. n66_n41_n71_n66 FFFT 4CC with DL CA and FF 2CC UL CA is configured,
    ...           cell-2/13 (n41/n66) selected as DL only scell, cell-12 (n71) is selected as DL+UL scell
    ...        b. TDD scell swap: cell-2 to cell-1, FDD scell swap: cell-12 to cell-14,
    ...           cell-14 (n71) is selected as DL+UL scell, cell-1 as DL only scell, cell-13 no impact
    ...           all CA related measurement reconfigured correctly
    ...           No impact on data, PM Counters shall be pegged
    ...        c. UE release successfully
    [Tags]    QC_349605    AB03
    Clear Counter Files
    Start TCE    ${TCE_PORT}
    Update UE capa    ${SA_Capa_Support}    81
    UE attach and scell add    ${4CC_FFFT_checkpoint}
    Trigger ScellSwap    event_type=A6    carrierfreq=518910    nrsrp_nr=30    nrsrq_nr=30    ue_id=81    scell_id=1    phycell_id=50
    ...    pass_regexp=${TDD_scellswap_checkpoint}
    Verify Throughput on Pscell and Scell 4CC after TDD scell swap    ue_id=81
    Trigger ScellSwap    event_type=A6    carrierfreq=125290    nrsrp_nr=30    nrsrq_nr=30    ue_id=81    scell_id=2    phycell_id=63
    ...    pass_regexp=${FDD_scellswap_checkpoint}
    Verify Throughput on Pscell and Scell 4CC after FDD scell swap    ue_id=81
    UE Deregister From gNB    81
    Check Wireshark Log    ${CURDIR}${/}a2a_AB03${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    Check Counters    pm_counters_expression=${PM_Counters}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

UE attach and scell add
    [Arguments]    ${pass_regexp}=none    ${fail_regexp}=none
    UE Attach To Target Cell    cell_id=11    ue_id=81
    Send Throuput    ue_id=81
    Verify Throuput on Pscell    ue_id=81
    Trigger MR    event_type=A1    carrierfreq=424090    srsrp_nr=100    srsrq_nr=50    ue_id=81
    ...           pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Verify Throughput on Pscell and Scell 4CC    ue_id=81

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell
    [Arguments]    ${cell_id}    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=150 trf_id=1    UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=150 trf_id=2    UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=150 trf_id=3    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${ul}=8
    sleep    10s    #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger MR
    [Arguments]    ${event_type}=A1    ${carrierfreq}=518910    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=82
    ...            ${pass_regexp}=none    ${fail_regexp}=none
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=518910    ${nrsrp_nr}=5    ${nrsrq_nr}=5    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=50    ${pass_regexp}=none
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

Verify Throughput on Pscell and Scell 4CC
    [Arguments]    ${ue_id}=81
    sleep    10s     #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    PUSCH Throughput
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    PDSCH Throughput
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 60    # 64.0 Mbps
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 300    # 321.4 Mbps
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 100    # 107.3 Mbps
    ${scell3_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    Should Be True    ${scell3_tput}/1000 > 60    # 64.0 Mbps
    ${scell0_ultput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell0_ultput}/1000 > 30    # 34.2 Mbps
    ${scell2_ultput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pusch    rate_type=ave
    Should Be True    ${scell2_ultput}/1000 > 50    # 53.8 Mbps

Verify Throughput on Pscell and Scell 4CC after TDD scell swap
    [Arguments]    ${ue_id}=81
    sleep    10s     #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    PUSCH Throughput
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    PDSCH Throughput
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 60    # 64.0 Mbps
    ${scell4_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=4    type=pdsch    rate_type=ave
    Should Be True    ${scell4_tput}/1000 > 300    # 352.7 Mbps
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 100    # 107.3 Mbps
    ${scell3_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    Should Be True    ${scell3_tput}/1000 > 60    # 64.0 Mbps
    ${scell0_ultput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell0_ultput}/1000 > 30    # 34.2 Mbps
    ${scell2_ultput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pusch    rate_type=ave
    Should Be True    ${scell2_ultput}/1000 > 50    # 53.8 Mbps

Verify Throughput on Pscell and Scell 4CC after FDD scell swap
    [Arguments]    ${ue_id}=81
    sleep    10s     #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    PUSCH Throughput
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    PDSCH Throughput
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 60    # 64.0 Mbps
    ${scell4_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=4    type=pdsch    rate_type=ave
    Should Be True    ${scell4_tput}/1000 > 300    # 352.7 Mbps
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 90    # 96.0 Mbps
    ${scell3_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    Should Be True    ${scell3_tput}/1000 > 60    # 64.0 Mbps
    ${scell0_ultput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell0_ultput}/1000 > 30    # 34.2 Mbps
    ${scell1_ultput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pusch    rate_type=ave
    Should Be True    ${scell1_ultput}/1000 > 50    # 53.8 Mbps
