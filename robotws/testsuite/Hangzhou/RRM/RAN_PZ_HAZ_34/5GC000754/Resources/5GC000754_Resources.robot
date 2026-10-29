*** Settings ***
Documentation    author: Liu Geng, Lou Shuhui
...               contact: geng.liu@nokia-sbell.com,shuhui.lou@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC000754-A
Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           ssh_pexpect.py
Library           ssh_pexpect.pcf   WITH NAME    PCF
#Variables         ${CFGFILE_ON_GIT}/Delta_SCF.py
#Variables         ${TLDelta_PATH_ON_GIT}TLDelta.py
Library           ../../5GC000638/Resources/coam_close.py


#Variables         ${CFGFILE_PATH}/Delta_SCF.py

*** Variables ***
${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}

#${CFGFILE_PATH}             /home/ute/TAF/cfgfile/5GC000754/
${CFGFILE_ON_GIT}           ${CFGFILE_PATH}5GC000754/
#${TLDelta_PATH_ON_GIT}        /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${GoldenSCF_ON_GIT}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/
${lua_script_path}          /home/ute/TAF/cfgfile/luashark/generated_luashark/luashark.lua

${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}

${ASIK_LMP_IP}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}


${PB_PORT}                  4001

${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

${IMSI}                     ${tl.ues[0].imsi}
${UE_SN}                    ${tl.ues[0].serial_number}

#${APP_server2_IP}                  ${tl.appserver.iperf_details.ssh_connection_details.addr}
#${APP_server2_USERNAME}            ${tl.appserver.iperf_details.ssh_connection_details.username}
#${APP_server2_PASSWORD}            ${tl.appserver.iperf_details.ssh_connection_details.password}

${APP_server1_IP}                  ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${APP_server1_USERNAME}            ${tl.ues[0].iperf_details.ssh_connection_details.username}
${APP_server1_PASSWORD}            ${tl.ues[0].iperf_details.ssh_connection_details.password}

${UL_TP}                    5
${DL_TP}                    10

${MRBTS_ID}                  MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                  NRBTS-${tl.gnbs[0].global_bts_id}

${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

${Control_PC_hostname}      ${tl.ues[0].ssh_connection_details.addr}
${Control_PC_username}      ${tl.ues[0].ssh_connection_details.username}
${Control_PC_password}      ${tl.ues[0].ssh_connection_details.password}

##################define these variable for convenient############################
${ALIAS_ASIK}               asik                                                ##
${ALIAS_ASIK2}              asik2                                               ##
${ALIAS_ASIK_SLAVE}         asik_slave                                          ##
${ALIAS_ABIL}               abil                                                ##
${ALIAS_ABIL_SLAVE}         abil_slave                                          ##
${ALIAS_UTE}                ute                                                 ##
${ALIAS_ENBCTLPC}           ENB_PC                                              ##
${ALIAS_SHP}                SHP                                                 ##
${ALIAS_LONER}              LONER                                               ##
${ALIAS_ASP_1A}             ASP_1A                                              ##
${ALIAS_MTKPC}              MTKPC                                               ##
${ALIAS_PCF}                PCF                                                 ##
${ALIAS_APP_server}         APP_server                                          ##
${ALIAS_APP_server1}        APP_server1                                         ##
${ALIAS_APP_server2}        APP_server2                                         ##
${UE_alias}                 UE_0                                                ##
${ALIAS_5GC}                5gc                                                 ##
########################END of alias Define#######################################

*** Keywords ***
TC.5GC000754_A_03_Add_One_More_QOS_Flow_To_One_Established_PDU_Session_Successful_without_traffic
#    [Setup]    Setup case
    [Tags]    5GC000754_A    CIT_20A    CIT_TRUNK    CIT_20B    CIT_21A
#    [Teardown]  Teardown case
    #gNB.Commission    scf_file=${Original_CFGFILE_754}    timeout=${2400}
    #Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    Process.Add One QoS Flow successful without traffic


TC.5GC000754_A_01_Add_One_More_QOS_Flow_To_One_Established_PDU_Session_Successful
#    [Setup]    Setup case
    [Tags]    5GC000754_A    CRT_20A    CRT_TRUNK    CRT_20B    CDRT_20B    CRT_21A
#    [Teardown]  Teardown case
    #gNB.Commission    scf_file=${Original_CFGFILE_754}    timeout=${2400}
    #Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
#    power_ue.Prepare UE    ue_type=${UE_TYPE}
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    KW.754.Change UE APN    ui_version=${CASE_INPUT_5GC000754['UE_UI_VERSION']}
    ...    apn_name=${CASE_INPUT_5GC000754['APN_754_NAME']}    serial_number=${UE_SN}
    process.start new PCF
    Run Keyword And Continue On Failure    PCF.pcf_connect    ip=${PCF_IP}    username=${PCF_USERNAME}
    ...    password=${PCF_PASSWORD}
    Run Keyword And Continue On Failure    PCF.pcf_start
    gNB.connect
    Wireshark.StartCaptureNGLog    filename=NG_PDU_modify_with_traffic.pcap
    sleep    5s
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    sleep    10s
    ${5Grach_ed}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    power_ue.Verify attach    ue_index=${0}    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    power_ue.Start traffic    ue_type=${UE_TYPE}   multidrb_QoS_dest=${UTE_IP}  direction=ul
    ...    apn_address=${CASE_INPUT_5GC000754['APN_754_ADDR']}    throughput=5MKbits/sec    duration=600
    power_ue.Start traffic    ue_type=${UE_TYPE}   multidrb_QoS_dest=${UTE_IP}  direction=dl
    ...    apn_address=${CASE_INPUT_5GC000754['APN_754_ADDR']}    throughput=10MKbits/sec    duration=600
    sleep  10s
    Run Keyword And Continue On Failure    PCF.pcf_add_one_QoS
    #sleep  10s
    #process.start dl traffic with default DRB    ueip=${ueip}
    #power_ue.Start traffic    ue_type=${UE_TYPE}   multidrb_QoS_dest=${UTE_IP}  direction=ul   apn_address=mdrbnokiacommnc002mcc460gprs
    #...    throughput=5MKbits/sec    duration=120
    sleep    10s
#    Run Keyword And Continue On Failure   process.check throughput
    process.check_Bi_throughput    ue_type=${UE_TYPE}   ultarget_throughput=5    dltarget_throughput=10
    ...    target_avg_percent=0.9    min_percent=0.7    cell_idx=1    ue_index=${0}

    Run Keyword And Continue On Failure   power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul
    ...    apn_address=${CASE_INPUT_5GC000754['APN_754_ADDR']}
    Run Keyword And Continue On Failure   power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl
    ...    apn_address=${CASE_INPUT_5GC000754['APN_754_ADDR']}
    sleep   15s
    #Run Keyword And Continue On Failure   process.kill iperf on APP server  s_ip=${UTE_IP}
    #...    s_usr=${UTE_USERNAME}    s_pwd=${UTE_USERNAME}  connection=${ALIAS_UTE}
    #sleep   10s
    #Run Keyword And Continue On Failure   process.start dl traffic with new added DRB    ueip=${ueip}
    power_ue.Start traffic    ue_type=${UE_TYPE}   multidrb_QoS_dest=${APP_server1_IP}  direction=ul
    ...    apn_address=${CASE_INPUT_5GC000754['APN_754_ADDR']}    throughput=5MKbits/sec    duration=600
    power_ue.Start traffic    ue_type=${UE_TYPE}   multidrb_QoS_dest=${APP_server1_IP}  direction=dl
    ...    apn_address=${CASE_INPUT_5GC000754['APN_754_ADDR']}    throughput=10MKbits/sec    duration=600
    sleep    10s
#    Run Keyword And Continue On Failure   process.check throughput
    process.check_Bi_throughput    ue_type=${UE_TYPE}   ultarget_throughput=5    dltarget_throughput=10
    ...    target_avg_percent=0.9    min_percent=0.7    cell_idx=1    ue_index=${0}

    Run Keyword And Continue On Failure   power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul
    ...    apn_address=${CASE_INPUT_5GC000754['APN_754_ADDR']}
    Run Keyword And Continue On Failure   power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl
    ...    apn_address=${CASE_INPUT_5GC000754['APN_754_ADDR']}
    sleep   15s
    #Run Keyword And Continue On Failure   process.kill iperf on APP server  s_ip=${APP_server1_IP}
    #...   s_usr=${APP_server1_USERNAME}   s_pwd=${APP_server1_PASSWORD}  connection=${ALIAS_APP_server}
    gNB.connect
    Wireshark.StopCaptureNGLog
    Wireshark.DownloadLogToUTE    filename=NG_PDU_modify_with_traffic.pcap
    sleep    5s
    Run Keyword And Continue On Failure   Wireshark.ReadLog    filename=NG_PDU_modify_with_traffic.pcap    filter=ngap.NGAP_PDU == 0
    sleep    5s
    Run Keyword And Continue On Failure   Wireshark.Check PDU session modification command
    Run Keyword And Continue On Failure   Wireshark.ReadLog    filename=NG_PDU_modify_with_traffic.pcap    filter=ngap.NGAP_PDU == 0
    Run Keyword And Continue On Failure   Wireshark.Check PDU session modification complete
    Wireshark.Action.Close

TC.5GC000754_A_10_EC16_handling_of_5QI=2and1_with_EPS_fallback
    [Documentation]
    ...     1)commission SCF:config related parameters of Redirect
    ...     2)start PCF commond
    ...     3)UE attach and establish PDU session
    ...     4)add two QoS flow 5QI2_1
    ...     5)check NGAP log:ngap.NGAP_PDU == 1 && ngap.radioNetwork == 36
#    power_ue.Prepare UE    ue_type=${UE_TYPE}
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    KW.754.Change UE APN    ui_version=${CASE_INPUT_5GC000754['UE_UI_VERSION']}
    ...    apn_name=${CASE_INPUT_5GC000754['APN_754_NAME']}    serial_number=${UE_SN}
    gNB.GenerateCaseSCF    InputFile=${Original_CFGFILE_754}
    ...                    OutputFile=${LOG_PATH}/SCF_754_A10.xml
    ...                    ResourceFolder=${CURDIR}
    ...                    MOsToAdd=MOs_TO_ADD_754_A_10
    ...                  ParamterToModify=PARAMS_TO_MODIFY_754_A_10
    gNB.commission    scf_file=${LOG_PATH}/SCF_754_A10.xml  timeout=${2400}
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    Process.Add Two QoS Flow 5QI2_1 successful without traffic



process.start new PCF
    [Arguments]
    ssh.Connect to    hostname=${PCF_IP}    username=${PCF_USERNAME}    password=${PCF_PASSWORD}    alias=${ALIAS_PCF}
    ssh.send command  ps -ef | grep sim | grep -v grep | grep 5g | awk '{print $2}' | xargs kill -2    connection=${ALIAS_PCF}
    ssh.disconnect    connection=${ALIAS_PCF}

