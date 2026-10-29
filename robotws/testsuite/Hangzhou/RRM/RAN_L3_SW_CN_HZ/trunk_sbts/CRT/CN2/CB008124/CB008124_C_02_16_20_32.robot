*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-niya.ma
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008124    release-SBTS23R2
...    STATE_CONFIGURED

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{8124_related_modification}
...    @{5qi80_related_modification}
...    @{GBR_5qi_4_71}
...    @{tdd_cell2_5ms_pattern}
...    NRCELL-2:cellDepType=SA
...    delete:NRCELL-2:configuredEpsTac
...    MRBTS-1/NRBTS-1/NRCELL-2:chBw=60MHz
...    MRBTS-1/NRBTS-1/NRCELLGRP-1:maxUlHarqTx=5

@{tdd_cell2_5ms_pattern}
...    NRCELL-2:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-2:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL-2:tddFrameStructure:lteToNrFrameShift=3ms
...    NRCELL-2:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=2/8

@{8124_related_modification}
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actUlCgType2=true
...    NRBTS/NRDRB-13:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS/NRDRB-15:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=2000
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=36
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms40
...    NRBTS/NRULCG_PROFILE-2:grantedPacketSize=80
...    NRBTS/NRULCG_PROFILE-2:maxNumPrbs=36
...    NRBTS/NRULCG_PROFILE-2:periodicity=ms5
...    NRCELL-1:actGBRAdmissionControl=GBRService
...    NRCELL-1:actNonVoNRGbrService=true
...    NRCELL-1:maxGBRTrafficLimit=40
...    NRCELL-1:ulConfiguredGrantType2:maxGBRAndCgType2TrafficLimit=50
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumPrbs=40
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumUeUl=1
...    NRCELL-1:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRCELL-2:actGBRAdmissionControl=GBRService
...    NRCELL-2:actNonVoNRGbrService=true
...    NRCELL-2:maxGBRTrafficLimit=40
...    NRCELL-2:ulConfiguredGrantType2:maxGBRAndCgType2TrafficLimit=50
...    NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumPrbs=36
...    NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumUeUl=1
...    NRCELL-2:ulConfiguredGrantType2:ulCgPrbStartOffset=0

@{5qi80_related_modification}
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB-15:actLostPduFastRetx=false
...    NRBTS-1/NRDRB-15:discardTimer=infinity
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=3gppFlowControl
...    NRBTS-1/NRDRB-15:dscp=0
...    NRBTS-1/NRDRB-15:endMarkerTimer=2000
...    NRBTS-1/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-15:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:nrDrbUlCgDN=${EMPTY}
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-15:resType=nonGBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=500
...    NRBTS-1/NRDRB-15:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-15:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS-1/NRDRB-15:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-15:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-15:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-15:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-15:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-15:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-15:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-15:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS-1/NRDRB_5QI-7:fiveqiValueList=80
...    NRBTS-1/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50
...    NRBTS-1/NRDRB-13:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1

@{GBR_5qi_4_71}
...    NRCELL:actNonVoNRGbrService=true
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=4
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
...    NRBTS/NRDRB_5QI-8:fiveqiValueList=71
...    NRBTS/NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
...    NRBTS/NRDRB-17:actDddsReduction=false
...    NRBTS/NRDRB-17:actLostPduFastRetx=false
...    NRBTS/NRDRB-17:discardTimer=300ms
...    NRBTS/NRDRB-17:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-17:dscp=28
...    NRBTS/NRDRB-17:l2OHFactorDl=16
...    NRBTS/NRDRB-17:l2OHFactorUl=35
...    NRBTS/NRDRB-17:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-17:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-17:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-17:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-17:maxTransferDelayGbr=20
...    NRBTS/NRDRB-17:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-7
...    NRBTS/NRDRB-17:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-17:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-17:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-2
...    NRBTS/NRDRB-17:numSduDiscard=1
...    NRBTS/NRDRB-17:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS/NRDRB-17:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-17:resType=GBR
...    NRBTS/NRDRB-17:rlcMode=RLC_AM
...    NRBTS/NRDRB-17:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-17:nsaDrbParam=${EMPTY}
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-5:schedulBSD=50ms
...    NRBTS/NRDRB_MAC-5:schedulPrio=4
...    NRBTS/NRDRB_MAC-7:delayTarget=50
...    NRBTS/NRDRB_MAC-7:lcgid=5
...    NRBTS/NRDRB_MAC-7:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-7:schedulBSD=5ms
...    NRBTS/NRDRB_MAC-7:schedulPrio=7

@{CASE_02}
...    NRBTS-1/NRDRB-13:nrDrbUlCgDN=${EMPTY}
...    NRBTS-1/NRDRB-17:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1

@{CASE_32}
...    NRBTS-1/NRDRB-11:nrDrbUlCgDN=${EMPTY}
...    NRBTS-1/NRDRB-15:nrDrbUlCgDN=${EMPTY}
...    NRBTS-1/NRDRB-17:nrDrbUlCgDN=${EMPTY}
...    NRBTS-1/NRDRB-13:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1

