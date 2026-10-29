*** Settings ***
Documentation
...    author: Lukasz Rzodeczko, lukasz.rzodeczko@nokia.com
...    maintainer: Grzegorz Kaczor, grzegorz.kaczor@nokia.com

Library                          Process
Library                          Collections
Library                          DateTime
Library                          OperatingSystem
Library                          String

Library                          taf.nms.netact.interface.netact    WITH NAME    netact
Library                          testsuite.Krakow.OAM.features.CB006939.resources.custom_python_resources_netact
Library                          testsuite.Krakow.OAM.features.CB006939.resources.NetactOperations
Library                          testsuite.Krakow.OAM.features.CB006939.resources.DuCommonInterface

Resource                         taf/rfrl/bts/robot/gnb.robot

*** Variables ***
${NETACT_NAME}                   ${tl.nms[0].addr}
${WEB_URL}                       https://${NETACT_NAME}/authentication/Login
${USERNAME}                      ${tl.nms[0].nom.ssh_connections_info.username}
${PASSWORD}                      ${tl.nms[0].nom.ssh_connections_info.password}
${NODE_IP}                       ${tl.nms[0].nom.ssh_connections_info.addr}

${GNB_ID}                        ${tl.gnbs[0].global_bts_id}
${MO_ID}                         PLMN-PLMN/MRBTS-${GNB_ID}
${LNCEL_ID}                      ${None}
${PLAN_DESCRIPTION}              The Lord once stood by the shore ${GNB_ID} 2137

${NUMBER_OF_TRIES}               3
${NRBTS_ID}                      ${tl.gnbs[0].global_bts_id}

${ACTIVATION_LIMIT}              ${575}
${OPERATION_LIMIT}               ${600}
${PRE_ACTIVATION_LIMIT}          ${60}
${DOWNLOAD_LIMIT}                ${10}
${OPERATION_DOWNLOAD_LIMIT}      ${20}
${VALIDATION_LIMIT}              ${60}
${OPERATION_VALIDATION_LIMIT}    ${75}
${ACTIVATION_OUTAGE_LIMIT}       ${575}
${OPERATION_OUTAGE_LIMIT}        ${600}
${FULL_PLAN_LIMIT}               ${660}
${OFFLINE_VALIDATION_LIMIT}      ${140}

*** Keywords ***
Suite variables setup
    ${ACTIVATION_DICT}= 	Create Dictionary
    Set Suite Variable    ${ACTIVATION_DICT}    ${ACTIVATION_DICT}
    ${offline_validation_start}=   Create List
    ${offline_validation_end}=   Create List
    ${OFFLINE_VALIDATION_DICT}=   Create Dictionary    Start   ${offline_validation_start}    End    ${offline_validation_end}
    Set Suite Variable    ${OFFLINE_VALIDATION_DICT}  ${OFFLINE_VALIDATION_DICT}
    ${clear_alarms_start_list}=   Create List
    ${clear_alarms_end_list}=   Create List
    ${CLEAR_ALARMS_DICT}=   Create Dictionary    Start   ${clear_alarms_start_list}    End    ${clear_alarms_end_list}
    Set Suite Variable    ${CLEAR_ALARMS_DICT}    ${CLEAR_ALARMS_DICT}
    ${cell_id}    Get random cell id    mrbts=${NRBTS_ID}
    Set Suite Variable    ${LNCEL_ID}    ${cell_id}

Netact test setup
    Precondition
    Set test variables

Netact custom test teardown
    Run Keyword If Test Failed    Delete Plan Configuration    plan=${PLANNED_CONFIGURATION}
    Save KPIs to file    file_name=DU_delta_NMS_activation_outage
    ...                  end_to_end=${end_to_end}
    ...                  bts_target=${bts_target}
    Netact test teardown

Netact test teardown
    Postcondition
    Verify gNB is onAir

Precondition
    Add Node    service_name=cmwas
    ...         hostname=${NODE_IP}
    ...         username=${USERNAME}
    ...         password=${PASSWORD}
    ...         alias=${NETACT_NAME}
    Add Web URL    web_url=${WEB_URL}
    ...            username=${USERNAME}
    ...            password=${PASSWORD}
    ...            alias=${NETACT_NAME}

Postcondition
    Delete Node    service_name=cmwas
    ...            alias=${NETACT_NAME}
    Clean All    alias=${NETACT_NAME}

Set test variables
    Set list as test variable    end_to_end
    Set list as test variable    bts_target

