*** Settings ***

Documentation
...   This robot resource file holds keywords to fetch and evaluate PM counters.
...   Don't use deprecated KWs for new test scripts!

Library     String
Library     DateTime
Library     OperatingSystem
Library     Collections

Library     taf.config.scf               WITH NAME    scf
Library     taf.collectors.pmcounters    WITH NAME    collect_pm
Library     taf.converters.pmtocsv       WITH NAME    pmtocsv
Library     taf.analyzer.pmcounter       WITH NAME    check_pm
Library     ../python/connect.py         WITH NAME    connect_py
Library     ../python/tools.py           WITH NAME    pm_tools

Resource    testcase-Keywords.robot
Resource    TARF-Keywords.robot

*** Variables ***
&{P_MEAS_PERIOD}        &{EMPTY}
&{P_START_TIME}         &{EMPTY}
${P_console}            ${False}

*** Keywords ***
Convert PM files to CSV
    [Documentation]
    ...
    ...    | file_path          | Collected PM counters file path, should be a folder                                           |
    ...    | param file_pattern | needed PM file pattern, if ${None} is it will be defined automatically for AiC  and Clasical  |
    ...
    ...    *Returns*    Location of converted PM counter file
    ...
    [Arguments]   ${file_path}   ${file_pattern}=${None}
    ${file_pattern}   Set Variable    PM*BTS*ANY*

    ${nidd_path}    pm_tools.get_nidd_file_name_path
    ${timestamp_msg}=   DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    BuiltIn.log     [${timestamp_msg}] Create PM to CSV Converter ${file_path}/${file_pattern}.xml    level=INFO    console=yes
    pmtocsv.Create PM to CSV Converter
    ...   name=test_converter
    ...   file_path_pattern=${file_path}/${file_pattern}.xml
    ...   delimiter=;
    ...   output_file_name=${file_path}/pmCounters.csv
    ...   nidd_path=${nidd_path}
    pmtocsv.Convert   test_converter
    [Return]   ${file_path}/pmCounters.csv


Collect PM Counter
    [Documentation]
    ...    | gnb_id             | Id/Number of gNB                                          |
    ...    | collector_alias    | alias name for collector                                  |
    ...    | target_dir         | save PM Counter files to path                             |
    ...    | component          | options : DU/CU) If oam type is cloud coam for vRAN 1.0   |
    ...
    ...    *Returns* Location of collected PM counter files
    ...
    [Arguments]   ${gnb_id}=0   ${du_id}=0   ${collector_alias}=gnb_pm_counters   ${target_dir}=None    ${duration}=10 minutes

    BuiltIn.log     du_id = ${du_id}
    ${target_dir}   Run Keyword If   '${target_dir}'=='None'   testcase-Keywords.Get Testcase Log Directory
    ...   ELSE      Set Variable     ${target_dir}

    Check if CU http port is configured for classical GNB   ${gnb_id}

    ${webservice}     connect_py.Get Webservice for Collector    tl=${tl}   gnb_id=${gnb_id}

    collect_pm.Create PM Collector   name=${collector_alias}    webservice=${webservice}    for_last=${duration}
    collect_pm.Setup Collectors      names=${collector_alias}
    collect_pm.Collect Collectors    names=${collector_alias}   target_dir=${target_dir}
    collect_pm.Teardown Collectors   names=${collector_alias}
    [Return]   ${target_dir}/${collector_alias}


Check PM counter value equal
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
    BuiltIn.Log    Keyword is deprecated. Please use "Verify PM Counter Reference Table" keywords.    console=${True}
    ${pi_value}   Get PM counter value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${expected_value}   Convert To Integer   ${expected_value}
    Should Be Equal   ${pi_value}   ${expected_value}   PM Counter ${pi_id} expected to be == ${expected_value} but is ${pi_value}


