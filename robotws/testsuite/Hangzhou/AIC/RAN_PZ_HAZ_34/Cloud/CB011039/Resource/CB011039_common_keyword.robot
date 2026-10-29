*** Settings ***
Documentation     author: nana.zhao
...               Group: VRF_HAZ3_T02
...               contact: nana.zhao@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_cloud.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource    testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/ru.robot
#Resource    testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/AIC_BTS.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Cloud/Cloud_Setup_and_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
#Resource    testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/AIC_Capture_Analysis_Log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot


#Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/resources/AIC/robot/aic_common_interface.robot
#Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/resources/AIC/robot/bts/aic_bts_common_oam.robot


*** Variables ***

${AEQY_ip}    ${tl.gnbs[0].dus[0].fhgws[0].rus[0].default_ssh_connection_details.addr}
${AEQY_username}    ${tl.gnbs[0].dus[0].fhgws[0].rus[0].default_ssh_connection_details.username}
${AEQY_password}    ${tl.gnbs[0].dus[0].fhgws[0].rus[0].default_ssh_connection_details.password}

${command_1}    / action create ResetControl /CI/resetControl/module /module
${command_2}    /CI/resetControl/module action enable_fail_safe_mode
${command_3}    /CI/resetControl/module get fail_safe_mode
${command_4}    /CI/resetControl/module action disable_fail_safe_mode


*** Keywords ***
reset_ru
    [Arguments]    ${ru_index}=1
    ${rmod_id_list_new}=  create list
    Append To List    ${rmod_id_list_new}    ${ru_index}
    log to console    ${rmod_id_list_new}
    cloud_ru.Reset Rmod By Rest    rmods_list=${rmod_id_list_new}

make ru enter fail safe mode
    [Arguments]    ${ru_index}=1
    log to console    make ru enter fail safe mode...

    ${alias}    Cloud Connect to RU    ru_index=${ru_index}
    cloud_ru.Cloud SSH Execute CMD   command=frmonShellClient localhost 2000   expert_prompt=$    alias=${alias}   check_result=${False}
    sleep  1
    ${out}    cloud_ru.Cloud SSH Execute CMD   command=${command_1}   expert_prompt=done ok    alias=${alias}   check_result=${False}
    sleep  1
    log to console    ${out}
    ${out}    cloud_ru.Cloud SSH Execute CMD   command=${command_2}   expert_prompt=done ok    alias=${alias}   check_result=${False}
    sleep  1
    log to console    ${out}

    reset_ru    ru_index=${ru_index}
    Wait until keyword succeeds    10min    30s     SG08_keywords_cloud.Expect Fault Should Present On vDU   fault_id=2934    severity=critical
    sleep    200s
    Verify Rmod Status in fail safe mode for vDU    ru_index=${ru_index}


    [Teardown]    run keyword and ignore error    Cloud Disconnect Alais    alias=${alias}

make ru exit fail safe mode
    [Arguments]    ${ru_index}=1
    log to console    make ru exit fail safe mode...
    ${alias}    Cloud Connect to RU    ru_index=${ru_index}
    cloud_ru.Cloud SSH Execute CMD   command=frmonShellClient localhost 2000   expert_prompt=$    alias=${alias}   check_result=${False}
    sleep  1
    ${out}    cloud_ru.Cloud SSH Execute CMD   command=${command_1}   expert_prompt=$    alias=${alias}   check_result=${False}
    sleep  1
    log to console    ${out}
    ${out}    cloud_ru.Cloud SSH Execute CMD   command=${command_4}   expert_prompt=$    alias=${alias}   check_result=${False}
    sleep  1
    log to console    ${out}

    reset_ru    ru_index=${ru_index}
    Verify Rmod Status in normal mode for vDU    ru_index=${ru_index}
    wait until keyword succeeds     15min    5s    Verify All Cells Status Should Be Onair for vDU

    Wait until keyword succeeds    10min    30s    SG08_keywords_cloud.Expect Fault Should Absent On vDU    fault_id=2934
    [Teardown]    run keyword and ignore error    Cloud Disconnect Alais    alias=${alias}


