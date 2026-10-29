*** Settings ***

Library    taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.collectors.btslog    WITH NAME    btslog
Library    taf.collectors.core    WITH NAME    core
Library    ../Python/admin_operation.py    WITH NAME    admin_operation
Library    ../Python/gnb_alarm.py    WITH NAME    GnbAlarmAnalyzer
Library    ../Python/scf_analysis.py    WITH NAME    scfas
Library    ../python/CI_analyzation.py    WITH NAME    RobotCaseInfo
Library    taf.selenium.sbts    WITH NAME    selenium_coam
Library    testsuite/Bangalore/ORAN/resources/python/SysValidation.py  WITH NAME  Validation
Resource    ../variables/Rjio_variables.robot
Library    Collections
Library    OperatingSystem
Library    String
Library    DateTime
Library    Process
Variables    ../variables/CB012601_Variables.py


*** Variables ***

*** Keywords ***

Start Btslog Collect
    [Arguments]    ${names}='btslog' 
    btslog.Create Btslog Collector    name=${names}    btslog_path=${btslog_dir}/btslog    
    ...    btslog_launcher_path=${btslog_dir}/btslog_launcher    log_dir=${log_dir}    start_timeout=${60}
    core.Setup Collectors    names=${names}
    core.Start Collectors    names=${names}
    btslog.Set Suite Alias    ${names}

Start Btslog With Path Check

    FOR    ${btslog_dir}    IN    [ @{btslog_dirs} ]
        ${file_exist}    BuiltIn.Run Keyword And Return Status    File Should Exist    ${btslog_dir}/btslog
        BuiltIn.Run Keyword If    '${file_exist}'=='True'    run keywords    Start Btslog Collect
        ...    btslog_dir=${btslog_dir}    AND    Exit For Loop
    END
    BuiltIn.Set Suite Variable    ${btslog_dir}     
    BuiltIn.Run Keyword If    '${btslog_dir}'=='none'    Log    Can't find btslog.,WARN

Stop Btslog With Path Check
    [Arguments]    ${target_dir}
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ps -ef | grep ${btslog_dir} | grep -v grep
    BuiltIn.Run Keyword If    '${btslog_dir}'!='none'    and    ${rc}==${0}    Stop Btslog Collect    target_dir=${target_dir}

Stop Btslog Collect
    BuiltIn.Run Keyword And Ignore Error    core.stop_collectors    names=${names}
    BuiltIn.Run Keyword And Ignore Error    core.collect_collectors    names=${names}    target_dir=${target_dir}
    core.Teardown Collectors    names=${names}
    BuiltIn.Log To Console    [ INFO ]: Collecting BTSLOG [DONE]

Get All Cell Id
    [Arguments]    ${ru_index}    ${connection}=GNB_OAM
    ${output}    coam.Get Cells Info    cell_type=${nr_cell_type}    connection=${connection}
    BuiltIn.Log Many    ${output}    level=DEBUG    
    ${cell_list}    BuiltIn.Create List
    FOR    ${cell}    IN    [ @{output} ]
        BuiltIn.Run Keyword If    ${ru_index}==${None}    append to list    ${cell_list}    ${cell['globalCellId']}
        Log    ${cell}
        ${dict_cell}    Create Dictionary    &{cell}
        ${carrier}    BuiltIn.Set Variable    ${dict_cell['carrierList'][0]}
        ${status}    BuiltIn.Run Keyword If    ${ru_index}!=${None}    run keyword and return status    
        ...    should contain    ${carrier['antennaLineId']['configuration']}    RMOD-${ru_index}
        BuiltIn.Run Keyword If    ${status}    append to list    ${cell_list}    ${cell['globalCellId']}
    END
    Collections.Sort List    ${cell_list}
    [Return]    ${cell_list}
Get All RU Index
    [Arguments]    ${connection}
    &{hw_info}    coam.Get Detected Hw Info    connection=${connection}
    ${rmod_info}    BuiltIn.Set Variable    ${hw_info.radioModules.rmod}
    ${ru_index_list}    BuiltIn.Create List
    FOR   ${ru}    IN    @{rmod_info}
        Log     ${ru}
        ${converted_ru}    Create Dictionary    &{ru}
        ${ru_id_configuration}    BuiltIn.Set Variable    ${converted_ru.id.configuration}
        ${ru_index}    String.Get Regexp Matches    ${ru_id_configuration}    RMOD-(\\d+)    1
        Collections.Append To List    ${ru_index_list}    ${ru_index[0]}
    END
    Collections.Sort List    ${ru_index_list}
    [Return]    ${ru_index_list}
