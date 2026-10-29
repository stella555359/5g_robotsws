*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Stop Capture Logs And Restore ENV In Test Teardown
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-DevHZ5_SG2    owner-yuhua.zhu    release-5G19B     5GC001200
Resource  ../../../../resources/DevHZ5_resource.robot


*** Variables ***
${UTE_WIRESHARK_FLAG}  ${False}
@{PARAMS_IN_SCF}    @{feature_flag}    @{RLO}
@{feature_flag}
...    NRCELL:actDynUlDataSplitMode=true
...    NRBTS-1:actMultiDrbNSA=true

@{RLO}
...    NRCELL:rlResumePathLossThreshold=159
...    NRCELL:rlResumeSinrThreshold=-199
...    NRCELL:rloSinrThreshold=299
...    NRCELL:rloPathLossThreshold=85
...    NRCELL:consecRlOThreshold=1
...    NRCELL:consecRlRThreshold=1
...    NRCELL:pucchDataDtxNumOfSamples=100
...    NRCELL:puschDataDtxNumOfSamples=100
...    NRDRB-2:nsaDrbParam:ulDataPath=ulOverLteNr_PrimaryPathOverNr
...    NRDRB-3:nsaDrbParam:ulDataPath=ulOverLteNr_PrimaryPathOverNr
...    NRDRB-4:nsaDrbParam:ulDataPath=ulOverLteNr_PrimaryPathOverNr
...    NRDRB-5:nsaDrbParam:ulDataPath=ulOverLteNr_PrimaryPathOverNr
...    NRDRB-6:nsaDrbParam:ulDataPath=ulOverLteNr_PrimaryPathOverNr
...    NRDRB-2:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRDRB-3:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRDRB-4:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRDRB-5:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRDRB-6:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRCELL:rlResumeBackOffTmr=3000

${BTS_STARTUP_RETRY}    4
@{OnlineParam}
...    NRBTS:actIntraMeNBMobility=true


*** Test Cases ***
5GSW_CP_EDA_5GC001200_PR589274_01687073_UL_Data_split_cross_with_IntraMenb_Inter_cell_HO
    [Documentation]
    ...    This case will include feature 5GC001200.The purpose of this test case is to check the gNB behavior,
    ...    when reconfigure from NR+LTE to LTEOnly due to a UL Radio Link Outage Indication
    ...    RLO happen
    ...    Add 1 SCG split bearer
    ...    RL resume happen
    ...    Check RLO/resume message in wireshark a2a log
    ...    Check rlResumeBackOffTmr in wireshark a2a log
    ...    IntraMenb Inter cell handover successfull
    ...    UL split mode refused
    [Tags]    QC_85537    Zhu Yuhua
    Activate IntraMeNBMobility    ${Online_Param}
    Ul Data Split As Expected
    Perform EN-DC SN modification procedure to add 1 SCG split bearer
    HO IntraMenb Inter cell
    UL split mode refused


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri


Modify Cfg
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=7,8,9
    Update Cfg    set_bearer id=3 ue=31 qci=8 pdn=1 preprovisioned=on filter=2 precedence=2
    ${set_cell1}    catenate    set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy=10.0.2.1:12219|10.0.2.1:8889
    ...    earfcn=2000:20000 mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off
    Update Cfg    ${set_cell1}
    ${set_cell2}    catenate    set_cell id=2 enb=1 eci=0x1234602 pci=3:1 tac=222 proxy=10.0.2.1:12229
    ...    earfcn=1400:19400 tdd_cell=on mandatory_for_activation=off
    Update Cfg    ${set_cell2}
    Update Cfg    enb_cell_param enb=1 id=1 allow_endc=on
    Update Cfg    enb_cell_param enb=1 id=2 allow_endc=on
	
Ul Data Split As Expected
    start to capture wireshark log    RLO_RLResume
    Config PHR profile
    UE_Attach   31    2
    Send And Verify Throuput    31    2    1.8    all
    Activate PHR testmode
    Verify Throuput    31    2    0    scg
	Verify UL Throuput after RLO 
    Check Wireshark Log    ${CURDIR}${/}a2a_UL_Datasplit_cross_withHO${/}RLO_RLResume.ini    name=RLO_RLResume
    ...    wait_string=UEContextModificationResponse::4