Verify Rmod Status in fail safe mode for vDU
    [Arguments]    ${vdu_index}=0    ${ru_index}=1

    ${rmod_id_list_new}=  create list
    Append To List    ${rmod_id_list_new}    ${ru_index}
    vDU Login    vdu_index=${vdu_index}
    Wait Until Keyword Succeeds  10min   20s    RMOD Status Should Be As Expected    rmods_id_list=${rmod_id_list_new}
    ...   availability_status=failed    operational_state=disabled

    [Teardown]  run keyword and ignore error    vDU Logout

Verify Rmod Status in normal mode for vDU
    [Arguments]    ${vdu_index}=0    ${ru_index}=1

    ${rmod_id_list_new}=  create list
    Append To List    ${rmod_id_list_new}    ${ru_index}

    vDU Login    vdu_index=${vdu_index}
    Wait Until Keyword Succeeds  15min   20s    RMOD Status Should Be As Expected    rmods_id_list=${rmod_id_list_new}
    ...   availability_status=on line    operational_state=enabled

    [Teardown]  run keyword and ignore error    vDU Logout

Cloud Check single RU log in Snapshot
    [Arguments]    ${ru_index}=1    ${ns}=cran1
    log to console   \nsave local snapshot on vDU...
    sleep    600
    ${snapshot_path}    Trigger And Save Local Snapshot For vDU
    #${snapshot_path}    SG08_keywords_cloud.Save Local Snapshot In vDU
    should exist    ${snapshot_path}/RU_${ru_index}.zip
    extract zip file    ${snapshot_path}/RU_${ru_index}.zip    ${snapshot_path}/RU_logs
    #extract zip file    ${snapshot_path}/RU_logs/RU_${ru_index}.zip    ${snapshot_path}/RU_logs/RU_${ru_index}
    #extract zip file    ${snapshot_path}/RU_logs/RU_${ru_index}.zip    ${snapshot_path}/RU_logs/RU_${ru_index}
    #${detail_files}    List Files In Directory    path=${snapshot_path}/RU_logs/RU_${ru_index}
    ${detail_files}    List Files In Directory    path=${snapshot_path}/RU_logs
    log to console   \nsave ru logs with command...
    ${download_rfsw_log_path}    Cloud Collect single RU log and Download    ru_index=${ru_index}    ru_log_path=${snapshot_path}    ns=${ns}
    #${download_rfsw_log_path}    Cloud Collect RU log and Download    ru_index=${ru_index}    ru_log_path=${snapshot_path}    ns=${ns}
    ${unzip_path}    ${extension}    split extension    ${download_rfsw_log_path}
    extract zip file    ${download_rfsw_log_path}    ${unzip_path}
    ${log_on_ru}    List Files In Directory    path=${unzip_path}
    log to console   \ncompare ru log files collected from command and vDU snapshot...
    ${not_include_list}    Create List
    FOR    ${item}  IN  @{log_on_ru}
        @{splits}    string.split string    ${item}    separator=_
        ${status}  Run Keyword And Return Status  Should Contain Match   ${detail_files}   regexp=.*${splits[1]}.*
        run keyword if    not ${status}    append to list    ${not_include_list}    ${splits[1]}
    END
    should be empty    ${not_include_list}

Cloud Collect single RU log and Download
    [Arguments]    ${ru_index}=${1}    ${gnb_index}=0     ${vdu_index}=0    ${ru_log_path}=${SAVE LOG DIRECTORY}    ${ns}=cran1
    [Documentation]    *****************
    ...    This keyword is designed to Collect RU log with command and download to Test PC.

    ${log_in_container}    Cloud Collect single RU log    ru_index=${ru_index}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${vdu_string}    ${vdu_version}=    string.Split String From Right    ${target_version}    separator=.    max_split=${1}
    log to console    ${vdu_string}
    run keyword if    '${vdu_string}'=='26.300'    vDU Download File From Container
    ...    pod_name=po-${ns}-oamfh-0    container_name=ctr-${ns}-oamfh
    ...    local_file_path=${ru_log_path}    file_path_in_container=${log_in_container}
    ...    ELSE    vDU Download File From Container    pod_name=po-oamfh-0    container_name=ctr-oamfh
    ...    local_file_path=${ru_log_path}    file_path_in_container=${log_in_container}
    [Return]  ${ru_log_path}/rfsw_log.zip

