*** Settings ***
Documentation     author: Yuan Hongyan
...               contact: hongyan.1.yuan@nokia-sbell.com
...               Common KWs for 5GC000900 feature.

Library           taf.transport.ssh		WITH NAME	csn
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           ../../5GC000638/Resources/coam_close.py
Resource          ../../5GC000496_C/Resources/L3Call.robot
Library           ../../5GC000742/Resources/MTKUE_extend.py
Library           MTKUE_extend.MTKUE    WITH NAME   MTKUE
Library           taf.ul.messaging.mtk      WITH NAME    mtk_msg
Library           taf.ue.rpc.mtk      WITH NAME    mtk_rpc


*** Variables ***
${IPERF_PORT}       ${tl.appserver.port}
${ELT_PATH}         /cygdrive/c/MTK/sw/ELT/ELT_exe_v2.2004.0_customer_Gen97_FT
${ADB_PATH}         ${tl.ues[0].edb_file_path}

*** Keywords ***
#  ### gNB side operation ###
Get rid of loner ssh fingerprint change issue
    gNB.Connect
    ssh.execute    command=ssh-keygen -R 192.168.253.22 -f /user/toor4nsn/.ssh/known_hosts   connection=${ALIAS_ASIK}
    ${wa_presence}    ssh.execute    command=cat /etc/ssh/ssh_config| grep "Host 192.168.253.22"    connection=${ALIAS_ASIK}
    run keyword if  not '${wa_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'    run keywords
    ...    ssh.execute    command=sed -i "1i\\Host 192.168.253.22" /etc/ssh/ssh_config    connection=${ALIAS_ASIK}
    ...    AND    ssh.execute    command=sed -i "2i\\${SPACE*3}StrictHostKeyChecking no" /etc/ssh/ssh_config    connection=${ALIAS_ASIK}
    ...    AND    ssh.execute    command=sed -i "3i\\${SPACE*3}UserKnownHostsFile=/dev/null" /etc/ssh/ssh_config    connection=${ALIAS_ASIK}
    gNB.Disconnect

Process.Verify gNB Readiness and Fail Case if Not After Reset
    ${gNB_on_air}    run keyword and return status    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend
    run keyword if  not ${gNB_on_air}   Powercycle gNB until Ready

Powercycle gNB until Ready
    Power.ResetgNB
    Power.Reset5GRU
    ${gNB_on_air}    run keyword and return status    wait until keyword succeeds   6x   3min   COAM_VerifyOnAirViaFrontendAndBackend
    run keyword if  not ${gNB_on_air}    fail    msg=gnb is not on air!

#  ### MTK side Operation ###
Powercycle MTK
    facom.PowerOnOff    pdu_ip=${PB_MTK_IP}    Port_Number=${PB_MTK_PORT}    Action=power_off
    sleep    5s
    facom.PowerOnOff    pdu_ip=${PB_MTK_IP}    Port_Number=${PB_MTK_PORT}    Action=power_on
    sleep    60s

Connect MTK CtrlPC
    ssh.connect to    hostname=${MTK_CtrlPC_IP}   username=${MTK_CtrlPC_USERNAME}  password=${MTK_CtrlPC_PASSWORD}  alias=MTK_CPC

Disconnect MTK CtrlPC
    ssh.disconnect    connection=MTK_CPC

Clear UE info from AMF with Retry
   [Arguments]  ${ue_imsi}=${IMSI}   ${retry_times}=2
    FOR    ${i}    IN RANGE    ${retry_times}
        Clear UE info from AMF
    END
    Log    UeAttach retry for ${i + 1} times.

Clear UE info from AMF
   [Arguments]  ${ue_imsi}=${IMSI}   ${retry_times}=2
   Connect to 5GC
   ${imsi_presence}=   csn.execute   command=cmm subscriber show --imsi ${ue_imsi} 2> /dev/null| head -n 7 | grep GENERALINFO
   ...    connection=${ALIAS_5GC}
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    csn.execute   command=cmm subscriber delete --imsi ${ue_imsi}    connection=${ALIAS_5GC}
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    sleep   2min    # WA, make IMSI clear opeation is done completely.
   Disconnect from 5GC

Verify if UE registered to AMF
   [Arguments]  ${ue_imsi}=${IMSI}
   Connect to 5GC
   ${output}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep amfRmState   connection=${ALIAS_5GC}
   should contain   ${output}   REGISTERED
   ${output}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep amfCmState  connection=${ALIAS_5GC}
   should contain   ${output}   CONNECTED
   Disconnect from 5GC

