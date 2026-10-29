*** Settings ***

Documentation
...    This robot resource file contains KWs for the Mediatek UE used by SyVe.

Library    Telnet                 WITH NAME    t
Library    Process
Library    taf.ue
Library    taf.ul.messaging.mtk   WITH NAME    mtk
Library    taf.transport.ssh      WITH NAME    ssh

Resource    ../../resources/Common/connect.robot

*** Keywords ***

Disable MTK Bands
    [Documentation]   disable all Bands except 7 on MTK
    ...    :param ue_id: (default=0) Id of UE
    [Arguments]     ${ue_id}=0
    connect.Connect To UE PC  ue_id=${ue_id}  alias=UEPC
#    ${output}=  ssh.execute    adb root  connection=UEPC
#    ${output}=  ssh.execute    adb adb disable-verity  connection=UEPC
#    ${output}=  ssh.execute    adb reboot  connection=UEPC
#    sleep    20s
    ${uepc_ip}=    Set Variable  ${tl.ues[${ue_id}].ssh_connection_details.addr}
    ${uepc_user}=  Set Variable  ${tl.ues[${ue_id}].ssh_connection_details.username}
    ${uepc_pass}=  Set Variable  ${tl.ues[${ue_id}].ssh_connection_details.password}
    ssh.Execute    adb root  connection=UEPC
    ssh.Execute    adb shell setprop persist.service.atci.usermode 1  connection=UEPC
    ssh.Execute    adb shell setprop persist.service.atci.autoinitiate 1  connection=UEPC
    ssh.Execute    adb shell setprop ctl.start atcid-daemon-u  connection=UEPC
    ssh.Execute    adb shell setprop ctl.start atci_service  connection=UEPC
    ssh.Execute    adb forward tcp:5678 localfilesystem:/dev/socket/adb_atci_socket  connection=UEPC
    ${ssh_output}=  Process.Run Process  sshpass -p ${uepc_pass} ssh -f -N -n ${uepc_user}@${uepc_ip} -L 5678:127.0.0.1:5678  shell=True
    Sleep  10s
    T.Open Connection     127.0.0.1  port=5678  encoding=Latin1  encoding_errors=strict
    T.Write    AT+EPBSEH?
    ${telnet_output}=   T.Read until  OK
    T.Write  AT+EPBSEH="0000009a","000400bb","BBDF38DF000087E200100C62","000000000000000000000040"
    ${telnet_output}=   T.Read until  OK
    T.Close Connection


Enable MTK Bands
    [Documentation]   enable all Bands on MTK
    ...    :param ue_id: (default=0) Id of UE
    [Arguments]     ${ue_id}=0
    connect.Connect To UE PC  ue_id=${ue_id}  alias=UEPC
#    ${output}=  ssh.execute    adb root  connection=UEPC
#    ${output}=  ssh.execute    adb adb disable-verity  connection=UEPC
#    ${output}=  ssh.execute    adb reboot  connection=UEPC
#    sleep    20s
    ${uepc_ip}=    Set Variable  ${tl.ues[${ue_id}].ssh_connection_details.addr}
    ${uepc_user}=  Set Variable  ${tl.ues[${ue_id}].ssh_connection_details.username}
    ${uepc_pass}=  Set Variable  ${tl.ues[${ue_id}].ssh_connection_details.password}
    ssh.Execute    adb root  connection=UEPC
    ssh.Execute    adb shell setprop persist.service.atci.usermode 1  connection=UEPC
    ssh.Execute    adb shell setprop persist.service.atci.autoinitiate 1  connection=UEPC
    ssh.Execute    adb shell setprop ctl.start atcid-daemon-u  connection=UEPC
    ssh.Execute    adb shell setprop ctl.start atci_service  connection=UEPC
    ssh.Execute    adb forward tcp:5678 localfilesystem:/dev/socket/adb_atci_socket  connection=UEPC
    ${ssh_output}=  Process.Run Process  sshpass -p ${uepc_pass} ssh -f -N -n ${uepc_user}@${uepc_ip} -L 5678:127.0.0.1:5678  shell=True
    sleep  10s
    T.Open Connection     127.0.0.1  port=5678  encoding=Latin1  encoding_errors=strict
    T.Write    AT+EPBSEH?
    ${telnet_output}=   T.Read Until  OK
    Log  ${telnet_output}
    T.Write  AT+EPBSEH="0000009a","000400bb","BBDF38DF000087E200100C62","3B0A38D7000081E2411DFE6200000003000000000000000000000000000000000000001F"
    ${telnet_output}=   T.Read until  OK
    T.Close Connection