HO IntraMenb Inter cell
    start to capture wireshark log    HO_GNB
    Execute Egate Command    ue_ho id=31 ho_mode=INTRA_LTE enb=1 cell=2    reported successful RA    timeout=300
    Check Wireshark Log    ${CURDIR}${/}a2a_UL_Datasplit_cross_withHO${/}HO_GNB.ini    name=HO_GNB    
    ...    wait_string=UEContextModificationResponse::10
    Verify Throuput    31    2    0    scg
    Verify UL Throuput after RLO


UL split mode refused
#Ready enbsim to send SgnbModificationRefuse to GNB
    start to capture wireshark log    UL_Split_refuse
    Execute Egate Command    ue_testmode_set_nr id=31 testmode=phr_override action=deactivate profile_id=1 scell=5
    Sleep    100s
    Set Suite Variable    ${cmd_1}    link_x2_management_abnormal_cases id=1 partner=2 sgnb_modification_reqd_rsp=refuse
    Set Suite Variable    ${cmd_2}    sgnb_modification_reqd_cause=MISC_CauseMisc_unspecified
    Execute Egate Command    ${cmd_1} ${cmd_2}
    Execute Egate Command    ue_testmode_set_nr id=31 testmode=phr_override action=activate profile_id=1 scell=5
	...    SgNBModificationRefuse    timeout=300
    Execute Egate Command    enb_ue_dc_release ue=31 by=enb cause=MISC_CauseMisc_unspecified
    Check Wireshark Log    ${CURDIR}${/}a2a_UL_Datasplit_cross_withHO${/}UL_Split_refuse.ini    name=UL_Split_refuse
    ...    wait_string=BearerContextReleaseComplete::2


Perform EN-DC SN modification procedure to add 1 SCG split bearer
# Activate RLF, CSI Report Override, PHR Override testmodes
    start to capture wireshark log    add_bearer
    Execute Egate Command    enb_ue_dc_modify ue=31 bearer_to_add=3 by=enb cause=MISC_CauseMisc_unspecified type=split_scg
    ...    SgNBReconfigurationComplete    timeout=300
    Check Wireshark Log    ${CURDIR}${/}a2a_UL_Datasplit_cross_withHO${/}add_bearer.ini    name=add_bearer
    ...    wait_string=BearerContextModificationResponse::12

	
Config PHR profile
    ${config_phr}    catenate
    ...    phr_override_testmode_nr profile_id=1 phr_start=-23 phr_min=-23 phr_max=40 phr_step_size=-63
    ...    phr_period=1 pc_max=33 phr_mode=Fixed
    Execute Egate Command    ${config_phr}
    Sleep    2s

UE_Attach
    [Arguments]    ${UE_ID}=31    ${BEARER_ID}=2
    Execute Egate Command    ue_attach id=${UE_ID} profile=1    UE IS ACTIVE    timeout=300
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
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${UE_ID}     bearer_id=${BEARER_ID}    direction=ul    dc_cell_group=${dcgroup}
    ...    rate_type=ave
    Should Be True    ${ul_throuput}/1000>=${ul_throuput_expect}
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${UE_ID}     bearer_id=${BEARER_ID}    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>1.8
    Execute Egate Command    bearer_stats_clear ue=${UE_ID} id=${BEARER_ID}

Verify UL Throuput after RLO    
	Execute Egate Command    bearer_stats_clear ue=31 id=2
    &{bearStatDict}    Ap Get Bearer Stats Info    ue=31    id=2    dir=ul   dc_cell_group=scg
    Should Be True    &{bearStatDict}[Bytes sent]==0

Stop Traffic
    Execute Egate Command    trf_data_stop ue=31    pass_regexp=Traffic was stopped


Activate IntraMeNBMobility
    [Arguments]  ${Online_Param}
    Delta Commission Parameters    ${Online_Param}


UE Detach From GNB
    [Arguments]    ${expect_string}=${EMPTY}
    Execute Egate Command  ue_detach id=31    ${expect_string}

Stop Capture Logs And Restore ENV In Test Teardown
    UE Detach From GNB
    Common Test Teardown And Stop Capture Logs