Process.Add One QoS Flow successful without traffic
    KW.754.Change UE APN    ui_version=${UE_UI_VERSION}    apn_name=${APN_754_NAME}    serial_number=${UE_SN}
#    power_ue.Prepare UE    ue_type=${UE_TYPE}
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    #power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=True
    #${Apnresult}    run keyword and return status    Android.SwitchApn    ui_version=Magic UI 3.1.1    apn_name=mdrb754
    #Run Keyword If    '${Apnresult}'=='False'
    #...    Run Keywords    Connect to control pc via cygwin    hostname=${Control_PC_hostname}    ue_index=${0}    AND
    #...    Commercial UE click AIRPLANE once   AND
    #...    Android.SwitchApn    ui_version=Magic UI 3.1.1    apn_name=mdrb754
    #KW.754.Change UE APN    ui_version=${UE_UI_VERSION}    apn_name=${APN_754_NAME}    serial_number=${UE_SN}
    process.start new PCF
    Run Keyword And Continue On Failure    PCF.pcf_connect    ip=${PCF_IP}    username=${PCF_USERNAME}
    ...    password=${PCF_PASSWORD}
    Run Keyword And Continue On Failure    PCF.pcf_start
    gNB.connect
    Wireshark.StartCaptureNGLog    filename=NG_PDU_modify_without_traffic.pcap
    sleep    5s
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    sleep    10s
    ${5Grach_ed}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    power_ue.Verify attach    ue_index=${0}    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    power_ue.Start traffic    ue_type=${UE_TYPE}   multidrb_QoS_dest=${UTE_IP}  direction=ul   apn_address=${CASE_INPUT_5GC000754['APN_754_ADDR']}
    ...    throughput=5MKbits/sec    duration=60
    Run Keyword And Continue On Failure    PCF.pcf_add_one_QoS
    sleep  20s
    power_ue.Stop traffic   ue_type=${UE_TYPE}   ue_index=${0}    apn_address=${CASE_INPUT_5GC000754['APN_754_ADDR']}    direction=ul
    gNB.connect
    Wireshark.StopCaptureNGLog
    Wireshark.DownloadLogToUTE    filename=NG_PDU_modify_without_traffic.pcap
    sleep    5s
    Wireshark.ReadLog    filename=NG_PDU_modify_without_traffic.pcap    filter=ngap.NGAP_PDU == 0
    Run Keyword And Continue On Failure    Wireshark.Check PDU session modification command
    Wireshark.ReadLog    filename=NG_PDU_modify_without_traffic.pcap    filter=ngap.NGAP_PDU == 0
    Run Keyword And Continue On Failure    Wireshark.Check PDU session modification complete
    Wireshark.Action.Close

