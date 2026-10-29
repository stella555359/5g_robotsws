*** Settings ***
Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.epcsim    WITH NAME    epc
Library    taf.hw.rf_attenuator    WITH NAME    attenuator
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.btslog  WITH NAME   btslog
Library    Telnet  WITH NAME   telnets
Library    taf.pdu
Library    XML  lxml=True
Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
#Library    ../../../../RRM/Hangzhou/libraries/L3Call.py
Library    taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource   taf/rfrl/common_resources/robot/gnb_classical.robot
#Library    MTKUE_extend.MTKUE    WITH NAME   MTKUE
Library    taf.ue    WITH NAME    ute_ue
Library    taf.ul.messaging.mtk      WITH NAME    mtk
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ru_soap_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
#Resource    ../../../Wroclaw/TestCases/RF_Faults/General_SiSo_Auto_Automatic_RAT_SW_upgrade.robot
#Resource    ../../5GC001274/Resources/5GC001274_1157_common.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001795/Resources/5GC001795_common.robot
#Resource    ../../common/RRH_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot

Documentation
...    author: Jack.zeng
...    contact:jack.zeng@nokia-sbell.com
...    squad group: 5G_PZ_HZ_3_SG
...    feature : 5GC001707

*** Variables ***
${appserver_addr}    ${tl.appserver.iperf_details.ssh_connection_details.addr}
${appserver_username}    ${tl.appserver.iperf_details.ssh_connection_details.username}
${appserver_password}    ${tl.appserver.iperf_details.ssh_connection_details.password}
${ASIK_LMP_IP}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}        ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${DL_PORT}      ${tl.ues[0].iperf_details.port}
${ul_time}    80s
${ul_length}    1024B
${ul_throughput}     10
${UL_PORT}     ${tl.appserver.iperf_details.port}
${dl_time}    80s
${dl_length}    1024B
${dl_throughput}    10
${epc_log_path}    /home/ute/SQ3project/cit
&{fault_61524}    faultId=${61524}    source=SMOD_R-1    #faultId:SSH_ENABLED  source:RU1
&{fault_61652}    faultId=${61652}    source=SMOD_R-1    #faultId:R&D_SERVICE_PORT_ENABLED  source:RU1
&{fault_7319}    faultId=${7319}    source=NRBTS     #faultId:EFaultId_X2LinkNotAvailableAl
&{fault_7300}    faultId=${7300}    source=NRBTS     #faultId:EFaultId_NoneX2LinkAvailableAl
@{ALLOWED_FAULT_LIST}    &{fault_61524}    &{fault_61652}
${atten_ip}    ${tl.attenuator[0].ip_addr}
${att_port_1}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4}                ${tl.attenuator[0].attenuator_ports[4]}
${att_api_port}              ${tl.attenuator[0].port}
${vendor}                    HBTE
${vendor1}                   TOPYOUNG
${max_attenuation_value}     ${127}
${5GRU1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5GRU1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${5GRU1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${5GRU2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5GRU2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${NRBTS_id}       NRBTS-${tl.gnbs[0].instance_id}
${TS_LOG_PATH_BASE}      /opt/workspace/CIT/Master/Case_Logs
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_ADDR}        ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WebUI_User}        ${WEBUI_NAME}
${WebUI_Password}    ${WEBUI_PWD}
${ENB_ADDRESS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${SN}    ${tl.ues[0].serial_number}
${gnb_path}    /tmp/
${iperf_path}    ${tl.ues[0].iperf_details.iperf_path}
${TESTLINE_NAME}    7_5_CLOUD402T0${tl.enbs[0].instance_id}
${enbx2_dist}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNADJGNB-1
${enbx2_para}    administrativeState
${f1_sctp_port}    38472
${x2_sctp_port}    36422
${enb_path}    /user/toor4nsn
${5G_QXDM_PATH}    C:/MyDrivers/software/QXDM88
${QCAT_EXE_PATH}    "C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe"
# alias
${ASIK_ALIAS}                    ASIK Master
${ENB_ALIAS}                     enblte
${GNB_COAM_ALIAS}                GNB_OAM
${ABIL_MASTER_ALIAS}             ABIL Master
${alias_master}    ASIK Master
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
@{rdparameter}    0x1003F=1    0x10040=1
${SUT_IP}         ${tl.gnbs[0].dus[0].rus[2].default_ssh_connection_details.addr}
${SUT_NAME}       ${tl.gnbs[0].dus[0].rus[2].default_ssh_connection_details.username}
${SUT_PWD}        ${tl.gnbs[0].dus[0].rus[2].default_ssh_connection_details.password}
*** Keywords ***
Prepare the atten for 20A Qualcomm Env
    Adjust the Attenuation Value    ports=${5GRU1_ANT1}    value=${3}
    Adjust the Attenuation Value    ports=${5GRU1_ANT2}    value=${3}
    Adjust the Attenuation Value    ports=${5GRU1_ANT3}    value=${3}
    Adjust the Attenuation Value    ports=${5GRU1_ANT4}    value=${3}

Setup Case
    [Arguments]    ${mcs}=0
    Run keyword If    ${mcs}==0    SetTestVariables    mcs=0    ul=2M    dl=16M
    Run keyword If    ${mcs}==16   SetTestVariables    mcs=16    ul=16M    dl=248M
    Run keyword If    ${mcs}==20    SetTestVariables    mcs=20    ul=24M    dl=360M
    Run keyword If    ${mcs}==21    SetTestVariables    mcs=21    ul=26M    dl=390M
    Run keyword If    ${mcs}==26    SetTestVariables    mcs=26    ul=36M    dl=500M
    Run keyword If    ${mcs}==27    SetTestVariables    mcs=27    ul=40M    dl=540M
    Run keyword If    ${mcs}==28    SetTestVariables    mcs=28    ul=48M    dl=560M

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
     Conn.Execute  cmd=cd ${elt_path}${/}Temp;ls |grep "\.tmp" |xargs rm -rf  alias=MTK_CPC
     Disconnect MTK CtrlPC

SetTestVariables
    [Arguments]    ${mcs}=0    ${ul}=6    ${dl}=22
    Set Test Variable    ${mcs}
    Set Test Variable    ${UL_TPUT}    ${ul}
    Set Test Variable    ${DL_TPUT}    ${dl}
    ${expect_ul}    Evaluate    ${UL_TPUT[:-1]}*1000*1000
    Set Test Variable    ${expect_ul}
    ${expect_dl}    Evaluate    ${DL_TPUT[:-1]}*1000*1000
    Set Test Variable    ${expect_dl}

facom.PowerOnOff
    [Arguments]    ${pdu_ip}    ${Port_Number}    ${Action}=power_off
    taf.pdu.Setup Pdu    host=${pdu_ip}    model=FACOM
    Run Keyword If    '${Action}'=='power_off'    taf.pdu.power_off    port=${Port_Number}
    ...    ELSE    taf.pdu.power_on    port=${Port_Number}
    sleep   15s
    ${state}    taf.pdu.get_port_status    port=${Port_Number}
    Run Keyword If    '${Action}'=='power_off'    should be equal    ${state}    off
    ...    ELSE    should be equal    ${state}    on

Restart UE Control PC
    [Documentation]  To reset te UE control pc which is windows system.
    [Arguments]    ${ue_index}=${0}
    Connect to UE control pc enhanced    ue_index=${ue_index}
    csn.Send Command    command=shutdown -r -t 3     connection=cpc_${ue_index}    timeout=5
    csn.disconnect      connection=cpc_${ue_index}

Connect to UE control pc enhanced
    [Documentation]  This keyword's is to connect to the UE control PC, add WA to restart the ssh servers.
    [Arguments]    ${ue_index}=${0}   ${telnet}=${true}
    ${cpc_ip} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ${cpc_usrname} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.username}
    ${cpc_passwd} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.password}
    ${cpc_status}    run keyword and return status      Connect to control pc
    ...     cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}    alias=cpc_${ue_index}
    run keyword if    '${cpc_status}'=='False' and ${telnet}
    ...               restart cpc sshd services    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    run keyword if    '${cpc_status}'=='False' and ${telnet}      Connect to control pc
    ...         cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}    alias=cpc_${ue_index}

