*** Settings ***
Documentation
    ...  Purpose of this test case is to verify that PM reporting interval change works properly on SBTS.
    ...  In this case Reporting interval change from shorter to longer is verified.
    ...  Step1: Preconditions check.
    ...   - Time should be synced
    ...   - SBTS should be OnAir
    ...   - New reporting interval should be greater than currently used
    ...  Step2: Get Last Available PM File Name And Save The File
    ...   - PM result file should already exist on BTS. If not, timeout is set for waiting.
    ...   - New reporting interval should be shorted than currently used
    ...  Step3: Recommissioning - Change Reporting Interval
    ...   - Recommissioning via ADMIN is performed
    ...  Step4: Verify That Reporting Interval Changed Correctly
    ...   - reporting interval change to longer than currently used should appear when current interval ends.

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${CHANGE_BACK_REPORTING_INTERVAL}  True


*** Keywords ***
TC__PM__Reporting_interval_reconfiguration_to_longer_than_currently_used_30_min
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroslaw
    ...  - 17.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29103 - Update testcases and resourses for CB011146
    ...  - 24.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29453 - Fix Set Variable If syntax
    ...  - 19.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30356 - Add faults for watchdog
    ...  - 13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30519 - Get SCF file with auto configured parameters
    ...  ******************

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-iuliia.taupeka@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_vrf  PHASE-CRT

    Step1: Test Preconditions
    Step2: Get Last Available PM File Name And Save The File
    Step3: Recommissioning - Change Reporting Interval
    Step4: Verify That Reporting Interval Changed Correctly
    IF  ${CHANGE_BACK_REPORTING_INTERVAL}==True  Step5: Recommissioning To Previous Reporting Interval


Step1: Test Preconditions
    Log  \n----- Step1: Test Preconditions Check ----- \n  console=true
    Set Test Variable  ${NEW_REPORTING_INTERVAL}  30min
    Change ReportingIntervalPm To 15 Min If Needed
    coam.Get Current Scf File  ${BTS_FILES}  SCF.xml  with_auto_configured_parameters=${TRUE}
    Setup Pm  scf_path=${BTS_FILES}/SCF.xml
    ${current_reporting_interval_in_seconds}  Get Reporting Interval  # Value is in seconds
    ${current_reporting_interval_in_minutes}  Evaluate  int(${current_reporting_interval_in_seconds}/60)
    Log  Current reporting interval is ${current_reporting_interval_in_minutes} min.  console=true
    ${current_reporting_interval_string}  Catenate  SEPARATOR=  ${current_reporting_interval_in_minutes}  min
    Should Not Be Equal  ${current_reporting_interval_string}  ${NEW_REPORTING_INTERVAL}
    Set Test Variable  ${OLD_REPORTING_INTERVAL}  ${current_reporting_interval_in_minutes}


Step2: Get Last Available PM File Name And Save The File
    Log  \n----- Step2: Get Last Available PM File Name And Save The File ----- \n  console=true
    ${last_pm_result_filename}  Wait Until Keyword Succeeds  ${OLD_REPORTING_INTERVAL}m  2m  Get Newest PM File Name
    ${last_unzipped_pm_file_name_before_reconfiguration}  Fetch From Left  ${last_pm_result_filename}  .gz
    Set Test Variable  ${PM_FILENAME_BEFORE_RECONFIGURATION}  ${last_unzipped_pm_file_name_before_reconfiguration}
    Log  Last PM result file available on flash before reconfiguration: ${last_pm_result_filename}.  console=true
    Read PM File
    Dump Pm Report  ${BTS_FILES}/PM_REPORT_${last_unzipped_pm_file_name_before_reconfiguration}


Step3: Recommissioning - Change Reporting Interval
    Log  \n----- Step3: Perform parameter reconfiguration: change reporting interval ----- \n  console=true
    ${bts_id}  Admin Get BTS ID
    ${distname}  Set Variable  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMCADM-1
    coam.Perform Parameter Recommissioning  ${distname}  reportingIntervalPm  update  ${NEW_REPORTING_INTERVAL}  skip_parameter_relation_errors=True
    Log  Reporting interval successfully changed from ${OLD_REPORTING_INTERVAL}min to ${NEW_REPORTING_INTERVAL}.  console=true


