*** Settings ***
Documentation
...    The keywords are for log check
...    Used for get cell throughput in gnb based on aasys log, include ul/dl average/peak/minimum throughput, one cell or multi-cells.
...    Contact: yixiang.x.wang@nokia-sbell.com, shengrong.rao@nokia-sbell.com

Library    taf.analyzer.pcap           WITH NAME    cap
Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Resource    ./aasyslog.robot
Resource    ../robot/BIP_trace/BIP_trace_collector.robot
Resource    ./container_log_capturing.robot

*** Variables ***
${TSHARK_PATH}    /usr/bin/tshark
${FILTER}    dldata_pdschsendreq||dldata_pdcchsendreq||uldata_puschreceivereq||uldata_pucchreceiverespharqd
${TSHARK_BIP_CMD}    {tshark_path} -r {input_file} -X lua_script:{luashark_path} -Y  \"${FILTER}\" -T pdml > {output_file}
${TSHARK_BIP_ulmcs}    ${TSHARK_BIP_COMMON} -T fields -e UlData_PuschReceiveReq.grants_item_15.mcs > {output_file}
${TSHARK_BIP_dlmcs}    ${TSHARK_BIP_COMMON} -T fields -e DlData_PdschSendReq.PdschSendReq.mcs > {output_file}
${TSHARK_BIP_bler}    ${TSHARK_BIP_COMMON} -T fields -e UlData_PucchReceiveRespHarqD.ackNack.ackNack > {output_file}
${TSHARK_BIP_beamid}    ${TSHARK_BIP_COMMON} -T fields -e DlData_PdcchSendReq.PdcchSendReq.beamId > {output_file}
${TSHARK_CPIF_CMD}    {tshark_path} -r {input_file} -X lua_script:{luashark_path} -Y \"nr-rrc\"  -T pdml > {output_file}
${XPATH_CPIF}     .//nr-rrc.measResultServingCell_element/nr-rrc.measResult_element/nr-rrc.cellResults_element/nr-rrc.resultsSSB_Cell_element
${TSHARK_BIP_COMMON}    {tshark_path} -r {input_file} -X lua_script:{luashark_path} -Y  \"${FILTER}\"
${TSHARK_BIP_dlmcs_ulmcs_beamid_bler}    ${TSHARK_BIP_COMMON} -T fields -e DlData_PdschSendReq.PdschSendReq.mcs
...    -e UlData_PuschReceiveReq.grants_item_15.mcs -e DlData_PdcchSendReq.PdcchSendReq.beamId
...    -e UlData_PucchReceiveRespHarqD.ackNack.ackNack > {output_file}

*** Keywords ***
Convert Pcap to pdml format
    [Documentation]    author:yixiang.x.wang@nokia-sbell.com
    ...    Description: convert to pcap file to pdml format, pdml can be used for value check.
    [Arguments]    ${file_path}    ${command_template}=${TSHARK_BIP_CMD}
    ...    ${luashark_path}=/opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
    ${pdml_packets}=    cap.load_pcap_file    pcap_file=${file_path}  tshark_path=${TSHARK_PATH}
    ...    luashark_path=${luashark_path}
    ...    command_template=${command_template}
    [Return]    ${pdml_packets}

Get value from output pdml files
    [Documentation]    author:shengrong.rao@nokia-sbell.com
    ...    Description: this keyword is used for get bip vaule with -T fields -e, and retrun vaule list.
    ...    please use "Convert Pcap to pdml format" first.should be .pdml format.
    ...    :param hostname: test pc host ip.
    ...    :param username: test pc username.
    ...    :param password: test pc password.
    ...    :param command_template: use tshark -T fields -e "" to get value directly.
    [Arguments]    ${file_path}    ${command_template}=${TSHARK_BIP_dlmcs}    ${command_to_convert_pdml}=${TSHARK_BIP_dlmcs}
    ...    ${luashark_path}=/opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
    ...    ${hostname}=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ${username}=${tl.test_pc.default_ssh_connection_details.username}
    ...    ${password}=${tl.test_pc.default_ssh_connection_details.password}
    ${pdml_file}    Catenate    SEPARATOR=    ${file_path.split(".pcap")[0]}    .pdml
    cap.load_pcap_file    command_template=${command_template}    pcap_file=${file_path}    luashark_path=${luashark_path}
    ...    tshark_path=${TSHARK_PATH}
    csn.Connect To     hostname=${hostname}    username=${username}    password=${password}    alias=ute
    csn.execute    command=${command_to_convert_pdml} > ${pdml_file}    connection=ute
    ${output_value}    csn.execute    command=cat ${pdml_file} |awk '/./ {print}'    connection=ute
    ${output_value}    Split To Lines    ${output_value}
    [Teardown]    Run Keyword And Ignore Error    Remove File    ${pdml_file}
    [Return]    ${output_value}

