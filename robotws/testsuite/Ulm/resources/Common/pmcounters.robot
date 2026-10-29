*** Settings ***

Documentation
...   This robot resource file holds keywords to fetch and evaluate PM countes.
...   Don't use deprecated KWs for new test scripts!

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
Library     python/connect.py            WITH NAME    connect_py
Library     python/testline_information.py

Resource    gnb.robot
Resource    testline.robot

*** Variables ***
&{P_MEAS_PERIOD}        &{EMPTY}
&{P_START_TIME}         &{EMPTY}
${P_console}            ${False}

*** Keywords ***
Convert PM Files To CSV
    [Documentation]
    ...
    ...    | file_path          | Collected PM counters file path, should be a folder                    |
    ...    | param file_pattern | needed PM file pattern, if ${None} is it will be defined automatically |
    ...
    ...    *Returns*    Location of converted PM counter file
    ...
    [Arguments]   ${file_path}   ${file_pattern}=${None}
    ${file_pattern}   Set Variable If
    ...   '${file_pattern}'=='${None}' and '${tl_info.deployment_type()}'=='classical'   PM*BTS*ANY*
    ...   $file_pattern is not None                                                      ${file_pattern}

    ${nidd_path}    pm_internal.Get Nidd File Name Path

    pmtocsv.Create PM To CSV Converter
    ...   name=test_converter
    ...   file_path_pattern=${file_path}/${file_pattern}.xml
    ...   delimiter=;
    ...   output_file_name=${file_path}/pmCounters.csv
    ...   nidd_path=${nidd_path}
    pmtocsv.Convert   test_converter
    RETURN   ${file_path}/pmCounters.csv


Collect PM Counter
    [Documentation]
    ...    | gnb_id          | Id/Number of gNB                                            |
    ...    | collector_alias | alias name for collector                                    |
    ...    | target_dir      | save PM Counter files to path                               |
    ...    | for_last        | optional create collector argument                          |
    ...    | intervals       | optional create collector argument                          |
    ...    | timeout         | optional create collector argument                          |
    ...    |                 | See KW 'create_pm_collector' from taf.collectors.pmcounters |
    ...
    ...    *Returns* Location of collected PM counter files
    ...
    [Arguments]   ${gnb_id}=0   ${collector_alias}=gnb_pm_counters   ${target_dir}=None
    ...   ${for_last}=${NONE}   ${intervals}=${NONE}   ${timeout}=${NONE}

    IF   '${target_dir}'=='None'
        ${target_dir}   testline.Get Testcase Log Directory
    END

    Check If CU HTTP Port Is Configured For Classical GNB   ${gnb_id}

    IF   '${tl_info.deployment_type(${gnb_id})}'=='classical'
        ${webservice}    connect_py.Get Webservice For Collector    tl=${tl}   gnb_id=${gnb_id}
    ELSE
        FAIL    Unsupported Node Type!
    END

    collect_pm.Create PM Collector   name=${collector_alias}    webservice=${webservice}
    ...   for_last=${for_last}   intervals=${intervals}   timeout=${timeout}
    collect_pm.Setup Collectors      names=${collector_alias}
    collect_pm.Collect Collectors    names=${collector_alias}   target_dir=${target_dir}
    collect_pm.Teardown Collectors   names=${collector_alias}
    RETURN   ${target_dir}/${collector_alias}


Check PM Counter Value Equal
    [Documentation]    [DEPRECATED]
    ...        checks that the value of a counter in the last reporting period is equal to a given value
    ...
    ...        | expected_value     | is the value compared to counter value                                                |
    ...        | pm_files_location  | is the path to PM files                                                               |
    ...        | pi_id              | is the PM counter ID e.g. M55112C03001                                                |
    ...        | moc                | is the class including the counter e.g. NRCELL-1                                      |
    ...        | ..                 | NOTE: it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1    |
    ...
    [Arguments]   ${expected_value}   ${pm_files_location}   ${pi_id}   ${moc}
    Log    Keyword is deprecated. Please use "Verify PM Counter Reference Table" keywords.    console=${True}    level=WARN
    ${pi_value}   Get PM Counter Value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${expected_value}   Convert To Integer   ${expected_value}
    Should Be Equal   ${pi_value}   ${expected_value}   PM Counter ${pi_id} expected to be == ${expected_value} but is ${pi_value}


