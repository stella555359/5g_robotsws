*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_BOO_AP_LOO
...    owner-zora.wang    release-SBTS24R2    team-CN1ET
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CA_NRREL}
...    @{PARAMS_FOR_9059}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_Handover}
...    @{732}
...    @{CB008225}

@{732}
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS-1:tWaitingRlRecoverSA=4000ms

@{CB008225}
...    NRBTS:drbInactivityTimerSA=60
...    NRBTS:srbInactivityTimerSA=6
...    NRBTS:maxUeRrcInactTime=1
...    NRBTS:rrcInactIMMSteeringEnabled=true
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:t380=60min
...    NRBTS:actPaging=true
...    NRBTS:tRanPagingGuard=5
...    NRBTS:ranPagingCycle=v32
...    NRCELL-11/NRPLMNSET_SA-1:ranAC=0
...    NRBTS:activityNotificationLevelSA=ue
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRRCC=5min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrPaging=5min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrF1CD=5min
...    NRBTS:act3gppBL23R1=true
...    NRBTS:actIdleMMSteering=true
...    NRCELL:idleMMSteeringAlgo=non CA aware
...    NRCELL:idleMMSteeringPercentageOfUes=10
...    NRCELL:idleMMSteeringWRREnabled=false
...    NRBTS:rrcInactPreferredStateEnabled=false

@{PARAMS_FOR_9059}
...    NRBTS-1/NRDRB-11:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-12:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-13:cellAggrLevel=FR1 CA incompatible
...    NRBTS-1/NRDRB-14:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-18:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-19:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1:actDrbProfileForCellAggrLevel=FR1_SA

@{PARAMS_FOR_CA}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:maxNumScellsDlFr1=4
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa
...    NRCELL:actCDrx=false
...    NRCELL:actAperCsi=false
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{CA_NRREL}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:nrDcAllowed=false
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
...    NRCELL-11/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3

...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-12/NRREL-2:lcrId=11
...    NRCELL-12/NRREL-2:nrDcAllowed=false
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3

...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-2:lcrId=11
...    NRCELL-3/NRREL-2:nrDcAllowed=false
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlOnly

@{PARAMS_FOR_Handover}
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIncXn=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:absThreshSsbRsrpConsolidation=80
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS/NRCELL-3:a1MeashoEnabled=rsrp
...    NRBTS/NRCELL-3:a1MeashoEnabledSA=rsrp
...    NRBTS/NRCELL-3:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRBTS/NRCELL-3:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL-3:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2ThresholdhoSsbRsrpSA=20|a2TimeToTriggerhoSsbRsrpSA=ms64

...    NRCELL-12:a1MeashoEnabled=rsrp
...    NRCELL-12:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-12:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-12:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-12:a1MeashoEnabledSA=rsrp
...    NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    NRCELL-12:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-12:a2MeashoEnabled=rsrp
...    NRCELL-12:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-12:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-12:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-12:a2MeashoEnabledSA=rsrp
...    NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2ThresholdhoSsbRsrpSA=20|a2TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=3
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=632736
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=30|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=11
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

@{PM_Counters_BC008}
...    NRCELL-11:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=3
...    NRCELL-11:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=2
...    NRCELL-11:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=2
...    NRCELL-11:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=2
...    NRCELL-11:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-11:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0
...    NRCELL-11:${DL_RRC_FSCELL_REL_ATT_SA}=1
...    NRCELL-11:${DL_RRC_FSCELL_REL_SUC_SA}=1
...    NRCELL-11:${DL_RRC_1SCELL_REL_ATT_SA}=0
...    NRCELL-11:${DL_RRC_1SCELL_REL_SUC_SA}=0

...    NRCELL-3:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-3:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=1
...    NRCELL-3:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=0
...    NRCELL-3:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=0
...    NRCELL-3:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-3:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0
...    NRCELL-3:${DL_RRC_FSCELL_REL_ATT_SA}=0
...    NRCELL-3:${DL_RRC_FSCELL_REL_SUC_SA}=0
...    NRCELL-3:${DL_RRC_1SCELL_REL_ATT_SA}=0
...    NRCELL-3:${DL_RRC_1SCELL_REL_SUC_SA}=0

