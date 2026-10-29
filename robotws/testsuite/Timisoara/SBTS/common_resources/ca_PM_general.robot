*** Settings ***
Documentation  This suite contains KWs used by PM TCs

Library  XML  use_lxml=${TRUE}
Library  hran_pm
Resource  ca_SBTS_general.robot


*** Keywords ***
Download PM Report
    [Documentation]  This keyword is used to download PM report.

    coam.Get Current Scf File  ${BTS_FILES}  scf.xml  with_auto_configured_parameters=${TRUE}  timeout=60
    Setup Pm  scf_path=${BTS_FILES}/scf.xml
    Load Measurements  ${MEASUREMENT_PATH}  ${ABBREVIATION_DICT_PATH}  filtrate_key=${TO_FILTRATE_KEYS}  filtrate_val=${TO_FILTRATE_VALUES}
    ${status}  Run Keyword And Return Status
    ...  Read PM File
    Run Keyword If  ${status} == ${FALSE}
    ...  Run Keywords
    ...  Log  PM file not yet created, wait for complete report  console=true
    ...  AND
    ...  Wait For Complete Report
    ...  AND
    ...  Read PM File
    Log  PM file loaded successfully  console=true


Check If Counters Are Present
    [Documentation]  This keyword is used to check if counters are present.
    [Arguments]
    ...  ${measurement}
    ...  ${counters_list}
    ...  ${check_counters_on_nr_cells}=${False}
    ...  ${check_counters_on_lte_cells}=${False}
    ...  ${check_counters_on_wcdma_cells}=${False}
    ...  ${check_trs_counters_path}=${False}

    ${enabled}  Measurement Enabled In Scf  ${measurement}
    Return From Keyword If  ${enabled}==${False}
    ${count}  Calculate Counter Occurrence  ${measurement}
    ${not_found_counters}  Check Counters  ${counters_list}  count=${count}
    ${counters_status}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${not_found_counters}
    Run Keyword If  ${counters_status}
    ...  Run Keywords
    ...  Set Test Failed  Following ${measurement} counters not found: ${not_found_counters}.
    ...  AND
    ...  Return From Keyword

    Run Keyword If  ${check_counters_on_nr_cells}
    ...  Check If Counters Are Present On NR  ${measurement}  ${counters_list}
    Run Keyword If  ${check_counters_on_lte_cells}
    ...  Check If Counters Are Present On LTE  ${measurement}  ${counters_list}
    Run Keyword If  ${check_counters_on_wcdma_cells}
    ...  Check If Counters Are Present On WCDMA  ${measurement}  ${counters_list}
    Run Keyword If  ${check_trs_counters_path}
    ...  Check Path For TRS Counters  ${measurement}  ${counters_list}


Check If Counters Are Present On NR
    [Documentation]  This keyword is used to check if counters are present on NR.
    [Arguments]  ${measurement}  ${counters_list}

    ${counters_string}  Catenate  SEPARATOR=,  @{counters_list}
    Setup Admin  bts_host=${OAM_BTS_IP}  name=get_pm_counters
    ${coam_counters}  coam.Get Pm Counters  ${counters_string}  connection=get_pm_counters

    ${nrbts_id}  Admin Get NRBTS ID
    ${bts_keys}  Get Dictionary Keys  ${coam_counters}[BTS][MRBTS-${BTS_ID}]
    Return From Keyword If  'NRBTS-${nrbts_id}' not in ${bts_keys}

    ${nrbts_keys}  Get Dictionary Keys  ${coam_counters}[BTS][MRBTS-${BTS_ID}][NRBTS-${nrbts_id}]
    ${counters_on_lte_cell}  Check If Keys List Contains Specific Cell Type  NRCEL  ${nrbts_keys}
    Return From Keyword If  ${counters_on_lte_cell}==${False}

    ${nr_cells_ids}  Get Short Ids For Cells  NRCEL
    List Should Contain Sub List  ${nr_cells_ids}  ${nrbts_keys}  ${measurement} counters are not generated for the expected LTE cells IDs.

    [Teardown]  Teardown Admin  connection=get_pm_counters