Set list as test variable
    [Arguments]    ${list_name}
    ${target_list}    Create List
    Set Test Variable    ${${list_name}}    ${target_list}

Save KPIs to file
    [Arguments]    ${file_name}    ${end_to_end}    ${bts_target}=${None}    ${path_to_file}=${OUTPUT DIR}/kpis
    ${current_date}    Get Current Date    result_format=%y.%m.%d_%H:%M
    ${end_to_end_avr}    get_average_from_list    list_of_elements_to_average_from=${end_to_end}
    ${bts_target_avr}    Run Keyword if    ${bts_target}!=${None}    get_average_from_list    list_of_elements_to_average_from=${bts_target}
    Run    mkdir -p ${path_to_file}
    Run    touch ${path_to_file}/${file_name}_${current_date}
    Run    echo 'end to end times: ${end_to_end} average ${end_to_end_avr}' >> ${path_to_file}/${file_name}_${current_date}
    Run Keyword If   ${bts_target}!=${None}
    ...   Run    echo 'bts target times: ${bts_target} average ${bts_target_avr}' >> ${path_to_file}/${file_name}_${current_date}
    File should exist    ${path_to_file}/${file_name}_${current_date}

Get Actual Configuration MO Data
    [Arguments]    ${mo_id}
    ${actual_conf}    Get Actual Configuration    alias=${NETACT_NAME}
    ${managed_object}    Get Managed Object    configuration=${actual_conf}
    ...                                        mo_id=${mo_id}
    ...                                        alias=${NETACT_NAME}
    [Return]    ${managed_object.meta_class}     ${managed_object.meta_version}    ${managed_object.parameters}

Add MO To Plan
    [Arguments]    ${dist_name}    ${plan_conf}    ${additinal_values}=${False}    ${alias}=${NETACT_NAME}
    ${meta_class}     ${meta_version}    ${parameters}    Get Actual Configuration MO Data    mo_id=${dist_name}
    ${managed_object}    Create Managed Object    plan=${plan_conf}
    ...                                           meta_class=${meta_class}
    ...                                           meta_version=${meta_version}
    ...                                           mo_id=${dist_name}
    ...                                           alias=${alias}
    Return From Keyword If    ${additinal_values}    ${plan_conf}    ${managed_object}
    ...                                              ${meta_class}    ${meta_version}    ${parameters}
    [Return]    ${plan_conf}    ${managed_object}

Create Plan And MO
    [Arguments]    ${dist_name}    ${plan_name}=DU_${GNB_ID}    ${additinal_values}=${False}    ${alias}=${NETACT_NAME}
    ${current_date}    Get Current Date    result_format=%Y%m%d%H%M%S
    Set Test Variable    ${PLAN_NAME}    ta_plan_${plan_name}_${current_date}
    ${plan_conf}     Create Plan Configuration    name=${PLAN_NAME}
    ...                                           description=${PLAN_DESCRIPTION}
    ...                                           alias=${alias}
    ${meta_class}     ${meta_version}    ${parameters}    Get Actual Configuration MO Data   mo_id=${dist_name}
    ${managed_object}    Create Managed Object    plan=${plan_conf}
    ...                                           meta_class=${meta_class}
    ...                                           meta_version=${meta_version}
    ...                                           mo_id=${dist_name}
    ...                                           alias=${alias}
    Return From Keyword If    ${additinal_values}    ${plan_conf}    ${managed_object}
    ...    ${meta_class}    ${meta_version}    ${parameters}
    Return From Keyword    ${plan_conf}    ${managed_object}


