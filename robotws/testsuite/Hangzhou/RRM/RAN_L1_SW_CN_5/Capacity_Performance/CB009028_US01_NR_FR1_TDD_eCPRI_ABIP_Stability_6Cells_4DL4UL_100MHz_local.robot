*** Settings ***
Documentation
...    Author:  Hou Yuguo
...    Contact: yuguo.hou@nokia-sbell.com
...    Feature: CB009028
...    Release: 23R4

Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    5G_RAN_TDD    RAN_5G    CLOUD_5G_I_MP_AP_LOOO
...    SBTS00    CRT    QL3    QCD_MN_RAN    QCP_RAN_RF
Library           taf.selenium.sbts  WITH NAME  selenium_coam
Resource    ../resources/Airphone/Airphone_resource.robot
Resource    ../resources/common_resource_bts.robot
Library         ./random_select_cells.py
Library    ../resources/python/KISS/ta_kiss_gnb/

*** Variables ***
&{GNB_ASIB}       ip=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik

*** Test Cases ***
CB009028_TC01_NR_FR1_TDD_eCPRI_ABIP_Stability_6Cells_4DL4UL_100MHz
    [Documentation]
    ...    This case is to verify ABIP NR FR1 TDD eCPRI 6 cells stability
    [Tags]    C&P    CB009028    ASIM+ABIP    6cells4D4U    QC_460326    Trunk
    Log To Console  start attach 120UEs to 4cells
    Ue Attach to 4cells and start 5G L3 call
    verify tput every 600 seconds
    Collect Snapshot GNB1

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env  tl_type=AP_LOOO/tdd_sansa_cmwv/FS/6cell_ecpri_local    cfg=wts.cfg

Ue Attach to 4cells and start 5G L3 call
    multiple_ue_register_and_traffic_start    ue_num=30    start_ue=1    cell_id=1    dl_mbps=40   ul_mbps=5
    multiple_ue_register_and_traffic_start    ue_num=30    start_ue=31    cell_id=2    dl_mbps=40    ul_mbps=5
    multiple_ue_register_and_traffic_start    ue_num=30    start_ue=61    cell_id=3    dl_mbps=40   ul_mbps=5
    multiple_ue_register_and_traffic_start    ue_num=30    start_ue=91    cell_id=4    dl_mbps=40   ul_mbps=5

verify tput every ${sleep_time} seconds
    Log To Console  start to check tput every ${sleep_time} seconds
    ${tput_check_times}    set Variable    3
    FOR    ${i}    IN RANGE    ${tput_check_times}
        sleep    ${sleep_time}
        get_all_active_and_idle_ues
        verify tput by PMCounter    30000000000    3000000000
        Log To Console  check tput pass
    END

verify tput by PMCounter
    [Arguments]    ${dltp_threshold}    ${ultp_threshold}
    Log To Console  check counters value
    ${pm_counter_file}=    Download Latest Pmcounter    ${SAVE LOG DIRECTORY}
    ${DL_tput_cell1}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=1
    ${UL_tput_cell1}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=1
    ${DL_tput_cell2}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=2
    ${UL_tput_cell2}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=2
    ${DL_tput_cell3}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=3
    ${UL_tput_cell3}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=3
    ${DL_tput_cell4}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=4
    ${UL_tput_cell4}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=4
    Should Be True    ${DL_tput_cell1}>=${dltp_threshold}
    Should Be True    ${UL_tput_cell1}>=${ultp_threshold}
    Should Be True    ${DL_tput_cell2}>=${dltp_threshold}
    Should Be True    ${UL_tput_cell2}>=${ultp_threshold}
    Should Be True    ${DL_tput_cell3}>=${dltp_threshold}
    Should Be True    ${UL_tput_cell3}>=${ultp_threshold}
    Should Be True    ${DL_tput_cell4}>=${dltp_threshold}
    Should Be True    ${UL_tput_cell4}>=${ultp_threshold}
