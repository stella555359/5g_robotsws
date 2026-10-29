*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-christine.chen
...    CLOUD_5G_I_BLLL_AP_LOO    CRT    CB007517-C    release-5G22R4
...    STATE_CONFIGURED    RAN_5G   
Resource    ../../../../resources/DevHZ5_resource.robot


*** Variables ***
${DEBUG_LOG_LEVEL}  0
${AP_LOG_LEVEL}  0

${GNB_BIP_FLAG}  ${True}

@{PARAMS_IN_SCF}
...    @{A4_Config}
...    @{NRHOIF_Config}
...    @{GNB_PMQAP}

@{GNB_PMQAP}
...    NRBTS:actNrpmqapProfiles=true
...    NRPMRNL-1/NRPMQAP-1:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=1-9
...    NRPMRNL-1/NRPMQAP-1:cfgArpRange=15
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-2:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-2:cfg5qiRange=1
...    NRPMRNL-1/NRPMQAP-2:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mcc=420
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mnc=06
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-3:cfgProfType=NSA
...    NRPMRNL-1/NRPMQAP-3:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mnc=489

@{A4_Config}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS-1:actHigherPrioFreqHo=SA
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-1:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-1:a4PeriodicMeasControlSA:a4MeasMaxNumber=3
...    NRCELL-1:a4PeriodicMeasControlSA:a4RetryTimer=5
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-2:a4PeriodicMeasControlSA:a4MeasMaxNumber=3
...    NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=5
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=3
...    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=5
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-12:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-12:a4PeriodicMeasControlSA:a4MeasMaxNumber=3
...    NRCELL-12:a4PeriodicMeasControlSA:a4RetryTimer=5
...    NRCELL-13:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-13:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-13:a4PeriodicMeasControlSA:a4MeasMaxNumber=3
...    NRCELL-13:a4PeriodicMeasControlSA:a4RetryTimer=5
...    NRCELL-14:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL-14:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL-14:a4PeriodicMeasControlSA:a4MeasMaxNumber=3
...    NRCELL-14:a4PeriodicMeasControlSA:a4RetryTimer=5

@{NRHOIF_Config}
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=424090
...    NRCELL-1/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=2
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-1:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-1/NRHOIF-2:cellDepType=SA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-2:ssbFrequency=126750
...    NRCELL-1/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4HysteresisSsbRsrp=2
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-2:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-1/NRHOIF-3:cellDepType=SA
...    NRCELL-1/NRHOIF-3:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-3:ssbFrequency=633216
...    NRCELL-1/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-5:cellDepType=SA
...    NRCELL-1/NRHOIF-5:freqBandIndicatorNR=257
...    NRCELL-1/NRHOIF-5:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-5:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-5:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-5:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-5:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-5:ssbFrequency=2079163
...    NRCELL-1/NRHOIF-5:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-5:a4PriorityForHigherPrioFreqHo=5

@{Mobility_onlineParam_for_C056}
...    NRCELL-2/NRHOIF-1:cellDepType=SA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=518910
...    NRCELL-2/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-2/NRHOIF-1:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:lcrId=1

@{Mobility_OnlineParam_BB056_recover}
...    delete:NRCELL-2/NRHOIF-1
...    delete:NRCELL-1/NRREL-1
...    delete:NRCELL-2/NRREL-1

@{Mobility_OnlineParam_for_C057}
...    NRBTS-1:actIntraNrNgHo=sourceAndTarget
...    NRBTS-1:tNgRelocExecDeltN=3000
...    NRBTS-1:tNgRelocOverallN=2000
...    NRBTS-1:tNgRelocPrepN=2000
...    NRBTS-1:tNgRelocCancelN=2000
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=513150
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-1:a4PriorityForHigherPrioFreqHo=1
...    NRADJNRCELL-1:physCellId=381
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=35
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:handoverAllowedSA=XnHoNotAllowed

@{Mobility_OnlineParam_BB057_recover}
...    delete:NRCELL-1/NRHOIF-1
...    delete:NRCELL-1/NRREL-1
...    NRADJNRCELL-1:physCellId=41

${ue_id}    81
${cell_id}    1
${pdu_id}    1

${BTS_STARTUP_RETRY}    4

