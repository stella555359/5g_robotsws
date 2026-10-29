*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    team-SG2    release-SBTS23R4
...    owner-teana.wang    owner-ying.5.chen    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}         tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_SECURITY}
...    @{PARAMS_FOR_A1}
...    @{PARAMS_FOR_A2}
...    @{PARAMS_FOR_A3}
...    @{PARAMS_FOR_InterFreq_IntraFreq_HO}
...    @{PARAMS_FOR_XN}
...    @{PARAMS_FOR_PMQAP}
...    @{PARAMS_FOR_CB010217}
...    @{NRCGI_config}

@{PARAMS_FOR_SECURITY}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9

@{PARAMS_FOR_A1}
...    NRBTS/NRCELL-1:a1MeashoEnabled=rsrp
...    NRBTS/NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRBTS/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRBTS/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRBTS/NRCELL-2:a1MeashoEnabled=rsrp
...    NRBTS/NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRBTS/NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRBTS/NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480

@{PARAMS_FOR_A2}
...    NRBTS/NRCELL-1:a2MeashoEnabled=rsrpAndRsrq
...    NRBTS/NRCELL-1:a2MeashoEnabledSA=rsrpAndRsrq
...    NRBTS/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRBTS/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRBTS/NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0
...    NRBTS/NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=31
...    NRBTS/NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480
...    NRBTS/NRCELL-2:a2MeashoEnabled=rsrpAndRsrq
...    NRBTS/NRCELL-2:a2MeashoEnabledSA=rsrpAndRsrq
...    NRBTS/NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRBTS/NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRBTS/NRCELL-2:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0
...    NRBTS/NRCELL-2:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=31
...    NRBTS/NRCELL-2:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480

@{PARAMS_FOR_A3}
...    NRBTS/NRCELL-1:a3MeasEnabled=rsrp
...    NRBTS/NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRBTS/NRCELL-1:absThreshSsbRsrqConsolidation=1
...    NRBTS/NRCELL-1:sMeasConfigSsbRsrp=1
...    NRBTS/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRBTS/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRBTS/NRCELL-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=2
...    NRBTS/NRCELL-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRBTS/NRCELL-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    NRBTS/NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRBTS/NRCELL-2:a3MeasEnabled=rsrp
...    NRBTS/NRCELL-2:absThreshSsbRsrpConsolidation=1
...    NRBTS/NRCELL-2:absThreshSsbRsrqConsolidation=1
...    NRBTS/NRCELL-2:sMeasConfigSsbRsrp=1
...    NRBTS/NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS/NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRBTS/NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRBTS/NRCELL-2:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    NRBTS/NRCELL-2:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRBTS/NRCELL-2:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    NRBTS/NRCELL-2:measGapSelectionSA=favourUeThroughput

@{PARAMS_FOR_InterFreq_IntraFreq_HO}


...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:timerXnUeProcGuard=6000
...    NRBTS-1/NRCELL-1:nrarfcn=633364
...    NRBTS-1/NRCELL-1:gscnOrSsPbchArfcn=7845
...    NRBTS-1/NRCELL-2:nrarfcn=633508
...    NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7847
...    NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=40
...    NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=633408
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms64
...    NRBTS-1/NRCELL-2/NRREL-2:gNbId=35
...    NRBTS-1/NRCELL-2/NRREL-2:gNbIdLength=22
...    NRBTS-1/NRCELL-2/NRREL-2:lcrId=1
...    NRBTS-1/NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-2/NRREL-2:gnbPlmn:mncLength=3

@{PARAMS_FOR_XN}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIncXn=true
...    NRBTS-1/NRADJNRCELL-1:lcrId=1
...    NRBTS-1/NRADJNRCELL-1:gNbId=35
...    NRBTS-1/NRADJNRCELL-1:nrarfcn=633508
...    NRBTS-1/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS-1/NRADJNRCELL-1:physCellId=381
...    NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRADJNRCELL-1:ssbFrequency=633408

@{PARAMS_FOR_PMQAP}
...    NRBTS-1:actNrpmqapProfiles=true
...    NRBTS-1:actIpThpt=true
...    NRPMRNL-1:miNrNGCC=15min
...    NRPMRNL-1:miNrHighRlcCellNrpmqap=15min
...    NRPMRNL-1:miNrNgInterfaceNrpmqap=15min
...    NRPMRNL-1:miNrNsaAcCuNrpmqap=15min
...    NRPMRNL-1:miNrPdcpCellNrpmqap=15min
...    NRPMRNL-1:miNrSaCuNrpmqap=15min
...    NRPMRNL-1:miNrUeStatNrpmqap=15min
...    NRPMRNL-1:miNrX2ccNrpmqap=15min
...    NRPMRNL-1/NRPMQAP-1:cfgProfType=both
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=1-9
...    NRPMRNL-1/NRPMQAP-1:cfgArpRange=1-15
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sd=13714341
...    NRPMRNL-1:miNrRelReportCu=15min

@{ENABLE_CB010217}
...    NRBTS:actVoiceFallbackDuringHOPrep=voiceFallbackDuringXnHOPrep

