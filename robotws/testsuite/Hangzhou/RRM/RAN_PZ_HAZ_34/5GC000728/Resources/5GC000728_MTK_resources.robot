*** Settings ***
Documentation     author: Liu Tiffany
...               contact: tiffany.liu@nokia-sbell.com
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           ../../5GC000742/Resources/MTKUE_extend.py
Library           MTKUE_extend.MTKUE    WITH NAME   MTKUE



*** Variables ***

#${UTE_UE_CONFIG}     ${CURDIR}/Resources/MTK_config_TL5.yaml
#${UTE_UE_CONFIG}     ${CURDIR}/Resources/MTK_config_TL5_wap2.yaml
${IMSI}                     ${tl.ues[0].imsi}

${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

${MTK_CtrlPC_IP}           ${tl.ues[0].ssh_connection_details.addr}
${MTK_CtrlPC_USERNAME}     ${tl.ues[0].ssh_connection_details.username}
${MTK_CtrlPC_PASSWORD}     ${tl.ues[0].ssh_connection_details.password}

#${MTK_CtrlPC_IP}           ${tl.ues[1].ssh_connection_details.addr}
#${MTK_CtrlPC_USERNAME}     ${tl.ues[1].ssh_connection_details.username}
#${MTK_CtrlPC_PASSWORD}     ${tl.ues[1].ssh_connection_details.password}


${ASIK_LMP_IP}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}        ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

${PB_ASIK_IP}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}     ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}    ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

${MTK_FACOM_IP}                   ${tl.ues[0].pdu.pdu.addr}
${MTK_FACOM_PORT}                   ${tl.ues[0].pdu.port_no}
#${ASIK_LMP_IP}        ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
#${ASIK_IP}        ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
#
#${WEBUI_IP}                 ${tl.gnbs[1].cu.oam_http_connection_details.addr}
#${WEBUI_USERNAME}           ${tl.gnbs[1].cu.oam_http_connection_details.username}
#${WEBUI_PASSWORD}           ${tl.gnbs[1].cu.oam_http_connection_details.password}
#
#${PB_ASIK_IP}     ${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
#${PB_ASIK_PORT}    ${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.port_no}
#
#${PB_5GRU_IP}     ${tl.gnbs[1].dus[0].rus[0].pdu_port.pdu.addr}
#${PB_5GRU_PORT}    ${tl.gnbs[1].dus[0].rus[0].pdu_port.port_no}
${MRBTS_1}    ${tl.gnbs[0].instance_id}
${NRBTS_1}    ${tl.gnbs[0].global_bts_id}

${dist_name}    ${MRBTS_1}/${NRBTS_1}

${REPEAT_TIME}    ${50}
${THRESHOLD}      ${49}
${EXPECTED_PRECENT}    10

##################define these variable for convenient############################
${ALIAS_ASIK}     asik
${ALIAS_ASIK_SLAVE}    asik_slave
${ALIAS_UTE}      ute
${ALIAS_ENBCTLPC}    ENB_PC
${ALIAS_SHP}      SHP
${ALIAS_E500}     E500
${ALIAS_PRISMA}    Prisma
${ALIAS_REAL_EPC_SERVER}    Real_EPC
${ALIAS_LONER}    LONER
${ALIAS_ASP_1A}    ASP_1A
${AlIAS_QC}       Qualcomm
${UE_alias}       UE_1
${ALIAS_5GC}      5gc
${ALIAS_AMF}                AMF                                                 ##
########################END of alias Define#######################################




*** Keywords ***

Powercycle gNB until Ready
    Power.ResetgNB
    Power.Reset5GRU
    ${gNB_on_air}    run keyword and return status    wait until keyword succeeds   6x   3min   COAM_VerifyOnAirViaFrontendAndBackend
    run keyword if  not ${gNB_on_air}    fail    msg=gnb is not on air!

Process.Verify gNB Readiness and Fail Case if Not After Reset
    ${gNB_on_air}    run keyword and return status    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend
    run keyword if  not ${gNB_on_air}   Powercycle gNB until Ready

GNB.SwconfigReplace
    [Arguments]    ${file_path}=${CFGFILE_PATH}
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.UploadFile    local_path=${file_path}/swconfig.txt    remote_path=/ffs/run/swconfig.txt    alias=${ALIAS_ASIK}
    Conn.Execute    cmd=cd /ffs/run/ && crasign swconfig.txt    alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}

