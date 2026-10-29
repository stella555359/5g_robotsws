*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_FDD    SBTS00    team-Rock_SGT&A    owner-ha.zheng
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    STATE_CONFIGURED    RAN_5G
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri
${5qi1_UE_Capabilities}    SEPARATOR= 
...    E1A01000074E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C39061
...    C00103278FAB80027800E0009E00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B
...    137582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C043D6C1010107
...    0EF1C39061C00103278FAA8000028000000841C4D00000000202682807008089FEAAAAA058060005038180703005807000683E0000
...    000000000E54D000100000965950034AAA8081C002C00000010020046AC4C0004080C1014181C202C4044484C648494989CA12986B
...    40
@{PARAMS_IN_SCF}
...    @{AS_ALGORITHM}
...    @{Gnb_VoNR}
...    @{Gnb_EmergencyCall}
...    @{GNB_PMQAP}
...    @{Inter_RAT_Handover}
...    @{Vonr_Emergency_Fallback}
@{AS_ALGORITHM}
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    NRBTS-1:cipherPrefL:nea0=0
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=9
@{Gnb_VoNR}

...    NRCELL:actVoNR=true
...    NRCELL:actCDrx=true
...    NRCELL:actCDrxVoNR=true
...    NRCELL:n310VoNR=n10
...    NRCELL:t310VoNR=100ms
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:drxProfile1:drxInactivityTimer=40ms
...    NRCELL:drxProfile1:drxLongCycle=40ms
...    NRCELL:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL:drxProfile2:drxInactivityTimer=40ms
...    NRCELL:drxProfile2:drxLongCycle=40ms
...    NRCELL:drxProfile2:drxOnDurationTimer=4ms
...    NRCELL:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL:drxProfile2:drxRetransTimerUl=0slot
...    NRDRB_MAC-4:lcgid=0
...    NRDRB_MAC-4:prioritisedBitRate=16kBps
...    NRDRB_MAC-4:schedulPrio=4
...    NRDRB_MAC-3:lcgid=4
...    NRDRB_MAC-3:prioritisedBitRate=16kBps
...    NRDRB_MAC-3:schedulPrio=5
...    NRDRB_MAC-3:schedulBSD=50ms
...    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRDRB-10:resType=nonGBR_Signaling
...    NRDRB-15:discardTimer=infinity
...    NRDRB-15:dlFlowControlAlgo=none
...    NRDRB-15:dscp=0
...    NRDRB-15:durationThresDiscardDl=40
...    NRDRB-15:durationThresDiscardUl=20
...    NRDRB-15:actDddsReduction=false
...    NRDRB-15:actLostPduFastRetx=false
...    NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRDRB-15:maxDataRateGbrDl=1000
...    NRDRB-15:maxDataRateGbrUl=1000
...    NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-15:numSduDiscard=1
...    NRDRB-15:queuingDelayDiscarding=Disabled
...    NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRDRB-15:resType=GBR
...    NRDRB-15:rlcMode=RLC_UM
...    NRDRB-15:schedulWeight=1
...    NRDRB-15:sduDiscardIntervalTmr=100
...    NRDRB-15:volThresDiscardDl=8000
...    NRDRB-15:volThresDiscardUl=800
...    NRDRB_5QI-6:fiveqiValueList=1
...    NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
@{Gnb_EmergencyCall}
...    NRBTS:tRLFindForDUVoNR=500ms
...    NRBTS:drbInactivityTimerSA=7200
...    NRBTS:rrcReestabTypeSA=viaRRCSetup
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXHighQ=0
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXLowQ=0
...    NRCELL:actEmergencyCall=true
...    NRCELL:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL:emergencyCallLimServ=true
...    NRCELL:maxGBRTrafficLimit=30
...    NRCELL:arpPrioEmergencyCall=1
...    NRBTS:actEmergencyFallback=false
...    NRBTS:actNormVCFallback=false
...    NRCELL:emergencyCallFails=true
...    NRCELL:maxNumOfNonGBRBearersSA=500
...    NRCELL:maxNumOfRrcSA=10
...    NRCELL:numOfRadioResReservForEmergency=1
...    NRCELL:sMeasConfigSsbRsrp=0
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRDU-1:numOfDrbsReservForEmergency=2
...    NRCELL/NRREDRT-1:redirFreqEutra=1350
...    NRCELL/NRREDRT-1:redirPrio=1
...    NRCELL/NRREDRT-1:redirRat=eutra
...    delete:NRCELL/NRREDRT-1:redirSsbScs
@{GNB_PMQAP}
...    NRBTS:actNrpmqapProfiles=true
...    NRPMRNL-1:miNrHighRlcCellNrpmqap=15min
...    NRPMRNL-1:miNrNgInterfaceNrpmqap=15min
...    NRPMRNL-1:miNrNsaAcCuNrpmqap=15min
...    NRPMRNL-1:miNrPdcpCellNrpmqap=15min
...    NRPMRNL-1:miNrSaCuNrpmqap=15min
...    NRPMRNL-1:miNrUeStatNrpmqap=15min
...    NRPMRNL-1:miNrX2ccNrpmqap=15min
...    NRPMRNL-1/NRPMQAP-1:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=5,1
...    NRPMRNL-1/NRPMQAP-1:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sd=13714341
...    NRPMRNL-1:miNrRelReportCu=15min
@{Intrafrequency_Intra_Gnb_Handover}
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL:a3MeasEnabled=rsrp
@{Intrafrequency_Intra_Inter_Gnb_HO}
...    NRBTS:actIncXn=true
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNodeBId=35
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mncLength=3
...    NRADJGNB-1:gnbPlmn:mcc=311
...    NRADJGNB-1:gnbPlmn:mnc=489
...    XNLINK-1:cPlaneIpAddr=10.0.1.124
...    NRCELL/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL/NRREL-2:gNbId=35
...    NRCELL/NRREL-2:gNbIdLength=22
...    NRCELL/NRREL-2:handoverAllowedSA=allowed
...    NRCELL/NRREL-2:removeNotAllowed=false
...    NRCELL/NRREL-2:lcrId=1
...    NRCELL/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL/NRREL-2:gnbPlmn:mcc=311
...    NRCELL/NRREL-2:gnbPlmn:mnc=489
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:fiveGsTac=0
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=489
@{Inter_RAT_Handover}
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actMFBIEutra=true
...    NRBTS:actInterRatHoSA=true