Check UE status from AMF
   [Arguments]  ${ue_imsi}=${IMSI}
   Connect to 5GC
   ${UE_Status}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}  connection=${ALIAS_5GC}
   ${RM_Status}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep amfRmState   connection=${ALIAS_5GC}
   ${CM_Status}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep amfCmState  connection=${ALIAS_5GC}
   ${PDN_Status}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep pnd  connection=${ALIAS_5GC}
   Log   ${UE_Status}
   Log to console   ${RM_Status}
   Log to console   ${CM_Status}
   Log to console   ${PDN_Status}

   Disconnect from 5GC

Connect to 5GC
    csn.connect to    hostname=${5GC_IP}   username=${5GC_USERNAME}    password=${5GC_PASSWORD}    alias=${ALIAS_5GC}

Disconnect from 5GC
    csn.disconnect    connection=${ALIAS_5GC}



#  ### Main L3 Call Procedures ###
GNB.SwconfigReplace
    [Arguments]    ${file_path}=${CFGFILE_PATH}
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.UploadFile    local_path=${file_path}/swconfig.txt    remote_path=/ffs/run/swconfig.txt    alias=${ALIAS_ASIK}
    Conn.Execute    cmd=cd /ffs/run/ && crasign swconfig.txt    alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}

GNB.Commissioning
    [Arguments]    ${scf_file}    ${file_path}=${CFGFILE_PATH}   ${timeout}=${900}
    COAM_Admin.commission    scf_file=${file_path}/${scf_file}    timeout=${timeout}
    Process.Verify gNB Readiness and Fail Case if Not After Reset

X2 Should Be Ready
    gNB.Connect
#    gNB.CheckHWStatusUntilReady
#    gNB.CheckF1StatusUntilReady
    gNB.CheckX2StatusUntilReady
    gNB.Disconnect

Reserve ue for tests
    [Documentation]   applicalbe for both QC and MTK
    ...     UE_CAPABILITIES: default value is for MTK,  For Qualcomm UE, REAL_ANDROID_UE is the correct value.
    [Arguments]    ${UE_alias}=UE_1    ${UE_CAPABILITIES}=REAL_MEDIATEK_UE
    [Timeout]      10min
    ute_ue.require Ue    ${UE_alias}    capabilities=${UE_CAPABILITIES}

MTK.Reserve ue for tests_With_Retry
    [Documentation]   Only applicalbe for MTK.  This is to workaround the issue of MTK unstale ports.
    [Arguments]    ${UE_alias}=UE_1    ${UE_CAPABILITIES}=REAL_MEDIATEK_UE
    ${status}   Run Keyword And Return Status    Reserve ue for tests    UE_alias=${UE_alias}    UE_CAPABILITIES=${UE_CAPABILITIES}
    run keyword if  not ${status}    Run Keywords    Powercycle MTK
    ...    AND    Reserve ue for tests    UE_alias=${UE_alias}    UE_CAPABILITIES=${UE_CAPABILITIES}
    mtk_msg.Setup    pyro_ip=${tl.ues[0].ssh_connection_details.addr}    pyro_port=${tl.ues[0].server_port}
    mtk_msg.Create Message Flow Alias    flow_alias=MTK_OTA_MESSAGE    message_type=ota_text
    mtk_msg.Create Message Flow Alias    flow_alias=MTK_PS_TRACE    message_type=ps_trace
    mtk_msg.Create Message Flow Alias    flow_alias=MTK_RAW_STRING    message_type=raw_string
    mtk_msg.Create Message Flow Alias    flow_alias=MTK_OTA_JSON    message_type=ota_json

Init MTK With Retry
    [Arguments]    ${reset}=${False}
    ${status}   Run Keyword And Return Status    MTKUE.init_mtk    reset=${reset}
    Run keyword if    '${status}'=='False'    Run Keywords    Powercycle MTK
    ...    AND    MTKUE.init_mtk    reset=${reset}

UE Detach
    [Documentation]   applicalbe for both QC and MTK
    [Arguments]    ${UE_alias}=UE_1
    ute_ue.detach_ue    ${UE_alias}
    sleep    3s

MTK.UE Detach With Verification
    [Documentation]   Only applicalbe for  MTK
    [Arguments]    ${UE_alias}=UE_1
    ute_ue.detach_ue    ${UE_alias}
    sleep    10s
    ${Detach Expected Messages} =    Create List     5GMM_DEREGISTRATION_REQUEST    NR_RRCRelease
    mtk_msg.Expect Messages in Flow    awaited_messages=${Detach Expected Messages}    flow_alias=MTK_OTA_MESSAGE

