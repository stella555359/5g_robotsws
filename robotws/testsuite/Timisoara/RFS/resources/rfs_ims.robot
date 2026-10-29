*** Settings ***
Documentation    Resource file for IMS
Library    taf.ul.oam_kpi_calculations  WITH NAME  kpi
Library    python_resources/tools.py
Library    taf.rfrl.common_resources.oam_kpi.report_oam_kpi  WITH NAME  kpi_report
Library    python_resources/alarms_analysis.py

*** Variables ***
# Valid KPI list
@{kpi_valid_name_list}=  kpi1a  kpi1b  kpi1c  kpi1f  kpi1g  kpi3  kpi51a  kpi51b  kpi51c  kpi53a  kpi53b  kpi54a  kpi54b  kpi17a  kpi17b  kpi16a
...  kpi16b  kpi5  kpi13  kpi7  kpi8  kpi9  kpi10  kpiswdownload  kpiswprovision  kpi2a  kpi12a  kpi12b

# Simplified alarm ims
&{SIMPLIFIED_ALARM_IMS}=  alarmId=${None}  faultId=${None}  alarmName=${None}
...  visibleForEM=${None}  visibleForNetAct=${None}  visibleForOnap=${None}
...  object_id=${None}  affected_resources_dn=${None}
...  supplAlarmInfo=${None}

# Translated ims alarm
&{TRANSLATED_ALARM_IMS}=  alarmId=alarmId  faultId=faultId  object_id=object_id  visibleForEM=visibleForEM
...  visibleForNetAct=visibleForNetAct  visibleForOnap=visibleForOnap  affected_resources_dn=affected_resources_dn  object_id=object_id
...  sn_attribute=sn_attribute

&{TRANSLATED_RD_FAULT_IMS}=  faultId=faultId  faultyObject=faultyObject  faultySubUnit=faultySubUnit  log_entry_dist_name=log_entry_dist_name

@{KEYS_FOR_REMOVE_DUPLICATE_ALARM_IMS}=  alarmId  alarm_dist_name  cleared  faultId  object_id  observationTime

*** Keywords ***
Get and check BTS RESET info from IMS file
    [Documentation]
    ...  Get and check BTS RESET info from IMS file
    ...  Variables ${start_point_timestamp_UTC} and ${end_point_timestamp_UTC} are set as returned values from KW Get Current Date UTC info (need to
    ...  be run apriori), otherwise set as empty
    ...  IMS file RESET timestamps UTC are compared with ${start_point_timestamp_UTC} and ${end_point_timestamp_UTC} as follows:
    ...  - if both start and end timestamps values are empty, all RESET timestamps found in IMS file will be considered for compare with expected
    ...  reset number
    ...  - if only start timestamp value is empty, all RESET timestamps found in IMS file until end timestamp value will be considered for compare
    ...  - if only end timestamp value is empty, all RESET timestamps found in IMS file from start timestamp value will be considered for compare
    ...  - if both start and end timestamps values are not empty, only RESET timestamps found in IMS file in range defined by start and end
    ...  timestamps values will be considered for compare with expected reset number
    ...
    ...  *INPUT*
    ...  | Parameter                 | Mandatory | Description                                |
    ...  | ims_file_path             | No        | IMS file path location                     |
    ...  | expected_reset_number     | No        | Expected RESET number                      |
    ...  | timeout                   | No        | Time to wait for positive procedure result |
    ...  | alias                     | No        | Alias of admin instance                    |
    ...  | log_level                 | No        | Log level info                             |
    ...  | remove_ims_file           | No        | Remove ims file after parsing RESET info   |
    ...  | start_point_timestamp_UTC | No        | Start point timestamp UTC format           |
    ...  | end_point_timestamp_UTC   | No        | End point timestamp UTC format             |
    ...
    [Arguments]  ${ims_file_path}=${EMPTY}  ${expected_reset_number}=1  ${timeout}=180  ${alias}=default  ${log_level}=ERROR
    ...  ${remove_ims_file}=${FALSE}  ${start_point_timestamp_UTC}=${EMPTY}  ${end_point_timestamp_UTC}=${EMPTY}

    ${ims_file_path_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${ims_file_path}
    ${ims_file_path}=  Run Keyword If  ${ims_file_path_isEmpty}
    ...  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}  timeout=${timeout}
    ...  ELSE
    ...  Set Variable  ${ims_file_path}

    Log  Get Reset request timestamps from IMS file: ${ims_file_path}  console=True

    ${ims_reset_timestamps}=  kpi.Get Reset Request Timestamps  ims_file_path=${ims_file_path}

    ${ims_reset_verdict}  ${ims_reset_number}=  Check BTS reset behavior based on IMS file  ${start_point_timestamp_UTC}  ${end_point_timestamp_UTC}
    ...  ${ims_reset_timestamps}  ${expected_reset_number}  ${alias}

    Run Keyword If  ${ims_reset_verdict}
    ...  Log  BTS ${alias} reset behavior as expected (expected/found reset number: ${expected_reset_number}/${ims_reset_number})!  console=True
    ...  ELSE  Run Keyword If  '${log_level}'=='WARN'
    ...  Log  BTS ${alias} reset behavior not as expected (expected/found reset number: ${expected_reset_number}/${ims_reset_number})!  level=WARN
    ...  ELSE  Run Keyword If  '${log_level}'=='ERROR'  Run Keywords
    ...  Log  BTS ${alias} reset behavior not as expected (expected/found reset number: ${expected_reset_number}/${ims_reset_number})!  level=ERROR
    ...  AND  Fail  BTS ${alias} reset behavior not as expected (expected/found reset number: ${expected_reset_number}/${ims_reset_number})!

    [Teardown]  Run Keyword If  ${ims_file_path_isEmpty} and ${remove_ims_file}  Run Keywords
    ...  Remove File  ${ims_file_path}
    ...  AND  Log  Removed IMS file ${ims_file_path}  level=INFO  console=True

Check BTS reset behavior based on IMS file
    [Arguments]  ${start_point_timestamp_UTC}  ${end_point_timestamp_UTC}  ${ims_reset_timestamps}  ${expected_reset_number}  ${alias}

    ${start_point_timestamp_UTC_epoch}=  Run Keyword If  '${start_point_timestamp_UTC}' != '${EMPTY}'
    ...  Convert Date  ${start_point_timestamp_UTC}  epoch  exclude_millis=True
    ...  ELSE
    ...  Set Variable  0
    ${end_point_timestamp_UTC_epoch}=  Run Keyword If  '${end_point_timestamp_UTC}' != '${EMPTY}'
    ...  Convert Date  ${end_point_timestamp_UTC}  epoch  exclude_millis=True
    ...  ELSE
    ...  Set Variable  0
    ${ims_reset_number}=  Set Variable  0

    FOR  ${timestamp}  IN  @{ims_reset_timestamps}
        ${timestamp_date}=  Convert Date  ${timestamp}  date_format=%Y-%m-%d %H:%M:%S  exclude_millis=True
        ${timestamp_epoch}=  Convert Date  ${timestamp_date}  epoch  exclude_millis=True
        ${cond1}=  Create Long String  '${start_point_timestamp_UTC}' == '${EMPTY}' and '${end_point_timestamp_UTC}' == '${EMPTY}'
        ${cond2}=  Create Long String  '${start_point_timestamp_UTC}' == '${EMPTY}' and '${end_point_timestamp_UTC}' != '${EMPTY}' and
        ...  ${timestamp_epoch} <= ${end_point_timestamp_UTC_epoch}
        ${cond3}=  Create Long String  '${start_point_timestamp_UTC}' != '${EMPTY}' and '${end_point_timestamp_UTC}' == '${EMPTY}' and
        ...  ${start_point_timestamp_UTC_epoch} <= ${timestamp_epoch}
        ${cond4}=  Create Long String  '${start_point_timestamp_UTC}' != '${EMPTY}' and '${end_point_timestamp_UTC}' != '${EMPTY}' and
        ...  ${start_point_timestamp_UTC_epoch} <= ${timestamp_epoch} <= ${end_point_timestamp_UTC_epoch}

        Run Keyword If  ${cond1} or ${cond2} or ${cond3} or ${cond4}
        ...  Log  BTS ${alias} UTC RESET timestamp from IMS file: ${timestamp_date}  console=True

        ${ims_reset_number}=  Run Keyword If  ${cond1} or ${cond2} or ${cond3} or ${cond4}
        ...  Evaluate  ${ims_reset_number} + 1
        ...  ELSE
        ...  Evaluate  ${ims_reset_number} + 0
    END

    ${ims_reset_verdict}=  Run Keyword And Return Status
    ...  Should Be Equal As Integers  ${ims_reset_number}  ${expected_reset_number}

    [Return]  ${ims_reset_verdict}  ${ims_reset_number}

