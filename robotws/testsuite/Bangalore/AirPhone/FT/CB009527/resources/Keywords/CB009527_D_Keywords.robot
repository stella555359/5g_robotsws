*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : Contains Keyword needed for CB008235-A
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,17.01.2025,vadivelan.manickavasagam@nokia.com

Resource    ../../../resources/Keywords/general_common_keywords.robot
Library     ../Python/tti_csv_filter_element_value.py
Library     ../Python/extract_uestats.py
Library      ta5g_pm_counters
Library     ta_a2a.interface

*** Keywords ***
UE1 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE1_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_1_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

Validate PM Counters From Dict
    [Arguments]          ${moid}       ${file}        &{counter_dict}
    FOR     ${counter_id}      ${counter_name}     IN      &{counter_dict}
        Log    Verifying      ${counter_id} - ${counter_name}
        Verify Last Counters In File
        ...    ${counter_id}    >0
        ...    ${counter_name}
        ...    local_moid=${moid}
        ...    file_path=${file}
    END

PM Check passing dictionary
    Log to Console       PM Check passing dictionary started\n
    FOR     ${counter_id}     ${counter_name}     IN     &{COUNTER_CHECKS}
       Log    Key: ${counter_id}, Value: ${counter_name}
    END

PM Check passing dictionary validate
    Log to Console       PM Check passing dictionary started\n
    FOR     ${counter_id}     ${counter_name}     IN     &{COUNTER_CHECKS}
       Log    Key: ${counter_id}, Value: ${counter_name}
       ${COUNTER_FILE}=      Get Latest Unpacked Full Pm Counters File
       Verify Last Counters In File
       ...     ${counter_id}      >0      ${counter_name}
       ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
       ...     file_path=${COUNTER_FILE}
    END

Verifying the Counter for CB009527
     Log to Console      Fetching the PM Counter\n
     Wait For Next Full Pm Interval
     ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
     Verify Last Counters In File
     ...     M55324C00701     >0     EIRP_SLIDING_SEGMENT_1
     ...     M55324C00000     >0       EIRP_SAMPLES
#     ...     M55326C01001    >0      PDCP_SDU_USDAT_NUM_DL_PL
#     ...     M55326C02006    >0      PDCP_VOL_DL_PLMN_QOS_GRP_06
     ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
     ...     file_path=${pm_counter_file}

Fetch Key And Value From Dictionary
    FOR    ${key}    ${value}    IN    &{DATA_DICT}
        Log    Key: ${key}
        Log    Value: ${value}
    END


UE2 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE2_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE2_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_2_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE3 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE3_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE3_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_3_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE4 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE4_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE4_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_4_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}


UE5 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE5_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE5_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_5_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE6 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE6_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE6_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_6_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}


UE7 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE7_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE7_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_7_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE8 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE8_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE8_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_8_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE9 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE9_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE9_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_9_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE10 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE10_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE10_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_10_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE11 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE11_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE11_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_11_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
UE12 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE12_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE12_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_12_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
UE13 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE13_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE13_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_13_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
UE14 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE14_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE14_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_14_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
UE15 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE15_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE15_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_15_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE16 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE16_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE16_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_16_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

CB009527 UE1 Data
     Exe egate cmd     cmd=${CM_UE_1_DL_TRF1_DATA}
     Exe egate cmd     cmd=${CM_UE_1_DL_TRF2_DATA}
     Exe egate cmd     cmd=${CM_UE_1_DL_TRF3_DATA}
     Exe egate cmd     cmd=${CM_UE_1_UL_TRF1_DATA}
     Sleep      5

CB009527 UE2 Data
     Exe egate cmd     cmd=${CM_UE_2_DL_TRF1_DATA}
     Exe egate cmd     cmd=${CM_UE_2_DL_TRF2_DATA}
     Exe egate cmd     cmd=${CM_UE_2_DL_TRF3_DATA}
     Exe egate cmd     cmd=${CM_UE_2_UL_TRF1_DATA}
     Sleep      5

