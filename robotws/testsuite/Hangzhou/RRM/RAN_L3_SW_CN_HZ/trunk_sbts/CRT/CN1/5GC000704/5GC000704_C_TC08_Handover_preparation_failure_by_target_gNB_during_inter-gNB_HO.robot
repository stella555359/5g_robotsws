*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    owner-flora.du    team-DevHZ5_SG2
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5GC000704-C    STATE_CONFIGURED    release-5G19A
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
#${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/1cell_ecpri

@{PARAMS_IN_SCF}    @{HO_PARAMS}    @{A5_PARAMS}    @{NRREL_PARAMS}    @{NRADJGNB}
...    @{NRADJNRCELL}    @{cipherPrefL}    @{XNLINK-1}    @{A3_PARAMS}

@{HO_PARAMS}
...    NRBTS-1:actConflictConfiguration=true
...    NRBTS-1:actIncXn=true

@{A3_PARAMS}
...    NRBTS-1/NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRBTS-1/NRCELL-1:absThreshSsbRsrqConsolidation=1
...    NRBTS-1/NRCELL-1:sMeasConfigSsbRsrp=1

...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0

...    NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40

@{A5_PARAMS}
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=11
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=20
...    MRBTS-1/NRBTS-1:actConflictConfiguration=false
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms320

@{NRREL_PARAMS}
...    NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL-1:gNbId=35
...    NRBTS-1/NRCELL-1/NRREL-1:gNbIdLength=24
...    NRBTS-1/NRCELL-1/NRREL-1:lcrId=1
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

@{NRADJNRCELL}
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:freqBandIndicatorNR=78
...    NRADJNRCELL-1:fiveGsTac=0
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=24
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mncLength=3

@{NRADJGNB}
...    MRBTS-1/NRBTS-1/NRADJGNB-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNbIdLength=24
...    MRBTS-1/NRBTS-1/NRADJGNB-1:xnLinkRef=1
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mncLength=3

@{XNLINK-1}
...    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddr=10.0.1.124

@{cipherPrefL}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9

@{PARAMS_TO_ENABLE_SA_A3_RSRP}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrXnCCInterface=5min

${XN_HO_REQ_SENT}    M55143C00004
${XN_HO_PREP_FAIL_RECEIVED}    M55143C00002

@{PM_Counter_HO_PREPARE_FAILURE}
...    ${XN_HO_PREP_FAIL_RECEIVED}=1
...    ${XN_HO_REQ_SENT}=1

*** Test Cases ***
5GC000704_C_TC08 Handover preparation failure by target gNB in inter-gNB HO
    [Documentation]
    ...    This case verify Handover preparation failure
    ...    Message check:
    ...    HandoverRequest,
    ...    HandoverPreparationFailure,
    ...    counter:
    ...    M55153C00001==1: HO Attempts per neighbour cell relation  ATT_HO_NRREL
    ...    M55143C00002==0: Number of incoming Handover Preparation Failure received from Target gNB FAIL_HO_NRREL_PREP
    [Tags]    5GC000704_C_TC08    QC_191599
    Delta Commission Parameters    ${PARAMS_TO_ENABLE_SA_A3_RSRP}
    Clear Counter Files
    Prepare UE History Information
    UE Attach To Cell1
    HO fails due to strongest neihgbour cell is not added in NRREL
    HO fails due to target gNB force failure
    UE Deregister From gNB    ue_id=1
    [Teardown]    Recover ENV for preparefailure and release UE

*** Keywords ***
Modify Cfg
    BuiltIn.Log    update CFG    console=${True}
    ${GNB3_CFG}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:24
    ...    daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${GNB3_CFG}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=true
    ${CELL_381}    Catenate    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    Update Cfg    ${CELL_381}

Prepare UE History Information
    ${cmd_1}    Catenate    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ${cmd_1}
    ${cmd_2}    Catenate    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ${cmd_2}
    ${cmd_3}    Catenate    ue_history_information_list id=1 action=commit
    Execute Egate Command    ${cmd_3}
    ${cmd_4}    Catenate    ue_enb_param id=1 ue_history_list=1
    Execute Egate Command    ${cmd_4}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
    Check Xn link available

UE Attach To Cell1
    Execute Egate Command    ue_change_location id=1 enb=2 cell=1
    Execute Egate Command    ue_register id=1    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1    pass_regexp=QoS Routing Table

HO fails due to target gNB force failure
    Start To Capture Wireshark Log    Preparefailure_pcap
    ${cmd}    Catenate    gnb_xn_handover_preparation_param id\=3 action=\force_failure
    Execute Egate Command    ${cmd}
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency   ue_id=1    carrierfreq=636576    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=381 nrsrp_nr=20 nrsrq_nr=20
    Execute Egate Command    ${cmd}    HandoverPreparationFailure for XnHANDOVER_REQUEST
    get_all_ues
    Check Wireshark Log    ${CURDIR}${/}a2a_C008${/}a2a_C008.ini    name=Preparefailure_pcap
    Check Counters    ${PM_Counter_HO_PREPARE_FAILURE}

Check Xn link available
    BuiltIn.Log    check expect xnlink setup as expect    console=${True}
    Object Should Exist    XNLINK-1:xnLinkStatus=available

HO fails due to strongest neihgbour cell is not added in NRREL
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency   ue_id=1    carrierfreq=636576    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=30 srsrq_nr=30
    ...    phycell_id=382 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${cmd}    pass_regexp=physCellId 382    fail_regexp=Intra-eNB handover
    Check Wireshark Log    ${CURDIR}${/}a2a_C009${/}a2a_C009.ini
    Execute Egate Command    ue_disp state=ACTIVE    2.1

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    UE${ue_id}: detached

Recover ENV for preparefailure and release UE
    ${cmd}    Catenate    gnb_xn_handover_preparation_param id=3 reset
    Execute Egate Command    ${cmd}
    Common Test Teardown And Stop Capture Logs
