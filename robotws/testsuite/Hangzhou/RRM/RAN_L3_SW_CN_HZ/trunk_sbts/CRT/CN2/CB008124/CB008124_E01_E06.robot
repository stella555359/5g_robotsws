*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-meredith.ma
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008124    release-SBTS23R3
...    STATE_CONFIGURED

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

${cg2_UE_Capabilities}    SEPARATOR=
...    E1A03000076E0140502D018F0041C19000F04983200021E12006201A0130080C0700CA8D851AC10143404B2CA261201EB608080838778E
...    1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CA261201EB608080838778E1C830E0008193C7D5C0013C0070004F000A
...    8D89BAC10143404B2CA261201EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CA261201EB60808083
...    8778E1C830E0008193C7D54000014000000420E2680000000101343C001C020227B09801800140E0A00E06013003800341F00000000000
...    0072A68000800004B2CA801A55542400E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094450

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=3/7
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4
...    @{intragnbHO}
...    @{multidrbs}
...    @{8124_related_modification}

@{8124_related_modification}
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL-1:actUlCgType2=false
...    NRCELL-2:actUlCgType2=true
...    NRBTS/NRDRB-3:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS/NRDRB-13:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=40
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=36
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms2
...    NRBTS/NRULCG_PROFILE-2:grantedPacketSize=80
...    NRBTS/NRULCG_PROFILE-2:maxNumPrbs=36
...    NRBTS/NRULCG_PROFILE-2:periodicity=ms5
...    NRCELL:maxGBRTrafficLimit=90
...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumPrbs=40
...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumUeUl=1
...    NRCELL:ulConfiguredGrantType2:ulCgPrbStartOffset=0

@{multidrbs}
...    NRDRB_5QI-10:fiveqiValueList=4
...    NRDRB_5QI-10:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...    NRDRB-3:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRDRB-3:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-3:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-3:resType=GBR
...    NRDRB-3:rlcMode=RLC_AM
...    NRDRB-3:maxDataRateGbrDl=30720
...    NRDRB-3:maxDataRateGbrUl=30720
...    NRDRB-3:l2OHFactorDl=16
...    NRDRB-3:l2OHFactorUl=35
...    NRDRB-3:discardTimer=50ms
...    NRDRB-3:dlFlowControlAlgo=3gppFlowControl
...    NRDRB-3:maxRlcQueueingDelayGbr=20
...    NRDRB-3:maxTransferDelayGbr=20
...    NRDRB-3:queuingDelayDiscarding=Disabled
...    NRDRB-3:dscp=46
...    NRDRB_MAC-5:lcgid=5
...    NRDRB_MAC-5:delayTarget=50
...    NRDRB_MAC-5:schedulBSD=20ms
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms15
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms15
...    NRCELL-1:actNonVoNRGbrService=true
...    NRCELL-2:actNonVoNRGbrService=true
...    NRCELL-1:actGBRAdmissionControl=GBRService
...    NRCELL-2:actGBRAdmissionControl=GBRService

@{intragnbHO}
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=50
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

@{PM_Counters_Check1}
...    NRCELL-1:NRCCD:${No_cg2_setup}=0
...    NRCELL-1:NRCCD:${No_cg2_rel}=0
...    NRCELL-1:RSADU:${No_cg2_att}=0
...    NRCELL-2:NRCCD:${No_cg2_setup}=1
...    NRCELL-2:NRCCD:${No_cg2_rel}=0
...    NRCELL-2:RSADU:${No_cg2_att}=1
...    NRCELL-1:NCELA:${No_cg2_act}=0
...    NRCELL-2:NCELA:${No_cg2_act}>=1

@{PM_Counters_Check2}
...    NRCELL-1:NRCCD:${No_cg2_setup}=0
...    NRCELL-1:NRCCD:${No_cg2_rel}=0
...    NRCELL-1:RSADU:${No_cg2_att}=0
...    NRCELL-2:NRCCD:${No_cg2_setup}=1
...    NRCELL-2:NRCCD:${No_cg2_rel}=0
...    NRCELL-2:RSADU:${No_cg2_att}=1