@{PM_Counters_BC009}
...    NRCELL-11:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=2
...    NRCELL-11:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=1
...    NRCELL-11:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=0
...    NRCELL-11:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=0
...    NRCELL-11:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-11:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0
...    NRCELL-11:${DL_RRC_FSCELL_REL_ATT_SA}=1
...    NRCELL-11:${DL_RRC_FSCELL_REL_SUC_SA}=1
...    NRCELL-11:${DL_RRC_1SCELL_REL_ATT_SA}=2
...    NRCELL-11:${DL_RRC_1SCELL_REL_SUC_SA}=2

${SCELL_ADDN_ALLOW_DRB_PRFL_CA}    M55125C00039
#This counter shows the number of times SCell addition is allowed for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.
${SCELL_ADDN_PREVENT_DRB_PRFL_CA}    M55125C00040
#This counter shows the number of times SCell addition is prevented for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.
${INCMP_DRB_STP_REL_SCELL_ATT_SA}    M55118C00034
# This counter measures the number of SCells to be released due to the addition of a CA-incompatible data radio bearer (DRB) in the PCell for SA.
${INCMP_DRB_STP_REL_SCELL_SUC_SA}    M55118C00035
#This counter measures the number of SCells released due to the addition of a CA-incompatible data radio bearer (DRB) in the PCell for SA.
${DL_RRC_FSCELL_REL_ATT_SA}    M55118C00042
#This counter measures the number of full SCell release attempts in DL in the PCell for SA. It considers only full SCell
#releases, partial SCell releases aren't counted. It considers both local SCells and ext-SCells.
${DL_RRC_FSCELL_REL_SUC_SA}    M55118C00043
#This counter measures the number of successful full SCell release attempts in DL in the PCell for SA. It considers only full
#SCell releases, partial SCell releases aren't counted. It considers both local SCells and ext-SCells.
${ELIGIBLE_DRB_REL_SCELL_ATT_SA}    M55118C00036
#This counter measures the number of SCells to be released due to the release of the last CA-eligible data radio bearer (DRB) in the PCell for SA.
${ELIGIBLE_DRB_REL_SCELL_SUC_SA}    M55118C00037
#This counter measures the number of SCells released due to the release of the last CA-eligible data radio bearer (DRB) in the PCell for SA.
${DL_RRC_1SCELL_REL_ATT_SA}    M55118C10503
#The number of DL 1 SCell Release attempts on PCell for SA
${DL_RRC_1SCELL_REL_SUC_SA}    M55118C10504
#The number of successful DL 1 SCell Release attempts on PCell for SA

${SA_Capa_3T3F}    SEPARATOR=
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

@{8311_enable}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=3
...    NRCELL:dlSCellConfigLevelNum=5
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRCELL:sCellInactivityReleaseTimer=10
...    NRBTS:drbRrcInactInactivityTimerSA=60

@{BC09_8225}
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:drbRrcInactInactivityTimerSA=6

@{BC09_recover}
...    NRBTS:actRrcInactState=none
...    delete:NRBTS:drbRrcInactInactivityTimerSA
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRBTS:actSCellReleaseForInactiveSCell=disabled
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1

@{BC09_sCellAdditionMethod_blind}
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRBTS:drbRrcInactInactivityTimerSA=6

@{5QI67_add}
...    Ue 81 PduId 1 Created FiveQi:Qfi mapping fiveQi 6 qfi 1
...    Ue 81 PduId 1 Created FiveQi:Qfi mapping fiveQi 7 qfi 2
...    a2-Threshold rsrp : 20
...    a3-Offset rsrp : 3
...    a1-Threshold rsrp : 70
...    QoS Routing Table
...    rrcReconfigurationComplete

@{3CC_scelladd_expect_UE81}
...    pcid:60, scellIdx:0
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    rrcReconfigurationComplete

@{Reestablishment_regexp}
...    RRC Reestablishment sucessfully completed
...    a1-Threshold rsrp : 70
...    rrcReconfigurationComplete

@{Reestablishment_without_A1_regexp}
...    RRC Reestablishment sucessfully completed
...    rrcReconfigurationComplete

@{DRB1_del}
...    reportConfigToRemoveList
...    Ue 81 PduId 1 Removed FiveQi:Qfi mapping fiveQi 6 qfi 1
...    QoS Routing Table
...    Pdu Session Resource Modify Response Message
...    rrcReconfigurationComplete

