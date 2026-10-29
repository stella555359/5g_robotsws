*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
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
...    @{GNB_2AMFs}
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
#...    NRDRB-15:durationThresDiscard=50
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
#...    NRDRB-15:volThresDiscard=100
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
#GNB_2AMFs for D006#

@{GNB_2AMFs}
...    NRBTS:actNgcFlexSaMode=true
...    NRBTS-1/SERVEDAMF-2:administrativeState=Locked
...    NRBTS-1/SERVEDAMF-2:amfIPAddress=10.0.1.102
...    NRBTS-1/SERVEDAMF-2:defaultAMF=false

${NG_FLOW_REL_ABNORMAL_5QI1}    M55125C09515
${NG_FLOW_CONNECTED_SESSION_TIME}    M55125C09516
${NG_FLOW_SESSION_DUR_ABNRM_5QI1}    M55125C09527
${NG_FLOW_REL_AMF_OTHER_5QI1}    M55125C09513
${NG_FLOW_REL_AMF_NORMAL}    M55125C09019
${NG_FLOW_REL_AMF_NORMAL_5QI1}    M55125C09512
#B007 counter check list
${NG_FLOW_SETUP_ATT_TOT_5QI1}    M55125C09517
${NG_FLOW_SETUP_SUCC_TOT_5QI1}    M55125C09518
${NG_FLOW_REL_AMF_NORMAL_PMQAP}    M55163C00519
@{PM_Counters_VoNR_PDUSessionResourceRelease}
...    NRCELL-1:${NG_FLOW_SETUP_ATT_TOT_5QI1}=1
...    NRCELL-1:${NG_FLOW_SETUP_SUCC_TOT_5QI1}=1
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL}=2
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL_5QI1}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
@{PM_Counters_VoNR_PDUSessionResourceModify}
...    NRCELL-1:${NG_FLOW_SETUP_ATT_TOT_5QI1}=1
...    NRCELL-1:${NG_FLOW_SETUP_SUCC_TOT_5QI1}=1
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL}=1
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL_5QI1}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_AMF_NORMAL_PMQAP}=0
#B007 --end
#D004 counter check list
${NG_FLOW_REL_GNB_RLF}    M55125C09003
${NG_FLOW_REL_GNB_RLF_5QI1}    M55125C09503
${NG_FLOW_REL_GNB_RLF_PMQAP}    M55163C00504
@{PM_Counters_SA_Release_Due_to_Radio_Link_Failure}
...    NRCELL-1:${NG_FLOW_REL_GNB_RLF}=0
...    NRCELL-1:${NG_FLOW_REL_GNB_RLF_5QI1}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_GNB_RLF_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_GNB_RLF_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_GNB_RLF_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_GNB_RLF_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_ABNRM_5QI1}=0
...    NRCELL-1:${NG_FLOW_REL_AMF_OTHER_5QI1}=0
@{PM_Counters_Voice_Call_Release_Due_to_Radio_Link_Failure}
...    NRCELL-1:${NG_FLOW_REL_GNB_RLF}=0
...    NRCELL-1:${NG_FLOW_REL_GNB_RLF_5QI1}=0
...    NRCELL-1:${NG_FLOW_REL_ABNORMAL_5QI1}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_GNB_RLF_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_GNB_RLF_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_GNB_RLF_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_GNB_RLF_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_ABNRM_5QI1}>1
...    NRCELL-1:${NG_FLOW_REL_AMF_OTHER_5QI1}=0
#D004 --end
#D005 counter check list
${NG_FLOW_REL_NG_RESET_AMF}    M55125C09017
${NG_FLOW_REL_AMF_NG_RESET_5QI1}    M55125C09510
${NG_FLOW_REL_AMF_NG_RESET_PMQAP}    M55163C00517
@{PM_Counters_SA_Call_Release_Due_to_NG_Reset_By_AMF}
...    NRCELL-1:${NG_FLOW_REL_NG_RESET_AMF}=1
...    NRCELL-1:${NG_FLOW_REL_AMF_NG_RESET_5QI1}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_AMF_NG_RESET_PMQAP}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_AMF_NG_RESET_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_AMF_NG_RESET_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_AMF_NG_RESET_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_ABNRM_5QI1}=0
...    NRCELL-1:${NG_FLOW_REL_AMF_OTHER_5QI1}=0
@{PM_Counters_Voice_Call_Release_Due_to_NG_Reset_By_AMF}
...    NRCELL-1:${NG_FLOW_REL_NG_RESET_AMF}=2
...    NRCELL-1:${NG_FLOW_REL_AMF_NG_RESET_5QI1}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_AMF_NG_RESET_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_AMF_NG_RESET_PMQAP}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_AMF_NG_RESET_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_AMF_NG_RESET_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_ABNRM_5QI1}>0
...    NRCELL-1:${NG_FLOW_REL_AMF_OTHER_5QI1}=0
...    NRCELL-1:${NG_FLOW_REL_ABNORMAL_5QI1}=1
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL}=0
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL_5QI1}=0

