*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-kexin.bao
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008124    release-SBTS24R1
...    STATE_CONFIGURED

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRCELL-2:cellDepType=SA
...    delete:NRCELL-2:configuredEpsTac
...    MRBTS-1/NRBTS-1/NRCELL-2:chBw=60MHz
...    NRCELL:actNonVoNRGbrService=true
...    NRCELL:actVoNR=true
...    @{5qi4_related_modification}
...    @{5qi1_related_modification}
...    @{rac}
...    @{5GC000749}
...    NRBTS/NRDRB-18:cellAggrLevel=FR1 CA incompatible
...    NRBTS/NRDRB-19:cellAggrLevel=FR1 CA incompatible

@{5GC000749}
...    NRBTS:actNormVCFallback=true
...    NRBTS:actRedirect=true
...    NRCELL:voiceFBMode=redirection
...    NRCELL/NRREDRT-1:redirPrio=1
...    NRCELL/NRREDRT-1:redirFreqEutra=38100
...    NRCELL/NRREDRT-1:redirRat=eutra
...    delete:NRCELL/NRREDRT-1:redirSsbScs
...    delete:NRCELL/NRREDRT-1:redirFreqNr
@{rac}
...    NRCELL-1:actGBRAdmissionControl=GBRService
...    NRCELL-1:maxGBRTrafficLimit=40
...    NRCELL-1:actIncreasedFdmUsersPerSlot=true
...    NRCELL-1:maxNumPdschAllocationPerSlot=16
...    NRCELL-1:maxNumPuschAllocationPerSlot=16

@{5qi4_related_modification}
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
...    NRBTS/NRDRB-18:l2OHFactorUl=35
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
...    NRBTS/NRDRB_5QI-8:fiveqiValueList=4
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

@{5qi1_related_modification}
...    NRBTS/NRDRB-19:actDddsReduction=false
...    NRBTS/NRDRB-19:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-19:actLostPduFastRetx=false
...    NRBTS/NRDRB-19:discardTimer=100ms
...    NRBTS/NRDRB-19:dlAllowMinDelayLinkXxCalib=false
...    NRBTS/NRDRB-19:dlFlowControlAlgo=none
...    NRBTS/NRDRB-19:dscp=46
...    NRBTS/NRDRB-19:durationThresDiscardDl=40
...    NRBTS/NRDRB-19:durationThresDiscardUl=20
...    NRBTS/NRDRB-19:endMarkerTimer=2000
...    NRBTS/NRDRB-19:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-19:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-19:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-19:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-19:maxTransferDelayGbr=20
...    NRBTS/NRDRB-19:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-6
...    NRBTS/NRDRB-19:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-4
...    NRBTS/NRDRB-19:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-4
...    NRBTS/NRDRB-19:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-19:numSduDiscard=1
...    NRBTS/NRDRB-19:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-19:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-19:resType=GBR
...    NRBTS/NRDRB-19:rlcMode=RLC_UM
...    NRBTS/NRDRB-19:schedulWeight=1
...    NRBTS/NRDRB-19:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-19:volThresDiscardDl=8000
...    NRBTS/NRDRB-19:volThresDiscardUl=800
...    NRBTS/NRDRB-19:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-19:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS/NRDRB-19:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS/NRDRB-19:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS/NRDRB-19:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS/NRDRB-19:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS/NRDRB-19:nsaDrbParam:dlNumOfCongOrGainDdds=2
...    NRBTS/NRDRB-19:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS/NRDRB-19:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS/NRDRB-19:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS/NRDRB-19:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS/NRDRB-19:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-19:nsaDrbParam:prioritizeX2Period=500
...    NRBTS/NRDRB-19:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-19:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS/NRDRB_5QI-9:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-9:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-19
...    NRBTS/NRDRB_MAC-6:delayTarget=50
...    NRBTS/NRDRB_MAC-6:lcgid=4
...    NRBTS/NRDRB_MAC-6:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-6:schedulBSD=50ms
...    NRBTS/NRDRB_MAC-6:schedulPrio=5
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50

${UE_Capa_Support_VONR}    SEPARATOR=
...    E1A01000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB28986801EB608080838778E1C830
...    E0008193C7D5C0013C0070004F000A8D899AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626
...    EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CA261A007AD8202020E1DE
...    38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000
...    E54D000100000965950034AAA85800E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094450

