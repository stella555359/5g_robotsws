*** Settings ***
Documentation    This file is for  for siso cloud related cases
...              Please do not modify the file without notification to author
...              Author: Zhou Qiang
...              Contact: qiang.1.zhou@nokia-sbell.com
...              Squad: SRAN HZ SISO
Library      BuiltIn
Library           taf.transport.ssh    WITH NAME    csn

*** Keywords ***
Lock UE Band
     [Arguments]    ${ue_index}
     ...    ${ue_type}
     ...    ${band}
     Log    ${ue_index}
     Run Keyword If    '${ue_type}'=='nokia_cpe'    Lock Band For Nokia CPE    ue_index=${ue_type}
     ...    band=${band}

Lock Band For Nokia CPE
     [Arguments]    ${ue_index}
     ...    ${band}
     android_common_keyword.Connect to control pc enhanced
     ...    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_username}    cpc_passwd=${cpc_password}
     ${remote_pc_shell_channel}=    traffic_via_iperf.Connect to ue manage ip
     ...    ue_index=${ue_index}    ue_manage_ip=${ue_manage_ip}    ue_manage_username=${ue_manage_username}
     ...    ue_manage_password=${ue_manage_password}
     #BuiltIn.Call Method    ${remote_pc_shell_channel}    send
     #...    cfgcli add InternetGatewayDevice.WANDevice.2.X_ALU-COM_Cellular.X_ALU-COM_5GBand.\n
     #Sleep    2s
     #${status}   BuiltIn.Call Method    ${remote_pc_shell_channel}    recv_ready
     #${output}   Run Keyword If     ${status}    Call Method    ${remote_pc_shell_channel}    recv    ${65535}
     #${output}    Convert To String    ${output}
     #${band_index}=    Get Regexp Matches    ${output}      X_ALU-COM_5GBand\\.(\\d+?)\\.    1


     BuiltIn.Call Method    ${remote_pc_shell_channel}    send
     ...    cfgcli -s InternetGatewayDevice.WANDevice.2.X_ALU-COM_Cellular.X_ALU-COM_5GBand.1.Band n${band}\n
     Sleep    2s
     BuiltIn.Call Method    ${remote_pc_shell_channel}    send
     ...    cfgcli -s InternetGatewayDevice.WANDevice.2.X_ALU-COM_Cellular.X_ALU-COM_5GBand.1.Enable true\n
     ${status}   BuiltIn.Call Method    ${remote_pc_shell_channel}    recv_ready
     ${output}   Run Keyword If     ${status}    Call Method    ${remote_pc_shell_channel}    recv    ${65535}

     [Teardown]    Run Keywords     Call Method    ${remote_pc_shell_channel}     close    AND
     ...    csn.disconnect    connection=cpc_${ue_index}

Remove Known File In Ue Control PC
     [Arguments]    ${ue_index}
     ${ue_config}   ue.get_common_ue_config   ue_info=${tl.ues[0]}    index=${ue_index}
     android_common_keyword.Connect to control pc enhanced
     ...    ue_index=${ue_index}    cpc_ip=${ue_config['cpc_ip']}    cpc_usrname=${ue_config['cpc_username']}
     ...    cpc_passwd=${ue_config['cpc_password']}
     csn.execute    find /home -name known_hosts | xargs rm    connection=cpc_${ue_index}
     ${root_ssh}    csn.execute    ls -a / | grep .ssh    connection=cpc_${ue_index}
     ${root_ssh_exist}    Run Keyword And Return Status    should not be empty    ${root_ssh}
     Run Keyword If    ${root_ssh_exist}    csn.execute    rm /.ssh/known_hosts    connection=cpc_${ue_index}
     [Teardown]    csn.disconnect    connection=cpc_${ue_index}

_Connect To Ctrl Pc
    [Documentation]  connect the control PC
    ...   :param cpc_ip: the ip address of control PC
    ...   :param cpc_usrname:  the user name to login in control PC
    ...   :param cpc_passwd: the user password to login in control PC
    [Arguments]    ${cpc_ip}    ${cpc_usrname}   ${cpc_passwd}  ${alias}=cpc
    Wait Until Keyword Succeeds    5min    20s
    ...   Csn.Connect to   ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    alias=${alias}

Reboot Ue Control PC
    [Arguments]    ${cpc_ip}    ${cpc_usrname}   ${cpc_passwd}    ${ue_index}
    _Connect To Ctrl Pc    ${cpc_ip}    ${cpc_usrname}   ${cpc_passwd}   cpc_${ue_index}
    csn.Send Command    command=shutdown -r -t 3     connection=cpc_${ue_index}    timeout=5
    csn.disconnect    connection=cpc_${ue_index}
    Sleep   60s