@{PM_Counters_Check_C056}
...    NRCELL-1:${ATT_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-1:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-2/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=1
...    NRCELL-2/PLMN-PLMN/NRPMQAP-1:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=1
...    NRCELL-2/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-2/PLMN-PLMN/NRPMQAP-2:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-2/PLMN-PLMN/NRPMQAP-3:SMAGP:${A4_IEF_IADU_HO_EX_ATT_SA}=0
...    NRCELL-2/PLMN-PLMN/NRPMQAP-3:SMAGP:${A4_IEF_IADU_HO_EX_SUC_SA}=0
...    NRCELL-2:${ATT_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-2:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRBTS-1:NSL:${ATT_IF_GNB_INTRA_DU_HO_SLICE}=2
...    NRBTS-1:NSL:${SUCC_IF_GNB_INTRA_DU_HO_SLICE}=2

${A4_IEF_IADU_HO_EX_ATT_SA}    M55184C00003
#Building of RRC Reconfiguration into DL RRC Message Transfer (from gNB-CU)
${A4_IEF_IADU_HO_EX_SUC_SA}    M55184C00004
#Reception of RRC Reconfiguration complete and sending UL RRC Message over NR (to gNB-CU)
${ATT_IF_INTRA_DU_HO_SA_PLMN}    M55145C00321
#The number of inter-frequency intra-DU HO attempts for SA per PLMN-ID
${SUCC_IF_INTRA_DU_HO_SA_PLMN}    M55145C00322
#The number of successful inter-frequency intra-DU HOs for SA per PLMN-ID
${ATT_IF_GNB_INTRA_DU_HO_SLICE}     M55149C00550
#The number of Inter-Frequency Intra-gNB Intra-DU HOs attempted for the given slice and PLMN
${SUCC_IF_GNB_INTRA_DU_HO_SLICE}     M55149C00551
#The number of Inter-Frequency Intra-gNB Intra-DU HOs successful for the given slice and PLMN

@{PM_Counters_Check_C057}
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMENP:${A4_IEF_NG_HO_PREP_ATT_SRC}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMENP:${A4_IEF_NG_HO_EXEC_ATT_SRC}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:SMENP:${A4_IEF_NG_HO_EXEC_SUC_SRC}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMENP:${A4_IEF_NG_HO_PREP_ATT_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMENP:${A4_IEF_NG_HO_EXEC_ATT_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:SMENP:${A4_IEF_NG_HO_EXEC_SUC_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMENP:${A4_IEF_NG_HO_PREP_ATT_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMENP:${A4_IEF_NG_HO_EXEC_ATT_SRC}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:SMENP:${A4_IEF_NG_HO_EXEC_SUC_SRC}=0
...    NRCELL-1:NNGCC:${NG_HO_PREP_ATT_SRC_IEF}=2
...    NRCELL-1:NNGCC:${NG_HO_EXEC_ATT_SRC_IEF}=2
...    NRCELL-1:NNGCC:${NG_HO_EXEC_SUCC_SRC_IEF}=2
...    NRBTS-1:NSL:${NG_HO_PREP_ATT_SRC_IEF_PLMN}=2
...    NRBTS-1:NSL:${NG_HO_EXEC_ATT_SRC_IEF_PLMN}=2
...    NRBTS-1:NSL:${NG_HO_EXEC_SUCC_SRC_IEF_PLMN}=2

${A4_IEF_NG_HO_PREP_ATT_SRC}     M55186C00001
#This counter measures the number of A4 triggered NG based Inter-frequency Inter-gNB handover preparation attempts on the source cell for SA.
${A4_IEF_NG_HO_EXEC_ATT_SRC}     M55186C00002
#This counter measures the number of A4 triggered NG based Inter-frequency Inter-gNB handover execution attempts on the source cell for SA.
${A4_IEF_NG_HO_EXEC_SUC_SRC}     M55186C00003
#This counter measures the number of A4 triggered successful NG based Inter-frequency Inter-gNB handover execution
#attempts on the source cell for SA.
${NG_HO_PREP_ATT_SRC_IEF}     M55125C07501
#This counter is updated when NGAP: Handover Required is sent for NG based Inter-frequency HO on the source gNB.
${NG_HO_EXEC_ATT_SRC_IEF}     M55125C07513
#This counter is updated when RRC ConnectionReconfiguration is sent to the UE for NG based Inter-frequency HO on the source gNB.
${NG_HO_EXEC_SUCC_SRC_IEF}     M55125C07522
#This counter is updated when NGAP: UE Context Release Command is received for NG based Inter-frequency HO on the source gNB
#and gNB verifies the handover was successful.
${NG_HO_PREP_ATT_SRC_IEF_PLMN}     M55149C03004
#This counter is updated when NGAP: Handover Required is sent for NG based Inter-frequency HO on the source gNB, per PLMN per slice.
${NG_HO_EXEC_ATT_SRC_IEF_PLMN}     M55149C03005
#This counter is updated when RRC ConnectionReconfiguration is sent to the UE for NG based interFreq HO on the source gNB,per PLMN per slice
${NG_HO_EXEC_SUCC_SRC_IEF_PLMN}     M55149C03006
#This counter is updated when NGAP: UE Context Release Command is received for NG based Inter-frequency HO on the source
#gNB and gNB verifies the handover was successful, per PLMN per slice.

${SA_Capa_Support_FR2_perFR}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C47013B8D85181AC1184341020E90186D6C98AB1A1CF
...    88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98AB121CFB027C471
...    E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E
...    7CC31E50B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD931562439F11C7B027C62471E439F51CF9863CA16070
...    38784FFF800003FFE0000016001C0A816806F1C610D00151E7E281845ED98AA9001E3C0087104184540A3F7F204BEF0A800C007BC3C4D000
...    E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A00038820000042C0AC3C4D000E230000010B02B1711800388
...    2001C4100000A160561E14000713400003058158B89A001C41000E140000040B02B1713400388C001C46000004160562E14000710400388C
...    0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02B170A000388C001C46000004160562E2680071180038500
...    000100008C1D0000000E0804808D00A2026C04182000E9720F851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C48912
...    26C73E1C28103639F022408103639F022408103639F022408103639F022408103639F022408103639F022408103639F022408103639F0204
...    0D8E7C002E1E318C6318C6318C6318C3D04C00F000F07050070300740380030120020301F048010000000080000100400000002000004010
...    00004008000030040000200200001401000802008020000180100000E0080040000001000010008000090040000180200002801000016008
...    00409024010000180672A6B2A6B052B032B066B056B296B266B016B036B012B022B07681A0800004B29282000032CA4A0800014B29202000
...    072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202
...    000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C50505E02540A05028140A05028140A05028140A
...    05028140A05000708080600C02004008404008020100C018402004008080600C02018030404030060100C018402004008080600C02004008
...    804030060100C018040300608080100402004010004008021AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2
...    D2F414182D

*** Test Cases ***
CB007517-ET-C056_A4_deconfigured_after_A2_then_Intra-DU_HO_with_A3_then_A4_HO
    [Documentation]
    ...    1. A4 deconfigured for non-first circulation after receiving inter-freq A2 MR and keep deconfigured then
    ...       receiving A3 MR inter-freq inter-DU HO succeed at last, then target A4 configured and HO succeed in
    ...       non-first circulation with A4 configured in target(UEcapaperFR_A4MGperFR1_interfreqA2Target7FR1FR2)
    ...    2. Configuration
    ...       a.configuration on cell 1
    ...       gNB is up and running
    ...       gNB config
    ...       1. SA Inter-frequency mobility is enabled
    ...          - NRBTS.actInterFreqHoSa = true
    ...       2. Source NRCell on which UE attaches is configured as a FR1 cell(cell1)
    ...       3. CB0007517 feature is activated in the gNB for SA
    ...         - NRBTS.actHigherPrioFreqHo =1
    ...       4. UE has transitioned from the IDLE to CONNECTED state.
    ...       5. UE's context has been setup through initial context setup for non-first circle and A4 measurement cfg done.
    ...       6. a4SupervisionTimer timer is running
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1.
    ...         b. wait 5s, A4 config
    ...         c. wait 10s, A4 deconfig
    ...         d. run the next cireculation, send a A2 MR during A4 a4SupervisionTimer.
    ...         e. send a A3 MR of cell2
    ...         f. send a A4 MR with prio 1 after 5S during a4SupervisionTimer.
    ...     4. Expect result:
    ...          a. PDU session is setup successfully, and start retry timer
    ...          b. A4 config, gapUE setup
    ...          c. A4 deconfig, gapUE release
    ...          d. A1 A3 config
    ...          e. HO successfully
    ...          f. A4 HO back successfully
    [Tags]    QC_194383    owner-Jing Qing    C056
    Prepare For C056
    Trigger A2 During A4 a4SupervisionTimer
    Trigger A3
    Trigger A4 During A4 a4SupervisionTimer    sleep_time=10s
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C056${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${PM_Counters_Check_C056}
    [Teardown]    TestTearDown BB056

CB007517-ET-C057_A4_deconfigured_after_A2_then_inter-gNB_NG_HO_with_A3_then_A4_HO
    [Documentation]
    ...    1. A4 deconfigured for non-first circulation after receiving inter-freq A2 MR and keep deconfigured then
    ...      receiving A3 MR inter-freq inter-gNB NG HO succeed at last, then target A4 configured and HO succeed in
    ...      non-first circulation with A4 configured in target(UEcapaperFR_A4MGperFR1_interfreqA2Target3FR1)
    ...    2. Configuration
    ...       a.configuration on cell 1
    ...       gNB is up and running
    ...       gNB config
    ...       1. SA Inter-frequency mobility is enabled
    ...          - NRBTS.actInterFreqHoSa = true
    ...       2. Source NRCell on which UE attaches is configured as a FR1 cell(cell1)
    ...       3. CB0007517 feature is activated in the gNB for SA
    ...         - NRBTS.actHigherPrioFreqHo =1
    ...       4. UE has transitioned from the IDLE to CONNECTED state.
    ...       5. UE's context has been setup through initial context setup for non-first circle and A4 measuremen cfg done
    ...       6. a4SupervisionTimer timer is running
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1.
    ...         b. wait 5s, A4 config
    ...         c. wait 10s, A4 deconfig
    ...         d. run the next cireculation, send a A2 MR during A4 a4SupervisionTimer.
    ...         e. send a A3 MR from cell1 to simGnb cell 1
    ...         f. send a A4 MR with prio 1 after 5S during a4SupervisionTimer.
    ...     4. Expect result:
    ...          a. PDU session is setup successfully, and start retry timer
    ...          b. A4 config, gapUE setup
    ...          c. A4 deconfig, gapUE release
    ...          d. A1 A3 config
    ...          e. HO successfully
    ...          f. A4 HO back successfully
    [Tags]    QC_194384    owner-Jing Qing    C057
    Prepare For C057
    Trigger A2 During A4 a4SupervisionTimer    carrierfreq=518910    sleep_time=11s
    Trigger A3    carrierfreq=513150    phycell_id=381    pass_regexp=measId
    Trigger A2    carrierfreq=513150    sleep_time=5s
    Trigger A3    carrierfreq=518910    sleep_time=5s    phycell_id=50    pass_regexp=measId
    Trigger A4 During A4 a4SupervisionTimer    carrierfreq=513150    sleep_time=10s    phycell_id=381    pass_regexp=measId
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C057${/}a2a.ini    wait_string=UEContextReleaseComplete::8
    Check Counters    ${PM_Counters_Check_C057}
    [Teardown]    TestTearDown BB057

*** Keywords ***
OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Update UE capa
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_Support_FR2_perFR}
    Execute Egate Command    ${cmd}

TestTearDown BB056
    OnlineParamChange    ${Mobility_OnlineParam_BB056_recover}
    Common Test Teardown And Stop Capture Logs

TestTearDown BB057
    OnlineParamChange    ${Mobility_OnlineParam_BB057_recover}
    Common Test Teardown And Stop Capture Logs

Trigger Xn Setup From Remote GNB
    [Arguments]    ${gnb_id}=3
    Execute Egate Command    gnb_param id=${gnb_id} send_xn_setup=true
    Execute Egate Command    gnb_xn_link_up gnb=${gnb_id} target=2    GNB-${gnb_id}: XnAP Link with GNB-2
    Execute Egate Command    gnb_param id=${gnb_id} sa_ho=ng_based

UE_register_and_ICS_w_pdu
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${cmd}=    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${pdu_id}
    Execute Egate Command    ${cmd}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId ${pdu_id} Created

Prepare For C056
    Clear Counter Files
    OnlineParamChange    ${Mobility_onlineParam_for_C056}
    Update UE capa
    UE_register_and_ICS_w_pdu
    Send And Verify Throuput

Prepare For C057
    Clear Counter Files
    OnlineParamChange    ${Mobility_OnlineParam_for_C057}
    Update UE capa
    Trigger Xn Setup From Remote GNB
    Execute Egate Command    trace amf=1 protocol=ng on
    UE_register_and_ICS_w_pdu
    Send And Verify Throuput

Verify Throuput
    [Arguments]    ${Tput_dl}=60    ${Tput_ul}=9.5    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10
    Verify Throuput
	
UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger A2 During A4 a4SupervisionTimer
    [Arguments]    ${ue_id}=81    ${carrierfreq}=518910    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for next cireculation during A4 a4SupervisionTimer
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=20 srsrq_nr=20
    ...    pass_regexp=eventId eventA3

Trigger A2
    [Arguments]    ${ue_id}=81    ${carrierfreq}=518910    ${sleep_time}=2s
    sleep    ${sleep_time}    sleep for A2 MR
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=5 srsrq_nr=5
    ...    pass_regexp=eventId eventA3

Trigger A3
    [Arguments]    ${ue_id}=81    ${carrierfreq}=633216    ${sleep_time}=2s    ${phycell_id}=51
    ...    ${pass_regexp}=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2
    sleep    ${sleep_time}    sleep for A3 MR
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}
    ...    pass_regexp=${pass_regexp}
    Verify Throuput

Trigger A4 During A4 a4SupervisionTimer
    [Arguments]    ${ue_id}=81    ${carrierfreq}=518910    ${sleep_time}=15s    ${phycell_id}=50
    ...    ${pass_regexp}=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1
    sleep    ${sleep_time}    sleep for next cireculation during A4 a4SupervisionTimer
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A4
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A4 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}
    ...    pass_regexp=${pass_regexp}
    Verify Throuput