Process.Add Two QoS Flow 5QI2_1 successful without traffic
    process.start new PCF
    Run Keyword And Continue On Failure    PCF.pcf_connect    ip=${PCF_IP}    username=${PCF_USERNAME}
    ...    password=${PCF_PASSWORD}
    Run Keyword And Continue On Failure    PCF.pcf_start
    gNB.connect
    Wireshark.StartCaptureNGLog    filename=NG_PDU_modify_without_traffic_5QI2_1.pcap
    sleep    5s
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    sleep    10s
    ${5Grach_ed}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    power_ue.Verify attach    ue_index=${0}    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    power_ue.Start traffic    ue_type=${UE_TYPE}   multidrb_QoS_dest=${UTE_IP}  direction=ul
    ...    apn_address=${CASE_INPUT_5GC000754['APN_754_ADDR']}    throughput=5MKbits/sec    duration=60
    Run Keyword And Continue On Failure    PCF.pcf_add_two_QoS_5QI2_1
    sleep  20s
    power_ue.Stop traffic   ue_type=${UE_TYPE}   ue_index=${0}
    ...    apn_address=${CASE_INPUT_5GC000754['APN_754_ADDR']}    direction=ul
#    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=True
    gNB.connect
    Wireshark.StopCaptureNGLog
    Wireshark.DownloadLogToUTE    filename=NG_PDU_modify_without_traffic_5QI2_1.pcap
    sleep    5s
    Wireshark.ReadLog    filename=NG_PDU_modify_without_traffic_5QI2_1.pcap    filter=ngap.NGAP_PDU == 1
    Run Keyword And Continue On Failure    Wireshark.CheckExpression   expression=ngap.radioNetwork == 36
    Wireshark.Action.Close