@{CASE_16}
...    NRBTS-1/NRDRB-11:nrDrbUlCgDN=${EMPTY}
...    NRBTS-1/NRDRB-13:nrDrbUlCgDN=${EMPTY}
...    NRBTS-1/NRDRB-17:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS-1/NRDRB-15:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-2

@{CASE_20}
...    NRBTS-1/NRDRB-11:nrDrbUlCgDN=${EMPTY}
...    NRBTS-1/NRDRB-13:nrDrbUlCgDN=${EMPTY}
...    NRBTS-1/NRDRB-17:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS-1/NRDRB-15:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-2

@{cgsetup_Regexp}
...    QoS Routing Table
...    configuredGrantConfig setup

@{cgnot_setup_Regexp}
...    QoS Routing Table

${UE_Capa_Support_CG2_mac_phy}    SEPARATOR=
...    E1A03000076E0140502D018F0041C19000F04983200021E12006201A0130080C0700CA8D851AC10143404B2CA261201EB608080838778E
...    1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CA261201EB608080838778E1C830E0008193C7D5C0013C0070004F000A
...    8D89BAC10143404B2CA261201EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CA261201EB60808083
...    8778E1C830E0008193C7D54000014000000420E2680000000101343C001C020227B09801800140E0A00E06013003800341F00000000000
...    0072A68000800004B2CA801A55542400E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094450

${RRC_RECONF_CMP_CG_SETUP_RCVD}    M55166C00005    #No of RRC reconfiguration complete received with UL configured grant type2 setup
${RRC_RECONF_CMP_CG_RELEASE_RCVD}    M55166C00006    #No of RRC reconfiguration complete received with UL configured grant type2 release
${CG_RES_ALLO_ATT_DU}    M55139C00017

@{PM_Counters_Check_C02_C16_C20}
...    NRCELL-2:NRCCD:${RRC_RECONF_CMP_CG_SETUP_RCVD}=1
...    NRCELL-2:RSADU:${CG_RES_ALLO_ATT_DU}=1
...    NRCELL-2:NRCCD:${RRC_RECONF_CMP_CG_RELEASE_RCVD}=0

@{PM_Counters_Check_C32}
...    NRCELL-2:NRCCD:${RRC_RECONF_CMP_CG_SETUP_RCVD}=1
...    NRCELL-2:RSADU:${CG_RES_ALLO_ATT_DU}=1
...    NRCELL-2:NRCCD:${RRC_RECONF_CMP_CG_RELEASE_RCVD}=1

*** Test Cases ***
CB008124-ET-C02_Successful_CG2_configuration_ics_wo_initial_pdu_GBR_CG2_and_non_GBR_noCG_with_tdd_pattern_5ms_with_ue_capabilities
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour for the successful setup of Configured UL Grant Type 2
    ...    configuration for the bearer associated with Configured UL Grants Type 2 profile that is received as part of
    ...    Initial Context Setup Request without pdu session setup procedure.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.default drb 5QI_80 is associated with NRULCG_PROFILE.
    ...    d.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach without PDU and then set up PDU session.5QI_4 is setup with CG2.
    ...    b.UE detach.
    [Tags]    QC_254480    owner-niya.ma
    Update UE capa    ue_id=2    SA_Capa_perUE_Full=${UE_Capa_Support_CG2_mac_phy}
    Clear Counter Files
    OnlineParamChange    ${CASE_02}
    ICS Without initial Pdu    ue_id=2    cell_id=2    qos_flow_01=8    qos_flow_02=4    regexp=${cgsetup_Regexp}
    Send And Verify Throuput    ue_id=2    qfi=2    send_dl=20    send_ul=10    sleep_time=10s    pdu=1
    Send And Verify Throuput    ue_id=2    qfi=1    send_dl=20    send_ul=10    sleep_time=10s    pdu=1
    UE Deregister From gNB    ue_id=2
    Check Counters    ${PM_Counters_Check_C02_C16_C20}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_C02${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008124-ET-C16-CG2_configuration_retained_with_PDU_Session_Modify_GBR_CG2_high_prio_non_GBR_no_CG_and_non_GBR_CG2_low_prio_with_tdd_pattern_5ms
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour for the successful setup of Configured UL Grant Type 2
    ...    configuration for the bearer associated with Configured UL Grants Type 2 profile that is received as part of
    ...    Initial Context Setup Request procedure.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.default drb 5QI_80 is associated with NRULCG_PROFILE.
    ...    d.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach without PDU and then set up PDU session.5QI_80 is setup with CG2.
    ...    b.UE detach.
    [Tags]    QC_255511    owner-niya.ma
    Update UE capa    ue_id=2    SA_Capa_perUE_Full=${UE_Capa_Support_CG2_mac_phy}
    Clear Counter Files
    OnlineParamChange    ${CASE_16}
    Pdu Session modify 02    ue_id=2    cell_id=2    qos_flow=8    qos_flow_01=4    qos_flow_02=9
    ...    regexp=${cgsetup_Regexp}    regexp02=${cgnot_setup_Regexp}
    Send And Verify Throuput    ue_id=2    qfi=1    send_dl=10    send_ul=10    sleep_time=10s    pdu=1
    Send And Verify Throuput    ue_id=2    qfi=2    send_dl=10    send_ul=10    sleep_time=10s    pdu=1
    Send And Verify Throuput    ue_id=2    qfi=3    send_dl=10    send_ul=10    sleep_time=10s    pdu=1
    UE Deregister From gNB    ue_id=2
    Check Counters    ${PM_Counters_Check_C02_C16_C20}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_C16${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008124-ET-C20-Successful_CG2_configuration_ics_with_initial_pdu_GBR_CG2_high_prio_and_non_GBR_CG2_low_prio_and_non_GBR_noCG_with_tdd_pattern_5ms
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour for the successful setup of Configured UL Grant Type 2
    ...    configuration for the bearer associated with Configured UL Grants Type 2 profile that is received as part of
    ...    Initial Context Setup Request procedure.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.default drb 5QI_80 is associated with NRULCG_PROFILE.
    ...    d.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach without PDU and then set up PDU session.5QI_4 is setup with CG2.
    ...    b.UE detach.
    [Tags]    QC_255642    owner-niya.ma
    Update UE capa    ue_id=2    SA_Capa_perUE_Full=${UE_Capa_Support_CG2_mac_phy}
    Clear Counter Files
    OnlineParamChange    ${CASE_20}
    ICS With initial Pdu    ue_id=2    cell_id=2    qos_flow_01=8    qos_flow_02=4    qos_flow_03=9    regexp=${cgsetup_Regexp}
    Send And Verify Throuput    ue_id=2    qfi=1    send_dl=10    send_ul=10    sleep_time=10s    pdu=1
    Send And Verify Throuput    ue_id=2    qfi=2    send_dl=10    send_ul=10    sleep_time=10s    pdu=1
    Send And Verify Throuput    ue_id=2    qfi=3    send_dl=10    send_ul=10    sleep_time=10s    pdu=1
    UE Deregister From gNB    ue_id=2
    Check Counters    ${PM_Counters_Check_C02_C16_C20}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_C20${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008124-ET-C32_Successful_CG2_release_with_PDU_Session_Modify_GBR_non_CG2_and_non_GBR_CG2_with_tdd_pattern_5ms
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour for the successful setup of Configured UL Grant Type 2
    ...    configuration for the bearer associated with Configured UL Grants Type 2 profile that is received as part of
    ...    Initial Context Setup Request procedure.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.default drb 5QI_80 is associated with NRULCG_PROFILE.
    ...    d.UE support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach without PDU and then set up PDU session.5QI_80 is setup with CG2.
    ...    b.UE detach.
    [Tags]    QC_256230    owner-niya.ma
    Update UE capa    ue_id=2    SA_Capa_perUE_Full=${UE_Capa_Support_CG2_mac_phy}
    Clear Counter Files
    OnlineParamChange    ${CASE_32}
    Pdu Session modify    ue_id=2    cell_id=2    qos_flow=8    qos_flow_01=4    regexp=${cgsetup_Regexp}
    ...    regexp02=${cgnot_setup_Regexp}
    Send And Verify Throuput    ue_id=2    qfi=2    send_dl=20    send_ul=10    sleep_time=10s    pdu=1
    UE Deregister From gNB    ue_id=2
    Check Counters    ${PM_Counters_Check_C32}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_C32${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=60 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8 default=on
    Update Cfg    set_qosflow id=9 5qi=80
    ${amf}    Catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=2
    Update Cfg    ${amf}

ICS With initial Pdu
    [Arguments]    ${ue_id}    ${cell_id}    ${qos_flow_01}    ${qos_flow_02}    ${qos_flow_03}    ${regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow_01} priority=15
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${qos_flow_02},${qos_flow_03}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${regexp}

ICS Without initial Pdu
    [Arguments]    ${ue_id}    ${cell_id}    ${qos_flow_01}    ${qos_flow_02}    ${regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow_01} priority=15
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${qos_flow_02}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${regexp}
    Execute Egate Command    amf_param id=1 send_ics_registration=off

Pdu Session modify
    [Arguments]    ${ue_id}    ${cell_id}    ${qos_flow}    ${qos_flow_01}    ${regexp}    ${regexp02}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow} priority=15
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${qos_flow_01}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${regexp}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qos_flow} by=amf    pass_regexp=${regexp02}
    Execute Egate Command    amf_param id=1 send_ics_registration=off

Pdu Session modify 02
    [Arguments]    ${ue_id}    ${cell_id}    ${qos_flow}    ${regexp}    ${qos_flow_01}    ${qos_flow_02}    ${regexp02}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow} priority=15
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${qos_flow_01}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${regexp}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qos_flow_02} by=amf    pass_regexp=${regexp02}
    Execute Egate Command    amf_param id=1 send_ics_registration=off

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}    ${pdu}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${send_dl}    ${send_ul}    ${sleep_time}    ${pdu}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${qfi}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}    ${pdu}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir
