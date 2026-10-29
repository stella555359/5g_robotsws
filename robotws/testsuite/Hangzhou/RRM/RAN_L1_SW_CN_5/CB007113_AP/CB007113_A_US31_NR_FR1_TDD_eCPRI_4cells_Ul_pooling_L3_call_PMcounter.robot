*** Settings ***
Documentation
...    Author: Huang Shujun
...    Contact: shujun.j.huang@nokia-sbell.com
...    Feature: CB006915_A
...    Release: 23R3

Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    5G_RAN_TDD    RAN_5G    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    SBTS00    SBTS23R1    CRT    QL3    QCD_MN_RAN    QCP_RAN_RF
...    claire.gao@nokia-sbell.com
Resource    ../resources/Airphone/Airphone_resource.robot

*** Variables ***
@{ALLOWED_FAULT}

*** Test Cases ***
CB007113_A_US31_NR_FR1_TDD_Intra_L1_subpool_UL_PRB_Pooling_for_Symmetric_L1_Pool_eCPRI_ASOE_PMcounter
    [Documentation]
    ...    This case is to verify ASOE eCPRI 4cells L3 call with 7113 UL pooling activate.
    [Tags]    LOKI    L1CRT    ASOE     airphone    CB007113
    Ue Attach to 4cells
    Start 5G L3 call and verify for UL and DL
    Check PM counter
    UE stop data transfer and detach

*** Keywords ***

Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/4cells_ecpri

Ue Attach to 4cells
    ue_register    ue_id=1    cell_id=1
    ue_register    ue_id=2    cell_id=2
    ue_register    ue_id=3    cell_id=3
    ue_register    ue_id=4    cell_id=4

Start 5G L3 call and verify for UL and DL
    traffic_start_and_throughput_verify    ue_id=1    dl_mbps=100    ul_mbps=100
    traffic_start_and_throughput_verify    ue_id=2    dl_mbps=200    ul_mbps=100
    traffic_start_and_throughput_verify    ue_id=3    dl_mbps=300    ul_mbps=100
    traffic_start_and_throughput_verify    ue_id=4    dl_mbps=400    ul_mbps=100

UE stop data transfer and detach
    traffic_data_stop   ue_id=1
    traffic_data_stop   ue_id=2
    traffic_data_stop   ue_id=3
    traffic_data_stop   ue_id=4
    release_ues    ue_id=1-4

Check PM counter
    Clear Counter files
    ${pm_counters}    Create List    NRCELL-1:M55308C10006    NRCELL-2:M55308C10006    NRCELL-3:M55308C10006    NRCELL-4:M55308C10006
    ...    NRCELL-1:M55308C10002    NRCELL-2:M55308C10002    NRCELL-3:M55308C10002    NRCELL-4:M55308C10002
    ${M55308C10006_c1}    ${M55308C10006_c2}    ${M55308C10006_c3}    ${M55308C10006_c4}
    ...    ${M55308C10002_c1}    ${M55308C10002_c2}    ${M55308C10002_c3}    ${M55308C10002_c4}    get_counters_value    ${pm_counters}
    ${PRBs_available_PUSCH_c1} =    Run Keyword And Return Status    Should Be True    ${M55308C10006_c1}>=19500000
    ${PRBs_used_PUSCH_c1} =    Run Keyword And Return Status    Should Be True    ${M55308C10002_c1}>=15000000
    ${PRBs_available_PUSCH_c2} =    Run Keyword And Return Status    Should Be True    ${M55308C10006_c2}>=19500000
    ${PRBs_used_PUSCH_c2} =    Run Keyword And Return Status    Should Be True    ${M55308C10002_c2}>=15000000
    ${PRBs_available_PUSCH_c3} =    Run Keyword And Return Status    Should Be True    ${M55308C10006_c3}>=19500000
    ${PRBs_used_PUSCH_c3} =    Run Keyword And Return Status    Should Be True    ${M55308C10002_c3}>=15000000
    ${PRBs_available_PUSCH_c4} =    Run Keyword And Return Status    Should Be True    ${M55308C10006_c4}>=19500000
    ${PRBs_used_PUSCH_c4} =    Run Keyword And Return Status    Should Be True    ${M55308C10002_c4}>=15000000
    Run Keyword If    not ${PRBs_available_PUSCH_c1} or not ${PRBs_used_PUSCH_c1}    Fail    The UL pooling PM counter can not match.
    Run Keyword If    not ${PRBs_available_PUSCH_c2} or not ${PRBs_used_PUSCH_c2}    Fail    The UL pooling PM counter can not match.
    Run Keyword If    not ${PRBs_available_PUSCH_c3} or not ${PRBs_used_PUSCH_c3}    Fail    The UL pooling PM counter can not match.
    Run Keyword If    not ${PRBs_available_PUSCH_c4} or not ${PRBs_used_PUSCH_c4}    Fail    The UL pooling PM counter can not match.
