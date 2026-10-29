*** Settings ***
Documentation
...   author: cristinel.sava@nokia.com
...   contact: cristinel.sava@nokia.com
...   update: cristinel.sava@nokia.com

Library    BuiltIn
Library    DateTime
Library    Collections
Library    taf.ul.verify_snapshot    WITH NAME    snapshot
Library    taf.transport.ssh         WITH NAME    tafssh
Library    taf.rfrl.cbts.utilities.generic_utils
Library    taf.rfrl.cbts.connections.rest_conn_vdu.GenericVDU    WITH NAME    vdu_gen
Library    taf.rfrl.cbts.devices.vdu.business.vdu_cm_business    WITH NAME   vdu_cm_business
Resource    ../../common_resources/vdu_frame.robot
Resource    ../../common_resources/vdu_general.robot
Resource    ../../common_resources/vcu_frame.robot
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_logging.robot
Resource    ../resources/LOGS_general.robot
Library  taf.gnb.oam.coam.vdu  WITH NAME  vdu
Library  taf.gnb.oam.coam.vdu.interface.vdu   WITH NAME  vdu1
Library    taf.rfrl.cbts.utilities.generic_utils    WITH NAME    generic_utils
Library           json
Resource    ../resources/verdicts.robot

Resource    ../../../SBTS/resources/pdu.robot
Library    String
Library     taf.hw.pdu     WITH NAME   pdu
Resource    ../resources/unpacking.robot
#Library    ../../test_line_specific/TSR7/Vdu139/Lib/CB010411.py
Library    ../resources/python/CB010411.py

*** Variables ***
${VDU_SCFC_PATH}  ${CURDIR}/SCF/vCu/vDu.xml
${VCU_SCFC_PATH}  ${CURDIR}/SCF/vCu/vCu.xml
@{LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}=    Create List
${REVERT_DELTA_CHANGES}    ${False}

${cell_list}    1

${FILE}    /home/ute/btsauto/logs/__init__.py
${model_l}    unknow
${tip_pdu}    unknow
${PDU_nr}     unknow
${PORT_nr}    unknow
${pdu_ip}     unknow
${version_pdu}    unknow

*** Keywords ***
TC__LOGS__CB012144-CR-A-RU_POST_data_verify_in_snapshot
    [Documentation]
    ...  CB012144-RU_POST_data_verify_in_snapshot


    Step 0: Precondition
    Step 1: RU_POST_data_verify_in_snapshot

Step 0: Precondition
   [Documentation]
    ...   In this step Precond
     Log    \nStep 0: Precondition    console=${True}
     Log    \nConnecting to vDU and set all necessary variables   console=${True}

    ${taf_config_model}=  Run keyword and return status   Variable should exist  ${tl}
    Set test variable  ${TAF_CONFIG_MODEL}  ${taf_config_model}
    Set test variable   ${SAVE LOG DIRECTORY}    ${TEST_RESULTS_DIR}
    Run keyword if  ${TAF_CONFIG_MODEL}  Taf config adapter
    ...       ELSE
    ...       Run Keywords
    ...       Import Library      hran_testline_configuration   ${HW_LOCATION_CODE}  ${TESTLINE_NAME}  AND
    ...       hran_testline_configuration.Set Config Variables   @{TESTLINE_CONFIG_VARIABLES}

    Set Test Variable    ${REVERT_DELTA_CHANGES}  ${False}
    ${rmod_listed}    vdu.get rmods status
    ${ids}    Create List
    Set Test Variable    ${ids}
    ${serial_numbers}      Create List

    FOR    ${item}    IN    @{rmod_listed}
        ${serial_number}    Get From Dictionary    ${item}    serial_number
        ${id}    Get From Dictionary    ${item}    id
        ${dist_names}    Get From Dictionary    ${item}    dist_names
        Append To List    ${serial_numbers}    ${serial_number}
        Append To List    ${ids}    ${id}
    END
    Set Test Variable    ${serial_numbers}
    ${config_value}    Set Variable    ${dist_names['config']}
    ${split}    Split String    ${config_value}    /
    ${mr_id}    Get From List    ${split}    0
    ${vdu_id}    Split String    ${mr_id}    -
    ${vdu_id}    Get From List    ${vdu_id}   1
    Set Test Variable  ${vdu_id}

    ${date}     Get Current Date    time_zone=UTC    result_format=%Y-%m-%d
    Set Test Variable    ${date}

    Set Test Variable    ${logs_dir}    ${TEST_RESULTS_DIR}
    sleep    3
#    Verify First Cell Are Disabled for vDU

