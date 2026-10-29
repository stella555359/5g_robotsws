*** Settings ***
Documentation
    ...  Step1: Download SCF from admin.
    ...   Load measurements and abbreviations xls from provided paths.
    ...   Wait for a new PM report and read it from BTS.
    ...  Step2: Compare required measurements with existing PM counters.
    ...   Dump PM report xml to a BTS Files directory.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${MEASUREMENT_PATH}  ${EMPTY}  # Path to NIDD exported counters xls file
${ABBREVIATION_DICT_PATH}  ${EMPTY}  # Path to measurement abbreviations xls file
${TO_FILTRATE_KEYS}  Product_types,Category,Document_state  # Column names (comma separated) list from NIDD file to filtrate
${TO_FILTRATE_VALUES}  Flexi_SBTS|Flexi_AirScale,Customer,Published  # Columns values (comma seprarated, allowed '|' as 'or' operator)
# from NIDD file to filtrate
${STARTUP_TIMEOUT}  15  # Timeout for BTS to startup after reset, default value 15 min


*** Keywords ***
TC__PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-5374
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 02.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-5374 - Initial creation
    ...  - 25.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7815 - Remove references to LNBTS
    ...  - 17.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-8059 - Download SCF via admin and pass its parameter to hran_pm
    ...  - 10.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8141 - TC shouldn't check cells states for missing technologies
    ...  - 30.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8391 - leave only one reset and change the verif approach for Check BTS State
    ...  - 15.12.2017 - https://jira3.int.net.nokia.com/browse/TAT-8542 - KW Assert every failed when no objects are found
    ...  - 25.01.2018 - https://jira3.int.net.nokia.com/browse/TAT-8556 - Two new parameters added to filtrate NIDD file
    ...  - 22.02.2018 - https://jira3.int.net.nokia.com/browse/TAT-9196 - Changed counters checking logic
    ...  - 22.02.2018 - https://jira3.int.net.nokia.com/browse/TAT-9131 - Add test variable STARTUP_TIMEOUT
    ...  - 09.11.2018 - https://jira3.int.net.nokia.com/browse/TAT-12630 - Changed variables TO_FILTRATE_KEYS, TO_FILTRATE_VALUES
    ...                                                              according to new export from NIDD tool
    ...  - 30.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-16252 - New group in charge and maintainer for TC
    ...  - 11.03.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21028 - TC failed with empty measurment list,
    ...                                                              information about how many measurments and counters was filtred
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-5374.png#

    Set Tags  CA-PM  OWNER-iuliia.taupeka@nokia.com  AUTHOR-sebastian.burniak@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP000918

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
    ...  Set Test Failed  message=EMPTY MEASURMENTS LIST!
    ${counters}  Set Variable  0
    FOR  ${measurement}  IN  @{measurements}
        ${numbers_list}  Set Variable  ${measurements['${measurement}']}
        ${n_len}  Get Length  ${numbers_list}
        Log  Measurment: ${measurement} -> number of counters: ${n_len}  console=true
        ${counters}  Evaluate  ${counters}+${n_len}
        Run Keyword And Continue On Failure
        ...  Check If Counters Are Present  ${measurement}  ${numbers_list}
    END
    Log  TOTAL number of counters: ${counters}  console=true


Teardown PM Library
    Teardown Pm
    Teardown Measurements


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
