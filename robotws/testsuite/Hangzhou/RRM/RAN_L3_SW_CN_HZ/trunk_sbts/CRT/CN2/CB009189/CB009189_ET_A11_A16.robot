*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-kexin.bao
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD     CRT    CB009189    release-SBTS23R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthUl:cRbStartUl=crb0
...    @{2271_related_modification}
...    @{9189_related_modification}
...    @{HO_flag}
...    @{NRCELL13_configuration}
...    @{NRCELL1_2_configuration}
...    @{NRCELL11_configuration}
...    @{5QI_4_configuration}
...    @{CA_flag}

@{2271_related_modification}
...    NRCELL:actAdaptiveSr=true
...    NRCELL:adaptiveSrBlockingMinimization=20
...    NRCELL:adaptiveSrLoadThresholdDown=50
...    NRCELL:adaptiveSrLoadThresholdUp=80
...    NRCELL:srPeriodicityMin=slots20
...    NRCELL:srPeriodicity=slots40
...    NRCELL-1:srPeriodicity=slots80
...    NRCELL-2:srPeriodicityMin=slots10
...    NRCELL-1:srPeriodicityMin=slots40
...    NRCELL:vonrReservation=30
...    NRCELL-1:preferredVoNrSrPeriod=slots40
...    NRCELL-2:preferredVoNrSrPeriod=slots40
...    NRCELL-11:preferredVoNrSrPeriod=slots20
...    NRCELL-12:preferredVoNrSrPeriod=slots20
...    NRCELL-13:preferredVoNrSrPeriod=slots40
...    NRCELL-14:preferredVoNrSrPeriod=slots20
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true

@{9189_related_modification}
...    NRCELL:actServiceAwareConfig=true
#5qi=4
...    NRBTS/NRDRB-17:srPeriodicityDrb=80ms
...    NRBTS/NRDRB-17:payloadSizeSRDrb=500
#5qi=6
...    NRBTS/NRDRB-11:srPeriodicityDrb=10ms
...    NRBTS/NRDRB-11:payloadSizeSRDrb=300
#5qi=7
...    NRBTS/NRDRB-12:srPeriodicityDrb=5ms
...    NRBTS/NRDRB-12:payloadSizeSRDrb=100

@{HO_flag}
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
@{CA_flag}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:sCellActivationMethod=blind
#for blind
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{NRCELL13_configuration}
...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=424000
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=344000
...    NRCELL-13:gscnOrSsPbchArfcn=5300
...    NRCELL-13:a3MeasEnabled=rsrp
...    NRCELL-13:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-13:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
...    NRCELL-13:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-13:absThreshSsbRsrpConsolidation=0
...    NRCELL-13:measGapSelectionSA=favourUeThroughput
...    NRCELL-13:sMeasConfigSsbRsrp=0
...    NRCELL-13/NRREL-10:lcrId=11

@{NRCELL1_2_configuration}
...    NRCELL-1:gscnOrSsPbchArfcn=6351
...    NRCELL-1:nrarfcn=508020
...    NRCELL-2:gscnOrSsPbchArfcn=6549
...    NRCELL-2:nrarfcn=524310
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-1:actK1Opt=intra-gNB

...    NRCELL-2:actK1Opt=intra-gNB

@{NRCELL11_configuration}
...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
...    NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-11:absThreshSsbRsrpConsolidation=0
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=20
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=70
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=50
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=40
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=26
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=80
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-11:sMeasConfigSsbRsrp=0
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:lcrId=13
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:nrDcAllowed=false
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
#NRCELL-1
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms80
...    NRCELL-11/NRHOIF-1:cellDepType=SA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssbFrequency=508110
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20

@{5QI_4_configuration}
...    NRCELL:actNonVoNRGbrService=true
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=4
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
...    NRBTS/NRDRB-17:actDddsReduction=false
...    NRBTS/NRDRB-17:actLostPduFastRetx=false
...    NRBTS/NRDRB-17:discardTimer=300ms
...    NRBTS/NRDRB-17:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-17:dscp=28
...    NRBTS/NRDRB-17:l2OHFactorDl=16
...    NRBTS/NRDRB-17:l2OHFactorUl=35
...    NRBTS/NRDRB-17:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-17:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-17:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-17:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-17:maxTransferDelayGbr=20
...    NRBTS/NRDRB-17:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-7
...    NRBTS/NRDRB-17:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-17:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-17:numSduDiscard=1
...    NRBTS/NRDRB-17:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS/NRDRB-17:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-17:resType=GBR
...    NRBTS/NRDRB-17:rlcMode=RLC_AM
...    NRBTS/NRDRB-17:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-17:nsaDrbParam=${EMPTY}
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-5:schedulBSD=50ms
...    NRBTS/NRDRB_MAC-5:schedulPrio=4
...    NRBTS/NRDRB_MAC-7:delayTarget=50
...    NRBTS/NRDRB_MAC-7:lcgid=5
...    NRBTS/NRDRB_MAC-7:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-7:schedulBSD=5ms
...    NRBTS/NRDRB_MAC-7:schedulPrio=7

${rdSrLoadThredsholdFactor}    0x59015B

@{PARAMS_IN_SWCONFIG}
...    ${rdSrLoadThredsholdFactor}=1

${UE_Capa_For_ca_n41_n41}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1
...    A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F
...    604F88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F
...    40CFB027C639F30C7942C0E070F05C00FFC007003FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CF
...    A8E7CC31E50B0381C3C27FFC00001FFF00000130000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E20800003
...    0B02B0F0A00038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E1400070A000003058158B89A001C4100
...    0E140000040B02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C410
...    00E230000020B02B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B0104
...    3D02EC1F0A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C
...    73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A098
...    01E00140E0A00E0601280380030120020301F0480100000000800001004000000020000040100000400800003004000020020000140100
...    0802008020000180100000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B0
...    32B066B056B296B266B016B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA48
...    0800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174
...    AA2A82C55058AA0D154A62A93455018AA051549AAA83C5090178095028140A05028140A05028140A05028140A050281400182020180300
...    801002101002008040300610080100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C018
...    20200401008010043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