...    NRBTS:excludedEutranCellPeriod=10
...    NRBTS:excludedEutranCellThreshold=5
...    NRBTS:excludedEutranCellTimeWindow=10
...    NRCELL:a1MeashoEnabledSA=rsrpCombined
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    NRCELL:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=31
...    NRCELL:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=2
...    NRCELL:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=31
...    NRCELL:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480
...    NRCELL:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:a1MeashoEnabled=rsrp
...    NRCELL:a2MeashoEnabled=none
...    NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRHOIR-1:earfcnValue=1400
...    NRHOIR-1:presenceAntennaPort1=false
...    NRHOIR-1:reportAmount=r8
...    NRHOIR-1:reportInterval=ms240
...    NRHOIR-1:b2MeashoEnabled=rsrp
...    NRHOIR-1:b2Threshold1hoRsrp=35
...    NRHOIR-1:b2Threshold1hoRsrq=50
...    NRHOIR-1:b2Threshold1hoRsrpVoNr=35
...    NRHOIR-1:allowedMeasBandwidth=mbw50
...    NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18
...    NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2
...    NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=0
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=18
...    NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrpVoNr=ms480
...    NRBTS-1/NRADJECELL-1:eNodeBId=18
...    NRBTS-1/NRADJECELL-1:ePSTrackingAreaCode=100
...    NRBTS-1/NRADJECELL-1:earfcnValue=1400
...    NRBTS-1/NRADJECELL-1:lcrId=1
...    NRBTS-1/NRADJECELL-1:physCellId=11
...    NRBTS-1/NRADJECELL-1:ecgiPlmn:mcc=311
...    NRBTS-1/NRADJECELL-1:ecgiPlmn:mnc=489
...    NRBTS-1/NRADJECELL-1:ecgiPlmn:mncLength=3
...    NRBTS-1/NRADJECELL-1:enbPlmn:mcc=311
...    NRBTS-1/NRADJECELL-1:enbPlmn:mnc=489
...    NRBTS-1/NRADJECELL-1:enbPlmn:mncLength=3
...    NRCELL/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL/NRRELE-1:eNodeBId=18
...    NRCELL/NRRELE-1:eutranCellExcluded=false
...    NRCELL/NRRELE-1:lcrId=1
...    NRCELL/NRRELE-1:ecgiPlmn:mcc=311|mncLength=3
...    NRCELL/NRRELE-1:ecgiPlmn:mnc=489|mncLength=3
...    NRCELL/NRRELE-1:ecgiPlmn:mncLength=3
@{Vonr_Emergency_Fallback}
...    NRBTS:actRedirect=true
...    NRDU-1:numOfDrbsReservForEmergency=0
...    NRCELL:a2MeasRedirectEnabled=rsrp
...    NRCELL:emergencyFBMode=redirection
...    NRCELL:numOfRadioResReservForEmergency=0
...    NRMOPR_SA-1:emergencyCallFails=redirection
@{maxNumOfGBRBearersSA_1}
...    NRCELL:maxNumOfGBRBearersSA=1
...    NRBTS:actRedirect=true
@{maxNumOfGBRBearersSA_2}
...    NRCELL:maxNumOfGBRBearersSA=10
...    NRBTS:actRedirect=false
@{drbInactivityTimer}
...    NRBTS:activityNotificationLevelSA=drb
...    NRBTS:drbInactivityTimerSA=60
...    NRBTS:drbInactivityTimerSA5qi1=30
...    NRBTS:drbInactivityTimerSA5qi5=30
...    NRBTS:srbInactivityTimerSA=60
@{del_drbInactivityTimer}
...    NRBTS:drbInactivityTimerSA5qi1=0
...    NRBTS:drbInactivityTimerSA5qi5=0
#D001
${NG_FLOW_REL_GNB_REDIRECT_5QI1}    M55125C09502
${NG_FLOW_REL_GNB_REDIRECT_PMQAP}    M55163C00503
${NG_FLOW_STP_FAIL_FALBACK_PMQAP}    M55163C00501
${NG_FLOW_STP_FAIL_FALBACK_5QI1}    M55125C09519
${NG_FLOW_CONNECTED_SESSION_TIME}    M55125C09516
${NG_FLOW_REL_NORMAL_5QI1}    M55125C09514
${NG_FLOW_SESSION_DUR_NORM_5QI1}    M55125C09526
${NG_FLOW_REL_AMF_NORMAL_PMQAP}     M55163C00519
${NG_FLOW_REL_GNB_REDIRECT}    M55125C09002
@{PM_Counters_Check_gnb_redirect}
...    NRCELL-1:${NG_FLOW_REL_GNB_REDIRECT_5QI1}=1
...    NRCELL-1:${NG_FLOW_REL_GNB_REDIRECT_PMQAP}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_STP_FAIL_FALBACK_PMQAP}=2
...    NRCELL-1:${NG_FLOW_STP_FAIL_FALBACK_5QI1}=1
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1                       
...    NRCELL-1:${NG_FLOW_REL_NORMAL_5QI1}=1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_NORM_5QI1}>0
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
@{PM_Counters_Check_vonr_redirect}
...    NRCELL-1:${NG_FLOW_REL_GNB_REDIRECT_5QI1}=1
...    NRCELL-1:${NG_FLOW_REL_GNB_REDIRECT_PMQAP}=2
...    NRCELL-1:${NG_FLOW_REL_GNB_REDIRECT}=2
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_REL_NORMAL_5QI1}=1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_NORM_5QI1}>0
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL_5QI1}=0
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
#D002
${NG_FLOW_REL_GNB_UE_LOST_5QI1}    M55125C09505
${NG_FLOW_REL_GNB_UE_LOST}    M55125C09005
${NG_FLOW_REL_GNB_UE_LOST_PMQAP}    M55163C00506
${NG_FLOW_REL_AMF_OTHER_5QI1}    M55125C09513
${NG_FLOW_REL_AMF_NORMAL}    M55125C09019
${NG_FLOW_REL_ABNORMAL_5QI1}    M55125C09515
${NG_FLOW_SESSION_DUR_ABNRM_5QI1}    M55125C09527
@{PM_Counters_Check_UE_Lost}
...    NRCELL-1:${NG_FLOW_REL_GNB_UE_LOST_5QI1}=1
...    NRCELL-1:${NG_FLOW_REL_GNB_UE_LOST}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_GNB_UE_LOST_PMQAP}=2
...    NRCELL-1:${NG_FLOW_REL_NORMAL_5QI1}=0
...    NRCELL-1:${NG_FLOW_REL_AMF_OTHER_5QI1}=0
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_REL_ABNORMAL_5QI1}=1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_ABNRM_5QI1}>1
#D003
${NG_FLOW_REL_GNB_UE_INACT_5QI1}    M55125C09504
${NG_FLOW_REL_GNB_UE_INACTIVITY}    M55125C09004
${NG_FLOW_REL_GNB_UE_INACT_PMQAP}    M55163C00505
${NG_FLOW_REL_AMF_NORMAL_5QI1}    M55125C09512
${NG_FLOW_REL_NORMAL}    M55125C08504
${NG_FLOW_REL_NORMAL_PMQAP}    M55163C00004
@{PM_Counters_Check_UE_Inactive}
...    NRCELL-1:${NG_FLOW_REL_GNB_UE_INACT_5QI1}=1
...    NRCELL-1:${NG_FLOW_REL_GNB_UE_INACTIVITY}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_GNB_UE_INACT_PMQAP}=2
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL_5QI1}=0
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_REL_NORMAL_5QI1}=1
...    NRCELL-1:${NG_FLOW_REL_NORMAL}=2
...    NRCELL-1:${NG_FLOW_REL_NORMAL_PMQAP}=2
...    NRCELL-1:${NG_FLOW_SESSION_DUR_NORM_5QI1}>0