restart cpc sshd services
    [Documentation]  Start the sshd server, with sometimes reset the control pc system,
    ...  the sshd server not work.
    [Arguments]    ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}
    telnets.Open connection    ${cpc_ip}
    telnets.set timeout    20 s
    telnets.Login    username=${cpc_usrname}    password=${cpc_passwd}    login_timeout=10 s    password_prompt=password:
    telnets.Write    text=sc stop cygsshd
    sleep    5s
    telnets.Write    text=sc config cygsshd start= Auto
    sleep    5s
    telnets.Write    text=sc start cygsshd
    sleep    5s
    telnets.close connection
    sleep    5s

#  ### MTK side Operation ###
Powercycle MTK
    FGCR_4454_common_KW.facom.PowerOnOff    pdu_ip=${PB_MTK_IP}    Port_Number=${PB_MTK_PORT}    Action=power_off
    sleep    5s
    FGCR_4454_common_KW.facom.PowerOnOff    pdu_ip=${PB_MTK_IP}    Port_Number=${PB_MTK_PORT}    Action=power_on
    sleep    60s

Connect MTK CtrlPC
    ssh.connect to    hostname=${MTK_CtrlPC_IP}   username=${MTK_CtrlPC_USERNAME}  password=${MTK_CtrlPC_PASSWORD}  alias=MTK_CPC

Disconnect MTK CtrlPC
    ssh.disconnect    connection=MTK_CPC

Reserve ue for Make L3 call
    [Documentation]   applicalbe for both QC and MTK
    ...     UE_CAPABILITIES: default value is for MTK,  For Qualcomm UE, REAL_ANDROID_UE is the correct value.
    [Arguments]    ${UE_alias}=UE_1    ${UE_CAPABILITIES}=REAL_MEDIATEK_UE
    [Timeout]      10min
    ute_ue.require Ue    ue_alias=${UE_alias}    capabilities=${UE_CAPABILITIES}

MTK.Reserve ue for tests_With_Retry
    [Documentation]   Only applicalbe for MTK.  This is to workaround the issue of MTK unstale ports.
    [Arguments]    ${UE_alias}=UE_1    ${UE_CAPABILITIES}=REAL_MEDIATEK_UE
    ${status}   Run Keyword And Return Status    Reserve ue for Make L3 call    UE_alias=${UE_alias}
    ...            UE_CAPABILITIES=${UE_CAPABILITIES}
    run keyword if  not ${status}    Run Keywords    Powercycle MTK
    ...    AND    Reserve ue for Make L3 call    UE_alias=${UE_alias}    UE_CAPABILITIES=${UE_CAPABILITIES}
    mtk.Setup    pyro_ip=${tl.ues[0].ssh_connection_details.addr}    pyro_port=${tl.ues[0].server_port}
    mtk.Create Message Flow Alias    flow_alias=MTK_OTA_MESSAGE    message_type=ota_text

MTK.UE Attach
    [Arguments]    ${UE_alias}=UE_1
    ute_ue.attach_ue    ue_alias=${UE_alias}
    Sleep    3
    Expect MTK Attach Messages

Expect MTK Attach Messages
    ${Attach Expected Messages} =    Create List     ERRC_RRCConnectionReconfigurationComplete
    mtk.Expect Messages in Flow    awaited_messages=${Attach Expected Messages}    flow_alias=MTK_OTA_MESSAGE

UE Attach and Start data transfer with Log Capturing
    [Documentation]   Only applicalbe for MTK, capturing all needed wireshark logs durig L3 call for further analysis
    [Arguments]    ${connection}=${ALIAS_ASIK}    ${UE_alias}=UE_1    ${Duration}=300s
    [Timeout]      20min
    gNB.Connect
    sleep    5s
    ${UE_Attach}    run keyword and return status     FGCR_4454_common_KW.MTK.UE Attach   UE_alias=${UE_alias}
    run keyword if    ${UE_Attach}    Run Keyword And Continue On Failure    Start DL Traffic     UE_alias=${UE_alias}
    ...     Expected_Tput=${DL_TPUT}bits/sec    Duration=${Duration}
    run keyword if   ${UE_Attach}   Run Keyword And Continue On Failure   Start UL Traffic   UE_alias=${UE_alias}
    ...    Expected_Tput=${UL_TPUT}bits/sec     Duration=${Duration}
    sleep    30s
    should be true   ${UE_Attach}

Start DL Traffic
    [Arguments]    ${Expected_Tput}=22Mbits/sec    ${DT_Name}=dt1_dl    ${UE_alias}=UE_1    ${direction}=dl    ${Duration}=90s
    ...    ${Data_Type}=udp    ${Packet_Size}=1024
    ute_ue.start_data_transfer    dt_name=${DT_Name}    ue_alias=${UE_alias}    direction=${direction}    throughput=${Expected_Tput}
    ...    duration=${Duration}    protocol=${Data_Type}    packet_size=${Packet_Size}

Wireshark.DownloadLogFromContainerToUTE
    [Arguments]    ${filename}    ${remote_dir}=/tmp
    ssh.download_file   local_path=${LOG_PATH}${/}${filename}    remote_path=${remote_dir}${/}${filename}   connection=${ALIAS_ASIK}
    sleep    20s

