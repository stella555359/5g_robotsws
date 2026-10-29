*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-kexin.bao
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT    CB008246    release-SBTS23R3
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRCELL-2:cellDepType=SA
...    delete:NRCELL-2:configuredEpsTac
...    NRCELL:actNonVoNRGbrService=true
...    NRCELL:actUl256Qam=false
...    NRCELL:actDl256Qam=false
...    @{8246_related}
...    @{rac}

@{8246_related}
...    @{bwp_profile}
...    @{PDSCHHRLA_PUSCHHRLA}
...    @{8246_cell_configuration}
...    @{5qi71_related_modification}

@{bwp_profile}
...    NRBTS/BWP_PROFILE-1/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-14/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevelHR=AL4

@{PDSCHHRLA_PUSCHHRLA}
...    NRBTS/NRDRB-11:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1    #5qi=6
...    NRBTS/NRDRB-12:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-2    #5qi=7
...    NRBTS/NRDRB-18:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-2    #5QI-71

...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=110
...    NRBTS/NRPUSCHHRLA-1:ullaBlerTargetHR=10
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePeriod=20
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutageTbsThresh=808
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutageTbsThresh64qam=1000
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPeriod=30
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverTbsThresh=10000
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverTbsThresh64qam=7000

...    NRBTS/NRPUSCHHRLA-2:scalFactorForHRGbrUl=130
...    NRBTS/NRPUSCHHRLA-2:ullaBlerTargetHR=8
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutagePeriod=20
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutageTbsThresh=808
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutageTbsThresh64qam=1000
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverPeriod=30
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverTbsThresh=10000
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverTbsThresh64qam=7000

@{8246_cell_configuration}
...    NRCELL:actCceSplit=false
...    NRCELL:actLAForHiReliab=true
...    NRCELL:puschHrLaConfig:iniDeltaSinrHR=-50
...    NRCELL:puschHrLaConfig:ullaDeltaSinrMaxHR=150
...    NRCELL:puschHrLaConfig:ullaDeltaSinrMinHR=-300
...    NRCELL:puschHrLaConfig:ullaDeltaSinrStepdownHR=20
...    NRCELL:puschHrLaConfig:ullaIniMcsHR=0
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamLowSERANK1HR=25
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamLowSERANK2HR=25
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamRANK1HR=25
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamRANK2HR=25
...    NRCELL:puschHrLaConfig:ullaSinrOffsetHR=20