MTK.UE Attach
    [Documentation]   Only applicalbe for MTK.  This is to workaround the issue of MTK unstale ports.
    [Arguments]    ${UE_alias}=UE_1
    [Timeout]      5min
    UE Attach   UE_alias=${UE_alias}
    ${attach_result_UE}    run keyword and return status     MTK.Verify Attach
#    run keyword unless   ${attach_result_UE}     log to console  message=attach failure may cause gNB crash: PR482964.
    ${attach_result_AMF}    run keyword and return status
    ...    wait until keyword succeeds   5x   5s   Verify if UE registered to AMF
#    should be true     ${attach_result_UE} and ${attach_result_AMF}
    should be true     ${attach_result_UE}
#    should be true     ${attach_result_AMF}

MTK.Verify Attach
    [Documentation]   Only applicalbe for MTK.
    [Arguments]    ${Expected_Messages}=5GMM_REGISTRATION_COMPLETE
    [Timeout]      2min
    ${attach_success} =    Create List     ${Expected_Messages}
    mtk_msg.Expect Messages in Flow    awaited_messages=${attach_success}    flow_alias=MTK_OTA_MESSAGE    timeout=${15}

UE Attach
    [Documentation]   applicalbe for both QC and MTK
    [Arguments]    ${UE_alias}=UE_1
    ute_ue.register    ${UE_alias}
    sleep    3s

Capture MTK Elg Log
    [Arguments]   ${log_name}=debug.elg
    mtk_rpc.configure    hostname=${MTK_PYRO_IP}    port=${MTK_PYRO_PORT}
    mtk_rpc.create_proxy    alias=save_elg
    mtk_rpc.save_elg_log    output_path=${log_name}   proxy=save_elg

UE Attach and Start data transfer with Log Capturing
    [Documentation]   Only applicalbe for MTK, capturing all needed wireshark logs durig L3 call for further analysis
    [Arguments]    ${connection}=${ALIAS_ASIK}    ${UE_alias}=UE_1    ${Duration}=1200s
    [Timeout]      20min
    gNB.Connect
    Wireshark.StartCaptureNGLog   filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_NG_DL.pcap
    Wireshark.Start Capturing Log From Container  filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_CPIF_DL.pcap
    ...    container=0xe004
    Wireshark.Start Capturing BIP Log    filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_BIP.pcap
    sleep    5s
    ${UE_Attach}    run keyword and return status     MTK.UE Attach   UE_alias=${UE_alias}
    Wireshark.StopCapturinglog    listen_port=etha01
    run keyword if  not ${UE_Attach}   Capture MTK Elg Log
    run keyword if    ${UE_Attach}    Run Keyword And Continue On Failure    Start DL Traffic     UE_alias=${UE_alias}   Duration=${Duration}
    Wireshark.StopCapturingAlllog
    Run Keyword And Ignore Error    Wireshark.DownloadLogToUTE   filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_BIP.pcap
    Wireshark.DownloadLogToUTE   filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_NG_DL.pcap
    Wireshark.DownloadLogFromContainerToUTE    filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_CPIF_DL.pcap
    ...    remote_dir=/tmp/node_0xe004/tmp
    run keyword if   ${UE_Attach}   Run Keyword And Continue On Failure   Start UL Traffic   UE_alias=${UE_alias}   Expected_Tput=${UL_TPUT}bits/sec
    ...    Duration=${Duration}
    sleep    30s
    should be true   ${UE_Attach}


UE Attach and DL data transfer with Log Capturing
    [Documentation]   Only applicalbe for MTK, L3 call with DL traffic, capturing all needed wireshark logs durig L3 call for further analysis
    [Arguments]    ${connection}=${ALIAS_ASIK}   ${UE_alias}=UE_1    ${Duration}=1200s
    [Timeout]      15min
    gNB.Connect
    Wireshark.StartCaptureNGLog   filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_NG_DL.pcap
    Wireshark.Start Capturing Log From Container  filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_CPIF_DL.pcap
    ...   container=0xe004
    Wireshark.Start Capturing BIP Log    filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_BIP.pcap
    ${UE_Attach}    run keyword and return status     MTK.UE Attach   UE_alias=${UE_alias}
#    Wireshark.StopCapturinglog    listen_port=etha01
    run keyword if  not ${UE_Attach}   Capture MTK Elg Log
    run keyword if    ${UE_Attach}    Run Keyword And Continue On Failure    Start DL Traffic     Duration=${Duration}   UE_alias=${UE_alias}
    sleep    30s
    Wireshark.StopCapturinglog    listen_port=etha01
    Wireshark.StopCapturingAlllog
    Run Keyword And Ignore Error    Wireshark.DownloadLogToUTE   filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_BIP.pcap
    Wireshark.DownloadLogToUTE   filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_NG_DL.pcap
    Wireshark.DownloadLogFromContainerToUTE    filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_CPIF_DL.pcap
    ...   remote_dir=/tmp/node_0xe004/tmp
    should be true   ${UE_Attach}