@{DRB1_add}
...    Added QosFlow with QFI:1 fiveQI:6
...    Ue 81 PduId 1 Created FiveQi:Qfi mapping fiveQi 6 qfi 1
...    a1-Threshold rsrp : 70
...    QoS Routing Table
...    rrcReconfigurationComplete

@{inter_HO_cell3}
...    pcid:52, scellIdx:0
...    Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.3 performed
...    rrcReconfigurationComplete

@{2CC_scelladd_expect_UE81}
...    pcid:52, scellIdx:0
...    pcid:60, scellIdx:1
...    rrcReconfigurationComplete

@{5QI68_add}
...    Ue 81 PduId 1 Created FiveQi:Qfi mapping fiveQi 6 qfi 1
...    Ue 81 PduId 1 Created FiveQi:Qfi mapping fiveQi 8 qfi 2
...    a2-Threshold rsrp : 20
...    a3-Offset rsrp : 3
...    QoS Routing Table
...    rrcReconfigurationComplete

@{DRB3_del}
...    Ue 81 PduId 1 Removed FiveQi:Qfi mapping fiveQi 8 qfi 2
...    QoS Routing Table
...    Pdu Session Resource Modify Response Message
...    rrcReconfigurationComplete

@{DRB3_add}
...    Added QosFlow with QFI:2 fiveQI:8
...    Ue 81 PduId 1 Created FiveQi:Qfi mapping fiveQi 8 qfi 2
...    QoS Routing Table
...    rrcReconfigurationComplete

@{UE_IN_INACTIVE_state}
...    Moving UE to NR_RRC_INACTIVE state
...    Is INACTIVE

@{5QI6_BC09}
...    Setup QosFlow with QFI:1 5QI:6
...    a1-Threshold rsrp : 70
...    QoS Routing Table

@{5QI7_BC09}
...    Setup QosFlow with QFI:1 5QI:7
...    QoS Routing Table

@{5QI8_BC09}
...    Setup QosFlow with QFI:1 5QI:8
...    QoS Routing Table

*** Test Cases ***
CB009059-ET-BC008_Interaction_with_RRC_Connection_Reestablishment
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:This user scenario describes CB009059 interaction with
    ...    the RRC Connection Reestablishment (5GC0000732) when the SCell Addition method is covBasedA1.
    ...    UE mobility cases when a CA is disallowed DRB configuration is established during the HO procedure.
    ...    incoming HO from LTE connected to ECP (5GC000711) when the SCell Addition method is blind.
    ...    incoming HO from LTE connected to ECP (5GC000711) when a CA is disallowed DRB configuration is established during the HO procedure.
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 1:Not FR1 CA eligible
    ...          UE81 3CC PCELL(cell-11) SCELLs(cell-1+cell-2)
    ...    2.Test Case Steps:
    ...     a.UE attaches to Cell11 and establishes 1 PDU session with DRB-1,DRB-2.A2,A3,A1 scell add configured.3CC add by A1,cell-1 and
    ...      cell-2 add as scell.DL Traffic for DRB-1 is on the PCell and SCells.DL Traffic for DRB-2 is only on the PCell.
    ...      UE reestablishment to cell11,A1 scell add configured.DL Traffic for DRB-1 and DRB-2 is on the PCell.
    ...     b.delete DRB-1 and add DRB-1,then 3CC add by A1,cell-1 and cell-2 add as scell.DL Traffic for DRB-1 is on the PCell and SCells.
    ...      DL Traffic for DRB-2 is only on the PCell.
    ...     c.Inter handover to cell3,then 2CC add by A1,cell-11 add as scell.UE reestablishment to cell11,A1 scell add configured.
    ...      DL Traffic for DRB-1 and DRB-2 is on the PCell.3CC add by A1,cell-1 and cell-2 add as scell.
    ...      DL Traffic for DRB-1 is on the PCell and SCells.DL Traffic for DRB-2 is only on the PCell.
    ...     d.UE attaches to Cell11 and establishes 1 PDU session with DRB-1,DRB-3.A2,A3 configured.A1 scell add not configured.
    ...      DL Traffic for DRB-1 and DRB-3 is on the PCell.UE reestablishment to cell11,A1 scell add not configured.
    ...      DL Traffic for DRB-1 and DRB-3 is on the PCell.
    ...     e.delete DRB-3, then 3CC add by A1, cell-1 and cell-2 add as scell.DL Traffic for DRB-1 is on the PCell and SCells.
    ...      Add DRB-3,A1 scell add not configured.DL Traffic for DRB-1 and DRB-3 is on the PCell.
    ...     f.Inter handover to cell3,A1 scell add not configured.DL Traffic for DRB-1 and DRB-3 is on the PCell.
    ...      UE reestablishment to cell11,A1 scell add not configured.DL Traffic for DRB-1 and DRB-3 is on the PCell.
    [Tags]    QC_347874    BC008    CA_LABEL-FTT(10Mhz_FDD_n71+60Mhz_TDD_n41+60Mhz_TDD_n41)
    clear counter files    wait=${False}
    UE attach to cell 11 with Not FR1 CA eligible DRB and scell add then RRCReestablish to the same cell    #step 1-3
    DRB1 delete DRB1 add then scell add    #step 4-6
    scell add after Inter handover then RRCReestablish to the same cell    #step 7-11
    UE attach to cell 11 with CA incompatible DRB and scell add then RRCReestablish to the other cell
    DRB3 delete DRB3 add then scell add
    scell add after Inter handover then RRCReestablish to the other cell with DRB3
    Check Counters    pm_counters_expression=${PM_Counters_BC008}