GNB.Commissioning
    [Arguments]    ${scf_file}    ${file_path}=${CFGFILE_PATH}
    COAM_Admin.commission    scf_file=${file_path}/${scf_file}
    Process.Verify gNB Readiness and Fail Case if Not After Reset


Modify parameter value via webui for common
    [Arguments]    ${dist_name}    ${new_value}    ${filter_param}    ${abbr}
    COAM_WebEM.Login
    ${vlaue_before}    COAM.GetParameterValue    dist_name=${dist_name}
    ...    filter_param=${filter_param}    abbr=${abbr}
    COAM.SetParameterValue    dist_name=${dist_name}
    ...    filter_param=${filter_param}    new_value=${new_value}    abbr=${abbr}
    COAM.ValidateAndActiveParameters
    ${vlaue_after}    COAM.GetParameterValue    dist_name=${dist_name}
    ...    filter_param=${filter_param}        abbr=${abbr}
    Should be equal    ${new_value}    ${vlaue_after}
    COAM_WebEM.Logout

#  ### gNB side WA ###
Get rid of loner ssh fingerprint change issue
    gNB.Connect
    ssh.execute    command=sed -i "1i\\Host 192.168.253.22" /etc/ssh/ssh_config    connection=${ALIAS_ASIK}
    ssh.execute    command=sed -i "2i\\${SPACE*3}StrictHostKeyChecking no" /etc/ssh/ssh_config    connection=${ALIAS_ASIK}
    ssh.execute    command=sed -i "3i\\${SPACE*3}UserKnownHostsFile=/dev/null" /etc/ssh/ssh_config    connection=${ALIAS_ASIK}
    ssh.execute    command=ssh-keygen -R 192.168.253.22 -f /user/toor4nsn/.ssh/known_hosts   connection=${ALIAS_ASIK}
    gNB.Disconnect

UE.Require_With_Retry
    [Arguments]    ${UE_alias}=UE_1    ${UE_CAPABILITIES}=REAL_MEDIATEK_UE
    ${status}   Run Keyword And Return Status    ute_ue.require Ue    ue_alias=${UE_alias}    capabilities=${UE_CAPABILITIES}
    Run keyword if    '${status}'=='False'    Run Keywords    UE.Power_Reset
    ...    AND    ute_ue.require Ue    ue_alias=${UE_alias}    capabilities=${UE_CAPABILITIES}

UE.Init_MTK_With_Retry
    ${status}   Run Keyword And Return Status    MTKUE.init_mtk
    Run keyword if    '${status}'=='False'    Run Keywords    UE.Power_Reset
    ...    AND    MTKUE.init_mtk

UE.Power_Reset
    facom.PowerOnOff    pdu_ip=${MTK_FACOM_IP}    Port_Number=${MTK_FACOM_PORT}    Action=power_off
    facom.PowerOnOff    pdu_ip=${MTK_FACOM_IP}    Port_Number=${MTK_FACOM_PORT}    Action=power_on
    sleep    60s

Check_And_Require_MTK
    UE.Require_With_Retry
    UE.Init_MTK_With_Retry

COAM.GetParameterValue
    [Arguments]    ${dist_name}   ${filter_param}    ${abbr}
    ${value}   Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}    abbr=${abbr}
    [Return]       ${value}

COAM.SetParameterValue
    [Arguments]    ${dist_name}    ${filter_param}    ${new_value}    ${abbr}
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}    new_value=${new_value}    abbr=${abbr}

COAM.ValidateAndActiveParameters
    ${error}    selenium_coam.validate_plan
    log    ${error}
    Run Keyword And Ignore error    selenium_coam.activate_plan    activate_plan_despite_errors=True

Wireshark.Check NG InitialUEMessage
    Run Keyword And Continue On Failure    Wireshark.CheckExpression   expression=ngap.procedureCode == 15

Wireshark.Check UE context release complete
    ${value} =  Wireshark.GetElementValue   check_param=ngap.UEContextReleaseComplete_element
    Should Not Be Empty  ${value}

COAM_WEBEM.CheckBTSConutersWithConditioanalTraget
    [Arguments]    ${counter_id}   ${target_value}
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_bts_counters_info   counter_id=${counter_id}
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    should be true     ${values[-1]}>=${target_value}

Reset gNB if Not Ready
    Power.ResetgNB
    ${gNB_on_air}    run keyword and return status    wait until keyword succeeds   6x   5min   COAM_VerifyOnAirViaFrontendAndBackend
    run keyword if  not ${gNB_on_air}    fail    msg=gnb is not on air!