Wireshark.Start Capturing BIP Log
    [Arguments]    ${filename}
    ssh.send command    command=cp /user/toor4nsn/loner_mirroring_L1R51.sh /ffs/run/    connection=${ALIAS_ASIK}
    Conn.ConnectToLoner    alias=${ALIAS_LONER}
    ssh.send command    command= cp /ffs/run/loner_mirroring_L1R51.sh /tmp/    connection=${ALIAS_LONER}
    ${output}   ssh.execute    command=sh /tmp/loner_mirroring_L1R51.sh    connection=${ALIAS_LONER}
    ssh.send command    command=dbgrrc mirror sport 25 dport 2 enable both    connection=${ALIAS_ASIK}
    Wireshark.StartCaptureLog    listen_port=etha01    log_dir=/tmp     filename=${filename}    connection=${ALIAS_ASIK}
    ssh.execute        command=ps -ef|grep -i tcpdump     connection=${ALIAS_ASIK}

Wireshark.Start Capturing Log From Container
    [Arguments]   ${filename}    ${container}=0xe004    ${listen_port}=any     ${log_dir}=/tmp   ${connection}=${ALIAS_ASIK}
    ssh.send command    command=lxc-attach -n ${container} -- tcpdump -n -i ${listen_port} -w ${log_dir}/${filename} &>/dev/null &
    ...    connection=${connection}

Wireshark.StopCapturingALLlog
    ssh.send command   command=ps -ef|grep tcpdump|grep -v grep|grep fp0|awk '{print $2}'|xargs kill -2   connection=${ALIAS_ASIK}
    ${pid}  ssh.execute   command=lxc-attach -n 0xe004 -- ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'  connection=${ALIAS_ASIK}
    ssh.execute   command=lxc-attach -n 0xe004 -- kill -2 ${pid.replace('\r\n','')}   connection=${ALIAS_ASIK}

Start DL Traffic
    [Arguments]    ${Expected_Tput}=22Mbits/sec    ${DT_Name}=dt1_dl    ${UE_alias}=UE_1    ${direction}=dl    ${Duration}=90s    ${Data_Type}=udp
    ...    ${Packet_Size}=1024
    ute_ue.start_data_transfer    dt_name=${DT_Name}    ue_alias=${UE_alias}    direction=${direction}    throughput=${Expected_Tput}
    ...    duration=${Duration}    protocol=${Data_Type}    packet_size=${Packet_Size}

Stop DL Traffic
   [Arguments]   ${DT_Name}=dt1_dl
   ute_ue.stop_data_transfer    dt_name=${DT_Name}

Wireshark.DownloadLogFromContainerToUTE
    [Arguments]    ${filename}    ${remote_dir}=/tmp
    ssh.download_file   local_path=${LOG_PATH}/${filename}    remote_path=${remote_dir}/${filename}   connection=${ALIAS_ASIK}
    sleep    20s

Start UL Traffic
    [Arguments]    ${Expected_Tput}=6Mbits/sec    ${DT_Name}=dt1_ul   ${UE_alias}=UE_1    ${direction}=ul    ${Duration}=90s    ${Data_Type}=udp
    ...    ${Packet_Size}=1024
    ute_ue.start_data_transfer    dt_name=${DT_Name}    ue_alias=${UE_alias}    direction=${direction}    throughput=${Expected_Tput}
    ...    duration=${Duration}    protocol=${Data_Type}    packet_size=${Packet_Size}

Stop UL Traffic
   [Arguments]   ${DT_Name}=dt1_ul
   ute_ue.stop_data_transfer    dt_name=${DT_Name}

Evaluate DL ThroughPut
    ${res}  run keyword and return status    GetDLBlerAndTP    ${expect_dl}    ${EXPECTED_PRECENT}
    log    ${res}
    Run Keyword If    ${res}    log    Test Passed
    ...    ELSE    Fail    Test Failed
#    Run Keyword If    ${res} == ('PASS', None)    Run Keyword And Ignore Error    record_throughput_to_file
#    ...    ${TEST NAME}    ${TP_FILE}    ${DLPercent}    ${dTP}

Evaluate UL ThroughPut
    ${res}    Run Keyword And Return Status    GetULBlerAndTP    ${expect_ul}*2    ${EXPECTED_PRECENT}
    log    ${res}
    Run Keyword And Ignore Error   gNB.GetULBlerAndThroughput
    Run Keyword If    ${res}    log    Test Passed
    ...    ELSE    Fail    Test Failed
