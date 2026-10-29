*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    owner-flora.du    team-DevHZ5_SG2
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5GC000704-C    STATE_CONFIGURED    release-5G19A
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${DEBUG_LOG_LEVEL}    0
${UTE_WIRESHARK_FLAG}    True

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
...    NRADJNRCELL-1:ssbFrequency=636576
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

@{PARAMS_TO_UPDATE_LENGTH}
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbIdLength=22

@{PARAMS_TO_RECOVERED_LENGTH}
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNbIdLength=24
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbIdLength=24
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbIdLength=24

@{DELETE_HO_NIDD}
...    delete:XNLINK-1
...    delete:NRADJGNB-1

@{RECOVE_HO_NIDD}
...    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddr=10.0.1.124
...    MRBTS-1/NRBTS-1/NRADJGNB-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNbIdLength=24
...    MRBTS-1/NRBTS-1/NRADJGNB-1:xnLinkRef=1
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mncLength=3

@{PARAMS_TO_ADD_BLACKLIST}
...    NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-1:pciExcludeList:pciRangeValidity=SA
...    NRBTS-1/NRCELL-1:pciExcludeList:physCellId=381
...    NRBTS-1/NRCELL-1:pciExcludeList:range=n8

@{PARAMS_TO_REMOVE_BLACKLIST}
...    delete:NRCELL-1:pciExcludeList

${XN_RESET_REQUEST_SENT_Number}    M55126C00012
${XN_RESET_RESPONSE_RECEIVED}    M55126C00013
${XN_RESET_OPER}    M55126C00026

@{PM_Counters_Check_EDA}
...    ${XN_RESET_REQUEST_SENT_Number}=1
...    ${XN_RESET_RESPONSE_RECEIVED}=1
...    ${XN_RESET_OPER}=1

@{PARAMS_IN_SWCONFIG}    0x340002=1    0x340006=55153

*** Test Cases ***
EDA_PR541182_Handover_should_successed_when_difference_PLMN_gNbIdLength
    [Documentation]
    ...    This case verify HO failure after Inter-GNB gNbIdLength mis-match
    ...    Message check:
    ...    xnlink_reset_req: xnap_16_7_0_2109_n03.ResetRequestTypeInfo == 0 and xnap_16_7_0_2109_n03.procedureCode == 20,
    ...    xnlink_reset_resp: xnap_16_7_0_2109_n03.procedureCode == 20 and xnap_16_7_0_2109_n03.ResetResponseTypeInfo == 0,
    ...    sctp_shutdown: sctp.chunk_type == 7,
    ...    sctp_shutdown_ack: sctp.chunk_type == 8,
    ...    sctp_shutdown_comp: sctp.chunk_type == 14
    ...    counter:
    ...    M55126C00012==1 XN_RESET_REQUEST_SENT Number
    ...    M55126C00013==1 XN_RESET_RESPONSE_RECEIVED
    ...    M55126C00026==1 XN_RESET_OPER
    [Tags]    EDA_PR541182    QC_123301
    Delta Commission Parameters    ${PARAMS_TO_ENABLE_SA_A5_RSRQ}
    Cells Should Be Onair
    Prepare UE History Information
    UE Attach To Cell1
    Clear Counter Files
    Handover From gNB to Sim Should Success    A5
    Handover From Sim to gNB Should Success    A5
    update neighbor GNB gNbIdLength and handover should failure
    UE Deregister From gNB    ue_id=1
    [Teardown]    Recover ENV for gNbIdLength

5GC000704_C002_Verify_HO_Failure_after_Xnlink_Remove_TestCase
    [Documentation]
    ...    This case verify HO failure  after Xn(gNB) link configuration is removed
    ...    Message check:
    ...    xnlink_reset_req: xnap_16_7_0_2109_n03.ResetRequestTypeInfo == 0 and xnap_16_7_0_2109_n03.procedureCode == 20,
    ...    xnlink_reset_resp: xnap_16_7_0_2109_n03.procedureCode == 20 and xnap_16_7_0_2109_n03.ResetResponseTypeInfo == 0,
    ...    sctp_shutdown: sctp.chunk_type == 7,
    ...    sctp_shutdown_ack: sctp.chunk_type == 8,
    ...    sctp_shutdown_comp: sctp.chunk_type == 14
    ...    counter (Covered by EDA case):
    ...    M55126C00012==1 XN_RESET_REQUEST_SENT Number
    ...    M55126C00013==1 XN_RESET_RESPONSE_RECEIVED
    ...    M55126C00026==1 XN_RESET_OPER
    [Tags]    5GC000704_DELXNLINK    QC_125786
    Check Xn link available
    Delta Commission Parameters   ${PARAMS_TO_ENABLE_SA_A5_RSRQ}
    Cells Should Be Onair
    Prepare UE History Information
    UE Attach To Cell1
    Delta Commission Parameters    ${DELETE_HO_NIDD}
    Trigger handover from GNB to sim should be failed    A5
    Check UE and should be on cell1
    Check Wireshark Log    ${CURDIR}${/}a2a_delxnlink${/}a2a_delxnlink.ini
    Recover the XN link and handover should successfully
    UE Deregister From gNB    ue_id=1
    [Teardown]    Recover ENV for add xnlink