@{5qi71_related_modification}
...    NRBTS/NRDRB-18:actDddsReduction=false
...    NRBTS/NRDRB-18:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-18:actLostPduFastRetx=false
...    NRBTS/NRDRB-18:discardTimer=50ms
...    NRBTS/NRDRB-18:dlAllowMinDelayLinkXxCalib=false
...    NRBTS/NRDRB-18:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-18:dscp=0
...    NRBTS/NRDRB-18:durationThresDiscardDl=40
...    NRBTS/NRDRB-18:durationThresDiscardUl=20
...    NRBTS/NRDRB-18:endMarkerTimer=2000
...    NRBTS/NRDRB-18:l2OHFactorDl=16
...    NRBTS/NRDRB-18:l2OHFactorUl=33
...    NRBTS/NRDRB-18:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-18:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-18:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-18:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-18:maxTransferDelayGbr=20
...    NRBTS/NRDRB-18:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-18:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-4
...    NRBTS/NRDRB-18:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-4
...    NRBTS/NRDRB-18:numSduDiscard=1
...    NRBTS/NRDRB-18:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS/NRDRB-18:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-18:resType=GBR
...    NRBTS/NRDRB-18:rlcMode=RLC_AM
...    NRBTS/NRDRB-18:schedulWeight=1
...    NRBTS/NRDRB-18:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-18:volThresDiscardDl=8000
...    NRBTS/NRDRB-18:volThresDiscardUl=800
...    NRBTS/NRDRB-18:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-18:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS/NRDRB-18:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS/NRDRB-18:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS/NRDRB-18:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS/NRDRB-18:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS/NRDRB-18:nsaDrbParam:dlNumOfCongOrGainDdds=2
...    NRBTS/NRDRB-18:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS/NRDRB-18:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS/NRDRB-18:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS/NRDRB-18:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS/NRDRB-18:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-18:nsaDrbParam:prioritizeX2Period=500
...    NRBTS/NRDRB-18:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-18:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS/NRDRB_5QI-8:fiveqiValueList=71
...    NRBTS/NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-18
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-5:schedulBSD=5ms
...    NRBTS/NRDRB_MAC-5:schedulPrio=7
...    NRBTS/NRDRB_PDCP-4:cuFlowControlProfId=1
...    NRBTS/NRDRB_PDCP-4:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_PDCP-4:pdcpBufDiscardThreshold=20000
...    NRBTS/NRDRB_PDCP-4:pdcpDelayThreshRetxMode=disabled
...    NRBTS/NRDRB_PDCP-4:tReorderingDl=ms8
...    NRBTS/NRDRB_PDCP-4:tReorderingUl=ms8
...    NRBTS/NRDRB_PDCP-4:xxFlowControlProfForCuIdx=1
...    NRBTS/NRDRB_RLC_AM-4:dlMaxRetxThreshold=t16
...    NRBTS/NRDRB_RLC_AM-4:dlPollByte=kB500
...    NRBTS/NRDRB_RLC_AM-4:dlPollPDU=p64
...    NRBTS/NRDRB_RLC_AM-4:dlTPollRetr=ms100
...    NRBTS/NRDRB_RLC_AM-4:dlTProhib=ms15
...    NRBTS/NRDRB_RLC_AM-4:dlTReassembly=ms15
...    NRBTS/NRDRB_RLC_AM-4:dlTReassemblyIBCA=30
...    NRBTS/NRDRB_RLC_AM-4:duFlowControlProfId=1
...    NRBTS/NRDRB_RLC_AM-4:ulMaxRetxThreshold=t32
...    NRBTS/NRDRB_RLC_AM-4:ulPollByte=kB500
...    NRBTS/NRDRB_RLC_AM-4:ulPollPDU=p64
...    NRBTS/NRDRB_RLC_AM-4:ulTPollRetr=ms45
...    NRBTS/NRDRB_RLC_AM-4:ulTProhib=ms15
...    NRBTS/NRDRB_RLC_AM-4:ulTReassembly=ms15
...    NRBTS/NRDRB_RLC_AM-4:ulTReassemblyIBCA=${EMPTY}

@{rac}
...    NRCELL-1:actGBRAdmissionControl=GBRService
...    NRCELL-1:maxGBRTrafficLimit=6
...    NRCELL-1:actIncreasedFdmUsersPerSlot=true
...    NRCELL-1:maxNumPdschAllocationPerSlot=16
...    NRCELL-1:maxNumPuschAllocationPerSlot=16

${UE_Capa_Support_HR_PUSCH_TypeA}    SEPARATOR=
...    EDA09000575F5A13160003C320016093170019C3D09009B22C39F30C7942C0E098040623803DC6C28C0D608C21A08107482406D6C98AB1A
...    1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E007FE00098000702A0D88DAC1184341020F9412024B64C55050E7C4
...    71E300000000000000000013FFE00000FFF8000009800070005E1E2300070A000000058081003011A01407A009806344891226C73E18028
...    08CF412003C1C1401C0C025007000602400406020000000003E008020000000100000200B036B2A68020800004B29282000032CA4A00A81
...    D552AAA12009001A050000040400801010040086A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060
...    B40