Check PM counter value not equal
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
    BuiltIn.Log    Keyword is deprecated. Please use "Verify PM Counter Reference Table" keywords.    console=${True}
    ${pi_value}   Get PM counter value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${not_expected_value}   Convert To Integer   ${not_expected_value}
    Should Not Be Equal   ${pi_value}   ${not_expected_value}   PM Counter ${pi_id} expected to be != ${not_expected_value} but is ${pi_value}


Check PM counter value bigger than
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
    BuiltIn.Log    Keyword is deprecated. Please use "Verify PM Counter Reference Table" keywords.    console=${True}
    ${pi_value}   Get PM counter value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${expected_value}   Convert To Integer   ${expected_value}
    Should Be True   ${pi_value}>${expected_value}   PM Counter ${pi_id} expected to be > ${expected_value} but is ${pi_value}


Check PM counter value equal or bigger than
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
    BuiltIn.Log    Keyword is deprecated. Please use "Verify PM Counter Reference Table" keywords.    console=${True}
    ${pi_value}   Get PM counter value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${expected_value}   Convert To Integer   ${expected_value}
    Should Be True   ${pi_value}>=${expected_value}   PM Counter ${pi_id} expected to be >= ${expected_value} but is ${pi_value}


Check PM counter value smaller than
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
    BuiltIn.Log    Keyword is deprecated. Please use "Verify PM Counter Reference Table" keywords.    console=${True}
    ${pi_value}   Get PM counter value   ${pm_files_location}   ${pi_id}   ${moc}
    ${pi_value}   Convert To Integer     ${pi_value}
    ${expected_value}   Convert To Integer   ${expected_value}
    Should Be True   ${pi_value}<${expected_value}   PM Counter ${pi_id} expected to be < ${expected_value} but is ${pi_value}


Check PM counter value equal or smaller than
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
    BuiltIn.Log    Keyword is deprecated. Please use "Verify PM Counter Reference Table" keywords.    console=${True}
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

    FOR   ${key}   IN     @{moc_list}
       ${key_is_moc}      Run Keyword And Return Status   Should End With   ${key}   ${moc}
       ${full_moc}        Set Variable If                 ${key_is_moc}     ${key}   ${None}
       Exit For Loop If   $full_moc is not None
    END

    Run Keyword If   $full_moc is None   FAIL
    ...   The counter ${pi_list} wasn't found in the last PM report for MO ${moc}!

    ${pi_value}      Collections.Get From Dictionary   ${cell_dict}   ${full_moc}
    BuiltIn.Log      ${pi_id} value: ${pi_value}       console=${P_console}
    [Return]   ${pi_value}


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
    ...     Example with distnames in table and comparing counters between different distanmes:
    ...
    ...     | ${reference_table_distnames}    Create List
    ...     | ...   (NRCELL-1)M55300C01028  ==  0                             Successful PDSCH tx by initial tx 64QAM MCS 28 NRCELL-1
    ...     | ...   (NRCELL-2)M55300C02028  ==  0                             Successful PDSCH tx by any tx 64QAM MCS 28 (NRCELL-3)
    ...     | ...   (NRCELL-1)M55300C01028  <=  (NRCELL-2)M55300C01028 + 20   Comparison same counter in NRCELL-1 and NRCELL-2
    ...     | ...   (NRCELL-2)M55300C02028 + (NRCELL-3)M55300C02028  ==  100  Adding same counter in NRCELL-2 and NRCELL-1 should equal 100
    ...     | Verify PM Counter Reference table    reference_table=${reference_table_distnames}  pm_dir=/path/to/pm/
    ...
    ...
    ...    | reference_table    | list with reference table. format described above                   |
    ...    | pm_dir             | directory where the PM Counter .xml files are located               |
    ...    | distname_suffix    | suffix of distname in case it is not provided in the table          |
    ...    | meas_index         | index to the measurement period. 0 is the last 1 second last etc. |
    ...
    [Arguments]   ${reference_table}   ${pm_dir}   ${distname_suffix}=${None}   ${meas_index}=0

    OperatingSystem.Directory Should Not Be Empty     ${pm_dir}
    pm_internal.validate_pm_counter_reference_table   reference_table=${reference_table}
    ...   pm_dir=${pm_dir}
    ...   distname_suffix=${distname_suffix}
    ...   meas_index=${meas_index}


