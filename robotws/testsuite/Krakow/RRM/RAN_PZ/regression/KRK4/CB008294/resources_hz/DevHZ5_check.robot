*** Settings ***
Documentation
...    maintainer: Bartlomiej Kolacz
...    contact: bartlomiej.kolacz@nokia.com

Resource    DevHZ5_startup.robot

*** Keywords ***
Check Counters
  [Arguments]  ${pm_counters_expression}=${EMPTY}  ${rd_counters_expression}=${EMPTY}  ${wait}=${True}
  [Documentation]
  ...  This keyword is to check PM counter and R&D counter(R&D counters checking are ported from 4G,
  ...  and not verified yet. If you need this function, pls contact TA core team)
  ...  | step1 | wait counter file produced at next pm counter interval if wait=True |
  ...  | step2 | download all counter files |
  ...  | step3 | unzip all counter files, parse them and check if satisfy counters expression  |
  ...
  ...  | Input Parameters       | Man. | Default | Description |
  ...  | pm_counters_expression | No   | []      | pm counters expression list |
  ...  | rd_counters_expression | No   | []      | rd counters expression list |
  ...  | wait                   | No   | ${True} | wait for pm counter interval before checking counters value or not |
  ...
  ...  Format of pm_counters_expression:
  ...  | 1) | [mo:][measurement_type]:counter_id=counter_value   | check total counter equal to some value |
  ...  | 2) | [mo:][measurement_type]:counter_id>=counter_value  | check total counter more than or equal to some value |
  ...  | 3) | [mo:][measurement_type]:counter_id<=counter_value  | check total counter less than or equal to some value |
  ...  | 4) | [mo:][measurement_type]:counter_id>counter_value   | check total counter more than some value |
  ...  | 5) | [mo:][measurement_type]:counter_id<counter_value   | check total counter less than some value |
  ...  | 6) | [mo:][measurement_type]:counter_id=existing        | check total counter existing |
  ...  | 7) | [mo:][measurement_type]:counter_id=not_existing    | check total counter not existing |
  ...  | 8) | "last " before the expression listed in 1)~5)  | check counter satisfying the expression in \
  ...  last pm counter interval. "last" can't be used together with expression 6) and 7) |
  ...  | 9) | [mo:][measurement_type]:counter_id=value1|value2|value3... | eg: 1|2|3, The counter passes if the
  ...  value is any one of 1,2,3 |
  ...  | 10) |[mo:][measurement_type]:counter_id=[value1-value2] | eg: 1-3, Another way to write a range of
  ...  values, The counter passes if the value is any one of 1,2,3 |
  ...
  ...  Note:
  ...  1. Format of the first part before =<>:
  ...  | 1) | counter_id |
  ...  | 2) | mo:counter_id |
  ...  | 3) | mo:measurement_type:counter_id | this format is preferred |
  ...  2. "last" prefix is used for max or average counter, which will be existing all the time until UE released.
  ...  3. Format of rd_counters_expression: almost same as pm_counters_expression,
  ...  the difference is that it uses counter_name not counter_id.
  ...
  ...
  ...  Example:
  ...  1)
  ...  | ${pm_counters} | Create List | NRCELL-12:RSACU:M55138C01501=existing | NRCELL-12:RSACU:M55138C01502=2 |
  ...  | NRCELL-2:RSACU:M55138C01501>1 | NRCEL-1/MCC-262/MNC-03/PMQAP-1:RSACU:M55138C01502<=4 |
  ...  | last NRCELL-12:RSADU:M55139C01004=4 |
  ...  | Check Counters | ${pm_counters} |
  ...
  ...  2)
  ...  | ${rd_counters} | Create List | REPORT_RSCFS_ATT_UTRAN>=2 |
  ...  | Check Counters | rd_counters_expression=${rd_counters} |

  ...  3)
  ...  | Check Counters | ${pm_counters} | ${rd_counters} |
  @{result_list}=  Check Counters And Return Result  ${pm_counters_expression}  ${rd_counters_expression}  ${wait}
  #FOR  ${counter_result}  IN  @{result_list}
  #  ${counter_name_or_id}  Set Variable  ${counter_result[0]}
  #  ${counter_value}  Set Variable  ${counter_result[1]}
  #  ${check_result}  Set Variable  ${counter_result[2]}
  #  Run Keyword If  ${counter_name_or_id.startswith("M8")}  Report Pm Counter  ${counter_name_or_id}
  #  ...  ${counter_value}  ${check_result}
  #END
  FOR  ${counter_result}  IN  @{result_list}
    ${check_result}  Set Variable  ${counter_result[2]}
    Run Keyword If  '${check_result.lower()}'== 'failed'  Fail
    ...  check counter failed, pls check keyword "Check Counters And Return Result"
  END

