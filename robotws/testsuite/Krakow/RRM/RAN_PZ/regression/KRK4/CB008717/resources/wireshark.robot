*** Settings ***
Documentation
...    Copied from testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/wireshark.robot
...    author/email  : Jian.1.Chen / jian.1.chen@nokia-sbell.com
...    Common keywords about wireshark
...    Start To Capture Wireshark Log From DU
...    Stop To Capture Wireshark Log From DU
...    Convert Wireshark Log Pcap To Pdml
...    Check Field Value In Pdml

Library     String
Library     DateTime
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME    csn
Library     ./csvanalyzer.py

*** Keywords ***
Start To Capture Wireshark Log From DU
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Example params
    ...    Require suite level variables - from resources/common/RAN_PZ_HAZ_34/lines/MMW_SG5/common_variables.robot
    ...    REMOTE_PCAP_PATH : /tmp/tmp.pcap
    [Arguments]    ${file_size}=100    ${connection}=gnb_du    ${interface}=any
    csn.Connect To    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection}
    csn.Send Command    command=killall tcpdump    connection=${connection}
    csn.Send Command    command=killall tcpdump    connection=${connection}
    csn.Send Command    command=rm -rf ${REMOTE_PCAP_PATH}*    connection=${connection}
    csn.Send Command    command=nohup tcpdump -C ${file_size} -i ${interface} -w ${REMOTE_PCAP_PATH} &>/dev/null &    connection=${connection}
    [Teardown]    csn.disconnect    connection=${connection}

Stop To Capture Wireshark Log From DU
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Example params
    ...    local_pcap_path : /home/ute/MMW_SG5/{feature}/{case}.pcap
    ...    Require suite level variables - from resources/common/RAN_PZ_HAZ_34/lines/MMW_SG5/common_variables.robot
    ...    REMOTE_PCAP_PATH : /tmp/tmp.pcap
    [Arguments]    ${local_pcap_path}    ${connection}=gnb_du
    csn.Connect To    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection}
    csn.Send Command    command=killall tcpdump    connection=${connection}
    csn.Send Command    command=killall tcpdump    connection=${connection}
    ${pcap_files}    csn.Execute    ls /tmp/*.pcap*    connection=${connection}
    ${pcap_files}    Replace String    ${pcap_files}    \t    \r\n
    ${pcap_files}    Replace String    ${pcap_files}    ${SPACE * 2}    \r\n
    ${pcap_files}    Replace String    ${pcap_files}    ${SPACE}    ${EMPTY}
    @{lines}    Split To Lines    ${pcap_files}
    Run    rm -rf /tmp/tmp.pcap*
    FOR    ${pcap_file}    IN    @{lines}
        csn.Download FILE    remote_path=${pcap_file}    local_path=${pcap_file}    connection=${connection}
    END
    Run    mergecap -a /tmp/tmp.pcap* -w ${local_pcap_path} -F pcap
    [Teardown]    csn.disconnect    connection=${connection}

Filter Wireshark Log To RRC NGAP F1AP E1AP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/10/31 16:52
    [Arguments]    ${pcap_file_path}    ${rrc_file}    ${ngap_file}    ${f1ap_file}    ${e1ap_file}
    Filter Wireshark Log To RRC    ${pcap_file_path}    ${rrc_file}
    ${ngap}    Catenate    tshark -r ${pcap_file_path} -Y ngap -w ${ngap_file}
    OperatingSystem.Run    ${ngap}
    ${f1ap}    Catenate    tshark -r ${pcap_file_path} -Y f1ap -w ${f1ap_file}
    OperatingSystem.Run    ${f1ap}
    ${e1ap}    Catenate    tshark -r ${pcap_file_path} -Y e1ap -w ${e1ap_file}
    OperatingSystem.Run    ${e1ap}

Filter Wireshark Log To RRC
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/12/12 14:16
    [Arguments]    ${pcap_file_path}    ${rrc_file}
    ${rrc}    Catenate    tshark -r ${pcap_file_path} -Y nr-rrc -w ${rrc_file}
    OperatingSystem.Run    ${rrc}

Convert Wireshark Log Pcap To Csv
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init define date: 2023/05/23 13:32
    ...    pcap_file_path : /home/ute/MMW_SG5/input.pcap
    ...    output_file : /home/ute/MMW_SG5/output.csv
    ...    filter : f1ap.UEContextSetupRequest_element
    ...    csv_title_list : f1ap.GNB_CU_UE_F1AP_ID
    [Arguments]    ${pcap_file_path}    ${output_file}    ${filter}    ${csv_title_list}
    ${csv_title}    Set Variable
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}    Catenate    tshark -r ${pcap_file_path} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Time -e _ws.col.Info
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}

Check Field Value Via Wireshark
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init define date: 2023/06/19 14:52
    [Arguments]    ${pcap_file_path}    ${filter}    ${field}    ${value}
    ${curr_date}    Get Current Date    result_format=_%Y%m%d_%H%M%S    exclude_millis=True
    ${output_file}    Replace String    ${pcap_file_path}    .pcap    ${curr_date}.csv
    ${fields}    Create List    ${field}
    Convert Wireshark Log Pcap To Csv    pcap_file_path=${pcap_file_path}
    ...    output_file=${output_file}
    ...    filter=${filter}
    ...    csv_title_list=${fields}
    ${true_value}    csvanalyzer.get_the_special_item_value    file_path=${output_file}
    ...    special_item=${field}
    List Should Contain Value    ${true_value}    ${value}

Get Field Value Count Via Wireshark
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init define date: 2023/06/19 14:52
    [Arguments]    ${pcap_file_path}    ${filter}    ${field}    ${value}
    ${curr_date}    Get Current Date    result_format=_%Y%m%d_%H%M%S    exclude_millis=True
    ${output_file}    Replace String    ${pcap_file_path}    .pcap    ${curr_date}.csv
    ${fields}    Create List    ${field}
    Convert Wireshark Log Pcap To Csv    pcap_file_path=${pcap_file_path}
    ...    output_file=${output_file}
    ...    filter=${filter}
    ...    csv_title_list=${fields}
    ${count}    csvanalyzer.get_the_special_item_value_count    file_path=${output_file}
    ...    special_item=${field}    special_item_value=${value}
    [Return]    ${count}

Get Field Value Via Wireshark
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init define date: 2023/06/19 14:52
    [Arguments]    ${pcap_file_path}    ${filter}    ${field}    ${sort_time}=False
    ${curr_date}    Get Current Date    result_format=_%Y%m%d_%H%M%S    exclude_millis=True
    ${output_file}    Replace String    ${pcap_file_path}    .pcap    ${curr_date}.csv
    ${fields}    Create List    ${field}
    Convert Wireshark Log Pcap To Csv    pcap_file_path=${pcap_file_path}    output_file=${output_file}
    ...    filter=${filter}    csv_title_list=${fields}
    ${true_value}    csvanalyzer.get_the_special_item_value    file_path=${output_file}    special_item=${field}    sort_time=${sort_time}
    [Return]    ${true_value}

Check Info Exist In Wireshark Log
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init define date: 2023/06/16 13:21
    [Arguments]    ${pcap_file_path}    ${infos}    ${output_file}=/home/ute/MMW_SG5/check_wireshark_info_exist.txt
    FOR    ${info}    IN    @{infos}
        ${cmd}    Catenate    tshark -r ${pcap_file_path} -Y '${info}' > ${output_file}
        OperatingSystem.Run    ${cmd}
        run keyword and continue on failure    File Should Not Be Empty    ${output_file}
    END