Start UL Traffic
    [Arguments]    ${Expected_Tput}=6Mbits/sec    ${DT_Name}=dt1_ul   ${UE_alias}=UE_1    ${direction}=ul
    ...    ${Duration}=90s    ${Data_Type}=udp    ${Packet_Size}=1024
    ute_ue.start_data_transfer    dt_name=${DT_Name}    ue_alias=${UE_alias}    direction=${direction}
    ...    throughput=${Expected_Tput}    duration=${Duration}    protocol=${Data_Type}    packet_size=${Packet_Size}

Evaluate DL ThroughPut
    ${res}  run keyword and return status    GetDLBlerAndTP    DLThroughput=${expect_dl}    Percentage=${DL_EXPECTED_PRECENT}
    log    ${res}
    Run Keyword If    ${res}    log    Test Passed
    ...    ELSE    Fail    Test Failed

Evaluate UL ThroughPut
    ${res}    Run Keyword And Return Status    GetULBlerAndTP    ULThroughput=${expect_ul}    Percentage=${UL_EXPECTED_PRECENT}
    log    ${res}
    Run Keyword If    ${res}    log    Test Passed
    ...    ELSE    Fail    Test Failed

gNB.Conn.ConnectWithTimeout
    [Arguments]    ${alias}
    Wait Until Keyword Succeeds    10min    30sec    gNB.Conn.Connect   alias=${alias}

gNB.Conn.Connect
    [Arguments]    ${alias}
    Run Keyword If    '${alias}'=='${ALIAS_ASIK}'    ssh.Connect to    hostname=${ASIK_IP}    username=${ASIK_USERNAME}
    ...          password=${ASIK_PASSWORD}            alias=${ALIAS_ASIK}
    ...    ELSE IF    '${alias}'=='${ALIAS_ASIK_SLAVE}'  ssh.Connect to  hostname=${FCT_IP}  username=${ASIK_USERNAME}
    ...          password=${ASIK_PASSWORD}        alias=${ALIAS_ASIK_SLAVE}  proxy=${ALIAS_ASIK}
    ...    ELSE IF    '${alias}'=='${ALIAS_UTE}'    ssh.Connect to    hostname=${UTE_IP}    username=${UTE_USERNAME}
    ...          password=${UTE_PASSWORD}           alias=${ALIAS_UTE}
    ...    ELSE IF    '${alias}'=='${ALIAS_ENBCTLPC}'    ssh.Connect to   hostname=${ENBCTLPC_IP}   username=${ENBCTLPC_USERNAME}
    ...            password=${ENBCTLPC_PASSWORD}      alias=${ALIAS_ENBCTLPC}
    ...    ELSE IF    '${alias}'=='${ALIAS_SHP}'    ssh.Connect to  hostname=${SHP_IP}  username=${ASIK_USERNAME}
    ...            password=${ASIK_PASSWORD}    alias=${ALIAS_SHP}
    ...    ELSE IF    '${alias}'=='${ALIAS_E500}'    ssh.Connect to  hostname=${E500_IP}  username=${E500_USERNAME_DOMAIN}
    ...            password=${E500_PASSWORD}      alias=${ALIAS_E500}
    ...    ELSE IF    '${alias}'=='${ALIAS_PRISMA}'    ssh.Connect to  hostname=${PRISMA_IP}  username=${PRISMA_USERNAME}
    ...            password=${PRISMA_PASSWORD}   alias=${ALIAS_PRISMA}
    ...    ELSE IF    '${alias}'=='${ALIAS_QC}'    ssh.Connect to  hostname=${QC_IP}  username=${QC_USERNAME}
    ...            password=${QC_PASSWORD}   alias=${ALIAS_QC}
    ...    ELSE    Fail    Unknow alias

gNB.Conn.ConnectToAsp1a
    [Arguments]    ${alias}=ASP_1A
    ssh.force_reconnect    connection=${ALIAS_ASIK}
    ssh.Connect to    hostname=${ASP_1A_IP}    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}
    ...                alias=${alias}   proxy=${ALIAS_ASIK}

gNB.Conn.Disconnect
    [Arguments]    ${alias}
    ssh.disconnect    connection=${alias}

GetDLThroughput
    [Arguments]    ${ALIAS_ASP_1A}=ASP_1A    ${duration}=30    ${location}=${17}
    ${DL_TP}   Get_And_Calculate_DL_throughput    alias=${ALIAS_ASP_1A}    duration=${duration}    location=${location}
    [Return]    ${DL_TP}

GetULBlerAndTP
    [Arguments]    ${ULThroughput}=6    ${Percentage}=90
    [Timeout]      10min
    gNB.Conn.ConnectWithTimeout    alias=${ALIAS_ASIK}
    gNB.Conn.ConnectToAsp1a    alias=${ALIAS_ASP_1A}
    ${uTP}    GetULBlerAndThroughputCoam    ALIAS_LONER=${ALIAS_LONER}    ALIAS_ASP_1A=${ALIAS_ASP_1A}    duration=40
    gNB.Conn.Disconnect    alias=${ALIAS_ASP_1A}
    gNB.Conn.Disconnect    alias=${ALIAS_ASIK}
    ${ULPercent}    Evaluate    ${uTP}*${100}*${1000}*${1000}/${ULThroughput}
    Set Test Variable    ${ULPercent}
    Set Test Variable    ${uTP}
    Should be true    ${ULPercent}>${Percentage}

GetDLBlerAndTP
    [Arguments]    ${DLThroughput}=6    ${Percentage}=90
    [Timeout]      10min
    gNB.Conn.ConnectWithTimeout    alias=${ALIAS_ASIK}
    gNB.Conn.ConnectToAsp1a    alias=${ALIAS_ASP_1A}
    ${dTP}    GetDLThroughput    ALIAS_ASP_1A=${ALIAS_ASP_1A}   duration=30    location=${16}
    gNB.Conn.Disconnect    alias=${ALIAS_ASP_1A}
    gNB.Conn.Disconnect    alias=${ALIAS_ASIK}
    ${DLPercent}    Evaluate    ${dTP}*${100}*${1000}*${1000}/${DLThroughput}/2
    Set Test Variable    ${DLPercent}
    Set Test Variable    ${dTP}
    Should be true    ${DLPercent}>${Percentage}

GetULBlerAndThroughputCoam
    [Arguments]    ${ALIAS_LONER}=LONER    ${ALIAS_ASP_1A}=ASP_1A    ${duration}=30
    ${UL_TP}   Get_And_Calculate_UL_throughput   alias=${ALIAS_ASP_1A}   duration=${duration}
    [Return]   ${UL_TP}

gNB.Close iperf progress
    [Arguments]
    Set Test Variable    ${appserver_addr}    ${tl.appserver.iperf_details.ssh_connection_details.addr}
    Set Test Variable    ${appserver_username}    ${tl.appserver.iperf_details.ssh_connection_details.username}
    Set Test Variable    ${appserver_password}    ${tl.appserver.iperf_details.ssh_connection_details.password}
    Set Test Variable    ${dl_port}    ${tl.ues[0].iperf_details.port}
    Set Test Variable    ${ul_port}    ${tl.appserver.iperf_details.port}
    Close the iperf process on APPserver    port=${dl_port}
    Close the iperf process on APPserver    port=${ul_port}

