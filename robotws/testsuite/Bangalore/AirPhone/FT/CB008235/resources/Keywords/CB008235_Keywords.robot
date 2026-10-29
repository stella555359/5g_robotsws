** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : Contains Keyword needed for CB008235-A
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,17.01.2025,vadivelan.manickavasagam@nokia.com

Resource    ../../../resources/Keywords/general_common_keywords.robot
Resource    ../Variables/CB012564_variables.robot
Library     ../Python/tti_csv_filter_element_value.py
Library     ../Python/extract_uestats.py
Library     ta_a2a.interface

*** Keywords ***
CB008235 Suite Setup
     Clean up Preparation before TC
     Add Rad Param Or Modify GNB swconfig    0x580936=0     0x5900FE=4      0x5900FF=4     0x8000a6=0
     Add Rad Param Or Modify AP swconfig     0x10043=51011     0x10040=1
#     Log to console      "suite setup - starting sos report with BIP"
#     Start SOS with BIP     ${sos_script_path}
     Sleep     10
     Start Logs      ${L_AP_GNB_SYS}

CB008235 Suite Teardown
     Log to console      "suite teardown - stopping and collecting sos report with BIP "
##     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
     Sleep     10
     Stop Logs     ${L_AP_GNB_SYS}
     Collect Cfg and egate logs
#     Cleanup Process After TC

CB008235 x2 link up
     Exe egate cmd      cmd=${CM_NSA_X2LINK}

CB008235 SA Call UE1 to UE16
     CB008235 SA Call UE1 to UE8
     CB008235 SA Call UE9 to UE16

Validate 16 UE RANK2 Paired Data Rate
     Exe egate cmd      cmd=ue_stat_nr id=1-16 type=pusch

NSA Call UE11 to UE14
     Exe egate cmd      cmd=${CM_NSA_UE_11_ATTACH}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NSA_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_SET_ENDC}        return_output=False
     Exe egate cmd      cmd=${CM_NSA_UE11_TRIGGER_ENDC}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_DUAL_CON}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_UE_11_DL_DATA}
     Exe egate cmd      cmd=${CM_NSA_UE_11_UL_DATA}
     Exe egate cmd      cmd=${CM_NSA_UE_12_ATTACH}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NSA_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_SET_ENDC}        return_output=False
     Exe egate cmd      cmd=${CM_NSA_UE12_TRIGGER_ENDC}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_DUAL_CON}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_UE_12_DL_DATA}
     Exe egate cmd      cmd=${CM_NSA_UE_12_UL_DATA}

     Exe egate cmd      cmd=${CM_NSA_UE_13_ATTACH}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NSA_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_SET_ENDC}        return_output=False
     Exe egate cmd      cmd=${CM_NSA_UE13_TRIGGER_ENDC}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_DUAL_CON}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_UE_13_DL_DATA}
     Exe egate cmd      cmd=${CM_NSA_UE_13_UL_DATA}

     Exe egate cmd      cmd=${CM_NSA_UE_14_ATTACH}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NSA_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Sleep      1
     Exe egate cmd      cmd=${CM_NSA_SET_ENDC}        return_output=False
     Exe egate cmd      cmd=${CM_NSA_UE14_TRIGGER_ENDC}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_DUAL_CON}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_UE_14_DL_DATA}
     Exe egate cmd      cmd=${CM_NSA_UE_14_UL_DATA}

NSA Call UE15 to UE18
     Exe egate cmd      cmd=${CM_NSA_UE_15_ATTACH}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NSA_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_SET_ENDC}        return_output=False
     Exe egate cmd      cmd=${CM_NSA_UE15_TRIGGER_ENDC}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_DUAL_CON}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_UE_15_DL_DATA}
     Exe egate cmd      cmd=${CM_NSA_UE_15_UL_DATA}
     Exe egate cmd      cmd=${CM_NSA_UE_16_ATTACH}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NSA_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_SET_ENDC}        return_output=False
     Exe egate cmd      cmd=${CM_NSA_UE16_TRIGGER_ENDC}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_DUAL_CON}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_UE_16_DL_DATA}
     Exe egate cmd      cmd=${CM_NSA_UE_16_UL_DATA}
     Exe egate cmd      cmd=${CM_NSA_UE_17_ATTACH}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NSA_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Sleep      1
     Exe egate cmd      cmd=${CM_NSA_SET_ENDC}        return_output=False
     Exe egate cmd      cmd=${CM_NSA_UE17_TRIGGER_ENDC}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_DUAL_CON}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_UE_17_DL_DATA}
     Exe egate cmd      cmd=${CM_NSA_UE_17_UL_DATA}
     Exe egate cmd      cmd=${CM_NSA_UE_18_ATTACH}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NSA_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_SET_ENDC}        return_output=False
     Exe egate cmd      cmd=${CM_NSA_UE18_TRIGGER_ENDC}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_DUAL_CON}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_UE_18_DL_DATA}
     Exe egate cmd      cmd=${CM_NSA_UE_18_UL_DATA}