Send AT Command To MTK
    [Documentation]   send AT cmd via adb tunnel to MTK
    ...    :param ue_id: (default=0) Id of UE
    ...    :cmd: (default=AT+CIMI) any AT command
    ...    :return:  return value of telnet comd

    [Arguments]     ${ue_id}=0  ${cmd}=AT+CIMI
    connect.Connect To UE PC  ue_id=${ue_id}  alias=UEPC
#    ${output}=  ssh.execute    adb root  connection=UEPC
#    ${output}=  ssh.execute    adb adb disable-verity  connection=UEPC
#    ${output}=  ssh.execute    adb reboot  connection=UEPC
#    sleep    20s
    ${uepc_ip}=    Set Variable  ${tl.ues[${ue_id}].ssh_connection_details.addr}
    ${uepc_user}=  Set Variable  ${tl.ues[${ue_id}].ssh_connection_details.username}
    ${uepc_pass}=  Set Variable  ${tl.ues[${ue_id}].ssh_connection_details.password}
    ssh.Execute    adb root  connection=UEPC
    ssh.Execute    adb shell setprop persist.service.atci.usermode 1  connection=UEPC
    ssh.Execute    adb shell setprop persist.service.atci.autoinitiate 1  connection=UEPC
    ssh.Execute    adb shell setprop ctl.start atcid-daemon-u  connection=UEPC
    ssh.Execute    adb shell setprop ctl.start atci_service  connection=UEPC
    ssh.Execute    adb forward tcp:5678 localfilesystem:/dev/socket/adb_atci_socket  connection=UEPC
    ${ssh_output}=  Process.Run Process  sshpass -p ${uepc_pass} ssh -f -N -n ${uepc_user}@${uepc_ip} -L 5678:127.0.0.1:5678  shell=True
    Sleep  10s
    T.Open Connection     127.0.0.1  port=5678  encoding=Latin1  encoding_errors=strict
    T.Write    ${cmd}
    ${telnet_output}=   T.Read Until  OK
    T.Close Connection
    RETURN  ${telnet_output}


Mediatek ADB Reboot
   [Documentation]    :Author: Furkan Tombul
    ...
    ...  :param ue_id:        which UE shall be rebooted.
    ...
    [Arguments]     ${ue_id}=0
    ssh.connect to    ${tl.ues[${ue_id}].ssh_connection_details.addr}
    ...               ${tl.ues[${ue_id}].ssh_connection_details.username}
    ...               ${tl.ues[${ue_id}].ssh_connection_details.password}
    ssh.execute     adb reboot
    sleep   120s


Disable Mediatek UE capability of UL MIMO
   [Documentation]    :Author: Hua Li
    ...    to disable UE capability of UL MIMO
    ...  :param ue_id:        which UE shall be rebooted.
    ...
    [Arguments]     ${ue_id}=0
    ${mace} =  taf.ue.Get Rpc Proxy    UE_${ue_id+1}
    Call Method     ${mace}    send_at_command   AT+EGMC\=1,"nr_force_1tx", 1

Turn on airplane mode
    [Arguments]   ${ue_id}=${0}
    ssh.connect to    ${tl.ues[${ue_id}].ssh_connection_details.addr}
    ...               ${tl.ues[${ue_id}].ssh_connection_details.username}
    ...               ${tl.ues[${ue_id}].ssh_connection_details.password}
    ...               alias=UEPC
    ssh.Send Command    adb shell "su 0 settings put global airplane_mode_on 1"
    ...                 connection=UEPC
    ...                 timeout=5
    sleep    3s
    ssh.send command    adb shell "su 0 am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true"
    ...                 connection=UEPC
    ...                 timeout=5
    sleep    5s
    ${result} =    ssh.read_output    connection=UEPC
    ssh.disconnect   connection=UEPC
    Should contain  ${result}  result=0


