*** Settings ***
Documentation    author: rao shengrong
...               contact: shengrong.rao@nokia-sbell.com
...               squad group: 5G_PZ_MMW_HZ_4_SG
...               feature : 5GC0002056



Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/Attenuation.py
Library    taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf
Library    taf.hw.rf_attenuator    WITH NAME    atten
Resource    ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    ../../../../OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    ../../5GC001937_OTA/resources/5GC001937_keywords.robot

*** Variables ***
@{rdflags_in_swconfig_531}    0x580017=1
@{rdflags_in_swconfig_532_TMPI0}    0x580011=0    0x580013=0    0x580012=0    0x580014=0    0x58010D=0
@{rdflags_in_swconfig_532_TMPI1}    0x580011=0    0x580013=0    0x580012=0    0x580014=0    0x58010D=1
@{rdflags_TMPIxxx}    0x580011=0    0x580013=0    0x580012=0    0x580014=0

${TSHARK_Dl_PMI}    -T fields -e DlData_PdschGrant.codebookIndex > {output_file}
${TSHARK_Dl_RANK}    -T fields -e DlData_PdschGrant.numOfLayers > {output_file}
${TSHARK_UL_PMI}    -T fields -e UlData_puschReceiveReqGrant_t.codebookIndex > {output_file}
${TSHARK_Ul_RANK}    -T fields -e UlData_puschReceiveReqGrant_t.numOfLayers > {output_file}
${TSHARK_pmirank1}    -T fields -e UlData_PuschReceiveRespPs.grants_item_15.ulPmiRank1 > {output_file}
${TSHARK_pmirank2}    -T fields -e UlData_PuschReceiveRespPs.grants_item_15.ulPmiRank2 > {output_file}
${TSHARK_pmirank}    -T fields -e UlData_PuschReceiveRespPs.grants_item_15.ulRank > {output_file}
${UCI_PMI}    -T fields -e DlData_PdschGrant.codebookIndex > {output_file}
${dl_mcs}    -T fields -e DlData_PdschGrant.mcs > {output_file}
${ul_mcs}    -T fields -e UlData_puschReceiveReqGrant_t.mcs > {output_file}

${luashark_path}          /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
${tshark_path}            /usr/bin/tshark

#${TSHARK_Dl_PMI}    -T fields -e DlData_PdschSendReq.grants_item_15.codebookIndex > {output_file}
#${TSHARK_Dl_RANK}    -T fields -e DlData_PdschSendReq.grants_item_15.numOfLayers > {output_file}
#${TSHARK_UL_PMI}    -T fields -e UlData_PuschReceiveReq.grants_item_15.codebookIndex > {output_file}
#${TSHARK_Ul_RANK}    -T fields -e UlData_PuschReceiveReq.grants_item_15.numOfLayers > {output_file}
#${TSHARK_pmirank1}    -T fields -e UlData_PuschReceiveRespPs.grants_item_15.ulPmiRank1 > {output_file}
#${TSHARK_pmirank2}    -T fields -e UlData_PuschReceiveRespPs.grants_item_15.ulPmiRank2 > {output_file}
#${TSHARK_pmirank}    -T fields -e UlData_PuschReceiveRespPs.grants_item_15.ulRank > {output_file}
#${UCI_PMI}    -T fields -e UlData_PucchReceiveRespPs.uciBits.uciBits_item_0 > {output_file}
#${dl_mcs}    -T fields -e DlData_PdschSendReq.grants_item_15.mcs > {output_finle}
#${ul_mcs}    -T fields -e UlData_PuschReceiveReq.grants_item_0.mcs > {output_file}

