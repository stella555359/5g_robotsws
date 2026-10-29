*** Settings ***
Documentation
    ...  Step1: Load measurements and abbreviations xls from provided paths.
    ...  Wait for a new PM report and read it from BTS.
    ...  Step2: Compare required measurements with existing PM counters.
    ...  Dump PM report xml to a BTS Files directory.

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${MEASUREMENT_PATH}  ${EMPTY}
# Path to NIDD exported counters xls file
${ABBREVIATION_DICT_PATH}  ${EMPTY}
# Path to measurement abbreviations xls file
${WCDMA_TRS_COUNTERS}  M51\\d{2}C\\d+
${TO_FILTRATE_KEYS}  Product_types,Category,Document_state
# Column names (comma separated) list from NIDD file to filtrate
${TO_FILTRATE_VALUES}  Flexi_SBTS|Flexi_AirScale,Customer,Published
# Columns values (comma seprarated, allowed '|' as 'or' operator) from NIDD file to filtrate
${STARTUP_TIMEOUT}  15
# Timeout for BTS to startup after reset, default value 15 min


*** Keywords ***
TC__PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroslaw
    ...  - 26.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27424 - Improve counters check
    ...  - 10.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27478 - Refactor counters check
    ...  - 17.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29103 - Update testcases and resourses for CB011146
    ...  ******************

    Set Tags  CA-SWM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-joanna.bielawska@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_vrf  PHASE-CRT  FEATURE-RP001145_RP000933  FEATURE-RP001486_RP000933

    Step0: Preconditions
    Step1: Download PM Report, Compare Result With NIDD Output


Step0: Preconditions
    [Documentation]
    ...  In this step parameter reportingIntervalPm is set to 60min, if this value was different.
    ...  Test waits appropriate amount of time for complete PM report.

    Log  Step0: Preconditions.  console=true
    ${bts_connection}  coam.Connect_to
    ${bts_id}  Admin Get BTS ID
    Set Test Variable  ${BTS_ID}
    ${is_interval_correct}  Query Infomodel
    ...  check /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${BTS_ID}/MNL_A-*/MNLENT_A-*/PMCADM_A-* is [reportingIntervalPm=60min]
    ...  allow_negative_result=True
    IF  '${is_interval_correct}' != '${True}'
      Change Reporting Interval To 60 Min
      Wait For Full Report After Interval Change
    ELSE
      Wait For Full Report
    END


Step1: Download PM Report, Compare Result With NIDD Output
    [Documentation]
    ...  In this step PM report is downloaded and compared with NIDD output.

    Log  Step1: Download PM Report, Compare Result With NIDD Output.  console=true
    Download PM Report
    ${req_measurements}  Create Dictionary
    ${measurements}  Get Required Measurements
    ${keys_mesurements}  Get Dictionary Keys  ${measurements}
    FOR  ${key}  IN  @{keys_mesurements}
        ${meas_value}  Get From Dictionary  ${measurements}  ${key}
        ${status}  ${value}  Run Keyword And Ignore Error  Should Not Match Regexp  ${meas_value[0]}  ${WCDMA_TRS_COUNTERS}
        IF  '${status}'=='PASS'  Set To Dictionary  ${req_measurements}  ${key}=${meas_value}
    END
    ${measurements_len}  Get Length  ${measurements}
    Log  Measurements list length: ${measurements_len}.  console=true
    IF  ${measurements_len}==0  Set Test Failed  EMPTY MEASURMENTS LIST!
    ${no_of_counters}  Set Variable  0
    FOR  ${measurement}  IN  @{measurements}
        ${counters_list}  Set Variable  ${measurements['${measurement}']}
        ${n_len}  Get Length  ${counters_list}
        Log  Measurement: ${measurement} -> number of counters: ${n_len}  console=true
        ${no_of_counters}  Evaluate  ${no_of_counters}+${n_len}
        Check If Counters Are Present  ${measurement}  ${counters_list}  check_counters_on_wcdma_cells=${True}
    END
    Log  TOTAL number of counters: ${no_of_counters}  console=true
    Dump Pm Report  ${BTS_FILES}/PM_REPORT.xml

    [Teardown]  Teardown PM Library


Change Reporting Interval To 60 Min
    [Documentation]  This KW changes parameter reportingIntervalPm to 60min.

    coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  parameter=reportingIntervalPm  operation=update
    ...  value=60min  skip_parameter_relation_errors=True
    Log  Parameter reportingIntervalPm changed to 60 min.  console=true


Wait For Full Report After Interval Change
    [Documentation]
    ...  This KW calulates minutes remaining to next full hour, adds 60 min and waits that amount of time to download complete PM report.

    ${minutes_now}  Get Time  minutes
    ${minutes_now}  Convert Time  ${minutes_now}
    ${time}  Evaluate  int(120-${minutes_now})
    Log  Waiting ${time}min for complete report.  console=true
    Sleep  ${time}m


Wait For Full Report
    [Documentation]
    ...  This KW checks if BTS uptime is longer than 120 min, if not it waits remaining time to download complete PM report.

    ssh.Connect To  hostname=${OAM_BTS_IP}  username=toor4nsn  password=oZPS0POrRieRtu
    ${bts_uptime_sec}  ssh.Execute  awk '{print int($1)}' /proc/uptime
    ssh.Disconnect
    ${bts_uptime_min}  Evaluate  int(${bts_uptime_sec}/60)
    ${waiting_time}  Evaluate  int(120-${bts_uptime_min})
    Log  BTS Uptime is ${bts_uptime_min} min.  console=true
    IF  ${bts_uptime_min}<120
      Log  Waiting ${waiting_time}min for complete report.  console=true
      Sleep  ${waiting_time}m
    END


Teardown PM Library
    Teardown Pm
    Teardown Measurements


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown