*** Settings ***
Documentation    Author: tomasz.blaszczyszyn@nokia.com; kacper.halas@nokia.com; filip.radwanski@nokia.com; michal.laski@nokia.com
...              Maintainer: tomasz.blaszczyszyn@nokia.com; kacper.halas@nokia.com; filip.radwanski@nokia.com; michal.laski@nokia.com
...              Description: These keywords handles actions performed with ute_admin_infomodel library refering to ADMIN INFOMODEL functionalities

Library             String
Library             BuiltIn
Library             OperatingSystem
Library             ute_admin_infomodel

*** Variables ***
${ADMIN_INFOMODEL_FILENAME} =                   infomodel.ims2
${ADMIN_INFOMODEL_LOG_DIR} =                    ${OUTPUT_DIR}
${ADMIN_INFOMODEL_CABLINK_PATH} =               /MRBTS-1/RAT-1/BTS_L-1/HWTOP_L-1/CABLNK_L-*
${ADMIN_INFOMODEL_RMOD_L} =                     /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/RMOD_L-
${ADMIN_INFOMODEL_RMOD_R} =                     /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-*
${ADMIN_INFOMODEL_SMOD_L_PATH} =                /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
${ADMIN_IMFOMODEL_LNBTS_PATH} =                 /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1  #TAM GDZIE LNBTS PAMIĘTAĆ O ID? CZY WYCIĄGAMY W INICIE?
${ADMIN_INFOMODEL_CELLS_PATH} =                 /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-*
${ADMIN_INFOMODEL_CPLANE_PATH} =                /MRBTS-1/RAT-*//LNBTS-1/CPLANE-1
${ADMIN_INFOMODEL_MRBTS_M_DN}=                  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1
${ADMIN_INFOMODEL_BTS_HOST} =                   192.168.255.129
${ADMIN_INFOMODEL_BTS_PORT} =                   443
${ADMIN_INFOMODEL_USERNAME} =                   Nemuadmin
${ADMIN_INFOMODEL_PASSWORD} =                   nemuuser
${ADMIN_INFOMODEL_USE_SSL} =                    True
${ADMIN_INFOMODEL_UPDATE_INTERVAL} =            1000
${ADMIN_INFOMODEL_ADMIN_API_LOG_DIR} =          ${OUTPUT_DIR}
${ADMIN_INFOMODEL_REMOTE_HOST_USERNAME} =       ute
${ADMIN_INFOMODEL_REMOTE_HOST_PASSWORD} =       ute
#${ADMIN_INFOMODEL_REMOTE_HOST_SSH_PROMPT} =     None
${ADMIN_INFOMODEL_TIMEOUT} =                    30
${ADMIN_INFOMODEL_ALIAS} =                      infomodel_1


*** Keywords ***
ADMIN INFOMODEL Start Logging
    [Arguments]    ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ...            ${admin_infomodel_ip}=${ADMIN_INFOMODEL_BTS_HOST}
    ...            ${admin_infomodel_port}=${ADMIN_INFOMODEL_BTS_PORT}
    ADMIN INFOMODEL Setup Infomodel    bts_host=${admin_infomodel_ip}
    ...                                bts_port=${admin_infomodel_port}
    ...                                alias=${alias}
    ADMIN INFOMODEL Connect Infomodel  alias=${alias}

ADMIN INFOMODEL Stop Logging
    [Arguments]    ${filename}=${ADMIN_INFOMODEL_FILENAME}
    ...            ${log_dir}=${ADMIN_INFOMODEL_LOG_DIR}
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ADMIN INFOMODEL Save Log              filename=${filename}
    ...                                   log_dir=${log_dir}
    ...                                   alias=${alias}
    ADMIN INFOMODEL Disconnect Infomodel  alias=${alias}
    ADMIN INFOMODEL Teardown Infomodel    alias=${alias}

ADMIN INFOMODEL Setup Infomodel
    [Arguments]    ${bts_host}=${ADMIN_INFOMODEL_BTS_HOST}
    ...            ${bts_port}=${ADMIN_INFOMODEL_BTS_PORT}
    ...            ${username}=${ADMIN_INFOMODEL_USERNAME}
    ...            ${password}=${ADMIN_INFOMODEL_PASSWORD}
    ...            ${use_ssl}=${ADMIN_INFOMODEL_USE_SSL}
    ...            ${update_interval}=${ADMIN_INFOMODEL_UPDATE_INTERVAL}
    ...            ${admin_api_log_dir}=${ADMIN_INFOMODEL_ADMIN_API_LOG_DIR}
    ...            ${remote_host_username}=${ADMIN_INFOMODEL_REMOTE_HOST_USERNAME}
    ...            ${remote_host_password}=${ADMIN_INFOMODEL_REMOTE_HOST_USERNAME}
