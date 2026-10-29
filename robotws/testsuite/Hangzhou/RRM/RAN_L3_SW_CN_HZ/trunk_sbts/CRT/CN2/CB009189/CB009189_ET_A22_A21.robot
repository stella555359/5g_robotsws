*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-kexin.bao
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    CB009189    release-SBTS23R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=9
...    NRBTS-1:actMultiDrbNSA=true
...    @{2271_related_modification}
...    @{9189_related_modification}
...    @{HO_flag}
...    @{intra_freq_intra_DU_TDD}
...    @{pscell_change_configuration}

@{2271_related_modification}
...    NRCELL:actAdaptiveSr=true
...    NRCELL:adaptiveSrBlockingMinimization=20
...    NRCELL:adaptiveSrLoadThresholdDown=50
...    NRCELL:adaptiveSrLoadThresholdUp=80
...    NRCELL-1:srPeriodicity=slots20
...    NRCELL-2:srPeriodicity=slots80
...    NRCELL:srPeriodicityMin=slots20
...    NRCELL-2:srPeriodicityMin=slots40
...    NRCELL-1:srPeriodicityMin=slots10
...    NRCELL:vonrReservation=30
...    NRCELL-2:preferredVoNrSrPeriod=slots40
...    NRCELL-11:preferredVoNrSrPeriod=slots20
...    NRCELL-12:preferredVoNrSrPeriod=slots20
...    NRCELL-13:preferredVoNrSrPeriod=slots20
...    NRCELL-14:preferredVoNrSrPeriod=slots20
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL-1:actEnhancedVoNR=false
...    delete:NRCELL-1:preferredVoNrSrPeriod

@{9189_related_modification}
...    NRCELL:actServiceAwareConfig=true
#qci=6
...    NRBTS/NRDRB-3:srPeriodicityDrb=20ms
...    NRBTS/NRDRB-3:payloadSizeSRDrb=500

@{HO_flag}
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true

@{intra_freq_intra_DU_TDD}
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrpConsolidation=0
...    NRCELL:sMeasConfigSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=8
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=2
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1/NRREL-1:gNbId=3
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=3
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-2/NRREL-1:gNbId=3
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=3
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

@{pscell_change_configuration}
...    NRBTS:tDCoverall=10000
...    NRBTS:timerX2UeProcGuard=15000
...    NRBTS/NRADJNRCELL-1:cellDepType=NSA
...    NRBTS/NRADJNRCELL-1:gNbId=3
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=3
...    NRBTS/NRADJNRCELL-1:nrarfcn=518580
...    NRBTS/NRADJNRCELL-1:physCellId=381
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    delete:NRBTS/NRADJNRCELL-1:freqBandIndicatorNR

@{OnlineParam_for_A021}
...    NRBTS/NRDRB-6:srPeriodicityDrb=20ms
...    NRBTS/NRDRB-6:payloadSizeSRDrb=800
...    NRBTS/NRDRB-8:srPeriodicityDrb=40ms
...    NRBTS/NRDRB-8:payloadSizeSRDrb=500
...    NRBTS:srb3SupportEnabled=true

*** Test Cases ***

CB009189-ET-A22_NSA_TDD_DRBsl10_add_9189DRBsl40_intergNB_pscell_change_A3_TDD_wo_SRB3
    [Documentation]
    ...    1. This user scenario describes NSA Intra-frequency pscell change after
    ...    successfully configure periodicity and possibly grant size for Scheduling Request per DRB profile.
    ...    2. Configuration
    ...    5GC002271 feature is enabled,and CB009189 flag is enabled.
    ...    NRREL is configured for NRCELL-1.
    ...    NRADJNRCELL-1 is configured as sim gNB.
    ...    3. Test Case Steps:
    ...    a.UE attach on NRCELL-1, and check SR period selection.
    ...    b.setup QCI=6, check SR period selection.
    ...    c.send A3 measurement, pscell change to simGNB and HO back to NRCELL-2 successfully,then check SR period selection.
    ...    d.UE detach.
    [Tags]    QC_221959    owner-kexin.bao
    Set UE Parameters Before Attach
    UE Attach    ue_id=91    target_gnb=2    target_cells=1    bearer_id=2    regexp=periodicityAndOffset sl10
    Setup Bearer    ue_id=91    bearer_id=4    regexp=periodicityAndOffset sl20
    Pscell Change    ue_id=91    carrierfreq_1=518910    carrierfreq_2=518910    event_id=A3    phycell_id_1=381    phycell_id_2=51
    ...    regexp=periodicityAndOffset sl40     bearer_id=4
    UE Detach    ue_id=91
    Check RRC log    ${CURDIR}${/}a2a_CB009189A022${/}a2a.ini

