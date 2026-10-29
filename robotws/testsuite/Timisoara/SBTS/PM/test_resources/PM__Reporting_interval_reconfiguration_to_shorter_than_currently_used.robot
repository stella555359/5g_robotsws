*** Settings ***
Documentation
    ...  Purpose of this test case is to verify that PM reporting period change works properly on BTS.
    ...  In this case Reporting period change from longer to shorter should be verified.
    ...  Step1: Preconditions check.
    ...   - Time should be synced
    ...   - SBTS should be OnAir
    ...   - At least one PM result file(.xml) should exist on ram disk of BTS
    ...  Step2: Download Latest PM Result File From BTS
    ...   - PM result file should already exist on BTS. If not, timeout is set for waiting.
    ...   - New reporting interval should be shorted than currently used
    ...  Step3: Change Reporting Interval
    ...   - Recommissioning via ADMIN is performed
    ...  Step4: Download First Next PM Result File
    ...   - Wait for next PM result file with new reporting interval
    ...  Step5: Validate PM Result File Content
    ...   - For each of raw files create list of timestamps.
    ...   - Check if each timestamp is peresnt in PM result file.
    ...  Step6: Change Back Reporting Interval
    ...   - Perform recommissioning to reporting interval value as before test.

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${NEW_REPORTING_INTERVAL}  ${EMPTY}
# New value of Reporting Interval (reportingIntervalPm NIDD Value) (should be less than currently used).
# For example '15min'
${CHANGE_BACK_REPORTING_INTERVAL}  True


*** Keywords ***
TC__PM__Reporting_interval_reconfiguration_to_shorter_than_currently_used
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroslaw
    ...  - 19.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29733 - Fix wrong evaluation
    ...  - 19.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30356 - Add faults for watchdog
    ...  - 13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30519 - Get SCF file with auto configured parameters

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-iuliia.taupeka@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_vrf  PHASE-CRT

    Step1: Preconditions Check
    Step2: Download Latest PM Result File From BTS
    Step3: Change Reporting Interval
    Step4: Download First Next PM Result File
    Step5: Validate PM Result File Content
    IF  ${CHANGE_BACK_REPORTING_INTERVAL}==True  Step6: Change Back Reporting Interval


Step1: Preconditions Check
    Log  \n----- Step1: Preconditions Check ----- \n  console=true
    Should Not Be Empty  ${NEW_REPORTING_INTERVAL}  msg=New value of reporting interval is not provided.

    IF  '${NEW_REPORTING_INTERVAL}'=='15min'
        Change ReportingIntervalPm Initial Value If Needed  15min  30min
    ELSE
        Change ReportingIntervalPm Initial Value If Needed  30min  60min
    END

    coam.Get Current Scf File  ${BTS_FILES}  scf.xml  with_auto_configured_parameters=${TRUE}
    Setup Pm  scf_path=${BTS_FILES}/scf.xml
    ${new_rep_int_check_status}  New Reporting Interval Value Is Correct NIDD Value  ${NEW_REPORTING_INTERVAL}
    ${new_reporting_interval_in_minutes}  Get Minutes From String  ${NEW_REPORTING_INTERVAL}
    ${current_reporting_interval_in_seconds}  Get Reporting Interval  # Value is in seconds
    ${current_reporting_interval_in_minutes}  Evaluate  int(${current_reporting_interval_in_seconds}/60)  # Convert value to minutes
    Set Test Variable  ${OLD_REP_INT_IN_MINUTES}  ${current_reporting_interval_in_minutes}
    ${old_reporting_interval_value}  Catenate  SEPARATOR=  ${current_reporting_interval_in_minutes}  min
    Log  Current reporting interval = ${current_reporting_interval_in_minutes} min  console=true
    Set Test Variable  ${OLD_REPORTING_INTERVAL_VALUE}
    Should Not Be Equal  ${new_reporting_interval_in_minutes}  ${current_reporting_interval_in_minutes}
    ...  msg=New value is the same as current value on BTS.
    # Check if there is PM.BTS.....xml file already created on ram disk
    Should Be True  '${new_reporting_interval_in_minutes}'<'${current_reporting_interval_in_minutes}'
    ...  msg=Entry conditions not met. New value is not shorter.
    Set Test Variable  ${NEW_REPORTING_INTERVAL_IN_MINUTES}
    Log  New reporting interval will be set to ${NEW_REPORTING_INTERVAL_IN_MINUTES} minutes in Step 3  console=true