Cloud Collect single RU log
    [Arguments]    ${ru_index}=${1}    ${gnb_index}=0     ${vdu_index}=0
    ...  ${rf_login_name}=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...  ${password}=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    [Documentation]    *****************
    ...    This keyword is designed to Collect RU log with command.

    #${conn_alias}    generic_utils.get_unique_id_string
    #vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    #${rmods_info}  vdu_ope_base.get_rmod_status  conn_alias=${conn_alias}
    #FOR   ${rmod_info}   IN    @{rmods_info}
    #    ${product_name}    Set Variable    ${rmod_info['product_name']}
    #    ${expert_prompt}   Set Variable If    '${product_name}'=='AQQL' or '${product_name}'=='AQQS' or '${product_name}'=='AQQQA'   \/usr\/bin    \#
    #    Exit For Loop If  "${rmod_info['id']}"=="${ru_index}"
    #END
    #vdu_gen.logout_rest    conn_alias=${conn_alias}
    ${ru_ip}    Cloud Get RU IP    ru_index=${ru_index}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${alias}    Cloud Connect to RU    ru_index=${ru_index}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${rfsw_log_name}    Set Variable    rfsw_log_${timestamp}.zip

    #${vdu_string}    ${vdu_version}=    string.Split String From Right    ${target_version}    separator=.    max_split=${1}
    #log to console    ${vdu_string}
    #${content}    run keyword if    '${vdu_string}'=='0.300'    Cloud SSH Execute CMD    cd /usr/bin;ccsShell.sh log -a -z /ram/rfsw_log.zip
    #...    expert_prompt=\/usr\/bin     alias=${alias}    #check_result=${False}
    #...    ELSE     Cloud SSH Execute CMD    cd /usr/bin;ccsShell.sh log -a -z /ram/rfsw_log.zip
    #...    expert_prompt=\#     alias=${alias}    #check_result=${False}

    ${content}    Cloud SSH Execute CMD    cd /usr/bin;ccsShell.sh log -a -z /ram/rfsw_log.zip
    ...    expert_prompt=\/usr\/bin     alias=${alias}    #check_result=${False}

    Cloud SSH Execute CMD   command=exit    expert_prompt=bash-5.2$    alias=${alias}
    ${cmd}    Set Variable If    ${is_dc}
    ...    scp -o StrictHostKeyChecking=no -o BindAddress=70.70.70.1 ${rf_login_name}@${ru_ip}:/ram/rfsw_log.zip /tmp/rfsw_log.zip
    ...    scp -o StrictHostKeyChecking=no ${rf_login_name}@${ru_ip}:/ram/rfsw_log.zip /tmp/rfsw_log.zip
    Cloud SSH Execute CMD    command=${cmd}    expert_prompt=password:    alias=${alias}    check_result=${False}
    Cloud SSH Execute CMD    command=${password}    expert_prompt=bash-5.2$    alias=${alias}
    ${log_in_container}    set variable    /tmp/rfsw_log.zip
    [Return]  ${log_in_container}
    [Teardown]    run keyword and ignore error    Cloud Disconnect Alais    alias=${alias}


Enter fail safe mode
    ${status}    Run Keyword And Return Status    make ru enter fail safe mode    ru_index=${ru_index}
    Set Global Variable    ${FIRST_CASE_RESULT}    ${status}

Case_Teardown
    [Arguments]    ${ru_index}=1
    robot_common_operations.Common Case Teardown
    make ru exit fail safe mode    ru_index=${ru_index}
    CI_interface.Common Case Teardown

