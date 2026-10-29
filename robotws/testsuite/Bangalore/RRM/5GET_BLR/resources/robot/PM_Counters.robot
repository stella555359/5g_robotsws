*** Settings ***
Documentation
...  AUTHOR          :   Kiran.G  kiran.1.g@nokia.com
...  MAINTAINER      :   Kiran.G  kiran.1.g@nokia.com
Library     String
Library     DateTime
Library     OperatingSystem
Library     taf.config.scf               WITH NAME    scf
Library     ../python/PM_Counters.py       WITH NAME    pm_internal
Library     ../python/Gnb.py              WITH NAME    gnb_lib
Library     taf.collectors.pmcounters    WITH NAME    collect_pm
Library     taf.converters.pmtocsv       WITH NAME    pmtocsv
Library     taf.analyzer.pmcounter       WITH NAME    check_pm

Resource    Gnb.robot
Resource    Testline.robot

*** Variables ***
&{P_MEAS_PERIOD}        &{EMPTY}
&{P_START_TIME}         &{EMPTY}
${P_console}            ${False}

*** Keywords ***

Convert PM files to CSV
    [Documentation]    :Author: Jing Liang
    ...
    ...    :param file_path: Collected PM counters file path, should be a folder
    ...    :param file_pattern: (default PM*BTS*ANY*) needed PM file pattern
    ...    :param nidd_file: (default Counters_5G19A.xml) needed nidd file located at robotws5g/resources/pmcounters/
    ...
    ...    :return: Location of converted PM counter file
    [Arguments]    ${file_path}    ${file_pattern}=PM*BTS*ANY*    ${nidd_file}=Counters_5G19A.xml
    ${work_space}=    testline.Get Workspace Directory
    ${nidd_path}=    Unzip NIDD file if zipped    file_path=${work_space}/resources/pmcounters/${nidd_file}    #WA until TALIB-1040
    pmtocsv.Create PM to CSV Converter
    ...  name=test_converter
    ...  file_path_pattern=${file_path}/${file_pattern}.xml
    ...  delimiter=;
    ...  output_file_name=${file_path}/pmCounters.csv
    ...  nidd_path=${nidd_path}
    pmtocsv.Convert    test_converter
    [Return]    ${file_path}/pmCounters.csv


Collect PM Counter
    [Documentation]    :Author: Jing Liang
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param collector_alias: (default gnb_pm_counters) alias name for collector
    ...    :param target_dir: (default None) save PM Counter files to path
    ...    :param component: (default=DU, options : DU/CU) If oam type is cloud coam for vRAN 1.0
    ...          the DU component is commissioned by default
    ...
    ...    :return: Location of collected PM counter files
    [Arguments]    ${gnb_id}=0    ${du_id}=0    ${collector_alias}=gnb_pm_counters    ${target_dir}=None  ${component}=DU
    Check if CU http port is configured for classical GNB
    ${oam_type}=    testline.Get OAM Type    gnb_id=${gnb_id}
    ${du_host_ip}=   gnb_lib.Get GNB DU Host IP   ${tl.gnbs[${gnb_id}].dus[${du_id}]}
    ${webservice}=  Run Keyword if  '${oam_type}'=='cloud_coam' and '${component}'=='DU'
    ...  Create Dictionary
    ...    host=${du_host_ip}
    ...    user=Nemuadmin
    ...    password=nemuuser
    ...    port=443
    ...    ELSE  Create Dictionary
    ...    host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...    user=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...    port=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.port}

    ${oam_type}=    Set Variable If
    ...    '${oam_type}'=='megazone'    mzoam
    ...    '${oam_type}'=='coam' or '${oam_type}'=='cloud_coam' and '${component}'=='DU'         coam
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    collect_pm.Create PM Collector    name=${collector_alias}    webservice=${webservice}    oam_type=${oam_type}
    collect_pm.Setup Collectors       names=${collector_alias}
    collect_pm.Collect Collectors     names=${collector_alias}    target_dir=${target_dir}
    collect_pm.Teardown Collectors    names=${collector_alias}
    [Return]    ${target_dir}/${collector_alias}


Check PM counter value equal
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        checks that the value of a counter in the last reporting period is equal to a given value
    ...
    ...        :param expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${expected_value}   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   Get PM counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${expected_value}=   convert to integer    ${expected_value}
    should be equal  ${pi_value}   ${expected_value}     PM Counter ${pi_id} expected to be == ${expected_value} but is ${pi_value}


