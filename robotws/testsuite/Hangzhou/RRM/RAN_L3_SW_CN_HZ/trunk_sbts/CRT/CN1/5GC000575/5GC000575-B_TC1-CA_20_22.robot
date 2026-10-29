*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CRT    SBTS00    master_classicalbts_all
...               STATE_CONFIGURED    FR1    CN2    team-SG2    owner-cathy.mao    release-5G21A
...               PRI-Medium    5GC000575    RRM_Mobility    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource          ../../../../resources/DevHZ5_resource.robot


*** Variables ***
@{PARAMS_IN_SCF}
...    @{NEIGHBOR_INFO}
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:sgnbRelForNoHandoverEnabled=true
...    NRBTS:actMultiDrbNSA=false
...    NRBTS:timerX2DataFwdGuard=2000
...    NRBTS:timerX2UeProcGuard=2000
...    NRBTS:waitForRecovBeforeCellBarringTimer=300
...    NRBTS:x2EnDcCfUpNbInfoBackOffTmr=300

@{NEIGHBOR_INFO}
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=78
...    NRBTS/NRADJNRCELL-1:gNbId=35
...    NRBTS/NRADJNRCELL-1:nrarfcn=636666
...    NRBTS/NRADJNRCELL-1:physCellId=381
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=31
...    NRBTS/NRADJNRCELL-2:lcrId=11
...    NRBTS/NRADJNRCELL-2:nrarfcn=636666
...    NRBTS/NRADJNRCELL-2:physCellId=383
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=${EMPTY}
...    NRBTS/NRADJNRCELL-3:cellDepType=NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:gNbId=4
...    NRBTS/NRADJNRCELL-3:lcrId=2
...    NRBTS/NRADJNRCELL-3:nrarfcn=2071591
...    NRBTS/NRADJNRCELL-3:physCellId=384
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=${EMPTY}
...    NRCELL-1/NRHOIF-1:cellDepType=NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=261
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:ssbFrequency=2071387
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRREDRT-1:redirFreqNr=636666
...    NRCELL-1/NRREL-1:gNbId=35
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-11:gNbId=31
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:gNbId=4
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1:actCceSplit=false
...    NRCELL-1:actCsiMeasEthFlowControl=PastTputBased
...    NRCELL-1:actPrachMultiplexing=false
...    NRCELL-1:configuredEpsTac=4580

@{delta_for_case_b_tc1}
...    NRBTS:actMultiDrbNSA=true

@{PM_COUNTERS_case20}
...    NRBTS-1:${INTRA_MENB_HO_RRC_RECONF_FAIL}=1

@{PM_COUNTERS_case22}
...    NRCELL-1:${X2_SGNB_MOD_REQ_RECEIVD}=1
...    NRCELL-1:${X2_SGNB_MOD_REQ_ACK_SNT}=1
...    NRBTS-1:${INTRA_MENB_HO_RRC_RECONF_FAIL}=1

@{PM_COUNTERS_B_TC1}
...    NRCELL-1:${X2_SGNB_MOD_REQ_RECEIVD}=2
...    NRCELL-1:${X2_SGNB_MOD_REQ_ACK_SNT}=2


${X2_SGNB_MOD_REQ_RECEIVD}    M55112C04001
${X2_SGNB_MOD_REQ_ACK_SNT}    M55112C04002
${INTRA_MENB_HO_RRC_RECONF_FAIL}    M55128C00005


*** Test Cases ***
5GC000575_TC_575_CA_20_Unsuccessful Intra MenNB HO due to TDCoverall timer expiry with in IntraDU scenario
    [Documentation]        This case is to check the system behavior when TDCoverall timer expiry occurs.
    [Tags]    QC_152632
    clear counter files
    NSA UE attached And Setup ENDC
    Send Tput And Verify Bearer Stats
    Tigger MeNB Failure Due to TDCoverall-expiry
    Stop Traffic and Detach UE
    check wireshark log    ${CURDIR}${/}a2a_case20${/}a2a.ini    wait_string=UEContextReleaseComplete::1
    check counters    ${PM_COUNTERS_case20}


5GC000575_TC_575_CA_22_Unsuccessful Intra MeNB HO due to RRCReConfigurationComplete with Reject cause in intra DU scenario
    [Documentation]        This case is to check for the system behavior when RRCReconfiguration Complete Reject is received.
    [Tags]    QC_152636
    clear counter files
    NSA UE attached And Setup ENDC
    Trigger MeNB Failure due to SCG configuration rejection
    Detach UE
    check wireshark log    ${CURDIR}${/}a2a_case22${/}a2a.ini     wait_string=UEContextReleaseComplete::1
    check counters    ${PM_COUNTERS_case22}

5GC000575_B_TC_1_verify SgNB Modification support to get SCG configuration from SgNB after basic call setup
    [Documentation]         This case is to check that SgNB shall support SCG query when initated by MeNB post L3 call.
    ...    EDA_PR569019: add DRB after msg SgNBModificationRequest.
    [Tags]    QC_152617
    clear counter files
    OnlineParamChange    ${delta_for_case_b_tc1}
    NSA UE attached And Setup ENDC
    Trgger SCG Query
    check bearer stats and detach UE
    check wireshark log    ${CURDIR}${/}a2a_case_b_tc1${/}a2a.ini    wait_string=UEContextReleaseComplete::1
    check counters    ${PM_COUNTERS_B_TC1}