${No_cg2_setup}    M55166C00005    #No of RRC reconfiguration complete received with UL configured grant type2 setup
${No_cg2_rel}    M55166C00006    #No of RRC reconfiguration complete received with UL configured grant type2 release
${No_cg2_att}    M55139C00017    #UL configured grant Type2 resource allocation attempts
${No_cg2_act}    M55308C00021    #Successful UL configured grant type 2 activation attempts

*** Test Cases ***
CB008124_E01_CG_Type2_activated_at_source_and_target_cells_during_IntragNB_HO
    [Documentation]
    ...    1. This scenario describes the gNB behaviour for the successful setup of CG Type 2 configuration during
    ...    handover based on the measurement report to a cell in the same gNB-DU.
    ...    2. Configuration
    ...    a.SA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    3. Test Case Steps:
    ...    a.Successful CG Type 2 configuration setup for the bearer setup with first (initial) PDU Session Setup.
    ...    b.Intrafreq IntraDU HO and CG Type 2 setup for UE successful.
    ...    c.UE detach.
    [Tags]    QC_280385   owner-meredith.ma
    Clear Counter Files
    UE Attach To Target Cell with more QoS flows    ue_id=1    cell_id=1
    Start traffic    ue_id=1
    SA Intragnb Intrafreq HO    ue_id=1
    Check Counters    ${PM_Counters_Check1}
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_E01${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008124_E06_CG_Type2_activated_at_source_cell_but_deactivated_at_target_cell_during_IntragNB_HO
    [Documentation]
    ...    1. This scenario describes the gNB behaviour for the successful setup of CG Type 2 configuration during
    ...    handover based on the measurement report to a cell in the same gNB-DU.
    ...    2. Configuration
    ...    a.SA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    3. Test Case Steps:
    ...    a.Successful CG Type 2 configuration setup for the bearer setup with first (initial) PDU Session Setup.
    ...    b.Intrafreq IntraDU HO and CG Type 2 setup for UE successful.
    ...    c.UE detach.
    [Tags]    QC_281172   owner-meredith.ma
    Clear Counter Files
    UE Attach To Target Cell with more QoS flows    ue_id=1    cell_id=2
    Start traffic    ue_id=1
    SA Intragnb Intrafreq HO from cell1    ue_id=1
    Check Counters    ${PM_Counters_Check2}
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_E06${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15

Modify Cfg
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=5000 gfbr_dl=10000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    ue_param id=1-2 ue_nr_capabilities=${cg2_UE_Capabilities}

UE Attach To Target Cell with more QoS flows
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=4
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

Start traffic
    [Arguments]    ${ue_id}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=10    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=5 mbps=2    UE ${ue_id}: UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=dl trf_id=4 mbps=10    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=ul trf_id=5 mbps=2    UE ${ue_id}: UDP UL
    Sleep    60s    sleep for Tput stable

Verify Multi drbs Throuput
    [Arguments]    ${ue_id}    ${Tput_dl}=9    ${Tput_ul}=0.5    ${sleep_time}=60s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${dl_throughput2}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=2    direction=dl    rate_type=ave
    ${ul_throughput2}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=2    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput1}/1000>${Tput_dl}
    Should Be True    ${ul_throughput1}/1000>${Tput_ul}
    Should Be True    ${dl_throughput2}/1000>${Tput_dl}
    Should Be True    ${ul_throughput2}/1000>${Tput_ul}

SA Intragnb Intrafreq HO
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A5 srsrp_nr=40 srsrq_nr=40 phycell_id=51 nrsrp_nr=60 nrsrq_nr=60
    ...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Verify Multi drbs Throuput    ${ue_id}

SA Intragnb Intrafreq HO from cell1
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A5 srsrp_nr=40 srsrq_nr=40 phycell_id=50 nrsrp_nr=60 nrsrq_nr=60
    ...    Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
    Verify Multi drbs Throuput    ${ue_id}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
