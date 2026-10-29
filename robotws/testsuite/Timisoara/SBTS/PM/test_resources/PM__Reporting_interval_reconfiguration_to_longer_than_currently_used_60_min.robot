*** Settings ***
Documentation
    ...  Purpose of this test case is to verify that PM reporting interval change works properly on SBTS.
    ...  In this case reporting interval is changed from shorter (15min or 30 min) to longer (60min) value.
    ...  Details are described under LTE_OPR_REQ_321 requirement and its ACs.
    ...  Step1: Test Preconditions
    ...   - Time should be synced
    ...   - SBTS should be OnAir
    ...   - Should Not Be Equal
    ...  Step2: Get Last Available PM File Name And Save The File
    ...   - PM result file should already exist on BTS. If not, timeout is set for waiting.
    ...  Step3: Recommissioning - Change Reporting Interval
    ...   - Recommissioning of Reporting Interval to 60min is performed via ADMIN.
    ...  Step4: Verify That Reporting Interval Changed Correctly
    ...   - reporting interval change to longer than currently used should appear when current interval ends.
    ...  Step5: Recommissioning To Previous Reporting Interval
    ...   - Recommissioning of Reporting Interval to old value is performed via ADMIN

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${CHANGE_BACK_REPORTING_INTERVAL}  True


*** Keywords ***
TC__PM__Reporting_interval_reconfiguration_to_longer_than_currently_used_60_min
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroslaw
    ...  - 13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30519 - Get SCF file with auto configured parameters

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-iuliia.taupeka@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_vrf  PHASE-CRT

    Step1: Test Preconditions
    Step2: Get Last Available PM File Name And Save The File
    Step3: Recommissioning - Change Reporting Interval
    Step4: Verify That Reporting Interval Changed Correctly
    Run Keyword If  ${CHANGE_BACK_REPORTING_INTERVAL}==True
    ...  Step5: Recommissioning To Previous Reporting Interval


Step1: Test Preconditions
    Log  \n----- Step1: Test Preconditions Check ----- \n  console=true
    Set Test Variable  ${NEW_REPORTING_INTERVAL}  60min
    Change ReportingIntervalPm To 15 Min If Needed
    coam.Get Current Scf File  ${BTS_FILES}  SCF.xml  with_auto_configured_parameters=${TRUE}
    Setup Pm  scf_path=${BTS_FILES}/SCF.xml
    ${current_reporting_interval_in_seconds}  Get Reporting Interval  # Value is in seconds
    ${current_reporting_interval_in_minutes}  Evaluate  int(${current_reporting_interval_in_seconds}/60)
    Log  Current reporting interval is ${current_reporting_interval_in_minutes} min  console=true
    ${current_reporting_interval_string}  Catenate  SEPARATOR=  ${current_reporting_interval_in_minutes}  min
    Should Not Be Equal  ${current_reporting_interval_string}  ${NEW_REPORTING_INTERVAL}
    Set Test Variable  ${OLD_REPORTING_INTERVAL}  ${current_reporting_interval_in_minutes}


Step2: Get Last Available PM File Name And Save The File
    Log  \n----- Step2: Get Last Available PM File Name And Save The File ----- \n  console=true
    ${last_pm_result_filename}  Wait Until Keyword Succeeds  ${OLD_REPORTING_INTERVAL}m  2m
    ...  Get Newest PM File Name
    ${last_unzipped_pm_file_name_before_reconfiguration}  Fetch From Left  ${last_pm_result_filename}  .gz
    Set Test Variable  ${PM_FILENAME_BEFORE_RECONF}  ${last_unzipped_pm_file_name_before_reconfiguration}
    Log  Last PM result file available on flash before reconfiguration: ${last_pm_result_filename}  console=true
    Read PM File
    Dump Pm Report  ${BTS_FILES}/PM_REPORT_${last_unzipped_pm_file_name_before_reconfiguration}
    ${last_timestamp_before_reconfiguration}  Get Timestamp From Filename  ${last_unzipped_pm_file_name_before_reconfiguration}
    Set Test Variable  ${LAST_TIMESTAMP_BEFORE_RECONFIGURATION}
    Log  Last available timestamp before reconfiguration is ${LAST_TIMESTAMP_BEFORE_RECONFIGURATION}  console=true
    Log  Unzipped PM file ${last_unzipped_pm_file_name_before_reconfiguration} saved in BTS Files folder.  console=true


