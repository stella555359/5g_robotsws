*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Stop Capture Logs And Restore ENV In Test Teardown
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CIT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-DevHZ5_SG2
...    owner-yuhua.zhu    release-5G19A     5GC001200
Resource  ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${UTE_WIRESHARK_FLAG}  ${False}
@{PARAMS_IN_SCF}
...    NRCELL-1:actDynUlDataSplitMode=true
...    NRCELL-1:rlResumePathLossThreshold=83
...    NRCELL-1:rlResumeSinrThreshold=300
...    NRCELL-1:rloConsecDtxThreshold=1
...    NRCELL-1:rloDtxRatioThreshold=1
...    NRCELL-1:consecRlOThreshold=3
...    NRCELL-1:consecRlRThreshold=1
...    NRCELL-1:rloPathLossThreshold=85
...    NRCELL-1:rloSinrThreshold=299
...    NRCELL-1:puschDataDtxNumOfSamples=100
...    NRCELL-1:pucchDataDtxNumOfSamples=100
...    NRDRB-2:nsaDrbParam:ulDataPath=ulOverNr
...    NRDRB-3:nsaDrbParam:ulDataPath=ulOverNr
...    NRDRB-4:nsaDrbParam:ulDataPath=ulOverNr
...    NRDRB-5:nsaDrbParam:ulDataPath=ulOverNr
...    NRDRB-6:nsaDrbParam:ulDataPath=ulOverNr
...    delete:NRDRB-5:nsaDrbParam:ulDataPathForUlSplitNotCapableUe
...    delete:NRDRB-6:nsaDrbParam:ulDataPathForUlSplitNotCapableUe
...    NRDRB-2:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRDRB-3:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRDRB-4:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRDRB-5:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRDRB-6:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS-1:actMultiDrbNSA=true
@{PM_Counters_Check_CIT015}
...    ${UL_DATA_SPLIT_RECONF_LTE_SUCC}=1
...    ${UL_DATA_SPLIT_RECONF_LTE_ATT}=1
...    ${NUM_MEET_UL_RL_OUTAGE_THLD}>=3
${UL_DATA_SPLIT_RECONF_LTE_SUCC}    M55146C01002    #Number of UL data split mode reconfiguration completions to LTE only
${UL_DATA_SPLIT_RECONF_LTE_ATT}    M55146C01001    #Number of UL data split mode reconfiguration attempts to LTE only
${NUM_MEET_UL_RL_OUTAGE_THLD}    M55308C12001    #Number of times meet the UL RL outage thresholds
${BTS_STARTUP_RETRY}    4
@{DisableDynUlDataSplitMod}
...    NRCELL-1:actDynUlDataSplitMode=false

@{B005}
...    NRCELL-1:actDynUlDataSplitMode=true
...    NRCELL-1:rlResumeSinrThreshold=-199
...    NRCELL-1:rlResumePathLossThreshold=159

*** Test Cases ***
5GSW_CP_CIT015_Verify_Classical_NSA_TDD_cmWave_UE_UL_data_traffic_is_reconfigured_from_NR_only_to_LTE_only
    [Documentation]
    ...    This case will include feature 5GC001200.The purpose of this test case is to check the gNB behavior,
    ...    when reconfigure from NR to LTEOnly due to a UL Radio Link Outage Indication
    ...    RLO happen
    ...    Check counters
    ...    Add 1 SCG split bearer
    ...    Disable DynUlDataSplitMod and Attach new UE successfully
    ...    RL resume happen
	[Tags]    QC_61711    Zhu Yuhua
	Ul Data Split As Expected    RLO
	Check Counters    ${PM_Counters_Check_CIT015}
	Perform EN-DC SN modification procedure to add 1 SCG split bearer
	Attach new UE after disable DynUlDataSplitMod
	#Ul Data resume As Expected
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri


Modify Cfg
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=7,8,9
	Update Cfg    set_bearer id=3 ue=31 qci=8 pdn=1 preprovisioned=on filter=2 precedence=2
	
	
Ul Data Split As Expected
    [Arguments]    ${pcap_name}
    start to capture wireshark log    ${pcap_name}
    Config PHR profile
    UE_Attach   31    2
    Send And Verify Throuput    31    2    1.8    all
    Verify UL Throuput on scg before RLO
    Activate PHR testmode
    Verify Throuput    31    2    0    scg
    Verify UL Throuput after RLO
    Check Wireshark Log    ${CURDIR}${/}a2a_CIT015${/}RLO.ini    name=RLO
    ...    wait_string=BearerContextModificationResponse::16

