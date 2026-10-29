*** Settings ***
Documentation
...   mapping RF5.0

Library           taf.hw.pdu    WITH NAME    pdu
Library    taf.transport.ssh    WITH NAME    csn
Library           taf/rfrl/cbts/utilities/time_convert.py
Library           taf.rfrl.cbts.utilities.tl_config   WITH NAME  tl_config
Library           taf.rfrl.cbts.devices.ru.ru_operations.FDDRUOpe  WITH NAME   ru_fdd_ope
Resource          taf/rfrl/cbts/robot/vdu/vdu_log.robot
Resource          taf/rfrl/cbts/robot/ru/ru_operations.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/alarm_checking.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot

*** Keywords ***
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

Cloud Perform RU Power On
    [Arguments]    ${ru_index}=${1}    ${gnb_index}=${0}    ${vdu_index}=${0}
    ...    ${model}=${tl.gnbs[0].dus[0].fhgws[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    ...    ${ru_pdu_ip}=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}-1].pdu_port.pdu.addr}
    ...    ${ru_pdu_port}=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}-1].pdu_port.port_no}
    [Documentation]    *****************
    ...    This keyword is designed to power on a given RU (Remote Unit).
    ...    - [Keyowrd Details]
    ...    It generates a unique string and uses it to connect to the vDU.
    ...    It retrieves the model, IP, and port of the PDU (Power Distribution Unit) for the given RU.
    ...    It then powers on the PDU port for the RU.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ru_index | No | The RU index. Default is 1. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...    | model | No | The model of the PDU. Default is the model of the PDU for the given RU from testline configuration. |
    ...    | ru_pdu_ip | No | The IP of the PDU for the given RU. Default is the IP of the PDU for the given RU from testline configuration. |
    ...    | ru_pdu_port | No | The port of the PDU for the given RU. Default is the port of the PDU for the given RU from testline configuration. |
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
    log to console    \nPower On Rmod ${ru_index}
    ${ru_index}    Convert to integer    ${ru_index}
    pdu.setup_pdu    model=${model}    host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}
    pdu.power_on    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}

Cloud SSH Execute CMD
    [Arguments]  ${command}    ${expert_prompt}=#    ${check_result}=${True}    ${alias}=default
    [Documentation]    *****************
    ...    This keyword is designed to execution command in case of ssh proxy.
    ...    - [Keyowrd Details]
    ...    This keyword accepts the RU index, gNB index, vDU index as arguments.
    ...    It then returns the IP for given RU.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | command | Yes | command to be executed. |
    ...    | expert_prompt | No | The command prompt. Default is #. |
    ...    | check_result | No | if check result. Default is True. |
    ...    | alias | No | The connection alias. Default is 'default'. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | content | the return info after excution commands. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* xuewen.zhang@nokia-sbell.com
    ...    *Group* VRF_HAZ4_05
    ...    *******************
    ${connection}    Get Library Instance    ssh_conn
    Call Method    ${connection.ssh_conn}    set_prompt   ${expert_prompt}   alias=${alias}
    ${content}    Call Method    ${connection.ssh_conn}    execute    ${command}    check_result=${check_result}    alias=${alias}
    [Return]  ${content}

Cloud Disconnect Alais
    [Arguments]  ${alias}=default
    [Documentation]    *****************
    ...    This keyword is designed to disconnect the given alais.
    ...    - [Keyowrd Details]
    ...    This keyword disconnects the given alias of connection.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | alias | No | The connection alais. Default value is 'default'. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* xuewen.zhang@nokia-sbell.com
    ...    *Group* VRF_HAZ4_05
    ...    *******************
    ${connection}    Get Library Instance    ssh_conn
    ${content}    Call Method    ${connection.ssh_conn}    disconnect    alias=${alias}

