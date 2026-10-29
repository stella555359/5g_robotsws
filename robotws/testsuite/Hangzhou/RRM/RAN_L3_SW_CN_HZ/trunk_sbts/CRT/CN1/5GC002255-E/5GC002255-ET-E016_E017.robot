*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  RAN_5G_FDD  CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD  team-DevHZ5_SG2
...  owner-keyun.ma  release-5G21A    5GC002255
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NRARFCN127180}    127210    #cell12 ssbfreq
${NRARFCN508020}    508110    #cell3 ssbfreq
${NRARFCN526020}    526590    #cell4 ssbfreq
${NRARFCN424000}    424090    #cell11 ssbfreq
@{PARAMS_IN_SCF}
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=134980
...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127180
...    NRCELL-12:freqBandIndicatorNR=71
...    NRCELL-12:gscnOrSsPbchArfcn=1589
...    NRBTS-1:srb3SupportEnabled=false
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actIntraFreqHoSA=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-12:a1MeashoEnabledSA=rsrp
...    NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-12:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    delete:NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr
...    delete:NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr
...    NRCELL-12:a2MeashoEnabledSA=rsrp
...    NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-12:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-12:actCDrx=true

...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    delete:NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr
...    delete:NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-11:actCDrx=false

...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1

...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:lcrId=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-12:gNbId=1
...    NRCELL-11/NRREL-12:gNbIdLength=22
...    NRCELL-11/NRREL-12:lcrId=12
...    NRCELL-11/NRREL-12:removeNotAllowed=false
...    NRCELL-11/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-12:gnbPlmn:mncLength=3

...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:lcrId=3
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3

...    NRCELL-12/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-11:gNbId=1
...    NRCELL-12/NRREL-11:gNbIdLength=22
...    NRCELL-12/NRREL-11:lcrId=11
...    NRCELL-12/NRREL-11:removeNotAllowed=false
...    NRCELL-12/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-11:gnbPlmn:mncLength=3

