*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_Aic    master_vDU    CRT
...    CLOUD_5GC_dRNIC_1vDU_O_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    owner-jianfen.shen    release-5G23R3    team-DevHZ5_SG02    vDUCNF00

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F
${SA_UE_ID}    1
@{PARAMS_IN_SCF_CU}    @{5GC000704_Base_cu}    @{TRACKINGAREA_CU}    @{XNLINK_CU}
...    @{NRADJGNB_CU}    @{NRADJNRCELL_CU}    @{NRREL_CU}    @{A3_PARAMS_CU}
@{PARAMS_IN_SCF_DU1}    @{5GC000704_Base_du}    @{TRACKINGAREA_DU}    @{CFRA_CONF_DU}
...    @{NRADJNRCELL_DU}    @{NRREL_DU}

@{5GC000704_Base_cu}
...    MRBTS-1/NRBTS-1:cipherPrefL:nea0=9
...    MRBTS-1/NRBTS-1:cipherPrefL:nea1_128=0
...    MRBTS-1/NRBTS-1:cipherPrefL:nea2_128=0
...    MRBTS-1/NRBTS-1:cipherPrefL:nea3_128=0
...    MRBTS-1/NRBTS-1:integrityProtPrefL:nia0=0
...    MRBTS-1/NRBTS-1:integrityProtPrefL:nia1_128=0
...    MRBTS-1/NRBTS-1:integrityProtPrefL:nia2_128=0
...    MRBTS-1/NRBTS-1:integrityProtPrefL:nia3_128=9
...    MRBTS-1/NRBTS-1:actIncXn=true
...    MRBTS-1/NRBTS-1:actConflictConfiguration=true
...    MRBTS-1/NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    MRBTS-1/NRBTS-1:timerXnDataFwdGuard=250

...    MRBTS-1/NRBTS-1/NRCELL-1:chBw=100MHz
...    MRBTS-1/NRBTS-1/NRCELL-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-1:nrarfcn=636666
...    MRBTS-1/NRBTS-1/NRCELL-1:actCDrx=false
...    MRBTS-1/NRBTS-1/NRCELL-1:reportIntervalSA=ms120
...    MRBTS-1/NRBTS-1/NRCELL-1:reportOnLeave=false
...    MRBTS-1/NRBTS-1/NRCELL-1:reportAmountSA=r4
...    MRBTS-1/NRBTS-1/NRCELL-1:ifhoSsbSmtcOffset=8

@{TRACKINGAREA_CU}
...    MRBTS-1/NRBTS-1/TRACKINGAREA-200:fiveGsTac=0
...    MRBTS-1/NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1

@{XNLINK_CU}
...    MRBTS-1/NRBTS-1/XNLINK-3:cPlaneIpAddr=10.0.12.11

@{5GC000704_Base_du}

...    MRBTS-1/NRBTS-1/NRCELL-1:chBw=100MHz
...    MRBTS-1/NRBTS-1/NRCELL-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-1:nrarfcn=636666
...    MRBTS-1/NRBTS-1/NRCELL-1:gscnOrSsPbchArfcn=7880
...    MRBTS-1/NRBTS-1/NRCELL-1:actCDrx=false

@{TRACKINGAREA_DU}
...    MRBTS-1/NRBTS-1/TRACKINGAREA-200:fiveGsTac=0
...    MRBTS-1/NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1

@{A3_PARAMS_CU}
...    NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRBTS-1/NRCELL-1:sMeasConfigSsbRsrp=1
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0

@{NRADJGNB_CU}
...    MRBTS-1/NRBTS-1/NRADJGNB-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJGNB-3:xnLinkRef=3
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mncLength=3

@{NRADJNRCELL_CU}
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrAdjNrCellId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=636666
#...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:ssbFrequency=633408
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=381
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:fiveGsTac=200

@{NRADJNRCELL_DU}
...    NRBTS/NRADJNRCELL-1

@{NRREL_CU}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:removeNotAllowed=true

@{NRREL_DU}
...    NRBTS/NRCELL/NRREL-1

#@{CFRA_CONF_CU}
#...    MRBTS-1/NRBTS-1/NRCELL-1:cbraPreamblesPerSsb=n60

@{CFRA_CONF_DU}
...    MRBTS-1/NRBTS-1/NRCELL-1:cbraPreamblesPerSsb=n60
...    MRBTS-1/NRBTS-1/NRCELL-1:rsrpThresholdSSB=15

