# @Time    : 2022/1/24 15:56
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : wireshark.robot
# @Software: PyCharm
*** Settings ***
Documentation    Common keywords about wireshark
...    Start To Capture Wireshark Log From DU
...    Stop To Capture Wireshark Log From DU
...    Convert Wireshark Log Pcap To Pdml
...    Check Field Value In Pdml
Library     ../python/pdmlanalyzer.py

*** Keywords ***
Start To Capture Wireshark Log From DU
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Example params
    ...    Require suite level variables - from resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/common_variables.robot
    ...    REMOTE_PCAP_PATH : /tmp/tmp.pcap
    [Arguments]    ${file_size}=100    ${connection}=gnb_du    ${interface}=any    ${stream}=SBTS24R3    ${interface_sec}=any
    csn.Connect To    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection}
    ${is_dual_core}    Check if TL is Dual Core    connection=${connection}
    csn.Send Command    command=killall tcpdump    connection=${connection}
    csn.Send Command    command=killall tcpdump    connection=${connection}
    csn.Send Command    command=rm -rf ${REMOTE_PCAP_PATH}*    connection=${connection}
    csn.Send Command    command=nohup tcpdump -C ${file_size} -i ${interface} -w ${REMOTE_PCAP_PATH} &>/dev/null &    connection=${connection}
    Run Keyword If    ${is_dual_core} and '${stream}'!='SBTS24R3' and '${stream}'!='SBTS24R2'
    ...    Start To Capture Wireshark Log From DU Secondary Core    interface=${interface_sec}    connection=${connection}
    [Teardown]    csn.disconnect    connection=${connection}

Start To Capture Wireshark Log From DU Secondary Core
    [Documentation]    Author: chun.li@nokia-sbell.com
    ...    Start tcpdump in secondary core for dual core test line
    ...    Example params
    ...    Require suite level variables - from resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/common_variables.robot
    ...    REMOTE_PCAP_PATH_SEC : /tmp/tmp_sec.pcap
    [Arguments]    ${file_size}=100    ${connection}=gnb_du    ${connection_secondary}=gnb_du2    ${interface}=any
    csn.Connect To    hostname=fct-4a
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${connection}
    ...               alias=${connection_secondary}
    csn.Send Command    command=killall tcpdump    connection=${connection_secondary}
    csn.Send Command    command=killall tcpdump    connection=${connection_secondary}
    csn.Send Command    command=rm -rf ${REMOTE_PCAP_PATH_SEC}*    connection=${connection_secondary}
    csn.Send Command    command=nohup tcpdump -C ${file_size} -i ${interface} -w ${REMOTE_PCAP_PATH_SEC} &>/dev/null &
    ...    connection=${connection_secondary}
    [Teardown]    csn.disconnect    connection=${connection_secondary}

Stop To Capture Wireshark Log From DU
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Example params
    ...    local_pcap_path : /home/ute/MMW_SG5/{feature}/{case}.pcap
    ...    Require suite level variables - from resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/common_variables.robot
    ...    REMOTE_PCAP_PATH : /tmp/tmp.pcap
    [Arguments]    ${local_pcap_path}    ${connection}=gnb_du    ${stream}=SBTS24R3
    csn.Connect To    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection}
    ${is_dual_core}    Check if TL is Dual Core    connection=${connection}
    csn.Send Command    command=killall tcpdump    connection=${connection}
    csn.Send Command    command=killall tcpdump    connection=${connection}
    ${pcap_files}    csn.Execute    ls /tmp/*.pcap*    connection=${connection}
    ${pcap_files}    Replace String    ${pcap_files}    \t    \r\n
    ${pcap_files}    Replace String    ${pcap_files}    ${SPACE * 2}    \r\n
    ${pcap_files}    Replace String    ${pcap_files}    ${SPACE}    ${EMPTY}
    @{lines}    Split To Lines    ${pcap_files}
    Run    rm -rf /tmp/*.pcap*
    FOR    ${pcap_file}    IN    @{lines}
        csn.Download FILE    remote_path=${pcap_file}    local_path=${pcap_file}    connection=${connection}
    END
    Run Keyword If    ${is_dual_core} and '${stream}'!='SBTS24R3' and '${stream}'!='SBTS24R2'
    ...    Stop To Capture Wireshark Log From DU Secondary Core    connection=${connection}
    Run    mergecap -a /tmp/*.pcap* -w ${local_pcap_path} -F pcapng
    [Teardown]    csn.disconnect    connection=${connection}

Stop To Capture Wireshark Log From DU Secondary Core
    [Documentation]    Author: chun.li@nokia-sbell.com
    ...    Example params
    ...    Require suite level variables - from resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/common_variables.robot
    ...    REMOTE_PCAP_PATH_SEC : /tmp/tmp_sec.pcap
    [Arguments]    ${connection}=gnb_du    ${connection_secondary}=gnb_du2
    csn.Connect To    hostname=fct-4a
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${connection}
    ...               alias=${connection_secondary}
    csn.Send Command    command=killall tcpdump    connection=${connection_secondary}
    csn.Send Command    command=killall tcpdump    connection=${connection_secondary}
    ${pcap_files}    csn.Execute    ls /tmp/*.pcap*    connection=${connection_secondary}
    ${pcap_files}    Replace String    ${pcap_files}    \t    \r\n
    ${pcap_files}    Replace String    ${pcap_files}    ${SPACE * 2}    \r\n
    ${pcap_files}    Replace String    ${pcap_files}    ${SPACE}    ${EMPTY}
    @{lines}    Split To Lines    ${pcap_files}
    FOR    ${pcap_file}    IN    @{lines}
        csn.Download FILE    remote_path=${pcap_file}    local_path=${pcap_file}    connection=${connection_secondary}
    END
    [Teardown]    csn.disconnect    connection=${connection_secondary}

Check if TL is Dual Core
    [Documentation]    Author: chun.li@nokia-sbell.com
    [Arguments]    ${connection}=gnb_du
    ${cpif_output}    csn.Execute    command=cat /ram/NrCellMappingInfo.txt |grep CP-IF |awk '{print $2}'    connection=${connection}
    ${cprt_output}    csn.Execute    command=cat /ram/NrCellMappingInfo.txt |grep CP-RT |awk '{print $2}'    connection=${connection}
    ${cpif_id}    Get Regexp Matches    ${cpif_output}    0x(..)    1
    ${cprt_id}    Get Regexp Matches    ${cprt_output}    0x(..)    1
    ${is_dual_core}    Set Variable If    ${cpif_id}[0]!=${cprt_id}[0]    ${True}    ${False}
    [Return]    ${is_dual_core}

Start To Capture Wireshark Log From ENB
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    REMOTE_PCAP_PATH : /tmp/tmp.pcap from /lines/MMW_SG5/common_variables.robot
    [Arguments]    ${interface}=any    ${connection}=enb
    csn.Connect To    hostname=${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection}
    csn.Send Command    command=rm -rf ${REMOTE_PCAP_PATH}    connection=${connection}
    Run Keyword And Ignore Error    csn.Execute    command=nohup tcpdump -nq -s 0 -i ${interface} -w ${REMOTE_PCAP_PATH}
    ...    timeout=1s    connection=${connection}
    [Teardown]    csn.disconnect    connection=${connection}

Stop To Capture Wireshark Log From ENB
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    local_pcap_path : /home/ute/MMW_SG5/{feature}/{case}.pcap
    ...    REMOTE_PCAP_PATH : /tmp/tmp.pcap from /lines/MMW_SG5/common_variables.robot
    [Arguments]    ${local_pcap_path}    ${connection}=enb
    csn.Connect To    hostname=${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection}
    csn.Send Command    command=killall tcpdump    connection=${connection}
    csn.Download FILE    remote_path=${REMOTE_PCAP_PATH}    local_path=${local_pcap_path}    connection=${connection}
    [Teardown]    csn.disconnect    connection=${connection}

Convert Wireshark Log Pcap To Pdml
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/11/24 10:31
    ...    local_pcap_path : /home/ute/MMW_SG5/{feature}/{case}.pcap
    [Arguments]    ${local_pcap_path}
    ${local_pdml_path}    Replace String    ${local_pcap_path}    .pcap    .pdml
    ${convert_pdcp_to_pdml}    Catenate    tshark -r ${local_pcap_path} -T pdml > ${local_pdml_path}
    OperatingSystem.Run    ${convert_pdcp_to_pdml}
    [Return]    ${local_pdml_path}

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
    ...    Li Chun: 2025/3/6: Add F1AP sctp Fragments in the filter
    [Arguments]    ${pcap_file_path}    ${rrc_file}
    ${rrc}    Catenate    tshark -r ${pcap_file_path} -Y "nr-rrc || sctp.data_payload_proto_id == 62" -w ${rrc_file}
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
    ${true_value}    get_the_special_item_value    file_path=${output_file}
    ...    special_item=${field}
    List Should Contain Value    ${true_value}    ${value}
    [Return]    ${true_value}

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
    ${count}    get_the_special_item_value_count    file_path=${output_file}
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
    ${true_value}    get_the_special_item_value    file_path=${output_file}    special_item=${field}    sort_time=${sort_time}
    [Return]    ${true_value}

Check Info Exist In Wireshark Log
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init define date: 2023/06/16 13:21
    [Arguments]    ${pcap_file_path}    ${infos}    ${output_file}=/home/ute/MMW_SG5/check_wireshark_info_exist.txt
    FOR    ${info}    IN    @{infos}
        ${cmd}    Catenate    tshark -r ${pcap_file_path} -Y '${info}' > ${output_file}
        OperatingSystem.Run    ${cmd}
        File Should Not Be Empty    ${output_file}
    END

Check Special Item Exist Via Wireshark Log
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${pcap_file_path}    ${filter}    ${item}    ${item_value}
    ${curr_date}    Get Current Date    result_format=_%Y%m%d_%H%M%S    exclude_millis=True
    ${output_file}    Replace String    ${pcap_file_path}    .pcap    ${curr_date}.csv
    @{csv_title_list}    Create List    ${item}
    Convert Wireshark Log Pcap To Csv    pcap_file_path=${pcap_file_path}
    ...    output_file=${output_file}    filter=${filter}
    ...    csv_title_list=${csv_title_list}
    Verify Special Item Value Exist    ${output_file}    ${item}    ${item_value}

Check Field Value In Pdml
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Example params
    ...    field_name : nr-rrc.physCellId
    ...    field_value : 50
    ...    local_pdml_path : /home/ute/MMW_SG5/{feature}/{case}.pdml
    [Arguments]    ${field_name}    ${field_value}    ${local_pdml_path}
    ${values}    get_list_of_values    ${local_pdml_path}    ${field_name}
    ${value}    Set Variable    ${values}[-1]
    ${passed}=    Run Keyword And Return Status    Should Be String    ${value}
    Run Keyword If    ${passed}    should be true    '${value}'=='${field_value}'
    ...    ELSE    should be true    '${value[0]}'=='${field_value}'