Analyze PM Counters TO REMOVE
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
    [Arguments]   ${regex}   ${pi_dir}   ${pi_expected}   ${index}=0   ${abs_tol}=0   ${rel_tol}=0   ${du_id}=0   ${gnb_id}=0   ${ru_id}=0
    ${pi_list}   Collections.Get Dictionary Keys   ${pi_expected}
    ${pi_dict}   Extract PM Counter Values from PM XML Files   pi_list=${pi_list}   pi_dir=${pi_dir}   gnb_id=${gnb_id}
    ${current_timestamp}   pm_internal.get_timestamp   pi_dict=${pi_dict}   index=${index}
    BuiltIn.Log    ${\n}Counters sampled at ${current_timestamp} GMT   console=${P_console}
    ${distName_params}   gnb.Get distNames from gNB DU   regex=${regex}   du_id=${du_id}   gnb_id=${gnb_id}
    Collections.Sort List   ${distName_params}

    FOR   ${pi}   IN   @{pi_list}
       ${pi_value}   pm_internal.get_counter_value   pi_dict=${pi_dict}   pi=${pi}   dist_name=${distName_params[${ru_id}]}   index=${index}
       BuiltIn.Log   Value of ${pi} is ${pi_value}   console=${P_console}
       Run Keyword If   ${pi_value}==${None}   Run Keyword And Continue On Failure
       ...   Fail   There are empty counters that can't be validated
       Continue For Loop If   ${pi_value}==${None}

       ${verdict}   pm_internal.compare_values
       ...   observed=${pi_value}
       ...   shall=${pi_expected}[${pi}]
       ...   rel_tolerance=${rel_tol}
       ...   abs_tolerance=${abs_tol}
       Run Keyword And Continue On Failure
       ...   Should Contain   ${verdict}   Passed
       ...   msg=Counter check failed for ${pi}: ${pi_value}=!${pi_expected}[${pi}]   values=False
    END


Get Counter Value TO REMOVE
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
    ${pi_dict}   Extract PM Counter Values from PM XML Files   pi_list=${pi_list}   pi_dir=${pi_dir}   gnb_id=${gnb_id}
    ${actual_pm_values}   pm_internal.get_actual_pm_values   pi_dict=${pi_dict}   pi_list=${pi_list}   dist_name=${dist_name}   index=${index}
    [Return]   ${actual_pm_values}


Extract PM Counter Values from PM XML Files TO REMOVE
    [Documentation]
    ...
    ...    *Scope* Internal
    ...
    ...    *Returns* Extracted PM counters from xml files
    ...
    [Arguments]   ${pi_dir}   ${pi_list}   ${gnb_id}=0
    BuiltIn.log     gnb_id = ${gnb_id}
    ${pi_file_pattern}   Set Variable    PM.BTS-*
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
    [Arguments]   ${gnb_id}=0
    ${meas_period}   Get Variable Value   ${P_MEAS_PERIOD.gnb_${gnb_id}}
    Run Keyword If   '${meas_period}'=='None'
    ...   Fetch Measurement Period from SCF   gnb_id=${gnb_id}
    [Return]   ${P_MEAS_PERIOD.gnb_${gnb_id}}


Fetch Measurement Period from SCF
    [Documentation]
    ...
    ...    Collect Measurement Period from SCF
    ...
    ...    *Scope* Internal
    ...
    [Arguments]   ${gnb_id}=0
    ${scf_path}  TARF-Keywords.COAM Get SCF   local_dir_path=${LOG_PATH}   file=SCFC-gNB-${gnb_id}-DU.xml   alias=coam_gnb
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