# HO Counters on CU
#The number of outgoing intra-frequency inter-gNB HO execution attempts for SA per PLMN-ID
${ATT_OG_INTER_GNB_HO_SA_PLMN}    M55145C00341
#The number of successful outgoing intra-frequency inter-gNB HO executions for SA per PLMN-ID
${SUCC_OG_INTER_GNB_HO_SA_PLMN}    M55145C00342
#The number of successful incoming inter-gNB HO preparations for SA per PLMN-ID
${SUCC_IC_INTER_GNB_HOP_SA_PLMN}    M55145C00361
#The number of successful incoming inter-gNB HO executions for SA per PLMN-ID
${SUCC_IC_INTER_GNB_HO_SA_PLMN}    M55145C00362
#The number of Intra-Frequency Inter-gNB HOs attempted, for the given slice and PLMN
${ATT_INTER_GNB_HO_SLICE}    M55149C00008
#The number of Intra-Frequency Inter-gNB Outgoing HO successful, for the given slice and PLMN
${SUCC_OG_INTER_GNB_HO_SLICE}    M55149C00009
#The number of Incoming Inter-gNB HO successful, for the given slice and PLMN
${SUCC_IC_INTER_GNB_HO_SLICE}    M55149C00010
#The number of positive Handover decisions after receiving A3 measurement report
${TOT_INTRA_FREQ_HO_DECISION_A3S}    M55147C00001


@{PM_Counters_Check_CU}
...    NRCELL-1:NRANS:${ATT_OG_INTER_GNB_HO_SA_PLMN}==1
...    NRCELL-1:NRANS:${SUCC_OG_INTER_GNB_HO_SA_PLMN}==1
...    NRCELL-1:NRANS:${SUCC_IC_INTER_GNB_HOP_SA_PLMN}==1
...    NRCELL-1:NRANS:${SUCC_IC_INTER_GNB_HO_SA_PLMN}==1
...    NRCELL-1:NMOCU:${TOT_INTRA_FREQ_HO_DECISION_A3S}==1
...    NRBTS-1:NSL:${ATT_INTER_GNB_HO_SLICE}==1
...    NRBTS-1:NSL:${SUCC_OG_INTER_GNB_HO_SLICE}==1
...    NRBTS-1:NSL:${SUCC_IC_INTER_GNB_HO_SLICE}==1

*** Test Cases ***
CB009881-ET_5GC000637_Verify_Cloud_gNB_SA_TDD_cmWave_intra-frequency_inter-gNB_HO_with_A3_RSRP_CFRA_is_successful
    [Documentation]
    ...    1. The purpose of this test case is designed to verify inter-gNB and intra frequency HO:
    ...         This case will cover 5GC000637 and 5GC000704 features.
    ...             gnb_cell1:band=n78, nr_arfcn=636666, gscn=7880, ssbFrequency=636576, bandwith=100M
    ...             sim_gnb_cell1:band=n78, nr_arfcn=636666, gscn=7880, ssbFrequency=636576, bandwith=50M
    ...    2. Test Case Steps:
    ...         a. UE HO from real gNB to simulated gNB.
    ...         b. UE HO back from simulated gNB to real gNB.
    ...         c. UE will use CFRA during HO.
    [Tags]    QC_278596
    Clear Counter files
    Add UE History Information List
    Register UE And Check Traffic
    UE Triggers Intra-Frequency Inter-gNB HO From Real gNB To Sim gNB
    UE HO Back From Sim gNB To Real gNB
    Stop and Analyze wireshark log
    Check Counters
    [Teardown]    Teardown Of Ue Deregister

*** Keywords ***
Modify Cfg Aic
    ${set_gnb2}    catenate
    ...    set_gnb id=2 type=external plmn=311:489 ng=10.0.11.10 gnb_id=0x01:22 daemon=10.0.2.1:22222 xn=10.0.12.10
    ...    s1u=10.0.1.210 x2u=10.0.1.210 x2=10.0.1.10:36422 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg Aic    ${set_gnb2}
    ${set_gnb2_cell1}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    Update Cfg Aic    ${set_gnb2_cell1}
    ${set_gnb3}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.11.11 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.12.11 nssai=0x1:0xd143a5 amf=1
    Update Cfg Aic    ${set_gnb3}
    ###set for CFRA
    Update Cfg Aic    gnb_param id=3 xn_listening_socket=on send_xn_setup=false
    ###end
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg Aic    ${set_gnb3_cell1}
    Update Cfg Aic    amf_ng_setup_param id=1 relative_capacity=100 include_backup_amf_name=off
    Update Cfg Aic    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg Aic    ue_param id=${SA_UE_ID} ue_nr_capabilities=${SA_Capa_perUE_Full}
    ${set_sa_ue1}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    Update Cfg Aic    ${set_sa_ue1}