CB009527 UE3 Data
     Exe egate cmd     cmd=${CM_UE_3_DL_TRF1_DATA}
     Exe egate cmd     cmd=${CM_UE_3_DL_TRF2_DATA}
     Exe egate cmd     cmd=${CM_UE_3_DL_TRF3_DATA}
     Exe egate cmd     cmd=${CM_UE_3_UL_TRF1_DATA}
     Sleep      5

CB009527 UE4 Data
     Exe egate cmd     cmd=${CM_UE_4_DL_TRF1_DATA}
     Exe egate cmd     cmd=${CM_UE_4_DL_TRF2_DATA}
     Exe egate cmd     cmd=${CM_UE_4_DL_TRF3_DATA}
     Exe egate cmd     cmd=${CM_UE_4_UL_TRF1_DATA}
     Sleep      5

CB009527 UE5 Data
     Exe egate cmd     cmd=${CM_UE_5_DL_TRF3_DATA}
     Exe egate cmd     cmd=${CM_UE_5_UL_TRF1_DATA}
     Sleep      5

CB009527 UE6 Data
     Exe egate cmd     cmd=${CM_UE_6_DL_TRF3_DATA}
     Exe egate cmd     cmd=${CM_UE_6_UL_TRF1_DATA}
     Sleep      5

CB009527 UE7 Data
     Exe egate cmd     cmd=${CM_UE_7_DL_TRF3_DATA}
     Exe egate cmd     cmd=${CM_UE_7_UL_TRF1_DATA}
     Sleep      5

CB009527 UE8 Data
     Exe egate cmd     cmd=${CM_UE_8_DL_TRF3_DATA}
     Exe egate cmd     cmd=${CM_UE_8_UL_TRF1_DATA}
     Sleep      5


CB009527 UE9 Data
     Exe egate cmd     cmd=${CM_UE_9_DL_TRF3_DATA}
     Exe egate cmd     cmd=${CM_UE_9_UL_TRF1_DATA}
     Sleep      5

CB009527 UE10 Data
     Exe egate cmd     cmd=${CM_UE_10_DL_TRF3_DATA}
     Exe egate cmd     cmd=${CM_UE_10_UL_TRF1_DATA}
     Sleep      5

CB009527 UE11 Data
     Exe egate cmd     cmd=${CM_UE_11_DL_TRF3_DATA}
     Exe egate cmd     cmd=${CM_UE_11_UL_TRF1_DATA}
     Sleep      5


CB009527 UE12 Data
     Exe egate cmd     cmd=${CM_UE_12_DL_TRF3_DATA}
     Exe egate cmd     cmd=${CM_UE_12_UL_TRF1_DATA}
     Sleep      5



CB009527 UE13 Data
     Exe egate cmd     cmd=${CM_UE_13_DL_TRF3_DATA}
     Exe egate cmd     cmd=${CM_UE_13_UL_TRF1_DATA}
     Sleep      5



CB009527 UE14 Data
     Exe egate cmd     cmd=${CM_UE_14_DL_TRF3_DATA}
     Exe egate cmd     cmd=${CM_UE_14_UL_TRF1_DATA}
     Sleep      5


CB009527 UE15 Data
     Exe egate cmd     cmd=${CM_UE_15_DL_TRF3_DATA}
     Exe egate cmd     cmd=${CM_UE_15_UL_TRF1_DATA}
     Sleep      5

CB009527 UE16 Data
     Exe egate cmd     cmd=${CM_UE_16_DL_TRF3_DATA}
     Exe egate cmd     cmd=${CM_UE_16_UL_TRF1_DATA}
     Sleep      5



