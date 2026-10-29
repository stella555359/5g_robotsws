*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CONFIGS_L2PS_WRO/2_RU_2_CELL_LOKI_AB_7262/TDD_ECPRI_FDD_CPRI/iphy_and_scfc.yaml
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
# 22R1 is not planned, 22R2 branch will be handled in future

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Library      ../../resources/Python/webem_alarms.py
Library      CB007262_keywords.py

Suite Setup       Run Keywords    Start Default Logging And Reach OnAir    lua_cfg_filepath=${CURDIR}/config/egate_2c_tdd_fdd.cfg
...               output_dirpath=${OUTPUT_DIR}/suite_setup_logs
...               AND   Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs


Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
@{CELLS_LIST}=                        1                  2
@{CELL_TECHNOLOGY_TDD_FDD}            TDD                FDD
@{ENABLED_ENABLED}                    enabled            enabled

*** Test Cases ***
CB007262_A_2_Full_ABIO_Deployment_NR_FR1_TDD_Loki_A_NR_FR1_FDD_Loki_B_FDD_CPRI_TDD_eCPRI_SA_L3_Call_Both_Cells
    Check Cells Parameter Values
    ...    cell_ids=@{CELLS_LIST}
    ...    parameter=technology
    ...    expected_values=@{CELL_TECHNOLOGY_TDD_FDD}
    Check Cells Are In Correct State    cell_ids=@{CELLS_LIST}    search_key=operationalState    cells_status=@{ENABLED_ENABLED}
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    cmd=set_pdu_param ue=2 pdu=2 trf_type=internal
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=5
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=5
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=2    pdu_id=2    gw_id=2
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=2 pdu=2 dir=dl mbps=5
    ...    pass_regexp=UE2: Started Downlink Internal traffic Receiver on Ue:2 Pdu:2 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=2 pdu=2 dir=ul mbps=5
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:2 UpfId:1 Pdu:2 Qfi:1 TrfId:1
    sleep    20s
    Verify Tput For UE SA    ue_id=1    pdu=1    qfi=1    dir=dl    unit=M    expected_tput=4.8
    Verify Tput For UE SA    ue_id=1    pdu=1    qfi=1    dir=ul    unit=M    expected_tput=4.8
    Verify Tput For UE SA    ue_id=2    pdu=2    qfi=1    dir=dl    unit=M    expected_tput=4.8
    Verify Tput For UE SA    ue_id=2    pdu=2    qfi=1    dir=ul    unit=M    expected_tput=4.8
    Stop All Data Transfers UE SA

CB007262_A_5_Full_ABIO_Deployment_NR_FR1_TDD_Loki_A_NR_FR1_FDD_Loki_B_FDD_CPRI_TDD_eCPRI_NSA_L3_Call_Both_Cells
    Attach Ue To Enb And Start Gnb Addition    ue_id=11   target_cells=1
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=5
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=ul mbps=5
    sleep    10s
    Attach Ue To Enb And Start Gnb Addition    ue_id=12    target_cells=2
    Execute Egate Command    cmd=trf_data_start id=2 ue=12 dir=dl mbps=5
    Execute Egate Command    cmd=trf_data_start id=2 ue=12 dir=ul mbps=5
    sleep    20s
    Verify Tput For UE NSA    ue_id=11    id=2    dir=dl    unit=M    expected_tput=4.8
    Verify Tput For UE NSA    ue_id=11    id=2    dir=ul    unit=M    expected_tput=4.8
    Verify Tput For UE NSA    ue_id=12    id=2    dir=dl    unit=M    expected_tput=4.8
    Verify Tput For UE NSA    ue_id=12    id=2    dir=ul    unit=M    expected_tput=4.8
    Stop All Data Transfers UE NSA

*** Keywords ***
Verify Tput For UE SA
    [Arguments]   ${ue_id}    ${pdu}    ${qfi}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Sa    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} > ${expected_tput}

Verify Tput For UE NSA
    [Arguments]   ${ue_id}    ${id}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Nsa    ue_id=${ue_id}    id=${id}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} > ${expected_tput}

Attach Ue To Enb And Start Gnb Addition
    [Arguments]    ${ue_id}    ${target_cells}
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure
    ...    ue=${ue_id}
    ...    target_cells=${target_cells}
    ...    target_gnb=2
    ...    bearer=2
    ...    dc_type=split_scg

Stop All Data Transfers UE SA
    Execute Egate Command    cmd=trf_data_stop ue=2 pdu=2
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1

Stop All Data Transfers UE NSA
    Execute Egate Command    cmd=trf_data_stop id=2 ue=12
    Execute Egate Command    cmd=trf_data_stop id=2 ue=11