#   ...            ${remote_host_ssh_prompt}=${ADMIN_INFOMODEL_REMOTE_HOST_SSH_PROMPT}
    ...            ${timeout}=${ADMIN_INFOMODEL_TIMEOUT}
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Setup infomodel    address=${bts_host}
    ...                                    port=${bts_port}
    ...                                    username=${username}
    ...                                    password=${password}
    ...                                    use_ssl=${use_ssl}
    ...                                    update_interval=${update_interval}
    ...                                    admin_api_log_dir=${admin_api_log_dir}
    ...                                    remote_host_username=${remote_host_username}
    ...                                    remote_host_password=${remote_host_password}
#  ...                                     remote_host_ssh_prompt=${remote_host_ssh_prompt}
    ...                                    timeout=${timeout}
    ...                                    alias=${alias}

ADMIN INFOMODEL Connect Infomodel
    [Arguments]    ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ...            ${timeout}=30
    ute_admin_infomodel.Connect Infomodel    timeout=${timeout}
    ...                                      alias=${alias}

ADMIN INFOMODEL Disconnect Infomodel
    [Arguments]    ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Disconnect Infomodel    alias=${alias}

ADMIN INFOMODEL Teardown Infomodel
    [Arguments]    ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Teardown Infomodel    alias=${alias}

ADMIN INFOMODEL Teardown All Aliases For Infomodel
    ute_admin_infomodel.Teardown All Aliases For Infomodel

ADMIN INFOMODEL Wait For Infomodel Response After Reset
    [Arguments]    ${timeout_for_reset}=300
    ...            ${timeout_for_response}=300
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Wait For Infomodel Response After Reset    timeout_for_reset=${timeout_for_reset}
    ...                                                            timeout_for_response=${timeout_for_response}
    ...                                                            alias=${alias}

ADMIN INFOMODEL Save Log
    [Arguments]    ${filename}=${ADMIN_INFOMODEL_FILENAME}
    ...            ${log_dir}=${ADMIN_INFOMODEL_LOG_DIR}
    ...            ${timeout}=180
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Save Infomodel Log  filename=${log_dir}/${filename}
    ...                                     timeout=${timeout}
    ...                                     alias=${alias}
    ADMIN INFOMODEL Verify IMS Saved Correctly    filename=${log_dir}/${filename}

ADMIN INFOMODEL Verify IMS Saved Correctly
    [Arguments]    ${filename}
    ${ims_status}=    Run Keyword And Return Status
    ...    OperatingSystem.File Should Exist
    ...    path=${filename}
    ${ims_status}=    Run Keyword And Return Status
    ...    OperatingSystem.File Should Not Be Empty
    ...    path=${filename}
    ${warn}=    Evaluate  "\\033[33mWARN\\033[0m"
    Run Keyword If    not ${ims_status}
    ...    Log To Console    [ ${warn} ] IMS Log saving failed.

ADMIN INFOMODEL Is Infomodel Connected
    [Arguments]    ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Is Infomodel Connected    alias=${alias}

ADMIN INFOMODEL Query Infomodel
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Query Infomodel    query=${dist_name} is [${parameter}]
    ...                                    timeout=${timeout}
    ...                                    alias=${alias}