Check PM counter value not equal
    [Documentation]   :Author: Vasileios Papoutsis
    ...        checks that the value of a counter in the last reporting period is equal to a given value
    ...
    ...        :param not_expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${not_expected_value}   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   Get PM counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${not_expected_value}=   convert to integer    ${not_expected_value}
    should not be equal  ${pi_value}   ${not_expected_value}     PM Counter ${pi_id} expected to be != ${not_expected_value} but is ${pi_value}


Check PM counter value bigger than
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        checks that the value of a counter in the last reporting period is bigger than a given value
    ...
    ...        :param expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${expected_value}    ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   Get PM counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${expected_value}=   convert to integer    ${expected_value}
    should be true  ${pi_value} > ${expected_value}     PM Counter ${pi_id} expected to be > ${expected_value} but is ${pi_value}

Check PM counter value bigger than float number
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        checks that the value of a counter in the last reporting period is bigger than a given value
    ...
    ...        :param expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${expected_value}    ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   Get PM counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to number    ${pi_value}
    ${expected_value}=   convert to number    ${expected_value}
    should be true  ${pi_value} > ${expected_value}     PM Counter ${pi_id} expected to be > ${expected_value} but is ${pi_value}

Check PM counter value equal to float number
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        checks that the value of a counter in the last reporting period is bigger than a given value
    ...
    ...        :param expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${expected_value}    ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   Get PM counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to number    ${pi_value}
    ${expected_value}=   convert to number    ${expected_value}
    should be equal  ${pi_value}   ${expected_value}     PM Counter ${pi_id} expected to be > ${expected_value} but is ${pi_value}

Check PM counter value equal or bigger than
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        checks that the value of a counter in the last reporting period is equal or bigger than a given value
    ...
    ...        :param expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${expected_value}   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   Get PM counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${expected_value}=   convert to integer    ${expected_value}
    should be true  ${pi_value} >= ${expected_value}     PM Counter ${pi_id} expected to be >= ${expected_value} but is ${pi_value}

Check PM counter value smaller than
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        checks that the value of a counter in the last reporting period is smaller than a given value
    ...
    ...        :param expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${expected_value}   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   Get PM counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${expected_value}=   convert to integer    ${expected_value}
    should be true  ${pi_value} < ${expected_value}     PM Counter ${pi_id} expected to be < ${expected_value} but is ${pi_value}


Check PM counter value equal or smaller than
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        checks that the value of a counter in the last reporting period is equal or smaller than a given value
    ...
    ...        :param expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${expected_value}   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   Get PM counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${expected_value}=   convert to integer    ${expected_value}
    should be true  ${pi_value} <= ${expected_value}     PM Counter ${pi_id} expected to be <= ${expected_value} but is ${pi_value}


Check PM counter value in range
    [Documentation]   :Author: Vasileios Papoutsis
    ...        checks that the value of a counter in the last reporting period is in range defined by a given value
    ...
    ...        :param expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    ...        :param rel_tolerance is the relative tolerance of the expected value
    ...        :param abs_tolerance is the absolute tolerance of the expected value
    [Arguments]    ${expected_value}   ${pm_files_location}   ${pi_id}    ${moc}    ${abs_tolerance}=0    ${rel_tolerance}=0.05
    ${pi_value}=   Get PM counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${expected_value}=   convert to integer    ${expected_value}
    ${upper_value}=    Evaluate    ${expected_value} + ${expected_value} * ${rel_tolerance} + ${abs_tolerance}
    ${lower_value}=    Evaluate    ${expected_value} - ${expected_value} * ${rel_tolerance} - ${abs_tolerance}
    should be true  ${lower_value} <= ${pi_value} <= ${upper_value}


Get PM counter value
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        get the value of a counter in the last reporting period
    ...
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=PM*
    ${last_report}    Get From List   ${PM_report_dict_list}     -1
    ${pi_dict}   Get Dictionary Values   ${last_report}
    ${first_pi}    Get From List   ${pi_dict}     0
    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
    ${cell_dict}   Get From List   ${cell_dict_list}     0
    ${moc_list}   get dictionary keys   ${cell_dict}
    ${full_moc}    Set Variable     empty
    FOR  ${key}  IN   @{moc_list}
       ${key_is_moc}  Run Keyword And Return Status    Should Contain  ${key}   ${moc}
       ${full_moc}  Set Variable If   ${key_is_moc}   ${key}    ${full_moc}
    END
    ${pi_value}     Get From Dictionary      ${cell_dict}    ${full_moc}
    BuiltIn.Log    ${pi_id} value: ${pi_value}   console=${P_console}
    [Return]    ${pi_value}




