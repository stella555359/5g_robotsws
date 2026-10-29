*** Settings ***
Resource    DevHZ5_startup.robot

*** Variables ***
${SWITCHOFF_TIMEOUT_4PIPES_2PIPES}  15 min  # random time from 0~300s, from 3 change to 15
${SWITCHOFF_TIMEOUT_8PIPES}  1 min
${SWITCH_TIMEOUT_PS}  15 min  # random time from 0~300s, from 2 change to 15
${SWITCHON_TIMEOUT_4PIPES_2PIPES}  15 min  # random time from 0~300s, from 8 change to 15
${SWITCHON_TIMEOUT_8PIPES}  1 min
${LOW_LOAD_SWITCHOFF_DELAY}  12  #default is 30, unit is 10s
${HIGH_LOAD_SWITCHON_DELAY}  6  #default is 12, unit is 10s

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
  FOR  ${counter_result}  IN  @{result_list}
    ${counter_name_or_id}  Set Variable  ${counter_result[0]}
    ${counter_value}  Set Variable  ${counter_result[1]}
    ${check_result}  Set Variable  ${counter_result[2]}
    Run Keyword If  ${counter_name_or_id.startswith("M8")}  Report Pm Counter  ${counter_name_or_id}
    ...  ${counter_value}  ${check_result}
  END
  FOR  ${counter_result}  IN  @{result_list}
    ${check_result}  Set Variable  ${counter_result[2]}
    Run Keyword If  '${check_result.lower()}'== 'failed'  Fail
    ...  check counter failed, pls check keyword "Check Counters And Return Result"
  END

Check Counters ENB2
  [Arguments]  ${pm_counters_expression}=${EMPTY}  ${rd_counters_expression}=${EMPTY}  ${wait}=${False}
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
  ...  | wait                   | No   | ${False} | wait for pm counter interval before checking counters value or not|
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
  ...
  ...  Note:
  ...  Format of the first part before =<>:
  ...  | 1) | counter_id |
  ...  | 2) | mo:counter_id |
  ...  | 3) | mo:measurement_type:counter_id | this format is preferred |
  ...
  ...  Format of rd_counters_expression: almost same as pm_counters_expression,
  ...  the difference is that it uses counter_name not counter_id.

  ...  Example:
  ...  1)
  ...  | ${pm_counters} | Create List | NRCELL-12:RSACU:M55138C01501=existing | NRCELL-12:RSACU:M55138C01502=2 |
  ...  | NRCELL-2:RSACU:M55138C01501>1 | NRCEL-1/MCC-262/MNC-03/PMQAP-1:RSACU:M55138C01502<=4 |
  ...  | last NRCELL-12:RSADU:M55139C01004=4 |
  ...  | Check Counters ENB2 | ${pm_counters} |
  ...
  ...  2)
  ...  | ${rd_counters} | Create List | REPORT_RSCFS_ATT_UTRAN>=2 |
  ...  | Check Counters ENB2 | rd_counters_expression=${rd_counters} |

  ...  3)
  ...  | Check Counters ENB2 | ${pm_counters} | ${rd_counters} |
  @{result_list}=  Check Counters And Return Result ENB2  ${pm_counters_expression}  ${rd_counters_expression}  ${wait}
  FOR  ${counter_result}  IN  @{result_list}
    ${counter_name_or_id}  Set Variable  ${counter_result[0]}
    ${counter_value}  Set Variable  ${counter_result[1]}
    ${check_result}  Set Variable  ${counter_result[2]}
    Run Keyword If  ${counter_name_or_id.startswith("M8")}  Report Pm Counter  ${counter_name_or_id}
    ...  ${counter_value}  ${check_result}
  END
  FOR  ${counter_result}  IN  @{result_list}
    ${check_result}  Set Variable  ${counter_result[2]}
    Run Keyword If  '${check_result.lower()}'== 'failed'  Fail
    ...  check counter failed, pls check keyword "Check Counters And Return Result ENB2"
  END

