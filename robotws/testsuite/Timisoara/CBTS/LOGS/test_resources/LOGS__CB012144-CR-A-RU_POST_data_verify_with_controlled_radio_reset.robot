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
Library    ../../LOGS/resources/python/CB010411.py


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
${pod}     unknow
${cont}     unknow
#${cmd_kctl}    kubectl exec -it -n cran1 po-oamfh-0 -c ctr-oamfh -- bash
#${service_user_password}    bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=

*** Keywords ***
TC__LOGS__CB012144-CR-A-RU_POST_data_verify_with_controlled_radio_reset
    [Documentation]
    ...  CB012144-CR-A-RU_POST_data_verify_with_controlled_radio_reset


    Step 0: Precondition
    Step 1: RU_POST_data_verify_with_controlled_radio_reset

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


    ${vdu_ssh_connection_params}=  Get vDU K8s Master Node Ssh Connection Parameters From Init File
    Set Test Variable  ${ip_addr}    ${vdu_ssh_connection_params['ip_addr']}
    Set Test Variable  ${username}    ${vdu_ssh_connection_params['username']}
    Set Test Variable  ${password}    ${vdu_ssh_connection_params['password']}


    ${command_pod}    Set variable    oc get pod -n cran1 |grep oamfh | awk \'{print $1}\'
    ${command_ctr_begin}    Set variable    oc -n cran1 describe pod

    ssh.Connect To  hostname=${ip_addr}  username=${username}  password=${password}    alias=ocp
    ${pod}    ssh.Execute  ${command_pod}  connection=ocp
    ${pod}=    Fetch from left   ${pod}  \r\n
    ${command_ctr}=  catenate  ${command_ctr_begin} ${pod} |grep ctr-oamfh | awk 'NR==1 {print $2}'
    ${command_ctr}=    Fetch from left   ${command_ctr}  \r\n
    ${cont}    ssh.Execute  ${command_ctr}  connection=ocp
    ${cont}=    Fetch from left   ${cont}  \r\n
    Set Test Variable    ${cmd_kctl}    kubectl exec -it -n cran1 ${pod} -c ${cont} -- bash
    Set Global Variable    ${pod}
    Set Global Variable    ${cont}

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

Step 1: RU_POST_data_verify_with_controlled_radio_reset
    Log To Console    RMOD reset 3 times start

    ${rmods}    Get Rmod List
    ${post_three_time_date}    Create List
    ${post_three_timestamp}    Create List
    FOR    ${i}    IN RANGE  ${3}
        ${post_check_start_time}    DateTime.Get Current Date    result_format=timestamp
        Log To Console    ${i+1}th time RMOD power off and power on and  reset
        Reset Rmod By Rest    rmods_list=${rmods}
        log to console    check cell status should be disabled for du...
        wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for vDU
        log to console    check cell should be on air for du...
        wait until keyword succeeds     6min    5s    Verify All Cells Status Should Be Onair for vDU
        ${post_check_stop_time}    DateTime.Get Current Date    result_format=timestamp
        Sleep    10s
        Append To List    ${post_three_time_date}    ${post_check_start_time}
        Append To List    ${post_three_time_date}    ${post_check_stop_time}
        ${post_check_start_timestamp}    DateTime.Convert Date    ${post_check_start_time}    result_format=epoch
        ${post_check_stop_timestamp}    DateTime.Convert Date    ${post_check_stop_time}    result_format=epoch
        Append To List    ${post_three_timestamp}    ${post_check_start_timestamp}
        Append To List    ${post_three_timestamp}    ${post_check_stop_timestamp}
    END
    log to console       Reset Rmod
    Reset Rmod By Rest    rmods_list=${rmods}
    log to console    check cell status should be disabled for du...
    wait until keyword succeeds    3min    5s    Verify All Cells Are Disabled for vDU
    log to console    check cell should be on air for du...
    wait until keyword succeeds     6min    5s    Verify All Cells Status Should Be Onair for vDU
    ${post_result_number}    ${post_dict_content}    get post result from RMOD

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
        ...  msg=RMOD ${${3}-${i}}th control reset start time ${post_three_time_date[${rmod_three_start_index}]} after post time ${time_zone_align}
        Run Keyword And Continue On Failure    Should Be True     ${post_timestamp} < ${post_three_timestamp[${rmod_three_stop_index}]}
        ...  msg=post time ${time_zone_align} before RMOD ${${3}-${i}}th control reset start time ${post_three_time_date[${rmod_three_stop_index}]}
    END

Login SSH
    Open Connection  ${VDU_SSH_IP}
    Login  core  ${VDU_SSH_PASSWORD}

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

Verify All Cells Are Disabled for vDU
    [Arguments]     ${alias}=default
    sleep    5s
    ${cells_status}=    vdu.get_vdu_cells_status     vdu_connection=${alias}
    FOR  ${cell}  IN  @{cells_status}
        Run keyword    Should be equal as strings    ${cell['operational_state']}    disabled
        ...  msg=operational_state for cell ${cell['id']} is not disabled
    END

Get Rmod List
    [Arguments]      ${alias}=default
#    ${conn_alias}    generic_utils.get_unique_id_string
    Connect To VDU  host=${VDU_OAM_IP}
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${alias}
    ${rmods}  create list
    FOR    ${rmod}    IN    @{rmods_status}
        append to list    ${rmods}    ${rmod}[id]
    END
    [Return]    ${rmods}

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

get post result from RMOD
    log to console    login vdu ssh server
#    ${alias}    generic_utils.get_unique_id_string
    log to console    get ru ip
    ${command}=  catenate    ${cmd_kctl}
    ...  -c "{ echo \\"aasyscomgw -r\\";sleep 3;echo \\"quit\\"; } | nc 127.0.0.1 15067;" | grep -a "192.170" |grep UDPCP | awk \'NR==1 {print $7}\'

    ssh.Connect To  hostname=${VDU_SSH_IP}  username=${VDU_SSH_USERNAME}  password=${VDU_SSH_PASSWORD}    alias=ocp
    ${rf_ip}    ssh.Execute  ${command}  connection=ocp
    log to console    RFip is:${rf_ip}
    Set Test Variable    ${rf_ip}    ${rf_ip}
    Login SSH
    ${rf_ip_clean}=    Strip String    ${rf_ip}
    ${cmd_all}  catenate    kubectl exec -i -n cran1 ${pod} -c ${cont}
    ...    -- ssh -o StrictHostKeyChecking=no -B lo root@${rf_ip_clean} -- cat /mnt/runtime/BBOX5
    ${BBOX5_str_content}=    Execute Command    ${cmd_all}
    Log To Console    ${BBOX5_str_content}
    ${post_result_number}    ${post_dict_content}    get_post_result_content_from_str    str_content=${BBOX5_str_content}
    [Return]    ${post_result_number}    ${post_dict_content}

TC Setup
    Common VDU Setup

TC Teardown
    Logs To Rotta Copy