Step4: Verify That Reporting Interval Changed Correctly
    Log  \n----- Step4: Verify That Reporting Interval Changed Correctly ----- \n  console=true
    ${minutes_after_reconfiguration}  Get Minutes From Time Now
    ${quarter_now}  Get Current Quarter  ${minutes_after_reconfiguration}
    IF  ${quarter_now} == 1 or ${quarter_now} == 3
      Verify If Reporting Interval Changed Correctly For Odd Quarter  ${minutes_after_reconfiguration}  ${quarter_now}
    ELSE IF  ${quarter_now} == 2 or ${quarter_now} == 4
      Verify If Reporting Interval Changed Correctly For Even Quarter  ${minutes_after_reconfiguration}  ${quarter_now}
    ELSE
      Log  Wrong Evaluation.  console=true
    END

    [Teardown]  Teardown Pm


Step5: Recommissioning To Previous Reporting Interval
    Log  \n----- Step5: Recommissioning To Previous Reporting Interval ----- \n  console=true
    ${bts_id}  Admin Get BTS ID
    ${distname}  Set Variable  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMCADM-1
    coam.Perform Parameter Recommissioning  ${distname}  reportingIntervalPm  update  ${OLD_REPORTING_INTERVAL}min
    ...  skip_parameter_relation_errors=True
    Log  Reporting interval successfully changed back from ${NEW_REPORTING_INTERVAL} to ${OLD_REPORTING_INTERVAL}min.  console=true


Verify If Reporting Interval Changed Correctly For Even Quarter
    [Documentation]
    ...  This keyword verifies that reporting interval is checked correctly if reconfiguration appeared in odd quarter.
    ...  1) Waits till end of current(old) reporting interval
    ...  2) Checks if file with current reporting interval created at its end.
    ...  3) Waits timer till end of new reporting interval
    ...  4) Checks if first PM File with new reporting interval created
    ...  5) Waits old reporting interval
    ...  6) Checks that there is no new PM file created after reconfiguration
    [Arguments]  ${minutes_after_reconfiguration}  ${quarter_now}

    Log  \n* Verification if reporting interval changed correctly for even quarter* \n  console=true
    Calculate And Wait Timer For Next Expected PM Result File With Old Interval  ${minutes_after_reconfiguration}  ${quarter_now}
    Log  Checking if file with current reporting interval created at its end.  console=true
    ${pm_filename_with_current_rep_int}  Get Newest PM File Name
    Log  Name of next PM file at the end of current reporting period: ${pm_filename_with_current_rep_int}  console=true
    Log  Waiting old reporting interval (${OLD_REPORTING_INTERVAL} minutes) to ensure that new PM file is not created.  console=true
    Sleep  ${OLD_REPORTING_INTERVAL}m
    Log  Checking that there is no new PM file created after reconfiguration. [OK]  console=true
    ${pm_filename_after_changed_rep_int}  Get Newest PM File Name
    Should Be Equal  ${pm_filename_after_changed_rep_int}  ${pm_filename_with_current_rep_int}  Seems that interval changed not properly (wrong time).
    Calculate And Wait Timer For First PM File With New Interval For Even Quarter
    Log  Checking if new PM file is created.
    ${pm_filename_with_new_rep_int}  Get Newest PM File Name
    ssh.Connect To  hostname=${OAM_BTS_IP}  username=toor4nsn  password=oZPS0POrRieRtu
    ${pm_files_list3}  ssh.Execute  ls /ffs/run/uri/PERFMON_FILES
    ssh.Disconnect
    Should Not Be Equal  ${pm_filename_with_new_rep_int}  ${pm_filename_after_changed_rep_int}
    ...  msg=Name of PM file after reconfiguration is incorrect.${pm_files_list3}
    Log  Name of next PM file at the end of current reporting period: ${pm_filename_with_new_rep_int}.  console=true


Calculate And Wait Timer For First PM File With New Interval For Even Quarter
    [Documentation]
    ...  This keyword calculates and waits timer for first PM File with new interval
    ...  if reconfiguration appeared in even quarter

    ${new_rep_int_in_minutes}  Get Minutes From String  ${NEW_REPORTING_INTERVAL}
    ${timer_for_pm_file_with_new_int}  Evaluate  (${new_rep_int_in_minutes} - ${OLD_REPORTING_INTERVAL})
    Log  Waiting till end of new reporting interval (${timer_for_pm_file_with_new_int} minutes left).  console=true
    Sleep  ${timer_for_pm_file_with_new_int}m