#    Run Keyword If    ${res} == ('PASS', None)    Run Keyword And Ignore Error    record_throughput_to_file
#    ...    ${TEST NAME}    ${TP_FILE}    ${ULPercent}    ${uTP}    ${bler}

GetULBlerAndTP
    [Arguments]    ${ULThroughput}=6    ${Percentage}=10
    [Timeout]      10min
    Conn.ConnectWithTimeout    ${ALIAS_ASIK}
#    Conn.ConnectToLoner    ${ALIAS_LONER}
    Conn.ConnectToAsp1a    ${ALIAS_ASP_1A}
#    ${uTP}    gNB.GetULBlerAndThroughputCoam    ALIAS_LONER=${ALIAS_LONER}    ALIAS_ASP_1A=${ALIAS_ASP_1A}    duration=40
    ${uTP}    gNB.GetULThroughput   ALIAS_ASP_1A=${ALIAS_ASP_1A}    duration=40
#    ${uTP}    ${bler}    gNB.GetULBlerAndThroughputCoam    ${ALIAS_LONER}    ${ALIAS_ASP_1A}    10
#    ${uTP}    ${bler}    gNB.GetULBlerAndThroughputCoam    ${ALIAS_LONER}    ${ALIAS_ASP_1A}    10
    Conn.Disconnect    ${ALIAS_ASP_1A}
#    Conn.Disconnect    ${ALIAS_LONER}
    Conn.Disconnect    ${ALIAS_ASIK}
    ${ULPercent}    Evaluate    ${uTP}*${100}*${1000}*${1000}/${ULThroughput}
    Set Test Variable    ${ULPercent}
    Set Test Variable    ${uTP}
#    Set Test Variable    ${bler}
    Should be true    ${ULPercent}>${Percentage}


GetDLBlerAndTP
    [Arguments]    ${DLThroughput}=6    ${Percentage}=10
    [Timeout]      10min
    Conn.ConnectWithTimeout    ${ALIAS_ASIK}
#    Conn.ConnectToLoner    ${ALIAS_LONER}
    Conn.ConnectToAsp1a    ${ALIAS_ASP_1A}
    ${dTP}    gNB.GetDLThroughput    ALIAS_ASP_1A=${ALIAS_ASP_1A}   duration=30    location=${16}
    Conn.Disconnect    ${ALIAS_ASP_1A}
#    Conn.Disconnect    ${ALIAS_LONER}
    Conn.Disconnect    ${ALIAS_ASIK}
    ${DLPercent}    Evaluate    ${dTP}*${100}*${1000}*${1000}/${DLThroughput}
    Set Test Variable    ${DLPercent}
    Set Test Variable    ${dTP}
    Should be true    ${DLPercent}>${Percentage}

gNB.GetULBlerAndThroughputCoam
    [Arguments]    ${ALIAS_LONER}=LONER    ${ALIAS_ASP_1A}=ASP_1A    ${duration}=30
#    Conn.Execute    cmd=bsh 1:2 -- /sbin/devmem 0xDF60C154 32 0x100   alias=${ALIAS_ASIK}
#    ${pre_crc}    Conn.Execute    cmd=bsh 1:2 -- /sbin/devmem 0xDF60C150 32   alias=${ALIAS_ASIK}
#    ${pre_tp}     Conn.Execute    cmd=bsh 1:2 -- /sbin/devmem 0xDF60C14C 32   alias=${ALIAS_ASIK}
#    Conn.Execute    cmd=bsh 1:2 -- /sbin/devmem 0xDF60C154 32 0x0   alias=${ALIAS_ASIK}

    ${UL_TP}   gNB.GetULThroughput   ALIAS_ASP_1A=${ALIAS_ASP_1A}   duration=${duration}

#    Conn.Execute    cmd=bsh 1:2 -- /sbin/devmem 0xDF60C154 32 0x100   alias=${ALIAS_ASIK}
#    ${cur_crc}    Conn.Execute    cmd=bsh 1:2 -- /sbin/devmem 0xDF60C150 32   alias=${ALIAS_ASIK}
#    ${cur_tp}     Conn.Execute    cmd=bsh 1:2 -- /sbin/devmem 0xDF60C14C 32   alias=${ALIAS_ASIK}
#    Conn.Execute    cmd=bsh 1:2 -- /sbin/devmem 0xDF60C154 32 0x0   alias=${ALIAS_ASIK}
#    ${crc}    Evaluate    ${cur_crc.strip()}-${pre_crc.strip()}
#    ${tp}     Evaluate    ${cur_tp.strip()}-${pre_tp.strip()}
#    ${bler}    Run Keyword If    ${tp} > 0    Evaluate    float(${crc})*100/${tp}
#    ...    ELSE    set variable    100
#    [Return]   ${UL_TP}    ${bler}
    [Return]   ${UL_TP}

