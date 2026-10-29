*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-tao.2.cui
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    CB008120    release-SBTS23R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${ap_snssai_1}    0x01:0xD143A5
${ap_snssai_2}    0x01:0xD143A6
${ap_snssai_3}    0x03:0xD143A7
${ap_snssai_4}    0x04:0xFFFFFF
${ap_snssai_5}    0x00:0xD143A6
${ap_snssai_6}    0x42:0xFFFFFF
${ap_snssai_9}    0x63:0xD143A6
${ap_snssai_10}    0x7F:0xFFFFFF
${gnb3_snssai_1}    ${ap_snssai_9}
${gnb3_snssai_2}    ${ap_snssai_10}
${gbr_2}    72
${gbr_4}    76
${non_gbr_6}    6
${non_gbr_8}    8
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/L1B/6cells_4T2F
${snssaiDNList}    SEPARATOR=
...    MRBTS-1/NRBTS-1/SNSSAI-1,MRBTS-1/NRBTS-1/SNSSAI-2,MRBTS-1/NRBTS-1/SNSSAI-3,MRBTS-1/NRBTS-1/SNSSAI-4,
...    MRBTS-1/NRBTS-1/SNSSAI-5,MRBTS-1/NRBTS-1/SNSSAI-6,MRBTS-1/NRBTS-1/SNSSAI-7,MRBTS-1/NRBTS-1/SNSSAI-8,
...    MRBTS-1/NRBTS-1/SNSSAI-9,MRBTS-1/NRBTS-1/SNSSAI-10
@{PARAMS_IN_SCF}
...    @{Gnb_GBR}
...    @{CB008379}
...    @{CB008120}
...    @{5GC002145}
...    @{VONR}
@{Gnb_GBR}

