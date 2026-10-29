*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]    team-CN1ET
...    owner-christine.chen    owner-zora.wang    release-SBTS23R4    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{HO_PARAMS}
...    @{A3_PARAMS_FOR_GNB1}
...    @{8281}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_CA_rel_for_NRCELL_1}
...    @{HO_PARAMS}
...    @{A3_PARAMS_FOR_GNB2}
...    @{8281}

@{8281}
...    NRCELL:actUlNrEcIdPosMethod=true
...    NRBTS:nrEcidMeasSupervisionTimer=6500
...    NRBTS:timerRRCGuard=2000

@{HO_PARAMS}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIncXn=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:actIntraFreqHoSA=true
...    MRBTS/NRBTS/NRPMRNL-1:miNrRelReportCu=5min

...    NRBTS:actIntraNrNgHo=sourceAndTarget
...    NRBTS:tNgRelocExecDeltN=3000
...    NRBTS:tNgRelocPrepN=2000
...    NRBTS:tNgRelocOverallN=2000
...    NRBTS:tNgRelocCancelN=2000

@{A3_PARAMS_FOR_GNB1}
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:absThreshSsbRsrqConsolidation=1
...    NRCELL-1:sMeasConfigSsbRsrp=1

...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=39
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0

...    NRCELL-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    NRCELL-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRCELL-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40

@{A3_PARAMS_FOR_GNB2}
...    NRCELL-3:absThreshSsbRsrpConsolidation=1
...    NRCELL-3:absThreshSsbRsrqConsolidation=1
...    NRCELL-3:sMeasConfigSsbRsrp=1
...    NRCELL-3:a3MeasEnabled=rsrp
...    NRCELL-3:a1MeashoEnabledSA=rsrp
...    NRCELL-3:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-3:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=39
...    NRCELL-3:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480

...    NRCELL-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0

...    NRCELL-3:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    NRCELL-3:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRCELL-3:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40

@{PARAMS_FOR_GNB1}
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL:chBw=40MHz

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=663400
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=4
...    NRBTS/NRADJNRCELL-4:nrarfcn=648000
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-4:physCellId=53
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=2
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=153400
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3

...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-3:chBw=40MHz
...    NRCELL-4:chBw=40MHz
...    NRCELL-3:nrarfcn=663400
...    NRCELL-3:gscnOrSsPbchArfcn=8159
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:measGapSelectionSA=favourUeThroughput

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRCELL:timingAdvanceOffset=n25600

@{GNB2_CA_rel_for_NRCELL_1}
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:lcrId=1

@{online_A019}
...    NRCELL-1/NRREL-3:handoverAllowedSA=XnHoNotAllowed

@{recover_A019}
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed

@{ECID_Failure_and_XN_HO_success}
...    Received ECID Measurement Failure
...    Inter-eNB handover from EXT_ENB-3.3 to EXT_ENB-2.1 performed
...    PATH SWITCH REQUEST ACK

@{ECID_Failure_and_NG_HO_success}
...    Received ECID Measurement Failure
...    from EXT_ENB-2.1 to EXT_ENB-3.3 performed
...    NgLink::OnReceiveUeContextReleaseComplete

@{PM_Counters_A026}
...    NRCELL-3:NNGCC:${NRPPA_MEASINIT_REQ_D}=1
...    NRCELL-3:NNGCC:${NRPPA_MEASINIT_RESP_D}=1

${NRPPA_MEASINIT_REQ_D}    M55125C00024
#Num of DL UE-associated NRPPA transport messages with E-CID measurement initiation requests for Reporting Type "On-Demand" per NR cell.
${NRPPA_MEASINIT_RESP_D}    M55125C00025
#Num of UL UE-associated NRPPA transport messages with E-CID measurement initiation response for Reporting Type "On-Demand" per NR cell.

