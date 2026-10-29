*** Settings ***
Documentation
    ...  Step1: Load measurements and abbreviations xls from provided paths.
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
TC__PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroslaw
    ...  - 18.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27675 - Check counters path
    ...  - 09.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30364 - Add fids for watchdog
    ...  - 13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30519 - Get SCF file with auto configured parameters

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-sebastian.burniak@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_vrf  PHASE-CRT  FEATURE-RP000918

    Step0: Change Parameters To Default Values If Needed
    Step1: Download Latest PM Report
    Step2: Compare PM Result With NIDD Output


Step0: Change Parameters To Default Values If Needed
    coam.Get Current Scf File  ${BTS_FILES}  SCF.xml  with_auto_configured_parameters=${TRUE}
    Setup Pm  scf_path=${BTS_FILES}/SCF.xml
    ${status}  ${interval}  Run Keyword And Ignore Error
    ...  Get Scf Parameter  topFreqSyncStatisticsInterval
    ${bts_id}  Admin Get BTS ID
    Run Keyword If  '${status}'=='FAIL'
    ...  coam.Perform Parameter Recommissioning  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1
    ...  topFreqSyncStatisticsInterval
    ...  update
    ...  15min
    ...  skip_parameter_relation_errors=True
    ${status}  ${interval}  Run Keyword And Ignore Error
    ...  Get Scf Parameter  ipV4AddressStatisticsInterval
    Run Keyword If  '${status}'=='FAIL'
    ...  coam.Perform Parameter Recommissioning  MRBTS-${bts_id}/TNLSVC-1/PMTNLINT-1
    ...  ipV4AddressStatisticsInterval
    ...  update
    ...  disabled
    ...  skip_parameter_relation_errors=True

    [Teardown]  Teardown Pm


Step1: Download Latest PM Report
    Log  Step1: Download Latest PM Report  console=true
    Download PM Report


Step2: Compare PM Result With NIDD Output
    Log  Step2: Compare PM Result With NIDD Output  console=true

    ${measurements}  Get Required Measurements
    ${measurements_len}  Get Length  ${measurements}
    Log  Meaaurments list length: ${measurements_len}  console=true
    Run Keyword If  ${measurements_len}==0
    ...  Set Test Failed  EMPTY MEASURMENTS LIST!
    ${counters}  Set Variable  0
    FOR  ${measurement}  IN  @{measurements}
        ${numbers_list}  Set Variable  ${measurements['${measurement}']}
        ${n_len}  Get Length  ${numbers_list}
        Log  Measurment: ${measurement} -> number of counters: ${n_len}  console=true
        ${counters}  Evaluate  ${counters}+${n_len}
        Check If Counters Are Present  ${measurement}  ${numbers_list}  check_trs_counters_path=${True}
    END
    Log  TOTAL number of counters: ${counters}  console=true

    Dump Pm Report  ${BTS_FILES}/PM_REPORT.xml

    [Teardown]  Teardown PM Library


Teardown PM Library
    Teardown Pm
    Teardown Measurements


TC Setup
    Common Test Setup  tc_name=PM__TNL_counters_available


TC Teardown
    Common Test Teardown