CB009527 D5 eCPRI WBtoSB SRS UE1
     Exe egate cmd     cmd=${CB009527_D_UE1_CMD1}
     Exe egate cmd     cmd=${CB009527_D_UE1_CMD2}
     Exe egate cmd     cmd=${CB009527_D_UE1_CMD3}
     Exe egate cmd     cmd=${CB009527_D_UE1_CMD4}
     Exe egate cmd     cmd=${CB009527_D_UE1_CMD5}
     Exe egate cmd     cmd=${CB009527_D_UE1_CMD6}
     Exe egate cmd     cmd=${CM_UE_1_STATS}
     Sleep        5

CB009527 D5 eCPRI WBtoSB SRS UE2
     Exe egate cmd     cmd=${CB009527_D_UE2_CMD1}
     Exe egate cmd     cmd=${CB009527_D_UE2_CMD2}
     Exe egate cmd     cmd=${CB009527_D_UE2_CMD3}
     Exe egate cmd     cmd=${CB009527_D_UE2_CMD4}
     Exe egate cmd     cmd=${CB009527_D_UE2_CMD5}
     Exe egate cmd     cmd=${CB009527_D_UE2_CMD6}
     Exe egate cmd     cmd=${CM_UE_2_STATS}
     Sleep        5

CB009527 D5 eCPRI WBtoSB SRS UE3
     Exe egate cmd     cmd=${CB009527_D_UE3_CMD1}
     Exe egate cmd     cmd=${CB009527_D_UE3_CMD2}
     Exe egate cmd     cmd=${CB009527_D_UE3_CMD3}
     Exe egate cmd     cmd=${CB009527_D_UE3_CMD4}
     Exe egate cmd     cmd=${CB009527_D_UE3_CMD5}
     Exe egate cmd     cmd=${CB009527_D_UE3_CMD6}
     Exe egate cmd     cmd=${CM_UE_3_STATS}
     Sleep       5

CB009527 D5 eCPRI WBtoSB SRS UE4
     Exe egate cmd     cmd=${CB009527_D_UE4_CMD1}
     Exe egate cmd     cmd=${CB009527_D_UE4_CMD2}
     Exe egate cmd     cmd=${CB009527_D_UE4_CMD3}
     Exe egate cmd     cmd=${CB009527_D_UE4_CMD4}
     Exe egate cmd     cmd=${CB009527_D_UE4_CMD5}
     Exe egate cmd     cmd=${CB009527_D_UE4_CMD6}
     Exe egate cmd     cmd=${CM_UE_4_STATS}

CB009527 D5 eCPRI WBtoSB SRS UE5
     Exe egate cmd     cmd=${CB009527_D_UE5_CMD1}
     Exe egate cmd     cmd=${CB009527_D_UE5_CMD2}
     Exe egate cmd     cmd=${CB009527_D_UE5_CMD3}
     Exe egate cmd     cmd=${CB009527_D_UE5_CMD4}
     Exe egate cmd     cmd=${CB009527_D_UE5_CMD5}
     Exe egate cmd     cmd=${CB009527_D_UE5_CMD6}
     Exe egate cmd     cmd=${CM_UE_5_STATS}

CB009527 D5 eCPRI WBtoSB SRS UE6
     Exe egate cmd     cmd=${CB009527_D_UE6_CMD1}
     Exe egate cmd     cmd=${CB009527_D_UE6_CMD2}
     Exe egate cmd     cmd=${CB009527_D_UE6_CMD3}
     Exe egate cmd     cmd=${CB009527_D_UE6_CMD4}
     Exe egate cmd     cmd=${CB009527_D_UE6_CMD5}
     Exe egate cmd     cmd=${CB009527_D_UE6_CMD6}
     Exe egate cmd     cmd=${CM_UE_6_STATS}


CB009527 D5 eCPRI WBtoSB SRS UE7
     Exe egate cmd     cmd=${CB009527_D_UE7_CMD1}
     Exe egate cmd     cmd=${CB009527_D_UE7_CMD2}
     Exe egate cmd     cmd=${CB009527_D_UE7_CMD3}
     Exe egate cmd     cmd=${CB009527_D_UE7_CMD4}
     Exe egate cmd     cmd=${CB009527_D_UE7_CMD5}
     Exe egate cmd     cmd=${CB009527_D_UE7_CMD6}
     Exe egate cmd     cmd=${CM_UE_7_STATS}