Connect MTK CtrlPC
    ssh.connect to    hostname=${MTK_CtrlPC_IP}   username=${MTK_CtrlPC_USERNAME}  password=${MTK_CtrlPC_PASSWORD}  alias=MTK_CPC

Disconnect MTK CtrlPC
    ssh.disconnect    connection=MTK_CPC

Powercycle MTK
    no operation   # TAF interface needed. MTK is powered via USB, any command available to make a powercycle?



Reserve ue for tests
    [Arguments]    ${UE_alias}=UE_1    ${UE_CAPABILITIES}=REAL_MEDIATEK_UE
    ute_ue.require Ue    ${UE_alias}    capabilities=${UE_CAPABILITIES}

Process.Ue Attach
#    Wait until keyword succeeds    2x    10s    MTK.UE Attach
    MTK.UE Attach
    #Verify if UE registered to AMF

MTK.UE Attach
    [Arguments]    ${UE_alias}=UE_1
#    Run Keyword And Ignore Error    Process.Ue Deteach
    Clear UE info from AMF with Retry
    ute_ue.register    ${UE_alias}
    ${res}    MTKUE.collect_ota_message_until    expected=5GMM_REGISTRATION_COMPLETE    wait_timeout=${120}
    should contain    ${res}    5GMM_REGISTRATION_COMPLETE

Clear UE info from AMF with Retry
   [Arguments]  ${ue_imsi}=${IMSI}   ${retry_times}=2
    FOR    ${i}    IN RANGE    ${retry_times}
        Clear UE info from AMF
    END
    Log    UeAttach retry for ${i + 1} times.

Clear UE info from AMF
   [Arguments]  ${ue_imsi}=${IMSI}   ${retry_times}=2
   Connect to 5GC
   ${imsi_presence}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi} 2> /dev/null| head -n 7 | grep GENERALINFO
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
#   ${output}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep amfCmState  connection=${ALIAS_5GC}
#   should contain   ${output}   CONNECTED
   Disconnect from 5GC

Check UE status from AMF
   [Arguments]  ${ue_imsi}=${IMSI}
   Connect to 5GC
   ${UE_Status}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}  connection=${ALIAS_5GC}
   ${RM_Status}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep amfRmState   connection=${ALIAS_5GC}
   ${CM_Status}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep amfCmState  connection=${ALIAS_5GC}
   ${PDN_Status}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep pnd  connection=${ALIAS_5GC}
   Log   ${UE_Status}
   Log   ${RM_Status}
   Log   ${CM_Status}
   Log   ${PDN_Status}

   Disconnect from 5GC

Connect to 5GC
    csn.connect to    ${5GC_IP}  ${5GC_USERNAME}  ${5GC_PASSWORD}    alias=${ALIAS_5GC}

Disconnect from 5GC
    csn.disconnect    connection=${ALIAS_5GC}

Wireshark.StopCapturingALLlog
    ssh.send command   command=ps -ef|grep tcpdump|grep -v grep|grep fp0|awk '{print $2}'|xargs kill -2   connection=${ALIAS_ASIK}
    ${pid}  ssh.execute   command=lxc-attach -n 0xe004 -- ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'  connection=${ALIAS_ASIK}
    ssh.execute   command=lxc-attach -n 0xe004 -- kill -2 ${pid.replace('\r\n','')}   connection=${ALIAS_ASIK}

Process.Start DL Traffic
    [Arguments]    ${Expected_Tput}=22Mbits/sec    ${DT_Name}=dt1_dl    ${UE_alias}=UE_1    ${direction}=dl    ${Duration}=90s    ${Data_Type}=udp
    ...    ${Packet_Size}=1024
    ute_ue.start_data_transfer    dt_name=${DT_Name}    ue_alias=${UE_alias}    direction=${direction}    throughput=${Expected_Tput}
    ...    duration=${Duration}    protocol=${Data_Type}    packet_size=${Packet_Size}

Wireshark.DownloadLogFromContainerToUTE
    [Arguments]    ${filename}    ${remote_dir}=/tmp
    ssh.download_file   local_path=${LOG_PATH}/${filename}    remote_path=${remote_dir}/${filename}   connection=${ALIAS_ASIK}
    sleep    20s

Proess.Start UL Traffic
    [Arguments]    ${Expected_Tput}=6Mbits/sec    ${DT_Name}=dt1_ul   ${UE_alias}=UE_1    ${direction}=ul    ${Duration}=90s    ${Data_Type}=udp
    ...    ${Packet_Size}=1024
    ute_ue.start_data_transfer    dt_name=${DT_Name}    ue_alias=${UE_alias}    direction=${direction}    throughput=${Expected_Tput}
    ...    duration=${Duration}    protocol=${Data_Type}    packet_size=${Packet_Size}