COAM_WEBEM.CheckBTSConutersWithUPandLowerValue
    [Arguments]    ${counter_id}   ${up_value}=1000   ${lower_value}=0
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_bts_counters_info   counter_id=${counter_id}
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    should be true    ${values[-1]} > ${lower_value}
    should be true    ${values[-1]} < ${up_value}


gNB.Power.ResetAndCommission
    [Arguments]    ${scf_file}
    Power.Reset5GRU
    Power.ResetgNB
    Sleep    10min
    wait until keyword succeeds    15min    1min    gNB.VerifyOnAirViaOAMUntilReady
    gNB.Commission    scf_file=${scf_file}    timeout=${2400}


COAM.SetParameterValue
    [Arguments]    ${distname}    ${paraname}    ${value}    ${abbr}=${None}
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=${paraname}    new_value=${value}    abbr=${abbr}

COAM.ValidateAndActiveParameters
    [Arguments]    ${activate_plan_despite_errors}=True
    ${error}    selenium_coam.validate_plan
    log    ${error}
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Clear UE info from AMF
   [Arguments]  ${ue_imsi}=${IMSI}   ${retry_times}=2
   Connect to 5GC
   ${imsi_presence}=    ssh.execute   command=cmm subscriber show --imsi ${ue_imsi} | head -n 7 | grep GENERALINFO    connection=${ALIAS_5GC}
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    ssh.execute   command=cmm subscriber delete --imsi ${ue_imsi}    connection=${ALIAS_5GC}
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    sleep   2min    # WA, make IMSI clear opeation is done completely.
   Disconnect from 5GC
   
Connect to 5GC
    [Arguments]    ${hostname}=${5GC_IP}   ${username}=${5GC_USERNAME}    ${password}=${5GC_PASSWORD}    ${alias}=${ALIAS_5GC}
    ssh.connect to    hostname=${hostname}  username=${username}  password=${password}    alias=${alias}

Disconnect from 5GC
    [Arguments]    ${connection}=${ALIAS_5GC}
    ssh.disconnect    connection=${connection}

#Wireshark.StartCaptureLog
#    [Arguments]    ${listen_port}     ${log_dir}     ${filename}    ${connection}
#    ssh.send command    tcpdump -s 0 -i ${listen_port} -w ${log_dir}/${filename} &>/dev/null &    connection=${connection}

Wireshark.Action.Capture
    [Arguments]   ${filename}    ${conn}    ${listen_port}=fp0    ${log_dir}=/tmp
    ASIK.Connect   alias=${conn}
    Wireshark.StartCaptureLog    listen_port=fp0    log_dir=/tmp     filename=${filename}    connection=${conn}
    sleep    2

Wireshark.Action.Stop_And_Download
    [Arguments]   ${conn}=${ALIAS_ASIK}    ${filename}=tcpdumpL2L1_filtering_off.pcap0
    ...   ${log_dir}=/tmp    ${listen_port}=fp0    ${localname}=${filename}
    gNB.connect
    sleep    2
    Wireshark.StopCapturinglog    connection=${conn}    listen_port=${listen_port}
    sleep    2
    Wireshark.DownloadLogToUTE    filename=${filename}   connection=${conn}    localname=${localname}
    sleep    5



Wireshark.Check PDU session modification complete
    [Arguments]
    [Documentation]  check PDU session modification complete
    Run Keyword And Continue On Failure    Wireshark.CheckExpression   nas_5gs.sm.message_type == 0xcc

Wireshark.Check PDU session modification command
    [Arguments]
    [Documentation]  check PDU session modification command
    Run Keyword And Continue On Failure    Wireshark.CheckExpression   nas_5gs.sm.message_type == 0xcb

