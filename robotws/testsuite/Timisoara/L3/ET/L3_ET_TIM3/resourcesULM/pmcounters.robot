*** Settings ***
Documentation    resources
Library     String
Library     DateTime
Library     OperatingSystem
Library     Collections

Library     taf.config.scf               WITH NAME    scf
Library     python/pmcounters.py         WITH NAME    pm_internal
Library     python/gnb.py                WITH NAME    gnb_lib
Library     taf.collectors.pmcounters    WITH NAME    collect_pm
Library     taf.converters.pmtocsv       WITH NAME    pmtocsv
Library     taf.analyzer.pmcounter       WITH NAME    check_pm
Library     python/all_in_cloud.py       WITH NAME    aic_py
Library     python/testline_information.py

Resource    gnb.robot
Resource    testline.robot

*** Variables ***
&{P_MEAS_PERIOD}        &{EMPTY}
&{P_START_TIME}         &{EMPTY}
${P_console}            ${False}

*** Keywords ***
Collect pm counter on CU
    [Documentation]
    ...
    ...    | gnb_id         | The gNodeB index of the gnb in the testline configuration |
    ...    | target_dir     | Path where to store the pm counter data                   |
    ...
    ...     *Returns*   path where the collector will store files (corresponds to collector alias name)
    ...
    [Arguments]   ${gnb_id}=${0}   ${target_dir}=None   ${collector_alias}=k8scounters_cu

    ${target_dir}   Run Keyword If   '${target_dir}'=='None'   testline.Get Testcase Log Directory
    ...   ELSE      Set Variable     ${target_dir}

    ${executor}     aic_py.get_cu_executor
    ${namespace}    aic_py.get_cu_namespace   gnb_id=${gnb_id}

    Set Log Level   DEBUG
    ${pod}   ${container}   aic_py.get_pm_pod_and_container_on_cu   gnb_id=${gnb_id}

#    collect_pm.create_k8s_pm_collector
#    ...   name=${collector_alias}
#    ...   executor=${executor}
#    ...   namespace=${namespace}
#    ...   pod=${pod}
#    ...   container=${container}
    collect_pm.setup_collectors
    ...   names=${collector_alias}

    collect_pm.collect_collectors
    ...   names=${collector_alias}
    ...   target_dir=${target_dir}

    collect_pm.teardown_collectors
    ...   names=${collector_alias}
    [Return]   ${target_dir}/${collector_alias}


Collect pm counter on VDU
    [Documentation]
    ...
    ...    | gnb_id         | The gNodeB index of the gnb in the testline configuration             |
    ...    | vdu_id         | The vdu index inside the gnb structure in the testline configuration  |
    ...    | target_dir     | Path where to store the pm counter data                               |
    ...
    ...     *Returns*   path where the collector will store files (corresponds to collector alias name)
    ...

    [Arguments]   ${gnb_id}=${0}   ${vdu_id}=${0}   ${target_dir}=None   ${collector_alias}=k8scounters_vdu

    ${target_dir}   Run Keyword If   '${target_dir}'=='None'   testline.Get Testcase Log Directory
    ...   ELSE      Set Variable     ${target_dir}

    ${executor}    aic_py.get_vdu_executor    gnb_id=${gnb_id}   vdu_id=${vdu_id}
    ${namespace}   aic_py.get_vdu_namespace   gnb_id=${gnb_id}   vdu_id=${vdu_id}

    ${pod}   ${container}   aic_py.get_pm_pod_and_container_on_vdu   gnb_id=${gnb_id}

#    collect_pm.create_k8s_pm_collector
#    ...   name=${collector_alias}
#    ...   executor=${executor}
#    ...   namespace=${namespace}
#    ...   pod=${pod}
#    ...   container=${container}
    collect_pm.setup_collectors
    ...   names=${collector_alias}

    collect_pm.collect_collectors
    ...   names=${collector_alias}
    ...   target_dir=${target_dir}

    collect_pm.teardown_collectors
    ...   names=${collector_alias}
    [Return]   ${target_dir}/${collector_alias}


