*** Settings ***
Suite Setup     Common Suite Setup And Setup Airphone Env
Suite Teardown      Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_FDD    SBTS00    team-Rock_SGT&A    owner-xiaowen.xu
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
...    NRDRB_MAC-5:lcgid=1
...    NRDRB_MAC-5:prioritisedBitRate=16kBps
...    NRDRB_MAC-5:schedulPrio=7
...    NRDRB_MAC-4:lcgid=4
...    NRDRB_MAC-4:prioritisedBitRate=16kBps
...    NRDRB_MAC-4:schedulPrio=5
...    NRDRB_MAC-3:schedulBSD=50ms
...    NRDRB_MAC-3:lcgid=0
...    NRDRB_MAC-3:prioritisedBitRate=16kBps
...    NRDRB_MAC-3:schedulPrio=4
...    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRDRB-10:resType=nonGBR_Signaling
...    NRDRB-15:discardTimer=10ms
...    NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRDRB-15:maxTransferDelayGbr=20
...    NRDRB-15:dlFlowControlAlgo=none
...    NRDRB-15:dscp=46
...    NRDRB-15:durationThresDiscardDl=40
...    NRDRB-15:durationThresDiscardUl=20
...    NRDRB-15:actDddsReduction=false
...    NRDRB-15:actLostPduFastRetx=false
...    NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-15:numSduDiscard=1
...    NRDRB-15:queuingDelayDiscarding=Disabled
...    NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRDRB-15:resType=GBR
...    NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRDRB-15:rlcMode=RLC_UM
...    NRDRB-15:schedulWeight=1
...    NRDRB-15:sduDiscardIntervalTmr=100
...    NRDRB-15:volThresDiscardDl=8000
...    NRDRB-15:volThresDiscardUl=800
...    NRDRB-15:maxDataRateGbrDl=1000
...    NRDRB-15:maxDataRateGbrUl=1000
...    NRDRB-16:discardTimer=infinity
...    NRDRB-16:dlFlowControlAlgo=none
...    NRDRB-16:dscp=34
...    NRDRB-16:durationThresDiscardDl=40
...    NRDRB-16:durationThresDiscardUl=20
...    NRDRB-16:actDddsReduction=false
...    NRDRB-16:actLostPduFastRetx=false
...    NRDRB-16:maxDddsPeriodCpuOvld=40
...    NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-16:numSduDiscard=1
...    NRDRB-16:queuingDelayDiscarding=Disabled
...    NRDRB-16:queuingDelaySduDiscardThreshold=200
...    NRDRB-16:resType=nonGBR
...    NRDRB-16:rlcMode=RLC_UM
...    NRDRB-16:schedulWeight=1
...    NRDRB-16:sduDiscardIntervalTmr=100
...    NRDRB-16:volThresDiscardDl=8000
...    NRDRB-16:volThresDiscardUl=800
...    NRDRB_5QI-6:fiveqiValueList=1
...    NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRDRB_5QI-7:fiveqiValueList=128
...    NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
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
...    NRCELL:emergencyCallFails=true
...    NRCELL:maxNumOfNonGBRBearersSA=500
...    NRCELL:maxNumOfRrcSA=10
...    NRCELL:numOfRadioResReservForEmergency=1
...    NRCELL:sMeasConfigSsbRsrp=0
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRDU-1:numOfDrbsReservForEmergency=2
...    NRCELL/NRREDRT-2:redirFreqEutra=1350
...    NRCELL/NRREDRT-2:redirPrio=2
...    NRCELL/NRREDRT-2:redirRat=eutra
...    delete:NRCELL/NRREDRT-2:redirSsbScs

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
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=9
...    NRPMRNL-1/NRPMQAP-1:cfgArpRange=15
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-2:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-2:cfg5qiRange=5,1
...    NRPMRNL-1/NRPMQAP-2:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-2:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-3:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-3:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mncLength=2
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mcc=460
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mnc=02
...    NRPMRNL-1/NRPMQAP-4:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-4:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-4:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-4:cfgSliceId:sd=13714342