Get ul dl mcs beamid bler value from output pdml files
    [Documentation]    author:shengrong.rao@nokia-sbell.com
    ...    Description: this keyword is used for ota cases to check ul dl mcs, beam id and bler together with fields -e
    ...    to save time during long time call. please use "Convert Pcap to pdml format" first. file_path should be .pdml format.
    ...    :param hostname: test pc host ip.
    ...    :param username: test pc username.
    ...    :param password: test pc password.
    ...    :param command_template: use tshark -T fields -e "" to get value directly.
    [Arguments]    ${file_path}    ${luashark_path}=/opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
    ...    ${command_template}=${TSHARK_BIP_dlmcs_ulmcs_beamid_bler}
    ...    ${hostname}=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ${username}=${tl.test_pc.default_ssh_connection_details.username}
    ...    ${password}=${tl.test_pc.default_ssh_connection_details.password}
    ${pdml_file}    Catenate    SEPARATOR=    ${file_path.split(".pcap")[0]}    .pdml
    ${pdml_packets}    Convert Pcap to pdml format    command_template=${command_template}    file_path=${file_path}
    ...    luashark_path=${luashark_path}
    csn.Connect To     hostname=${hostname}    username=${username}    password=${password}    alias=ute
    ${output1}    csn.execute    command=cat ${pdml_file} | grep ^"0x"    connection=ute
    ${output2}    csn.execute    command=cat ${pdml_file} | grep ^$'\t'"0x"    connection=ute
    ${output3}    csn.execute    command=cat ${pdml_file} | grep ^$'\t'$'\t'"0x"    connection=ute
    ${output4}    csn.execute    command=cat ${pdml_file} | grep ^$'\t'$'\t'$'\t'"[A-Za-z1-9]"    connection=ute
    @{lines}    Split To Lines    ${output1}
    ${length}=    get length     ${lines}
    ${lines}    Evaluate    map(lambda x: int(x, 16), ${lines})
    ${ave_dlmcs}    Evaluate    round(round(sum(${lines}), 1)/round(${length}, 1), 1)
    @{lines}    Split To Lines    ${output2}
    ${length}=    get length     ${lines}
    ${lines}    Evaluate    map(lambda x: int(x, 16), ${lines})
    ${ave_ulmcs}    Evaluate    round(round(sum(${lines}), 1)/round(${length}, 1), 1)
    @{lines}    Split To Lines    ${output3}
    ${length}=    get length     ${lines}
    ${lines}    Evaluate    map(lambda x: int(x, 16), ${lines})
    ${ave_beam}    Evaluate    round(round(sum(${lines}), 1)/round(${length}, 1), 1)
    @{lines}    Split To Lines    ${output4}
    ${length}=    get length     ${lines}
    ${bler_handle}    set variable
    ...    round(float((bin(int(x.lstrip('\\t'),16))[2:]).rstrip('0').count('0'))/len((bin(int(x.lstrip('\\t'),16))[2:]).rstrip('0')),4)
    ${lines}    Evaluate    map(lambda x: ${bler_handle}, ${lines})
    ${ave_bler}    Evaluate    round(round(sum(${lines}), 4)/round(${length}, 1), 4)
    [Teardown]    Run Keyword And Ignore Error    Remove File    ${pdml_file}
    [Return]    ${ave_dlmcs}    ${ave_ulmcs}    ${ave_beam}    ${ave_bler}