Convert PM files to CSV
    [Documentation]
    ...
    ...    | file_path          | Collected PM counters file path, should be a folder                                           |
    ...    | param file_pattern | needed PM file pattern, if ${None} is it will be defined automatically for AiC  and Clasical  |
    ...    | param nidd_file    | DEPRECATED                                                                                    |
    ...
    ...    *Returns*    Location of converted PM counter file
    ...
    [Arguments]   ${file_path}   ${file_pattern}=${None}   ${nidd_file}=${None}
    ${file_pattern}   Set Variable If
    ...   '${file_pattern}'=='${None}' and '${tl_info.deployment_type()}'=='classical'   PM*BTS*ANY*
    ...   '${file_pattern}'=='${None}' and '${tl_info.deployment_type()}'=='aic'         A20*
    ...   $file_pattern is not None                                                      ${file_pattern}

    ${work_space}   testline.Get Workspace Directory
    ${nidd_path}    pm_internal.get_nidd_file_name_path
    log    ${nidd_file}
    pmtocsv.Create PM to CSV Converter
    ...   name=test_converter
    ...   file_path_pattern=${file_path}/${file_pattern}.xml
    ...   delimiter=;
    ...   output_file_name=${file_path}/pmCounters.csv
    ...   nidd_path=${nidd_path}
    pmtocsv.Convert   test_converter
    [Return]   ${file_path}/pmCounters.csv