@{PARAMS_FOR_CB010217_CASE01}
...    NRBTS:timerHOGuard=6000          #RRCReconfiguration-->RRCReconfigurationComplete
...    NRBTS:actVoiceFallbackDuringHOPrep=disabled
...    NRCELL:emergencyFBMode=redirection
...    NRBTS:actEmergencyFallback=true
...    NRBTS:actMobilityProfile=false
...    NRBTS/NRANR-1:actAutoNrNbRemoval=false
...    NRCELL/NRREDRT-1:redirPrio=1
...    NRCELL/NRREDRT-1:redirFreqEutra=39750
...    NRCELL/NRREDRT-1:redirRat=eutra
...    delete:NRCELL/NRREDRT-1:redirSsbScs
...    delete:NRCELL/NRREDRT-1:redirFreqNr
...    NRCELL:actCDrx=false
...    delete:NRCELL:drxProfile1
...    NRBTS:actDedicatedAnrDrxProfile=false
...    NRBTS-1:actSaUeBasedInterFreqAnrNr=false
...    NRBTS/NRCELL-1/NRREL-256:gNbId=35
...    NRBTS/NRCELL-1/NRREL-256:gNbIdLength=22
...    NRBTS/NRCELL-1/NRREL-256:lcrId=1
...    NRBTS/NRCELL-1/NRREL-256:gnbPlmn:mcc=311
...    NRBTS/NRCELL-1/NRREL-256:gnbPlmn:mnc=489
...    NRBTS/NRCELL-1/NRREL-256:gnbPlmn:mncLength=3
@{PARAMS_FOR_CB010217}
...    NRBTS:timerXnUeProcGuard=6000    ###handoverrequest-->handoverrequestacknowleg
...    NRBTS:actMobilityProfile=true
...    NRBTS:actVoiceFallbackDuringHOPrep=voiceFallbackDuringXnHOPrep
...    NRBTS:actEmergencyFallback=true
...    NRCELL:emergencyFBMode=redirection
...    NRBTS/NRMOPR_SA-1:emergencyFBMode=redirection
...    NRBTS:actSPID=true
...    NRCELL/NRREDRT-1:redirPrio=1
...    NRCELL/NRREDRT-1:redirFreqEutra=38100
...    NRCELL/NRREDRT-1:redirRat=eutra
...    delete:NRCELL/NRREDRT-1:redirSsbScs
...    delete:NRCELL/NRREDRT-1:redirFreqNr
...    NRCELL:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRBTS/NRMOPR_NSA-1:a1MeashoEnabled=none
...    NRBTS/NRMOPR_NSA-1:a2MeashoEnabled=none
...    NRBTS/NRMOPR_NSA-1:a3MeasEnabled=none
...    NRBTS/NRMOPR_NSA-1:a5MeasEnabled=none
...    NRBTS/NRMOPR_SA-1:nrMoRedDNList=MRBTS-1/NRBTS-1/NRMORED-1
...    NRBTS/NRMOPR_SA-1:voiceFBMode=redirection
...    NRBTS/NRMORED-1:redirFreqEutra=39750
...    NRBTS/NRMORED-1:redirRat=eutra
...    NRBTS/NRMORED-1:redirPrio=2

@{NRCGI_config}
...    NRCELL-1:actCDrx=true
...    NRCELL:actCDrx=true
...    NRCELL:drxProfile1:drxInactivityTimer=80ms
...    NRCELL:drxProfile1:drxLongCycle=160ms
...    NRCELL:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL:drxProfile1:drxRetransTimerDl=0slot
...    NRCELL:drxProfile1:drxRetransTimerUl=0slot
...    NRCELL-1:drxProfileNrAnr:drxControl=intraNRSA
...    NRCELL-1:drxProfileNrAnr:drxInactivityTimer=80ms
...    NRCELL-1:drxProfileNrAnr:drxLongCycle=320ms
...    NRCELL-1:drxProfileNrAnr:drxOnDurationTimer=20ms
...    NRCELL-1:drxProfileNrAnr:drxRetransTimerDl=0slot
...    NRCELL-1:drxProfileNrAnr:drxRetransTimerUl=0slot
...    NRCELL-1:drxProfileNrAnr:nrDrxDN=NRDRX-3
...    NRBTS:actDedicatedAnrDrxProfile=true
...    NRBTS-1:actSaUeBasedInterFreqAnrNr=true
...    NRBTS/NRANR-1:actAutoEutraNbRemoval=false
...    NRBTS/NRANR-1:actAutoNrNbRemoval=true
...    NRBTS/NRANR-1:consecHoFailThres=0
...    NRBTS/NRANR-1:consecHoFailThresEutra=3
...    NRBTS/NRANR-1:consecXnResolveFailThres=3
...    NRBTS/NRANR-1:gNbIdLengthConfig:gNbIdLength=22
...    NRBTS/NRANR-1:gNbIdLengthConfig:priorityIndex=1
...    NRBTS/NRANRPR-2:anrThresRsrpNbCell=-90
...    NRBTS/NRANRPR-2:anrThresRsrqNbCell=-48
...    NRBTS/NRANRPR-2:anrThresholdSelector=RSRP
...    NRBTS/NRANRPR-2:cellDepMode=SA+NSA
...    NRBTS/NRANRPR-2:consecRecheckForNrNbRemoval=5
...    NRBTS/NRANRPR-2:idleTimeForNrNbRemoval=72
...    NRBTS/NRANRPR-2:maxNumAnrNrrelAllowed=50
...    NRBTS/NRANRPR-2:nrarfcn=633508
...    NRBTS/NRANRPR-2:ssbFrequency=633408

