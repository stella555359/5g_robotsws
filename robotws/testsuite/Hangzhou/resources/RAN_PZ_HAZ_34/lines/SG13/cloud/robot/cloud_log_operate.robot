*** Settings ***
Documentation    This is for cloud common keywords
#Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/cloud/cloud_dcap.robot
Library       taf.rfrl.cbts.utilities.generic_utils
Library       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/cloud/python/dcap_operation.py
Library       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/cloud/python/log_analysis.py


*** Variables ***
${SCF_PATH_ON_UTE}    /home/ute/SCF
${LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs


*** Keywords ***

Start ttitrace log in vDU by dcap
    [Arguments]    ${dcap_ip}    ${dcap_port}=443    ${username}=dcapuser
    ...            ${password}=dcapadmin!    ${rd_version}=dcapv3
    ...            ${secure}=${True}
    ...            ${gnb_index}=${0}         ${vdu_index}=${0}
    ...            ${vdu_custom_profiles}=NONE
    ...            ${vcu_custom_profiles}=NONE
    ...            ${vcu_trace_profile}=NONE
    ...            ${vdu_trace_profile}=NONE
    ...            ${gnb_trace_profile}=dcap-lite-default
    ...            ${enb_trace_profile}=NONE
    ...            ${bts_trace_profile}=NONE
    [Documentation]   this kw is used to Start TTI Log In vDU.
    ...    | Input Parameters    | Man. | Description |
    ...    | dcap_ip | yes | dcap server ip address  |
    ...    | dcap_port | yes | dcap server port  |
    ...    | dcap_username | no | user name to log in dcap server  |
    ...    | dcap_password | no | password to log in dcap server  |
    ...    | rd_version | no | dcap api version  |
    ...    | secure | no | true for https, false for http |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of vDU |
    ...    | vdu_custom_profiles | yes | specify what kind of tti logs that dcap captures from vDU |
    ...    | vcu_custom_profiles | no | specify what kind of tti logs that dcap captures from vCU |
    ...    | vcu_trace_profile | no | the id or name of the vCU start trace |
    ...    | vdu_trace_profile | no | the id or name of the vDU start trace |
    ...    | gnb_trace_profile | no | the id or name of the gnb start trace |
    ...    | enb_trace_profile | no | the id or name of the enb start trace |
    ...    | bts_trace_profile | no | the id or name of the bts start trace |
    ...
    ...    | Return Value | Description |
    ...    | vdu_web_ip | vdu webem ip |
    ...
    ...    Example
    ...   | Start ttitrace log in vDU by dcap |
    ...
    ${vdu_web_ip}    set variable
    ...    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${vdu_username}    set variable
    ...    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ${vdu_password}    set variable
    ...    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}

    &{vdu_info}=    create dictionary    host=${vdu_web_ip}
    ...    port=443    username=${vdu_username}    password=${vdu_password}
    log to console    \nStarting to connect to the DCAP server
    ${dcap_alias}    generic_utils.get_unique_id_string
    set suite variable    ${dcap_alias}
    connect_to_dcap    host=${dcap_ip}    port=${dcap_port}
    ...    username=${username}    password=${password}    rd_version=${rd_version}    secure=${secure}    alias=${dcap_alias}
    Make Sure BTS Added In DCAP    ${vdu_info}
    log to console    \nstarting capture ttitrace
    ${trace_id}    start_trace_in_dcap    ${vdu_info}    tag=start_trace
    ...    vdu_custom_profile_list=${vdu_custom_profiles}   force=${True}
    ...    vcu_custom_profile_list=${vcu_custom_profiles}
    ...    vcu_trace_profile=${vcu_trace_profile}   vdu_trace_profile=${vdu_trace_profile}
    ...    gnb_trace_profile=${gnb_trace_profile}    enb_trace_profile=${enb_trace_profile}
    ...    bts_trace_profile=${bts_trace_profile}   wait_for_activation=${False}
    ...    timeout=${400}
    [Return]    ${vdu_web_ip}

Stop And Decode TTI Log In vDU
    [Arguments]   ${vdu_web_ip}    ${tti_csv_file}   ${is_combine_dl_ul}=${True}
    [Documentation]   this kw is used to Stop And Decode TTI Log In vDU
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_web_ip | no | vdu webem ip  |
    ...    | is_combine_dl_ul | no | True:  combined DL and UL events  |
    ...                            | False: separate dl and ul *.csv   |
    ...
    ...    | Return Value | Description |
    ...    | tti_csv_file_paths | tti csv file paths |
    ...
    ...    Example
    ...   | Stop And Decode TTI Log In vDU |
    ...
    ${dcap_alias}    generic_utils.get_unique_id_string
    set suite variable    ${dcap_alias}
    log to console    \nStopping capture ttitrace log
    ${dcap_local_file_path}    Stop ttitrace log in vDU by dcap    ${vdu_web_ip}
    @{files}    List Files In Directory    ${dcap_local_file_path}    *.zip
    ${tti_archive}    set variable    ${dcap_local_file_path}/${files}[0]
    ssh.connect to     ${PC_HOST}    ${PC_USER}    ${PC_PASSWORD}    alias=VM
    download_tti_decode_tool    ${VDU_VERSION}    ${dcap_local_file_path}    VM
    ${tti_csv_file_paths}    decode_tti
    ...    ${VDU_VERSION}    ${dcap_local_file_path}    ${tti_archive}
    ...    ${is_combine_dl_ul}    VM
    Log To Console    tti_csv_file_paths=${tti_csv_file_paths}
    ${file_path}    get_directory_name    ${tti_csv_file_paths}[0]