get current bts configuration
    [Arguments]    ${connection}=GNB_OAM
    ${ru_index_list}    Get All RU Index    ${connection}
    ${ru_num}    BuiltIn.Get Length    ${ru_index_list}
    ${cell_index_list}    Get All Cell Id    ru_index=${1}
    ${cell_num}    BuiltIn.Get Length    ${cell_index_list}
    ${nrcell_objects}    coam.Get Managed Objects    class_name=NRCELL_A    connection=${connection}
    ${nrCellType_d}    coam.Get Parameters    dist_name=${nrcell_objects[0]['distName']}    pattern=nrCellType    connection=${connection}
    ${nrCellType}    Collections.Get From Dictionary    ${nrCellType_d}    nrCellType
    ${nrCellType}    String.Replace String    ${nrCellType}    L    -
    ${nrCellType}    String.Get Substring    ${nrCellType}    0    -1
    ${configuration}    BuiltIn.Set Variable    ${ru_num}S-${cell_num}CC-${nrCellType}
    BuiltIn.Log To Console    BTS Current Configuration:${configuration}

get specified scf from tag
    ${Status}    BuiltIn.Set Variable    ${False}
    ${SCF_Path}    BuiltIn.Set Variable    ${Golden_SCF_Path}
    ${tag_num}    BuiltIn.Get Length    ${TEST_TAGS}
    BuiltIn.Return From Keyword If    ${tag_num}==${0}    ${SCF_Path}    ${Status}
    ${configuration}    get current bts configuration
    ${flag}    BuiltIn.Set Variable    ${False}
    FOR    ${tag}    IN    [ @{TEST_TAGS} ]
        ${flag}    BuiltIn.Run Keyword And Return Status    Should contain    ${tag}    S-
        BuiltIn.Run Keyword If    ${flag}    Log to console    Case TAG:${tag}
        ${SCF_Path}    BuiltIn.Run Keyword If    ${flag}    Replace String    ${Golden_SCF_Path}    .xml     _${tag}.xml    
        ...    ELSE    set variable    ${Golden_SCF_Path}
        ${flag2}    BuiltIn.Run Keyword And Return Status    Should contain    ${configuration}    ${tag}
        ${Status}    BuiltIn.Set Variable If    ${flag}==${True}    and    ${flag2}==${False}    ${True}    ${False}
        BuiltIn.Exit For Loop If    ${flag}
    END
get specified scf
    ${flag}    BuiltIn.Run Keyword And Return Status    variable should exist    ${SCFNAME}
    ${SCF_Path}    ${Status}    BuiltIn.Run Keyword If    ${flag}    get specified scf from jenkins
     ...    ELSE    get specified scf from tag

Check all cells info should be onair
    [Arguments]    ${connection}=GNB_OAM
    BuiltIn.Log To Console    Check all NR and LTE cells should be onair
    ${nr_cells_info}    coam.Get Cells Info    cell_type=nr    timeout=20    connection=${connection}
    FOR    ${cell}    IN    [ @{nr_cells_info} ]
        BuiltIn.Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}    enabled
        BuiltIn.Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}    unlocked
        BuiltIn.Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}    unblocked
    END
    ${lte_cells_info}    coam.Get Cells Info    cell_type=lte    timeout=20    connection=${connection}
    FOR    ${cell}    IN    [ @{lte_cells_info} ]
        BuiltIn.Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}    enabled
        BuiltIn.Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}    unlocked
        BuiltIn.Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}    unblocked
    END

COAM Check GNB RU status
    [Arguments]    ${connection}
    BuiltIn.Log To Console    Check RU status from GNB
    ${sw_version}    coam.Get Sw Version    connection=${connection}
    ${result}    BuiltIn.Run Keyword And Return Status    should contain any    ${sw_version}    24R2  24R1    24R3    00
    ${unlocked}    BuiltIn.Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    BuiltIn.Set Variable If    ${result}    Enabled    enabled
    ${hw_info}    coam.Get Detected Hw Info    connection=${connection}
    @{list_RUs}    BuiltIn.Set Variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    BuiltIn.Get Length    ${list_RUs}
    ${ru_item}    BuiltIn.Set Variable    ${0}
    BuiltIn.Should Be True    ${count_RUs}>=${1}    msg=Check RU status failed as total RU number is less than 1
    FOR    ${ru}    IN    [ @{list_RUs} ]
        BuiltIn.Run Keyword If    '${ru_sn}'!='all'    and    '${ru_sn}'!='${ru['serialNumber']}'    continue for loop
        ${ru_item}    BuiltIn.Evaluate    ${ru_item}+1
        BuiltIn.Run Keyword And Continue On Failure    Should be equal as strings    ${ru['status']['administrativeState']}    
        ...    ${unlocked}    msg=Current RU administrativeState is not in Unlocked status
        BuiltIn.Run Keyword And Continue On Failure    Should be equal as strings    
        ...    ${ru['status']['operationalState']}    ${enabled}    msg=Current RU operationalState is not in Enabled status
        BuiltIn.Run Keyword And Continue On Failure    Should be equal as strings
        ...    ${ru['status']['proceduralStatus']}    configured    msg=Current RU proceduralStatus is not in configured status
        BuiltIn.Run Keyword If    ${result}    Run keyword and continue on failure    
        ...    Should be equal as strings    ${ru['status']['availabilityStatus']}    
        ...    Online    msg=Current RU availabilityStatus is not in Online status
    END
    BuiltIn.Should Be True    ${ru_item}>${0}    msg=Check RU status failed as no RU found !!!

