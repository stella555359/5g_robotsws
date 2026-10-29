*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  RAN_5G_FDD  CRT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  team-DevHZ5_SG2
...  owner-song.xiuli  release-SBTS00
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  @{Emergency_Call_Related_Parameters}
...  @{5QI1}
...  @{5QI5}
...  @{5QI1_5QI2}
...  @{NRCELL1_A3RSRQ}
...  @{NRCELL2_A3RSRQ}
...  @{TAC_300}
@{Emergency_Call_Related_Parameters}
...  NRCELL-1:actVoNR=true
...  NRBTS:cipherPrefL:nea0=1
...  NRBTS:cipherPrefL:nea1_128=0
...  NRBTS:cipherPrefL:nea2_128=9
...  NRBTS:cipherPrefL:nea3_128=0
...  NRBTS:integrityProtPrefL:nia1_128=0
...  NRBTS:integrityProtPrefL:nia2_128=9
...  NRBTS:integrityProtPrefL:nia3_128=0

...  NRCELL-1:actEmergencyCall=true
...  NRCELL-1:actEnhancedVoNR=true
...  NRCELL-1:actGBRAdmissionControl=EnhancedVoNR
...  NRCELL-1:emergencyCallLimServ=true
...  NRCELL-1:maxGBRTrafficLimit=30
...  NRCELL-1:maxNumOfGBRBearersSA=5
...  NRCELL-1:maxNumOfNonGBRBearersSA=500
...  NRCELL-1:n310VoNR=n3
...  NRCELL-1:t310VoNR=500ms
...  NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=false
...  NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=false
...  NRDU-1:numOfDrbsReservForEmergency=2
...  NRBTS:tRLFindForDUVoNR=500ms
...  NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXHighQ=0
...  NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXLowQ=0
...  NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...  NRBTS-1/SNSSAI-1:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...  NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...  NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...  NRBTS-1/SNSSAI-2:sd=13714342
...  NRBTS-1/SNSSAI-2:sst=1
...  NRBTS:ngCplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...  TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...  TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...  NRCELL-1:arpPrioEmergencyCall=1
...  NRCELL-1:emergencyCallFails=false
...  NRCELL-1:numOfRadioResReservForEmergency=1
...  NRBTS:rrcReestabTypeSA=viaRRCSetup

...  NRBTS:actIntraFreqHoSA=true
...  NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...  NRCELL-2:actEmergencyCall=true
...  NRCELL-2:actEnhancedVoNR=true
...  NRCELL-2:actGBRAdmissionControl=EnhancedVoNR
...  NRCELL-2:emergencyCallLimServ=true
...  NRBTS-1/NRCELL-2:actVoNR=true
...  NRBTS-1/NRCELL-2:maxGBRTrafficLimit=30
...  NRBTS-1/NRCELL-2:maxNumOfGBRBearersSA=10
...  NRBTS-1/NRCELL-2:maxNumOfNonGBRBearersSA=500
...  NRBTS-1/NRCELL-2:n310VoNR=n3
...  NRBTS-1/NRCELL-2:t310VoNR=500ms
...  NRBTS-1/NRCELL-2:emergencyCallRestrictions:emergencyCallMrListIgnore=false
...  NRBTS-1/NRCELL-2:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=false
...  NRBTS-1/NRCELL-2:arpPrioEmergencyCall=6
...  NRBTS-1/NRCELL-2:emergencyCallFails=false
...  NRBTS-1/NRCELL-2:numOfRadioResReservForEmergency=1
@{5QI1}
...  NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...  NRBTS-1/NRDRB-15:dscp=0
...  NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...  NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...  NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...  NRBTS-1/NRDRB-15:numSduDiscard=1
...  NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...  NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...  NRBTS-1/NRDRB-15:resType=GBR
...  NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...  NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=100
...  NRBTS-1/NRDRB-15:schedulWeight=1
...  NRBTS-1/NRDRB-15:discardTimer=150ms
...  NRBTS-1/NRDRB-15:actDddsReduction=false
...  NRDRB-15:maxDataRateGbrUl=1000
...  NRDRB-15:maxDataRateGbrDl=1000
...  NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...  NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...  NRBTS-1/NRDRB_MAC-3:lcgid=4
...  NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...  NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false