Setup Suite
    Create Log Directories
    set suite variable      ${Log_PATH_Artifactory}    /opt/ute/workspace/CIT/Master/Case_Logs
    set suite variable   ${OAM_TYPE}    COAM
    set suite variable    ${TP_FILE}    ${LOG_PATH}/tp.txt
    Run Keyword And Ignore Error    run    rm ${TP_FILE}
    Conn.ResetCache

Teardown Suite
    TestSuite.Stop
    Run Keyword And Ignore Error    run    cat ${TP_FILE}

Setup Case
    [Arguments]    ${mcs}=0
    Run keyword If    ${mcs}==0    SetTestVariables    mcs=0    ul=6M    dl=22M
    Run keyword If    ${mcs}==16   SetTestVariables    mcs=16    ul=64M    dl=248M
    Run keyword If    ${mcs}==20    SetTestVariables    mcs=20    ul=83M    dl=323M
    Run keyword If    ${mcs}==21    SetTestVariables    mcs=21    ul=91M    dl=352M
    Run keyword If    ${mcs}==26    SetTestVariables    mcs=26    ul=129M    dl=495M
    Run keyword If    ${mcs}==27    SetTestVariables    mcs=27    ul=134M    dl=516M
    Run keyword If    ${mcs}==28    SetTestVariables    mcs=28    ul=140M    dl=536M
    Run Keyword And Ignore Error    Clear Python and ELT in MTK CtrlPC
    Run Keyword And Ignore Error    Start BTSlogs Collection
#    Reset gNB until Ready

Teardown Case
    [Arguments]    ${UE_alias}=UE_1
    Run Keyword And Ignore error    MTK.UE Detach With Verification   UE_alias=${UE_alias}
    gNB.Connect
    Run Keyword And Ignore Error     Wireshark.StopCapturingALLlog     # to be combined with the following two
    Run Keyword And Ignore Error     ssh.execute   command=killall -2 tcpdump   connection=${ALIAS_ASIK}
    Run Keyword And Ignore Error     ssh.execute   command=killall -2 tcpdump   connection=${ALIAS_ASIK_SLAVE}
    Run Keyword And Ignore Error     Check UE status from AMF
    Run Keyword And Ignore Error     Collect Pyroserver and ELG Log
    Run Keyword And Ignore Error     Collect Snapshot
    Run Keyword And Ignore Error     Stop BTSlogs Collection and get logs
    Run Keyword If Test Failed    Run Keyword And Ignore Error     Collect gNB Logs
    Run Keyword And Ignore error     selenium_coam.disable_virtual_display
    Run Keyword And Ignore error     Kill Xvfb in UTE
    Run Keyword And Ignore error     force_close_coam_webdriver
    Run Keyword And Ignore error     run    command=killall firefox
    Run Keyword And Ignore error     run    command=killall geckodriver
    Run Keyword And Ignore error     Kill iperfs in MTK CtrlPC
    Run Keyword And Ignore error     Kill iperfs in AppServer
    Run Keyword And Ignore error     Clear UE info from AMF with Retry
    Conn.ResetCache
    Run Keyword And Ignore Error    ute_ue.stop_data_transfers_for_all_ues

Collect Pyroserver and ELG Log
    Connect MTK CtrlPC
    ${tm}    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}    .    :
    ${pyro_logname}=    catenate    SEPARATOR=_    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}   ProServer_${tm}.log
    ${elg_logname}=    catenate    SEPARATOR=_    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}   debug_${tm}.elg
    Conn.DownloadFile  local_path=${LOG_PATH}/${pyro_logname}  remote_path=/cygdrive/c/pyro_server/workspace/server_debug.log
    ...    alias=MTK_CPC
    Run Keyword And Ignore error     Conn.DownloadFile  local_path=${LOG_PATH}/${elg_logname}
    ...    remote_path=/cygdrive/c/pyro_server/workspace/debug.elg   alias=MTK_CPC
    Disconnect MTK CtrlPC


Kill Xvfb in UTE
    ${Xvfb_Cnt}  run  command=ps -ef | grep -i Xvfb |grep -v grep|awk '{print$2}'|awk 'END{print NR}'
    FOR    ${i}    IN RANGE    ${Xvfb_Cnt}
        ${PID1}  run  command=ps -ef|grep -i Xvfb|awk '{{print $2}}'|head -n 1
        Log  message=Killing ${i+1}st Xvfb process with PID ${PID1}.
        run  command=/bin/kill -9 ${PID1.strip()}
    END
    run  command=ps -ef | grep -i Xvfb |grep -v grep