COAM get all ru detail info
    [Documentation]  Author: Ding Binmei
    ...              Description: Get all RU detail info
    ...              Return with a dict with all RU info included, keys are the ru_index, values are the detail ru info
    [Arguments]    ${connection}=GNB_OAM
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    Should be true    ${count_RUs}>=1    msg=No RU found
    &{dict_RUs_detail_info}   Create dictionary
    FOR    ${RU}    IN    @{list_RUs}
        ${RU_dict}    Create Dictionary    &{RU}
        ${config_rmod}    Set variable    ${RU_dict['id']['configuration']}
        ${rmod_index}    Fetch from right    ${config_rmod}    RMOD-
        Set to dictionary    ${dict_RUs_detail_info}    ${rmod_index}    ${RU_dict}
    END
    [Return]  ${dict_RUs_detail_info}

Generate test case log path
    ${tc_name}    String.Replace String    string=${TEST_NAME}    search_for=${SPACE}    replace_with=_
    ${case_log_path}    OperatingSystem.Join Path    ${SUITE_LOG_PATH}    TC_${tc_name}
    BuiltIn.Set Test Variable    ${TS_CASE_LOG_PATH}    ${case_log_path}
    OperatingSystem.Create Directory    ${TS_CASE_LOG_PATH}

__Check alarm and raised fatal error
    [Arguments]  ${gnb_index}=${0}    ${enb_index}=${0}    ${connection}=Trunk_roll_chec
    ${has_enb}    testline_info.Has Enb    ${tl}
    ${enb_oam_ip}    BuiltIn.Run Keyword If    ${has_enb}    
    ...    set variable if    ${tl.enbs[${enb_index}].airscale}    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}    
    ...    ${tl.enbs[${enb_index}].oam_ip.v4}
    BuiltIn.Run Keyword If    ${tl.gnbs}    
    ...    Connect to gnb coam via ssl    connection=${connection}
    ...    ELSE    Connect to gnb coam via ssl    bts_host=${enb_oam_ip}    connection=${connection}    
    ...    username=Nemuadmin    password=nemuuser
    @{truck_roll_fault}    BuiltIn.Create List    ${10}    ${1806}    ${4341}    ${4352}    ${4383}
    ${active_alarms}    coam.Get Active Alarms    connection=${connection}
    FOR    ${active_alarm}    IN    @{active_alarms}
        ${roll}    run keyword and return status    Collections.List Should not Contain Value    ${truck_roll_fault}    ${active_alarm['faultId']}
        run keyword if    not ${roll}
        ...    fatal error    msg=Fault ${active_alarm['faultId']}, possible truck roll issue, case failed!!!!!
    END
    [Teardown]  coam.teardown    connection=${connection}

Check Alarm and stop robot testing when unexpected alarm raised
    BuiltIn.Run Keyword And Ignore Error    run keyword if    ${trunk_rolll_needed}    __Check alarm and raised fatal error

robot_common_operations.Common Case Setup
    Check Alarm and stop robot testing when unexpected alarm raised
    # BuiltIn.Run Keyword And Ignore Error    Requset Configuration Id Report

Connect to gnb coam via ssl
    [Arguments]  ${connection}=GNB_OAM    ${gnb_index}=0
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    ${ignore_get_release_error}=${True}

    # No more pass release after TAF-2785 Support Auto release detect in admin library.
    admin.connect_to    bts_host=${bts_host}    bts_port=${443}
    ...    username=${username}    password=${password}   name=${connection}

Get Active SW Version
    [Arguments]    ${connection}=GNB_OAM
    ${sw_version}    coam.Get Sw Version    connection=${connection}
    ${sbts}    BuiltIn.Run Keyword And Return Status    Should contain    ${sw_version}    SBTS
    BuiltIn.Return From Keyword If    ${sbts}    ${sw_version}


Get gNB CU type
    [Arguments]  ${connection}=GNB_OAM
    ${NRBTS_A_objects}    coam.get_managed_objects    class_name=NRBTS_A    connection=${connection}
    ${gNb_CuType_d}   coam.get_parameters    dist_name=${NRBTS_A_objects[0]['distName']}    pattern=gNbCuType     connection=${connection}
    ${gNb_CuType}    Get From Dictionary    ${gNb_CuType_d}    gNbCuType
    [Return]  ${gNb_CuType}
    
