*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_NL_10340_1ASOE_2FRHC  STATE_COMMISSIONED
Library           XML  use_lxml=True

Resource    ../../PM/test_resources/PM__NR_measurement_interval_change_from_longer_to_shorter.robot
Resource    ../../PM/test_resources/PM__NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot


*** Variables ***
${SCF_ID}                 01
${HW_LOCATION_CODE}       Timisoara
${REQUEST_SCF_SCOUT}      ${TRUE}
${SCOUT_TL_NAME}          10_18_UTESRANCLOUD1340
${SKIP_RU_POWER_CHECK}    ${TRUE}


${PM__NR_MEASUREMENT_PATH}                   SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       SBTS24R3_NR_Counters.csv

${PM__NR_counters_ABBREVIATION_DICT_PATH}    SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       NR_Abbreviations.csv


*** Test Cases ***
[1]Automated__PM__NR_measurement_interval_change_from_longer_to_shorter
    [Tags]     nr_interval_change
    [Setup]    Run Keywords    Set Test Variable    ${NRPMRNL_PARAMETER_INTERVAL}    miNrCellAvailability=15min, miNrNgInterface=30min
    ...    AND    PM__NR_measurement_interval_change_from_longer_to_shorter.TC Setup
    ...    AND    Modify Resource Search Order    PM__NR_measurement_interval_change_from_longer_to_shorter
    ...    AND    Set Library Search Order    PM__NR_measurement_interval_change_from_longer_to_shorter
    [Timeout]    14400
    TC__PM__NR_measurement_interval_change_from_longer_to_shorter
    [Teardown]    Run Keywords    PM__NR_measurement_interval_change_from_longer_to_shorter.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__PM__NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]     nr_nidd_check
    [Setup]    Run Keywords    Set Test Variable    ${MEASUREMENT_PATH}    ${PM__NR_MEASUREMENT_PATH}
    ...    AND    Set Test Variable    ${ABBREVIATION_DICT_PATH}    ${PM__NR_counters_ABBREVIATION_DICT_PATH}
    ...    AND    Set Test Variable    ${TO_FILTRATE_KEYS}      Product_types,Category,Document_state
    ...    AND    Set Test Variable    ${TO_FILTRATE_VALUES}    5G CoAM,Customer,Published
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15
    ...    AND    PM__NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Setup
    ...    AND    Modify Resource Search Order    PM__NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    ...    AND    Set Library Search Order    PM__NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Timeout]    14400
    TC__PM__NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Teardown]    Run Keywords    PM__NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Teardown
    ...    AND    Restore Resource Search Order