@{PM_Counters_Check_A16}
...    NRBTS-1:NSL:${ATT_IF_GNB_INTRA_DU_HO_SLICE}=1
...    NRBTS-1:NSL:${SUCC_IF_GNB_INTRA_DU_HO_SLICE}=1
...    NRCELL-1:NRANS:${ATT_IF_INTRA_DU_HO_SA_PLMN}=0
...    NRCELL-1:NRANS:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=0
...    NRCELL-1:NRUC:${SR_SLOT20_POOL_AS_MAIN}=0
...    NRCELL-1:NRUC:${SR_SLOT40_POOL_AS_MAIN}>0
...    NRCELL-1:NRUC:${MAIN_POOL_CHANGED_TO_LONGER}>0
...    NRCELL-1:NRUC:${MAX_VOICE_OUT_OF_PREF_SR_POOL}=1
...    NRCELL-1:NRUC:${SUM_VOICE_OUT_OF_PREF_SR_POOL}>0
...    NRCELL-1:NRUC:${SUM_USED_RES_SS_SR_SLOT10}>10
...    NRCELL-1:NRUC:${NUM_SS_SR_10SLOT_PERIOD_REQ}=1
...    NRCELL-1:NRUC:${NUM_SS_SR_10SLOT_PERIOD_SUC}=1
...    NRCELL-1:NRUC:${SUM_USED_RES_SS_SR_SLOT5}=0
...    NRCELL-1:NRUC:${SUM_USED_RES_SS_SR_SLOT20}>8
...    NRCELL-11:NRANS:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-11:NRANS:${ATT_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-11:NRUC:${SR_SLOT20_POOL_AS_MAIN}>0
...    NRCELL-11:NRUC:${SR_SLOT40_POOL_AS_MAIN}>0
...    NRCELL-11:NRUC:${MAIN_POOL_CHANGED_TO_LONGER}>0
...    NRCELL-11:NRUC:${MAX_VOICE_OUT_OF_PREF_SR_POOL}=1
...    NRCELL-11:NRUC:${SUM_VOICE_OUT_OF_PREF_SR_POOL}>0
...    NRCELL-11:NRUC:${SUM_USED_RES_SS_SR_SLOT5}>10
...    NRCELL-11:NRUC:${NUM_SS_SR_5SLOT_PERIOD_REQ}=1
...    NRCELL-11:NRUC:${NUM_SS_SR_5SLOT_PERIOD_SUC}=1
...    NRCELL-11:NRUC:${SUM_USED_RES_SS_SR_SLOT10}=0
...    NRCELL-11:NRUC:${SUM_USED_RES_SS_SR_SLOT20}=0
...    NRCELL-11:NRUC:${SUM_USED_RES_SS_SR_SLOT40}=0

${SR_SLOT20_POOL_AS_MAIN}    M55165C00009
#The counter indicates how often slot20 SR pool is the main pool.
${SR_SLOT40_POOL_AS_MAIN}    M55165C00010
#The counter indicates how often slot40 SR pool is the main pool.
${MAIN_POOL_CHANGED_TO_LONGER}    M55165C00013
#The counter indicates how often the main pool has been upgraded to the SR pool with longer SR period from the prior pool.
${MAX_VOICE_OUT_OF_PREF_SR_POOL}    M55165C00028
#The maximum number of resources used by UEs with VoNR in the pools with different SR periods than the preferred one (configured for voice).
${SUM_VOICE_OUT_OF_PREF_SR_POOL}    M55165C00029
#The sum of SR resources used by UEs with VoNR in the pools with different SR periods than the preferred one (configured for voice).
${SUM_USED_RES_SS_SR_SLOT5}    M55165C00501
#This counter provides the sum of slot5 SR resources used by service-specific SR.
${SUM_USED_RES_SS_SR_SLOT10}    M55165C00502
#This counter provides the sum of slot10 SR resources used by service-specific SR.
${SUM_USED_RES_SS_SR_SLOT20}    M55165C00503
#This counter provides the sum of slot20 SR resources used by service-specific SR.
${SUM_USED_RES_SS_SR_SLOT40}    M55165C00504
#This counter provides the sum of slot40 SR resources used by service-specific SR.
${NUM_SS_SR_5SLOT_PERIOD_SUC}    M55165C00507
#This counter provides the number of service-specific SR periodicity requests for 5 Slots, which are successfully admitted
${NUM_SS_SR_10SLOT_PERIOD_SUC}    M55165C00508
#This counter provides the number of service-specific SR periodicity requests for 10 Slots, which are successfully admitted
${NUM_SS_SR_5SLOT_PERIOD_REQ}    M55165C00513
#This counter provides the number of service-specific SR periodicity requests for 5 Slots.
${NUM_SS_SR_10SLOT_PERIOD_REQ}    M55165C00514
#This counter provides the number of service-specific SR periodicity requests for 10 Slots.
${ATT_IF_INTRA_DU_HO_SA_PLMN}    M55145C00321
#When RRC Reconfiguration message is sent by the gNBto UE for Intra-gNBIntra-DU HO, which indicates a Handover Command to the UE.
${SUCC_IF_INTRA_DU_HO_SA_PLMN}    M55145C00322
#The number of successful inter-frequency intra-DU HO executions for SA per PLMN-ID
${ATT_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00550
#Attempted Inter-Frequency Intra-gNBIntra-DU HO per PLMN, per slice
${SUCC_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00551
#Successful Inter-Frequency Intra-gNBIntra-DU HO, per PLMN, per slice

*** Test Cases ***
CB009189-ET-A11_SA_FDD_DRBsl40_2ndpool_add_VONRsl20_add_9189DRBsl80_intrafreq_intraDU_intragNB_HO_A3
    [Documentation]
    ...    1. This user scenario describes Intra-frequency Intra-DU Intra-gNB handover to target cell after
    ...    successfully configure periodicity and possibly grant size for Scheduling Request per DRB profile.
    ...    2. Configuration
    ...    5GC002271 feature is enabled,and CB009189 flag is enabled.
    ...    A3 is configured for NRCELL-11.
    ...    3. Test Case Steps:
    ...    a.UE register, and check SR period selection.
    ...    b.setup VONR and 9189 DRB,check SR period selection.
    ...    c.send A3 measurement, then intrafreq intraDU HO successfully,and check SR period selection.
    ...    d.delete VONR, check SR period selection.
    ...    e.UE deregister.
    [Tags]    QC_221962    owner-kexin.bao
    UE Attach To Target Cell    ue_id=81    cell_id=11    regexp=periodicityAndOffset sl40
    Setup VONR And GBR Bearer Before HO A11    ue_id=81
    Trigger A3 HO    ue_id=81    carrierfreq=424090    sleep_time=2s    phycell_id=62
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.13    regexp=periodicityAndOffset sl40
    Bearer Operation After HO A11    ue_id=81
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189A011${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB009189-ET-A16_SA_F_T_CA_DRBsl40_2ndpool_add_9189DRBsl5_VONRsl20_Interfreq_intraDU_intragNB_HO_A3_T_T
    [Documentation]
    ...    1. This user scenario describes Inter-frequency Intra-DU Intra-gNB handover to target cell after
    ...    successfully configure periodicity and possibly grant size for Scheduling Request per DRB profile.
    ...    2. Configuration
    ...    5GC002271 feature is enabled,and CB009189 flag is enabled.
    ...    A3 is configured for NRCELL-1.
    ...    3. Test Case Steps:
    ...    a.UE register, and check SR period selection.
    ...    b.setup VONR and 9189 DRB,check SR period selection.
    ...    c. send A1 measurement to add scell F+T.
    ...    d.send A3 measurement, then interfreq intraDU HO successfully,check scell and check SR period selection.
    ...    e.add and delete 9189 DRB, check SR period selection.
    ...    f.UE deregister.
    [Tags]    QC_221961    owner-kexin.bao
    Update UE capa    ue_id=81    SA_Capa_perUE_Full=${UE_Capa_For_ca_n41_n41}
    Clear Counter Files
    UE Attach To Target Cell    ue_id=81    cell_id=11    regexp=periodicityAndOffset sl40
    Setup VONR And GBR Bearer Before HO A16    ue_id=81
    Trigger A1 To Add Scell    ue_id=81    carrierfreq=424090    regexp=sCellIndex 1
    Trigger Measurement to HO    ue_id=81    carrierfreq1=424090    carrierfreq2=508110    phycell_id=50
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.1    regexp=periodicityAndOffset sl10
    Bearer Operation After HO A16    ue_id=81
    UE Deregister From gNB    ue_id=81
    Log Check
    Check Counters    ${PM_Counters_Check_A16}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8 default=on

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}    ${regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    ${regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=1    send_dl=10    send_ul=5    sleep_time=10s

Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}=81    ${qfi}=1    ${send_dl}=70    ${send_ul}=10    ${sleep_time}=10s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=${qfi} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=${qfi} dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${qfi}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger A1 To Add Scell
    [Arguments]    ${ue_id}    ${carrierfreq}    ${regexp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=70
    Execute Egate Command    ${cmd}    pass_regexp=${regexp}
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=4    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=2    Tput_dl=9    Tput_ul=4    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=3    Tput_dl=9    Tput_ul=4    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=4    Tput_dl=9    Tput_ul=4    sleep_time=2s

Trigger A3 HO
    [Arguments]    ${ue_id}    ${carrierfreq}    ${sleep_time}    ${phycell_id}    ${pass_regexp}    ${regexp}
    sleep    ${sleep_time}    sleep for A3 MR
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=70
    ...    phycell_id=${phycell_id} nrsrp_nr=80
    ${retvalue}    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    Should Contain    ${retvalue}    ${regexp}
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=4    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=2    Tput_dl=9    Tput_ul=4    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=3    Tput_dl=9    Tput_ul=4    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=4    Tput_dl=9    Tput_ul=4    sleep_time=2s

Trigger Measurement to HO
    [Arguments]    ${ue_id}    ${carrierfreq1}    ${carrierfreq2}    ${phycell_id}    ${pass_regexp}    ${regexp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq1}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=70 srsrq_nr=70    eventId eventA3
    Trigger A3 HO    ue_id=${ue_id}    carrierfreq=${carrierfreq2}    sleep_time=2s    phycell_id=${phycell_id}
    ...    pass_regexp=${pass_regexp}    regexp=${regexp}

Setup VONR And GBR Bearer Before HO A11
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=5 by=amf    pass_regexp=Created FiveQi:Qfi mapping fiveQi 5
    Send And Verify Throuput    ue_id=${ue_id}    qfi=2    send_dl=10    send_ul=5    sleep_time=10s
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=1 by=amf    pass_regexp=periodicityAndOffset sl20
    Send And Verify Throuput    ue_id=${ue_id}    qfi=3    send_dl=10    send_ul=5    sleep_time=10s
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=4 by=amf    pass_regexp=Created FiveQi:Qfi mapping fiveQi 4
    Send And Verify Throuput    ue_id=${ue_id}    qfi=4    send_dl=10    send_ul=5    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=4    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=2    Tput_dl=9    Tput_ul=4    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=3    Tput_dl=9    Tput_ul=4    sleep_time=2s

Bearer Operation After HO A11
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=1 by=amf    Deleted QoSFlow with QFI 3
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=4    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=2    Tput_dl=9    Tput_ul=4    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=4    Tput_dl=9    Tput_ul=4    sleep_time=2s

Setup VONR And GBR Bearer Before HO A16
    [Arguments]    ${ue_id}
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=7 by=amf
    ...    pass_regexp=Added QosFlow with QFI:2 5QI:7
    should contain    ${retvalue}    periodicityAndOffset sl5
    Send And Verify Throuput    ue_id=${ue_id}    qfi=2    send_dl=10    send_ul=5    sleep_time=10s
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=5 by=amf    pass_regexp=Added QosFlow with QFI:3 5QI:5
    Send And Verify Throuput    ue_id=${ue_id}    qfi=3    send_dl=10    send_ul=5    sleep_time=10s
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=1 by=amf    pass_regexp=Added QosFlow with QFI:4 5QI:1
    Send And Verify Throuput    ue_id=${ue_id}    qfi=4    send_dl=10    send_ul=5    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=4    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=2    Tput_dl=9    Tput_ul=4    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=3    Tput_dl=9    Tput_ul=4    sleep_time=2s

Bearer Operation After HO A16
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=6 by=amf    pass_regexp=Added QosFlow with QFI:5 5QI:6
    Send And Verify Throuput    ue_id=${ue_id}    qfi=5    send_dl=10    send_ul=5    sleep_time=10s
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=7 by=amf    pass_regexp=periodicityAndOffset sl20
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=4    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=3    Tput_dl=9    Tput_ul=4    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=4    Tput_dl=9    Tput_ul=4    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=5    Tput_dl=9    Tput_ul=4    sleep_time=2s

Log Check
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189A016${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check RRC log    ${CURDIR}${/}a2a_CB009189A016${/}a2a.ini