_Archive_a2a_successful_logs
    Return From Keyword If  '${KEYWORD STATUS}'=='FAIL'
    Create Directory  ${SAVE LOG DIRECTORY}/a2a_logs_succeed
    Execute Cmd On PC  mv ${SAVE LOG DIRECTORY}/*.ini ${SAVE LOG DIRECTORY}/a2a_logs_succeed
    Execute Cmd On PC  mv ${SAVE LOG DIRECTORY}/*.pdm ${SAVE LOG DIRECTORY}/a2a_logs_succeed
    Execute Cmd On PC  mv ${SAVE LOG DIRECTORY}/*-p.log ${SAVE LOG DIRECTORY}/a2a_logs_succeed
    Execute Cmd On PC  mv ${SAVE LOG DIRECTORY}/*-w.log ${SAVE LOG DIRECTORY}/a2a_logs_succeed
    Execute Cmd On PC  mv ${SAVE LOG DIRECTORY}/*.a2a_decode ${SAVE LOG DIRECTORY}/a2a_logs_succeed

_Check Logs With Au2anlysis
  [Arguments]  ${ini_path}  ${log_need_to_check}
  ${res}=  Run Keyword And Return Status  Check Log With Au2anlysis  ${ini_path}  ${log_need_to_check}  save_log_directory=${SAVE LOG DIRECTORY}
  Run Keyword If  ${res}==${False}  Parse A2A Fail  case_log_path=${save_log_directory}  checkfile_type=${log_need_to_check}

Check WireShark Log
  [Arguments]  ${a2a_ini_file}  ${name}=${empty}  ${wait_string}=UEContextReleaseComplete::2  ${decode_option}=${EMPTY}
  [Documentation]
  ...  This keyword is used to check wireshark log via a2a tool
  ...  | step1 | wait expected string occurred with specified times in wireshark log and stop it |
  ...  | step2 | check the log with a2a tool |
  ...
  ...  | Input Parameters | Man. | Default  | Description |
  ...  | a2a_ini_file     | YES  | NA       | a2a ini file  |
  ...  | name             | NO   | ${empty} | used to specify which wireshark log to be checked |
  ...  | wait_string      | NO   | UEContextReleaseComplete::1  | retry until this string appears \
  ...  for the dedicated times in wireshark log before download the log |
  ...  | decode_option    | NO   | ${empty} | used to specify extra options when transform wireshark pcap to txt |
  ...
  ...  Format of wait_string:<expected_string>[::<times>]
  ...
  ...  Examples:
  ...  1) use default wait sting
  ...  | Check WireShark Log | ${CURDIR}/a2a_01/a2a.ini |
  ...
  ...  2) use other string and it appeared more than/equal to one time
  ...  | Check WireShark Log | ${CURDIR}/a2a_01/a2a.ini | wait_string=UEContextReleaseComplete |
  ...
  ...  3) use other string and it appeared more than/equal to specified times
  ...  | Check WireShark Log | ${CURDIR}/a2a_01/a2a.ini | wait_string=Detach request::3 |
  Run Keyword And Ignore Error  Stop Wireshark Log After String Found  ${name}  ${wait_string}  ${decode_option}
  recreate_wireshark_txt_files  ${a2a_ini_file}
  Execute Cmd On Pc  cd ${SAVE LOG DIRECTORY};ls -ltrh wireshark*;cd -
  _Check Logs With Au2anlysis  ${a2a_ini_file}  w
  [Teardown]  Run Keyword And Ignore Error  _Archive_a2a_successful_logs
