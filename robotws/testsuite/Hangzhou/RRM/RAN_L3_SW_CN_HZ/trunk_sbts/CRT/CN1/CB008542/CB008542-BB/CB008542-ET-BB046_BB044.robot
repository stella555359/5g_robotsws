*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team- CN1ET    owner-chunjian.yang    release-5G22R3    CB008542
Resource  ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${DEBUG_LOG_LEVEL}    4
@{PARAMS_IN_SCF}
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actFdmScheduling=true
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRCELL-1:gscnOrSsPbchArfcn=6549
...    NRCELL-1:nrarfcn=524310
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:actCDrx=true
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-2:a1MeashoEnabled=rsrp
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-2:a2MeashoEnabled=rsrp
...    NRCELL-2:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-2:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-2:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-2:actCDrx=true
...    NRCELL-2:pucchModeSelect=longPucch
...    NRCELL-2:actK1Opt=intra-gNB
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-2:absThreshSsbRsrpConsolidation=1
...    NRCELL-2:enDcSyncStatus=synchronous
...    NRCELL-2:sMeasConfigSsbRsrp=1
...    NRCELL-2:a3MeasEnabled=none
...    NRCELL-2:a5MeasEnabled=rsrp
...    NRCELL-2:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-2:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-2:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-12:measGapSelectionSA=favourUeThroughput
...    NRCELL-12:actCDrx=true
...    NRCELL-12:absThreshSsbRsrpConsolidation=1
...    NRCELL-12:sMeasConfigSsbRsrp=1
...    NRCELL-12:a1MeashoEnabled=rsrp
...    NRCELL-12:a3MeasEnabled=none
...    NRCELL-12:a5MeasEnabled=rsrp
...    NRCELL-12:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-12:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-12:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-12:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-12:a2MeashoEnabled=rsrp
...    NRCELL-12:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-12:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-12:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:sCellDeactivationTimerGNB=infinity
${CA_support_list}  ca_Fr1Tdd_Fdd_Nsa

@{OnlineParam_BB046}
...    NRBTS/NRADJNRCELL-1:cellDepType=NSA
...    NRBTS/NRADJNRCELL-1:gNbId=36
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=127230
...    NRBTS/NRADJNRCELL-1:ssbFrequency=127230
...    NRBTS/NRADJNRCELL-1:physCellId=382
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms80
...    NRCELL-1/NRHOIF-1:cellDepType=NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssbFrequency=127230
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-10:lcrId=11
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=36
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms80
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:sMeasConfigSsbRsrp=1
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-10:lcrId=1
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11:sMeasConfigSsbRsrp=0
...    NRCELL-11:pucchModeSelect=longPucch
...    NRCELL-11:actK1Opt=intra-gNB

@{OnlineParam_BB046_recover}
...    delete:NRBTS/NRADJNRCELL-1
...    delete:NRCELL-1/NRHOIF-1
...    delete:NRCELL-1/NRREL-1

@{OnlineParam_BB044}
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=2
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11:sMeasConfigSsbRsrp=0
...    NRCELL-11:pucchModeSelect=longPucch
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-2/NRHOIF-1:cellDepType=NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssbFrequency=127450
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-2/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=1
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-10:lcrId=11
...    NRCELL-2/NRREL-10:removeNotAllowed=false
...    NRCELL-2/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=12
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-1:cellDepType=NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:ssbFrequency=518910
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-10:lcrId=2
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3

@{PM_Counters_Check_BB046}
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISSION_REQ}=2
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISSION_SUCC}=2
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=2
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=2
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0

@{PM_Counters_Check_BB044}
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-2:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-2:RACDU:${SGNB_DU_NSA_ADMISSION_REQ}=2
...    NRCELL-2:RACDU:${SGNB_DU_NSA_ADMISSION_SUCC}=2
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=2
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=2
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
...    NRCELL-12:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-12:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-12:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=0
...    NRCELL-12:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=0