Reserve MTK UE For tests
   [Documentation]    :Author: Hua Li
    ...  repeat max 10 times require ue,  perform adb reboot in failure case
    ...  :param ue_id:          which of the 2 UEs in the testline to be reserved for the test, either 0. or 1.
    ...  :param Deployment_Mode: must be set explicitly as SA or NSA
    ...
    [Arguments]     ${ue_id}=${0}    ${Deployment_Mode}=SA
    ${ue_id}=    Convert To Integer    ${ue_id}
    Turn on airplane mode    ${ue_id}
    # robocop: disable=unused-variable
    FOR  ${Retry}  IN RANGE   ${10}
       ${status}    Run Keyword and return status    taf.ue.Require Ue    UE_${ue_id+1}    capabilities=MTK_UE${ue_id+1}
       mtk.Setup    pyro_ip=${tl.ues[${ue_id}].ssh_connection_details.addr}    pyro_port=${tl.ues[${ue_id}].server_port}
       mtk.Create Message Flow Alias    flow_alias=MTK_OTA_MESSAGE${ue_id+1}    message_type=ota_text
       IF  '${status}' == 'False'
            Mediatek ADB reboot  ${ue_id}
       ELSE
            BREAK
       END
    END
    IF   '${status}' == 'False'   Fail   Require UE failing
    taf.ue.Enable Elg Logging      alias=UE_${ue_id+1}
    taf.ue.Change Deployment Mode    UE_${ue_id+1}    ${Deployment_Mode}
    ${mace} =  taf.ue.Get Rpc Proxy    UE_${ue_id+1}
    Call Method     ${mace}    send_at_command     AT+ECNCFG\=1
    Call Method     ${mace}    send_at_command     AT+EDATASIM\=1


Reserve MTK UE For tests with TAF UE Proxy
   [Documentation]    :Author: Hua Li
    ...  repeat max 10 times require ue,  perform adb reboot in failure case
    ...  :param ue_id:          which of the 2 UEs in the testline to be reserved for the test, either 0. or 1.
    ...
    [Arguments]     ${ue_id}=${0}
    ${ue_id}=    Convert To Integer    ${ue_id}
    Turn on airplane mode    ${ue_id}
    # robocop: disable=unused-variable
    FOR  ${Retry}  IN RANGE   ${10}
       ${status}    Run Keyword and return status    taf.ue.Require Ue    UE_${ue_id+1}    capabilities=REAL_MTK_UE${ue_id+1}
       #mtk.Setup    pyro_ip=${tl.ues[${ue_id}].ssh_connection_details.addr}    pyro_port=${tl.ues[${ue_id}].server_port}
       #mtk.Create Message Flow Alias    flow_alias=MTK_OTA_MESSAGE${ue_id+1}    message_type=ota_text
       IF  '${status}' == 'False'
            Mediatek ADB reboot  ${ue_id}
       ELSE
            BREAK
       END
    END
    IF   not ${status}   Fail   Require UE failing


Save MTK ELT Log
   [Documentation]    :Author: Hua Li
    ...   to save ELT log, which is normally requested by MTK support for analyse if any issue happend
    ...  :param ue_id:          which of the 2 UEs in the testline to be reserved for the test, either 0. or 1.
    ...  :param file_name:      given file name
    [Arguments]     ${ue_id}=0      ${file_name}=mtk
    ${UE}=   evaluate   ${ue_id} + 1
    ${mtk_rpc_proxy} =    taf.ue.get_rpc_proxy    alias=UE_${UE}
    Call Method    ${mtk_rpc_proxy}    save_elg_log    logs/${file_name}.elg

Expect UE OTA Messages
    [Arguments]     ${expected_message}    ${UE}=1
    ${Expected Messages} =    Create List     ${expected_message}
    mtk.Expect Messages in Flow  awaited_messages=${Expected Messages}  flow_alias=MTK_OTA_MESSAGE${UE}  timeout=${60}
