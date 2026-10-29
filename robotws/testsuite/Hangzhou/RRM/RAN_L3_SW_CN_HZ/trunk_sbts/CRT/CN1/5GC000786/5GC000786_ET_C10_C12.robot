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
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS/NRDRB-10:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-10:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRBTS/NRDRB-10:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-3:lcgid=0
...    NRBTS/NRDRB_MAC-3:schedulPrio=4
...    NRBTS/NRDRB_PDCP-2:tReorderingDl=ms100
...    NRBTS/NRDRB_PDCP-2:tReorderingUl=ms100
...    NRBTS/NRDRB_RLC_AM-2:ulMaxRetxThreshold=t16
@{PARAMS_FOR_5QI1}
...    NRCELL-1:actVoNR=false
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
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms300
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


...    NRCELL-1:actCDrx=true
...    NRCELL-1:drxWactDlEnabled=true
...    NRCELL-1:drxWactUlEnabled=true
...    NRCELL-1:drxProfile1:drxInactivityTimer=20ms
...    NRCELL-1:drxProfile1:drxLongCycle=40ms
...    NRCELL-1:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320

${UECapabilities}    SEPARATOR=
...    E1A01000064E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C3906
...    1C00103278FAB800FF800E003FE00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB800FF800E003FE0015
...    1B137582028680965944C043D6C10101070EF1C39061C00103278FAB800FF800E003FE00151B13B582028680965944C043D6C1010
...    1070EF1C39061C00103278FAA8000028000000841C4D00000000202682807008089EC1601800140E0601C0C01601C001A0F800000
...    0000000395340004000025965400D2AAA0207000B000000040080100

${UECapabilities1}    SEPARATOR=
...    E1A01000064E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C3906
...    1C00103278FAB800FF800E003FE00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB800FF800E003FE0015
...    1B137582028680965944C043D6C10101070EF1C39061C00103278FAB800FF800E003FE00151B13B582028680965944C043D6C1010
...    1070EF1C39061C00103278FAA8000028000000841C4D00000000202682807008089EC1601800140E0601C0C01601C001A0F800000
...    0000000395340004000025965400D2AAA0207000B0000000400801022280

*** Test Cases ***
5GC000786-ET-C010_Verify UE Radio Capability Check procedure failure due to no UE radio capablity IE contained and send prior to ICSR_TDD_SA
    [Tags]    QC_61504
    Trigger UE1 Register
    UE1 Radio Capability Check Without UERadioCapability Expect NgAP ERROR_INDICATION
    UE1 Radio Capability Check With None UERadioCapability Expect NgAP ERROR_INDICATION
    Trigger UE2 Register
    UE2 Radio Capability Check Without UERadioCapability Expect NgAP ERROR_INDICATION
    UE2 Radio Capability Check With None UERadioCapability Expect NgAP ERROR_INDICATION
    Release Ues    ue_type=all

5GC000786-ET-C012_Verify UE Radio Capability Check procedure successful_TDD_SA
    [Tags]    QC_61505    C012
    [Setup]    Set actVoNR And Start To Capture Logs    true
    Trigger UE3 MO VoNR Call With PDU Default 5QI5
    UE3 Radio Capability Check Without UERadioCapability Expect IMSVoiceSupportIndicator NOT-SUPPORTED
    UE3 Radio Capability Check With None UERadioCapability Expect IMSVoiceSupportIndicator NOT-SUPPORTED
    UE3 Radio Capability Check With UERadioCapability Without VoiceOverNR Expect IMSVoiceSupportIndicator NOT-SUPPORTED
    UE3 Radio Capability Check With UERadioCapability With VoiceOverNR Expect IMSVoiceSupportIndicator SUPPORTED
    Trigger UE4 MO VoNR Call With PDU Default 5QI5
    UE4 Radio Capability Check Without UERadioCapability Expect IMSVoiceSupportIndicator SUPPORTED
    UE4 Radio Capability Check With None UERadioCapability Expect IMSVoiceSupportIndicator SUPPORTED
    UE4 Radio Capability Check With UERadioCapability Without VoiceOverNR Expect IMSVoiceSupportIndicator NOT-SUPPORTED
    UE4 Radio Capability Check With UERadioCapability With VoiceOverNR Expect IMSVoiceSupportIndicator SUPPORTED
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    # UE1/3 UE capablity without VoiceOverNR, UE2/4 UE capablity with VoiceOverNR
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
    ${set_ue3}    catenate
    ...    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645402 mode=nr enb=2 cell=1
    ${ue3_param}    catenate
    ...    ue_param id=3
    ...    ue_nr_capabilities=${UECapabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue3}
    Update Cfg    ${ue3_param}
    Update Cfg    ue_nr_capabilities id=3 voice_over_nr=on:on:off
    ${set_ue4}    catenate
    ...    set_ue simulated id=4 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645403 mode=nr enb=2 cell=1
    ${ue4_param}    catenate
    ...    ue_param id=4
    ...    ue_nr_capabilities=${UECapabilities1}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue4}
    Update Cfg    ${ue4_param}
    Update Cfg    ue_nr_capabilities id=4 voice_over_nr=on:on:off
    # 5QI configuration
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2 qos_rules=1,2 default=on ue=1-6 amf=1-6

