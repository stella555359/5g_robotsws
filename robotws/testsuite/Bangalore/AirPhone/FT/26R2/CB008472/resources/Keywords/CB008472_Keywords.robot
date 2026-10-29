** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Keerthi.Chittoor
                 ...              :contact      : keerthi.chittoor@nokia.com
                 ...              :Description  : Contains Keyword needed for CB008472
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,12.12.2025,keerthi.chittoor@nokia.com

Resource    ../../../../resources/Keywords/new_general_common_keywords.robot
Resource    ../Variables/CB008472_variables.robot

***Keywords***
CB008472 Suite Setup
     [Arguments]    ${TC_DIR}
     Set Suite Variable    ${TC_LOG_DIR}     ${TC_DIR}
     Clean up Preparation before TC     ${TC_DIR}
     Download Ttitrace Decode Tool
     Sleep     10
     Start Logs      ${L_AP_GNB_SYS}

CB008472 Suite Teardown
     [Arguments]    ${TC_DIR}
     Stop and collect SOS       ${sos_script_path}     ${TC_DIR}
     Sleep     10
     Stop Logs     ${L_AP_GNB_SYS}     ${TC_DIR}
     Collect Cfg and egate logs     ${TC_DIR}
     Cleanup Process After TC     ${TC_DIR}

CB008472_B Suite Setup
     [Arguments]    ${TC_DIR}
     Set Suite Variable    ${TC_LOG_DIR}     ${TC_DIR}
     Clean up Preparation before TC     ${TC_DIR}
     Download Ttitrace Decode Tool
     Sleep     10
     Delete Interface for NRDC
     Create Interface for NRDC
     Start Logs      ${L_AP_GNB_SYS}

CB008472_B Suite Teardown
     [Arguments]    ${TC_DIR}
     Stop and collect SOS       ${sos_script_path}     ${TC_DIR}
     Sleep     10
     Stop Logs     ${L_AP_GNB_SYS}     ${TC_DIR}
     Collect Cfg and egate logs     ${TC_DIR}
     Cleanup Process After TC     ${TC_DIR}
     Delete Interface for NRDC

Register UE1
     Log to console    "Registering UE1"
     Exe egate cmd      cmd=${CM_UE_1_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE1 with PDU1 session establishment
     Log to console     "Establishing PDU-1 session for UE-1"
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_DTYPE_INTERNAL}       return_output=False
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_1_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_UL_DATA}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_DL_DATA}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_MOD_QOS2_ADD}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_1_MOD_QOS2_ADD}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_MOD_QOS3_ADD}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_1_MOD_QOS3_ADD}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_MOD_QOS4_ADD}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_1_MOD_QOS4_ADD}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_MOD_QOS5_ADD}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_1_MOD_QOS5_ADD}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_MOD_QOS6_ADD}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_1_MOD_QOS6_ADD}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE1 with PDU2 session establishment
     Log to console     "Establishing PDU-2 session for UE-1"
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_DTYPE_INTERNAL}       return_output=False
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_2_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_UL_DATA}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_DL_DATA}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_MOD_QOS2_ADD}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_2_MOD_QOS2_ADD}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_MOD_QOS4_ADD}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_2_MOD_QOS4_ADD}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_MOD_QOS5_ADD}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_2_MOD_QOS5_ADD}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_MOD_QOS6_ADD}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_2_MOD_QOS6_ADD}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE1 with PDU3 session establishment
     Log to console     "Establishing PDU-3 session for UE-1"
     Exe egate cmd      cmd=${CM_UE_1_PDU_3_DTYPE_INTERNAL}       return_output=False
     Exe egate cmd      cmd=${CM_UE_1_PDU_3_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_3_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_3_UL_DATA}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_3_DL_DATA}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_3_MOD_QOS4_ADD}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_3_MOD_QOS4_ADD}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_3_MOD_QOS5_ADD}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_3_MOD_QOS5_ADD}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

