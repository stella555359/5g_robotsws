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
Library     ./py_res_CNI107623.py
Library     ./modify_para.py

*** Keywords ***
Connect to GNB
    [Arguments]     ${alias}=ASIK Master
    csn.Connect to    ${tl.gnbs[0].dus[0].f1_m_ip_addr.v4}
    ...               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}

Connect to ENB
    [Arguments]    ${alias}=ASIK Master
    csn.Connect to    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    ...               ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
    ...               ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}

Start wireshark capture from gNB or Enb
    [Documentation]    Description: Start X2 log capture on gNB or Enb
    [Arguments]     ${filename}    ${if_gnb}=${True}    ${interface}=any    ${alias}=ASIK Master
    Run keyword if    ${if_gnb}     Connect to GNB    alias=${alias}
    ...    ELSE    Connect to ENB    alias=${alias}
    ${log_name}    Set variable    ${filename}.pcap
    ${log_full_path_gnb}    join path    /tmp    ${log_name}
    csn.send command    command=ps -ef |grep tcpdump |grep -v grep |grep ${interface} |awk '{print $2}' |xargs kill -2    connection=${alias}
    sleep    2s
#    csn.send command    command=nohup tcpdump sctp -i ${interface} -w ${log_full_path_gnb}     connection=${alias}
    csn.send command    nohup tcpdump -i ${interface} -w ${log_full_path_gnb} &>/dev/null &    connection=${alias}
    sleep    2s
    Trace capturing process should be triggered    log_prefix=${log_name}    connection_alias=${alias}
    [Return]    ${alias}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

Stop wireshark capture from gNB or Enb
    [Documentation]    Description: Stop X2 log capture on gNB or Enb, and download x2 log to testpc
    [Arguments]     ${filename}    ${logpath}=${OUTPUT_DIR}    ${alias}=ASIK Master    ${if_gnb}=${True}
    Run keyword if    ${if_gnb}    Connect to GNB    alias=${alias}
    ...    ELSE    Connect to ENB    alias=${alias}
    Stop trace capturing    log_prefix=${filename}    connection_alias=${alias}
    ${log_full_path_ute}    set variable     ${logpath}/${filename}.pcap
    csn.download_file   remote_path=/tmp/${filename}.pcap   local_path=${log_full_path_ute}   connection=${alias}
    csn.execute    command=rm /tmp/${filename}.pcap    connection=${alias}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

Stop trace capturing
    [Documentation]    Author: Liu Zheng
    ...                Stop trace process.
    ...    2020/04/23 Cui Lingxue: add retry logic
    [Arguments]        ${log_prefix}    ${connection_alias}=ASIK Slave    ${retry_time}=10
    FOR    ${i}    IN RANGE    ${retry_time}
        csn.execute    ps -ef | grep tcpdump | grep -v grep | grep ${log_prefix} | awk '{print $2}' | xargs kill -2
        ...    connection=${connection_alias}
        ${is_trace_capture_stopped}    run keyword and return status    wait until keyword succeeds    5s    200ms
        ...    Trace capturing process should be stopped    log_prefix=${log_prefix}    connection_alias=${connection_alias}
        exit for loop if    ${is_trace_capture_stopped}==${True}
    END
    should be true    ${is_trace_capture_stopped}

Trace capturing process should be stopped
    [Documentation]    Author: Cui Lingxue
    ...    check if tcpdump process is stopped.
    [Arguments]         ${log_prefix}    ${connection_alias}=ASIK Slave
    ${is_process_exist}    Is trace capturing process exist    log_prefix=${log_prefix}    connection_alias=${connection_alias}
    should be true    ${is_process_exist}==${False}

Trace capturing process should be triggered
    [Documentation]    Author: Liu Zheng
    ...                Make sure tcpdump process should be triggered.
    ...                There is tcpdump process after start the tcpdump process,
    ...                but when to stop the process, the tcpdump process disappeared in rare cases.
    ...                So to make sure the process is really trigged, there are default three check times to make sure tcpdump process exist.
    [Arguments]         ${log_prefix}    ${connection_alias}=ASIK Slave    ${check_times}=${3}    ${sleep_interval}=1 sec
    FOR    ${check_time}    IN RANGE    ${check_times}
        ${is_process_exist}    Is trace capturing process exist    log_prefix=${log_prefix}    connection_alias=${connection_alias}
        exit for loop if    ${is_process_exist}
        Sleep    ${sleep_interval}
    END
    Should be equal as strings    ${is_process_exist}    True

