*** Settings ***
Documentation    Common resource about radio operation
Library    ./python/command_execution_in_bts.py
Library    ./python/bts_upgrade.py

*** Keywords ***
########################################################
##                         radio                      ##
########################################################

Get Radio Units
    ${bts_info}=    sbts_admin.get_bts_info
    ${rmod_info}=    Set Variable    ${bts_info["radioModules"]["rmod"]}
    ${rmod_info_dict}    Create Dictionary
    FOR    ${rmod}    IN    @{rmod_info}
        ${tmp_dict}    Create Dictionary    productName=${rmod['productName']}    status=${rmod['status']}
        Set To Dictionary    ${rmod_info_dict}    ${rmod['id']['configuration']}=${tmp_dict}
    END
    [Return]    ${rmod_info_dict}

5G RMOD Operation via WebUI
    [Arguments]    ${locked_unlocked}     ${RMODs_index}
    [Documentation]
    ...    Description: 5G RMOD lock/unlock operation via WebUI by RMOD index or RMOD index list.
    ...    ${RMODs_index} Should be a number or a list.
    Should Be True    '${locked_unlocked.lower()}'=='locked' or '${locked_unlocked.lower()}'=='unlocked'
    ...    ${locked_unlocked.lower()} should be locked/unlocked.
    ${isList}    Robot Isinstance    ${RMODs_index}    list
    ${isNumber}    Robot Isinstance    ${RMODs_index}    int
    ${index_list}    Run Keyword If    ${isNumber}    Create List    ${RMODs_index}
    ${rmod_list}=    Set Variable If    ${isList}    ${RMODs_index}    ${index_list}
    ${mrbtsID}    Set Variable    ${btsid}
    Selenium Coam Login And Disable Screen Lock
    FOR    ${rmod}    IN    @{rmod_list}
        ${RMOD_dist_name}    Set Variable If     'RMOD-' in '${rmod}'    ${rmod}    MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${rmod}
        Log To Console    \n[INFO] ${RMOD_dist_name} is being performed [${locked_unlocked}]... ...
        Run Keyword If    '${locked_unlocked.lower().strip('ed')}'=='lock'    selenium_coam.lock_ru    ru_index=${rmod}    sbts=suite
        Run Keyword If    '${locked_unlocked.lower().strip('ed')}'=='unlock'    selenium_coam.unlock_ru    ru_index=${rmod}    sbts=suite
        # selenium_coam.set_parameter_value    dist_name=${RMOD_dist_name}
        # ...    filter_param=Administrative state    new_value=${locked_unlocked.title()}
        # ...    abbr=administrativeState    sbts=suite
    END
    # selenium_coam.validate_plan    sbts=suite
    # selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=300    sbts=suite

    FOR    ${rmod}    IN    @{rmod_list}
        ${id}    Set Variable If    'RMOD-' in '${rmod}'    ${rmod.split('-')[-1]}    ${rmod}
        Wait Until Keyword Succeeds    180 sec    20 sec    Status Should Be ${locked_unlocked} for RMOD-${id}
    END

Status Should Be ${locked_unlocked} for RMOD-${RMODs_index}
    Should Be True    '${locked_unlocked.lower()}'=='locked' or '${locked_unlocked.lower()}'=='unlocked'
    ...    ${locked_unlocked.lower()} should be locked/unlocked.
    @{rmod_list}=    Split String    ${RMODs_index}    ,
    &{rmod_status}    Get Board Info By Index    board_type=RMOD
    FOR    ${rmod_index}    IN    @{rmod_list}
        Should be equal as strings    ${rmod_status['${rmod_index}']['status']['administrativeState']}    ${locked_unlocked.title()}
        ...  msg=Current RMOD-${rmod_index} administrativeState is not in [${locked_unlocked}] status    ignore_case=${True}
        Should be equal as strings    ${rmod_status['${rmod_index}']['status']['operationalState']}       Enabled
        ...  msg=Current RMOD-${rmod_index} operationalState is not in [Enabled] status    ignore_case=${True}
        Should be equal as strings    ${rmod_status['${rmod_index}']['status']['proceduralStatus']}       configured
        ...  msg=Current RMOD-${rmod_index} proceduralStatus is not in [configured] status    ignore_case=${True}
        Log To Console    \n[INFO] The RMOD-${rmod_index} is ${locked_unlocked} successfully
    END

Admin Reset RMOD
    [Arguments]  ${rmod_id}    ${connection}=default
    ${rmod_dist_name}    Set Variable    /MRBTS-${btsid}/EQM_R-1/APEQM_R-1/RMOD_R-${rmod_id}
    sbts_admin.reset_unit    dist_name=${rmod_dist_name}    connection=${connection}    timeout=300    force_radio_reset=${TRUE}

FPFH Power Operation
    [Arguments]    ${port}    ${operation}=OFF
    pdu.Setup PDU      model=FPFH      host=${FPFH_IP_ADDRESS}      alias=fpfh     login=${user}    password=${password}
    ${port_status}  pdu.Get Port Status      ${port}      pdu_device=fpfh
    Run Keyword If    '${port_status}'=='on'     Log To Console    The port-${port} is ${port_status}, it should be 'OFF'.
    Run Keyword If    '${port_status}'=='off'    Log To Console    The port-${port} is ${port_status}, it should be 'ON'.
    ${status}    Run Keyword If    '${operation.upper()}'=='OFF'    pdu.Power Off      ${port}      pdu_device=fpfh
    ...    ELSE IF    '${operation.upper()}'=='ON'     pdu.Power ON       ${port}      pdu_device=fpfh
    ...    ELSE    Fail    operation should be ON|on|OFF|off.