Step3: Recommissioning - Change Reporting Interval
    Log  \n----- Step3: Perform parameter reconfiguration: change reporting interval ----- \n  console=true
    ${bts_id}  Admin Get BTS ID
    ${distname}  Set Variable  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMCADM-1
    coam.Perform Parameter Recommissioning  ${distname}  reportingIntervalPm  update  ${NEW_REPORTING_INTERVAL}  skip_parameter_relation_errors=True
    Log  Reporting interval successfully changed from ${OLD_REPORTING_INTERVAL}min to ${NEW_REPORTING_INTERVAL}  console=true


Step4: Verify That Reporting Interval Changed Correctly
    Log  \n----- Step4: Verify That Reporting Interval Changed Correctly ----- \n  console=true
    ${time_now}  Get Current Date  UTC  result_format=%Y%m%d.%H%M%S  exclude_millis=True
    ${minutes_after_reconfiguration}  Get Minutes From Timestamp  ${time_now}
    ${current_quarter}  Get Current Quarter  ${minutes_after_reconfiguration}
    Run Keyword If  ${OLD_REPORTING_INTERVAL} == 15
    ...  Verify If Reporting Interval Changed Properly For 15min  ${minutes_after_reconfiguration}  ${current_quarter}  ${time_now}
    ...  ELSE IF  ${OLD_REPORTING_INTERVAL} == 30
    ...  Verify If Reporting Interval Changed Properly For 30min  ${minutes_after_reconfiguration}  ${current_quarter}  ${time_now}
    ...  ELSE
    ...  Log  Wrong reporting interval value  console=true


Step5: Recommissioning To Previous Reporting Interval
    Log  \n----- Step5: Recommissioning To Previous Reporting Interval ----- \n  console=true
    ${bts_id}  Admin Get BTS ID
    ${distname}  Set Variable  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMCADM-1
    coam.Perform Parameter Recommissioning  ${distname}  reportingIntervalPm  update  ${OLD_REPORTING_INTERVAL}min
    ...  skip_parameter_relation_errors=True
    Log  Reporting interval successfully changed back from ${NEW_REPORTING_INTERVAL} to ${OLD_REPORTING_INTERVAL}min  console=true


Verify If Reporting Interval Changed Properly For 15min
    [Documentation]
    ...  This keyword (if old reporting interval= 15min) depending on quarter of reconfiguration chooses and performas Verification Pah1 or Path2.
    ...  Detailed steps are described in KWs for each path.
    [Arguments]  ${minutes_when_reconfig_done}  ${quarter_now}  ${timestamp_after_reconfig}

    Run Keyword If  ${quarter_now} == 1 or ${quarter_now} == 2 or ${quarter_now} == 4
    ...  Verify If Reporting Interval Changed Correctly Path1  ${minutes_when_reconfig_done}  ${timestamp_after_reconfig}
    ...  ELSE IF  ${quarter_now} == 3
    ...  Verify If Reporting Interval Changed Correctly Path2  ${minutes_when_reconfig_done}  ${timestamp_after_reconfig}
    ...  ELSE
    ...  Log  Wrong Evaluation  console=true


Verify If Reporting Interval Changed Properly For 30min
    [Documentation]
    ...  This keyword (if old reporting interval= 30min) depending on quarter of reconfiguration chooses and performas Verification Pah1 or Path2.
    ...  Detailed steps are described in KWs for each path.
    [Arguments]  ${minutes_when_reconfig_done}  ${quarter_now}  ${timestamp_after_reconfig}

    Run Keyword If  ${quarter_now} == 1 or ${quarter_now} == 2
    ...  Verify If Reporting Interval Changed Correctly Path2  ${minutes_when_reconfig_done}  ${timestamp_after_reconfig}
    ...  ELSE IF  ${quarter_now} == 3 or ${quarter_now} == 4
    ...  Verify If Reporting Interval Changed Correctly Path1  ${minutes_when_reconfig_done}  ${timestamp_after_reconfig}
    ...  ELSE
    ...  Log  Wrong Evaluation  console=true