Collect CU And VDU PM Counters
    [Documentation]
    ...    | pm_collector_alias | The Alias of the pm counter collector     |
    ...    | target_dir         | The target directory                      |
    ...    | cu_logs_alias      | The Alias of the cu pm counter collector  |
    ...    | vdu_logs_alias     | The Alias of the vdu pm counter collector |
    ...
    ...    *Returns*    Location of converted PM counter file
    ...

    [Arguments]   ${collector_alias}   ${target_dir}   ${gnb_id}   ${du_id}

    Collect pm counter on CU    gnb_id=${gnb_id}
    ...                         target_dir=${target_dir}
    ...                         collector_alias=${collector_alias}_cu
    Collect pm counter on VDU   gnb_id=${gnb_id}
    ...                         vdu_id=${du_id}
    ...                         target_dir=${target_dir}
    ...                         collector_alias=${collector_alias}_vdu

    ${output_path}   Set Variable   ${target_dir}/${collector_alias}
    OperatingSystem.Create Directory   ${target_dir}/${collector_alias}
    OperatingSystem.Copy Files   ${target_dir}/${collector_alias}_cu/*    ${output_path}
    OperatingSystem.Copy Files   ${target_dir}/${collector_alias}_vdu/*   ${output_path}

    [Return]   ${output_path}


Collect PM Counter
    [Documentation]
    ...    | gnb_id             | Id/Number of gNB                                          |
    ...    | collector_alias    | alias name for collector                                  |
    ...    | target_dir         | save PM Counter files to path                             |
    ...    | component          | options : DU/CU) If oam type is cloud coam for vRAN 1.0   |
    ...
    ...    *Returns* Location of collected PM counter files
    ...
    [Arguments]   ${gnb_id}=0   ${du_id}=0   ${collector_alias}=gnb_pm_counters   ${target_dir}=None   ${component}=DU
    log    ${component}
    ${target_dir}   Run Keyword If   '${target_dir}'=='None'   testline.Get Testcase Log Directory
    ...   ELSE      Set Variable     ${target_dir}

    Run Keyword If   '${tl_info.deployment_type(${gnb_id})}'=='aic'
    ...   Run Keywords
    ...         Collect CU And VDU PM Counters   ${collector_alias}   ${target_dir}   ${gnb_id}   ${du_id}
    ...   AND   Return From Keyword   ${target_dir}/${collector_alias}

    Check if CU http port is configured for classical GNB   ${gnb_id}
    ${du_host_ip}   gnb_lib.Get GNB DU Host IP   ${tl.gnbs[${gnb_id}].dus[${du_id}]}
    ${remote_ip}    connect.Get test pc ip for remote connection    node_type=gnb   node_id=${gnb_id}

    ${webservice}   Run Keyword If   '${tl_info.deployment_type(${gnb_id})}'=='classical'
    ...       Get Webservice for Collector    tl=${tl}   gnb_id=${gnb_id}
    ...   ELSE
    ...       FAIL    Unsupported Node Type!

    collect_pm.Create PM Collector   name=${collector_alias}    webservice=${webservice}
    collect_pm.Setup Collectors      names=${collector_alias}
    collect_pm.Collect Collectors    names=${collector_alias}   target_dir=${target_dir}
    collect_pm.Teardown Collectors   names=${collector_alias}
    [Return]   ${target_dir}/${collector_alias}


Check PM counter value equal
    [Documentation]
    ...        checks that the value of a counter in the last reporting period is equal to a given value
    ...
    ...        | expected_value     | is the value compared to counter value                                                |
    ...        | pm_files_location  | is the path to PM files                                                               |
    ...        | pi_id              | is the PM counter ID e.g. M55112C03001                                                |
    ...        | moc                | is the class including the counter e.g. NRCELL-1                                      |
    ...        | ..                 | NOTE: it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1    |
    ...
    [Arguments]   ${expected_value}   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Get PM counter value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${expected_value}   Convert To Integer   ${expected_value}
    Should Be Equal   ${pi_value}   ${expected_value}   PM Counter ${pi_id} expected to be == ${expected_value} but is ${pi_value}


Check PM counter value not equal
    [Documentation]
    ...        checks that the value of a counter in the last reporting period is equal to a given value
    ...
    ...        | not_expected_value | is the value compared to counter value                                                |
    ...        | pm_files_location  | is the path to PM files                                                               |
    ...        | pi_id              | is the PM counter ID e.g. M55112C03001                                                |
    ...        | moc                | is the class including the counter e.g. NRCELL-1                                      |
    ...        | ..                 | NOTE: it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1    |
    ...
    [Arguments]   ${not_expected_value}   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Get PM counter value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${not_expected_value}   Convert To Integer   ${not_expected_value}
    Should Not Be Equal   ${pi_value}   ${not_expected_value}   PM Counter ${pi_id} expected to be != ${not_expected_value} but is ${pi_value}


Check PM counter value bigger than
    [Documentation]
    ...        checks that the value of a counter in the last reporting period is bigger than a given value
    ...
    ...        | expected_value     | is the value compared to counter value                                                |
    ...        | pm_files_location  | is the path to PM files                                                               |
    ...        | pi_id              | is the PM counter ID e.g. M55112C03001                                                |
    ...        | moc                | is the class including the counter e.g. NRCELL-1                                      |
    ...        | ..                 | NOTE: it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1    |
    ...
    [Arguments]   ${expected_value}   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Get PM counter value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${expected_value}   Convert To Integer   ${expected_value}
    Should Be True   ${pi_value}>${expected_value}   PM Counter ${pi_id} expected to be > ${expected_value} but is ${pi_value}

Check PM counter value equal or bigger than
    [Documentation]
    ...        checks that the value of a counter in the last reporting period is equal or bigger than a given value
    ...
    ...        | expected_value     | is the value compared to counter value                                                |
    ...        | pm_files_location  | is the path to PM files                                                               |
    ...        | pi_id              | is the PM counter ID e.g. M55112C03001                                                |
    ...        | moc                | is the class including the counter e.g. NRCELL-1                                      |
    ...        | ..                 | NOTE: it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1    |
    ...
    [Arguments]   ${expected_value}   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Get PM counter value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${expected_value}   Convert To Integer   ${expected_value}
    Should Be True   ${pi_value}>=${expected_value}   PM Counter ${pi_id} expected to be >= ${expected_value} but is ${pi_value}

Check PM counter value smaller than
    [Documentation]
    ...        checks that the value of a counter in the last reporting period is smaller than a given value
    ...
    ...        | expected_value     | is the value compared to counter value                                                |
    ...        | pm_files_location  | is the path to PM files                                                               |
    ...        | pi_id              | is the PM counter ID e.g. M55112C03001                                                |
    ...        | moc                | is the class including the counter e.g. NRCELL-1                                      |
    ...        | ..                 | NOTE: it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1    |
    ...
    [Arguments]   ${expected_value}   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Get PM counter value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${expected_value}   Convert To Integer   ${expected_value}
    Should Be True   ${pi_value}<${expected_value}   PM Counter ${pi_id} expected to be < ${expected_value} but is ${pi_value}


Check PM counter value equal or smaller than
    [Documentation]
    ...        checks that the value of a counter in the last reporting period is equal or smaller than a given value
    ...
    ...        | expected_value     | is the value compared to counter value                                                |
    ...        | pm_files_location  | is the path to PM files                                                               |
    ...        | pi_id              | is the PM counter ID e.g. M55112C03001                                                |
    ...        | moc                | is the class including the counter e.g. NRCELL-1                                      |
    ...        | ..                 | NOTE: it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1    |
    ...
    [Arguments]  ${expected_value}   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Get PM counter value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${expected_value}   Convert To Integer   ${expected_value}
    Should Be True  ${pi_value} <= ${expected_value}     PM Counter ${pi_id} expected to be <= ${expected_value} but is ${pi_value}


Check PM counter value in range
    [Documentation]
    ...        checks that the value of a counter in the last reporting period is in range defined by a given value
    ...
    ...        | expected_value     | is the value compared to counter value                                                |
    ...        | pm_files_location  | is the path to PM files                                                               |
    ...        | pi_id              | is the PM counter ID e.g. M55112C03001                                                |
    ...        | moc                | is the class including the counter e.g. NRCELL-1                                      |
    ...        | ..                 | NOTE: it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1    |
    ...        | rel_tolerance      | is the relative tolerance of the expected value                                       |
    ...        | abs_tolerance      | is the absolute tolerance of the expected value                                       |
    ...
    [Arguments]   ${expected_value}   ${pm_files_location}   ${pi_id}   ${moc}   ${abs_tolerance}=0   ${rel_tolerance}=0.05
    ${pi_value}   Get PM counter value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${expected_value}   Convert To Integer    ${expected_value}
    ${upper_value}   Evaluate   ${expected_value} + ${expected_value} * ${rel_tolerance} + ${abs_tolerance}
    ${lower_value}   Evaluate   ${expected_value} - ${expected_value} * ${rel_tolerance} - ${abs_tolerance}
    Should Be True   ${lower_value} <= ${pi_value} <= ${upper_value}   PM Counter ${pi_id} isn't in expected range


Get PM counter value
    [Documentation]
    ...        get the value of a counter in the last reporting period
    ...
    ...        | pm_files_location  | is the path to PM files                                                               |
    ...        | pi_id              | is the PM counter ID e.g. M55112C03001                                                |
    ...        | moc                | is the class including the counter e.g. NRCELL-1                                      |
    ...        | ..                 | NOTE: it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1    |
    ...
    ...    *Returns* pm counter value
    ...
    [Arguments]   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_list}   Create List   ${pi_id}
    ${PM_report_dict_list}   check_pm.get_pi_value
    ...   pi_list=${pi_list}
    ...   pi_dir=${pm_files_location}
    ...   pi_file_pattern=PM*

    ${last_report}      Collections.Get From List           ${PM_report_dict_list}   -1
    ${pi_dict}          Collections.Get Dictionary Values   ${last_report}
    ${first_pi}         Collections.Get From List           ${pi_dict}               0
    ${cell_dict_list}   Collections.Get Dictionary Values   ${first_pi}
    ${cell_dict}        Collections.Get From List           ${cell_dict_list}        0
    ${moc_list}         Collections.Get Dictionary Keys     ${cell_dict}
    ${full_moc}   Set Variable   empty

    FOR   ${key}   IN    @{moc_list}
       ${key_is_moc}   Run Keyword And Return Status   Should Contain   ${key}   ${moc}
       ${full_moc}     Set Variable If   ${key_is_moc}   ${key}   ${full_moc}
    END

    ${pi_value}   Collections.Get From Dictionary   ${cell_dict}   ${full_moc}
    BuiltIn.Log   ${pi_id} value: ${pi_value}   console=${P_console}
    [Return]   ${pi_value}


Wait until the next Measurement Period starts
    [Documentation]
    ...    this keyword could be used as wait for current Measurement Period stops
    ...
    ...    | gnb_id             | Id/Number of gNB                      |
    ...    | component          | options : DU/CU) If gnb type is aic   |
    ...    | additional_time    | additional seconds for waiting        |
    ...
    [Arguments]   ${gnb_id}=0   ${component}=DU   ${additional_time}=30
    ${meas_period}   Get Measurement Period from GNB   gnb_id=${gnb_id}   component=${component}
    pm_internal.wait_next_meas_period   meas_period=${meas_period}   add_time=${additional_time}   with_console_output=${P_console}
    ${start_time}   DateTime.Get Current Date   result_format=%H:%M:%S
    BuiltIn.Log   Start Time Of Measurement Period = ${start_time}   level=DEBUG
    ${start_time}   DateTime.Convert Time   ${start_time}   result_format=timedelta
    Collections.Set To Dictionary   ${P_START_TIME}   gnb_${gnb_id}   ${start_time}
    Set Test Variable   ${P_START_TIME}


Wait until the current Measurement Period stops
    [Documentation]
    ...
    ...    | gnb_id             | Id/Number of gNB                      |
    ...    | component          | options : DU/CU) If gnb type is aic   |
    ...    | additional_time    | additional seconds for waiting        |
    ...
    [Arguments]   ${gnb_id}=0   ${component}=DU   ${additional_time}=30
    ${start_time}     Get Start Time from Test   gnb_id=${gnb_id}
    ${meas_period}    Get Measurement Period from GNB   gnb_id=${gnb_id}   component=${component}
    ${current_time}   DateTime.Get Current Date   result_format=%H:%M:%S
    ${current_time}   DateTime.Convert Time   ${current_time}   result_format=timedelta
    ${time_delay}     Evaluate   ${current_time.total_seconds()}-${start_time.total_seconds()}
    Return From Keyword If   ${time_delay}>=${meas_period}
    pm_internal.wait_next_meas_period   meas_period=${meas_period}   add_time=${additional_time}   with_console_output=${P_console}


Verify PM Counter Reference Table
    [Documentation]
    ...     Keyword for very descriptive pm counter checking. Expected is a pm_counter List, containing the pm counter,
    ...     the compare operation, an expected value to compare against as well as a description.
    ...
    ...     With this Keyword PM Counters can be checked in the following way:
    ...
    ...     | ${reference_table}    Create List
    ...     | ...   M55300C01028  ==  0       Successful PDSCH transmissions by initial transmission with 64QAM MCS table using MCS 28
    ...     | ...   M55300C02028  ==  0       Successful PDSCH transmissions by any transmission with 64QAM MCS table using MCS 28
    ...     | ...   M55300C03028  ==  0       Unsuccessful PDSCH transmissions by last HARQ reTx with 64QAM MCS table using MCS 28
    ...     | ...   M55300C04027  >=  400000  PDSCH initial transmissions with 256QAM MCS table using MCS 27
    ...     | ...   M55300C05027  >=  400000  Successful PDSCH transmissions by initial transmission with 256QAM MCS table using MCS 27
    ...     | ...   M55300C06027  >=  400000  Successful PDSCH transmissions by any transmission with 256QAM MCS table using MCS 27
    ...     | ...   M55300C07027  <=  100     Unsuccessful PDSCH transmissions by last HARQ reTx with 256QAM MCS table using MCS 27
    ...     | ...   M55113C01006  ==  0       Number of UE Context Modification Required received (RLC retr)
    ...     | ...   M55116C00004  ==  0       Number of UE Context Modification Required with cause Radio Network Layer / radio link failure
    ...     | Verify PM Counter Reference table    reference_table=${reference_table}  pm_dir=/path/to/pm/  cell_id=1

    [Arguments]   ${reference_table}   ${pm_dir}   ${distname_suffix}=${None}

    pm_internal.validate_pm_counter_reference_table   reference_table=${reference_table}
    ...   pm_dir=${pm_dir}
    ...   distname_suffix=${distname_suffix}


Analyze PM Counters
    [Documentation]
    ...  Analyse PM Counters based on given given expected values and index. Index=0 is the last measurement.
    ...  The output of the keyword is a pass or a fail based on the parameters under evaluation
    ...
    ...  | abs_tol      | is the absolute tolerance in same units as the counter.                                           |
    ...  | rel_tol      | is the relative tolerance used as multiplier when calculating verdict. Example: 0.1 is 10%.       |
    ...  | pi_expected  | is a dictionary where PM Counter name as key and the expected value of the counter is the value   |
    ...  | index        | is the position of the counter interval that needs to be analyzed.                                |
    ...  | ..           | By default the last or the latest counter interval is analyzed.                                   |
    ...  | ..           | index position 1 means the 2nd last counter interval is analyzed                                  |
    ...  | regex        | is a regular expression which identifies a counter                                                |
    ...  | ..           | (Eg. regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+)                                               |
    ...  | pi_dir       | directory where the PM Counter .xml files are located                                             |
    ...  | ru_id        | This is the RadioUnit under Test.                                                                 |
    ...
    [Arguments]   ${regex}   ${pi_dir}   ${pi_expected}   ${index}=0   ${abs_tol}=0   ${rel_tol}=0   ${gnb_id}=0   ${ru_id}=0
    ${pi_list}   Collections.Get Dictionary Keys   ${pi_expected}
    ${pi_dict}   Extract PM Counter Values from PM XML Files   pi_list=${pi_list}   pi_dir=${pi_dir}   gnb_id=${gnb_id}   index=${index}
    ${current_timestamp}   pm_internal.get_timestamp   pi_dict=${pi_dict}   index=${index}
    BuiltIn.Log    ${\n}Counters sampled at ${current_timestamp} GMT   console=${P_console}
    ${distName_params}   gnb.Get distNames from gNB SCF   regex=${regex}   gnb_id=${gnb_id}
    Collections.Sort List   ${distName_params}

    FOR   ${pi}   IN   @{pi_list}
       ${pi_value}   pm_internal.get_counter_value   pi_dict=${pi_dict}   pi=${pi}   dist_name=${distName_params[${ru_id}]}   index=${index}
       BuiltIn.Log   Value of ${pi} is ${pi_value}   console=${P_console}
       Run Keyword If   ${pi_value}==${None}   Run Keyword And Continue On Failure
       ...   Fail   There are empty counters that can't be validated
       Continue For Loop If   ${pi_value}==${None}

       ${verdict}   pm_internal.compare_values
       ...   observed=${pi_value}
       ...   shall=&{pi_expected}[${pi}]
       ...   rel_tolerance=${rel_tol}
       ...   abs_tolerance=${abs_tol}
       Run Keyword And Continue On Failure
       ...   Should Contain   ${verdict}   Passed
       ...   msg=Counter check failed for ${pi}: ${pi_value}=!&{pi_expected}[${pi}]   values=False
    END

Get Counter Value
    [Documentation]
    ...  Get counter values for either one or a list of PM Counters
    ...  The output of the keyword is in the form of a dictionary. The format depends on the type of the index variable.
    ...
    ...  | pi_dir       | Directory path where PM Counter XML files are stored                                                                   |
    ...  | dist_name    | The desired dist_name of the cell who's PM Counters are of interest                                                    |
    ...  | pi_list      | List of PM Counters to be extracted                                                                                    |
    ...  | index        | is the position of the counter interval that needs to be analyzed. (Index can either be a string or a list of strings) |
    ...  By default the last or the latest counter interval is analyzed. index position 1 means the 2nd last counter interval is analyzed.
    ...  The output will be a dictionary where Key is the PM Counter name and value is the Value of the PM Counter.
    ...  Index can be a list of strings for e.g.
    ...  | ${index_list}=  Create List    0    1    2    3
    ...  In this case the counter values from the last 4 intervals will be extracted and the output will be a
    ...  The output will be a dictionary of dictionaries for e.g. {u'0': {u'M55308C02001': 0, u'M55308C02000': 0}}
    ...  where the key is the index and the value is a dictionary containing corrosponding PM Counter values
    ...
    [Arguments]   ${pi_dir}   ${dist_name}   ${pi_list}   ${index}=0   ${gnb_id}=0
    ${pi_dict}   Extract PM Counter Values from PM XML Files   pi_list=${pi_list}   pi_dir=${pi_dir}   gnb_id=${gnb_id}   index=${index}
    ${actual_pm_values}   pm_internal.get_actual_pm_values   pi_dict=${pi_dict}   pi_list=${pi_list}   dist_name=${dist_name}   index=${index}
    [Return]   ${actual_pm_values}


Extract PM Counter Values from PM XML Files
    [Documentation]
    ...
    ...    *Scope* Internal
    ...
    ...    *Returns* Extracted PM counters from xml files
    ...
    [Arguments]   ${pi_dir}   ${pi_list}   ${gnb_id}=0   ${index}=0
    log    ${index}
    ${pi_file_pattern}   Set Variable If   '${tl_info.deployment_type(${gnb_id})}'=='aic'   A20*   PM.BTS-*
    ${pi_dict}   pm_internal.get_pi_dict
    ...   pi_dir=${pi_dir}
    ...   pi_list=${pi_list}
    ...   pi_file_pattern=${pi_file_pattern}
    [Return]   ${pi_dict}


Get Measurement Period from GNB
    [Documentation]
    ...
    ...    *Scope* Internal
    ...
    ...    *Returns* Measurement period in second
    ...
    [Arguments]   ${gnb_id}=0   ${component}=DU
    ${meas_period}   Get Variable Value   ${P_MEAS_PERIOD.gnb_${gnb_id}}
    Run Keyword If   '${meas_period}'=='None'
    ...   Fetch Measurement Period from SCF   gnb_id=${gnb_id}   component=${component}
    [Return]   ${P_MEAS_PERIOD.gnb_${gnb_id}}


Fetch Measurement Period from SCF
    [Documentation]
    ...
    ...    Collect Measurement Period from SCF
    ...
    ...    *Scope* Internal
    ...
    [Arguments]   ${gnb_id}=0  ${component}=DU
    ${scf_path}   gnb.Get SCF from gNB   gnb_id=${gnb_id}   component=${component}
    scf.Load SCF   file_path=${scf_path}
    ${meas_period}   scf.Get Value from SCF   p_name=reportingIntervalPm
    ${meas_period}   Evaluate   int(${meas_period[:-3]}) * 60
    Collections.Set To Dictionary   ${P_MEAS_PERIOD}   gnb_${gnb_id}   ${meas_period}
    Set Suite Variable   ${P_MEAS_PERIOD}


Get Start Time from Test
    [Documentation]
    ...
    ...    *Scope* Internal
    ...
    ...    *Returns* start time from keyword "Wait until the next Measurement Period starts"
    ...
    [Arguments]   ${gnb_id}=0
    ${start_time}   Get Variable Value   ${P_START_TIME.gnb_${gnb_id}}
    ${msg}   Catenate   No start time found,
    ...   use 'Wait until the next Measurement Period starts' first,
    ...   before calling 'Wait until the current Measurement Period stops'
    Run Keyword If   '${start_time}'=='None'   Fail   ${msg}
    [Return]    ${start_time}


Check if CU http port is configured for classical GNB
    [Documentation]
    ...
    ...    Temporary Check for Classical BTS, because http port is an optional parameter, maybe another Collectors also need this check
    ...
    ...    *Scope* Internal
    ...
    [Arguments]   ${gnb_id}=0
    ${http_port}   Get Variable Value   ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.port}
    Run Keyword If   '${http_port}'=='80'   BuiltIn.Log
    ...          Please specify cu.oam_http_connection_details.port to 443 in your testline config for Collectors
    ...          level=WARN
    ...   ELSE   Return From Keyword
    Set Suite Variable   ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.port}   ${443}


Wait for a certain Measurement Period to start
    [Documentation]
    ...    this keyword could be used to wait for certain measurement period to start the test case scenario
    ...    If Counters are collected every 15 mints and test case needs 5 mints then you can start the function
    ...    at time (15-5=10) or (30-5=25)
    ...
    ...    | meas_periods   | (default [10, 25, 40, 55]) list of minutes when the measurement can start |
    ...    | gnb_id         |  Id/Number of gNB                                                         |
    ...
    [Arguments]   ${gnb_id}=0   ${meas_period_list}=0
    pm_internal.wait_certain_meas_period   with_console_output=${P_console}   meas_periods=${meas_period_list}
    ${start_time}   DateTime.Get Current Date   result_format=%H:%M:%S
    BuiltIn.Log   Start Time Of Measurement Period = ${start_time}   level=DEBUG
    ${start_time}   DateTime.Convert Time   ${start_time}   result_format=timedelta
    Collections.Set To Dictionary   ${P_START_TIME}   gnb_${gnb_id}   ${start_time}
    Set Test Variable   ${P_START_TIME}
