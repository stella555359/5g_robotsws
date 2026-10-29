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
CB012971 Suite Setup
     [Arguments]    ${TC_DIR}=none
     Clean up Preparation before TC     ${TC_DIR}
     Download Ttitrace Decode Tool
     Sleep     10
     Start Logs      ${L_AP_GNB_SYS}

CB012971 Suite Teardown
     [Arguments]    ${TC_DIR}=none
##     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
     Sleep     10
     Stop Logs     ${L_AP_GNB_SYS}     ${TC_DIR}
     Collect Cfg and egate logs     ${TC_DIR}
     Cleanup Process After TC     ${TC_DIR}

CB012971 x2 link up
     Exe egate cmd      cmd=${CM_NSA_X2LINK}

CB012971 4UE PROFILE POS ACT
     Exe egate cmd     cmd=${CB012971_POS_PROFILE1_CMD}        return_output=False
     Exe egate cmd     cmd=${CB012971_UE1_PROFILE1_POS_CMD_ACT}        return_output=False
     Exe egate cmd     cmd=${CB012971_POS_PROFILE2_CMD}        return_output=False
     Exe egate cmd     cmd=${CB012971_UE2_PROFILE2_POS_CMD_ACT}        return_output=False
     Exe egate cmd     cmd=${CB012971_POS_PROFILE3_CMD}        return_output=False
     Exe egate cmd     cmd=${CB012971_UE3_PROFILE3_POS_CMD_ACT}        return_output=False
     Exe egate cmd     cmd=${CB012971_POS_PROFILE4_CMD}        return_output=False
     Exe egate cmd     cmd=${CB012971_UE4_PROFILE4_POS_CMD_ACT}        return_output=False
     Exe egate cmd     cmd=${CB012971_POS_PROFILE5_CMD}        return_output=False
     Exe egate cmd     cmd=${CB012971_UE5_PROFILE5_POS_CMD_ACT}        return_output=False
     Exe egate cmd     cmd=${CB012971_POS_PROFILE6_CMD}        return_output=False
     Exe egate cmd     cmd=${CB012971_UE6_PROFILE6_POS_CMD_ACT}        return_output=False
     Exe egate cmd     cmd=${CB012971_POS_PROFILE7_CMD}        return_output=False
     Exe egate cmd     cmd=${CB012971_UE7_PROFILE7_POS_CMD_ACT}        return_output=False
     Exe egate cmd     cmd=${CB012971_POS_PROFILE8_CMD}        return_output=False
     Exe egate cmd     cmd=${CB012971_UE8_PROFILE8_POS_CMD_ACT}        return_output=False
     Exe egate cmd     cmd=ul_ue_beam_pos_nr profile_id=1
     Exe egate cmd     cmd=ul_ue_beam_pos_nr profile_id=2
     Exe egate cmd     cmd=ul_ue_beam_pos_nr profile_id=3
     Exe egate cmd     cmd=ul_ue_beam_pos_nr profile_id=4
     Exe egate cmd     cmd=ul_ue_beam_pos_nr profile_id=5
     Exe egate cmd     cmd=ul_ue_beam_pos_nr profile_id=6
     Exe egate cmd     cmd=ul_ue_beam_pos_nr profile_id=7
     Exe egate cmd     cmd=ul_ue_beam_pos_nr profile_id=8

CB012971 SA Call UE1 to UE4
     Exe egate cmd      cmd=${CM_UE1TO4_DTYPE_INTERNAL}        return_output=False
     Exe egate cmd      cmd=${CM_UE_1_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_UL_DATA_TRFID_1}
     Exe egate cmd      cmd=${CM_UE_2_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_2_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_2_UL_DATA_TRFID_1}

     Exe egate cmd      cmd=${CM_UE_3_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_3_PDU_SESSION}
     Sleep      10
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_3_UL_DATA_TRFID_1}

     Exe egate cmd      cmd=${CM_UE_4_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_4_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_4_UL_DATA_TRFID_1}

     Exe egate cmd      cmd=${CM_UE_1TO4_DL_DATA_TRFID_1}
     Exe egate cmd      cmd=${CM_UE_1TO4_DL_DATA_TRFID_2}
     Exe egate cmd      cmd=${CM_UE_1TO4_DL_DATA_TRFID_3}
     Exe egate cmd      cmd=${CM_UE_1TO4_DL_DATA_TRFID_4}
     Exe egate cmd      cmd=${CM_UE_1TO4_DL_DATA_TRFID_5}
#     Exe egate cmd      cmd=${CM_UE_1TO4_DL_DATA_TRFID_6}
#     Exe egate cmd      cmd=${CM_UE_1TO4_DL_DATA_TRFID_7}

CB012971 SA Deregister UE 1 to 4
     Exe egate cmd      cmd=${CM_UE_1_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

     Exe egate cmd      cmd=${CM_UE_2_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

     Exe egate cmd      cmd=${CM_UE_3_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

     Exe egate cmd      cmd=${CM_UE_3_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

     Exe egate cmd      cmd=${CM_UE_4_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
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