Check If Counters Are Present On LTE
    [Documentation]  This keyword is used to check if counters are present on LTE.
    [Arguments]  ${measurement}  ${counters_list}

    ${counters_string}  Catenate  SEPARATOR=,  @{counters_list}
    Setup Admin  bts_host=${OAM_BTS_IP}  name=get_pm_counters
    ${coam_counters}  coam.Get Pm Counters  ${counters_string}  connection=get_pm_counters
    ${lnbts_id}  Admin Get LNBTS ID
    ${mrbts_keys}  Get Dictionary Keys  ${coam_counters}[BTS][MRBTS-${BTS_ID}]
    Return From Keyword If  'LNBTS-${lnbts_id}' not in ${mrbts_keys}

    ${lnbts_keys}  Get Dictionary Keys  ${coam_counters}[BTS][MRBTS-${BTS_ID}][LNBTS-${lnbts_id}]
    ${counters_on_lte_cell}  Check If Keys List Contains Specific Cell Type  LNCEL  ${lnbts_keys}
    Return From Keyword If  ${counters_on_lte_cell}==${False}

    ${lte_cells_ids}  Get Short Ids For Cells  LNCEL
    List Should Contain Sub List  ${lte_cells_ids}  ${lnbts_keys}  ${measurement} counters are not generated for the expected LTE cells IDs.

    [Teardown]  Teardown Admin  connection=get_pm_counters


Get Short Ids For Cells
    [Documentation]  This keyword is used to get short ids for cells.
    [Arguments]  ${cells_type}

    ${cells_dns}  coam.Get Ids For All  ${cells_type}
    ${cells_ids}  Create List
    FOR  ${cell_dn}  IN  @{cells_dns}
        ${cell_id}  Fetch From Right  ${cell_dn}  /
        ${cell_id}  Remove String  ${cell_id}  _R
        Append To List  ${cells_ids}  ${cell_id}
    END

    [Return]  ${cells_ids}


Check If Keys List Contains Specific Cell Type
    [Documentation]  This keyword is used to check if keys list contains specific cell type (LNCEL/NRCEL).
    [Arguments]  ${cell_type}  ${list}

    FOR  ${item}  IN  @{list}
        Return From Keyword If  '${cell_type}' in '${item}'  ${True}
    END

    [Return]  ${False}


Check If Counters Are Present On WCDMA
    [Documentation]  This keyword is used to check if counters are present on WCDMA.
    [Arguments]  ${measurement}  ${counters_list}

    ${counters_string}  Catenate  SEPARATOR=,  @{counters_list}
    Setup Admin  bts_host=${OAM_BTS_IP}  name=get_pm_counters
    ${coam_counters}  coam.Get Pm Counters  ${counters_string}  connection=get_pm_counters
    ${rnc_id}  Get RNC ID
    ${bts_keys}  Get Dictionary Keys  ${coam_counters}[BTS][RNC-${rnc_id}]
    ${wnbts_id}  Admin Get WNBTS ID
    Should Be Equal As Strings  ${bts_keys}[0]  WBTS-${wnbts_id}  ${measurement} counters are not generated for the expected WNBTS ID.

    ${wbts_keys}  Get Dictionary Keys  ${coam_counters}[BTS][RNC-${rnc_id}][WBTS-${wnbts_id}]
    ${meas_on_wcel}  Run Keyword And Return Status
    ...  Should Contain  ${wbts_keys}[0]  WCEL
    Run Keyword If  ${meas_on_wcel}
    ...  Check If WCEL Ids Are Valid  ${measurement}  ${coam_counters}[BTS][RNC-252][WBTS-${wnbts_id}]

    [Teardown]  Teardown Admin  connection=get_pm_counters


Check If WCEL Ids Are Valid
    [Documentation]  This keyword is used to check if WCEL ids are valid.
    [Arguments]  ${measurement}  ${cells_counters}

    ${wcdma_cells_ids}  Create List
    ${cells_dns}  Get Ids For All  WNCEL
    FOR  ${cell_dn}  IN  @{cells_dns}
        ${wncel_id}  Fetch From Right  ${cell_dn}  -
        Append To List  ${wcdma_cells_ids}  WCEL-${wncel_id}
    END
    ${wncells_keys}  Get Dictionary Keys  ${cells_counters}
    List Should Contain Sub List  ${wcdma_cells_ids}  ${wncells_keys}  ${measurement} counters are not generated for the expected WCDMA cells IDs.


