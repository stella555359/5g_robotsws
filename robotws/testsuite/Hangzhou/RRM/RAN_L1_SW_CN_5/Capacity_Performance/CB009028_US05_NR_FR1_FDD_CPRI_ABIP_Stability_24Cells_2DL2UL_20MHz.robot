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
...    zefang.xu@nokia-sbell.com
Library           taf.selenium.sbts  WITH NAME  selenium_coam
Resource        ../resources/Airphone/Airphone_resource.robot
Resource        ../resources/common_resource_bts.robot
Library        ./random_select_cells.py
Library    ../resources/python/KISS/ta_kiss_gnb/

*** Variables ***
&{GNB_ASIB}       ip=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik

*** Test Cases ***
CB009028_TC05_NR_FR1_FDD_CPRI_ABIP_Stability_24Cells_2T2R_20MHz
    [Documentation]
    ...    This case is to verify ABIP NR FR1 FDD CPRI 12 cells stability
    [Tags]    C&P    CB009028    ASIM+ABIP    12cells2D2U    Trunk
    Log To Console  start attach 105UEs to 7cells
    Ue Attach to 7cells and start 5G L3 call
    verify tput every 600 seconds
    Collect Snapshot GNB1
    traffic_data_stop    ue_id=1-120
    Ue Pdu Session Release    ue_id=1-120
    release_ues    ue_id=1-120

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env  tl_type=AP_LOOO/fdd_sansa_cmwv/FS/12cell_cpri    cfg=wts.cfg

Ue Attach to 7cells and start 5G L3 call
    Perform Egate Command    uec_param id=1 reordering_timer=0
    multiple_ue_register_and_traffic_start    ue_num=15    start_ue=1    cell_id=1    dl_mbps=8   ul_mbps=5
    multiple_ue_register_and_traffic_start    ue_num=15    start_ue=16    cell_id=2    dl_mbps=8    ul_mbps=5
    multiple_ue_register_and_traffic_start    ue_num=15    start_ue=31    cell_id=3    dl_mbps=8    ul_mbps=5
    multiple_ue_register_and_traffic_start    ue_num=15    start_ue=46    cell_id=4    dl_mbps=8    ul_mbps=5
    multiple_ue_register_and_traffic_start    ue_num=15    start_ue=61    cell_id=5    dl_mbps=8    ul_mbps=5
    multiple_ue_register_and_traffic_start    ue_num=15    start_ue=76    cell_id=6    dl_mbps=8    ul_mbps=5
    multiple_ue_register_and_traffic_start    ue_num=15    start_ue=91    cell_id=7    dl_mbps=8    ul_mbps=5
    #multiple_ue_register_and_traffic_start    ue_num=15    start_ue=106    cell_id=8    dl_mbps=8    ul_mbps=5

verify tput every ${sleep_time} seconds
    Log To Console  start to check tput every ${sleep_time} seconds
    ${tput_check_times}    set Variable    4
    FOR    ${i}    IN RANGE    ${tput_check_times}
        sleep    ${sleep_time}
        get_all_active_and_idle_ues
        verify tput by PMCounter    3000000000    2000000000
    END

verify tput by PMCounter
    [Arguments]    ${dltp_threshold}    ${ultp_threshold}
    Log To Console  download pmcounter file and get counters value
    ${pm_counter_file}=    Download Latest Pmcounter    ${SAVE LOG DIRECTORY}
    ${DL_tput_cell1}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=1
    ${UL_tput_cell1}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=1
    ${DL_tput_cell2}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=2
    ${UL_tput_cell2}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=2
    ${DL_tput_cell3}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=3
    ${UL_tput_cell3}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=3
    ${DL_tput_cell4}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=4
    ${UL_tput_cell4}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=4
    ${DL_tput_cell5}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=5
    ${UL_tput_cell5}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=5
    ${DL_tput_cell6}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=6
    ${UL_tput_cell6}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=6
    ${DL_tput_cell7}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=7
    ${UL_tput_cell7}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=7
    #${DL_tput_cell8}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=8
    #${UL_tput_cell8}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=8
    #${DL_tput_cell9}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=9
    #${UL_tput_cell9}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=9
    #${DL_tput_cell10}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=10
    #${UL_tput_cell10}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=10
    #${DL_tput_cell11}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=11
    #${UL_tput_cell11}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=11
    #${DL_tput_cell12}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=12
    #${UL_tput_cell12}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=12
    Log To Console  check counters value
    Should Be True    ${DL_tput_cell1}>=${dltp_threshold}
    Should Be True    ${UL_tput_cell1}>=${ultp_threshold}
    Should Be True    ${DL_tput_cell2}>=${dltp_threshold}
    Should Be True    ${UL_tput_cell2}>=${ultp_threshold}
    Should Be True    ${DL_tput_cell3}>=${dltp_threshold}
    Should Be True    ${UL_tput_cell3}>=${ultp_threshold}
    Should Be True    ${DL_tput_cell4}>=${dltp_threshold}
    Should Be True    ${UL_tput_cell4}>=${ultp_threshold}
    Should Be True    ${DL_tput_cell5}>=${dltp_threshold}
    Should Be True    ${UL_tput_cell5}>=${ultp_threshold}
    Should Be True    ${DL_tput_cell6}>=${dltp_threshold}
    Should Be True    ${UL_tput_cell6}>=${ultp_threshold}
    Should Be True    ${DL_tput_cell7}>=${dltp_threshold}
    Should Be True    ${UL_tput_cell7}>=${ultp_threshold}
    #Should Be True    ${DL_tput_cell8}>=${dltp_threshold}
    #Should Be True    ${UL_tput_cell8}>=${ultp_threshold}
    #Should Be True    ${DL_tput_cell9}>=${dltp_threshold}
    #Should Be True    ${UL_tput_cell9}>=${ultp_threshold}
    #Should Be True    ${DL_tput_cell10}>=${dltp_threshold}
    #Should Be True    ${UL_tput_cell10}>=${ultp_threshold}
    #Should Be True    ${DL_tput_cell11}>=${dltp_threshold}
    #Should Be True    ${UL_tput_cell11}>=${ultp_threshold}
    #Should Be True    ${DL_tput_cell12}>=${dltp_threshold}
    #Should Be True    ${UL_tput_cell12}>=${ultp_threshold}