Step 1: RU_POST_data_verify_in_snapshot
    Log    \nStep 1: RU_POST_data_verify_in_snapshot    console=${True}
    [Arguments]   ${ru_index}=${1}
    Log To Console    RMOD power off and power on and reset 3 times start

    ${rmods}    Get Rmod List
    ${post_three_time_date}    Create List
    ${post_three_timestamp}    Create List
    FOR    ${i}    IN RANGE  ${3}    #normal =3
        ${post_check_start_time}    DateTime.Get Current Date    result_format=timestamp
        Log To Console    ${i+1}th time RMOD power off and power on and  reset
        pdu.setup_pdu    model=${model_l}    host=${pdu_ip}    alias=${tip_pdu}    version=${version_pdu}
        pdu.power_on    ${PORT_nr}   pdu_device=${tip_pdu}
        pdu.teardown_pdu    pdu_device=${tip_pdu}
        log to console    check cell status should be disabled for du...

        wait until keyword succeeds    3min    5s    Verify First Cell Are Disabled for vDU
        log to console    check fault 10 reported on du
        wait until keyword succeeds    3min    5s    Expect Fault Should Present On vDU    fault_id=10
        pdu.setup_pdu    model=${model_l}    host=${pdu_ip}    alias=${tip_pdu}    version=${version_pdu}
        pdu.power_off    ${PORT_nr}   pdu_device=${tip_pdu}
        pdu.teardown_pdu    pdu_device=${tip_pdu}
        wait until keyword succeeds     6min    5s    Verify All Rmods Status Should Be Normal for vDU
        log to console    check cell should be on air for du...
        wait until keyword succeeds     6min    5s    Verify All Cells Status Should Be Onair for vDU
        ${post_check_stop_time}    DateTime.Get Current Date    result_format=timestamp
        Reset Rmod By Rest    rmods_list=${rmods}
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds    3min    5s    Verify First Cell Are Disabled for vDU
        log to console    check cell should be on air for du...
        wait until keyword succeeds     6min    5s    Verify All Cells Status Should Be Onair for vDU
        Append To List    ${post_three_time_date}    ${post_check_start_time}
        Append To List    ${post_three_time_date}    ${post_check_stop_time}
        ${post_check_start_timestamp}    DateTime.Convert Date    ${post_check_start_time}    result_format=epoch
        ${post_check_stop_timestamp}    DateTime.Convert Date    ${post_check_stop_time}    result_format=epoch
        Append To List    ${post_three_timestamp}    ${post_check_start_timestamp}
        Append To List    ${post_three_timestamp}    ${post_check_stop_timestamp}
    END

    ${Snapshot_file_path}    Save Local Snapshot In vDU    local_snapshot_location=post_snapshot    compressed_or_not=${False}
    should exist    ${Snapshot_file_path}/RU_${ru_index}.zip
    Unp Archive Content To Directory  ${Snapshot_file_path}/RU_${ru_index}.zip  ${Snapshot_file_path}/RU_${ru_index}
    ${detail_files}    OperatingSystem.List Files In Directory    path=${Snapshot_file_path}/RU_${ru_index}
    FOR    ${file_name}  IN  @{detail_files}
        ${result}    Run Keyword And Return Status    Should Contain    ${file_name}    BBOX5
        ${BBOX5_file_name}=    Set Variable If    ${result}    ${file_name}
        Exit For Loop If    ${result}
    END

    Unp Archive Content To Directory  ${snapshot_path}/RU_${ru_index}/${BBOX5_file_name}    ${snapshot_path}/RU_${ru_index}/BBOX5_file
    ${post_result_number}    ${post_dict_content}    get_post_result_content_from_file    ${snapshot_path}/RU_${ru_index}/BBOX5_file/BBOX5
    Should Be Equal    ${post_result_number}    ${3}
    ${post_result}    Set Variable    OK
    ${post_type}    Set Variable    NORMAL
    FOR    ${i}    IN RANGE    ${post_result_number}
        ${rmod_three_start_index}    Evaluate    6 - ${i+1} * 2
        ${rmod_three_stop_index}    Evaluate    5 - ${i} * 2
        Should Be Equal    ${post_dict_content['POST[${i}] type']}    ${post_type}
        Should Be Equal    ${post_dict_content['POST[${i}] result']}    ${post_result}
        ${time_zone_align}=    Add Time To Date    ${post_dict_content['POST[${i}] timestamp']}      00:00:00    result_format=%Y-%m-%d %H:%M:%S
        ${post_timestamp}    DateTime.Convert Date    ${time_zone_align}   result_format=epoch
        Run Keyword And Continue On Failure    Should Be True     ${post_timestamp} > ${post_three_timestamp[${rmod_three_start_index}]}
        ...  msg=RMOD ${${3}-${i}}th power off start time ${post_three_time_date[${rmod_three_start_index}]} after post time ${time_zone_align}
        Run Keyword And Continue On Failure    Should Be True     ${post_timestamp} < ${post_three_timestamp[${rmod_three_stop_index}]}
        ...  msg=post time ${time_zone_align} before RMOD ${${3}-${i}}th power off start time ${post_three_time_date[${rmod_three_stop_index}]}
    END

