*** Settings ***

Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_FDD    SBTS00    team-TA_Coreteam    owner-Flora.Du
...    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CXT  release-SBTS22R4
...    STATE_CONFIGURED    RAN_5G    SBTS22R3

Resource    ../resources/DevHZ5_resource.robot

*** Variables ***
${Cell_Nmuber}    6
${SA_Start_Num}    81
${NSA_Start_Num}    91

*** Test Cases ***
Verify BOO testline startup and UE attach
    [Documentation]
    ...    Verify BOO testline startup and UE attach
    [Tags]    
    [Timeout]    1 hour
    SA NSA UEs attach to 6 cells
    Release Ues    ue_type=all
    sleep    2s


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/L1B/6cells_2T4F_2N41_2N71_2N66

SA NSA UEs attach to 6 cells
    SA UE_81 attach to cell_1 1_successful      #cell_1
    NSA UE_91 attach to cell_1 successful
    Sleep    2
    SA UE_82 attach to cell_2 2_successful      #cell_2
    NSA UE_92 attach to cell_2 successful
    Sleep    2
    SA UE_83 attach to cell_11 3_successful      #cell_11
    NSA UE_93 attach to cell_11 successful
    Sleep    2
    SA UE_84 attach to cell_12 4_successful      #cell_12
    NSA UE_94 attach to cell_12 successful
    Sleep    2
    SA UE_85 attach to cell_13 5_successful      #cell_13
    NSA UE_95 attach to cell_13 successful
    Sleep    2
    SA UE_86 attach to cell_14 6_successful      #cell_14
    NSA UE_96 attach to cell_14 successful
    Sleep    2

SA UE_${ue_id} attach to cell_${cell_id} ${gateway}_successful
    sa_attach_ue    ${ue_id}    ${gateway}

NSA UE_${ue_id} attach to cell_${cell_id} successful
    nsa_attach_ue    ${ue_id}    ${cell_id}

sa_attach_ue
    [Arguments]    ${ue_id}    ${gateway}    ${cmd_regexp}=NG RM Registered
    ...    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    ${cmd_pdu_regexp}

nsa_attach_ue
    [Arguments]    ${ue_id}    ${cell_id}    ${cmd_regexp}=reported successful RA
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg    ${cmd_regexp}

Modify Cfg
    ${V1}    catenate
    ...    set_ue simulated id=81 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 
    ...    suci=0:311:489:0000:0:0:021645481 enb=2 cell=1 mode=nr
    ${V2}    catenate
    ...    set_ue simulated id=82 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645482 enb=2 cell=2 mode=nr
    ${V3}    catenate
    ...    set_ue simulated id=83 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 
    ...    suci=0:311:489:0000:0:0:021645483 enb=2 cell=11 mode=nr
    ${V4}    catenate
    ...    set_ue simulated id=84 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645484 enb=2 cell=12 mode=nr
    ${V5}    catenate
    ...    set_ue simulated id=85 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645485 enb=2 cell=13 mode=nr
    ${V6}    catenate
    ...    set_ue simulated id=86 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645486 enb=2 cell=14 mode=nr
    ${V7}    catenate    set_ue simulated id=93 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645493
    ${V8}    catenate    set_ue simulated id=94 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645494
    ${V9}    catenate    set_ue simulated id=95 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645495
    ${V10}    catenate    set_ue simulated id=96 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645496
    Update Cfg    ${V1}
    Update Cfg    ${V2}
    Update Cfg    ${V3}
    Update Cfg    ${V4}
    Update Cfg    ${V5}
    Update Cfg    ${V6}
    Update Cfg    ${V7}
    Update Cfg    ${V8}
    Update Cfg    ${V9}
    Update Cfg    ${V10}
    Update Cfg    ue_param id=93 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    set_bearer id=2 ue=93 qci=9 pdn=1 ip=4.7.254.240 default=on trf_type=internal
    Update Cfg    ue_param id=94 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    set_bearer id=2 ue=94 qci=9 pdn=1 ip=4.7.254.241 default=on trf_type=internal
    Update Cfg    ue_param id=95 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    set_bearer id=2 ue=95 qci=9 pdn=1 ip=4.7.254.243 default=on trf_type=internal
    Update Cfg    ue_param id=96 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    set_bearer id=2 ue=96 qci=9 pdn=1 ip=4.7.254.244 default=on trf_type=internal