Verify If Reporting Interval Changed Correctly For Odd Quarter
    [Documentation]
    ...  This keyword verifies that reporting interval is checked correctly if reconfiguration appeared in odd quarter.
    ...  1) Waits till end of current (old) reporting interval.
    ...  2) Checks if file with current reporting interval created at its end.
    ...  3) Waits old reporting interval
    ...  4) Checks that there is no new PM file created after reconfiguration
    ...  5) Waits till end of new reporting interval
    ...  6) Checks if new PM file is created
    [Arguments]  ${minutes_after_reconfiguration}  ${quarter_now}

    Calculate And Wait Timer For Next Expected PM Result File With Old Interval  ${minutes_after_reconfiguration}  ${quarter_now}
    ${pm_filename_with_current_rep_int}  Get Newest PM File Name
    Log  Name of next PM file at the end of current reporting period: ${pm_filename_with_current_rep_int}  console=true
    Should Not Be Equal  ${pm_filename_with_current_rep_int}  ${PM_FILENAME_BEFORE_RECONFIGURATION}
    ...  msg=PM file with current (old) interval not created.
    Calculate And Wait Timer For First PM File With New Interval For Odd Quarter
    ssh.Connect To  hostname=${OAM_BTS_IP}  username=toor4nsn  password=oZPS0POrRieRtu
    ${pm_files_list}  ssh.Execute  ls /ffs/run/uri/PERFMON_FILES
    ssh.Disconnect
    ${pm_filename_with_new_rep_int}  Get Newest PM File Name
    Log  Lista plikow ${pm_files_list}  console=true
    Should Not Be Equal  ${pm_filename_with_new_rep_int}  ${pm_filename_with_current_rep_int}  Name of PM file after reconfiguration is incorrect.
    Log  Name of next PM file at the end of current reporting period: ${pm_filename_with_new_rep_int}.  console=true
    Log  Sleeping old reporting interval (${OLD_REPORTING_INTERVAL} minutes).  console=true
    Sleep  ${OLD_REPORTING_INTERVAL}m
    ${pm_filename_after_changed_rep_int}  Get Newest PM File Name
    Should Be Equal  ${pm_filename_after_changed_rep_int}  ${pm_filename_with_new_rep_int}


Calculate And Wait Timer For First PM File With New Interval For Odd Quarter
    [Documentation]
    ...  This keyword calculates and waits timer for first PM File with new interval
    ...  if reconfiguration appeared in odd quarter

    ${new_rep_int_in_minutes}  Get Minutes From String  ${NEW_REPORTING_INTERVAL}
    ${timer_for_pm_file_with_new_int}  Evaluate  (${new_rep_int_in_minutes} - ${OLD_REPORTING_INTERVAL})
    Log  Waiting for first PM file with new reporting interval ${timer_for_pm_file_with_new_int} minutes.  console=true
    Sleep  ${timer_for_pm_file_with_new_int}m


Get Minutes From String
    [Arguments]  ${interval_value}

    ${int_of_interval_value}  Remove String Using Regexp  ${interval_value}  \\D+
    ${int_of_interval_value}  Convert To Integer  ${int_of_interval_value}

    [Return]  ${int_of_interval_value}


Get Minutes From Time Now
    ${time_now}  Get Time
    Log  Current time after reconfiguration ${time_now}.
    ${minutes_now}  Get Time  minutes
    ${minutes_now}  Convert To Integer  ${minutes_now}
    Log  Timestamp (minutes) of reconfiguration ${minutes_now}.  console=true

    [Return]  ${minutes_now}


Get Current Quarter
    [Documentation]
    ...  This keyword calculates and returns number of current quarter of an hour
    ...  Eg. if time now is 15:03 -> quarter=1; 15:47 -> quarter=4.
    [Arguments]  ${minutes}

    ${current_quarter}  Set Variable If  ${minutes} < 15  1
    ...  15 <= ${minutes} < 30  2
    ...  30 <= ${minutes} < 45  3
    ...  4
    Log  Current quarter is: ${current_quarter}.
    ${current_quarter}  Convert To Integer  ${current_quarter}

    [Return]  ${current_quarter}


Calculate And Wait Timer For Next Expected PM Result File With Old Interval
    [Documentation]
    ...  This KW calculates and waits timer till end of current(old) reporting interval.
    [Arguments]  ${minutes}  ${current_quarter}

    ${timer_till_end_of_current_interval}  Evaluate  int(${OLD_REPORTING_INTERVAL} * ${current_quarter} - ${minutes} + 1)
    ${timer_till_end_of_current_interval}  Convert To String  ${timer_till_end_of_current_interval}
    ${timer_till_end_of_current_interval}  Remove String  ${timer_till_end_of_current_interval}  -
    Log  Waiting timer till end of current(old) reporting interval = ${timer_till_end_of_current_interval}  console=true
    Sleep  ${timer_till_end_of_current_interval}m


TC Setup
    Common Test Setup  tc_name=PM__Reporting_interval_reconfiguration_30_min


TC Teardown
    Common Test Teardown