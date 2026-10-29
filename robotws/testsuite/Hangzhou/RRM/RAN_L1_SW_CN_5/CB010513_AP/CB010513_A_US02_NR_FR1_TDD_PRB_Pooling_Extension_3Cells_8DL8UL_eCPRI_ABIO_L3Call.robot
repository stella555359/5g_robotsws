*** Settings ***
Documentation
...    Author: Li Lei
...    Contact: lei.1.li@nokia-sbell.com
...    Feature: CB010513_A
...    Release: 23R4
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    5G_RAN_TDD    RAN_5G    CLOUD_5G_I_MP_AP_LOOO
...    SBTS00    SBTS24R1    CRT    QL3    QCD_MN_RAN    QCP_RAN_RF
Resource    ../resources/Airphone/Airphone_resource.robot
Resource    ../resources/common_resource_bts.robot

*** Variables ***
@{ALLOWED_FAULT}

*** Test Cases ***
CB010513_A_US02_NR_FR1_TDD_PRB_Pooling_Extension_3Cells_8DL8UL_eCPRI_ABIO_L3Call
	[Documentation]
    ...    This case is to verify ABIO NR FR1 TDD eCPRI 3 cells L3call with TDD PRB pooling extension.
	[Tags]    LOKI    L1CRT    ABIP     airphone    CB010513    QC_495442
	Ue Attach to 3 cells and data traffic
    Check PM counter
    UE stop data transfer and detach

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Get BSR package
    Load and active BSR
    Setup Airphone Env    tl_type=AP_LOOO/tdd_sansa_cmwv/FS/CB010513_3cells_ecpri    cfg=wts.cfg


Ue Attach to ${num} cells and data traffic
    FOR    ${id}    IN RANGE    ${num}
        ue_register    ue_id=${id+1}    cell_id=${id+1}
    END
    traffic_start_and_throughput_verify    ue_id=1    dl_mbps=700    ul_mbps=150    duration=60
    traffic_start_and_throughput_verify    ue_id=2    dl_mbps=200    ul_mbps=150    duration=60
    traffic_start_and_throughput_verify    ue_id=3    dl_mbps=700    ul_mbps=150    duration=60


UE stop data transfer and detach
    traffic_data_stop   ue_id=1
    traffic_data_stop   ue_id=2
    traffic_data_stop   ue_id=3
    release_ues    ue_id=1-3

Check PM counter
    Clear Counter files
    ${pm_counters}    Create List    NRCELL-1:M55308C10005    NRCELL-2:M55308C10005    NRCELL-3:M55308C10005
    ${M55308C10005_c1}    ${M55308C10005_c2}    ${M55308C10005_c3}    get_counters_value    ${pm_counters}
    ${PRBs_available_PDSCH_c1} =    Run Keyword And Return Status    Should Be True    ${M55308C10005_c1}>=90000000
    ${PRBs_available_PDSCH_c2} =    Run Keyword And Return Status    Should Be True    ${M55308C10005_c2}>=90000000
    ${PRBs_available_PDSCH_c3} =    Run Keyword And Return Status    Should Be True    ${M55308C10005_c3}>=90000000
    ${PRBs_available_PDSCH_interpool} =    Run Keyword And Return Status    Should Be True
    ...    ${M55308C10005_c1}>=${M55308C10005_c2}
    Run Keyword If    not ${PRBs_available_PDSCH_c1}    Fail
    ...    Number of PRBs available for PDSCH (M55308C10005) NOT match: cell-1:{M55308C10005_c1}
    Run Keyword If    not ${PRBs_available_PDSCH_c2}    Fail
    ...    Number of PRBs available for PDSCH (M55308C10005) NOT match: cell-1:{M55308C10005_c2}
    Run Keyword If    not ${PRBs_available_PDSCH_c3}    Fail
    ...    Number of PRBs available for PDSCH (M55308C10005) NOT match: cell-1:{M55308C10005_c3}
    Run Keyword If    not ${PRBs_available_PDSCH_interpool}    Fail    Inter-pool pooling NOT match