Verify If Reporting Interval Changed Correctly Path1
    [Documentation]
    ...  This keyword performs verification Path1:
    ...  1) Wail till end of current interval
    ...  2) Check if PM file with old int created
    ...  3) Wait Old Reporting Interval
    ...  4) Check That There Is No New PM File Created
    ...  5) Wait Till End Of New Reporting Interval
    ...  6) Check That New PM File Created With Expected Timestamp
    [Arguments]  ${minutes_when_reconfig_done}  ${timestamp_after_reconfig}

    Log  Verification PATH 1 start  console=true
    Log  \n----- 4.1 Wail till end of current interval ----- \n  console=true
    ${time_till_end_of_old_rep_interval}  Calculate Timer Till End Od Current Reporting Interval  ${minutes_when_reconfig_done}
    ${min_till_end_of_old_rep_interval}  Set Variable  ${time_till_end_of_old_rep_interval} minutes
    ${expected_filename_at_the_end_of_old_rep_interval}  Calculate Expected Filename  ${min_till_end_of_old_rep_interval}
    ...  ${timestamp_after_reconfig}
    Log  Expected filename at the end of OLD reporting interval ${expected_filename_at_the_end_of_old_rep_interval}  console=true
    ${time_to_wait_for_next_file}  Evaluate  ${time_till_end_of_old_rep_interval} + 1
    Log  Waiting timer till end of current(old) reporting interval: ${time_to_wait_for_next_file} minutes...  console=true
    Sleep  ${time_to_wait_for_next_file}m
    Log  \n----- 4.2 Check if PM file with old int created ----- \n  console=true
    ${first_pm_file_name_after_reconf}  Check If Created PM File With Current Reporting Interval  ${expected_filename_at_the_end_of_old_rep_interval}
    Log  \n----- 4.3 Wait Old Reporting Interval ----- \n  console=true
    Wait Old Reporting Interval
    Log  \n----- 4.4 Check That There Is No New PM File Created ----- \n  console=true
    Check That There Is No New PM File Created  ${first_pm_file_name_after_reconf}
    Log  \n----- 4.5 Calculate And Wait Timer Till End Of New Reporting Interval ----- \n  console=true
    ${time_till_end_of_new_rep_interval}  Calculate Timer Till End Of New Reporting Interval
    ${min_till_end_of_new_rep_interval}  Set Variable  ${time_till_end_of_new_rep_interval} minutes
    ${time_to_wait_for_next_file}  Evaluate  int(${time_till_end_of_new_rep_interval} + 1)
    ${new_time_now}  Get Current Date  UTC  result_format=%Y%m%d.%H%M%S  exclude_millis=True
    ${expected_filename_at_the_end_of_new_rep_interval}  Calculate Expected Filename  ${min_till_end_of_new_rep_interval}  ${new_time_now}
    Log  Expected filename at the end of NEW reporting interval ${expected_filename_at_the_end_of_new_rep_interval}  console=true
    Sleep  ${time_to_wait_for_next_file}m
    Log  \n----- 4.6 Check That New PM File Created With Expected Timestamp ----- \n  console=true
    ${pm_file_name_with_new_interval}  Check That New PM File Created With Expected Timestamp  ${expected_filename_at_the_end_of_new_rep_interval}