replace_commission_scf_to_current_bts_scf
    [Arguments]    ${connection}    ${file_name}=SCF_SBTS00.xml
    log    ${Golden_SCF_Path}
    ${local_scf_path}    set variable    ${TS_CASE_LOG_PATH}/Current_SCF_${BTS_ID}
    OperatingSystem.Create Directory   ${local_scf_path}
    log    ${local_scf_path}
    ${current_BTS_scf}    admin.get_current_scf_file    local_dir_path=${local_scf_path}    file_name=${file_name}    connection=${connection}
    log    ${current_BTS_scf}
    # replace_scf_file_to_current_bts    current_path_file=${Golden_SCF_Path}    new_file=${current_BTS_scf}




Get Golden SCF Path
    [Arguments]    ${gnb_index}
    get stream from version    ${Active_SW_version}
    ${ute_env}    BuiltIn.Run Keyword And Return Status    run keywords    Variable Should Exist
    ...    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline}    BuiltIn.Run Keyword If    ${ute_env}    String.Fetch From Right
    ...    string=${CONFIGURATION}    marker=.    
    ...    ELSE    set variable    ${testline_name}
    ${gnb_type}    BuiltIn.Set Variable    ${tl.gnbs[${gnb_index}].__class__.__name__}
    ${Golden_SCF_Path}    Get SCF File Path    testline=${testline}    
    ...    stream=${stream}    gnb_type=${gnb_type}    gnb_index=${gnb_index}

get stream from version
    [Arguments]    ${version}
    ${sbts_trunk}    BuiltIn.Run Keyword And Return Status    Should Contain    ${version}    _ENB_9999_
    @{version_split}    String.Split String    ${version}    separator=_
    ${Stream}    BuiltIn.Set Variable If    ${sbts_trunk}    SBTS00    @{version_split}[0]
    Set Suite Variable    ${stream}    ${Stream} 
  
Get SCF File Path 
    [Arguments]    ${testline}      ${stream}    ${gnb_type}    ${gnb_index}
    # ${scf_base_path}    String.Replace String  
    # ...    ./scf_path
    # ...    ${cur_relative_dir}    ${scf_relative_dir}
    ${scf_base_path}    Set Variable    ${scf_path}
    ${gnb_ext_index}    BuiltIn.Evaluate    ${gnb_index}+1
    ${gnb_ext}    BuiltIn.Set Variable If    ${gnb_index}==0    ${EMPTY}    _gnb${gnb_ext_index}
    ${path}    BuiltIn.Run Keyword If    '${gnb_type}'=='ClassicalBts'
    ...    Catenate    SEPARATOR=${/}    ${scf_base_path}    ${testline}    SCF_${stream}${gnb_ext}.xml
    ...    ELSE IF    '${gnb_type}'=='CloudBts'    
    ...    Catenate    SEPARATOR=${/}    ${scf_base_path}    ${testline}    SCF_${stream}${gnb_ext}_${cu_or_du}.xml
    Set Suite Variable    ${main_scf_path}    ${path}
    OperatingSystem.File Should Exist    ${path}
    BuiltIn.Log To Console    ${SPACE*2}scf path: ${path}.

Generate suite log path
    [Arguments]    ${timeout}=2
    ${has_cbts}    testline_info.Has CloudBts    ${tl}
    ${ts_name}    String.Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    BuiltIn.Run Keyword If    ${has_cbts}    
    ...    wait until keyword succeeds    ${timeout}    2sec    Cloud DU connect to gnb coam via ssl
    ...    ELSE    wait until keyword succeeds
    ...    ${timeout}    2sec    Connect to gnb coam via ssl
    ${sw_version}    coam.Get Sw Version    connection=GNB_OAM
    ${suite_log_path}    OperatingSystem.Join Path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    BuiltIn.Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}Scf_selection_depends_on_sw_version
    OperatingSystem.Create Directory    ${SUITE_LOG_PATH}
    BuiltIn.Run Keyword And Ignore Error    COAM Teardown gnb connections    

COAM Teardown gnb connections
    [Arguments]    ${connection}=GNB_OAM
    coam.Teardown    connection=${connection}

Scf_selection_depends_on_sw_version
    # [Arguments]  ${connect}=""
    ${connect}    coam.Connect To    bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    BuiltIn.Run Keyword If    '${SW_stream}[0]'=='SBTS23R4'
    ...    replace_commission_scf_to_current_bts_scf    connection=${connect}    file_name=SCF_SBTS23R4.xml
    BuiltIn.Run Keyword If    '${SW_stream}[0]'=='SBTS24R1'
    ...    replace_commission_scf_to_current_bts_scf    connection=${connect}    file_name=SCF_SBTS24R1.xml
    BuiltIn.Run Keyword If    '${SW_stream}[0]'=='SBTS24R2'
    ...    replace_commission_scf_to_current_bts_scf    connection=${connect}    file_name=SCF_SBTS24R2.xml
    BuiltIn.Run Keyword If    '${SW_stream}[0]'=='SBTS00'
    ...    replace_commission_scf_to_current_bts_scf    connection=${connect}    file_name=SCF_SBTS00.xml