#${TSHARK_Dl_PMI}    -T fields -e _5G_L1_DL_L2_PS_DlData_PdschGrant.codebookIdex > {output_file}
#${TSHARK_Dl_RANK}    -T fields -e _5G_L1_DL_L2_PS_DlData_PdschGrant.numOfLayers > {output_file}
#${TSHARK_UL_PMI}    -T fields -e _5G_L1_UL_L2_PS_UlData_puschReceiveReqGrant_t.codebookIndex > {output_file}
#${TSHARK_Ul_RANK}    -T fields -e _5G_L1_UL_L2_PS_UlData_puschReceiveReqGrant_t.numOfLayers > {output_file}
#${TSHARK_pmirank1}    -T fields -e _5G_L1_UL_L2_PS_UlData_puschReceiveReqGrant_t.ulPmiRank1 > {output_file}
#${TSHARK_pmirank2}    -T fields -e _5G_L1_UL_L2_PS_UlData_puschReceiveReqGrant_t.ulPmiRank2 > {output_file}
#${TSHARK_pmirank}    -T fields -e _5G_L1_UL_L2_PS_UlData_puschReceiveReqGrant_t.ulRank > {output_file}
#${UCI_PMI}    -T fields -e uciBits > {output_file}
#${dl_mcs}    -T fields -e _5G_L1_DL_L2_PS_DlData_PdschGrant.mcs > {output_file}
#${ul_mcs}     -T fields -e _5G_L1_UL_L2_PS_UlData_puschReceiveReqGrant_t.mcs  > {output_file}

*** Keywords ***
Get value from output pdml files new
    [Arguments]  ${input_file}    ${filter1}    ${filter_command}   ${hostname}=10.57.157.245    ${username}=ute    ${password}=iW_K#8.ute%A10h0m0ra
    ${pdml_file}     Catenate    SEPARATOR=    ${input_file.split(".pcap")[0]}    .pdml
    ${command_template}     Catenate
    ...    ${tshark_path} -r ${input_file} -X lua_script:${luashark_path} -Y "${filter1}" ${filter_command} > ${pdml_file}
    ${connection}    csn.Connect to     hostname=${hostname}    username=${username}    password=${password}  alias=TESTPC
    csn.send_command    command=${command_template}    connection=${connection}
    sleep    15s
    ${output_value}    csn.execute    command=cat ${pdml_file} |awk '/./ {print}'    connection=${connection}
    ${output_value}     String.Split To Lines    ${output_value}
    Run Keyword And Ignore Error    Remove File    ${pdml_file}
    [Return]  ${output_value}
    [Teardown]  csn.Disconnect    connection=${connection}

Modify SCFfile and Commissioning
    [Documentation]    used for update scf or modify parameter with scf commission.
    [Arguments]    ${PARAMS_TO_MODIFY_SCF}   ${SBTS_scf_name}=SCF_SBTS00.xml    ${Branch_scf_name}=SCF_11.800_DU.xml    ${connection}=GNB_OAM
    Log To Console    Set Default Scf
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}     connection=GNB_OAM
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${default_scf}    set variable if    ${if_common_load}    ${default_scf_path}${SBTS_scf_name}
    ...    ${default_scf_path}${Branch_scf_name}
    log to console   ${default_scf}
    coam.teardown      connection=${connection}
    ${new_scf_file}    COAM Modify scf file    scf_file_path=${default_scf}    scf_parameters_list=${PARAMS_TO_MODIFY_SCF}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${new_scf_file}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Modify rdflag in swconfig file
    [Documentation]    used for update rd flag in current gnb swconfig.
    [Arguments]    ${params}
    Connect to BB1 master    alias=ASIK
    Download_swConfig_file_from_asik_to_test_pc    localFilePath=${OUTPUT_DIR}/swconfig.txt    asik_alias=ASIK
    Modify_swConfig_file    parametersList=${params}    filePath=${OUTPUT_DIR}/swconfig.txt
    Upload_swConfig_file_to_asik_and_crasign    localFilePath=${OUTPUT_DIR}/swconfig.txt    asik_alias=ASIK
    [Teardown]   Run keyword and ignore error    csn.Disconnect    connection=ASIK

Recover rdflag in swconfig file
    [Documentation]    Recover rdflag in swconfig file
    Connect to BB1 master    alias=ASIK
    restore_swConfig_file_on_asik_and_crasign  asik_alias=ASIK
    [Teardown]   Run keyword and ignore error    csn.Disconnect    connection=ASIK

