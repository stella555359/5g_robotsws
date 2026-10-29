*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 2DU
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    team-L3CN3_SG2    owner-wen.y.xu    release-5G19B
...    CLOUD_5GC_dRNIC_2vDU_P_AP_LOO_DC    master_vDU    vDUCNF00
Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2du/4cells_du1_2T_du2_2T

@{PARAMS_IN_SCF_CU}    @{HO}    @{NRREL}    @{A3_event}    @{SRB3}
@{PARAMS_IN_SCF_DU1}    @{DU_NRREL}    @{SSB}
@{PARAMS_IN_SCF_DU2}    @{DU_NRREL}    @{SSB}

@{HO}
...    NRBTS-1:actIntraFreqIntraGnbMobilityNSA=true

@{NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

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
...    NRBTS-1:integrityProtPrefL:nia2_128=4
...    NRBTS-1:integrityProtPrefL:nia3_128=2

@{SSB}
...    NRCELL:cbraPreamblesPerSsb=n60
...    NRCELL:rsrpThresholdSSB=11

@{DU_NRREL}
...    NRCELL/NRREL-1

@{PM_Counters}
...    NRCELL-1:NINFC:${INT_FR_PSCEL_CHA_ATT_SRB3}=1
...    NRCELL-2:NINFC:${INT_FR_PSCEL_CHA_ATT_SRB3}=1
...    NRCELL-1:NINFC:${TRA_FR_PSCEL_CH_ATTEMPT}=0
...    NRCELL-2:NINFC:${TRA_FR_PSCEL_CH_ATTEMPT}=0

${INT_FR_PSCEL_CHA_ATT_SRB3}    M55120C00501    #The number of intra gNB intra frequency PSCell change attempts with usage of NSA NR SRB3
${TRA_FR_PSCEL_CH_ATTEMPT}    M55120C00001    #The number of intra gNB intra frequency PSCell change attempts

${ue_id}    31

${carrierfreq}    636576

*** Test Cases ***
5GC000572_Intra-freq_inter-DU_handover_with_A3-RSRP-SRB3-CFRA_is_successful
    [Documentation]
    ...    1. Verify Cloud NSA TDD cmWave Intra-freq inter-DU handover with A3-RSRP-SRB3-CFRA is successful
    [Tags]
    Clear Counter Files Cu Aic    ${False}
    UE attach and traffic
    UE tigger Intra-gnb inter-DU HO from CELL1 to CELL2
    UE tigger Intra-gnb inter-DU HO from CELL2 to CELL1
    traffic data stop    ue_id=${ue_id}
#    check wireshark log aic    ${CURDIR}${/}a2a_572${/}a2a.ini    wait_string=UEContextModificationResponse::12
    check counters cu aic    ${PM_Counters}

*** Keywords ***
UE attach and traffic
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    reported successful RA
    Send Throughput
    Verify Throughput

UE tigger Intra-gnb inter-DU HO from CELL1 to CELL2
    ${A3_meas_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${A3_meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=30
    ...    nrsrq_nr=30 rs_type=ssb index=0 nrs_result=35:35:35
    Execute Egate Command    ${cmd}    SgNB Modification Confirm
    Verify Throughput

UE tigger Intra-gnb inter-DU HO from CELL2 to CELL1
    ${A3_meas_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${A3_meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=30
    ...    nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:20:59
    Execute Egate Command    ${cmd}    SgNB Modification Confirm
    Verify Throughput

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