...    NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:cellDepType=SA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:scs=15 KHz
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:ssbFrequency=${NRARFCN424000}
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:cellDepType=SA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:scs=15 KHz
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:ssbFrequency=${NRARFCN127180}
...    NRCELL-2:fPdcchMonOccsnPo=0
...    NRCELL-4:fPdcchMonOccsnPo=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=30
@{Deltacommission16}
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
@{Deltacommission17}
...    NRCELL-4:measGapSelection=favourUeThroughput
...    NRCELL-4:ifhoSsbSmtcOffset=0
...    NRCELL-4:a1MeashoEnabledSA=rsrp
...    NRCELL-4:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-4:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-4:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    delete:NRCELL-4:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr
...    delete:NRCELL-4:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr
...    NRCELL-4:a2MeashoEnabledSA=rsrp
...    NRCELL-4:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-4:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-4:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-4:actCDrx=false
...    NRCELL-4/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-12:gNbId=1
...    NRCELL-4/NRREL-12:gNbIdLength=22
...    NRCELL-4/NRREL-12:lcrId=12
...    NRCELL-4/NRREL-12:removeNotAllowed=false
...    NRCELL-4/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-4/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-4/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-4/NRHOIF-1:cellDepType=SA
...    NRCELL-4/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-4/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-4/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-4/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-4/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-4/NRHOIF-1:scs=15 KHz
...    NRCELL-4/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-4/NRHOIF-1:ssbFrequency=${NRARFCN127180}
...    NRCELL-4/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-4/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-4/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-4/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-4/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-4/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=10
...    NRCELL-4/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=30
...    NRCELL-4/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=55
...    NRCELL-4/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:cellDepType=SA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:scs=30 KHz
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:ssbFrequency=${NRARFCN526020}
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=10
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=30
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=55
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0
...    NRCELL-12/NRREL-11:gNbId=1
...    NRCELL-12/NRREL-11:lcrId=4
${ATT_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00550   #	The number of Inter-Frequency Intra-gNB Intra-DU HOs attempted for the given slice and PLMN
${SUCC_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00551   #The number of Inter-Frequency Intra-gNB Intra-DU HOs successful for the given slice and PLMN
${ATT_IF_INTRA_DU_HO_SA_PLMN}    M55145C00321  #The number of inter-frequency intra-DU HO execution attempts for SA per PLMN-ID
${SUCC_IF_INTRA_DU_HO_SA_PLMN}    M55145C00322  #The number of successful inter-frequency intra-DU HO executions for SA per PLMN-ID
@{PM_Counters_List16}
...    NRBTS-1/MCC-311/MNC-489:${ATT_IF_GNB_INTRA_DU_HO_SLICE}=6
...    NRBTS-1/MCC-311/MNC-489:${SUCC_IF_GNB_INTRA_DU_HO_SLICE}=6
...    NRCELL-11/MCC-311/MNC-489:${ATT_IF_INTRA_DU_HO_SA_PLMN}=3
...    NRCELL-11/MCC-311/MNC-489:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=3
...    NRCELL-12/MCC-311/MNC-489:${ATT_IF_INTRA_DU_HO_SA_PLMN}=3
...    NRCELL-12/MCC-311/MNC-489:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=3
@{PM_Counters_List17}
...    NRBTS-1/MCC-311/MNC-489:${ATT_IF_GNB_INTRA_DU_HO_SLICE}=6
...    NRBTS-1/MCC-311/MNC-489:${SUCC_IF_GNB_INTRA_DU_HO_SLICE}=6
...    NRCELL-4/MCC-311/MNC-489:${ATT_IF_INTRA_DU_HO_SA_PLMN}=3
...    NRCELL-4/MCC-311/MNC-489:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=3
...    NRCELL-12/MCC-311/MNC-489:${ATT_IF_INTRA_DU_HO_SA_PLMN}=3
...    NRCELL-12/MCC-311/MNC-489:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=3
${SOS_REPORT_FLAG}     pass:True,fail:True
${DEBUG_LOG_LEVEL}    0

${GNB_BIP_FLAG}    True
*** Test Cases ***
5GC002255-ET-E016_Verify_SA_A3_rsrp_Interfreq_IntragNB_HO_success_from_CA_to_FDD_with_perFR1_meas_Gap
    [Documentation]    This case will test A3 rsrp inter-Freq, IntragNB HO from CA to FDD with perFR1 measurement gap
    ...    Case steps:
    ...    1.Setup CA successfully,set source cell(CA) drx ON,set target cell drx False
    ...    2.Trigger A2 measurement report
    ...    3.Trigger A3 measurement report to HO to FDD
    ...    4.Trigger A3 to handover to real GNB FDD+TDD check traffic
    [Tags]    E016    QC_83625
    clear counter files
    delta commission parameters    ${Deltacommission16}
    Attach UE for waiting L3 call OK
    Trigger Inter A3 HO Loop three times
    Verify Throughput
    Ue Deregister
    Check Wireshark Log    ${CURDIR}${/}a2a_16${/}a2a.ini    wait_string=UEContextRelease
    check counters    ${PM_Counters_List16}

5GC002255-ET-E017_Verify_SA_A5_rsrp_Interfreq_IntragNB_HO_success_from_CA_to_TDD_with_perFR1_meas_Gap
    [Documentation]    The purpose of this case is to verify SA A5 rsrp Interfreq IntragNB HO success from CA to TDD with perFR1 meas Gap.
    ...    Case steps:
    ...    1.Setup CA successfully,set source cell(CA) drx ON,set target cell drx False
    ...    2.Trigger A2 measurement report
    ...    3.Trigger A5 measurement report to HO to TDD
    ...    4.Trigger A5 to handover to real GNB FDD+TDD check traffic
    [Tags]    E017    QC_83624
    clear counter files
    delta commission parameters    ${Deltacommission17}
    Attach UE for waiting L3 call OK
    Trigger Inter A5 HO Loop three times
    Verify Throughput
    Ue Deregister
    Check Wireshark Log    ${CURDIR}${/}a2a_17${/}a2a.ini    wait_string=UEContextRelease
    check counters    ${PM_Counters_List17}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=fddtdd_sansa_cmwv/L1B/6cells_4T2F

Modify Cfg
   ${ue_82}    catenate
    ...    set_ue simulated id=82 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nea=null+zuc
    ...    nia=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645482 enb=2 cell=12 mode=nr
    Update Cfg    ${ue_82}
    ${ue_nr_capabilities}   catenate   SEPARATOR=
    ...    EFA09000574F5E13020002C32001209106000983848018806804C020311406014CE01751B0A303582308682041D2090165B262A86873E238F40CFB027C639
    ...    F30C7942C0E070F02E000BE0038002F800260001C0A836236B04610D04083C412028B64C55090E7D813E238F18E7CC31E50B0381C3C13F8000000FE000000
    ...    098000702A0D883AC1184341000100480A2D931542439F604F88E3C639F30C7942C0E070F00FE0000003F80000002600018003583850100000041D41C1401
    ...    C46000002120541C1401C410000041204014028808D01043C008C070226C73E1C29D3B639F0E04ED8E7C307A09801C001C0E0A00E06012803800301200203
    ...    0141080000014240268800E7CC31E50B03028210008001904804D4000438820422A0407C20004000000020000040100000000800002004000018020000100
    ...    100000A0080000600400200802008000070040000400200100000004000048020000280100001724A0040C030B925000061724A00C0C0300C030B92500406
    ...    018061724A0180C0300C0300C0300C2E4940201806018060185C928070300C0300C0300C0300C2E094000185C928000313925002060189C928020300C0313
    ...    825000062724A01C0C0300C0300C0300C031392500606018060189C92800030392500E060180601806018060181C12800030392500606018060181819CA9A
    ...    CA9AC14AC0CAC0DAC15AC19ACA5AC99AC05AC08AC04ADD201C0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA48080003
    ...    4B292020000F2CA480800044B29202000132CA480800054B292020081605CB29282000172CA4A0800038B29202000042CA4805A9555D2AAAA55154162A81C
    ...    55068AA53174AA2A93455018AA05155DA81204F020A05028140A05028140A05028140A0502804020100804020100804020100804020100804020001000406
    ...    00208080100002014028404008000100A014628840004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05091900
    Update Cfg    ue_param id=82 ue_nr_capabilities=${ue_nr_capabilities}

Attach UE for waiting L3 call OK
    [Arguments]    ${ueid}=82
    Execute Egate Command    ue_location_change id=${ueid} enb=2 cell=12
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
	Execute Egate Command    ue_register id=${ueid}    Received REGISTRATION COMPLETE
	Execute Egate Command    set_pdu_param ue=${ueid} pdu=2 trf_type=internal
	Execute Egate Command    ue_pdu_session_setup pdu=2 ue=${ueid} nwslice=1 gw=2    SCellIndex 1 activated successfully at airphone
	Execute Egate Command    trf_data_start ue=${ueid} pdu=2 qfi=1 dir=dl mbps=100 trf_id=1    UDP DL TRF
	Execute Egate Command    trf_data_start ue=${ueid} pdu=2 qfi=1 dir=ul mbps=10 trf_id=1    UDP UL TRF

Verify Throughput
    [Documentation]    verify Tput in scell is not 0
    [Arguments]    ${Tput_dl}=90    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=82    pdu=2    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=82    pdu=2    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=82 scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Report A2 and configured A3 for UE
    [Arguments]    ${ue_id}=82   ${ssbfreq}=${NRARFCN127180}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${NRARFCN127180}    A2
	Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
	...    rrcReconfigurationComplete

Report A2 and configured A5 for UE
    [Arguments]    ${ue_id}=82   ${ssbfreq}=${NRARFCN127180}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${NRARFCN127180}    A2
	Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
	...    rrcReconfigurationComplete

Report A3 and Trigger HO from cell12 to cell11
    [Arguments]    ${ue_id}=82   ${ssbfreq}=${NRARFCN127180}   ${phycell_id}=382
	${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${ssbfreq}    A3
	${A3_cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
	...    phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
	${retv}    Execute Egate Command    ${A3_cmd}    SCellIndex 1 activated successfully at airphone
	should contain    ${retv}    Intra-eNB handover from EXT_ENB-2.12 to EXT_ENB-2.11 performed

Report A5 and Trigger HO from cell12 to cell4
    [Arguments]    ${ue_id}=82   ${ssbfreq}=${NRARFCN526020}   ${phycell_id}=53
	${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${ssbfreq}    A5
	${A5_cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A5 srsrp_nr=11 srsrq_nr=11
	...    phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
	Execute Egate Command    ${A5_cmd}    Intra-eNB handover from EXT_ENB-2.12 to EXT_ENB-2.4 performed

Report A3 and Trigger HO from cell11 to cell12
    [Arguments]    ${handover_string}=Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.12 performed    ${ssbfreq}=${NRARFCN424000}
    ${A2_measid}    get nr meas id for specific type and frequency    82    ${ssbfreq}    A2
	Execute Egate Command    ue_measurement_send_nr id=82 meas_id=${A2_measid} event=A2 srsrp_nr=7 srsrq_nr=7    rrcReconfigurationComplete
	${A3_measid}    get nr meas id for specific type and frequency    82    ${NRARFCN127180}    A3
	${A3cmd}    catenate    ue_measurement_send_nr id=82 meas_id=${A3_measid} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=61 nrsrp_nr=60 nrsrq_nr=60
	${retvlue}    Execute Egate Command    ${A3cmd}   SCellIndex 1 activated successfully at airphone
	Should Contain    ${retvlue}    ${handover_string}

Report A5 and Trigger HO from cell4 to cell12
    [Arguments]    ${handover_string}=Intra-eNB handover from EXT_ENB-2.4 to EXT_ENB-2.12 performed    ${ssbfreq}=${NRARFCN526020}
    ${A2_measid}    get nr meas id for specific type and frequency    82    ${ssbfreq}    A2
	Execute Egate Command    ue_measurement_send_nr id=82 meas_id=${A2_measid} event=A2 srsrp_nr=7 srsrq_nr=7    rrcReconfigurationComplete
	${A5_measid}    get nr meas id for specific type and frequency    82    ${NRARFCN127180}    A5
	${A5cmd}    catenate    ue_measurement_send_nr id=82 meas_id=${A5_measid} event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=61 nrsrp_nr=60 nrsrq_nr=60
	${retvlue}    Execute Egate Command    ${A5cmd}   SCellIndex 1 activated successfully at airphone
	Should Contain    ${retvlue}    ${handover_string}

Ue Deregister
    Execute Egate Command    ue_deregister id=82 ue_deregister_type=switch_off    rrcRelease

Trigger Inter A3 HO Loop three times
    FOR    ${index}    IN RANGE    0    3
        Report A2 and configured A3 for UE
        Report A3 and Trigger HO from cell12 to cell11    ssbfreq=${NRARFCN424000}    phycell_id=60
        Report A3 and Trigger HO from cell11 to cell12
    END

Trigger Inter A5 HO Loop three times
    FOR    ${index}    IN RANGE    0    3
        Report A2 and configured A5 for UE
        Report A5 and Trigger HO from cell12 to cell4
        Report A5 and Trigger HO from cell4 to cell12
    END