@{Delete_PMQAP3_Modify_PMQAP4}
...    delete:NRPMRNL-1/NRPMQAP-3
...    NRPMRNL-1/NRPMQAP-4:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-4:cfgArpRange=15,12
...    NRPMRNL-1/NRPMQAP-4:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-4:cfgSliceId:sd=13714340

@{Recover_PMQAP4_PMQAP3}
...    NRPMRNL-1/NRPMQAP-3:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-3:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mncLength=2
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mcc=460
...    NRPMRNL-1/NRPMQAP-3:cfgPlmnId:mnc=02
...    NRPMRNL-1/NRPMQAP-4:cfgProfType=SA
...    NRPMRNL-1/NRPMQAP-4:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-4:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-4:cfgSliceId:sd=13714342

@{Delay_SctpTimeRetry}
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=180

${NG_FLOW_REL_ABNORMAL_5QI1}    M55125C09515
${NG_FLOW_REL_AMF_UE_LOST_5QI1}    M55125C09533
${NG_FLOW_REL_AMF_UE_LOST_PMQAP}    M55163C00518
${NG_FLOW_CONNECTED_SESSION_TIME}    M55125C09516
${NG_FLOW_SESSION_DUR_ABNRM_5QI1}    M55125C09527
${NG_FLOW_REL_AMF_NORMAL_5QI1}    M55125C09512
${NG_FLOW_REL_AMF_NORMAL}    M55125C09019
${NG_FLOW_REL_NORMAL_5QI1}    M55125C09514
${NG_FLOW_REL_AMF_NORMAL_PMQAP}    M55163C00519
${NG_FLOW_SESSION_DUR_NORM_5QI}    M55125C09526
${AVE_NUMBER_OF_UE_5QI1}    M55125C09528
${AVE_NUMBER_OF_UE_5QI1_DENOM}    M55125C09529
${PEAK_NUMBER_OF_UE_5QI1}    M55125C09530
${NG_FLOW_REL_AMF_OTHER}    M55125C09020
${NG_FLOW_REL_AMF_OTHER_5QI1}     M55125C09513
${NG_FLOW_REL_AMF_OTHER_PMQAP}    M55163C00520
${NG_FLOW_CON_SESSION_TIME_PMQAP}    M55163C00521

#D008 counter check list
@{PM_Counters_SA_Qosflow_Release_Due_Ue_Lost}
...    NRCELL-1:${NG_FLOW_REL_ABNORMAL_5QI1}=0
...    NRCELL-1:${NG_FLOW_REL_AMF_UE_LOST_5QI1}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_AMF_UE_LOST_PMQAP}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_AMF_UE_LOST_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_AMF_UE_LOST_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_AMF_UE_LOST_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_ABNRM_5QI1}=0
@{PM_Counters_Voice_Call_Qosflow_5QI1_Release_Due_Ue_Lost}
...    NRCELL-1:${NG_FLOW_REL_ABNORMAL_5QI1}=1
...    NRCELL-1:${NG_FLOW_REL_AMF_UE_LOST_5QI1}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_AMF_UE_LOST_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_AMF_UE_LOST_PMQAP}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_AMF_UE_LOST_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_AMF_UE_LOST_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_ABNRM_5QI1}>1
@{PM_Counters_Voice_Call_Release_Due_Ue_Lost}
...    NRCELL-1:${NG_FLOW_REL_ABNORMAL_5QI1}=1
...    NRCELL-1:${NG_FLOW_REL_AMF_UE_LOST_5QI1}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_AMF_UE_LOST_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_AMF_UE_LOST_PMQAP}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_AMF_UE_LOST_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_AMF_UE_LOST_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_ABNRM_5QI1}>1
#D008 --end

#D009 counter check list
@{PM_Counters_Voice_Call_AMF_Normal_PDU_Release}
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL_5QI1}=1
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL}=2
...    NRCELL-1:${NG_FLOW_REL_NORMAL_5QI1}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_ABNRM_5QI1}=0
...    NRCELL-1:${NG_FLOW_SESSION_DUR_NORM_5QI}>1
@{PM_Counters_Voice_Call_AMF_Normal_PDU_Modify_Release}
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL_5QI1}=1
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL}=1
...    NRCELL-1:${NG_FLOW_REL_NORMAL_5QI1}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_ABNRM_5QI1}=0
...    NRCELL-1:${NG_FLOW_SESSION_DUR_NORM_5QI}>1

#D011 counter check list
@{PM_Counters_Voice_Call_Release_Due_Other_Cause}
...    NRCELL-1:${NG_FLOW_REL_AMF_OTHER}=2
...    NRCELL-1:${NG_FLOW_REL_AMF_OTHER_5QI1}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_AMF_OTHER_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_AMF_OTHER_PMQAP}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_AMF_OTHER_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_AMF_OTHER_PMQAP}=0
...    NRCELL-1:${NG_FLOW_REL_ABNORMAL_5QI1}=1
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_CON_SESSION_TIME_PMQAP}>1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_ABNRM_5QI1}>1
@{PM_Counters_Voice_Call_Release_by_PDU_modify_Due_Other_Cause}
...    NRCELL-1:${NG_FLOW_REL_AMF_OTHER}=1
...    NRCELL-1:${NG_FLOW_REL_AMF_OTHER_5QI1}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_AMF_OTHER_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_AMF_OTHER_PMQAP}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_AMF_OTHER_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_AMF_OTHER_PMQAP}=0
...    NRCELL-1:${NG_FLOW_REL_ABNORMAL_5QI1}=1
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_CON_SESSION_TIME_PMQAP}>1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_ABNRM_5QI1}>1

#E001 counter check list
@{PM_Counters_Peak_Ave_Number}
...    NRCELL-1:${AVE_NUMBER_OF_UE_5QI1}>1
...    last NRCELL-1:${AVE_NUMBER_OF_UE_5QI1_DENOM}=${60*${PM_COUNTER_INTERVAL[:-3]}}
...    last NRCELL-1:${PEAK_NUMBER_OF_UE_5QI1}=1

@{PM_Counters_Peak_Ave_Number_After_UE_Release}
...    NRCELL-1:${AVE_NUMBER_OF_UE_5QI1}>1
...    last NRCELL-1:${AVE_NUMBER_OF_UE_5QI1_DENOM}=${60*${PM_COUNTER_INTERVAL[:-3]}}
...    last NRCELL-1:${PEAK_NUMBER_OF_UE_5QI1}=0

@{Nglink_lock}
...    SERVEDAMF-1:administrativeState=Locked
...    NRBTS:actNgcFlexSaMode=true

@{Nglink_unlock}
...    SERVEDAMF-1:administrativeState=Unlocked


*** Test Cases ***
CB008200-ET-D008_Verify Counter when AMF initiated QosFlow Release due to Radio Connnection With Ue Lost
    [Tags]  QC_161100    D08
    [Documentation]  Check NG_Flow_Release counters initiated by AMF with UE_lost.
    ...    Include :UEContextReleaseRequest,PDUSessionResourceRelease,PDUSessionResourceModifyRequest.
    ...    step1.1: setup normal call(5qi9), and release 5qi9 by PDUSessionResourceRelease  with casue=Ue Lost
    ...    step1.2: setup normal call(5qi9), and release 5qi9 by UEContextReleaseRequest  with casue=Ue Lost
    ...    step2.1: setup vonr call ,release 5qi5+5qi1 by PDUSessionResourceRelease with casue=Ue Lost
    ...    step2.2: setup vonr call ,release 5qi1 by PDUSessionResourceModifyRequest with casue=Ue Lost
    ...    step2.3: setup vonr call ,release 5qi5+5qi1 by UEContextReleaseRequest with casue=Ue Lost
    SA Call QosFlow Release With UE Lost Test
    VoNR Call QosFlow Release With UE Lost Test

CB008200-ET-D009_Verify Related Counters when AMF initiated QosFlow Release due to Normal cause
    [Documentation]
    ...    1. The purpose of this test case is to verify Related Counters when AMF initiated QosFlow Release due to Normal cause
    ...    2. Test Case Steps:
    ...         Step 1: Setup VONR  call successfully by InitialContextSetupRequest,
    ...         AMF Sends PDUSessionResourceReleaseCommand with cause "nas-normal-release"
    ...         Step 2: Setup VONR call successfully by PDUSessionResourceSetupRequest,
    ...         AMF Sends PNgAP:PDUSessionResourceModifyRequest released with cause "nas-normal-release"
    ...         Step 3: Setup VONR  call successfully by PDUSessionResourceModifyRequest,
    ...         NAS deregistration trigger, AMF Sends NGAP: UEContextReleaseCommand
    ...    3. Expected Results:
    ...         Step 1: increase the counter NG_FLOW_REL_AMF_NORMAL_PMQAP+2,
    ...                 NG_FLOW_CONNECTED_SESSION_TIME>0, NG_FLOW_REL_NORMAL_5QI1+1 ,
    ...                 NG_FLOW_SESSION_DUR_NORM_5QI>0, NG_FLOW_REL_AMF_NORMAL+2
    ...         Step 2: Result: increase the counter NG_FLOW_REL_AMF_NORMAL_PMQAP+1,
    ...                 NG_FLOW_CONNECTED_SESSION_TIME>0, NG_FLOW_REL_NORMAL_5QI1+1 ,
    ...                 NG_FLOW_SESSION_DUR_NORM_5QI>0, NG_FLOW_REL_AMF_NORMAL+1
    ...         Step 3: increase the counter NG_FLOW_REL_AMF_NORMAL_PMQAP+2,
    ...                 NG_FLOW_CONNECTED_SESSION_TIME>0, NG_FLOW_REL_NORMAL_5QI1+1,
    ...                 NG_FLOW_SESSION_DUR_NORM_5QI>0, NG_FLOW_REL_AMF_NORMAL+2
    [Tags]  QC_161101    D09
    VoNR Call AMF initiated QosFlow Normal Release by PDU release command
    VoNR Call AMF initiated QosFlow Normal Release by PDU modify request
    VoNR Call AMF initiated QosFlow Normal Release by UE context release

