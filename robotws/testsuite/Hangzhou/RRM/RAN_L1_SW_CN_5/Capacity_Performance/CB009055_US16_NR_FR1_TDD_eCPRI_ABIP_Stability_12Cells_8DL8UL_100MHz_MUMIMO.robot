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
Resource    ../resources/Airphone/Airphone_resource.robot
Resource    ../resources/common_resource_bts.robot
*** Variables ***
@{ALLOWED_FAULT}

*** Test Cases ***
CB009055_US16_NR_FR1_TDD_eCPRI_ABIP_Stability_12Cells_8DL8UL_100MHz_MUMIMO
    [Tags]    C&P    ABIP     airphone    CB009055
    ue_register    ue_id=1    cell_id=1
    Perform Egate Command
    ...    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=UL_MIMO
    Perform Egate Command    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
    Perform Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=ul trf_id=1 mbps=100
    Perform Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=dl trf_id=1 mbps=5
    ue_register    ue_id=2    cell_id=1
    Perform Egate Command
    ...    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=2 init_sub_quad_pos=3 test_type=UL_MIMO
    Perform Egate Command    ue_testmode_set_nr id=2 testmode=ul_mimo_srs_beam_pos action=activate profile_id=2
    Perform Egate Command    trf_data_start ue=2 pdu=1 qfi=1 dir=ul trf_id=3 mbps=100
    Perform Egate Command    trf_data_start ue=2 pdu=1 qfi=1 dir=dl trf_id=3 mbps=5
    ue_register    ue_id=3    cell_id=1
    Perform Egate Command
    ...    ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=3 init_sub_quad_pos=1 test_type=UL_MIMO
    Perform Egate Command    ue_testmode_set_nr id=3 testmode=ul_mimo_srs_beam_pos action=activate profile_id=3
    Perform Egate Command    trf_data_start ue=3 pdu=1 qfi=1 dir=ul trf_id=4 mbps=100
    Perform Egate Command    trf_data_start ue=3 pdu=1 qfi=1 dir=dl trf_id=4 mbps=5
    ue_register    ue_id=4    cell_id=1
    Perform Egate Command
    ...    ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=UL_MIMO
    Perform Egate Command    ue_testmode_set_nr id=4 testmode=ul_mimo_srs_beam_pos action=activate profile_id=4
    Perform Egate Command    trf_data_start ue=4 pdu=1 qfi=1 dir=ul trf_id=5 mbps=100
    Perform Egate Command    trf_data_start ue=4 pdu=1 qfi=1 dir=dl trf_id=5 mbps=5
    Ue Attach to 6cells and start 5G L3 call

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Get BSR package
    Load and active BSR
    Setup Airphone Env    tl_type=AP_LOOO/tdd_sansa_cmwv/FS/6cell_ecpri_mumimo/8D8U    cfg=wts.cfg

Ue Attach to 6cells and start 5G L3 call
    multiple_ue_register_and_traffic_start    ue_num=16    start_ue=5    cell_id=1    dl_mbps=5    ul_mbps=4
    multiple_ue_register_and_traffic_start    ue_num=20    start_ue=21    cell_id=2    dl_mbps=5    ul_mbps=4
    multiple_ue_register_and_traffic_start    ue_num=20    start_ue=41    cell_id=3    dl_mbps=5    ul_mbps=4
    multiple_ue_register_and_traffic_start    ue_num=20    start_ue=61    cell_id=4    dl_mbps=5   ul_mbps=4
    multiple_ue_register_and_traffic_start    ue_num=20    start_ue=81    cell_id=5    dl_mbps=5    ul_mbps=4
    multiple_ue_register_and_traffic_start    ue_num=20    start_ue=101    cell_id=6    dl_mbps=5    ul_mbps=4

verify tput every ${sleep_time} seconds
    Log To Console  start to check tput every ${sleep_time} seconds
    ${tput_check_times}    set Variable    3
    FOR    ${i}    IN RANGE    ${tput_check_times}
        sleep    ${sleep_time}
        get_all_active_and_idle_ues
        verify tput by PMCounter    35000000000    1800000000
        Log To Console  check tput pass ${i}
    END

verify tput by PMCounter for cell
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
    ${DL_tput_cell5}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=5
    ${UL_tput_cell5}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=5
    ${DL_tput_cell6}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=6
    ${UL_tput_cell6}=    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=6
    Should Be True    ${DL_tput_cell1}>=30000000000
    Should Be True    ${UL_tput_cell1}>=12000000000
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