AVQC NSA UE11 to UE18 Beam Pos Activation
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_08_11_AVQC}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_08_12_AVQC}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_08_13_AVQC}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_08_14_AVQC}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_08_15_AVQC}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_08_16_AVQC}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_08_17_AVQC}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_08_18_AVQC}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_08_11_AVQC_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_08_12_AVQC_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_08_13_AVQC_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_08_14_AVQC_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_08_15_AVQC_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_08_16_AVQC_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_08_17_AVQC_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_08_18_AVQC_ACT}
     Sleep     1

NSA UE11 to UE18 Beam Pos Activation
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_1}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_2}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_3}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_4}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_5}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_6}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_7}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_8}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_08_11_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_08_12_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_08_13_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_08_14_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_08_15_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_08_16_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_08_17_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_08_18_ACT}

NSA Detach UE11 to UE14
     Exe egate cmd      cmd=${CM_NSA_UE_11_DETTACH}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NSA_DETTACH}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_UE_12_DETTACH}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NSA_DETTACH}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_UE_13_DETTACH}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NSA_DETTACH}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_UE_14_DETTACH}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NSA_DETTACH}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

NSA Detach UE15 to UE18
     Exe egate cmd      cmd=${CM_NSA_UE_15_DETTACH}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NSA_DETTACH}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_UE_16_DETTACH}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NSA_DETTACH}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_UE_17_DETTACH}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NSA_DETTACH}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_NSA_UE_18_DETTACH}
     Sleep      1
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NSA_DETTACH}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

CB008235 Ul Sinr Profile Act
     Exe egate cmd      cmd=${CM_UL_SINR_PROFILE_11}
     Exe egate cmd      cmd=${CM_UL_SINR_ACT_16UE}


CB008235 SA Call UE1 to UE4 RANK1
     Log to conslle     "UE 1 TO 4 SA DATA CALL"
     Exe egate cmd      cmd=${CM_UE1_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_1_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_UL_DATA}
     Exe egate cmd      cmd=${CM_UE2_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_2_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_2_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_2_UL_DATA}
     Exe egate cmd      cmd=${CM_UE3_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_3_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_3_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_3_UL_DATA}

     Exe egate cmd      cmd=${CM_UE4_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_4_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_4_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_4_UL_DATA}
     Sleep      2
     Log to console     "UE 1 TO 4 UL DATA stats after POS ACT"
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_1}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_1_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_2}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_2_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_3}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_3_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_4}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_4_ACT}
     Sleep      5

CB008235 SA Call UE1 to UE6 RANK2
     Log to console     "UE 1 TO 6 RANK 2 UES SA DATA CALL start "
     Exe egate cmd      cmd=${CM_UE1_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_1_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_R2_UE_1_UL_DATA}
     Sleep      2

     Exe egate cmd      cmd=${CM_UE2_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_2_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_2_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_R2_UE_2_UL_DATA}
     Sleep      2
     Exe egate cmd      cmd=${CM_UE3_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_3_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_3_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_R2_UE_3_UL_DATA}
     Sleep      2
     Exe egate cmd      cmd=${CM_UE4_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_4_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_4_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_R2_UE_4_UL_DATA}
     Sleep      2
     Exe egate cmd      cmd=${CM_UE5_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_5_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_5_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_R2_UE_5_UL_DATA}
     Sleep      2
     Exe egate cmd      cmd=${CM_UE6_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_6_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_6_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_R2_UE_6_UL_DATA}
     Sleep      2
     Log to console     "AFTER ACT : UE 1 to 6 RANK 2 UE"
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_1}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_1_ACT}
     Sleep      5
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_2}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_2_ACT}
     Sleep      5
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_3}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_3_ACT}
     Sleep      5
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_4}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_4_ACT}
     Sleep      15
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_5}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_5_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_6}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_6_ACT}

