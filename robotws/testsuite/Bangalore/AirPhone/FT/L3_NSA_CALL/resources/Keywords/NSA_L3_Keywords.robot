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

UE Attach and Bearer Setup
     Exe egate cmd      cmd=${CM_UE1_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE1_X2LINK}
     Exe egate cmd      cmd=${CM_UE_1_ATTACH}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NSA_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Sleep      5
     Exe egate cmd      cmd=${SET_ENDC}        return_output=False
     Exe egate cmd      cmd=${BEARER_SPLIT}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_DUAL_CON}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UL Data
     Exe egate cmd      cmd=${CM_UE_1_UL_DATA}
     Sleep      1

DL Data
     Exe egate cmd      cmd=${CM_UE_1_DL_DATA}
     Sleep      1

UE Dettach
     Exe egate cmd      cmd=${CM_UE_DETTACH}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE11_DETTACH}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
