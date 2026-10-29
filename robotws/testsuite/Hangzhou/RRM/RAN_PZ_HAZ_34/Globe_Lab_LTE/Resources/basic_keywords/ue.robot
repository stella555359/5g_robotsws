# @Time    : 2021/10/25 16:35
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : ue.robot
# @Software: PyCharm
# @Doc     : UE Common Keywords
*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library     SSHLibrary    WITH NAME    robssh
Library     taf.transport.ssh    WITH NAME    csn

*** Keywords ***
UE Attach And Detach
    [Arguments]    ${ue_index}=0
    UE Attach And Verify 4G    ${ue_index}
    [Teardown]    UE UE Detach    ${ue_index}

UE Attach And Verify 4G
    [Arguments]    ${ue_index}=0
    ${ue_type}    translate_power_ue_type_from_testline    ${ue_index}
    power_ue.Prepare UE    ${ue_type}    ${ue_index}
    ${attach_output}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Open UE 4G Data
    Wait Until Keyword Succeeds    1min    10s    Verify 4G Attach by ADB Command    ${ue_index}

UE UE Detach
    [Arguments]    ${ue_index}=0
    ${ue_type}    translate_power_ue_type_from_testline    ${ue_index}
    power_ue.UE Detach    ${ue_type}    ${ue_index}

Get UE Addr
    [Arguments]    ${ue_index}=0
    Connect UE Control PC    ${ue_index}
    ${ue_addr}    robssh.Execute Command
    ...  adb -s ${tl.ues[${ue_index}].serial_number} shell ip route | cut -d " " -f 9
    [Return]    ${ue_addr}
    #[Teardown]    robssh.Close All Connections

Get UE Cell Tac
    [Arguments]    ${ue_index}=0
    Connect UE Control PC    ${ue_index}
    ${mservice_state}    robssh.Execute Command
    ...  adb -s ${tl.ues[${ue_index}].serial_number} shell dumpsys telephony.registry | grep -E mServiceState
    ${cell_tac_list}    Get Regexp Matches    ${mservice_state}    mTac=\\d+
    [Return]    ${cell_tac_list}[0]
    [Teardown]    robssh.Close All Connections

Get UE Cell Signal
    [Arguments]    ${ue_index}=0
    Connect UE Control PC    ${ue_index}
    ${signal_strength}    robssh.Execute Command
    ...  adb -s ${tl.ues[${ue_index}].serial_number} shell dumpsys telephony.registry | grep -E mSignalStrength
    #${cell_tac_list}    Get Regexp Matches    ${mservice_state}    mTac=\\d+
    #[Return]    ${cell_tac_list}[0]
    [Teardown]    robssh.Close All Connections

Check UE Cell Changed
    [Arguments]    ${old_cell_tac}
    ${new_cell_tac}    Get UE Cell Tac
    Should Not Be Equal    ${old_cell_tac}    ${new_cell_tac}

Connect UE Control PC
    [Arguments]    ${ue_index}=0
    Wait Until Keyword Succeeds     1 min    1 s
    ...                             robssh.Open Connection      ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...                             escape_ansi=True            newline=CRLF
    ...                             alias=uepc
    Wait Until Keyword Succeeds     1 min    1 s
    ...                             robssh.Login
    ...                             username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...                             password=${tl.ues[${ue_index}].ssh_connection_details.password}

Disconnect UE Control PC
    robssh.Close All Connections

Open UE 4G Data
    [Arguments]    ${ue_index}=0
    Connect UE Control PC    ${ue_index}
    robssh.Execute Command    adb -s ${tl.ues[${ue_index}].serial_number} shell svc data enable
    [Teardown]    robssh.Close All Connections

Close UE 4G Data
    [Arguments]    ${ue_index}=0
    Connect UE Control PC    ${ue_index}
    robssh.Execute Command    adb -s ${tl.ues[${ue_index}].serial_number} shell svc data disable
    [Teardown]    robssh.Close All Connections

UE Ping Ftp Server
    [Arguments]    ${ftp_server_ip}    ${packet_size}=32    ${ping_times}=10    ${ue_index}=0
    Connect UE Control PC    ${ue_index}
    ${ping_result}    robssh.Execute Command
    ...     adb -s ${tl.ues[${ue_index}].serial_number} shell ping -s ${packet_size} -c ${ping_times} ${ftp_server_ip}
    [Return]    ${ping_result}
    [Teardown]    robssh.Close All Connections

UE Ping In Background
    [Arguments]    ${ftp_server_ip}    ${packet_size}=1000    ${ping_times}=50    ${ue_index}=0
    Connect UE Control PC    ${ue_index}
    robssh.Execute Command    start /b adb -s ${tl.ues[${ue_index}].serial_number}
    ...     shell ping -s ${packet_size} -c ${ping_times} ${ftp_server_ip}
    [Teardown]    robssh.Close All Connections

Verify Ping Result No Packet Loss
    [Arguments]    ${ping_result}
    ${lines}    Get Lines Containing String    ${ping_result}    , 0% packet loss
    Should Not Be Empty    ${lines}