Get and check KPI info from IMS file
    [Documentation]
    ...  Get and check KPI info. Following KPI names are available:
    ...  - Site Reset: kpi1a, kpi1b, kpi1c, kpi1f, kpi1g
    ...  - Power-On BTS Startup: kpi3; mandatory to set variable ${start_point_timestamp_UTC}
    ...  - RU Reset: kpi51a, kpi51b, kpi51c; recommended to set variables ${triggered_from} and ${ims_from}
    ...  - Power-On RU Startup: kpi54a, kpi54b; mandatory to set variable ${start_point_timestamp_UTC}
    ...  - Cell block: kpi17a; mandatory to set variable ${cell_dist_name}
    ...  - Cell unblock: kpi17b; mandatory to set variable ${cell_dist_name}
    ...  - Cell lock: kpi16a; mandatory to set variable ${cell_dist_name}
    ...  - Cell unlock: kpi16a; mandatory to set variable ${cell_dist_name}
    ...  - BBMOD Reset: kpi5;
    ...  - SW rollback: kpi13;
    ...  - RAT Reset: kpi7(LTE), kpi8(WCDMA), kpi9(GSM), kpi10(NR);
    ...  - SW download: kpiswdownload;
    ...  - SW provision: kpiswprovision;
    ...  - SW activation: kpi2a
    ...  - Recommissioning: kpi12a, kpi12b
    ...  Variable ${start_point_timestamp_UTC} is set as returned value from KW Get Current Date UTC info (need to be run apriori to set power ON
    ...  start action)
    ...
    ...  *INPUT*
    ...  | Parameter                 | Mandatory | Description                                                                             |
    ...  | kpi_names                 | Yes       | KPI names: list of kpi names separated by comma (ex. kpi1a, kpi1b, kpi1c, kpi1f, kpi1g) |
    ...  | kpi_thresholds            | Yes       | KPI thresholds: list of kpi thresholds (seconds) separated by comma (ex. 100, 105, 110) |
    ...  | kpi_folder_path           | No        | KPI folder path location                                                                |
    ...  | ims_file_path             | No        | IMS file path location                                                                  |
    ...  | timeout                   | No        | Time to wait for positive procedure result                                              |
    ...  | alias                     | No        | Alias of admin instance                                                                 |
    ...  | save_kpi_file             | No        | Save KPI info in kpi file after parsing KPI info                                        |
    ...  | remove_ims_file           | No        | Possible values:                                                                        |
    ...                                            TRUE - Remove ims file after parsing KPI info                                           |
    ...                                            FALSE - Keep ims file after parsing KPI info (default value)                            |
    ...  | start_point_timestamp_UTC | No        | Start point timestamp UTC format                                                        |
    ...  | end_point_timestamp_UTC   | No        | End point timestamp UTC format                                                          |
    ...  | cell_dist_name            | Yes       | Useful only for kpi17a, kpi17b; specifies cell dist name                                |
    ...  | global_cell_id            | Yes       | Useful only for kpi16a, kpi16b; specifies global cell id
    ...  | triggered_from            | No        | Useful only for kpi51a, kpi51b, kpi51c; specifies the BTS where the reset RM is
    ...                                            triggered from. Possible values: primary or secondary                                   |
    ...  | ims_from                  | No        | Useful only for kpi51a, kpi51b, kpi51c; specifies the BTS where the ims trace is
    ...                                            collected for KPI measurement. Possible values: primary or secondary                    |
    ...  | current_cell_dist_names   | No        | Useful only for kpi12a, kpi12b; specifies all current cell dist names                   |
    ...
    [Arguments]  ${kpi_names}  ${kpi_thresholds}  ${kpi_folder_path}=${EMPTY}  ${ims_file_path}=${EMPTY}  ${timeout}=180  ${alias}=default
    ...  ${save_kpi_file}=${TRUE}  ${remove_ims_file}=${FALSE}  ${start_point_timestamp_UTC}=${EMPTY}  ${end_point_timestamp_UTC}=${EMPTY}
    ...  ${cell_dist_name}=${EMPTY}  ${global_cell_id}=${EMPTY}  ${triggered_from}=${EMPTY}  ${ims_from}=${EMPTY}
    ...  ${current_cell_dist_names}=${EMPTY}

    ${kpi_name_list}=  Prepare list info from string info  ${kpi_names}
    ${kpi_threshold_list}=  Prepare list info from string info  ${kpi_thresholds}
    ${kpi_folder_path}=  Run Keyword If  '${kpi_folder_path}' == '${EMPTY}'
    ...  Set Variable  ${Test Results Dir}/KPI/${alias}
    ...  ELSE
    ...  Set Variable  ${kpi_folder_path}

    ${ims_file_path_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${ims_file_path}

    ${kpi_skip_enabled}=  Check If KPI Check Skip Enabled
    ${kpi_mock_obj}=  Run Keyword If  ${kpi_skip_enabled}  tools.Create Mock Object
    Return From Keyword If  ${kpi_mock_obj}  ${kpi_mock_obj}

    ${ims_file_path}=  Run Keyword If  ${ims_file_path_isEmpty}
    ...  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}  timeout=${timeout}
    ...  ELSE
    ...  Set Variable  ${ims_file_path}

    kpi.Clear Results

    ${start_point_timestamp_UTC_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${start_point_timestamp_UTC}
    Run Keyword If  '${start_point_timestamp_UTC_isEmpty}' == 'False'  Save Search Start Timestamp  ${start_point_timestamp_UTC}
    ${end_point_timestamp_UTC_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${end_point_timestamp_UTC}
    Run Keyword If  '${end_point_timestamp_UTC_isEmpty}' == 'False'  Save Search End Timestamp  ${end_point_timestamp_UTC}

    ${kpi_name_delta_dict} =  Create Dictionary

    FOR  ${kpi_name}  ${kpi_threshold}  IN ZIP  ${kpi_name_list}  ${kpi_threshold_list}
        Run Keyword If  '${kpi_name.lower()}' not in ${kpi_valid_name_list}  Run Keywords
        ...  Log  KPI ${kpi_name.lower()} not yet implemented in current KW  level=ERROR
        ...  AND  Run Keyword And Continue On Failure  Fail  KPI ${kpi_name.lower()} not yet implemented in current KW
        ...  AND  Continue For Loop

        ${kpi_start_end_info}=  Set Variable If
        ...  '${kpi_name.lower()}' == 'kpi1a'  first cell down to last cell up
        ...  '${kpi_name.lower()}' == 'kpi1b'  last cell down to first cell up
        ...  '${kpi_name.lower()}' == 'kpi1c'  reset request to first cell up
        ...  '${kpi_name.lower()}' == 'kpi1f'  first cell down to last cell up - reset without RU reset
        ...  '${kpi_name.lower()}' == 'kpi1g'  last cell down to first cell up - reset without RU reset
        ...  '${kpi_name.lower()}' == 'kpi3'  power on BTS to first cell up
        ...  '${kpi_name.lower()}' == 'kpi51a'  first cell down to last cell up
        ...  '${kpi_name.lower()}' == 'kpi51b'  last cell down to first cell up
        ...  '${kpi_name.lower()}' == 'kpi51c'  first cell degraded to last cell up
        ...  '${kpi_name.lower()}' == 'kpi53a'  first cell down to last cell up
        ...  '${kpi_name.lower()}' == 'kpi53b'  last cell down to first cell up
        ...  '${kpi_name.lower()}' == 'kpi54a'  power on RU to last cell up
        ...  '${kpi_name.lower()}' == 'kpi54b'  power on RU to first cell up
        ...  '${kpi_name.lower()}' == 'kpi17a'  cell block to cell down
        ...  '${kpi_name.lower()}' == 'kpi17b'  cell unblock to cell up
        ...  '${kpi_name.lower()}' == 'kpi16a'  cell lock to cell down
        ...  '${kpi_name.lower()}' == 'kpi16b'  cell unlock to cell up
        ...  '${kpi_name.lower()}' == 'kpi5'  first cell down to last cell up
        ...  '${kpi_name.lower()}' == 'kpi13'  first cell down to last cell up
        ...  '${kpi_name.lower()}' == 'kpi7'  first LTE cell down to last LTE cell up
        ...  '${kpi_name.lower()}' == 'kpi8'  first WCDMA cell down to last WCDMA cell up
        ...  '${kpi_name.lower()}' == 'kpi9'  first GSM cell down to last GSM cell up
        ...  '${kpi_name.lower()}' == 'kpi10'  first NR cell down to last NR cell up
        ...  '${kpi_name.lower()}' == 'kpiswdownload'  SW download start to SW download end
        ...  '${kpi_name.lower()}' == 'kpiswprovision'  SW download start to last cell up
        ...  '${kpi_name.lower()}' == 'kpi2a'  first cell down to last cell up
        ...  '${kpi_name.lower()}' == 'kpi12a'  first cell down to last cell up
        ...  '${kpi_name.lower()}' == 'kpi12b'  first cell down to last cell up

        Log  ***** Get and check KPI ${kpi_name} (${kpi_start_end_info}) info from IMS file *****  console=True

        ${kpi_info}=  Run Keyword If  '${kpi_name.lower()}' == 'kpi1a'
        ...  kpi.Calculate Kpi1a  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi1b'  Run Keyword
        ...  kpi.Calculate Kpi1b  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi1c'  Run Keyword
        ...  kpi.Calculate Kpi1c  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi1f'  Run Keyword
        ...  kpi.Calculate Kpi1f  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi1g'  Run Keyword
        ...  kpi.Calculate kpi1g  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi3'  Run Keyword
        ...  kpi.Calculate Kpi3  ims_file_path=${ims_file_path}  start_point_timestamp=${start_point_timestamp_UTC}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi51a'  Run Keyword
        ...  kpi.Calculate Kpi51a  ims_file_path=${ims_file_path}  triggered_from=${triggered_from}  ims_from=${ims_from}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi51b'  Run Keyword
        ...  kpi.Calculate Kpi51b  ims_file_path=${ims_file_path}  triggered_from=${triggered_from}  ims_from=${ims_from}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi51c'  Run Keyword
        ...  kpi.Calculate Kpi51c  ims_file_path=${ims_file_path}  triggered_from=${triggered_from}  ims_from=${ims_from}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi53a'  Run Keyword
        ...  kpi.Calculate Kpi53a  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi53b'  Run Keyword
        ...  kpi.Calculate Kpi53b  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi54a'  Run Keyword
        ...  kpi.Calculate Kpi54a  ims_file_path=${ims_file_path}  start_point_timestamp=${start_point_timestamp_UTC}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi54b'  Run Keyword
        ...  kpi.Calculate Kpi54b  ims_file_path=${ims_file_path}  start_point_timestamp=${start_point_timestamp_UTC}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi17a'  Run Keyword
        ...  kpi.Calculate Kpi17a  ims_file_path=${ims_file_path}  dist_name=${cell_dist_name}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi17b'  Run Keyword
        ...  kpi.Calculate Kpi17b  ims_file_path=${ims_file_path}  dist_name=${cell_dist_name}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi16a'  Run Keyword
        ...  kpi.Calculate kpi16a  ims_file_path=${ims_file_path}  global_cell_id=${global_cell_id}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi16b'  Run Keyword
        ...  kpi.Calculate kpi16b  ims_file_path=${ims_file_path}  global_cell_id=${global_cell_id}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi5'  Run Keyword
        ...  kpi.Calculate Kpi5  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi13'  Run Keyword
        ...  kpi.Calculate Kpi13  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi7'  Run Keyword
        ...  kpi.Calculate Kpi7  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi8'  Run Keyword
        ...  kpi.Calculate Kpi8  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi9'  Run Keyword
        ...  kpi.Calculate Kpi9  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi10'  Run Keyword
        ...  kpi.Calculate Kpi10  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpiswdownload'  Run Keyword
        ...  kpi.Calculate KpiSwDownload  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpiswprovision'  Run Keyword
        ...  kpi.Calculate KpiSwProvision  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi2a'  Run Keyword
        ...  kpi.Calculate Kpi2a  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi12a'  Run Keyword
        ...  kpi.Calculate Kpi12a  ims_file_path=${ims_file_path}  cell_dist_names=${current_cell_dist_names}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi12b'  Run Keyword
        ...  kpi.Calculate Kpi12b  ims_file_path=${ims_file_path}  cell_dist_names=${current_cell_dist_names}


        ${kpi_thresholds_int}=  Convert To Integer  ${kpi_threshold}
        ${kpi_targets} =  Create Dictionary  ${kpi_name}=${kpi_thresholds_int}
        ${kpi_rep}=  Get Library Instance  kpi_report
        ${valid_kpi_rep_list}=  Get Dictionary Keys  ${kpi_rep.ReportOamKpi.KPI_ID_MAPPING}
        Run Keyword If  '${kpi_name.lower()}' in ${valid_kpi_rep_list}
        ...  Report KPI results in REP  ${kpi_name}  ${kpi_info}  ${kpi_targets}
        ...  ELSE  Log  Report ${kpi_name} results in REP will be skipped. Procedure not applicable for ${kpi_name}.  console=True

        Run Keyword If  ${save_kpi_file}  Save KPI results to file  kpi_name=${kpi_name.lower()}  folder_path=${kpi_folder_path}

        ${kpi_delta_list}  ${kpi_start_point_timestamp_list}  ${kpi_end_point_timestamp_list}=  Get KPI info from IMS file  ${kpi_info}
        ...  ${kpi_name.lower()}  ${start_point_timestamp_UTC}  ${end_point_timestamp_UTC}

        Check KPI value from IMS file with KPI threshold  ${kpi_name.lower()}  ${kpi_threshold}  ${kpi_delta_list}
        ...  ${kpi_start_point_timestamp_list}  ${start_point_timestamp_UTC}  ${kpi_end_point_timestamp_list}  ${end_point_timestamp_UTC}

        Set To Dictionary  ${kpi_name_delta_dict}  ${kpi_name.lower()}  ${kpi_delta_list}
    END

    [Return]  ${kpi_name_delta_dict}

    [Teardown]  Run Keyword If  ${ims_file_path_isEmpty} and ${remove_ims_file} and not ${kpi_skip_enabled}  Run Keywords
    ...  Remove File  ${ims_file_path}
    ...  AND  Log  Removed IMS file ${ims_file_path}  level=INFO  console=True

Report KPI results in REP
     [Arguments]  ${kpi_name}  ${kpi_info}  ${kpi_targets}=None

     Log  Report ${kpi_name} results in REP  console=True
     ${status}=  Run Keyword and Return Status  kpi_report.Report OAM KPI  oam_kpi_results=${kpi_info}  oam_kpi_targets=${kpi_targets}
     Run Keyword If  ${status}  Log  ${kpi_name} results were successfully reported in REP  console=True
     ...  ELSE  Log  ${kpi_name} results could not be successfully reported in REP  level=WARN

Save KPI results to file
    [Documentation]
    ...  Save KPI results to file for specific BTS
    ...
    ...  *INPUT*
    ...  | Parameter   | Mandatory | Description                       |
    ...  | kpi_name    | Yes       | KPI name                          |
    ...  | folder_path | Yes       | Folder path for KPI file location |
    ...
    ...  *RETURN*
    ...  | Parameter     | Description             |
    ...  | kpi_file_path | KPI file path full name |
    ...
    [Arguments]  ${kpi_name}  ${folder_path}

    ${folder_status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${folder_path}
    Run Keyword If  not ${folder_status}  Create Directory  ${folder_path}

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${kpi_file_name}=  Set Variable  KPI_${kpi_name}_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.json
    ${kpi_file_path}=  Set Variable  ${folder_path}/${kpi_file_name}
    kpi.Save Results To File  file_path=${kpi_file_path}
    Sleep  3s
    ${file_status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${kpi_file_path}
    Run Keyword If  ${file_status}
    ...  Log  KPI ${kpi_name} file available at ${kpi_file_path}  level=INFO  console=True
    ...  ELSE  Run Keywords
    ...  Log  KPI ${kpi_name} file not available at ${kpi_file_path}  level=ERROR
    ...  AND  Fail  KPI ${kpi_name} file not available at ${kpi_file_path}
    kpi.Clear Results

    [Return]  ${kpi_file_path}

Prepare list info from string info
    [Arguments]  ${string_info}
    ${string_info_strip}=  Replace String  ${string_info}  ${SPACE}  ${EMPTY}
    ${list_info}=  Split String  ${string_info_strip}  ,

    [Return]  ${list_info}

Get KPI info from IMS file
    [Arguments]  ${kpi_info}  ${kpi_name}  ${start_point_timestamp_UTC}  ${end_point_timestamp_UTC}

    ${start_point_timestamp_UTC_epoch}=  Run Keyword If  '${start_point_timestamp_UTC}' != '${EMPTY}'
    ...  Convert Date  ${start_point_timestamp_UTC}  epoch  exclude_millis=True
    ...  ELSE
    ...  Set Variable  0
    ${end_point_timestamp_UTC_epoch}=  Run Keyword If  '${end_point_timestamp_UTC}' != '${EMPTY}'
    ...  Convert Date  ${end_point_timestamp_UTC}  epoch  exclude_millis=True
    ...  ELSE
    ...  Set Variable  0
    ${kpi_delta_list}=  Create List
    ${kpi_start_point_timestamp_list}=  Create List
    ${kpi_end_point_timestamp_list}=  Create List

    ${kpi_data}=  Get From Dictionary  ${kpi_info}  ${kpi_name}

    Log  KPI ${kpi_name} value(s) for specific UTC timestamp interval measurement:  console=True

    FOR  ${item}  IN  @{kpi_data}
      ${kpi_delta}=  Get From Dictionary  ${item}  delta
      ${kpi_start_point_timestamp}=  Get From Dictionary  ${item}  start_point_timestamp
      ${kpi_end_point_timestamp}=  Get From Dictionary  ${item}  end_point_timestamp
      ${kpi_start_point_timestamp_date}=  Convert Date  ${kpi_start_point_timestamp}  date_format=%Y-%m-%d %H:%M:%S  exclude_millis=True
      ${kpi_end_point_timestamp_date}=  Convert Date  ${kpi_end_point_timestamp}  date_format=%Y-%m-%d %H:%M:%S  exclude_millis=True
      ${kpi_start_point_timestamp_date_epoch}=  Convert Date  ${kpi_start_point_timestamp_date}  epoch  exclude_millis=True
      ${kpi_end_point_timestamp_date_epoch}=  Convert Date  ${kpi_end_point_timestamp_date}  epoch  exclude_millis=True

      ${cond1}=  Create Long String  '${start_point_timestamp_UTC}' == '${EMPTY}' and '${end_point_timestamp_UTC}' == '${EMPTY}'
      ${cond2}=  Create Long String  '${start_point_timestamp_UTC}' == '${EMPTY}' and '${end_point_timestamp_UTC}' != '${EMPTY}' and
      ...  ${kpi_end_point_timestamp_date_epoch} <= ${end_point_timestamp_UTC_epoch}
      ${cond3}=  Create Long String  '${start_point_timestamp_UTC}' != '${EMPTY}' and '${end_point_timestamp_UTC}' == '${EMPTY}' and
      ...  ${start_point_timestamp_UTC_epoch} <= ${kpi_start_point_timestamp_date_epoch}
      ${cond4}=  Create Long String  '${kpi_start_point_timestamp_date_epoch}' != '${EMPTY}' and '${end_point_timestamp_UTC}' != '${EMPTY}' and
      ...  ${start_point_timestamp_UTC_epoch} <= ${kpi_start_point_timestamp_date_epoch} and
      ...  ${kpi_end_point_timestamp_date_epoch} <= ${end_point_timestamp_UTC_epoch}

      Run Keyword If  ${cond1} or ${cond2} or ${cond3} or ${cond4}  Run Keywords
      ...  Log Long String  - KPI ${kpi_name} value: ${kpi_delta.total_seconds()} secs for timestamp interval:
      ...  ${kpi_start_point_timestamp_date} - ${kpi_end_point_timestamp_date}  console=True
      ...  AND  Append To List  ${kpi_delta_list}  ${kpi_delta.total_seconds()}
      ...  AND  Append To List  ${kpi_start_point_timestamp_list}  ${kpi_start_point_timestamp_date}
      ...  AND  Append To List  ${kpi_end_point_timestamp_list}  ${kpi_end_point_timestamp_date}
    END

    [Return]  ${kpi_delta_list}  ${kpi_start_point_timestamp_list}  ${kpi_end_point_timestamp_list}

Check KPI value from IMS file with KPI threshold
    [Arguments]  ${kpi_name}  ${kpi_threshold}  ${kpi_delta_list}  ${kpi_start_point_timestamp_list}  ${start_point_timestamp_UTC}
    ...  ${kpi_end_point_timestamp_list}  ${end_point_timestamp_UTC}

    Run Keyword If  '${kpi_threshold}' == '${EMPTY}'  Run Keywords
    ...  Log  Please set a valid value (not empty) for ${kpi_name} threshold  level=ERROR
    ...  AND  Run Keyword And Continue On Failure  Fail  Please set a valid value (not empty) for variable ${kpi_name} threshold
    ...  AND  Return From Keyword

    ${start_point_timestamp_UTC_epoch}=  Run Keyword If  '${start_point_timestamp_UTC}' != '${EMPTY}'
    ...  Convert Date  ${start_point_timestamp_UTC}  epoch  exclude_millis=True
    ...  ELSE
    ...  Set Variable  0
    ${end_point_timestamp_UTC_epoch}=  Run Keyword If  '${end_point_timestamp_UTC}' != '${EMPTY}'
    ...  Convert Date  ${end_point_timestamp_UTC}  epoch  exclude_millis=True
    ...  ELSE
    ...  Set Variable  0

    Log  Check KPI ${kpi_name} value(s) with KPI ${kpi_name} threshold:  console=True

    FOR  ${delta}  ${start_timestamp}  ${end_timestamp}  IN ZIP  ${kpi_delta_list}  ${kpi_start_point_timestamp_list}  ${kpi_end_point_timestamp_list}
        ${start_timestamp_epoch}=  Convert Date  ${start_timestamp}  epoch  exclude_millis=True
        ${end_timestamp_epoch}=  Convert Date  ${end_timestamp}  epoch  exclude_millis=True
        ${cond1}=  Create Long String  '${start_point_timestamp_UTC}' == '${EMPTY}' and '${end_point_timestamp_UTC}' == '${EMPTY}'
        ${cond2}=  Create Long String  '${start_point_timestamp_UTC}' == '${EMPTY}' and '${end_point_timestamp_UTC}' != '${EMPTY}' and
        ...  ${end_timestamp_epoch} <= ${end_point_timestamp_UTC_epoch}
        ${cond3}=  Create Long String  '${start_point_timestamp_UTC}' != '${EMPTY}' and '${end_point_timestamp_UTC}' == '${EMPTY}' and
        ...  ${start_point_timestamp_UTC_epoch} <= ${start_timestamp_epoch}
        ${cond4}=  Create Long String  '${start_point_timestamp_UTC}' != '${EMPTY}' and '${end_point_timestamp_UTC}' != '${EMPTY}' and
        ...  ${start_point_timestamp_UTC_epoch} <= ${start_timestamp_epoch} and ${end_timestamp_epoch} <= ${end_point_timestamp_UTC_epoch}

        ${kpi_verdict}=  Run Keyword If  ${cond1} or ${cond2} or ${cond3} or ${cond4}
        ...  Set Variable If  ${delta} <= ${kpi_threshold}  ${TRUE}  ${FALSE}

        Run Keyword If  ${kpi_verdict}
        ...  Log Long String  - KPI ${kpi_name} value: ${delta} secs in range of KPI ${kpi_name} threshold: ${kpi_threshold} secs for timestamp
        ...  interval: ${start_timestamp} - ${end_timestamp}  console=True
        ...  ELSE  Run Keywords
        ...  Set KPI Check Level Based on Execution Environment  ${kpi_threshold}
        ...  AND  Set Test Variable  ${SnapshotTriggerEndTest}  YES
    END

Get KPI info
    [Documentation]
    ...  Get KPI info. Following KPI names are available:
    ...  - Site Reset: kpi1a, kpi1b, kpi1c, kpi1f, kpi1g
    ...  - Power-On BTS Startup: kpi3; mandatory to set variable ${start_point_timestamp_UTC}
    ...  - RU Reset: kpi51a, kpi51b, kpi51c; recommended to set variables ${triggered_from} and ${ims_from}
    ...  - Power-On RU Startup: kpi54a, kpi54b; mandatory to set variable ${start_point_timestamp_UTC}
    ...  - SW rollback: kpi13
    ...  - RAT Reset: kpi7(LTE), kpi8(WCDMA), kpi9(GSM), kpi10(NR)
    ...  - SW download: kpiswdownload;
    ...  - SW provision: kpiswprovision;
    ...  - SW activation: kpi2a
    ...  Variable ${start_point_timestamp_UTC} is set as returned value from KW Get Current Date UTC info (need to be run apriori to set power ON
    ...  start action)
    ...
    ...  *INPUT*
    ...  | Parameter                 | Mandatory | Description                                                                             |
    ...  | kpi_names                 | Yes       | KPI names: list of kpi names separated by comma (ex. kpi1a, kpi1b, kpi1c, kpi1f, kpi1g) |
    ...  | kpi_folder_path           | No        | KPI folder path location                                                                |
    ...  | ims_file_path             | No        | IMS file path location                                                                  |
    ...  | timeout                   | No        | Time to wait for positive procedure result                                              |
    ...  | alias                     | No        | Alias of admin instance                                                                 |
    ...  | save_kpi_file             | No        | Save KPI info in kpi file after parsing KPI info                                        |
    ...  | remove_ims_file           | No        | Possible values:                                                                        |
    ...                                            TRUE - Remove ims file after parsing KPI info                                           |
    ...                                            FALSE - Keep ims file after parsing KPI info (default value)                            |
    ...  | start_point_timestamp_UTC | No        | Start point timestamp UTC format                                                        |
    ...  | end_point_timestamp_UTC   | No        | End point timestamp UTC format                                                          |
    ...  | triggered_from            | No        | Useful only for kpi51a, kpi51b, kpi51c; specifies the BTS where the reset RM is
    ...                                            triggered from. Possible values: primary or secondary                                   |
    ...  | ims_from                  | No        | Useful only for kpi51a, kpi51b, kpi51c; specifies the BTS where the ims trace is
    ...                                            collected for KPI measurement. Possible values: primary or secondary                    |
    ...
    [Arguments]  ${kpi_names}  ${kpi_folder_path}=${EMPTY}  ${ims_file_path}=${EMPTY}  ${timeout}=180  ${alias}=default
    ...  ${save_kpi_file}=${TRUE}  ${remove_ims_file}=${FALSE}  ${start_point_timestamp_UTC}=${EMPTY}  ${end_point_timestamp_UTC}=${EMPTY}
    ...  ${triggered_from}=${EMPTY}  ${ims_from}=${EMPTY}

    ${kpi_name_list}=  Prepare list info from string info  ${kpi_names}
    ${kpi_folder_path}=  Run Keyword If  '${kpi_folder_path}' == '${EMPTY}'
    ...  Set Variable  ${Test Results Dir}/KPI/${alias}
    ...  ELSE
    ...  Set Variable  ${kpi_folder_path}

    ${ims_file_path_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${ims_file_path}

    ${kpi_skip_enabled}=  Check If KPI Check Skip Enabled
    ${kpi_mock_obj}=  Run Keyword If  ${kpi_skip_enabled}  tools.Create Mock Object
    Return From Keyword If  ${kpi_mock_obj}  ${kpi_mock_obj}

    ${ims_file_path}=  Run Keyword If  ${ims_file_path_isEmpty}
    ...  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}  timeout=${timeout}
    ...  ELSE
    ...  Set Variable  ${ims_file_path}

    kpi.Clear Results

    ${start_point_timestamp_UTC_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${start_point_timestamp_UTC}
    Run Keyword If  '${start_point_timestamp_UTC_isEmpty}' == 'False'  Save Search Start Timestamp  ${start_point_timestamp_UTC}
    ${end_point_timestamp_UTC_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${end_point_timestamp_UTC}
    Run Keyword If  '${end_point_timestamp_UTC_isEmpty}' == 'False'  Save Search End Timestamp  ${end_point_timestamp_UTC}

    ${kpi_name_delta_dict} =  Create Dictionary

    FOR  ${kpi_name}  IN  @{kpi_name_list}
        Run Keyword If  '${kpi_name.lower()}' not in ${kpi_valid_name_list}  Run Keywords
        ...  Log  KPI ${kpi_name.lower()} not yet implemented in current KW  level=ERROR
        ...  AND  Run Keyword And Continue On Failure  Fail  KPI ${kpi_name.lower()} not yet implemented in current KW
        ...  AND  Continue For Loop

        ${kpi_start_end_info}=  Set Variable If
        ...  '${kpi_name.lower()}' == 'kpi1a'  first cell down to last cell up
        ...  '${kpi_name.lower()}' == 'kpi1b'  last cell down to first cell up
        ...  '${kpi_name.lower()}' == 'kpi1c'  reset request to first cell up
        ...  '${kpi_name.lower()}' == 'kpi1f'  first cell down to last cell up - reset without RU reset
        ...  '${kpi_name.lower()}' == 'kpi1g'  last cell down to first cell up - reset without RU reset
        ...  '${kpi_name.lower()}' == 'kpi3'  power on BTS to first cell up
        ...  '${kpi_name.lower()}' == 'kpi51a'  first cell down to last cell up
        ...  '${kpi_name.lower()}' == 'kpi51b'  last cell down to first cell up
        ...  '${kpi_name.lower()}' == 'kpi51c'  first cell degraded to last cell up
        ...  '${kpi_name.lower()}' == 'kpi54a'  power on RU to last cell up
        ...  '${kpi_name.lower()}' == 'kpi54b'  power on RU to first cell up
        ...  '${kpi_name.lower()}' == 'kpi13'  first cell down to last cell up
        ...  '${kpi_name.lower()}' == 'kpi7'  first LTE cell down to last LTE cell up
        ...  '${kpi_name.lower()}' == 'kpi8'  first WCDMA cell down to last WCDMA cell up
        ...  '${kpi_name.lower()}' == 'kpi9'  first GSM cell down to last GSM cell up
        ...  '${kpi_name.lower()}' == 'kpi10'  first NR cell down to last NR cell up
        ...  '${kpi_name.lower()}' == 'kpiswdownload'  SW download start to SW download end
        ...  '${kpi_name.lower()}' == 'kpiswprovision'  SW download start to last cell up
        ...  '${kpi_name.lower()}' == 'kpi2a'  first cell down to last cell up

        Log  ***** Get KPI ${kpi_name} (${kpi_start_end_info}) info from IMS file *****  console=True

        ${kpi_info}=  Run Keyword If  '${kpi_name.lower()}' == 'kpi1a'
        ...  kpi.Calculate Kpi1a  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi1b'  Run Keyword
        ...  kpi.Calculate Kpi1b  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi1c'  Run Keyword
        ...  kpi.Calculate Kpi1c  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi1f'  Run Keyword
        ...  kpi.Calculate Kpi1f  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi1g'  Run Keyword
        ...  kpi.Calculate kpi1g  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi3'  Run Keyword
        ...  kpi.Calculate Kpi3  ims_file_path=${ims_file_path}  start_point_timestamp=${start_point_timestamp_UTC}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi51a'  Run Keyword
        ...  kpi.Calculate Kpi51a  ims_file_path=${ims_file_path}  triggered_from=${triggered_from}  ims_from=${ims_from}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi51b'  Run Keyword
        ...  kpi.Calculate Kpi51b  ims_file_path=${ims_file_path}  triggered_from=${triggered_from}  ims_from=${ims_from}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi51c'  Run Keyword
        ...  kpi.Calculate Kpi51c  ims_file_path=${ims_file_path}  triggered_from=${triggered_from}  ims_from=${ims_from}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi53a'  Run Keyword
        ...  kpi.Calculate Kpi53a  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi53b'  Run Keyword
        ...  kpi.Calculate Kpi53b  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi54a'  Run Keyword
        ...  kpi.Calculate Kpi54a  ims_file_path=${ims_file_path}  start_point_timestamp=${start_point_timestamp_UTC}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi54b'  Run Keyword
        ...  kpi.Calculate Kpi54b  ims_file_path=${ims_file_path}  start_point_timestamp=${start_point_timestamp_UTC}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi13'  Run Keyword
        ...  kpi.Calculate Kpi13  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi7'  Run Keyword
        ...  kpi.Calculate Kpi7  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi8'  Run Keyword
        ...  kpi.Calculate Kpi8  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi9'  Run Keyword
        ...  kpi.Calculate Kpi9  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi10'  Run Keyword
        ...  kpi.Calculate Kpi10  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpiswdownload'  Run Keyword
        ...  kpi.Calculate KpiSwDownload  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpiswprovision'  Run Keyword
        ...  kpi.Calculate KpiSwProvision  ims_file_path=${ims_file_path}
        ...  ELSE IF  '${kpi_name.lower()}' == 'kpi2a'  Run Keyword
        ...  kpi.Calculate Kpi2a  ims_file_path=${ims_file_path}

        ${kpi_rep}=  Get Library Instance  kpi_report
        ${valid_kpi_rep_list}=  Get Dictionary Keys  ${kpi_rep.ReportOamKpi.KPI_ID_MAPPING}
        Run Keyword If  '${kpi_name.lower()}' in ${valid_kpi_rep_list}
        ...  Report KPI results in REP  ${kpi_name}  ${kpi_info}
        ...  ELSE  Log  Report ${kpi_name} results in REP will be skipped. Procedure not applicable for ${kpi_name}.  console=True

        Run Keyword If  ${save_kpi_file}  Save KPI results to file  kpi_name=${kpi_name.lower()}  folder_path=${kpi_folder_path}

        ${kpi_delta_list}  ${kpi_start_point_timestamp_list}  ${kpi_end_point_timestamp_list}=  Get KPI info from IMS file  ${kpi_info}
        ...  ${kpi_name.lower()}  ${start_point_timestamp_UTC}  ${end_point_timestamp_UTC}

        Set To Dictionary  ${kpi_name_delta_dict}  ${kpi_name.lower()}  ${kpi_delta_list}
    END

    [Return]  ${kpi_name_delta_dict}

    [Teardown]  Run Keyword If  ${ims_file_path_isEmpty} and ${remove_ims_file} and not ${kpi_skip_enabled}  Run Keywords
    ...  Remove File  ${ims_file_path}
    ...  AND  Log  Removed IMS file ${ims_file_path}  level=INFO  console=True

Check If KPI Check Skip Enabled
    ${status}=  Run Keyword And Return Status  Variable Should Exist  ${SKIP_KPI_CALCULATION}
    Run Keyword If  not ${status}  Return From Keyword  ${False}
    Run Keyword If  ${SKIP_KPI_CALCULATION}  Run Keywords
    ...  Log  KPI Calculation is skipped because SKIP_KPI_CALCULATION=TRUE  level=WARN
    ...  AND  Return From Keyword  ${True}

Eval IMS2 Alarms SOAM
    [Documentation]
    ...  Keyword that checks list of ${expected_alarms} in ims2 trace starting with
    ...  ${start_timestamp} in UTC format.
    ...  Keyword will pass if each - distinct - expected alarm is found in ims2trace once
    ...  Management of duplicates is not done - if expected_alarms contains duplicates, it is
    ...  not insured that each of the alarms occurs at least once.
    ...
    ...  *INPUT*
    ...  | Parameter                 | Mandatory | Description                                                                             |
    ...  | alias                     | No        | Alias of admin instance                                                                 |
    ...  | start_timestamp           | No        | timestamp from which alarm search in ims2 begins                                        |
    ...  | expected_alarms           | Yes       | List of expected alarms. If not given, keyword will exit
    ...  |                           |           | with PASSED result

    [Arguments]  ${alias}=default  ${start_timestamp}=${None}  ${expected_alarms}=@{Empty}  ${ignored_alarms}=@{Empty}  ${critical_alarms}=@{Empty}
    ...  ${ims_file_path}=${Empty}
    ...  ${only_expected_alarms_which_are_not_cleared}=${False}
    ...  ${only_unexpected_alarms_visible_in_webem}=${True}  ${only_unexpected_alarms_which_are_not_cleared}=${False}
    ...  ${only_unexpected_alarms_of_same_id_and_number_with_expected_alarms}=${True}
    ...  ${skip_check_if_empty_expected_alarms}=${True}

    Set Test Variable  @{not_found_expected_ims2_alarms}  @{Empty}
    Set Test Variable  @{found_expected_ims2_alarms}  @{Empty}

    Return From Keyword If  ${expected_alarms} == @{Empty} and ${skip_check_if_empty_expected_alarms}

    ${ims_file_path}=  Run Keyword If  not '${ims_file_path}'
    ...  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}
    ...  ELSE  Set Variable  ${ims_file_path}
    ${active_alarms}=  ims2alarms.Get Alarms In Interval
    ...  file_path=${ims_file_path}  begin=${start_timestamp}
    ${active_alarms}=  Remove all alarm duplicates  ${active_alarms}  ${KEYS_FOR_REMOVE_DUPLICATE_ALARM_IMS}

    ${found_expected_ims2_alarms}  ${not_found_expected_ims2_alarms}
    ...  ${found_critical_ims2_alarms}  ${found_ignored_ims2_alarms}
    ...  ${found_unexpected_ims2_alarms}=
    ...  alarms_analysis.Get Filtered Alarms  ${active_alarms}  ${expected_alarms}  ${ignored_alarms}  ${critical_alarms}  ${SIMPLIFIED_ALARM_IMS}

    ${delta_expected_alarms}=  Run Keyword If  ${only_expected_alarms_which_are_not_cleared}
    ...  Evaluate  [alrm for alrm in ${found_expected_ims2_alarms} if not alrm.cleared]
    ...  ELSE  Create List
    Remove Values From List  ${found_expected_ims2_alarms}  @{delta_expected_alarms}
    Append To List  ${not_found_expected_ims2_alarms}  @{delta_expected_alarms}

    ${visible_in_webem_list}=  Run Keyword If  ${only_unexpected_alarms_visible_in_webem}
    ...  Create List  ${True}
    ...  ELSE  Create List  ${True}  ${False}
    ${cleared_condition_values}=  Run Keyword If  ${only_unexpected_alarms_which_are_not_cleared}
    ...  Create List  ${False}
    ...  ELSE  Create List  ${True}  ${False}
    ${condition_unexpected_visible_in_webem}=  Create Long String
    ...  [alrm for alrm in ${found_unexpected_ims2_alarms} if alrm["visibleForEM"] in ${visible_in_webem_list}
    ...  and alrm["cleared"] in ${cleared_condition_values}]
    ${found_unexpected_ims2_alarms}=  Evaluate  ${condition_unexpected_visible_in_webem}

    ${unexpected_alarm_list_present_in_expected}=  Intersect Alarm Lists
    ...  ${found_unexpected_ims2_alarms}  ${found_expected_ims2_alarms}
    ${found_unexpected_ims2_alarms}=  Set Variable If  ${only_unexpected_alarms_of_same_id_and_number_with_expected_alarms}
    ...  ${unexpected_alarm_list_present_in_expected}  ${found_unexpected_ims2_alarms}

    [Return]  ${not_found_expected_ims2_alarms}  ${found_expected_ims2_alarms}
    ...  ${found_unexpected_ims2_alarms}
    ...  ${found_critical_ims2_alarms}
    ...  ${found_ignored_ims2_alarms}

Intersect alarm lists
    [Arguments]    ${list1}  ${list2}

    ${SIMPLIFIED_ALARM}=  Create Dictionary  alarmId=${NONE}  faultId=${NONE}  alarmName=${NONE}

    ${list2_copy}=  Copy List  ${list2}  deepcopy=${True}

    ${result}=  Create List
    FOR  ${alrm1}  IN  @{list1}
        FOR  ${alrm2}  IN  @{list2_copy}
            ${res}=  Compare alarms ims  ${alrm1}  ${alrm2}  SIMPLIFIED_ALARM=${SIMPLIFIED_ALARM}
            IF  ${res}
            ...  Append To List  ${result}  ${alrm1}
            IF  ${res}  BREAK
        END
    END

    [Return]  ${result}

Compare alarms ims
    [Arguments]    ${alarm_1}  ${alarm_2}  ${SIMPLIFIED_ALARM}=${SIMPLIFIED_ALARM_IMS}

    ${are_same}=  Set Variable  ${False}
    ${alarm_keys}=  Get Dictionary Keys  ${SIMPLIFIED_ALARM}

    FOR  ${key}  IN  @{alarm_keys}
        ${are_same}=  Set Variable If  "${alarm_1['${key}']}"=="${alarm_2['${key}']}"  ${True}  ${are_same}
        Exit For Loop If  not ${are_same}
    END
    [Return]    ${are_same}

Get And Check Detailed IMS2 Alarms SOAM
    [Documentation]
    ...  Keyword that checks list of ${expected_alarms} in ims2 trace starting with
    ...  ${start_timestamp} in UTC format.
    ...  Keyword will pass if each expected alarm is found in ims2trace once
    ...  Management of duplicates is done - if expected_alarms contains duplicates, it is
    ...  insured that each of the alarms occurs exactly once.
    ...
    ...  *INPUT*
    ...  | Parameter                | Mandatory | Description                                                                                       |
    ...  | alias                    | No        | Alias of admin instance                                                                           |
    ...  | start_timestamp          | No        | timestamp from which alarm search in ims2 begins                                                  |
    ...  | expected_alarms          | Yes       | List of expected alarms. If not given, keyword will exit with PASSED result. Example:             |
    ...  |                                        expected_alarms = [{'alarmId': '7116','faultId': '10'}]                                           |
    ...  | bts_additional_alarm_info | No        | List of expected alarms with its corresponding object dn (affected_resources_dn). Expected alarms |
    ...  |                                        will be checked on desired object dn. If not given, expected_alarms will be used. Example:        |
    ...  |                                        bts_additional_alarm_info =                                                                        |
    ...  |                                        [{'affected_resources_dn': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1',  |
    ...  |                                          'alarmId': '7116',                                                                              |
    ...  |                                          'faultId': '10'}]
    ...  |                                       | List of expected alarms with its corresponding sn (sn_attribute). Expected alarms |
    ...  |                                        will be checked on desired object sn. If not given, expected_alarms will be used. Example:        |
    ...  |                                        bts_additional_alarm_info =                                                                        |
    ...  |                                        [{'sn_attribute: 'KLM103427',
    ...  |                                          'alarmId': '7116',                                                                              |
    ...  |                                          'faultId': '10'}]                                                                              |

    [Arguments]  ${alias}=default  ${start_timestamp}=${None}  ${expected_alarms}=@{Empty}  ${ignored_alarms}=@{Empty}  ${critical_alarms}=@{Empty}
    ...  ${bts_additional_alarm_info}=@{Empty}  ${ims_file_path}=${Empty}
    ...  ${only_expected_alarms_which_are_not_cleared}=${False}
    ...  ${only_unexpected_alarms_visible_in_webem}=${True}  ${only_unexpected_alarms_which_are_not_cleared}=${False}
    ...  ${only_unexpected_alarms_of_same_id_and_number_with_expected_alarms}=${True}
    ...  ${skip_check_if_empty_expected_alarms}=${True}
    ...  ${fail_if_unexpected_alarms}=${True}

    ${not_found_expected_ims2_alarms}  ${found_expected_ims2_alarms}
    ...  ${found_unexpected_ims2_alarms}
    ...  ${found_critical_ims2_alarms}
    ...  ${found_ignored_ims2_alarms}  Eval IMS2 Alarms SOAM  alias=${alias}  start_timestamp=${start_timestamp}
    ...  ignored_alarms=${ignored_alarms}  critical_alarms=${critical_alarms}
    ...  expected_alarms=${expected_alarms}  ims_file_path=${ims_file_path}
    ...  only_expected_alarms_which_are_not_cleared=${only_expected_alarms_which_are_not_cleared}
    ...  only_unexpected_alarms_visible_in_webem=${only_unexpected_alarms_visible_in_webem}
    ...  only_unexpected_alarms_which_are_not_cleared=${only_unexpected_alarms_which_are_not_cleared}
    ...  only_unexpected_alarms_of_same_id_and_number_with_expected_alarms=${only_unexpected_alarms_of_same_id_and_number_with_expected_alarms}
    ...  skip_check_if_empty_expected_alarms=${skip_check_if_empty_expected_alarms}

    ${expected_alarms}=  Set Variable If  ${bts_additional_alarm_info} == @{Empty}  ${expected_alarms}  ${bts_additional_alarm_info}

    Set Test Variable  ${not_found_expected_ims2_alarms}
    Set Test Variable  ${found_unexpected_ims2_alarms}
    Set Test Variable  ${found_critical_ims2_alarms}

    Run Keyword If  ${found_critical_ims2_alarms}  Run Keywords
    ...  Log  Critical alarms were found:  level=ERROR
    ...  AND  alarms_analysis.Print Alarms  critical_alarms_patterns=${found_critical_ims2_alarms}  simplified_dictionary=${SIMPLIFIED_ALARM_IMS}
    ...  AND  Run Keyword And Continue On Failure  Fail  Critical alarms were found: ${found_critical_ims2_alarms}

    Run Keyword If  ${not_found_expected_ims2_alarms}  Run Keywords
    ...  Log  Some expected alarms were not found:  level=ERROR
    ...  AND  alarms_analysis.Print Alarms  missing_alarms_patterns=${not_found_expected_ims2_alarms}  simplified_dictionary=${SIMPLIFIED_ALARM_IMS}
    ...  AND  Run Keyword And Continue On Failure  Fail  Some expected alarms were not found: ${not_found_expected_ims2_alarms}

    Run Keyword If  ${found_unexpected_ims2_alarms}  Run Keywords
    ...  Log  All expected alarms have been found, but also unexpected alarms have been found  level=WARN
    ...  AND  alarms_analysis.Print Alarms  warnings=${found_unexpected_ims2_alarms}  simplified_dictionary=${SIMPLIFIED_ALARM_IMS}
    ...  AND  Set Test Variable  ${SnapshotTriggerEndTest}  YES
    ...  AND  Run Keyword If  ${fail_if_unexpected_alarms}
    ...  Run Keyword And Continue On Failure  Fail  Unexpected alarms have been found in IMS2 trace!
    ...  ELSE
    ...  Log  All expected alarms have been found  console=True

Check object status change for desired parameter value
    [Documentation]
    ...  Keyword that checks status change for indicated object, with indicated parameter value
    ...  in ims2 trace starting with  ${start_timestamp} in UTC format.
    ...  Keyword will pass if the indicated status change with indicated parameter value is found in ims2trace
    ...
    ...  *INPUT*
    ...  | Parameter                | Mandatory | Description                                                                                       |
    ...  | alias                    | No        | Alias of admin instance                                                                           |
    ...  | object_dn                | Yes       | DN or DN part of the object that changes its status                                               |
    ...  | start_timestamp          | No        | timestamp from which alarm search in ims2 begins. If not indicated, the search is done over the   |
    ...  |                          |           | whole trace file                                                                                  |
    ...  | parameter_name           | Yes       | Name of parameter who'se value is searched for inside the object status change                    |
    ...  | parameter_value          | Yes       | Value of above indicated parameter, which is verified inside the status change                    |
    ...  | object_exact_match       | No        | Flag indicating whether the object DN of the status change is part of the object DN or is         |
    ...  |                          |           | a complete object DN                                                                              |


    [Arguments]  ${alias}=default  ${ims_file_path}=${Empty}  ${object_dn}=${Empty}  ${start_timestamp}=${Empty}
    ...  ${parameter_name}=${Empty}  ${parameter_value}=${Empty}  ${obj_exact_match}=${False}

    Return From Keyword If  '${object_dn} '=='${Empty} ' or '${parameter_name} '=='${Empty} ' or '${parameter_value} '=='${Empty} '
    ${parameter_value_found}=  Set Variable  ${False}

    ${ims_file_path}=  Run Keyword If  '${ims_file_path} '==' '
    ...  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}
    ...  ELSE  Set Variable  ${ims_file_path}

    ${parameter_value_found}=  ims2alarms.Check Object Status Change To Desired Value
    ...  file_path=${ims_file_path}  obj_dist_name=${object_dn}  parameter_name=${parameter_name}
    ...  parameter_value=${parameter_value}  begin=${start_timestamp}  obj_exact_match=${obj_exact_match}

    [Return]  ${parameter_value_found}

Search IMS2 alarms in list
    [Arguments]  ${alarm_to_search}=&{Empty}  ${alarm_list}=@{Empty}

    ${found_alarm}=  Set Variable  ${False}
    ${index}=  Set Variable  0
    FOR  ${index}  ${item}  IN ENUMERATE  @{alarm_list}
        ${found_alarm}=  Match expected alarm to alarm from BTS  ${alarm_to_search}  ${item}
        Exit For Loop If    ${found_alarm}
    END

    ${index}=  Set Variable If  not ${found_alarm}  -1  ${index}

    [Return]  ${index}

Search IMS2 rd fault in list
    [Arguments]  ${rd_fault_to_search}=&{Empty}  ${rd_fault_list}=@{Empty}

    ${found_rd_fault}=  Set Variable  ${False}
    ${index}=  Set Variable  0
    FOR  ${index}  ${item}  IN ENUMERATE  @{rd_fault_list}
        ${found_rd_fault}=  Match expected rd fault to rd fault from BTS  ${rd_fault_to_search}  ${item}
        Exit For Loop If    ${found_rd_fault}
    END

    ${index}=  Set Variable If  not ${found_rd_fault}  -1  ${index}

    [Return]  ${index}

Match expected alarm to alarm from BTS
    [Arguments]  ${alarm1}=&{Empty}  ${alarm2}=&{Empty}

    ${are_equal}=  Set Variable  ${True}
    ${alarm1_keys}=  Get Dictionary Keys  ${alarm1}

    FOR  ${key}  IN  @{alarm1_keys}
        ${key_is_present}=  Run Keyword And Return Status
        ...  Dictionary Should Contain Key  ${TRANSLATED_ALARM_IMS}  ${key}
        Continue For Loop If  not ${key_is_present}

        ${key_is_present}=  Run Keyword And Return Status
        ...  Dictionary Should Contain Key  ${alarm2}  ${TRANSLATED_ALARM_IMS['${key}']}
        Run Keyword If  not ${key_is_present}
        ...  Run Keywords
        ...  Log  Alarm in BTS key ${TRANSLATED_ALARM_IMS['${key}']} does not match TRANSLATED_ALARM_IMS dictionary  console=True
        ...  AND  Return From Keyword  ${False}

        ${alarm1_value}=  Get From Dictionary  ${alarm1}  ${key}
        ${alarm2_value}=  Get From Dictionary  ${alarm2}  ${TRANSLATED_ALARM_IMS['${key}']}

        ${are_equal}=  Set Variable If  '${alarm1_value}' != '${alarm2_value}'
        ...  ${False}  ${are_equal}

        Exit For Loop If  not ${are_equal}
    END

    [Return]  ${are_equal}

Match expected rd fault to rd fault from BTS
    [Arguments]  ${rd_fault_1}=&{Empty}  ${rd_fault_2}=&{Empty}

    ${are_equal}=  Set Variable  ${True}
    ${rd_fault_1_keys}=  Get Dictionary Keys  ${rd_fault_1}

    FOR  ${key}  IN  @{rd_fault_1_keys}
        ${key_is_present}=  Run Keyword And Return Status
        ...  Dictionary Should Contain Key  ${TRANSLATED_RD_FAULT_IMS}  ${key}
        Continue For Loop If  not ${key_is_present}
        ${key_is_present}=  Run Keyword And Return Status
        ...  Dictionary Should Contain Key  ${rd_fault_2}  ${TRANSLATED_RD_FAULT_IMS['${key}']}
        Run Keyword If  not ${key_is_present}
        ...  Run Keywords
        ...  Log  Alarm in BTS key ${TRANSLATED_RD_FAULT_IMS['${key}']} does not match TRANSLATED_RD_FAULT_IMS dictionary  console=True
        ...  AND  Return From Keyword  ${False}

        ${are_equal}=  Set Variable If  '${rd_fault_1['${key}']}' != '${rd_fault_2['${TRANSLATED_RD_FAULT_IMS['${key}']}']}'
        ...  ${False}  ${are_equal}
        Exit For Loop If    not ${are_equal}
    END

    [Return]  ${are_equal}

Get and check detailed RD Fault from IMS
    [Documentation]
    ...  Keyword that checks ${expected_rd_fault} is present in ims2 trace starting with
    ...  ${start_timestamp} in UTC format.
    ...  Keyword will pass if each expected rd fault is found in ims2trace once
    ...  Management of duplicates is done - if rd fault duplicates exist, it is
    ...  insured that each of the rd fault occurs exactly once.
    ...
    ...  *INPUT*
    ...  | Parameter                 | Mandatory | Description                                                                             |
    ...  | alias                     | No        | Alias of admin instance                                                                 |
    ...  | start_timestamp           | No        | timestamp from which alarm search in ims2 begins                                        |
    ...  | expected_rd_faults        | No        | Expected RD faults to be checked                                                        |

    [Arguments]  ${alias}=default  ${start_timestamp}=${None}  ${expected_rd_faults}=@{EMPTY}

    Log    Checking ${alias} IMS for the presence of RD fault(s): ${expected_rd_faults}    console=True

    ${expected_rd_faults_unique_values}=  Remove Duplicates  ${expected_rd_faults}
    ${ims_file_path}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${alias}  alias=${alias}
    ${obj_updates}=    ims2alarms.Get Object Updates In Interval  file_path=${ims_file_path}  obj_dist_name=FAULT_NOTIF-  begin=${start_timestamp}
    ...  obj_exact_match=${False}
    ${obj_updates}=  Remove Duplicates  ${obj_updates}
    ${rd_faults_found}=  Create List
    ${rd_faults_not_found}=  Create List
    Set Test Variable  ${rd_faults_found}
    Set Test Variable  ${rd_faults_not_found}

    FOR  ${expected_rd_fault}    IN    @{expected_rd_faults}
        ${item_location}=  Search IMS2 rd fault in list  rd_fault_to_search=${expected_rd_fault}  rd_fault_list=${obj_updates}
        Run Keyword If  ${item_location}!=-1  Run Keywords
        ...  Remove from list  ${obj_updates}  ${item_location}
        ...  AND  Append to list  ${rd_faults_found}  ${expected_rd_fault}
        ...  ELSE
        ...  Append to list  ${rd_faults_not_found}  ${expected_rd_fault}
    END

    Log  RD faults found: ${rd_faults_found}  console=True
    Log  RD faults not found: ${rd_faults_not_found}  console=True
    Set Test Variable  ${fail_flag}  False

    FOR  ${expected_rd_fault}    IN    @{expected_rd_faults_unique_values}
        Run Keyword If  ${expected_rd_fault} in ${rd_faults_not_found}
        ...  Run Keywords
        ...  Log  RD Fault ${expected_rd_fault} not found. KW will fail!  console=True
        ...  AND  Set Test Variable  ${fail_flag}  True
        ...  AND  Continue For Loop
        ${item_location}=  Search IMS2 rd fault in list  rd_fault_to_search=${expected_rd_fault}  rd_fault_list=${obj_updates}
        Run Keyword If  ${item_location}!=-1  Run Keywords
        ...  Log  RD Fault ${expected_rd_fault} found more times than expected! Snapshot collection will be triggered at the end of the test!
        ...  level=WARN
        ...  AND  Set Test Variable  ${SnapshotTriggerEndTest}  YES
        ...  AND  Continue For Loop
    END

    Run Keyword If  '${fail_flag}'=='True'  Fail  RD Fault check from ${alias} IMS failed!
    Log  RD Fault check from ${alias} IMS successful!  console=True

Check object parameters values are not changed from IMS file
    [Documentation]
    ...  Check the object parameters values are not changed during specified timestamp interval based on recorded info from IMS file
    ...
    ...  *INPUT*
    ...  | Parameter                 | Mandatory | Description                                                                                |
    ...  | ims_file_path             | Yes       | IMS file path location                                                                     |
    ...  | obj_dist_name             | Yes       | Distinguished name of the object to be checked                                             |
    ...  | obj_parameter_dict        | Yes       | The object attributes that will be checked for change; dict containing structure:
    ...                                            {'<parameter_name>': '<parameter_value>'}                                                  |
    ...  | start_point_timestamp_UTC | Yes       | Start point timestamp UTC format                                                           |
    ...  | end_point_timestamp_UTC   | Yes       | End point timestamp UTC format                                                             |
    ...  | obj_exact_match           | No        | To check for exact match of obj_dist_name (${TRUE}) or part (${FALSE}). By default ${TRUE} |
    ...  | allow_no_updates          | No        | Allow no updates in IMS trace. Possible values: ${TRUE} or ${FALSE}. By default ${FALSE}   |
    ...
    ...  KW is passed if no change for requested object parameters is found in IMS file during specified timestamp interval, otherwise it fails
    ...
    [Arguments]  ${ims_file_path}  ${obj_dist_name}  ${obj_parameter_dict}  ${start_point_timestamp_UTC}  ${end_point_timestamp_UTC}
    ...  ${obj_exact_match}=${TRUE}  ${allow_no_updates}=${FALSE}  ${regex_parameter_value_search}=${False}

    ${obj_parameter_name_list}=  Get Dictionary Keys  ${obj_parameter_dict}  False

    FOR  ${obj_parameter_name}  IN  @{obj_parameter_name_list}

        ${obj_parameter_value}=  Get From Dictionary  ${obj_parameter_dict}  ${obj_parameter_name}
        Check object parameter value is not changed from IMS file  ${ims_file_path}  ${obj_dist_name}  ${obj_parameter_name}  ${obj_parameter_value}
        ...  ${start_point_timestamp_UTC}  ${end_point_timestamp_UTC}  ${obj_exact_match}  ${allow_no_updates}  ${regex_parameter_value_search}

    END

Check object parameter value is not changed from IMS file
    [Documentation]
    ...  Check the object parameter value is not changed during specified timestamp interval based on recorded info from IMS file
    ...
    ...  *INPUT*
    ...  | Parameter                 | Mandatory | Description                                                                                |
    ...  | ims_file_path             | Yes       | IMS file path location                                                                     |
    ...  | obj_dist_name             | Yes       | Distinguished name of the object to be checked                                             |
    ...  | obj_parameter_name        | Yes       | The object parameter name that will be checked for change                                  |
    ...  | obj_parameter_value       | Yes       | The object parameter value that will be checked for change                                 |
    ...  | start_point_timestamp_UTC | Yes       | Start point timestamp UTC format                                                           |
    ...  | end_point_timestamp_UTC   | Yes       | End point timestamp UTC format                                                             |
    ...  | obj_exact_match           | No        | To check for exact match of obj_dist_name (${TRUE}) or part (${FALSE}). By default ${TRUE} |
    ...  | allow_no_updates          | No        | Allow no updates in IMS trace. Possible values: ${TRUE} or ${FALSE}. By default ${FALSE}   |
    ...
    ...  KW is passed if no change for requested object parameter is found in IMS file during specified timestamp interval, otherwise it fails
    ...
    [Arguments]  ${ims_file_path}  ${obj_dist_name}  ${obj_parameter_name}  ${obj_parameter_value}  ${start_point_timestamp_UTC}
    ...  ${end_point_timestamp_UTC}  ${obj_exact_match}=${TRUE}  ${allow_no_updates}=${FALSE}  ${regex_parameter_value_search}=${False}

    ${obj_updates}=  ims2alarms.Get Object Updates In Interval  file_path=${ims_file_path}  obj_dist_name=${obj_dist_name}
    ...  begin=${start_point_timestamp_UTC}  end=${end_point_timestamp_UTC}  obj_exact_match=${obj_exact_match}

    ${obj_parameter_name_check}=  Set Variable  ${FALSE}

    FOR  ${item}  IN  @{obj_updates}

        ${obj_parameter_name_found}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${item}  ${obj_parameter_name}

        ${obj_parameter_name_check}=  Set Variable If  ${obj_parameter_name_found}  ${TRUE}  ${obj_parameter_name_check}

        ${obj_parameter_value_regex}=  Get Regexp Matches  ${obj_parameter_value}  regex"(.*)"  1
        ${obj_parameter_value_regex}=  Set Variable If  ${obj_parameter_value_regex}  ${obj_parameter_value_regex}[${0}]  ${obj_parameter_value}

        ${condition_string}=  Run Keyword If  ${regex_parameter_value_search}
        ...  Evaluate  re.match(r"${obj_parameter_value_regex}", "${item["${obj_parameter_name}"]}") is None  modules=re
        ...  ELSE  Evaluate  '${item['${obj_parameter_name}']}' != '${obj_parameter_value}'

        Run Keyword If  ${obj_parameter_name_found} and ${condition_string}  Run Keywords
        ...  Log  ${obj_dist_name} ${obj_parameter_name} change in IMS file: ${ims_file_path}  level=ERROR
        ...  AND  Fail  ${obj_dist_name} ${obj_parameter_name} change in IMS file: ${ims_file_path}

    END

    Run Keyword If  not ${obj_parameter_name_check} and '${allow_no_updates}' == 'True'
    ...  Log Long String  No updates were found in IMS file: ${ims_file_path} during interval ${start_point_timestamp_UTC} -
    ...  ${end_point_timestamp_UTC}  console=True
    ...  ELSE IF  not ${obj_parameter_name_check}  Run Keywords
    ...  Log  No info related to ${obj_dist_name} ${obj_parameter_name} found in IMS file: ${ims_file_path}  level=ERROR
    ...  AND  Fail  No info related to ${obj_dist_name} ${obj_parameter_name} found in IMS file: ${ims_file_path}
