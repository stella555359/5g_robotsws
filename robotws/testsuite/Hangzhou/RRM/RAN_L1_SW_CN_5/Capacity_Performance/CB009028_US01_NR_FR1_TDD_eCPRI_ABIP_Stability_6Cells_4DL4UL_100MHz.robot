*** Settings ***
Documentation
...    Author:  Hou Yuguo
...    Contact: yuguo.hou@nokia-sbell.com
...    Feature: CB009028
...    Release:

Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    5G_RAN_TDD    RAN_5G    CLOUD_5G_I_MP_AP_LOOO
...    SBTS00    CRT    QL3    QCD_MN_RAN    QCP_RAN_RF
Resource    ../resources/Airphone/Airphone_resource.robot

*** Variables ***
@{ALLOWED_FAULT}

*** Test Cases ***
CB009028_TC01_NR_FR1_TDD_eCPRI_ABIP_Stability_6Cells_4DL4UL_100MHz
    [Documentation]
    ...    This case is to verify ABIP NR FR1 TDD eCPRI 6 cells stability in 23R3
    [Tags]    C&P    ABIP     airphone    CB009028
    Ue Attach to 6cells and start 5G L3 call
    verify Ue tput every 600 seconds
    Collect Snapshot GNB1
    traffic_data_stop    ue_id=1-120
    Ue Pdu Session Release    ue_id=1-120
    release_ues    ue_id=1-120

*** Keywords ***

Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env    tl_type=AP_LOOO/tdd_sansa_cmwv/FS/6cell_ecpri    cfg=wts.cfg

Ue Attach to 6cells and start 5G L3 call
    multiple_ue_register_and_traffic_start    ue_num=20    start_ue=1    cell_id=1    dl_mbps=5    ul_mbps=5
    multiple_ue_register_and_traffic_start    ue_num=20    start_ue=21    cell_id=2    dl_mbps=5    ul_mbps=5
    multiple_ue_register_and_traffic_start    ue_num=20    start_ue=41    cell_id=3    dl_mbps=5    ul_mbps=5
    multiple_ue_register_and_traffic_start    ue_num=20    start_ue=61    cell_id=4    dl_mbps=5   ul_mbps=5
    multiple_ue_register_and_traffic_start    ue_num=20    start_ue=81    cell_id=5    dl_mbps=5    ul_mbps=5
    multiple_ue_register_and_traffic_start    ue_num=20    start_ue=101    cell_id=6    dl_mbps=5    ul_mbps=5

verify Ue tput every ${sleep_time} seconds
    Log To Console  start to check ue tput every ${sleep_time} seconds
    ${tput_check_times}    set Variable    3
    FOR    ${i}    IN RANGE    ${tput_check_times}
        sleep    ${sleep_time}
        multiple_ue_throughput_verify    ue_num=120    start_ue=1    dl_mbps=5    ul_mbps=5
    END
