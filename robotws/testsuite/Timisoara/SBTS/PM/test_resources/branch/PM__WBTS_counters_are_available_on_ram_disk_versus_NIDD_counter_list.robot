*** Settings ***
Documentation
    ...  Step1: Load measurements and abbreviations xls from provided paths.
    ...   Wait for a new PM report and read it from BTS.
    ...  Step2: Compare required measurements with existing PM counters.
    ...   Dump PM report xml to a BTS Files directory.

Library  DateTime
Library  SSHLibrary
Library  hran_pm
Library  taf.sbts.oam.coam.admin  WITH NAME  coam
Resource  ../../../resources/verdicts.robot
Resource  ../../../resources/pm.robot
Resource  ../../../resources/pm_logs_frame.robot
Resource  ../../../resources/pm_logs_general.robot
Resource  ../../../resources/dcap.robot
# Resource  /taf/rfrl/common_resources/common_step/interface.robot
Resource  ../../../common_resources/ca_PM_general.robot


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
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-6294
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  2017-06-08 - TC delivery
    ...  - 25.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7815 - Remove references to LNBTS
    ...  - 17.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-8059 - Download SCF via admin and pass its parameter to hran_pm
    ...  - 28.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8393 - Check GNCELs via admin
    ...  - 30.11.2017 - TAT-8391 - leave only one reset and change the verification approach for Check BTS State
    ...  - 26.01.2018 - TAT-8556 - Added filtrating NIDD file, also corrected checking bts states in step1
    ...  - 30.01.2018 - TAT-9029 - TC moved from RGT to CI directory
    ...  - 02.02.2018 - TAT-9074 - Added convert time in step2
    ...  - 22.02.2018 - TAT-9196 - Changed counters checking logic
    ...  - 22.02.2018 - TAT-9131 - Add test variable STARTUP_TIMEOUT
    ...  - 09.11.2018 - TAT-12630 - Changed variables TO_FILTRATE_KEYS, TO_FILTRATE_VALUES according to new export from NIDD tool
    ...  - 30.05.2018 - TAT-16252 - New group in charge and maintainer for TC
    ...  - 11.03.2021 - TAT-21028 - TC failed with empty measurment list, information about how many measurments and counters was filtred
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-05-12 - TAT-23087 - Link to flowchart corrected
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...           checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 2023-02-13 - TAT-24701 - Added reportingIntervalPM verification and waiting for complete PM report.
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...  - 2023-06-07 - TAT-25492 - Adding DCAP Keywords to TC Setup and TC Teardown for log collection
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/TAT-6294.png

    Set Tags  CA-SWM  OWNER-iuliia.taupeka@nokia.com  AUTHOR-joanna.bielawska@nokia.com  MAINTAINER-iuliia.taupeka@nokia.com
    ...  GROUP_IN_CHARGE-WRO_6_Vrf  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001145_RP000933  FEATURE-RP001486_RP000933

    Step0: Preconditions
    Step1: Download PM Report, Compare Result With NIDD Output


Step0: Preconditions
    [Documentation]
    ...  In this step parameter reportingIntervalPm is set to 60min, if this value was different.
    ...  Test waits appropriate amount of time for complete PM report.

    Log  Step0: Preconditions  console=true
    ${bts_connection}  coam.Connect_to
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}

    ${is_interval_correct}  Query Infomodel
    ...  check /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${BTS_ID}/MNL_A-*/MNLENT_A-*/PMCADM_A-* is [reportingIntervalPm=60min]
    ...  allow_negative_result=True
    Run Keyword If  '${is_interval_correct}' != '${True}'
    ...  Run Keywords
    ...  Change Reporting Interval To 60 Min
    ...  AND
    ...  Wait For Full Report After Interval Change
    ...  ELSE
    ...  Wait For Full Report


Step1: Download PM Report, Compare Result With NIDD Output
    [Documentation]
    ...  In this step PM report is downloaded and compared with NIDD output.

    Log  Step1: Download PM Report, Compare Result With NIDD Output  console=true
    pm.Download PM Report
    ${req_measurements}  Create Dictionary
    ${measurements}  Get Required Measurements
    ${keys_mesurements}  Get Dictionary Keys  ${measurements}
    FOR  ${key}  IN  @{keys_mesurements}
        ${meas_value}  Get From Dictionary  ${measurements}  ${key}
        ${status}  ${value}  Run Keyword And Ignore Error
        ...  Should Not Match Regexp  ${meas_value[0]}  ${WCDMA_TRS_COUNTERS}
        Run Keyword If  '${status}'=='PASS'
        ...  Set To Dictionary  ${req_measurements}  ${key}=${meas_value}
    END

    ${measurements_len}  Get Length  ${measurements}
    Log  Meaaurments list length: ${measurements_len}  console=true
    Run Keyword If  ${measurements_len}==0
    ...  verdicts.Set Test Failed  EMPTY MEASURMENTS LIST!
    ${counters}  Set Variable  0
    FOR  ${measurement}  IN  @{measurements}
        ${numbers_list}  Set Variable  ${measurements['${measurement}']}
        ${n_len}  Get Length  ${numbers_list}
        Log  Measurment: ${measurement} -> number of counters: ${n_len}  console=true
        ${counters}  Evaluate  ${counters}+${n_len}
        Run Keyword And Continue On Failure
        ...  pm.Check If Counters Are Present  ${measurement}  ${numbers_list}
    END
    Log  TOTAL number of counters: ${counters}  console=true

    Dump Pm Report  ${BTS_FILES}/PM_REPORT.xml

    [Teardown]  Teardown PM Library


Change Reporting Interval To 60 Min
    [Documentation]
    ...  This KW changes parameter reportingIntervalPm to 60min.

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

    ssh_utils.Setup SMOD Connection
    ${bts_uptime_sec}  ssh_utils.Run Command  awk '{print int($1)}' /proc/uptime
    ${bts_uptime_min}  Evaluate  int(${bts_uptime_sec}/60)
    ${waiting_time}  Evaluate  int(120-${bts_uptime_min})
    Log  BTS Uptime is ${bts_uptime_min} min.  console=true
    Run Keyword If  ${bts_uptime_min}<120
    ...  Run Keywords
    ...  Log  Waiting ${waiting_time}min for complete report.  console=true
    ...  AND
    ...  Sleep  ${waiting_time}m


Teardown PM Library
    Teardown Pm
    Teardown Measurements


TC Setup
    Run Keywords
    ...  Common Test Setup


TC Teardown
    Run Keywords
    ...  interface.Common Step Trigger
    ...  AND
    ...  Common Test Teardown
