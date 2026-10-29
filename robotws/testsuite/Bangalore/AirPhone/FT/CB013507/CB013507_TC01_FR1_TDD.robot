*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Shivalingesh Sheelavanth
                 ...              :contact      : Shivalingesh, Dharmendra
                 ...              :Description  : This script will validate and check The Timing Advance Report for feature
                 ...                               CB013507 includes details on both activation and deactivation status.
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,shivalingesh.sheelavantar@nokia.com

Library           ./resources/Keywords/CB013507_validate_bip_keywords.py

Resource          ./resources/Keywords/CB013507_Keyword.robot
Resource          ../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/CB013507_variables.robot
Resource          ./resources/Keywords/CB013507_gnbbip_convert.robot

Suite Setup       CB013507 Suite Setup
Suite Teardown    CB013507 Suite Teardown

*** Test Cases ***
CB013507 TC01 Call
    [Documentation]
         ...    author: shivalingesh.sheelavantar@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,11.01.2025,shivalingesh.sheelavantar@nokia.com
         ...    The Timing Advance Report for feature CB013507
     Start Logs     ${L_AP_GNB_SYS}
     Get cell On Air      iphy=${CB013507_TC01_AP_IPHY}      scf_delta=${CB013507_GNB_SCF_DELTA_JSON}
     ...     cfg=${CB013507_TC01_WTS_CFG}
     Start Logs     ${L_GNB_L3} ${L_WTS_L3}
     Start Logs     ${L_GNB_BIP}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE2_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE_2_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_2_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     UL2 Data
     CB013507 TC01 IMF for UE2
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${CB013507_TC01_val_req}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${CB013507_TC01_val_res}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     UE2 Deregister
     Stop Logs     ${L_GNB_L3} ${L_WTS_L3}
     Stop Logs     ${L_AP_GNB_SYS}
     Stop Logs     ${L_GNB_BIP}
     Log to Console       PCAP validation started
     Validate       log=${L_WTS_L3}        logfile_with_path=/home/ute/logs/wts.pcap
     ...     filter=nrppa        element=nrppa.measurementQuantitiesValue
     Validate       log=${L_GNB_L3}        logfile_with_path=/home/ute/logs/gnbl3.pcap
     ...     filter=nrppa        element=nrppa.ReportCharacteristics
     Log to Console       BIP gNB validation started
     Convert BIP To CSV By MCShark with column        ${CB013507_BIP_SCN_TC01}/BIP_L1L2.pcap
     ...     ${CB013507_BIP_SCN_TC01}/${BIP_CSV_NAME}      filter=${FILTER_CB013507_2}
     ...     csv_title_list=${COLUMN_NAME1}
     Log to Console       CB013507 gNB BIP initialUlEcidTAdv value verifiying..?
     Convert BIP To CSV By MCShark CB013507 Check1      ${CB013507_BIP_SCN_TC01}/BIP_L1L2.pcap
     ...      ${CB013507_BIP_SCN_TC01}/${BIP_CSV_CB013507_1}      filter=${FILTER_CB013507_1}
     ...      csv_title_list=${COLUMN_NAME1}
     Log to Console       CB013507 gNB BIP initialUlEcidTAdv value verified :) :)
     Log to Console       CB013507 gNB BIP initialTa value verifiying..?
     Convert BIP To CSV By MCShark CB013507 Check2     ${CB013507_BIP_SCN_TC01}/BIP_L1L2.pcap
     ...      ${CB013507_BIP_SCN_TC01}/${BIP_CSV_CB013507_2}      filter=${FILTER_CB013507_2}
     ...      csv_title_list=${COLUMN_NAME2}
     Log to Console       CB013507 gNB BIP initialTa value verified :) :)
     Log to Console       CB013507 CSV verification Python has script started..?
     ${csv1}=    Set Variable
     ...      /home/ute/logs/CB013507_TC01_Call/gNB/biptaf/TestCase_gnbbip/BIP_L1L2_filter_initialUlEcidTAdv.csv
     ${csv2}=    Set Variable
     ...      /home/ute/logs/CB013507_TC01_Call/gNB/biptaf/TestCase_gnbbip/BIP_L1L2_filter_initialTa.csv
     ${result}=    Validate Bip Values    ${csv1}    ${csv2}
     Log to Console       CB013507 CSV verification Python has script started