*** Test Cases ***
CB008200-ET-D001_Verify Counter when QosFlow Release due to Redirection
    [Tags]  QC_161093    D001
    [Documentation]
    ...    1. This User scenario is to provide the counters used for measuring SA accessibility.
    ...    2. Test Case Steps:
    ...         step1. Set up VONR call in UE1(5QI1 + 5QI5 are setup successfully).
    ...         step2. Set up Emergency call fails due to RAC failure(num of GBR bearer exceed maxNumOfGBRBearersSA).
    ...         step3. Check related Counters 'PM_Counters_Check_gnb_redirect'
    ...         step4. Set up VONR call in UE2(5QI1 + 5QI5 are setup successfully).
    ...         step5. Trigger A2 Redirect
    ...         step6. Check related Counters 'PM_Counters_Check_vonr_redirect'
    delta commission parameters    ${maxNumOfGBRBearersSA_1}
    delta commission parameters    ${del_drbInactivityTimer}
    VoNR Call And Emergency Call Redirect
    VoNR Call Redirect

CB008200-ET-D002_Verify Counter when QosFlow Release due to Radio Connection With Ue Lost and related other counter
    [Tags]  QC_161094    D002
    [Documentation]
    ...    1. This User Scenario is to provide the counters used for measuring SA retainability.
    ...    2. Test Case Steps:
    ...         step1. Set up VONR call in UE3.
    ...         step2. Set ue_nr_rrc_reconf_param action=drop.
    ...         step3. Trigger A2 measurement Report and UE is idle.
    ...         step4. Check related Counters 'PM_Counters_Check_UE_Lost'.
    ...         step5. Set up VONR call in UE4.
    ...         step6. Set ue_nr_rrc_reconf_param action=reestablish cause=reconfigurationFailure.
    ...         step7. Trigger PDU session release.
    ...         step8. Check related Counters 'PM_Counters_Check_UE_Lost'.
    delta commission parameters    ${maxNumOfGBRBearersSA_2}
    VoNR Call Lost due to drop
    VoNR Call Lost due to reconf failure