Common Suite Setup for COAM
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}     ${LOG_PATH}/${time_stamp}/
    Create directory    path=${epc_log_path}

Common Suite Teardown for COAM
    Connect to gnb coam via ssl
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    COAM Teardown gnb connections

Prepare the classical COAM BTS cell onair
    [Arguments]    ${cell_no}=1
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error
    ...      Prepare with COAM classical BTS cell onair with cell_no    cell_no=${cell_no}
    set suite variable    ${cell_status}

Prepare with COAM classical BTS cell onair with cell_no
    [Arguments]    ${cell_no}=1
    Perform full commission for COAM gnb
    Restart UE Control PC
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    #Check gnb COAM classical start normally
    sleep     30
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    Get Cell num and RU num
#    Run keyword and ignore error    Check the gnb cell status onair    cell_no=${cell_no}


Check the gnb cell status onair
    [Arguments]    ${gnb_ip}=${WEBUI_COAM}    ${cell_no}=1
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${gnb_ip}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    wait until keyword succeeds    10min    30s    Get all cell info    cell_no=${cell_no}
    [Teardown]    selenium_coam.logout

Get all cell info
    [Arguments]    ${cell_no}
    FOR   ${cell_idx}    IN RANGE    1    ${cell_no}
        Get cell info    cell_idx=${cell_idx}
    END

Get cell info
    [Arguments]    ${cell_idx}=1
    ${cell_status} =    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    Get info status check    info_status=${cell_status}

Adjust the Attenuation Value
    [Arguments]     ${ports}    ${value}    ${attenuation_port_numbers_oneport}=${ports}
    ...     ${atten_ip}=${atten_ip}    ${att_api_port}=${att_api_port}    ${vendor}=${vendor1}
    @{attenuation_port_numbers_oneport}    create list    ${attenuation_port_numbers_oneport}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers_oneport}   max_attenuation=${max_attenuation_value}
    ...    vendor=${vendor1}
    attenuator.set_attenuation     port=${ports}    value=${value}
    ${value_port_1}    attenuator.read_attenuation    port=${ports}
    should be equal    ${value_port_1}    ${value}
    sleep    5s

#Adjust the Attenuation Value
#    [Arguments]    ${ports}    ${value}
#    atten.connect to    ip=${atten_ip}
#    atten.set_value    channel=${ports}    value=${value}
#    atten.disconnect

Get info status check
    [Arguments]    ${info_status}
    ${Status} =   get from dictionary    dictionary=${info_status}    key=Status
#    ${opr_state} =   get from dictionary    dictionary=${Status}    key=Operational state
#    should be equal    first=${opr_state}    second=Enabled
    ${avi_state} =   get from dictionary    dictionary=${Status}   key=Availability status
    should be equal    first=${avi_state}    second=Online
    ${adm_state} =   get from dictionary    dictionary=${Status}    key=Administrative state
    should be equal    first=${adm_state}    second=Unlocked

Check gnb COAM classical start normally
    Check Airscale HW module status
    #wait until keyword succeeds    11min   30s    gNB.Check the sctp port UP    port_num=${f1_sctp_port}
    Check the gnb RU status ready
    wait until keyword succeeds    5min   30s    gNB.Check the sctp port UP    port_num=${x2_sctp_port}

gNB.Check the sctp port UP
    [Arguments]    ${port_num}
    Connect to BB1 master    alias=BB1
    csn.send Command    command=netstat -anl |grep sctp    connection=BB1
    sleep    3s
    ${sctp_status} =    csn.read_output    connection=BB1
    csn.disconnect     connection=BB1
    should contain    ${sctp_status}    ${port_num}

Check the gnb RU status ready
    Connect to gnb coam via ssl
    wait until keyword succeeds    5min   30s    COAM Check GNB RU status
    COAM Teardown gnb connections

Get Cell num and RU num
    [Arguments]    ${connection}=GNB_OAM
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Log to console    Get Cell num and RU num
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    ${cell_no}     RRH_common_keyword.COAM Get GNB CELL Number    connection=${connection}
    Set Suite Variable    ${cell_no}
    Set Suite Variable    ${count_RUs}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Perform All RU Reset
    FOR    ${ru_index}    IN RANGE    1    ${count_RUs}+1
        Wait Until Keyword Succeeds    240 sec    30 sec    Perform RU Reset    ru_index=${ru_index}
    END

Perform full commission for COAM gnb
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${tl_scf_filename}    is_pdl_checking_needed=${False}
    ...    timeout=1200
    COAM Teardown gnb connections
    sleep    time_=300s

Tests Recover
    FGCR_4454_common_KW.Tear down connections
    gNB.Close iperf progress

Tear down connections
    [Arguments]
    Run keyword and ignore error    coam_gnb_classical.COAM Teardown gnb connections
    Run keyword and ignore error    enb_lte.Enblte close down    connection=${ENB_ALIAS}
    Run keyword and ignore error    csn.Disconnect    connection=ABIL Loner_1
    Run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Run keyword and ignore error    csn.Disconnect    connection=RU_1
    Run keyword and ignore error    csn.Disconnect    connection=RU_2
    Run keyword and ignore error    csn.Disconnect    connection=RU_3
    Run Keyword And Ignore Error   csn.Reset Cache

adjust the HBTE attenuation value
    [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${value_4}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA value default value[0-63db] if not set the max_attenuation value below
    ...                for value plz set in your case level
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${att_port_1}    value=${value_1}
    attenuator.set_attenuation     port=${att_port_2}    value=${value_2}
    attenuator.set_attenuation     port=${att_port_3}    value=${value_3}
    attenuator.set_attenuation     port=${att_port_4}    value=${value_4}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value_1}
    ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_2}    ${value_2}
    ${value_port_3}    attenuator.read_attenuation    port=${att_port_3}
    should be equal    ${value_port_3}    ${value_3}
    ${value_port_4}    attenuator.read_attenuation    port=${att_port_4}
    should be equal    ${value_port_4}    ${value_4}
    sleep    5s

Precondition for power UE
    [Arguments]    ${ue_type}    ${ui_version}=default
    power_ue.Prepare UE    ue_type=${ue_type}     ui_version=${ui_version}      ue_index=${0}
    ...     capatibility_index=${0}    reset_sol=pc_reset    detach_request=${true}

Attach and check power UE
    [Arguments]    ${ue_type}    ${5Gstatus}=PASS
    Run Keyword And Ignore Error   csn.Reset Cache
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    5Gstatus=${5Gstatus}

Detach for power UE
    [Arguments]    ${ue_type}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

