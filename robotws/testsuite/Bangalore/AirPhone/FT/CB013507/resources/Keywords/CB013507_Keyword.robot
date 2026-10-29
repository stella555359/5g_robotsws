*** Settings ***
Documentation    :copyright    : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : Contains Keyword needed for CB008235-A
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com

Resource    ../../../resources/Keywords/general_common_keywords.robot

*** Keywords ***
L3 Suite Setup
     Log to console      "suite setup"

L3 Suite Teardown
     Log to console      "suite teardown"

CB013507 Suite Setup
     Log to console      "suite setup"

CB013507 Suite Teardown
     Log to console      "suite teardown"

UE1 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE1_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE_1_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE2 Register  and PDU Session
     Exe egate cmd      cmd=${CM_UE2_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE_2_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_2_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE52 Register  and PDU Session
     Exe egate cmd      cmd=${CM_UE_52_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE_52_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_52_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}


UE53 Register  and PDU Session
     Exe egate cmd      cmd=${CM_UE_53_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE_53_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_53_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

DL53 Data
    Exe egate cmd      cmd=${CM_UE_53_DL_DATA}
     Sleep      1

UL53 Data
     Exe egate cmd      cmd=${CM_UE_53_UL_DATA}
     Sleep      1

UL1 Data
     Exe egate cmd      cmd=${CM_UE_1_UL_DATA}
     Sleep      1

UL2 Data
     Exe egate cmd      cmd=${CM_UE_2_UL_DATA}
     Sleep      1
DL1 Data
    Exe egate cmd      cmd=${CM_UE_1_DL_DATA}
     Sleep      1

UL52 Data
     Exe egate cmd      cmd=${CM_UE_52_UL_DATA}
     Sleep      1

DL52 Data
    Exe egate cmd       cmd=${CM_UE_52_UL_DATA}
     Sleep      1

DL2 Data
    Exe egate cmd      cmd=${CM_UE_2_UL_DATA}
    Sleep      1

UE1 Deregister
     Exe egate cmd      cmd=${CM_UE_1_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE52 Deregister
     Exe egate cmd      cmd=${CM_UE_52_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE53 Deregister
     Exe egate cmd      cmd=${CM_UE_53_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}


CB013507 TC01 IMF for UE1
     Exe egate cmd      cmd=${IMF_CMD_CB013507_UE1_TC01}

CB013507 TC01 IMF for UE2
     Exe egate cmd      cmd=${IMF_CMD_CB013507_UE2_TC01}

CB013507 TC01 IMF for UE53
     Exe egate cmd      cmd=${IMF_CMD_CB013507_UE53_TC01}

CB013507 TC02 DELAY PR1
     Exe egate cmd         cmd=${CB013507_UE_TA_NR_CMD1_TC02_PR1}
     Exe egate cmd         cmd=${CB013507_UE_TA_NR_CMD2_TC02_PR1}
     Exe egate cmd         cmd=${CB013507_UE_TA_NR_CMD3_TC02_PR1}

CB013507 TC02 DELAY PR1 UE53
     Exe egate cmd         cmd=${CB013507_UE_53_TA_NR_CMD1_TC02_PR1}
     Exe egate cmd         cmd=${CB013507_UE_53_TA_NR_CMD2_TC02_PR1}
     Exe egate cmd         cmd=${CB013507_UE_53_TA_NR_CMD3_TC02_PR1}



CB013507 TC02 DELAY PR2
     Exe egate cmd         cmd=${CB013507_UE_TA_NR_CMD1_TC02_PR2}
     Exe egate cmd         cmd=${CB013507_UE_TA_NR_CMD2_TC02_PR2}
     Exe egate cmd         cmd=${CB013507_UE_TA_NR_CMD3_TC02_PR2}

CB013507 TC02 DELAY PR2 UE53
     Exe egate cmd         cmd=${CB013507_UE_53_TA_NR_CMD1_TC02_PR2}
     Exe egate cmd         cmd=${CB013507_UE_53_TA_NR_CMD2_TC02_PR2}
     Exe egate cmd         cmd=${CB013507_UE_53_TA_NR_CMD3_TC02_PR2}

CB013507 TC03
     Exe egate cmd         cmd=${CM_UE_52_DL_BEARER}
     Exe egate cmd         cmd=${CM_UE_52_DL_BEARER}
     Exe egate cmd         cmd=${IMF_CMD_CB013507_UE52_TC01}

Validate CSV Values
       ${rows}=    Read CSV File       ${FILE PATH_CSV_CHECK}
       FOR    ${row}    IN    @{rows}
         Run Keyword If    ${len(row)} >= 2    Validate Row    ${row[0]}    ${row[1]}
       END


Validate CSV Range From File
    [Arguments]    ${csv_file}
    [Documentation]    Calls Python function with the CSV file path and validates result.
    ${result}=    Check All Values From Csv    ${csv_file}
    Run Keyword If    '${result}' == 'FAIL'    Fail    ❌ CSV check failed for file: ${csv_file}
    Log    ✅ CSV check passed for file: ${csv_file}


Validate Row
   [Arguments]    ${val1}    ${val2}
   ${val1}=    Convert To Integer    ${val1}
   ${val2}=    Convert To Integer    ${val2}CB013507 TC02 DELAY PR1
   Run Keyword If    ${val1} >= 128 and ${val1} <= 3150848 and ${val2} >= 0 and ${val2} <= 1024
   ...    Log To Console    Yes - The value is correct as per scenario

UE2 Deregister
     Exe egate cmd      cmd=${CM_UE_2_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