Step2: Download Latest PM Result File From BTS
    Log  \n----- Step2: Download Latest PM Result File From BTS ----- \n  console=true
    ${status}  Run Keyword And Return Status
    ...  Read PM File
    IF  ${status}==${FALSE}
        Log  PM file not yet created, wait for complete report  console=true
        Wait For PM Result File
        Read PM File
    END
    ${last_pm_file_name_before_recon}  Get Newest PM File Name
    Log  Latest PM result file available on BTS: ${last_pm_file_name_before_recon}  console=true
    Set Test Variable  ${LAST_PM_FILE_NAME_BEFORE_RECON}
    ${last_unzipped_pm_file_name_before_reconfiguration}  Fetch From Left  ${LAST_PM_FILE_NAME_BEFORE_RECON}  .gz
    Dump Pm Report  ${BTS_FILES}/PM_REPORT_${last_unzipped_pm_file_name_before_reconfiguration}
    ${last_timestamp_before_reconfiguration}  Get Timestamp From Filename  ${last_unzipped_pm_file_name_before_reconfiguration}
    Set Test Variable  ${LAST_TIMESTAMP_BEFORE_RECONFIGURATION}
    Log  Last available timestamp before reconfiguration is ${LAST_TIMESTAMP_BEFORE_RECONFIGURATION}  console=true
    Log  Unzipped PM file ${last_unzipped_pm_file_name_before_reconfiguration} saved in BTS Files folder.  console=true


Step3: Change Reporting Interval
    Log  \n----- Step3: Change Reporting Interval ----- \n  console=true
    ${bts_id}  Admin Get BTS ID
    ${dist_name}  Set Variable  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMCADM-1
    ${parameter}  Set Variable  reportingIntervalPm
    ${operation}  Set Variable  update
    coam.Perform Parameter Recommissioning  ${dist_name}  ${parameter}  ${operation}  ${NEW_REPORTING_INTERVAL}  skip_parameter_relation_errors=True
    Log  Delta recommissioning done. Reporting interval changed to ${NEW_REPORTING_INTERVAL}. \nReset occurence will be checked.  console=true


Step4: Download First Next PM Result File
    Log  \n----- Step4: Download First Next PM Result File ----- \n  console=true
    ${time_now}  Get Current Date  UTC  result_format=%Y%m%d.%H%M%S
    Log  Date and time now: ${time_now}  console=true
    ${add_minutes}  How Long Wait For Next Report  ${time_now}
    ${wait_minutes}  Set Variable  ${add_minutes}
    ${add_minutes}  Set Variable  ${add_minutes} minutes
    ${new_timestamp}  Add Reporting Interval Minutes To Timestamp  ${time_now}  ${add_minutes}
    ${expected_new_filename}  Get Expected File Name  ${LAST_PM_FILE_NAME_BEFORE_RECON}  ${LAST_TIMESTAMP_BEFORE_RECONFIGURATION}  ${new_timestamp}
    Log  New filename should be ${expected_new_filename}  console=true
    ${list_of_raw_files}  Get All Pm Raw Files List From Bts
    Log  List of raw files on BTS ${list_of_raw_files}  console=true
    ${list_of_timestamps}  Get Raw Files Timestamps List  ${list_of_raw_files}
    ${wait_minutes}  Evaluate  ${wait_minutes} - 1
    Log  Waiting ${add_minutes} minutes for next PM result file.  console=true
    Sleep  ${wait_minutes}m
    Sleep  2min  TC will wait until PM report is loaded.
    Get Pm Raw Files From BTS  ${BTS_FILES}/PM_Raw_files/
    ${first_pm_file_nameafter_change}  Get Newest PM File Name
    Should Be Equal  ${expected_new_filename}  ${first_pm_file_name_after_change}  msg=Expected PM result file not found
    Log  PM result filename after reconfiguration ${first_pm_file_name_after_change}  console=true
    ${unzipped_xml_filename}  Fetch From Left  ${first_pm_file_nameafter_change}  .gz
    Read PM File
    Dump Pm Report  ${BTS_FILES}/PM_REPORT_${unzipped_xml_filename}
    Get Pm Raw Files From BTS  ${BTS_FILES}/PM_Raw_files/
    Set Test Variable  ${UNZIPPED_XML_FILENAME}


