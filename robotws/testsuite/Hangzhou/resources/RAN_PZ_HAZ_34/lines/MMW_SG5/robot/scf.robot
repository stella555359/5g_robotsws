*** Settings ***
Documentation
...             Usefull keywords for scf
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001655/Resources/1347_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot

*** Variables ***

${GN_OAM_ADDR}=      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
*** Keywords ***
#######################################
### GENERIC KEYWORDS
#######################################

scf uploading and commissioning
    [Tags]                          commissioning
    [Arguments]    ${Log_directory}    ${SCF_Filename}
    Log                             \nCommissioning gNodeB with ${Log_directory}/${SCF_Filename}
    coam_gnb_classical.Connect to gnb coam via ssl
    coam_gnb_classical.COAM Commission with scf file    scf_file_path=${Log_directory}/${SCF_Filename}
    ...    is_pdl_checking_needed=${False}    timeout=900
    wait until keyword succeeds    1200      5    coam_gnb_classical.COAM Check GNB cell on air
    Run Keyword And Continue On Failure    Wait For Fault with Alarm to disappear    FaultID=7319
    Run Keyword And Continue On Failure    Wait For Fault with Alarm to disappear    FaultID=7300
    Sleep    5mins
    Run Keyword And Ignore Error    coam_gnb_classical.COAM Teardown gnb connections    connection=GNB_OAM

Wait For Fault with Alarm to disappear
  [Arguments]  ${FaultID}
  wait until keyword succeeds  1200      5    Fault Should Not Be Present   ${FaultID}

Fault Should Not Be Present
  [Arguments]    ${fault_id}
  ${active_alarms}    coam.get_active_alarms    timeout=600s    connection=GNB_OAM
  ${len}    Get Length    ${active_alarms}
  ${alarm_id_list}    Create List
  FOR    ${i}    IN RANGE    ${len}
      ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
      Append To List    ${alarm_id_list}    ${tmp_id}
  END
  ${list}     convert to string  ${alarm_id_list}
  Should Not Contain     ${list}    ${fault_id}

WebUI gNB Set Attribute Value
  [Documentation]     Set gNB Param Value using webUI
    [Arguments]         ${dist_name}    ${p_name}    ${new_value}
    wait until keyword succeeds    3x  10s  coam_gnb_classical.Connect to gnb coam via ssl
    Log                 logged in webUI. begin modif of ${dist_name} ${p_name} to ${new_value}
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${p_name}    operation=update
    ...  value=${new_value}  timeout=900  skip_parameter_relation_errors=True  connection=GNB_OAM
    [Teardown]          coam.teardown  connection=GNB_OAM

Activate Parameter Value
    [Arguments]         ${dist_name}    ${p_name}    ${new_value}
    ${pre_ModifiedValue}    scf.gNB Get Attribute value in SCF     dist_name=${dist_name}
    ...                 p_name=${p_name}
    ${status}  Run Keyword And Return Status  Should Not Be Equal     ${new_value}    ${pre_ModifiedValue}
    Run Keyword If  ${status}  wait until keyword succeeds    2x    5s
    ...     WebUI gNB Set Attribute Value    dist_name=${dist_name}            p_name=${p_name}
    ...     new_value=${new_value}
    ${ModifiedValue}    scf.gNB Get Attribute value in SCF     dist_name=${dist_name}
    ...                 p_name=${p_name}
    Run Keyword If  ${status}  should be equal     ${new_value}    ${ModifiedValue}
    Run Keyword If  ${status}  sleep               1s
    Run Keyword If  ${status}  coam_gnb_classical.Connect to gnb coam via ssl
    Run Keyword If  ${status}  wait until keyword succeeds    1200      5    coam_gnb_classical.COAM Check GNB cell on air
    Run Keyword If  ${status}  Run Keyword And Ignore Error    coam_gnb_classical.COAM Teardown gnb connections    connection=GNB_OAM

gNB Get Attribute value in SCF
    [Documentation]     Get element value in SCF content
    [Arguments]         ${dist_name}    ${p_name}
    ${content}=         scf.gNB Get SCF Content
    ${xml_root}=        XML.Parse XML    ${content}
    ${result}=          XML.Get Element    ${xml_root}
    ...                 .//managedObject[@distName="${dist_name}"]/p[@name="${p_name}"]
    [Return]            ${result.text}