${NR_RRC_RELEASE_REDIR_EF_LTE}    M55124C03501
${NNGCC_UE_CTXT_STP_REQ_RECD}    M55125C02501
${NNGCC_UE_CTXT_STP_REQ_EF_RECD}    M55125C03001
${NNGCC_UE_CTXT_STP_RESP_SENT}    M55125C02502
${NNGCC_UE_CTXT_STP_RESP_EF_SENT}    M55125C03002
${NNGCC_UE_CTXT_STP_FAIL_SENT}    M55125C02503
${NNGCC_UE_CTXT_STP_FAIL_EF_SENT}    M55125C03003
${NNGCC_UE_CTXT_MOD_REQ_RECD}    M55125C03004
${NNGCC_UE_CTXT_MOD_FAIL_SENT}    M55125C03006
${NNGCC_UE_CTXT_MOD_REQ_EF_RECD}    M55125C03007
${NNGCC_UE_CTXT_MOD_FAIL_EF_SENT}    M55125C03009
${XN_HO_CANCEL_SENT}    M55143C00003                  #Number of outgoing Handover Cancel sent to Target gNB
${FAIL_HO_NRREL_PREP}    M55153C00003                 #HO preparation failure per neighbour cell relation
${NG_FLOW_STP_FAIL_FALBACK_5QI1}    M55125C09519      #Number of 5QI-1 QoS Flows setup failure due to Fallback
${NG_FLOW_STP_FAIL_FALBACK_PMQAP}    M55163C00501     #Number of PMQAP Profile based QoS Flows released due to voice Fallback for PMQAP Profile
${NRRCC_RRC_RELEASE_REDIR_LTE}    M55124C01502        #Number of RRC Releases with LTE frequency redirection information
${XN_HO_PREP_CNC_SRC_EPSFB}    M55143C00012           #Number of Xn handover preparations canceled due to EPS fallback
${NG_FLOW_STP_FAIL_HO_5QI1}    M55125C00035           #Number of 5QI-1 QoS Flow setup failures due to ongoing Xn handover
${NRRCC_RRC_RELEASE_SENT}    M55124C00001             #Number of RRC RELEASE messages sent (CU counter)
${NNGCC_UE_CTXT_MOD_RESP_EF_SENT}    M55125C03008     #Number of UE CONTEXT MODIFICATION RESPONSE for emergency fallback sent
${NNGCC_UE_CTXT_MOD_RESP_SENT}    M55125C03005        #Number of UE CONTEXT MODIFICATION RESPONSE sent
${UE_CTX_MOD_FAIL_EF_HO}    M55125C03010              #Number of emergency fallbacks rejected due to ongoing Xn handover
${XN_HO_PREP_CNC_SRC_EMCFB}    M55143C01503           #Xn handover preparation canceled due to an emergency fallback

@{PM_Counters_B001}
...    NRCELL-1:${UE_CTX_MOD_FAIL_EF_HO}=3
...    NRCELL-2:${UE_CTX_MOD_FAIL_EF_HO}=3
...    NRCELL-1:${XN_HO_PREP_CNC_SRC_EMCFB}=1
...    NRCELL-2:${XN_HO_PREP_CNC_SRC_EMCFB}=1
...    NRCELL-1:${NR_RRC_RELEASE_REDIR_EF_LTE}=1
...    NRCELL-2:${NR_RRC_RELEASE_REDIR_EF_LTE}=1
...    NRCELL-1:${NNGCC_UE_CTXT_MOD_REQ_RECD}=4
...    NRCELL-2:${NNGCC_UE_CTXT_MOD_REQ_RECD}=4
...    NRCELL-1:${NNGCC_UE_CTXT_MOD_REQ_EF_RECD}=4
...    NRCELL-2:${NNGCC_UE_CTXT_MOD_REQ_EF_RECD}=4
...    NRCELL-1:${NNGCC_UE_CTXT_MOD_RESP_EF_SENT}=1
...    NRCELL-2:${NNGCC_UE_CTXT_MOD_RESP_EF_SENT}=1
...    NRCELL-1:${NNGCC_UE_CTXT_MOD_RESP_SENT}=1
...    NRCELL-2:${NNGCC_UE_CTXT_MOD_RESP_SENT}=1
...    NRCELL-1:${XN_HO_CANCEL_SENT}=1
...    NRCELL-2:${XN_HO_CANCEL_SENT}=1
...    NRCELL-1:NRREL:${FAIL_HO_NRREL_PREP}=1
...    NRCELL-2:NRREL:${FAIL_HO_NRREL_PREP}=1
...    NRCELL-1:${NG_FLOW_STP_FAIL_FALBACK_5QI1}=0
...    NRCELL-2:${NG_FLOW_STP_FAIL_FALBACK_5QI1}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_STP_FAIL_FALBACK_PMQAP}=0
...    NRCELL-2/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_STP_FAIL_FALBACK_PMQAP}=0
...    NRCELL-1:${NRRCC_RRC_RELEASE_REDIR_LTE}=1
...    NRCELL-2:${NRRCC_RRC_RELEASE_REDIR_LTE}=1
...    NRCELL-1:${XN_HO_PREP_CNC_SRC_EPSFB}=0
...    NRCELL-2:${XN_HO_PREP_CNC_SRC_EPSFB}=0
...    NRCELL-1:${NG_FLOW_STP_FAIL_HO_5QI1}=0
...    NRCELL-2:${NG_FLOW_STP_FAIL_HO_5QI1}=0
...    NRCELL-1:${NRRCC_RRC_RELEASE_SENT}=3
...    NRCELL-2:${NRRCC_RRC_RELEASE_SENT}=3

@{delta_For_Nrcell_gnb3}
...    NRBTS/NRCELL-1/NRREL-256:gNbId=35
...    NRBTS/NRCELL-1/NRREL-256:gNbIdLength=22
...    NRBTS/NRCELL-1/NRREL-256:lcrId=1
...    NRBTS/NRCELL-1/NRREL-256:gnbPlmn:mcc=311
...    NRBTS/NRCELL-1/NRREL-256:gnbPlmn:mnc=489
...    NRBTS/NRCELL-1/NRREL-256:gnbPlmn:mncLength=3

