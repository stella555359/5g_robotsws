*** Settings ***
Documentation    :copyright    : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : Contains Keyword needed for CB008235-A
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com

Resource       ../../../../resources/Keywords/general_common_keywords.robot
Resource       ../../../../resources/Keywords/gnbbip_convert.robot

*** Keywords ***
CB009543 Suite Setup
     Log to console      "suite setup"

CB009543 Suite Teardown
     Log to console      "suite teardown"


CB009543 PROFILE BASIC UE1
      Exe egate cmd      cmd=${CM_UE1_DTYPE_INTERNAL}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_CREATE_UE1}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_ACTIVATION_UE1}      return_output=False
      Exe egate cmd      cmd=${CM_UE_1_REGISTER}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
      Exe egate cmd      cmd=${CM_UE_1_PDU_SESSION}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

CB009543 PROFILE BASIC UE2
      Exe egate cmd      cmd=${CM_UE2_DTYPE_INTERNAL}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_CREATE_UE2}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_ACTIVATION_UE2}      return_output=False
      Exe egate cmd      cmd=${CM_UE_2_REGISTER}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
      Exe egate cmd      cmd=${CM_UE_2_PDU_SESSION}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

CB009543 PROFILE BASIC UE3
      Exe egate cmd      cmd=${CM_UE3_DTYPE_INTERNAL}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_CREATE_UE3}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_ACTIVATION_UE3}      return_output=False
      Exe egate cmd      cmd=${CM_UE_3_REGISTER}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
      Exe egate cmd      cmd=${CM_UE_3_PDU_SESSION}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

CB009543 PROFILE BASIC UE4
      Exe egate cmd      cmd=${CM_UE4_DTYPE_INTERNAL}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_CREATE_UE4}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_ACTIVATION_UE4}      return_output=False
      Exe egate cmd      cmd=${CM_UE_4_REGISTER}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
      Exe egate cmd      cmd=${CM_UE_4_PDU_SESSION}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

CB009543 PROFILE BASIC UE5
      Exe egate cmd      cmd=${CM_UE5_DTYPE_INTERNAL}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_CREATE_UE5}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_ACTIVATION_UE5}      return_output=False
      Exe egate cmd      cmd=${CM_UE_5_REGISTER}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
      Exe egate cmd      cmd=${CM_UE_5_PDU_SESSION}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

CB009543 PROFILE BASIC UE6
      Exe egate cmd      cmd=${CM_UE6_DTYPE_INTERNAL}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_CREATE_UE6}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_ACTIVATION_UE6}      return_output=False
      Exe egate cmd      cmd=${CM_UE_6_REGISTER}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
      Exe egate cmd      cmd=${CM_UE_6_PDU_SESSION}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

CB009543 PROFILE BASIC UE7
      Exe egate cmd      cmd=${CM_UE7_DTYPE_INTERNAL}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_CREATE_UE7}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_ACTIVATION_UE7}      return_output=False
      Exe egate cmd      cmd=${CM_UE_7_REGISTER}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
      Exe egate cmd      cmd=${CM_UE_7_PDU_SESSION}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

CB009543 PROFILE BASIC UE8
      Exe egate cmd      cmd=${CM_UE8_DTYPE_INTERNAL}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_CREATE_UE8}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_ACTIVATION_UE8}      return_output=False
      Exe egate cmd      cmd=${CM_UE_8_REGISTER}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
      Exe egate cmd      cmd=${CM_UE_8_PDU_SESSION}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

CB009543 PROFILE BASIC UE9
      Exe egate cmd      cmd=${CM_UE9_DTYPE_INTERNAL}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_CREATE_UE9}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_ACTIVATION_UE9}      return_output=False
      Exe egate cmd      cmd=${CM_UE_9_REGISTER}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
      Exe egate cmd      cmd=${CM_UE_9_PDU_SESSION}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

CB009543 PROFILE BASIC UE10
      Exe egate cmd      cmd=${CM_UE10_DTYPE_INTERNAL}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_CREATE_UE10}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_ACTIVATION_UE10}      return_output=False
      Exe egate cmd      cmd=${CM_UE_10_REGISTER}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
      Exe egate cmd      cmd=${CM_UE_10_PDU_SESSION}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