power UE.SetTestVariables
    [Arguments]    ${mcs}=0    ${ul}=6    ${dl}=22    ${DLTPpercent}=105    ${ULTPpercent}=100
    ${DL_TPUT1}     Evaluate     ${dl[:-1]}*110/100.00
    ${UL_TPUT1}     Evaluate     ${ul[:-1]}*110/100.00
    Set Test Variable    ${mcs}
    Set Test Variable    ${UL_TPUT}    ${UL_TPUT1}M
    Set Test Variable    ${DL_TPUT}    ${DL_TPUT1}M
    ${expect_ul}    Evaluate    ${ul[:-1]}*${ULTPpercent}/100.00/2
    Set Test Variable    ${expect_ul}
    ${expect_dl}    Evaluate    ${dl[:-1]}*${DLTPpercent}/100.00
    Set Test Variable    ${expect_dl}

Change SWconf
    Connect to BB1 master     alias=${alias_master}
    SWconfig.download_swConfig_file_from_asik_to_test_pc    localFilePath=${epc_log_path}swconfig.txt
    ...    asik_alias=${alias_master}
    SWconfig.modify_swConfig_file    parametersList=@{rdparameter}    filePath=${epc_log_path}swconfig.txt
    SWconfig.upload_swConfig_file_to_asik_and_crasign    localFilePath=${epc_log_path}swconfig.txt    asik_alias=${alias_master}

UE.Check throughput
    [Arguments]    ${ue_type}    ${direction}    ${throughput}    ${deviation}=10
    ...            ${ue_index}=${0}    ${dt_index}=${0}    ${ue_alias}=UE_${ue_index}    ${gnb_index}=${0}    ${du_index}=${0}
    ...            ${hw_slot}=${1}    ${sample}=${8}    ${start_offset}=${2}    ${sleep_time}=${10}    ${cellid}=${EMPTY}
    ...            ${log_type}=Aasyslog     ${retry}=10
    [Documentation]    Check throughput from started traffic.
    [Timeout]      30min
    Log to console    \nINFO:power_ue.Check throughput
    wait until keyword succeeds    ${retry}x   10s    power_ue.Check throughput     ue_type=${ue_type}
    #power_ue.Check throughput     ue_type=${ue_type}
    ...     direction=${direction}     throughput=${throughput}     cellid=${cellid}    sleep_time=${sleep_time}
    ...     deviation=${deviation}     ue_index=${ue_index}     dt_index=${dt_index}    ue_alias=$UE_${ue_index}
    ...     gnb_index=${gnb_index}     du_index=${du_index}     hw_slot=${hw_slot}    sample=${sample}
    ...     start_offset=${start_offset}     log_type=${log_type}

UE.traffic.Teardown
    Log to console    \nINFO:Stop traffic
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul     iperf_port=${ul_port}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl     iperf_port=${dl_port}
    Run keyword and ignore error    FGCR_4454_common_KW.Detach for power UE     ue_type=${ue_type}

Get parameter value
    [arguments]    ${dis_name}    ${filter_name}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${value}=    selenium_coam.get_parameter_value    dist_name=${dis_name}
    ...    filter_param=${filter_name}
    sleep    8s
    selenium_coam.logout
    [return]    ${value}

get nrCellid
    [arguments]    ${cellid}     ${nrbtsid}=1
    ${value}=    Get parameter value    dis_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${nrbtsid}/NRCELL-${cellid}
    ...    filter_name=NR Cell Identity
    [Return]    ${value}

locked LTE cell
    [arguments]    ${cellid}    ${eNBid}    ${BTS_PORT}=443     ${USE_SSL}=True    ${connection}=enblte
    enblte.connect_to    bts_host=${tl.enbs[1].airscale.common_units[0].lmp_connection.addr}
    ...    bts_port=${BTS_PORT}  use_ssl=${USE_SSL}    name=${connection}
    enblte.perform_parameter_recommissioning       dist_name=MRBTS-${eNBid}/LNBTS-${eNBid}/LNCEL-${cellid}
    ...                                            parameter=administrativeState
    ...                                            operation=update
    ...                                            value=locked
    ...                                            connection=enblte
    ...                                            skip_parameter_relation_errors=True
    enblte.teardown    connection=enblte
    sleep    10s

change FrameStructure
    [arguments]    ${lteToNrFrameShift}=0ms
    ...           ${bandwidth}=40MHz
    ...           ${prachIndex}=97
    ...           ${lteToNrTimeOffset}=0
    ...           ${slotRatio}=2/8
    ...           ${frame}=tdlte
    ...           ${guardPeriod}=4Symbols
    ...           ${tdLteUlDlConfig}=tdLteConfig2
    ...           ${nrarfcn}=512880
    ...           ${pMax}=38
    ...           ${cellId}=1
    ...           ${cellId2}=2
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    sleep    5s
    selenium_coam.set_parameter_value    dist_name=${NRBTS_id}/NRCELL-${cellId}
    ...                                  filter_param=LTE to NR frame shift
    ...                                  new_value=${lteToNrFrameShift}
    selenium_coam.set_parameter_value    dist_name=${NRBTS_id}/NRCELL-${cellId}
    ...                                  filter_param=Channel bandwidth
    ...                                  new_value=${bandwidth}
    selenium_coam.set_parameter_value    dist_name=${NRBTS_id}/NRCELL-${cellId}
    ...                                  filter_param=PRACH configuration index
    ...                                  new_value=${prachIndex}
    selenium_coam.set_parameter_value    dist_name=${NRBTS_id}/NRCELL-${cellId}
    ...                                  filter_param=Time offset between the LTE PCell and the NR cell
    ...                                  new_value=${lteToNrTimeOffset}
    selenium_coam.set_parameter_value    dist_name=${NRBTS_id}/NRCELL-${cellId}
    ...                                  filter_param=UL to DL logical data slot ratio
    ...                                  new_value=${slotRatio}
    selenium_coam.set_parameter_value    dist_name=${NRBTS_id}/NRCELL-${cellId}
    ...                                  filter_param=Guard Period length
    ...                                  new_value=${guardPeriod}
    selenium_coam.set_parameter_value    dist_name=${NRBTS_id}/NRCELL-${cellId}
    ...                                  filter_param=TDLTE UL-DL configuration
    ...                                  new_value=${tdLteUlDlConfig}
    selenium_coam.set_parameter_value    dist_name=${NRBTS_id}/NRCELL-${cellId}
    ...                                  filter_param=NR Absolute radio frequency channel number
    ...                                  new_value=${nrarfcn}
    selenium_coam.set_parameter_value    dist_name=${NRBTS_id}/NRCELL-${cellId}
    ...                                  filter_param=Maximum output power
    ...                                  new_value=${pMax}
    selenium_coam.set_parameter_value    dist_name=${NRBTS_id}/NRCELL-${cellId2}
    ...                                  filter_param=LTE to NR frame shift
    ...                                  new_value=${lteToNrFrameShift}
    selenium_coam.set_parameter_value    dist_name=${NRBTS_id}/NRCELL-${cellId2}
    ...                                  filter_param=Channel bandwidth
    ...                                  new_value=${bandwidth}
    selenium_coam.set_parameter_value    dist_name=${NRBTS_id}/NRCELL-${cellId2}
    ...                                  filter_param=PRACH configuration index
    ...                                  new_value=${prachIndex}
    selenium_coam.set_parameter_value    dist_name=${NRBTS_id}/NRCELL-${cellId2}
    ...                                  filter_param=Time offset between the LTE PCell and the NR cell
    ...                                  new_value=${lteToNrTimeOffset}
    selenium_coam.set_parameter_value    dist_name=${NRBTS_id}/NRCELL-${cellId2}
    ...                                  filter_param=UL to DL logical data slot ratio
    ...                                  new_value=${slotRatio}
    selenium_coam.set_parameter_value    dist_name=${NRBTS_id}/NRCELL-${cellId2}
    ...                                  filter_param=Guard Period length
    ...                                  new_value=${guardPeriod}
    selenium_coam.set_parameter_value    dist_name=${NRBTS_id}/NRCELL-${cellId2}
    ...                                  filter_param=TDLTE UL-DL configuration
    ...                                  new_value=${tdLteUlDlConfig}
    selenium_coam.set_parameter_value    dist_name=${NRBTS_id}/NRCELL-${cellId2}
    ...                                  filter_param=NR Absolute radio frequency channel number
    ...                                  new_value=${nrarfcn}
    selenium_coam.set_parameter_value    dist_name=${NRBTS_id}/NRCELL-${cellId2}
    ...                                  filter_param=Maximum output power
    ...                                  new_value=${pMax}
    selenium_coam.validate_plan
    selenium_coam.activate_plan     activate_plan_despite_errors=True
    sleep    65s
    Run Keyword And Ignore Error   selenium_coam.logout
    selenium_coam.disable_virtual_display