@{PM_Counters_B005}
...    NRCELL-1:${NRRCC_RRC_RELEASE_REDIR_LTE}=3    #M55124C01502         -b
...    NRCELL-2:${NRRCC_RRC_RELEASE_REDIR_LTE}=1
...    NRCELL-1:${NR_RRC_RELEASE_REDIR_EF_LTE}=3    #M55124C03501
...    NRCELL-2:${NR_RRC_RELEASE_REDIR_EF_LTE}=1
...    NRCELL-1:${NNGCC_UE_CTXT_STP_REQ_RECD}=3     #M55125C02501
...    NRCELL-2:${NNGCC_UE_CTXT_STP_REQ_RECD}=2
...    NRCELL-1:${NNGCC_UE_CTXT_STP_REQ_EF_RECD}=0    #M55125C03001
...    NRCELL-2:${NNGCC_UE_CTXT_STP_REQ_EF_RECD}=0
...    NRCELL-1:${NNGCC_UE_CTXT_STP_RESP_SENT}=3     #M55125C02502
...    NRCELL-2:${NNGCC_UE_CTXT_STP_RESP_SENT}=2
...    NRCELL-1:${NNGCC_UE_CTXT_STP_RESP_EF_SENT}=0    #M55125C03002
...    NRCELL-2:${NNGCC_UE_CTXT_STP_RESP_EF_SENT}=0
...    NRCELL-1:${NNGCC_UE_CTXT_STP_FAIL_SENT}=0     #M55125C02503
...    NRCELL-2:${NNGCC_UE_CTXT_STP_FAIL_SENT}=0
...    NRCELL-1:${NNGCC_UE_CTXT_MOD_FAIL_EF_SENT}=0     #M55125C03009
...    NRCELL-2:${NNGCC_UE_CTXT_MOD_FAIL_EF_SENT}=0
...    NRCELL-1:${NNGCC_UE_CTXT_MOD_REQ_RECD}=3    #M55125C03004
...    NRCELL-2:${NNGCC_UE_CTXT_MOD_REQ_RECD}=1
...    NRCELL-1:${NNGCC_UE_CTXT_MOD_FAIL_SENT}=0    #M55125C03006
...    NRCELL-2:${NNGCC_UE_CTXT_MOD_FAIL_SENT}=0
...    NRCELL-1:${NNGCC_UE_CTXT_MOD_REQ_EF_RECD}=3    #55125C03007
...    NRCELL-2:${NNGCC_UE_CTXT_MOD_REQ_EF_RECD}=1
...    NRCELL-1:${NNGCC_UE_CTXT_MOD_RESP_EF_SENT}=3     #M55125C03008==1
...    NRCELL-2:${NNGCC_UE_CTXT_MOD_RESP_EF_SENT}=1     #M55125C03008==1
...    NRCELL-1:${NNGCC_UE_CTXT_MOD_RESP_SENT}=3     #M55125C03005==1
...    NRCELL-2:${NNGCC_UE_CTXT_MOD_RESP_SENT}=1     #M55125C03005==1
...    NRCELL-1:${UE_CTX_MOD_FAIL_EF_HO}=0      #M55125C03010==1
...    NRCELL-2:${UE_CTX_MOD_FAIL_EF_HO}=0      #M55125C03010==1
...    NRCELL-1:${XN_HO_PREP_CNC_SRC_EMCFB}=1     #M55143C01503==1
...    NRCELL-2:${XN_HO_PREP_CNC_SRC_EMCFB}=1     #M55143C01503==1
...    NRCELL-1:${NNGCC_UE_CTXT_STP_FAIL_EF_SENT}=0     #M55125C03003
...    NRCELL-2:${NNGCC_UE_CTXT_STP_FAIL_EF_SENT}=0
...    NRCELL-1:${XN_HO_CANCEL_SENT}=1     #M55143C00003                    -a
...    NRCELL-2:${XN_HO_CANCEL_SENT}=1
...    NRCELL-1:NRREL:${FAIL_HO_NRREL_PREP}=1    #M55153C00003
...    NRCELL-2:NRREL:${FAIL_HO_NRREL_PREP}=1
...    NRCELL-1:${NG_FLOW_STP_FAIL_FALBACK_5QI1}=0    #M55125C09519
...    NRCELL-2:${NG_FLOW_STP_FAIL_FALBACK_5QI1}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_STP_FAIL_FALBACK_PMQAP}=0     #M55163C00501
...    NRCELL-2/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_STP_FAIL_FALBACK_PMQAP}=0
...    NRCELL-1:${XN_HO_PREP_CNC_SRC_EPSFB}=0     #M55143C00012
...    NRCELL-2:${XN_HO_PREP_CNC_SRC_EPSFB}=0
...    NRCELL-1:${NG_FLOW_STP_FAIL_HO_5QI1}=0    #M55125C00035
...    NRCELL-2:${NG_FLOW_STP_FAIL_HO_5QI1}=0
...    NRCELL-1:${NRRCC_RRC_RELEASE_SENT}=6    #M55124C00001
...    NRCELL-2:${NRRCC_RRC_RELEASE_SENT}=3

${SA_UE_Support_LTE_Capabilities}    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C80008780818806804C020301C032A36146B04050D012CB2898087AD8202020E1DE38720C3
...    8002064F1F570004F001C0013C002A36266B04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36
...    26EB04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB2898087AD8202020E
...    1DE38720C38002064F1F55000005000000108389A00000000404D0301C020227B058060005038080E0600B00E000D07C0000000000
...    001CA9A0002000012CB2A00695550103800580000002004008D58980008101820283038405880889098C909293139425389B40

${SA_UE_Not_Support_LTE_Capabilities}    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C39061C001032
...    78FAB80027800E0009E00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13758202868096
...    5944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C043D6C10101070EF1C39061C00103278FA
...    A8000028000000841C4D00000000202682807008089EC1601800140E0601C0C01601C001A0F8000000000000395340004000025965400D2AA
...    A0207000B000000040080108

