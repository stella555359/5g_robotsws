*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD
...    team-DevHZ5_SG4    owner-kang.xiang    release-5G22R2    5GC000784    FR1
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{5GC000784}    @{5qi}
@{5GC000784}
...    NRCELL:actVoNR=true
...    NRCELL:actEmergencyCall=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL:arpPrioEmergencyCall=1
...    NRBTS-1:rrcReestabTypeSA=viaRRCSetup
...    NRBTS-1:actNormVCFallback=false
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL:emergencyCallLimServ=true
...    NRCELL:emergencyCallFails=true
...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=9
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9

@{5qi}
...    NRBTS-1/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS-1/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB-10:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS-1/NRDRB-10:resType=nonGBR
...    NRBTS-1/NRDRB-10:rlcMode=RLC_AM
...    NRBTS-1/NRDRB_MAC-4:lcgid=1
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=4

...    NRBTS-1/NRDRB_5QI-4:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-4:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    delete:NRBTS-1/NRDRB-15:nrDrbRlcAmDN
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_PDCP-1:pdcpBufDiscardEnabled=false

...    NRBTS-1/NRDRB_5QI-7:fiveqiValueList=128
...    NRBTS-1/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS-1/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS-1/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRBTS-1/NRDRB-16:dlFlowControlAlgo=3gppFlowControl
...    NRBTS-1/NRDRB-16:resType=nonGBR
...    NRBTS-1/NRDRB-16:rlcMode=RLC_UM
...    delete:NRBTS-1/NRDRB-16:nrDrbRlcAmDN
...    NRBTS-1/NRDRB_MAC-5:lcgid=2
...    NRBTS-1/NRDRB_MAC-5:schedulPrio=5

...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms40

${SA_Capa_perUE}    SEPARATOR=
...    E1A01000074E5A031E000381A00F04983200021E0A018806804C020301C022A36146B04050D012CB2898183D6C10101070EF1C39061C00103278FAB
...    80027800E0009E00151B11B582028680965944C0C1EB608080838778E1C830E0008193C7D53FF4FFCA8D89BAC10143404B2CA26060F5B0404041C3B
...    C70E418700040C9E3EAE0009E003800278000610713400000041C2800000010711800000802809B00A20230380780C04402301000FF5555504C00E0
...    00A070500703007803800341F004000000000000000100795358194010400002596540000010074AAA881D0500E001600010008010020010040086A
...    C4C0004080C1014181C202C4044484C648494989CA12986B40

@{Change_Cipher}    NRBTS-1:cipherPrefL:nea0=9
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0

*** Test Cases ***
5GC000784-ET-D004_Verify_Normal_voice_call_is_reject_with_emergency_call_ongoing
    [Documentation]
    ...    Test Case Steps:
    ...       a.set qosflow priorityLevelARP=1 and VoNR with pdu session1 5qi=5 of priorityLevelARP=1 by initial-emergency-request.
    ...       b.add 5qi=1 within pdu session1 by pdu session modify.
    ...       c.set qosflow priorityLevelARP=15.
    ...       d.pdu session2 setup with 5qi=5 of priorityLevelARP=15 by initial-request.
    ...       e.add 5qi=1 within pdu session2 by pdu session modify and verify PDU Session Resource Modify Unsuccessful Transfer.
    ...       f.release pdu session one by one.
    [Tags]    QC_61230
    Trigger UE Setup Emergency Call With 5QI5    ue_id=1    pdu_id=1    gw=1
    Trigger UE 5QI Add Successfully With PDU Session Modify    ue_id=1    pdu_id=1    qosflows_to_add=2    fiveQI=1
    Set Qosflow Priority And SMF Reset    priority=15
    Trigger UE 5QI5 Setup Successfully With PDU    ue_id=1    pdu_id=2    gw=2    request_type=initial-request
    Trigger UE 5QI1 Add Failed    ue_id=1    pdu_id=2    qosflows_to_add=2    fiveQI=1
    Release PDU Session One By One    ue_id=1
    Check Wireshark log    ${CURDIR}${/}a2a_d04${/}a2a_wireshark.ini    wait_string=UEContextReleaseComplete::1

5GC000784-ET-D005_Verify_Successful_setup_of_Emergency_call_although_another_PDU_with_EC5QI5_exist
    [Documentation]
    ...    Test Case Steps:
    ...       a.VoNR with pdu session1 5qi=5 of priorityLevelARP=15 by initial-request.
    ...       b.pdu session1 add 5qi=1 of priorityLevelARP=15 by pdu session modify.
    ...       c.set qosflow priorityLevelARP=1.
    ...       d.pdu session2 setup only with 5qi=5 of priorityLevelARP=1 by initial-emergency-request.
    ...       e.pdu session3 setup with 5qi=5,1 of priorityLevelARP=1 by initial-emergency-request one by one.
    ...       f.release pdu session3.
    ...       g.release other pdu session one by one.
    [Tags]    QC_61232
    Set Qosflow Priority And SMF Reset    priority=15
    Trigger UE MO VoNR Call With PDU    ue_id=2    pdu_id=1    gw=3    request_type=initial-request
    Trigger UE 5QI Add Successfully With PDU Session Modify    ue_id=2    pdu_id=1    qosflows_to_add=2    fiveQI=1
    Set Qosflow Priority And SMF Reset    priority=1
    Trigger UE 5QI5 Setup Successfully With PDU    ue_id=2    pdu_id=2    gw=4    request_type=initial-emergency-request
    Trigger UE 5QI5 Setup Successfully With PDU    ue_id=2    pdu_id=3    gw=5    request_type=initial-emergency-request
    Trigger UE 5QI Add Successfully With PDU Session Modify    ue_id=2    pdu_id=3    qosflows_to_add=2    fiveQI=1
    Trigger UE PDU Session Release    ue_id=2    pdu_id=3
    Release PDU Session One By One    ue_id=2
    Check Wireshark log    ${CURDIR}${/}a2a_d05${/}a2a_wireshark.ini    wait_string=UEContextReleaseComplete::1