${UE_Capa_Support_HR_PUSCH_TypeB}    SEPARATOR=
...    EDA09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623803DC6C28C0D608C21A08107482406D6C98AB1A
...    1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E007FE00098000702A0D88DAC1184341020F9412024B64C55050E7C4
...    71E300000000000000000013FFE00000FFF8000009800070005E1E2300070A000000058081003011A01407A009806344891226C73E18028
...    08CF412003C1C1401C0C025007000602400406028000000000240080083E008020000000100000200B036B2A68020800004B29282000032
...    CA4A00A81D552AAA12009001A050000040400801010040086A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8
...    B4BD05060B4

${normal_ue}    SEPARATOR=
...    EDA09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623803DC6C28C0D608C21A08107482406D6C98AB1A
...    1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E007FE00098000702A0D88DAC1184341020F9412024B64C55050E7C4
...    71E300000000000000000013FFE00000FFF8000009800070005E1E2300070A000000058081003011A01407A009806344891226C73E18028
...    08CF412003C1C1401C0C025007000602400406020000000003E008020000000100000200B036B2A68020800004B29282000032CA4A00A81
...    D552AAA12009001A050000040400801010040086A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060
...    B40

@{online_modify_step1}
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamLowSERANK1HR=20
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamRANK1HR=15

@{online_modify_step2}
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamLowSERANK2HR=28
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamRANK2HR=20