Check Path For TRS Counters
    [Documentation]  This keyword checks MRBTS and TNL id from provided counters path.
    [Arguments]  ${measurement}  ${counters_list}

    ${counters_string}  Catenate  SEPARATOR=,  @{counters_list}
    Setup Admin  bts_host=${OAM_BTS_IP}  name=get_pm_counters
    ${coam_counters}  coam.Get Pm Counters  ${counters_string}  connection=get_pm_counters
    ${root_keys}  Get Dictionary Keys  ${coam_counters}
    Return From Keyword If  'TRS' not in ${root_keys}

    ${trs_keys}  Get Dictionary Keys  ${coam_counters}[TRS]
    Should Be Equal As Strings  ${trs_keys}[0]  MRBTS-${BTS_ID}  ${measurement} counters are not generated for the expected MRBTS ID.

    ${tnlsvc_id}  ${tnl_id}  Get TNLSVC And TNL Id
    ${tnlsvc_keys}  Get Dictionary Keys  ${coam_counters}[TRS][MRBTS-${BTS_ID}]
    Should Be Equal As Strings  ${tnlsvc_keys}[0]  TNLSVC-${tnlsvc_id}  ${measurement} counters are not generated for the expected TNLSVC ID.
    ${tnl_keys}  Get Dictionary Keys  ${coam_counters}[TRS][MRBTS-${BTS_ID}][TNLSVC-${tnlsvc_id}]
    Should Be Equal As Strings  ${tnl_keys}[0]  TNL-${tnl_id}  ${measurement} counters are not generated for the expected TNL ID.

    [Teardown]  Teardown Admin  connection=get_pm_counters


Get TNLSVC And TNL Id
    [Documentation]  This keyword returns ids for TNLSVC and TNL objects.

    ${tnlsvc_obj}  Query Infomodel  get object //TNLSVC_A-*
    ${tnlsvc_id}  Fetch From Right  ${tnlsvc_obj}[dist_name]  -
    ${tnl_obj}  Query Infomodel  get object //TNL_A-*
    ${tnl_id}  Fetch From Right  ${tnl_obj}[dist_name]  -

    [Return]  ${tnlsvc_id}  ${tnl_id}


Calculate Counter Occurrence
    [Documentation]  This keyword is used to calculate counter occurrence.
    [Arguments]  ${measurement}

    ${mnt_interval}  Get Measurement Interval  ${measurement}
    ${rp_interval}  Get Reporting Interval
    ${count_float}  Evaluate  ${rp_interval}/${mnt_interval}
    ${count}  Convert To Integer  ${count_float}

    [Return]  ${count}


Wait For Next PM File Collection
    [Documentation]
    ...  This keyword waits for the next PM file collection. Sleep time is calculated based on the current time
    ...  and the reporting interval.

    ${reporting_interval}  Get Reporting Interval
    ${current_time}  Get Current Date  exclude_millis=True  result_format=datetime
    ${time}  Evaluate  int(${reporting_interval}-60*${current_time.minute}%${reporting_interval}+60)
    Sleep  ${time}