...    NRDRB_5QI-1:fiveqiValueList=5
...    NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-5
...    NRDRB_5QI-2:fiveqiValueList=${non_gbr_6}
...    NRDRB_5QI-2:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-6
...    NRDRB_5QI-6:fiveqiValueList=7
...    NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-4:fiveqiValueList=${non_gbr_8}
...    NRDRB_5QI-4:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-8
...    NRDRB_5QI-5:fiveqiValueList=129
...    NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-9
...    NRDRB_5QI-7:fiveqiValueList=3
...    NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRDRB_5QI-8:fiveqiValueList=${gbr_2}
...    NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...    NRDRB_5QI-9:fiveqiValueList=${gbr_4}
...    NRDRB_5QI-9:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-11
...    NRDRB_5QI-10:fiveqiValueList=4
...    NRDRB_5QI-10:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...    NRDRB-2:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-1
...    NRDRB-2:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-2:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-2:dlFlowControlAlgo=3gppFlowControl
...    NRDRB-2:rlcMode=RLC_AM
...    NRDRB-2:discardTimer=infinity
...    NRDRB-3:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRDRB-3:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-3:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-3:resType=GBR
...    NRDRB-3:rlcMode=RLC_AM
...    NRDRB-3:maxDataRateGbrDl=30720
...    NRDRB-3:maxDataRateGbrUl=30720
...    NRDRB-3:l2OHFactorDl=16
...    NRDRB-3:l2OHFactorUl=35
...    NRDRB-3:discardTimer=50ms
...    NRDRB-3:dlFlowControlAlgo=3gppFlowControl
...    NRDRB-3:maxRlcQueueingDelayGbr=20
...    NRDRB-3:maxTransferDelayGbr=20
...    NRDRB-3:queuingDelayDiscarding=Disabled
...    NRDRB-3:dscp=46
...    NRDRB-5:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRDRB-5:resType=nonGBR_Signaling
...    NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRDRB-10:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-10:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-10:resType=GBR
...    NRDRB-10:rlcMode=RLC_UM
...    NRDRB-10:maxDataRateGbrDl=30720
...    NRDRB-10:maxDataRateGbrUl=30720
...    NRDRB-10:l2OHFactorDl=16
...    NRDRB-10:l2OHFactorUl=35
...    NRDRB-10:discardTimer=50ms
...    NRDRB-10:dlFlowControlAlgo=none
...    NRDRB-10:maxRlcQueueingDelayGbr=20
...    NRDRB-10:maxTransferDelayGbr=20
...    NRDRB-10:queuingDelayDiscarding=Disabled
...    NRDRB-11:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRDRB-11:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-11:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-11:resType=GBR
...    NRDRB-11:rlcMode=RLC_AM
...    NRDRB-11:maxDataRateGbrDl=30720
...    NRDRB-11:maxDataRateGbrUl=30720
...    NRDRB-11:l2OHFactorDl=16
...    NRDRB-11:l2OHFactorUl=35
...    NRDRB-11:discardTimer=50ms
...    NRDRB-11:dlFlowControlAlgo=3gppFlowControl
...    NRDRB-11:maxRlcQueueingDelayGbr=20
...    NRDRB-11:maxTransferDelayGbr=20
...    NRDRB-11:queuingDelayDiscarding=Disabled
...    NRDRB_MAC-3:lcgid=5
...    NRDRB_MAC-3:delayTarget=50
...    NRDRB_MAC-3:schedulBSD=20ms
...    NRDRB_MAC-5:lcgid=0
...    NRDRB_MAC-5:prioritisedBitRate=16kBps
...    NRDRB_MAC-5:schedulPrio=12
...    NRDRB_MAC-5:schedulBSD=${EMPTY}
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms15
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms15
...    NRDRB_PDCP-1:pdcpBufDiscardEnabled=false
...    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
@{CB008379}
...    NRCELL-1:actNonVoNRGbrService=true
...    NRCELL-2:actNonVoNRGbrService=true
...    NRCELL-1:actGBRAdmissionControl=GBRService
...    NRCELL-2:actGBRAdmissionControl=GBRService
@{CB008120}
...    NRBTS:activityNotificationLevelSA=drb
...    NRBTS:actAdditionalSliceSupport=true
...    NRBTS/SNSSAI-2:drbInactivityTimerSA=100
...    NRBTS/SNSSAI-2:sst=1
...    NRBTS/SNSSAI-2:sd=13714342
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-2:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-3:sst=3
...    NRBTS/SNSSAI-3:sd=13714343
...    NRBTS/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-3:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-4:sst=4
...    NRBTS/SNSSAI-4:sd=${EMPTY}
...    NRBTS/SNSSAI-4:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-4:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-5:drbInactivityTimerSA=100
...    NRBTS/SNSSAI-5:sst=0
...    NRBTS/SNSSAI-5:sd=13714342
...    NRBTS/SNSSAI-5:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-5:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-6:drbInactivityTimerSA=100
...    NRBTS/SNSSAI-6:sst=66
...    NRBTS/SNSSAI-6:sd=${EMPTY}
...    NRBTS/SNSSAI-6:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-6:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-7:drbInactivityTimerSA=100
...    NRBTS/SNSSAI-7:sst=77
...    NRBTS/SNSSAI-7:sd=13714342
...    NRBTS/SNSSAI-7:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-7:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-8:drbInactivityTimerSA=100
...    NRBTS/SNSSAI-8:sst=88
...    NRBTS/SNSSAI-8:sd=${EMPTY}
...    NRBTS/SNSSAI-8:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-8:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-9:drbInactivityTimerSA=100
...    NRBTS/SNSSAI-9:sst=99
...    NRBTS/SNSSAI-9:sd=13714342
...    NRBTS/SNSSAI-9:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-9:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-10:drbInactivityTimerSA=100
...    NRBTS/SNSSAI-10:sst=127
...    NRBTS/SNSSAI-10:sd=${EMPTY}
...    NRBTS/SNSSAI-10:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-10:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-4|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-4
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-5|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-5
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-6|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-6
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-7|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-7
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-8|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-8
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-9|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-9
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-10|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-10

...    NRBTS:drbInactivityTimerSA=60
...    NRBTS:srbInactivityTimerSA=20
...    NRBTS/SNSSAI-3:drbInactivityTimerSA=30
...    NRBTS/SNSSAI-4:drbInactivityTimerSA=${EMPTY}
@{5GC002145}
...    NRBTS/TRACKINGAREA-788:fiveGsTac=788
#...    NRBTS/TRACKINGAREA-788:snssaiDNList=${snssaiDNList}
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-4|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-4
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-5|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-5
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-6|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-6
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-7|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-7
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-8|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-8
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-9|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-9
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-10|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-10

@{VONR}
...    NRCELL-1:actVoNR=true
...    NRCELL-2:actVoNR=true

