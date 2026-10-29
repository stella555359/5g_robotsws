*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    CRT
...    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F

@{PARAMS_IN_SCF_CU}    @{HO}    @{intra_freq_intra_gnb}    @{A3_event}    @{SRB3}
@{PARAMS_IN_SCF_DU1}    @{DU_NRREL}    @{SSB}

@{HO}
...    NRBTS-1:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS-1:actUeInitRlf=true
...    NRBTS-1:actGnbInitRlf=true
...    NRBTS-1:tWaitingRlRecover=10000ms
...    NRPMRNL-1:miNrUeState=5min


@{intra_freq_intra_gnb}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=true
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=true
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    @{bandwidth_configuration}

@{bandwidth_configuration}
...    NRCELL:chBw=100MHz
...    NRCELL:rlfPsccTrigThresholdRsrp=30

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
...    NRBTS-1:integrityProtPrefL:nia1_128=3
#...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=4
#...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=2
#...    NRBTS-1:integrityProtPrefL:nia3_128=9

@{SSB}
...    NRCELL:cbraPreamblesPerSsb=n60
...    NRCELL:rsrpThresholdSSB=11

@{DU_NRREL}
...    NRCELL/NRREL-1

@{PM_Counters}
...    ${RLF_INITIATED_UE_PSCELL_CHANGE}=5
...    ${RLF_INITIATED_UE_T310_EXPIRY}=1
...    ${RLF_INITIATED_UE_RACH_FAIL}=1
...    ${RLF_INIT_SGNB_MAX_RLC_RETX}=0
...    ${RLF_INITIATED_UE_SCG_RECNF_F}=0
...    ${RLF_INITIATED_UE_SCG_CHGE_FAIL}=0 
...    ${RLF_INITIATED_UE_SRB_INTGRTY_F}=0

@{PM_Counters_PScell_Change}
...    ${RLF_INITIATED_UE_PSCELL_CHANGE}=1

@{PM_Counters_PScell_Release}
...    ${RLF_INITIATED_UE_T310_EXPIRY}=1

@{PM_Counters_RA_PScell_Release}
...    ${RLF_INITIATED_UE_RACH_FAIL}=1

${RLF_INITIATED_UE_PSCELL_CHANGE}        M55116C00007
${RLF_INITIATED_UE_T310_EXPIRY}          M55116C00008
${RLF_INITIATED_UE_RACH_FAIL}            M55116C00009
${RLF_INIT_SGNB_MAX_RLC_RETX}            M55116C00015
${RLF_INITIATED_UE_SCG_RECNF_F}          M55116C00013
${RLF_INITIATED_UE_SCG_CHGE_FAIL}        M55116C00012
${RLF_INITIATED_UE_SRB_INTGRTY_F}        M55116C00011

${ue_id}    31

${carrierfreq}    636576

*** Test Cases ***
CB011169_01_CNI-79164_01_NSA_Preventing_PSCELL_change_loop_due_to_RLF
    [Documentation]
    ...    Verify Cloud NSA TDD cmWave Intra-freq 
    [Tags]    CRT   CB011169    QC_32520    QCD_MN_RAN    QCP_RAN_VRF
    Clear Counter Files Cu Aic    ${False}
    X2 Link for simulated gNB-35
    UE attach and traffic    local_cell_id=1
    Trigger UE Iniated RLF for Pscell Change    failure_type=T310_expiry    
    ...    meas=05936D40864A0A0866A280
    Execute Egate Command    ue_detach id=${ue_id}    UE IS OFF
    #Trigger UE Iniated RLF for Pscell Change    phycell_id=51    failure_type=T310_expiry    
    #...    meas=05936D40864A190866A190
    sleep    12s
    UE attach and traffic    local_cell_id=1
    Trigger UE Iniated RLF for Pscell Release    failure_type=T310_expiry
    ...    meas=05936D40864A0A0866A190
    Execute Egate Command    ue_detach id=${ue_id}    UE IS OFF
    sleep    12s
    UE attach and traffic    local_cell_id=1 
    Trigger UE Iniated RLF for Pscell Release    failure_type=random_access_problem 
    ...    meas=05936D40864A190866A370
    Execute Egate Command    ue_detach id=${ue_id}    UE IS OFF
    UE attach and traffic    local_cell_id=1 
    Trigger UE Iniated RLF for Pscell Change    failure_type=rlc_max_num_retx
    ...    meas=05936D40864A190866A370
    Execute Egate Command    ue_detach id=${ue_id}    UE IS OFF
    UE attach and traffic    local_cell_id=1 
    Trigger UE Iniated RLF for Pscell Change    failure_type=synch_reconfiguration_failure_scg
    ...    meas=05936D40864A190866A370
    Execute Egate Command    ue_detach id=${ue_id}    UE IS OFF
    UE attach and traffic    local_cell_id=1 
    Trigger UE Iniated RLF for Pscell Change    failure_type=scg_reconfig_failure
    ...    meas=05936D40864A190866A370
    Execute Egate Command    ue_detach id=${ue_id}    UE IS OFF
    UE attach and traffic    local_cell_id=1 
    Trigger UE Iniated RLF for Pscell Change    failure_type=srb3_integrity_failure
    ...    meas=05936D40864A190866A370
    Execute Egate Command    ue_detach id=${ue_id}    UE IS OFF
    check counters cu aic    ${PM_Counters}
       

*** Keywords ***
Trigger UE Iniated RLF for Pscell Change
    [Arguments]    ${ue_id}=31    ${failure_type}=T310_expiry    ${at}=gnb    ${meas}=0583D6E4864A190866A370
    Trigger RLF    ue_id=${ue_id}    failure_type=${failure_type}    at=${at}    meas=${meas}
    ...   pass_regexp=ENB-1: UE${ue_id}: Dispatch ScgFailureInformationNR_r15 Message

Trigger UE Iniated RLF for Pscell Release
    [Arguments]    ${ue_id}=31    ${failure_type}=T310_expiry    ${at}=gnb    ${meas}=0583D6E4864A190866A370
    Trigger RLF    ue_id=${ue_id}    failure_type=${failure_type}    at=${at}    meas=${meas}
    ...   pass_regexp=Bearer-type change from SCG-split to MCG is successful

Trigger RLF
    [Arguments]    ${ue_id}    ${failure_type}    ${at}    ${meas}
    ...            ${pass_regexp}
    ${V_1}    catenate
    ...    ue_dc_rlf ue=${ue_id} failure_type=${failure_type} at=${at} meas_result_scg=${meas}
    Execute Egate Command    ${V_1}    pass_regexp=${pass_regexp}    
    Sleep    1s    reason=wait command to be executed

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
    Execute Egate Command    enb_x2_link_up enb=1 target=2
    ...    pass_regexp=is UP || is up

UE attach and traffic
    [Arguments]    ${local_cell_id} 
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE || already active
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${local_cell_id} bearer=2 type=split_scg    
    ...    reported successful RA || already an EN-DC bearer
    Send Throughput
    Verify Throughput


UE tigger PScell Change To Specific Cell
    [Arguments]    ${phycell_id}    ${ue_id}=31
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=UE${ue_id}: Sending SgNB Modification Confirm

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
