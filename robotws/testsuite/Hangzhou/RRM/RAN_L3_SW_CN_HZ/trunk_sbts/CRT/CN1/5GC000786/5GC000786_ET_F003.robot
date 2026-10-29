*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    STATE_CONFIGURED
...    owner-ying.5.chen    owner-yin.zhang    team-SG2    release-5G20B    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}
...    @{PARAMS_FOR_5QI2}
...    @{PARAMS_FOR_5QI9}
...    @{PARAMS_FOR_SECURITY}
...    @{PARAMS_FOR_OTHERS}
...    @{PARAMS_FOR_VCFB}
...    @{PARAMS_FOR_NWSLICE}
...    @{PARAMS_FOR_DRX}
@{PARAMS_FOR_5QI5}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-10:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-10:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRBTS/NRDRB-10:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-4:lcgid=0
...    NRBTS/NRDRB_MAC-4:schedulPrio=4
...    NRBTS/NRDRB_PDCP-2:tReorderingDl=ms100
...    NRBTS/NRDRB_PDCP-2:tReorderingUl=ms100
...    NRBTS/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_RLC_AM-2:ulMaxRetxThreshold=t16
@{PARAMS_FOR_5QI1}
...    NRCELL-1:actVoNR=true
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=0
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB_MAC-3:lcgid=4
...    NRBTS/NRDRB_MAC-3:schedulPrio=5
...    NRBTS/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
@{PARAMS_FOR_SECURITY}
...    NRBTS:cipherPrefL:nea0=1
...    NRBTS:cipherPrefL:nea1_128=9
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=9
...    NRBTS:integrityProtPrefL:nia2_128=0
...    NRBTS:integrityProtPrefL:nia3_128=0
${InactivityTimer}    60
@{PARAMS_FOR_OTHERS}


...    NRBTS:drbInactivityTimerSA=${InactivityTimer}
...    NRBTS:srbInactivityTimerSA=${InactivityTimer}
@{PARAMS_FOR_VCFB}
...    NRBTS:actNormVCFallback=false
...    NRBTS:actRedirect=true
...    delete:NRCELL-1/NRREDRT-1:redirSsbScs
...    NRCELL-1/NRREDRT-1:redirRat=eutra
...    NRCELL-1/NRREDRT-1:redirFreqEutra=38000
...    NRCELL-1:voiceFBMode=redirection
@{PARAMS_FOR_5QI2}
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=128
...    NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS/NRDRB-16:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-16:dscp=46
...    NRBTS/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-16:numSduDiscard=1
...    NRBTS/NRDRB-16:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-16:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-16:resType=nonGBR
...    NRBTS/NRDRB-16:rlcMode=RLC_UM
...    NRBTS/NRDRB-16:schedulWeight=25
...    NRBTS/NRDRB-16:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB_MAC-2:schedulPrio=7
...    NRBTS/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
@{PARAMS_FOR_5QI9}
...    NRBTS/NRDRB_5QI-5:fiveqiValueList=9
...    NRBTS/NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-14
...    NRBTS/NRDRB-14:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-14:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-14:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-14:resType=nonGBR
...    NRBTS/NRDRB-14:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-2:lcgid=1
...    NRBTS/NRDRB_PDCP-2:cuFlowControlProfId=1
...    NRBTS/NRDRB_RLC_AM-2:duFlowControlProfId=1
@{PARAMS_FOR_NWSLICE}
...    NRBTS/SNSSAI-2:sd=13714342
...    NRBTS/SNSSAI-2:administrativeState=Unlocked
...    NRBTS/SNSSAI-2:sst=1
...    NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
@{PARAMS_FOR_DRX}
...    NRCELL-1:actCDrx=true
...    NRCELL-1:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-1:drxProfile1:drxLongCycle=40ms
...    NRCELL-1:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=24slot
...    NRCELL-1:drxProfile1:drxRetransTimerUl=24slot