#D005 --end
#D006 counter check list
${NG_FLOW_REL_GNB_NG_RESET}    M55125C09001
${NG_FLOW_REL_GNB_NG_RESET_5QI1}    M55125C09501
${NG_FLOW_REL_GNB_NG_RESET_PMQAP}    M55163C00502
@{PM_Counters_SA_Call_Release_Due_to_NG_Reset_By_GNB}
...    NRCELL-1:${NG_FLOW_REL_GNB_NG_RESET}=1
...    NRCELL-1:${NG_FLOW_REL_GNB_NG_RESET_5QI1}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_GNB_NG_RESET_PMQAP}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_GNB_NG_RESET_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_GNB_NG_RESET_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_GNB_NG_RESET_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_ABNRM_5QI1}=0
...    NRCELL-1:${NG_FLOW_REL_AMF_OTHER_5QI1}=0
@{PM_Counters_Voice_Call_Release_Due_to_NG_Reset_By_GNB}
...    NRCELL-1:${NG_FLOW_REL_GNB_NG_RESET}=2
...    NRCELL-1:${NG_FLOW_REL_GNB_NG_RESET_5QI1}=1
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_GNB_NG_RESET_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-2:${NG_FLOW_REL_GNB_NG_RESET_PMQAP}=2
...    NRCELL-1/PLMN-PLMN/NRPMQAP-3:${NG_FLOW_REL_GNB_NG_RESET_PMQAP}=0
...    NRCELL-1/PLMN-PLMN/NRPMQAP-4:${NG_FLOW_REL_GNB_NG_RESET_PMQAP}=0
...    NRCELL-1:${NG_FLOW_CONNECTED_SESSION_TIME}>1
...    NRCELL-1:${NG_FLOW_SESSION_DUR_ABNRM_5QI1}>0
...    NRCELL-1:${NG_FLOW_REL_AMF_OTHER_5QI1}=0
...    NRCELL-1:${NG_FLOW_REL_ABNORMAL_5QI1}=1
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL}=0
...    NRCELL-1:${NG_FLOW_REL_AMF_NORMAL_5QI1}=0
*** Test Cases ***
CB008200-ET-B007_Verify Number of VoNR QosFlow Setup Attempts and Success
    [Tags]  QC_161091
    [Documentation]  Check NG_Flow counters with normal procedures.
    ...    step1: setup vonr call by PDUSessionResourceModify(5qi5_ICS , 5qi1_pdu_modify),release 5qi5+5qi1 by UEContextReleaseCommand
    ...    step2: setup vonr call by ICS (5qi5+5qi1),release 5qi5+5qi1 by PDUSessionResourceReleaseCommand
    ...    step3: setup vonr call by 2nd PDU session setup (5qi5+5qi1 in pdu2),release 5qi1 by PDUSessionResourceModify
    VoNR Call setup with PDUSessionResourceModify And Release With UEContextReleaseCommand
    VoNR Call setup with ICS And Release With PDUSessionResourceReleaseCommand
    VoNR Call setup with PDUSessionResourceSetup And Release 5QI1 With PDUSessionResourceModify
    [teardown]     Common Test Teardown And Reset AMF

CB008200-ET-D004_Verify Counter when QosFlow Release due to Radio Link Failure and SA flow duration for QosFlow Abnormal release VoNR QosFlow
    [Tags]  QC_161096
    [Documentation]  Check NG_Flow counters when release due Radio Link Failure.
    ...    step1: setup normal call(5qi9), and release 5qi9 due Radio Link Failure
    ...    step2: setup vonr call by PDUSessionResourceModify(5qi5_ICS , 5qi1_pdu_modify),release 5qi5+5qi1 due Radio Link Failure
    SA Call QosFlow Release Due to Radio Link Failure
    VoNR Call QosFlow Release Due to Radio Link Failure
    [teardown]     Common Test Teardown And Deactivate Rlf

CB008200-ET-D005_Verify Counter when QosFlow Release due to Ng Reset initiated by AMF and VoNR QosFlow Release abnormal
    [Tags]  QC_161097
    [Documentation]  Check NG_Flow counters when release Ng Reset initiated by AMF.
    ...    step1: setup normal call(5qi9), then trigger AMF NG reset by egate_command
    ...    step2: setup vonr call by PDUSessionResourceModify(5qi5_ICS , 5qi1_pdu_modify), then trigger NG reset by initiated by AMF(egate command)
    SA Call QosFlow Release Due to NG Reset By AMF
    VoNR Call QosFlow Release Due to NG Reset By AMF