CB009189-ET-A21_NSA_TDD_9189DRBsl40_add_9189DRBsl80_intergNB_pscell_change_A5_FDD_w_SRB3
    [Documentation]
    ...    1. This user scenario describes NSA Intra-frequency pscell change after
    ...    successfully configure periodicity and possibly grant size for Scheduling Request per DRB profile.
    ...    2. Configuration
    ...    5GC002271 feature is enabled,and CB009189 flag is enabled.
    ...    NRREL is configured for NRCELL-2.
    ...    NRADJNRCELL-1 is configured as sim gNB.
    ...    3. Test Case Steps:
    ...    a.UE attach on NRCELL-2, and check SR period selection.
    ...    b.setup QCI=70, check SR period selection.
    ...    c.send A3 measurement, pscell change to simGNB and HO back to NRCELL-11 successfully,then check SR period selection.
    ...    d.UE detach.
    [Tags]    QC_221960    owner-kexin.bao
    OnlineParamChange    ${OnlineParam_for_A021}
    Set UE Parameters Before Attach
    UE Attach    ue_id=91    target_gnb=2    target_cells=2    bearer_id=2    regexp=periodicityAndOffset sl40
    Setup Bearer    ue_id=91    bearer_id=7    regexp=schedulingRequestToAddModList
    Pscell Change    ue_id=91    carrierfreq_1=518910    carrierfreq_2=424090    event_id=A3    phycell_id_1=381    phycell_id_2=60
    ...    regexp=periodicityAndOffset sl20    bearer_id=7
    UE Detach    ue_id=91
    Check RRC log    ${CURDIR}${/}a2a_CB009189A021${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

Modify Cfg
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    set_bearer id=2 ue=91 qci=9 pdn=1 ip=4.7.254.209 default=on trf_type=internal
    Update Cfg    set_bearer id=3 ue=91 qci=5 pdn=1
    Update Cfg    set_bearer id=4 ue=91 qci=6 pdn=1
    Update Cfg    set_bearer id=5 ue=91 qci=7 pdn=1
    Update Cfg    set_bearer id=6 ue=91 qci=8 pdn=1
    Update Cfg    set_bearer id=7 ue=91 qci=70 pdn=1

    Update Cfg    gnb_set id=3 s1u=10.0.1.122 plmn=311:489 gnb_id=0x3 type=simulated daemon=10.0.2.1:22222 x2=10.0.1.122:36422 x2_peers=none
    Update Cfg    gnb_param id=3 x2_listening_socket=1 measEvent=A3
    ${cell_381}    Catenate    set_cell id=3 gnb=3 tac=200 pci=127:0 proxy=10.0.2.1:12221|10.0.2.1:8891 nrci=0x1 nr_arfcn=518580:518580
    ...    gscn=6486 tdd_cell=on mandatory_for_activation=off
    Update Cfg    ${cell_381}
    ${enb}    Catenate    set_enb id=1 plmn=311:489 s1=10.0.1.121 enb_id_macro=0x12346 daemon=10.0.2.1:22222 x2=10.0.1.12 x2u=10.0.1.136
    ...    type=simulated x2_peers=none
    Update Cfg    ${enb}
    ${gnb2}    Catenate    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 gnb_id=0x2:22 x2=10.0.1.2:36422 x2_peers=none ng=10.0.1.2
    ...    xn=10.0.1.2 amf=1 nssai=0x1:0xd143a5
    Update Cfg    ${gnb2}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Set UE Parameters Before Attach
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2
    Execute Egate Command    enb_x2_link_up enb=1 target=3    ENB-1: X2AP Link with GNB-3

UE Attach
    [Arguments]    ${ue_id}    ${target_gnb}    ${target_cells}    ${bearer_id}    ${regexp}
    Execute Egate Command    ue_attach id=${ue_id} profile=1    UE IS ACTIVE
    ${retvalue}    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    Successfully reconfigured dual connectivity
    Should Contain    ${retvalue}    ${regexp}
    Send And Verify Nsa Throuput    ${ue_id}    ${bearer_id}    sleep_time=10s

Verify Throuput
    [Arguments]    ${ue_id}    ${bearer_id}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=${bearer_id}    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=${bearer_id}    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throughput}/1000>9
    Should Be True    ${ul_throughput}/1000>9

Send And Verify Nsa Throuput
    [Arguments]    ${ue_id}=91    ${bearer_id}=2    ${sleep_time}=10s
    Execute Egate Command    data_trf_start ue=${ue_id} id=${bearer_id} dir=dl mbps=10    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=${bearer_id} dir=ul mbps=10    UE ${ue_id}: UDP UL
    Verify Throuput    ${ue_id}    ${bearer_id}    ${sleep_time}

UE Detach
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_detach id=${ue_id}    UE${ue_id}: detached    timeout=10s

Setup Bearer
    [Arguments]    ${ue_id}    ${bearer_id}    ${regexp}
    Execute Egate Command    bearer_add ue=${ue_id} id=${bearer_id} filter=0 precedence=0    drb-ToAddModList
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_add=${bearer_id} by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    ...     ${regexp}
    Send And Verify Nsa Throuput    ue_id=${ue_id}    bearer_id=${bearer_id}    sleep_time=10s

Pscell Change
    [Arguments]    ${ue_id}    ${carrierfreq_1}    ${carrierfreq_2}    ${event_id}    ${phycell_id_1}    ${phycell_id_2}    ${regexp}    ${bearer_id}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq_1}    event_type=${event_id}
    ${cmd}    Set Variable
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_id} srsrp_nr=20 phycell_id=${phycell_id_1} nrsrp_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=Successfully reconfigured dual connectivity
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq_2}    event_type=${event_id}
    ${cmd}    Set Variable
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_id} srsrp_nr=20 phycell_id=${phycell_id_2} nrsrp_nr=80
    ${retvalue}    Execute Egate Command    ${cmd}    pass_regexp=Successfully reconfigured dual connectivity
    Should Contain    ${retvalue}    ${regexp}
    Verify Throuput    ue_id=${ue_id}    bearer_id=${bearer_id}    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    bearer_id=2    sleep_time=10s