...    NRDRB_5QI-3:fiveqiValueList=1
...    NRDRB_5QI-3:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-12
...    NRDRB-12:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRDRB-12:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-12:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-12:resType=GBR
...    NRDRB-12:rlcMode=RLC_UM
...    NRDRB-12:maxDataRateGbrDl=30720
...    NRDRB-12:maxDataRateGbrUl=30720
...    NRDRB-12:l2OHFactorDl=16
...    NRDRB-12:l2OHFactorUl=35
...    NRDRB-12:queuingDelayDiscarding=Disabled
...    NRDRB-12:dscp=46
...    NRDRB-12:discardTimer=150ms
...    NRDRB-12:dlFlowControlAlgo=none
...    NRDRB-12:maxRlcQueueingDelayGbr=20
...    NRDRB-12:maxTransferDelayGbr=20
...    NRDRB_MAC-4:lcgid=4
...    NRDRB_MAC-4:delayTarget=50
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm6bitSN
...    NRCELL-1:actEnhancedVoNR=true
...    NRCELL-2:actEnhancedVoNR=true
...    NRBTS:tRLFindForDUVoNR=2000ms
...    NRCELL-1:n310VoNR=n20
...    NRCELL-1:t310VoNR=4000ms
...    NRCELL-2:n310VoNR=n20
...    NRCELL-2:t310VoNR=4000ms
@{Case14_OnlineParam}
...    NRBTS:srbInactivityTimerSA=15
...    NRBTS/NRDRB-2:drbInactivityTimerSA=20
...    NRBTS/NRDRB-8:drbInactivityTimerSA=80
...    NRBTS/SNSSAI-3:drbInactivityTimerSA=30
...    NRBTS/SNSSAI-4:drbInactivityTimerSA=40

