*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-jing.ye
...    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    5GC000732-I    release-5G22R2
...    STATE_CONFIGURED    RAN_5G    RAN_5G_FDD
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
@{PARAMS_IN_SWCONFIG}    ${timerRRCGuard}=8500
@{PARAMS_IN_SCF}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRBTS-1:timerRRCGuard=6000
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{CA_FT_Config}

@{CA_FT_Config}
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:sCellActivationMethod=blind
...    NRBTS-1:actLteNrDss=false
...    NRBTS-1/NRDU-1:actInterNumerologyCa=true
...    NRBTS-1/NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa
...    NRBTS-1/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms

${timerRRCGuard}    0x59012A
${reconfigurationFailure}     reconfigurationFailure
${ue_id}    81
${pdu_id}    1
${gw_id}    1
${BTS_STARTUP_RETRY}    4

*** Test Cases ***
5GC000732_ET_I020_rrcreestablishmentrequest_incoming_during_coverBased_scell_addition_procedure_abort_then_process
    [Documentation]
    ...    1. This user scenario describes the concurrency table for reestablishment.
    ...    2. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 11.
    ...         b. Trigger hold RRC reconfiguration complete during scell addition procedure for 5s.
    ...         c. Trigger coverBased scell addition.
    ...         d. Trigger RRC reestablishment request to cell 1.
    ...         e. Scell addition is abort, RRC reestablishment is successfully.
    [Tags]    QC_167127    owner-jing.ye    I020
    UE Attach To Cell11   ue_id=${ue_id}   pdu_id=${pdu_id}   gw_id=${gw_id}
    Send And Verify Throuput
    Trigger hold RRC reconfiguration complete
    Trigger Scell Addition
    Trigger RRC reestablishment to cell1    ${reconfigurationFailure}
    Verify Throuput
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732I020${/}a2a.ini

5GC000732_ET_I021_rrcreestablishmentrequest_incoming_during_coverBased_scell_release_procedure_abort_then_process
    [Documentation]
    ...    1. This user scenario describes the concurrency table for reestablishment.
    ...    2. Test Case Steps:
    ...         a. UE registers successfully  and PDU session is setup successfully on cell 11.
    ...         b. CoverBased scell addition is successfully.
    ...         c. Trigger hold RRC reconfiguration complete during scell release procedure for 5s.
    ...         d. Trigger coverBased scell release.
    ...         e. Trigger RRC reestablishment request to cell 11.
    ...         f. Scell release is abort, RRC reestablishment is successfully.
    [Tags]    QC_167126    owner-jing.ye    I021
    UE Attach To Cell11    ue_id=${ue_id}   pdu_id=${pdu_id}   gw_id=${gw_id}
    Send And Verify Throuput
    Scell Addition Should Be Successful
    Trigger hold RRC reconfiguration complete
    Trigger Scell Release
    Trigger RRC reestablishment to cell11    ${reconfigurationFailure}
    Verify Throuput
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732I021${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/L1B/6cells_2T4F

UE Attach To Cell11
    [Arguments]   ${ue_id}  ${pdu_id}   ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=11
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=1    QoS Routing Table

Trigger RRC reestablishment to cell1
    [Arguments]   ${RRC_cause}
    ${ret1}=     Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1 cause=${RRC_cause}
    ...    rrcReconfigurationComplete    timeout=30s

Trigger RRC reestablishment to cell11
    [Arguments]   ${RRC_cause}
    ${ret1}=     Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=11 cause=${RRC_cause}
    ...    rrcReconfigurationComplete    timeout=30s

Trigger hold RRC reconfiguration complete
    ${ret1}=     Execute Egate Command    ue_param id=${ue_id} reestablishing_state_timeout=9s
    ${ret1}=     Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=5000

Trigger Scell Addition
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} event=A1 meas_id=1 srsrp_nr=112 srsrq_nr=40
    ...    Hit on error cases presence=any action=delay    timeout=5s

Scell Addition Should Be Successful
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} event=A1 meas_id=1 srsrp_nr=112 srsrq_nr=40
    ...    SCellIndex 1 activated successfully at airphone    timeout=5s

Trigger Scell Release
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A2 scell=1 scell_rsrp=30
    ...    Hit on error cases presence=any action=delay    timeout=5s

Verify Throuput
    [Arguments]    ${Tput_dl}=63    ${Tput_ul}=9.5    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10
    Verify Throuput

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