Cloud Get RU Direct Connection Flag
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0    ${vdu_vnf_index}=0    ${conn_prompt}=${EMPTY}
    ...    ${vdu_release_name}=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.vnfs[${vdu_vnf_index}].name}
    ...    ${vdu_namespace}=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    [Documentation]    *****************
    ...    This keyword is designed to Get RU Direct Connection Flag
    ...    - [Keyowrd Details]
    ...    change to fetch DC flag from 'helm get values vdu|grep fhmSiso: direct-connect'
    ...    return 0 if it's switch network(SWN)
    ...    return 1 if it's direct_connection(DC)
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...    | vdu_vnf_index | no | vdu_vnf_index, default is 0 |
    ...    | conn_prompt | no | prompt used to connect to vdu cloud hosting, default is EMPTY |
    ...    | vdu_release_name | no | vdu_release_name, default value is got from tl config file |
    ...    | vdu_namespace | no | vdu_namespace, default value is got from tl config file |
    ...
    ...    | =Return Values= | =Description= |
    ...    | ru_direct_connection_flag | Get RU Direct Connection Flag |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* xuewen.zhang@nokia-sbell.com
    ...    *Group* VRF_HAZ4_05
    ...    *******************
    ${conn_alias}    generic_utils.get_unique_id_string
    ${vdu_namespace}   tl_config.get_vdu_namespace   vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${vdu_release_name}    Get vDU Release Name
    ssh_conn.connect_to_vdu_cloud_hosting    using_tenant=${True}    prompt=${conn_prompt}
    ...                                      vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    ${cmd}  Set Variable  helm get values ${vdu_release_name} -n ${vdu_namespace}|grep -E "fhmSiso:\\s*direct-connect"|wc -l
    ${output}   ssh_conn.execute_normal_cmd   base_command=${cmd}   alias=${conn_alias}

    #to strip linux cosole characters as follow
    ${lineNum}    String.Get Line Count   ${output}
    ${stat}   Run Keyword And Return Status    Should Be True    '${output}'=='1'
    Return From Keyword If   ${lineNum}==1 and ${stat}   1
    ${lines}   String.Split To Lines   ${output}
    Run Keyword If   ${lineNum}>=3   Run Keywords    Collections.Remove From List    ${lines}   0
    ...    AND    Collections.Remove From List    ${lines}   -1
    ${len}    BuiltIn.Get Length    ${lines}
    Return From Keyword If   ${len}>=1 and '${lines}[-1]'=='1'   1

    ${ru_direct_connection_flag}  Set Variable     0
    [Return]  ${ru_direct_connection_flag}
    [Teardown]  ssh_conn.disconnect_vdu_cloud_hosting  alias=${conn_alias}

Get vDU Release Name
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0    ${vdu_vnf_index}=0
    [Documentation]    *****************
    ...    This keyword is designed to Get vDU Release Name From Testline
    ...    - [Keyowrd Details]
    ...    return vDU release name got from tl config file.

    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...    | vdu_vnf_index | no | vdu_vnf_index, default is 0 |
    ...
    ...    | =Return Values= | =Description= |
    ...    | release_name | vDU Release Name got from tl config file  |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* xuewen.zhang@nokia-sbell.com
    ...    *Group* VRF_HAZ4_05
    ...    *******************
    ${release_name}  set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.vnfs[${vdu_vnf_index}].name}
    [Return]  ${release_name}

Cloud Get RU IP
    [Arguments]    ${ru_index}=${1}    ${gnb_index}=0     ${vdu_index}=0
    [Documentation]    *****************
    ...    This keyword is designed to get RU IP.
    ...    - [Keyowrd Details]
    ...    This keyword accepts the RU index, gNB index, vDU index as arguments.
    ...    It then returns the IP for given RU.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ru_index | No | The RU index. Default is 1. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | RF_ip | IP of the given RU. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* xuewen.zhang@nokia-sbell.com
    ...    *Group* VRF_HAZ4_05
    ...    *Update* jie.2.li@nokia-sbell.com  mapping RF5.0
    ...    *******************
    ${TDD_RUs}  ${FDD_RUs}    Get TDD/FDD RU Info On Specific vCU And VDU   gnb_index=${gnb_index}
    ...   vdu_index=${vdu_index}
    ${TDD_RUS_RESULT}=    Wait Until Keyword Succeeds    30s   30   ru_operations._Get Final SN IP Mapping   ${TDD_RUs}
    ...   vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${ru_index}    convert to integer    ${ru_index}
    ${RF_ip}   set variable   ${TDD_RUS_RESULT}[${ru_index-1}][ru_ip]
    [Return]  ${RF_ip}

