*** Settings ***
Documentation    :copyright    : Nokia
                 ...              :author       : Shivalingesh
                 ...              :contact      : Shivalingesh Sheelavantar
                 ...              :Description  : Contains Keyword needed for CB007880
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,24.10.2025, Shivalingesh

Resource    ../../../../resources/Keywords/general_common_keywords.robot

*** Keywords ***
CB007880 Suite Setup
     Log to console      "suite setup"

CB007880 Suite Teardown
     Log to console      "suite teardown"

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

UE Register 2 and PDU Session
     Exe egate cmd      cmd=${CM_UE2_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE_2_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_2_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE Register 3 and PDU Session
     Exe egate cmd      cmd=${CM_UE3_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE_3_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_3_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE Register 4 and PDU Session
     Exe egate cmd      cmd=${CM_UE4_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE_4_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_4_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UL Data
     Exe egate cmd      cmd=${CM_UE_1_UL_2_MBPS_DATA}
     Sleep      1

DL Data
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

UE1 TRP POS INFO VALIDATION
     Exe egate cmd        cmd=${LMF_CMD_TRP_SRS_TRANS_UE1}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_TRP_SEND_POS_INFO_UE1}         return_output=False
     Exe egate cmd        cmd=${LMF_CMD_TRP_MEAS_REQ_OBJ_UE1}           return_output=False
     Exe egate cmd        cmd=${LMF_CMD_TRP_MEAS_QTY_ITEM_OBJ_UE1}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_TRP_SRS_RES_CONFIG_OBJ_UE1}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_TRP_SRS_RES_CHECK_POS_MSG_UE_1}        return_output=False
     Exe egate cmd        cmd=${LMF_CMD_TRP_SRS_POINTA_UE_1}                 return_output=False
     Exe egate cmd        cmd=${LMF_CMD_TRP_SET_CONFIG_OBJ_CARRIER_UE_1}            return_output=False
     Exe egate cmd        cmd=${LMF_CMD_TRP_SEND_MEAS_REQ_UE_1}             return_output=False

UE1 NRPOS MULTICELL TRP INFO VALIDATION
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SRS_TRANS_UE1}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SEND_POS_INFO_UE1}         return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_MEAS_REQ_OBJ_UE1}           return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_MEAS_QTY_ITEM_OBJ_UE1}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SRS_RES_CONFIG_OBJ_UE1}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SRS_RES_CHECK_POS_MSG_UE_1}        return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SRS_POINTA_UE_1}                 return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SET_CONFIG_OBJ_CARRIER_UE_1}            return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SEND_MEAS_REQ_UE_1}             return_output=False

UE2 NRPOS MULTICELL TRP INFO VALIDATION
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SRS_TRANS_UE2}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SEND_POS_INFO_UE2}         return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_MEAS_REQ_OBJ_UE2}           return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_MEAS_QTY_ITEM_OBJ_UE2}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SRS_RES_CONFIG_OBJ_UE2}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SRS_RES_CHECK_POS_MSG_UE_2}        return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SRS_POINTA_UE_2}                 return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SET_CONFIG_OBJ_CARRIER_UE_2}            return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SEND_MEAS_REQ_UE_2}               return_output=False

UE3 NRPOS MULTICELL TRP INFO VALIDATION
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SRS_TRANS_UE3}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SEND_POS_INFO_UE3}         return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_MEAS_REQ_OBJ_UE3}           return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_MEAS_QTY_ITEM_OBJ_UE3}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SRS_RES_CONFIG_OBJ_UE3}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SRS_RES_CHECK_POS_MSG_UE_3}        return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SRS_POINTA_UE_3}                 return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SET_CONFIG_OBJ_CARRIER_UE_3}            return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SEND_MEAS_REQ_UE_3}                        return_output=False

UE4 NRPOS MULTICELL TRP INFO VALIDATION
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SRS_TRANS_UE4}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SEND_POS_INFO_UE4}         return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_MEAS_REQ_OBJ_UE4}           return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_MEAS_QTY_ITEM_OBJ_UE4}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SRS_RES_CONFIG_OBJ_UE4}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SRS_RES_CHECK_POS_MSG_UE_4}        return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SRS_POINTA_UE_4}                 return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SET_CONFIG_OBJ_CARRIER_UE_4}            return_output=False
     Exe egate cmd        cmd=${LMF_CMD_D_NRPOS_TRP_SEND_MEAS_REQ_UE_4}                      return_output=False

SUPERCELL TRP CHECK
     Exe egate cmd        cmd=${LMF_CMD_SUPER_1_TRP_SRS_TRANS_1}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_1_SEND_POS_INFO_1}        return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_2_SEND_REQ_INFO_2}           return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_2_TRP_SRS_TRANS_2}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_2_SEND_POS_INFO_2}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_2_TRP_MEAS_REQ_2}           return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_1_TRP_MEAS_REQ_1}                  return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_1_TRP_MEAS_QTY_UL_RTOA_1}             return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_1_RES_CONFIG_PEAIOD_1}              return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_2_TRP_MEAS_QTY_UL_RTOA_2}           return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_2_RES_CONFIG_PEAIOD_2}           return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_1_FIRST_1}             return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_1_SECOND_1}            return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_2_FIRST_2}             return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_2_SECOND_2}                   return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_1_SRS_CONFIG_OBJ_1}          return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_2_SRS_CONFIG_OBJ_2}         return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_1_MEASREMENT_REQ_1}         return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_2_MEASREMENT_REQ_2}         return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_1_UE_PRECISE_POS_1}         return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_1_UE_TESTMODE_SET_NR_1}            return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_2_UE_PRECISE_POS_2}            return_output=False
     Exe egate cmd        cmd=${LMF_CMD_SUPER_2_UE_TESTMODE_SET_NR_2}           return_output=False
     Sleep      5

UE Deregister
     Exe egate cmd      cmd=${CM_UE_1_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