Single CM activation
    [Arguments]    ${add_or_subtract}
    Verify Setup Of All Cells
    ${current_date}    Get Current Date    result_format=%Y%m%d%H%M%S
    ${plan_conf}    ${managed_object}    Create Plan And MO    dist_name=PLMN-PLMN/${LNCEL_ID}
    Set test variable    ${PLANNED_CONFIGURATION}    ${plan_conf}
    ${plan_conf}    ${managed_object}    ${meta_class}    ${meta_version}    ${parameters}    Add MO To Plan
    ...                                                                                     dist_name=${MO_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                                                                     plan_conf=${PLANNED_CONFIGURATION}
    ...                                                                                     additinal_values=${True}
    Set test variable    ${PLANNED_CONFIGURATION}    ${plan_conf}
    Edit Managed Object    managed_object=${managed_object}
    ...                    operation=UPDATE
    ...                    btsAccountLockoutDuration=${${parameters}[btsAccountLockoutDuration]+${add_or_subtract}}
    ...                    btsFailedLoginCountingPeriod=${${parameters}[btsFailedLoginCountingPeriod]+${add_or_subtract}}
    ...                    btsMaxFailedLoginAttempts=${${parameters}[btsMaxFailedLoginAttempts]+${add_or_subtract}}
    ...                    btsSessionLoginDelay=${${parameters}[btsSessionLoginDelay]+${add_or_subtract}}
    ...                    localPasswdExpiryPeriod=${${parameters}[localPasswdExpiryPeriod]+${add_or_subtract}}
    ...                    localPasswdWarningPeriod=${${parameters}[localPasswdWarningPeriod]+${add_or_subtract}}
    ...                    webEMSessionLogoutTimer=${${parameters}[webEMSessionLogoutTimer]+${add_or_subtract}}
    Provision Plan    plan_name=${PLAN_NAME}
    ...               provisioning_operation=preactivate
    ...               alias=${NETACT_NAME}
    Activate Preactivated Plan    plan_name=${PLAN_NAME}
    ...                           alias=${NETACT_NAME}
    ${output}   get_detailed_operations_history_parser    plan_names=${PLAN_NAME}
    ...                                                   mo_id=${MO_ID}
    ...                                                   operations_count=${20}
    Set To Dictionary    ${ACTIVATION_DICT}    ${PLAN_NAME}    ${output}
    ${operation_begins}    Set Variable
    ...                 ${output}[${PLAN_NAME}][Activate_Pre-Activation][Feedbacks][Netact Status][Prepare operation scope started.]
    ${activation_started}   Set Variable
    ...             ${output}[${PLAN_NAME}][Activate_Pre-Activation][Feedbacks][${MO_ID}][Operations][5G/LTE/SRAN plan activate started.]
    ${activation_finished}   Set Variable
    ...             ${output}[${PLAN_NAME}][Activate_Pre-Activation][Feedbacks][${MO_ID}][Operations][5G/LTE/SRAN plan activate finished.]
    Run Keyword And Continue On Failure    Validate operation time is within the limit    start=${activation_started}
    ...                                                                                   end=${activation_finished}
    ...                                                                                   limit=${ACTIVATION_LIMIT}
    ...                                                                                   target_list=${bts_target}
    ...                                                                                   convert_to_date=${True}
    Run Keyword And Continue On Failure    Validate operation time is within the limit    start=${operation_begins}
    ...                                                                                   end=${activation_finished}
    ...                                                                                   limit=${OPERATION_LIMIT}
    ...                                                                                   target_list=${end_to_end}
    ...                                                                                   convert_to_date=${True}

Single online validation
    [Arguments]    ${attempt}
    Wait until keyword succeeds    60 sec
    ...                            15 sec
    ...                            Verify Setup Of All Cells
    ${local_passwd_expiry_period}    Evaluate   50+${attempt}+1
    ${local_passwd_warning_period}    Evaluate   50+${attempt}+2
    ${plan_conf}    ${managed_object}    Create Plan And MO    ${MO_ID}/MNL-1/AMGR-1/LUAC-1
    Set test variable    ${PLANNED_CONFIGURATION}    ${plan_conf}
    Edit Managed Object    managed_object=${managed_object}
    ...                    operation=UPDATE
    ...                    localPasswdExpiryPeriod=${local_passwd_expiry_period}
    Provision Plan    plan_name=${PLAN_NAME}
    ...               provisioning_operation=preactivate
    ...               alias=${NETACT_NAME}
    Perform Configuration Parameter Recommissioning On gNB    dist_name=MRBTS-${GNB_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                                       param_name=localPasswdWarningPeriod
    ...                                                       param_value=${local_passwd_warning_period}
    Run Keyword And Ignore Error    Validate Plan    plan_name=${PLAN_NAME}
    ...                                              alias=${NETACT_NAME}
    ${output}    get_detailed_operations_history_parser    plan_names=${PLAN_NAME}
    ...                                                    mo_id=${MO_ID}
    ...                                                    operations_count=20
    ${operation_begins}    Set Variable
    ...                 ${output}[${PLAN_NAME}][Validate][Feedbacks][Netact Status][Prepare operation scope started.]
    ${validation_started}    Set Variable
    ...                       ${output}[${PLAN_NAME}][Validate][Feedbacks][${MO_ID}][Operations][5G/LTE/SRAN plan validate started.]
    ${validation_finished}   Set Variable
    ...                       ${output}[${PLAN_NAME}][Validate][Feedbacks][${MO_ID}][Operations][5G/LTE/SRAN plan validate failed.]
    Run Keyword And Continue On Failure    Validate operation time is within the limit    start=${validation_started}
    ...                                                                                   end=${validation_finished}
    ...                                                                                   limit=${VALIDATION_LIMIT}
    ...                                                                                   target_list=${bts_target}
    ...                                                                                   convert_to_date=${True}
    Run Keyword And Continue On Failure    Validate operation time is within the limit    start=${operation_begins}
    ...                                                                                   end=${validation_finished}
    ...                                                                                   limit=${OPERATION_VALIDATION_LIMIT}
    ...                                                                                   target_list=${end_to_end}
    ...                                                                                   convert_to_date=${True}

Online validation post loop teardown
    Perform Configuration Parameter Recommissioning On gNB    dist_name=MRBTS-${GNB_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                                       param_name=localPasswdWarningPeriod
    ...                                                       param_value=50
    Verify Setup Of All Cells

Validate operation time is within the limit
    [Arguments]    ${start}    ${end}    ${limit}    ${target_list}    ${convert_to_date}=${FALSE}    ${date_format}=%m/%d/%y %I:%M:%S %p
    ${start}    Run Keyword If   ${convert_to_date}   Convert Date    ${start}   date_format=${date_format}
    ...   ELSE    Set Variable    ${start}
    ${end}    Run Keyword If   ${convert_to_date}   Convert Date    ${end}   date_format=${date_format}
    ...   ELSE    Set Variable    ${end}
    ${whole_operation_time}    Subtract Date From Date    ${end}    ${start}
    ${status}    Evaluate    ${0} <= ${whole_operation_time} <= ${limit}
    Append To List    ${target_list}    ${whole_operation_time}
    Run Keyword Unless    ${status}    Fail    Operation time of ${whole_operation_time} is outside of limit of ${limit}

Uzip syslog and return its path
    [Arguments]  ${syslog_zip_path}=/tmp/btslog2/syslog_files.tgz
    File Should Exist    ${syslog_zip_path}
    ${output}    Run    tar xvf ${syslog_zip_path} -C ${OUTPUT DIR}
    Run    rm ${syslog_zip_path}
    Should Contain    ${output}    .LOG
    ${file_name}    Should Match Regexp    ${output}    SYS.*LOG
    ${path_to_syslog}    Set Variable    ${OUTPUT DIR}/${file_name}
    [Return]    ${path_to_syslog}

Search for message in syslog and return its date
    [Arguments]    ${syslog_path}    ${message_regex}    ${number_of_messages}
    ${output}    Grep File    ${syslog_path}    ${message_regex}
    ${date}    Get Regexp Matches    ${output}    \\d{2}.\\d{2}\\s\\d{2}:\\d{2}:\\d{2}
    ${cnt}    Get Length    ${date}
    Should Be Equal As Numbers    ${cnt}    ${number_of_messages}
    [Return]    ${date}

Single activation with outage
    ${operation_begins}    ${close_click}    load_current_scf_download_it_and_activate
    ${syslog_path}    Uzip syslog and return its path
    ${activation_started}    Search for message in syslog and return its date    syslog_path=${syslog_path}
    ...                          message_regex=[INF/SysAdapter/URI/EM]*PlanActivateIndScenario] start
    ...                          number_of_messages=${1}
    Set test variable    ${ACTIVATION_WITH_OUTAGE_STARTED}    ${activation_started}
    ${activation_finished}    Search for message in syslog and return its date    syslog_path=${syslog_path}
    ...                           message_regex=[INF/SysAdapter/URI/EM]*PlanActivateIndScenario] stop
    ...                           number_of_messages=${2}
    Set test variable    ${ACTIVATION_WITH_OUTAGE_FINISHED}    ${activation_finished}
    Run    rm ${syslog_path}

Single CM provisioning operation
    ${validation_click}    ${validation_end}    ${operation_begins}    ${close_click}    load_current_scf_validate_it_and_provision
    Run Keyword And Continue On Failure    Validate operation time is within the limit    start=${operation_begins}
    ...                                                                                   end=${close_click}
    ...                                                                                   limit=${FULL_PLAN_LIMIT}
    ...                                                                                   target_list=${end_to_end}
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    5 min
    ...                                                                   10 sec
    ...                                                                   Verify Setup Of All Cells
    Append to List    ${OFFLINE_VALIDATION_DICT}[Start]   ${validation_click}
    Append to List    ${OFFLINE_VALIDATION_DICT}[End]   ${validation_end}