GetULBlerAndTP
    [Arguments]    ${ULThroughput}=${UL_TP}    ${Percentage}=10
    Conn.ConnectWithTimeout    ${ALIAS_ASIK}
    Conn.ConnectToLoner    ${ALIAS_LONER}
    Conn.ConnectToAsp1a    ${ALIAS_ASP_1A}
    ${uTP}      Run Keyword And Continue On Failure   gNB.GetULThroughput   ${ALIAS_ASP_1A}    10
    Conn.Disconnect    ${ALIAS_ASP_1A}
    Conn.Disconnect    ${ALIAS_LONER}
    Conn.Disconnect    ${ALIAS_ASIK}
    ${ULPercent}    Run Keyword And Continue On Failure    Evaluate    ${uTP}*${100}/${ULThroughput}
    Set Test Variable    ${ULPercent}
    Set Test Variable    ${uTP}
    Run Keyword And Continue On Failure     Should be true    ${ULPercent}>${Percentage}

GetDLBlerAndTP
    [Arguments]    ${DLThroughput}=6    ${Percentage}=10
    Conn.ConnectWithTimeout    alias=${ALIAS_ASIK}
    Conn.ConnectToLoner    alias=${ALIAS_LONER}
    Conn.ConnectToAsp1a    alias=${ALIAS_ASP_1A}
    ${dTP}    gNB.GetDLThroughput    ALIAS_ASP_1A=${ALIAS_ASP_1A}    location=${16}
    Conn.Disconnect    alias=${ALIAS_ASP_1A}
    Conn.Disconnect    alias=${ALIAS_LONER}
    Conn.Disconnect    alias=${ALIAS_ASIK}
    ${DLPercent}    Evaluate    ${dTP}*${100}*${1000}*${1000}/${DLThroughput}
    Set Test Variable    ${DLPercent}
    Set Test Variable    ${dTP}
    Should be true    ${DLPercent}>${Percentage}



TestSuilt.Init
    Create Log Directories
    set suite variable      ${Log_PATH_Artifactory}    /root/workspace/CIT/Master/Case_Logs/
    set suite variable   ${OAM_TYPE}    COAM
    set suite variable    ${TP_FILE}    ${LOG_PATH}/tp.txt
    Run Keyword And Ignore Error    run    rm ${TP_FILE}
    Conn.ResetCache
    Powercycle MTK

TestSuilt.Destroy
    Run Keyword And Ignore Error    run    cat ${TP_FILE}
    TestSuite.Stop


TestCase.Init
    [Arguments]    ${mcs}=0
    TestCase.Start
    Start BTSlogs Collection
    Run keyword If    ${mcs}==0    SetTestVariables    mcs=0    ul=6M    dl=22M
    Run keyword If    ${mcs}==16   SetTestVariables    mcs=16    ul=64M    dl=248M
    Run keyword If    ${mcs}==20    SetTestVariables    mcs=20    ul=83M    dl=323M
    Run keyword If    ${mcs}==21    SetTestVariables    mcs=21    ul=91M    dl=352M
    Run keyword If    ${mcs}==26    SetTestVariables    mcs=26    ul=129M    dl=495M
    Run keyword If    ${mcs}==27    SetTestVariables    mcs=27    ul=134M    dl=516M
    Run keyword If    ${mcs}==28    SetTestVariables    mcs=28    ul=140M    dl=536M

TestCase.Destory
    [Arguments]   ${connection}=COAM
    Run Keyword And Ignore Error    Stop BTSlogs Collection and get logs
    Run Keyword And Ignore Error    Backup current SCF
    gNB.Connect
    Run Keyword And Ignore Error    kill GNB wireshark process
    log     ${TEST STATUS}
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    Collect logs
    #Run Keyword And Ignore Error    Clean GNB wireshark log
    Run Keyword And Ignore Error    kill admin process
    Run Keyword And Ignore Error    run   command=killall firefox
    Conn.ResetCache
    TestCase.Stop

kill admin process
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9

Collect logs
    ${gNB_logName}=    catenate    SEPARATOR=_    ${TEST NAME.replace(" ", "_")}   gNB.log
    Run Keyword And Ignore Error    gnb.collectlog    ${gNB_logName}
    Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    Collect snapshot via webui