replace_commission_scf_to_current_bts_scf_duplicated
    [Arguments]    ${current_path_file}=scf.xml
    BuiltIn.Log    ${Golden_SCF_Path}
    ${local_scf_path}    BuiltIn.Set Variable    ${TS_CASE_LOG_PATH}/Current_SCF_${BTS_ID}
    OperatingSystem.Create Directory    ${local_scf_path}
    BuiltIn.Log    ${local_scf_path}
    ${current_BTS_scf}    coam.Get Current Scf File    local_dir_path=${local_scf_path}
    ...    file_name=${file_name}    connection=${connection}
    BuiltIn.Log    ${current_BTS_scf}
    # Replace Scf File To Current Bts    current_path_file=${Golden_SCF_Path}    new_file=${current_BTS_scf}

COAM Download scf from cluster
    [Arguments]    ${scf_dir_path}    ${connection}    ${timeout}=60
    ${time_stamp}    DateTime.Get Current Date     result_format=%Y%m%d%H%M%S
    ${scf_default_name}    BuiltIn.Catenate    SEPARATOR=${EMPTY}    
    ...    scf_backup_from_cluster     ${time_stamp}    .xml
    ${scf_file_path}    coam.Get Current Scf File    local_dir_path=${scf_dir_path}   
    ...    file_name=${scf_default_name}    connection=${connection}    timeout=${timeout}
    set suite variable    ${scf_path}    ${scf_file_path}
Download SCF Download Via Rest Api
    [Arguments]    ${scf_dir_path}    ${connection}=GNB_OAM
    ${scf_path}    COAM Download scf from cluster    scf_dir_path=${scf_dir_path}    connection=${connection}

Get mrbtsID and nrbtsID via SCF for gNB
    [Arguments]    ${scf_path}     ${cell_id}
    ${nrcell_info}    OperatingSystem.Run    cat ${scf_path} | grep -oE "MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-${cell_id}" | head -n 1
    ${len}    BuiltIn.Get Length    ${nrcell_info}
    ${nrcell_info}    BuiltIn.Run Keyword If    ${len}==0     
    ...    Run    cat ${scf_path} | grep -oE "MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]" | head -n 1
    ...    ELSE    set variable    ${nrcell_info}
    ${mrbtsID}    OperatingSystem.Run    echo ${nrcell_info}|grep -oE "MRBTS-[0-9]+"| awk -F '-' '{print $2}'
    ${nrbtsID}    OperatingSystem.Run    echo ${nrcell_info}|grep -oE "NRBTS-[0-9]+"| awk -F '-' '{print $2}'
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}

add fault to the allowed fault list
    [Arguments]    ${faultId}
    ${ALLOWED_FAULT_TEMP}    Collections.Copy List    ${ALLOWED_FAULT}
    ${fault_dic}    BuiltIn.Create Dictionary    faultId=${faultId}
    Collections.Append To List    ${ALLOWED_FAULT_TEMP}    ${fault_dic}
    BuiltIn.Set Suite Variable    ${ALLOWED_FAULT}    ${ALLOWED_FAULT_TEMP}

add fault to the allowed history fault list
    [Arguments]    ${faultId}
    ${ALLOWED_FAULT_TEMP}    Collections.Copy List    ${ALLOWED_FAULT}
    ${fault_dic}    BuiltIn.Create Dictionary    faultId=${faultId}
    Collections.Append To List    ${ALLOWED_FAULT_TEMP}    ${fault_dic}
    BuiltIn.Set Suite Variable    ${ALLOWED_FAULT}    ${ALLOWED_FAULT_TEMP}

reset_actRemoteSyslogTransmission
     update_parameter_value    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/TRBLCADM-1    
     ...    parameter_name=actRemoteSyslogTransmission    value=false
     update_parameter_value    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/TRBLCADM-1
     ...    parameter_name=actRemoteSyslogTransmission    value=true

update_parameter_value
    [Arguments]   ${value}    ${dist_name}    ${parameter_name}
    coam.Perform Parameter Recommissioning    dist_name=${dist_name}    parameter=${parameter_name}
    ...    value=${value}    operation=update    connection=GNB_OAM
    BuiltIn.Sleep    5s
    BuiltIn.Wait Until Keyword Succeeds    5min    30s    verify all cells should be onair