GNB triggers an intra-cell handover to perform a security key refresh
     Log to console     "GNB triggers an intra-cell handover to perform a security key refresh"
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_MOD_QOS2_DEL}
     Sleep      15
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_1_MOD_QOS2_DEL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${KEY_REFRESH}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_MOD_QOS2_ADD}
     Sleep      15
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_1_MOD_QOS2_ADD}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_MOD_QOS6_DEL}
     Sleep      15
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_2_MOD_QOS6_DEL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${KEY_REFRESH}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_MOD_QOS6_ADD}
     Sleep      15
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_2_MOD_QOS6_ADD}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_3_RELEASE}
     Sleep      15
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_3_RELEASE}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     UE1 with PDU3 session establishment

Stop Data Traffic
     Log to console     "Stopping the Traffic"
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_UL_DATA_STOP}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_DL_DATA_STOP}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_UL_DATA_STOP}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_DL_DATA_STOP}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_3_UL_DATA_STOP}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_3_DL_DATA_STOP}
     Sleep      5

DEREGISTER UE
     Log to console     "Deregistering UE"
     Exe egate cmd      cmd=${CM_UE_1_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

PDU1 Session Establishment for UE1
     Log to console     "Establishing PDU-1 session for UE-1 followed by Establishing NRDC"
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_DTYPE_INTERNAL}       return_output=False
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_SESSION}
     Exe egate cmd      cmd=${CM_UE_1_NRDC_ESTABLISHMENT}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_1_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NRDC_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_UL_DATA}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_DL_DATA}
     Sleep      5

PDU2 Session Establishment for UE1
     Log to console     "Establishing PDU-2 session for UE-1"
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_DTYPE_INTERNAL}       return_output=False
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_2_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_UL_DATA}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_DL_DATA}
     Sleep      5

PDU3 Session Establishment for UE1
     Log to console     "Establishing PDU-3 session for UE-1"
     Exe egate cmd      cmd=${CM_UE_1_PDU_3_DTYPE_INTERNAL}       return_output=False
     Exe egate cmd      cmd=${CM_UE_1_PDU_3_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_3_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_3_UL_DATA}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_3_DL_DATA}
     Sleep      5

Adding QOS flow
     Log to console     "Modifying PDU session by adding QOS flow with 2 & 3"
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_MOD_QOS2_ADD}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_MOD_QOS3_ADD}
     Sleep      5

Deleting QOS flow
     Log to console     "Modifying PDU session by Deleting QOS flow with 2 & 3"
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_MOD_QOS2_DEL}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_MOD_QOS3_DEL}
     Sleep      5

Exhausting DRB_ID by repeating QOS flow add and delete
     Log to console    "Exhausting DRB_ID by repeating QOS flow add and delete"
     FOR    ${i}    IN RANGE    6
         Log to console    ===== Iteration ${i + 1} =====
         Adding QOS flow
         Deleting QOS flow
     END

Verify NRDC released followed by Intra cell Handover triggered
     Log to console      "Verifing NRDC released followed by Intra cell Handover triggered"
     Validate     log=${L_EGATE_CONSOLE}      element=${NRDC_RELEASE}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${KEY_REFRESH}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

Before triggering intra-cell handover NR-DC is released
     Log to console      "Verifing NRDC released followed by Intra cell Handover triggered"
     Exhausting DRB_ID by repeating QOS flow add and delete
     Wait Until Keyword Succeeds    30s    5s
     ...    Verify NRDC released followed by Intra cell Handover triggered

Create Interface for NRDC
    Run    sudo ip addr add 10.0.1.6/24 dev eth3
    Run    sudo ip addr add 10.0.1.7/24 dev eth3

Delete Interface for NRDC
    Run    sudo ip addr del 10.0.1.6/24 dev eth3
    Run    sudo ip addr del 10.0.1.7/24 dev eth3