Attach new UE after disable DynUlDataSplitMod
    Online modification    ${DisableDynUlDataSplitMod}
	UE_Attach    32    2
	Send And Verify Throuput    32    2    1.8    all
    

Ul Data resume As Expected
    Execute Egate Command    ue_testmode_set_nr id=31 testmode=phr_override action=deactivate profile_id=1 scell=5
    Sleep    100s
	Release Ues    ue_type=all
    Online modification    ${B005}
	Ul Data Split As Expected    RLResume
	Check Wireshark Log    ${CURDIR}${/}a2a_CIT015${/}RLResume.ini    name=RLResume
    ...    wait_string=UEContextModificationResponse::8
	
Config PHR profile
    Clear Counter Files
    ${config_phr}    catenate
    ...    phr_override_testmode_nr profile_id=1 phr_start=-23 phr_min=-23 phr_max=40 phr_step_size=-63
    ...    phr_period=1 pc_max=33 phr_mode=Fixed
    Execute Egate Command    ${config_phr}
    Sleep    2s

UE_Attach
    [Arguments]    ${UE_ID}=31    ${BEARER_ID}=2
    Execute Egate Command    ue_attach id=${UE_ID}    UE IS ACTIVE    timeout=300
    Execute Egate Command    enb_endc_param id=1 serving_cell_index_range_scg=5:31
    Execute Egate Command
    ...    ue_dc_enb_start ue=${UE_ID} target_gnb=2 target_cells=1 bearer=${BEARER_ID} type=split_scg
    ...    Successfully reconfigured dual connectivity    timeout=20s

Activate PHR testmode
    Execute Egate Command    ue_testmode_set_nr id=31 testmode=phr_override action=deactivate profile_id=1 scell=5
    Sleep    100s
    Execute Egate Command    ue_testmode_set_nr id=31 testmode=phr_override action=activate profile_id=1 scell=5
	...    SgNBModificationConfirm    timeout=300


Send And Verify Throuput
    [Arguments]    ${UE_ID}    ${BEARER_ID}    ${ul_throuput_expect}    ${dcgroup}
    Execute Egate Command    data_trf_start ue=${UE_ID} id=2 dir=dl mbps=2 trf_id=2    UE ${UE_ID}: UDP DL
    Execute Egate Command    data_trf_start ue=${UE_ID} id=2 dir=ul mbps=2    UE ${UE_ID}: UDP UL
    Verify Throuput    ${UE_ID}    ${BEARER_ID}    ${ul_throuput_expect}    ${dcgroup}


Verify Throuput
    [Arguments]    ${UE_ID}    ${BEARER_ID}    ${ul_throuput_expect}    ${dcgroup}    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${UE_ID}     bearer_id=${BEARER_ID}    direction=ul    dc_cell_group=${dcgroup}    rate_type=ave
    Should Be True    ${ul_throuput}/1000>=${ul_throuput_expect}
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${UE_ID}     bearer_id=${BEARER_ID}    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>1.8
	
Verify UL Throuput after RLO    
	Execute Egate Command    bearer_stats_clear ue=31 id=2
    &{bearStatDict}    Ap Get Bearer Stats Info    ue=31    id=2    dir=ul   dc_cell_group=scg
    Should Be True    &{bearStatDict}[Bytes sent]==0

Verify UL Throuput on scg before RLO
    &{bearStatDict}    Ap Get Bearer Stats Info    ue=31    id=2    dir=ul   dc_cell_group=scg
    Should Be True    &{bearStatDict}[Bytes sent]>0

Stop Traffic
    Execute Egate Command    trf_data_stop ue=31    pass_regexp=Traffic was stopped

UE Detach From GNB
    [Arguments]    ${expect_string}=${EMPTY}
    Execute Egate Command  ue_detach id=31    ${expect_string}

Stop Capture Logs And Restore ENV In Test Teardown
    UE Detach From GNB
    Common Test Teardown And Stop Capture Logs


Perform EN-DC SN modification procedure to add 1 SCG split bearer
# Activate RLF, CSI Report Override, PHR Override testmodes
    start to capture wireshark log    add_bearer
    Execute Egate Command    enb_ue_dc_modify ue=31 bearer_to_add=3 by=enb cause=MISC_CauseMisc_unspecified type=split_scg
    ...    SgNBReconfigurationComplete    timeout=300
    Check Wireshark Log    ${CURDIR}${/}a2a_CIT015${/}add_bearer.ini    name=add_bearer
    ...    wait_string=BearerContextModificationResponse::12


Online modification
    [Arguments]  ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
