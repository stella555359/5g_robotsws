*** Settings ***
Documentation
    ...  In first step, TC waits for PM report and compares required measurements, loaded from
    ...  xml files, with existing NR PM counters.
    ...  Next, site reset is performing and after SBTS will reach onAir state,
    ...  counters are verified again.
    ...  Last operation is site power reset. After it, like in the previous steps, counters
    ...  should be visible in WebEM as expected.

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${MEASUREMENT_PATH}  ${EMPTY}
# Mandatory. Path to NIDD exported counters xls file
${ABBREVIATION_DICT_PATH}  ${EMPTY}
# Mandatory. Path to measurement abbreviations xls file
${TO_FILTRATE_KEYS}  Product_types,Category,Document_state
# Column names (comma separated) list from NIDD file to filtrate
${TO_FILTRATE_VALUES}  5G CoAM,Customer,Published
# Columns values (comma seprarated, allowed '|' as 'or' operator) from NIDD file to filtrate
${STARTUP_TIMEOUT}  15
# Timeout for BTS to startup after reset, default value 15 min


*** Keywords ***
TC__PM__Robustness_NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27892
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27892 - Initial TC creation

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT

    Step1: Check Counters On RAM
    Step2: Perform Site Reset
    Step3: Check Counters On RAM
    Step4: Perform Site Power Reset
    Step5: Check Counters On RAM


Step${index}: Check Counters On RAM
    Log  \nStep${index}: Check counters on RAM  console=true
    Download PM Report
    Check Counters For Each Measurement
    Dump Pm Report  ${BTS_FILES}/PM_REPORT_step${index}.xml

    [Teardown]  Teardown PM Library


Step2: Perform Site Reset
    Log  \nStep2: Perform site reset  console=true
    coam.Reset Site  timeout=600
    Wait Until Keyword Succeeds  30m  1m
    ...  Admin Check All Required State


Step4: Perform Site Power Reset
    Log  \nStep4: Perform site power reset  console=true
    coam.Power Reset  timeout=600
    Wait Until Keyword Succeeds  30m  1m
    ...  Admin Check All Required State


Check Counters For Each Measurement
    ${measurements}  Get Required Measurements
    ${measurements_len}  Get Length  ${measurements}
    Log  Measurements list length: ${measurements_len}  console=true
    Run Keyword If  ${measurements_len}==0
    ...  Fail  EMPTY MEASURMENTS LIST!
    ${no_of_counters}  Set Variable  0
    FOR  ${measurement}  IN  @{measurements}
        ${counters_list}  Set Variable  ${measurements['${measurement}']}
        ${n_len}  Get Length  ${counters_list}
        Log  Measurement: ${measurement} -> number of counters: ${n_len}  console=true
        ${no_of_counters}  Evaluate  ${no_of_counters}+${n_len}
        Check If Counters Are Present  ${measurement}  ${counters_list}  check_counters_on_nr_cells=${True}
    END
    Log  TOTAL number of counters: ${no_of_counters}  console=true


Teardown PM Library
    Teardown Pm
    Teardown Measurements


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
