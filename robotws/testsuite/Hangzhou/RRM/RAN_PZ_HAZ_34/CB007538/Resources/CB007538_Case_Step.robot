*** Settings ***
Documentation    This is for feature CB008247 related common keywords.
...              Please do not modify the file without notification to author
...              Author:xiaoxia.hao@nokia-sbell.com
...              Squard: HZ SG6
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/TestData.py
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008015/Resources/CB008015_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007737/Resources/CB007737_Case_Step.robot

*** Keywords ***
CB007538-A_001_Monitoring_of_the_PCMD-content_related_to_Cell_specific_CSI-RS_UE_measurements_from_SA_UE_using_beamforming
    [Arguments]    ${pcell_index}
    Keep only Pcell notbarred for CA testing    pcell_index=${pcell_index}
    Enable CB007235 parameters
    ${scell_list}    Create List    1     2     3
    Delete NRREL Cell Infor On Gnb    pcell_index=${pcell_index}    scell_list=${scell_list}
    run keyword and ignore error    Update PA Value For Tput
#    Wireshark setup Before Run case
    Generate Pcell And Scell Mapping Info    pcell_index=${pcell_index}
    ${pcell_index}    Convert To String    ${pcell_index}
    Start wireshark capture from gNB
    Make_L3_Call_And_Check_Tput    ul_data_transfer=100M
    ...                            dl_data_transfer=2400M
    ...                            is_do_require_ue=${True}
    ...                            whether_collect_tput=${False}
    ...                            check_pcell_tput=${False}
    ...                            check_scell_tput=${False}
    ...                            is_wireshark_log_capture=${True}
    ...                            check_scell_tput=${False}
    ...                            get_attach_cell_index_needed=${False}
    ...                            is_need_stop_traffic=${False}
    Sleep    1min
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    Run Keyword And Ignore Error    Stop Traffic With Power UE
    ${log_full_path_ute}    Stop wireshark capture from gNB
    run keyword and continue on failure    Check ReportRecord Infor From Tcpdump    log_full_path_ute=${log_full_path_ute}
    ${abil_index}    Set Variable If    '${stream}'=='SBTS25R1'    4    2
    Perform BBMOD reset via webui    abil_index=${abil_index}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Sleep    3min
    Start wireshark capture from gNB
    Make_L3_Call_And_Check_Tput    ul_data_transfer=100M
    ...                            dl_data_transfer=2400M
    ...                            is_do_require_ue=${False}
    ...                            whether_collect_tput=${False}
    ...                            check_pcell_tput=${False}
    ...                            check_scell_tput=${False}
    ...                            is_wireshark_log_capture=${True}
    ...                            check_scell_tput=${False}
    ...                            get_attach_cell_index_needed=${False}
    ...                            is_need_stop_traffic=${False}
    Sleep    1min
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    Run Keyword And Ignore Error    Stop Traffic With Power UE
    ${log_full_path_ute}    Stop wireshark capture from gNB
    run keyword and continue on failure    Check ReportRecord Infor From Tcpdump    log_full_path_ute=${log_full_path_ute}
    [Teardown]    Run Keyword And Ignore Error    Stop Traffic With Power UE

