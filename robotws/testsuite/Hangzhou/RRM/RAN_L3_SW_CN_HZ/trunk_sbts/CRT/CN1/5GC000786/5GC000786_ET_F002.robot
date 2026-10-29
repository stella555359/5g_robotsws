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
...    @{PARAMS_FOR_5QI9}
...    @{PARAMS_FOR_SECURITY}
...    @{PARAMS_FOR_OTHERS}
...    @{PARAMS_FOR_VCFB}
...    @{PARAMS_FOR_NWSLICE}
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
@{PARAMS_FOR_SECURITY}
...    NRBTS:cipherPrefL:nea0=1
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=9
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=9
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
@{PARAMS_FOR_NWSLICE}
...    NRBTS/SNSSAI-2:sd=13714342
...    NRBTS/SNSSAI-2:administrativeState=Unlocked
...    NRBTS/SNSSAI-2:sst=1
...    NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1

${UE_NR_CAPABILITIES}    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C80008780818806804C020301C032A36146B04050D012CB2898087AD8202020E1DE38720C3800206
...    4F1F570004F001C0013C002A36266B04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D01
...    2CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB2898087AD8202020E1DE38720C38002064F
...    1F55000005000000108389A00000000404D0301C020227FAAAAA81601800140E020381802C03800341F000000000000072A68000800004B2
...    CA801A5554040E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094C35A

*** Test Cases ***
5GC000786-ET-F002_Verify Successful setup of Voice over NR call together with non-GBR and UE capability included in ICSR
    [Documentation]
    ...    it will cover IMS Video call setup ICS successfully with 5QI5 and 5QI1, also verify that UE capabilities are included in ICS and 5QI5 and
    ...    5QI1 is release normal
    [Tags]    QC_61519
    Trigger UE register in cell1    ue_id=1
    Trigger UE1 setup ICS successfully with 5QI5 and 5QI1
    Trigger UE1 5QI9 SETUP successfully
    Trigger UE1 5QI5 and 5QI1 release successfully
    Release Ues    ue_type=all
    Check Wireshark Log    ${CURDIR}/a2a_F002/a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on voice_fallback=on
    # UE configuration
    Update Cfg Param    set_ue simulated id=1 nia=null+aes nea=null+aes
    Update Cfg    ue_param id=1 ue_nr_capabilities=${UE_NR_CAPABILITIES} nr_usage_setting=voice_centric
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg Param    set_ue simulated id=2 nia=null+aes nea=null+aes
    Update Cfg    ue_param id=2 ue_nr_capabilities=${UE_NR_CAPABILITIES} nr_usage_setting=voice_centric
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    # 5QI configuration
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1-6 qos_flows=1,2,3 qos_rules=1,2,3
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1-6 amf=1-6 qos_flows=3 qos_rules=3

Trigger UE register in cell1
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered

Trigger UE1 setup ICS successfully with 5QI5 and 5QI1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2
    Execute Egate Command    amf_ue_ics_param id=1 include_ue_capabilities=on ue_capabilities=${UE_NR_CAPABILITIES}
    ${ret1}    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1    QoS Routing Table
    Should Contain    ${ret1}    drb-Identity 4
    Should Contain    ${ret1}    drb-Identity 5
    Should Contain    ${ret1}    UE1: Ue 1 PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1
    Should Contain    ${ret1}    UE1: Ue 1 PduId 1 Created FiveQi:Qfi mapping fiveQi 1 qfi 2
    Should Contain    ${ret1}    AMF-1: Setup QosFlow with QFI:1 5QI:5
    Should Contain    ${ret1}    AMF-1: Setup QosFlow with QFI:2 5QI:1

Trigger UE1 5QI9 SETUP successfully
    ${ret1}    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=2 nwslice=2 gw=2    QoS Routing Table
    Should Contain    ${ret1}    Setup QosFlow with QFI:1 fiveQI:9 TEID:2
    Should Contain    ${ret1}    drb-Identity 6
    Should Contain    ${ret1}    Setup QosFlow with QFI:1 5QI:9

Trigger UE1 5QI5 and 5QI1 release successfully
    ${ret1}    Execute Egate Command    ue_pdu_session_release pdu=1 ue=1 by=ue
    ...    Successfully released PDU Session with ID
    Should Contain    ${ret1}    drb-ToReleaseList
    Should Contain    ${ret1}    4
    Should Contain    ${ret1}    5
    Should Contain    ${ret1}    Successfully released PDU Session with ID

