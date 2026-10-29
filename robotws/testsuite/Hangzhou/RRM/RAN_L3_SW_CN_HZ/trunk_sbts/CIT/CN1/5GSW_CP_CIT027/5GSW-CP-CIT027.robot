*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    release-5G21A    RAN_5G    RAN_5G_TDD    CIT    CDRT    SBTS00
...               master_classicalbts_all    STATE_CONFIGURED    FR1    CN2    team-SG2    owner-cathy.mao
...               PRI-Medium    5GC000575    RRM_Mobility    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource          ../../../../resources/DevHZ5_resource.robot


*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:sgnbRelForNoHandoverEnabled=true
...    NRBTS:actMultiDrbNSA=false
...    NRBTS:timerX2DataFwdGuard=2000
...    NRBTS:timerX2UeProcGuard=2000
...    NRBTS:x2EnDcCfUpNbInfoBackOffTmr=300
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:lcrId=1


@{PM_COUNTERS_CIT027}
...    NRCELL-1:${X2_SGNB_MOD_REQ_RECEIVD}=1
...    NRCELL-1:${X2_SGNB_MOD_REQ_ACK_SNT}=1
...    NRBTS-1:${INTRA_MENB_HO_WI_PSCELL_CHNGE}=1
...    NRBTS-1:${INTRA_MENB_HO_RRC_RECONF}=1
...    NRBTS-1:${INTRA_MENB_HO_RRC_RECONF_SUCC}=1

${X2_SGNB_MOD_REQ_RECEIVD}    M55112C04001
${X2_SGNB_MOD_REQ_ACK_SNT}    M55112C04002
${INTRA_MENB_HO_WI_PSCELL_CHNGE}    M55128C00001
${INTRA_MENB_HO_RRC_RECONF}    M55128C00003
${INTRA_MENB_HO_RRC_RECONF_SUCC}    M55128C00004

*** Test Cases ***
5GSW-CP-CIT027_Verify Classical NSA TDD cmWave_Intra-MeNB LTE handover causes changing UE capabilities to change PSCell at SgNB is successful
    [Documentation]
    [Tags]    QC_47245
    clear counter files
    ENABLE ENB CELL2 ENDC
    NSA UE attached And Setup ENDC
    Start traffic and INTRA LTE HO
    Stop traffic and Detach UE    31
    check wireshark log    ${CURDIR}${/}a2a_case_cit027${/}a2a.ini    wait_string=UEContextReleaseComplete::1
    check counters    ${PM_COUNTERS_CIT027}



*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    update cfg    set_bearer id=2 ue=31 qci=9 pdn=1 ip=4.7.254.208 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
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


Enable ENB cell2 ENDC
    execute egate command    enb_cell_param enb=1 id=2 allow_endc=on

Start traffic and INTRA LTE HO
    [Arguments]    ${ue_id}=31
    execute egate command    trf_data_start id=2 ue=31 dir=dl mbps=5 trf_id=1    UDP DL TRF
    execute egate command    trf_data_start id=2 ue=31 dir=ul mbps=2 trf_id=2    UDP UL TRF
    execute egate command    ue_enb_endc_param id=31 candidate_cells_mn_hex_for_menb_ho=0B26DA810C804330
    ${ret1}    execute egate command    ue_ho id=31 ho_mode=INTRA_LTE enb=1 cell=2     Intra-eNB handover from .*ENB-1.1 to ENB-1.2 performed
    should contain    ${ret1}    Proxy (eNB 2 cell 2) reported successful RA
    should contain    ${ret1}    Dual Connectivity reconfiguration is successful
    Verify Throughput    ${ue_id}

Stop Traffic and Detach UE
    [Arguments]    ${ue_id}=31
    execute egate command    trf_data_stop ue=${ue_id} id=2 trf_id=2 dir=dl    Traffic was stopped
    execute egate command    trf_data_stop ue=${ue_id} id=2 trf_id=2 dir=ul    Traffic was stopped
    execute egate command    ue_detach id=${ue_id}    detached

Verify Throughput
    [Arguments]    ${sleep_time}=15s    ${ue_id}=31
    sleep    ${sleep_time}
    ${ul_Throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_Throughput}/1000>1.8
    ${dl_Throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_Throughput}/1000>4.5

Verify bearer stats
    execute egate command    bearer_stats id=2 ue=31 dir=dl dc_cell_group=scg
    execute egate command    bearer_stats id=2 ue=31 dir=ul dc_cell_group=all
    &{bearer_state_dl}    Ap Get Bearer Stats Info    ue=31    id=2    dir=dl    dc_cell_group=scg
    should be true    ${&{bearer_state_dl}[Total packets received]}>0
    should be true    ${&{bearer_state_dl}[Maximum packet rate]}>450
    should be true    ${&{bearer_state_dl}[Average data rate]}>4500000
    &{bearer_state_ul}    Ap Get Bearer Stats Info    ue=31    id=2    dir=ul    dc_cell_group=all
    should be true    ${&{bearer_state_ul}[Total packets received]}>0
    should be true    ${&{bearer_state_ul}[Maximum packet rate]}>180
    should be true    ${&{bearer_state_ul}[Average data rate]}>1800000