*** Test Cases ***
LBT27588_01_ICS_failure_redirect_to_eutran
    [Documentation]
    ...    1.Description
    ...    To validate the gNB behaviour during the admission control to check if UE can fallback to eutran.
    ...    2.Configuration
    ...      a.SA,TDD.
    ...      b.Configured feature: NRBTS:actNormVCFallback=true and NRCELL-1:actGBRAdmissionControl=GBRService.
    ...    3.Test Steps
    ...      a.UE attach to target cell w optimized way,with VONR.
    ...      b.UE enter idle.
    ...      c.Online modify maxGBRTrafficLimit to reject VONR when UE reconnect.
    ...      d.Ue exit idle.
    [Tags]    QC_320727    owner-kexin.bao
    First UE Attach    ue_id=1    cell_id=1
    Another UE attach with 2PDU Enter Idle    ue_id=2    cell_id=1
    OnlineParamChange    NRCELL-1:maxGBRTrafficLimit=0
    Exit Idle    ue_id=2    pass_regexp=RAN ims voice eps fallback or rat fallback triggered
    UE Deregister From gNB    ue_id=1
    UE Deregister From gNB    ue_id=2
    OnlineParamChange    NRCELL-1:maxGBRTrafficLimit=40
    Check Wireshark Log    ${CURDIR}${/}a2a_LBT27588_01${/}a2a.ini    wait_string=UEContextReleaseComplete::16

LBT27588_02_ICS_failure_with_other_reasons_with_normal_rrc_release
    [Documentation]
    ...    1.Description
    ...    To validate the gNB behaviour during the admission control to check if UE can be released.
    ...    2.Configuration
    ...      a.SA,TDD.
    ...      b.Configured feature: NRCELL-1:actGBRAdmissionControl=GBRService.
    ...    3.Test Steps
    ...      a.UE attach to target cell w optimized way,with VONR.
    ...      b.UE enter idle.
    ...      c.Online modify maxGBRTrafficLimit to reject VONR when UE reconnect.
    ...      d.Set Security command fail or delay.
    ...      e. ue exit idle.
    [Tags]    QC_320726    owner-kexin.bao
    First UE Attach    ue_id=3    cell_id=1
    Another UE attach with 2PDU Enter Idle    ue_id=2    cell_id=1
    Another UE attach with 2PDU Enter Idle    ue_id=1    cell_id=1
    OnlineParamChange    NRCELL-1:maxGBRTrafficLimit=0
    Exit Idle With SMC Fail    ue_id=2    pass_regexp=radio resources not available
    Exit Idle With SMC Timeout    ue_id=1    pass_regexp=radio resources not available
    UE Deregister From gNB    ue_id=3
    Check Wireshark Log    ${CURDIR}${/}a2a_LBT27588_02${/}a2a.ini    wait_string=UEContextReleaseComplete::20

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15

Modify Cfg
    ${set_amf1}    catenate    amf_param id=1 full_nas_auth=on nia=snow3g+zuc+aes+null nea=snow3g+zuc+aes+null
    ...    ims_voice_3gpp=on voice_fallback=on
    Update Cfg    ${set_amf1}
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=400 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7 default=on
    Update Cfg    set_qosflow id=8 5qi=8
    Update Cfg    set_qosflow id=9 5qi=9
    Update Cfg    ue_param id=1 ue_nr_capabilities=${UE_Capa_Support_VONR}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${UE_Capa_Support_VONR}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${UE_Capa_Support_VONR}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table :

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

First UE Attach
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=5 priority=1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=4
    Execute Egate Command    qosflow_modify qos_flow=4 gfbr_dl=1000
    UE Attach To Target Cell    ue_id=${ue_id}    cell_id=${cell_id}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=1    pdu=1    send_dl=5    send_ul=3    sleep_time=10s
    Send And Verify Throuput    ue_id=${ue_id}    qfi=2    pdu=1    send_dl=5    send_ul=3    sleep_time=10s

Another UE attach with 2PDU Enter Idle
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=9 priority=1
    UE Attach To Target Cell    ue_id=${ue_id}    cell_id=${cell_id}
    Execute Egate Command    qosflow_modify default=on qos_flow=5 priority=1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=1    QoS Routing Table :
    Execute Egate Command    ue_ng_ctx_release id=${ue_id} by=amf cause=RN_successful_handover    UE CONTEXT RELEASE COMPLETE
    Execute Egate Command    amf_ue_ics_param id=${ue_id} include_ue_capabilities=on

Exit Idle
    [Arguments]    ${ue_id}    ${pass_regexp}
    Execute Egate Command    amf_ue_ics_param id=${ue_id} include_ue_capabilities=on
    Execute Egate Command    ue_im_exit id=${ue_id} by=ue    pass_regexp=${pass_regexp}

Exit Idle With SMC Fail
    [Arguments]    ${ue_id}    ${pass_regexp}
    Execute Egate Command    amf_ue_ics_param id=${ue_id} include_ue_capabilities=on
    Execute Egate Command    ue_rrc_sec_mode_param id=${ue_id} if_contains=any action=failure
    Execute Egate Command    ue_im_exit id=${ue_id} by=ue    pass_regexp=${pass_regexp}

Exit Idle With SMC Timeout
    [Arguments]    ${ue_id}    ${pass_regexp}
    Execute Egate Command    amf_ue_ics_param id=${ue_id} include_ue_capabilities=on
    Execute Egate Command    ue_rrc_sec_mode_param id=${ue_id} if_contains=any action=none delay=60000
    Execute Egate Command    ue_im_exit id=${ue_id} by=ue    pass_regexp=${pass_regexp}