Wait until the next Measurement Period starts
    [Documentation]    :Author: Jing Liang
    ...    this keyword could be used as wait for current Measurement Period stops
    ...
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param additional_time: (default=30) additional seconds for waiting
    [Arguments]    ${gnb_id}=0    ${additional_time}=30
    ${meas_period}=    Get Measurement Period from GNB    gnb_id=${gnb_id}
    pm_internal.wait_next_meas_period    meas_period=${meas_period}    add_time=${additional_time}    with_console_output=${P_console}
    ${start_time}=    DateTime.Get Current Date    result_format=%H:%M:%S
    BuiltIn.Log    Start Time Of Measurement Period = ${start_time}    level=DEBUG
    ${start_time}=    DateTime.Convert Time    ${start_time}    result_format=timedelta
    Set To Dictionary    ${P_START_TIME}    gnb_${gnb_id}    ${start_time}
    Set Test Variable    ${P_START_TIME}


Wait until the current Measurement Period stops
    [Documentation]    :Author: Jing Liang
    ...
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param additional_time: (default=30) additional seconds for waiting
    [Arguments]    ${gnb_id}=0    ${additional_time}=30
    ${start_time}=    Get Start Time from Test    gnb_id=${gnb_id}
    ${meas_period}=    Get Measurement Period from GNB    gnb_id=${gnb_id}
    ${current_time}=    DateTime.Get Current Date    result_format=%H:%M:%S
    ${current_time}=    DateTime.Convert Time    ${current_time}    result_format=timedelta
    ${time_delay}=    Evaluate    ${current_time.total_seconds()}-${start_time.total_seconds()}
    Return from Keyword If    ${time_delay} >= ${meas_period}
    pm_internal.wait_next_meas_period    meas_period=${meas_period}    add_time=${additional_time}    with_console_output=${P_console}

Verify PM Counter Reference Table
    [Documentation]   :Author: Thomas Nuecker
    ...     Keyword for very descriptive pm counter checking. Expected is a pm_counter List, containing the pm counter,
    ...     the compare operation, an expected value to compare against as well as a description. With this Keyword,
    ...     PM Counters can be checked in the following way:
    ...
    ...     ${reference_table}    Create List
    ...     ...   M55300C01028  ==  0       Successful PDSCH transmissions by initial transmission with 64QAM MCS table using MCS 28
    ...     ...   M55300C02028  ==  0       Successful PDSCH transmissions by any transmission with 64QAM MCS table using MCS 28
    ...     ...   M55300C03028  ==  0       Unsuccessful PDSCH transmissions by last HARQ reTx with 64QAM MCS table using MCS 28
    ...     ...   M55300C04027  >=  400000  PDSCH initial transmissions with 256QAM MCS table using MCS 27
    ...     ...   M55300C05027  >=  400000  Successful PDSCH transmissions by initial transmission with 256QAM MCS table using MCS 27
    ...     ...   M55300C06027  >=  400000  Successful PDSCH transmissions by any transmission with 256QAM MCS table using MCS 27
    ...     ...   M55300C07027  <=  100     Unsuccessful PDSCH transmissions by last HARQ reTx with 256QAM MCS table using MCS 27
    ...     ...   M55113C01006  ==  0       Number of UE Context Modification Required received (RLC retr)
    ...     ...   M55116C00004  ==  0       Number of UE Context Modification Required with cause Radio Network Layer / radio link failure
    ...     Verify PM Counter Reference table    reference_table=${reference_table}  pm_dir=/path/to/pm/  cell_id=1

    [Arguments]     ${reference_table}  ${pm_dir}  ${cell_id}

    Validate Pm Counter Reference Table    ${reference_table}   ${pm_dir}   ${cell_id}