Check PM Counter Value Not Equal
    [Documentation]    [DEPRECATED]
    ...        checks that the value of a counter in the last reporting period is equal to a given value
    ...
    ...        | not_expected_value | is the value compared to counter value                                                |
    ...        | pm_files_location  | is the path to PM files                                                               |
    ...        | pi_id              | is the PM counter ID e.g. M55112C03001                                                |
    ...        | moc                | is the class including the counter e.g. NRCELL-1                                      |
    ...        | ..                 | NOTE: it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1    |
    ...
    [Arguments]   ${not_expected_value}   ${pm_files_location}   ${pi_id}   ${moc}
    Log    Keyword is deprecated. Please use "Verify PM Counter Reference Table" keywords.    console=${True}    level=WARN
    ${pi_value}   Get PM Counter Value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${not_expected_value}   Convert To Integer   ${not_expected_value}
    Should Not Be Equal   ${pi_value}   ${not_expected_value}   PM Counter ${pi_id} expected to be != ${not_expected_value} but is ${pi_value}


Check PM Counter Value Bigger Than
    [Documentation]    [DEPRECATED]
    ...        checks that the value of a counter in the last reporting period is bigger than a given value
    ...
    ...        | expected_value     | is the value compared to counter value                                                |
    ...        | pm_files_location  | is the path to PM files                                                               |
    ...        | pi_id              | is the PM counter ID e.g. M55112C03001                                                |
    ...        | moc                | is the class including the counter e.g. NRCELL-1                                      |
    ...        | ..                 | NOTE: it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1    |
    ...
    [Arguments]   ${expected_value}   ${pm_files_location}   ${pi_id}   ${moc}
    Log    Keyword is deprecated. Please use "Verify PM Counter Reference Table" keywords.    console=${True}    level=WARN
    ${pi_value}   Get PM Counter Value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${expected_value}   Convert To Integer   ${expected_value}
    Should Be True   ${pi_value}>${expected_value}   PM Counter ${pi_id} expected to be > ${expected_value} but is ${pi_value}


Check PM Counter Value Equal Or Bigger Than
    [Documentation]    [DEPRECATED]
    ...        checks that the value of a counter in the last reporting period is equal or bigger than a given value
    ...
    ...        | expected_value     | is the value compared to counter value                                                |
    ...        | pm_files_location  | is the path to PM files                                                               |
    ...        | pi_id              | is the PM counter ID e.g. M55112C03001                                                |
    ...        | moc                | is the class including the counter e.g. NRCELL-1                                      |
    ...        | ..                 | NOTE: it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1    |
    ...
    [Arguments]   ${expected_value}   ${pm_files_location}   ${pi_id}   ${moc}
    Log    Keyword is deprecated. Please use "Verify PM Counter Reference Table" keywords.    console=${True}    level=WARN
    ${pi_value}   Get PM Counter Value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${expected_value}   Convert To Integer   ${expected_value}
    Should Be True   ${pi_value}>=${expected_value}   PM Counter ${pi_id} expected to be >= ${expected_value} but is ${pi_value}


Check PM Counter Value Smaller Than
    [Documentation]    [DEPRECATED]
    ...        checks that the value of a counter in the last reporting period is smaller than a given value
    ...
    ...        | expected_value     | is the value compared to counter value                                                |
    ...        | pm_files_location  | is the path to PM files                                                               |
    ...        | pi_id              | is the PM counter ID e.g. M55112C03001                                                |
    ...        | moc                | is the class including the counter e.g. NRCELL-1                                      |
    ...        | ..                 | NOTE: it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1    |
    ...
    [Arguments]   ${expected_value}   ${pm_files_location}   ${pi_id}   ${moc}
    Log    Keyword is deprecated. Please use "Verify PM Counter Reference Table" keywords.    console=${True}    level=WARN
    ${pi_value}   Get PM Counter Value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${expected_value}   Convert To Integer   ${expected_value}
    Should Be True   ${pi_value}<${expected_value}   PM Counter ${pi_id} expected to be < ${expected_value} but is ${pi_value}


Check PM Counter Value Equal Or Smaller Than
    [Documentation]    [DEPRECATED]
    ...        checks that the value of a counter in the last reporting period is equal or smaller than a given value
    ...
    ...        | expected_value     | is the value compared to counter value                                                |
    ...        | pm_files_location  | is the path to PM files                                                               |
    ...        | pi_id              | is the PM counter ID e.g. M55112C03001                                                |
    ...        | moc                | is the class including the counter e.g. NRCELL-1                                      |
    ...        | ..                 | NOTE: it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1    |
    ...
    [Arguments]  ${expected_value}   ${pm_files_location}   ${pi_id}   ${moc}
    Log    Keyword is deprecated. Please use "Verify PM Counter Reference Table" keywords.    console=${True}    level=WARN
    ${pi_value}   Get PM Counter Value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${expected_value}   Convert To Integer   ${expected_value}
    Should Be True  ${pi_value} <= ${expected_value}     PM Counter ${pi_id} expected to be <= ${expected_value} but is ${pi_value}