Common setup for rdflag and scf
    [Arguments]    ${PARAMS_TO_MODIFY_SCF}=${PARAMS_TO_MODIFY_SCF}    ${params}=@{params}
    Modify rdflag in swconfig file    params=${params}
    Modify SCFfile and Commissioning    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_SCF}

Prepare and attach UE
    [Documentation]    used for attach UE.
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${tl.ues[0].capabilities[-1]}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}
    log to console    UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False

UE start traffic
    [Documentation]    used for UE start traffic, ul/dl/both.
    [Arguments]    ${ue_index}=${0}    ${protocol}=udp    ${tp_direction}=both    ${duration}=600    ${iperf_type}=via_command
    ...    ${ul_throughput}=140MKbits/sec    ${dl_throughput}=600MKbits/sec    ${time}=20s    ${ue_type}=${tl.ues[0].capabilities[-1]}
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${ue_index}
    ...    direction=ul    throughput=${ul_throughput}    duration=${duration}    ue_type=${ue_type}
    ...    protocol=${protocol}    ue_mode=NSA
    sleep    1s
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${ue_index}
    ...     direction=dl    throughput=${dl_throughput}    duration=${duration}    ue_type=${ue_type}    protocol=${protocol}    ue_mode=NSA
    sleep    ${time}

UE stop traffic
    [Documentation]    used for UE stop traffic, ul/dl/both.
    [Arguments]    ${ue_index}=${0}    ${tp_direction}=both    ${protocol}=udp
    ...    ${iperf_type}=via_command    ${ue_type}=${tl.ues[0].capabilities[-1]}
    log to console    Stop traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=ul
    ...    ue_index=${ue_index}    ue_type=${ue_type}    ue_mode=NSA
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=dl
    ...     ue_index=${ue_index}    ue_type=${ue_type}    ue_mode=NSA

UE check throughput
    [Arguments]  ${tp_direction}=both    ${exp_ul}=50    ${exp_dl}=220
    log to console    Check throughput
    ${all_tp}    Get ul and dl peak and ave throughput and return result
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...      should be true    ${all_tp[1]}>${exp_dl}
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...     should be true    ${all_tp[4]}>${exp_ul}
    Set Suite Variable    ${all_tp}

UE end to detach
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${tl.ues[0].capabilities[-1]}
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}

Start capatrue 5G21A bip log
    [Documentation]    Start BIP Capture On 5G21A.
    ...                :param intf: interface of current HW which deployed.
    ...                :param slot: the slot of ASIB which you deployed. default should be 1
    ...                :param file_size_mbytes: size of file create, tcpdump -C.
    ...                :param port0: ports of defined in HW, default port is 303
    ...                :param port1: ports of defined in HW, default port is 303
    [Arguments]    ${connection}=ASIB    ${filename}=tcpdumpL2L1_bip.pcap    ${intf}=ethsei10
    ...    ${slot}=5    ${port0}=304    ${port1}=305    ${file_size_mbytes}=200    ${time}=5s    ${filter}=${EMPTY}
    Connect to BB1 master    alias=${connection}
    csn.send command    command=rm /tmp/${filename}    connection=${connection}
    csn.send command    command=sh /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ${intf} -f L1_L2_UL -b "C1B2(2)" -s ${slot} -l eths2 -v ${port0}
    ...    connection=${connection}
    sleep    5s
    csn.send command    command=sh /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ${intf} -f L1_L2_DL -b "C1B2(2)" -s ${slot} -l eths2 -v ${port1}
    ...    connection=${connection}
    sleep    5s
    csn.send command    command=ncp_portmirror -p xgmac97 -r    connection=${connection}
    sleep    2s
    csn.send command    command=ncp_portmirror -d netdriver -p xgmac97    connection=${connection}
    sleep    2s
    csn.execute    command=ps -ef | grep tcpdump | grep -v grep |awk '{print $2}' |xargs kill -9    connection=${connection}
    sleep    2s
    csn.send command    command=tcpdump -i eths2 -C ${file_size_mbytes} -w /tmp/${filename} "${filter}"    connection=${connection}
    sleep    2s
    csn.send command    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'    connection=${connection}
    ${output}    Csn.read_output    connection=${connection}
    Should not be empty    ${output}
    sleep    ${time}
    [Teardown]   Run keyword and ignore error    csn.Disconnect    connection=${connection}

