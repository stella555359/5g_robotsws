# @Time    : 2025/1/23 15:09
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB012192_common_keywords.robot
# @Software: PyCharm
# @Doc     : This is common robot keywords template
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: NSB MN RAN RD VRF HAZ3 5
...    Feature CB012192 common keywords
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Library    analysis_l1_ue_log.py

*** Keywords ***
Pioneer Multi UE Require
    [Arguments]    ${host}=${tl.ues[0].ssh_connection_details.addr}    ${port}=30999
    ...    ${ssh_username}=${tl.ues[0].ssh_connection_details.username}
    ...    ${ssh_password}=${tl.ues[0].ssh_connection_details.password}
    ...    ${alias}=pioneer    ${pioneer_log_path}=C:/pioneer_logs    ${log_name}=ta_log
    ...    ${ue_length}=${6}    ${start_log}=True    ${wait_5min}=False
    Set Test Variable    ${UE_LENGTH}    ${ue_length}
    client.setup_service
    ...    host=${host}
    ...    port=${port}
    ...    ssh_username=${ssh_username}
    ...    ssh_password=${ssh_password}
    ...    alias=${alias}
    client.prepare_ues    service=${alias}

    IF    ${wait_5min}==True
        # ensure that the operation is completed with one 5minute interval
        wait_until_next_5_min    extra_sleep_time=10
    END

    IF    ${start_log}==True
        # ensure that the operation is completed with one 5minute interval
        wait_until_next_5_min    extra_sleep_time=10
        Run Keyword And Ignore Error    client.stoplog    service=${alias}
        ${timestamp}    Get Current Date    result_format=%Y%m%d%H%M%S
        Set Test Variable    ${REMOTE_LOG_PATH}    ${pioneer_log_path}/${timestamp}
        Set Test Variable    ${LOCAL_LOG_PATH}    ${TS_CASE_LOG_PATH}/${timestamp}
        Create Directory    ${LOCAL_LOG_PATH}
        client.startlog    logpath=${REMOTE_LOG_PATH}    logname=${log_name}    service=${alias}
    END

    FOR    ${i}    IN RANGE    0    ${UE_LENGTH}
        client.require_ue    imei=${tl.ues[${i}].imei}    service=${alias}    ue_alias=ue${i}
    END

Pioneer Multi UE Start Traffic
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/24 15:16
    [Arguments]    ${appserver}=${tl.ues[0].iperf_details.network_interface_address}
    ...    ${port}=${tl.ues[0].iperf_details.port}    ${protocol}=UDP
    ...    ${testtime}=20    ${bandwidth}=1000    ${buffersize}=1024    ${packetsize}=1400
    FOR    ${i}    IN RANGE    0    ${UE_LENGTH}
        client.startultraffic
        ...    protocol=${protocol}
        ...    address=${appserver}
        ...    port=${port}
        ...    testtime=${testtime}
        ...    bandwidth=${bandwidth}
        ...    buffersize=${buffersize}
        ...    packetsize=${packetsize}
        ...    ue=ue${i}
    END

Pioneer Multi UE Stop Traffic
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/24 15:16
    FOR    ${i}    IN RANGE    0    ${UE_LENGTH}
        client.stopultraffic    ue=ue${i}
    END

Pioneer Multi UE Check Traffic
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/24 15:16
    [Arguments]    ${dl_threshold}=${100}    ${ul_threshold}=${100}
    &{results}    Create Dictionary
    FOR    ${i}    IN RANGE    0    ${UE_LENGTH}
        ${tp_result}    client.getparammac    ue=ue${i}
        Should Be True    ${tp_result["Param"]["MACDL"]}>=${dl_threshold}
        Should Be True    ${tp_result["Param"]["MACUL"]}>=${ul_threshold}
        Set To Dictionary    ${results}    ue${i}=${tp_result["Param"]}
    END
    [Return]    ${results}

Pioneer Multi UE Teardown
    [Arguments]    ${alias}=pioneer    ${wait_time}=30s    ${stop_log}=True
    IF    ${stop_log}==True
        Run Keyword And Ignore Error    client.stoplog    service=${alias}
    END
    client.release_ues    service=${alias}
    Sleep    ${wait_time}
    client.teardown_service    service=${alias}

Export UE DDIB Log to L1 XML
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/21 21:56
    ...    ${REMOTE_LOG_PATH} ${LOCAL_LOG_PATH} is Test Variable define in Pioneer Multi UE Require
    [Arguments]    ${host}=${tl.ues[0].ssh_connection_details.addr}    ${port}=30999
    ...    ${ssh_username}=${tl.ues[0].ssh_connection_details.username}
    ...    ${ssh_password}=${tl.ues[0].ssh_connection_details.password}
    ...    ${alias}=pioneer    ${ssh_alias}=ssh_pioneer
    client.setup_service
    ...    host=${host}
    ...    port=${port}
    ...    ssh_username=${ssh_username}
    ...    ssh_password=${ssh_password}
    ...    alias=${alias}

    csn.Connect To    ${host}    ${ssh_username}    ${ssh_password}    alias=${ssh_alias}
    csn.Send Command    command=ls -l ${REMOTE_LOG_PATH}/*.ddib | awk -F "/" '{print$4}'    connection=${ssh_alias}
    ${ue_log_list}    csn.Read Output    connection=${ssh_alias}
    csn.Disconnect    connection=${ssh_alias}
    @{ue_logs}    Split String    ${ue_log_list}    separator=\n
    @{ue_log_xml_list}    Create List
    FOR    ${ue_log_ddib}    IN    @{ue_logs[:-1]}
        ${ue_log_xml}    Replace String    ${ue_log_ddib}    .ddib    .xml
        client.export_layer1_msg
        ...    exportfilename=${REMOTE_LOG_PATH}/${ue_log_xml}
        ...    logfile=${REMOTE_LOG_PATH}/${ue_log_ddib}
        ...    until_timeout=120
        ...    service=${alias}
        client.download_file    remote_src_file=${REMOTE_LOG_PATH}/${ue_log_xml}
        ...    local_dest_file=${LOCAL_LOG_PATH}/${ue_log_xml}    service=${alias}
        Append To List    ${ue_log_xml_list}    ${LOCAL_LOG_PATH}/${ue_log_xml}
    END
    [Teardown]    client.teardown_service    service=${alias}
    [Return]    ${ue_log_xml_list}

Pioneer Multi UE Attach
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/22 9:57
    [Arguments]    ${uemode}=5G_SA    ${wait_time}=3s
    FOR    ${i}    IN RANGE    0    ${UE_LENGTH}
        client.attach    uemode=${uemode}    ue=ue${i}
    END
    Sleep    ${wait_time}

Pioneer Multi UE Verify Attach
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/26 14:34
    [Arguments]    ${bts_id}    ${pci}    ${wait_time}=3s
    FOR    ${i}    IN RANGE    0    ${UE_LENGTH}
        ${attach_status}    client.get_attach_status    ue=ue${i}
        Should Be True    '${attach_status["Param"]["AttachStatus"]}'=='Attached'
        Should Be True    '${attach_status["Param"]["CellInfoList"][0]["BTSId"]}'=='${bts_id}'
        Should Be True    '${attach_status["Param"]["CellInfoList"][0]["PCI"]}'=='${pci}'
    END
    Sleep    ${wait_time}

Pioneer Multi UE Detach
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/22 10:02
    [Arguments]    ${withpdu}=0    ${wait_time}=3s
    FOR    ${i}    IN RANGE    0    ${UE_LENGTH}
        client.detach    withpdu=${withpdu}    ue=ue${i}
    END
    Sleep    ${wait_time}

Pioneer Multi UE Poweron
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/22 10:03
    [Arguments]    ${wait_time}=3s
    FOR    ${i}    IN RANGE    0    ${UE_LENGTH}
        client.poweron    ue=ue${i}
    END
    Sleep    ${wait_time}

Pioneer Multi UE Poweroff
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/22 10:03
    [Arguments]    ${wait_time}=3s
    FOR    ${i}    IN RANGE    0    ${UE_LENGTH}
        client.poweroff    ue=ue${i}
    END
    Sleep    ${wait_time}

Create Counter IDS From M55306C00001 To M55306C00064
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/23 10:27
    ${counter_ids}    Set Variable    ${EMPTY}
    FOR    ${i}    IN RANGE    1    10
        ${counter_ids}    Set Variable    ${counter_ids}M55306C0000${i},
    END
    FOR    ${i}    IN RANGE    10    65
        ${counter_ids}    Set Variable    ${counter_ids}M55306C000${i},
    END
    ${counter_ids}    Set Variable    ${counter_ids}M55306C03001,M55306C06001
    [Return]    ${counter_ids}

Get Counters Recent Values
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/23 9:51
    [Arguments]    ${counter_ids}    ${nrcell}=NRCELL-0    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${counters}    coam.get_pm_counters    counter_ids=${counter_ids}    connection=${connection}
    ${target_cell_counters}    Set Variable
    ...    ${counters["BTS"]["MRBTS-${MRBTS_ID}"]["NRBTS-${NRBTS_ID}"]["${nrcell}"]["NRACH"]}
    ${time_list}    Get Dictionary Keys    ${target_cell_counters["M55306C06001"]}
    ${latest_time}    Set Variable    ${time_list[-1]}

    # Fix counter already updated， need the previous value (on 2025/06/23 10:49 by jian.1.chen)
    FOR    ${time}    IN    @{time_list[::-1]}
        IF    ${target_cell_counters["M55306C06001"]}[${time}] > 0
            ${latest_time}    Set Variable    ${time}
            BREAK
        END
    END

    ${counter_id_list}    Get Dictionary Keys    ${target_cell_counters}
    &{counter_values}    Create Dictionary    &{EMPTY}
    FOR    ${counter_id}    IN    @{counter_id_list}
        ${counter_value}    Set Variable    ${target_cell_counters["${counter_id}"]["${latest_time}"]}
        Set To Dictionary    ${counter_values}    ${counter_id}=${counter_value}
    END
    [Teardown]    COAM Teardown gnb connections
    [Return]    ${counter_values}

Check KPI NR_5013a Update Normally
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/23 10:49
    [Arguments]    ${counter_values}    ${pass_percent}=1
    ${M55306C06001_value}    Set Variable    ${counter_values["M55306C06001"]}
    Remove From Dictionary    ${counter_values}    M55306C06001    M55306C03001
    ${sum_counter_values}    Set Variable    ${EMPTY}
    FOR    ${counter_id}    IN    @{counter_values}
        ${sum_counter_values}    Evaluate    ${sum_counter_values}+${counter_values["${counter_id}"]}
    END
    IF    ${sum_counter_values}==0
        Log    ${sum_counter_values}
        Log    ${counter_values}
        Fail    KPI NR_5013a Update Abnormally
    ELSE
        ${check_NR_5013a}    Evaluate    ${M55306C06001_value}/${sum_counter_values}>=${pass_percent}
        Should Be True    ${check_NR_5013a}==True
    END

Check SSB Counters Update Normally
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/23 10:49
    ...    keys in counter: M55306C00001~M55306C00006
    ...    keys in log:0~5
    [Arguments]    ${counter_values}    ${log_values}
    Should Be True    ${counter_values["M55306C00001"]}==${log_values["0"]["SUCCESS(0)"]}
    Should Be True    ${counter_values["M55306C00002"]}==${log_values["1"]["SUCCESS(0)"]}
    Should Be True    ${counter_values["M55306C00003"]}==${log_values["2"]["SUCCESS(0)"]}
    Should Be True    ${counter_values["M55306C00004"]}==${log_values["3"]["SUCCESS(0)"]}
    Should Be True    ${counter_values["M55306C00005"]}==${log_values["4"]["SUCCESS(0)"]}
    Should Be True    ${counter_values["M55306C00006"]}==${log_values["5"]["SUCCESS(0)"]}
    ${sum_counter}    Set Variable    0
    FOR    ${i}    IN RANGE    1    7
        ${sum_counter}    Evaluate    ${sum_counter}+${counter_values["M55306C0000${i}"]}
    END
    Should Be True    ${sum_counter}==${counter_values["M55306C06001"]}

Check All attach Are Success in UElog
    [Arguments]    ${attach_result}
    ${beam_ids}=    Get Dictionary Keys    ${attach_result}
    FOR    ${beam_id}    IN    @{beam_ids}
        Continue For Loop If    '${beam_id}' == '255'
        ${beam_data}=    Get From Dictionary    ${attach_result}    ${beam_id}
        ${invalid_keys}=    Evaluate    [key for key in ${beam_data} if key != 'SUCCESS(0)']
        Run Keyword If    ${invalid_keys}    Fail    Beam ${beam_id} contain: ${invalid_keys}
    END

