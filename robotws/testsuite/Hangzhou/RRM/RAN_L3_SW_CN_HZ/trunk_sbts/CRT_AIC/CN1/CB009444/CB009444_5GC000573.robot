*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    team-L3CN3_SG2    owner-baijie.zhu    release-5G19A
...    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC    SANSA_FS_ECPRI_CMWV_TDD_CPRI_CMWV_FDD    master_vDU    vDUCNF00    5GC000573
Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F

@{PARAMS_IN_SCF_CU}    @{HO}    @{intra_freq_inter_gnb}    @{A3_event}    @{SRB3}
@{PARAMS_IN_SCF_DU1}    @{DU_NRREL}    @{SSB}

@{HO}
...    NRBTS-1:actIntraFreqInterGnbMobilityNSA3x=true

@{intra_freq_inter_gnb}
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:fiveGsTac=0
...    NRADJNRCELL-1:freqBandIndicatorNR=78
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=35
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:removeNotAllowed=true
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    @{bandwidth_configuration}

@{bandwidth_configuration}
...    NRCELL:chBw=100MHz

@{A3_event}
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:sMeasConfigSsbRsrp=1

@{SRB3}
...    NRBTS-1:srb3SupportEnabled=true
...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=3
...    NRBTS-1:cipherPrefL:nea2_128=4
...    NRBTS-1:cipherPrefL:nea3_128=2
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9

@{SSB}
...    NRCELL:cbraPreamblesPerSsb=n60
...    NRCELL:rsrpThresholdSSB=11

@{DU_NRREL}
...    NRCELL/NRREL-1

@{PM_Counters}
...    ${X2_SGNB_CHG_REQD_SENT}=1
...    ${X2_SGNB_CHG_REF_RECEIVED}=0
...    ${X2_SGNB_CHG_CONF_RECEIVED}=1
...    ${X2_SGNB_ADD_REQ_SN_CH_RCVD}=1
...    ${X2_SGNB_ADD_REQ_ACK_SN_CH_SENT}=1
...    ${X2_SGNB_RECONF_SN_CH_RCVD}=1
...    ${X2_SGNB_RECONF_ACK_SN_CH_RCVD}=1

${X2_SGNB_CHG_REQD_SENT}             M55112C02501
${X2_SGNB_CHG_CONF_RECEIVED}         M55112C02502
${X2_SGNB_RECONF_SN_CH_RCVD}         M55112C02505
${X2_SGNB_RECONF_ACK_SN_CH_RCVD}     M55112C02506
${X2_SGNB_ADD_REQ_SN_CH_RCVD}        M55112C02503
${X2_SGNB_ADD_REQ_ACK_SN_CH_SENT}    M55112C02504
${X2_SGNB_CHG_REF_RECEIVED}          M55112C02512

${ue_id}    31

${carrierfreq}    636576

*** Test Cases ***
5GC000573_Verify_Cloud_NSA_TDD_cmWave_intra-frequency_inter-gNB_HO_with_A3_RSRP_CFRA_SRB3_is_successful
    [Documentation]
    ...    Verify Cloud NSA TDD cmWave Intra-freq inter-gNB handover with A3-RSRP-SRB3-CFRA is successful
    [Tags]    QC_277246
    Clear Counter Files Cu Aic    ${False}
    X2 Link for simulated gNB-35
    UE attach and traffic
    UE Tigger Inter-gnb HO From RealGNB to SimGNB    phycell_id=381
    UE Tigger Inter-gnb HO From SimGNB to RealGNB    phycell_id=50
    Check Throuput Counters Wireshark-log

*** Keywords ***
Modify Cfg Aic
    ${V_1}    catenate
    ...    ue_param id=31 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    ${V_2}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    ${V_4}    catenate
    ...    set_ue simulated id=31 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nea=null+zuc nia=null+zuc imsi=311:489:21645400
    Update Cfg Aic    ${V_1}
    Update Cfg Aic    gnb_set id=3 s1u=10.0.1.138 plmn=311:489 gnb_id=0x23:22 type=simulated daemon=:22222 x2=10.0.1.138:36422
    Update Cfg Aic    ${V_2}
    Update Cfg Aic    gnb_endc_param id=3 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0
    Update Cfg Aic    ${V_4}

X2 Link for simulated gNB-35
    Execute Egate Command    enb_x2_link_up enb=1 target=3
    ...    pass_regexp=is UP

UE attach and traffic
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    reported successful RA
    Send Throughput
    Verify Throughput

UE Tigger Inter-gnb HO From SimGNB to RealGNB
    [Arguments]    ${phycell_id}    ${ue_id}=31
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${V_4}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${ret1}=     Execute Egate Command
    ...    ${V_4}
    ...    pass_regexp=Sending SgNB Change Confirm

UE tigger Inter-gnb HO From RealGNB to SimGNB
    [Arguments]    ${phycell_id}    ${ue_id}=31
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Confirm

Send Throughput
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=5 trf_id=1    UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=5 trf_id=2    UDP DL

Verify Throughput
    [Arguments]    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.5
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.5

Check Throuput Counters Wireshark-log
    Verify Throughput
    traffic data stop    ue_id=${ue_id}
    check wireshark log aic    ${CURDIR}${/}a2a_573${/}a2a.ini    wait_string=UEContextModificationResponse::4
    check counters cu aic    ${PM_Counters}
