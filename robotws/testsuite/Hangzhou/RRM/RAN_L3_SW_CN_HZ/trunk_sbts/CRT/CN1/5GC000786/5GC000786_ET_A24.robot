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
...    @{PARAMS_FOR_SECURITY}
...    @{PARAMS_FOR_OTHERS}
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
...    NRBTS/NRDRB_RLC_AM-2:ulMaxRetxThreshold=t16
@{PARAMS_FOR_5QI1}
...    NRCELL-1:actVoNR=true
...    NRBTS:actNormVCFallback=false
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
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=9
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=9
...    NRBTS:integrityProtPrefL:nia3_128=0
@{PARAMS_FOR_OTHERS}


${NNGCC_PDUSESMODREQ_RECD}    M55125C03501

${UECapabilities}    SEPARATOR=
...    E1A01000064E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C3
...    9061C00103278FAB800FF800E003FE00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB800FF800E003
...    FE00151B137582028680965944C043D6C10101070EF1C39061C00103278FAB800FF800E003FE00151B13B582028680965944C0
...    43D6C10101070EF1C39061C00103278FAA8000028000000841C4D00000000202682807008089EC1601800140E0601C0C01601C
...    001A0F8000000000000395340004000025965400D2AAA0207000B00000004008011AB130001020304050607080B10111213192
...    1252627284A61340

${UECapabilities1}    SEPARATOR=
...    E1801000064E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C3
...    9061C00103278FAB800FF800E003FE00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB800FF800E003
...    FE00151B137582028680965944C043D6C10101070EF1C39061C00103278FAB800FF800E003FE00151B13B582028680965944C0
...    43D6C10101070EF1C39061C00103278FAA8000028000000841C4D00000000202682807008089EC1601800140E0601C0C01601C
...    001A0F8000000000000395340004000025965400D2AAA0207000B0000000400801

*** Test Cases ***
5GC000786-ET-A024_Verify_UE_capability_in_VoNR_call_TDD_SA_Airphone
    [Documentation]
    ...    it will cover successful setup of Voice over NR call and Unsuccessful setup of Voice over NR call with UE Capability setting
    ...    as well cover PM counter M55125C03501 is correct
    ...    it test cp-rt is running as user btssw instead of root after CB006048
    [Tags]    QC_61498
    Check If Started By Btssw    cp-rt
    Clear Counter Files    wait=${False}
    Trigger UE1 MO VoNR Call With PDU Default 5QI5
    Trigger UE1 5QI1 Setup Successfully
    Check Counters    NRCELL-1:NNGCC:${NNGCC_PDUSESMODREQ_RECD}=1
    Trigger UE2 MO VoNR Call With PDU Default 5QI5
    Trigger UE2 5QI1 Setup Failed
    Release Ues    ue_type=all


*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    # UE configuration
    ${set_ue1}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    ${ue1_param}    catenate
    ...    ue_param id=1
    ...    ue_nr_capabilities=${UECapabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue1}
    Update Cfg    ${ue1_param}
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    ${set_ue2}    catenate
    ...    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1
    ${ue2_param}    catenate
    ...    ue_param id=2
    ...    ue_nr_capabilities=${UECapabilities1}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue2}
    Update Cfg    ${ue2_param}
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    # 5QI configuration
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1-6 qos_flows=1,2 qos_rules=1,2

Trigger UE${id} MO VoNR Call With PDU Default 5QI5
    Execute Egate Command    ue_register id=${id}    UE now in NG RM Registered
    ${ret1}    Execute Egate Command    ue_pdu_session_setup ue=${id} pdu=1 gw=${id} nwslice=1    QoS Routing Table
    Should Contain    ${ret1}    securityModeCommand
    Should Contain    ${ret1}    cipheringAlgorithm nea2
    Should Contain    ${ret1}    Setup QosFlow with QFI:1 5QI:5


Trigger UE${id} 5QI1 Setup Successfully
    Start RRC Log    ue${id}_5QI1_setup
    ${ret1}    Execute Egate Command    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_add=2 by=amf    QoS Routing Table
    Should Contain    ${ret1}    pdcp-SN-SizeUL len12bits
    Should Contain    ${ret1}    pdcp-SN-SizeDL len12bits
    Should Contain    ${ret1}    sn-FieldLength size12
    Should Contain    ${ret1}    Added QosFlow with QFI:2 5QI:1
    Check RRC log    ${CURDIR}/a2a_A24/a2a_ue${id}.ini

Trigger UE2 5QI1 Setup Failed
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=2 pdu=1 qosflows_to_add=2 by=amf
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID
    Should Contain    ${ret1}    5QI:1
    Should Contain    ${ret1}    PDU Session Resource Modify Unsuccessful Transfer
