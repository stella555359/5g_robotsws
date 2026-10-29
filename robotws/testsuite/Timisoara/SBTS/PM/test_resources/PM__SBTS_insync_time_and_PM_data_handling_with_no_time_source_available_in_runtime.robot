*** Settings ***
Documentation
    ...  Test case created to check if PM files are not generated when synchronization sources are not available from startup

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  10  # Timeout value in minutes after startup for all modules to reach working state.


*** Keywords ***
TC__PM__SBTS_insync_time_and_PM_data_handling_with_no_time_source_available_in_runtime
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroslaw
    ...  - 13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30519 - Get SCF file with auto configured parameters

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-lukasz.targonski@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_vrf  PHASE-CRT

    Step 1: Check If PM File Is Available
    Step 2: Remove Time Synchronization Sources
    Step 3: Check If PM File Is Available After Time Synchronization Sources Are Removed
    Step 4: Restore Time Synchronization Sources
    Step 5: Check If PM File Is Available After Time Synchronization Sources Are Restored


Step 1: Check If PM File Is Available
    [Documentation]
    ...  In this step it is checked if Pm file is generated on ram disc before time synchronization sources are disabled.

    Log  \nStep 1: Check If PM Report Is Available  console=true
    coam.Get Current Scf File  ${BTS_FILES}  scf.xml  with_auto_configured_parameters=${TRUE}
    Setup Pm  scf_path=${BTS_FILES}/scf.xml
    Wait For PM File Collection After Startup
    ${pm_files_collected}  Run Keyword And Ignore Error
    ...  Get Pm XML Files From BTS  ${BTS_FILES}/Step_1_xml_files/
    Run Keyword If  '${pm_files_collected[0]}'=='FAIL'
    ...  Run Keywords
    ...  Log  Need to wait for the next PM file collection  console=true
    ...  AND
    ...  Wait For Next PM File Collection
    ...  AND
    ...  Get Pm XML Files From BTS  ${BTS_FILES}/Step_1_xml_files/

    ${xml_pm_file_name}  Build PM File Name  xml
    ${xml_pm_file_is_present}  Check If The Lates PM File Is Present  ${BTS_FILES}/Step_1_xml_files/  ${xml_pm_file_name}

    Run Keyword If  '${xml_pm_file_is_present}'=='PASS'
    ...  Log  PM file is present  console=true
    ...  ELSE
    ...  Set Test Failed  PM file is not present  ${TRUE}

    Teardown All Aliases


Step 2: Remove Time Synchronization Sources
    [Documentation]
    ...  In this test step all time synchronization sources are removed. This includes changing NTP and BCF IP addresses,
    ...  removing SyncInputList structure. Reportins interval value is also changed to 15min.

    Log  \nStep 2: Remove Time Synchronization Sources  console=true
    ${delta_id}  Set Variable  remove_sync
    coam.Create Delta  ${delta_id}
    ${scf}  Parse XML  ${BTS_FILES}/scf.xml

    Update All Vlans  ${delta_id}  ${scf}
    Update SyncInput Structure  ${delta_id}  ${scf}
    Update Reporting Interval  ${delta_id}  ${scf}

    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS_FILES}/Remove_Time_Synchro_Sources_Delta.json  delta_id=${delta_id}
    ${recommissioning_status}  ${_}  Run Keyword And Ignore Error
    ...  coam.Perform Delta Recommissioning  ${BTS_FILES}/Remove_Time_Synchro_Sources_Delta.json  skip_parameter_relation_errors=True
    coam.Remove Delta  ${delta_id}
    Run Keyword If  '${recommissioning_status}'=='FAIL'
    ...  Run Keywords
    ...  Set Test Variable  ${TIME_SYNCHRONIZED}  ${True}
    ...  AND
    ...  Set Test Failed  Recommissioning failed
    ...  ELSE
    ...  Set Test Variable  ${TIME_SYNCHRONIZED}  ${False}


Step ${n}: Check If PM File Is Available After Time Synchronization Sources Are ${removed_restored}
    Log  \nStep${n}: Check if PM file is available after time synchronization sources are ${removed_restored}  console=true

    coam.Get Current Scf File  ${BTS_FILES}  scf_sync_${removed_restored}.xml  with_auto_configured_parameters=${TRUE}
    Setup Pm  scf_path=${BTS_FILES}/scf_sync_${removed_restored}.xml
    Wait For Next PM File Collection

    ${path_to_xml_files}  Get Pm XML Files From BTS  ${BTS_FILES}/Step_${n}_xml_files/
    ${xml_pm_file_name}  Build PM File Name  xml
    ${xml_pm_file_is_present}  Check If The Lates PM File Is Present  ${path_to_xml_files}  ${xml_pm_file_name}

    ${path_to_raw_files}  Get Pm Raw Files From BTS  ${BTS_FILES}/Step_${n}_raw_files/
    ${raw_pm_file_name}  Build PM File Name  raw
    ${raw_file_is_present}  Check If The Lates PM File Is Present  ${path_to_raw_files}  ${raw_pm_file_name}

    Run Keyword If  '${xml_pm_file_is_present}'=='PASS'
    ...  Log  PM file is present  console=true
    ...  ELSE
    ...  Set Test Failed  PM file is not present

    Run Keyword If  '${raw_file_is_present}'=='PASS'
    ...  Log  Raw file is present  console=true
    ...  ELSE
    ...  Set Test Failed  Raw file is not present.

    Check If Xml Pm File Contains Previously Collected Raw Files  ${xml_pm_file_name}  ${raw_pm_file_name}  ${n}

    Teardown All Aliases


Step 4: Restore Time Synchronization Sources
    [Documentation]
    ...  In this step time synchronization sources are changed back to the previous values

    Log  \nStep 4: Restore Time Synchronization Sources  console=true
    ${delta_id}  Set Variable  restore_sync
    coam.Create Delta  ${delta_id}

    FOR  ${vlan_id_dist_name}  IN  @{VLAN_ID_DICT}
        ${vlan_id}  Get From Dictionary  ${VLAN_ID_DICT}  ${vlan_id_dist_name}
        coam.Append Parameter Update To Delta  ${vlan_id_dist_name}  vlanId  ${vlan_id}  delta_id=${delta_id}
        Log  Changing vlanId in distName ${vlan_id_dist_name} back to ${vlan_id}  console=true
    END

    FOR  ${clock}  IN  @{CLOCK_ELEM}
        Add Clock Sync List To Delta  ${clock}  ${delta_id}
    END

    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS_FILES}/Restore_Time_Synchro_Sources_Delta.json  delta_id=${delta_id}
    ${recommissioning_status}  ${_}  Run Keyword And Ignore Error
    ...  coam.Perform Delta Recommissioning  ${BTS_FILES}/Restore_Time_Synchro_Sources_Delta.json  skip_parameter_relation_errors=True
    coam.Remove Delta  ${delta_id}
    Run Keyword If  '${recommissioning_status}'=='FAIL'
    ...  Set Test Failed  Recommissioning failed
    ...  ELSE
    ...  Set Test Variable  ${TIME_SYNCHRONIZED}  ${True}


Wait For PM File Collection After Startup
    [Documentation]
    ...  *AUTHOR* lukasz.targonski@nokia.com
    ...  This keyword calculates PM file availability time based on the BTS startup time and sleeps
    ...  if calculated time is after the curent time.

    ${reporting_interval}  Get Reporting Interval
    ${uptime}  Check BTS Uptime
    ${seconds_to_report_after_startup}  Evaluate  int(${reporting_interval}-60*${uptime.minute}%${reporting_interval})
    ${report_time_after_startup}  Add Time To Date  ${uptime}  ${seconds_to_report_after_startup}  exclude_millis=True  result_format=datetime
    ${report_time_after_startup}  Subtract Time From Date  ${report_time_after_startup}  ${report_time_after_startup.second}  exclude_millis=True
    ...  result_format=datetime

    ${current_time}  Get Current Date  exclude_millis=True  result_format=datetime
    ${seconds_to_report}  Evaluate  int(${reporting_interval}-60*${current_time.minute}%${reporting_interval}+60)
    ${report_time}  Add Time To Date  ${current_time}  ${seconds_to_report}  exclude_millis=True  result_format=datetime
    ${report_time}  Subtract Time From Date  ${report_time}  ${report_time.second}  exclude_millis=True  result_format=datetime

    ${time_diff}  Subtract Date From Date  ${current_time}  ${report_time_after_startup}

    Run Keyword If  ${time_diff}<0
    ...  Run Keywords
    ...  Log  Need to wait untill ${report_time} for PM report  console=true
    ...  AND
    ...  Sleep  ${seconds_to_report}
    ...  ELSE
    ...  Log  No need to wait for PM report  console=true


Update All Vlans
    [Arguments]  ${delta_id}  ${scf}

    @{vlan_objects}  Evaluate Xpath  ${scf}  //managedObject[contains(@class, "VLANIF")]
    ${vlan_id_dict}  Create Dictionary
    Set Test Variable  ${VLAN_ID_DICT}
    ${fake_vlan_id}  Set Variable  999

    FOR  ${vlan_object}  IN  @{vlan_objects}
        ${vlan_dist_name}  XML.Get Element Attribute  ${vlan_object}  distName
        ${vlan_elements}  XML.Get Child Elements  ${vlan_object}
        ${object_content}  XML.Get Element Text  ${vlan_object}
        ${lines}  Get Line Count  ${object_content}
        ${last_line}  Evaluate  ${lines}-2
        ${vlan_id}  Get Line  ${object_content}  ${last_line}
        Set To Dictionary  ${VLAN_ID_DICT}  ${vlan_dist_name}  ${vlan_id}
        coam.Append Parameter Update To Delta  ${vlan_dist_name}  vlanId  ${fake_vlan_id}  delta_id=${delta_id}
        Log  Changing vlanId in distName:${vlan_dist_name} to ${fake_vlan_id}  console=true
        ${fake_vlan_id}  Evaluate  ${fake_vlan_id}-1
    END


Update SyncInput Structure
    [Arguments]  ${delta_id}  ${scf}

    @{clock_elem}  Evaluate Xpath  ${scf}  //managedObject[@class="com.nokia.srbts.mnl:CLOCK" and contains(@distName, "CLOCK-1")]
    Set Test Variable  @{CLOCK_ELEM}
    FOR  ${clock}  IN  @{CLOCK_ELEM}
        ${clock_dist_name}  XML.Get Element Attribute  ${clock}  distName
        coam.Append Parameter Delete To Delta  ${clock_dist_name}  syncInputList  delta_id=${delta_id}
        Log  Deleting syncInputList structure from ${clock_dist_name}  console=true
    END


Update Reporting Interval
    [Arguments]  ${delta_id}  ${scf}

    ${reporting_interval}  Get Element Text  ${scf}  //managedObject[contains(@class,"PMCADM")]/p[@name="reportingIntervalPm"]
    ${pmcadm_distname}  XML.Get Element Attribute  ${scf}  distName  //managedObject[contains(@class,"PMCADM")]
    Set Test Variable  ${REPORTING_INTERVAL}
    Set Test Variable  ${PMCADM_DISTNAME}
    Run Keyword If  '${REPORTING_INTERVAL}'!='15min'
    ...  Run Keywords
    ...  coam.Append Parameter Update To Delta  ${PMCADM_DISTNAME}  reportingIntervalPm  15min  delta_id=${delta_id}
    ...  AND
    ...  Log  Changing reportingIntervalPm value to 15min  console=true


