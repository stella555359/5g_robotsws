*** Settings ***
Suite Setup     Common Suite Setup And Setup Airphone Env
Suite Teardown      Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_FDD    SBTS00    team-Jazz_SGT&A    owner-jolin.fan
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
...    NRDRB-15:discardTimer=100ms
...    NRDRB-15:dlFlowControlAlgo=none
...    NRDRB-15:dscp=46
...    NRDRB-15:durationThresDiscard=50
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
...    NRDRB-15:rlcMode=RLC_UM
...    NRDRB-15:schedulWeight=1
...    NRDRB-15:sduDiscardIntervalTmr=100
...    NRDRB-15:volThresDiscard=100
...    NRDRB-15:maxDataRateGbrDl=1000
...    NRDRB-15:maxDataRateGbrUl=1000
...    NRDRB-16:discardTimer=infinity
...    NRDRB-16:dlFlowControlAlgo=none
...    NRDRB-16:dscp=34
...    NRDRB-16:durationThresDiscard=50
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
...    NRDRB-16:volThresDiscard=100
...    NRDRB_5QI-6:fiveqiValueList=1
...    NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRDRB_5QI-7:fiveqiValueList=128
...    NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16

@{GNB_PMQAP}
...    NRBTS:actNrpmqapProfiles=true
...    NRPMRNL-1:miNrHighRlcCellNrpmqap=5min
...    NRPMRNL-1:miNrNgInterfaceNrpmqap=5min
...    NRPMRNL-1:miNrNsaAcCuNrpmqap=5min
...    NRPMRNL-1:miNrPdcpCellNrpmqap=5min
...    NRPMRNL-1:miNrSaCuNrpmqap=5min
...    NRPMRNL-1:miNrUeStatNrpmqap=5min
...    NRPMRNL-1:miNrX2ccNrpmqap=5min
...    NRPMRNL-1/NRPMQAP-1:cfgProfType=both
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=5,1
...    NRPMRNL-1/NRPMQAP-1:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sd=13714341
...    NRPMRNL-1/NRPMQAP-2:cfgProfType=both
...    NRPMRNL-1/NRPMQAP-2:cfgQciRange=5
...    NRPMRNL-1/NRPMQAP-2:cfgArpRange=15,1
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-2:cfgSliceId:sd=13714342


${COUNTER_INTERVAL}    5
${AVE_NUMBER_OF_UE_5QI1}    M55125C09528
${AVE_NUMBER_OF_UE_5QI1_DENOM}    M55125C09529
${PEAK_NUMBER_OF_UE_5QI1}    M55125C09530
${PEAK_NUMBER_OF_SA_RRC_USERS}    M55138C00014
${PEAK_NUMBER_OF_SA_NGBR}     M55138C00015
${PEAK_NUMBER_OF_SA_NGBR_USERS}    M55138C00016
${PEAK_NUMBER_OF_SA_RRC_GR}    M55138C00033
${PEAK_NBR_OF_SA_NGBR_USERS_GR}    M55138C00034
${PEAK_NUMBER_OF_SA_NGBR_GR}    M55138C00035
${PEAK_NUMBER_OF_SA_GBR}    M55138C01007
${PEAK_SA_GBR_HOLDING_TIME}    M55138C01010
${PEAK_SA_RRC_HOLDING_TIME}    M55138C00019
${PEAK_SA_NGBR_HOLDING_TIME}    M55138C00022

${PEAK_NUMBER_OF_NSA_USERS_PMQAP}    M55160C00003
${PEAK_NUMB_OF_SA_RRC_USER_PMQAP}    M55161C00003
${PEAK_NUMBER_OF_NSA_USERS_CU}    M55131C00001
${PEAK_NUMBER_OF_NSA_USERS}    M55114C00010
${PEAK_NSA_USER_HOLDING_TIME}    M55114C00013
${PEAK_NUMBER_OF_NSA_USERS_GR}    M55114C00036



