*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-tao.2.cui
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008124    release-SBTS23R3
...    STATE_CONFIGURED

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri
${BTSLOG_FLAG}    ${True}
${WIRESHARK_FLAG}    ${True}
${SNAPSHOT_FLAG}    pass:False,fail:True
${TTITRACE_FLAG}    ${True}
${GNB_BIP_FLAG}    ${True}

@{PARAMS_IN_SWCONFIG}
...    0x58057E=0x200
...    0x58057A=0x3

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{cell-2_parameters}
...    @{Enable GBR Service}
...    @{CB008124_related_modification}
...    @{DRB_To_5qi_Mapping}
...    @{Create_DRB-18}
...    @{Create_DRB-15}

@{Enable GBR Service}
...    NRCELL:actNonVoNRGbrService=true

@{cell-2_parameters}
...    NRCELL-2:cellDepType=SA
...    delete:NRCELL-2:configuredEpsTac
...    MRBTS-1/NRBTS-1/NRCELL-2:chBw=60MHz

@{CB008124_related_modification}
#Enable CB008124
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actUlCgType2=true
#Config Cell Based Parameters
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumPrbs=32
...    NRCELL-1:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumUeUl=2
...    NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumPrbs=32
...    NRCELL-2:ulConfiguredGrantType2:ulCgPrbStartOffset=20
...    NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumUeUl=2
#Config NRULCG_Profile Based Parameters
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=1000
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=32
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms1
...    NRBTS/NRULCG_PROFILE-2:grantedPacketSize=2000
...    NRBTS/NRULCG_PROFILE-2:maxNumPrbs=32
...    NRBTS/NRULCG_PROFILE-2:periodicity=ms5
...    NRBTS/NRULCG_PROFILE-3:grantedPacketSize=800
...    NRBTS/NRULCG_PROFILE-3:maxNumPrbs=32
...    NRBTS/NRULCG_PROFILE-3:periodicity=ms80
#Link DRB to NRULCG_Profile
...    NRBTS/NRDRB-15:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1    #DRB-15-->5QI-80-->qfi-9
...    NRBTS/NRDRB-18:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-2    #DRB-18-->5QI-4-->qfi-4
...    NRBTS/NRDRB-11:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-3    #DRB-11-->5QI-6-->qfi-6

@{DRB_To_5qi_Mapping}
#Create 5QI-4 and link to DRB-18
...    NRBTS/NRDRB_5QI-8:fiveqiValueList=4
...    NRBTS/NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-18
#Create 5qi80 and link to DRB-15
...    NRBTS-1/NRDRB_5QI-7:fiveqiValueList=80
...    NRBTS-1/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15

@{Create_DRB-18}
#Create DRB-18 linked PDCP MAC RLC Profile
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-5:schedulBSD=5ms
...    NRBTS/NRDRB_MAC-5:schedulPrio=7
...    NRBTS/NRDRB_PDCP-4:cuFlowControlProfId=1
...    NRBTS/NRDRB_PDCP-4:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_PDCP-4:pdcpBufDiscardThreshold=20000
...    NRBTS/NRDRB_PDCP-4:pdcpDelayThreshRetxMode=disabled
...    NRBTS/NRDRB_PDCP-4:tReorderingDl=ms8
...    NRBTS/NRDRB_PDCP-4:tReorderingUl=ms8
...    NRBTS/NRDRB_PDCP-4:xxFlowControlProfForCuIdx=1
...    NRBTS/NRDRB_RLC_AM-4:dlMaxRetxThreshold=t16
...    NRBTS/NRDRB_RLC_AM-4:dlPollByte=kB500
...    NRBTS/NRDRB_RLC_AM-4:dlPollPDU=p64
...    NRBTS/NRDRB_RLC_AM-4:dlTPollRetr=ms100
...    NRBTS/NRDRB_RLC_AM-4:dlTProhib=ms15
...    NRBTS/NRDRB_RLC_AM-4:dlTReassembly=ms15
...    NRBTS/NRDRB_RLC_AM-4:dlTReassemblyIBCA=30
...    NRBTS/NRDRB_RLC_AM-4:duFlowControlProfId=1
...    NRBTS/NRDRB_RLC_AM-4:ulMaxRetxThreshold=t32
...    NRBTS/NRDRB_RLC_AM-4:ulPollByte=kB500
...    NRBTS/NRDRB_RLC_AM-4:ulPollPDU=p64
...    NRBTS/NRDRB_RLC_AM-4:ulTPollRetr=ms45
...    NRBTS/NRDRB_RLC_AM-4:ulTProhib=ms15
...    NRBTS/NRDRB_RLC_AM-4:ulTReassembly=ms15
...    NRBTS/NRDRB_RLC_AM-4:ulTReassemblyIBCA=${EMPTY}
#Create DRB-18
...    NRBTS/NRDRB-18:actDddsReduction=false
...    NRBTS/NRDRB-18:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-18:actLostPduFastRetx=false
...    NRBTS/NRDRB-18:discardTimer=50ms
...    NRBTS/NRDRB-18:dlAllowMinDelayLinkXxCalib=false
...    NRBTS/NRDRB-18:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-18:dscp=0
...    NRBTS/NRDRB-18:durationThresDiscardDl=40
...    NRBTS/NRDRB-18:durationThresDiscardUl=20
...    NRBTS/NRDRB-18:endMarkerTimer=2000
...    NRBTS/NRDRB-18:l2OHFactorDl=16
...    NRBTS/NRDRB-18:l2OHFactorUl=35
...    NRBTS/NRDRB-18:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-18:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-18:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-18:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-18:maxTransferDelayGbr=20
...    NRBTS/NRDRB-18:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-18:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-4
...    NRBTS/NRDRB-18:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-4
...    NRBTS/NRDRB-18:numSduDiscard=1
...    NRBTS/NRDRB-18:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS/NRDRB-18:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-18:resType=GBR
...    NRBTS/NRDRB-18:rlcMode=RLC_AM
...    NRBTS/NRDRB-18:schedulWeight=1
...    NRBTS/NRDRB-18:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-18:volThresDiscardDl=8000
...    NRBTS/NRDRB-18:volThresDiscardUl=800
...    NRBTS/NRDRB-18:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-18:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS/NRDRB-18:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS/NRDRB-18:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS/NRDRB-18:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS/NRDRB-18:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS/NRDRB-18:nsaDrbParam:dlNumOfCongOrGainDdds=2
...    NRBTS/NRDRB-18:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS/NRDRB-18:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS/NRDRB-18:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS/NRDRB-18:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS/NRDRB-18:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-18:nsaDrbParam:prioritizeX2Period=500
...    NRBTS/NRDRB-18:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-18:nsaDrbParam:ulDataSplitThreshold=infinity

@{Create_DRB-15}
#Modify DRB-15 linked RLC Profile
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50
#Create DRB-15
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

@{ULCG_RAC}
...    NRCELL-1:actGBRAdmissionControl=GBRService
...    NRCELL-1:maxGBRTrafficLimit=10
...    NRCELL-1:ulConfiguredGrantType2:maxGBRAndCgType2TrafficLimit=10
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumUeUl=1

${UE_Capa_Support_CG2_mac_phy}    SEPARATOR=
...    E1A03000076E0140502D018F0041C19000F04983200021E12006201A0130080C0700CA8D851AC10143404B2CA261201EB608080838778E
...    1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CA261201EB608080838778E1C830E0008193C7D5C0013C0070004F000A
...    8D89BAC10143404B2CA261201EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CA261201EB60808083
...    8778E1C830E0008193C7D54000014000000420E2680000000101343C001C020227B09801800140E0A00E06013003800341F00000000000
...    0072A68000800004B2CA801A55542400E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094450

${ue_Capa_Support_CG2_mac_phy_7552}    SEPARATOR=
...    E1A03000076E0140502D018F0041C210003C1260C800087848018806804C060180E01951B0A3582028680965944C3400F5B0404041C3BC
...    70E418700040C9E3EAE0009E00380027800546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB80027800E0009E00
...    151B137582028680965944C3400F5B0404041C3BC70E418700040C9E3EAE0009C00380027000546C4ED6080A1A025965130D003D6C1010
...    1070EF1C39061C00103278FAA8000028000000841C4D0000000020268B80003804044F617001800140E0A00E06013003800341F0000000
...    00000072A68000800004B2CA801A55542C007000B00000004008011AB130001020304050607080B101112131921252627284A228