Get UL MCS from BIP log
    [Documentation]    author:yixiang.x.wang@nokia-sbell.com
    ...    Description: get mcs values in bip log for single UE
    [Arguments]    ${pdml_packets}
    @{mcs_list}    Create list
    ${mcs_value}     cap.get_field_value_by_xpath
    ...      xpath=.//UlData_PuschReceiveReq.grants_item_15.mcs
    ...     attribute_name=value
    FOR    ${value}    IN    @{mcs_value}
        ${tmp}    Convert To Integer    ${value}    16
        Append to list    ${mcs_list}    ${tmp}
    END
    [Return]    ${mcs_list}

Get DL MCS from BIP log
    [Documentation]    author:yixiang.x.wang@nokia-sbell.com
    ...    Description: get mcs values in bip log for single UE
    [Arguments]    ${pdml_packets}
    @{mcs_list}    Create list
    ${mcs_value}     cap.get_field_value_by_xpath
    ...      xpath=.//DlData_PdschSendReq.PdschSendReq.mcs
    ...     attribute_name=value
    FOR    ${value}    IN    @{mcs_value}
        ${tmp}    Convert To Integer    ${value}    16
        Append to list    ${mcs_list}    ${tmp}
    END
    [Return]    ${mcs_list}

Get Average DL MCS from BIP log
    [Documentation]    author:yixiang.x.wang@nokia-sbell.com
    ...    Description: get average DL mcs values in bip log for single UE
    ...    example:
    ...        ${pdml_packets}    Convert Pcap to pdml format    file_path=/opt/ute/results/bip.pcap
    ...                 command_template=${TSHARK_BIP_CMD}
    ...        ${dl_avg_mcs}    Get Average DL MCS from BIP log    pdml_packets=${pdml_packets}
    [Arguments]    ${pdml_packets}
    ${mcs_list}    Get DL MCS from BIP log    pdml_packets=${pdml_packets}
    ${sum_mcs}    set variable    0
    ${count}    get length    ${mcs_list}
    FOR    ${value}    IN    @{mcs_list}
        ${tmp}    Convert To Integer    ${value}
        ${sum_mcs}    Evaluate    ${sum_mcs} + ${value}
    END
    ${average_mcs}    Evaluate    ${sum_mcs}.0/${count}.0
    ${average_mcs}    Evaluate	round(${average_mcs}, 1)
    [Return]    ${average_mcs}

Get Average UL MCS from BIP log
    [Documentation]    author:yixiang.x.wang@nokia-sbell.com
    ...    Description: get average UL mcs values in bip log for single UE
    ...    example:
    ...        ${pdml_packets}    Convert Pcap to pdml format    file_path=/opt/ute/results/bip.pcap
    ...                 command_template=${TSHARK_BIP_CMD}
    ...        ${ul_avg_mcs}    Get Average UL MCS from BIP log    pdml_packets=${pdml_packets}
    [Arguments]    ${pdml_packets}
    ${mcs_list}    Get UL MCS from BIP log    pdml_packets=${pdml_packets}
    ${sum_mcs}    set variable    0
    ${count}    get length    ${mcs_list}
    FOR    ${value}    IN    @{mcs_list}
        ${tmp}    Convert To Integer    ${value}
        ${sum_mcs}    Evaluate    ${sum_mcs} + ${value}
    END
    ${average_mcs}    Evaluate    ${sum_mcs}.0/${count}.0
    ${average_mcs}    Evaluate	round(${average_mcs}, 1)
    [Return]    ${average_mcs}