Check PM Counter Value In Range
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
    ${pi_value}   Get PM Counter Value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${expected_value}   Convert To Integer    ${expected_value}
    ${upper_value}   Evaluate   ${expected_value} + ${expected_value} * ${rel_tolerance} + ${abs_tolerance}
    ${lower_value}   Evaluate   ${expected_value} - ${expected_value} * ${rel_tolerance} - ${abs_tolerance}
    Should Be True   ${lower_value} <= ${pi_value} <= ${upper_value}   PM Counter ${pi_id} isn't in expected range


Get PM Counter Value
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
    ${PM_report_dict_list}   check_pm.Get Pi Value
    ...   pi_list=${pi_list}
    ...   pi_dir=${pm_files_location}
    ...   pi_file_pattern=PM*

    ${last_report}      Collections.Get From List           ${PM_report_dict_list}   -1
    ${pi_dict}          Collections.Get Dictionary Values   ${last_report}
    ${first_pi}         Collections.Get From List           ${pi_dict}               0
    ${cell_dict_list}   Collections.Get Dictionary Values   ${first_pi}
    ${cell_dict}        Collections.Get From List           ${cell_dict_list}        0
    ${moc_list}         Collections.Get Dictionary Keys     ${cell_dict}

    FOR   ${key}   IN     @{moc_list}
       ${key_is_moc}      Run Keyword And Return Status   Should End With   ${key}   ${moc}
       ${full_moc}        Set Variable If                 ${key_is_moc}     ${key}   ${None}
       IF   $full_moc is not None   BREAK
    END

    IF   $full_moc is None   FAIL   The counter ${pi_list} wasn't found in the last PM report for MO ${moc}!

    ${pi_value}      Collections.Get From Dictionary   ${cell_dict}   ${full_moc}
    Log      ${pi_id} value: ${pi_value}       console=${P_console}
    RETURN   ${pi_value}


Wait Until The Next Measurement Period Starts
    [Documentation]
    ...    this keyword could be used as wait for current Measurement Period stops
    ...
    ...    | gnb_id             | Id/Number of gNB                      |
    ...    | additional_time    | additional seconds for waiting        |
    ...
    [Arguments]   ${gnb_id}=0   ${additional_time}=30
    ${meas_period}   Fetch Measurement Period From SCF   gnb_id=${gnb_id}
    Log To Console    ${\n}The reportingIntervalPm is set to ${meas_period} Sec.
    pm_internal.Wait Next Meas Period   meas_period=${meas_period}   add_time=${additional_time}   with_console_output=${P_console}
    ${start_time}   DateTime.Get Current Date   result_format=%H:%M:%S
    Log   Start Time Of Measurement Period = ${start_time}   level=DEBUG
    ${start_time}   DateTime.Convert Time   ${start_time}   result_format=timedelta
    Collections.Set To Dictionary   ${P_START_TIME}   gnb_${gnb_id}   ${start_time}
    Set Test Variable   ${P_START_TIME}


Wait Until The Current Measurement Period Stops
    [Documentation]
    ...
    ...    | gnb_id             | Id/Number of gNB                      |
    ...    | additional_time    | additional seconds for waiting        |
    ...
    [Arguments]   ${gnb_id}=0   ${additional_time}=30
    ${start_time}     Get Start Time From Test   gnb_id=${gnb_id}
    ${meas_period}    Fetch Measurement Period From SCF   gnb_id=${gnb_id}
    ${current_time}   DateTime.Get Current Date   result_format=%H:%M:%S
    ${current_time}   DateTime.Convert Time   ${current_time}   result_format=timedelta
    ${time_delay}     Evaluate   ${current_time.total_seconds()}-${start_time.total_seconds()}
    IF   ${time_delay}>=${meas_period}   RETURN
    pm_internal.Wait Next Meas Period   meas_period=${meas_period}   add_time=${additional_time}   with_console_output=${P_console}


