*** Settings ***
Documentation    :copyright    : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : Contains Keyword needed for CB008235-A
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com

Resource    ../../../../resources/Keywords/general_common_keywords.robot
Library     ta_a2a.interface


*** Keywords ***
L3 Suite Setup
     Log to console      "suite setup"

L3 Suite Teardown
     Log to console      "suite teardown"

UE Attach
     Exe egate cmd      cmd=${CM_UE1_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE1_X2LINK}
     Exe egate cmd      cmd=${CM_UE_1_ATTACH}
     Sleep      5
     Exe egate cmd      cmd=${SET_ENDC}        return_output=False
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NSA_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}



Bearer Setup
     Exe egate cmd      cmd=${BEARER_SPLIT}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_DUAL_CON}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UL Data
     Exe egate cmd      cmd=${CM_UE_1_UL_DATA}

DL Data
     Exe egate cmd      cmd=${CM_UE_1_DL_DATA}


UE Dettach
     Exe egate cmd      cmd=${CM_UE_DETTACH}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE11_DETTACH}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

INTRALTE handover
    Exe egate cmd      cmd=${LTE_HO_11}
    Validate     log=${L_EGATE_CONSOLE}      element=${VER_HO}
    ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}


Carrier Aggregation
    Exe egate cmd      cmd=${A1_measurement}
    Sleep       5
    Validate     log=${L_EGATE_CONSOLE}      element=${Scell_activation}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
    Exe egate cmd      cmd=${A2_measurement}
    Sleep       5
    Validate     log=${L_EGATE_CONSOLE}      element=${VER_A2}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

Location Update
    Exe egate cmd      cmd=${Location_Update}
    Sleep       1
    Validate     log=${L_EGATE_CONSOLE}      element=${VER_Location}
    ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