${SA_UE_Support_CGI_LTE_Capabilities}    SEPARATOR=
...    E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB28986801EB608080838778E1C830E000
...    8193C7D5C0013C0070004F000A8D899AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D
...    012CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CA261A007AD8202020E1DE38720C380020
...    64F1F55000005000000108389A00000000404D1700007008089EC2E003E00281C1401C0C026007000683E0000000000000E54D000100000965
...    950034AAA85800E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094E26D0

@{UES_ON_CELL2}    2    4
@{UES_ON_CELL1}    1    3
@{UES_NOT_SUPPORT_LTE}    3    4

@{RecvResponse_and_RedirectToLTE}
...    ServiceType is Emergency in Ue Active Mode
...    OnReceiveUEContextModificationResponse
...    cnType epc
...    Re-direction to 4G/LTE cell
...    Received UE Context Release Complete from GNB-2
...    UE.*IS IDLE

@{RejectRequest_and_HOSuccess_DuringHOPrepare}
...    ServiceType is Emergency in Ue Active Mode
...    Received UE Context Modification Failure from GNB-2 with cause RAN xn handover triggered
...    Inter-eNB handover from EXT_ENB-2.* to ENB-3.1 performed
...    Setup QosFlow with QFI:1
...    PATH SWITCH REQUEST ACK

@{RejectRequest_and_HOSuccess_DuringHOExec}
...    ServiceType is Emergency in Ue Active Mode
...    Inter-eNB handover from EXT_ENB-2.* to ENB-3.1 performed
...    Setup QosFlow with QFI:1
...    PATH SWITCH REQUEST ACK

*** Test Cases ***
CB010217-ET-B005_verify_Rejecting_UecontextModificationrequest_during_Interfreq_ANR_PCI_resolution_phase
    [Documentation]
    ...    1. The purpose of this test case is to verify that the request to setup Emergency UeContextModificationRequest
    ...       during the inter-freq ANR-PCI resolution phase and EPS fallback will enable in the gNB.
    ...    2. Test Case Steps:
    ...         Real gNB(gNB1) is in source, sim gNB(gNB3) is in target
    ...         cell1 frequency: 633364, cell2 frequency:633508, sim cell frequency: 633508
    ...                     ssb: 633216              ssb: 633408                ssb: 633408
    ...          UE capability:
    ...          CELL1_UE11: ANR
    ...          CELL2_UE12: NO_ANR
    ...          CELL1_UE13: ANR
    ...          CELL2_UE14: NO_ANR
    ...          CELL2_UE15: NO_ANR
    ...         a. setup XN link up
    ...         b. UE11, UE13 and UE15 attach to cell1, UE12, UE14 attach to cell2. start and check traffic for UE11-UE15
    ...         c. Set PCI-ANR resolution time delay of 2000ms to wait Emergency UEcontextmodifyRequest event.UE11 trigger redirect event
    ...         d. UE12 from CELL2 HO sim gnb cell1 and check traffic
    ...         e. Set PCI-ANR resolution time delay of 2000ms to wait Emergency UEcontextmodifyRequest event.UE13 trigger redirect event
    ...         f. UE14 from CELL2 HO sim gnb cell1 and check traffic
    ...         g. UE12 and UE14 from sim gnb HO to origin cell and check traffic
    ...         h. delta Cell11 nrrel related parameters on the webUI and set delay response to Xn handoverrequest preparation phase
    ...         i. UE15 trigger A2/A3 to HO -> gNB received NGAP:UeContextModificationRequest
    ...         g. UE14 trigger A3 to HO -> gNB received NGAP:UeContextModificationRequest
    ...         k. Check UE12 traffic
    ...         l. Check counter information
    ...    3. Expert Result:
    ...         a. XN link setup successful.
    ...         b. UE11, UE13 and UE15 attach to cell1 successful; UE12, UE14 attach to cell2 successful and all UE
    ...            traffic can start successfully,DL/UL traffic are transferred without loss
    ...         C.
    ...             c.1    when PCI-ANR parsing, concurrent Emergency UEcontextmodifyRequest event creation successful
    ...             c.2    Source gNB does not continues with the ANR resolution procedureand ANR setup fail.
    ...             c.3    Check the NRREL MO information on the webui does not exist.
    ...             c.4    UE11 will successfully trigger redirection behavior
    ...         d. UE12 will HO successful
    ...         e. Result as same step C
    ...         f. Result as same step d
    ...         g. UE12 and UE14 successful to origin cell
    ...         h. Update NIDD parameter successful and no error information and delay time set successful
    ...         i. UE15 trigger redirect event successful
    ...         g. UE14 trigger redirect event successful
    ...         k. Check UE12 DL/UL traffic are transferred without loss
    ...         L. check counter result is right
    [Tags]    B005    ying.5.chen
    clear counter files    ${False}
    Setup Xn Link To gNB
    Trigger UE attach target cell and traffic    num=16    ue_id=11
    UEs trigger HO event to redirect    ue_id1=11    ue_id2=12
    UEs trigger HO event to redirect    ue_id1=13    ue_id2=14
    UE12 and UE14 HO Back to origin cells
    Delta NRREL Parameter and set delay Xn handover response time
    Trigger interFre interGnb HO with the concurrency    ue=15
    Trigger intraFre interGnb HO with the concurrency    ue=14    
    Verify Throughput    ue_id=12
    Release UEs    ue_type=all
    Check Counters    pm_counters_expression=${PM_Counters_B005}