${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021    #The number of radio admission requests for 1 Scell
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028    #The number of successful radio admissions for 1 Scell additions.
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000    #RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000    #Successful RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000    #Number of CA UEs in the current cell configured as a PSCell, which have 1 configured SCell in DL
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
#The number of radio admission requests for 1 S-Cell in addition of PS-Cell. Updated to the PS-Cell whenever there is an admission request for the UE
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015    #The number of successful radio admissions for 1 Scell additions.
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006    #The number of radio admission request for S-Cells. Updated to the S-Cell.
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007    #The number of successful radio admissions for the S-Cell. Updated to the S-Cell.
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000    #Number of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
${SGNB_DU_NSA_ADMISSION_REQ}    M55115C00002    #The number of admission requests for NSA user
${SGNB_DU_NSA_ADMISSION_SUCC}    M55115C00003   #The number of successful radio admitted NSA users

${SA_Capa_perUE_Full}    SEPARATOR=
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

${Capa_LTE}    SEPARATOR=
...    a11ff83bc4c0c03850001c46000000162205e260601c4d000e230000000b1102f130300e26800710400000058881789818070a00038820000
...    002c040bc4c0c03882001c46000002160205e360601c46000e208007104000010580817898180713400385000000c2c040804808d00a001c0
...    41809a1e80b907893a244d8e7c3893a244d8e7c3893a244d8e7c3893a244d8e7c3893a24498e7d1a7448912639f449d1224c73e01a0718c63
...    18c60c02080002010100200804030061000040202004008080600c3000080404030060100c018040300610000402020040100801004000000
...    00

*** Test Cases ***
CB008542-ET-BB046_Verify_NSA_A3_rsrp_interfreq_intergNB_HO_from_realGNB_blind_TF_to_simGNB_F
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         a.US CB008542-BB#B3: Inter-frequency mobility support for UE which has FR1 TDD-FDD CA configured for NSA call
    ...    2. Test Case Steps:
    ...         Note: For intergNB HO case , when source or target cell type is band41 TDD , AP not support the arfcn which
	...         overlapped with band 38
     ...        a. CA NSA UE91 attached to NR Cell 1 PCI 50 and blind add FDD scell 60.
    ...         b. Trigger A2 measGap then trigger IntergNB HO from real gNB to simgNB FDD Cell 382 via A3
    ...         c. Trigger A2 measGap then trigger IntergNB HO from simgNB back to real gNB TDD Cell 50 via A3
    ...         d. CA NSA UE91 Detach.
    ...    3. Expected Results:
    ...         Step a: UE91 TF CA added. Traffic is normal.
    ...         Step b: UE91 HO successfully. Traffic is normal.
    ...         Step c: UE91 HO back successfully. blind TF CA added Traffic is normal.
    ...         Step d: UE detach success.
	[Tags]    QC_164113    BB046    Yang Chunjian
	Delta Commission Parameters    ${OnlineParam_BB046}
	Clear Counter Files
	Set X2AP Link with simgNB
	Ue Attach To Cell and Initial Endc Blind Ca
    Ue Ho To sim gNB Cell382
    Ue Ho Back target real gNB Cell50
    NSA UE Detach From GNB
	Check wireshark log    ${CURDIR}${/}a2a_BB046${/}a2a.ini
	Check Counters

CB008542-ET-BB044_Verify_NSA_A5_rsrp_interfreq_intragNB_HO_from_covBasedA1TF_to_F_actHoOptimizationCa_enabled_and_A1thresholdnotfulfilled
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         a.US CB008542-BB#B3: Inter-frequency mobility support for UE which has FR1 TDD-FDD CA configured for NSA call
    ...    2. Test Case Steps:
     ...        a. CA NSA UE91 attached to NR Cell 2 PCI 51 and add FDD scell 60 via coverbasedA1.
    ...         b. Trigger A2 measGap then trigger InterFre intragNB HO from Cell1 to cell12 (pci 61) via A5
    ...         c. Trigger A2 measGap then trigger HO back from cell12 to cell2 via A5, due to A1threholdnotfulfilled,
    ...            need A1 command to add scell
    ...         d. CA NSA UE91 Detach.
    ...    3. Expected Results:
    ...         Step a: UE91 TF CA added. Traffic is normal.
    ...         Step b: UE91 HO successfully. Sorce scell release ,Traffic is normal.
    ...         Step c: UE91 HO back successfully. Scell added via A1, Traffic is normal.
    ...         Step d: UE detach success.
	[Tags]    QC_164084    BB044    Yang Chunjian
	Delta Commission Parameters    ${OnlineParam_BB044}
	Clear Counter Files
	Ue Attach and add Scell via A1
    Ue Ho To FDD cell success
    Ue Ho Back to TDD Cell success
    Add gNB Cell1 As Scell By A1
    Verify Throuput
    NSA UE Detach From GNB
	Check wireshark log    ${CURDIR}${/}a2a_BB044${/}a2a.ini
	Check Counters    ${PM_Counters_Check_BB044}

*** Keywords ***
Modify Cfg
	Update Cfg    gnb_set id=4 s1u=10.0.1.139 plmn=311:489 gnb_id=0x24:22 type=simulated daemon=10.0.2.1:22222 x2=10.0.1.139:36422
    Update Cfg    gnb_endc_param id=4 use_nr_ran_cont=true
    Update Cfg    gnb_endc_param id=4 scg_dl_dist_percent=0
    Update Cfg    gnb_endc_param id=4 enable_dud_poll_bit=0
    Update Cfg    gnb_param id=4 xn_listening_socket=on send_xn_setup=true

Ue Attach To Cell and Initial Endc Blind Ca
    Update UE capa    91    ${SA_Capa_perUE_Full}    ${Capa_LTE}
    UE Attach To Enb Cell1    ue_id=91
    Initial Endc And Blind Ca    ue_id=91    target_gnb=2    target_cells=1    bearer_id=2
    Send And Verify Throuput

Update UE capa
    [Arguments]    ${ue_id}=91    ${SA_Capa_perUE_Full}=none    ${Capa_LTE}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Execute Egate Command    ${cmd}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66    ue_count=1

NSA UE attach
    [Arguments]    ${ue_id}=91    ${target_cells}=2
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    ${cmd}    catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    Execute Egate Command    ${cmd}    successful RA

Set X2AP Link with simgNB
    Execute Egate Command    enb_x2_link_up enb=1 target=4    ENB-1: X2AP Link with GNB-4

UE Attach To Enb Cell1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

Initial Endc And Blind Ca
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=1
    ${ret1}=    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    Successfully reconfigured dual connectivity    timeout=20s
    Should Contain    ${ret1}    SCellIndex 9 activated successfully

Send And Verify Throuput
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=150 trf_id=2    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=150 trf_id=3    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=150 trf_id=4    UE 91: UDP DL
	Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=150 trf_id=5    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=ul mbps=20 trf_id=2    UE 91: UDP UL
    Verify Throuput

Verify Throuput
    [Arguments]    ${ue_id}=91    ${pcell_dl}=300    ${scell_dl}=60    ${ul}=8
    sleep    10s     #sleep for stable traffic
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > ${pcell_dl}
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > ${scell_dl}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>${ul}

Ue Ho To sim gNB Cell382
    Set MeasurementGap and Initial A2 Event    carrierfreq=523950
    Initial InterFreA3 Ho    carrierfreq=127230    phycell_id=382

Ue Ho Back target real gNB Cell50
    Set MeasurementGap and Initial A2 Event in simulator    carrierfreq=127230
    Initial InterFreA3 Ho back    carrierfreq=523950    phycell_id=50
    Verify Throuput

Set MeasurementGap and Initial A2 Event
    [Arguments]    ${carrierfreq}
    Execute Egate Command    ue_enb_param id=91 measurement_gap=gp0:19 gap_trigger=gnb_triggered
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${carrierfreq}    event_type=A2
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=Sending SgNB Modification Confirm
    Should Contain    ${ret1}    measGapConfig setup
    Should Contain    ${ret1}    drx-Config release : NULL

Set MeasurementGap and Initial A2 Event in simulator
    [Arguments]    ${carrierfreq}
    Execute Egate Command    ue_enb_param id=91 measurement_gap=gp0:19 gap_trigger=gnb_triggered
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${carrierfreq}    event_type=A2
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=NR RRC Reconfiguration procedure completed successfully

Initial InterFreA3 Ho
    [Arguments]    ${carrierfreq}    ${phycell_id}
    Execute Egate Command    ue_enb_param id=91 measurement_gap=off
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${carrierfreq}    event_type=A3
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    ...    pass_regexp=Sending SgNB Change Confirm

Initial InterFreA3 Ho back
    [Arguments]    ${carrierfreq}    ${phycell_id}
    Execute Egate Command    ue_enb_param id=91 measurement_gap=off
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    catenate    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id}
    ...    nrsrp_nr=60 nrsrq_nr=60 rs_type=ssb index=0 nrs_result=30:30:30
    ${ret1}=     Execute Egate Command    ${cmd}
    ...    pass_regexp=SCellIndex 9 activated successfully