5GC000784-ET-D007_Verify_UE_terminates_the_VoNR_call_when_initiating_IMS_emergency_call
    [Documentation]
    ...    Test Case Steps:
    ...       a.VoNR with pdu session1 5qi=5 of priorityLevelARP=15 by initial-request.
    ...       b.pdu session1 add 5qi=1 of priorityLevelARP=15 by pdu session modify.
    ...       c.set qosflow priorityLevelARP=1.
    ...       d.pdu session2 setup with 5qi=5 of priorityLevelARP=1 by initial-emergency-request.
    ...       e.pdu session2 modify fail and redirected with add 5qi=1 of priorityLevelARP=1.
    ...       f.no need release pdu session due to rediect at step e.
    [Tags]    QC_61227
    Change Cipher Algorithm
    Set Qosflow Priority And SMF Reset    priority=15
    Trigger UE MO VoNR Call With PDU    ue_id=3    pdu_id=1    gw=5    cipheringAlgorithm=nea0
    Trigger UE 5QI Add Successfully With PDU Session Modify    ue_id=3    pdu_id=1    qosflows_to_add=2    fiveQI=1
    Set Qosflow Priority And SMF Reset    priority=1
    Trigger UE 5QI5 Setup Successfully With PDU    ue_id=3    pdu_id=2    gw=6    request_type=initial-emergency-request
    Trigger UE PDU session release    ue_id=3    pdu_id=1
    Trigger UE 5QI Add Successfully With PDU Session Modify    ue_id=3    pdu_id=2    qosflows_to_add=2    fiveQI=1
    Trigger UE PDU Session Release    ue_id=3    pdu_id=2
    Check Wireshark log    ${CURDIR}${/}a2a_d07${/}a2a_wireshark.ini    wait_string=UEContextReleaseComplete::1


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells
    #Debug Enter Into Egate

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc voice_fallback=on ims_voice_3gpp=on
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_perUE}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_perUE}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${SA_Capa_perUE}
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=2
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-3 amf=1 qos_flows=3,2,1 qos_rules=1,2
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1 amf=1
    Update Cfg    set_nwslice id=3 snssai=0x01:0xD143A7 ue=1 amf=1
    Update Cfg    set_nwslice id=4 snssai=0x01:0xD143A8 ue=1 amf=1
    Update Cfg    set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.3.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=5 ue_nat_ip=72.23.4.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=6 ue_nat_ip=72.23.5.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=3 voice_over_nr=on:on:off

Trigger UE Setup Emergency Call With 5QI5
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${gw}=1    ${request_type}=initial-emergency-request
    Set Qosflow Priority And SMF Reset    priority=1
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Trigger UE MO VoNR Call With PDU    ue_id=${ue_id}    pdu_id=${pdu_id}    gw=${gw}    fiveQI=5    nwslice=1    request_type=${request_type}

Set Qosflow Priority And SMF Reset
    [Arguments]    ${priority}=1
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=3 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=4 priority=${priority}
    Execute Egate Command    smf_param id=1 reset

Trigger UE MO VoNR Call With PDU
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${fiveQI}=5    ${nwslice}=1    ${gw}=1    ${request_type}=initial-request
    ...    ${cipheringAlgorithm}=nea3
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw} nwslice=${nwslice} request_type=${request_type}
    ...    pass_regexp=QoS Routing Table
    Should Contain    ${ret1}    securityModeCommand
    Should Contain    ${ret1}    cipheringAlgorithm ${cipheringAlgorithm}
    Should Contain    ${ret1}    Initial Context Setup Successful for UE with AMF UE
    Should Contain    ${ret1}    Setup QosFlow with QFI:1 5QI:${fiveQI}

Trigger UE 5QI Add Successfully With PDU Session Modify
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qosflows_to_add}=2    ${fiveQI}=1
    ${ret2}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully
    Should Contain    ${ret2}    rrcReconfiguration
    Should Contain    ${ret2}    Added QosFlow with QFI:${qosflows_to_add} 5QI:${fiveQI}

Trigger UE 5QI5 Setup Successfully With PDU
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${nwslice}=1    ${gw}=2    ${request_type}=initial-request
    ${ret3}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ...    Pdu Session Resource Setup Response Message with RAN UE NGAP ID [0-9]* handled successfully
    Should Contain    ${ret3}    rrcReconfiguration
    Should Contain    ${ret3}    Setup QosFlow with QFI:1 5QI:5

Trigger UE 5QI1 Add Failed
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${qosflows_to_add}=2    ${fiveQI}=1
    ${ret4}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully
    Should Contain    ${ret4}    PDU Session Resource Modify Unsuccessful Transfer
    Should Not Contain    ${ret4}    fallback

Release PDU Session One By One
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1 by=ue    pass_regexp=Successfully released PDU Session    sleep_time=1
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=2 by=ue    pass_regexp=Successfully released PDU Session    sleep_time=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE CONTEXT RELEASE COMPLETE

Trigger UE PDU Session Release
    [Arguments]    ${ue_id}=2    ${pdu_id}=3
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id} by=ue    pass_regexp=Successfully released PDU Session    sleep_time=1

Change Cipher Algorithm
    Delta Commission Parameters    ${Change_Cipher}
