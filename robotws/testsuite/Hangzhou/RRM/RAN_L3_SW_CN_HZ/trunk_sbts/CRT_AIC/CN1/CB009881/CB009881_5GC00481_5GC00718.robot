*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_Aic    master_vDU    CRT    owner-jianfen.shen
...    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC    SANSA_FS_ECPRI_CMWV_TDD_CPRI_CMWV_FDD    release-5G23R3    team-DevHZ5_SG02    vDUCNF00

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F
${SA_UE_ID}    1
@{PARAMS_IN_SCF_CU}
@{PARAMS_IN_SCF_DU1}


*** Test Cases ***
CB009881-ET_5GC000481_718_Verify_Cloud_gNB_SA_TDD_cmWave_lock_then_unlock_cell_is_successful
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    lock/unlock cell, and check ue released after cell locked, and ue can re-register after cell unlocked.
    ...    2. Test Case Steps:
    ...       a. UEs register to cell1 and cell2
    ...       b. Lock Cell1
    ...       c. Unlock Cell1 and re-register UE1~UE3
    ...    3. Expected Results:
    ...       a: UE1~UE3 register on CELL1. UE4~UE7 register on Cell2
    ...       b: UE1~UE3 detached, and UE4~UE7 active
    ...       c: UE1~UE3 re-register successful
    [Tags]    QC_278595
    UEs Register To Cell1 And Cell2
    UEs On Cell1 Are Released After Lock Cell1
    Unlock Cell1 And Re-register UEs
    Release Ues    ue_type=sa

*** Keywords ***
UEs Register To Cell1 And Cell2
    FOR    ${ue_id}    IN RANGE    1    4
        Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
        UE Register To Cell Successfully And Traffic OK    ue_id=${ue_id}
    END
    FOR    ${ue_id_2}    IN RANGE    4    8
        Execute Egate Command    ue_change_location id=${ue_id_2} enb=2 cell=2
        UE Register To Cell Successfully And Traffic OK    ue_id=${ue_id_2}
    END

UE Register To Cell Successfully And Traffic OK
    [Arguments]    ${ue_id}=${SA_UE_ID}
    SA UE Register And PDU Setup    ue_id=${ue_id}
    Send Throughput    ue_id=${ue_id}
    Verify Throughput    ue_id=${ue_id}

Send Throughput
    [Arguments]    ${ue_id}=${SA_UE_ID}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 protocol=udp mbps=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=2 protocol=udp mbps=5    UE ${ue_id}: UDP UL

Verify Throughput
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Throughput stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.6
    Should Be True    ${ul_throuput}/1000>4.6
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps

SA UE Register And PDU Setup
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=1    QoS Routing Table

UEs On Cell1 Are Released After Lock Cell1
    delta commission parameters du    NRCELL-1:administrativeState=Locked
    Execute Egate Command    disp_ue id=1    OFF
    Execute Egate Command    disp_ue id=2    OFF
    Execute Egate Command    disp_ue id=3    OFF
    Execute Egate Command    disp_ue id=4    ACTIVE
    Execute Egate Command    disp_ue id=5    ACTIVE
    Execute Egate Command    disp_ue id=6    ACTIVE
    Execute Egate Command    disp_ue id=7    ACTIVE

Unlock Cell1 And Re-register UEs
    delta commission parameters du    NRCELL-1:administrativeState=Unlocked
    cells should be onair du    timeout=300
    FOR    ${ue_id}    IN RANGE    1    4
        UE Register To Cell Successfully And Traffic OK    ue_id=${ue_id}
    END