Verify all cells should be onair
    BuiltIn.Log To Console    Verify all cells are on air
    ${sw_version}    coam.Get Sw Version    connection=${connection}
    ${result}    BuiltIn.Run Keyword And Return Status    should contain any    ${sw_version}    12.400    14.400    22R1    
    ...    22R2    21B
    ${unlocked}    BuiltIn.Set Variable If    ${result}    Unlocked    Unlocked
    ${unlocked}    BuiltIn.Set Variable If    ${result}==${False}    and    '${cell_type}'=='lte'    unlocked    ${unlocked}
    ${enabled}    BuiltIn.Set Variable If    ${result}    Enabled    enabled
    ${cells_info}    coam.Get Cells Info    cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        BuiltIn.Run Keyword And Continue On Failure    Should Be Equal As Strings    
        ...    ${cell['status']['administrativeState']}    ${unlocked}
        BuiltIn.Run Keyword And Continue On Failure    Should be equal as strings    
        ...    ${cell['status']['operationalState']}    ${enabled}
        BuiltIn.Run Keyword If    ${result}    Run keyword and continue on failure
        ...    Should Be Equal As Strings    ${cell['status']['availabilityStatus']}    Online
    END
    

robot_common_operations.Common Suite Teardown
    BuiltIn.Log    robot_common_operations.Common Suite Teardown
    BuiltIn.Log To Console    \n***SISO Coam Suite Teardown***

save full snapshot
    [Arguments]        ${connection}=GNB_OAM
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    ${snapshot_zip_file_full}    OperatingSystem.Join Path     ${snapshot_path}    snapshot_${timestamp}.zip
    coam.Get Snapshot    target_file_name=${snapshot_zip_file_full}    coverage=Full
    ...    timeout=1500    connection=${connection}
interface.Common step trigger
    rfrlscc.Check Ecpri Ru Transmit Power In Normal Range    pass_ru_power_check=${pass_ru_power_check}

Get alarms from Gnb
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run keyword if    ${has_cbts}
    ...            Wait Until Keyword Succeeds    5min    30s    coam_gnb_classical.Cloud DU connect to gnb coam via ssl
    ...    ELSE    Wait Until Keyword Succeeds    5min    30s    coam_gnb_classical.Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${active_alarms_list}    coam.get_active_alarms    connection=GNB_OAM
    ${history_alarms_list}    coam.get_historic_alarms    connection=GNB_OAM    load_history=${True}    timeout=60
    [Return]    ${active_alarms_list}    ${history_alarms_list}

Get active alarm from Gnb
    [Arguments]
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run keyword if    ${has_cbts}
    ...            Wait Until Keyword Succeeds    5min    30s    coam_gnb_classical.Cloud DU connect to gnb coam via ssl
    ...    ELSE    Wait Until Keyword Succeeds    5min    30s    coam_gnb_classical.Connect to gnb coam via ssl
    ${active_alarms_list}    coam.get_active_alarms    connection=GNB_OAM
    [Return]    ${active_alarms_list}
    [Teardown]  coam.teardown    connection=GNB_OAM

# COAM Download scf from cluster
#     ${time_stamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
#     ${scf_default_name}    BuiltIn.Catenate    SEPARATOR=${EMPTY}    scf_backup_from_cluster    ${time_stamp}    .xml
#     ${scf_file_path}    coam.Get Current Scf File    local_dir_path=${scf_dir_path}    
#     ...    file_name=${scf_default_name}    connection=${connection}    timeout=${timeout}

Collect_execution_info
    [Documentation]    keyword to collect alarm and report to DB.
    [Arguments]    ${ru_power}    ${connection}=GNB_OAM    ${gnb_index}=0
    ${active_alarms}    ${history_alarms}    Get alarms from Gnb    connection=${connection}    gnb_index=${gnb_index}
    ${alarm_result}    GnbAlarmAnalyzer.analysis_active_alarms    alarms=${active_alarms}
    ...                                                           case_name=${TEST NAME}
    ${history_result}    GnbAlarmAnalyzer.analysis_history_alarms    alarms=${history_alarms}
    ...                                                              case_name=${TEST NAME}
    # ${scf_path}    Wait Until Keyword Succeeds    2min    10s    COAM Download scf from cluster    scf_dir_path=${OUTPUT_DIR}
    ${cell_list}    admin_operation.get_all_cell_id_via_admin
    ...    connection=${connection}
    scfas.setup    scf_path=${scf_path}
    # ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    # ${technology_cells_dict}    get_cell_ids_based_on_cell_technology    connection_alias=${connection}
    # ${get_tdd_cells_mapping}    RobotCaseInfo.get_technology_cells_mapping    cell_mapping=${cell_mapping}
    # ...    technology_cells_dict=${technology_cells_dict}    technology=TDD
    # ${cell_info_list}    scfas.generate_cell_info_list_from_scf    cell_mapping=${get_tdd_cells_mapping}
    # ${lte_cell_info_list}    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot.bts.common.admin_operation.get_lte_cell_data_via_admin
    # ...                      connection=${connection}
    # ${beamforming_status}    run keyword and return status    Check RU Beamforming Status    connection=${connection}
    coam.teardown    connection=${connection}
    RobotCaseInfo.add_scf_data    cell_info_list=${cell_info_list}    lte_cell_info_list=${lte_cell_info_list}
    # RobotCaseInfo.add_gnb_data    beamforming_status=${beamforming_status}
    RobotCaseInfo.add_alarm_report_data    alarms=${alarm_result}    history=${history_result}
    RobotCaseInfo.get_execution_info
    RobotCaseInfo.report    ta_status=${TEST STATUS}    ru_power=${ru_power}    case_name=${TEST NAME}


