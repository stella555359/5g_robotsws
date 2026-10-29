*** Settings ***
Documentation
...    Author:  Hou Yuguo
...    Contact: yuguo.hou@nokia-sbell.com
...    Feature: CB009055
...    Release:

Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    5G_RAN_TDD    RAN_5G    CLOUD_5G_I_MP_AP_LOOO
...    SBTS00    SBTS24R1    CRT    QL3    QCD_MN_RAN    QCP_RAN_RF
Resource    ../resources/Airphone/Airphone_resource.robot

*** Variables ***
@{ALLOWED_FAULT}

*** Test Cases ***
CB009055_G1_B1_CB007113_TC07_NR_FR1_TDD_eCPRI_ABIP_Intra_L1_subpool_UL_PRB_Pooling_LoadMetric_L3Call
    [Documentation]
    ...    This case is to verify ABIP NR FR1 TDD eCPRI legacy cell sets L3call with loadMetric UL PRB pooling.
    [Tags]    LOKI    L1CRT    ABIP     airphone    CB009055-CB007113
    Ue Attach to 3 cells and data traffic
    Check PM counter
    UE stop data transfer and detach

*** Keywords ***

Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env    tl_type=AP_LOOO/tdd_sansa_cmwv/FS/3cell_ecpri    cfg=wts.cfg

Ue Attach to ${num} cells and data traffic
    FOR    ${id}    IN RANGE    ${num}
        ue_register    ue_id=${id+1}    cell_id=${id+1}
    END
    FOR    ${id}    IN RANGE    ${num}
        traffic_start_and_throughput_verify    ue_id=${id+1}    dl_mbps=300    ul_mbps=150
    END

UE stop data transfer and detach
    traffic_data_stop   ue_id=1
    traffic_data_stop   ue_id=2
    traffic_data_stop   ue_id=3
    release_ues    ue_id=1-3

Check PM counter
    Clear Counter files
    ${pm_counters}    Create List    NRCELL-1:M55308C10006    NRCELL-2:M55308C10006    NRCELL-3:M55308C10006
    ...    NRCELL-1:M55308C10002    NRCELL-2:M55308C10002    NRCELL-3:M55308C10002
    ${M55308C10006_c1}    ${M55308C10006_c2}    ${M55308C10006_c3}
    ...    ${M55308C10002_c1}    ${M55308C10002_c2}    ${M55308C10002_c3}    get_counters_value    ${pm_counters}
    ${PRBs_available_PUSCH_c1} =    Run Keyword And Return Status    Should Be True    ${M55308C10006_c1}>=19500000
    ${PRBs_used_PUSCH_c1} =    Run Keyword And Return Status    Should Be True    ${M55308C10002_c1}>=15000000
    ${PRBs_available_PUSCH_c2} =    Run Keyword And Return Status    Should Be True    ${M55308C10006_c2}>=19500000
    ${PRBs_used_PUSCH_c2} =    Run Keyword And Return Status    Should Be True    ${M55308C10002_c2}>=15000000
    ${PRBs_available_PUSCH_c3} =    Run Keyword And Return Status    Should Be True    ${M55308C10006_c3}>=19500000
    ${PRBs_used_PUSCH_c3} =    Run Keyword And Return Status    Should Be True    ${M55308C10002_c3}>=15000000
    Run Keyword If    not ${PRBs_available_PUSCH_c1} or not ${PRBs_used_PUSCH_c1}    Fail    The UL pooling PM counter can not match.
    Run Keyword If    not ${PRBs_available_PUSCH_c2} or not ${PRBs_used_PUSCH_c2}    Fail    The UL pooling PM counter can not match.
    Run Keyword If    not ${PRBs_available_PUSCH_c3} or not ${PRBs_used_PUSCH_c3}    Fail    The UL pooling PM counter can not match.
