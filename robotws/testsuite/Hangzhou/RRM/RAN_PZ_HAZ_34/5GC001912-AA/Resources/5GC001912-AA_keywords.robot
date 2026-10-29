*** Settings ***
Documentation
...    author: shenrao
...    contact: shengrong.rao@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    Feature 5GC001912_AA program

Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    ./5GC001937_keywords.robot

*** Variables ***

${UE_TYPE}    qct_dx50
${dltp}    100
${ultp}    20
#${pcapfile}    5GC001912_PCMD.pcap
${luashark_path}    /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
${TSHARK_timeOfUePduRx}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.timeOfUePduRx
${TSHARK_timeOfUePduRx_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.timeOfUePduRx
${TSHARK_timeOfUeSched}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.timeOfUeSched
${TSHARK_timeOfUeSched_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.timeOfUeSched
${TSHARK_timeOfUePduTx}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.timeOfUePduTx
${TSHARK_timeOfUePduTx_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.timeOfUePduTx
${TSHARK_numOfBad1stMacPduTx}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.numOfBad1stMacPduTx
${TSHARK_numOfBad1stMacPduTx_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.numOfBad1stMacPduTx
${TSHARK_numOfBadLastMacPduTx}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.numOfBadLastMacPduTx
${TSHARK_numOfBadLastMacPduTx_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.numOfBadLastMacPduTx
${TSHARK_numOf1stMacPduTx}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.numOf1stMacPduTx
${TSHARK_numOf1stMacPduTx_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.numOf1stMacPduTx
${TSHARK_sumOfRlcPduRxBytes}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.sumOfRlcPduRxBytes
${TSHARK_sumOfRlcPduRxBytes_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.sumOfRlcPduRxBytes
${TSHARK_sumOfRlcPduTxBytes}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.sumOfRlcPduTxBytes
${TSHARK_sumOfRlcPduTxBytes_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.sumOfRlcPduTxBytes
${TSHARK_sumOfWbCqi}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.sumOfWbCqi
${TSHARK_sumOfWbCqi_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.sumOfWbCqi
${TSHARK_numOfWbCqiSamples}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.numOfWbCqiSamples
${TSHARK_numOfWbCqiSamples_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.numOfWbCqiSamples
${TSHARK_5GC001912_COMMON}    /usr/bin/tshark -r {pcap_file} -X lua_script:{luashark_path} -Y  \"nsetapx.TraceMessage\"
${TSHARK_5GC001912_pdml}    /usr/bin/tshark -r ${output_dir}/${pcapfile} -X lua_script:${luashark_path} -Y  \"nsetapx.TraceMessage\"

*** Keywords ***

Common Setup for 5GC001912
    log to console         Common Setup for 5GC001912
    COAM Check GNB_DU cell on air
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False
    Log To Console    \n ### Start Capture wireshark ###
    Start Capture wireshark log for 5GC001912
    Log To Console    \n ###UE Start traffic and check TP ###
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=500M    duration=120s
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput=100M    duration=120s
    ${all_tp}    Get ul and dl peak and ave throughput and return result
    Run keyword and continue on failure    should be true    ${all_tp[1]}>${0}
    Run keyword and continue on failure    should be true    ${all_tp[4]}>${0}
    Log To Console    \n ### Stop Capture wireshark and download ###
    sleep    1m
    Stop Capture wireshark log for 5GC001912
    Download wireshark Log To TestPC
    Log To Console    \n ### Stop traffic ###
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
    [Teardown]   Run Keyword And Ignore Error    Stop Capture wireshark log for 5GC001912

PCMD value check from pdml
    [Arguments]    ${output_value}    ${traffic_direction}=dl
    FOR    ${item}    IN    @{output_value}
        ${dl_data}    Evaluate    ${item.split(",")[0]}
        ${ul_data}    Evaluate    ${item.split(",")[0]}
        run keyword if    "${traffic_direction}"=="dl" and "${dl_data}"!="${EMPTY}"    Exit For Loop
        run keyword if    "${traffic_direction}"=="dl" and "${dl_data}"!="${EMPTY}"    Exit For Loop
    END


Start Capture wireshark log for 5GC001912
    [Documentation]    Start Capture wireshark log for 5GC001912.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA.
    ...                :param file_name: file name

    [Arguments]    ${gnb_index}=0    ${du_index}=0
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    ${file_name}=5GC001912_PCMD.pcap
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIK_Master
    csn.Execute    command=rm -rf /tmp/${file_name}    connection=ASIK_Master
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep |awk '{print $2}' |xargs kill -9    connection=ASIK_Master
    #Should be empty    ${output}
    ${cmd}=    catenate    tcpdump -i fp0 -w /tmp/${file_name} &>/dev/null &
    csn.send command    command=${cmd}    connection=ASIK_Master
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'    connection=ASIK_Master
    Should not be empty    ${output}
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master

Stop Capture wireshark log for 5GC001912
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${connection}=ASIK_Master
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIK_Master
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep |awk '{print $2}'    connection=ASIK_Master
    #Should not be empty    ${output}
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'|xargs kill -9    connection=ASIK_Master
    Should be empty    ${output}
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master

Download wireshark Log To TestPC
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${connection}=ASIK_Master    ${log_path}=${output_dir}
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    ${file_name}=5GC001912_PCMD.pcap
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIK_Master
    csn.Download file    remote_path=/tmp/${file_name}    local_path=${log_path}/${file_name}   connection=ASIK_Master
    csn.execute    command=rm -rf /tmp/${file_name}     connection=ASIK_Master
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master

