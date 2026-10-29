** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Keerthi.Chittoor
                 ...              :contact      : keerthi.chittoor@nokia.com
                 ...              :Description  : Contains Keyword needed for CB012328
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,03.02.2026,keerthi.chittoor@nokia.com

Resource    ../../../../resources/Keywords/new_general_common_keywords.robot
Resource    ../Variables/CB012328_variables.robot

***Keywords***
CB012328 Suite Setup
     [Arguments]    ${TC_DIR}
     Set Suite Variable    ${TC_LOG_DIR}     ${TC_DIR}
     Clean up Preparation before TC     ${TC_DIR}
     Download Ttitrace Decode Tool
     Sleep     10
     Create Interface for NRDC
     Start Logs      ${L_AP_GNB_SYS}

CB012328 Suite Teardown
     [Arguments]    ${TC_DIR}
     Stop and collect SOS       ${sos_script_path}     ${TC_DIR}
     Sleep     10
     Delete Interface for NRDC
     Stop Logs     ${L_AP_GNB_SYS}     ${TC_DIR}
     Collect Cfg and egate logs     ${TC_DIR}
     Cleanup Process After TC     ${TC_DIR}

Register UE on SimGNB and start traffic
     Log to console    "Registering UE with 2 PDU sessions on SimGnb"
     Exe egate cmd      cmd=${CM_for_sib1}
     Sleep      5
     Exe egate cmd      cmd=${CM_for_sib2}
     Sleep      5
     Exe egate cmd      cmd=${CM_for_sib5}
     Sleep      5
     Exe egate cmd      cmd=${CM_for_UE_LOC_CHANGE}
     Register UE1
     Log to console     "UE1 with PDU1 session establishment which eligible for NRDC"
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_DTYPE_INTERNAL}       return_output=False
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_1_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     UE1 with PDU2 session establishment with VONR
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_UL_DATA}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_1_DL_DATA}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_UL_DATA}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_DL_DATA}
     Sleep      5

Register UE1
     Log to console    "Registering UE1"
     Exe egate cmd      cmd=${CM_UE_1_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE1 with PDU1 session establishment which eligible for NRDC
     Log to console     "Establishing PDU-1 session for UE-1 which is eligible for  NRDC"
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

UE1 with PDU2 session establishment with VONR
     Log to console     "Establishing PDU-2 session with VONR DRB setup  for UE-1"
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
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_MOD_QOS3_ADD}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_2_MOD_QOS3_ADD}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

Configuring Sim GNB with UE history
     Log to console     "Configuring Sim GNB with UE history"
     Exe egate cmd      cmd=${CM_for_UE_HIST_INFO}        return_output=False
     Sleep      5
     Exe egate cmd      cmd=${CM_for_UE_HIST_INFO_1}
     Sleep      5
     Exe egate cmd      cmd=${CM_for_UE_HIST_INFO_2}       return_output=False
     Sleep      5
     Exe egate cmd      cmd=${CM_for_UE_MEAS_DISP}
     Sleep      5

Configuring UE to ignore RRC Reconfiguration but to trigger RRC Reestablishment
     Log to console     "Configuring UE to ignore RRC Reconfiguration but to trigger RRC Reestablishment"
     Exe egate cmd      cmd=${CM_UE_1_UE_NR_RRC_RECONF}        return_output=False
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_GNB_XN_HO}        return_output=False
     Sleep      5

Triggering A3 measurment for XN HO from SIM GNB
    Log to console     "Triggering A3 measurment for XN HO from SIM GNB to Target GNB"
    Exe egate cmd      cmd=${CM_UE_1_A3_MEAS_SRC_TO_TGT}
    Sleep      5
    Validate     log=${L_EGATE_CONSOLE}      element=${VAL_XN_HO_AT_SRC}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

Triggering A3 measurment for XN HO to SIM GNB
    Log to console     "Triggering A3 measurment for XN HO from Target GNB to SIM GNB"
    Exe egate cmd      cmd=${CM_for_UE_MEAS_DISP}
    Sleep      5
    Exe egate cmd      cmd=${CM_UE_1_A3_MEAS_TGT_TO_SRC}
    Sleep      5
    Validate     log=${L_EGATE_CONSOLE}      element=${VAL_XN_HO_AT_TGT}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

Releasing 5QI-1 and Triggering A4 measurment for NRDC Establishment
    Log to console     "Releasing 5QI-1 bearer and configures A4 measurement for NR-DC activation"
    Exe egate cmd      cmd=${CM_UE_1_PDU_2_MOD_QOS3_DEL}
    Exe egate cmd      cmd=${CM_for_UE_MEAS_DISP}
    Sleep      5
    Exe egate cmd      cmd=${CM_UE_1_NRDC_ESTABLISHMENT}
    Sleep      5
    Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NRDC_SESSION}
    ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

Establishing 5QI-1 Bearer
    Exe egate cmd      cmd=${CM_UE_1_PDU_2_MOD_QOS3_ADD}
    Sleep      5
    Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_2_MOD_QOS3_ADD}
    ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
    MN gNB performs SN bearer takeback followed by VoNR DRB setup

MN gNB performs SN bearer takeback followed by VoNR DRB setup
     Log to console     "MN gNB performs SN bearer takeback followed by VoNR DRB setup"
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SN_take_back}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

Releasing 5QI-1 bearer and configures A4 measurement for NR-DC activation
     Log to console     "Releasing 5QI-1 bearer and configures A4 measurement for NR-DC activation"
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_MOD_QOS3_DEL}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_NRDC_ESTABLISHMENT_9}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NRDC_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

Observing SN take back by esatblishing 5QI-1 and Releasing it and checking for NRDC establishment
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_MOD_QOS3_ADD}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_2_MOD_QOS3_ADD}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     MN gNB performs SN bearer takeback followed by VoNR DRB setup
     Log to console     "Releasing 5QI-1 bearer and configures A4 measurement for NR-DC activation"
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_MOD_QOS3_DEL}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_NRDC_ESTABLISHMENT_2}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NRDC_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_MOD_QOS3_ADD}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_2_MOD_QOS3_ADD}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     MN gNB performs SN bearer takeback followed by VoNR DRB setup
     Log to console     "Releasing 5QI-1 bearer and configures A4 measurement for NR-DC activation"
     Exe egate cmd      cmd=${CM_UE_1_PDU_2_MOD_QOS3_DEL}
     Sleep      5
     Exe egate cmd      cmd=${CM_UE_1_NRDC_ESTABLISHMENT_3}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_NRDC_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

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

DEREGISTER UE
     Log to console     "Deregistering UE"
     Exe egate cmd      cmd=${CM_UE_1_DEREG}
     Sleep      5

Create Interface for NRDC
    Run    sudo ip addr add 10.0.1.5/24 dev eth3
    Run    sudo ip addr add 10.0.1.6/24 dev eth3
    Run    sudo ip addr add 10.0.1.7/24 dev eth3
    Run    sudo ip addr add 10.0.1.8/24 dev eth3
    Run    sudo ip addr add 10.0.1.13/24 dev eth3
    Run    sudo ip addr add 10.0.1.14/24 dev eth3

Delete Interface for NRDC
    Run    sudo ip addr del 10.0.1.5/24 dev eth3
    Run    sudo ip addr del 10.0.1.6/24 dev eth3
    Run    sudo ip addr del 10.0.1.7/24 dev eth3
    Run    sudo ip addr del 10.0.1.8/24 dev eth3
    Run    sudo ip addr del 10.0.1.13/24 dev eth3
    Run    sudo ip addr del 10.0.1.14/24 dev eth3