Get Beam ID from BIP log
    [Documentation]    author:yixiang.x.wang@nokia-sbell.com
    ...    Description: get mcs values in bip log for single UE, filter dldata_pdschsendreq
    ...    example:
    ...        ${pdml_packets}    Convert Pcap to pdml format    file_path=/opt/ute/results/bip.pcap
    ...                 command_template=${TSHARK_BIP_CMD}
    ...        ${beam_id}    Get Beam ID from BIP log    pdml_packets=${pdml_packets}
    [Arguments]    ${pdml_packets}
    @{beam_list}    Create list
    ${beam_value}     cap.get_field_value_by_xpath
    ...      xpath=.//DlData_PdcchSendReq.PdcchSendReq.beamId
    ...     attribute_name=value
    FOR    ${value}    IN    @{beam_value}
        ${tmp}    Convert To Integer    ${value}    16
        Append to list    ${beam_list}    ${tmp}
    END
    ${beam_list}    Remove Duplicates    ${beam_list}
    [Return]    ${beam_list}[0]

Get DL bler from BIP log
    [Documentation]    author:yixiang.x.wang@nokia-sbell.com
    ...    Description:
    ...    UlData_PucchReceiveRespHarqD.ackNack.ackNack show the ack/nack bit
    ...    example:
    ...        ${pdml_packets}    Convert Pcap to pdml format    file_path=/opt/ute/results/bip.pcap
    ...                 command_template=${TSHARK_BIP_CMD}
    ...        ${dl_bler_ratio}    Get DL bler from BIP log    pdml_packets=${pdml_packets}
    [Arguments]    ${pdml_packets}
    ${total_ack_num}    set variable    0
    ${total_nack_num}    set variable    0
    ${ackNack}     cap.get_field_value_by_xpath
    ...      xpath=.//UlData_PucchReceiveRespHarqD.ackNack.ackNack
    ...     attribute_name=value
    FOR    ${value}    IN    @{ackNack}
        ${value}    Strip String    string=${value}    mode=right    characters=0
        ${value_len}    get length    item=${value}
        ${len}    evaluate    ${value_len}*4
        ${bit_map}    Convert To Binary    item=${value}    base=16    length=${len}
        ${bit_map}   Strip String    string=${bit_map}    mode=right    characters=0
        ${bit_map}    Convert To String    item=${bit_map}
        ${ack_num}    Get Count    ${bit_map}    1
        ${nack_num}    Get Count    ${bit_map}    0
        ${total_ack_num}    evaluate     ${total_ack_num}+${ack_num}
        ${total_nack_num}    evaluate     ${total_nack_num}+${nack_num}
    END
    ${bler_ratio}    Evaluate    ${total_nack_num}.0/(${total_ack_num}.0 + ${total_nack_num}.0)
    ${bler_ratio}    Evaluate	round(${bler_ratio}, 3)
    [Return]    ${bler_ratio}

Get rsrp sinr from cpif log
    [Documentation]    author:yixiang.x.wang@nokia-sbell.com
    ...    Description: get rsrp and sinr from cpif log
    ...    example:
    ...       ${pdml_packets}    Convert Pcap to pdml format    file_path=/opt/ute/results/CPIF_900D12_1.pcap
    ...                 command_template=${TSHARK_CPIF_CMD}
    ...       ${rsrp}    ${sinr}    Get rsrp sinr from cpif log    pdml_packets=${pdml_packets}
    [Arguments]    ${pdml_packets}
    ${rsrp_str}     cap.get_field_value_by_xpath
    ...    xpath=${XPATH_CPIF}/nr-rrc.rsrp
    ...    attribute_name=showname
    ${sinr_str}     cap.get_field_value_by_xpath
    ...    xpath=${XPATH_CPIF}/nr-rrc.sinr
    ...    attribute_name=showname
    ${rsrp}    Get Regexp Matches	  ${rsrp_str}[0]    rsrp:(.+?dBm)    1
    ${sinr}    Get Regexp Matches	  ${sinr_str}[0]    sinr:(.+?dB)    1
    [Return]    ${rsrp}    ${sinr}

Get cell numbers in gnb
    [Documentation]    Get cell numbers in gnb.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA.
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${gnb_index}].f1_m_ip_addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    ${connection}=COAM
    admin_cli.connect to     bts_host=${host}
    ...                      username=${username}
    ...                      password=${password}
    ...                      name=${connection}
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
    ${status}    Run Keyword and Return Status    Dictionary Should Contain Key    ${bts_info}    requestMessage
    ${cell_list}   Run Keyword If   ${status}
    ...   Set Variable   ${bts_info['requestMessage']['cells']['nr']}
    ...   ELSE   Set Variable   ${bts_info['cells']['nr']}
    ${cell_numbers}    get length    ${cell_list}
    [Return]    ${cell_numbers}

