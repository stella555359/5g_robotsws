*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Shivalingesh Sheelavantar
                 ...              :contact      : Shivalingesh,Dharmendra
                 ...              :Description  : This script is to validate L3 call in
                 ...                               LO_AP_LO TL with sos report / bip
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,shivalingesh.sheelavantar@nokia.com
Library           ./resources/Keywords/CB013507_validate_bip_keywords.py
Library           ./resources/Keywords/CB013507_delay_checker_TADV.py

Resource           ./resources/Keywords/CB013507_Keyword.robot
Resource          ../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/CB013507_variables.robot
Resource           ./resources/Keywords/CB013507_gnbbip_convert.robot


Suite Setup       CB013507 Suite Setup
Suite Teardown    CB013507 Suite Teardown

*** Test Cases ***
CB013507 TC06 Call
    [Documentation]
         ...    author: shivalingesh.sheelavantar@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,12.06.2025,shivalingesh.sheelavantar@nokia.com
         ...    This is basic CB013507 TC02 Call with delay
     Get cell On Air      iphy=${CB013507_TC01_AP_IPHY}      scf_delta=${CB013507_GNB_SCF_DELTA_JSON}
     ...     cfg=${CB013507_TC01_WTS_CFG}
     Start Logs     ${L_GNB_L3} ${L_WTS_L3}
     Start Logs     ${L_GNB_BIP}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_53_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE_53_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_53_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     UL53 Data
     DL53 Data
     CB013507 TC01 IMF for UE53
     UE53 Deregister
     Stop Logs     ${L_GNB_L3} ${L_WTS_L3}
     Log to Console        WTS PCAP validation started..
     Validate       log=${L_WTS_L3}        logfile_with_path=/home/ute/logs/wts.pcap
     ...           filter=nrppa        element=nrppa.NR_TADV
     Validate       log=${L_GNB_L3}        logfile_with_path=/home/ute/logs/gnbl3/gnbl3.pcap
     ...            filter=nrppa        element=nrppa.NR_TADV
     log to console   WTS Pcap validation done ...
     Exe egate cmd           cmd=${CB013507_UE_53_TA_NR_CMD1_TC02_PR1}            return_output=False
     Exe egate cmd           cmd=${CB013507_UE_53_TA_NR_CMD2_TC02_PR1}            return_output=False
     Exe egate cmd           cmd=${CB013507_UE_53_TA_NR_CMD3_TC02_PR1}            return_output=False
     Log to Console        \nThree delay cmds are executed\n
     Log to Console       After delay UE Register on ongoing
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_53_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE_53_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_53_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     UL53 Data
     DL53 Data
     CB013507 TC01 IMF for UE53
     UE53 Deregister
     Log to Console        \nTC06 Scenario cmds are executed Validation is started..?\n
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
     Convert BIP To CSV By MCShark with CB013507 delay single TADV        ${CB013507_BIP_SCN_TC06}/BIP_L1L2.pcap
     ...      ${CB013507_BIP_SCN_TC06}/${BIP_CSV_CB013507_NR_TADA_AFTER}        filter=${FILTER_CB013507_3}
     ...       csv_title_list=${COLUMN_NR_TADA}
     Log to Console       CB013507 gNB BIP checked after delay NR_TADV with UE53..:)
     Log to Console       PCAP validation started..
     Validate       log=${L_WTS_L3}        logfile_with_path=/home/ute/logs/wts.pcap
     ...            filter=nrppa        element=nrppa.measurementQuantitiesValue
     Validate       log=${L_WTS_L3}        logfile_with_path=/home/ute/logs/wts.pcap
     ...            filter=nrppa        element=nrppa.ReportCharacteristics
     Log to Console       BIP gNB validation started
     Convert BIP To CSV By MCShark with column        ${CB013507_BIP_SCN_TC06}/BIP_L1L2.pcap
     ...      ${CB013507_BIP_SCN_TC06}/${BIP_CSV_NAME}       filter=${FILTER_CB013507_3}
     ...       csv_title_list=${COLUMN_NAME1}
     Log to Console       CB013507 gNB BIP initialUlEcidTAdv value verifiying..?
     Convert BIP To CSV By MCShark CB013507 Check1        ${CB013507_BIP_SCN_TC06}/BIP_L1L2.pcap
     ...      ${CB013507_BIP_SCN_TC06}/${BIP_CSV_CB013507_1}       filter=${FILTER_CB013507_1}
     ...       csv_title_list=${COLUMN_NAME1}
     Log to Console       CB013507 gNB BIP initialUlEcidTAdv value verified :) :)
     Log to Console       CB013507 gNB BIP initialTa value verifiying..?
     Convert BIP To CSV By MCShark CB013507 Check2        ${CB013507_BIP_SCN_TC06}/BIP_L1L2.pcap
     ...      ${CB013507_BIP_SCN_TC06}/${BIP_CSV_CB013507_2}       filter=${FILTER_CB013507_2}
     ...       csv_title_list=${COLUMN_NAME2}
     Log to Console       CB013507 gNB BIP initialTa value verified :) :)
     Log to Console       CB013507 CSV verification Python has script started..?
     ${csv1}=    Set Variable
     ...      /home/ute/logs/CB013507_TC06_Call/gNB/biptaf/TestCase_gnbbip/BIP_L1L2_filter_initialUlEcidTAdv.csv
     ${csv2}=    Set Variable
     ...      /home/ute/logs/CB013507_TC06_Call/gNB/biptaf/TestCase_gnbbip/BIP_L1L2_filter_initialTa.csv
     ${result}=    Validate Bip Values    ${csv1}    ${csv2}
     Log to Console       \nCB013507 TC06 Main Validation Python script started to check delay range\n
     ${result_delay}=     Check Delay Values In Range          ${CB013507_CSV_PATH_Delay_After_TC06}
     Should Be Equal     ${result_delay}     PASS
     Log To Console      Final Result: ${result_delay}
     Log to Console       \nCB013507 TC06 Main Validation Python script completed.. :) :)\n
     Log to Console       \nThe End Testcase is Completed!..\n

