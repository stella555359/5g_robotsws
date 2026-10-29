*** Settings ***
Documentation     author: Chen Yin
...               contact: yin.1.chen@nokia-sbell.com
...               squad group: SG_02
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.collectors.snapshot     WITH NAME     snapshot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${WEBUI_URL}      https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${scf_relative_dir}    commissionings/HGZ
${ru_ip_addr}        192.168.100.3

*** Keywords ***
Get Report title
    [Arguments]    ${RUreport}
    COAM Navigate to login page via webUI    download_dir=${OUTPUT DIR}
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${stream}    Split String    ${current_version['Active']}
    set test variable    ${mrbtsid}    ${tl.gnbs[0].instance_id}
	set test variable    ${nrbtsid}    ${tl.gnbs[0].global_bts_id}
	${stream}      String.Split String       ${current_version['Active']}      _
	${status}      Run keyword and return status      Should Contain      ${RUreport}      'ID'
    Run keyword if      ${status}
    ...      Get all reprot title in branch release
    ...      ELSE
    ...      Get all reprort title in Trunk

Get all reprort title in Trunk
    Set Suite Variable    ${CP_ID}    Check point
    Set Suite Variable    ${CP_result}    Check status
    Set Suite Variable    ${CP_name}    Check point name
    Set Suite Variable    ${CP_type}    Trigger type
    Set Suite Variable    ${CP_module}    Target distinguished name
    Set Suite Variable    ${checking_status_NEW}    Check point successful
    Set Suite Variable    ${distName_1}      MRBTS-${mrbtsid}/EQM_R-1/APEQM_R-1/RMOD_R-1,MRBTS-${mrbtsid}/EQM_R-1/APEQM_R-1/RMOD_R-2,
    Set Suite Variable    ${distName_2}      MRBTS-${mrbtsid}/EQM_R-4/APEQM_R-1/RMOD_R-1,MRBTS-${mrbtsid}/EQM_R-4/APEQM_R-1/RMOD_R-2
    ${distName}      Catenate      ${distName_1}      ${distName_2}
    Set Suite Variable    ${distName}

Get all reprot title in branch release
    Set Suite Variable    ${CP_ID}    ID
    Set Suite Variable    ${CP_result}    Last execution result
    Set Suite Variable    ${CP_name}    Check point
    Set Suite Variable    ${CP_type}    Trigger type
    Set Suite Variable    ${CP_module}    Radio module
    Set Suite Variable    ${checking_status_NEW}    OK
    Set Suite Variable    ${distName}      RMOD_R-1,RMOD_R-2

CheckRUReport
    [Arguments]    ${RUreport}    ${checkID}    ${CheckPoint}    ${TriggerType}
    ...      ${dist_Name}=${WEBEM_RADIO_MODUDLES}    ${checking_status}=OK
    Get Report title      RUreport=${RUreport}
    ${checking_status}=      RUN keyword If      '${checking_status}'=='OK'      Set variable      ${checking_status_NEW}
    ...      ELSE      Set variable      ${checking_status}
    FOR  ${item}  IN  @{RUreport}
        log to console     \n${item}
        ${id}=      Get From Dictionary    ${item}    ${CP_ID}
        ${status}=      Run keyword and return status      Should be Equal      '${id}'      '${checkID}'
        Run keyword if      ${status}
        ...      Check report details      ${item}      ${TriggerType}    ${CheckPoint}      ${checking_status}      ${dist_Name}
    END

Check report details
    [Arguments]    ${report}   ${TriggerType}   ${CheckPoint}      ${result}      ${distName}
    Should be equal as strings    ${report['${CP_result}']}   ${result}
    Should be equal as strings    ${report['${CP_type}']}   ${TriggerType}
    Should be equal as strings    ${report['${CP_name}']}   ${CheckPoint}
    Should Contain      ${distName}      ${report['${CP_module}']}

CheckRUReport_CLI
    [Arguments]    ${RUreport}    ${checkID}    ${CheckPoint}    ${TriggerType}
    ...      ${dist_Name}=${WEBEM_RADIO_MODUDLES}    ${checking_status}=${checking_status}
    FOR  ${item}  IN  @{RUreport}
        log to console     \n${item}
        ${id}=      Get From Dictionary    ${item}    checkpointId
        ${status}=      Run keyword and return status      Should be Equal      '${checkpointId}'      '${checkID}'
        Run keyword if      ${status}
        ...      Check report details with CLI
        ...      ${item}      ${TriggerType}    ${CheckPoint}      ${checking_status}      ${dist_Name}
    END

Check report details with CLI
    [Arguments]    ${report}   ${TriggerType}   ${CheckPoint}      ${result}      ${distName}
    Should be equal as strings    ${report['lastResult']}   ${result}
    Should be equal as strings    ${report['triggerType']}   ${TriggerType}
    Should be equal as strings    ${report['checkpointName']}   ${CheckPoint}
    Should Contain      ${distName}      ${report['distName']}