Step5: Validate PM Result File Content
    Log  \n----- Step5: Validate PM Result File Content ----- \n  console=true
    ${list_of_gz_raw_files}  OperatingSystem.List Directory  ${BTS_FILES}/PM_Raw_files/
    Remove Last Raw File From List  ${list_of_gz_raw_files}
    Unzip Raw Files
    ${unzipped_raw_files_list}  OperatingSystem.List Directory  ${BTS_FILES}/Unzipped_raw_files/  pattern=*.raw
    Log  List of files available on BTS after PM result file without timestamp ${LAST_TIMESTAMP_BEFORE_RECONFIGURATION}  console=true
    Log  below: ${unzipped_raw_files_list}  console=true
    Log  \n Validation of raw files content presense in final PM result file \n  console=true
    FOR  ${item}  IN  @{unzipped_raw_files_list}
        Log  Raw file under check ${item}. Checking presence of its timestamps in PM result file.  console=true
        ${timestamps_list}  List Timestamps Of All PMSetup Elements From Raw File  ${BTS_FILES}/Unzipped_raw_files/${item}
        Check Presense Of All Raw File Timestamps  ${timestamps_list}  ${BTS_FILES}/PM_REPORT_${UNZIPPED_XML_FILENAME}
    END


Step6: Change Back Reporting Interval
    Log  \n----- Step6: Change Back Reporting Interval ----- \n  console=true
    ${bts_id}  Admin Get BTS ID
    ${dist_name}  Set Variable  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMCADM-1
    ${parameter}  Set Variable  reportingIntervalPm
    ${operation}  Set Variable  update
    coam.Perform Parameter Recommissioning  ${dist_name}  ${parameter}  ${operation}  ${OLD_REPORTING_INTERVAL_VALUE}
    ...  skip_parameter_relation_errors=True
    Log  Delta recommissioning done. Reporting interval changed to old ${OLD_REPORTING_INTERVAL_VALUE} value. \n  console=true


Change ReportingIntervalPm Initial Value If Needed
    [Arguments]  ${ref_value}  ${new_initial_value}

    coam.Get Current Scf File  ${BTS_FILES}  SCF.xml  with_auto_configured_parameters=${TRUE}
    Setup Pm  scf_path=${BTS_FILES}/SCF.xml
    ${current_reporting_interval_in_seconds}  Get Reporting Interval  # Value is in seconds
    ${current_reporting_interval_in_minutes}  Evaluate  int(${current_reporting_interval_in_seconds}/60)
    ${bts_id}  Admin Get BTS ID
    ${ref_value}  Remove String  ${ref_value}  min
    ${ref_value}  Convert To Integer  ${ref_value}
    IF  ${current_reporting_interval_in_minutes}<=${ref_value}
        coam.Perform Parameter Recommissioning  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMCADM-1  reportingIntervalPm  update  ${new_initial_value}
        ...  skip_parameter_relation_errors=True
        Sleep Until New Cycle  ${new_initial_value}
        Sleep  1min  TC will wait until PM report is loaded.
    END

    [Teardown]  Teardown Pm


Wait For PM Result File
    ${minutes_now}  Get Time  minutes
    ${minutes_now}  Convert Time  ${minutes_now}
    ${time}  Evaluate  int(${OLD_REP_INT_IN_MINUTES}-${minutes_now}%${OLD_REP_INT_IN_MINUTES})
    Log  Now sleeping ${time} minutes to wait for available PM report.  console=true
    Sleep  ${time}m


New Reporting Interval Value Is Correct NIDD Value
    [Documentation]
    ...  This keyword validates correctness of provided new parameter value (if it is correct NIDD value).
    [Arguments]  ${parameter_to_be_checked}

    ${check_status}  Set Variable If
    ...  '${parameter_to_be_checked}'=='15min' or '${parameter_to_be_checked}'=='30min' or '${parameter_to_be_checked}'=='60min'  TRUE  FALSE
    IF  '${check_status}'=='TRUE'
        Log  New Value (${NEW_REPORTING_INTERVAL}) is correct NIDD Value.  console=true
    ELSE
        Fail  Value is not allowed. Please check in NIDD correct possible values.
    END

    RETURN  ${check_status}


Get Minutes From String
    [Arguments]  ${interval_value}

    ${int_of_interval_value}  Remove String Using Regexp  ${interval_value}  \\D+
    ${int_of_interval_value}  Convert To Integer  ${int_of_interval_value}

    RETURN  ${int_of_interval_value}


How Long Wait For Next Report
    [Arguments]  ${current_date}
    [Documentation]
    ...  This keyword calculates and returns time to wait for next expected PM result file.

    ${reporting_interval}  Set Variable  ${NEW_REPORTING_INTERVAL_IN_MINUTES}
    ${minutes_now}  Get Substring  ${current_date}  -4  -2
    ${minutes_now}  Convert Time  ${minutes_now}
    ${time}  Evaluate  int(${reporting_interval}-${minutes_now}%${reporting_interval})
    Log  Time left to creating next PM result file: ${time} minutes.  console=true

    RETURN  ${time}


Get Timestamp From Filename
    [Documentation]
    ...  This keyword extracts timestamp from PM filename.
    [Arguments]  ${filename}

    ${date_and_time_stamp}  Get Regexp Matches  ${filename}  \\d{8}\\.\\d{6}
    ${date_and_time_stamp}  Set Variable  ${date_and_time_stamp[0]}

    RETURN  ${date_and_time_stamp}


Add Reporting Interval Minutes To Timestamp
    [Documentation]
    ...  This keyword calculates expected timestamp for next PM result file.
    [Arguments]  ${timestamp_from_last_file}  ${reporting_interval}

    ${expected_pm_file_timestamp}  Add Time To Date  ${timestamp_from_last_file}  ${reporting_interval}  result_format=%Y%m%d.%H%M00

    RETURN  ${expected_pm_file_timestamp}


Get Expected File Name
    [Documentation]
    ...  This keyword calculates expected next PM result filename.
    [Arguments]  ${last_pm_filename}  ${old_timestamp}  ${new_timestamp}

    ${expected_filename}  Replace String  ${last_pm_filename}  ${old_timestamp}  ${new_timestamp}

    RETURN  ${expected_filename}


Get All Pm Raw Files List From Bts
    [Documentation]
    ...  This keyword lists PM raw files available on BTS and returns the list.

    SSHLibrary.Open Connection  ${SMOD1['IP']}  encoding=unicode_escape
    SSHLibrary.Login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    ${raw_file_pattern}  Set Variable  *.raw.gz
    ${path}  Set Variable  /rom/uri/PERFMON_FILES
    ${raw_files_list}  SSHLibrary.List Directory  ${path}  ${raw_file_pattern}
    SSHLibrary.Close Connection

    RETURN  ${raw_files_list}


