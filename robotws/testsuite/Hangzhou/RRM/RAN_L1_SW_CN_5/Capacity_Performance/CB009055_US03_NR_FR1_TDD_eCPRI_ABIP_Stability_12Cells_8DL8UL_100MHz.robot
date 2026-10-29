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
...    SBTS00    CRT    QL3    QCD_MN_RAN    QCP_RAN_RF
Library           taf.selenium.sbts  WITH NAME  selenium_coam
Resource    ../resources/Airphone/Airphone_resource.robot
Resource    ../resources/common_resource_bts.robot
Library         ./random_select_cells.py
Library    ../resources/python/KISS/ta_kiss_gnb/

*** Variables ***
@{ALLOWED_FAULT}

*** Test Cases ***
CB009055_TC03_NR_FR1_TDD_eCPRI_ABIP_Stability_12Cells_8DL8UL_100MHz
    [Documentation]
    ...    This case is to verify ABIP NR FR1 TDD eCPRI 6 cells stability
    [Tags]    CB009055    ASIM+ABIP    6cells8D8U    Trunk    C&P
    Log To Console  start attach 120UEs to 4cells
    WebUI connection    suite
    Setup Parameter for UL subcell0 IQ capture
    Ue Attach to 4cells and start 5G L3 call
    Run Keyword And Ignore Error    check UL event trigger count
    Setup Parameter for DL subcell0 IQ capture
    verify tput every 600 seconds
    IQ capture and save snapshot
    WebUI disconnection    suite
    traffic_data_stop    ue_id=1-120
    Ue Pdu Session Release    ue_id=1-120
    release_ues    ue_id=1-120

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env  tl_type=AP_LOOO/tdd_sansa_cmwv/FS/6cell_ecpri_local/8D8U    cfg=wts.cfg

Setup Parameter for UL subcell0 IQ capture
    ${ul_subcell_index_list}=    Create List    [BBMOD_R-1(ABIP)] [PCI: 51]NRCELL-2: Subcell 2    [BBMOD_R-1(ABIP)] [PCI: 51]NRCELL-2: Subcell 3
    Configure IQ capture via webUI     ul_subcell_index_list=${ul_subcell_index_list}    dl_subcell_index_list=${None}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Event    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}
    common_resource_bts.ADMIN Set Multiple RAD debug parameters    NrUlPhy    [{'name':'phyEventEnableExt', 'value': '2147483648'}]
    ${phyEventEnableExt}    common_resource_bts.ADMIN Get RAD Debug Parameter Details    NrUlPhy    phyEventEnableExt
    log    ${phyEventEnableExt}

check UL event trigger count
    Wait Until Keyword Succeeds    2min    30s    check the event count

check the event count
    ${event_count}    Get Event Trigger Count on BBMOD    bsh 1:1    NR
    Should Be True    ${event_count}>0    [ERROR]Event Trigger Count not large than zero

Setup Parameter for DL subcell0 IQ capture
    ${dl_subcell_index_list}=    Create List    [BBMOD_R-1(ABIP)] [PCI: 51]NRCELL-2: Subcell 2    [BBMOD_R-1(ABIP)] [PCI: 51]NRCELL-2: Subcell 3
    Configure IQ capture via webUI    ul_subcell_index_list=${None}    dl_subcell_index_list=${dl_subcel_index_list}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Event    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}
    common_resource_bts.ADMIN Set Multiple RAD debug parameters    NrDlPhy    [{'name':'dlPhyEventEnable', 'value': '1'}]
    ${dlPhyEventEnable}    common_resource_bts.ADMIN Get RAD Debug Parameter Details    NrDlPhy    dlPhyEventEnable
    log    ${dlPhyEventEnable}

IQ capture and save snapshot
    Wait Until Keyword Succeeds    2min    30s    check the event count
    Save SnapShot Via WebUI

Ue Attach to 4cells and start 5G L3 call
    Perform Egate Command    uec_param id=1 reordering_timer=0
    multiple_ue_register_and_traffic_start    ue_num=30    start_ue=1    cell_id=2    dl_mbps=10   ul_mbps=5
    multiple_ue_register_and_traffic_start    ue_num=30    start_ue=31    cell_id=3    dl_mbps=10    ul_mbps=5
    multiple_ue_register_and_traffic_start    ue_num=30    start_ue=61    cell_id=4    dl_mbps=10   ul_mbps=5
    multiple_ue_register_and_traffic_start    ue_num=30    start_ue=91    cell_id=5    dl_mbps=10   ul_mbps=5

verify tput every ${sleep_time} seconds
    Log To Console  start to check tput every ${sleep_time} seconds
    ${tput_check_times}    set Variable    4
    FOR    ${i}    IN RANGE    ${tput_check_times}
        sleep    ${sleep_time}
        get_all_active_and_idle_ues
        verify tput by PMCounter    10000000000    4000000000
        Log To Console  check tput pass
    END

verify tput by PMCounter
    [Arguments]    ${dltp_threshold}    ${ultp_threshold}
    Log To Console  check counters value
    ${pm_counter_file}=    Download Latest Pmcounter    ${SAVE LOG DIRECTORY}
    #${pm_counter_file}=    Download Latest Pmcounter    ${OUTPUT DIR}/
    ${DL_tput_cell5}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=5
    ${UL_tput_cell5}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=5
    ${DL_tput_cell2}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=2
    ${UL_tput_cell2}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=2
    ${DL_tput_cell3}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=3
    ${UL_tput_cell3}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=3
    ${DL_tput_cell4}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=4
    ${UL_tput_cell4}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=4
    Should Be True    ${DL_tput_cell5}>=${dltp_threshold}
    Should Be True    ${UL_tput_cell5}>=${ultp_threshold}
    Should Be True    ${DL_tput_cell2}>=${dltp_threshold}
    Should Be True    ${UL_tput_cell2}>=${ultp_threshold}
    Should Be True    ${DL_tput_cell3}>=${dltp_threshold}
    Should Be True    ${UL_tput_cell3}>=${ultp_threshold}
    Should Be True    ${DL_tput_cell4}>=${dltp_threshold}
    Should Be True    ${UL_tput_cell4}>=${ultp_threshold}