Get Pm Raw Files From BTS
    [Documentation]
    ...  This keyword gets all existing PM raw files from BTS and saves to prowided path locally.
    ...  *INPUT*
    ...  | Parameter              | Description                                              |
    ...  | path_to_save_raw_files | Path where PM raw files From BTS should be saved         |
    ...  *OUTPUT*
    ...  | Parameter              | Description                                              |
    ...  | PM_raw_files_path      | Path to saved locally PM raw files                       |
    [Arguments]  ${path_to_save_raw_files}

    ${pm_raw_files_path}  Set Variable  ${path_to_save_raw_files}

    SSHLibrary.Open Connection  ${SMOD1['IP']}  encoding=unicode_escape
    SSHLibrary.Login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    SSHLibrary.Get File  /rom/uri/PERFMON_FILES/*.raw.gz  ${pm_raw_files_path}
    SSHLibrary.Close Connection

    [Return]  ${pm_raw_files_path}


Get Pm XML Files From BTS
    [Documentation]
    ...  This keyword gets all existing PM raw files from BTS and saves to prowided path locally.
    ...  *INPUT*
    ...  | Parameter              | Description                                              |
    ...  | path_to_save_xml_files | Path where PM xml files should be saved |
    ...  *OUTPUT*
    ...  | Parameter              | Description                                              |
    ...  | PM_xml_files_path      | Path to saved locally PM xml files |
    [Arguments]  ${path_to_save_xml_files}

    ${pm_xml_files_path}  Set Variable  ${path_to_save_xml_files}

    SSHLibrary.Open Connection  ${SMOD1['IP']}  encoding=unicode_escape
    SSHLibrary.Login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    SSHLibrary.Get File  /rom/uri/PERFMON_FILES/*.xml.gz  ${pm_xml_files_path}
    SSHLibrary.Close Connection

    [Return]  ${pm_xml_files_path}


Check BTS Uptime
    [Documentation]
    ...  This keyword checkes BTS utime date, that is needed to calculate full measurement start time after BTS startup.

    ${date_time}  Get Current Date  exclude_millis=True  result_format=datetime

    SSHLibrary.Open Connection  ${SMOD1['IP']}  encoding=unicode_escape
    SSHLibrary.Login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    ${command_output}  SSHLibrary.Execute Command  cut -f1 -d. /proc/uptime
    ${uptime_date}  Subtract Time From Date  ${date_time}  ${command_output} seconds  result_format=datetime
    Log  BTS is up since: ${uptime_date}  console=true

    [Return]  ${uptime_date}


Wait For Complete Report
    [Documentation]  This keyword is used to wait for complete report.

    ${reporting_interval}  Get Reporting Interval
    ${minutes_now}  Get Time  minutes
    ${minutes_now}  Convert Time  ${minutes_now}
    ${time}  Evaluate  int(2*${reporting_interval}-60*${minutes_now}%${reporting_interval})
    Sleep  ${time}


Unpack Archive Content To Directory
    [Documentation]
    ...  Unpacks the given file to the specified destination directory, based on its file extension.
    ...  example of simple use:  Unpack Archive Content To Directory   ${file}  ${destination_directory}
    [Arguments]  ${file}  ${destination}

    ${extension}  Get File Extension  ${file}
    Run Keyword If  '${extension}' == 'zip'
    ...  _Unzip To Directory  ${file}  ${destination}
    Run Keyword If  '${extension}' == 'tar'
    ...  _Untar To Directory  ${file}  ${destination}
    Run Keyword If  '${extension}' == 'tgz'
    ...  _Untgz To Directory  ${file}  ${destination}
    Run Keyword If  '${extension}' == 'gz'
    ...  _Ungz To Directory  ${file}  ${destination}
    Run Keyword If  '${extension}' == 'xz'
    ...  _Unxz To Directory  ${file}  ${destination}


Get File Extension
    [Documentation]
    ...  Returns the extension of the given file.
    [Arguments]  ${file}

    ${extension}  Fetch From Right  ${file}  .

    [Return]  ${extension}


_Unzip To Directory
    [Documentation]
    ...  Unpacks the given .zip file to the specified destination directory.
    ...  If directory does not exist it will be created
    [Arguments]  ${zip_file}  ${destination_dir}

    OperatingSystem.File Should Exist  ${zip_file}  msg=File ${zip_file} doesn't exist!
    ${state}  Run Keyword And Return Status
    ...  OperatingSystem.Directory Should Exist  ${destination_dir}
    Run Keyword If  ${state}==False
    ...  Run Keyword
    ...  Run  mkdir -p ${destination_dir}
    Run  unzip -o ${zip_file} -d ${destination_dir}
    ${state2}  Run Keyword And Return Status
    ...  OperatingSystem.Directory Should Not Be Empty  ${destination_dir}
    Run Keyword If  ${state2}==False
    ...  Log  Extract directory is empty  WARN
    Append To List  ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}  ${destination_dir}


_Untar To Directory
    [Documentation]
    ...  Unpacks the given .tar file to the specified destination directory.
    ...  If directory does not exist it will be created
    [Arguments]  ${tar_file}  ${destination_dir}

    OperatingSystem.File Should Exist  ${tar_file}  msg=File ${tar_file} doesn't exist!
    ${state}  Run Keyword And Return Status
    ...  OperatingSystem.Directory Should Exist  ${destination_dir}
    Run Keyword If  ${state}==False
    ...  Run Keyword
    ...  Run  mkdir -p ${destination_dir}
    Run  tar -oxf ${tar_file} -C ${destination_dir}
    ${state2}  Run Keyword And Return Status
    ...  OperatingSystem.Directory Should Not Be Empty  ${destination_dir}
    Run Keyword If  ${state2}==False
    ...  Log  Extract directory is empty  WARN
    Append To List  ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}  ${destination_dir}


_Untgz To Directory
    [Documentation]
    ...  Unpacks the given .tgz file to the specified destination directory.
    ...  If directory does not exist it will be created
    [Arguments]  ${tgz_file}  ${destination_dir}

    OperatingSystem.File Should Exist  ${tgz_file}  msg=File ${tgz_file} doesn't exist!
    ${state}  Run Keyword And Return Status
    ...  OperatingSystem.Directory Should Exist  ${destination_dir}
    Run Keyword If  ${state}==False
    ...  Run Keyword
    ...  Run  mkdir -p ${destination_dir}
    Run  tar -oxzf ${tgz_file} -C ${destination_dir}
    ${state2}  Run Keyword And Return Status
    ...  OperatingSystem.Directory Should Not Be Empty  ${destination_dir}
    Run Keyword If  ${state2}==False
    ...  Log  Extract directory is empty  WARN
    Append To List  ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}  ${destination_dir}


_Ungz To Directory
    [Documentation]
    ...  Unpacks the given .gz file to the specified destination directory.
    ...  If directory does not exist it will be created
    [Arguments]  ${gz_file}  ${destination_dir}

    OperatingSystem.File Should Exist  ${gz_file}  msg=File ${gz_file} doesn't exist!
    ${state}  Run Keyword And Return Status
    ...  OperatingSystem.Directory Should Exist  ${destination_dir}
    Run Keyword If  ${state}==False
    ...  Run Keyword
    ...  Run  mkdir -p ${destination_dir}
    Run  gunzip -f ${gz_file} -c > ${destination_dir}/`basename ${gz_file} .gz`
    ${state2}  Run Keyword And Return Status
    ...  OperatingSystem.Directory Should Not Be Empty  ${destination_dir}
    Run Keyword If  ${state2}==False
    ...  Log  Extract directory is empty  WARN
    Append To List  ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}  ${destination_dir}


_Unxz To Directory
    [Documentation]
    ...  Unpacks the given .xz file to the specified destination directory.
    ...  If directory does not exist it will be created
    [Arguments]  ${xz_file}  ${destination_dir}

    OperatingSystem.File Should Exist  ${xz_file}  msg=File ${xz_file} doesn't exist!
    ${state}  Run Keyword And Return Status
    ...  OperatingSystem.Directory Should Exist  ${destination_dir}
    Run Keyword If  ${state}==False
    ...  Run Keyword
    ...  Run  mkdir -p ${destination_dir}
    Run  xz -d ${xz_file} -c > ${destination_dir}/`basename ${xz_file} .xz`
    ${state2}  Run Keyword And Return Status
    ...  OperatingSystem.Directory Should Not Be Empty  ${destination_dir}
    Run Keyword If  ${state2}==False
    ...  Log  Extract directory is empty  WARN
    Append To List  ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}  ${destination_dir}


Change ReportingIntervalPm To 15 Min If Needed
    [Documentation]  This keyword is used to change reportingIntervalPm to 15 min if needed.

    coam.Get Current Scf File  ${BTS_FILES}  SCF.xml  with_auto_configured_parameters=${TRUE}
    Setup Pm  scf_path=${BTS_FILES}/SCF.xml
    ${current_reporting_interval_in_seconds}  Get Reporting Interval
    ${current_reporting_interval_in_minutes}  Evaluate  int(${current_reporting_interval_in_seconds}/60)
    Run Keyword If  '${current_reporting_interval_in_minutes}'>='60'
    ...  coam.Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    ...  reportingIntervalPm
    ...  update
    ...  15min
    ...  skip_parameter_relation_errors=True

    [Teardown]  Teardown Pm


Remove All Directories After Unpack
    [Documentation]
    ...  This keyword is romoving all temporary directories created during unpacking files
    ...  from global list variable named: "LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK"
    ...  For more details please check in TAT-26884 https://jiradc.ext.net.nokia.com/browse/TAT-26884

    FOR  ${dir_to_del}  IN  @{LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}
        Run  rm -rf ${dir_to_del}
    END


Sleep Until New Cycle
    [Documentation]  This keyword calculates the minutes it needs to sleep until new [argument] minutes cycle (from 5 to 60 min).
    [Arguments]  ${minutes_for_cycle}  ${additional_condition}=${False}

    ${minutes_for_cycle}  Convert To String  ${minutes_for_cycle}
    ${minutes_for_cycle}  Remove String  ${minutes_for_cycle}  min
    ${minutes_for_cycle}  Set Variable If  '${minutes_for_cycle}'=='5'  0${minutes_for_cycle}  ${minutes_for_cycle}
    @{time}  Get Time  min sec
    ${minutes}  Set Variable  00:${minutes_for_cycle}:00
    ${minutes_dict}  Create Dictionary  05=12  15=4  30=2  60=1
    ${limit}  Set Variable  ${minutes_dict}[${minutes_for_cycle}]
    FOR  ${index}  IN RANGE  0  ${limit}
        Run Keyword If  '00:${time}[0]:${time}[1]'<'${minutes}'
        ...  Exit For Loop
        ${minutes}  Add Time To Time  ${minutes}  ${minutes_for_cycle}:00  timer  exclude_millis=yes
    END
    ${minutes}  Subtract Time From Time  ${minutes}  00:${time}[0]:${time}[1]  timer  exclude_millis=yes
    Log  Sleep for ${minutes} minutes until new ${minutes_for_cycle} min cycle.  console=true
    Sleep  ${minutes}
    Return From Keyword If  not ${additional_condition}

    ${reporting_interval_sec}  Get Reporting Interval
    ${reporting_interval_min}  Evaluate  int(${reporting_interval_sec}/60)
    ${minutes_for_cycle}  Convert To Integer  ${minutes_for_cycle}
    Return From Keyword If  ${reporting_interval_min}>=${minutes_for_cycle}

    Log  Sleep for ${minutes} minutes until new entire ${minutes_for_cycle} min cycle.  console=true
    Sleep  ${minutes_for_cycle}min


Get RNC ID
    [Documentation]  This keyword is used to get RNC id.

    ${rnc_dn}  Get Ids For All  RNC
    ${rnc_parameters}  coam.Get Parameters  ${rnc_dn}[0]
    ${rnc_id}  Convert To String  ${rnc_parameters}[rncId]

    [Return]  ${rnc_id}


Check BTS Uptime In Minutes
    [Documentation]  This keyword is returning bts uptime in minutes.

    SSHLibrary.Open Connection  ${SMOD1['IP']}  encoding=unicode_escape
    SSHLibrary.Login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    ${command_output}  SSHLibrary.Execute Command  uptime
    ${output}  Run Keyword And Ignore Error
    ...  Should Not Match Regexp  ${command_output}  day|days|min
    ${uptime_in_minutes}  Run Keyword If  '${output[0]}'=='PASS'
    ...  Convert To Minutes  ${command_output}
    ${output}  Run Keyword And Ignore Error
    ...  Should Match Regexp  ${command_output}  min
    ${uptime_in_minutes}  Run Keyword If  '${output[0]}'=='PASS'
    ...  Evaluate  re.search(r'(\\d{1,}) min','''${command_output}''').group(1)  re
    ...  ELSE
    ...  Set Variable  ${uptime_in_minutes}
    ${output}  Run Keyword And Ignore Error
    ...  Should Match Regexp  ${command_output}  day
    ${uptime_in_minutes}  Run Keyword If  '${output[0]}'=='PASS'
    ...  Evaluate  int(re.search(r'(\\d{1,}) days{0,}','''${command_output}''').group(1))*1440  re
    ...  ELSE
    ...  Set Variable  ${uptime_in_minutes}

    [Return]  ${uptime_in_minutes}


Convert To Minutes
    [Documentation]  This keyword is extracting minutes value from bts uptime command output.
    [Arguments]  ${command_output}

    ${uptime_hours}  Run Keyword And Ignore Error
    ...  Evaluate  re.search(r'(\\d{1,}:\\d{1,}),','''${command_output}''').group(1)  re
    ${get_hours_minutes}  Get Regexp Matches  ${uptime_hours[1]}  \\d{1,}
    ${hours}  Convert Time  ${get_hours_minutes[0]}
    ${minutes}  Convert Time  ${get_hours_minutes[1]}
    ${uptime_in_minutes}  Evaluate  ${hours}*60+${minutes}

    [Return]  ${uptime_in_minutes}


Wait For Measurement Start Time
    [Documentation]  This keyword is waiting for counters from list of measurements to be loaded, based
    ...  on bts uptime.
    [Arguments]  ${uptime}  ${current_interval_list}

    ${longest_interval}  Set Variable  15
    FOR  ${interval}  IN  @{current_interval_list}
        ${interval}  Get Regexp Matches  ${interval}  \\d{1,}
        ${a}  Evaluate  ${interval[0]}-${longest_interval}
        ${longest_interval}  Set Variable If  '${a}'>'0'  ${interval[0]}  ${longest_interval}
    END
    ${current_date}  Get Current Date  UTC  result_format=datetime
    ${uptime_date}  Subtract Time From Date  ${current_date}  ${uptime} mins  result_format=datetime

    ${current_sleep_time_in_seconds}  Calc Measurement Time  ${current_date}  ${longest_interval}
    ${uptime_sleep_time_in_seconds}  Calc Measurement Time  ${uptime_date}  ${longest_interval}

    ${current_measurement_start_time}  Add Time To Date  ${current_date}  ${current_sleep_time_in_seconds}
    ${uptime_measurement_start_time}  Add Time To Date  ${uptime_date}  ${uptime_sleep_time_in_seconds}

    ${time_diff}  Subtract Date From Date  ${current_measurement_start_time}  ${uptime_measurement_start_time}

    Run Keyword If  ${time_diff}==0
    ...  Run Keywords
    ...  Log  BTS is up since ${uptime_date} UTC  console=true
    ...  AND
    ...  Log  Need to wait for longest measurement interval '${longest_interval}min' start time ${current_measurement_start_time} UTC  console=true
    ...  AND
    ...  Sleep  ${current_sleep_time_in_seconds}
    ...  ELSE
    ...  Log  BTS is up since ${uptime_date} UTC  console=true


Calc Measurement Time
    [Documentation]  This keyword is converting datetime value in seconds.
    [Arguments]  ${uptime_date}  ${longest_interval}

    ${hour}  Set Variable  ${uptime_date.hour}
    ${hour}  Convert Time  ${hour}
    ${minutes}  Set Variable  ${uptime_date.minute}
    ${minutes}  Convert Time  ${minutes}
    ${current_time_in_minutes}  Evaluate  int(${hour}*60+${minutes})
    ${sleep_time_in_seconds}  Evaluate  (${longest_interval}-${current_time_in_minutes}%${longest_interval})*60

    [Return]  ${sleep_time_in_seconds}


Get Last Value From Dictionary For Specific Counter
    [Documentation]  This keyword is returning the last value for provided counter
    ...  from the last time interval.
    [Arguments]  ${enb_counter_values}

    FOR  ${key}  IN  @{enb_counter_values}
        Continue For Loop
    END

    [Return]  ${enb_counter_values}[${key}]


Get Counters Dictionaries Based On XML PM File
    [Documentation]  This KW returns the numbers for all counters and counters set on 0 based on xml file and counters_match for required technology.
    [Arguments]  ${counters_match}  ${pm_xml_path}

    ${counters_match}  Replace String  ${counters_match}  ,  |
    ${counters_match}  Remove String  ${counters_match}  ${SPACE}
    ${all_counters_command}  Catenate  grep -E "<(${counters_match})" ${pm_xml_path} | grep -iv "<MO dimension" | cut -d":" -f1 | sort | uniq -c
    ${counters_set_on_0_command}  Catenate  grep -E "<(${counters_match})" ${pm_xml_path} | grep -iv "<MO dimension" |
    ...  grep -E ">0\.?0*<\\/M" | cut -d":" -f1 | sort | uniq -c
    ${all_counters}  SSHLibrary.Execute Command  ${all_counters_command}
    ${counters_set_on_0}  SSHLibrary.Execute Command  ${counters_set_on_0_command}

    ${counters_number}  Get Number Of Unique Counters  ${all_counters}
    ${counters_set_on_0}  Get Number Of Unique Counters  ${counters_set_on_0}
    ${counters_numbers_dict}  Create Dictionary  counters_number=${counters_number}  counters_set_on_0=${counters_set_on_0}

    [Return]  ${counters_numbers_dict}


Get Number Of Unique Counters
    [Documentation]  This KW is counting unique counters within < > brackets from counters lines provided by grep command.
    [Arguments]  ${counters_lines}

    ${counters}  Get Regexp Matches  ${counters_lines}  <M[0-9A-Z]+>
    ${counters}  Remove Duplicates  ${counters}
    ${counters_number}  Get Length  ${counters}

    [Return]  ${counters_number}


Extract Last Gz File From SBTS AND Get XML File Name
    [Documentation]  This KW is extracting gz file into xml file and return xml file name. SSH connection to SBTS must be opened first.

    ${pm_gz_files}  SSHLibrary.List Files In Directory  /rom/uri/PERFMON_FILES  PM.*\.xml\.gz
    ${last_xml_file}  Fetch From Left  ${pm_gz_files}[-1]  .gz
    ${path}  Set Variable  /rom/uri/PERFMON_FILES
    SSHLibrary.Execute Command  gzip -d -c ${path}/${pm_gz_files}[-1] > ${path}/test_${last_xml_file}
    SSHLibrary.Execute Command  sed -i "s/></>\\n</g" ${path}/test_${last_xml_file}

    [Return]  test_${last_xml_file}


Get PM File And Counters Number For TNL And List Of RATs
    [Documentation]  Thiw KW returns the last PM file from SBTS and the numbers of counters for TNL and each RAT from list provided.
    [Arguments]  ${rat_list}

    ${last_xml_file}  Extract Last Gz File From SBTS AND Get XML File Name
    ${counters_on_technologies}  Create Dictionary
    FOR  ${rat}  IN  @{rat_list}
        ${counters_on_rat}  Get Counters Dictionaries Based On XML PM File  ${${rat}_COUNTERS_MATCH}  /rom/uri/PERFMON_FILES/${last_xml_file}
        Set To Dictionary  ${counters_on_technologies}  ${rat}=${counters_on_rat}
    END
    ${tnl_counters}  Get Counters Dictionaries Based On XML PM File  ${TNL_COUNTERS_MATCH}  /rom/uri/PERFMON_FILES/${last_xml_file}
    Set To Dictionary  ${counters_on_technologies}  TNL=${tnl_counters}

    [Return]  ${last_xml_file}  ${counters_on_technologies}


Get Counters Differences Between 2 XML Files
    [Documentation]  This KW is returning a list of counters which represents counters differences between provided 2 xml files from virtual machine.
    ...  The last argument ${counters_type} can be 'all' or 'set_on_0' and grep command is set accordingly.
    [Arguments]  ${first_xml_file}  ${second_xml_file}  ${counters_match}  ${counters_type}

    ${last_commands}  Set Variable  grep -iv "<MO dimension"
    ${last_commands}  Set Variable If  '${counters_type}'=='all'  ${last_commands}  ${last_commands} | grep -E ">0\.?0*<\\/M"
    ${last_commands}  Set Variable  ${last_commands} | cut -d":" -f1 | sort | uniq -c

    ${first_xml_counters_lines}  Run  grep -E "<(${counters_match})" ${first_xml_file} | ${last_commands}
    ${first_xml_counters}  Get Regexp Matches  ${first_xml_counters_lines}  <M[0-9A-Z]+>

    ${second_xml_counters_lines}  Run  grep -E "<(${counters_match})" ${second_xml_file} | ${last_commands}
    ${second_xml_counters}  Get Regexp Matches  ${second_xml_counters_lines}  <M[0-9A-Z]+>

    ${counters_diff}  Evaluate  list(set($first_xml_counters) ^ set($second_xml_counters))

    [Return]  ${counters_diff}


Check PM Report In Syslog
    [Documentation]  This kw is searching for provided PM report to be logged as sent to NetAct in syslog file after
    ...  specific time.
    [Arguments]  ${pm_report}  ${syslog_file}  ${time_to_search_after}

    ${pattern}  Catenate  SEPARATOR=  .INF\/Ne3sAdapter\/Pm,\\s+\\[manager::pm::PmHandler\\]\\s+\\[PM\\]Notification\\s+of
    ...  \\s+pm\\s+with\\s+relative\\s+path:\\s+\/PERFMON_FILES\/${pm_report}\\s+.*transfer\\s+success
    ${report_line_from_syslog}  Grep File  ${syslog_file}  ${pattern}  regexp=${TRUE}
    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${report_line_from_syslog}
    IF  not ${status}
        Fail  ${pm_report} was not sent to NetAct.
        Return From Keyword
    END

    ${time_match}  Get regexp matches  ${report_line_from_syslog}  <.*>
    ${time_match}  Remove String  ${time_match}[0]  <  >  Z
    ${time_match}  Replace String  ${time_match}  T  ${SPACE}
    ${status}  Run Keyword And Return Status  Should Be True  '${time_match}'>'${time_to_search_after}'
    IF  not ${status}
        Fail  ${pm_report} was not reported after O&M reconnection.
        Return From Keyword
    END
    Log  ${pm_report} was correctly reported to NetAct at ${time_match}.  console=true


Get Primary Core Serial Number
    [Documentation]  This kw is returning serial number for primary core unit.

    ${smods_objects}  Get System Module List
    ${smods_objects}  Get From Dictionary  ${smods_objects}  systemModules
    FOR  ${obj}  IN  @{smods_objects}
        IF  '${obj}[activeRole]'!='Secondary'  RETURN  ${obj}[serialNumber]
    END
    Fail  No system module object has primary active role.


Get PPM File Not Empty
    [Documentation]  This kw is searching for PPM file generated in ${ppm_files_path_on_sbts} location. Previous
    ...  ssh connection to SBTS is required.
    [Arguments]  ${ppm_files_path_on_sbts}  ${pattern}

    ${current_ppm_file}  SSHLibrary.List Files In Directory  ${ppm_files_path_on_sbts}  pattern=${pattern}
    Should Not Be Empty  ${current_ppm_file}  There are zero PPM files generated.

    RETURN  ${current_ppm_file}


Wait For New PPM File To Be Generated
    [Documentation]  This kw is searching for new PPM file in ${ppm_files_path_on_sbts} location based on
    ...  current_ppm_file.
    [Arguments]  ${ppm_files_path_on_sbts}  ${current_ppm_file}  ${bench_mark}  ${pattern}

    ${new_ppm_file}  SSHLibrary.List Files In Directory  ${ppm_files_path_on_sbts}  pattern=${pattern}
    Should Not Be Empty  ${new_ppm_file}  There are zero PPM files generated after ${bench_mark} from current interval.
    ${new_file_is_not_generated}  Run Keyword And Return Status  Lists Should Be Equal  ${new_ppm_file}  ${current_ppm_file}
    IF  ${new_file_is_not_generated}  Fail  There is no new PPM file generated as expected after ${bench_mark} from current interval.

    RETURN  ${new_ppm_file}


Wait For New 1 Minute Interval
    [Documentation]  Thiw kw waits until new 1 minute interval starts.

    ${current_time}  Get Current Date  exclude_millis=True  result_format=datetime  time_zone=UTC
    ${wait_time}  Evaluate  int(60-${current_time.second})
    Sleep  ${wait_time}  TC waits until new 1 minute interval.