power UE.Start DLUL traffic
    [Arguments]     ${duration}    ${data_transfer_dl}     ${data_transfer_ul}
    FGCR_4454_common_KW.Attach and check power UE     ue_type=${ue_type}
    #${nrcell_id}    get nrCellid    cellid=1
    Log to console    \nINFO:power_ue.Start traffic ul
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${data_transfer_ul}
    ...     duration=${duration}     iperf_port=${ul_port}
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${data_transfer_dl}
    ...     duration=${duration}     iperf_port=${dl_port}
    Log to console    \nINFO:power_ue.Start traffic dl
    #sleep     ${duration}
    [Teardown]    Run keyword and ignore error    UE.traffic.Teardown

UE.Start DLUL traffic
    [Arguments]     ${duration}=30s
    ${status}    run keyword and return status    power UE.Start DLUL traffic
    ...                                 data_transfer_dl=${DL_TPUT}
    ...                                 data_transfer_ul=${UL_TPUT}
    ...                                 duration=${duration}
    Should be true     ${status}

power UE.Start DLUL traffic and Caculate throughput
    [Arguments]     ${duration}    ${data_transfer_dl}     ${data_transfer_ul}     ${Expected_Throughput_DL}
    ...     ${Expected_Throughput_UL}    ${nrbtsid}=1
    ${nrcell_id}    get nrCellid    cellid=1    nrbtsid=${nrbtsid}
    ${list_of_cell_ids}    Create list    ${nrcell_id}
    FGCR_4454_common_KW.Attach and check power UE     ue_type=${ue_type}
    Log to console    \nINFO:power_ue.Start traffic ul
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${data_transfer_ul}
    ...     duration=${duration}     iperf_port=${ul_port}
    #sleep     20s
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
    Power_ue.Check Tput    ue_type=${ue_type}    direction=UL    log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${Expected_Throughput_UL}
    #Run Keyword And Ignore Error    UE.Check throughput     ue_type=${ue_type}     direction=ul
    #...     throughput=${Expected_Throughput_UL}     cellid=${nrcell_id}    sleep_time=${sleep_time}
    FGCR_4454_common_KW.Attach and check power UE     ue_type=${ue_type}
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${data_transfer_dl}
    ...     duration=${duration}     iperf_port=${dl_port}
    Log to console    \nINFO:power_ue.Start traffic dl
    sleep     240s
    #sleep     ${duration}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${Expected_Throughput_DL}
    #UE.Check throughput     ue_type=${ue_type}     direction=dl     throughput=${Expected_Throughput_DL}
    #...     cellid=${nrcell_id}    sleep_time=${sleep_time}
    [Teardown]    Run keyword and ignore error    UE.traffic.Teardown

UE.Start DLUL traffic and Caculate throughput
    [Arguments]     ${duration}=1800s    ${nrbtsid}=1
    ${status}    run keyword and return status    power UE.Start DLUL traffic and Caculate throughput
    ...                                 data_transfer_dl=${DL_TPUT}
    ...                                 data_transfer_ul=${UL_TPUT}
    ...                                 duration=${duration}
    ...                                 Expected_Throughput_DL=${expect_dl}
    ...                                 Expected_Throughput_UL=${expect_ul}
    ...                                 nrbtsid=${nrbtsid}
    Should be true     ${status}

power UE.Start DLUL traffic and Caculate throughput for Huawei
    [Arguments]     ${duration}    ${data_transfer_dl}     ${data_transfer_ul}     ${Expected_Throughput_DL}
    ...     ${Expected_Throughput_UL}    ${nrbtsid}=1     ${retry}=10
    ${nrcell_id}    get nrCellid    cellid=1    nrbtsid=${nrbtsid}
    ${list_of_cell_ids}    Create list    ${nrcell_id}
    FGCR_4454_common_KW.Attach and check power UE     ue_type=${ue_type}
    Log to console    \nINFO:power_ue.Start traffic dl
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${data_transfer_dl}
    ...     duration=${duration}     iperf_port=${dl_port}
    sleep     15s
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${Expected_Throughput_DL}
#    UE.Check throughput     ue_type=${ue_type}     direction=dl     throughput=${Expected_Throughput_DL}
#    ...     cellid=${nrcell_id}    sleep_time=${sleep_time}     retry=${retry}
#    Log to console    \nINFO:power_ue.Start traffic ul
#    #FGCR_4454_common_KW.Attach and check power UE     ue_type=${ue_type}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${data_transfer_ul}
    ...     duration=${duration}     iperf_port=${ul_port}
    sleep     15s
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
    Power_ue.Check Tput    ue_type=${ue_type}    direction=UL    log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${Expected_Throughput_UL}
#    UE.Check throughput     ue_type=${ue_type}     direction=ul     retry=${retry}
#    ...     throughput=${Expected_Throughput_UL}     cellid=${nrcell_id}    sleep_time=${sleep_time}
    [Teardown]    Run keyword and ignore error    UE.traffic.Teardown

UE.Start DLUL traffic and Caculate throughput for Huawei
    [Arguments]     ${duration}=1800s      ${nrbtsid}=1     ${retry}=10
    Set Suite Variable    ${home}    82
    ${status}    run keyword and return status    power UE.Start DLUL traffic and Caculate throughput for Huawei
    ...                                 data_transfer_dl=${DL_TPUT}
    ...                                 data_transfer_ul=${UL_TPUT}
    ...                                 duration=${duration}
    ...                                 Expected_Throughput_DL=${expect_dl}
    ...                                 Expected_Throughput_UL=${expect_ul}
    ...                                 nrbtsid=${nrbtsid}
    ...                                 retry=${retry}
    Should be true     ${status}

#power UE.Start DLUL traffic and Caculate throughput for Huawei
#    [Arguments]     ${duration}    ${data_transfer_dl}     ${data_transfer_ul}     ${Expected_Throughput_DL}
#    ...     ${Expected_Throughput_UL}    ${nrbtsid}=1     ${retry}=10
#    ${nrcell_id}    get nrCellid    cellid=1    nrbtsid=${nrbtsid}
#    FGCR_4454_common_KW.Attach and check power UE     ue_type=${ue_type}
#    Log to console    \nINFO:power_ue.Start traffic dl
#    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${data_transfer_dl}
#    ...     duration=${duration}     iperf_port=${dl_port}
#    sleep     15s
#    UE.Check throughput     ue_type=${ue_type}     direction=dl     throughput=${Expected_Throughput_DL}
#    ...     cellid=${nrcell_id}    sleep_time=${sleep_time}     retry=${retry}
#    Log to console    \nINFO:power_ue.Start traffic ul
#    #FGCR_4454_common_KW.Attach and check power UE     ue_type=${ue_type}
#    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${data_transfer_ul}
#    ...     duration=${duration}     iperf_port=${ul_port}
#    sleep     15s
#    UE.Check throughput     ue_type=${ue_type}     direction=ul     retry=${retry}
#    ...     throughput=${Expected_Throughput_UL}     cellid=${nrcell_id}    sleep_time=${sleep_time}
#    [Teardown]    Run keyword and ignore error    UE.traffic.Teardown
#
#UE.Start DLUL traffic and Caculate throughput for Huawei
#    [Arguments]     ${duration}=1800s      ${nrbtsid}=1     ${retry}=10
#    Set Suite Variable    ${home}    82
#    ${status}    run keyword and return status    power UE.Start DLUL traffic and Caculate throughput for Huawei
#    ...                                 data_transfer_dl=${DL_TPUT}
#    ...                                 data_transfer_ul=${UL_TPUT}
#    ...                                 duration=${duration}
#    ...                                 Expected_Throughput_DL=${expect_dl}
#    ...                                 Expected_Throughput_UL=${expect_ul}
#    ...                                 nrbtsid=${nrbtsid}
#    ...                                 retry=${retry}
#    Should be true     ${status}

SISO suite setup
    admin_cli.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}    name=GNB_OAM
    taf_coam.COAM WEBUI Login   display=${false}    version=21A


SISO suite teardown
    Run Keyword and Ignore Error    admin_cli.teardown
    Run Keyword and Ignore Error    taf_coam.COAM WEBUI Logout


UE.Check Both ULDL throughput
    [Arguments]    ${ue_type}    ${theory_dl_peak}    ${theory_ul_peak}    ${deviation}=10
    ...            ${total_time}=40    ${interval}=5s    ${duration_time_for_once}=15s
    ...            ${acceptable_tput_percentage}=0.90    ${nr_cell_index}=1    ${du_index}=0
    ...            ${gnb_ssl_connection}=GNB_OAM    ${is_need_to_capture_log}=${False}
    ...            ${gnb_index}=${0}
    [Documentation]    Check Both ULDL throughputt from started traffic.
    [Timeout]      30min
    admin_cli.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}    name=GNB_OAM
    Log to console    \nINFO:power_ue.Check Both ULDL throughput
    power_ue.Check peak throughput     ue_type=${ue_type}
    ...     theory_dl_peak=${theory_dl_peak}     theory_ul_peak=${theory_ul_peak}     nr_cell_index=${nr_cell_index}
    ...     total_time=${total_time}     duration_time_for_once=${duration_time_for_once}
    ...     acceptable_tput_percentage=${acceptable_tput_percentage}
    ...     du_index=${du_index}
    [Teardown]    Run keyword and ignore error    admin_cli.teardown

power UE.Start DLUL traffic and Caculate throughput for Huawei for 40s
    [Arguments]     ${duration}    ${data_transfer_dl}     ${data_transfer_ul}     ${Expected_Throughput_DL}
    ...     ${Expected_Throughput_UL}    ${nrbtsid}=${tl.gnbs[0].instance_id}    ${retry}=10     ###${nr_cell_index}=1
    ###${nrcell_id}    get nrCellid    cellid=1    nrbtsid=${nrbtsid}
    ${nrcell_id}    get nrCellid    cellid=1    nrbtsid=${nrbtsid}
    ${list_of_cell_ids}    Create list    ${nrcell_id}
    FGCR_4454_common_KW.Attach and check power UE     ue_type=${ue_type}
    Log to console    \nINFO:power_ue.Start traffic ul
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${data_transfer_ul}
    ...     duration=${duration}     iperf_port=${ul_port}
    sleep    15s
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
    Power_ue.Check Tput    ue_type=${ue_type}    direction=UL    log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${Expected_Throughput_UL}
    Log to console    \nINFO:power_ue.Start traffic dl
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${data_transfer_dl}
    ...     duration=${duration}     iperf_port=${dl_port}
    sleep    12s
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${Expected_Throughput_DL}
    #crisbefore#UE.Check Both ULDL throughput     ue_type=${ue_type}     theory_ul_peak=${Expected_Throughput_UL}
    #crisbefore#...     theory_dl_peak=${Expected_Throughput_DL}
    #crisbefore#...     nr_cell_index=${nr_cell_index}
    [Teardown]    Run keyword and ignore error    UE.traffic.Teardown

UE.Start DLUL traffic and Caculate throughput for Huawei for 40s
    [Arguments]     ${duration}=1000s      ${nrbtsid}=${tl.gnbs[0].instance_id}    ${retry}=10      #${nr_cell_index}=1
    Set Suite Variable    ${home}    82
    ${status}    run keyword and return status    power UE.Start DLUL traffic and Caculate throughput for Huawei for 40s
    ...                                 data_transfer_dl=${DL_TPUT}
    ...                                 data_transfer_ul=${UL_TPUT}
    ...                                 duration=${duration}
    ...                                 Expected_Throughput_DL=${expect_dl}
    ...                                 Expected_Throughput_UL=${expect_ul}
    ...                                 nrbtsid=${nrbtsid}
    ...                                 retry=${retry}
    #...                                 nr_cell_index=${nr_cell_index}
    Should be true     ${status}