gNB Get CellId and BTSId DN in SCF
    ${content}=    gNB Get SCF Content
    ${parsed_xml}=    XML.Parse Xml    ${content}
    ${cell_elements}=     XML.Get Elements    ${parsed_xml}
    ...    cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    BuiltIn.Should Not Be Empty    ${cell_elements}
    ${cell_num}=    BuiltIn.Get Length    ${cell_elements}
    Set Suite Variable    ${cell_num}
    BuiltIn.Set Suite Variable    ${CV_NRCELL_1}    ${cell_elements[${cell_num}-1].attrib['distName']}
    BuiltIn.Set Suite Variable    ${CV_NRBTS}    ${cell_elements[${cell_num}-1].attrib['distName'].split('/NRCELL')[0]}

gNB Get SCF Content
    [Documentation]     Get SCF content
    wait until keyword succeeds    3x  10s  coam_gnb_classical.Connect to gnb coam via ssl
    ${content}=         coam.get_scf  timeout=900  with_auto_configured_parameters=${True}   connection=GNB_OAM
    [Return]            ${content}
    [Teardown]          coam.teardown  connection=GNB_OAM


Activate or Deactivate feature
    [Arguments]    ${delta_file}
    ...            ${skip_parameter_relation_errors}=True
    ...            ${should_activate}=${True}
    ...            ${timeout}=300
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    Connect to gnb coam via ssl  gnb_index=${gnb_index}  connection=${connection}
    coam.Perform Delta Recommissioning
    ...                                        delta_file=${delta_file}
    ...                                        skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                        should_activate=${should_activate}
    ...                                        timeout=${timeout}
    ...                                        connection=${connection}
    wait until keyword succeeds    1200      5    coam_gnb_classical.COAM Check GNB cell on air  connection=${connection}
    [Teardown]    Run keyword and ignore error  coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}

Modify json file
    [Arguments]  ${json_file}  ${old_string}=MRBTSID  ${new_string}=${MRBTSID}
    ${filter_res}   OperatingSystem.Run    cat ${json_file} | grep ${old_string}
    ${status}    Run keyword and return status    Should Not Be Empty    ${filter_res}
    Run Keyword If    ${status}    Run Keyword And Ignore Error     OperatingSystem.Run
    ...    sed -i 's/${old_string}/${new_string}/g' ${json_file}

Modify json file before testing
    [Arguments]  ${json_file}  ${string_1}=${MRBTS_ID}  ${string_2}=${NRBTS_ID}
    Modify json file  json_file=${json_file}  old_string=MRBTSID  new_string=${string_1}
    Modify json file  json_file=${json_file}  old_string=NRBTSID  new_string=${string_2}


Modify json file after testing
  [Arguments]  ${json_file}  ${string_1}=${MRBTS_ID}  ${string_2}=${NRBTS_ID}
  Modify json file  json_file=${json_file}  old_string=${string_1}  new_string=MRBTSID
  Modify json file  json_file=${json_file}  old_string=${string_2}  new_string=NRBTSID

Modify json file and activate
  [Arguments]  ${json_file}  ${string_1}=${MRBTS_ID}  ${string_2}=${NRBTS_ID}  ${connection}=GNB_OAM
  ...  ${gnb_index}=0
  Modify json file before testing  json_file=${json_file}  string_1=${string_1}  string_2=${string_2}
  scf.Activate or Deactivate feature  delta_file=${json_file}  timeout=600  connection=${connection}
  ...  gnb_index=${gnb_index}
  [Teardown]  Modify json file after testing  json_file=${json_file}  string_1=${string_1}  string_2=${string_2}

Modify common json file
    [Arguments]  ${json_file}  ${string_1}=${MRBTS_ID}  ${string_2}=${NRBTS_ID}
    ${len}  Get Length  ${string_1}
    FOR  ${i}  IN RANGE  0  ${len}
      Modify json file  json_file=${json_file}  old_string=${string_1}[${i}]  new_string=${string_2}[${i}]
    END

Modify common json file and activate
  [Arguments]  ${json_file}  ${old_string}=MRBTSID  ${new_string}=${MRBTSID}  ${diff_env}=${True}
  Modify json file  json_file=${json_file}  old_string=${old_string}  new_string=${new_string}
  Run keyword If  ${diff_env}  Modify json file and activate  json_file=${json_file}
  ...  ELSE  scf.Activate or Deactivate feature  delta_file=${json_file}  timeout=600
  [Teardown]  Modify json file  json_file=${json_file}  old_string=${new_string}  new_string=${old_string}