Clear Python and ELT in MTK CtrlPC
     [Arguments]  ${elt_path}=${ELT_PATH}
     Connect MTK CtrlPC
     ${pythonCnt}  Conn.Execute  cmd=ps -Wef | grep python |grep -v grep|awk '{print$2}'|awk 'END{print NR}'  alias=MTK_CPC
     FOR    ${i}    IN RANGE    ${pythonCnt}
         ${PID1}  Conn.Execute  cmd=ps -Wef|grep python|awk '{{print $2}}'|head -n 1  alias=MTK_CPC
         Log  message=Killing ${i+1}st python process with PID ${PID1}.
         Conn.Execute   cmd=/bin/kill -f ${PID1.strip()}   alias=MTK_CPC
     END
     Conn.Execute  cmd=ps -Wef | grep python |grep -v grep    alias=MTK_CPC
     ${PID2}  Conn.Execute  cmd=ps -Wef|grep "ELT\.exe"|awk '{{print $2}}'|head -n 1  alias=MTK_CPC
     Conn.Execute  cmd=/bin/kill -f ${PID2.strip()}  alias=MTK_CPC
     Conn.Execute  cmd=cd ${elt_path}/Temp;ls |grep "\.tmp" |xargs rm -rf  alias=MTK_CPC
     Disconnect MTK CtrlPC

Kill iperfs in MTK CtrlPC
     Connect MTK CtrlPC
     ${iperf_Cnt}  Conn.Execute  cmd=ps -Wef | grep -i iperf |grep -v grep|awk '{print$2}'|awk 'END{print NR}'  alias=MTK_CPC
     FOR    ${i}    IN RANGE    ${iperf_Cnt}
         ${PID1}  Conn.Execute  cmd=ps -Wef|grep -i iperf|awk '{{print $2}}'|head -n 1  alias=MTK_CPC
         Log  message=Killing ${i+1}st iperf process with PID ${PID1}.
         Conn.Execute   cmd=/bin/kill -f ${PID1.strip()}   alias=MTK_CPC
     END
     Conn.Execute  cmd=ps -Wef | grep -i iperf |grep -v grep    alias=MTK_CPC
     Disconnect MTK CtrlPC

Kill iperfs in AppServer
     [Arguments]   ${port}=${IPERF_PORT}
     Connect to 5GC
     ${iperf_Cnt}  Conn.Execute  cmd=ps -ef | grep -i iperf |grep ${port} |grep -v grep|awk '{print$2}'|awk 'END{print NR}'
      ...    alias=${ALIAS_5GC}
     FOR    ${i}    IN RANGE    ${iperf_Cnt}
         ${PID1}  Conn.Execute  cmd=ps -ef|grep -i iperf| grep ${port} |grep -v grep|awk '{{print $2}}'|head -n 1  alias=${ALIAS_5GC}
         Log  message=Killing ${i+1}st iperf process with PID ${PID1}.
         Conn.Execute   cmd=kill -9 ${PID1.strip()}   alias=${ALIAS_5GC}
     END
     Conn.Execute  cmd=ps -ef | grep -i iperf |grep ${port} |grep -v grep    alias=${ALIAS_5GC}
     Disconnect from 5GC

SetTestVariables
    [Arguments]    ${mcs}=0    ${ul}=6    ${dl}=22
    Set Test Variable    ${mcs}
    Set Test Variable    ${UL_TPUT}    ${ul}
    Set Test Variable    ${DL_TPUT}    ${dl}
    ${expect_ul}    Evaluate    ${UL_TPUT[:-1]}*1000*1000
    Set Test Variable    ${expect_ul}
    ${expect_dl}    Evaluate    ${DL_TPUT[:-1]}*1000*1000
    Set Test Variable    ${expect_dl}

Collect gNB Logs
    Log    collect all log ${TEST NAME}
    ${tm}    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}    .    :
    ${gNB_logName}=    catenate    SEPARATOR=_    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}   gNB-${tm}.log
    Run Keyword And Ignore Error    gNB.LogCollector   ${gNB_logName}
    Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
#    run keyword and ignore error    MTK.Collect log
    Conn.ResetCache