Unp Archive Content To Directory
    [Documentation]
    ...  Unpacks the given file to the specified destination directory, based on its file extension.
    ...  example of simple use:  Unpack Archive Content To Directory   ${file}  ${destination_directory}
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    [Arguments]    ${file}    ${destination}
    ${extension}=    Get File Ext    ${file}
    Run Keyword If    '${extension}' == 'zip'    _Unzip To Directory    ${file}    ${destination}
    Run Keyword If    '${extension}' == 'tar'    _Untar To Directory    ${file}    ${destination}
    Run Keyword If    '${extension}' == 'tgz'    _Untgz To Directory    ${file}    ${destination}
    Run Keyword If    '${extension}' == 'gz'    _Ungz To Directory    ${file}    ${destination}
    Run Keyword If    '${extension}' == 'xz'    _Unxz To Directory    ${file}    ${destination}

_Unzip To Directory
    [Documentation]
    ...  Unpacks the given .zip file to the specified destination directory.
    ...  If directory does not exist it will be created
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    [Arguments]    ${zip_file}    ${destination_dir}
    OperatingSystem.File Should Exist   ${zip_file}    msg=File ${zip_file} doesn't exist!
    ${state}    Run Keyword and return status    OperatingSystem.Directory Should Exist    ${destination_dir}
    Run Keyword if    ${state}==False    Run Keyword    Run    mkdir -p ${destination_dir}
    Run    unzip -o ${zip_file} -d ${destination_dir}
    ${state2}    Run Keyword and return status    OperatingSystem.Directory Should Not Be Empty    ${destination_dir}
    Run Keyword if    ${state2}==False    Log    Extract directory is empty    WARN
    #TAT-26884:
    Append To List    ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}    ${destination_dir}

Get File Ext
    [Documentation]
    ...  Returns the extension of the given file.
    ...
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    [Arguments]    ${file}
    ${extension}    Fetch From Right  ${file}    .
    [Return]    ${extension}


Save Local Snapshot In vDU
    [Arguments]    ${local_snapshot_location}=vdu_snapshot    ${compressed_or_not}=${True}
    log to console    Save vdu Local Snapshot...
    set test variable  ${Snapshot_path}    ${SAVE LOG DIRECTORY}${local_snapshot_location}
    create directory   ${Snapshot_path}
    ${Snapshot_file_path}    vdu.Get_Local_Snapshot    ${Snapshot_path}    compressed_or_not=${compressed_or_not}
    [Return]    ${Snapshot_file_path}


Reset Rmod By Rest
    [Arguments]   ${rmods_list}    ${alias}=default
    log to console   Reset RUs ${rmods_list} by REST...
    ${out}   vdu.reset_rmods     rmods_list=${rmods_list}    vdu_connection=${alias}
    Wait Until Keyword Succeeds  60   3   _Check Reset RUs Status Should Be Expected
    ...    operation_id=${out["operation_id"]}    expected_status=ongoing    vdu_connection=${alias}

_Check Reset RUs Status Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}     ${vdu_connection}=default
    ${out}    vdu.get_reset_rmods_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...    vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

Verify All Cells Status Should Be Onair for vDU
    [Arguments]  ${alias}=default
    ${cells_status}=  vdu.get_vdu_cells_status     vdu_connection=${alias}
    FOR  ${cell}  IN  @{cells_status}
        Run keyword    Should be equal as strings    ${cell['operational_state']}    enabled
        ...  msg=operational_state for cell ${cell['id']} is not enabled
        Run keyword    Should be equal as strings    ${cell['availability_status']}    on line
        ...  msg=availability_status for cell ${cell['id']} is not on line
        Run keyword    Should be equal as strings    ${cell['administrative_state']}    Unlocked
        ...  msg=administrative_state for cell ${cell['id']} is not Unlocked
        Run keyword    Should be equal as strings    ${cell['procedural_status']}    configured
        ...  msg=procedural_status for cell ${cell['id']} is not configured
        Run keyword    Should be equal as strings    ${cell['blocking_state']}    Unblocked
        ...  msg=blocking_state for cell ${cell['id']} is not Unblocked
    END