Analyze PM Counters
    [Documentation]  :Author: Srihari Janardhan
    ...  Analyse PM Counters based on given given expected values and index. Index=0 is the last measurement.
    ...  The output of the keyword is a pass or a fail based on the parameters under evaluation
    ...  :param abs_tol:  (default=0)  is the absolute tolerance in same units as the counter.
    ...  :param rel_tol:  (default=0)  is the relative tolerance used as multiplier when calculating verdict. Example: 0.1 is 10%.
    ...  :param pi_expected:  is a dictionary where PM Counter name as key and the expected value of the counter is the value
    ...  :param index:  is the position of the counter interval that needs to be analyzed.\
    ...  By default the last or the latest counter interval is analyzed. index position 1 means the 2nd last counter interval is analyzed
    ...  :param regex:  is a regular expression which identifies a counter (Eg. regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+)
    ...  :pi_dir:  directory where the PM Counter .xml files are located
    ...  :ru_id: This is the RadioUnit under Test.
    [Arguments]  ${regex}  ${pi_dir}  ${pi_expected}  ${index}=0  ${abs_tol}=0  ${rel_tol}=0   ${gnb_id}=0    ${ru_id}=0
    ${pi_list}=  Get dictionary keys  ${pi_expected}
    ${pi_dict}=  Extract PM Counter Values from PM XML Files  pi_list=${pi_list}  pi_dir=${pi_dir}  index=0
    ${current_timestamp}=  pm_internal.get_timestamp  pi_dict=${pi_dict}  index=${index}
    BuiltIn.Log    \nCounters sampled at ${current_timestamp} GMT  console=${P_console}
    ${distName_params}=  Get distNames from gNB SCF  regex=${regex}   gnb_id=${gnb_id}
    Sort List    ${distName_params}
    FOR  ${pi}  IN  @{pi_list}
       ${pi_value}=  pm_internal.get_counter_value  pi_dict=${pi_dict}  pi=${pi}  dist_name=${distName_params[${ru_id}]}  index=${index}
       BuiltIn.Log    Value of ${pi} is ${pi_value}  console=${P_console}
       Run Keyword If    ${pi_value}==${None}    Run Keyword And Continue On Failure
       ...    Fail    There are empty counters that can't be validated
       Continue For Loop If    ${pi_value}==${None}
       ${verdict}=  pm_internal.compare_values
       ...  observed=${pi_value}
       ...  shall=&{pi_expected}[${pi}]
       ...  rel_tolerance=${rel_tol}
       ...  abs_tolerance=${abs_tol}
       Run keyword and continue on failure
       ...  Should contain  ${verdict}  Passed
       ...  msg=Counter check failed for ${pi}: ${pi_value}=!&{pi_expected}[${pi}]   values=False
    END

Get Counter Value
    [Documentation]  :Author: Srihari Janardhan
    ...  Get counter values for either one or a list of PM Counters
    ...  The output of the keyword is in the form of a dictionary. The format depends on the type of the index variable
    ...  :param pi_dir:  Directory path where PM Counter XML files are stored
    ...  :param dist_name:  The desired dist_name of the cell who's PM Counters are of interest
    ...  :param pi_list:  List of PM Counters to be extracted
    ...  :param index:  is the position of the counter interval that needs to be analyzed. (Index can either be a string or a list of strings)
    ...  By default the last or the latest counter interval is analyzed. index position 1 means the 2nd last counter interval is analyzed
    ...  The output will be a dictionary where Key is the PM Counter name and value is the Value of the PM Counter
    ...  Index can be a list of strings for e.g. ${index_list}=  Create List  0  1  2  3
    ...  In this case the counter values from the last 4 intervals will be extracted and the output will be a
    ...  The output will be a dictionary of dictionaries for e.g. {u'0': {u'M55308C02001': 0, u'M55308C02000': 0}}
    ...  where the key is the index and the value is a dictionary containing corrosponding PM Counter values
    [Arguments]  ${pi_dir}  ${dist_name}  ${pi_list}  ${index}=0
    ${pi_dict}=  Extract PM Counter Values from PM XML Files  pi_list=${pi_list}  pi_dir=${pi_dir}  index=0
    ${actual_pm_values}=  pm_internal.get_actual_pm_values  pi_dict=${pi_dict}  pi_list=${pi_list}  dist_name=${dist_name}  index=${index}
    [Return]  ${actual_pm_values}

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
# Private keywords --> must not used outside of this file!
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Extract PM Counter Values from PM XML Files
    [Documentation]     :Author: Srihari Janardhan
    ...    [PRIVATE]
    ...    :return: Extracted PM counters from xml files
    [Arguments]  ${pi_dir}  ${pi_list}  ${index}=0
    ${pi_dict}=  pm_internal.get_pi_dict
    ...  pi_dir=${pi_dir}
    ...  pi_list=${pi_list}
    [Return]  ${pi_dict}
    log to console      ${index}