Stop and download 5G21A bip log
    [Arguments]    ${connection}=ASIB    ${filename}=tcpdumpL2L1_bip.pcap
    Connect to BB1 master    alias=${connection}
    csn.send command    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 | awk '{print $2}'| xargs kill -9    connection=${connection}
    ${output}    Csn.read_output    connection=${connection}
    Should be empty    ${output}
    csn.download_file   remote_path=/tmp/${filename}    local_path=${OUTPUT_DIR}/${filename}
    ...     connection=${connection}
    [Teardown]   Run keyword and ignore error    csn.Disconnect    connection=${connection}

#Start capatrue 5G21A bip log
#    [Documentation]    Start BIP Capture On 5G21A.
#    ...                :param intf: interface of current HW which deployed.
#    ...                :param slot: the slot of ASIB which you deployed. default should be 1
#    ...                :param file_size_mbytes: size of file create, tcpdump -C.
#    ...                :param port0: ports of defined in HW, default port is 303
#    ...                :param port1: ports of defined in HW, default port is 303
#    [Arguments]    ${connection}=ASIB    ${filename}=tcpdumpL2L1_bip.pcap    ${intf}=ethsei10
#    ...    ${slot}=5    ${port0}=304    ${port1}=305    ${file_size_mbytes}=200    ${time}=5s    ${filter}=${EMPTY}
#    Connect to BB1 master    alias=${connection}
#    csn.send command    command=rm /user/toor4nsn/${filename}    connection=${connection}
#    csn.send command    command=bsh 1:0 "dbgnac set port 1 loop e t"    connection=${connection}
#    sleep    5s
#    csn.send command    command=bsh 1:0 "dbgnac mirror sport 12 dport 1 e b"    connection=${connection}
#    sleep    5s
#    csn.send command    command=bsh 1:0 "dbgnac mirror sport 16 dport 1 e b"    connection=${connection}
#    sleep    2s
#    csn.send command    command=bsh 1:0 "dbgnac mirror sport 1 dport 20 e b"    connection=${connection}
#    sleep    2s
#    csn.send command    command=bsh 1:0 "ifconfig eth1 up"    connection=${connection}
#    sleep    2s
#    csn.execute    command=bsh 1:0 "ps -ef | grep tcpdump | grep -v grep |awk '{print $2}' |xargs kill -9"    connection=${connection}
#    sleep    2s
#    csn.send command    command=bsh 1:0 "tcpdump -i eth1 -C ${file_size_mbytes} -w /tmp/${filename} "${filter}""    connection=${connection}
#    sleep    2s
#    csn.send command    command=bsh 1:0 "ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'"    connection=${connection}
#    ${output}    Csn.read_output    connection=${connection}
#    Should not be empty    ${output}
#    sleep    ${time}
#    [Teardown]   Run keyword and ignore error    csn.Disconnect    connection=${connection}
#
#Stop and download 5G21A bip log
#    [Arguments]    ${connection}=ASIB    ${filename}=tcpdumpL2L1_bip.pcap
#    Connect to BB1 master    alias=${connection}
#    #csn.send command    command=bsh 1:0 "ps -ef | grep tcpdump | grep -v grep | tail -n 1 | awk '{print $2}'| xargs kill -9"
#    ...     connection=${connection}
#    csn.send command    command=bsh 1:0 "killall tcpdump"    connection=${connection}
#    sleep    2s
#    csn.send command    command=bsh 1:0 "ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'"    connection=${connection}
#    ${output}    Csn.read_output    connection=${connection}
#    Should be empty    ${output}
#    csn.send command    command=bsh 1:0 "mv /tmp/${filename} /ffs/run/config/toor4nsn/"    connection=${connection}
#    ssh.await execution end  connection=${connection}  timeout=20s
#    csn.download_file   remote_path=/ffs/run/config/toor4nsn/${filename}    local_path=${OUTPUT_DIR}/${filename}
#    ...     connection=${connection}
#    [Teardown]   Run keyword and ignore error    csn.Disconnect    connection=${connection}