Verify All Rmods Status Should Be Normal for vDU
    [Arguments]       ${alias}=default

    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${alias}
    FOR  ${ru}  IN  @{rmods_status}
        Run keyword    Should be equal as strings    ${ru['operational_state']}    enabled
        ...  msg=operational_state for ru ${ru['id']} is not enabled
        Run keyword    Should be equal as strings    ${ru['availability_status']}    on line
        ...  msg=availability_status for ru ${ru['id']} is not on line
        Run keyword    Should be equal as strings    ${ru['administrative_state']}    Unlocked
        ...  msg=administrative_state for ru ${ru['id']} is not Unlocked
        Run keyword    Should be equal as strings    ${ru['procedural_status']}    configured
        ...  msg=procedural_status for ru ${ru['id']} is not configured
    END
    Sleep    5s

Expect Fault Should Present On vDU
    [Arguments]    ${fault_id}    ${alarming_object}=${None}    ${severity}=${None}    ${alarm_id}=${None}
    ...            ${alias}=default
    ${fault_id}    Convert To Integer    ${fault_id}
#    Wait Until Keyword Succeeds    5 min    10 sec    Connect To VDU  host=${VDU_OAM_IP}
    ${alarms}    vdu.vdu_get_active_alarms    vdu_connection=${alias}
    ${alarm_num}    Get From Dictionary    ${alarms}    total
    Run Keyword If    ${alarm_num}==0    Fail
    ${alarms}    Get From Dictionary    ${alarms}    alarms
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
        ${present_status}    Run Keyword And Return Status    Run Keywords
        ...    Dictionary Should Contain Item    ${alarm}    fault_id    ${fault_id}    AND
        ...    Run Keyword If    '${alarming_object}'!='${None}'
        ...    Should Contain     ${alarm['alarming_object']}    ${alarming_object}    case_insensitive=True    AND
        ...    Run Keyword If    '${severity}'!='${None}'
        ...    Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
        ...    Run Keyword If    '${alarmId}'!='${None}'
        ...    Should Be Equal As Strings    ${alarm['alarm_id']}    ${alarm_id}
        Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail
    Sleep    5s

Verify First Cell Are Disabled for vDU
    [Arguments]     ${alias}=default
    sleep    5s
    ${cells_status}=    vdu.get_vdu_cells_status     vdu_connection=${alias}
    log to console    id_celula:${cells_status[0]['id']}
    FOR  ${cell}  IN  @{cells_status}
        Run keyword if    ${cell['id']} == 239    Should be equal as strings    ${cell['operational_state']}    disabled
#            ...  msg=operational_state for cell ${cell['id']} is not disabled
    END


Verify All Cells Are Disabled for CU
    [Arguments]  ${gnb_index}=0
    CU Login SG8  ${gnb_index}
    ${cells_status}=   cu.get_cells_statuses
    FOR  ${cell}  IN  @{cells_status}
        Run keyword    Should be equal as strings    ${cell['operational_state']}    disabled
        ...  msg=operational_state for cell ${cell['id']} is not disabled
    END
    [Teardown]   run keyword and ignore error   CU Logout SG8

Get Rmod List
    [Arguments]      ${alias}=default
    ${conn_alias}    generic_utils.get_unique_id_string
    Connect To VDU  host=${VDU_OAM_IP}
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${alias}
    ${rmods}  create list
    FOR    ${rmod}    IN    @{rmods_status}
        append to list    ${rmods}    ${rmod}[id]
    END
    [Return]    ${rmods}

Cloud Perform RU Power Off
    [Arguments]    ${ru_index}=${1}    ${gnb_index}=${0}    ${vdu_index}=${0}
    ...    ${model}=${tl.gnbs[0].dus[0].fhgws[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    ...    ${ru_pdu_ip}=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}-1].pdu_port.pdu.addr}
    ...    ${ru_pdu_port}=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}-1].pdu_port.port_no}
    [Documentation]    *****************
    ...    This keyword is designed to power off a given RU (Remote Unit).
    ...    - [Keyowrd Details]
    ...    It generates a unique string and uses it to connect to the vDU.
    ...    It retrieves the model, IP, and port of the PDU (Power Distribution Unit) for the given RU.
    ...    It then powers off the PDU port for the RU and logs a message.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ru_index | No | The RU index. Default is 1. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...    | model | No | The model of the PDU. Default is the model of the PDU for the given RU from testline configuration. |
    ...    | ru_pdu_ip | No | The IP of the PDU for the given RU. Default is the IP of the PDU for the given RU from testline configuratio. |
    ...    | ru_pdu_port | No | The port of the PDU for the given RU. Default is the port of the PDU for the given RU from testline configuratio. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* kaihui.fan@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *******************
    log to console    \nPower Off Rmod ${ru_index}
    ${ru_index}    Convert to integer    ${ru_index}
    pdu.setup_pdu    model=${model}   host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}
    pdu.power_off    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}
    BuiltIn.Log    Reset RU via Power off and Power On.