*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    update cfg    set_bearer id=2 ue=31 qci=9 pdn=1 ip=4.7.254.208 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    update cfg    set_bearer id=3 ue=31 qci=8 pdn=1 preprovisioned=on filter=2 precedence=2
    update cfg    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7
    update cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    update cfg    set_cell id=2 enb=1 eci=0x1234602 pci=3:1 tac=222 proxy=10.0.2.1:12229 earfcn=2000:20000 mapped_earfcn=4200:22200
    ${cell2_gnb}    catenate    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    update cfg    ${cell2_gnb}

NSA UE attached And Setup ENDC
    [Arguments]    ${ue_id}=31
    execute egate command    state_sim_disp
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2
    Execute Egate Command    ue_change_location id=31 cell=1 enb=1
    execute egate command    enb_endc_param id=1 reset
    execute egate command    sim_debug_log level=0 mme=1
    execute egate command    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7
    UE Attach To Enb Cell1    ue_id=31
    Initial Endc Setup    ue_id=31    target_gnb=2    target_cells=1    bearer_id=2

Initial Endc Setup
    [Arguments]    ${ue_id}=31    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=1
    ${ret1}=    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    Proxy \\(eNB 2 cell 1\\) reported successful RA    timeout=20s
    Should Contain    ${ret1}    Successfully reconfigured dual connectivity

UE Attach To Enb Cell1
    [Arguments]    ${ue_id}=31
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

Send Tput And Verify Bearer Stats
    execute egate command    trf_data_start ue=31 id=2 dir=dl mbps=2 trf_id=2    pass_regexp=UDP DL TRF
    execute egate command    bearer_stats id=2 ue=31 dir=dl type=l3 trf_id=2    Average packet interval
    sleep    3s    #wait traffic stable
    &{bearer_state_dl}    Ap Get Bearer Stats Info    ue=31    id=2    dir=dl    type=l3    trf_id=2
    should be true    ${&{bearer_state_dl}[Total packets received]}>0
    should be true    ${&{bearer_state_dl}[Total packets sent]}>0
    should be true    ${&{bearer_state_dl}[Maximum packet rate]}>180
    should be true    ${&{bearer_state_dl}[Average data rate]}>1800000
    should be true    ${&{bearer_state_dl}[Total packets sent]}-${&{bearer_state_dl}[Total packets received]}<100


Tigger MeNB Failure Due to TDCoverall-expiry
    [Arguments]    ${ue_id}=31
    execute egate command    enb_endc_param id=1 menb_failure_scenario=dont_send_sgnb_reconf_complete
    ${ret1}=    Execute Egate Command    ue_reauth id=${ue_id}    pass_regexp=Bearer-type change from SCG-split to MCG is successful
    should contain    ${ret1}    Proxy (eNB 2 cell 1) reported successful RA
    should contain    ${ret1}    Dual Connectivity reconfiguration is successful
    should contain    ${ret1}    Intra-cell handover (key refresh) performed at ENB-1.1
    should contain    ${ret1}    radioNetwork : tDCoverall-expiry
    should contain    ${ret1}    REAUTHENTICATION PROCEDURE IS COMPLETED
    should not contain    ${ret1}    SgNBReconfigurationComplete


Stop Traffic and Detach UE
    [Arguments]    ${ue_id}=31
    execute egate command    trf_data_stop ue=${ue_id} id=2 trf_id=2 dir=dl    Traffic was stopped for 1 bearers
    Detach UE    ue_id=31


Trigger MeNB Failure due to SCG configuration rejection
    [Arguments]    ${ue_id}=31
    execute egate command    enb_endc_param id=1 menb_failure_scenario=send_sgnb_reconf_complete_failure
    ${ret1}=    Execute Egate Command    ue_reauth id=${ue_id}    pass_regexp=Failed reauthentication procedure with cause 3    timeout=20s
    should contain    ${ret1}    radioNetwork : mCG-Mobility
    should contain    ${ret1}    reject-by-MeNB-SgNBReconfComp
    should contain    ${ret1}    Modification is aborted by SgNB Release Request, Partial Reset or timeout on SgnbReconfigurationComplete
    should contain    ${ret1}    Bearer-type change from SCG-split to MCG is successful

Trgger SCG Query
    [Arguments]    ${ue_id}=31    ${bearer_id}=3
    execute egate command    enb_ue_dc_modify ue=${ue_id} by=enb cause=RN_mCG_Mobility scg_config_query=on    Sending SgNB Modification Request
    ${ret1}    execute egate command    enb_ue_dc_modify ue=${ue_id} bearer_to_add=${bearer_id} by=enb cause=RN_mCG_Mobility type=split_scg
    ...    pass_regexp=SgNBReconfigurationComplete
    should contain    ${ret1}    radioNetwork : mCG-Mobility
    should contain    ${ret1}    Successfully reconfigured dual connectivity


Detach UE
    [Arguments]    ${ue_id}=31
    execute egate command    ue_detach id=${ue_id}   detached

check bearer stats and detach UE
    [Arguments]    ${ue_id}=31
    execute egate command    bearer_disp ue=31 at=enb
    detach ue

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir
