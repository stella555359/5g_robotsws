*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-kexin.bao
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008124    release-SBTS23R2
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{8124_related_modification}
...    @{5qi80_related_modification}
...    NRCELL-2:cellDepType=SA
...    delete:NRCELL-2:configuredEpsTac
...    delete:NRBTS-1/NRDRB-15:nrPdschHRLaDN
...    MRBTS-1/NRBTS-1/NRCELL-2:chBw=60MHz

@{8124_related_modification}
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actUlCgType2=true
...    NRBTS/NRDRB-13:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=10
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=4
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms1
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumPrbs=12
...    NRCELL-1:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumPrbs=32
...    NRCELL-2:ulConfiguredGrantType2:ulCgPrbStartOffset=20

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
...    NRBTS/NRDRB-15:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS-1/NRDRB_5QI-7:fiveqiValueList=80
...    NRBTS-1/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50

@{OnlineParam_for_A02}
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms20
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=12

@{OnlineParam_for_B01}
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms80
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=4

${UE_Capa_Support_CG2_mac_phy}    SEPARATOR=
...    E1A03000076E0140502D018F0041C19000F04983200021E12006201A0130080C0700CA8D851AC10143404B2CA261201EB608080838778E
...    1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CA261201EB608080838778E1C830E0008193C7D5C0013C0070004F000A
...    8D89BAC10143404B2CA261201EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CA261201EB60808083
...    8778E1C830E0008193C7D54000014000000420E2680000000101343C001C020227B09801800140E0A00E06013003800341F00000000000
...    0072A68000800004B2CA801A55542400E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094450

${UE_Capa_Support_CG2_n78}    SEPARATOR=
...    E1A03000074E5A031E0003832001E09306400043C2400C4034026010180E01951B0A3582028680965944C2403D6C10101070EF1C39061C
...    00103278FAB80027800E0009E00151B133582028680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00551B1375
...    82028680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E000900C04200600A8D89DAC10143404B2CA261201EB60
...    8080838778E1C830E0008193C7D54000014000000420E2680000000101343C001C020227B09801800140E0A00E06013003800341F00000
...    0000000072A68000800004B2CA801A55542400E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094450

${SYSCOM_FLAG}    ${True}

*** Test Cases ***
CB008124_A_03_Failure_Configure_CG2_dueto_UECapa_after_Update_UECapa_CG2_configure_success_with_ICS_TDD_SANSA
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour for the successful setup of Configured UL Grant Type 2
    ...    configuration for the bearer associated with Configured UL Grants Type 2 profile that is received as part of
    ...    Initial Context Setup Request procedure.
    ...    2. Configuration
    ...    a.SA+NSA,TDD
    ...    b.Configured UL Grants Type 2 feature: NRBTS/NRCELL.actUlCgType2=true
    ...    c.default drb 5QI_8 is associated with NRULCG_PROFILE.
    ...    d.UE not support CG2.
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.5QI_8 is setup without CG2.
    ...    b.UE detach.
    ...    c.update UE capability to support CG2.
    ...    d.UE attach and set up PDU session.5QI_8 is setup with CG2.
    ...    e.UE detach.
    [Tags]    QC_252758    owner-kexin.bao
    Start RRC Log    A03_CG2_fail
    UE Attach To Target Cell    ue_id=1    cell_id=1
    Rrc Should Not Contain    configuredGrantConfig setup
    UE Deregister From gNB    ue_id=1
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_Support_CG2_n78}
    Start RRC Log    A03_CG2_success
    UE Attach To Target Cell    ue_id=1    cell_id=1
    Rrc Should Contain    configuredGrantConfig setup
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_A03${/}a2a.ini    wait_string=UEContextReleaseComplete::8

CB008124_A_02_Success_Configure_CG2_with_ICS_woPDU_TDD_SA
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
    ...    a.UE attach without PDU and then setup PDU session.5QI_80 is setup with CG2.
    ...    b.UE detach.
    [Tags]    QC_250677    owner-kexin.bao
    OnlineParamChange    ${OnlineParam_for_A02}
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_Support_CG2_mac_phy}
    ICS Without PDU    ue_id=1    cell_id=2    regexp=configuredGrantConfig setup
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_A02${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008124_B_01_Success_Multi_NonGBR_Bearer_CG2_Bearer_Release_SA
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
    ...    a.UE attach with PDU and then setup PDU session.5QI_80 is setup with CG2 and non-GBR:5qi=7.
    ...    b.UE detach.
    [Tags]    QC_254821    owner-lin.g.wang
    OnlineParamChange    ${OnlineParam_for_B01}
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_Support_CG2_n78}
    TC01 SA UE Attach    ue_id=1    cell_id=2    pdu_id=1    nwslice_id=1    gw_id=1
    Trigger PDU session release    ue_id=1    pdu_id=1    pass_regexp=Successfully released PDU Session
    UE Deregister From gNB    ue_id=1
    check wireshark log    ${CURDIR}${/}a2a_CB008124_B01${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8 default=on
    Update Cfg    set_qosflow id=9 5qi=80

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

ICS Without PDU
    [Arguments]    ${ue_id}    ${cell_id}    ${regexp}
    Execute Egate Command    qosflow_modify default=on qos_flow=9 priority=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${retvalue}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Should Contain    ${retvalue}    ${regexp}
    Execute Egate Command    amf_param id=1 send_ics_registration=off

TC01 SA UE Attach
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    qosflow_modify default=on qos_flow=9 priority=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1    Initial Context Setup Successful
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=7 by=amf    QoS Routing Table

Trigger PDU session release
    [Arguments]    ${ue_id}    ${pdu_id}    ${pass_regexp}
    ${output}=    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id} by=amf
    ...    pass_regexp=${pass_regexp}
    Should Contain    ${output}=    AMF-1: N4 Session Release for PDU Session
    Should Contain    ${output}=    drb-ToReleaseList
    Should Contain    ${output}=    4
    Should Contain    ${output}=    5
    Should Contain    ${output}=    AMF-1: PDU SESSION RESOURCE RELEASE RESPONSE