########################################################
##                       AVQL LMI                     ##
########################################################

LMI eth on
    [Arguments]    ${rmod_id}=AVQL
    [Documentation]    This keyword is used to enable the lmi-eth on Mars of RU.
    ...    To perform command 'sudo lmi-eth on' via 192.168.255.1 -> lxc-attach -> ssh to RU.
    connect_and_execute_command_on_ru    rmod_id=${rmod_id}    command=sudo lmi-eth on
    ${isMarsPingable}    Run    ping -c 5 192.168.100.1
    Should Contain    ${isMarsPingable}    5 received, 0% packet loss    [ ERROR ] Mars is NOT pingable.
    # ${isThorPingable}    Run    ping -c 5 192.168.101.17
    # Should Contain    ${isThorPingable}    5 received, 0% packet loss    [ ERROR ] Thor is NOT pingable.

LMI Execute Command via ssh
    [Arguments]    ${commands}    ${passed_tag}=${None}    ${ip}=192.168.100.1    ${username}=serviceuser
    ...    ${password}=kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=
    [Documentation]    This keyword is used to perform command in RU via LMI card.
    ...    | Arguments | Default | Mandatory | Comments |
    ...    | commands  | NA      | Yes       | single command or command list |
    ...    | passed_tag| None    | No        | it's the regrex of command respose. if =None, only send command, no response. |
    ...    | ip        | 100.1   | No        | 192.168.100.1 is to Mars; 192.168.101.17 is to Thor |
    ...    | username  | serviceuser    | No        | username for ssh session, changed 'rfsw' to 'serviceuser' due to limited access in CB010663. |
    ...    | password  |         | No        | default is password of AVQL/AVQC (serviceuser). |
    ${isSingleCmd}    Run Keyword And Return Status    Should Be String    ${commands}

    ${response_list}    Create List

    ${tmp_cmds_list}    Run Keyword If    ${isSingleCmd}    Create List    ${commands}
    ...    ELSE    Set Variable    ${commands}
    ssh.connect to    hostname=${ip}    username=${username}    password=${password}    alias=lmi
    FOR    ${cmd}    IN    @{tmp_cmds_list}
        Log To Console    --> ${cmd}
        Log    send command: ${cmd}
        ${response}    Run Keyword If    '${passed_tag}'=='None'    ssh.send_command    command=${cmd}    connection=lmi
        ...    ELSE    ssh.execute    command=${cmd}    connection=lmi
        Log To Console    <-- ${response}
        Log    Received: ${response}
        Run Keyword If    '${passed_tag}'!='None'    Should Contain    ${response}    ${passed_tag}
        ...    [ ERROR ] The [${passed_tag}] is NOT in [${response}].
        Append To List    ${response_list}    ${response}
    END
    ${final_response}    Set Variable If    ${isSingleCmd}    ${response}    ${response_list}
    [Return]    ${final_response}
    [Teardown]    ssh.disconnect    connection=lmi

LMI Transfer Files
    [Arguments]    ${remote}    ${local}    ${operation}=download    ${ip}=192.168.100.1    ${username}=serviceuser
    ...    ${password}=kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=
    [Documentation]    This keyword is used to transfer files in RU via LMI card.
    ...    | Arguments | Default | Mandatory | Comments |
    ...    | remote    | NA      | Yes       | if operation is 'download', remote is a file/files list; if operation is 'upload', remote is a path. |
    ...    | local     | NA      | Yes       | if operation is 'download', local is a path; if operation is 'upload', local is a file/files list. |
    ...    | operation | download| No        | download or upload files from or to RU. |
    ...    | ip        | 100.1   | No        | 192.168.100.1 is to Mars; 192.168.101.17 is to Thor |
    ...    | username  | serviceuser    | No        | username for ssh session, changed 'rfsw' to 'serviceuser' due to limited access in CB010663. |
    ...    | password  |         | No        | default is password of AVQL/AVQC (serviceuser). |

    Run Keyword And Ignore Error    Run    ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "192.168.101.17"

    ${operation}    Set Variable    ${operation.lower()}
    Should Be True    '${operation}' in ('download', 'upload')    [ ERROR ] ${operation} should be [ download | upload ].

    Run Keyword If    '${operation}'=='download'    Directory Should Exist    ${local}    [ ERROR ] ${local} is NOT existed.
    Run Keyword If    '${operation}'=='upload'    File Should Exist    ${local}    [ ERROR ] ${local} is NOT existed.

    ${target_files}    Set Variable If    '${operation}'=='download'    ${remote}    ${local}
    ${target_path}    Set Variable If    '${operation}'=='download'    ${local}    ${remote}
    ${isSingleFile}    Run Keyword And Return Status    Should Be String    ${target_files}
    ${tmp_file_list}    Run Keyword If    ${isSingleFile}    Create List    ${target_files}
    ...    ELSE    Set Variable    ${target_files}
    FOR    ${file}    IN    @{tmp_file_list}
        Log To Console    [ transferring ] ${file} --> ${target_path} ...
        Log    transfer file: ${file} --> ${target_path}
        Run Keyword If    '${operation}'=='download'    Run    sshpass -p ${password} scp ${username}@${ip}:${file} ${target_path}
        Run Keyword If    '${operation}'=='upload'    Run    sshpass -p ${password} scp ${file} ${username}@${ip}:${target_path}
    END