CB009527 D5 eCPRI WBtoSB SRS UE8
     Exe egate cmd     cmd=${CB009527_D_UE8_CMD1}
     Exe egate cmd     cmd=${CB009527_D_UE8_CMD2}
     Exe egate cmd     cmd=${CB009527_D_UE8_CMD3}
     Exe egate cmd     cmd=${CB009527_D_UE8_CMD4}
     Exe egate cmd     cmd=${CB009527_D_UE8_CMD5}
     Exe egate cmd     cmd=${CB009527_D_UE8_CMD6}
     Exe egate cmd     cmd=${CM_UE_8_STATS}

CB009527 D5 eCPRI WBtoSB SRS UE9
     Exe egate cmd     cmd=${CB009527_D_UE9_CMD1}
     Exe egate cmd     cmd=${CB009527_D_UE9_CMD2}
     Exe egate cmd     cmd=${CB009527_D_UE9_CMD3}
     Exe egate cmd     cmd=${CB009527_D_UE9_CMD4}
     Exe egate cmd     cmd=${CB009527_D_UE9_CMD5}
     Exe egate cmd     cmd=${CB009527_D_UE9_CMD6}
     Exe egate cmd     cmd=${CM_UE_9_STATS}

CB009527 D5 eCPRI WBtoSB SRS UE10
     Exe egate cmd     cmd=${CB009527_D_UE10_CMD1}
     Exe egate cmd     cmd=${CB009527_D_UE10_CMD2}
     Exe egate cmd     cmd=${CB009527_D_UE10_CMD3}
     Exe egate cmd     cmd=${CB009527_D_UE10_CMD4}
     Exe egate cmd     cmd=${CB009527_D_UE10_CMD5}
     Exe egate cmd     cmd=${CB009527_D_UE10_CMD6}
     Exe egate cmd     cmd=${CM_UE_10_STATS}

CB009527 D5 eCPRI WBtoSB SRS UE11
     Exe egate cmd     cmd=${CB009527_D_UE11_CMD1}
     Exe egate cmd     cmd=${CB009527_D_UE11_CMD2}
     Exe egate cmd     cmd=${CB009527_D_UE11_CMD3}
     Exe egate cmd     cmd=${CB009527_D_UE11_CMD4}
     Exe egate cmd     cmd=${CB009527_D_UE11_CMD5}
     Exe egate cmd     cmd=${CB009527_D_UE11_CMD6}
     Exe egate cmd     cmd=${CM_UE_11_STATS}

CB009527 D5 eCPRI WBtoSB SRS UE12
     Exe egate cmd     cmd=${CB009527_D_UE12_CMD1}
     Exe egate cmd     cmd=${CB009527_D_UE12_CMD2}
     Exe egate cmd     cmd=${CB009527_D_UE12_CMD3}
     Exe egate cmd     cmd=${CB009527_D_UE12_CMD4}
     Exe egate cmd     cmd=${CB009527_D_UE12_CMD5}
     Exe egate cmd     cmd=${CB009527_D_UE12_CMD6}
     Exe egate cmd     cmd=${CM_UE_12_STATS}

CB009527 D5 eCPRI WBtoSB SRS UE13
     Exe egate cmd     cmd=${CB009527_D_UE13_CMD1}
     Exe egate cmd     cmd=${CB009527_D_UE13_CMD2}
     Exe egate cmd     cmd=${CB009527_D_UE13_CMD3}
     Exe egate cmd     cmd=${CB009527_D_UE13_CMD4}
     Exe egate cmd     cmd=${CB009527_D_UE13_CMD5}
     Exe egate cmd     cmd=${CB009527_D_UE13_CMD6}
     Exe egate cmd     cmd=${CM_UE_13_STATS}


