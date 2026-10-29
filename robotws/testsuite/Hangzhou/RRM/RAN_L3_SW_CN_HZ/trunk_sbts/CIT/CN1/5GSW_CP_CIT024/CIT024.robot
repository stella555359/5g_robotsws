*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CIT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN3_SG2
...    owner-baijie.zhu    release-5G20A     5GC000706    CDRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{5GC000706_Base}    @{NRADJNRCELL}    @{NRHOIF}    @{NRADJGNB}    @{NRREL}
@{5GC000706_Base}
...    MRBTS-1/NRBTS-1:cipherPrefL:nea0=9
...    MRBTS-1/NRBTS-1:cipherPrefL:nea3_128=0
...    MRBTS-1/NRBTS-1:actIncXn=true
...    MRBTS-1/NRBTS-1:actConflictConfiguration=true
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1:timerXnDataFwdGuard=250

...    MRBTS-1/NRBTS-1/NRCELL-1:cbraPreamblesPerSsb=n60
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabledSA=rsrpAndRsrq
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:measGapSelectionSA=favourUeThroughput
...    MRBTS-1/NRBTS-1/NRCELL-1:actCDrx=false
...    MRBTS-1/NRBTS-1/NRCELL-1:gapOffset=8
...    MRBTS-1/NRBTS-1/NRCELL-1:mgta=ms0dot5
...    MRBTS-1/NRBTS-1/NRCELL-1:reportIntervalSA=ms120
...    MRBTS-1/NRBTS-1/NRCELL-1:reportOnLeave=false
...    MRBTS-1/NRBTS-1/NRCELL-1:reportAmountSA=r4
...    MRBTS-1/NRBTS-1/NRCELL-1:ifhoSsbSmtcOffset=8
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=80
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=26
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=80
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=10
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=40
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms64
...    TRACKINGAREA-200:fiveGsTac=0
...    MRBTS-1/NRBTS-1/XNLINK-3:cPlaneIpAddr=10.0.1.122
@{NRADJNRCELL}
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrAdjNrCellId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=633372
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:ssbFrequency=633408
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=381
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:fiveGsTac=200
@{NRHOIF}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=633408
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
@{NRREL}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
@{NRADJGNB}
...    MRBTS-1/NRBTS-1/NRADJGNB-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJGNB-3:xnLinkRef=3
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mncLength=3

${UE_CAPA_CIT024}  SEPARATOR=
...    69800000446084C00E83626D52B04610D04083E52F55555553D55555540A00E000801C4D000000002626801FFFF000058
...    06C005038180603105806000780F0300C03C00000000000008A80000000000000A8000008010020

# HO Counters
${ATT_OG_IF_INTER_GNB_HO_SA_PLMN}    M55145C00351
${SUCC_OG_IF_INTERGNB_HO_SA_PLMN}    M55145C00352
${SUCC_IC_INTER_GNB_HOP_SA_PLMN}    M55145C00361
${SUCC_IC_INTER_GNB_HO_SA_PLMN}    M55145C00362
${TOT_INTER_FREQ_HO_DECISION_A3}    M55147C00024
${ATT_IF_INTER_GNB_HO_SLICE}    M55149C00570
${SUCC_OG_IF_INTER_GNB_HO_SLICE}    M55149C00571
${NRRCC_MEAS_A2_REC}    M55124C02002

@{PM_Counters_Check_CIT024}
...    NRCELL-1:NRANS:${ATT_OG_IF_INTER_GNB_HO_SA_PLMN}==1
...    NRCELL-1:NRANS:${SUCC_OG_IF_INTERGNB_HO_SA_PLMN}==1
...    NRCELL-1:NRANS:${SUCC_IC_INTER_GNB_HOP_SA_PLMN}==1
...    NRCELL-1:NRANS:${SUCC_IC_INTER_GNB_HO_SA_PLMN}==1
...    NRCELL-1:NMOCU:${TOT_INTER_FREQ_HO_DECISION_A3}==1
...    NRBTS-1:NSL:${ATT_IF_INTER_GNB_HO_SLICE}==1
...    NRBTS-1:NSL:${SUCC_OG_IF_INTER_GNB_HO_SLICE}==1
...    NRCELL-1:NRRCC:${NRRCC_MEAS_A2_REC}==1

${BTS_STARTUP_RETRY}    4

