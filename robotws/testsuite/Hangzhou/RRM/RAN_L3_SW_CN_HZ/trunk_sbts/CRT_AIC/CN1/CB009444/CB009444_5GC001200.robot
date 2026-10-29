*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    master_vDU    RAN_5G    RAN_Aic    CRT
...    CLOUD_5GC_dRNIC_1vDU_O_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    owner-jianfen.shen    release-5G23R3    team-DevHZ5_SG02    vDUCNF00

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F
${NSA_UE_ID}    31
@{PARAMS_IN_SCF_CU}    @{5GC001200CU_full}
@{PARAMS_IN_SCF_DU1}    @{5GC001200DU_full}
@{DELTA_PARAMS_IN_SCF_DU}    @{5GC001200DU_delta}

@{5GC001200CU_full}
...    NRBTS/NRDRB-2:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-2:nsaDrbParam:ulDataSplitThreshold=infinity

@{5GC001200DU_full}
...    NRBTS/NRCELL-1:actDynUlDataSplitMode=true
...    NRBTS/NRCELL-1:consecRlOThreshold=1
...    NRBTS/NRCELL-1:consecRlRThreshold=1
...    NRBTS/NRCELL-1:pucchDataDtxNumOfSamples=100
...    NRBTS/NRCELL-1:puschDataDtxNumOfSamples=100
...    NRBTS/NRCELL-1:rlResumePathLossThreshold=83
...    NRBTS/NRCELL-1:rlResumeSinrThreshold=300
...    NRBTS/NRCELL-1:rloConsecDtxThreshold=1
...    NRBTS/NRCELL-1:rloDtxRatioThreshold=1
...    NRBTS/NRCELL-1:rloPathLossThreshold=85
...    NRBTS/NRCELL-1:rloSinrThreshold=299

@{5GC001200DU_delta}
...    NRBTS/NRCELL-1:actDynUlDataSplitMode=false

###counter on CU
${UL_DATA_SPLIT_RECONF_LTE_SUCC}    M55146C01002    #Number of UL data split mode reconfiguration completions to LTE only
${UL_DATA_SPLIT_RECONF_LTE_ATT}    M55146C01001    #Number of UL data split mode reconfiguration attempts to LTE only
@{PM_Counters_Check_CU}
...    NRCELL-1:NRBC:${UL_DATA_SPLIT_RECONF_LTE_SUCC}=1
...    NRCELL-1:NRBC:${UL_DATA_SPLIT_RECONF_LTE_ATT}=1

###counter on DU
###1200 counter
${NUM_MEET_UL_RL_OUTAGE_THLD}    M55308C12001    #Number of times meet the UL RL outage thresholds

@{PM_Counters_Check_DU}
...    NRCELL-1:NCELA:${NUM_MEET_UL_RL_OUTAGE_THLD}>=1


*** Test Cases ***
CB009444-ET_5GC001200_Verify_UE_UL_data_traffic_is_reconfigured_from_NR_only_to_LTE_only_is_successful
    [Documentation]
    ...    1. The purpose of this test case is to:
    ...        a. check the gNB behavior when reconfigure from NR to LTEOnly due to a UL Radio Link Outage Indication. -5GC001200
    ...    2. Test Case Steps:
    ...         a. active 1200 related NIDDs in full commission
    ...         b. config UL Radio Link Outage parameters via egate command
    ...         c. NSA UE attach and start traffic
    ...         d. activate CSI Report Override, PHR Override testmodes
    ...         e. NSA UE detach
    ...         f. deactivate DynUlDataSplitMode
    ...         g. NSA UE attach and start traffic
    ...    3. Expected Results:
    ...         Step c: NSA UE attach successfully and traffic should be OK
    ...         Step d: trigger SgNBModificationConfirm, UL traffic is switch from 5G to 4G and DL traffic is still in 5G
    ...         Step e: NSA UE detach successfully
    ...         Step f: delta commisonn on CU and DU successfully
    ...         Step g: NSA UE attach successfully and traffic should be OK, check no drx setup
    ...         check counters on CU: M55146C01001, M55146C01002
    ...         check counters on DU: M55308C12001, M55308C11001, M55308C11002
    [Tags]    QC_278713
    Clear Counter Files
    Config PHR Profile At Enb Side
    NSA UE Attach and Traffic
    Activate PHR Testmode
    Check UL Traffic Split To LTE And DL Traffic Still In 5G
    Check WireShark Log Aic    a2a_ini_file=${CURDIR}/a2a_1200/a2a.ini    wait_string=UEContextModificationResponse::4
    Check Counters
    Deactivate DynUlDataSplitMod And Verify UE Attach and Traffic OK
    Release Ues    ue_id=${NSA_UE_ID}    ue_type=nsa

