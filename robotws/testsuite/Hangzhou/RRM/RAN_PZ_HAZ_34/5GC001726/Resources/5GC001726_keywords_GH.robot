*** Settings ***
Documentation
...   This is for 1726 TA common keywords
...   squad group: MMW_SG1
Resource    ./5GC001726_keywords.robot

*** Keywords ***
Verify peak throughput on gnb L2Lo
    [Documentation]    Author: Wang Yixiang
    ...                Description: Capturing logs and do verifications as bellow:
    ...                             1. ul and dl peak throughput of all cells
    ...                             2. Bler is as expected
    ...                dl_cell can be 1 or 1,2,3,4,5,6,7,8
    ...                ul_cell can be 1 or 1,2
    ...                e.g  Verify peak throughput on gnb L2Lo    dl_cell=1,2,3,4,5,6,7,8     expected_dl_tput=${DL_TPUT_802}
    ...                                                           ul_cell=1,2     expected_ul_tput=${UL_TPUT_802}
    [Arguments]    ${dl_cell}    ${expected_dl_tput}    ${ul_cell}    ${expected_ul_tput}
    ${list_dl_cell}    string2list    ${dl_cell}
    ${list_ul_cell}    string2list    ${ul_cell}
    @{direction_component_list}    Create list    UL_L2LO    DL_L2LO
    Connect to Capacity Unit Master case
    ${saved_tput_file_list}    check_average_throughput.start_tput_log_capturing    direction_component_list=${direction_component_list}
    Start TTI trace log capturing
    Sleep    5s
    check_average_throughput.stop_tput_log_capturing    saved_tput_file_list=${saved_tput_file_list}
    Stop TTI trace log capturing
    &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc
    &{dict_local_tput_file_path}    check_average_throughput.download_tput_files    saved_tput_file_list=${saved_tput_file_list}
    ...    download_dir=${TS_CASE_LOG_PATH}
    ${ul_tput_all}    verify_tput.get_peak_tput_all_cells    tput_file=${dict_local_tput_file_path['UL_L2LO']}
    ...    list_cell=${list_ul_cell}    nr_cell_id_mapping=${NR_CELL_ID_MAPPING}
    ${dl_tput_all}    verify_tput.get_peak_tput_all_cells    tput_file=${dict_local_tput_file_path['DL_L2LO']}
    ...    list_cell=${list_dl_cell}    nr_cell_id_mapping=${NR_CELL_ID_MAPPING}
    Run keyword and continue on failure    Verify bler is as expected based on event trace log    dict_event_trace_log=${dict_csv_file_path}
    ...    data_transfer_direction=both
    should be true    ${ul_tput_all} >= ${expected_ul_tput}
    should be true    ${dl_tput_all} >= ${expected_dl_tput}

