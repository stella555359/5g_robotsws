** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : Contains Keyword needed for CB012971-A
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,17.01.2025,vadivelan.manickavasagam@nokia.com

Resource    ../../../../resources/Keywords/new_general_common_keywords.robot
Library     ../Python/tti_csv_filter_element_value.py
Library     ../Python/extract_uestats.py
Library     ta_a2a.interface

*** Keywords ***
FT_LEGACY Suite Setup
     [Arguments]    ${TC_DIR}=none
     Clean up Preparation before TC     ${TC_DIR}
#     Download Ttitrace Decode Tool
     Sleep     10
     Configure Routes in WTS with arguments     ${ROUTE_10_0_1_61_M24}     ${DEV_ETH3}
     Start Logs      ${L_AP_GNB_SYS}

FT_LEGACY Suite Teardown
     [Arguments]    ${TC_DIR}=none
#     Stop and collect SOS       ${sos_script_path}      ${TC_DIR}
     Sleep     10
     Stop Logs     ${L_AP_GNB_SYS}     ${TC_DIR}
     Delete Routes in WTS with arguments     ${ROUTE_10_0_1_61_M24}     ${DEV_ETH3}
     Remove Pet Config     ${WTS_WORKING_DIR}
     Collect Cfg and egate logs     ${TC_DIR}
     Cleanup Process After TC     ${TC_DIR}

PET FT LEGACY SA Call
     [Arguments]    ${PET_FT_LEGACY_SCRIPT}
     Exe egate cmd      cmd=script file=/opt/wts/latest/commands.lua entry=${PET_FT_LEGACY_SCRIPT}
     Wait Until Keyword Succeeds    3min    1min
     ...     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PET_SCRIPT_COMPLETE}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

DLMUPAIR
     Exe egate cmd      cmd=${CM_UE_1_DL_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>14000

     Exe egate cmd      cmd=${CM_UE_2_DL_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>14000

     Exe egate cmd      cmd=${CM_UE_3_DL_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>14000

     Exe egate cmd      cmd=${CM_UE_4_DL_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>14000

DLMUPAIRTTI
     Convert TTI trace from pcap to excelCsv      pcap_path=/home/ute/logs/l2stream3/tcpdump/tcpdump.pcap
     ...      output_path_with_tag=/home/ute/logs/l2stream3/tcpdump/     decode_format=excelCsv
     ta_a2a.interface.Check Logs With Au2anlysis      ini_path=${CURDIR}/../../ini/CB012971_C_DLPAIR.ini    log_need_to_check=i
     ...    save_log_directory=/home/ute/logs/l2stream3/

CB012971 Validate PM counter
      [Arguments]    ${CB012971_C_LST_OF_PM_COUNT_DICT}     ${PM_FILE_PATH}
      Validate PM counter     ${CB012971_C_LST_OF_PM_COUNT_DICT}      ${PM_FILE_PATH}

PET CB012971 SA Deregister UE 1 to 4
     Exe egate cmd      cmd=seq_stop id=all
