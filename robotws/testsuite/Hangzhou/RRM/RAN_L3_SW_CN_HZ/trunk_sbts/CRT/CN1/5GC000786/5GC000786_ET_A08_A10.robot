*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    STATE_CONFIGURED
...    owner-ying.5.chen   owner-yin.zhang    team-SG2    release-5G20B    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_5QI9}
...    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}
...    @{PARAMS_FOR_SECURITY}
...    @{PARAMS_FOR_OTHERS}
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
@{PARAMS_FOR_5QI5}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS/NRDRB-10:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-10:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRBTS/NRDRB-10:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-3:lcgid=0
...    NRBTS/NRDRB_MAC-3:schedulPrio=4
@{PARAMS_FOR_5QI1}
...    NRCELL-1:actVoNR=true
...    NRBTS:actNormVCFallback=false
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=46
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
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=5
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
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

${UECapabilities}    SEPARATOR=
...    E1A01000064E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C3
...    9061C00103278FAB800FF800E003FE00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB800FF800E003
...    FE00151B137582028680965944C043D6C10101070EF1C39061C00103278FAB800FF800E003FE00151B13B582028680965944C0
...    43D6C10101070EF1C39061C00103278FAA8000028000000841C4D00000000202682807008089EC1601800140E0601C0C01601C
...    001A0F8000000000000395340004000025965400D2AAA0207000B00000004008011AB130001020304050607080B10111213192
...    1252627284A61340

*** Test Cases ***
5GC000786-ET-A008_Verify_one_VoNR_call_5QI5_and_5QI1_Qos_flow_setup_in_PDU_Session_Resource_Modify_in_single_cell_TDD_SA_Airphone
    [Tags]    QC_61497    owner-jun.15.zhang    A008
    Trigger UE1 MO VoNR Call With PDU
    Trigger UE1 5QI5 Setup Successfully Default 5QI9
    Trigger UE1 5QI1 Setup Successfully Default 5QI9
    Trigger UE1 5QI1 Release Successfully
    Trigger UE1 5QI5 Release Successfully
    Release UEs    ue_type=all

5GC000786-ET-A010_Verify_one_VoNR_call_5QI5_and_5QI1_setup_in_PDU_Session_Resource_Modify_and_release_in_one_pdu_session_modify_TDD_SA_Airphone
    [Tags]    QC_61496    owner-jun.15.zhang    A010
    Trigger UE2 MO VoNR Call With PDU
    Trigger UE2 5QI5 Setup Successfully Default 5QI9
    Trigger UE2 5QI1 Setup Successfully Default 5QI9
    Trigger UE2 5QI5 And 5QI1 Release In One Same PDUSessionResourceModify Successfully
    Release UEs    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    #UE configuration
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
    ...    ue_nr_capabilities=${UECapabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue2}
    Update Cfg    ${ue2_param}
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    #5QI configuration
    Update Cfg    set_qosflow id=1 5qi=5 default=off
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=9 default=on
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3 qos_rules=1,2 default=on ue=1-6 amf=1-6

Trigger UE${id} MO VoNR Call With PDU
    execute egate command    ue_register id=${id}    UE now in NG RM Registered
    ${out}    execute egate command    ue_pdu_session_setup ue=${id} pdu=1 gw=${id} nwslice=1    QoS Routing Table
    should contain    ${out}    Setup QosFlow with QFI:1 5QI:9

Trigger UE${id} 5QI5 Setup Successfully Default 5QI9
    ${out}    execute egate command    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_add=1 by=amf    QoS Routing Table
    should contain    ${out}    rrcReconfiguration
    should contain    ${out}    Added QosFlow with QFI:2 5QI:5

Trigger UE${id} 5QI1 Setup Successfully Default 5QI9
    ${out}    execute egate command    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_add=2 by=amf    QoS Routing Table
    should contain    ${out}    rrcReconfiguration
    should contain    ${out}    Added QosFlow with QFI:3 5QI:1

Trigger UE${id} 5QI1 Release Successfully
    ${out}    execute egate command    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_del=2 by=amf
    ...    Pdu Session Resource Modify Response Message
    should contain    ${out}    Deleting QosFlow with QFI:3 5QI:1

Trigger UE${id} 5QI5 Release Successfully
     ${out}    execute egate command    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_del=1 by=amf
     ...    Pdu Session Resource Modify Response Message
     should contain    ${out}    Deleting QosFlow with QFI:2 5QI:5

Trigger UE${id} 5QI5 And 5QI1 Release In One Same PDUSessionResourceModify Successfully
    ${out}    execute egate command    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_del=1,2 by=amf
    ...    Pdu Session Resource Modify Response Message
    should contain    ${out}    rrcReconfiguration
    should contain    ${out}    Deleting QosFlow with QFI:2 5QI:5
    should contain    ${out}    Deleting QosFlow with QFI:3 5QI:1