Wireshark.StopCapturingALLlog
    ASIK.Connect   alias=${ALIAS_ASIK}
    ssh.send command   command=ps -ef|grep tcpdump|grep -v grep|grep fp0|awk '{print $2}'|xargs kill -2   connection=${ALIAS_ASIK}
    ${pid}  ssh.execute   command=lxc-attach -n 0xe004 -- ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'  connection=${ALIAS_ASIK}
    ssh.execute   command=lxc-attach -n 0xe004 -- kill -2 ${pid.replace('\r\n','')}   connection=${ALIAS_ASIK}
    ASIK.Disconnect    alias=${ALIAS_ASIK}

Wireshark.Action.Close
    Conn.ConnectWithTimeout    alias=${ALIAS_UTE}
    ssh.execute     command=ps -ef|grep -i wireshark    connection=${ALIAS_UTE}
    ssh.send command    command=killall wireshark     connection=${ALIAS_UTE}
    Conn.Disconnect      ${ALIAS_UTE}
    sleep  2s

Process.GetDLBlerAndTP
    [Arguments]    ${DLThroughput}=${DL_TP}    ${Percentage}=10
    Conn.ConnectWithTimeout    ${ALIAS_ASIK}
    #Conn.ConnectToLoner    ${ALIAS_LONER}
    Conn.ConnectToAsp1a    ${ALIAS_ASP_1A}
    ${dTP}    Run Keyword And Continue On Failure  gNB.GetDLThroughput
    ...    ALIAS_ASP_1A=${ALIAS_ASP_1A}  duration=10    location=${16}
    Conn.Disconnect    ${ALIAS_ASP_1A}
    #Conn.Disconnect    ${ALIAS_LONER}
    Conn.Disconnect    ${ALIAS_ASIK}
    ${DLPercent}    Run Keyword And Continue On Failure    Evaluate    ${dTP}*${100}/${DLThroughput}
    Set Test Variable    ${DLPercent}
    Set Test Variable    ${dTP}
    Run Keyword And Continue On Failure    Should be true    ${DLPercent}>${Percentage}

Process.GetULBlerAndTP
    [Arguments]    ${ULThroughput}=${UL_TP}    ${Percentage}=10
    Conn.ConnectWithTimeout    ${ALIAS_ASIK}
    #Conn.ConnectToLoner    ${ALIAS_LONER}
    Conn.ConnectToAsp1a    ${ALIAS_ASP_1A}
    ${uTP}      Run Keyword And Continue On Failure   gNB.GetULThroughput   ${ALIAS_ASP_1A}    10
    Conn.Disconnect    ${ALIAS_ASP_1A}
    #Conn.Disconnect    ${ALIAS_LONER}
    Conn.Disconnect    ${ALIAS_ASIK}
    ${ULPercent}    Run Keyword And Continue On Failure    Evaluate    ${uTP}*${100}/${ULThroughput}
    Set Test Variable    ${ULPercent}
    Set Test Variable    ${uTP}
    #Set Test Variable    ${bler}
    Run Keyword And Continue On Failure     Should be true    ${ULPercent}>${Percentage}

ASIK.Connect
    [Arguments]   ${alias}
    Run Keyword And Continue On Failure  ssh.Connect to    hostname=${ASIK_IP}
     ...    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}  alias=${alias}

ASIK.Disconnect
     [Arguments]   ${alias}
    Run Keyword And Continue On Failure  Conn.Disconnect    ${alias}

