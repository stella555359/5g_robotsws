*** Settings ***
Library     String
Library     DateTime
Library     OperatingSystem
Library     taf.config.scf               WITH NAME    scf
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007608_A_B/Resources/python/pmcounters.py    WITH NAME    pm_internal
Library     taf.collectors.pmcounters    WITH NAME    collect_pm
Library     taf.converters.pmtocsv       WITH NAME    pmtocsv
Library     taf.analyzer.pmcounter       WITH NAME    check_pm
Library     taf.collectors.snapshot    WITH NAME    collect_snapshot
Resource    ./testline.robot
Documentation    This file is used for checking PMcounters

*** Variables ***
&{P_MEAS_PERIOD}        &{EMPTY}
&{P_START_TIME}         &{EMPTY}
${P_console}            ${False}

*** Keywords ***

Collect PM Counter
    [Documentation]    :Author: Jing Liang
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param collector_alias: (default gnb_pm_counters) alias name for collector
    ...    :param target_dir: (default None) save PM Counter files to path
    ...    :param component: (default=DU, options : DU/CU) If oam type is cloud coam for vRAN 1.0
    ...          the DU component is commissioned by default
    ...    :return: Location of collected PM counter files
    [Arguments]    ${gnb_id}=0    ${du_id}=0    ${collector_alias}=gnb_pm_counters    ${target_dir}=None  ${component}=DU
    Check if CU http port is configured for classical GNB
    ${oam_type}=    testline.Get OAM Type    gnb_id=${gnb_id}
    ${webservice}=  Run Keyword if  '${oam_type}'=='cloud_coam' and '${component}'=='DU'
    ...  Create Dictionary
    ...    host=${tl.gnbs[${gnb_id}].dus[${du_id}].f1_m_ip_addr}
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
    collect_pm.Create PM Collector    name=${collector_alias}    webservice=${webservice}    oam_type=${oam_type}    for_last=2 minutes
    collect_pm.Setup Collectors       names=${collector_alias}
    collect_pm.Collect Collectors     names=${collector_alias}    target_dir=${target_dir}
    collect_pm.Teardown Collectors    names=${collector_alias}
    [Return]    ${target_dir}/${collector_alias}

Collect Snapshot
    [Documentation]    :Author: Jing Liang
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param collector_alias: (default gnb_pm_counters) alias name for collector
    ...    :param target_dir: (default None) save PM Counter files to path
    ...    :param component: (default=DU, options : DU/CU) If oam type is cloud coam for vRAN 1.0
    ...          the DU component is commissioned by default
    ...    :return: Location of collected PM counter files
    [Arguments]    ${gnb_id}=0    ${du_id}=0    ${collector_alias}=gnb_snapshot    ${target_dir}=None  ${component}=DU
    Check if CU http port is configured for classical GNB
    ${oam_type}=    testline.Get OAM Type    gnb_id=${gnb_id}
    ${webservice}=  Run Keyword if  '${oam_type}'=='cloud_coam' and '${component}'=='DU'
    ...  Create Dictionary
    ...    host=${tl.gnbs[${gnb_id}].dus[${du_id}].f1_m_ip_addr}
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
    collect_snapshot.create_sbts_snapshot_collector    name=${collector_alias}    webservice=${webservice}
    collect_snapshot.Setup Collectors       names=${collector_alias}
    collect_snapshot.Collect Collectors     names=${collector_alias}    target_dir=${target_dir}
    collect_snapshot.Teardown Collectors    names=${collector_alias}
    [Return]    ${target_dir}/${collector_alias}

Check PM counter value equal
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        checks that the value of a counter in the last reporting period is equal to a given value
    ...        :param expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${expected_value}   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   Get PM counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${expected_value}=   convert to integer    ${expected_value}
    should be equal  ${pi_value}   ${expected_value}

Get PM counter value
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        get the value of a counter in the last reporting period
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
    ${last_report}    Get From List   ${PM_report_dict_list}     0
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
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param additional_time: (default=30) additional seconds for waiting
    [Arguments]    ${gnb_id}=0    ${additional_time}=30
#    ${meas_period}=    Get Measurement Period from GNB    gnb_id=${gnb_id}
    ${meas_period}=  Set Variable    300
    pm_internal.wait_next_meas_period    meas_period=${meas_period}    add_time=${additional_time}    with_console_output=${P_console}
    ${start_time}=    DateTime.Get Current Date    result_format=%H:%M:%S
    BuiltIn.Log    Start Time Of Measurement Period = ${start_time}    level=DEBUG
    ${start_time}=    DateTime.Convert Time    ${start_time}    result_format=timedelta
    Set To Dictionary    ${P_START_TIME}    gnb_${gnb_id}    ${start_time}
    Set Test Variable    ${P_START_TIME}


Wait until the current Measurement Period stops
    [Documentation]    :Author: Jing Liang
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param additional_time: (default=30) additional seconds for waiting
    [Arguments]    ${gnb_id}=0    ${additional_time}=90
    ${start_time}=    Get Start Time from Test    gnb_id=${gnb_id}
#    ${meas_period}=    Get Measurement Period from GNB    gnb_id=${gnb_id}
    ${meas_period}=  Set Variable    300
    ${current_time}=    DateTime.Get Current Date    result_format=%H:%M:%S
    ${current_time}=    DateTime.Convert Time    ${current_time}    result_format=timedelta
    ${time_delay}=    Evaluate    ${current_time.total_seconds()}-${start_time.total_seconds()}
    Return from Keyword If    ${time_delay} >= ${meas_period}
    pm_internal.wait_next_meas_period    meas_period=${meas_period}    add_time=${additional_time}    with_console_output=${P_console}



#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
# Private keywords --> must not used outside of this file!
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

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