CB010217-ET-B001_verify_Emergency_Service_Fallback_actVoiceFallbackDuringHOPrep_disable_or_enable_Xn_HO_Preparation_and_Execution_phase
    [Documentation]
    ...    1. This user scenario verifies Emergency Fallback enable that during the XN-HO preparation phase,
    ...       after triggering Emergency Fallback, EPS fallback behavior can be triggered,
    ...       during the XN-HO execution phase, EPS fallback behavior cannot be triggered.
    ...    2. Precondition:
    ...         Real gnb-2: cell-1: TDD, pci: 50, nrarfcn=633364, ssbFrequency=633216
    ...                     cell-2: TDD, pci: 51, nrarfcn=633508, ssbFrequency=633408
    ...         sim gnb-3: cell-1: TDD, pci: 381, nrarfcn=633508, ssbFrequency=633408
    ...         location on cell1: UE 1,3
    ...         location on cell2: UE 2,4
    ...         UECapability Support LTE bands: UE 1,2
    ...         actVoiceFallbackDuringHOPrep=disabled
    ...    3. Test Case Steps:
    ...         a. setup XN link up
    ...         b. Holding Xn handover response message with 5S
    ...         c. UE1-4 attach to target cells -> setup pdu -> trigger A2/A3 to HO -> gNB received NGAP:UeContextModificationRequest
    ...         d. update actVoiceFallbackDuringHOPrep=voiceFallbackDuringXnHOPrep to enable feature
    ...         e. UE1-4 HO back to original cells.
    ...         f. UE1-4 trigger A2/A3 to HO -> gNB received NGAP:UeContextModificationRequest
    ...         g. UE3/4 HO back to orig cell.
    ...         h. Reset Xn handover Preparation Param, and set Response message delay of RRC Reconfiguration for 5S
    ...         i. UE4 update capability to support Redirection targets
    ...         j. UE3-4 trigger HO -> gNB received NGAP:UeContextModificationRequest
    ...         k. check counter
    ...     4. Test Expected Result:
    ...         c. UE1-4: Does not trigger redirection, cause by feature disabled, HO from source Real gNB to sim gNB successfully.
    ...                   Source gNB send NGAP:UeContextModificationRequestFailure with cause "xn-handover-triggered"
    ...         f. UE3/4: Does not trigger redirection, casue by UE not support LTE band, HO from source Real gNB to sim gNB successfully.
    ...                   Source gNB send NGAP:UeContextModificationRequestFailure with cause "xn-handover-triggered"
    ...            UE1/2: Emergency Service fallback is triggered, HO cancelled with cause "procedure-cancelled"
    ...                   Source GNG send NGAP:UeContextModificationresponse,
    ...                   and UE context is released from both source and target gNB.
    ...         j. UE3-4: Does not trigger redirection, cause by Xn handover execution phase. HO successfully.
    [Tags]    B001    teana.wang
    Case Setup For A001
    Clear Counter Files
    Setup Xn Link To gNB
    Delay Response to Xn Handover Preparation
    UEs Attach to Target Cell and Setup PDU Session    ue_id=1     num=5
    UE1-4 Perform Service Request during Inter-GNB HO Preparation based Feature Disabled
    Delta Commission Parameters    ${ENABLE_CB010217}
    UE1-4 HO Back to Origin Cell
    UE1-4 Perform Service Request during Inter-GNB HO Preparation based Feature Enabled
    Reset Xn Handover Preparation Param
    # UE3-4 Perform Service Request during Inter-GNB HO Execution based Feature Enabled
    Release UEs    ue_type=all
    Check Counters    pm_counters_expression=${PM_Counters_B001}

*** Keywords ***
Modify Cfg
    ${set_amf1}    catenate    amf_param id=1 full_nas_auth=on nia=snow3g+zuc+aes+null nea=snow3g+zuc+aes+null
    ...    emergency_service_fallback=on target_cn=epc
    Update Cfg    ${set_amf1}
    FOR    ${ue_id}    IN    @{UES_ON_CELL2}
        Update Cfg Param    set_ue simulated id=${ue_id} enb=2 cell=2
    END
    FOR    ${ue_id}    IN    @{UES_NOT_SUPPORT_LTE}
        Update Cfg    ue_param id=${ue_id} ue_nr_capabilities=${SA_UE_Not_Support_LTE_Capabilities}
    END
    ${ue11_param}    catenate    ue_param id=11 ue_nr_capabilities=${SA_UE_Support_CGI_LTE_Capabilities}
    Update Cfg    ${ue11_param}
    ${set_ue12}    catenate
    ...    set_ue simulated id=12 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645411 mode=nr enb=2 cell=2
    Update Cfg    ${set_ue12}
    ${ue13_param}    catenate    ue_param id=13 ue_nr_capabilities=${SA_UE_Support_CGI_LTE_Capabilities}
    Update Cfg    ${ue13_param}
    ${set_ue14}    catenate
    ...    set_ue simulated id=14 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645413 mode=nr enb=2 cell=2
    Update Cfg    ${set_ue14}
    ${ue14_param}    catenate    ue_param id=14 ue_nr_capabilities=${SA_UE_Support_CGI_LTE_Capabilities}
    Update Cfg    ${ue14_param}
    ${ue15_param}    catenate    ue_param id=15 ue_nr_capabilities=${SA_UE_Support_LTE_Capabilities}
    Update Cfg    ${ue15_param}
    ${set_gnb2}    catenate
    ...    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x01:22 daemon=10.0.2.1:22222
    ...    xn=10.0.1.2 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${set_gnb2}
    ${set_gnb2_cell1}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=633364:633364 gscn=7845 mandatory_for_activation=off
    Update Cfg    ${set_gnb2_cell1}
    ${set_gnb2_cell2}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=633508:633508 gscn=7847 mandatory_for_activation=off
    Update Cfg    ${set_gnb2_cell2}
    ${set_gnb3}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1 plmnList=311:489
    Update Cfg    ${set_gnb3}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false measEvent=A3
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999
    ...    nr_arfcn=633508:633508 gscn=7847 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}