CB008200-ET-D011_Verify Counter when AMF initiated QosFlow Release due to Other cause
    [Documentation]
    ...    1. The purpose of this test case is to verify Related Counters when AMF initiated QosFlow Release due to Other cause
    ...    2. Test Case Steps:
    ...         Step 1: Setup VONR call successfully by InitialContextSetupRequest,
    ...         AMF Sends PDUSessionResourceReleaseCommand with other cause
    ...         Step 2: Setup VONR call successfully by PDUSessionResourceSetupRequest,
    ...         AMF Sends PNgAP:PDUSessionResourceModifyRequest released with other cause
    ...         Step 3: Setup VONR call successfully by PDUSessionResourceModifyRequest,
    ...         NAS deregistration trigger, AMF Sends NGAP: UEContextReleaseCommand
    ...    3. Expected Results:
    ...         Step 1: increase the counter:
    ...                 NG_FLOW_REL_AMF_OTHER=2, NG_FLOW_REL_AMF_OTHER_5QI1=1, NG_FLOW_REL_AMF_OTHER_PMQAP=2,
    ...                 NG_FLOW_REL_ABNORMAL_5QI1=1, NG_FLOW_CONNECTED_SESSION_TIME>1,
    ...                 NG_FLOW_CON_SESSION_TIME_PMQAP>1, NG_FLOW_SESSION_DUR_ABNRM_5QI1>1
    ...         Step 2: increase the counter:
    ...                 NG_FLOW_REL_AMF_OTHER=1, NG_FLOW_REL_AMF_OTHER_5QI1=1, NG_FLOW_REL_AMF_OTHER_PMQAP=1,
    ...                 NG_FLOW_REL_ABNORMAL_5QI1=1, NG_FLOW_CONNECTED_SESSION_TIME>1,
    ...                 NG_FLOW_CON_SESSION_TIME_PMQAP>1, NG_FLOW_SESSION_DUR_ABNRM_5QI1>1
    ...         Step 3: increase the counter:
    ...                 NG_FLOW_REL_AMF_OTHER=2, NG_FLOW_REL_AMF_OTHER_5QI1=1, NG_FLOW_REL_AMF_OTHER_PMQAP=2,
    ...                 NG_FLOW_REL_ABNORMAL_5QI1=1, NG_FLOW_CONNECTED_SESSION_TIME>1,
    ...                 NG_FLOW_CON_SESSION_TIME_PMQAP>1, NG_FLOW_SESSION_DUR_ABNRM_5QI1>1
    [Tags]  QC_161102    D11    owner-hao.6.zhang
    VoNR Call AMF initiated QosFlow Release by PDU release command With Other Cause
    VoNR Call AMF initiated QosFlow Release by PDU modify request With Other Cause
    VoNR Call AMF initiated QosFlow Release by UE context release With Other Cause

CB008200-ET-E001_Verify Average and Peak Number of Connected 5QI-1 Ues
    [Documentation]
    ...    1. The purpose of this test case is to verify Average and Peak Number of Connected 5QI-1 Ues
    ...    2. Test Case Steps:
    ...         Step 1: Setup 1 video call(5QI-5+5QI-1+5QI-2) by InitialContextSetupRequest successfully,
    ...         Step 2: last for 1 minute, release ue
    ...         Step 3: 02934837_EDA_Lock_AMF_Then_Modify_NRPMQAP,Fault 7506 Should not Raised.
    ...         Step 4: 03286866_EDA_Drop_NgLink_Then_Modify_NRPMQAP,Fault 7506 Should not Raised.
    ...    3. Expected Results:
    ...         Step 1: increase the counter AVE_NUMBER_OF_UE_5QI1>1
    ...                 AVE_NUMBER_OF_UE_5QI1_DENOM=60
    ...                 PEAK_NUMBER_OF_UE_5QI1=1
    ...         Step 2: increase the counter AVE_NUMBER_OF_UE_5QI1>1
    ...                 AVE_NUMBER_OF_UE_5QI1_DENOM=60
    ...                 PEAK_NUMBER_OF_UE_5QI1=1
    ...         Step 3: Fault 7506 Should not Raised,Cell Should Be Barred.
    ...         Step 4: Fault 7506 Should not Raised,Cell Should Be Barred.
    [Tags]  QC_161103    E01    owner-qimao
    Video Call Setup
    Sleep    60s   #call lasting time
    Video Call Release
    02934837_EDA_Lock_AMF_Then_Modify_NRPMQAP
    03286866_EDA_Drop_NgLink_Then_Modify_NRPMQAP
    [Teardown]    8200_E001_Teardown

*** Keywords ***
#common suite keyword
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri  ue_count=15
#    Debug Enter Into Egate

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=9
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=tcp qos_flow=3
    Update Cfg    set_qosrule id=4 proto=udp qos_flow=4
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-11 qos_flows=4,3,2,1 qos_rules=1,2,3,4 amf=1-6
    Update Cfg    ue_nr_capabilities id=1-11 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1-11 qos_flows=4,3,2,1 qos_rules=1,2,3,4 amf=1-6

    Update Cfg    ue_param id=1-11 nr_usage_setting=voice_centric ue_nr_capabilities=${5qi1_UE_Capabilities}
    Update Cfg    set_pdu_gateway id=7 ue_nat_ip=72.23.6.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=8 ue_nat_ip=72.23.7.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=9 ue_nat_ip=72.23.8.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=10 ue_nat_ip=72.23.9.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=11 ue_nat_ip=72.23.10.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1

8200_E001_Teardown
    Recover PMQAP
    Common Test Teardown And Stop Capture Logs

02934837_EDA_Lock_AMF_Then_Modify_NRPMQAP
    Lock NG Link
    Modify PMQAP and Fault 7506 Should not Exist
    Cell Should Be Barred
    UnLock NG Link
    Recover PMQAP
    Fm Fault Should Not Exist    fault_id=7506

03286866_EDA_Drop_NgLink_Then_Modify_NRPMQAP
    Drop Ng Link And Cell Barred
    Modify PMQAP and Fault 7506 Should not Exist
    Wait Until Keyword Succeeds    5min    10s    Cells Should Be Onair
    Recover PMQAP
    Fm Fault Should Not Exist    fault_id=7506

Lock NG Link
    Delta Commission Parameters    ${Nglink_lock}
    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Inactive

UnLock NG Link
    Delta Commission Parameters    ${Nglink_unlock}
    Wait Until Keyword Succeeds    5min    10s    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    Cells Should Be Onair

Drop Ng Link And Cell Barred
    Delta Commission Parameters    ${Delay_SctpTimeRetry}
    execute egate command    link_drop link=ng by=amf:1 to=gnb:2 msg_type=shutdown    NG Link Drop
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Inactive
    Cell Should Be Barred

Modify PMQAP and Fault 7506 Should not Exist
    Delta Commission Parameters    ${Delete_PMQAP3_Modify_PMQAP4}
    Fm Fault Should Not Exist    fault_id=7506

Cell Should Be Barred
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:barringStatus=barred
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-2:barringStatus=barred

Recover PMQAP
    Delta Commission Parameters    ${Recover_PMQAP4_PMQAP3}


UE Register And Add Pdu With Default 5QI5
    [Arguments]    ${ue_id}    ${type}=${EMPTY}
    Run Keyword If    '${type}'=='emergency'    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    ue_register id=${ue_id} nwslice=1  pass_regexp=Received REGISTRATION COMPLETE
    ${cmd}=    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    ${cmd_emergency}=    Catenate    ${cmd}    request_type=initial-emergency-request
    ${ret}=    Run Keyword If    '${type}'=='emergency'    Execute Egate Command    ${cmd_emergency}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1
    ...    ELSE
    ...    Execute Egate Command    ${cmd}    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1