Modify memoryTestThreshold in json file
    [Arguments]    ${memoryTestThreshold}   ${bin_file}=sysmon_primary.bin
    ...      ${json_file}=/ram/sysmon_primary.json
    ...      ${Download_path}=/home/ute/sysmon_primary.json
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    ${ru_index_list}    get all ru index
    FOR    ${index}    IN    @{ru_index_list}
        Connect to RU With Allocated IP      ru_index=${index}
        ${cmd_create_configAccess}      Set Variable
        ...    echo / action create ConfigAccess /CI/ConfigAccess /module|frmonShellClient 127.0.0.1 2000
        ${output_cmd_ssh}      csn.execute      command=${cmd_create_configAccess}      connection=RU
        ${cmd_decoded_configAccess}      Set Variable
        ...     echo '/CI/ConfigAccess action fetch DECODED "${bin_file}" "${json_file}"'|frmonShellClient 127.0.0.1 2000
        ${output_decoded_configAccess}  csn.execute  command=${cmd_decoded_configAccess}    connection=RU
        csn.download_file    /ram/sysmon_primary.json      ${Download_path}      connection=RU
        update_key_value_in_json_file    ${Download_path}    memoryTestThreshold    ${memoryTestThreshold}
        csn.upload_file    ${Download_path}    ${json_file}    connection=RU
        ${cmd_store_configAccess}   Set Variable
        ...    echo '/CI/ConfigAccess action store PERMANENT DECODED "${bin_file}" "${json_file}"'|frmonShellClient 127.0.0.1 2000
        ${output_store_configAccess}  csn.execute  command=${cmd_store_configAccess}    connection=RU
        Run Keyword And Ignore Error    csn.disconnect    connection=RU
    END
    Reset RU and Check Status    allowed_faults=${allowed_faults}    ru_list=${ru_index_list}

Trigger CP42 NOK case
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    ${ru_index_list}    get all ru index
    FOR    ${index}    IN    1
        Connect to RU With Allocated IP      ru_index=${index}
        csn.connect_to    hostname=192.168.100.3
        ...               username=${ru_username}
        ...               password=${ru_password}
        ...               alias=RU_${index}
        ...               proxy=RU
        ${cmd_config_access}   Set Variable
        ...    echo "/ action create ConfigAccess /ca /module"|frmonShellClient 127.0.0.1 2000
        ${output_config_access}  csn.execute  command=${cmd_config_access}    connection=RU_${index}
        ${cmd_create_thermometerDevice}   Set Variable
        ...    echo "/ action create ThermometerDevice /CI/thermometerDevice/rf/trx1_4 /rf/trx1_4"|frmonShellClient 127.0.0.1 2000
        ${output_create_thermometerDevice}  csn.execute  command=${cmd_create_thermometerDevice}    connection=RU_${index}
        ${cmd_override_fault}   Set Variable
        ...    echo "/CI/thermometerDevice/rf/trx1_4 action override FAULTY"|frmonShellClient 127.0.0.1 2000
        ${output_override_fault}  csn.execute  command=${cmd_override_fault}    connection=RU_${index}
        ${cmd_exit}   Set Variable
        ...    exit
        ${output_exit}  csn.execute  command=${cmd_exit}    connection=RU_${index}
        Wait until keyword succeeds    10min    30 sec    Check FID1171 in fault_history_log      connection=RU
    END

Check FID1171 in fault_history_log
    [Arguments]     ${connection}
    ${cmd_read_fault}   Set Variable
    ...    cat /ram/fault_history_log_temp.txt
    ${output_read_fault}  csn.execute  command=${cmd_read_fault}    connection=${connection}
    Should Contain    ${output_read_fault}    EFaultId_TemperValueMissing (1171)

Clear FID1171
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    ${ru_index_list}    get all ru index
    FOR    ${index}    IN    1
        Connect to RU With Allocated IP      ru_index=${index}
        csn.connect_to    hostname=192.168.100.3
        ...               username=${ru_username}
        ...               password=${ru_password}
        ...               alias=RU_${index}
        ...               proxy=RU
        ${cmd_config_access}   Set Variable
        ...    echo "/ action create ConfigAccess /ca /module"|frmonShellClient 127.0.0.1 2000
        ${output_config_access}  csn.execute  command=${cmd_config_access}    connection=RU_${index}
        ${cmd_create_thermometerDevice}   Set Variable
        ...    echo "/ action create ThermometerDevice /CI/thermometerDevice/rf/trx1_4 /rf/trx1_4"|frmonShellClient 127.0.0.1 2000
        ${output_create_thermometerDevice}  csn.execute  command=${cmd_create_thermometerDevice}    connection=RU_${index}
        ${cmd_clear_fault}   Set Variable
        ...    echo "/CI/thermometerDevice/rf/trx1_4 action override OFF"|frmonShellClient 127.0.0.1 2000
        ${output_clear_fault}  csn.execute  command=${cmd_clear_fault}    connection=RU_${index}
    END

suite setup with environment setup
    [Arguments]   ${scf_path}
    ...    ${cur_relative_dir}=testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010823_AHQK/Resources
    robot_common_operations.Common Suite Setup
    Connect to gnb coam via ssl
    ${exist_fault}    COAM Get active alarms
    ${testline_name}      Get TL Name
    ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${scf_relative_dir}
    Commissioning with Template Commission      scf_file=${scf_base_path}/${testline_name}/${scf_path}

suite setup with environment recovery
    [Arguments]   ${scf_path}
    ...    ${cur_relative_dir}=testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010823_AHQK/Resources
    Connect to gnb coam via ssl
    ${exist_fault}    COAM Get active alarms
    ${testline_name}      Get TL Name
    ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${scf_relative_dir}
    Commissioning with Template Commission      scf_file=${scf_base_path}/${testline_name}/${scf_path}
    robot_common_operations.Common Suite Teardown

Login webEM
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}
    ...            ${timeout}=${60}
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${version}=      Get webEM version
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}
    ...                    username=${username}
    ...                    password=${password}
    ...                    download_dir=${download_dir}
    ...                    timeout=${timeout}
    ...                    version=${version}
    selenium_coam.disable_message_box

Get webEM version
    COAM Navigate to login page via webUI
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    COAM selenium logout
    Set Test Variable    ${current_version}    ${current_version['Active']}
    @{stream_list}=    Split String    ${current_version}    _
    Set Test Variable      ${stream}      ${stream_list}[0]
    [Return]      ${stream}

CB010823 Test case Teardown
    Run Keyword And Ignore Error
    ...      Run      command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Test Case Teardown