Check Rtpm Counters
    [Arguments]  ${pm_counters_expression}=${EMPTY}  ${pm_reference_file}=${EMPTY}  ${tag}=${EMPTY}
    [Documentation]  This keyword is to check rtpm counter. pm_counters_expression or pm_reference_file must be provided,
    ...  but can't be given at the same time.
    ...  \ \ \ \ \ \ | step1 | wait more than 60s, stop rtpm and convert rtpm binary file to xml format file |
    ...  \ \ \ \ \ | step2 | compare actual counter value in rtpm xml file with pm_counters_expression or pm_reference file |
    ...  \ \ \ \ \ \ | Input Parameters | Man. | Description |
    ...  \ | pm_counters_expression \ | No \ \ | pm counters expression list. |
    ...  | pm_reference_file | No | pm reference file, support two kindes of formats |
    ...
    ...  format of pm_counters_expression:
    ...  | 1) | [mo:][counter_type]:counter_id=counter_value | check counter equal to some value |
    ...  | 2) | [mo:][counter_type]:counter_id>=counter_value | check counter more than or equal to some value |
    ...  | 3) | [mo:][counter_type]:counter_id<=counter_value | check counter less than or equal to some value |
    ...  | 4) | [mo:][counter_type]:counter_id>counter_value | check counter more than some value |
    ...  | 5) | [mo:][counter_type]:counter_id<counter_value | check counter less than some value |
    ...  | 6) | [mo:][counter_type]:counter_id=existing | check counter existing |
    ...  | 7) | [mo:][counter_type]:counter_id=not_existing | check counter not existing |
    ...  | 8) | "every " before the expression listed in 1)~7) | check counter satisfying the expression in every pm counter interval.
    ...  it is 60s for rtpm counter |
    ...  | 9) | "last " before the expression listed in 1)~7) | check counter satisfying the expression in last pm counter interval.
    ...  it is used for checking average counter and always existing counter once produced |
    ...
    ...  format of pm_reference file:
    ...  type 1: traditional pm reference file
    ...  | 1) | <DN:NE-mo><counter_type><counter_id><counter_value> | check counter equal to some value |
    ...  | 2) | <DN:NE-mo><counter_type><counter_id><smallest_value..biggest_value> | check smallest_value<=counter<=biggest_value \ |
    ...  | 3) | !<DN:NE-mo><counter_type><counter_id><*> | check counter not exist |
    ...  | 4) | <DN:NE-mo><counter_type><counter_id><*> | check counter exist, but not care what value it is |
    ...  type 2: file content composed by pm_counters_expression, with 9 kindes of format described as above
    ...
    ...
    ...  Example:
    ...
    ...  1) pm_counters_expression \ -- suggest to use
    ...  | ${pm_counters} | Create List | M8017C12<=1 | M8017C13>=2 | M8008C13=1 | LNCEL-100:M8008C12>1 | \ LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C5=0
    ...  | M8017C11=existing | LNCEL-1:LTE_EPS_Bearer:M8006CC=not_existing | every M8061C214<=900 |
    ...  | ${result_list} | check_rtpm_counter_and_return_result | ${pm_counters} |
    ...
    ...  2) pm_reference_file with traditional format \ -- not used for new cases
    ...  | ${result_list} | check_rtpm_counter_and_return_result | pm_reference_file=${CURDIR}/reference_PM_format1.txt |
    ...
    ...  3) pm_reference_file with pm counter expressions \ -- not used for new cases
    ...  | ${result_list} | check_rtpm_counter_and_return_result | pm_reference_file=${CURDIR}/reference_PM_format2.txt \ |
    ...
    ...  example of reference_PM_format1.txt:
    ...
    ...  <DN:NE-LNBTS-1/LNCEL-1/MCC-262/MNC-03><LTE_Cell_Load><M8001C421><0>
    ...
    ...  <DN:NE-LNBTS-1/LNCEL-1/MCC-262/MNC-03><LTE_EPS_Bearer><M8006C0><0..1>
    ...
    ...  <DN:NE-LNBTS-1/LNCEL-1/MCC-262/MNC-03><LTE_EPS_Bearer><M8006C1><*>
    ...
    ...  !<DN:NE-LNBTS-1/LNCEL-1/MCC-262/MNC-03><LTE_EPS_Bearer><M8006CC><*>
    ...
    ...
    ...  example of reference_PM_format2.txt:
    ...
    ...  LNCEL-1:LTE_Cell_Load:M8001C421=0
    ...
    ...  LNCEL-1:LTE_EPS_Bearer:M8006C0>=0
    ...
    ...  LNCEL-1:LTE_EPS_Bearer:M8006C0<=1
    ...
    ...  LNCEL-1:LTE_EPS_Bearer:M8006C1=existing
    ...
    ...  LNCEL-1:LTE_EPS_Bearer:M8006CC=not_existing
    @{result_list}=  Check Rtpm Counter And Return Result  ${pm_counters_expression}  ${pm_reference_file}  ${tag}
    FOR  ${counter_result}  IN  @{result_list}
        ${counter_name_or_id}  Set Variable  ${counter_result[0]}
        ${counter_value}  Set Variable  ${counter_result[1]}
        ${check_result}  Set Variable  ${counter_result[2]}
        Run Keyword If  ${counter_name_or_id.startswith("M8")}  Report Pm Counter  ${counter_name_or_id}  ${counter_value}  ${check_result}
    END
    FOR  ${counter_result}  IN  @{result_list}
        ${check_result}  Set Variable  ${counter_result[2]}
        Run Keyword If  '${check_result.lower()}'== 'failed'  Fail  check counter failed, pls check keyword "check counters and return result"
    END