Setup Xn Link To gNB
    [Arguments]    ${gnb_id}=3
    execute egate command    gnb_param id=${gnb_id} xn_listening_socket=1 send_xn_setup=true sib1_period=160ms
    execute egate command    gnb_xn_link_up gnb=${gnb_id} target=2    GNB-${gnb_id}: XnAP Link with GNB-2 .* is up

Delay Response to Xn Handover Preparation
    Execute Egate Command    gnb_xn_handover_preparation_param id=3 action=delayed_rsp time_to_wait=v5s

Reset Xn Handover Preparation Param
    Execute Egate Command    gnb_xn_handover_preparation_param id=3 reset

UEs Attach to Target Cell and Setup PDU Session
    [Arguments]    ${num}=5    ${ue_id}=1    ${pdu_id}=1    ${pass_regexp}=QoS Routing Table
    FOR    ${ue_id}    IN RANGE    ${ue_id}    ${num}
        Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
        Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
        Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1     pass_regexp=${pass_regexp}
    END

UEs trigger HO event to redirect
    [Arguments]    ${ue_id1}=11    ${ue_id2}=12
    Trigger interFreANR with the concurrency    ${ue_id1}
    Trigger UE from Cell2 to SIM Cell by A3    ${ue_id2}
    Wait Until Keyword Succeeds    20min    10s    Object Should Not Exist    NRBTS-1/NRCELL-1/NRREL-256:gNbId=35

Trigger interFre interGnb HO with the concurrency
    [Arguments]     ${ue}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=633216    event_type=A2
    ${A2_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid} event=A2 srsrp_nr=7 srsrq_nr=7
    ${ret1}=    execute_egate_command    ${A2_Event}    rrcReconfigurationComplete    timeout=20s
    ${measid1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=633408    event_type=A3
    ${A3_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid1} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    ${ret1}=    execute_egate_command    ${A3_Event}    pass_regexp=SNStatusTransfer in WAIT HANDOVER REQUEST    timeout=20s
    execute_egate_command    ue_conn_service_req id=${ue} service_type=emergency_services_fallback
    ...   pass_regexp=${RecvResponse_and_RedirectToLTE}


Trigger UE attach target cell and traffic
    [Arguments]    ${num}=6    ${ue_id}=1
    UEs Attach to Target Cell and Setup PDU Session    ${num}    ${ue_id}
    FOR    ${index}    IN RANGE    ${ue_id}    ${num}
        Send Throuput     ue_id=${index}
        Verify Throughput    ue_id=${index}
    END

Send Throuput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=130    ${Tput_ul}=40    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}



Trigger intraFre interGnb HO with the concurrency
    [Arguments]     ${ue}
    ${measid1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=633408    event_type=A3
    ${A3_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid1} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    ${ret1}=    execute_egate_command    ${A3_Event}    pass_regexp=SNStatusTransfer in WAIT HANDOVER REQUEST    timeout=20s
    execute_egate_command    ue_conn_service_req id=${ue} service_type=emergency_services_fallback
    ...   pass_regexp=${RecvResponse_and_RedirectToLTE}

Trigger interFreANR with the concurrency
    [Arguments]    ${ue_id1}=11
    ${meas_id_A2}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id1}    carrierfreq=633216    event_type=A2
    ...    threshold=34
    Execute Egate Command    ue_measurement_send_nr id=${ue_id1} meas_id=${meas_id_A2} event=A2 srsrp_nr=10 srsrq_nr=10
    ...    rrcReconfigurationComplete
    ${meas_id_A3}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id1}    carrierfreq=633408    event_type=A3
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id1} if_contains=report_cgi anr_cgi_delay=2000ms
    ${cmd1}=    Set Variable    ue_measurement_send_nr id=${ue_id1} meas_id=${meas_id_A3} event=A3 srsrp_nr=5 srsrq_nr=5
    ${cmd2}=    Set Variable    phycell_id=381 nrsrp_nr=100 nrsrq_nr=100
    ${cmd_HO}=    Catenate    ${cmd1}    ${cmd2}
    Execute Egate Command    ${cmd_HO}    pass_regexp=Hit on error cases presence=report_cgi action=none
    Execute Egate Command    ue_conn_service_req id=${ue_id1} service_type=emergency_services_fallback
    ...    pass_regexp=${RecvResponse_and_RedirectToLTE}

Trigger UE from Cell2 to SIM Cell by A3
    [Arguments]    ${ue_id2}=11
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id2}    carrierfreq=633408    event_type=A3
    ${A3_Event}    catenate    ue_measurement_send_nr id=${ue_id2} meas_id=${measid} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=80
    ${ret1}=    execute_egate_command    ${A3_Event}    pass_regexp=Inter-eNB handover from EXT_ENB-2.2 to ENB-3.1 performed
    Verify Throughput    ue_id=${ue_id2}

Delta NRREL Parameter and set delay Xn handover response time
    Delta Commission Parameters    ${delta_For_Nrcell_gnb3}
    Delay Response to Xn Handover Preparation

Case Setup For A001
    Delta Commission Parameters    ${PARAMS_FOR_CB010217_CASE01}
    Reset Xn Handover Preparation Param

UE1-4 Perform Service Request during Inter-GNB HO Preparation based Feature Disabled
    Perform UE Service Request during Inter-GNB Inter-Freq HO Preparation    ue_id=1
    ...    pass_regexp=${RejectRequest_and_HOSuccess_DuringHOPrepare}
    Perform UE Service Request during Inter-GNB Intra-Freq HO Preparation    ue_id=2
    ...    pass_regexp=${RejectRequest_and_HOSuccess_DuringHOPrepare}
    Perform UE Service Request during Inter-GNB Inter-Freq HO Preparation    ue_id=3
    ...    pass_regexp=${RejectRequest_and_HOSuccess_DuringHOPrepare}
    Perform UE Service Request during Inter-GNB Intra-Freq HO Preparation    ue_id=4
    ...    pass_regexp=${RejectRequest_and_HOSuccess_DuringHOPrepare}

