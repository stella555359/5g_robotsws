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

UE1 UL Data
     Exe egate cmd      cmd=${CM_UE_1_UL_DATA}
     Sleep      1

UE1 DL Data
    Exe egate cmd      cmd=${CM_UE_1_DL_DATA}
     Sleep      1
UE1 DRB drop 1st time
    Exe egate cmd      cmd=${UE1_DRB_drop_1st_time}
    sleep       5
    Exe egate cmd      cmd=${UE1_DRB_drop_1st_time_activate}
    sleep       5
UE1 DRB drop 2nd time
    Exe egate cmd      cmd=${UE1_DRB_drop_2nd_time}
    sleep       5
    Exe egate cmd      cmd=${UE1_DRB_drop_2nd_time_activate}
    sleep       5
    Validate     log=${L_EGATE_CONSOLE}      element=${UE1_intra_cell_HO}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE1 SRB2 drop 1st time
    Exe egate cmd      cmd=${UE1_SRB2_drop_1st_time}
    sleep       5
    Exe egate cmd      cmd=${UE1_SRB2_drop_1st_time_activate}
    sleep       5
    Exe egate cmd      cmd=${UE1_SRB2_message_send_1st_time}
    sleep       5

UE1 SRB2 drop 2nd time
    Exe egate cmd      cmd=${UE1_SRB2_drop_2nd_time}
    sleep       5
    Exe egate cmd      cmd=${UE1_SRB2_drop_2nd_time_activate}
    sleep       5
    Exe egate cmd      cmd=${UE1_SRB2_message_send_2nd_time}
    sleep       5
    Validate     log=${L_EGATE_CONSOLE}      element=${UE1_intra_cell_HO}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE1 Deregister
     Exe egate cmd      cmd=${CM_UE_1_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
UE2 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE2_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE_2_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_2_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE2 UL Data
     Exe egate cmd      cmd=${CM_UE_2_UL_DATA}
     Sleep      1

UE2 DL Data
    Exe egate cmd      cmd=${CM_UE_2_DL_DATA}
     Sleep      1
UE2 DRB drop 1st time
    Exe egate cmd      cmd=${UE2_DRB_drop_1st_time}
    sleep       5
    Exe egate cmd      cmd=${UE2_DRB_drop_1st_time_activate}
    sleep       5

UE2 DRB drop 2nd time
    Exe egate cmd      cmd=${UE2_DRB_drop_2nd_time}
    sleep       5
    Exe egate cmd      cmd=${UE2_DRB_drop_2nd_time_activate}
    sleep       5
    Validate     log=${L_EGATE_CONSOLE}      element=${UE2_intra_cell_HO}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE2 SRB2 drop 1st time
    Exe egate cmd      cmd=${UE2_SRB2_drop_1st_time}
    sleep       5
    Exe egate cmd      cmd=${UE2_SRB2_drop_1st_time_activate}
    sleep       5
    Exe egate cmd      cmd=${UE2_SRB2_message_send_1st_time}
    sleep       5

UE2 SRB2 drop 2nd time
    Exe egate cmd      cmd=${UE2_SRB2_drop_2nd_time}
    sleep       5
    Exe egate cmd      cmd=${UE2_SRB2_drop_2nd_time_activate}
    sleep       5
    Exe egate cmd      cmd=${UE2_SRB2_message_send_2nd_time}
    sleep       5
    Validate     log=${L_EGATE_CONSOLE}      element=${UE2_intra_cell_HO}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE2 Deregister
     Exe egate cmd      cmd=${CM_UE_2_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE2_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
UE3 Register and PDU Session
     Exe egate cmd      cmd=${CM_UE3_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE_3_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_3_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE3 UL Data
     Exe egate cmd      cmd=${CM_UE_3_UL_DATA}
     Sleep      1

UE3 DL Data
    Exe egate cmd      cmd=${CM_UE_3_DL_DATA}
     Sleep      1
UE3 DRB drop 1st time
    Exe egate cmd      cmd=${UE3_DRB_drop_1st_time}
    sleep       5
    Exe egate cmd      cmd=${UE3_DRB_drop_1st_time_activate}
    sleep       5

UE3 DRB drop 2nd time
    Exe egate cmd      cmd=${UE3_DRB_drop_2nd_time}
    sleep       5
    Exe egate cmd      cmd=${UE3_DRB_drop_2nd_time_activate}
    sleep       5
    Validate     log=${L_EGATE_CONSOLE}      element=${UE3_intra_cell_HO}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE3 SRB2 drop 1st time
    Exe egate cmd      cmd=${UE3_SRB2_drop_1st_time}
    sleep       5
    Exe egate cmd      cmd=${UE3_SRB2_drop_1st_time_activate}
    sleep       5
    Exe egate cmd      cmd=${UE3_SRB2_message_send_1st_time}
    sleep       5

UE3 SRB2 drop 2nd time
    Exe egate cmd      cmd=${UE3_SRB2_drop_2nd_time}
    sleep       5
    Exe egate cmd      cmd=${UE3_SRB2_drop_2nd_time_activate}
    sleep       5
    Exe egate cmd      cmd=${UE3_SRB2_message_send_2nd_time}
    sleep       5
    Validate     log=${L_EGATE_CONSOLE}      element=${UE3_intra_cell_HO}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE3 Deregister
     Exe egate cmd      cmd=${CM_UE_3_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE2_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

emergency call
    Exe egate cmd      cmd=${EMR_CALL}

UE Register with HPA
     Exe egate cmd       cmd=${CM_UE2_DTYPE_INTERNAL}      return_output=False
     Sleep      5
     Exe egate cmd       cmd=${CM_UE2_RRC_SETUP_HPA}       return_output=False
     Sleep      5
     Exe egate cmd       cmd=${CM_UE2_REGISTER}
     Sleep      5
     Exe egate cmd       cmd=${CM_UE2_PDU_SESSION}
     Sleep      5

UE Register with EMR
     Exe egate cmd       cmd=${CM_UE3_DTYPE_INTERNAL}       return_output=False
     Sleep      5
     Exe egate cmd       cmd=${CM_UE3_RRC_SETUP_EMR}        return_output=False
     Sleep      5
     Exe egate cmd       cmd=${CM_UE3_REGISTER}
     Sleep      5
     Exe egate cmd       cmd=${CM_UE3_PDU_SESSION}
     Sleep      5

PDU session modify
    Exe egate cmd        cmd=${QOS_modify_7}
    Sleep      5
    Exe egate cmd        cmd=${QOS_modify_8}
    Sleep      5
    Exe egate cmd        cmd=${QOS_modify_9}
    Sleep      5

Inter gNB HO
    Exe egate cmd        cmd=${Inter_gNB_HO}
    Sleep      5