CB008200-ET-D003_Verify Counter when QosFlow Release due to User Inactivity and related other counter
    [Tags]  QC_161095    D003
    [Documentation]
    ...    1. This User Scenario is to provide the counters used for measuring SA retainability.
    ...    2. Test Case Steps:
    ...         step1. Set up VONR call in UE5.
    ...         step2. Wait 35s until ue drbInactivityTimerSA5qi1 and drbInactivityTimerSA5qi5 timeout, ue is idle.
    ...         step3. Check related Counters 'PM_Counters_Check_UE_Inactive'
    delta commission parameters    ${maxNumOfGBRBearersSA_2}
    delta commission parameters    ${drbInactivityTimer}
    VoNR Call Inactive due to inactive Time out

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15
    #Debug Enter Into Egate

Modify Cfg 
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=9
    Update Cfg    set_qosflow id=2 5qi=1 ue=1-12
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-12 qos_flows=3,2,1 qos_rules=1,2 amf=1-6
    Update Cfg    ue_nr_capabilities id=1-12 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc voice_fallback=on
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1-12 qos_flows=3,2,1 qos_rules=1,2 amf=1-6
    ${gnb3_info}    Catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124
    ...    nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${gnb3_info}
    Update Cfg    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666 gscn=7880
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=true
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all send_ho_ack=on
    Update Cfg    set_gnb id=6 type=simulated plmn=311:489 ng=10.0.1.13 daemon=10.0.2.1:22222 gnb_id=0x12:28 nssai=0x01:0xD143A5 x2_peers=none amf=1
    ${gnb6_cell1_info}    Catenate
    ...    set_cell id=1 gnb=6 pci=3:2 nrci=0x01 tac=100 proxy=10.0.2.1:12218 earfcn=1400:19400 technology=lte tdd_cell=on
    ...    mandatory_for_activation=off
    Update Cfg    ${gnb6_cell1_info}
    Update Cfg    gnb_param id=6 xn_listening_socket=off
    Update Cfg    ue_param id=1-12 nr_usage_setting=voice_centric ue_nr_capabilities=${5qi1_UE_Capabilities}
    Update Cfg    set_pdu_gateway id=7 ue_nat_ip=72.23.6.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1 
    Update Cfg    set_pdu_gateway id=8 ue_nat_ip=72.23.7.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1 
    Update Cfg    set_pdu_gateway id=9 ue_nat_ip=72.23.8.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1 
    Update Cfg    set_pdu_gateway id=10 ue_nat_ip=72.23.9.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1 
    Update Cfg    set_pdu_gateway id=11 ue_nat_ip=72.23.10.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=12 ue_nat_ip=72.23.11.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1

