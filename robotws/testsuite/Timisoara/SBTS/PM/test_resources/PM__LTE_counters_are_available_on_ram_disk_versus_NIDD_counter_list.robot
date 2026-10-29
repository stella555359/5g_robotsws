*** Settings ***
Documentation
    ...  Step1: Download SCF from admin.
    ...   Load measurements and abbreviations xls from provided paths.
    ...   Wait for a new PM report and read it from BTS.
    ...  Step2: Compare required measurements with existing PM counters.
    ...   Dump PM report xml to a BTS Files directory.

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${MEASUREMENT_PATH}  ${EMPTY}
# Path to NIDD exported counters xls file
${ABBREVIATION_DICT_PATH}  ${EMPTY}
# Path to measurement abbreviations xls file
${TO_FILTRATE_KEYS}  Product_types,Category,Document_state
# Column names (comma separated) list from NIDD file to filtrate
${TO_FILTRATE_VALUES}  Flexi_SBTS|Flexi_AirScale,Customer,Published
# Columns values (comma seprarated, allowed '|' as 'or' operator) from NIDD file to filtrate
${STARTUP_TIMEOUT}  15
# Timeout for BTS to startup after reset, default value 15 min


*** Keywords ***
TC__PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroslaw
    ...  - 19.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27383 - Improve counters check
    ...  - 09.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30364 - Add fids for watchdog

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-sebastian.burniak@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT

    Step1: Download Latest PM Report
    Step2: Compare PM Result With NIDD Output


Step1: Download Latest PM Report
    Log  Step1: Download Latest PM Report  console=true
    Download PM Report


Step2: Compare PM Result With NIDD Output
    Log  Step2: Compare PM Result With NIDD Output  console=true
    Check Counters For Each Measurement
    Dump Pm Report  ${BTS_FILES}/PM_REPORT.xml

    [Teardown]  Teardown PM Library


Check Counters For Each Measurement
    ${measurements}  Get Required Measurements
    ${measurements_len}  Get Length  ${measurements}
    Log  Meaaurments list length: ${measurements_len}  console=true
    Run Keyword If  ${measurements_len}==0
    ...  Set Test Failed  EMPTY MEASURMENTS LIST!
    ${no_of_counters}  Set Variable  0
    FOR  ${measurement}  IN  @{measurements}
        ${counters_list}  Set Variable  ${measurements['${measurement}']}
        ${n_len}  Get Length  ${counters_list}
        Log  Measurment: ${measurement} -> number of counters: ${n_len}  console=true
        ${no_of_counters}  Evaluate  ${no_of_counters}+${n_len}
        Check If Counters Are Present  ${measurement}  ${counters_list}  check_counters_on_lte_cells=${True}
    END
    Log  TOTAL number of counters: ${no_of_counters}  console=true


Teardown PM Library
    Teardown Pm
    Teardown Measurements


TC Setup
    Common Test Setup  tc_name=LTE_counters_available


TC Teardown
    Common Test Teardown