Get gnb release in rrm
    [Arguments]   ${host}   ${username}   ${password}
    csn.Connect To   ${host}   ${username}   ${password}   alias=release_info
    ${info}   csn.Execute    ls /ffs/run/TargetBD*xml   connection=release_info
    ${release_info}     set variable    ${info.split('_')[4]}
    ${release_is_SBTS}     set variable    ${info.split('_')[1]}
    ${if_common_load}     run keyword and return status    should contain     ${release_is_SBTS}    SBTS
    ${release_info_result}    set variable if    ${if_common_load}    ${release_is_SBTS}      ${release_info}
    set suite variable    ${release_info_result}    ${release_info_result}
    [Return]    ${release_info_result}
    [Teardown]   csn.Disconnect   connection=release_info

Get nrcellid from aasys log
    [Documentation]    Get cell id list from aasys log.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA.
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${log_name}=data_dl.txt
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${release_version}    Get gnb release in rrm    host=${host}    username=${username}    password=${password}
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIK_Master
    csn.Execute    command=sed 's/\\x00//g' -i /tmp/${log_name}    connection=ASIK_Master
    ${aasyslog_cell_id_index}    run keyword if    'SBTS' in '${release_version}' or '${release_version}'=='000400'
    ...    set variable    9    ELSE    set variable    11
    ${cell_id}    csn.Execute
    ...    command=cat /tmp/${log_name} |grep "DataPdu:" |cut -d ':' -f 5|grep "nrCellId"|awk '{print $3}'
    ...    connection=ASIK_Master
    @{cell_id}    Split To Lines    ${cell_id}
    ${cell_id}    Remove Duplicates    ${cell_id}
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master
    [Return]    ${cell_id}

Get traffic data from aasys log
    [Documentation]    Get traffic data from aasys log with dl and ul direction.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA.
    ...                :param cell_id: grep by cell id if needed.
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${cell_id}=${EMPTY}    ${log_name}=data_dl.txt
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${release_version}    Get gnb release in rrm    host=${host}    username=${username}    password=${password}
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIK_Master
    csn.Execute    command=sed 's/\\x00//g' -i /tmp/${log_name}    connection=ASIK_Master
    ${dl_data_index}    run keyword if    'SBTS' in '${release_version}' or '${release_version}'=='000400'
    ...    set variable    11    ELSE    set variable    12
    ${dl_data_location}    run keyword if    '${release_version}'=='000800' or '${release_version}'=='000400'
    ...    set variable    4    ELSE    set variable    1
    ${dl_traffic_data}    csn.Execute
    ...    command=cat /tmp/${log_name} |grep "DataPdu:" |grep "${cell_id}" |awk '{print $${dl_data_index}}'|cut -d '|' -f ${dl_data_location}
    ...    connection=ASIK_Master
    ${dl_traffic_data}     replace string    ${dl_traffic_data}    ]    ${EMPTY}
    ${ul_traffic_data}    csn.Execute    command=cat /tmp/${log_name} |grep "rlcPduBytes" |grep "${cell_id}" |awk '{print $10}'|cut -d '(' -f 2
    ...    connection=ASIK_Master
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master
    [Return]    ${dl_traffic_data}    ${ul_traffic_data}

Get traffic data from aasys log for TRUNK
    [Documentation]    Get traffic data from aasys log with dl and ul direction.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA.
    ...                :param cell_id: grep by cell id if needed.
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${cell_id}=${EMPTY}    ${log_name}=data_dl.txt
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIK_Master
    csn.Execute    command=sed 's/\\x00//g' -i /tmp/${log_name}    connection=ASIK_Master
    ${dl_traffic_data}    csn.Execute    command=cat /tmp/${log_name} |grep "DataPdu:" |grep "${cell_id}" |awk '{print $11}'|cut -d '|' -f 1
    ...    connection=ASIK_Master
    ${ul_traffic_data}    csn.Execute    command=cat /tmp/${log_name} |grep "rlcPduBytes" |grep "${cell_id}" |awk '{print $10}'|cut -d '(' -f 2
    ...    connection=ASIK_Master
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master
    [Return]    ${dl_traffic_data}    ${ul_traffic_data}

Calculate Throughput and retrun result in gnb
    [Documentation]    Calculate Throughput and retrun result.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param data: traffic data from aasys log.
    ...                :param cell_numbers: number of cell in gnb.
    ...                :param cell_numbers: if you want to check one of multi-cells or only one cell deploy in gnb, use default vaule.
    [Arguments]    ${data}=${dl_traffic_data}    ${cell_numbers}=1
    @{lines}    Split To Lines    ${data}
    FOR    ${item}    IN    @{lines}
        ${if_number}    run keyword and return status    should match regexp    ${item}    ^\\d+$
        run keyword if  not ${if_number}     remove values from list    ${lines}     ${item}
    END
    ${count}    get length    ${lines}
    ${mod}    Evaluate    ${count}%${cell_numbers}
    ${lines}    Set Variable    ${lines[:int(${count}-${mod})]}
    ${count}    get length    ${lines}
    ${lines}    Evaluate    list(map(eval, ${lines}))
    ${Throughput}    Create List
    FOR    ${i}    IN RANGE    0    ${count}    ${cell_numbers}
        ${total}    Evaluate    sum(${lines[${i}:${i}+${cell_numbers}]})
        Append To List    ${Throughput}    ${total}
    END
    ${count}    get length    ${Throughput}
    ${max}    Evaluate    max(${Throughput})
    ${min}    Evaluate    min(${Throughput})
    ${total}    Evaluate    sum(${lines})/${count}
    ${average_tp}=    Evaluate    round((${total}*8/1024/1024.0), 3)
    ${minimum_tp}=    Evaluate    round((${min}*8/1024/1024.0), 3)
    ${peak_tp}=    Evaluate    round((${max}*8/1024/1024.0), 3)
    [Return]    ${peak_tp}    ${average_tp}    ${minimum_tp}

AAsys log captrue
    [Documentation]    Aasyslog captrue process in gnb reference aasys log common keyword.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    ...                :param filter: the save log can add filter to what you want
    ...                :param stop_aasys_flag: stop aasys log online or in backgroud, default is true, EG. True/Flase
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${sleep_time}=20s    ${filter}=L2Lo    ${log_name}=data_dl.txt    ${log_ip}=127.0.0.1
    ...    ${timeout}=15m     ${stop_aasys_flag}=${True}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition     gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=${filter}    log_name=${log_name}
	...    log_ip=${log_ip}    timeout=${timeout}
    sleep    ${sleep_time}
    run keyword if    '${stop_aasys_flag}'=='${True}'    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}

Get average dl mcs by cap
    [Documentation]    get average dl mcs by cap.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param filename: captured bip log.
    [Arguments]    ${filename}=asod_bip.pcap0    ${tmp_lua_dir}=opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
    cap.Read Cap      cap_file=${filename}           display_filter=dldata_pdschsendreq      X=lua_script:${tmp_lua_dir}
    ${dlmcs_list}=   cap.Get element value    element_expression=DlData_PdschSendReq.PdschSendReq.mcs
    ${length}=    get length     ${dlmcs_list}
    ${dlmcs_list}    Evaluate    map(lambda x: int(x, 16), ${dlmcs_list})
    ${ave_dl_mcs}    Evaluate    round(round(sum(${dlmcs_list}), 1)/round(${length}, 1), 1)
    [Return]    ${ave_dl_mcs}