Cloud Connect to RU
    [Arguments]    ${ru_index}=1     ${vdu_index}=0    ${gnb_index}=0
    [Documentation]    *****************
    ...    This keyword is designed to setup connection to RU.
    ...    - [Keyowrd Details]
    ...    This keyword accepts the RU index, gNB index, vDU index as arguments.
    ...    It then returns the alias of connection to RU.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ru_index | No | The vDU index. Default is 1. |
    ...    | vdu_index | No | The RU index. Default is 0. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | alias | alias of connection to RU. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* xuewen.zhang@nokia-sbell.com
    ...    *Group* VRF_HAZ4_05
    ...    *******************
    log to console    \nConnect to RU_${ru_index}
    ${is_dc}    Cloud Get RU Direct Connection Flag    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${is_dc}    set variable if    ${is_dc}    1    0
    Set Test Variable    ${is_dc}
    ${ru_index}    convert to integer    ${ru_index}
    ${ru_index}    Evaluate    ${ru_index}-1
    ${alias}    Connect To RU Ecpri Interface Of TDD    vdu_index=${vdu_index}    gnb_index=${gnb_index}    ru_index=${ru_index}
    ...    is_dc=${is_dc}
    [Return]    ${alias}

Cloud Collect RU log
    [Arguments]    ${ru_index}=${1}    ${gnb_index}=0     ${vdu_index}=0
    ...  ${rf_login_name}=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...  ${password}=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    [Documentation]    *****************
    ...    This keyword is designed to Collect RU log with command.
    ...    - [Keyowrd Details]
    ...    This keyword accepts the RU index, gNB index, vDU index as arguments.
    ...    It then returns RU log file path on container.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ru_index | No | The RU index. Default is 1. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...    | rf_login_name | No | The ru username defined in tl config file. |
    ...    | password | No | The ru password defined in tl config file. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | log_in_container | RU log file path in container. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* xuewen.zhang@nokia-sbell.com
    ...    *Group* VRF_HAZ4_05
    ...    *******************
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${rmods_info}  vdu_ope_base.get_rmod_status  conn_alias=${conn_alias}
    FOR   ${rmod_info}   IN    @{rmods_info}
        ${product_name}    Set Variable    ${rmod_info['product_name']}
        ${expert_prompt}   Set Variable If    '${product_name}'=='AQQL' or '${product_name}'=='AQQS'    \/usr\/bin    \#
        Exit For Loop If  "${rmod_info['id']}"=="${ru_index}"
    END
    vcu_gen.logout_rest    conn_alias=${conn_alias}
    ${ru_ip}    Cloud Get RU IP    ru_index=${ru_index}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${alias}    Cloud Connect to RU    ru_index=${ru_index}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${rfsw_log_name}    Set Variable    rfsw_log_${timestamp}.zip
    ${content}    Cloud SSH Execute CMD    cd /usr/bin;ccsShell.sh log -a -z /ram/rfsw_log.zip
    ...    expert_prompt=${expert_prompt}     alias=${alias}    #check_result=${False}
    Cloud SSH Execute CMD   command=exit    expert_prompt=bash-5.2$    alias=${alias}
    ${cmd}    Set Variable If    ${is_dc}
    ...    scp -o StrictHostKeyChecking=no -o BindAddress=70.70.70.1 ${rf_login_name}@${ru_ip}:/ram/rfsw_log.zip /tmp/rfsw_log.zip
    ...    scp -o StrictHostKeyChecking=no ${rf_login_name}@${ru_ip}:/ram/rfsw_log.zip /tmp/rfsw_log.zip
    Cloud SSH Execute CMD    command=${cmd}    expert_prompt=password:    alias=${alias}    check_result=${False}
    Cloud SSH Execute CMD    command=${password}    expert_prompt=bash-5.2$    alias=${alias}
    ${log_in_container}    set variable    /tmp/rfsw_log.zip
    [Return]  ${log_in_container}
    [Teardown]    run keyword and ignore error    Cloud Disconnect Alais    alias=${alias}