CB009527 D5 eCPRI WBtoSB SRS UE14
     Exe egate cmd     cmd=${CB009527_D_UE14_CMD1}
     Exe egate cmd     cmd=${CB009527_D_UE14_CMD2}
     Exe egate cmd     cmd=${CB009527_D_UE14_CMD3}
     Exe egate cmd     cmd=${CB009527_D_UE14_CMD4}
     Exe egate cmd     cmd=${CB009527_D_UE14_CMD5}
     Exe egate cmd     cmd=${CB009527_D_UE14_CMD6}
     Exe egate cmd     cmd=${CM_UE_14_STATS}


CB009527 D5 eCPRI WBtoSB SRS UE15
     Exe egate cmd     cmd=${CB009527_D_UE15_CMD1}
     Exe egate cmd     cmd=${CB009527_D_UE15_CMD2}
     Exe egate cmd     cmd=${CB009527_D_UE15_CMD3}
     Exe egate cmd     cmd=${CB009527_D_UE15_CMD4}
     Exe egate cmd     cmd=${CB009527_D_UE15_CMD5}
     Exe egate cmd     cmd=${CB009527_D_UE15_CMD6}
     Exe egate cmd     cmd=${CM_UE_15_STATS}

CB009527 D5 eCPRI WBtoSB SRS UE16
     Exe egate cmd     cmd=${CB009527_D_UE16_CMD1}
     Exe egate cmd     cmd=${CB009527_D_UE16_CMD2}
     Exe egate cmd     cmd=${CB009527_D_UE16_CMD3}
     Exe egate cmd     cmd=${CB009527_D_UE16_CMD4}
     Exe egate cmd     cmd=${CB009527_D_UE16_CMD5}
     Exe egate cmd     cmd=${CB009527_D_UE16_CMD6}
     Exe egate cmd     cmd=${CM_UE_16_STATS}


UL Data
     Exe egate cmd      cmd=${CM_UE_1_UL_DATA}
     Sleep      1

CB006649 UL Data
     Exe egate cmd      cmd=${CM_UE_1_UL_TRF1_DATA}
     Exe egate cmd      cmd=${CM_UE_1_UL_TRF2_DATA}
     Exe egate cmd      cmd=${CM_UE_1_UL_TRF3_DATA}
     Exe egate cmd      cmd=${CM_UE_1_UL_TRF4_DATA}
     Exe egate cmd      cmd=${CM_UE_1_UL_TRF5_DATA}
     Exe egate cmd      cmd=${CM_UE_1_UL_TRF6_DATA}
     Exe egate cmd      cmd=${CM_UE_1_STATS}
     Exe egate cmd      cmd=${CM_UE_1_STATS}
     Exe egate cmd      cmd=${CM_UE_1_STATS}
     Exe egate cmd      cmd=${CM_UE_1_DL_TRF1_DATA}
     Exe egate cmd      cmd=${CM_UE_1_DL_TRF2_DATA}
     Exe egate cmd      cmd=${CM_UE_1_DL_TRF3_DATA}
     Exe egate cmd      cmd=${CM_UE_1_DL_TRF4_DATA}
     Exe egate cmd      cmd=${CM_UE_1_DL_TRF5_DATA}
     Exe egate cmd      cmd=${CM_UE_1_DL_TRF6_DATA}
     Exe egate cmd      cmd=${CM_UE_1_STATS}
     Exe egate cmd      cmd=${CM_UE_1_UL_TRF7_DATA}
     Exe egate cmd      cmd=${CM_UE_1_STATS}
     Exe egate cmd      cmd=${CM_UE_1_UL_TRF8_DATA}
     Exe egate cmd      cmd=${CM_UE_1_STATS}
     Exe egate cmd      cmd=${CM_UE_1_UL_TRF9_DATA}
     Exe egate cmd      cmd=${CM_UE_1_STATS}
     Exe egate cmd      cmd=${CM_UE_1_UL_TRF10_DATA}
     Exe egate cmd      cmd=${CM_UE_1_STATS}
     Exe egate cmd      cmd=${CM_UE_1_UL_TRF11_DATA}
     Exe egate cmd      cmd=${CM_UE_1_STATS}
     Exe egate cmd      cmd=${CM_UE_1_STATS}
     Exe egate cmd      cmd=${CM_UE_1_STATS}
     Sleep      10
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_SCELL_ACTIVATED}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Sleep      10
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_SCELL_MOD_LIST}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Sleep      10