CB009059-ET-BC009_Interaction_with_RRC_Resume_procedure
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:This user scenario describes CB009059 interaction with the RRC Resume
    ...    procedure (CB008225) when the SCell Addition method is blind and buffer based SCell Addition is activated(CB008311).
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 1:Not FR1 CA eligible
    ...          UE81 3CC PCELL(cell-11) SCELLs(cell-1+cell-2)
    ...    2.Test Case Steps:(only DL can resume)
    ...     a.UE attaches to Cell11 and establishes 1 PDU session with DRB-1,DRB-2.A2,A3,A1 scell add configured.3CC add by A1,cell-1 and
    ...      cell-2 add as scell.DL Traffic for DRB-1 is on the PCell and SCells.DL Traffic for DRB-2 is only on the PCell.After stop traffic,
    ...      all DRBs and SRB inactivity timer is expired, UE is released to RRC_INACTIVE state.Then DL traffic send,gNB-CU-CP builds RRCResume
    ...      and UE relpy with RRCResumeComplete, A1 Scell addition measconfig to UE.3CC add by A1,cell-1 and cell-2 add as scell.
    ...      DL Traffic for DRB-1 is on the PCell and SCells.DL Traffic for DRB-2 is only on the PCell.
    ...     b.online set 8311 enable.UE attaches to Cell11 and establishes 1 PDU session with DRB-1.3CC add by A1,cell-1 and cell-2 add as scell.
    ...      After stop traffic,all DRBs and SRB inactivity timer is expired, UE is released to RRC_INACTIVE state.Then traffic send,gNB-CU-CP
    ...     builds RRCResume and UE relpy with RRCResumeComplete.3CC add by A1,cell-1 and cell-2 add as scell.
    ...     c.UE attaches to Cell11 and establishes 1 PDU session with DRB-2. After stop traffic,all DRBs and SRB inactivity timer is expired,UE
    ...     is released to RRC_INACTIVE state.Then traffic send,gNB-CU-CP builds RRCResume and UE relpy with RRCResumeComplete.A1 not configured.
    ...     d.online set NRCELL-11 sCellAdditionMethod as blind.UE attaches to Cell11 and establishes 1 PDU session with DRB-3.After stop traffic,
    ...     all DRBs and SRB inactivity timer is expired, UE is released to RRC_INACTIVE state.Then traffic send,gNB-CU-CP builds RRCResume and UE
    ...     relpy with RRCResumeComplete.A1 not configured.
    [Tags]    QC_347873    BC009    CA_LABEL-FTT(10Mhz_FDD_n71+60Mhz_TDD_n41+60Mhz_TDD_n41)
    OnlineParamChange    ${BC09_8225}
    clear counter files
    UE attach with Not FR1 CA eligible DRB and scell add then RRCResume with traffic then scell add    #step 1-5
    OnlineParamChange    ${8311_enable}
    UE attach only with CA eligible DRB and scell add then RRCResume with traffic then scell add
    UE attach only with Not FR1 CA eligible DRB and scell add then RRCResume with traffic then scell add
    OnlineParamChange    ${BC09_sCellAdditionMethod_blind}
    UE attach only with CA incompatible DRB and scell add then RRCResume with traffic then scell add
    Check Counters    pm_counters_expression=${PM_Counters_BC009}
    [Teardown]    case recover BC009

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/7cells_3T4F_8pipes