Get average ul mcs by cap
    [Documentation]    get average ul mcs by cap.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param filename: captured bip log.
    [Arguments]    ${filename}=asod_bip.pcap0    ${tmp_lua_dir}=opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
    cap.Read Cap      cap_file=${filename}           display_filter=uldata_puschreceivereq      X=lua_script:${tmp_lua_dir}
    ${ulmcs_list}=   cap.Get element value    element_expression=UlData_PuschReceiveReq.grants_item_15.mcs
    ${length}=    get length     ${ulmcs_list}
    ${ulmcs_list}    Evaluate    map(lambda x: int(x, 16), ${ulmcs_list})
    ${ave_ul_mcs}    Evaluate    round(round(sum(${ulmcs_list}), 1)/round(${length}, 1), 1)
    [Return]    ${ave_ul_mcs}

Get beam id by cap
    [Documentation]    get beam id by cap.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param filename: captured bip log.
    [Arguments]    ${filename}=asod_bip.pcap0    ${tmp_lua_dir}=opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
    cap.Read Cap      cap_file=${filename}           display_filter=dldata_pdcchsendreq      X=lua_script:${tmp_lua_dir}
    ${beam_list}=   cap.Get element value    element_expression=DlData_PdcchSendReq.PdcchSendReq.beamId
    ${length}=    get length     ${beam_list}
    should be true    ${length}>0
    ${beam_list}    Remove Duplicates    ${beam_list}
    ${beam_id}    Evaluate    int('${beam_list[0]}', 16)
    [Return]    ${beam_id}

Get ul dl mcs together
    [Documentation]    Get ul dl mcs together, big traffic bip wireshark sometimes maybe damaged,check together to save time.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param filename: captured bip log.
    [Arguments]    ${filename}=/home/ute/shushu/asod_bip_2020_0716_0801_21.pcap0
    ${ave_dl_mcs}    Get average dl mcs by cap    filename=${filename}
    ${ave_ul_mcs}    Get average ul mcs by cap    filename=${filename}
    [Return]    ${ave_dl_mcs}    ${ave_ul_mcs}

Get ul dl mcs and beam id
    [Documentation]    Get ul dl mcs and beam id, if more files exist,${dlmcs_total} and ${ulmcs_total} will be type list.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param log_path: captured bip log path.
    ...                :param sample: big traffic bip check will takes long time, add sample check to save time if needed.
    [Arguments]    ${log_path}=/home/ute/shushu/asod_bip_2020_0716_0801_21.pcap0    ${sample}=1
    ${length}=    get length     ${log_path}
    FOR    ${i}    IN RANGE    0    ${length}
        ${status}    ${beam_id}=    Run Keyword And Ignore Error    Get beam id by cap    filename=${log_path[${i}]}
        run keyword if    "${status}"=="PASS" and "${beam_id}"!="${EMPTY}"    Exit For Loop
    END
    ${dlmcs_total}    Create List
    ${ulmcs_total}    Create List
    FOR    ${i}    IN RANGE    0    ${length}    ${sample}
        ${status}    ${mcs_info}=    Run Keyword And Ignore Error    Get ul dl mcs together    filename=${log_path[${i}]}
        run keyword if    '${status}'=='PASS'    Run Keywords    Append To List    ${dlmcs_total}    ${mcs_info[0]}
        ...    AND    Append To List    ${ulmcs_total}    ${mcs_info[1]}
    END
    [Teardown]    Run Keyword And Ignore Error    Remove big log files    filename=${log_path}
    [Return]    ${dlmcs_total}    ${ulmcs_total}    ${beam_id}

Check pdcchPrecodingOption4x4 and numOfLayers in BIP log
    [Documentation]   Auther: tingting.zhong@nokia-sbell.com
    [Arguments]    ${bip_log}    ${lua_script_path}
    ${filter} =    Catenate    dldata_pdschsendreq||dldata_pdcchsendreq
    Wait until keyword succeeds    1 min     5 s    cap.Read cap
    ...    cap_file=${bip_log}    display_filter=${filter}    X=lua_script:${lua_script_path}
    cap.Check Expression     condition_expression=DlData_PdcchSendReq.dciInfo_item_15.pdcchPrecodingOption4x4 == 2
    cap.Check Expression     condition_expression=DlData_PdschSendReq.grants_item_15.numOfLayers == 0x04