*** Test Cases ***
CB008120_13_UE_rel_expiration_of_SNSSAI_InactivityTimer_1
    [Documentation]
    ...    The purpose of this test case is to verify creating Slice with
    ...    standarized SST value from new range successful
    ...    Step1: ue register
    ...    Step2: Add QoSFlow
    ...    Step3: PDU Setup
    ...    Step4: Add QoSFlow
    ...    Step5: Send and Verify Throughput
    [Tags]    QC_222487    owner-tao.2.cui
    SA UE Attach    ue_id=81    cell_id=1    pdu_id=1    nwslice_id=3    gw_id=1
    PDU Add QoSFlow    ue_id=81    pdu_id=1    qfi_id=8
    Send And Verify Throuput    ue_id=81    pdu_id=1    qfi_id=1    send_dl=10    send_ul=10    sleep_time=20s
    PDU Setup QoSFlow    ue_id=81    pdu_id=2    nwslice_id=4    gw_id=2
    PDU Add QoSFlow    ue_id=81    pdu_id=2    qfi_id=8
    Send And Verify Throuput    ue_id=81    pdu_id=2    qfi_id=1    send_dl=10    send_ul=10    sleep_time=20s
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}a2a_13${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008120_14_UE_rel_expiration_of_NRDRB_InactivityTimer_1
    [Documentation]
    ...    The purpose of this test case is to verify creating Slice with
    ...    standarized SST value from new range successful
    ...    Step1: ue register
    ...    Step2: Add QoSFlow
    ...    Step3: PDU Setup
    ...    Step4: Add QoSFlow
    ...    Step5: Send and Verify Throughput
    [Tags]    QC_221192    owner-tao.2.cui
    onlineParamChange    ${Case14_OnlineParam}
    SA UE Attach    ue_id=81    cell_id=1    pdu_id=1    nwslice_id=3    gw_id=1
    PDU Add QoSFlow    ue_id=81    pdu_id=1    qfi_id=8
    Send And Verify Throuput    ue_id=81    pdu_id=1    qfi_id=1    send_dl=10    send_ul=10    sleep_time=20s
    PDU Setup QoSFlow    ue_id=81    pdu_id=2    nwslice_id=4    gw_id=2
    PDU Add QoSFlow    ue_id=81    pdu_id=2    qfi_id=8
    Send And Verify Throuput    ue_id=81    pdu_id=2    qfi_id=1    send_dl=10    send_ul=10    sleep_time=20s
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}a2a_14${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=1 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=2 5qi=${gbr_2} gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=${gbr_4} gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=${non_gbr_6}
    Update Cfg    set_qosflow id=7 5qi=7 default=on priority=7
    Update Cfg    set_qosflow id=8 5qi=${non_gbr_8}
    Update Cfg    set_qosflow id=9 5qi=129
    Update Cfg    set_qosflow id=10 5qi=4 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 qos_flows=10,9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=${ap_snssai_1} default=on ue=all amf=1
    Update Cfg    set_nwslice id=2 qos_flows=10,9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=${ap_snssai_2} default=off ue=all amf=1
    Update Cfg    set_nwslice id=3 qos_flows=10,9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=${ap_snssai_3} default=off ue=all amf=1
    Update Cfg    set_nwslice id=4 qos_flows=10,9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=${ap_snssai_4} default=off ue=all amf=1
    Update Cfg    set_nwslice id=5 qos_flows=10,9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=${ap_snssai_5} default=off ue=all amf=1
    Update Cfg    set_nwslice id=6 qos_flows=10,9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=${ap_snssai_6} default=off ue=all amf=1
    Update Cfg    set_nwslice id=9 qos_flows=10,9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=${ap_snssai_9} default=off ue=all amf=1
    Update Cfg    set_nwslice id=10 qos_flows=10,9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=${ap_snssai_10} default=off ue=all amf=1
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.3.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=5 ue_nat_ip=72.23.4.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=6 ue_nat_ip=72.23.5.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=7 ue_nat_ip=72.23.6.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=8 ue_nat_ip=72.23.7.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=9 ue_nat_ip=72.23.8.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=10 ue_nat_ip=72.23.9.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=11 ue_nat_ip=72.23.10.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=12 ue_nat_ip=72.23.11.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=13 ue_nat_ip=72.23.12.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=14 ue_nat_ip=72.23.13.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=15 ue_nat_ip=72.23.14.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    ${gnb_3}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22
    ...    daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.122 nssai=${gnb3_snssai_1},${gnb3_snssai_2} amf=1
    Update Cfg    ${gnb_3}
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false sib1_period=3000
    ${gnb3_cell1}    catenate
    ...    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01
    ...    tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=633000:633000 gscn=7840
    Update Cfg    ${gnb3_cell1}
    ${gnb4_cell1}    catenate
    ...    set_cell id=1 gnb=4 pci=127:0 tac=788 nrci=0x01
    ...    tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=633000:633000 gscn=7840
    Update Cfg    ${gnb4_cell1}
    ${gnb_5}    catenate
    ...    set_gnb id=5 s1u=10.0.1.129 plmn=311:489 gnb_id=0x5 type=simulated
    ...    daemon=10.0.2.1:22222 x2=10.0.1.128:36422 x2_peers=none
    Update Cfg    ${gnb_5}
    Update Cfg    gnb_param id=5 x2_listening_socket=1 measEvent=A3
    Update Cfg    gnb_endc_param id=5 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0
    ${gnb5_cell1}    catenate
    ...    set_cell id=1 gnb=5 tac=3 pci=128:0 proxy=10.0.2.1:12221|10.0.2.1:8891 nrci=0x1
    ...    nr_arfcn=2071591:2071591 tdd_cell=on gscn=22446 mandatory_for_activation=off
    Update Cfg    ${gnb5_cell1}
    ${gnb_6}    catenate
    ...    set_gnb id=6 type=simulated plmn=311:489 ng=10.0.1.127 daemon=10.0.2.1:22222 gnb_id=0x19:28
    ...    nssai=0x01:0xD143A5 x2_peers=none xn=10.0.1.126 amf=1
    Update Cfg    ${gnb_6}
    Update Cfg    gnb_param id=6 xn_listening_socket=1 send_xn_setup=false
    ${gnb6_cell1}    catenate
    ...    set_cell id=1 gnb=6 pci=4:0 earfcn=39750:39750 tac=200 proxy=10.0.2.93:9999 nrci=0x1
    ...    tdd_cell=on bw=20MHz technology=lte mandatory_for_activation=off
    Update Cfg    ${gnb6_cell1}
    ${enb_11}    catenate
    ...    set_enb id=11 plmn=311:489 s1=10.0.1.140 enb_id_macro=0x12347
    ...    daemon=10.0.2.1:22222 x2=10.0.1.141 x2u=10.0.1.142 type=simulated x2_peers=none
    Update Cfg    ${enb_11}
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    ${enb11_cell1}    catenate
    ...    set_cell id=1 enb=11 eci=0x1234701 pci=7:0 tac=222 proxy=10.0.2.1:12217|10.0.2.1:8887
    ...    earfcn=2000:20000 mapped_earfcn=4200:22200 mandatory_for_activation=off
    Update Cfg    ${enb11_cell1}

onlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

SA UE Attach
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    is now Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${gw_id} ue=${ue_id} nwslice=${nwslice_id}    Initial Context Setup Successful

PDU Setup QoSFlow
    [Arguments]    ${ue_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice_id} gw=${gw_id}    Setup QosFlow with QFI

PDU Add QoSFlow
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qfi_id} by=amf    QoS Routing Table

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached

Verify Throuput
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi_id}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${send_dl}=10    ${send_ul}=10    ${sleep_time}=20s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${pdu_id}    ${qfi_id}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}