*** Test Cases ***
5GSW-CP-CIT024_Verify_Classical_SA_TDD_cmWave_inter-frequency_inter-gNB_HO_with_A3_RSRP_CFRA_is_successful
    [Documentation]    This case is designed to verify inter-gNB and inter frequency HO.
    ...                1. UE HO from real gNB to simulated gNB.
    ...                2. UE HO back from simulated gNB to real gNB.
    ...                3. UE will use CFRA during HO.
    [Tags]    QC_61709    Zhu Baijie
    Clear Counter files
    Add UE History Information List
    Register UE And Check A2 MeasConfig
    UE Triggers Inter-Frequency Inter-gNB HO and Check MeasGap Setup
    UE HO back from sim_gNB and check MeasGap Release
    Stop and Analyze wireshark log
    Analyze PM Counters
    [Teardown]    Teardown Of Ue Deregister

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${V_1}    catenate
    ...    ue_param id=1 ue_nr_capabilities=${UE_CAPA_CIT024}
    Update Cfg    ${V_1}
    ${set_gnb2}    catenate
    ...    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x01:22 daemon=10.0.2.1:22222
    ...    xn=10.0.1.2 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${set_gnb2}
    ${set_gnb2_cell1}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb2_cell1}
    ${set_gnb3}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${set_gnb3}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=633372:633372
    ...    gscn=7847 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}
    ${set_gnb3_cell2}    catenate    set_cell id=2 gnb=3 pci=127:1 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell2}

Add UE History Information List
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=1 action=commit
    Execute Egate Command    ue_enb_param id=1 ue_history_list=1
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3

Register UE And Check A2 MeasConfig
    Start RRC Log     Check_A2_MeasConfig
    Execute Egate Command    ue_register id=1    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table
    Check RRC log    ${CURDIR}${/}a2a_CIT024${/}Check_A2_MeasConfig.ini

UE Triggers Inter-Frequency Inter-gNB HO and Check MeasGap Setup
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=dl trf_id=4 mbps=10    UE 1: UDP DL
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=ul trf_id=5 mbps=10    UE 1: UDP UL
    Send A2 MR And Check MeasGap Setup
    Send A3 MR Then HO
    Verify Throughput

UE HO back from sim_gNB and check MeasGap Release
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=50    nrsrp_nr=30 nrsrq_nr=30
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${meas_gap_release}=    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover
    ${tmp_log}=    Remove Blank Character    ${meas_gap_release}
    Should Contain    ${tmp_log}    spCellConfigCommon{physCellId50
    Should Contain    ${tmp_log}    cfra
    Should Contain    ${meas_gap_release}    gapUE release : NULL

Verify Throughput
    [Documentation]    verify Tput in scell is not 0
    [Arguments]    ${Tput_dl}=9    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=1 scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Stop and Analyze wireshark log
    Check Wireshark Log     ${CURDIR}${/}a2a_CIT024${/}Check_HO.ini    wait_string=PathSwitchRequestAcknowledge
    BuiltIn.Log To Console    Wirshark check is done

Analyze PM Counters
    Check Counters    ${PM_Counters_Check_CIT024}
    BuiltIn.Log To Console    PM check is done

Ue_Deregister_With Traffic_Stop_And_Pdu_Session_Release
    Execute Egate Command    trf_data_stop ue=1 pdu=1    Stopped Downlink Internal traffic on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:4
    Execute Egate Command    ue_pdu_session_release ue=1 pdu=1    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    UE CONTEXT RELEASE COMPLETE

Teardown Of Ue Deregister
    Ue_Deregister_With Traffic_Stop_And_Pdu_Session_Release
    Common Test Teardown And Stop Capture Logs

Send A3 MR Then HO
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=4 event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=381 nrsrp_nr=30 nrsrq_nr=30
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${ho_log}=    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    ${ho_log}    Remove Blank Character    ${ho_log}
    Should Contain    ${ho_log}    spCellConfigCommon{physCellId381
    sleep    15s    #wait for be stable

Remove Blank Character
    [Arguments]    ${str}
    ${str}=    Remove String    ${str}    ${SPACE}
    ${str}=    Remove String    ${str}    \r\n
    ${str}=    Remove String    ${str}    \n
    ${str}=    Remove String    ${str}    \x1b[K
    [Return]    ${str}

Send A2 MR And Check MeasGap Setup
    ${A2_egate_log}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11    pass_regexp=eventA3
    Should Contain    ${A2_egate_log}    gapOffset 8
    Should Contain    ${A2_egate_log}    mgl ms3
    Should Contain    ${A2_egate_log}    mgrp ms160
    Should Contain    ${A2_egate_log}    mgta ms0dot5