Set actVoNR And Start To Capture Logs
    [Arguments]    ${actVoNR_value}
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    NRCELL-1:actVoNR=${actVoNR_value}

Trigger UE${id} Register
    Execute Egate Command    ue_register id=${id}    UE now in NG RM Registered

UE${id} Radio Capability Check Without UERadioCapability Expect NgAP ERROR_INDICATION
    Execute Egate Command    amf_ue_trigger_radio_capability_check id=1 ue=${id} gnb=2    NgAP:ERROR_INDICATION

UE${id} Radio Capability Check With None UERadioCapability Expect NgAP ERROR_INDICATION
    Execute Egate Command    amf_ue_trigger_radio_capability_check id=1 ue=${id} gnb=2 ue_radio_capability=none    NgAP:ERROR_INDICATION

Trigger UE${id} MO VoNR Call With PDU Default 5QI5
    Execute Egate Command    ue_register id=${id}    UE now in NG RM Registered
    ${ret1}    Execute Egate Command    ue_pdu_session_setup ue=${id} pdu=1 gw=${id} nwslice=1    QoS Routing Table
    Should Contain    ${ret1}    Setup QosFlow with QFI:1 5QI:5

UE3 Radio Capability Check Without UERadioCapability Expect IMSVoiceSupportIndicator NOT-SUPPORTED
    Execute Egate Command    amf_ue_trigger_radio_capability_check id=1 ue=3 gnb=2    IMSVoiceSupportIndicator:NOT-SUPPORTED

UE3 Radio Capability Check With None UERadioCapability Expect IMSVoiceSupportIndicator NOT-SUPPORTED
    Execute Egate Command    amf_ue_trigger_radio_capability_check id=1 ue=3 gnb=2 ue_radio_capability=none
    ...    IMSVoiceSupportIndicator:NOT-SUPPORTED

UE3 Radio Capability Check With UERadioCapability Without VoiceOverNR Expect IMSVoiceSupportIndicator NOT-SUPPORTED
    Execute Egate Command
    ...    amf_ue_trigger_radio_capability_check id=1 ue=3 gnb=2 ue_radio_capability=00E881B01000000010800000004D7800000000000011500000000000001500
    ...    IMSVoiceSupportIndicator:NOT-SUPPORTED

UE3 Radio Capability Check With UERadioCapability With VoiceOverNR Expect IMSVoiceSupportIndicator SUPPORTED
    Execute Egate Command    amf_ue_trigger_radio_capability_check id=1 ue=3 gnb=2 ue_radio_capability=007880D00201000010800000004D022280
    ...    IMSVoiceSupportIndicator:SUPPORTED

UE4 Radio Capability Check Without UERadioCapability Expect IMSVoiceSupportIndicator SUPPORTED
    Execute Egate Command    amf_ue_trigger_radio_capability_check id=1 ue=4 gnb=2    IMSVoiceSupportIndicator:SUPPORTED

UE4 Radio Capability Check With None UERadioCapability Expect IMSVoiceSupportIndicator SUPPORTED
    Execute Egate Command    amf_ue_trigger_radio_capability_check id=1 ue=4 gnb=2 ue_radio_capability=none    IMSVoiceSupportIndicator:SUPPORTED

UE4 Radio Capability Check With UERadioCapability Without VoiceOverNR Expect IMSVoiceSupportIndicator NOT-SUPPORTED
    Execute Egate Command
    ...    amf_ue_trigger_radio_capability_check id=1 ue=4 gnb=2 ue_radio_capability=00E881B01000000010800000004D7800000000000011500000000000001500
    ...    IMSVoiceSupportIndicator:NOT-SUPPORTED

UE4 Radio Capability Check With UERadioCapability With VoiceOverNR Expect IMSVoiceSupportIndicator SUPPORTED
    Execute Egate Command    amf_ue_trigger_radio_capability_check id=1 ue=4 gnb=2 ue_radio_capability=007880D00201000010800000004D022280
    ...    IMSVoiceSupportIndicator:SUPPORTED