Backup current SCF
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    coam.get_current_scf_file   local_dir_path=${LOG_PATH}   file_name=${TEST NAME.replace(" ", "_")}.xml   connection=COAM   timeout=10
    COAM_Admin.Logout


kill GNB wireshark process
    Run Keyword And Ignore Error    ssh.execute    command=killall -2 tcpdump    connection=${ALIAS_ASIK}
    Run Keyword And Ignore Error    ssh.execute    command=lxc-attach -n 0xe004 -- killall -2 tcpdump    connection=${ALIAS_ASIK}


Collect snapshot via webui
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}

SetTestVariables
    [Arguments]    ${mcs}=0    ${ul}=6    ${dl}=22
    Set Test Variable    ${mcs}
    Set Test Variable    ${UL_TPUT}    ${ul}
    Set Test Variable    ${DL_TPUT}    ${dl}
    ${expect_ul}    Evaluate    ${UL_TPUT[:-1]}*1000*1000
    Set Test Variable    ${expect_ul}
    ${expect_dl}    Evaluate    ${DL_TPUT[:-1]}*1000*1000
    Set Test Variable    ${expect_dl}

#CollectLogs
#    Log    collect all log ${TEST NAME}
#    ${tm}    Get Current Date
#    ${tm}=    Remove String    ${tm.replace(' ','-')}    .    :
#    ${gNB_logName}=    catenate    SEPARATOR=_    ${TEST NAME.replace(" ", "_")}   gNB-${tm}.log
#    Run Keyword And Ignore Error    gnb.collectlog    ${gNB_logName}
#    Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
#    Run Keyword And Ignore Error    Wireshark.DownloadLogToUTE   filename=NG.pcap
#    Run Keyword And Ignore Error    Wireshark.DownloadLogFromContainerToUTE    filename=CPIF.pcap   remote_dir=/tmp/node_0xe004/tmp
#    Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
##    run keyword and ignore error    MTK.Collect log
#    Conn.ResetCache

Start BTSlogs Collection
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf BTSLOG_TRACE_*.bin ; rm -rf SYSLOG_*.LOG
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    btslog.Set Global Alias     btslog
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog

Stop BTSlogs Collection and get logs
    core.stop_collectors      names=btslog
    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz SYSLOG_combine.LOG
    run    command=cp /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz ${LOG_PATH}


#############################################################################


Process.GetDLBlerAndTP
    [Arguments]    ${DLThroughput}=10000000    ${Percentage}=10
    Conn.ConnectWithTimeout    ${ALIAS_ASIK}
    #Conn.ConnectToLoner    ${ALIAS_LONER}
    Conn.ConnectToAsp1a    ${ALIAS_ASP_1A}
    ${dTP}    Run Keyword And Continue On Failure  gNB.GetDLThroughput    ${ALIAS_ASP_1A}  10
    Conn.Disconnect    ${ALIAS_ASP_1A}
    #Conn.Disconnect    ${ALIAS_LONER}
    Conn.Disconnect    ${ALIAS_ASIK}
    ${DLPercent}    Run Keyword And Continue On Failure    Evaluate    ${dTP}*${100}*${1000}*${1000}/${DLThroughput}
    Set Test Variable    ${DLPercent}
    Set Test Variable    ${dTP}
    Run Keyword And Continue On Failure    Should be true    ${DLPercent}>${Percentage}

Close Wireshark on ute
    Conn.ConnectWithTimeout    alias=${ALIAS_UTE}
    ssh.execute     command=ps -ef|grep -i wireshark    connection=${ALIAS_UTE}
    ssh.send command    command=killall wireshark     connection=${ALIAS_UTE}
    Conn.Disconnect      alias=${ALIAS_UTE}
    sleep  2s

Wireshark.Download_Pcap
    [Arguments]  ${NG_case.pcap}    ${alias}
    ASIK.Connect  alias=${alias}
    Wireshark.StopCapturinglog
    Wireshark.DownloadLogToUTE    filename=${NG_case.pcap}  alias=${alias}
    ASIK.Disconnect  alias=${alias}

#Wireshark.DownloadLogToUTE
#    [Arguments]    ${filename}  ${alias}
#    ssh.download_file   local_path=${LOG_PATH}/${filename}    remote_path=/tmp/${filename}   connection=${alias}
#    sleep    20s

ASIK.Connect
    [Arguments]   ${alias}
    Run Keyword And Continue On Failure  ssh.Connect to   ${ASIK_IP}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}   alias=${alias}
ASIK.Disconnect
     [Arguments]   ${alias}
    Run Keyword And Continue On Failure  Conn.Disconnect    ${alias}