Modify Cfg
    Update Cfg    ue_param id=81,82 ue_nr_capabilities=${SA_Capa_3T3F} nr_usage_setting=voice_centric
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    Update Cfg    ue_nr_capabilities id=81 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosflow id=5 5qi=71 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3,4,5 qos_rules=1,2 default=on ue=1-6 amf=1

case recover BC009
    Release UEs    ue_type=all
    OnlineParamChange    ${BC09_recover}
    Common Test Teardown And Stop Capture Logs

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

UE PDU Session Setup with Qosflow
    [Arguments]    ${ue_id}=81    ${cell_id}=11    ${qos_id}=1    ${gw_id}=1    ${pass_regexp}=QoS Routing Table    ${fail_regexp}=none
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    ${set_ics_param}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${set_ics_param}
    Execute Egate Command    qosflow_modify qos_flow=${qos_id} default=on
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${gw_id} nwslice=1    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Execute Egate Command    smf_param id=1 reset

UE PDU Session Setup with multiple Qosflows
    [Arguments]    ${ue_id}=81    ${cell_id}=11    ${qos_id}=2    ${qos_id_default}=1    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    ${set_ics_param}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${set_ics_param}
    Execute Egate Command    qosflow_modify qos_flow=${qos_id_default} default=on
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${qos_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=${pass_regexp}
    Execute Egate Command    smf_param id=1 reset

Trigger ScellAdd
    [Arguments]    ${carrierfreq}=127450    ${srsrp_nr}=90    ${srsrq_nr}=70    ${ue_id}=81    ${pass_regexp}=rrcReconfigurationComplete
    ...    ${fail_regexp}=none
    ${meas_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

Send Throughput
    [Arguments]    ${ue_id}=81    ${times}=5    ${pdu}=1    ${qfi}=1
    FOR    ${I}    IN RANGE    1    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=170 trf_id=${I}    UE ${ue_id}: UDP DL
    END
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL

Check Traffic
    [Arguments]     ${ue_id}=81    ${cell_num}=2    ${dl}=600    ${ul}=8
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    Throughput
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}+1
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 0
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${dl}
    Should Be True    ${ul_throuput}/1000 > ${ul}

Verify Throughput pcell
    [Arguments]     ${ue_id}=81    ${dl}=60    ${ul}=8
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    Throughput
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${dl_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=1-11 type=pdsch    fail_regexp=CellIndex-
    Should Be True    ${dl_tput}/1000 > ${dl}
    Should Be True    ${ul_throuput}/1000 > ${ul}

Stop traffic
    [Arguments]    ${ue_id}=81    ${pdu}=1    ${pass_regexp}=Stopped Downlink Internal traffic
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu}    pass_regexp=${pass_regexp}

Check CA Traffic for different DRB
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${cell_num}=2    ${dl}=600    ${pass_regexp}=Stopped Downlink Internal traffic
    ...    ${times}=5
    Send Throughput    ue_id=${ue_id}    times=${times}    pdu=${pdu_id}    qfi=${qfi_id}
    Wait Until Keyword Succeeds    40s    5s    Check Traffic    ue_id=${ue_id}    cell_num=${cell_num}    dl=${dl}
    Wait Until Keyword Succeeds    80s    5s    Stop traffic    ue_id=${ue_id}    pdu=${pdu_id}    pass_regexp=${pass_regexp}

Check Pcell Traffic for different DRB
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${dl}=60    ${pass_regexp}=Stopped Downlink Internal traffic
    Send Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}
    Wait Until Keyword Succeeds    1min    5s    Verify Throughput pcell    ue_id=${ue_id}    dl=${dl}
    Wait Until Keyword Succeeds    80s    5s    Stop traffic    ue_id=${ue_id}    pdu=${pdu_id}    pass_regexp=${pass_regexp}