Setup suite
    TestSuite.Start
    Create Log Directories
    #set suite variable      ${Log_PATH_Artifactory}    /root/workspace/CIT/Master/Case_Logs/
    set suite variable    ${OAM_TYPE}    COAM
    #set suite variable    ${PCF_Server}               ${MTK_extend['pdu']}
    set suite variable    ${PCF_IP}                   ${CASE_INPUT_5GC000754['PCF_Server']['addr']}
    set suite variable    ${PCF_Username}             ${CASE_INPUT_5GC000754['PCF_Server']['username']}
    set suite variable    ${PCF_PASSWORD}             ${CASE_INPUT_5GC000754['PCF_Server']['password']}
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["detach_request"]    default_value=${true}
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["power_reset"]        default_value=true
    gNB.GenerateTestLineSCFs
    gNB.GenerateCaseSCF    InputFile=${LOG_PATH}/TestLineSCF1Cell.xml    OutputFile=${LOG_PATH}/5GC000754_base_SCF.xml
    ...               ResourceFolder=${CURDIR}
    ...               ParameterToDelete=PARAMS_TO_DELETE_754
	...               MOsToAdd=MOs_TO_Add_754
    ...               ParamterToModify=PARAMS_TO_MODIFY_754
    ...               ListParamterToModify=LIST_PARAMS_TO_MODIFY_754
    ...               ListToAdd=LIST_TO_ADD_754
    set suite variable    ${Original_CFGFILE_754}    ${LOG_PATH}/5GC000754_base_SCF.xml
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    gNB.Commission    scf_file=${Original_CFGFILE_754}    timeout=${2400}
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    Conn.ResetCache

TestSuilt.Destroy
    Run Keyword And Ignore Error    run    cat ${TP_FILE}
    TestSuite.Stop

Generate 754_1cell_SA
	[Arguments]    ${InputFile}
	gNB.ModifySCF     InputFile=${InputFile}
    ...               OutputFile=${LOG_PATH}/754_1cell_SA.xml
    ...               ParameterToDelete=${PARAMS_TO_DELETE_754}
	...               MOsToAdd=${MOs_TO_Add_754}
    ...               ParamterToModify=${PARAMS_TO_MODIFY_754}
    ...               ListParamterToModify=${LIST_PARAMS_TO_MODIFY_754}
    ...               ListToAdd=${LIST_TO_ADD_754}
	[Return]     ${LOG_PATH}/754_1cell_SA.xml
	
KW.CaseInit
    TestCase.Start
    Log to console    Case setup

KW.CaseDestroy
    KW.754.Change UE APN    ui_version=${CASE_INPUT_5GC000754['UE_UI_VERSION']}
    ...    apn_name=${CASE_INPUT_5GC000754['DEFAULT_APN_NAME']}    serial_number=${UE_SN}
    Run Keyword And Ignore Error   power_ue.UE Detach    ue_type=${UE_TYPE}    power_reset=True
    Run Keyword And Ignore Error    gNB.connect
    Run Keyword And Ignore Error    Wireshark.StopCaptureNGLog
    Run Keyword And Ignore Error    Wireshark.DownloadLogToUTE    filename=NG_PDU_modify_without_traffic.pcap
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    run    command=killall firefox
    #Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    #Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    force_close_coam_webdriver
    Run Keyword And Ignore Error    Wireshark.StopCapturingALLlog
    Conn.ResetCache
    TestCase.Stop

Collect snapshot via webui
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}

Start BTSlogs Collection
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf TRACE_*.bin ; rm -rf SYSLOG_*.LOG
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/home/ute/btslog/btslog
    ...   btslog_launcher_path=/home/ute/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    btslog.Set Global Alias     btslog
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog

Stop BTSlogs Collection and get logs
    core.teardown_collectors      names=btslog
    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz SYSLOG_combine.LOG
    run    command=cp /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz ${LOG_PATH}

KW.754.Change UE APN
    [Documentation]
    [Arguments]   ${ue_index}=${0}    ${ui_version}=Magic UI 3.1.1   ${apn_name}=mdrb754    ${serial_number}=NULL
    ${Apnresult}    run keyword and return status    Android.SwitchApn
    ...    ui_version=${ui_version}    apn_name=${apn_name}    serial_number=${serial_number}
    Run Keyword If    '${Apnresult}'=='False'
    ...    Run Keywords    Connect to control pc via cygwin    hostname=${Control_PC_hostname}    ue_index=${ue_index}
    ...    AND    Commercial UE click AIRPLANE once
    ...    AND    Android.SwitchApn    ui_version=${ui_version}    apn_name=${apn_name}    serial_number=${serial_number}