*** Test Cases ***
CB008124_C26_Success_Non-GBR_Bearer_Configured_CG2_Setup_actGBRAdmissionControl_off
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
    ...    b.DRB addition 5qi=4
    ...    c.UL and DL tPUT
    ...    b.UE detach.
    [Tags]    QC_280386    owner-tao.2.cui
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${ue_Capa_Support_CG2_mac_phy}
    Update UE capa    ue_id=2    SA_Capa_perUE_Full=${ue_Capa_Support_CG2_mac_phy}
    Update UE capa    ue_id=3    SA_Capa_perUE_Full=${ue_Capa_Support_CG2_mac_phy}

    ICS Without PDU    ue_id=1    cell_id=1    qos_flow=9    regexp=configuredGrantConfig setup
    Setup DRB    ue_id=1    regexp=Added QosFlow with QFI:2 5QI:4    qfi=2    qosflow=4    5qi=4
    Send Dl And Ul Throuput    ue_id=1    qfi=1    send_dl=10    send_ul=10    pdu=1

    UE Attach To Target Cell    ue_id=2    cell_id=1
    Send Dl And Ul Throuput    ue_id=2    qfi=1    send_dl=10    send_ul=10    pdu=1

    ICS Without PDU    ue_id=3    cell_id=1    qos_flow=9    regexp=configuredGrantConfig setup
    Setup DRB    ue_id=3    regexp=Added QosFlow with QFI:2 5QI:4    qfi=2    qosflow=4    5qi=4
    Send And Verify Throuput    ue_id=3    qfi=1    send_dl=10    send_ul=10    sleep_time=10s    pdu=1

    UE Deregister From gNB    ue_id=1
    UE Deregister From gNB    ue_id=2
    UE Deregister From gNB    ue_id=3

CB008124_C23_Success_GBR_CG2_Till_maxGBRTrafficLimit_actGBRAdmissionControl_Off
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
    ...    b.DRB addition 5qi=4
    ...    c.UL and DL tPUT
    ...    b.UE detach.
    [Tags]    QC_280387    owner-tao.2.cui
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${ue_Capa_Support_CG2_mac_phy}
    Update UE capa    ue_id=2    SA_Capa_perUE_Full=${ue_Capa_Support_CG2_mac_phy}
    Update UE capa    ue_id=3    SA_Capa_perUE_Full=${ue_Capa_Support_CG2_mac_phy}

    ICS Without PDU    ue_id=1    cell_id=1    qos_flow=9    regexp=configuredGrantConfig setup
    Setup DRB    ue_id=1    regexp=Added QosFlow with QFI:2 5QI:4    qfi=2    qosflow=4    5qi=4
    Send Dl And Ul Throuput    ue_id=1    qfi=2    send_dl=10    send_ul=10    pdu=1

    UE Attach To Target Cell    ue_id=2    cell_id=1
    Setup DRB    ue_id=2    regexp=Added QosFlow with QFI:2 5QI:4    qfi=2    qosflow=4    5qi=4
    Send Dl And Ul Throuput    ue_id=2    qfi=2    send_dl=10    send_ul=10    pdu=1

    ICS Without PDU    ue_id=3    cell_id=1    qos_flow=9    regexp=configuredGrantConfig setup
    Setup DRB    ue_id=3    regexp=Added QosFlow with QFI:2 5QI:4    qfi=2    qosflow=4    5qi=4
    Send And Verify Throuput    ue_id=3    qfi=2    send_dl=10    send_ul=10    sleep_time=10s    pdu=1

    UE Deregister From gNB    ue_id=1
    UE Deregister From gNB    ue_id=2
    UE Deregister From gNB    ue_id=3

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
    Delete Cfg    set_qosflow id=1 5qi=6
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=10720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8 default=on
    Update Cfg    set_qosflow id=9 5qi=80
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_Capa_Support_CG2_mac_phy}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${ue_Capa_Support_CG2_mac_phy}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${ue_Capa_Support_CG2_mac_phy}

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
    [Arguments]    ${ue_id}    ${cell_id}    ${regexp}    ${qos_flow}
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow} priority=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${retvalue}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Should Contain    ${retvalue}    ${regexp}
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    Execute Egate Command    qosflow_modify default=on qos_flow=8 priority=1

Setup DRB
    [Arguments]    ${ue_id}    ${regexp}    ${qfi}    ${qosflow}    ${5qi}
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qosflow} by=amf
    ...    pass_regexp=Added QosFlow with QFI:${qfi} fiveQI:${5qi}
    should contain    ${retvalue}    ${regexp}

PDU Add QoSFlow
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qfi_id} by=amf    QoS Routing Table

Send And Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${send_dl}    ${send_ul}    ${sleep_time}    ${pdu}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${send_dl} size=100
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=${send_ul} size=100
    Verify Throuput    ${ue_id}    ${qfi}    ${send_dl}*0.1    ${send_ul}*0.1    ${sleep_time}    ${pdu}

Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}    ${pdu}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send Dl And Ul Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${send_dl}    ${send_ul}    ${pdu}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${send_dl} size=100
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=${send_ul} size=100

Stop Dl And Ul Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${pdu}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi}