CB008200-ET-D006_Verify Counter when QosFlow Release due to Ng Reset initiated by gNB
    [Tags]  QC_161098
    [Documentation]  Check NG_Flow counters when release Ng Reset initiated by GNB.
    ...    step1: setup normal call(5qi9), then trigger NG reset by lock AMF on gnb side
    ...    step2: setup vonr call by PDUSessionResourceModify(5qi5_ICS , 5qi1_pdu_modify), then trigger NG reset by lock AMF on gnb side.
    delta commission parameters    NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
    SA Call QosFlow Release Due to NG Reset By GNB
    VoNR Call QosFlow Release Due to NG Reset By GNB
    [teardown]     Common Test Teardown And Unlock NG Links

*** Keywords ***
#common suite keyword
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15
#    Debug Enter Into Egate

Common Test Teardown And Reset AMF
    Execute Egate Command    smf_param id=1 reset
    Common Test Teardown And Stop Capture Logs

Common Test Teardown And Deactivate Rlf
    Execute Egate Command    ue_testmode_set_nr id=4 testmode=rlf action=deactivate profile_id=1
    Execute Egate Command    ue_testmode_set_nr id=5 testmode=rlf action=deactivate profile_id=1
    Common Test Teardown And Stop Capture Logs

Common Test Teardown And Unlock NG Links
    Unlock_Lock_NG_Links    status=Unlocked
    Common Test Teardown And Stop Capture Logs

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=9
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-11 qos_flows=4,3,2,1 qos_rules=1,2 amf=1-6
    Update Cfg    ue_nr_capabilities id=1-11 voice_over_nr=on:on:off

    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1-11 qos_flows=4,3,2,1 qos_rules=1,2 amf=1-6

    Update Cfg    ue_param id=1-11 nr_usage_setting=voice_centric ue_nr_capabilities=${5qi1_UE_Capabilities}
    Update Cfg    set_pdu_gateway id=7 ue_nat_ip=72.23.6.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=8 ue_nat_ip=72.23.7.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=9 ue_nat_ip=72.23.8.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=10 ue_nat_ip=72.23.9.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=11 ue_nat_ip=72.23.10.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1

UE Register And Add Pdu With Default 5QI5
    [Arguments]    ${ue_id}    ${type}=${EMPTY}
    Run Keyword If    '${type}'=='emergency'    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Execute Egate Command    ue_register id=${ue_id} nwslice=1  pass_regexp=Received REGISTRATION COMPLETE
    ${cmd}=    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    ${cmd_emergency}=    Catenate    ${cmd}    request_type=initial-emergency-request
    ${ret}=    Run Keyword If    '${type}'=='emergency'    Execute Egate Command    ${cmd_emergency}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1
    ...    ELSE
    ...    Execute Egate Command    ${cmd}    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1

SA UE Register And Add Pdu With Default 5QI9
    [Arguments]    ${ue_id}
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    Execute Egate Command    ue_register id=${ue_id} nwslice=1    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 9 qfi 1

PDU Add QoSFlow 5QI1
    [Arguments]    ${ue_id}    ${pdu}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=2 by=amf  pass_regexp=Added QosFlow with QFI:2 fiveQI:1
#common suite keyword --end
#B007
UE Register And Add Pdu With Default 5QI5 And 5QI1
    [Arguments]    ${ue_id}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2
    ${cmd_register}=    Set Variable    ue_register id=${ue_id} nwslice=1
    Execute Egate Command    ${cmd_register}    pass_regexp=Received REGISTRATION COMPLETE
    ${cmd_pdu}=    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    ${ret}=    Execute Egate Command    ${cmd_pdu}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 1 qfi 2

VoNR Call Setup with 2nd PDU
    [Arguments]    ${ue_id}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2
    ${cmd}=    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=2 nwslice=1 gw=2
    Execute Egate Command    ${cmd}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 2 Created FiveQi:Qfi mapping fiveQi 1 qfi 2

VoNR Call setup with PDUSessionResourceModify And Release With UEContextReleaseCommand
    [Arguments]    ${ue_id}=1
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=${ue_id}
    PDU Add QoSFlow 5QI1    ue_id=${ue_id}
    release ues    ue_type=all    ue_id=${ue_id}
    Check Counters    ${PM_Counters_VoNR_PDUSessionResourceRelease}

VoNR Call setup with ICS And Release With PDUSessionResourceReleaseCommand
    [Arguments]    ${ue_id}=2
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5 And 5QI1    ue_id=${ue_id}
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} by=amf pdu=1
    ...    pass_regexp=Successfully released PDU Session with ID 1
    Check Counters    ${PM_Counters_VoNR_PDUSessionResourceRelease}
    release ues    ue_type=all    ue_id=${ue_id}