Check Rtpm Counters eNB2
    [Arguments]  ${pm_counters_expression}=${EMPTY}  ${pm_reference_file}=${EMPTY}  ${tag}=${EMPTY}
    [Documentation]  This keyword is to check rtpm counter. pm_counters_expression or pm_reference_file must be provided,
    ...  but can't be given at the same time.
    ...  \ \ \ \ \ \ | step1 | wait more than 60s, stop rtpm and convert rtpm binary file to xml format file |
    ...  \ \ \ \ \ | step2 | compare actual counter value in rtpm xml file with pm_counters_expression or pm_reference file |
    ...  \ \ \ \ \ \ | Input Parameters | Man. | Description |
    ...  \ | pm_counters_expression \ | No \ \ | pm counters expression list. |
    ...  | pm_reference_file | No | pm reference file, support two kindes of formats |
    ...
    ...  format of pm_counters_expression:
    ...  | 1) | [mo:][counter_type]:counter_id=counter_value | check counter equal to some value |
    ...  | 2) | [mo:][counter_type]:counter_id>=counter_value | check counter more than or equal to some value |
    ...  | 3) | [mo:][counter_type]:counter_id<=counter_value | check counter less than or equal to some value |
    ...  | 4) | [mo:][counter_type]:counter_id>counter_value | check counter more than some value |
    ...  | 5) | [mo:][counter_type]:counter_id<counter_value | check counter less than some value |
    ...  | 6) | [mo:][counter_type]:counter_id=existing | check counter existing |
    ...  | 7) | [mo:][counter_type]:counter_id=not_existing | check counter not existing |
    ...  | 8) | "every " before the expression listed in 1)~7) | check counter satisfying the expression in every pm counter interval.
    ...  it is 60s for rtpm counter |
    ...
    ...  format of pm_reference file:
    ...
    ...  type 1: traditional pm reference file
    ...  | 1) | <DN:NE-mo><counter_type><counter_id><counter_value> | check counter equal to some value |
    ...  | 2) | <DN:NE-mo><counter_type><counter_id><smallest_value..biggest_value> | check smallest_value<=counter<=biggest_value \ |
    ...  | 3) | !<DN:NE-mo><counter_type><counter_id><*> | check counter not exist |
    ...  | 4) | <DN:NE-mo><counter_type><counter_id><*> | check counter exist, but not care what value it is |
    ...  type 2: file content composed by pm_counters_expression, with 8 kindes of format described as above
    ...
    ...
    ...  Example:
    ...
    ...  1) pm_counters_expression
    ...  | ${pm_counters} | Create List | M8017C12<=1 | M8017C13>=2 | M8008C13=1 | LNCEL-100:M8008C12>1 | \ LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C5=0
    ...  | M8017C11=existing | LNCEL-1:LTE_EPS_Bearer:M8006CC=not_existing | every M8061C214<=900 |
    ...  | ${result_list} | check_rtpm_counter_and_return_result | ${pm_counters} |
    ...
    ...  2) pm_reference_file with traditional format
    ...  | ${result_list} | check_rtpm_counter_and_return_result | pm_reference_file=${CURDIR}/reference_PM_format1.txt |
    ...
    ...  3) pm_reference_file with pm counter expressions
    ...  | ${result_list} | check_rtpm_counter_and_return_result | pm_reference_file=${CURDIR}/reference_PM_format2.txt \ |
    ...
    ...  example of reference_PM_format1.txt:
    ...
    ...  <DN:NE-LNBTS-1/LNCEL-1/MCC-262/MNC-03><LTE_Cell_Load><M8001C421><0>
    ...
    ...  <DN:NE-LNBTS-1/LNCEL-1/MCC-262/MNC-03><LTE_EPS_Bearer><M8006C0><0..1>
    ...
    ...  <DN:NE-LNBTS-1/LNCEL-1/MCC-262/MNC-03><LTE_EPS_Bearer><M8006C1><*>
    ...
    ...  !<DN:NE-LNBTS-1/LNCEL-1/MCC-262/MNC-03><LTE_EPS_Bearer><M8006CC><*>
    ...
    ...
    ...  example of reference_PM_format2.txt:
    ...
    ...  LNCEL-1:LTE_Cell_Load:M8001C421=0
    ...
    ...  LNCEL-1:LTE_EPS_Bearer:M8006C0>=0
    ...
    ...  LNCEL-1:LTE_EPS_Bearer:M8006C0<=1
    ...
    ...  LNCEL-1:LTE_EPS_Bearer:M8006C1=existing
    ...
    ...  LNCEL-1:LTE_EPS_Bearer:M8006CC=not_existing
    @{result_list}=  Check Rtpm Counter And Return Result enb2  ${pm_counters_expression}  ${pm_reference_file}  ${tag}
    FOR  ${counter_result}  IN  @{result_list}
        ${counter_name_or_id}  Set Variable  ${counter_result[0]}
        ${counter_value}  Set Variable  ${counter_result[1]}
        ${check_result}  Set Variable  ${counter_result[2]}
        Run Keyword If  ${counter_name_or_id.startswith("M8")}  Report Pm Counter  ${counter_name_or_id}  ${counter_value}  ${check_result}
    END
    FOR  ${counter_result}  IN  @{result_list}
        ${check_result}  Set Variable  ${counter_result[2]}
        Run Keyword If  '${check_result.lower()}'== 'failed'  Fail  check counter failed, pls check keyword "check counters and return result enb2"
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
  ${pcmd}  Get Scf Parameter Value  LNBTS-1:actPCMDReport
  ${trace}  Get Scf Parameter Value  LNBTS-1:actCellTrace
  Run Keyword If  '${pcmd}'=='false' and '${trace}'=='false'  Fail  only trace case can use this keyword
  Run Keyword And Ignore Error  Stop Wireshark Log After String Found  ${name}  ${wait_string}  ${decode_option}
  recreate_wireshark_txt_files  ${a2a_ini_file}
  _Check Logs With Au2anlysis  ${a2a_ini_file}  w
  [Teardown]  Run Keyword And Ignore Error  _Archive_a2a_successful_logs

Check WireShark Log eNB2
  [Arguments]  ${a2a_ini_file}  ${name}=${empty}  ${wait_string}=UEContextReleaseComplete::1  ${decode_option}=${EMPTY}
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
  ${pcmd}  Get Scf Parameter Value eNB2  LNBTS-2:actPCMDReport
  ${trace}  Get Scf Parameter Value eNB2  LNBTS-2:actCellTrace
  Run Keyword If  '${pcmd}'=='false' and '${trace}'=='false'  Fail  only trace case can use this keyword
  Run Keyword And Ignore Error  Stop Wireshark Log After String Found ENB2  ${name}  ${wait_string}  ${decode_option}
  recreate_wireshark_txt_files  ${a2a_ini_file}
  _Check Logs With Au2anlysis  ${a2a_ini_file}  w
  [Teardown]  Run Keyword And Ignore Error  _Archive_a2a_successful_logs

Check Enb TTitrace
    [Arguments]  ${a2a_ini_file}  ${tag}=${EMPTY}
    Stop Capture Enb Ttitrace  ${tag}
    Check Logs With Au2anlysis  ${a2a_ini_file}  i

Cell${number} Enter Into energySaving State
    Wait Until Keyword Succeeds  ${SWITCH_TIMEOUT_PS}  10 s  Energy Saving State Should Be  ${number}  energySaving