SA UE Register And Add Pdu With Default 5QI9
    [Arguments]    ${ue_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    ue_register id=${ue_id} nwslice=1    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 9 qfi 1

PDU Add QoSFlow 5QI1
    [Arguments]    ${ue_id}    ${pdu}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=2 by=amf  pass_regexp=Added QosFlow with QFI:2 fiveQI:1

PDU Session Release
    [Arguments]    ${ue_id}    ${pdu}=1    ${cause}=RN_radio_connection_with_ue_lost
    Execute Egate Command    ue_pdu_release_param_amf cause=${cause} ue=${ue_id} id=1
    ${cmd}=    Set Variable    ue_pdu_session_release pdu=${pdu} ue=${ue_id} by=amf
    Execute Egate Command    ${cmd}    pass_regexp=AMF-1: Successfully released PDU Session with ID ${pdu} in SMF

PDU Session Modify to release QoSFlow
    [Arguments]    ${ue_id}    ${pdu}=1    ${qosflows_to_del}=2    ${cause}=RN_radio_connection_with_ue_lost
    Execute Egate Command    amf_ue_pdu_modify_param id=1 ue=${ue_id} action=override_ie qos_flow_to_del_cause=${cause}
    ${cmd_modify}=    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=${qosflows_to_del} by=amf
    Execute Egate Command    ${cmd_modify}    pass_regexp=Received Pdu Session Resource Modify Response Message

Ue Deregister
    [Arguments]    ${ue_id}    ${cause}=RN_radio_connection_with_ue_lost
    Execute Egate Command    amf_ue_ctx_release_param id=1 action=override_cause cause=${cause}
    ${cmd_Deregister}=    Set Variable    ue_deregister id=${ue_id} ue_deregister_type=switch_off
    Execute Egate Command    ${cmd_Deregister}    pass_regexp=AMF-1: UE CONTEXT RELEASE COMPLETE: gNB=2

UE Register And Add Pdu With 5QI5 and 5QI1
    [Arguments]    ${ue_id}    ${type}=${EMPTY}
    Run Keyword If    '${type}'=='emergency'    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2
    Execute Egate Command    ue_register id=${ue_id} nwslice=1  pass_regexp=Received REGISTRATION COMPLETE
    ${cmd}=    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    ${cmd_emergency}=    Catenate    ${cmd}    request_type=initial-emergency-request
    ${ret}=    Run Keyword If    '${type}'=='emergency'    Execute Egate Command    ${cmd_emergency}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1
    ...    ELSE
    ...    Execute Egate Command    ${cmd}    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1

PDU Setup With 5QI5 and 5QI1
    [Arguments]    ${ue_id}    ${pdu}    ${gw_id}
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=1 gw=${gw_id}

UE Register And Add Pdu With 5QI5 and 5QI1 5QI2
    [Arguments]    ${ue_id}    ${type}=${EMPTY}
    Run Keyword If    '${type}'=='emergency'    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2,4
    Execute Egate Command    ue_register id=${ue_id} nwslice=1  pass_regexp=Received REGISTRATION COMPLETE
    ${cmd}=    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    ${cmd_emergency}=    Catenate    ${cmd}    request_type=initial-emergency-request
    ${ret}=    Run Keyword If    '${type}'=='emergency'    Execute Egate Command    ${cmd_emergency}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1
    ...    ELSE
    ...    Execute Egate Command    ${cmd}    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1
#common suite keyword --end

#D08
SA Call QosFlow Release With UE Lost Test
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    SA Call PDUSessionResourceRelease With UE Lost
    SA Call Deregister With UE Lost

VoNR Call QosFlow Release With UE Lost Test
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Voice Call PDUSessionResourceRelease With UE Lost
    Voice Call PDUSessionResourceModifyRequest With UE Lost
    Voice Call Deregister With UE Lost

SA Call PDUSessionResourceRelease With UE Lost
    Clear Counter Files
    SA UE Register And Add Pdu With Default 5QI9    ue_id=1
    PDU Session Release    ue_id=1    pdu=1    cause=RN_radio_connection_with_ue_lost
    Check Counters    ${PM_Counters_SA_Qosflow_Release_Due_Ue_Lost}
    Release ues    ue_type=all

SA Call Deregister With UE Lost
    Clear Counter Files
    SA UE Register And Add Pdu With Default 5QI9    ue_id=3
    Ue Deregister    ue_id=3    cause=RN_radio_connection_with_ue_lost
    Check Counters    ${PM_Counters_SA_Qosflow_Release_Due_Ue_Lost}
    Release ues    ue_type=all

Voice Call PDUSessionResourceRelease With UE Lost
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=4
    PDU Add QoSFlow 5QI1    ue_id=4
    PDU Session Release    ue_id=4    pdu=1    cause=RN_radio_connection_with_ue_lost
    Check Counters    ${PM_Counters_Voice_Call_Release_Due_Ue_Lost}
    Release ues    ue_type=all

Voice Call PDUSessionResourceModifyRequest With UE Lost
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=5
    PDU Add QoSFlow 5QI1    ue_id=5
    PDU Session Modify to release QoSFlow    ue_id=5    qosflows_to_del=2    cause=RN_radio_connection_with_ue_lost
    Check Counters    ${PM_Counters_Voice_Call_Qosflow_5QI1_Release_Due_Ue_Lost}
    Release ues    ue_type=all

Voice Call Deregister With UE Lost
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=6
    PDU Add QoSFlow 5QI1    ue_id=6
    Ue Deregister    ue_id=6    cause=RN_radio_connection_with_ue_lost
    Check Counters    ${PM_Counters_Voice_Call_Release_Due_Ue_Lost}
    Release ues    ue_type=all
#D08 --end

#D09
VoNR Call AMF initiated QosFlow Normal Release by PDU release command
    Clear Counter Files
    UE Register And Add Pdu With 5QI5 and 5QI1    ue_id=7
    Sleep    3s   #call lasting time
    PDU Session Release    ue_id=7    pdu=1    cause=NAS_normal_release
    Check Counters    ${PM_Counters_Voice_Call_AMF_Normal_PDU_Release}
    Release ues    ue_type=all

VoNR Call AMF initiated QosFlow Normal Release by PDU modify request
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=8
    PDU Setup With 5QI5 and 5QI1    ue_id=8    pdu=2    gw_id=11
    Sleep    3s   #call lasting time
    PDU Session Modify to release QoSFlow    ue_id=8    pdu=2    qosflows_to_del=2    cause=NAS_normal_release
    Check Counters    ${PM_Counters_Voice_Call_AMF_Normal_PDU_Modify_Release}
    Release ues    ue_type=all

VoNR Call AMF initiated QosFlow Normal Release by UE context release
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=9
    PDU Add QoSFlow 5QI1    ue_id=9
    Sleep    3s   #call lasting time
    Ue Deregister    ue_id=9    cause=NAS_normal_release
    Check Counters    ${PM_Counters_Voice_Call_AMF_Normal_PDU_Release}
    Release ues    ue_type=all
#D09 --end

#D11 --start
VoNR Call AMF initiated QosFlow Release by PDU release command With Other Cause
    Clear Counter Files
    UE Register And Add Pdu With 5QI5 and 5QI1    ue_id=7
    Sleep    3s   #call lasting time
    PDU Session Release    ue_id=7    pdu=1    cause=RN_CauseRadioNetwork_unspecified
    Check Counters    ${PM_Counters_Voice_Call_Release_Due_Other_Cause}
    Release ues    ue_type=all

VoNR Call AMF initiated QosFlow Release by PDU modify request With Other Cause
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=8
    PDU Setup With 5QI5 and 5QI1    ue_id=8    pdu=2    gw_id=11
    Sleep    3s   #call lasting time
    PDU Session Modify to release QoSFlow    ue_id=8    pdu=2    qosflows_to_del=2    cause=NAS_CauseNas_unspecified
    Check Counters    ${PM_Counters_Voice_Call_Release_by_PDU_modify_Due_Other_Cause}
    Release ues    ue_type=all

VoNR Call AMF initiated QosFlow Release by UE context release With Other Cause
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=9
    PDU Add QoSFlow 5QI1    ue_id=9
    Sleep    3s   #call lasting time
    Ue Deregister    ue_id=9    cause=NAS_CauseNas_unspecified
    Check Counters    ${PM_Counters_Voice_Call_Release_Due_Other_Cause}
    Release ues    ue_type=all
#D11 --end

#E01
Video Call Setup
    Clear Counter Files
    UE Register And Add Pdu With 5QI5 and 5QI1 5QI2    ue_id=10
    Check Counters    ${PM_Counters_Peak_Ave_Number}

Video Call Release
    Clear Counter Files
    Ue Deregister    ue_id=10    cause=NAS_normal_release
    Check Counters    ${PM_Counters_Peak_Ave_Number_After_UE_Release}
    Release ues    ue_type=all
#E01 --end