Get Measurement Period from GNB
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    :return: Measurement period in second
    [Arguments]    ${gnb_id}=0
    ${meas_period}=    Get Variable Value    ${P_MEAS_PERIOD.gnb_${gnb_id}}
    Run Keyword If    '${meas_period}'=='None'
    ...    Fetch Measurement Period from SCF    gnb_id=${gnb_id}
    [Return]    ${P_MEAS_PERIOD.gnb_${gnb_id}}


Fetch Measurement Period from SCF
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    Collect Measurement Period from SCF
    [Arguments]    ${gnb_id}=0
    ${scf_path}=    gnb.Get SCF from gNB    gnb_id=${gnb_id}
    scf.Load SCF    file_path=${scf_path}
    ${meas_period}=    scf.Get Value from SCF    p_name=reportingIntervalPm
    scf.Save SCF    file_path=${scf_path}
    ${meas_period}=    Evaluate    int(${meas_period[:-3]}) * 60
    Set To Dictionary    ${P_MEAS_PERIOD}    gnb_${gnb_id}    ${meas_period}
    Set Suite Variable    ${P_MEAS_PERIOD}


Get Start Time from Test
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    :return: start time from keyword "Wait until the next Measurement Period starts"
    [Arguments]    ${gnb_id}=0
    ${start_time}=    Get Variable Value    ${P_START_TIME.gnb_${gnb_id}}
    ${msg}=    Catenate      No start time found,
    ...    use 'Wait until the next Measurement Period starts' first,
    ...    before calling 'Wait until the current Measurement Period stops'
    Run Keyword If    '${start_time}'=='None'
    ...    Fail    ${msg}
    [Return]    ${start_time}


Check if CU http port is configured for classical GNB
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    Temporary Check for Classical BTS, because http port is an optional parameter, maybe another Collectors also need this check
    [Arguments]    ${gnb_id}=0
    ${gnb_type}=    Get gNB type    gnb_id=${gnb_id}
    Return from Keyword If    '${gnb_type}' == 'cloud'
    ${http_port}=    Get Variable Value    ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.port}
    Run Keyword If    '${http_port}' == '80'    BuiltIn.Log
    ...    Please specify cu.oam_http_connection_details.port to 443 in your testline config for Collectors
    ...    level=WARN
    ...    ELSE    Return From Keyword
    Set Suite Variable    ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.port}    ${443}

Unzip NIDD file if zipped
    [Documentation]    [PRIVATE]    WA until ticket close
    ...    https://jira3.int.net.nokia.com/browse/TALIB-1040
    ...    :return NIDD file path
    [Arguments]    ${file_path}
    Return From Keyword If    '.xml'=='${file_path[-4:]}'    ${file_path}
    ${output}=    OperatingSystem.Run    unzip -o ${file_path} -d /tmp | grep xml
    ${output}=    String.Strip String    ${output}
    ${rest}    ${file_name}=    Split String    ${output}    separator=/tmp/    max_split=1
    [Return]    /tmp/${file_name}


Wait for a certain Measurement Period to start
    [Documentation]    :Author: Amr Aboushehata
    ...    this keyword could be used to wait for certain measurement period to start the test case scenario
    ...    If Counters are collected every 15 mints and test case needs 5 mints then you can start the function
    ...    at time (15-5=10) or (30-5=25)
    ...    :meas_periods: (default [10, 25, 40, 55]) list of minutes when the measurement can start
    ...    :param gnb_id: (default=0) Id/Number of gNB
    [Arguments]    ${gnb_id}=0    ${meas_period_list}=0
    pm_internal.wait_certain_meas_period    with_console_output=${P_console}    meas_periods=${meas_period_list}
    ${start_time}=    DateTime.Get Current Date    result_format=%H:%M:%S
    BuiltIn.Log    Start Time Of Measurement Period = ${start_time}    level=DEBUG
    ${start_time}=    DateTime.Convert Time    ${start_time}    result_format=timedelta
    Set To Dictionary    ${P_START_TIME}    gnb_${gnb_id}    ${start_time}
    Set Test Variable    ${P_START_TIME}
