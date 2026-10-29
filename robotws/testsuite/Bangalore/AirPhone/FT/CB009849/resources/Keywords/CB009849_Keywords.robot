*** Settings ***
Documentation    :copyright    : Nokia
                 ...              :author       : Keerthi Chittoor
                 ...              :contact      : keerthi.chittoor@nokia.com
                 ...              :Description  : Contains Keyword needed for CB008235-A
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,13.05.2025,keerthi.chittoor@nokia.com

Resource    ../../../resources/Keywords/general_common_keywords.robot
Resource    ../../../resources/Variables/general_common_variables.robot

*** Keywords ***
CB009849 Suite Setup
     Log to console      "suite setup"

CB009849 Suite Teardown
     Log to console      "suite teardown"
     Stop Data Traffic
     UE Deregister

SA UE Attach And Send Traffic
     Get cell On Air     iphy=${CB009849_A2_TC_01_IPHY}     scf_delta=${CB009849_A2_TC_01_GNB_SCF}
     ...     cfg=${CB009849_A2_TC_01_WTS}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     UE Register and PDU Session
     User Modify with 5QI5 DRB Addition
     Start Data Traffic and validate

UE Register and PDU Session
     Exe egate cmd      cmd=${CM_UE1_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE_1_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

Start Data Traffic and validate
     Exe egate cmd      cmd=${CM_UE_1_UL_DATA_START}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_UL_Data}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_DL_DATA_START}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DL_Data}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate Data Traffic
     Sleep      2

Validate Data Traffic
     Exe egate cmd      cmd=${CM_UE_1_UL_BEARER_STATS}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_UL_STATS}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_DL_BEARER_STATS}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DL_STATS}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

Transformer precoder Activation for UE1
     Exe egate cmd      cmd=${CM_UE_1_UL_SINR_TARGET_PUSCH}       return_output=False
     Exe egate cmd      cmd=${CM_UE_1_UL_SINR_PATHLOSS}           return_output=False
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_UL_SINR_ACT_1}        return_output=False
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_UL_SINR_ACT_2}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_RRC_RECON_COM}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_TP_ENABLED}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate Data Traffic
     sleep      5

Transformer precoder Deactivation for UE1
     Exe egate cmd      cmd=${CM_UE_1_REV_UL_SINR_TARGET_PUSCH}      return_output=False
     Exe egate cmd      cmd=${CM_UE_1_REV_UL_SINR_PATHLOSS}          return_output=False
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_UL_SINR_ACT_3}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_UL_SINR_ACT_4}           return_output=False
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_RRC_RECON_COM}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_TP_DISABLED}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate Data Traffic
     Sleep      5

User Modify with 5QI5 DRB Addition
     Exe egate cmd      cmd=${CM_UE_1_PDU_Mod_5QI5}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_PDU_Mod_5QI5}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

User Modify with 5QI1 DRB Addition
     Exe egate cmd      cmd=${CM_UE_1_PDU_Mod_5QI1}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_PDU_Mod_5QI1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_TP_ENABLED}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Sleep      5
     Validate Data Traffic
     Sleep      5

User Modify with 5QI1 DRB Release
     Exe egate cmd      cmd=${CM_UE_1_PDU_Rel_5QI5}       return_output=False
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_Rel_5QI1}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_TP_DISABLED}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate Data Traffic
     Sleep      5

Stop Data Traffic
     Exe egate cmd      cmd=${CM_UE_1_UL_DATA_STOP}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_DL_DATA_STOP}
     Sleep      5

UE Deregister
     Exe egate cmd      cmd=${CM_UE_1_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
