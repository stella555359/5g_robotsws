*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT
...    owner-ying.5.chen    team-SG2    release-5G20B    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_VoNR}
...    @{PARAMS_FOR_5QI9}
...    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}
...    @{PARAMS_FOR_5QI2}
...    @{PARAMS_FOR_SECURITY}
...    @{PARAMS_FOR_OTHERS}
...    @{PARAMS_FOR_Redirect}
@{PARAMS_FOR_VoNR}
...    NRCELL-1:actVoNR=true
...    NRCELL-2:actVoNR=true
...    NRBTS:actNormVCFallback=false
@{PARAMS_FOR_5QI9}
...    NRBTS/NRDRB_5QI-5:fiveqiValueList=9
...    NRBTS/NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-14
...    NRBTS/NRDRB-14:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-14:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-14:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-14:resType=nonGBR
...    NRBTS/NRDRB-14:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-2:lcgid=2     #1
...    NRBTS/NRDRB_MAC-2:schedulPrio=7
...    NRBTS/NRDRB_PDCP-2:cuFlowControlProfId=1
...    NRBTS/NRDRB_RLC_AM-2:duFlowControlProfId=1
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
@{PARAMS_FOR_5QI1}
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
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB_MAC-3:lcgid=4
...    NRBTS/NRDRB_MAC-3:schedulPrio=5
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
@{PARAMS_FOR_5QI2}
...    NRBTS/NRDRB-16:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-16:dscp=46
...    NRBTS/NRDRB-16:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-16:numSduDiscard=1
...    NRBTS/NRDRB-16:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-16:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-16:resType=nonGBR
...    NRBTS/NRDRB-16:rlcMode=RLC_UM
...    MNRBTS/NRDRB-16:schedulWeight=24
...    NRBTS/NRDRB-16:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=128
@{PARAMS_FOR_SECURITY}
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=9
...    NRBTS:integrityProtPrefL:nia3_128=0
@{PARAMS_FOR_OTHERS}


...    NRBTS:drbInactivityTimerSA=60
#...    MRBTS:srbInactivityTimerSA=60
@{PARAMS_FOR_Redirect}
...    MRBTS-1/NRBTS-1:actRedirect=true
...    MRBTS-1/NRBTS-1/NRCELL-1:voiceFBMode=redirection
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirRat=eutra
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirFreqEutra=38000
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirSsbScs

${SGNB_SA_NGBR_DRB_REQ}    M55138C00003     #The number of non-GBR DRB radio admission requests for SA user
${SGNB_SA_NGBR_DRB_SUCC}    M55138C00005     #The number of non-GBR DRB successful radio admissions for SA user
${F1_UE_CTXT_MOD_REQ_RECEIVED}    M55117C00001     #Number of incoming UE CONTEXT MODIFICATION REQUEST received from gNB-CU
${SGNB_SA_NGBR_DRB_REL}    M55138C00004     #The number of non-GBR DRB radio admission releases for SA user
${SGNB_SA_RAC_REJ_DUE_TO_NGBR}    M55138C00007     #The number of rejected radio admission requests for SA user due to lack of non-GBR capacity

@{counters_dict_E002}
...    NRBTS-1:NF1CD:${F1_UE_CTXT_MOD_REQ_RECEIVED}==10    #M55117C00001==10
...    NRCELL-1:RSACU:${SGNB_SA_NGBR_DRB_REQ}==2    #M55138C00003==2
...    NRCELL-2:RSACU:${SGNB_SA_NGBR_DRB_REQ}==0
...    NRCELL-1:RSACU:${SGNB_SA_NGBR_DRB_SUCC}==2    #M55138C00005==2
...    NRCELL-2:RSACU:${SGNB_SA_NGBR_DRB_SUCC}==0
#...    NRCELL-1:RSACU:${SGNB_SA_NGBR_DRB_REL}==1    #M55138C00004==1
...    NRCELL-1:RSACU:${SGNB_SA_NGBR_DRB_REL}==2    #M55138C00004==1
...    NRCELL-2:RSACU:${SGNB_SA_NGBR_DRB_REL}==0

@{counters_dict_E004}
...    NRCELL-1:RSACU:${SGNB_SA_NGBR_DRB_REQ}==1    #M55138C00003==2
...    NRCELL-2:RSACU:${SGNB_SA_NGBR_DRB_REQ}==0
...    NRCELL-2:RSACU:${SGNB_SA_RAC_REJ_DUE_TO_NGBR}==0    #M55138C00007

@{PARAMS_For_Del_5QI2}
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=125

@{DELTA_PARAS}
...    MRBTS-1/NRBTS-1:actNormVCFallback=true