UE Register And Add Pdu With Default 5QI5
    [Arguments]    ${ue_id}    ${type}=${EMPTY}
    Run Keyword If    '${type}'=='emergency'    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Execute Egate Command    ue_register id=${ue_id} nwslice=1  pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${cmd}=    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    ${cmd_emergency}=    Catenate    ${cmd}    request_type=initial-emergency-request
    ${ret}=    Run Keyword If    '${type}'=='emergency'    Execute Egate Command    ${cmd_emergency}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1
    ...    ELSE
    ...    Execute Egate Command    ${cmd}    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1
  
PDU Add QoSFlow 5QI1
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf    pass_regexp=Added QosFlow with QFI:2 fiveQI:1

Start Data Trf
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 mbps=10 dir=dl    pass_regexp=Started Downlink Internal traffic

PDU Setup with QoSFlow 5QI5 and 5QI1 fail
    [Arguments]    ${ue_id}    ${pdu_id}=2
    Execute Egate Command    smf_param id=${ue_id} additional_qosflows_to_activate=2
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${pdu_id} request_type=initial-emergency-request
    ...    pass_regexp=UE Context Release Complete
    should contain    ${ret1}    redirectedCarrierInfo eutra
    should contain    ${ret1}    eutraFrequency 1350
  
VoNR Call And Emergency Call Redirect
    Clear Counter Files  
    Execute Egate Command    qosflow_modify qos_flow=1 priority=15
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15
    UE Register And Add Pdu With Default 5QI5    ue_id=1
    PDU Add QoSFlow 5QI1    ue_id=1
    Execute Egate Command    qosflow_modify qos_flow=1 priority=1
    Execute Egate Command    qosflow_modify qos_flow=2 priority=1
    PDU Setup with QoSFlow 5QI5 and 5QI1 fail    ue_id=1
    Check Counters    ${PM_Counters_Check_gnb_redirect}
    Release Ues  ue_type=all

