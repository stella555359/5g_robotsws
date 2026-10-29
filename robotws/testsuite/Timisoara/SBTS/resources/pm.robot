*** Settings ***
Library         DateTime
Library         hran_pm
Library         taf.sbts.oam.coam.admin  WITH NAME  coam

*** Keywords ***
Download PM Report
    coam.Get Current Scf File  ${BTS Files}  scf.xml  export_type=configuration
    Setup Pm    scf_path=${BTS Files}/scf.xml
    Load Measurements    ${MEASUREMENT_PATH}  ${ABBREVIATION_DICT_PATH}  filtrate_key=${TO_FILTRATE_KEYS}  filtrate_val=${TO_FILTRATE_VALUES}
    ${status}     Run keyword and return status    Read PM File
    Run keyword unless    ${status}    Run keywords     Log    PM file not yet created, wait for complete report    console=${TRUE}
    ...                                                 AND    Wait For Complete Report    AND   Read PM File
    Log   PM file loaded successfully    console=${TRUE}

Check If Counters Are Present
    [Arguments]  ${measurement}  ${numbers_list}
    ${enabled}=     Measurement Enabled In Scf      ${measurement}
    Return From Keyword If    ${enabled}==${False}
    ${count}=       Calculate Counter Occurrence    ${measurement}
    ${not_found_counters}=    Check Counters    ${numbers_list}    count=${count}
    Run Keyword If    ${not_found_counters}!=@{EMPTY}
    ...  Set Test Failed    For measurement: ${measurement}. Following counters not found: ${not_found_counters}

Calculate Counter Occurrence
    [Arguments]  ${measurement}
    ${mnt_interval}=    Get Measurement Interval  ${measurement}
    ${rp_interval}=     Get Reporting Interval
    ${count_float}=     Evaluate    ${rp_interval}/${mnt_interval}
    ${count}=           Convert To Integer   ${count_float}
    [Return]  ${count}

Wait Timer Till End Of WCDMA Measurement Interval
    ${reporting_interval} =  Get Reporting Interval
    ${minutes_now}=  Get Time    minutes
    Log  Minutes now: ${minutes_now}    console=${TRUE}
    ${minutes_now}=  Convert Time   ${minutes_now}
    ${time}=    Evaluate    int(61-${minutes_now})
    Log  Waiting till end of currect reporting interval ${time} minutes.  console=${TRUE}
    Sleep  ${time}m

Wait For PM File Collection After Startup
    [Documentation]
    ...  *AUTHOR* lukasz.targonski@nokia.com
    ...  This keyword calculates PM file availability time based on the BTS startup time and sleeps
    ...  if calculated time is after the curent time.

    ${reporting_interval}  Get Reporting Interval
    ${uptime}  pm.Check BTS Uptime
    ${seconds_to_report_after_startup}  Evaluate  int(${reporting_interval}-60*${uptime.minute}%${reporting_interval})
    ${report_time_after_startup}  Add Time To Date  ${uptime}  ${seconds_to_report_after_startup}  exclude_millis=True  result_format=datetime
    ${report_time_after_startup}  Subtract Time from Date
    ...  ${report_time_after_startup}  ${report_time_after_startup.second}  exclude_millis=True  result_format=datetime

    ${current_time}  Get Current Date  exclude_millis=True  result_format=datetime
    ${seconds_to_report}  Evaluate  int(${reporting_interval}-60*${current_time.minute}%${reporting_interval}+60)
    ${report_time}  Add Time To Date  ${current_time}  ${seconds_to_report}  exclude_millis=True  result_format=datetime
    ${report_time}  Subtract Time from Date  ${report_time}  ${report_time.second}  exclude_millis=True  result_format=datetime

    ${time_diff}  Subtract Date From Date  ${current_time}  ${report_time_after_startup}

    Run Keyword If  ${time_diff}<0  Run Keywords
    ...  Log  Need to wait untill ${report_time} for PM report  console=${TRUE}
    ...  AND  Sleep  ${seconds_to_report}
    ...  ELSE  Log  No need to wait for PM report  console=${TRUE}

Wait For Next PM File Collection
    [Documentation]
    ...  *AUTHOR* lukasz.targonski@nokia.com
    ...  This keyword waits for the next PM file collection. Sleep time is calculated based on the current time
    ...  and the reporting interval.

    ${reporting_interval}  Get Reporting Interval
    ${current_time}  Get Current Date  exclude_millis=True  result_format=datetime
    ${time}    Evaluate    int(${reporting_interval}-60*${current_time.minute}%${reporting_interval}+60)
    Sleep  ${time}

Get Pm Raw Files From BTS
    [Documentation]
    ...  *AUTHOR* iuliia.taupeka@nokia.com
    ...  This keyword gets all existing PM raw files from BTS and saves to prowided path locally.
    ...  *INPUT*
    ...  | Parameter              | Description                                              |
    ...  | path_to_save_raw_files | Path where PM raw files From BTS should be saved         |
    ...  *OUTPUT*
    ...  | Parameter              | Description                                              |
    ...  | PM_raw_files_path      | Path to saved locally PM raw files                       |

    [Arguments]  ${path_to_save_raw_files}
    ${PM_raw_files_path}  Set Variable  ${path_to_save_raw_files}

    SSHLibrary.open connection  ${SMOD1['IP']}  encoding=unicode_escape
    SSHLibrary.login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    SSHLibrary.Get File  /rom/uri/PERFMON_FILES/*.raw.gz  ${PM_raw_files_path}
    SSHLibrary.Close Connection
    [Return]  ${PM_raw_files_path}

Get Pm XML Files From BTS
    [Documentation]
    ...  *AUTHOR* iuliia.taupeka@nokia.com
    ...  This keyword gets all existing PM raw files from BTS and saves to prowided path locally.
    ...  *INPUT*
    ...  | Parameter              | Description                                              |
    ...  | path_to_save_xml_files | Path where PM xml files should be saved |
    ...  *OUTPUT*
    ...  | Parameter              | Description                                              |
    ...  | PM_xml_files_path      | Path to saved locally PM xml files |

    [Arguments]  ${path_to_save_xml_files}
    ${PM_xml_files_path}  Set Variable  ${path_to_save_xml_files}

    SSHLibrary.open connection  ${SMOD1['IP']}  encoding=unicode_escape
    SSHLibrary.login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    SSHLibrary.Get File  /rom/uri/PERFMON_FILES/*.xml.gz  ${PM_xml_files_path}
    SSHLibrary.Close Connection
    [Return]  ${PM_xml_files_path}

Check BTS Uptime
    [Documentation]
    ...  *AUTHOR* lukasz.targonski@nokia.com
    ...  This keyword checkes BTS utime date, that is needed to calculate full measurement start time after BTS startup.

    ${datetime}  Get Current Date  exclude_millis=True  result_format=datetime

    SSHLibrary.Open Connection  ${SMOD1['IP']}  encoding=unicode_escape
    SSHLibrary.Login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    ${command_output}  SSHLibrary.execute command  cut -f1 -d. /proc/uptime return_stdout=False
    ${uptime_date}  Subtract Time From Date  ${datetime}  ${command_output} seconds  result_format=datetime

    [Return]  ${uptime_date}

Wait For Complete Report
    ${reporting_interval} =  Get Reporting Interval
    ${minutes_now}=  Get Time    minutes
    ${minutes_now}=  Convert Time   ${minutes_now}
    ${time}=    Evaluate    int(2*${reporting_interval}-60*${minutes_now}%${reporting_interval})
    Sleep  ${time}