*** Test Cases ***
CB008246_I_05_FR1_SA_TDD_Delete_5G_UE_with_multiple_nonGBR_HR_DRBs_in_UL_via_PDU_Modify
    [Documentation]
    ...    1.Description
    ...    To validates the gNB behaviour for the setup and release of one or more non-GBR High Reliability DRBs and
    ...    data transmission in UL.
    ...    2.Configuration
    ...      a.SA,TDD.
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.Default drb 5QI_6 is associated with NRPUSCHHRLA-1,and 5QI_7 is associated with NRPUSCHHRLA-2.
    ...      d.UE support Ul-64QAM-MCS-TableAlt.
    ...    3.Test Steps
    ...      a.UE attach to target cell w PDU,with default DRB 5QI6&7.
    ...      b.delete 5QI7.
    ...      c.UE detach.
    ...    4.Check Points
    ...      4.1 for stepa:PsUser_BearerSetupReq message,gNB-DU-CPRT configures drbAddReqPs->HrLaProfile->puschHrConfig for 5QI6&5QI7.
    ...      4.2 for stepa:Check PsUser_UserModifyReq message, cellConfigurationForModification->puschConfig->msctable as qam64LowSE.
    ...      4.3 for stepa:Check RRC RECONFIGURATION message,qam64LowSE should be set in mcs-Table parameter of PUSCH-Config
    ...      4.4 for stepb:Check RRC RECONFIGURATION message should not contain PUSCH-Config.
    [Tags]    QC_301831    owner-kexin.bao
    Prepare For Test I005
    UE Attach To Target Cell    ue_id=1    cell_id=2    regexp=mcs-Table qam64LowSE
    Send And Verify Throuput    ue_id=1    qfi=1    pdu=1    send_dl=10    send_ul=5    sleep_time=10s
    Send And Verify Throuput    ue_id=1    qfi=2    pdu=1    send_dl=10    send_ul=5    sleep_time=10s
    Delete DRB    ue_id=1    pdu=1    qfi=2    qosflow=7    5qi=7    fail_regexp=mcs-Table qam64LowSE
    Verify Throuput    ue_id=1    qfi=1    pdu=1    Tput_dl=9    Tput_ul=4.5    sleep_time=10s
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_I05${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008246_I_18_FR1_SA_TDD_Scheduling_5G_UE_with_one_GBR_multiple_nonGBR_HR_DRBs_in_UL_via_PDU_Modify
    [Documentation]
    ...    1.Description
    ...    To validate the gNB behaviour for the setup and release of one GBR High Reliability DRB associated with
    ...    QoS flow with 5QI 2/3/4 and one or more non-GBR High Reliability DRB. It also verifies data transmission in UL.
    ...    2.Configuration
    ...      a.SA,TDD.
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.Default drb 5QI_6 is associated with NRPUSCHHRLA-1,and 5QI_71 is associated with NRPUSCHHRLA-2.
    ...      d.UE support Ul-64QAM-MCS-TableAlt.
    ...    3.Test Steps
    ...      a.UE attach to target cell w default DRB 5QI6.
    ...      b.setup GBR 5QI71.
    ...      c.UE detach.
    ...    4.Check Points
    ...      4.1 for stepa:PsUser_BearerSetupReq message,gNB-DU-CPRT configures drbAddReqPs->HrLaProfile->puschHrConfig for 5QI6.
    ...      4.2 for stepa:Check PsUser_UserModifyReq message, cellConfigurationForModification->puschConfig->msctable as qam64LowSE.
    ...      4.3 for stepa:Check RRC RECONFIGURATION message, qam64LowSE should be set in mcs-Table parameter of PUSCH-Config
    ...      4.4 for stepb:PsUser_BearerSetupReq message,gNB-DU-CPRT configures drbAddReqPs->HrLaProfile->puschHrConfig for 5QI71.
    ...      4.5 for stepb:Check RRC RECONFIGURATION message should not contain PUSCH-Config.
    [Tags]    QC_301918    owner-kexin.bao
    Prepare For Test I018
    UE Attach To Target Cell    ue_id=2    cell_id=2    regexp=mcs-Table qam64LowSE
    Send And Verify Throuput    ue_id=2    qfi=1    pdu=1    send_dl=10    send_ul=5    sleep_time=10s
    Setup DRB And Make Tput    ue_id=2    pdu=1    qfi=2    qosflow=10    5qi=71    fail_regexp=mcs-Table qam64LowSE
    Verify Throuput    ue_id=2    qfi=1    pdu=1    Tput_dl=9    Tput_ul=4.5    sleep_time=10s
    UE Deregister From gNB    ue_id=2
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_I18${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008246_I_011_FR1_SA_TDD_Scheduling_5G_UE_with_multiple_nonGBR_HR_DRBs_in_UL_via_PDU_Not_Support_64QAM_MCS_TableAlt_Online_Change_DlHRLinkAdaption
    [Documentation]
    ...    1.Description
    ...    To validate the gNB behaviour for the setup and release of one GBR High Reliability DRB associated with
    ...    QoS flow with 5QI 2/3/4 and one or more non-GBR High Reliability DRB. It also verifies data transmission in UL.
    ...    2.Configuration
    ...      a.SA,TDD.
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.5QI_6 is associated with NRPUSCHHRLA-1,and 5QI_7 is associated with NRPUSCHHRLA-2, they are both default DRB.
    ...      d.UE doesnot support Ul-64QAM-MCS-TableAlt.
    ...    3.Test Steps
    ...      a.UE1 attach to target cell w default DRB 5QI6&7.
    ...      b.UE2 and UE3 enter idle.
    ...      c.online modify ullaMcsMax64qamRANK1HR related parameters, then make UE2 exit idle.
    ...      d.online modify ullaMcsMax64qamRANK2HR related parameters, then make UE3 exit idle.
    ...      e.all UE detach.
    ...    4.Check Points
    ...      for stepc:modification take effect on UE1 and UE2.
    ...      for stepd:modification take effect on UE1, UE2 and UE3.
    [Tags]    QC_304432    owner-kexin.bao
    UE Attach To Target Cell Normal UE    ue_id=4    cell_id=2    fail_regexp=mcs-Table qam64LowSE
    Make UE In Idle    ue_id=5    cell_id=2    fail_regexp=mcs-Table qam64LowSE
    Make UE In Idle    ue_id=6    cell_id=2    fail_regexp=mcs-Table qam64LowSE
    Online Modify ullaMcsMax64qamRANK1HR
    Online Modify ullaMcsMax64qamRANK2HR
    Release All UEs    ue_id_start=4    ue_id_end=6

CB008246_I_030_FR1_SA_FDD_Radio_admission_control_for_HR_GBR_GFBR_modify_in_UL
    [Documentation]
    ...    1.Description
    ...    To validate the gNB behaviour during the admission control to check if there is sufficient GBR resources
    ...    available in UL to admit another HR GBR DRB associated to QoS flow with 5QI 2/3/4/71/72/76 or operator defined
    ...    5QI[128..254]. Here, the legacy GBR admission control mechanism is used including GBR load report from L2RT,
    ...    additionally considering the configurable scaling factors to Guaranteed Flow Bit Rate(GFBR) of the HR DRB.
    ...    Scaling factor is the multiplier to the GFBR to reflect the need for the additional radio resources when HR
    ...    BLER target is applied.
    ...    2.Configuration
    ...      a.SA,FDD.
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.5QI_6 is associated with NRPUSCHHRLA-1,5QI_7 and 5QI_71 is associated with NRPUSCHHRLA-2, they are both default DRB.
    ...      d.UE doesnot support Ul-64QAM-MCS-TableAlt.
    ...    3.Test Steps
    ...      a.UE1 attach to target cell w default DRB 5QI6&7.
    ...      b.UE2 and UE3 enter idle.
    ...      c.online modify ullaMcsMax64qamRANK1HR related parameters, then make UE2 exit idle.
    ...      d.online modify ullaMcsMax64qamRANK2HR related parameters, then make UE3 exit idle.
    ...      e.all UE detach.
    ...    4.Check Points
    ...      for stepc:modification take effect on UE2.
    ...      for stepd:modification take effect on UE3.
    [Tags]    QC_304433    owner-kexin.bao
    Prepare For Test I30
    UE Attach To Target Cell    ue_id=1    cell_id=1    regexp=QoS Routing Table
    Send And Verify UL Throuput    ue_id=1    qfi=2    pdu=1    send_ul=1    sleep_time=10s
    UE Attach To Target Cell 2PDU    ue_id=2    cell_id=1    regexp=QoS Routing Table
    Prepare For Test I30
    UE Attach To Target Cell    ue_id=3    cell_id=1    regexp=RAN radio resources not available
    GFBR Modification    ue_id=2
    Release All UEs    ue_id_start=1    ue_id_end=3
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_I30${/}a2a.ini    wait_string=UEContextReleaseComplete::12
    
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/2cells_1T1F    ue_count=15

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=2000 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7 default=on
    Update Cfg    set_qosflow id=8 5qi=8
    Update Cfg    set_qosflow id=10 5qi=71 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    ue_param id=1 ue_nr_capabilities=${UE_Capa_Support_HR_PUSCH_TypeA}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${UE_Capa_Support_HR_PUSCH_TypeB}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${UE_Capa_Support_HR_PUSCH_TypeB}
    Update Cfg    ue_param id=4 ue_nr_capabilities=${normal_ue}
    Update Cfg    ue_param id=5 ue_nr_capabilities=${normal_ue}
    Update Cfg    ue_param id=6 ue_nr_capabilities=${normal_ue}

Prepare For Test I005
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=6 priority=1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=7

Prepare For Test I018
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=6 priority=1

Prepare For Test I30
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=7 priority=1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=10
    Execute Egate Command    qosflow_modify qos_flow=10 gfbr_ul=1000

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}    ${regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    ${regexp}

UE Attach To Target Cell Normal UE
    [Arguments]    ${ue_id}    ${cell_id}    ${fail_regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=6 priority=1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=7
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    fail_regexp=${fail_regexp}
    Send And Verify UL Throuput    ue_id=${ue_id}    qfi=1    pdu=1    send_ul=2    sleep_time=10s
    Send And Verify UL Throuput    ue_id=${ue_id}    qfi=2    pdu=1    send_ul=2    sleep_time=10s

Make UE In Idle
    [Arguments]    ${ue_id}    ${cell_id}    ${fail_regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    amf_param empty_pdu_session_list=on id=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    fail_regexp=${fail_regexp}
    Execute Egate Command    ue_ng_ctx_release id=${ue_id} by=amf cause=RN_successful_handover    UE Context Release Complete

Exit idle
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_im_exit id=${ue_id} by=ue    Initial Context Setup Successful
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Send And Verify UL Throuput    ue_id=${ue_id}    qfi=1    pdu=1    send_ul=2    sleep_time=10s
    Send And Verify UL Throuput    ue_id=${ue_id}    qfi=2    pdu=1    send_ul=2    sleep_time=10s

UE Attach To Target Cell 2PDU
    [Arguments]    ${ue_id}    ${cell_id}    ${regexp}
    Prepare For Test I018
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    ${regexp}
    Prepare For Test I30
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=1    ${regexp}
    Send And Verify UL Throuput    ue_id=2    qfi=2    pdu=2    send_ul=1    sleep_time=10s

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Online Modify ullaMcsMax64qamRANK1HR
    Start To Capture Wireshark Log    I_11_01
    OnlineParamChange    ${online_modify_step1}
    Exit idle    ue_id=5
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_I11${/}a2a_I11_01.ini    name=I_11_01    wait_string=ullaMcsMax64qamLowSERANK1HR::2

Online Modify ullaMcsMax64qamRANK2HR
    Start To Capture Wireshark Log    I_11_02
    OnlineParamChange    ${online_modify_step2}
    Exit idle    ue_id=6
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_I11${/}a2a_I11_02.ini    name=I_11_02    wait_string=ullaMcsMax64qamLowSERANK2HR::2

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${pdu}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${pdu}=1    ${send_dl}=30    ${send_ul}=10    ${sleep_time}=10s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${qfi}    ${pdu}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}

Verify UL Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${pdu}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify UL Throuput
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${pdu}=1    ${send_ul}=10    ${sleep_time}=10s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=${send_ul}
    Verify UL Throuput    ${ue_id}    ${qfi}    ${pdu}    ${send_ul}*0.9    ${sleep_time}

Setup DRB And Make Tput
    [Arguments]    ${ue_id}    ${pdu}    ${qfi}    ${qosflow}    ${5qi}    ${fail_regexp}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflow} by=amf
    ...    pass_regexp=Added QosFlow with QFI:${qfi} 5QI:${5qi}    fail_regexp=${fail_regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=${qfi}    pdu=${pdu}    send_dl=40    send_ul=10    sleep_time=10s

Delete DRB
    [Arguments]    ${ue_id}    ${pdu}    ${qfi}    ${qosflow}    ${5qi}    ${fail_regexp}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=${qosflow} by=amf
    ...    pass_regexp=PduId ${pdu} Removed FiveQi:Qfi mapping fiveQi ${5qi} qfi ${qfi}    fail_regexp=${fail_regexp}

GFBR Modification
    [Arguments]    ${ue_id}
    Execute Egate Command    qosflow_modify qos_flow=10 gfbr_ul=5000
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_modify=10 by=amf    Unsuccessful Transfer
    Execute Egate Command    qosflow_modify qos_flow=10 gfbr_ul=200
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_modify=10 by=amf    ulInformationTransfer
    Execute Egate Command    qosflow_modify qos_flow=10 gfbr_ul=5000
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_modify=10 by=amf    Unsuccessful Transfer
    Execute Egate Command    qosflow_modify qos_flow=10 gfbr_ul=200
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_modify=10 by=amf    ulInformationTransfer
    Execute Egate Command    qosflow_modify qos_flow=10 gfbr_ul=300
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_modify=10 by=amf    ulInformationTransfer

Release All UEs
    [Arguments]    ${ue_id_start}    ${ue_id_end}
    FOR    ${i}    IN RANGE    ${ue_id_start}    ${ue_id_end}
        UE Deregister From gNB    ue_id=${i}
    END