@{5QI5}
...  NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...  NRBTS-1/NRDRB_MAC-4:lcgid=1
...  NRBTS-1/NRDRB_MAC-4:schedulPrio=4
@{5QI1_5QI2}
...  NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...  NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
@{NRCELL1_A3RSRQ}
...  NRCELL-1:a3MeasEnabled=rsrq
...  NRCELL-1:absThreshSsbRsrqConsolidation=1
...  NRCELL-1:measGapSelectionSA=favourUeThroughput
...  NRCELL-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=2
...  NRCELL-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...  NRCELL-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
@{NRCELL2_A3RSRQ}
...  NRCELL-2:a3MeasEnabled=rsrq
...  NRCELL-2:absThreshSsbRsrqConsolidation=1
...  NRCELL-2:measGapSelectionSA=favourUeThroughput
...  NRCELL-2:a3MeasSsbRsrq:a3HysteresisSsbRsrq=2
...  NRCELL-2:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...  NRCELL-2:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
@{TAC_300}
...  NRBTS-1/TRACKINGAREA-300:fiveGsTac=100
...  TRACKINGAREA-300:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...  TRACKINGAREA-300:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2

@{Online_Param_EDA}
...  NRDU-1:numOfDrbsReservForEmergency=1

@{PM_Counters_Check_EDA}
...    NRCELL-1:NNGCC:${NNGCC_PDUSESMOD_FAIL_EC_SENT}=1
${NNGCC_PDUSESMOD_FAIL_EC_SENT}    M55125C05511    #The total number of PDU SESSION RESOURCE MODIFICATION procedure failures for IMS Emergency Calls
*** Test Cases ***
5GC000784-ET-B-EDA_B017_Verify_successful_intra_freq_intra_gnb_Ho_with_different_emergencyARP_configured_on_target
    [Documentation]
    ...    1. The purpose to verify intra-GNB intra-PLMN HO with Emergency Call ongoing with different ECARP config on target cell.
    ...         Both Cells: numOfRadioResReservForEmergency=1, numOfDrbsReservForEmergency=2
    ...         Source Cell: NRBTS/NRCELL.emergencyCallMrListIgnore=false, NRBTS/NRCELL.emergencyCallPlmnHoAllowed=false, arpPrioEmergencyCall=1
    ...         Target Cell: NRBTS/NRCELL.emergencyCallMrListIgnore=false, NRBTS/NRCELL.emergencyCallPlmnHoAllowed=false, arpPrioEmergencyCall=6
    ...    2. Test Case Step:
    ...        a, UE1 register on cell-1 setup the first PDU session with 5QI-5 bearer
    ...        b, UE-1 initial emergency call in source cell via 2 pdu sessions (Normal 5QI5, EC 5QI5&1)
    ...        c, UE-1 perform intra gnb intra-plmn HO to target cell phycel-51.
    ...        d, UE-1 initial emergency call in source cell via 3 pdu sessions (Normal 5QI5, EC 5QI5&1)
    ...        e, Release 3 pdu sessions
    ...        f, UE-1 perform intra gnb intra-plmn HO to source cell phycel-50.
    ...        g, online set numOfDrbsReservForEmergency=1
    ...        h, UE-1 initial emergency call in source cell via 3 pdu sessions (Normal 5QI5, EC 5QI5&1),5QI-1 setup failed

    [Tags]    QC_61236    owner-shelly.song
    Clear Counter Files
    Trigger UE Setup Normal VoNR call with PDU    pdu_id=1    nwslice=2
    Trigger UE 5QI5 and 5QI1 Emergency call setup successfully    priority=1    pdu_id=2    request_type=initial-emergency-request
    Trigger UE Intra-Frequency Intra-gNB HO    ue_id=1    phycell_id=51
    Trigger UE 5QI5 and 5QI1 Emergency call setup successfully    priority=6    pdu_id=3    gw=3    request_type=initial-emergency-request
    Release The Third PDU seesion
    Trigger UE Intra-Frequency Intra-gNB HO    ue_id=1    phycell_id=50
    OnlineParamChange    ${Online_Param_EDA}
    Trigger UE 5QI5 and 5QI1 Emergency call Failed with same PDU   pdu_id=3    request_type=initial-emergency-request
    Check RRC log    ${CURDIR}${/}a2a_b17${/}a2a.ini
    Check Counters    ${PM_Counters_Check_EDA}
    Check Wireshark Log    ${CURDIR}${/}a2a_b17${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes voice_fallback=off ims_voice_3gpp=on
    Update Cfg    set_qosflow id=1 5qi=5 default=off
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=9 default=on
    Update Cfg    set_qosflow id=4 5qi=7
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1 amf=1,2,3,4 qos_flows=3,2,1 qos_rules=1,2
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1 amf=1 qos_flows=1,2 qos_rules=1,2
    ${cell_2}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=100 nrci=0x02 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    Update Cfg    ${cell_2}
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=3 voice_over_nr=on:on:off
   ${ue_1}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    Update Cfg    ${ue_1}

    ${ue_nr_capabilities}    catenate    SEPARATOR=
    ...    ue_param id=1 ue_nr_capabilities=E1A01000074E5A031E000381A00F04983200021E0A018806804C020301C022A36146B04050D012
    ...    CB2898183D6C10101070EF1C39061C00103278FAB80027800E0009E00151B11B582028680965944C0C1EB608080838778E1C830E0008193
    ...    C7D53FF4FFCA8D89BAC10143404B2CA26060F5B0404041C3BC70E418700040C9E3EAE0009E003800278000610713400000041C280000001
    ...    0711800000802809B00A20230380780C04402301000FF5555504C00E000A070500703007803800341F00400000000000000010079535819
    ...    4010400002596540000010074AAA881D0500E001600010008010020010040086AC4C0004080C1014181C202C4044484C648494989CA1298
    ...    6B40 nr_usage_setting=voice_centric
    Update Cfg    ${ue_nr_capabilities}

Set qosflow priority and Reset smf param
    [Arguments]    ${priority}=1
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=3 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=4 priority=${priority}
    Execute Egate Command    smf_param id=1 reset

Trigger UE Setup Normal VoNR call with PDU
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=2    ${gw}=1    ${request_type}=initial-request    ${fiveQI}=5
    ...    ${cipheringAlgorithm}=nea2
    Set qosflow priority and Reset smf param     priority=15
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ...    QoS Routing Table
    Should Contain    ${ret1}    securityModeCommand
    Should Contain    ${ret1}    cipheringAlgorithm ${cipheringAlgorithm}
    Should Contain    ${ret1}    Initial Context Setup Successful for UE with AMF UE
    Should Contain    ${ret1}    Setup QosFlow with QFI:1 5QI:${fiveQI}
    Should Contain    ${ret1}    Initial Context Setup Successful

Trigger UE 5QI5 and 5QI1 Emergency call setup successfully
    [Arguments]    ${priority}=1    ${ue_id}=1    ${pdu_id}=2    ${nwslice}=2    ${gw}=2    ${request_type}=initial-emergency-request
    Set qosflow priority and Reset smf param    ${priority}
    Execute Egate Command
    ...    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ...    Pdu Session Resource Setup Response Message    timeout=20s
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=2 by=amf
    ...    Added QosFlow with QFI:2 fiveQI:1
    Should Contain    ${ret1}    rrcReconfiguration
    Should Contain    ${ret1}    Added QosFlow with QFI:2 5QI:1
 #   Should Contain    ${ret1}    handled successfully

Trigger UE Intra-Frequency Intra-gNB HO
    [Arguments]    ${ue_id}=1    ${mea_id}=1    ${phycell_id}=51
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
    ...    Intra-eNB handover
    Should Contain  ${ret1}  eventId eventA3
OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Release The Third PDU seesion
    [Arguments]
    Set qosflow priority and Reset smf param    priority=1
    Execute Egate Command    ue_pdu_session_release ue=1 pdu=3 by=ue    Successfully released PDU Session with ID 3 in SMF

Trigger UE 5QI5 and 5QI1 Emergency call Failed with same PDU
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${nwslice}=2    ${gw}=3    ${request_type}=initial-emergency-request
    Execute Egate Command
    ...    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ...    Pdu Session Resource Setup Response Message
    Execute Egate Command
    ...    ue_pdu_session_modify ue=1 pdu=3 qosflows_to_add=2 by=amf
    ...    PDU Session Resource Modify Unsuccessful Transfer
