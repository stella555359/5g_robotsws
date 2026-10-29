*** Settings ***
Documentation
...  SBTS10339 PM TC trunk sutie Exploratory

Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_SRAN_LWG_10339_1ASIA_2ABIA_2FXDB_1FHEL_2FRGY  STATE_COMMISSIONED
Library           XML  use_lxml=True

Resource    ../../PM/test_resources/PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../PM/test_resources/PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../PM/test_resources/PM__NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../PM/test_resources/PM__Check_Counters_Number_On_NetAct_Reports.robot

Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1339
${SKIP_RU_POWER_CHECK}    ${TRUE}

${PM__LTE_counters_ABBREVIATION_DICT_PATH}    SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       LTE_Abbreviations.csv

${PM__MEASUREMENT_PATH}                       SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       SBTS26R1_LTE_Counters_339.csv

${PM__TNL_counters_ABBREVIATION_DICT_PATH}    SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       TNL_Abbreviations.csv

${PM__TNL_counters_MEASUREMENT_PATH}          SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       26R1_TNL_Counters_339.csv

${PM__NR_MEASUREMENT_PATH}                   SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       SBTS26R1_NR_Counters_339.csv

${PM__NR_counters_ABBREVIATION_DICT_PATH}  SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       NR_Abbreviations.csv


*** Test Cases ***
PM__Check_Counters_Number_On_NetAct_Reports
    [Tags]     QC_***
    [Setup]    Run Keywords
    ...    Set Test Variable    ${WEB_URL}    srnclab5012lbwas.srnblr.nsn-rdnet.net
    ...    AND    Set Test Variable    ${CMWAS_SERVICE_IP}    10.8.103.185
    ...    AND    PM__Check_Counters_Number_On_NetAct_Reports.TC Setup
    ...    AND    Modify Resource Search Order    PM__Check_Counters_Number_On_NetAct_Reports
    ...    AND    Set Library Search Order    PM__Check_Counters_Number_On_NetAct_Reports
    TC__PM__Check_Counters_Number_On_NetAct_Reports
    [Teardown]    Run Keywords    PM__Check_Counters_Number_On_NetAct_Reports.TC Teardown
    ...    AND    Restore Resource Search Order



[1]Automated__PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Setup]    Run Keywords    Set Test Variable    ${MEASUREMENT_PATH}    ${PM__TNL_counters_MEASUREMENT_PATH}
    ...    AND    Set Test Variable    ${ABBREVIATION_DICT_PATH}    ${PM__TNL_counters_ABBREVIATION_DICT_PATH}
    ...    AND    Set Test Variable    ${TO_FILTRATE_KEYS}    Product_types,Category,Document_state
    ...    AND    Set Test Variable    ${TO_FILTRATE_VALUES}    Flexi_SBTS|Flexi_AirScale,Customer,Published
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15
    ...    AND    PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Setup
    ...    AND    Modify Resource Search Order    PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    ...    AND    Set Library Search Order    PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Timeout]    14400
    TC__PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Teardown]    Run Keywords    PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Setup]    Run Keywords    Set Test Variable    ${MEASUREMENT_PATH}    ${PM__MEASUREMENT_PATH}
    ...    AND    Set Test Variable    ${ABBREVIATION_DICT_PATH}    ${PM__LTE_counters_ABBREVIATION_DICT_PATH}
    ...    AND    Set Test Variable    ${TO_FILTRATE_KEYS}    Product_types,Category,Document_state
    ...    AND    Set Test Variable    ${TO_FILTRATE_VALUES}    AirScale_SBTS,Customer,Published
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15
    ...    AND    PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Setup
    ...    AND    Modify Resource Search Order    PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    ...    AND    Set Library Search Order    PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Timeout]    14400
    TC__PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Teardown]    Run Keywords    PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__PM__NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Setup]    Run Keywords    Set Test Variable    ${MEASUREMENT_PATH}    ${PM__NR_MEASUREMENT_PATH}
    ...    AND    Set Test Variable    ${ABBREVIATION_DICT_PATH}    ${PM__NR_counters_ABBREVIATION_DICT_PATH}
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15
    ...    AND    Set Test Variable    ${TO_FILTRATE_KEYS}         Product_types,Category,Document_state
    ...    AND    Set Test Variable    ${TO_FILTRATE_VALUES}    5G CoAM,Customer,Published
    ...    AND    PM__NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Setup
    ...    AND    Modify Resource Search Order    PM__NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    ...    AND    Set Library Search Order    PM__NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Timeout]    14400
    TC__PM__NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Teardown]    Run Keywords    PM__NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...  cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