Cell${number} Enter Into notEnergySaving State
    ${cell_info}  Get Cell Info  ${number}
    ${SWITCH_TIMEOUT}  Set Variable If  ${cell_info["pipes_num"]}==8  ${SWITCHON_TIMEOUT_8PIPES}  ${SWITCHON_TIMEOUT_4PIPES_2PIPES}
    Wait Until Keyword Succeeds  ${SWITCH_TIMEOUT}  10 s  Energy Saving State Should Be  ${number}  notEnergySaving
    ${onair}  Run Keyword And Return Status  Query Infomodel  //CELL_M-${number} is [stateInfo.proceduralState=OnAirDone]
    Run Keyword If  ${onair}  Active Pipes Should Be  ${number}  ${cell_info["pipes_num"]}
    Run Keyword If    not ${onair}  Active Pipes Should Be  ${number}  0

Cell${number} Enter Into reducedEnergySaving State
    [Documentation]  When cell enter into reducedEnergySaving State:
    ...  1. LNCEL:energySavingState should be reducedEnergySaving State
    ...  2. 8TX or 4TX pipes are reduced to 2TX; 2TX are reduced to 1TX
    ...  3. TM7/8/9 switch to TM3, not checked in this keyword.it need be checked by L3 call.
    ${cell_info}  Get Cell Info  ${number}
    ${SWITCH_TIMEOUT}  Set Variable If  ${cell_info["pipes_num"]}==8  ${SWITCHOFF_TIMEOUT_8PIPES}  ${SWITCHOFF_TIMEOUT_4PIPES_2PIPES}
    Wait Until Keyword Succeeds  ${SWITCH_TIMEOUT}  10 s  Energy Saving State Should Be  ${number}  reducedEnergySaving
    ${active_pipes_exp}  Set Variable If  ${cell_info["pipes_num"]}==2  1  2
    Active Pipes Should Be  ${number}  ${active_pipes_exp}

Cell${number} Keep In EnergySaving State
    Energy Saving State Should Be  ${number}  energySaving

Cell${number} Keep In notEnergySaving State
    Energy Saving State Should Be  ${number}  notEnergySaving

Cell${number} Keep In reducedEnergySaving State
    Energy Saving State Should Be  ${number}  reducedEnergySaving

Cell${number} Shall Not Enter Into reducedEnergySaving State
    ${cell_info}  Get Cell Info  ${number}
    ${SWITCH_TIMEOUT}  Set Variable If  ${cell_info["pipes_num"]}==8  ${SWITCHOFF_TIMEOUT_8PIPES}  ${SWITCHOFF_TIMEOUT_4PIPES_2PIPES}
    Sleep  ${SWITCH_TIMEOUT}
    Energy Saving State Should Be  ${number}  notEnergySaving

Energy Saving State Should Be
    [Arguments]  ${lcr}  ${psm_exp}
    ${value}    get scf parameter value    LNCEL-${lcr}:energySavingState
    Should Match Regexp    ${value}    ${psm_exp}

Wait HighLoadSwitchOnDelay
    Sleep  ${${HIGH_LOAD_SWITCHON_DELAY}*10}s

Wait LowLoadSwitchOffDelay
    Sleep  ${${LOW_LOAD_SWITCHOFF_DELAY}*10}s