Add Clock Sync List To Delta
    [Arguments]  ${clock}  ${delta_id}

    ${clock_dist_name}  XML.Get Element Attribute  ${clock}  distName
    @{sync_input_list}  Evaluate Xpath  ${clock}  ./list[@name="syncInputList"]/item
    FOR  ${item}  IN  @{sync_input_list}
        ${sync_input_dict}  Create Dictionary  list_name=syncInputList
        @{name_list}  Evaluate Xpath  ${item}  ./p
        ${name}  XML.Get Element Attribute  ${name_list[0]}  name
        ${value}  Get Element Text  ${name_list[0]}
        Set To Dictionary  ${sync_input_dict}  ${name}  ${value}
        ${name}  XML.Get Element Attribute  ${name_list[1]}  name
        ${value}  Get Element Text  ${name_list[1]}
        Set To Dictionary  ${sync_input_dict}  ${name}  ${value}
        coam.Append Complex Item To Delta  ${clock_dist_name}  list_name=syncInputList  &{sync_input_dict}  delta_id=${delta_id}
        Log  Adding syncInputList structure in distName:${clock_dist_name} to &{sync_input_dict}  console=true
    END


Check If The Lates PM File Is Present
    [Arguments]  ${path_to_xml_files}  ${file_name}

    Log  Checking if PM file: ${file_name} is present on ram disc  console=true
    ${xml_pm_files_list}  OperatingSystem.List Directory  ${path_to_xml_files}
    ${xml_pm_file_is_present}  Run Keyword And Ignore Error
    ...  Should Contain  ${xml_pm_files_list}  ${file_name}

    RETURN  ${xml_pm_file_is_present[0]}


Build PM File Name
    [Arguments]  ${file_type}

    ${reporting_interval}  Run Keyword If  '${file_type}'=='xml'
    ...  Get Reporting Interval
    ...  ELSE
    ...  Set Variable  900

    ${current_time}  Get Current Date  exclude_millis=True  result_format=datetime  time_zone=UTC
    ${current_time}  Subtract Time From Date  ${current_time}  ${current_time.second} seconds  result_format=datetime
    ${seconds_to_full_report}  Evaluate  int(${reporting_interval}-60*${current_time.minute}%${reporting_interval})
    ${pm_file_availability_time}  Add Time To Date  ${current_time}  ${seconds_to_full_report} seconds
    ${pm_file_availability_time}  Subtract Time From Date  ${pm_file_availability_time}  ${reporting_interval} seconds  result_format=%Y%m%d.%H%M%S

    ${bts_id}  Admin Get BTS ID

    ${file_name}  Set Variable  PM.BTS-${bts_id}.${pm_file_availability_time}.ANY.${file_type}.gz

    RETURN  ${file_name}


Check If Xml Pm File Contains Previously Collected Raw Files
    [Arguments]  ${xml_pm_file_name}  ${raw_pm_file_name}  ${n}

    Unpack Archive Content To Directory  ${BTS_FILES}/Step_${n}_raw_files/${raw_pm_file_name}  ${BTS_FILES}/Step_${n}_raw_files/
    ${raw_pm_file_name}  Fetch From Left  ${raw_pm_file_name}  .gz
    ${path_to_raw}  Set Variable  ${BTS_FILES}/Step_${n}_raw_files/${raw_pm_file_name}
    Unpack Archive Content To Directory  ${BTS_FILES}/Step_${n}_xml_files/${xml_pm_file_name}  ${BTS_FILES}/Step_${n}_xml_files/
    ${xml_pm_file_name}  Fetch From Left  ${xml_pm_file_name}  .gz
    ${path_to_xml}  Set Variable  ${BTS_FILES}/Step_${n}_xml_files/${xml_pm_file_name}
    ${raw_files_list}  Create List  ${path_to_raw}

    FOR  ${raw_file}  IN  @{raw_files_list}
        ${timestamp_list}  List Timestamps Of All PMSetup Elements From Raw File  ${raw_file}
        Check Presense Of All Raw File Timestamps  ${timestamp_list}  ${path_to_xml}
    END