Cloud Collect RU log and Download
    [Arguments]    ${ru_index}=${1}    ${gnb_index}=0     ${vdu_index}=0    ${ru_log_path}=${SAVE LOG DIRECTORY}
    [Documentation]    *****************
    ...    This keyword is designed to Collect RU log with command and download to Test PC.
    ...    - [Keyowrd Details]
    ...    This keyword accepts the RU index, gNB index, vDU index as arguments.
    ...    It then returns RU log file path on container.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ru_index | No | The RU index. Default is 1. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...    | ru_log_path | No | The RU log where to save. Default is SUITE_LOG_PATH. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | ${ru_log_path}/rfsw_log.zip | RU log file path in Test PC. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* xuewen.zhang@nokia-sbell.com
    ...    *Group* VRF_HAZ4_05
    ...    *******************
    ${log_in_container}    Cloud Collect RU log    ru_index=${ru_index}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    vDU Download File From Container    pod_name=po-cran1-oamfh-0    container_name=ctr-cran1-oamfh
    ...    local_file_path=${ru_log_path}    file_path_in_container=${log_in_container}
    [Return]  ${ru_log_path}/rfsw_log.zip

Cloud Check RU log in Snapshot
    [Arguments]   ${ru_index}=${1}
    [Documentation]
    ...    This keyword is designed to compaire RU logs collected via command with RU logs collected in vDU snapshot.
    ...    - [Keyowrd Details]
    ...    This keyword accepts the RU index as arguments.
    ...    It collects vDU snapshot and RU log via command seprately and then compaired the RU files list.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ru_index | No | The RU index. Default is 1. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* xuewen.zhang@nokia-sbell.com
    ...    *Group* VRF_HAZ4_05
    ...    *******************
    log to console   \nsave local snapshot on vDU...
    ${snapshot_path}    Trigger And Save Local Snapshot For vDU
    should exist    ${snapshot_path}/RU_logs.zip
    extract zip file    ${snapshot_path}/RU_logs.zip    ${snapshot_path}/RU_logs
    extract zip file    ${snapshot_path}/RU_logs/RU_${ru_index}.zip    ${snapshot_path}/RU_logs/RU_${ru_index}
    ${detail_files}    List Files In Directory    path=${snapshot_path}/RU_logs/RU_${ru_index}
    log to console   \nsave ru logs with command...
    ${download_rfsw_log_path}    Cloud Collect RU log and Download    ru_index=${ru_index}    ru_log_path=${snapshot_path}
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

Get Rmod List
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]
    ...    This keyword is get rmode list.
    ...    - [Keyowrd Details]
    ...    This keyword is get rmode list.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The GNB index. Default value is 0. |
    ...    | =Return Values= | =Description= |
    ...    | rmods | This keyword return rmode list. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* jiayi.tang@nokia-sbell.com
    ...    *Group* VRF_HAZ3_02
    ...    *******************
    log to console    rmods_info
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}    alias=${conn_alias}
    ${rmods_status}    vdu_ope_base.get_rmod_status    conn_alias=${conn_alias}
    ${rmods}  create list
    FOR    ${rmod}    IN    @{rmods_status}
        append to list    ${rmods}    ${rmod}[id]
    END
    [Return]    ${rmods}
    [Teardown]  vdu_gen.logout_rest    conn_alias=${conn_alias}