ADMIN INFOMODEL Query Infomodel Check Any Without Parameter
    [Arguments]    ${dist_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Query Infomodel    query=check ${dist_name}
    ...                                    timeout=${timeout}
    ...                                    alias=${alias}

ADMIN INFOMODEL Query Infomodel Check Any With Parameter
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Query Infomodel    query=check ${dist_name} is [${parameter}]
    ...                                    timeout=${timeout}
    ...                                    alias=${alias}

ADMIN INFOMODEL Query Infomodel Check Every With Parameter
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Query Infomodel    query=every ${dist_name} is [${parameter}]
    ...                                    timeout=${timeout}
    ...                                    alias=${alias}

ADMIN INFOMODEL Query Infomodel Check Count With Parameter
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${number}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Query Infomodel    query=count ${dist_name} is [${parameter}] = ${number}
    ...                                    timeout=${timeout}
    ...                                    alias=${alias}

ADMIN INFOMODEL Query Infomodel Check Count Without Parameter
    [Arguments]    ${dist_name}
    ...            ${number}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Query Infomodel    query=count ${dist_name} is = ${number}
    ...                                    timeout=${timeout}
    ...                                    alias=${alias}

ADMIN INFOMODEL Query Infomodel Get Count With Parameter
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ${out_count}=    ute_admin_infomodel.Query Infomodel  query=get count ${dist_name} is [${parameter}]
    ...                                                   timeout=${timeout}
    ...                                                   alias=${alias}
    [Return]  ${out_count}

ADMIN INFOMODEL Query Infomodel Get Count Without Parameter
    [Arguments]    ${dist_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ${out_count}=   ute_admin_infomodel.Query Infomodel  query=get count ${dist_name}
    ...                                                  timeout=${timeout}
    ...                                                  alias=${alias}
    [Return]  ${out_count}

ADMIN INFOMODEL Query Infomodel Get Object With Parameter
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ${out_object}=  ute_admin_infomodel.Query Infomodel  query=get object ${dist_name} is [${parameter}]
    ...                                                  timeout=${timeout}
    ...                                                  alias=${alias}
    [Return]  ${out_object}

ADMIN INFOMODEL Query Infomodel Get Object With Parameter Value
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ${out_object}=  ute_admin_infomodel.Query Infomodel  query=get object ${dist_name} is [${parameter}=${value}]
    ...                                                  timeout=${timeout}
    ...                                                  alias=${alias}
    [Return]  ${out_object}

ADMIN INFOMODEL Query Infomodel Get Object Without Parameter
    [Arguments]    ${dist_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ${out_object}=  ute_admin_infomodel.Query Infomodel  query=get object ${dist_name}
    ...                                                  timeout=${timeout}
    ...                                                  alias=${alias}
    [Return]  ${out_object}

ADMIN INFOMODEL Query Infomodel Get List With Parameter
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ${out_list}=  ute_admin_infomodel.Query Infomodel  query=get list ${dist_name} is [${parameter}]
    ...                                                timeout=${timeout}
    ...                                                alias=${alias}
    [Return]  ${out_list}

ADMIN INFOMODEL Query Infomodel Get List With Parameter Value
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ${out_list}=  ute_admin_infomodel.Query Infomodel  query=get list ${dist_name} is [${parameter}=${value}]
    ...                                                timeout=${timeout}
    ...                                                alias=${alias}
    [Return]  ${out_list}

ADMIN INFOMODEL Query Infomodel Get List Without Parameter
    [Arguments]    ${dist_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ${out_list}=  ute_admin_infomodel.Query Infomodel  query=get list ${dist_name}
    ...                                                timeout=${timeout}
    ...                                                alias=${alias}
    [Return]  ${out_list}

ADMIN INFOMODEL Get List Of Parameters For Given Object
    [Arguments]    ${dist_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ${out_query_result}=    ute_admin_infomodel.Query Infomodel    query=get list ${dist_name}  timeout=${timeout}  alias=${alias}
    [Return]     ${out_query_result}

ADMIN INFOMODEL Get Infomodel Object And Return Parameter Value
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ${infomodel_object}=  ute_admin_infomodel.Get Infomodel Object    dist_name=${dist_name}    timeout=${timeout}    alias=${alias}
    [Return]    ${infomodel_object.${parameter}}

ADMIN INFOMODEL Query Infomodel And Expect Parameter Value
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ${out_query_result}=    ute_admin_infomodel.Query Infomodel    query=${dist_name} is [${parameter}=${value}]  timeout=${timeout}  alias=${alias}

ADMIN INFOMODEL Query Infomodel And Not Expect Parameter Value
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${timeout}=120
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ${out_query_result}=    ute_admin_infomodel.Query Infomodel    query=${dist_name} is [${parameter}!=${value}]  timeout=${timeout}  alias=${alias}

ADMIN INFOMODEL Query Infomodel And Expect Grater Value
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ${out_query_result}=    ute_admin_infomodel.Query Infomodel    query=${dist_name} is [${parameter}>${value}]  timeout=${timeout}  alias=${alias}

ADMIN INFOMODEL Query Infomodel And Expect Lower Value
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ${out_query_result}=    ute_admin_infomodel.Query Infomodel    query=${dist_name} is [${parameter}<${value}]  timeout=${timeout}  alias=${alias}

ADMIN INFOMODEL Query Infomodel And Expect Lower Or Equal Value
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ${out_query_result}=   ute_admin_infomodel.Query Infomodel    query=${dist_name} is [${parameter}=<${value}]  timeout=${timeout}  alias=${alias}

ADMIN INFOMODEL Query Infomodel And Expect Grater Or Equal Value
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ${out_query_result}=    ute_admin_infomodel.Query Infomodel    query=${dist_name} is [${parameter}=>${value}]  timeout=${timeout}  alias=${alias}


ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    [Arguments]    ${timeout}=900
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    Query infomodel  query=${ADMIN_INFOMODEL_CPLANE_PATH} is [stateInfo.usageState=regex"Idle|Active"]
    ...              timeout=${timeout}
    ...              alias=${alias}

ADMIN INFOMODEL Check If RMOD And Cablinks Are Detected
    [Arguments]    ${rmod_number}
    ...            ${cablink_number}
    ...            ${cablink_type}
    ADMIN INFOMODEL Check If SMOD_L Is Online State
    ADMIN INFOMODEL Check If RMOD Is In Enabled State  rmod_number=${rmod_number}
    ADMIN INFOMODEL Check If RMOD CABLINK_L Is In Online State  cablink_type=${cablink_type}  rmod_number=${rmod_number}
    ...    cablink_number=${cablink_number}

ADMIN INFOMODEL Check If RMOD CABLINK_L Is In Online State
    [Arguments]    ${cablink_type}
    ...            ${cablink_number}
    ...            ${rmod_number}
    ...            ${expected_state}=availabilityStatus=regex"Online|"
    ADMIN INFOMODEL Check If RMOD CABLINK_L Is In Expected State  cablink_type=${cablink_type}
    ...                                                           cablink_number=${cablink_number}
    ...                                                           rmod_number=${rmod_number}
    ...                                                           expected_state=${expected_state}

ADMIN INFOMODEL Check If RMOD CABLINK_L Is In Expected State
    [Arguments]    ${cablink_type}
    ...            ${cablink_number}
    ...            ${rmod_number}
    ...            ${expected_state}
    ...            ${timeout}=30
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ${query_str1}    Set Variable    [cablinkType=${cablink_type},sourceDistName=regex"/MRBTS-1/RAT-1/EQM_L-1/RMOD_L
    ${query_str2}    Set Variable    -${rmod_number}/CONNECTOR_L-.*",stateInfo.${expected_state}] = ${cablink_number}]
    ute_admin_infomodel.Query Infomodel
    ...    query=count ${ADMIN_INFOMODEL_CABLINK_PATH} is ${query_str1}${query_str2}
    ...                                  timeout=${timeout}
    ...                                  alias=${alias}

ADMIN INFOMODEL Check If RMOD Is In Enabled State
    [Arguments]    ${expected_state}=operationalState=regex"Enabled|enabled"
    ...            ${rmod_number}=None
    ADMIN INFOMODEL Check If RMOD Is In Expected State    expected_state=${expected_state}
    ...                                                   rmod_number=${rmod_number}

ADMIN INFOMODEL Check If RMOD Is In Expected State
    [Arguments]    ${expected_state}
    ...            ${rmod_number}
    ...            ${timeout}=30
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Query Infomodel  query=${ADMIN_INFOMODEL_RMOD_L}${rmod_number} is [stateInfo.${expected_state}]
    ...                                  timeout=${timeout}
    ...                                  alias=${alias}

ADMIN INFOMODEL Check If RMOD_R Is In Expected State
    [Arguments]    ${expected_state}
    ...            ${rmod_number}
    ...            ${timeout}=30
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Query Infomodel  query=${ADMIN_INFOMODEL_RMOD_R}${rmod_number} is [stateInfo.${expected_state}]
    ...                                  timeout=${timeout}
    ...                                  alias=${alias}

ADMIN INFOMODEL Check If RMOD Is Disabled
    [Arguments]    ${rmod_number}
    ...            ${timeout}=30
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ADMIN INFOMODEL Check If RMOD Is In Expected State  rmod_number=${rmod_number}
    ...                                                 expected_state=operationalState=regex"Disabled|disabled"
    ...                                                 timeout=${timeout}
    ...                                                 alias=${alias}

ADMIN INFOMODEL Check If RMOD Is Enabled
    [Arguments]    ${rmod_number}
    ...            ${timeout}=30
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ADMIN INFOMODEL Check If RMOD Is In Expected State  rmod_number=${rmod_number}
    ...                                                 expected_state=operationalState=regex"Enabled|enabled"
    ...                                                 timeout=${timeout}
    ...                                                 alias=${alias}

ADMIN INFOMODEL Check If RMOD Is NotInstalled
    [Arguments]    ${rmod_number}
    ...            ${timeout}=30
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ADMIN INFOMODEL Check If RMOD Is In Expected State  rmod_number=${rmod_number}
    ...                                                 expected_state=availabilityStatus=regex"NotInstalled|not installed"
    ...                                                 timeout=${timeout}
    ...                                                 alias=${alias}

ADMIN INFOMODEL Check If RMOD Is Online
    [Arguments]    ${rmod_number}
    ...            ${timeout}=30
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ADMIN INFOMODEL Check If RMOD Is In Expected State  rmod_number=${rmod_number}
    ...                                                 expected_state=availabilityStatus=regex"Online|"
    ...                                                 timeout=${timeout}
    ...                                                 alias=${alias}

ADMIN INFOMODEL Check If RMOD Is Online And Enabled
    [Arguments]    ${rmod_number}
    ...            ${timeout}=30
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ADMIN INFOMODEL Check If RMOD Is Online  rmod_number=${rmod_number}
    ...                                      timeout=${timeout}
    ...                                      alias=${alias}
    ADMIN INFOMODEL Check If RMOD Is Enabled  rmod_number=${rmod_number}
    ...                                       timeout=${timeout}
    ...                                       alias=${alias}

ADMIN INFOMODEL Check If RMOD Is NotInstalled And Disabled
    [Arguments]    ${rmod_number}
    ...            ${timeout}=30
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ADMIN INFOMODEL Check If RMOD Is NotInstalled  rmod_number=${rmod_number}
    ...                                            timeout=${timeout}
    ...                                            alias=${alias}
    ADMIN INFOMODEL Check If RMOD Is Disabled  rmod_number=${rmod_number}
    ...                                        timeout=${timeout}
    ...                                        alias=${alias}


ADMIN INFOMODEL Check If SMOD_L Is Online State
    [Arguments]    ${expected_state}=availabilityStatus=regex"Online|"
    ADMIN INFOMODEL Check If SMOD_L Is In Expected State   expected_state=${expected_state}

ADMIN INFOMODEL Check If SMOD_L Is In Expected State
    [Arguments]    ${expected_state}
    ...            ${timeout}=30
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Query Infomodel  query=${ADMIN_INFOMODEL_SMOD_L_PATH} is [stateInfo.${expected_state}]
    ...                                  timeout=${timeout}
    ...                                  alias=${alias}

ADMIN INFOMODEL BTS RMOD Disconnection Is Detected Cablinks Are Updated
    [Arguments]    ${rmod_number}
    ...            ${cablink_number}
    ...            ${cablink_type}
    ADMIN INFOMODEL Check If RMOD Is In NotInstalled State  rmod_number=${rmod_number}
    ADMIN INFOMODEL Check If RMOD CABLINK_L Is In NotInstalled State  cablink_type=${cablink_type}
    ...                                                               rmod_number=${rmod_number}
    ...                                                               cablink_number=${cablink_number}

ADMIN INFOMODEL Check If RMOD Is In NotInstalled State
    [Arguments]    ${expected_state}=operationalState=regex"NotInstalled|not installed"
    ...            ${rmod_number}=None
    ADMIN INFOMODEL Check If RMOD Is In Expected State    expected_state=${expected_state}
    ...                                                   rmod_number=${rmod_number}

ADMIN INFOMODEL Check If RMOD CABLINK_L Is In NotInstalled State
    [Arguments]    ${cablink_type}
    ...            ${cablink_number}
    ...            ${rmod_number}
    ...            ${expected_state}=availabilityStatus=regex"NotInstalled|not installed"
    ADMIN INFOMODEL Check If RMOD CABLINK_L Is In Expected State  cablink_type=${cablink_type}
    ...                                                           cablink_number=${cablink_number}
    ...                                                           rmod_number=${rmod_number}
    ...                                                           expected_state=${expected_state}

ADMIN INFOMODEL Validate Number Of Resets
    [Arguments]    ${number_of_expected_resets}
    ...            ${filename}=infomodel_tmp.ims2
    ...            ${log_dir}=${OUTPUT_DIR}
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    Run keyword and ignore error    OperatingSystem.Remove File   path=${log_dir}/${filename}
    ADMIN INFOMODEL Save Log  filename=${filename}
    ...                       log_dir=${log_dir}
    ...                       alias=${alias}
    Initialize ims2 validator   ${log_dir}/${filename}
    Add expected ims2 event   reset times=${number_of_expected_resets}
    Validate ims2  alias=${alias}

ADMIN INFOMODEL Check If BTS Is In Test Dedicated State
    [Arguments]    ${tds_state}
    ...            ${timeout}=500
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Query Infomodel  query=${ADMIN_INFOMODEL_MRBTS_M_DN} is [stateInfo.testingState=${tds_state}]
    ...    timeout=${timeout}
    ...    alias=${alias}

##################