${UECapabilities}    SEPARATOR=
...    E1A01000064E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C3
...    9061C00103278FAB800FF800E003FE00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB800FF800E003
...    FE00151B137582028680965944C043D6C10101070EF1C39061C00103278FAB800FF800E003FE00151B13B582028680965944C0
...    43D6C10101070EF1C39061C00103278FAA8000028000000841C4D00000000202682807008089EC1601800140E0601C0C01601C
...    001A0F8000000000000395340004000025965400D2AAA0207000B00000004008011AB130001020304050607080B10111213192
...    1252627284A61340
${RECREATE_WIRESHARK_FLAG}    ${false}
*** Test Cases ***
5GC000786-ET-E001_Verify Successful setup and release of Video over NR call_5QI-1 and 5QI-2 adding together_Airphone
    [Documentation]
    ...    This part shall provide an unambiguous short description of the case and its purpose without details or requirements in order to
    ...    inform the reader on what the test case is about.
    ...    it will cover IMS Video call uccessful setup and release of Video over NR call_5QI-1 and 5QI-2 adding together
    [Tags]    QC_61513    E001
    Trigger UE register    1
    Trigger UE setup ICS successfully    1
    Trigger UE setup 5QI1 and 5QI2 successfully    1
    Trigger Video Call release 5QI1 and 5QI2    1
    Check Wireshark Log    ${CURDIR}/a2a_E001/a2a_E001.ini    wait_string=UEContextReleaseComplete::3

5GC000786-ET-E002_Verify Successful setup and release of Video over NR call - 5QI-2 adding separately_Airphone
    [Documentation]
    ...    This part shall provide an unambiguous short description of the case and its purpose without details or requirements in order to
    ...    inform the reader on what the test case is about.
    ...    it will cover IMS Video call uccessful setup and release of Video over NR call_5QI-1 and 5QI-2 adding separately
    [Tags]    QC_61514    E002
    Clear Counter files
    Trigger UE register    2
    Trigger UE setup ICS successfully    2
    Trigger UE 5QI1 Setup Successfully    2
    Trigger UE 5QI2 Setup successfully    2
    5QI2 and 5QI1 one by one release    2
    Check Wireshark Log    ${CURDIR}/a2a_E002/a2a_E002.ini    wait_string=UEContextReleaseComplete::6
    Check Counters    ${counters_dict_E002}

5GC000786-ET-E007_Verify 5QI2 coming when 5QI-1 is not existing _Airphone
    [Documentation]
    ...    This part shall provide an unambiguous short description of the case and its purpose without details or requirements in order to
    ...    inform the reader on what the test case is about.
    ...    it will cover IMS Video call failure setup when 5QI-1 is not existing
    [Tags]    QC_61515    E007
    Trigger UE register    3
    Trigger UE setup ICS successfully    3
    Trigger UE 5QI2 setup fail    3
    Check Wireshark Log    ${CURDIR}/a2a_E007/a2a_E007.ini    wait_string=UEContextReleaseComplete::3

5GC000786-ET-E004_Verify VideoCall unsuccessful due to 5QI2 DRB profile selection failure when 5QI adding together with Voice Fallback disabled_AP
    [Documentation]
    ...    This part shall provide an unambiguous short description of the case and its purpose without details or requirements in order to
    ...    inform the reader on what the test case is about.
    ...    it will cover IMS Video call unsuccessful due to 5QI2 DRB profile selection failure when 5QI adding together with Voice Fallback disabled
    [Tags]    QC_61516    E004
    Delta Commission Parameters    ${PARAMS_For_Del_5QI2}
    Clear Counter files
    Trigger UE register    4
    Trigger UE setup ICS successfully    4
    Trigger UE 5QI1 and 5QI2 setup fail    4
    Check Wireshark Log    ${CURDIR}/a2a_E004/a2a_E004.ini    wait_string=UEContextReleaseComplete::3
    Check Counters    ${counters_dict_E004}
    Release UEs    ue_type=all

5GC000786-ET-E006_Verify Video call unsuccessful due to DRB profile selection failure when 5QI2 adding separately with Voice Fallback enabled_AP
    [Documentation]
    ...    This part shall provide an unambiguous short description of the case and its purpose without details or requirements in order to
    ...    inform the reader on what the test case is about.
    ...    it will cover Voice Fallback is enabled,IMS Video call unsuccessful due to DRB profile selection failure when 5QI2 adding separately, and
    ...    Voice call will be Fallback
    [Tags]    QC_61517    E006
    Delta Commission Parameters    ${DELTA_PARAS}
    Trigger UE register    5
    Trigger UE setup ICS successfully    5
    Trigger UE 5QI1 Setup Successfully    5
    Trigger UE 5QI2 setup fail    5
    Check Wireshark Log    ${CURDIR}/a2a_E006/a2a_E006.ini    wait_string=UEContextReleaseComplete::3
    Release UEs    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on voice_fallback=on
    ${set_ue1}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    ${ue1_param}    catenate
    ...    ue_param id=1    ue_nr_capabilities=${UECapabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue1}
    Update Cfg    ${ue1_param}
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    ${set_ue2}    catenate
    ...    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1
    ${ue2_param}    catenate
    ...    ue_param id=2    ue_nr_capabilities=${UECapabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue2}
    Update Cfg    ${ue2_param}
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    ${set_ue3}    catenate
    ...    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645402 mode=nr enb=2 cell=1
    ${ue3_param}    catenate
    ...    ue_param id=3    ue_nr_capabilities=${UECapabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue3}
    Update Cfg    ${ue3_param}
    Update Cfg    ue_nr_capabilities id=3 voice_over_nr=on:on:off
    ${set_ue4}    catenate
    ...    set_ue simulated id=4 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645403 mode=nr enb=2 cell=1
    ${ue4_param}    catenate
    ...    ue_param id=4    ue_nr_capabilities=${UECapabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue4}
    Update Cfg    ${ue4_param}
    Update Cfg    ue_nr_capabilities id=4 voice_over_nr=on:on:off
    ${set_ue5}    catenate
    ...    set_ue simulated id=5 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645404 mode=nr enb=2 cell=1
    ${ue5_param}    catenate
    ...    ue_param id=5    ue_nr_capabilities=${UECapabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue5}
    Update Cfg    ${ue5_param}
    Update Cfg    ue_nr_capabilities id=5 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosflow id=3 5qi=2
    Update Cfg    qosrule_set id=3 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3 qos_rules=1,2,3 default=on ue=1-6 amf=1-6
    Update Cfg    amf_ue_ics_param id=1 include_ue_capabilities=on
Trigger UE register
    [Arguments]     ${ue_id}=1
    execute egate command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s

Trigger UE setup ICS successfully
    [Arguments]     ${ue_id}=1
    ${ret1}    execute egate command    ue_pdu_session_setup ue=${ue_id} pdu=${ue_id} gw=1 nwslice=1    QoS Routing Table    timeout=20s
    Should Contain    ${ret1}    UPF-1: Setup QosFlow with QFI:1 fiveQI:5
    Should Contain    ${ret1}    securityModeCommand
    Should Contain    ${ret1}    cipheringAlgorithm nea0
    Should Contain    ${ret1}    Initial Context Setup Successful for UE with AMF UE ID
    Should Contain    ${ret1}    AMF-1: Setup QosFlow with QFI:1 5QI:5

Trigger Video Call release 5QI1 and 5QI2
    [Arguments]     ${ue_id}=1
    ${ret1}    execute egate command    ue_pdu_session_modify ue=${ue_id} pdu=${ue_id} qosflows_to_del=2,3 by=amf
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID     timeout=20s
    Should Contain    ${ret1}=    AMF-1: Deleting QosFlow with QFI:2 5QI:1
    Should Contain    ${ret1}=    AMF-1: Deleting QosFlow with QFI:3 5QI:2
    Should Contain    ${ret1}=    drb-ToReleaseList
    Should Contain    ${ret1}=    5    #release 5QI128
    Should Contain    ${ret1}=    6    #release 5QI1

Trigger UE 5QI1 Setup Successfully
    [Arguments]    ${ue_id}=1
    ${out}    execute egate command    ue_pdu_session_modify ue=${ue_id} pdu=${ue_id} qosflows_to_add=2 by=amf    QoS Routing Table
    should contain    ${out}    rrcReconfiguration
    should contain    ${out}    Added QosFlow with QFI:2 5QI:1

Trigger UE 5QI2 Setup Successfully
    [Arguments]    ${ue_id}=1
    ${out}    execute egate command    ue_pdu_session_modify ue=${ue_id} pdu=${ue_id} qosflows_to_add=3 by=amf    QoS Routing Table
    should contain    ${out}    rrcReconfiguration
    should contain    ${out}    Added QosFlow with QFI:3 5QI:2

Trigger UE setup 5QI1 and 5QI2 successfully
    [Arguments]    ${ue_id}=1
    ${out}    execute egate command    ue_pdu_session_modify ue=${ue_id} pdu=${ue_id} qosflows_to_add=2,3 by=amf    QoS Routing Table
    should contain    ${out}    Added QosFlow with QFI:3 fiveQI:2
    should contain    ${out}    Added QosFlow with QFI:2 fiveQI:1

Trigger UE 5QI2 setup fail
    [Arguments]     ${ue_id}=1
    execute egate command    ue_pdu_session_modify ue=${ue_id} pdu=${ue_id} qosflows_to_add=3 by=amf
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID    timeout=20s

Trigger UE 5QI1 and 5QI2 setup fail
    [Arguments]     ${ue_id}=1
    execute egate command    ue_pdu_session_modify ue=${ue_id} pdu=${ue_id} qosflows_to_add=2,3 by=amf
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID    timeout=20s

5QI2 and 5QI1 one by one release
    [Arguments]    ${ue_id}=1
    ${ret1}=    execute egate command    ue_pdu_session_modify ue=${ue_id} pdu=${ue_id} qosflows_to_del=3 by=amf
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID     timeout=20s
    ${ret2}=    execute_egate_command    ue_pdu_session_modify ue=${ue_id} pdu=${ue_id} qosflows_to_del=2 by=amf
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID     timeout=20s