*** Keywords ***
Modify Cfg Aic
    ${V_1}    catenate
    ...    set_ue simulated id=${NSA_UE_ID} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g
    ...    imsi=311:489:21645431
    Update Cfg Aic    ${V_1}
    ${V_2}    catenate
    ...    ue_param id=${NSA_UE_ID} ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg Aic    ${V_2}
    Update Cfg Aic    set_bearer id=2 ue=${NSA_UE_ID} qci=9 pdn=1 ip=4.7.254.208 default=on trf_type=internal

Clear Counter Files
    Clear Counter Files Cu Aic    wait=False
    Clear Counter Files Du Aic    wait=False

Check Counters
    Check Counters Cu Aic    ${PM_Counters_Check_CU}
    Check Counters Du Aic    pm_counters_expression=${PM_Counters_Check_DU}    wait=False

Config PHR Profile At Enb Side
    Set Suite Variable    ${cmd_1}    phr_override_testmode_nr profile_id=1 phr_start=-23 phr_min=-23
    Set Suite Variable    ${cmd_2}    phr_max=40 phr_step_size=-63 phr_period=1 pc_max=33 phr_mode=Fixed
    Execute Egate Command    ${cmd_1} ${cmd_2}
    Execute Egate Command    enb_endc_param id=1 serving_cell_index_range_scg=5:31
    sleep    10s    sleep for AP command take effect

NSA UE Attach and Traffic
    [Arguments]    ${ue_id}=${NSA_UE_ID}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    pass_regexp=reported successful RA
    Send Throughput    ue_id=${ue_id}
    Verify Throughput    ue_id=${ue_id}

Send Throughput
    [Arguments]    ${ue_id}
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=5 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=5 trf_id=2    UE ${ue_id}: UDP UL

Verify Throughput
    [Arguments]    ${ue_id}    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.5
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.5
    &{BearInfoDict}    Ap Get Bearer Stats Info    ue=${ue_id}    id=2    dir=ul    dc_cell_group=scg
    Should Be True    &{BearInfoDict}[Total packets sent]>0

Activate PHR Testmode
    [Arguments]    ${ue_id}=${NSA_UE_ID}
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=phr_override action=activate profile_id=1 scell=5
    ...    pass_regexp=Sending SgNB Modification Confirm    timeout=600

Check UL Traffic Split To LTE And DL Traffic Still In 5G
    [Arguments]    ${ue_id}=${NSA_UE_ID}    ${sleep_time}=15s
    Execute Egate Command    bearer_stats_clear ue=${ue_id} id=2
    sleep    ${sleep_time}    sleep for Tput stable
    &{transmitter_stats}    Ap Get Bearer Stats Info    ue=${ue_id}    id=2    dir=ul    dc_cell_group=scg
    Should Be True    &{transmitter_stats}[Total packets sent]==0
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=mcg    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.5
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.5

Detach UE
    [Arguments]    ${ue_id}=${NSA_UE_ID}
    Release Ues    ue_id=${ue_id}    ue_type=nsa

Deactivate DynUlDataSplitMod
    Delta Commission Parameters DU    ${DELTA_PARAMS_IN_SCF_DU}

Stop Traffic
    [Arguments]    ${ue_id}=${NSA_UE_ID}
    Execute Egate Command    trf_data_stop ue=${ue_id}    pass_regexp=Traffic was stopped

Deactivate DynUlDataSplitMod And Verify UE Attach and Traffic OK
    Detach UE
    Deactivate DynUlDataSplitMod
    NSA UE Attach and Traffic
    Stop Traffic