CB008235 SA Call UE1 to UE4
     Log to console     "UE 1 TO 4 RANK 2 UES SA DATA CALL start "
     Exe egate cmd      cmd=${CM_UE1_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_1_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_UL_DATA}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE2_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_2}
     Exe egate cmd      cmd=${CM_UE_2_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_2_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_2_UL_DATA}
     Sleep      5
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}

     Exe egate cmd      cmd=${CM_UE3_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_3_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_3_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_3_UL_DATA}
     Sleep      5
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Exe egate cmd      cmd=${CM_UE4_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_4_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_4_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_4_UL_DATA}
     Sleep      5
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_1}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_2}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_3}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_4}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_1_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_2_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_3_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_4_ACT}
     Sleep      5
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Sleep      5

CB008235 SA Call UE9 to UE16
     Log to console      "Starting UE 9 TO 16  DATA CALL"
     Exe egate cmd      cmd=${CM_UE9_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_9_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_9_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_9_UL_DATA}

     Exe egate cmd      cmd=${CM_UE10_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_10_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_10_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_11_UL_DATA}
     Exe egate cmd      cmd=${CM_UE11_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_11_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_11_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_11_UL_DATA}
     Exe egate cmd      cmd=${CM_UE12_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_12_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_12_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_12_UL_DATA}
     Sleep      2
     Exe egate cmd      cmd=${CM_UE12_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_13_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_13_PDU_SESSION}
      Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_13_UL_DATA}
     Sleep      2
     Exe egate cmd      cmd=${CM_UE14_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_14_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_14_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_14_UL_DATA}

     Exe egate cmd      cmd=${CM_UE15_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_15_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_15_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_15_UL_DATA}
     Exe egate cmd      cmd=${CM_UE16_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_16_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_16_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_16_UL_DATA}
     Log to console      "INFO:    Checking UE 1 TO 8 stats"
     Sleep      5
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_9}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_9_ACT}
     Sleep      5
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_10}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_10_ACT}
     Sleep      5
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_11}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_11_ACT}
     Sleep      5
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_12}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_12_ACT}
     Sleep      15
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_13}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_13_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_14}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_14_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_15}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_15_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_16}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_16_ACT}
     Sleep      1
     Log to console      "INFO:    Checking UE 1 TO 8 PAIRING  stats"
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Exe egate cmd      cmd=ue_stats_nr id=1-16 type=pusch
     Sleep      5
     Exe egate cmd      cmd=ue_stats_nr id=1-16 type=pusch
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Sleep      5

CB008235 SA Call UE1 to UE8
     Log to console      "Starting UE 1 TO 5 DATA CALL"
     Exe egate cmd      cmd=${CM_UE1_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_1_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_UL_DATA}

     Exe egate cmd      cmd=${CM_UE2_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_2_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_2_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_2_UL_DATA}
     Exe egate cmd      cmd=${CM_UE3_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_3_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_3_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_3_UL_DATA}
     Exe egate cmd      cmd=${CM_UE4_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_4_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_4_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_4_UL_DATA}
     Sleep      2
     Exe egate cmd      cmd=${CM_UE5_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_5_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_5_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_5_UL_DATA}
     Sleep      2
     Exe egate cmd      cmd=${CM_UE6_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_6_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_6_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_6_UL_DATA}

     Exe egate cmd      cmd=${CM_UE7_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_7_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_7_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_7_UL_DATA}
     Exe egate cmd      cmd=${CM_UE8_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_8_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_8_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_8_UL_DATA}
     Log to console      "INFO:    Checking UE 1 TO 8 stats"
     Sleep      5
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_1}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_1_ACT}
     Sleep      5
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_2}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_2_ACT}
     Sleep      5
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_3}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_3_ACT}
     Sleep      5
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_4}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_4_ACT}
     Sleep      15
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_5}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_5_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_6}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_6_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_7}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_7_ACT}
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_8}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_8_ACT}
     Sleep      1
     Log to console      "INFO:    Checking UE 1 TO 8 PAIRING  stats"
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Exe egate cmd      cmd=ue_stats_nr id=1-8 type=pusch
     Sleep      5
     Exe egate cmd      cmd=ue_stats_nr id=1-8 type=pusch
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Sleep      5

CB008235 SA Call UE9
     Exe egate cmd      cmd=${CM_UE9_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_9_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE9_REG_COMPLETE}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_9_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE9_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_9_UL_DATA}
     Sleep      2