Modify common json file and activate for different ENV
  [Arguments]  ${json_file}  ${old_string}=MRBTSID  ${new_string}=${MRBTSID}  ${string_1}=${MRBTS_ID}  ${string_2}=${NRBTS_ID}
  ...  ${connection}=GNB_OAM  ${gnb_index}=0  ${diff_env}=${True}
  Run keyword If  ${diff_env}  Modify json file before testing  json_file=${json_file}  string_1=${string_1}  string_2=${string_2}
  Modify common json file  json_file=${json_file}  string_1=${old_string}  string_2=${new_string}
  scf.Activate or Deactivate feature  delta_file=${json_file}  timeout=600  connection=${connection}
  ...  gnb_index=${gnb_index}
  [Teardown]  Run keywords  Run keyword If  ${diff_env}  Modify json file after testing  json_file=${json_file}  string_1=${string_1}
  ...  string_2=${string_2}
  ...  AND  Modify common json file  json_file=${json_file}  string_1=${new_string}  string_2=${old_string}

Get btsname from scf
    ${btsname}    scf.gNB Get Attribute value in SCF     dist_name=MRBTS-${MRBTS_ID}
    ...                 p_name=btsName
    Set Suite Variable  ${btsname}

Get cellname from scf
    [Arguments]  ${cell_id}
    ${cellname}    scf.gNB Get Attribute value in SCF     dist_name=${GNB_PATH}/NRCELL-${cell_id}
    ...                 p_name=cellName
    [Return]  ${cellname}

Get nr cell id mapping
    [Arguments]  ${connection}=GNB_OAM  ${gnb_index}=0
    &{nr_cell_id_mapping}  coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    ...  connection_alias=${connection}  gnb_index=${gnb_index}
    # coam_gnb_classical.Get nr cell id mapping if not exist  connection=${connection}
    ${info}  Collections.Get Dictionary Values  ${nr_cell_id_mapping}
    Set suite variable  ${info}

Get physical Cell Id Via Index
    [Arguments]  ${index}
    [Documentation]  index:lcrId
    FOR    ${cur_info}    IN    @{info}
        ${physical_Cell_Id}    set variable   ${cur_info}[physicalCellId]
        ${cell_index}    set variable   ${cur_info}[lcrId]
        Exit For Loop If    ${index}==${cell_index}
    END
    [Return]    ${physical_Cell_Id}

Get real SCF From BTS
    [Arguments]  ${connection}=GNB_OAM
    ...          ${sub_scf_dir}=tmp_scf
    ...          ${config_type}=configurationAndRuntimeObjects
    Log To Console  Get SCF From BTS
    ${local_dir}    Set Variable     ${TS_CASE_LOG_PATH}/${sub_scf_dir}
    Create Directory    ${local_dir}
    ${current_time}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S%f
    ${scf_file_path}     Set Variable    ${local_dir}/scf_${current_time}.xml
    coam.collect_scf    target_file_name=${scf_file_path}    export_type=${config_type}
    ...    timeout=30    connection=${connection}
    [Return]   ${scf_file_path}

Get Parameter Value from SCF
    [Arguments]  ${parameter}    ${dist_name}  ${scf_file_path}  ${p_index}=${0}    ${list_name}=${None}    ${connection}=GNB_OAM
    ...          ${config_type}=configurationAndRuntimeObjects
    Log To Console  Get ${parameter} Value from SCF
    ${value}     coam_parameter.get_single_value_from_scf_file    local_dir_path=${scf_file_path}   p_index=${p_index}
    ...       parameter=${parameter}   list_name=${list_name}   dist_name=${dist_name}
    ...       connection=${connection}    config_type=${config_type}
    # run keyword and ignore error    run    rm -rf ${local_dir}
    [Return]   ${value}

Add fault id
  AlarmWatchdog.add_allow_alarms    fault_id=4590
  AlarmWatchdog.add_allow_alarms    fault_id=7107
  AlarmWatchdog.add_allow_alarms    fault_id=7305
  AlarmWatchdog.add_allow_alarms    fault_id=7304
  AlarmWatchdog.add_allow_alarms    fault_id=7308
  AlarmWatchdog.add_allow_alarms    fault_id=4298
  AlarmWatchdog.add_allow_alarms    fault_id=4592

Remove fault id
  AlarmWatchdog.remove_allow_alarms    fault_id=4590
  AlarmWatchdog.remove_allow_alarms    fault_id=7107
  AlarmWatchdog.remove_allow_alarms    fault_id=7305
  AlarmWatchdog.remove_allow_alarms    fault_id=7304
  AlarmWatchdog.remove_allow_alarms    fault_id=7308
  AlarmWatchdog.remove_allow_alarms    fault_id=4298
  AlarmWatchdog.remove_allow_alarms    fault_id=4592

Uploading and commissioning SCF
  [Arguments]  ${SCF_Filename}=None
  Add fault id
  Run Keyword IF  '${SCF_Filename}' == 'None'  CI_interface.Common Suite Setup
  ...  ELSE  scf.scf uploading and commissioning  Log_directory=${Log_directory}  SCF_Filename=${SCF_Filename}
  Remove fault id