Get Raw Files Timestamps List
    [Documentation]
    ...  This keyword returns list of timestamps of PM raw file.
    [Arguments]  ${raw_files_on_bts}

    ${timestamps}  Create List
    FOR  ${item}  IN  @{raw_files_on_bts}
        ${timestamp}  Get Timestamp From Filename  ${item}
        Append To List  ${timestamps}  ${timestamp}
    END

    RETURN  ${timestamps}


Unzip Raw Files
    [Documentation]
    ...  In this keyword raw.gz files are unzipped to 'Unzipped raw files' folder

    ${raw_files_expected_in_xml}  OperatingSystem.List Directory  ${BTS_FILES}/PM_Raw_files/  pattern=*.raw.gz
    FOR  ${item}  IN  @{raw_files_expected_in_xml}
        Log  Unzipping file ${item}  console=true
        ${path_to_unzip_file}  Unpack Archive Content To Directory  ${BTS_FILES}/PM_Raw_files/${item}  ${BTS_FILES}/Unzipped_raw_files/
    END


Remove Last Raw File From List
    [Arguments]  ${list_of_raw_files}

    FOR  ${item}  IN  @{list_of_raw_files}
        ${output}  Run Keyword And Return Status
        ...  Should Contain  ${item}  ${LAST_TIMESTAMP_BEFORE_RECONFIGURATION}
        IF  ${output}
            Remove Values From List  ${list_of_raw_files}  ${item}
            Remove File  ${BTS_FILES}/PM_Raw_files/${item}
        END
    END
    Log  List of raw files created on BTS after reconfiguration ${list_of_raw_files}  console=true

    RETURN  ${list_of_raw_files}


List Timestamps Of All PMSetup Elements From Raw File
    [Documentation]
    ...  In this keyword is being created the list of timestamp of all PMSetup Elements for current raw file.
    [Arguments]  ${pm_raw_file}

    ${pm_file}  Parse XML  ${pm_raw_file}
    ${pm_setup_elements}  Get Elements  ${pm_file}  PMSetup
    ${list_of_timestamps_from_raw_file}  Create List
    FOR  ${item}  IN  @{pm_setup_elements}
        ${timestamp_of_current_element}  Get Element Attributes  ${item}
        Append To List  ${list_of_timestamps_from_raw_file}  ${timestamp_of_current_element}
    END
    Log  ==Final list of timestamps from current ${pm_raw_file} raw file ${list_of_timestamps_from_raw_file}==  console=true

    RETURN  ${list_of_timestamps_from_raw_file}


Check Single Timestamps Present In PM Result File
    [Documentation]
    ...  This keyword checks if single timestamp is present in PM result file.
    [Arguments]  ${final_xml_file}  ${interval_value}  ${start_time_value}

    ${xpath_result}  Evaluate Xpath  ${final_xml_file}
    ...  //PMSetup[contains(@interval,"${interval_value}") and contains(@startTime,"${start_time_value}")]
    ${pm_setup_attributes}  Get Element Attributes  ${xpath_result[0]}
    IF  '${xpath_result}'=='[]'
        Set Test Failed  Element with startTime ${start_time_value} and interval ${interval_value} not found in PM result file.
    ELSE
        Log  Element with startTime ${start_time_value} and interval ${interval_value} is present in PM result file  console=true
    END


Check Presense Of All Raw File Timestamps
    [Documentation]
    ...  This keyword checks in a loop presense of timestamps from the list in PM result file.
    [Arguments]  ${list_of_raw_file_pm_setup_entries}  ${final_xml_file}

    FOR  ${item}  IN  @{list_of_raw_file_pm_setup_entries}
        Check Single Timestamps Present In PM Result File  ${final_xml_file}  ${item['interval']}  ${item['startTime']}
    END


Custom Test Teardown
    Common Test Teardown
    IF  ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}!='[]'  Remove All Directories After Unpack


TC Setup
    Common Test Setup  tc_name=PM__Reporting_interval_reconfiguration_shorter
    @{list_of_directory_to_del_after_unpack}  Create List
    Set Test Variable  ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}


TC Teardown
    Custom Test Teardown