UE Deregister
     Exe egate cmd      cmd=${CM_UE_1_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

CB009527 Suite Setup
     Log to console      "suite setup - starting sos report with BIP"
     Start SOS with BIP     ${sos_script_path}
     Sleep     10
     Start Logs      ${L_AP_GNB_SYS}

CB009527 Suite Teardown
     Log to console      "suite teardown - stopping and collecting sos report with BIP "
     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
     Sleep     10
     Stop Logs     ${L_AP_GNB_SYS}
#     Cleanup Process After TC


Validate 4 UE RANK2 Paired Data Rate
     Exe egate cmd      cmd=${CM_UE_1_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>90
     Exe egate cmd      cmd=${CM_UE_2_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>90
     Exe egate cmd      cmd=${CM_UE_3_STATS}
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>90
     Exe egate cmd      cmd=${CM_UE_4_STATS}
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>90

Validate 8 UE RANK1 Paired Data Rate
     Exe egate cmd      cmd=${CM_UE_1_STATS}
     Sleep      5
#     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>50
     Exe egate cmd      cmd=${CM_UE_2_STATS}
     Sleep      5
#     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>40
     Exe egate cmd      cmd=${CM_UE_3_STATS}
#     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>40
     Exe egate cmd      cmd=${CM_UE_4_STATS}
#     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>40
     Exe egate cmd      cmd=${CM_UE_5_STATS}
#     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>40
     Exe egate cmd      cmd=${CM_UE_6_STATS}
#     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>40
     Exe egate cmd      cmd=${CM_UE_7_STATS}
#     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>40
     Exe egate cmd      cmd=${CM_UE_8_STATS}
#     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>40

Validate 2UE RANK2 Paired in TTI logs
     Convert TTI trace from pcap to excelCsv      pcap_path=/home/ute/logs/l2stream3/tcpdump/tcpdump.pcap
     ...      output_path_with_tag=/home/ute/logs/l2stream3/tcpdump/     decode_format=excelCsv
     ta_a2a.interface.Check Logs With Au2anlysis      ini_path=${CURDIR}/../../ini/CB008235_4_RANK2_UE.ini    log_need_to_check=i
     ...    save_log_directory=/home/ute/logs/l2stream3/


Validate 4UE RANK2 Paired in TTI logs
     Convert TTI trace from pcap to excelCsv      pcap_path=/home/ute/logs/l2stream3/tcpdump/tcpdump.pcap
     ...      output_path_with_tag=/home/ute/logs/l2stream3/tcpdump/     decode_format=excelCsv
     ta_a2a.interface.Check Logs With Au2anlysis      ini_path=${CURDIR}/../../ini/CB008235_4_RANK2_UE.ini    log_need_to_check=i
     ...    save_log_directory=/home/ute/logs/l2stream3/

Validate 8UE RANK1 Paired in TTI logs
     Convert TTI trace from pcap to excelCsv      pcap_path=/home/ute/logs/l2stream3/tcpdump/tcpdump.pcap
     ...      output_path_with_tag=/home/ute/logs/l2stream3/tcpdump/     decode_format=excelCsv
     ta_a2a.interface.Check Logs With Au2anlysis      ini_path=${CURDIR}/../../ini/CB008235_8_RANK1_UE.ini    log_need_to_check=i
     ...    save_log_directory=/home/ute/logs/l2stream3/