Reset Rmod By Rest
    [Arguments]   ${rmods_list}   ${vdu_index}=0    ${gnb_index}=0
    [Documentation]
    ...    This keyword is to reset ru.
    ...    - [Keyowrd Details]
    ...    This keyword is to reset ru.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | rmods_list | Yes | The RMOD list. No default value. |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The GNB index. Default value is 0. |
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* jiayi.tang@nokia-sbell.com
    ...    *Group* VRF_HAZ3_02
    ...    *******************
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}        alias=${conn_alias}
    vdu.reset_rmods     rmods_list=${rmods_list}    vdu_connection=${conn_alias}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Verify All RU Status Should Be Normal on vDU
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]
    ...    This keyword is to check ru status.
    ...    - [Keyowrd Details]
    ...    This keyword is to check ru status.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The GNB index. Default value is 0. |
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* jiayi.tang@nokia-sbell.com
    ...    *Group* VRF_HAZ3_02
    ...    *******************
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}        alias=${conn_alias}
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${conn_alias}
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
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Get RMOD Power Measurement By Ru Family Type
    [Arguments]   ${alias}  ${prompt_match_ru_list}  ${ru_index}=1  ${ru_family_type}=rf7  ${vdu_index}=0  ${gnb_index}=0
    [Documentation]    *****************
    ...    This keyword is designed to get the power measurement of a given RU (Remote Unit) by its family type.
    ...    - [Keyword Details]
    ...    It retrieves the product name of the RU and sets the expert prompt based on the product name.
    ...    It then executes the appropriate command based on the RU family type to get the power measurement.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | alias | Yes | The connection alias. |
    ...    | ru_index | No | The RU index. Default is 1. |
    ...    | ru_family_type | No | The RU family type. Default is 'rf7'. It should be 'made1', 'made2', or 'rf7'. |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | cmd_temp_action, expert_prompt | The command to get the power measurement and the expert prompt. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 30.05.2024 - - Created
    ...    *******************
    ...    * Owner: kaihui.fan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${rmods_info}  vdu_ope_base.get_rmod_status  conn_alias=${conn_alias}
    FOR   ${rmod_info}   IN    @{rmods_info}
        ${product_name}    Set Variable    ${rmod_info['product_name']}
        ${is_in_list} =    Evaluate    '${product_name}' in @{prompt_match_ru_list}
        ${expert_prompt}   Set Variable If    ${is_in_list}   \/home\/rfsw    \#
        Exit For Loop If  "${rmod_info['id']}"=="${ru_index}"
    END
    vcu_gen.logout_rest    conn_alias=${conn_alias}
    ${cmd_temp_create}   Run Keyword If  "${ru_family_type}"=="made2"  Set Variable   "/ action create PsuMeasurements /rf_psu /rf/psu"
    ...    ELSE IF  "${ru_family_type}"=="made1"  Set Variable  "/ action create PsuMeasurements /CI/PsuMeasurements /module"
    ...   ELSE IF  "${ru_family_type}"=="rf7"  Set Variable  "/ action create ConfigAccess /ca /module"
    ...   ELSE  Fail   \nNot support ru made type
    ${status}  ${output}    Run Keyword And Ignore Error  Cloud SSH Execute CMD    echo ${cmd_temp_create}|frmonShellClient 127.0.0.1 2000
    ...    expert_prompt=${expert_prompt}  check_result=${False}   alias=${alias}
    Should Contain Any   ${output}    done ok    Path already taken
    ${cmd_temp_rf7}   Run Keyword If  "${ru_family_type}"=="rf7"  Set Variable   "/ action create Psu /papsu1 /rf/papsu1"
    ${output_rf7}   Run Keyword If  "${ru_family_type}"=="rf7"
    ...  Cloud SSH Execute CMD    echo ${cmd_temp_rf7}|frmonShellClient 127.0.0.1 2000
    ...    expert_prompt=${expert_prompt}  check_result=${False}   alias=${alias}
    Run Keyword If  "${ru_family_type}"=="rf7"  Should Contain Any   ${output_rf7}    done ok    Path already taken
    ${cmd_temp_action}   Run Keyword If  "${ru_family_type}"=="made2"  Set Variable   "/rf_psu action measure"
    ...    ELSE IF  "${ru_family_type}"=="made1"  Set Variable  "/CI/PsuMeasurements action measure"
    ...   ELSE IF  "${ru_family_type}"=="rf7"  Set Variable  "/papsu1 action measure"
    ...   ELSE  Fail   \nNot support ru made type
    [Return]    ${cmd_temp_action}  ${expert_prompt}