Verify PM Counter Reference Table
    [Documentation]
    ...     Keyword for very descriptive pm counter checking. Expected is a pm_counter List, containing the pm counter,
    ...     the compare operation, an expected value to compare against as well as a description. The reference table can
    ...     also have comparisons between counters and aritmetic expressions. In case you want to compare counters
    ...     from different managed objects, you can give the distname inside the table (see second example below). In
    ...     that case the distname_suffix argument cannot be given. Otherwise keyword will cause the test to fail.
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
    ...     | Verify PM Counter Reference table    reference_table=${reference_table}  pm_dir=/path/to/pm/  distname_suffix=1
    ...
    ...     Example with distnames in table and comparing counters between different distnames:
    ...
    ...     | ${reference_table_distnames}    Create List
    ...     | ...   (NRCELL-1)M55300C01028  ==  0                             Successful PDSCH tx by initial tx 64QAM MCS 28 NRCELL-1
    ...     | ...   (NRCELL-2)M55300C02028  ==  0                             Successful PDSCH tx by any tx 64QAM MCS 28 (NRCELL-3)
    ...     | ...   (NRCELL-1)M55300C01028  <=  (NRCELL-2)M55300C01028 + 20   Comparison same counter in NRCELL-1 and NRCELL-2
    ...     | ...   (NRCELL-2)M55300C02028 + (NRCELL-3)M55300C02028  ==  100  Adding same counter in NRCELL-2 and NRCELL-1 should equal 100
    ...     | Verify PM Counter Reference table    reference_table=${reference_table_distnames}  pm_dir=/path/to/pm/
    ...
    ...
    ...    | reference_table    | list with reference table. format described above                              |
    ...    | pm_dir             | directory where the PM Counter .xml files are located                          |
    ...    | distname_suffix    | suffix of distname in case it is not provided in the table.                    |
    ...    |                    | To distinguish NRCELL-1 from NRCELL-11 use e.g. distname_suffix=-1             |
    ...    | meas_index         | index to the measurement period. 0 is the last 1 second last etc.              |
    ...    | interval           | list of allowed intervals or comma-separated allowed interval values e.g. 5,15 |
    ...
    [Arguments]   ${reference_table}   ${pm_dir}   ${distname_suffix}=${None}   ${meas_index}=0   ${interval}=${None}

    OperatingSystem.Directory Should Not Be Empty     ${pm_dir}
    pm_internal.Validate PM Counter Reference Table   reference_table=${reference_table}
    ...   pm_dir=${pm_dir}
    ...   distname_suffix=${distname_suffix}
    ...   meas_index=${meas_index}
    ...   interval=${interval}


Analyze PM Counters
    [Documentation]
    ...  Analyse PM Counters based on given given expected values and index. Index=0 is the last measurement.
    ...  The output of the keyword is a pass or a fail based on the parameters under evaluation
    ...
    ...  | abs_tol      | is the absolute tolerance in same units as the counter.                                         |
    ...  | rel_tol      | is the relative tolerance used as multiplier when calculating verdict. Example: 0.1 is 10%.     |
    ...  | pi_expected  | is a dictionary where PM Counter name as key and the expected value of the counter is the value |
    ...  | index        | is the position of the counter interval that needs to be analyzed.                              |
    ...  | ..           | By default the last or the latest counter interval is analyzed.                                 |
    ...  | ..           | index position 1 means the 2nd last counter interval is analyzed                                |
    ...  | regex        | is a regular expression which identifies a counter                                              |
    ...  | ..           | (Eg. regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+)                                             |
    ...  | pi_dir       | directory where the PM Counter .xml files are located                                           |
    ...  | gnb_id       | This is the GNB under Test.                                                                     |
    ...  | ru_id        | This is the RadioUnit under Test.                                                               |
    ...
    [Arguments]   ${regex}   ${pi_dir}   ${pi_expected}   ${index}=0   ${abs_tol}=0   ${rel_tol}=0   ${gnb_id}=0   ${ru_id}=0
    ${pi_list}   Collections.Get Dictionary Keys   ${pi_expected}
    ${pi_dict}   Extract PM Counter Values From PM XML Files   pi_list=${pi_list}   pi_dir=${pi_dir}
    ${current_timestamp}   pm_internal.Get Timestamp   pi_dict=${pi_dict}   index=${index}
    Log    ${\n}Counters sampled at ${current_timestamp} GMT   console=${P_console}
    ${distName_params}   gnb.Get DistNames From GNB DU   regex=${regex}   gnb_id=${gnb_id}
    Collections.Sort List   ${distName_params}

    FOR   ${pi}   IN   @{pi_list}
       ${pi_value}   pm_internal.Get Counter Value   pi_dict=${pi_dict}   pi=${pi}   dist_name=${distName_params[${ru_id}]}   index=${index}
       Log   Value of ${pi} is ${pi_value}   console=${P_console}
       IF   ${pi_value}==${None}   Run Keyword And Continue On Failure
       ...   Fail   There are empty counters that can't be validated
       IF   ${pi_value}==${None}   CONTINUE

       ${verdict}   pm_internal.Compare Values
       ...   observed=${pi_value}
       ...   shall=${pi_expected}[${pi}]
       ...   rel_tolerance=${rel_tol}
       ...   abs_tolerance=${abs_tol}
       Run Keyword And Continue On Failure
       ...   Should Contain   ${verdict}   Passed
       ...   msg=Counter check failed for ${pi}: ${pi_value}=!${pi_expected}[${pi}]   values=False
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
    [Arguments]   ${pi_dir}   ${dist_name}   ${pi_list}   ${index}=0
    ${pi_dict}   Extract PM Counter Values From PM XML Files   pi_list=${pi_list}   pi_dir=${pi_dir}
    ${actual_pm_values}   pm_internal.Get Actual PM Values   pi_dict=${pi_dict}   pi_list=${pi_list}   dist_name=${dist_name}   index=${index}
    RETURN   ${actual_pm_values}