#    ${tti_new_file}    set variable   ${file_path}/${tti_csv_name}.csv
#    Move File     ${tti_csv_file_paths}[0]    ${tti_new_file}
    #Copy File    ${tti_csv_file_paths}[0]    /home/ute/test.csv
    Move File     ${tti_csv_file_paths}[0]    ${tti_csv_file}
    Log To Console    tti_new_file=${tti_csv_file}
    [Return]    ${tti_csv_file}
    [Teardown]  Run Keyword And Ignore Error   ssh.disconnect    alias=VM


Stop ttitrace log in vDU by dcap
    [Arguments]   ${vdu_web_ip}
    [Documentation]   this kw is used to Stop And download TTI Log In vDU
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_web_ip | no | vdu webem ip  |
    ...
    ...    | Return Value | Description |
    ...    | dcap_local_file_path | NA |
    ...
    ...    Example
    ...   | Stop ttitrace log in vDU by dcap |
    ...
    [Timeout]    20 min
    log to console    \nstopping trace
    stop_trace_in_dcap    ${vdu_web_ip}
    log to console    \nDownloading logs
    ${dcap_local_file_path}    Download Trace File From Dcap    ${vdu_web_ip}
    [Return]    ${dcap_local_file_path}

Download Trace File From Dcap
    [Arguments]    ${btsip}    ${wait_time}=300s
    ...            ${timeout}=${600}
    [Documentation]    Used to download trace files under DCAP.
    ...    | Input Parameters | Man. | Description |
    ...    | btsip | yes | bts ip address |
    ...    | wait_time | no | times to check result from DCAP ready |
    ...    | timeout | no | timeout for trace file downloading |
    ...    Example
    ...    | Download Trace File From Dcap | ${btsip}
    ...
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${dcap_local_file_path}    Join path    ${TEST_LOG_DIRECTORY()}    DCAP    ${timestamp}
#    ${dcap_local_file_path}    Join path    /home/ute/    DCAP    ${timestamp}
    Create directory    ${dcap_local_file_path}
    Set Test Variable    ${dcap_local_file_path}
    ${last_trace_id}    get_last_trace_id    ${btsip}
    Log To Console    last_trace_id=${last_trace_id}
    Wait Until Keyword Succeeds    ${wait_time}    10s
    ...    Make Sure Trace Status Ready    ${last_trace_id}

    download_trace_file
    ...    ${btsip}    target_dir=${dcap_local_file_path}
    ...    timeout=${timeout}
    [Return]    ${dcap_local_file_path}

Make Sure Trace Status Ready
    [Arguments]    ${trace_id}
    [Documentation]    Used to make sure trace files are ready to download

    ...    | Input Parameters | Man. | Description |
    ...    | trace_id | yes | to get trace info by trace id |
    ...    Example
    ...    | Make Sure Trace Status Ready | ${trace_id}
    ...
    ${trace_status}    check_trace_status    ${trace_id}
    Should Be True    ${trace_status}

Make Sure BTS Added In DCAP
    [Arguments]    ${bts_dic}    ${alias}=dcap
    [Documentation]    Used to make sure the BTS is added in DCAP.

    ...    | Input Parameters | Man. | Description |
    ...    | bts_dic | yes | bts info as dict type |
    ...    | alias | No | the instance alias, same as alias in Connect To DCAP Server |
    ...    | Return Value | Description |
    ...    |  |  |
    ...    Example
    ...    | Make Sure BTS Added In DCAP | ${bts_dic}  | ${alias}
    ...
    ${bts_web_ip}      Set Variable    ${bts_dic['host']}
    ${bts_username}    Set Variable    ${bts_dic['username']}
    ${bts_password}    Set Variable    ${bts_dic['password']}
    ${bts_port}        Set Variable    ${bts_dic['port']}
    ${all_bts_info}    get_all_bts_info
    ${is_bts_exist}    set variable    ${false}
    FOR    ${info}    IN    @{all_bts_info}
        ${ip}     Set Variable    ${info['host']}
        Run Keyword If    '${ip}'=='${bts_web_ip}'    Set Test Variable  ${is_bts_exist}  ${true}
        Run Keyword If    ${is_bts_exist}    Exit For Loop
    END
    log to console    is_bts_exist=${is_bts_exist}
    Run Keyword If    not ${is_bts_exist}    create_bts_to_dcap    bts_web_ip=${bts_web_ip}    bts_web_port=${bts_port}
    ...    bts_username=${bts_username}    bts_password=${bts_password}    bts_alias=${bts_web_ip}