*** Test Cases ***
CB008281-ET-A026_Verify the E-CID MR when a Intra-Freq Inter-gNB HO event reported from UE while waiting for the E-CID MR
    [Documentation]
    ...    This case is to Verify the E-CID Measurement Reporting when a handover event/event A2 triggering redirection reported
    ...    from UE while waiting for the E-CID Measurement Report
    ...    [Configuration]:
    ...    a.SA,TDD
    ...    b.Configured actUlNrEcIdPosMethod=true, nrEcidMeasSupervisionTimer=6500, timerRRCGuard=2000
    ...    c.Intra-Frequency Inter-gNB neihbour cell configured.
    ...    d.Intra-Frequency Event A3/A5 triggering Intra-Frequency Inter-gNB handover
    ...    3. Test Case Steps:
    ...    a. setup SA call
    ...    b. LMF sends E-CID MEASUREMENT INITIATION REQUEST with Report Characteristics IE set to 'On-Demand' and Measurement Quantity requested
    ...    is 'SS-RSRP & SS-RSRQ'.
    ...    c. while waiting for the MeasurementReport for the E-CID Measurement Quantities, gnb received Measurement Event Intra-Frequency MR.
    ...    d. UE send E-CID Measurement report is ignore, UE is HO to cell1
    ...    e. normal HO back should be ok.
    [Tags]    QC_303346    christine.chen    A026
    Clear counter
    UE attach cell    enb_id=3    cell_id=3
    Send Throuput and check Throuput
    Trigger intra-freq handover and interGNB handover should successed
    UE Deregister From gNB
    Check WireShark Log    ${CURDIR}${/}A2A_A_026${/}a2a.ini    wait_string=UEContextRelease::8
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_A_026${/}a2a_gnb2.ini    wait_string=UEContextRelease::18
    check Counters GNB2    ${PM_Counters_A026}    wait=True

CB008281-ET-A019_Verify the handling of E-CID MEASUREMENT INITIATION REQUEST while outgoing Intra-Frequency Inter-gNB handover is in progress
    [Documentation]
    ...    1.This case is to Verify the handling of E-CID MEASUREMENT INITIATION REQUEST while outgoing handoverNote2/Note4
    ...    is in progress or coverage based blind redirection is in progressNote3.
    ...    2.[Configuration]:
    ...    a.SA,TDD
    ...    b.Configured actUlNrEcIdPosMethod=true, nrEcidMeasSupervisionTimer=6500, timerRRCGuard=2000
    ...    c.Intra-Frequency Inter-gNB neihbour cell configured.
    ...    d.Intra-Frequency Event A3/A5 triggering Intra-Frequency Inter-gNB handover
    ...    3. Test Case Steps:
    ...    a. setup SA call on gnb3 cell3.
    ...    b. delay RRCReconfigurationComplete 1s and then trigger Inter-gnb Intra-Frequency MR.
    ...    c. while waiting for RRCReconfigurationComplete,LMF sends E-CID MEASUREMENT INITIATION REQUEST with Report Characteristics IE set
    ...    to 'On-Demand' and Measurement Quantity requested is 'SS-RSRP & SS-RSRQ'.
    ...    d. Received ECID Measurement Failure, UE is HO to gnb2 cell1.Then deregister ue.
    ...    e. online change NRCELL-1/NRREL-3:handoverAllowedSA=XnHoNotAllowed.then setup SA call on gnb2 cell1.
    ...    g. delay RRCReconfigurationComplete 1s and then trigger Inter-gnb Intra-Frequency MR.
    ...    h. while waiting for RRCReconfigurationComplete,LMF sends E-CID MEASUREMENT INITIATION REQUEST with Report Characteristics IE set
    ...    to 'On-Demand' and Measurement Quantity requested is 'SS-RSRP & SS-RSRQ'.
    ...    i. Received ECID Measurement Failure, UE is HO to gnb3 cell3.Then deregister ue.
    [Tags]    QC_303345    A019    zora.wang
    UE attach cell    enb_id=3    cell_id=3
    Send Throuput and check Throuput
    delay RRCReconfigurationComplete then trigger Intra-Frequency Inter-gNB handover
    trigger E-CID Measurement Initiation request and received ECID Measurement Failure    pass_regexp=${ECID_Failure_and_XN_HO_success}
    UE Deregister From gNB
    OnlineParamChange    ${online_A019}
    UE attach cell    enb_id=2    cell_id=1
    Send Throuput and check Throuput
    delay RRCReconfigurationComplete then trigger Intra-Frequency Inter-gNB handover    phycell_id=52
    trigger E-CID Measurement Initiation request and received ECID Measurement Failure    pass_regexp=${ECID_Failure_and_NG_HO_success}
    UE Deregister From gNB
    Check WireShark Log    ${CURDIR}${/}A2A_A019${/}a2a.ini    wait_string=UEContextRelease::25
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_A019${/}a2a_gnb2.ini    wait_string=UEContextRelease::16
    [Teardown]    A019_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Modify Cfg
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh

Trigger intra-freq handover and interGNB handover should successed
    [Arguments]    ${ue_id}=1
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...     delay=4000 srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40
    Execute Egate Command    ${cmd}    pass_regexp=send this meas report
    ${cmd1}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=1 lmf_ue_measurement_id=1 report_characteristics=OnDemand
    ...    meas_qty=SS-RSRP,SS-RSRQ
    Execute Egate Command    ${cmd1}    pass_regexp=rrcReconfigurationComplete
    Handover Should Success
    sleep    7s    sleep for HO interval
    Handover back Should Success

Clear counter
    Clear Counter Files    wait=${False}
    Clear Counter Files GNB2

Handover Should Success
    [Arguments]    ${event_id}=A3    ${phycell_id}=50
    ${meas_id}    Get the measurement id    ${event_id}
    ${cmd}    Set Variable
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=${event_id} srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from EXT_ENB-3.3 to EXT_ENB-2.1 performed
    Execute Egate Command    ue_disp state=ACTIVE    pass_regexp=2.1

Handover back Should Success
    [Arguments]    ${event_id}=A3    ${phycell_id}=52
    ${meas_id}    Get the measurement id    ${event_id}
    ${cmd}    Set Variable
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=${event_id} srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to EXT_ENB-3.3 performed
    Execute Egate Command    ue_disp state=ACTIVE    pass_regexp=3.3

Get the measurement id
    [Arguments]    ${event_id}=A3
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=1    carrierfreq=663360    event_type=${event_id}
    [Return]    ${meas_id}

UE attach cell
    [Arguments]    ${ue_id}=1    ${enb_id}=3    ${cell_id}=3
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table

Send Throuput and check Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    pass_regexp=UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=10 trf_id=2    pass_regexp=UE ${ue_id}: UDP DL
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput for cell    ue_id=1

Verify Throuput for cell
    [Arguments]    ${ue_id}=1    ${dl}=8    ${ul}=8    ${pdu_id}=1
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000 >${dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached    timeout=10s

trigger E-CID Measurement Initiation request and received ECID Measurement Failure
    [Arguments]    ${ue_id}=1    ${meas_qty}=SS-RSRP,SS-RSRQ    ${tid}=1    ${pass_regexp}=Received ECID Measurement Failure
    ${cmd}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=${tid} lmf_ue_measurement_id=${tid}
    ...    report_characteristics=OnDemand meas_qty=${meas_qty}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

delay RRCReconfigurationComplete then trigger Intra-Frequency Inter-gNB handover
    [Arguments]    ${event_id}=A3    ${phycell_id}=50
    ${meas_id}    Get the measurement id    ${event_id}
    ${cmd}    Set Variable
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=${event_id} srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ue_nr_rrc_reconf_param id=1 if_contains=any delay=1000
    Execute Egate Command    ${cmd}    pass_regexp=Hit on error cases presence=any action=delay

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

A019_Teardown
    OnlineParamChange    ${recover_A019}
    Common Test Teardown And Stop Capture Logs