Check CA Traffic only in Pcell for different DRB
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${cell_num}=2    ${dl}=60
    ...    ${times}=5
    Send Throughput    ue_id=${ue_id}    times=${times}    pdu=${pdu_id}    qfi=${qfi_id}
    Wait Until Keyword Succeeds    40s    5s    Check CA exsit but Traffic only in Pcell    ue_id=${ue_id}    cell_num=${cell_num}    dl=${dl}
    Stop traffic    ue_id=${ue_id}    pdu=${pdu_id}

Check CA exsit but Traffic only in Pcell
    [Arguments]     ${ue_id}=81    ${cell_num}=2    ${dl}=60    ${ul}=8
    ${scell_t}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    Throughput
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    0    pdsch
    ${total_dl_tput}    Set Variable    ${scell_tput}
    FOR    ${index}    IN RANGE    1    ${cell_num}+1
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 == 0
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${dl}
    Should Be True    ${ul_throuput}/1000 > ${ul}

Trigger reestablishment
    [Arguments]    ${ue_id}=81    ${cell_id}=11    ${pass_regexp}=RRC Reestablishment sucessfully completed
    ${cmd}=    Set Variable    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=reconfigurationFailure
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    Check Pcell Traffic for different DRB    qfi_id=1
    Check Pcell Traffic for different DRB    qfi_id=2

ADD QOS in same pdu
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qos_id}=4    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}

Delete QOS in same pdu
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qos_id}=3    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}

Inter handover to cell3
    [Arguments]    ${ue_id}=81    ${cellfreq}=127450    ${cellfreq2}=632736    ${pass_regexp}=rrcReconfigurationComplete
    ${A2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A2} event=A2 srsrp_nr=5
    ...    pass_regexp=rrcReconfigurationComplete
    ${A3}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq2}    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A3} event=A3 srsrp_nr=5 srsrq_nr=11 phycell_id=52 nrsrp_nr=90 nrsrq_nr=80
    ...    pass_regexp=${pass_regexp}
    Check Pcell Traffic for different DRB    qfi_id=1    dl=600
    Check Pcell Traffic for different DRB    qfi_id=2    dl=600

UE attach to cell 11 with Not FR1 CA eligible DRB and scell add then RRCReestablish to the same cell
    UE PDU Session Setup with multiple Qosflows    cell_id=11    qos_id=2    pass_regexp=${5QI67_add}
    Check Pcell Traffic for different DRB    qfi_id=1
    Check Pcell Traffic for different DRB    qfi_id=2
    Trigger ScellAdd    pass_regexp=${3CC_scelladd_expect_UE81}
    Check CA Traffic only in Pcell for different DRB    qfi_id=2
    Check CA Traffic for different DRB    qfi_id=1
    Trigger reestablishment    cell_id=11    pass_regexp=${Reestablishment_regexp}

DRB1 delete DRB1 add then scell add
    Delete QOS in same pdu    qos_id=1    pass_regexp=${DRB1_del}    #step 4
    Check Pcell Traffic for different DRB    qfi_id=2
    ADD QOS in same pdu    qos_id=1    pass_regexp=${DRB1_add}
    Check Pcell Traffic for different DRB    qfi_id=1
    Check Pcell Traffic for different DRB    qfi_id=2
    Trigger ScellAdd    pass_regexp=${3CC_scelladd_expect_UE81}
    Check CA Traffic only in Pcell for different DRB    qfi_id=2
    Check CA Traffic for different DRB    qfi_id=1

scell add after Inter handover then RRCReestablish to the same cell
    Inter handover to cell3    pass_regexp=${inter_HO_cell3}    #step 7,8
    Trigger ScellAdd    carrierfreq=632736    pass_regexp=${2CC_scelladd_expect_UE81}    #cell3 A1 scell add
    Check CA Traffic for different DRB    cell_num=1    qfi_id=1    dl=1000    times=8
    Check CA Traffic only in Pcell for different DRB    cell_num=1    qfi_id=2    dl=1000    times=8
    Trigger reestablishment    cell_id=11    pass_regexp=${Reestablishment_regexp}    #step 10
    Trigger ScellAdd    pass_regexp=${3CC_scelladd_expect_UE81}
    Check CA Traffic only in Pcell for different DRB    qfi_id=2
    Check CA Traffic for different DRB    qfi_id=1
    UE Deregister From gNB