#E001 counter check list
@{terminated_PM_Counters_Peak_Number}
...    NRCELL-1:${AVE_NUMBER_OF_UE_5QI1}>1
...    NRCELL-1:${AVE_NUMBER_OF_UE_5QI1_DENOM}=${3*60*${COUNTER_INTERVAL}}
...    NRCELL-1:${PEAK_SA_GBR_HOLDING_TIME}>600000
...    NRCELL-1:${PEAK_SA_RRC_HOLDING_TIME}>600000
...    NRCELL-1:${PEAK_SA_NGBR_HOLDING_TIME}>600000
...    NRCELL-1:${PEAK_NUMBER_OF_UE_5QI1}=3
...    NRCELL-1:${PEAK_NUMBER_OF_SA_RRC_USERS}=3
...    NRCELL-1:${PEAK_NUMBER_OF_SA_NGBR}=6
...    NRCELL-1:${PEAK_NUMBER_OF_SA_NGBR_USERS}=3
...    NRCELL-1:${PEAK_NUMBER_OF_SA_RRC_GR}=3
...    NRCELL-1:${PEAK_NBR_OF_SA_NGBR_USERS_GR}=3
...    NRCELL-1:${PEAK_NUMBER_OF_SA_NGBR_GR}=6
...    NRCELL-1:${PEAK_NUMBER_OF_SA_GBR}=3
...    NRCELL-2/PLMN-PLMN/NRPMQAP-1:${PEAK_NUMBER_OF_NSA_USERS_PMQAP}=3
...    ${PEAK_NUMBER_OF_NSA_USERS_CU}=3
...    NRCELL-2:${PEAK_NSA_USER_HOLDING_TIME}>3
...    NRCELL-2:${PEAK_NUMBER_OF_NSA_USERS}=3
...    NRCELL-2:${PEAK_NUMBER_OF_NSA_USERS_GR}=3


@{last_PM_Counters_Peak_Number}
...    last NRCELL-1:${AVE_NUMBER_OF_UE_5QI1}>1
...    last NRCELL-1:${AVE_NUMBER_OF_UE_5QI1_DENOM}=${60*${COUNTER_INTERVAL}}
...    last NRCELL-1:${PEAK_NUMBER_OF_UE_5QI1}=1
...    last NRCELL-1:${PEAK_NUMBER_OF_SA_RRC_USERS}=1
...    last NRCELL-1:${PEAK_NUMBER_OF_SA_NGBR}=2
...    last NRCELL-1:${PEAK_NUMBER_OF_SA_NGBR_USERS}=1
...    last NRCELL-1:${PEAK_NUMBER_OF_SA_RRC_GR}=1
...    last NRCELL-1:${PEAK_NBR_OF_SA_NGBR_USERS_GR}=1
...    last NRCELL-1:${PEAK_NUMBER_OF_SA_NGBR_GR}=2
...    last NRCELL-1:${PEAK_NUMBER_OF_SA_GBR}=1
...    last NRCELL-1:${PEAK_SA_GBR_HOLDING_TIME}=0
...    last NRCELL-1:${PEAK_SA_RRC_HOLDING_TIME}=0
...    last NRCELL-1:${PEAK_SA_NGBR_HOLDING_TIME}=0
...    last NRCELL-2/PLMN-PLMN/NRPMQAP-1:${PEAK_NUMBER_OF_NSA_USERS_PMQAP}=1
...    last NRCELL-2/PLMN-PLMN/NRPMQAP-2:${PEAK_NUMBER_OF_NSA_USERS_PMQAP}=0
...    last NRCELL-1/PLMN-PLMN/NRPMQAP-1:${PEAK_NUMB_OF_SA_RRC_USER_PMQAP}=1
...    last NRCELL-1/PLMN-PLMN/NRPMQAP-2:${PEAK_NUMB_OF_SA_RRC_USER_PMQAP}=0
...    last ${PEAK_NUMBER_OF_NSA_USERS_CU}=1
...    last NRCELL-2:${PEAK_NUMBER_OF_NSA_USERS}=1
...    last NRCELL-2:${PEAK_NUMBER_OF_NSA_USERS_GR}=1
...    last NRCELL-2:${PEAK_NSA_USER_HOLDING_TIME}=0