Extract PM Counter Values From PM XML Files
    [Documentation]
    ...
    ...    *Scope* Internal
    ...
    ...    *Returns* Extracted PM counters from xml files
    ...
    [Arguments]   ${pi_dir}   ${pi_list}
    ${pi_file_pattern}   Set Variable   PM.BTS-*
    ${pi_dict}   pm_internal.Get Pi Dict
    ...   pi_dir=${pi_dir}
    ...   pi_list=${pi_list}
    ...   pi_file_pattern=${pi_file_pattern}
    RETURN   ${pi_dict}


Fetch Measurement Period From SCF
    [Documentation]
    ...
    ...    Collect Measurement Period from SCF
    ...
    ...    *Scope* Internal
    ...
    [Arguments]   ${gnb_id}=0
    ${scf_path}   gnb.Get SCF From GNB   gnb_id=${gnb_id}
    scf.Load SCF   file_path=${scf_path}
    ${meas_period}   scf.Get Value From SCF   p_name=reportingIntervalPm
    ${meas_period}   Evaluate   int(${meas_period[:-3]}) * 60
    Collections.Set To Dictionary   ${P_MEAS_PERIOD}   gnb_${gnb_id}   ${meas_period}
    Set Suite Variable   ${P_MEAS_PERIOD}
    RETURN   ${P_MEAS_PERIOD.gnb_${gnb_id}}


Get Start Time From Test
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
    IF   '${start_time}'=='None'   Fail   ${msg}
    RETURN    ${start_time}


Check If CU HTTP Port Is Configured For Classical GNB
    [Documentation]
    ...
    ...    Temporary Check for Classical BTS, because http port is an optional parameter, maybe another Collectors also need this check
    ...
    ...    *Scope* Internal
    ...
    [Arguments]   ${gnb_id}=0
    ${http_port}   Get Variable Value   ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.port}

    IF   '${http_port}'=='80'
        Log       Please specify cu.oam_http_connection_details.port to 443 in your testline config for Collectors     level=WARN
    ELSE
        RETURN
    END
    Set Suite Variable   ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.port}   ${443}


Wait For A Certain Measurement Period To Start
    [Documentation]
    ...    this keyword could be used to wait for certain measurement period to start the test case scenario
    ...    If Counters are collected every 15 mints and test case needs 5 mints then you can start the function
    ...    at time (15-5=10) or (30-5=25)
    ...
    ...    | meas_periods   | (default [10, 25, 40, 55]) list of minutes when the measurement can start |
    ...    | gnb_id         |  Id/Number of gNB                                                         |
    ...
    [Arguments]   ${gnb_id}=0   ${meas_period_list}=0
    pm_internal.Wait Certain Meas Period   with_console_output=${P_console}   meas_periods=${meas_period_list}
    ${start_time}   DateTime.Get Current Date   result_format=%H:%M:%S
    Log   Start Time Of Measurement Period = ${start_time}   level=DEBUG
    ${start_time}   DateTime.Convert Time   ${start_time}   result_format=timedelta
    Collections.Set To Dictionary   ${P_START_TIME}   gnb_${gnb_id}   ${start_time}
    Set Test Variable   ${P_START_TIME}