CB008235 SA Call UE9 to UE10
     Exe egate cmd      cmd=ue_stats_nr id=1-10 type=pusch
     Sleep      2
     Exe egate cmd      cmd=${CM_UE9_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_9_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE9_REG_COMPLETE}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_9_PDU_SESSION}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE9_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_9_UL_DATA}
     Sleep      10
     Exe egate cmd      cmd=${CM_UE10_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_10_REGISTER}
     Sleep      2
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE10_REG_COMPLETE}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_10_PDU_SESSION}
     Sleep      10
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE10_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_10_UL_DATA}
     Sleep      1
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_9}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_9_ACT}
     Sleep      1
     Exe egate cmd      cmd=${CM_UL_BEAM_POS_PROFILE_TC_04_10}
     Exe egate cmd      cmd=${CM_UL_BEAM_PROFILE_TC_04_10_ACT}
     Sleep      1
     Exe egate cmd      cmd=ue_stats_nr id=1-10 type=pusch

CB008235 SA Deregister UE 1 to 4
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
     Exe egate cmd      cmd=${CM_UE_4_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

CB008235 SA Deregister UE 1 to 6
     CB008235 SA Deregister UE 1 to 4
     Exe egate cmd      cmd=${CM_UE_5_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE5_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

     Exe egate cmd      cmd=${CM_UE_6_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE6_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

CB008235 SA Deregister UE 1 to 8
     CB008235 SA Deregister UE 1 to 4
     Exe egate cmd      cmd=${CM_UE_5_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

     Exe egate cmd      cmd=${CM_UE_6_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_7_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

     Exe egate cmd      cmd=${CM_UE_8_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

CB008235 SA Deregister UE 9
    Exe egate cmd      cmd=${CM_UE_9_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

CB008235 SA Deregister UE 9 to 10
     Exe egate cmd      cmd=${CM_UE_9_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

     Exe egate cmd      cmd=${CM_UE_10_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

Trigger Channel Condition Variation using SINR and NOISE
     Exe egate cmd      cmd=${CM_NOISE_PUSCH_PROFILE_1}
     Sleep      1
     Exe egate cmd      cmd=${CM_SINR_TARGET_PUSCH_PROFILE_20}
     Sleep      1
     Exe egate cmd      cmd=${CM_NOISE_PUSCH_CELL1_PROFILE_1_ACT}
     Sleep      1
     Exe egate cmd      cmd=${CM_SINR_TARGET_PUSCH_UE11_PROFILE_20_ACT}
     Exe egate cmd      cmd=ue_disp id=11-18

Validate 4 RANK2 Paired UE Data Rate
     [Arguments]    ${EXPECTED_DATA_RATE}=1500
     Exe egate cmd      cmd=${CM_UE_1_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>${EXPECTED_DATA_RATE}
     Exe egate cmd      cmd=${CM_UE_2_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>${EXPECTED_DATA_RATE}
     Exe egate cmd      cmd=${CM_UE_3_STATS}
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>${EXPECTED_DATA_RATE}
     Exe egate cmd      cmd=${CM_UE_4_STATS}
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>${EXPECTED_DATA_RATE}


Validate 4 UE RANK2 Paired Data Rate
     Exe egate cmd      cmd=${CM_UE_1_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>79
     Exe egate cmd      cmd=${CM_UE_2_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>79
     Exe egate cmd      cmd=${CM_UE_3_STATS}
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>79
     Exe egate cmd      cmd=${CM_UE_4_STATS}
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>79

Validate 2 UE RANK2 Paired Data Rate
     Exe egate cmd      cmd=${CM_UE_5_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>39
     Exe egate cmd      cmd=${CM_UE_6_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>39

Validate UE1 To UE4 Paired Data Rate
     Exe egate cmd      cmd=${CM_UE_1_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>90
     Exe egate cmd      cmd=${CM_UE_2_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>90
     Exe egate cmd      cmd=${CM_UE_3_STATS}
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>90
     Exe egate cmd      cmd=${CM_UE_4_STATS}
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>90

Validate UE5 UE6 RANK2 Paired Data Rate
     Exe egate cmd      cmd=${CM_UE_5_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>90
     Exe egate cmd      cmd=${CM_UE_6_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>90

Validate UE7 UE8 In SUMIMO Data Rate
     Exe egate cmd      cmd=${CM_UE_7_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>90
     Exe egate cmd      cmd=${CM_UE_8_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>90

Validate 8 UE RANK1 Paired Data Rate
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Sleep      5
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>39
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Exe egate cmd      cmd=${CM_UE_2_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>39
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Exe egate cmd      cmd=${CM_UE_3_STATS}
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>39
     Exe egate cmd      cmd=${CM_UE_4_STATS}
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>39
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Exe egate cmd      cmd=${CM_UE_5_STATS}
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>39
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Exe egate cmd      cmd=${CM_UE_6_STATS}
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>39
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Exe egate cmd      cmd=${CM_UE_7_STATS}
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>39
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Exe egate cmd      cmd=${CM_UE_8_STATS}
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>39

Validate NSA 8 UE RANK1 Paired Data Rate
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Sleep      5
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Sleep      5
     Exe egate cmd      cmd=${CM_NSA_UE_11_STATS}
     Sleep      5
     ${value}      extract_uestats.NSA Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>37
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Exe egate cmd      cmd=${CM_NSA_UE_12_STATS}
     Sleep      5
     ${value}      extract_uestats.NSA Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>37
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Exe egate cmd      cmd=${CM_NSA_UE_13_STATS}
     ${value}      extract_uestats.NSA Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>37
     Exe egate cmd      cmd=${CM_NSA_UE_14_STATS}
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     ${value}      extract_uestats.NSA Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>37
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Exe egate cmd      cmd=${CM_NSA_UE_15_STATS}
     ${value}      extract_uestats.NSA Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>37
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Exe egate cmd      cmd=${CM_NSA_UE_16_STATS}
     ${value}      extract_uestats.NSA Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>37
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Exe egate cmd      cmd=${CM_NSA_UE_17_STATS}
     ${value}      extract_uestats.NSA Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>37
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Exe egate cmd      cmd=${CM_NSA_UE_18_STATS}
     ${value}      extract_uestats.NSA Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>37

Validate 9 to 10 UE RANK1 Paired Data Rate
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Sleep      5
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_9_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>39
     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
     Exe egate cmd      cmd=${CM_UE_10_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>39

Validate CB008235 TC07B TTI Logs For Pairing
     Convert TTI trace from pcap to excelCsv      pcap_path=/home/ute/logs/l2stream3/tcpdump/tcpdump.pcap
     ...      output_path_with_tag=/home/ute/logs/l2stream3/tcpdump/     decode_format=excelCsv
     ta_a2a.interface.Check Logs With Au2anlysis      ini_path=${CURDIR}/../../ini/CB008235_TC_07B.ini    log_need_to_check=i
     ...    save_log_directory=/home/ute/logs/l2stream3/

Validate UE1 To UE2 Paired Data Rate
      Exe egate cmd      cmd=${CM_UE_1_STATS}
     Sleep      5
#     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>50
     Exe egate cmd      cmd=${CM_UE_2_STATS}
     Sleep      5
#     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>40

Validate UE3 To UE6 Paired Data Rate
     Exe egate cmd      cmd=${CM_UE_3_STATS}
     Sleep      5
#     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>50
     Exe egate cmd      cmd=${CM_UE_4_STATS}
     Sleep      5
#     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>40
      Exe egate cmd      cmd=${CM_UE_5_STATS}
     Sleep      5
#     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>50
     Exe egate cmd      cmd=${CM_UE_6_STATS}
     Sleep      5
#     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
#     Should Be True      ${value}>40

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

Validate CB008235 TC07 TTI Logs For Pairing
     Validate    log=${L_GNB_TTI}      logfile_with_path=/home/ute/logs/l2stream3/tcpdump/tcpdump.pcap
     ...      element=${CURDIR}/../../ini/CB008235_TC_07.ini

Validate 4UE RANK2 NOT Paired in TTI logs
     Convert TTI trace from pcap to excelCsv      pcap_path=/home/ute/logs/l2stream3/tcpdump/tcpdump.pcap
     ...      output_path_with_tag=/home/ute/logs/l2stream3/tcpdump/     decode_format=excelCsv
     ta_a2a.interface.Check Logs With Au2anlysis      ini_path=${CURDIR}/../../ini/CB008235_D_TC_03_MU_NO_PAIR_CHECK.ini    log_need_to_check=i
     ...    save_log_directory=/home/ute/logs/l2stream3/

CB008235 Validate PM counter
      [Arguments]    ${LST_OF_PM_COUNT_DICT}     ${PM_FILE_PATH}
      Validate PM counter     ${LST_OF_PM_COUNT_DICT}      ${PM_FILE_PATH}