gNB.LogCollector
    [Arguments]    ${logName}=gNB.log    ${location}=/ffs/run/logs
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.Execute  cmd=rm -rf ${location}/*gNB*.log   alias=${ALIAS_ASIK}
    Conn.Execute  cmd=rm -rf ${location}/*gNB*.log.tgz   alias=${ALIAS_ASIK}
    Conn.Execute  cmd=/user/toor4nsn/wa/classicalbts_log_collector.sh -o ${location}/${logName}   alias=${ALIAS_ASIK}
    Conn.Execute  cmd=tar czvf ${location}/${logName}.tgz ${location}/${logName}/  alias=${ALIAS_ASIK}
    Conn.DownloadFile  local_path=${LOG_PATH}/${logName}.tgz  remote_path=${location}/${logName}.tgz   alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}

Collect Snapshot
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}

Start BTSlogs Collection
    [Documentation]    collect syslogs from ute VM.
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
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_SYSLOG.tgz SYSLOG_combine.LOG
    run    command=cp /tmp/${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_SYSLOG.tgz ${LOG_PATH}


###  QC specific part ####
QC.UE Attach
    Conn.ConnectWithTimeout    ${AlIAS_QC}
    wait until keyword succeeds    2min    10s    Qualcomm.check adb devices    ${device_model}    ${AlIAS_QC}
    sleep    10s
#    Wait until keyword succeeds    3x    10s    Qualcomm.UEAttach
    Wait until keyword succeeds    2x    10s    Qualcomm.UEAttach with log capturing

Qualcomm.check adb devices
    [Arguments]    ${serial_number}    ${connection}=cpc
    Csn.send_command    adb devices    connection=${connection}    timeout=5
    Sleep    3s
    ${result}    Csn.read_output    connection=${connection}
    Should contain    ${result}    ${serial_number}
    log    INFO:UE devices detected    console=true
    Sleep    3s

Qualcomm.Verify 4G UE setup by ADB log
    [Arguments]    ${lte_earfcn}    ${connection}=${AlIAS_QC}
    Csn.send_command    cat /tmp/ADB.log | grep DATA_REGISTRATION | grep rat    connection=${connection}
    sleep    2s
    ${result}    Csn.read_output    connection=${connection}
    Run keywords    Should contain    ${result}    rat = 0
    ...    AND    Should contain    ${result}    earfcn = ${lte_earfcn}

Qualcomm.UEAttach
    Run Keyword And Ignore Error    UE Detach   ${QC_UE_alias}
    #Qualcomm.Start catch UE ADB logs    ${device_model}    ${AlIAS_QC}
    log    INFO:attach ue    console=true
#    taf_ue.attach_ue    ${UE_alias}
    ute_ue.attach_ue    ${QC_UE_alias}
    sleep    20s
    #Qualcomm.Stop catch UE ADB logs and save it    ${device_model}    ${AlIAS_QC}
    #Qualcomm.ADB log verify 5G UE setup successfully    ${lte_earfcn}    ${AlIAS_QC}
    Log    INFO:attach ue success    console=true

Qualcomm.UEAttach with log capturing
    Run Keyword And Ignore Error    UE Detach   UE_alias=${QC_UE_alias}
    gNB.Connect
    Wireshark.StartCaptureNGLog   filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_X2.pcap
    Wireshark.Start Capturing Log From Container  filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_NSA_CPIF.pcap
    ...    container=0xe004
    Wireshark.Start Capturing BIP Log    filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_NSA_BIP.pcap
    ${UE_Attach}   run keyword and return status   ute_ue.attach_ue    ue_alias=${QC_UE_alias}
    sleep    20s
    Log    INFO:attach ue success    console=true
    Wireshark.StopCapturinglog    listen_port=etha01
    Wireshark.StopCapturingAlllog
    Run Keyword And Ignore Error    Wireshark.DownloadLogToUTE
    ...    filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_NSA_BIP.pcap
    Wireshark.DownloadLogToUTE   filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_X2.pcap
    Wireshark.DownloadLogFromContainerToUTE    filename=${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_NSA_CPIF.pcap
    ...   remote_dir=/tmp/node_0xe004/tmp
    should be true   ${UE_Attach}

Qualcomm.RebootUeViaADB
    [Arguments]    ${device_model_num}=${device_model}
    Log    INFO:reboot ue by adb command    console=true
    Conn.ConnectWithTimeout    ${AlIAS_QC}
    Csn.send_command    command=adb -s ${device_model_num} shell "su 0 settings put global airplane_mode_on 0"   connection=${AlIAS_QC}    timeout=5
    Sleep    5s
    Csn.send_command    command=adb -s ${device_model_num} shell "su 0 am broadcast -a android.intent.action.AIRPLANE_MODE"
    ...    connection=${AlIAS_QC}    timeout=5
    Sleep    5s
    Csn.send_command    command=adb root   connection=${AlIAS_QC}    timeout=5
    Sleep    5s
    Csn.send_command    command=adb reboot    connection=${AlIAS_QC}    timeout=5
    Sleep    5s
    Csn.read_output    connection=${AlIAS_QC}