Verify If Reporting Interval Changed Correctly Path2
    [Documentation]
    ...  This keyword performs verification Path2:
    ...  1) Wail till end of current interval
    ...  2) Check if PM file with old int created
    ...  3) Wait Timer Till End Of New Reporting Interval
    ...  4) Check That New PM File Created With Expected Timestamp
    ...  5) Wait Old Reporting Interval
    ...  6) Check That There Is No New PM File Created
    [Arguments]  ${minutes_when_reconfig_done}  ${timestamp_after_reconfig}

    Log  Verification PATH 2 start  console=true
    Log  \n----- 4.1 Wail till end of current interval ----- \n  console=true
    ${time_till_end_of_old_rep_interval}  Calculate Timer Till End Od Current Reporting Interval  ${minutes_when_reconfig_done}
    ${min_till_end_of_old_rep_interval}  Set Variable  ${time_till_end_of_old_rep_interval} minutes
    ${expected_filename_at_the_end_of_old_rep_interval}  Calculate Expected Filename  ${min_till_end_of_old_rep_interval}
    ...  ${timestamp_after_reconfig}
    Log  Expected filename at the end of OLD reporting interval ${expected_filename_at_the_end_of_old_rep_interval}  console=true
    ${time_to_wait_for_next_file}  Evaluate  ${time_till_end_of_old_rep_interval} + 1
    Log  Waiting timer till end of current(old) reporting interval: ${time_to_wait_for_next_file} minutes...  console=true
    Sleep  ${time_to_wait_for_next_file}m
    Log  \n----- 4.2 Check if PM file with old int created ----- \n  console=true
    ${first_pm_file_name_after_reconf}  Check If Created PM File With Current Reporting Interval  ${expected_filename_at_the_end_of_old_rep_interval}
    Log  \n----- 4.3 Calculate And Wait Timer Till End Of New Reporting Interval ----- \n  console=true
    ${time_till_end_of_new_rep_interval}  Calculate Timer Till End Of New Reporting Interval
    ${min_till_end_of_new_rep_interval}  Set Variable  ${time_till_end_of_new_rep_interval} minutes
    ${time_to_wait_for_next_file}  Evaluate  int(${time_till_end_of_new_rep_interval} + 1)
    ${new_time_now}  Get Current Date  UTC  result_format=%Y%m%d.%H%M%S  exclude_millis=True
    ${expected_filename_at_the_end_of_new_rep_interval}  Calculate Expected Filename  ${min_till_end_of_new_rep_interval}  ${new_time_now}
    Log  Expected filename at the end of NEW reporting interval ${expected_filename_at_the_end_of_new_rep_interval}  console=true
    Sleep  ${time_to_wait_for_next_file}m
    Log  \n----- 4.4 Check That New PM File Created With Expected Timestamp ----- \n  console=true
    ${pm_file_name_with_new_interval}  Check That New PM File Created With Expected Timestamp  ${expected_filename_at_the_end_of_new_rep_interval}
    Log  \n----- 4.5 Wait Old Reporting Interval ----- \n  console=true
    Wait Old Reporting Interval
    Log  \n----- 4.6 Check That There Is No New PM File Created ----- \n  console=true
    Check That There Is No New PM File Created  ${pm_file_name_with_new_interval}


Calculate Expected Filename
    [Documentation]
    ...  This keyword calculates and returns expected filename (by adding minutes to timestamp from input).
    [Arguments]  ${minutes_to_add}  ${timestamp}

    ${new_timestamp}  Add Reporting Interval Minutes To Timestamp  ${timestamp}  ${minutes_to_add}
    ${expected_new_filename}  Get Expected File Name  ${PM_FILENAME_BEFORE_RECONF}  ${LAST_TIMESTAMP_BEFORE_RECONFIGURATION}  ${new_timestamp}

    [Return]  ${expected_new_filename}


Calculate Timer Till End Od Current Reporting Interval
    [Documentation]
    ...  This keyword calculates and returns time till end of current (old) reporting interval (in minutes).
    [Arguments]  ${minutes_now}

    ${time_till_end_of_current_rep_interval}  Evaluate  int(${OLD_REPORTING_INTERVAL} - ${minutes_now}%${OLD_REPORTING_INTERVAL})

    [Return]  ${time_till_end_of_current_rep_interval}


Check If Created PM File With Current Reporting Interval
    [Documentation]
    ...  This keyword verifies that there was created PM file name at the end of current(old) reporting interval.
    ...  KW returns PM file name after end of current (old) interval.
    [Arguments]  ${expected_new_filename}

    ${first_pm_file_name_after_change}  Get Newest PM File Name
    ${first_pm_file_name_after_change}  Fetch From Left  ${first_pm_file_name_after_change}  .gz
    Should Be Equal  ${expected_new_filename}  ${first_pm_file_name_after_change}  msg=Expected PM result file not found
    Log  PM result filename after reconfiguration ${first_pm_file_name_after_change} as expected.  console=true

    [Return]  ${first_pm_file_name_after_change}


Wait Old Reporting Interval
    [Documentation]
    ...  This keyword waits time equal to old reporting interval value (before reconfiguration)
    Log  Waiting old reporting interval ${OLD_REPORTING_INTERVAL} minutes  console=true
    Sleep  ${OLD_REPORTING_INTERVAL}m


Check That There Is No New PM File Created
    [Documentation]
    ...  This keyword verifies that there is no new unecpeted file created (by filenames comparison).
    [Arguments]  ${first_pm_filename_after_changed_rep_int}

    ${newest_available_pm_filename}  Get Newest PM File Name
    ${newest_available_pm_filename}  Fetch From Left  ${newest_available_pm_filename}  .gz
    Log  Now first_PM_filename_after_changed_repInt and newest_available_PM_filename should be equal  console=true
    Log  ${first_pm_filename_after_changed_rep_int} ${newest_available_pm_filename}  TRACE  console=true
    Should Be Equal  ${first_pm_filename_after_changed_rep_int}  ${newest_available_pm_filename}
    ...  msg=Name of PM file after reconfiguration is incorrect.


