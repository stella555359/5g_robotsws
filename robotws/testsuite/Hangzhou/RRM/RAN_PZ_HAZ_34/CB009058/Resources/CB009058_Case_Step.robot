*** Settings ***
Documentation    This is for feature CB008247 related common keywords.
...              Please do not modify the file without notification to author
...              Author:xiaoxia.hao@nokia-sbell.com
...              Squard: HZ SG6
Resource    CB009058_keywords.robot

*** Variables ***
@{btslog_dirs}        /opt/btslog     /opt/ute/tools/btslog

*** Keywords ***
CB009058_B_01_three_TDD_cells_each_L2_subpool_one_cell_on_half_ABIO
    [Arguments]    ${pcell_index}
    Check L2SP Infor From CPIF Log
    run keyword and ignore error    Update PA Value For Tput
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${pcell_index}
    Generate Pcell Mapping Info    pcell_index=${pcell_index}
    Make_L3_Call_And_Check_Tput
    ...                            is_do_require_ue=${True}
    ...                            ul_data_transfer=120M
    ...                            dl_data_transfer=1400M
    ...                            is_wireshark_log_capture=${True}
    ...                            get_attach_cell_index_needed=${False}
    ...                            scell_mapping=${None}
    ...                            check_scell_tput=${False}
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