TAF Config Adapter
    @{configuration}=   Split String  ${CONFIGURATION}  .
    @{tl_params}=       Split String  ${configuration}[1]  _
    Set suite variable  ${HW_LOCATION_CODE}        ${configuration}[0]
    Set suite variable  ${TESTLINE_NAME}           ${tl_params}[0]_${tl_params}[1]_${tl_params}[2]
    Set suite variable  ${TEMP_LOGS_DIR}            /home/ute/btsauto/logs
    Run    mkdir -p /home/ute/btsauto
    Run    mkdir -p /home/ute/btsauto/logs
    Run    cp /home/ute/testline_configuration/${TESTLINE_NAME}/__init__.py ${TEMP_LOGS_DIR}/__init__.py
    Extract PDU Line


Extract PDU Line
    ${content}=    OperatingSystem.Get File    ${FILE}

    # search exactly n caracters after text
    ${match}=    Get Regexp Matches    ${content}    pdu_port=_pdu_(.{14})
    ${model}=    Get Regexp Matches    ${content}    model=(.{6})
    ${tip}=    Get Regexp Matches    ${content}    _pdu_1 = (.{4})
    ${version}=    Get Regexp Matches    ${content}    version=(.{7})
    Log    Found: ${model}
    Log    Found: ${tip}
    Log    Found: ${version}
#    ${tip_pdu}  Fetch From Right  ${tip}[0]  -
    ${tip_pdu}    Evaluate    "${tip}[0][-4:]"
    ${version_pdu}    Evaluate    "${version}[0][-6:]"
    Log    Found tip_pdu: ${tip_pdu}
    Log    Found version_pdu: ${version_pdu}
    ${model_str}=    Get From List    ${model}    0
    ${model_l}=      Evaluate           re.findall(r'model="([A-Za-z]+)"', '${model_str}')    modules=re
    Log              Letters in model: ${model_l}[0]


    ${pdu_and_port}=    Set Variable    ${match[0]}
    Log    Found: ${pdu_and_port}
    # found IP address in object _pdu_1
    ${match}=    Get Regexp Matches    ${content}    _pdu_1\\s*=\\s*Gude\\([^)]*addr="([^"]+)"
    ${ip_pdu}=    Set Variable    ${match[0]}

    Log    Found IP: ${ip_pdu}

    # Extract PDU and Port using regex

    Log    ${pdu_and_port}
    ${pdu_and_port}=    Set Variable    ${pdu_and_port}
    ${matches}=    Evaluate    re.findall(r"_pdu_(\\d+)\\.pdu_ports\\[(\\d+)\\]", """${pdu_and_port}""")    modules=re
    Log    ${matches}
    ${PDU_nr}=    Set Variable    ${matches[0][0]}
    ${PORT_nr}=   Set Variable    ${matches[0][1]}
    Log    PDU number=${PDU_nr}, PORT number=${PORT_nr}

    ${ip_pdu}=    Set Variable    ${ip_pdu}

    # 1. replace newlines wirh space to hane only a string
    ${clean_text}=    Replace String    ${ip_pdu}    \n    " "

    # 2. Extract IP
    ${matches1}=    Evaluate        re.findall(r'addr="([\\d\\.]+)"', '${clean_text}')    modules=re

    # 3. take first resoult
    ${pdu_ip}=            Set Variable    ${matches1}[0]

    # 4. IP
    Log               Found IP: ${pdu_ip}
    [Return]    ${PDU_nr}    ${PORT_nr}    ${pdu_ip}    ${model_l}   ${tip_pdu}    ${version_pdu}
    ${model_l}    Get From List    ${model_l}    0
    Set Global Variable    ${model_l}
    Set Global Variable    ${tip_pdu}
    Set Global Variable    ${PDU_nr}
    Set Global Variable    ${PORT_nr}
    Set Global Variable    ${pdu_ip}
    Set Global Variable    ${version_pdu}


TC Setup
    Common VDU Setup

TC Teardown
    Logs To Rotta Copy