NSA UE Detach From GNB
    [Arguments]    ${ue_id}=91
    Stop Traffic
    Execute Egate Command  ue_detach id=${ue_id}    UE IS OFF

Stop Traffic
    Execute Egate Command    trf_data_stop ue=91    pass_regexp=Traffic was stopped

Ue Attach and add Scell via A1
    NSA CA UE Attach To Cell
    Add gNB Cell1 As Scell By A1
    Send And Verify Throuput

NSA CA UE Attach To Cell
    [Arguments]    ${ue_id}=91    ${cell_id}=2
    Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full}    ${Capa_LTE}
    NSA UE attach    ${ue_id}    ${cell_id}

Add gNB Cell1 As Scell By A1
    [Arguments]    ${ue_id}=91    ${carrierfreq}=518910
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Start RRC Log    NSA_UE${ue_id}_covBaseA1_scelladd
    Execute Egate Command    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A1 srsrp_nr=120 ssinr_nr=59 srsrq_nr=120
    ...    pass_regexp=SCellIndex 9 activated successfully

Ue Ho To FDD cell success
    Set MeasurementGap and Initial A2 Event    carrierfreq=518910
    Initial InterFreA5 Ho    carrierfreq=127450    phycell_id=61
    Verify Throuput And Scell Release

Ue Ho Back to TDD Cell success
    Set MeasurementGap and Initial A2 Event    carrierfreq=127450
    Initial InterFreA5 Ho back    carrierfreq=518910    phycell_id=51

Initial InterFreA5 Ho
    [Arguments]    ${carrierfreq}    ${phycell_id}
    Execute Egate Command    ue_enb_param id=91 measurement_gap=off
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${carrierfreq}    event_type=A5
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    ...    pass_regexp=Sending SgNB Modification Confirm
    Should Contain    ${ret1}    sCellToReleaseList

Initial InterFreA5 Ho back
    [Arguments]    ${carrierfreq}    ${phycell_id}
    Execute Egate Command    ue_enb_param id=91 measurement_gap=off
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${carrierfreq}    event_type=A5
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    ...    pass_regexp=Sending SgNB Modification Confirm

Verify Throuput And Scell Release
    [Arguments]    ${sleep_time}=10s    ${target_dl_throuput}=60
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > ${target_dl_throuput}
    Execute Egate Command    ue_stats_nr id=91 scell=9 type=pdsch    fail_regexp=CellIndex-9
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${target_dl_throuput}
