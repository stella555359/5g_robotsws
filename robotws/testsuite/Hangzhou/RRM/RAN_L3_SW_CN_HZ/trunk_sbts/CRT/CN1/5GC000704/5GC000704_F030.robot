*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    owner-flora.du    team-DevHZ5_SG2
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5GC000704-F    STATE_CONFIGURED    release-5G19A
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
#${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cell_ecpri

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
...    NRADJNRCELL-1:fiveGsTac=200
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

@{PARAMS_TO_ENABLE_SA_A5_RSRQ}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1/NRCELL-1:a5MeasEnabled=rsrq
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min


*** Test Cases ***
5GC000704-ET-F030_Verify_SA_inter-gnb_ho_should_failed_when_match_forbiddenAreaInformation_in_MRL
    [Documentation]
    ...    This case verify SA inter-gnb handover should failed when PLMN and TAC of target cell is in
    ...    MRL(servingPlmn and forbiddenAreaInformation)
    ...    the MobilityRestrictionList in InitialContextSetupRequest message
    ...    Step: 
    ...    Step1. UE1 attach
    ...    Step2. Set forbidden TAC
    ...    Step3. UE1 handover success (forbidden TAC not effect the exist UE)
    ...    Step4: UE2 attach (forbidden TAC effect the new UE)
    ...    Step5: UE2 handover failed
    ...    Message check:
    ...    InitialContextSetupRequest: ngap.id == 36 && ngap.pLMNIdentity == 13:41:98 && ngap.TAC == 200,
    ...    measurementReport: nr-rrc.physCellId == 381 && nr-rrc.c1 == 0 && nr-rrc.physCellId == 381,
    ...    not meet message:
    ...    HandoverRequest: xnap.procedureCode == 0
    [Tags]    QC_61776
    Delta Commission Parameters    ${PARAMS_TO_ENABLE_SA_A5_RSRQ}
    Prepare UE History Information
    UE1 Attach To Cell1
    Set MRL with forbidden area information only
    UE1 handover should success	
    Start To Capture Wireshark Log    forbidden_tacs
    UE2 Attach To Cell1
    UE2 Handover From gNB to Sim Should failure
    Release UEs    ue_type=sa    ue_id=1-2
    Check WireShark Log    ${CURDIR}/a2a_F030/a2a_F030.ini    name=forbidden_tacs    wait_string=UEContextReleaseComplete::8

*** Keywords ***
Modify Cfg
    BuiltIn.Log    update CFG    console=${True}
    ${GNB3_CFG}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:24 
    ...    daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${GNB3_CFG}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=true
    ${CELL_381}    Catenate    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    Update Cfg    ${CELL_381}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
    Check Xn link available

Check Xn link available
    BuiltIn.Log    check expect xnlink setup as expect    console=${True}
    Object Should Exist    XNLINK-1:xnLinkStatus=available

UE${ue_id} Attach To Cell1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${ue_id} gw=${ue_id}    pass_regexp=QoS Routing Table

UE1 handover should success
    Handover From gNB to Sim Should Success
    Handover From Sim to gNB Should Success
    Stop capture wireshark log
	
Prepare UE History Information
    ${cmd_1}    Catenate    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ${cmd_1}
    ${cmd_2}    Catenate    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ${cmd_2}
    ${cmd_3}    Catenate    ue_history_information_list id=1 action=commit
    Execute Egate Command    ${cmd_3}
    ${cmd_4}    Catenate    ue_enb_param id=1 ue_history_list=1
    Execute Egate Command    ${cmd_4}  

Get the measurement id
    [Arguments]    ${event_id}=A3    ${ue_id}=1
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=${event_id}
    [Return]    ${meas_id}

Handover From gNB to Sim Should Success
    ${meas_id}    Get the measurement id    A5
    ${cmd}    Catenate
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=381 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Execute Egate Command    ue_disp state=ACTIVE    3.1

Handover From Sim to gNB Should Success
    ${meas_id}    Get the measurement id    A5
    ${cmd}    Catenate
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=40 nrsrq_nr=40
    Execute Egate Command    ${cmd}    pass_regexp=Inter-gNB Handover is triggered
    Execute Egate Command    ue_disp state=ACTIVE    2.1

Set MRL with forbidden area information only
    Execute Egate Command    amf_mobility_restriction_list_param id=1 fa_plmn=311:489 forbidden_tacs=200
    Execute Egate Command    amf_ics_param id=1 ue=1 mobility_restriction_list_id=1
    Execute Egate Command    amf_ics_param id=1 ue=2 mobility_restriction_list_id=1

UE2 Handover From gNB to Sim Should failure
    ${meas_id}    Get the measurement id    A5    ue_id=2    
    ${cmd}    Catenate
    ...    ue_measurement_send_nr id=2 meas_id=${meas_id} event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=381 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${cmd}    fail_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Execute Egate Command    ue_disp state=ACTIVE    2.1