5GC000704_C_TC17 Blacklisted cell marked under NIDD is not selected during Inter gNB HO
    [Documentation]
    ...    This case verify Cell add to blacklist in NIDD, the handover failed, move blacklist, and handover successed
    ...    Message check:
    ...
    [Tags]    5GC000704_C_TC17    QC_61778
    Check Xn link available
    Delta Commission Parameters    ${PARAMS_TO_ADD_BLACKLIST}
    Cells Should Be Onair
    Prepare UE History Information
    UE Attach To Cell1
    HO fails due to target cell in NIDD blacklist
    Check Wireshark Log    ${CURDIR}${/}a2a_TC017${/}a2a_tc017.ini
    Delta Commission Parameters    ${PARAMS_TO_REMOVE_BLACKLIST}
    Cells Should Be Onair
    HO succeeds due to target cell move from NIDD blacklist
    UE Deregister From gNB    ue_id=1
    [Teardown]    Recover ENV for Remove blacklist

5GC002497-A-ET-A003_SA_UE_Inter_gNB_Handover_Failure_Due_To_No_Receipt_Of_NR_Reconfiguration_Complete
    [Documentation]
    ...    This case verify Unsuccessful intra-frequency handover due to no receipt NR reconfiguration complete
    ...    Message check: UEContextRelease
    ...    xnap_16_7_0_2109_n03.procedureCode == 6
    ...    Counter check:
    [Tags]    5GC002497_A003    QC_61790
    Delta Commission Parameters    ${PARAMS_TO_ENABLE_SA_A5_RSRQ}
    Cells Should Be Onair
    Prepare UE History Information
    UE Attach To Cell1
    Handover From gNB to Sim Should Success    A5
    Start To Capture Wireshark Log    norrc_pcap
    Set UE RRC Reconf Param to Not Response for the RRC Reconfiguration
    Trigger A5 Rsrq measurement and HO Should Fail
    Check Wireshark Log    ${CURDIR}${/}a2a_norrc${/}a2a_norrc.ini    name=norrc_pcap
    [Teardown]    Recover ENV for no RRC and release UE

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

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
    Check Xn link available

Check Xn link available
    BuiltIn.Log    check expect xnlink setup as expect    console=${True}
    Object Should Exist    XNLINK-1:xnLinkStatus=available

Check xnLink should be unavailable
    BuiltIn.Log    check expect xnlink setup as expect    console=${True}
    Object Should Exist    XNLINK-1:xnLinkStatus=unavailable

update neighbor GNB gNbIdLength and handover should failure
    Start To Capture Wireshark Log    EDA_pcap
    Update the neighbor GNB gNbIdLength
    Check xnLink should be unavailable
    Handover From gNB to Sim Should failed when Xn link down
    Check UE and should be on cell1
    Check Wireshark Log    ${CURDIR}${/}a2a_EDA${/}a2a_EDA.ini    name=EDA_pcap
    Check Counters    ${PM_Counters_Check_EDA}
    Recovered the neighbor GNB gNbIdLength

UE Attach To Cell1
    Execute Egate Command    ue_change_location id=1 enb=2 cell=1
    Execute Egate Command    ue_register id=1    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1    pass_regexp=QoS Routing Table

Handover From gNB to Sim Should failed when Xn link down
    Trigger handover from GNB to sim should be failed    A5