*** Test Cases ***
CB008200-ET-E001_Verify Average and Peak Number of Connected 5QI-1 Ues
    [Documentation]
    ...    1. The purpose of this test case is to verify Average and Peak Number of Connected 5QI-1 Ues
    ...    2. Test Case Steps:
    ...         Step 1: Setup 1 video call(5QI-5(nonGBR_Signaling)+5QI-1(GBR)+5QI-2) by InitialContextSetupRequest successfully,
    ...         Step 2: last for 5 minute, release ue
    ...    3. Expected Results:
    ...         Step 1: increase the counter
    ...                 PEAK_NUMBER_OF_UE_5QI1=1
    ...         Step 2: increase the counter
    ...                 PEAK_NUMBER_OF_UE_5QI1=1
    [Tags]  QC_161103    E01    owner-jolin.fan
    Video Call Setup
    NSA Call Setup
    Check Counters    ${last_PM_Counters_Peak_Number}
    NSA UE Detach    ue_id=31
    Video Call Release

*** Keywords ***
#common suite keyword
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
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
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1 qos_flows=4,3,2,1 qos_rules=1,2,3,4 amf=1-6
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1 qos_flows=4,3,2,1 qos_rules=1,2,3,4 amf=1-6
    Update Cfg    ue_param id=1 nr_usage_setting=voice_centric ue_nr_capabilities=${5qi1_UE_Capabilities}


UE Register And Add Pdu With 5QI5 and 5QI1 5QI2
    [Arguments]    ${ue_id}    ${type}=${EMPTY}
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2,4
    Execute Egate Command    ue_register id=${ue_id} nwslice=1  pass_regexp=Received REGISTRATION COMPLETE
    ${cmd}    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}
    Execute Egate Command    ${cmd}    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1

Ue Deregister
    [Arguments]    ${ue_id}    ${cause}=RN_radio_connection_with_ue_lost
    Execute Egate Command    amf_ue_ctx_release_param id=1 action=override_cause cause=${cause}
    ${cmd_Deregister}=    Set Variable    ue_deregister id=${ue_id} ue_deregister_type=switch_off
    Execute Egate Command    ${cmd_Deregister}    pass_regexp=AMF-1: UE CONTEXT RELEASE COMPLETE: gNB=2

Video Call Setup
    Clear Counter Files
    UE Register And Add Pdu With 5QI5 and 5QI1 5QI2    ue_id=1

Video Call Release
    #Clear Counter Files
    Ue Deregister    ue_id=1    cause=NAS_normal_release
    Check Counters    ${terminated_PM_Counters_Peak_Number}
    Release ues    ue_type=all

NSA Call Setup
    UE Attach To Enb Cell1    ue_id=31
    Initial Endc    ue_id=31    target_gnb=2    target_cells=2    bearer_id=2
    Send And Verify Throuput    ue_id=31

UE Attach To Enb Cell1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

Initial Endc
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=1
    ${ret1}=    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    Successfully reconfigured dual connectivity

Send And Verify Throuput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=100 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10    UE ${ue_id}: UDP UL
    Verify Throuput    ue_id=${ue_id}    sleep_time=30s

Verify Throuput
    [Arguments]    ${ue_id}=1    ${sleep_time}=15s
    sleep    ${sleep_time}

    
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>8
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>90

NSA UE Detach
  [Arguments]    ${ue_id}=1    ${expect_string}=${EMPTY}
  Execute Egate Command    ue_detach id=${ue_id}    ${expect_string}