CB009543 PROFILE BASIC UE11
      Exe egate cmd      cmd=${CM_UE11_DTYPE_INTERNAL}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_CREATE_UE11}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_ACTIVATION_UE11}      return_output=False
      Exe egate cmd      cmd=${CM_UE_11_REGISTER}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
      Exe egate cmd      cmd=${CM_UE_11_PDU_SESSION}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

CB009543 PROFILE BASIC UE12
      Exe egate cmd      cmd=${CM_UE12_DTYPE_INTERNAL}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_CREATE_UE12}      return_output=False
      Exe egate cmd      cmd=${FDD_SUPER_PROFILE_ACTIVATION_UE12}      return_output=False
      Exe egate cmd      cmd=${CM_UE_12_REGISTER}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
      Exe egate cmd      cmd=${CM_UE_12_PDU_SESSION}
      Sleep      5
      Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
      ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}


#SUBCELL 2 UE 1- 10
CB009543 SWITCH SUBCELL 2 UE 1
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_2_UE1}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 2 UE 2
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_2_UE2}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 2 UE 3
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_2_UE3}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 2 UE 4
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_2_UE4}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 2 UE 5
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_2_UE5}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 2 UE 6
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_2_UE6}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 2 UE 7
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_2_UE7}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 2 UE 8
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_2_UE8}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 2 UE 9
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_2_UE9}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 2 UE 10
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_2_UE10}      return_output=False
     Sleep      5


#SUBCELL 3 UE 1- 10
CB009543 SWITCH SUBCELL 3 UE 1
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_3_UE1}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 3 UE 2
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_3_UE2}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 3 UE 3
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_3_UE3}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 3 UE 4
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_3_UE4}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 3 UE 5
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_3_UE5}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 3 UE 6
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_3_UE6}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 3 UE 7
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_3_UE7}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 3 UE 8
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_3_UE8}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 3 UE 9
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_3_UE9}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 3 UE 10
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_3_UE10}      return_output=False
     Sleep      5

#SUBCELL 4 UE 1- 10
CB009543 SWITCH SUBCELL 4 UE 1
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_4_UE1}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 4 UE 2
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_4_UE2}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 4 UE 3
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_4_UE3}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 4 UE 4
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_4_UE4}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 4 UE 5
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_4_UE5}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 4 UE 6
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_4_UE6}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 4 UE 7
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_4_UE7}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 4 UE 8
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_4_UE8}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 4 UE 9
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_4_UE9}      return_output=False
     Sleep      5

CB009543 SWITCH SUBCELL 4 UE 10
     Exe egate cmd      cmd=${FDD_SUPER_SUBCELL_SWITCH_4_UE10}      return_output=False
     Sleep      5
UE1 UL Data
     Exe egate cmd      cmd=${CM_UE_1_UL_2_MBPS_DATA}
     Sleep      1

UE1 DL Data
    Exe egate cmd      cmd=${CM_UE_1_DL_2_MBPS_DATA}
    Sleep     1

UE2 UL Data
     Exe egate cmd      cmd=${CM_UE_2_UL_2_MBPS_DATA}
     Sleep      1

UE2 DL Data
    Exe egate cmd      cmd=${CM_UE_2_DL_2_MBPS_DATA}
     Sleep     1

UE3 UL Data
     Exe egate cmd      cmd=${CM_UE_3_UL_2_MBPS_DATA}
     Sleep      1

UE3 DL Data
    Exe egate cmd      cmd=${CM_UE_3_DL_2_MBPS_DATA}
     Sleep     1

UE4 UL Data
     Exe egate cmd      cmd=${CM_UE_4_UL_2_MBPS_DATA}
     Sleep      1

UE4 DL Data
    Exe egate cmd      cmd=${CM_UE_4_DL_2_MBPS_DATA}
    Sleep     1

UE Deregister
     Exe egate cmd      cmd=${CM_UE_1_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