VoNR Call Redirect
    Clear Counter Files
    Execute Egate Command    qosflow_modify qos_flow=1 priority=15
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15
    Execute Egate Command    smf_param id=1 reset
    UE Register And Add Pdu With Default 5QI5    ue_id=2
    PDU Add QoSFlow 5QI1    ue_id=2
    Trigger A2 Redirect    ue_id=2
    Check Counters    ${PM_Counters_Check_vonr_redirect}
    Release Ues  ue_type=all

Trigger A2 Redirect
    [Arguments]    ${ue_id}
    ${ret1}=    Execute Egate Command   ue_measurement_send_nr id=${ue_id} meas_id=2 event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=IS IDLE
    should contain    ${ret1}    UE Context Release Complete
    should contain    ${ret1}    redirectedCarrierInfo eutra
    should contain    ${ret1}    eutraFrequency 1350

Trigger A2 Measurement Report
    [Arguments]    ${ue_id}
    ${a2cmd}=    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7 srs_result=0:7:7:0 phycell_id=50
    ...    nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    ${ret1}=     Execute Egate Command    ${a2cmd}    pass_regexp=IS IDLE
    should contain    ${ret1}    UE Context Release Complete

VoNR Call Lost due to drop
    Clear Counter Files
    Execute Egate Command    qosflow_modify qos_flow=1 priority=15
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15
    Execute Egate Command    smf_param id=1 reset
    UE Register And Add Pdu With Default 5QI5    ue_id=3
    Start Data Trf    ue_id=3
    PDU Add QoSFlow 5QI1    ue_id=3
    Set Action Of Rrc Reconf Param    ue_id=3    action=drop
    Trigger A2 Measurement Report    ue_id=3
    Check Counters    ${PM_Counters_Check_UE_Lost}
    Release Ues  ue_type=all

VoNR Call Lost due to reconf failure
    Clear Counter Files
    Execute Egate Command    qosflow_modify qos_flow=1 priority=15
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15
    Execute Egate Command    smf_param id=1 reset
    UE Register And Add Pdu With Default 5QI5    ue_id=4
    Start Data Trf    ue_id=4
    PDU Add QoSFlow 5QI1    ue_id=4
    Set Action Of Rrc Reconf Param    ue_id=4    action=reestablish cause=reconfigurationFailure
    Trigger Pdu Session Release    ue_id=4
    Check Counters    ${PM_Counters_Check_UE_Lost}
    Release Ues  ue_type=all

Set Action Of Rrc Reconf Param
    [Arguments]    ${ue_id}    ${action}
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=${action}    sleep_time=2

Trigger Pdu Session Release
    [Arguments]    ${ue_id}
    ${ret1}=     Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1 by=ue
    ...    pass_regexp=UE CONTEXT RELEASE COMPLETE
    should contain    ${ret1}    reestablishmentCause reconfigurationFailure

VoNR Call Inactive due to inactive Time out
    Clear Counter Files
    Execute Egate Command    qosflow_modify qos_flow=1 priority=15
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15
    Execute Egate Command    smf_param id=1 reset
    UE Register And Add Pdu With Default 5QI5    ue_id=5
    PDU Add QoSFlow 5QI1    ue_id=5
    Wait A While    ue_id=5    InactivityTimer=35s
    Check Counters    ${PM_Counters_Check_UE_Inactive}
    Release Ues    ue_type=all

Wait A While
    [Arguments]    ${ue_id}    ${InactivityTimer}
    Start RRC Log  rrcRelease
    Sleep  ${InactivityTimer}  wait for UE inactivity
    rrc Should Contain  rrcRelease
    rrc Should Contain  UE${ue_id}: IS IDLE