Trigger handover from GNB to sim should be failed
    [Arguments]    ${event_id}=A5
    ${meas_id}    Get the measurement id    ${event_id}
    ${a5_rsrq_cmd}    Set Variable
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=${event_id} srsrp_nr=11 srsrq_nr=11 phycell_id=381 nrsrp_nr=40 nrsrq_nr=40
    Execute Egate Command    ${a5_rsrq_cmd}    fail_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    UE${ue_id}: detached

Check UE and should be on cell1
    Execute Egate Command    ue_disp state=ACTIVE    2.1


Update the neighbor GNB gNbIdLength
    Delta Commission Parameters    ${PARAMS_TO_UPDATE_LENGTH}
    Cells Should Be Onair

Recovered the neighbor GNB gNbIdLength
    Delta Commission Parameters    ${PARAMS_TO_RECOVERED_LENGTH}
    Cells Should Be Onair
    wait until keyword succeeds    1min    10s    Check Xn link available


Recover ENV for gNbIdLength
    run keyword if test failed    Recovered the neighbor GNB gNbIdLength
    Common Test Teardown And Stop Capture Logs

Prepare UE History Information
    ${cmd_1}    Catenate    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ${cmd_1}
    ${cmd_2}    Catenate    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ${cmd_2}
    ${cmd_3}    Catenate    ue_history_information_list id=1 action=commit
    Execute Egate Command    ${cmd_3}
    ${cmd_4}    Catenate    ue_enb_param id=1 ue_history_list=1
    Execute Egate Command    ${cmd_4}  

Set UE RRC Reconf Param to Not Response for the RRC Reconfiguration
    ${cmd}    Catenate    ue_nr_rrc_reconf_param id=1 if_contains=any action=drop
    Execute Egate Command    ${cmd}
    sleep    2s    #waiting pcap

Trigger A5 Rsrq measurement and HO Should Fail
    ${meas_id}    Get the measurement id    A5
    ${a5_meas_cmd_2}    Catenate
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A5 srsrp_nr=10 srsrq_nr=10 phycell_id=50 nrsrp_nr=40 nrsrq_nr=40
    Execute Egate Command    ${a5_meas_cmd_2}    pass_regexp=UE CONTEXT RELEASE
    Sleep    3.5s    #waiting RlRecoveryTimer Timer expired
    Check Resources Leakage

HO fails due to target cell in NIDD blacklist
    Trigger handover from GNB to sim should be failed    A3
    Sleep    2s    #waiting for PCAP

HO succeeds due to target cell move from NIDD blacklist
    Sleep    2s    #starting for NIDD efforct
    Handover From gNB to Sim Should Success    A3
    Handover From Sim to gNB Should Success    A3

Recover ENV for no RRC and release UE
    UE Deregister From gNB    ue_id=1
    ${cmd}    Catenate    ue_nr_rrc_reconf_param id=1 reset
    Execute Egate Command    ${cmd}
    Common Test Teardown And Stop Capture Logs

Recover ENV for add xnlink
    run keyword if test failed    Delta Commission Parameters    ${RECOVE_HO_NIDD}
    run keyword if test failed    Cells Should Be Onair
    Common Test Teardown And Stop Capture Logs

Recover ENV for Remove blacklist
    run keyword if test failed    Delta Commission Parameters    ${PARAMS_TO_REMOVE_BLACKLIST}
    run keyword if test failed    Cells Should Be Onair
    Common Test Teardown And Stop Capture Logs

Recover the XN link and handover should successfully
    Delta Commission Parameters    ${RECOVE_HO_NIDD}
    Cells Should Be Onair
    Handover From gNB to Sim Should Success    A5
    Handover From Sim to gNB Should Success    A5

Get the measurement id
    [Arguments]    ${event_id}=A3
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency   ue_id=1    carrierfreq=636576    event_type=${event_id}
    [Return]    ${meas_id}

Handover From gNB to Sim Should Success
    [Arguments]    ${event_id}=A3
    ${meas_id}    Get the measurement id    ${event_id}
    ${cmd}    Set Variable
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=${event_id} srsrp_nr=11 srsrq_nr=11 phycell_id=381 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Execute Egate Command    ue_disp state=ACTIVE    3.1

Handover From Sim to gNB Should Success
    [Arguments]    ${event_id}=A3
    ${meas_id}    Get the measurement id    ${event_id}
    ${cmd}    Set Variable
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=${event_id} srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=40 nrsrq_nr=40
    Execute Egate Command    ${cmd}    pass_regexp=Inter-gNB Handover is triggered
    Execute Egate Command    ue_disp state=ACTIVE    2.1