Setup Case for 40M for trunk
    [Arguments]    ${mcs}=0
    Run keyword If    ${mcs}==0    power UE.SetTestVariables    mcs=0    ul=5M    dl=5M
    Run keyword If    ${mcs}==10   power UE.SetTestVariables    mcs=10    ul=10M    dl=10M    ULTPpercent=98
    ...     DLTPpercent=98
    Run keyword If    ${mcs}==16   power UE.SetTestVariables    mcs=16    ul=64M    dl=248M
    Run keyword If    ${mcs}==20    power UE.SetTestVariables    mcs=20    ul=83M    dl=323M
    Run keyword If    ${mcs}==21    power UE.SetTestVariables    mcs=21    ul=91M    dl=352M
    Run keyword If    ${mcs}==26    power UE.SetTestVariables    mcs=26    ul=129M    dl=495M
    Run keyword If    ${mcs}==27    power UE.SetTestVariables    mcs=27    ul=41M    dl=505M    ULTPpercent=95
    ...     DLTPpercent=90
    Run keyword If    ${mcs}==28    power UE.SetTestVariables    mcs=28    ul=72M    dl=900M

Prepare the atten for Huawei trunk
    Adjust the Attenuation Value    ports=${5GRU1_ANT1}    value=${0}
    Adjust the Attenuation Value    ports=${5GRU1_ANT2}    value=${0}
    Adjust the Attenuation Value    ports=${5GRU2_ANT1}    value=${0}
    Adjust the Attenuation Value    ports=${5GRU2_ANT2}    value=${0}

UE.TestPC connections
    ${cpc_ip} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ${cpc_usrname} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.username}
    ${cpc_passwd} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.password}
    csn.Connect To    hostname=${cpc_ip}
    ...               username=${cpc_usrname}
    ...               password=${cpc_passwd}
    ...               alias=TestPC

UE.killall firefox progress
    UE.TestPC connections
    csn.send command    command=killall firefox    connection=TestPC
    csn.send command    command=killall Xvfb    connection=TestPC
    csn.disconnect    connection=TestPC
    sleep    10s

Prepare the atten for Huawei 19B
    adjust the HBTE attenuation value    value_1=${16}    value_2=${16}   value_3=${16}    value_4=${16}

UE.ADB Reboot UE
    [Documentation]  Use adb command to reboot the android ue device
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    UE.TestPC connections
    csn.execute    command=adb -s ${serial_number} reboot   connection=TestPC
    sleep    30s
    wait until keyword succeeds    3 min    10s    Connect ADB devices    alias=TestPC    serial_number=${serial_number}
    csn.disconnect   connection=TestPC

Setup Case for 20M for 20A
    [Arguments]    ${mcs}=0
    Run keyword If    ${mcs}==0    power UE.SetTestVariables    mcs=0    ul=16M    dl=42M
    Run keyword If    ${mcs}==16   power UE.SetTestVariables    mcs=16    ul=64M    dl=248M
    Run keyword If    ${mcs}==20    power UE.SetTestVariables    mcs=20    ul=83M    dl=323M
    Run keyword If    ${mcs}==21    power UE.SetTestVariables    mcs=21    ul=91M    dl=352M
    Run keyword If    ${mcs}==26    power UE.SetTestVariables    mcs=27    ul=41M    dl=535M    ULTPpercent=5
    ...     DLTPpercent=8
    Run keyword If    ${mcs}==27    power UE.SetTestVariables    mcs=27    ul=20M    dl=260M    ULTPpercent=95
    ...     DLTPpercent=90
    Run keyword If    ${mcs}==28    power UE.SetTestVariables    mcs=28    ul=72M    dl=900M

Setup Case for 80M for 20A
    [Arguments]    ${mcs}=0
    Run keyword If    ${mcs}==0    power UE.SetTestVariables    mcs=0    ul=16M    dl=42M
    Run keyword If    ${mcs}==16   power UE.SetTestVariables    mcs=16    ul=64M    dl=248M
    Run keyword If    ${mcs}==20    power UE.SetTestVariables    mcs=20    ul=83M    dl=323M
    Run keyword If    ${mcs}==21    power UE.SetTestVariables    mcs=21    ul=91M    dl=352M
    Run keyword If    ${mcs}==26    power UE.SetTestVariables    mcs=27    ul=41M    dl=535M    ULTPpercent=5
    ...     DLTPpercent=8
    Run keyword If    ${mcs}==27    power UE.SetTestVariables    mcs=27    ul=80M    dl=1080M    ULTPpercent=95
    ...     DLTPpercent=90
    Run keyword If    ${mcs}==28    power UE.SetTestVariables    mcs=28    ul=72M    dl=900M

Setup Case for 80M for Thoughput
    Set Test Variable    ${UL_TPUT}    45M
    Set Test Variable    ${DL_TPUT}    1040M
    Set Test Variable    ${expect_ul}    40.5    #45*0.9
    Set Test Variable    ${expect_dl}    936    #1040*0.9

Setup Case for 40M for 20A
    [Arguments]    ${mcs}=0
    Run keyword If    ${mcs}==0    power UE.SetTestVariables    mcs=0    ul=16M    dl=42M
    Run keyword If    ${mcs}==16   power UE.SetTestVariables    mcs=16    ul=64M    dl=248M
    Run keyword If    ${mcs}==20    power UE.SetTestVariables    mcs=20    ul=83M    dl=323M
    Run keyword If    ${mcs}==21    power UE.SetTestVariables    mcs=21    ul=91M    dl=352M
    Run keyword If    ${mcs}==26    power UE.SetTestVariables    mcs=27    ul=41M    dl=535M    ULTPpercent=5
    ...     DLTPpercent=8
    Run keyword If    ${mcs}==27    power UE.SetTestVariables    mcs=27    ul=41M    dl=535M    ULTPpercent=95
    ...     DLTPpercent=90
    Run keyword If    ${mcs}==28    power UE.SetTestVariables    mcs=28    ul=72M    dl=900M

clear UTE memery cache
    [Arguments]     ${alias}=ute_cache
    csn.Connect to    hostname=${SUT_IP}
    ...             username=${SUT_NAME}    password=${SUT_PWD}    alias=${alias}
    sleep     10s
    Log To Console     before clear UTE memery cache
    ${cache_status}    OperatingSystem.Run     free -m
    Log To Console     ${cache_status}
    sleep     5s
    Run Keyword And Ignore Error    csn.send command
    ...    command=echo 3 > /proc/sys/vm/drop_caches    connection=${alias}
    sleep     5s
    Log To Console     after clear UTE memery cache
    ${cache_status2}    OperatingSystem.Run     free -m
    Log To Console     ${cache_status2}
   [Teardown]     csn.disconnect    connection=${alias}