${UE_NR_CAPABILITIES}    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C80008780818806804C020301C032A36146B04050D012CB2898087AD8202020E1DE38720C3800206
...    4F1F570004F001C0013C002A36266B04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D01
...    2CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB2898087AD8202020E1DE38720C38002064F
...    1F55000005000000108389A00000000404D0301C020227FAAAAA81601800140E020381802C03800341F000000000000072A68000800004B2
...    CA801A5554040E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094C35A

*** Test Cases ***
5GC000786-ET-F003_Verify Successful setup of Video over NR call in PDU Session Setup Request on top of non-GBR bearer and interworking with DRX
    [Documentation]
    ...    it will cover Successful setup of Video over NR call in PDU Session Setup Request on top of non-GBR bearer and and interworking with DRX
    [Tags]    QC_61525
    Trigger UE setup ICS with 5QI9 And Check DRX Setup
    Trigger UE Video call And Check DRX Released
    Trigger UE1 5QI1 and 5QI2 Del And Check DRX Setup
    Trigger UE1 5QI1 and 5QI2 add again And Check DRX Released
    Trigger UE1 5QI5 5QI1 5QI2 release And Check DRX Setup

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+snow3g nea=null+snow3g ims_voice_3gpp=on voice_fallback=on
    # UE configuration
    Update Cfg Param    set_ue simulated id=1 nia=null+snow3g nea=null+snow3g
    Update Cfg    ue_param id=1 ue_nr_capabilities=${UE_NR_CAPABILITIES} nr_usage_setting=voice_centric
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg Param    set_ue simulated id=2 nia=null+snow3g nea=null+snow3g
    Update Cfg    ue_param id=2 ue_nr_capabilities=${UE_NR_CAPABILITIES} nr_usage_setting=voice_centric
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    # 5QI configuration
    Update Cfg    set_qosflow id=1 5qi=9 default=on
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=4 proto=udp qos_flow=4
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1-6 qos_flows=1,2,3,4 qos_rules=1,2,3,4
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1-6 amf=1-6 qos_flows=2,3,4 qos_rules=2,3,4

Trigger UE setup ICS with 5QI9 And Check DRX Setup
    Start To Capture Wireshark Log    ICSestablish
    Execute Egate Command    ue_register id=1    UE now in NG RM Registered
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1    drx-SlotOffset
    Should Contain    ${ret}    drx-Config setup
    Check WireShark Log    ${CURDIR}/a2a_F003/a2a_ICSestablish.ini    ICSestablish    wait_string=UEContextModificationResponse::8

Trigger UE Video call And Check DRX Released
    Start To Capture Wireshark Log    Videocallestablish
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=3,4
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=2 nwslice=2 gw=2    QoS Routing Table
    Should Contain    ${ret}     drx-Config release : NULL
    Check WireShark Log    ${CURDIR}/a2a_F003/a2a_Videocallestablish.ini    Videocallestablish    wait_string=UEContextModificationResponse::4

Trigger UE1 5QI1 and 5QI2 Del And Check DRX Setup
     Start To Capture Wireshark Log    Videocalldel
     ${ret}    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=2 qosflows_to_del=3,4 by=amf
     ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID
     Should Contain    ${ret}    drx-Config setup
     Check WireShark Log    ${CURDIR}/a2a_F003/a2a_Videocalldel.ini    Videocalldel    wait_string=PDU session modification complete::1

Trigger UE1 5QI1 and 5QI2 add again And Check DRX Released
    Start To Capture Wireshark Log    Videocallagain
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=3 nwslice=2 gw=3    QoS Routing Table
    Should Contain    ${ret}     drx-Config release : NULL
    Stop Capture Wireshark Log    Videocallagain

Trigger UE1 5QI5 5QI1 5QI2 release And Check DRX Setup
    Start To Capture Wireshark Log    Videocallrelease
    Execute Egate Command    ue_pdu_session_release pdu=3 ue=1 by=ue    drx-Config setup
    Release Ues    ue_type=all
    Check WireShark Log    ${CURDIR}/a2a_F003/a2a_Videocallrelease.ini    Videocallrelease    wait_string=UEContextReleaseComplete::4