Get value from bip
    [Arguments]    ${file_path}=${OUTPUT_DIR}/tcpdumpL2L1_bip.pcap    ${fiter1}=${EMPTY}    ${filter_command}=${TSHARK_Dl_PMI}
    ${command}=    catenate    {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y  \"${fiter1}\" ${filter_command}
    ${output_value}    Get value from output pdml files    file_path=${file_path}    command_template=${command}
    [Return]    ${output_value}

Adjust RU attenuation and recovery
    [Arguments]      ${value_1}    ${value_2}    ${time}=5s    ${att_port1}=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
    ...    ${att_port2}=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
    atten.setup_attenuator    attenuator=${tl.attenuator}
    ${org_value_port1}    atten.read_attenuation    port=${att_port1}
    ${org_value_port2}    atten.read_attenuation    port=${att_port2}
    ${value_1}    Evaluate    ${value_1}+${org_value_port1}
    ${value_2}    Evaluate    ${value_2}+${org_value_port2}
    atten.set_attenuation     port=${att_port1}    value=${value_1}
    atten.set_attenuation     port=${att_port2}    value=${value_2}
    ${value_port1}    atten.read_attenuation    port=${att_port1}
    run keyword and continue on failure    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    atten.read_attenuation    port=${att_port2}
    run keyword and continue on failure    should be equal    ${value_port2}    ${value_2}
    sleep    ${time}
    atten.set_attenuation     port=${att_port1}    value=${org_value_port1}
    atten.set_attenuation     port=${att_port2}    value=${org_value_port2}

Wait for counter to be gathered after guard peroid
   [Arguments]  ${interval}
   ${list}=           Create List         00  15  30  45
   ${actualTime}=     Get Current Date    result_format=%M
   ...                                    time_zone=UTC
   ${time_check}    run keyword and return status   List Should Contain Value    ${list}    ${actualTime}
   run keyword if    ${time_check}   Sleep   ${interval} minutes
   PM Wait To Nearest Measurement Period

PM Wait To Nearest Measurement Period
   Log    PM Wait To Nearest Measurement Period    console=yes
   Wait Until Keyword Succeeds                     16 min
   ...                                            1 min
   ...                                             Wait For Right Period
   Sleep                                           60

Wait For Right Period
   ${list}=           Create List         00  15  30  45
   ${actualTime}=     Get Current Date    result_format=%M
   ...                                    time_zone=UTC
   ...                                    increment=8 hours
   ${actualHour}=     Get Current Date    result_format=%H
   ...                                    time_zone=UTC
    ...                                    increment=8 hours
   ${date}=     Get Current Date    result_format=%Y-%m-%d
   ...                                    time_zone=UTC
   ...                                    increment=8 hours
    ${date_nodash}=    Get Current Date    result_format=%Y%m%d
   ...                                    time_zone=UTC
   ${actualEpoch}=    Convert Date	       ${date} ${actualHour}:${actualTime}:00.000	epoch
   List Should Contain Value	           ${list}  ${actualTime}
   Log                                    ${actualTime}
   ${string_epoch}=   Convert To String   ${actualEpoch}
   ${nopoint_epoch}=   fetch from left   ${string_epoch}   .
   ${integer_epoch}=   convert to integer  ${nopoint_epoch}
   ${epoch_minus_interval}=   Evaluate   ${integer_epoch}-15*60
   ${epoch_minus_interval_string}=   Convert To String   ${epoch_minus_interval}
   set test variable    ${epoch_minus_interval_string}

Check PM counter result
    [Arguments]    ${counter_id}    ${counter_object}=NDLSQ
    Connect to gnb coam via ssl
    ${counter_values}=    coam.get pm counters   couter_ids=${counter_id}    connection=GNB_OAM
    ${result}    Get Dictionary Values   ${counter_values['BTS']['CELLS']['NRCELL-1']['${counter_object}']['${counter_id}']}
    [Return]    ${result}
    [Teardown]    COAM Teardown gnb connections