Collection Trigger at Teardown
    [Arguments]       ${ru_power}    ${connection}    ${gnb_index}
    Collect_execution_info    ru_power=${ru_power}    connection=${connection}    gnb_index=${gnb_index}

Common Case Teardown
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=${0} 
    ${result}    ${ru_power}    BuiltIn.Run Keyword And Ignore Error    
    ...    Wait Until Keyword Succeeds    10 min    10 min    Run Keyword And Return Status    interface.Common step trigger
    BuiltIn.Run Keyword And Ignore Error    Collection Trigger at Teardown    
    ...    ru_power=${ru_power}    connection=${connection}    gnb_index=${gnb_index}

robot_common_operations.Common Case Teardown
    Check Alarm and stop robot testing when unexpected alarm raised

Check Alarm Is Allowed
    [Arguments]    ${allowed_alarm_list}       ${check_alarm}
    ${allowed_status}    BuiltIn.Set Variable    ${False}
    FOR   ${alarm}    IN    [ @{allowed_alarm_list} ]
        ${check_source}    ${source_value}    BuiltIn.Run Keyword And Ignore Error    Set Variable    ${alarm['source']}
        ${allowed_status}    BuiltIn.Run Keyword And Return Status    Run Keywords    
        ...    Should Be Equal    ${check_alarm['faultId']}    ${alarm['faultId']}    
        ...    AND    Run Keyword If    '${check_source}'=='PASS'    Should Contain    ${check_alarm['notifier']}    ${source_value}
        BuiltIn.Exit For Loop If    ${allowed_status}
    END
    BuiltIn.Run Keyword If    ${allowed_status}==${False}    
    ...    Fail    faultId ${check_alarm['faultId']} reported by ${check_alarm['notifier']} not allowed
        
Unexpect Alarm Should Not Exist
    [Arguments]    ${allowed_faults}       ${connection}    ${file_path}=${unexpected_active_alarm_file_path}
    ${active_alarms_list}    coam.Get Active Alarms    connection=${connection}
    ${active_alarms_num}    BuiltIn.Get Length    ${active_alarms_list}
    ${unexpect_alarms}    BuiltIn.Create List
    FOR    ${alarm}    IN    @{active_alarms_list}
        BuiltIn.Exit For Loop If    ${active_alarms_num}==${0}
        ${status}    BuiltIn.Run Keyword And Return Status    Check Alarm Is Allowed    allowed_alarm_list=${allowed_faults}
        ...    check_alarm=${alarm}
        BuiltIn.Run Keyword If    ${status}==${False}    Append To List    ${unexpect_alarms}    ${alarm}
        BuiltIn.Run Keyword If    ${status}==${False}    Log to console    [ ERROR ]: Unexpect Active Alarm : ${alarm['faultId']}
    END
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${unexpect_alarm_file}    BuiltIn.Set Variable    ${file_path}/unexpect_active_alarms_${timestamp}.txt
    ${alarm_num}    BuiltIn.Get Length    ${unexpect_alarms}
    BuiltIn.Run Keyword If    ${alarm_num}!=${0}    
    ...    Run    command=echo "unexpect alarm number:${alarm_num}">${unexpect_alarm_file}
    BuiltIn.Run Keyword If    ${alarm_num}!=${0}    fail    ${alarm_num}    alarms are not allowed    details in log: ${unexpect_alarm_file}

Unexpect History Alarm Should Not Exist
    [Arguments]    ${allowed_faults}       ${connection}    ${file_path}=${unexpected_history_alarm_file_path}
    ${history_alarms_list}    coam.Get Historic Alarms    connection=${connection}    timeout=100    load_history=${True}
    ${history_alarms_num}    BuiltIn.Get Length    ${history_alarms_list}
    ${unexpect_alarms}    BuiltIn.Create List
    FOR    ${alarm}    IN    [ @{history_alarms_list} ]
        BuiltIn.Exit For Loop If    ${history_alarms_num}==${0}
        ${status}    BuiltIn.Run Keyword And Return Status    
        ...    Check Alarm Is Allowed    allowed_alarm_list=${allowed_faults}    check_alarm=${alarm}
        BuiltIn.Run Keyword If    ${status}==${False}    Append To List    ${unexpect_alarms}    ${alarm}
        BuiltIn.Run Keyword If    ${status}==${False}    Log to console    Unexpect History Alarm : ${alarm['faultId']}
    END
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${unexpect_alarm_file}    BuiltIn.Set Variable    ${file_path}/unexpect_history_alarms_${timestamp}.txt
    ${alarm_num}    BuiltIn.Get Length    ${unexpect_alarms}
    BuiltIn.Run Keyword If     ${alarm_num}!=${0}    Run    command=echo "unexpect alarm number:${alarm_num}">${unexpect_alarm_file}
    BuiltIn.Run Keyword If    ${alarm_num}!=${0}    fail    ${alarm_num} alarms are not allowed, details in log: ${unexpect_alarm_file}

