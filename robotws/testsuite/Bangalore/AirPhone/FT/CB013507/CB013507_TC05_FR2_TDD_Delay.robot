*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Shivalingesh Sheelavantar
                 ...              :contact      : Shivalingesh, Dharmendra
                 ...              :Description  : This is basic CB013507 TC05 FR2 FDD  Resolution enhancement
                 ...                 Timing Advance measurement in TDD FR2 Test case two
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,shivalingesh.sheelavantar@nokia.com
Library                ./resources/Keywords/CB013507_validate_bip_keywords.py
Library                 ./resources/Keywords/CB013507_delay_checker_TADV.py

Resource          ./resources/Keywords/CB013507_Keyword.robot
Resource          ../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/CB013507_variables.robot
Resource          ./resources/Keywords/CB013507_gnbbip_convert.robot


Suite Setup       CB013507 Suite Setup
Suite Teardown    CB013507 Suite Teardown

*** Test Cases ***
CB013507 TC05 FR2
    [Documentation]
         ...    author: shivalingesh.sheelavantar@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,12.06.2025,shivalingesh.sheelavantar@nokia.com
         ...    This is basic CB013507 TC05 FR2 FDD  Resolution enhancement for Timing Advance measurement
     Get cell On Air      iphy=${CB013507_FR2_TDD_AP_IPHY}       scf_delta=${CB013507_GNB_SCF_FR2_TDD_DELTA_JSON}
     ...     cfg=${CB013507_FR2_TDD_WTS_CFG}
     Start Logs     ${L_GNB_L3} ${L_WTS_L3}
     Start Logs     ${L_GNB_BIP}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE1_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE_1_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     UL1 Data
     DL1 Data
     CB013507 TC01 IMF for UE1
     UE1 Deregister
     Stop Logs     ${L_GNB_L3} ${L_WTS_L3}
     Log to Console        WTS PCAP validation started..
     Validate       log=${L_WTS_L3}        logfile_with_path=/home/ute/logs/wts.pcap
     ...            filter=nrppa        element=nrppa.NR_TADV
     Validate       log=${L_GNB_L3}        logfile_with_path=/home/ute/logs/gnbl3/gnbl3.pcap
     ...            filter=nrppa        element=nrppa.NR_TADV
     log to console   WTS Pcap validation done ...
     Exe egate cmd           cmd=${CB013507_UE_TA_NR_CMD1_TC02_PR1}          return_output=False
     Exe egate cmd           cmd=${CB013507_UE_TA_NR_CMD2_TC02_PR1}          return_output=False
     Exe egate cmd           cmd=${CB013507_UE_TA_NR_CMD3_TC02_PR1}          return_output=False
     Log to Console        \nThree delay cmds are executed\n
     Log to Console       After delay UE Register on ongoing..
     Exe egate cmd      cmd=${CM_UE1_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE_1_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     UL1 Data
     DL1 Data
     CB013507 TC01 IMF for UE1
     UE1 Deregister
     Log to Console        \nTC05 Scenario cmds are executed Validation is started..?\n
     Start Logs     ${L_GNB_L3} ${L_WTS_L3}
#     Start Logs    ${L_GNB_BIP}
     Sleep    30
     Stop Logs     ${L_GNB_L3} ${L_WTS_L3}
     Log to Console        WTS gNB  PCAP validation started after delay..
     Validate       log=${L_GNB_L3}        logfile_with_path=/home/ute/logs/gnbl3/gnbl3.pcap
     ...            filter=nrppa        element=nrppa.NR_TADV
     Validate       log=${L_WTS_L3}        logfile_with_path=/home/ute/logs/wts.pcap
     ...            filter=nrppa        element=nrppa.NR_TADV
     Stop Logs     ${L_GNB_BIP}
     Log to Console       BIP gNB stoped and validation started..
     Sleep     10
     Convert BIP To CSV By MCShark with CB013507 delay single TADV        ${CB013507_BIP_SCN_TC05}/BIP_L1L2.pcap
     ...      ${CB013507_BIP_SCN_TC05}/${BIP_CSV_CB013507_NR_TADA_AFTER}        filter=${FILTER_CB013507_3}
     ...      csv_title_list=${COLUMN_NR_TADA}
     Log to Console       CB013507 gNB BIP checked after delay NR_TADV :)
     Log to Console       PCAP validation started
     Validate       log=${L_WTS_L3}        logfile_with_path=/home/ute/logs/wts.pcap
     ...            filter=nrppa        element=nrppa.measurementQuantitiesValue
     Validate       log=${L_WTS_L3}        logfile_with_path=/home/ute/logs/wts.pcap
     ...            filter=nrppa        element=nrppa.ReportCharacteristics
     Log to Console       \nCB013507 TC05 Main Validation Python script started to check delay range\n
     ${result_delay}=     Check Delay Values In Range          ${CB013507_CSV_PATH_Delay_After_TC05}
     Log to Console       \nCB013507 TC05 Main Validation Python script completed.. :) :)\n
     Log to Console       \nThe End Testcase is Completed!..\n