UE attach to cell 11 with CA incompatible DRB and scell add then RRCReestablish to the other cell
    UE PDU Session Setup with multiple Qosflows    cell_id=11    qos_id=3    pass_regexp=${5QI68_add}
    Check Pcell Traffic for different DRB    qfi_id=1
    Check Pcell Traffic for different DRB    qfi_id=2
    ${measure_config}    Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr    ReportCfgId
    should not contain    ${measure_config}    EventA1
    Trigger reestablishment    cell_id=11    pass_regexp=${Reestablishment_without_A1_regexp}
    ${measure_config}    Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr    ReportCfgId
    should not contain    ${measure_config}    EventA1

DRB3 delete DRB3 add then scell add
    Delete QOS in same pdu    qos_id=3    pass_regexp=${DRB3_del}
    Check Pcell Traffic for different DRB    qfi_id=1
    Trigger ScellAdd    pass_regexp=${3CC_scelladd_expect_UE81}
    Check CA Traffic for different DRB    qfi_id=1
    ADD QOS in same pdu    qos_id=3    pass_regexp=${DRB3_add}
    ${measure_config}    Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr    ReportCfgId
    should not contain    ${measure_config}    EventA1
    Check Pcell Traffic for different DRB    qfi_id=1
    Check Pcell Traffic for different DRB    qfi_id=2

scell add after Inter handover then RRCReestablish to the other cell with DRB3
    Inter handover to cell3    pass_regexp=${inter_HO_cell3}    #step 7,8
    ${measure_config}    Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr    ReportCfgId
    should not contain    ${measure_config}    EventA1
    Trigger reestablishment    cell_id=11    pass_regexp=${Reestablishment_without_A1_regexp}    #step 10
    ${measure_config}    Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr    ReportCfgId
    should not contain    ${measure_config}    EventA1
    UE Deregister From gNB

UE attach with Not FR1 CA eligible DRB and scell add then RRCResume with traffic then scell add
    UE PDU Session Setup with multiple Qosflows    qos_id=2    pass_regexp=${5QI67_add}
    Trigger ScellAdd    pass_regexp=${3CC_scelladd_expect_UE81}
    Check CA Traffic only in Pcell for different DRB    qfi_id=2
    Check CA Traffic for different DRB    qfi_id=1    pass_regexp=${UE_IN_INACTIVE_state}
    Send Throughput    qfi=2
    Trigger ScellAdd    pass_regexp=${3CC_scelladd_expect_UE81}
    Check CA Traffic only in Pcell for different DRB    qfi_id=2
    Check CA Traffic for different DRB    qfi_id=1
    UE Deregister From gNB

UE attach only with CA eligible DRB and scell add then RRCResume with traffic then scell add
    UE PDU Session Setup with Qosflow    qos_id=1    pass_regexp=${5QI6_BC09}
    Trigger ScellAdd    pass_regexp=measurementReport    fail_regexp=${3CC_scelladd_expect_UE81}
    Check CA Traffic for different DRB    qfi_id=1    pass_regexp=${UE_IN_INACTIVE_state}
    Send Throughput    qfi=1
    Trigger ScellAdd    pass_regexp=${3CC_scelladd_expect_UE81}
    Check CA Traffic for different DRB    qfi_id=1
    UE Deregister From gNB

UE attach only with Not FR1 CA eligible DRB and scell add then RRCResume with traffic then scell add
    UE PDU Session Setup with Qosflow    qos_id=2    pass_regexp=${5QI7_BC09}    fail_regexp=a1-Threshold rsrp : 70
    Check Pcell Traffic for different DRB    qfi_id=1    pass_regexp=${UE_IN_INACTIVE_state}
    Send Throughput    qfi=1
    ${measure_config}    Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr    ReportCfgId
    should not contain    ${measure_config}    EventA1
    Check Pcell Traffic for different DRB    qfi_id=1
    UE Deregister From gNB

UE attach only with CA incompatible DRB and scell add then RRCResume with traffic then scell add
    UE PDU Session Setup with Qosflow    qos_id=3    pass_regexp=${5QI8_BC09}    fail_regexp=a1-Threshold rsrp : 70
    Check Pcell Traffic for different DRB    qfi_id=1    pass_regexp=${UE_IN_INACTIVE_state}
    Send Throughput    qfi=1
    Check Pcell Traffic for different DRB    qfi_id=1
    UE Deregister From gNB