VoNR Call setup with PDUSessionResourceSetup And Release 5QI1 With PDUSessionResourceModify
    [Arguments]    ${ue_id}=3
    Execute Egate Command    smf_param id=1 reset
    SA UE Register And Add Pdu With Default 5QI9    ue_id=${ue_id}
    Clear Counter Files
    VoNR Call Setup with 2nd PDU    ue_id=${ue_id}
    Execute Egate Command    amf_ue_pdu_modify_param id=1 ue=${ue_id} action=override_ie qos_flow_to_del_cause=NAS_normal_release
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_del=2 by=amf
    ...    pass_regexp=Received Pdu Session Resource Modify Response Message
    Check Counters    ${PM_Counters_VoNR_PDUSessionResourceModify}
    release ues    ue_type=all    ue_id=${ue_id}

#B007 --end
#D004
SA Call QosFlow Release Due to Radio Link Failure
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    Clear Counter Files
    SA UE Register And Add Pdu With Default 5QI9    ue_id=4
    Trigger Ue Deregister Due To RLF    ue_id=4
    Check Counters    ${PM_Counters_SA_Release_Due_to_Radio_Link_Failure}
    release ues    ue_type=all    ue_id=4

VoNR Call QosFlow Release Due to Radio Link Failure
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=5
    PDU Add QoSFlow 5QI1    ue_id=5
    Trigger Ue Deregister Due To RLF    ue_id=5
    Check Counters    ${PM_Counters_Voice_Call_Release_Due_to_Radio_Link_Failure}
    release ues    ue_type=all    ue_id=5

Trigger Ue Deregister Due To RLF
    [Arguments]    ${ue_id}
    Execute Egate Command    rlf_testmode_nr profile_id=1 num_stop_csi_report=200 num_stop_dlharq_tx=100
    ${cmd}=    Set Variable    ue_testmode_set_nr id=${ue_id} testmode=rlf action=activate profile_id=1
    Execute Egate Command    ${cmd}
#    wait until keyword succeeds    2 min    2 sec    Execute Egate Command    ${cmd}
#    ...    pass_regexp=Received UE CONTEXT RELEASE REQUEST from GNB-2 handled successfully
#D004 --end

#D005
UE Deregister
    [Arguments]    ${ue_id}
    ${cmd_Deregister}=    Set Variable    ue_deregister id=${ue_id} ue_deregister_type=switch_off
    wait until keyword succeeds    1 min    5 sec
    ...    Execute Egate Command    ${cmd_Deregister}    pass_regexp=UE${ue_id}: detached

SA Call QosFlow Release Due to NG Reset By AMF
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    Clear Counter Files
    SA UE Register And Add Pdu With Default 5QI9    ue_id=6
    Trigger NG Reset By AMF
    Check Counters    ${PM_Counters_SA_Call_Release_Due_to_NG_Reset_By_AMF}
    UE Deregister    ue_id=6

VoNR Call QosFlow Release Due to NG Reset By AMF
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=7
    PDU Add QoSFlow 5QI1    ue_id=7
    Trigger NG Reset By AMF
    Check Counters    ${PM_Counters_Voice_Call_Release_Due_to_NG_Reset_By_AMF}
    UE Deregister    ue_id=7

Trigger NG Reset By AMF
    ${cmd}=    Set Variable    link_ng_reset by=amf:1
    Execute Egate Command    ${cmd}    pass_regexp=Received NG Reset Acknowledge from GNB-2
#D005 --end

#D006
SA Call QosFlow Release Due to NG Reset By GNB
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    Clear Counter Files
    SA UE Register And Add Pdu With Default 5QI9    ue_id=8
    Unlock_Lock_NG_Links    status=Locked
    Check Counters    ${PM_Counters_SA_Call_Release_Due_to_NG_Reset_By_GNB}
    Unlock_Lock_NG_Links    status=Unlocked


VoNR Call QosFlow Release Due to NG Reset By GNB
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Clear Counter Files
    UE Register And Add Pdu With Default 5QI5    ue_id=9
    PDU Add QoSFlow 5QI1    ue_id=9
    Unlock_Lock_NG_Links    status=Locked
    Check Counters    ${PM_Counters_Voice_Call_Release_Due_to_NG_Reset_By_GNB}
    Unlock_Lock_NG_Links    status=Unlocked

Unlock_Lock_NG_Links
    [Arguments]    ${status}=Locked
    ${delta_parameters}    Create List    NRBTS-1/SERVEDAMF-1:administrativeState=${status}     NRBTS-1/SERVEDAMF-2:administrativeState=${status}
    delta commission parameters    ${delta_parameters}
#D006 --end