Is trace capturing process exist
    [Documentation]    Author: Liu Zheng
    ...                Check if the tcpdump process is triggered .
    [Arguments]         ${log_prefix}    ${connection_alias}=ASIK Slave
    ${check_process}    csn.Execute    ps -ef | grep tcpdump | grep -v grep | grep ${log_prefix}
    ...                  connection=${connection_alias}
    ${check_process}    Strip string    ${check_process}
    ${output_len}    Get length    ${check_process}
    ${is_process_exist}    set variable if    ${output_len}!=0    ${True}    ${False}
    [Return]    ${is_process_exist}

Check Wireshark Log for CNI_107623
    [Arguments]      ${txt_filename}    ${case_type}=b1_fr2    ${log_path}=${OUTPUT_DIR}
    ${if_4193}    run keyword and return status    should contain    ${case_type}    b1
    ${if_FR2}    run keyword and return status    should contain    ${case_type}    fr2
    ${if_FR1}    run keyword and return status    should contain    ${case_type}    fr1
    ${checked_para}    set variable if    ${if_FR1}    ${attached_pci_100}
    ...    ${if_FR2}    ${attached_pci_4}    ${EMPTY}
    Check wireshark log Parameter    sgnb_chg_ho_message=${nrRestrictionInEPS}    txt_filename=${txt_filename}
    Run keyword if    '${case_type}'!='none'    Check wireshark log Parameter
    ...    sgnb_chg_ho_message=${checked_para}    txt_filename=${txt_filename}
    ${check_result}    Run keyword if    '${case_type}'=='none'    Check Wireshark Message Flow From Txt
    ...    message_dict=${only_attach_lte}    txt_file_path=${logpath}/${txt_filename}
    ...    ELSE    py_res_CNI107623.checkBandResrictionfr1Andfr2    txt_filename=${log_path}/${txt_filename}
    should be True    ${check_result}
    ${check_result2}    Run keyword if    ${if_4193}    py_res_CNI107623.checkb1report    txt_filename=${log_path}/${txt_filename}
    Run keyword if    ${if_4193}    should be true    ${check_result2}

Convert pcap to text
    [Arguments]    ${pacp_filename}   ${txt_filename}    ${filter}    ${logpath}=${OUTPUT_DIR}
    ${source}      set variable     ${logpath}/${pacp_filename}
    ${target}      set variable     ${logpath}/${txt_filename}
    ${cmd}    Catenate    nice tshark -V -r ${source} -T text > ${target} -Y '${filter}'
    OperatingSystem.Run    ${cmd}

Check wireshark log Parameter HO NOK
    [Arguments]     ${txt_filename}     ${sgnb_chg_ho_message}      ${logpath}=${OUTPUT_DIR}
    ${val_result}    py_res_CNI107623.Check_Wireshark_Parameter_From_Txt    txt_file_path=${logpath}/${txt_filename}
    ...    parameters=${sgnb_chg_ho_message}
    @{val_list}     set variable    ${val_result}[resultList]
    FOR    ${val1}    IN    @{val_list}
        Run Keyword And Continue On Failure    should be equal    ${val1}    ${False}
    END

Check wireshark log Parameter
    [Arguments]     ${txt_filename}     ${sgnb_chg_ho_message}      ${logpath}=${OUTPUT_DIR}
    ${val_result}    py_res_CNI107623.Check_Wireshark_Parameter_From_Txt    txt_file_path=${logpath}/${txt_filename}
    ...    parameters=${sgnb_chg_ho_message}
    @{val_list}     set variable    ${val_result}[resultList]
    FOR    ${val1}    IN    @{val_list}
        Run Keyword And Continue On Failure    should be equal    ${val1}    ${True}
    END

Check Wireshark Message Flow From Txt File
    [Arguments]     ${message_dict}    ${txt_file_path}
    py_res_CNI107623.Check_Wireshark_Message_Flow_From_Txt    txt_file_path=${txt_file_path}    message_dict=${message_dict}