List Timestamps Of All PMSetup Elements From Raw File
    [Documentation]
    ...  In this keyword is being created the list of timestamp of all PMSetup Elements for current raw file.
    [Arguments]  ${pm_raw_file}

    ${pm_file}  Parse XML  ${pm_raw_file}
    ${pm_setup_elements}  Get Elements  ${pm_file}  PMSetup
    ${list_of_timestamps_from_raw_file}  Create List
    FOR  ${item}  IN  @{pm_setup_elements}
        ${timestamp_of_current_element}  XML.Get Element Attributes  ${item}
        Append To List  ${list_of_timestamps_from_raw_file}  ${timestamp_of_current_element}
    END

    RETURN  ${list_of_timestamps_from_raw_file}


Check Presense Of All Raw File Timestamps
    [Documentation]
    ...  This keyword checks in a loop presense of timestamps from the list in PM result file.
    [Arguments]  ${list_of_raw_file_pm_setup_entries}  ${final_xml_file}

    FOR  ${item}  IN  @{list_of_raw_file_pm_setup_entries}
        ${xpath_result}  Evaluate Xpath  ${final_xml_file}
        ...  //PMSetup[contains(@interval,"${item['interval']}") and contains(@startTime,"${item['startTime']}")]
        ${pm_setup_attributes}  XML.Get Element Attributes  ${xpath_result[0]}
        Run Keyword If  '${xpath_result}'=='[]'
        ...  Set Test Failed  Element with startTime ${item['startTime']} and interval ${item['interval']} not found in PM result file.
        ...  ELSE
        ...  Log  Element with startTime ${item['startTime']} and interval ${item['interval']} is present in PM result file  console=true
    END


Custom Test Teardown
    Log  \nCustom Test Teardown  console=true
    ${delta_id}  Set Variable  teardown
    coam.Create Delta  ${delta_id}

    Run Keyword If  ${TIME_SYNCHRONIZED}==${FALSE}
    ...  Run Keywords
    ...  Log  Restoring commissioning  console=true
    ...  AND
    ...  coam.Perform Commissioning  ${BTS_FILES}/scf.xml
    ...  AND
    ...  Wait For Target To Be Reachable  ${SMOD1['IP']}  120
    ...  AND
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT} min  15 sec
    ...  coam.Assert Every  BTS  proceduralState=OnAir
    ...  AND
    ...  Sleep  180
    ...  AND
    ...  Return From Keyword

    Run Keyword If  '${REPORTING_INTERVAL}'!='15min'
    ...  Run Keywords
    ...  Log  Changing reportingIntervalPm value back to ${REPORTING_INTERVAL}  console=true
    ...  AND
    ...  coam.Append Parameter Update To Delta  ${PMCADM_DISTNAME}  reportingIntervalPm  ${REPORTING_INTERVAL}  delta_id=${delta_id}
    ...  AND
    ...  coam.Get Delta  ${delta_id}
    ...  AND
    ...  coam.Save Delta  ${BTS_FILES}/Restore_Reporting_Interval_Delta.json  delta_id=${delta_id}
    ...  AND
    ...  coam.Perform Delta Recommissioning  ${BTS_FILES}/Restore_Reporting_Interval_Delta.json  skip_parameter_relation_errors=True
    ...  AND
    ...  coam.Remove Delta  ${delta_id}
    Common Test Teardown
    Run Keyword If  ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}!='[]'
    ...  Remove All Directories After Unpack


TC Setup
    Common Test Setup  tc_name=PM__SBTS_insync_no_time_source_available_in_runtime
    @{list_of_directory_to_del_after_unpack}  Create List
    Set Test Variable  ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}


TC Teardown
    Custom Test Teardown
