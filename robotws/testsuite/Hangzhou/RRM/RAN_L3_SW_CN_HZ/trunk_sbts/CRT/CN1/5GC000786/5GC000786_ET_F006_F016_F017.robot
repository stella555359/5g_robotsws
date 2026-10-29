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
...    @{PARAMS_FOR_5QI6}
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
@{PARAMS_FOR_SECURITY}
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
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
@{PARAMS_FOR_5QI6}
...    NRBTS/NRDRB_5QI-2:fiveqiValueList=6
...    NRBTS/NRDRB_5QI-2:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-11
...    NRBTS/NRDRB-11:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-11:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-11:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-11:resType=nonGBR
...    NRBTS/NRDRB-11:rlcMode=RLC_AM
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

${UE_CAPABILITIES_VoNR}    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C80008780818806804C020301C032A36146B04050D012CB2898087AD8202020E1DE38720C3800206
...    4F1F570004F001C0013C002A36266B04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D01
...    2CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB2898087AD8202020E1DE38720C38002064F
...    1F55000005000000108389A00000000404D0301C020227FAAAAA81601800140E020381802C03800341F000000000000072A68000800004B2
...    CA801A5554040E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094C35A

${UE_CAPABILITIES_NO_VoNR}    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C80008780818806804C020301C032A36146B04050D012CB2898087AD8202020E1DE38720C3800206
...    4F1F570004F001C0013C002A36266B04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D01
...    2CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB2898087AD8202020E1DE38720C38002064F
...    1F55000005000000108389A00000000404D0301C020227FAAAAA81601800140E020381802C03800341F000000000000072A68000800004B2
...    CA801A5554040E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094C348

*** Test Cases ***
5GC000786-ET-F006_Verify VoNR call Unsuccessful with ICS non-optimzed procedure due to UE no VoNR capability when Voice Fallback is disabled_AP
    [Documentation]
    ...    it will cover IMS ICS non-optimzed procedure VoNR call Unsuccessful due to UE no VoNR capability,Also verify that GNB behaves correctly
    ...    when Voice Fallback is disabled
    [Tags]    QC_61520
    Delta Commission Parameters    NRBTS:actNormVCFallback=false
    Trigger UE5 register in cell1
    Trigger UE5 voice call is Unsuccessful with 5QI5 and 5QI1
    Release Ues    ue_type=all
    Check WireShark Log    ${CURDIR}/a2a_F006/a2a.ini    wait_string=UEContextReleaseComplete::8

5GC000786-ET-F016_Verify VoNR call fail_PDU Session Setup Request or ICSR due to no 5QI-5 when Voice Fallback to LTE is disabled or enabled
    [Documentation]
    ...    it will cover IMS Voice call unsuccessful in subsequent PDU Session Setup Request due to no 5QI-5 with Voice Fallback is enabled,
    ...    same verify GNB behaves correctly of Voice Fallback.
    ...    and cover IMS Voice call unsuccessful in ICSR due to no 5QI-5 with Voice Fallback is disabled, same verify GNB behaves correctly of Voice
    ...    Fallback.
    [Tags]    QC_61522
    Delta Commission Parameters    NRBTS:actNormVCFallback=true
    Trigger UE1 register in cell1
    Trigger UE1 ICS successfully with 5QI6
    Trigger UE1 Voice call is unsuccessful
    Delta Commission Parameters    NRBTS:actNormVCFallback=false
    Trigger UE2 register in cell1
    Trigger UE2 Voice call is unsuccessful without 5QI5
    Release Ues    ue_type=all
    Check WireShark Log    ${CURDIR}/a2a_F016/a2a.ini    wait_string=UEContextReleaseComplete::12