UE1-4 Perform Service Request during Inter-GNB HO Preparation based Feature Enabled
    Perform UE Service Request during Inter-GNB Inter-Freq HO Preparation    ue_id=1
    ...    pass_regexp=${RecvResponse_and_RedirectToLTE}
    Perform UE Service Request during Inter-GNB Intra-Freq HO Preparation    ue_id=2
    ...    pass_regexp=${RecvResponse_and_RedirectToLTE}
    Perform UE Service Request during Inter-GNB Inter-Freq HO Preparation    ue_id=3
    ...    pass_regexp=${RejectRequest_and_HOSuccess_DuringHOPrepare}
    Perform UE Service Request during Inter-GNB Intra-Freq HO Preparation    ue_id=4
    ...    pass_regexp=${RejectRequest_and_HOSuccess_DuringHOPrepare}
    UE3 and UE4 HO Back to Origin Cell

UE3-4 Perform Service Request during Inter-GNB HO Execution based Feature Enabled
    Perform UE Service Request during Inter-GNB Inter-Freq HO Execution    ue_id=3
    ...    pass_regexp=${RejectRequest_and_HOSuccess_DuringHOExec}
    Execute Egate Command    ue_param id=4 ue_nr_capabilities=${SA_UE_Support_LTE_Capabilities}
    Perform UE Service Request during Inter-GNB Intra-Freq HO Execution    ue_id=4
    ...    pass_regexp=${RejectRequest_and_HOSuccess_DuringHOExec}
    UE3 and UE4 HO Back to Origin Cell

Perform UE Service Request during Inter-GNB Inter-Freq HO Preparation
    [Arguments]    ${ue_id}    ${pass_regexp}
    BuiltIn.Log    Perform UE${ue_id} Service Request during Inter-GNB Inter-Freq HO Preparation    console=${True}
    ${a2_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633216    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a2_measid} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    ${a3_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633408    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    ...    pass_regexp=SNStatusTransfer in WAIT HANDOVER REQUEST
    Execute Egate Command    ue_conn_service_req id=${ue_id} service_type=emergency_services_fallback
    ...    pass_regexp=${pass_regexp}

Perform UE Service Request during Inter-GNB Intra-Freq HO Preparation
    [Arguments]    ${ue_id}    ${pass_regexp}
    BuiltIn.Log    Perform UE${ue_id} Service Request during Inter-GNB Intra-Freq HO Preparation    console=${True}
    ${a3_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633408    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    ...    pass_regexp=SNStatusTransfer in WAIT HANDOVER REQUEST
    Execute Egate Command    ue_conn_service_req id=${ue_id} service_type=emergency_services_fallback
    ...    pass_regexp=${pass_regexp}

Perform UE Service Request during Inter-GNB Inter-Freq HO Execution
    [Arguments]    ${ue_id}    ${pass_regexp}
    BuiltIn.Log    Perform UE${ue_id} Service Request during Inter-GNB Inter-Freq HO Execution    console=${True}
    ${a2_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633216    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a2_measid} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=5000
    ${a3_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633408    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    ...    pass_regexp=Hit on error cases presence
    Execute Egate Command    ue_conn_service_req id=${ue_id} service_type=emergency_services_fallback
    ...    pass_regexp=${pass_regexp}
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} reset

Perform UE Service Request during Inter-GNB Intra-Freq HO Execution
    [Arguments]    ${ue_id}    ${pass_regexp}
    BuiltIn.Log    Perform UE${ue_id} Service Request during Inter-GNB Intra-Freq HO Execution    console=${True}
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=5000
    ${a3_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633408    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    ...    pass_regexp=Hit on error cases presence
    Execute Egate Command    ue_conn_service_req id=${ue_id} service_type=emergency_services_fallback
    ...    pass_regexp=${pass_regexp}
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} reset

Trigger UE HO Back from Cell3-1 to Cell2-1
    [Arguments]    ${ue_id}
    ${ho_success}    create list
    ...    Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    ...    rrcReconfigurationComplete
    ...    PATH SWITCH REQUEST ACK
    ${a3_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633216    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=30 phycell_id=50 nrsrp_nr=80
    ...    pass_regexp=${ho_success}

Trigger UE HO Back from Cell3-1 to Cell2-2
    [Arguments]    ${ue_id}
    ${ho_success}    create list
    ...    Inter-eNB handover from ENB-3.1 to EXT_ENB-2.2 performed
    ...    rrcReconfigurationComplete
    ...    PATH SWITCH REQUEST ACK
    ${a3_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633408    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a3_measid} event=A3 srsrp_nr=11 phycell_id=51 nrsrp_nr=85
    ...    pass_regexp=${ho_success}

UE1-4 HO Back to Origin Cell
    FOR    ${ue_id}     IN    @{UES_ON_CELL1}
        Trigger UE HO Back from Cell3-1 to Cell2-1    ue_id=${ue_id}
    END
    FOR    ${ue_id}     IN    @{UES_ON_CELL2}
        Trigger UE HO Back from Cell3-1 to Cell2-2    ue_id=${ue_id}
    END

UE3 and UE4 HO Back to Origin Cell
    Trigger UE HO Back from Cell3-1 to Cell2-1    ue_id=3
    Trigger UE HO Back from Cell3-1 to Cell2-2    ue_id=4

UE12 and UE14 HO Back to origin cells
    Trigger UE HO Back from Cell3-1 to Cell2-2    ue_id=12
    Trigger UE HO Back from Cell3-1 to Cell2-2    ue_id=14