start Btslogs from Local machine
    [Arguments]    
    ${log_alias}    Set Suite Variable    ${syslog_alias}    
    btslog.create_btslog_collector    ${log_alias}    
    core.setup_collectors     ${log_alias}
    core.start_collectors     ${log_alias} 
    core.Set Suite Alias    ${log_alias}
Stops Btslogs from Local machine
    [Arguments]    ${log_alias}   
    Run Keyword And Continue On Failure     core.stop_collectors      names=${log_alias}   
    Run Keyword And Continue On Failure     core.collect_collectors      names=${log_alias}   
    Run Keyword And Continue On Failure    core.teardown_collectors      names=${log_alias} 

Verify_syslog_prints
    [Arguments]    ${syslog_print}
    FOR  ${i}  IN RANGE  0  1
        Verification_btslog    search_string=${syslog_print}
    END

Verification_btslog
    [Documentation]
    [Arguments]    ${BTSLOG_Path_for_validation}  
    ${dir_path}    Set suite variable    ${BTSLOG_Path_for_validation}  
    Validation.validate_syslog_file_contents    dir_path=${dir_path}


Load_defult_SWconfigfile
    [Documentation]   Need to be implement
    [Arguments]     
    ${Standard_swconfigfile_path}    Set Variable    ${backup_remote_path}
    SSH.Upload File    local_path=${Standard_swconfigfile_path}    remote_path=${sw_config_path}    connection=${sysmod_alias}
    [Return]    

ssh_connection_to_system_module
    [Arguments]    
    
    SSH.Connect To    hostname=${Sys_module_login_ip}    username=${Sys_module_login_username}
    ...    password=${Sys_module_login_password}     alias=${sysmod_alias}
    SSH.Send Command  command=cd /ffs/run    connection=${sysmod_alias}
    SSH.Send Command  command=ls -lrt | grep swconfig.txt    connection=${sysmod_alias}
    Set Suite Variable    ${remote_path}        ${swconfigfilepath}
    ${swconfigfile_available}    SSH.File Exists    remote_path=${remote_path}    connection=${sysmod_alias}
    Set Suite Variable    ${swconfigfile_available}
    [Return]    ${swconfigfile_available}

Modified_Swconfigfile_for_adding_flag
    [Documentation]
    [Arguments]

    SSH.Download File    remo=te_path=${backup_remote_path}    local_path=${remote_path}
    ...    connection=${sysmod_alias}
    # Check file contain 
    

Get_Time_Current_Time    
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    [Return]     ${timestamp}
    
SCF_Commission
    [Arguments]      ${Commission_file}=${scf_commission}
    Directory Should Exist    ${SCF_PATH}   
    admin.perform_commissioning    ${BTS_ID}    skip_parameter_relation_errors=true
    ...        scf_file=${Commission_file}   timeout=200

Test_Setup_keywords  
    coam.Connect to    
    SCF_Commission     ${scf_commission}
    Sleep    100s
    Get_MRBTS_NRBTS_IDs
    Start_Dcap

Test_Teardown_Keywords
    Stop_Dcap
    coam.teardown_admin

Start_Dcap
    rd.connect_to      host=${Dcap_Server_Details.host}    port=${Dcap_Server_Details.port}
    ...             secure=${True}  
    ${out_put}    rd.start_trace     duration=-1     bts=&{Dcap_User_Details}
    ...        gnb_custom_profile=@{Only_Gnb_custom_profile}    bts_custom_profile=@{Bts_custom_profile}
    ...        wait_for_activation=True
    Log To Console    ${out_put}
    ${trace_id}     Get From Dictionary     ${out_put}    tracer_id
    Set Suite Variable    ${trace_id} 
Stop_Dcap
    [Arguments]        ${Dcap_Trace_ID}=${trace_id}
    Log To Console    ${Dcap_Trace_ID}
    rd.stop_trace    ${Dcap_Trace_ID}
    Sleep    3m    DCAP log stopping take more then expected.To avoid unwanted interfrence
    ${DCAP_results_path}    OperatingSystem.Join Path    ${OUT_SUITE_LOGS_DIR_PATH}    DCAP_Logs
    Create Directory  ${DCAP_results_path}
    rd.get_results     target_dir=${DCAP_results_path}    timeout=200