5GC000786-ET-F017_Verify Video NR call fail_PDU Session Setup Request due to no 5QI-5 or 5QI-1 when Voice Fallback to LTE is disabled or enabled
    [Documentation]
    ...    it will cover IMS Video over NR call unsuccessful due to no 5QI-5 with Voice Fallback is disabled, same verify GNB behaves correctly of
    ...    Voice Fallback.
    ...    and cover IMS Video over NR call unsuccessful due to no 5QI-1 with Voice Fallback is enabled, same verify GNB behaves correctly of
    ...    Voice Fallback.
    [Tags]    QC_61523
    Delta Commission Parameters    NRBTS:actNormVCFallback=false
    Trigger UE3 register in cell1
    Trigger UE3 ICS successfully with 5QI6
    Trigger UE3 Video call is unsuccessful without 5QI5
    Delta Commission Parameters    NRBTS:actNormVCFallback=true
    Trigger UE4 register in cell1
    Trigger UE4 ICS successfully with 5QI6
    Trigger UE4 Video call is unsuccessful with 5QI5 and 5QI2
    Release Ues    ue_type=all
    Check WireShark Log    ${CURDIR}/a2a_F017/a2a.ini    wait_string=UEContextReleaseComplete::12

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on voice_fallback=on
    # UE configuration
    Update Cfg Param    set_ue simulated id=1 nia=null+aes nea=null+aes
    Update Cfg    ue_param id=1 ue_nr_capabilities=${UE_CAPABILITIES_VoNR} nr_usage_setting=voice_centric
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg Param    set_ue simulated id=2 nia=null+aes nea=null+aes
    Update Cfg    ue_param id=2 ue_nr_capabilities=${UE_CAPABILITIES_VoNR} nr_usage_setting=voice_centric
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    Update Cfg Param    set_ue simulated id=3 nia=null+aes nea=null+aes
    Update Cfg    ue_param id=3 ue_nr_capabilities=${UE_CAPABILITIES_VoNR} nr_usage_setting=voice_centric
    Update Cfg    ue_nr_capabilities id=3 voice_over_nr=on:on:off
    Update Cfg Param    set_ue simulated id=4 nia=null+aes nea=null+aes
    Update Cfg    ue_param id=4 ue_nr_capabilities=${UE_CAPABILITIES_VoNR} nr_usage_setting=voice_centric
    Update Cfg    ue_nr_capabilities id=4 voice_over_nr=on:on:off
    Update Cfg Param    set_ue simulated id=5 nia=null+aes nea=null+aes
    Update Cfg    ue_param id=5 ue_nr_capabilities=${UE_CAPABILITIES_NO_VoNR} nr_usage_setting=voice_centric
    Update Cfg    ue_nr_capabilities id=5 voice_over_nr=on:on:off
    # 5QI configuration
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=4 proto=udp qos_flow=4
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1-6 qos_flows=1,2,3,4 qos_rules=1,2,3,4
    Update Cfg    set_pdu_gateway id=7 ue_nat_ip=72.23.7.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP
    Update Cfg    set_pdu_gateway id=8 ue_nat_ip=72.23.8.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP
    Update Cfg    set_pdu_gateway id=9 ue_nat_ip=72.23.9.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP
    Update Cfg    set_pdu_gateway id=10 ue_nat_ip=72.23.10.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP

Trigger UE${id} register in cell1
    Execute Egate Command    ue_register id=${id}    UE now in NG RM Registered

Trigger UE5 voice call is Unsuccessful with 5QI5 and 5QI1
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=2 ue=5
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=3
    ${ret}    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=5 nwslice=1 gw=6    IS IDLE
    Should Contain    ${ret}    Setup QosFlow with QFI:1 fiveQI:5
    Should Contain    ${ret}    Received UE Radio Capability Info Indication Message with RAN UE NGAP ID
    Should Contain    ${ret}    Received Initial Context Setup Failure
    Should Contain    ${ret}    Initial Context Setup Failure for UE with AMF UE ID

Trigger UE${id} ICS successfully with 5QI6
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=1 ue=${id}
    Execute Egate Command    amf_ue_ics_param id=1 include_ue_capabilities=on ue_capabilities=${UE_CAPABILITIES_VoNR}
    ${ret}    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${id} nwslice=1 gw=${id}    QoS Routing Table
    Should Contain    ${ret}    AMF-1: Setup QosFlow with QFI:1 5QI:6

Trigger UE1 Voice call is unsuccessful
    Execute Egate Command    qosflow_modify default=on qos_flow=3 ue=1    #5QI1
    ${ret}    Execute Egate Command    ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=7    Pdu Session Resource Setup Response Message
    Should Contain    ${ret}    Setup QosFlow with QFI:1 fiveQI:1
    Should Contain    ${ret}    unsuccessful due to RAN invalid qos combination

Trigger UE2 Voice call is unsuccessful without 5QI5
    Execute Egate Command    amf_ue_ics_param id=1 include_ue_capabilities=on ue_capabilities=${UE_CAPABILITIES_VoNR}
    Execute Egate Command    qosflow_modify default=on qos_flow=1 ue=1    #5QI6
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=3    #5QI1
    ${ret}    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=2 nwslice=1 gw=8    UE2: IS IDLE
    Should Contain    ${ret}    Received Initial Context Setup Failure

Trigger UE3 Video call is unsuccessful without 5QI5
    Execute Egate Command    qosflow_modify default=on qos_flow=4 ue=3    #5QI2
    Execute Egate Command    ue_pdu_session_setup pdu=2 ue=3 nwslice=1 gw=9    No message available for resend

Trigger UE4 Video call is unsuccessful with 5QI5 and 5QI2
    Execute Egate Command    qosflow_modify default=on qos_flow=2 ue=4    #5QI5
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=4    #5QI2
    Execute Egate Command    ue_pdu_session_setup pdu=2 ue=4 nwslice=1 gw=10    No message available for resend