Cloud Get RMOD Avg Power Measurement
    [Arguments]   ${prompt_match_ru_list}    ${ru_index}=1  ${ru_family_type}=rf7  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]    *****************
    ...    This keyword is designed to get the average power measurement of a given RU (Remote Unit) by its family type.
    ...    - [Keyword Details]
    ...    It retrieves the product name of the RU and sets the expert prompt based on the product name.
    ...    It then executes the appropriate command based on the RU family type to get the power measurement.
    ...    It repeats this process 10 times and calculates the average power measurement.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ru_index | No | The RU index. Default is 1. |
    ...    | ru_family_type | No | The RU family type. Default is 'rf7'. It should be 'made1', 'made2', or 'rf7'. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | average | The average power measurement. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 30.05.2024 - - Created
    ...    *******************
    ...    * Owner: kaihui.fan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************

    ${alias}=  Cloud Connect to RU  ru_index=${ru_index}  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${cmd_temp_action}  ${expert_prompt}  Cloud Get RMOD Power Measurement By Ru Family Type   prompt_match_ru_list=${prompt_match_ru_list}
    ...   alias=${alias}  ru_index=${ru_index}
    ...   ru_family_type=${ru_family_type}
    ${power_measure}  Convert to number  0
    FOR   ${index}  IN RANGE  10
        ${output}    Cloud SSH Execute CMD    echo ${cmd_temp_action}|frmonShellClient 127.0.0.1 2000
        ...    expert_prompt=${expert_prompt}  check_result=${False}     alias=${alias}
        Should Contain Any   ${output}    done ok    Path already taken
        ${parts}    Split String    ${output}    POWER
        ${power_part}    Get From List    ${parts}    1
        ${power}    Fetch From Left    ${power_part}    \r\n
        ${power}    convert to number  ${power}    2
        ${index}    Evaluate  ${index}+1
        ${power_measure}  Evaluate  ${power_measure}+${power}
        Sleep  5
    END
    ${average}   Evaluate   ${power_measure}/10
    log   \npower_average = ${average}     console=yes
    [Return]    ${average}
    [Teardown]   ru_fdd_ope.disconnect_from_ru  alias=${alias}

Cloud Get RU And Antennas Dist Name And Cells
    [Arguments]  ${ru_index}  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]    *****************
    ...    This keyword is used to retrieve the Radio Unit (RU), Antennas Dist Name and Cells from the vDU.
    ...    - [Keyword Details]
    ...    It retrieves the RU, Antennas Dist Name and Cells from the vDU.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ru_index | Yes | The RU index. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | rmod_runtime_dn | The Radio module runtime managed object dist name. |
    ...    | ants_runtime_dn_list | The Antenna runtime managed object dist names. |
    ...    | rmod_cell_list | The cell list of the Radio module. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 04.06.2024 - - Created
    ...    *******************
    ...    * Owner: kaihui.fan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    * Update: jie.2.li@nokia-sbell.com https://jiradc.ext.net.nokia.com/browse/WESTLAKE-11686

    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${all_rmods_params}=  vdu_ope_base.get_rmod_status  conn_alias=${conn_alias}
    FOR  ${rmod_params}  IN  @{all_rmods_params}
      ${rmod_runtime_dn}=  Set Variable  ${rmod_params['dist_names']['runtime']}
      ${rmod_id_value}=  Set Variable  ${rmod_params['id']}
      ${rmod_ant_ports}=  Set Variable  ${rmod_params['ant_ports']}
      ${rmod_cell_list}=  Set Variable  ${rmod_params['cell_ids']}
      Exit For Loop If  "${rmod_params['id']}"=="${ru_index}"
    END
    Run Keyword If  '${rmod_id_value}'!='${ru_index}'
    ...  Fail  Radio module serial number ${ru_index} not found in current configuration !
    ${ants_runtime_dn_list}  Create List
    FOR  ${ant_port}  IN  @{rmod_ant_ports}
      Append To List  ${ants_runtime_dn_list}  ${ant_port['dist_names']['runtime']}
    END
    [Return]  ${rmod_runtime_dn}  ${ants_runtime_dn_list}  ${rmod_cell_list}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Start RF Scan And Check Scan File
    [Arguments]  ${rmod_dn}  ${capture_type}  ${all_antennas}  ${ants_runtime_dns}=@{EMPTY}  ${antenna_carrier}=${None}
    ...  ${antenna_panel}=${None}  ${rfscan_dir_path}=${SAVE LOG DIRECTORY}  ${rfscan_filename}=rfscan.zip  ${files_count}=14
    ...   ${vdu_index}=0   ${gnb_index}=0
    [Documentation]    *****************
    ...    This keyword is used to initiate the RF scan test operation on the vDU and check the scan file.
    ...    - [Keyword Details]
    ...    It starts the RF scan test operation and waits for the expected status. After the operation, it checks the scan file.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_connection | Yes | The vDU connection. |
    ...    | rmod_dn | Yes | The Radio module runtime managed object dist name. |
    ...    | capture_type | Yes | The Capture type. |
    ...    | all_antennas | Yes | The flag to indicate if all antennas are used. |
    ...    | ants_runtime_dns | No | The Antenna runtime managed object dist names. Default is empty. |
    ...    | antenna_carrier | No | The Managed object dist name of cell. Default is None. MRBTS-11111/NRBTS-11077/NRCELL-1.|
    ...    | antenna_panel | No | The panel of the antenna. Default is None. Full_Array, Top_Array, Bottom_Array, Left_Array, Right_Array |
    ...    | rfscan_dir_path | No | The RF scan directory path. Default is suite logs directory path. |
    ...    | rfscan_filename | No | The RF scan filename. Default is 'rfscan.zip'. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 04.06.2024 - - Created
    ...    *******************
    ...    * Owner: kaihui.fan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    FOR  ${ants_runtime_dn}  IN  @{ants_runtime_dns}
      ${antenna}=  Run Keyword If  '${all_antennas}'=='True'
      ...  Set Variable  ALL_ANTENNAS
      ...  ELSE
      ...  Fetch From Right  string=${ants_runtime_dn}  marker=/
      Run Keyword If  '${all_antennas}'=='True'
      ...  Start RF Scan Test For vDU  rmod_dn=${rmod_dn}  capture_type=${capture_type}
      ...  antenna_panel=${antenna_panel}  antenna_carrier=${antenna_carrier}  vdu_connection=${conn_alias}
      ...  ELSE
      ...  Start RF Scan Test For vDU  rmod_dn=${rmod_dn}  capture_type=${capture_type}  antenna_dn=${ants_runtime_dn}
      ...  antenna_carrier=${antenna_carrier}  antenna_panel=${antenna_panel}  vdu_connection=${conn_alias}
      Log to Console  \nStart RF scan test operation for ${antenna} completed successfully
      ${rfscan_filename_local}=  Set Variable  ${rfscan_filename}_${antenna}
      Cloud Get And Check RF Scan File  ants_runtime_dn_list=${ants_runtime_dns}  rfscan_dir_path=${rfscan_dir_path}
      ...  rfscan_filename=${rfscan_filename_local}  files_count=${files_count}  vdu_connection=${conn_alias}
      Exit For Loop If  '${all_antennas}'=='True'
    END
    [Teardown]  vdu_gen.logout_rest    conn_alias=${conn_alias}

Check Rf Scan Test Operation Status For vDU
    [Arguments]   ${operation_id}  ${expected_status}=success  ${vdu_connection}=${None}
    [Documentation]    *****************
    ...    This keyword is used to check the status of the RF scan test operation on the vDU.
    ...    - [Keyword Details]
    ...    This keyword accepts the operation ID and the expected status as arguments.
    ...    It retrieves the status of the RF scan test operation and checks if it matches the expected status.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | operation_id | Yes | The operation ID of the RF scan test. |
    ...    | expected_status | No | The expected status of the operation. Default is 'success'. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 04.06.2024 - - Created
    ...    *******************
    ...    * Owner: kaihui.fan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04

    ${rf_scan_test_result}=  vdu.Get Rf Scan Test Operation Status  operation_id=${operation_id}  vdu_connection=${vdu_connection}
    Should Be True  '${rf_scan_test_result['status']}'=='${expected_status}'

Start RF Scan Test For vDU
    [Arguments]  ${vdu_connection}  ${rmod_dn}  ${capture_type}  ${antenna_dn}=${None}  ${antenna_carrier}=${None}
    ...  ${antenna_panel}=${None}
    [Documentation]    *****************
    ...    This keyword is used to start the RF scan test operation on the vDU.
    ...    - [Keyword Details]
    ...    It  starts the RF scan test operation and waits for the expected status.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | rmod_dn | Yes | The Radio module runtime managed object dist name. |
    ...    | capture_type | Yes | The Capture type. |
    ...    | antenna_dn | No | The Antenna runtime managed object dist name. Default is None. |
    ...    | antenna_carrier | No | The Managed object dist name of cell. Default is None. |
    ...    | antenna_panel | No | The panel of the antenna. Default is None. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 04.06.2024 - - Created
    ...    - 13.09.2024 - - Updated by j7li: https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10659
    ...    *******************
    ...    * Owner: kaihui.fan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04

    ${start_rf_scan_result}=  vdu.Start Rf Scan Test  ru_dn=${rmod_dn}  signal=${capture_type}  antenna=${antenna_dn}
    ...  antenna_carrier=${antenna_carrier}  antenna_panel=${antenna_panel}  vdu_connection=${vdu_connection}
    Wait Until Keyword Succeeds  160s  5s   Check Rf Scan Test Operation Status For vDU  operation_id=${start_rf_scan_result['operation_id']}
    ...  expected_status=success   vdu_connection=${vdu_connection}

Cloud Get And Check RF Scan File
    [Arguments]  ${ants_runtime_dn_list}  ${rfscan_dir_path}=${SUITE_LOGS_DIR_PATH}  ${rfscan_filename}=rfscan.zip
    ...   ${files_count}=14   ${vdu_connection}=${None}
    [Documentation]    *****************
    ...    This keyword is used to retrieve the RF scan test file from the vDU and check its contents.
    ...    - [Keyword Details]
    ...    It retrieves the RF scan test file and unzips it. It then checks the number of .rfcap and .xml files in the unzipped directory.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ants_runtime_dns | Yes | The Antenna runtime managed object dist names. |
    ...    | rfscan_dir_path | No | The RF scan directory path. Default is suite logs directory path. |
    ...    | rfscan_filename | No | The RF scan filename. Default is 'rfscan.zip'. |
    ...    | files_count | No | The expected number of files. Default is 14. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 04.06.2024 - - Created
    ...    *******************
    ...    * Owner: kaihui.fan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04

    Log To Console    ${ants_runtime_dn_list}
    vdu.Get Rf Scan Test File  local_path=${rfscan_dir_path}  local_file_name=${rfscan_filename}.zip  vdu_connection=${vdu_connection}
    Unzip And Check RF Scan File  rfscan_dir_path=${rfscan_dir_path}  rfscan_filename=${rfscan_filename}  files_count=${files_count}

Set RU Power Variables Based On Direct Connection Flag
    [Arguments]   ${ru_index}=1   ${gnb_index}=0    ${vdu_index}=0    ${fhgw_index}=0   ${rannic_index}=0
    ${is_dc}    Cloud Get RU Direct Connection Flag    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${is_dc}    set variable if    ${is_dc}    1    0
    ${model}   Set Variable If   ${is_dc}  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus[${ru_index}-1].pdu_port.pdu.vendor}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${rannic_index}].rus[${ru_index}-1].pdu_port.pdu.vendor}
    ${ru_pdu_ip}   Set Variable If   ${is_dc}   ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus[${ru_index}-1].pdu_port.pdu.addr}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${rannic_index}].rus[${ru_index}-1].pdu_port.pdu.addr}
    ${ru_pdu_port}   Set Variable If   ${is_dc}  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus[${ru_index}-1].pdu_port.port_no}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${rannic_index}].rus[${ru_index}-1].pdu_port.port_no}
    [Return]    ${model}    ${ru_pdu_ip}    ${ru_pdu_port}

Get Rmod Id Mapping Cell
    [Arguments]    ${cell_id}    ${gnb_index}=0    ${vdu_index}=0
    [Documentation]    This keyword is designed to get the Rmod ID for a given cell ID.
    ...    - [Keyword Details]
    ...    This keyword accepts the cell ID, vDU index, and gNB index as arguments.
    ...    It then logs into the vDU and retrieves the status of all Rmods.
    ...    It iterates over the list of Rmods and checks if the given cell ID is in the cell list of the Rmod.
    ...    If the cell ID is found, it returns the Rmod ID.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | cell_id | Yes | The cell ID. |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | rmod_id | The Rmod ID for the given cell ID. If no match is found, it returns None. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 21.06.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${all_rmods_params}=  vdu_ope_base.get_rmod_status  conn_alias=${conn_alias}
    ${rmod_id}=  Set Variable    ${None}
    FOR  ${rmod_params}  IN  @{all_rmods_params}
      ${rmod_cell_list}=  Set Variable  ${rmod_params['cell_ids']}
      ${rmod_id}=  Set Variable  ${rmod_params['id']}
      ${status}    run keyword and return status    should contain    ${rmod_cell_list}    ${cell_id}
      Exit For Loop If    ${status}
    END
    [Return]    ${rmod_id}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}