Calculate Timer Till End Of New Reporting Interval
    [Documentation]
    ...  This keyword calculates and returns time to end of new reporting interval.

    ${time_now_minutes}  Get Time  minutes
    ${time_now_minutes}  Convert To Integer  ${time_now_minutes}
    Log  Timestamp (minutes) now: ${time_now_minutes}  console=true
    ${time_to_end_of_new_reporting_interval}  Evaluate  int(60 - ${time_now_minutes})
    Log  Now Sleeping Till End Of New Reporting Interval: ${time_to_end_of_new_reporting_interval} minutes  console=true

    [Return]  ${time_to_end_of_new_reporting_interval}


Check That New PM File Created With Expected Timestamp
    [Documentation]
    ...  This keyword verifies that new PM file is created with expected timestamp according to new configured
    ...  reporting interval. KW returns filename with changed reporting interval.
    [Arguments]  ${expected_target_filename_after_reconfig}

    ${pm_file_name_with_changed_rep_int}  Get Newest PM File Name
    ${pm_file_name_with_changed_rep_int}  Fetch From Left  ${pm_file_name_with_changed_rep_int}  .gz
    Should Be Equal  ${expected_target_filename_after_reconfig}  ${pm_file_name_with_changed_rep_int}  msg=Expected PM result file not found
    Log  PM result filename after reconfiguration ${pm_file_name_with_changed_rep_int} as expected.  console=true

    [Return]  ${pm_file_name_with_changed_rep_int}


Add Reporting Interval Minutes To Timestamp
    [Documentation]
    ...  This keyword calculates and returns expected timestamp for next PM result file
    ...  (by adding minutes to timestamp).
    [Arguments]  ${timestamp_from_last_file}  ${time_to_add}

    ${expected_pm_file_timestamp}  Add Time To Date  ${timestamp_from_last_file}  ${time_to_add}  result_format=%Y%m%d.%H%M00

    [Return]  ${expected_pm_file_timestamp}


Get Expected File Name
    [Documentation]
    ...  This keyword calculates and returns expected PM result filename.
    [Arguments]  ${last_pm_filename}  ${old_timestamp}  ${new_timestamp}

    ${expected_filename}  Replace String  ${last_pm_filename}  ${old_timestamp}  ${new_timestamp}

    [Return]  ${expected_filename}


Get Timestamp From Filename
    [Documentation]
    ...  This keyword extracts and returns timestamp from PM filename.
    [Arguments]  ${filename}

    Log  KW Get Timestamp From Filename START  console=true
    ${date_and_time_stamp}  Get Regexp Matches  ${filename}  \\d{8}\\.\\d{6}
    ${date_and_time_stamp}  Set Variable  ${date_and_time_stamp[0]}

    [Return]  ${date_and_time_stamp}


Get Minutes From Timestamp
    [Documentation]
    ...  This keyword extracts and returns minutes from given timestamp.
    [Arguments]  ${timestamp}

    Log  Current time is: ${timestamp}  console=true
    ${minutes_now}  Convert Date  ${timestamp}  result_format=%M
    ${minutes_int}  Convert To Integer  ${minutes_now}
    Log  Timestamp (minutes) now: ${minutes_int}  console=true

    [Return]  ${minutes_int}


Get Current Quarter
    [Documentation]
    ...  This keyword calculates and returns number of current quarter of an hour
    ...  Eg. if time now is 15:03 -> quarter=1; 15:47 -> quarter=4.
    [Arguments]  ${minutes}

    ${current_quarter}  Run Keyword If  ${minutes} < 15
    ...  Set Variable  1
    ...  ELSE IF  15 <= ${minutes} < 30
    ...  Set Variable  2
    ...  ELSE IF  30 <= ${minutes} < 45
    ...  Set Variable  3
    ...  ELSE
    ...  Set Variable  4
    Log  Current quarter is: ${current_quarter}  console=true
    ${current_quarter}  Convert To Integer  ${current_quarter}

    [Return]  ${current_quarter}


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
