# @Time    : 2021/10/25 16:36
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : wireshark.robot
# @Software: PyCharm
# @Doc     : Wireshark Common Keywords
*** Settings ***
Library     taf.transport.ssh    WITH NAME    csn
Library    taf.analyzer.pcap    WITH NAME   cap

*** Keywords ***
Connect To BTS
    [Arguments]    ${connection}=enb
    csn.connect To    hostname=${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection}

Start Capture Wireshark Log On BTS
    [Arguments]    ${file_name}    ${connection}=enb    ${interface}=any    ${remote_path}=/tmp
    Stop Capture Wireshark Log On BTS    ${connection}
    csn.send command    command=tcpdump -i ${interface} sctp -w ${remote_path}/${file_name}    connection=${connection}

Start Capture Wireshark Log On Control PC
    [Arguments]    ${file_name}    ${ue_index}=0    ${remote_path}=C:/temp
    #Stop Capture Wireshark Log On Control PC    ${ue_index}
    run keyword and ignore error    Connect to control pc enhanced    ${ue_index}
    csn.send command    command=cd C:/Progra~1/wireshark && ./dumpcap.exe -i 2 -w ${remote_path}/${file_name}
    ...     connection=cpc_${ue_index}

Stop Capture Wireshark Log On BTS
    [Arguments]    ${connection}
    Run Keyword And Ignore Error    Connect To BTS     connection=${connection}
    csn.send command    command=killall tcpdump     connection=${connection}

Stop Capture Wireshark Log On Control PC
    [Arguments]  ${ue_index}=0
    run keyword and ignore error    Connect to control pc enhanced    ${ue_index}
    csn.send command    command=taskkill /F /IM dumpcap.exe    connection=cpc_${ue_index}

Collect Wireshark Log On BTS
    [Arguments]    ${file_name}    ${connection}=enb    ${remote_path}=/tmp
    Stop Capture Wireshark Log On BTS    ${connection}
    csn.download_file    remote_path=${remote_path}/${file_name}
    ...     local_path=${CASE_LOG_PATH}/${file_name}    connection=${connection}
    csn.send_command    command=rm -rf ${remote_path}/${file_name}    connection=${connection}

Collect Wireshark Log On Control PC
    [Arguments]    ${file_name}    ${ue_index}=0    ${remote_path}=C:/temp
    Stop Capture Wireshark Log On Control PC    ${ue_index}
    csn.download_file    remote_path=${remote_path}/${file_name}
    ...     local_path=${CASE_LOG_PATH}/${file_name}    connection=cpc_${ue_index}
    csn.send_command    command=rm -rf ${remote_path}/${file_name}    connection=cpc_${ue_index}

Verify UE Attach By Wireshark Log
    [Arguments]    ${file_name}
    cap.read_cap    cap_file=${CASE_LOG_PATH}/${file_name}    display_filter=s1ap
    ${expression}    Catenate    SEPARATOR= and${SPACE}  s1ap.procedureCode == 9
    ...     ip.dst == ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    cap.Check Expression    ${expression}
    ${expression}    Catenate    SEPARATOR= and${SPACE}  s1ap.procedureCode == 12
    ...     ip.src == ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    cap.Check Expression    ${expression}

Verify UE Idle By Wireshark Log
    [Arguments]    ${file_name}
    cap.read_cap    cap_file=${CASE_LOG_PATH}/${file_name}    display_filter=s1ap
    ${expression}    Catenate    SEPARATOR= and${SPACE}  s1ap.procedureCode == 18
    ...     ip.src == ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    cap.Check Expression    ${expression}
    ${expression}    Catenate    SEPARATOR= and${SPACE}  s1ap.procedureCode == 23
    ...     ip.dst == ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    cap.Check Expression    ${expression}
    ${expression}    Catenate    SEPARATOR= and${SPACE}  s1ap.procedureCode == 23
    ...     ip.src == ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    cap.Check Expression    ${expression}

Verify S1 Link Established
    [Arguments]    ${file_name}
    cap.read_cap    cap_file=${CASE_LOG_PATH}/${file_name}    display_filter=s1ap
    ${expression}    Catenate    SEPARATOR= and${SPACE}  s1ap.procedureCode == 17
    ...     ip.dst == ${MME1_IP}
    cap.Check Expression    ${expression}
    ${expression}    Catenate    SEPARATOR= and${SPACE}  s1ap.procedureCode == 17
    ...     ip.src == ${MME2_IP}
    cap.Check Expression    ${expression}