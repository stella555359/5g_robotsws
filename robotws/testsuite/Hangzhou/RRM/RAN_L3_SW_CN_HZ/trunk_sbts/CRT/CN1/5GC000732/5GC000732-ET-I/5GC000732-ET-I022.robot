*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-lena.zhuo
...    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    5GC000732-I    release-5G22R2
...    STATE_CONFIGURED    RAN_5G    RAN_5G_FDD
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRBTS-1:timerRRCGuard=6000
...    NRBTS-1:drbInactivityTimerSA=4
...    NRBTS-1:srbInactivityTimerSA=4
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

${reconfigurationFailure}     reconfigurationFailure
${ue_id}    81
${pdu_id}    1
${gw_id}    1
${BTS_STARTUP_RETRY}    4

*** Test Cases ***
5GC000732_ET_I022_BearerContextInactivityNotification_incoming_during_RRE_procedure_queue_then_activeDRB
    [Documentation]
    ...    1. This user scenario describes the concurrency table for reestablishment.
    ...    2. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 11.
    ...         b. Trigger hold RRC reconfiguration complete during RRE to cell-1.
    ...         c. Trigger DL traffic after RRE complete immediately within DRB inactivity timer.
    ...         d. Stop traffic, trigger RRE to cell-1, and hold RRC reconfiguration complete during RRE.
    ...         e. setup second PDU after RRE complete.
    [Tags]    QC_218373    owner-lena.zhuo    I022
    UE Attach To Cell11    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Trigger hold RRC reconfiguration complete
    Trigger RRC reestablishment to cell1    ${reconfigurationFailure}
    Send And Verify Throughput
    Trigger hold RRC reconfiguration complete
    Stop traffic
    Trigger RRC reestablishment to cell1    ${reconfigurationFailure}
    Second PDU setup
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732I022${/}a2a.ini    wait_string=UEContextRelease::27

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/L1B/6cells_2T4F

UE Attach To Cell11
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=11
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=1    QoS Routing Table

Trigger RRC reestablishment to cell1
    [Arguments]    ${RRC_cause}
    ${ret1}=     Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1 cause=${RRC_cause}
    ...    rrcReconfigurationComplete    timeout=10s

Trigger hold RRC reconfiguration complete
    ${ret1}=     Execute Egate Command    ue_param id=${ue_id} reestablishing_state_timeout=9s
    ${ret1}=     Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=5000

Verify Throughput
    [Arguments]    ${Tput_dl}=63    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}

Send And Verify Throughput
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=70
    Verify Throughput

UE Deregister From gNB
    [Arguments]    ${ue_id}
    sleep    5s    sleep for inactivity timer timeout
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Second PDU setup
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=1    Setup QosFlow with QFI

Stop traffic
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} trf_id=1 dir=dl