Clear Counter Files
    Clear Counter Files Cu Aic    wait=False

Add UE History Information List
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=1 action=commit
    Execute Egate Command    ue_enb_param id=${SA_UE_ID} ue_history_list=1
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3

Register UE And Check Traffic
    Execute Egate Command    ue_register id=${SA_UE_ID}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${SA_UE_ID} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${SA_UE_ID} pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table
    Execute Egate Command    data_trf_start ue=${SA_UE_ID} pdu=1 qfi=1 dir=dl trf_id=4 mbps=10    UE 1: UDP DL
    Execute Egate Command    data_trf_start ue=${SA_UE_ID} pdu=1 qfi=1 dir=ul trf_id=5 mbps=10    UE 1: UDP UL
    Verify Throughput

UE Triggers Intra-Frequency Inter-gNB HO From Real gNB To Sim gNB
    Send A3 MR Then HO
    Verify Throughput

UE HO Back From Sim gNB To Real gNB
    [Arguments]    ${event_id}=A3
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${SA_UE_ID}    carrierfreq=636576    event_type=${event_id}
    ${cmd}    Catenate    ue_measurement_send_nr id=${SA_UE_ID} meas_id=${meas_id} event=${event_id} srsrp_nr=11 srsrq_nr=11 phycell_id=50
    ...    nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=40:40:59
    ${ho_log}=    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover
    ${tmp_log}=    Remove Blank Character    ${ho_log}
    Should Contain    ${tmp_log}    spCellConfigCommon{physCellId50
    Should Contain    ${tmp_log}    cfra
    Execute Egate Command    ue_disp state=ACTIVE    2.1

Verify Throughput
    [Documentation]    verify Tput in scell is not 0
    [Arguments]    ${Tput_dl}=8.5    ${Tput_ul}=8.5    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${SA_UE_ID}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${SA_UE_ID}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${SA_UE_ID} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Stop and Analyze wireshark log
    Check WireShark Log Aic     ${CURDIR}${/}a2a_5GC000637${/}a2a.ini    wait_string=UEContextRelease::10
    BuiltIn.Log To Console    Wirshark check is done

Check Counters
    Check Counters Cu Aic    ${PM_Counters_Check_CU}
    BuiltIn.Log To Console    PM check is done

Ue_Deregister_With Traffic_Stop_And_Pdu_Session_Release
    Execute Egate Command    trf_data_stop ue=${SA_UE_ID} pdu=1    Stopped Downlink Internal traffic on Ue:${SA_UE_ID} UpfId:1 Pdu:1 Qfi:1 TrfId:4
    Execute Egate Command    ue_pdu_session_release ue=${SA_UE_ID} pdu=1    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${SA_UE_ID} ue_deregister_type=switch_off    UE CONTEXT RELEASE COMPLETE

Teardown Of Ue Deregister
    Ue_Deregister_With Traffic_Stop_And_Pdu_Session_Release
    Common Test Teardown And Stop Capture Logs Aic

Send A3 MR Then HO
    [Arguments]    ${event_id}=A3
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${SA_UE_ID}    carrierfreq=636576    event_type=${event_id}
    ${cmd}    Set Variable
    ...    ue_measurement_send_nr id=${SA_UE_ID} meas_id=${meas_id} event=${event_id} srsrp_nr=11 srsrq_nr=11 phycell_id=381 nrsrp_nr=30 nrsrq_nr=30
    ${ho_log}=    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    ${ho_log}    Remove Blank Character    ${ho_log}
    Should Contain    ${ho_log}    spCellConfigCommon{physCellId381
    sleep    10s    #wait for be stable
    Execute Egate Command    ue_disp state=ACTIVE    3.1

Remove Blank Character
    [Arguments]    ${str}
    ${str}=    Remove String    ${str}    ${SPACE}
    ${str}=    Remove String    ${str}    \r\n
    ${str}=    Remove String    ${str}    \n
    ${str}=    Remove String    ${str}    \x1b[K
    [Return]    ${str}


