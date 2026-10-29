# *** Settings ***
# Documentation     author: Liu Tiffany
# ...               contact: tiffany.liu@nokia-sbell.com
# Suite Setup       Setup My Suite
# Suite Teardown    TestSuilt.Destroy
# Force Tags
# ...    PY36
# Resource          ../5GC000728/Resources/5GC000728_MTK_resources.robot
# Resource          ../5GC000496_C/Resources/L3Call.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Library           taf.hw.rf_attenuator    WITH NAME    PA
# Library           taf.ue    WITH NAME    ute_ue
# Library           ute_ue
# Library           ../5GC000742/Resources/MTKUE_extend.py
# Library           MTKUE_extend.MTKUE    WITH NAME   MTKUE
#
# *** Variables ***
#
# ${PA_INFO}            ${tl.attenuator}
# ${CFGFILE_PATH}    /home/ute/TAF/cfgfile/
# #${UTE_UE_CONFIG}     ${CURDIR}/Resources/MTK_config_TL5.yaml
# #${UTE_UE_CONFIG}     ${CURDIR}/Resources/MTK_config_TL5_wap2.yaml
# ${IMSI}                     ${tl.ues[0].imsi}
#
# ${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
# ${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
# ${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}
#
# ${MTK_CtrlPC_IP}           ${tl.ues[0].ssh_connection_details.addr}
# ${MTK_CtrlPC_USERNAME}     ${tl.ues[0].ssh_connection_details.username}
# ${MTK_CtrlPC_PASSWORD}     ${tl.ues[0].ssh_connection_details.password}
#
# #${MTK_CtrlPC_IP}           ${tl.ues[1].ssh_connection_details.addr}
# #${MTK_CtrlPC_USERNAME}     ${tl.ues[1].ssh_connection_details.username}
# #${MTK_CtrlPC_PASSWORD}     ${tl.ues[1].ssh_connection_details.password}
#
#
# ${ASIK_LMP_IP}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
# ${ASIK_IP}        ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#
# ${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# ${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
#
# ${PB_ASIK_IP}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
# ${PB_ASIK_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
#
# ${PB_5GRU_IP}     ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
# ${PB_5GRU_PORT}    ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
#
# ${MTK_FACOM_IP}                   ${tl.ues[0].pdu.pdu.addr}
# ${MTK_FACOM_PORT}                   ${tl.ues[0].pdu.port_no}
# #${ASIK_LMP_IP}        ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
# #${ASIK_IP}        ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
# #
# #${WEBUI_IP}                 ${tl.gnbs[1].cu.oam_http_connection_details.addr}
# #${WEBUI_USERNAME}           ${tl.gnbs[1].cu.oam_http_connection_details.username}
# #${WEBUI_PASSWORD}           ${tl.gnbs[1].cu.oam_http_connection_details.password}
# #
# #${PB_ASIK_IP}     ${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
# #${PB_ASIK_PORT}    ${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.port_no}
# #
# #${PB_5GRU_IP}     ${tl.gnbs[1].dus[0].rus[0].pdu_port.pdu.addr}
# #${PB_5GRU_PORT}    ${tl.gnbs[1].dus[0].rus[0].pdu_port.port_no}
# #${UE_TYPE}          huawei_sigspark
#
# ${REPEAT_TIME}    ${50}
# ${THRESHOLD}      ${49}
# ${EXPECTED_PRECENT}    10
#
# ##################define these variable for convenient############################
# ${ALIAS_ASIK}     asik
# ${ALIAS_ASIK_SLAVE}    asik_slave
# ${ALIAS_UTE}      ute
# ${ALIAS_ENBCTLPC}    ENB_PC
# ${ALIAS_SHP}      SHP
# ${ALIAS_E500}     E500
# ${ALIAS_PRISMA}    Prisma
# ${ALIAS_REAL_EPC_SERVER}    Real_EPC
# ${ALIAS_LONER}    LONER
# ${ALIAS_ASP_1A}    ASP_1A
# ${AlIAS_QC}       Qualcomm
# ${UE_alias}       UE_1
# ${ALIAS_5GC}      5gc
# ########################END of alias Define#######################################
#
# *** Test Cases ***
#
#
#
# [1]5GC002267_A_02_Re-establishment_Count_Update
#     [Tags]    Classicalbts    Blow6GHz   MTK   CRT_19B    CRT_Trunk
#     [Setup]    TestCase.Init    mcs=0
#     wait until keyword succeeds    30x    1min    gNB.VerifyOnAirViaOAMUntilReady
#     Check_And_Require_MTK
#     Process.UE Attach and DL data transfer with Log Capturing
#     Wireshark.StartCaptureLogFromContainer    filename=NG_2267_A_case2.pcap
#     PA.setup_attenuator    attenuator=${PA_INFO}
#     ${PORTS}    Get Dictionary Keys    ${tl.attenuator.attenuator_ports}
#     log to console     ${PORTS[0]}
#     log to console     ${PORTS[1]}
#     PA.set_attenuation    port=${PORTS[0]}     value=${25}
#     PA.read_attenuation    port=${PORTS[0]}
#     PA.set_attenuation    port=${PORTS[1]}     value=${25}
#     PA.read_attenuation    port=${PORTS[1]}
#     sleep    30
#     PA.set_attenuation    port=${PORTS[0]}     value=${5}
#     PA.read_attenuation    port=${PORTS[0]}
#     PA.set_attenuation    port=${PORTS[1]}     value=${5}
#     PA.read_attenuation    port=${PORTS[1]}
#     #trigger rrc reestablishment with send ru signal command on ru
# #    Conn.ConnectToLoner
# #    Conn.ConnectTo5GRu
# #    ${res}=    Conn.Execute   cmd=/sbin/devmem 0xA000120C 32 0x00110     alias=${5G_RU}
# #    log  ${res}
# #    sleep   10s
# #    ${res1}=    Conn.Execute   cmd=/sbin/devmem 0xA000120C 32     alias=${5G_RU}
# #    log  ${res1}
# #    sleep   10s
# #    ${res2}=    Conn.Execute   cmd=/sbin/devmem 0xA000120C 32 0x00000     alias=${5G_RU}
# #    log  ${res2}
# #    ssh.send command    command=devmem 0xA000120C 32 0x00000    connection=${5G_RU}
#     Wireshark.StopCapturingAlllog
#     Wireshark.DownloadLogToUTE   filename=NG_2267_A_case2.pcap     log_dir=/tmp/node_0xe004/tmp
#     Wireshark.ReadLog    filename=NG_2267_A_case2.pcap    filter=f1ap
#     Wireshark.Check reest request in f1ap
#     wait until keyword succeeds    3x    1min    COAM_WebEM.Login
#     Wait Until Keyword Succeeds    5x    1min    Check Reestablishment_Counters
#     COAM_WebEM.Logout
#     [Teardown]    TestCase.Destory for 2267
#
#
# *** Keywords ***
# Process.UE Attach and DL data transfer with Log Capturing
#     [Arguments]    ${connection}=${ALIAS_ASIK}
#     gNB.Connect
#     #Wireshark.StartCaptureNGLog   filename=728_B_case2.pcap
#     #Wireshark.StartCaptureLogFromContainer  filename=CPIF_UL.pcap   container=0xe004
#     Run Keyword And Continue On Failure    Process.UE Attach
#     Run Keyword And Continue On Failure    Process.Start DL Traffic    Duration=450s
#     sleep   10s
#
# TestCase.Destory for 2267
#     [Arguments]   ${connection}=COAM
#     PA.setup_attenuator    attenuator=${PA_INFO}
#     ${PORTS}    Get Dictionary Keys    ${tl.attenuator.attenuator_ports}
#     PA.set_attenuation    port=${PORTS[0]}     value=${5}
#     PA.read_attenuation    port=${PORTS[0]}
#     PA.set_attenuation    port=${PORTS[1]}     value=${5}
#     PA.read_attenuation    port=${PORTS[1]}
#     Run Keyword And Ignore Error    Stop BTSlogs Collection and get logs
#     Run Keyword And Ignore Error    Backup current SCF
#     gNB.Connect
#     Run Keyword And Ignore Error    kill GNB wireshark process
#     log     ${TEST STATUS}
#     Run Keyword If  '${TEST STATUS}' == 'FAIL'    Collect logs
#     ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect logs
#     #Run Keyword And Ignore Error    Clean GNB wireshark log
#     Run Keyword And Ignore Error    kill admin process
#     Run Keyword And Ignore Error    run   command=killall firefox
#     Conn.ResetCache
#
# Wireshark.StopCapturingALLlog
#     ssh.send command   command=ps -ef|grep tcpdump|grep -v grep|grep fp0|awk '{print $2}'|xargs kill -2   connection=${ALIAS_ASIK}
#     ${pid}  ssh.execute   command=lxc-attach -n 0xe004 -- ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'  connection=${ALIAS_ASIK}
#     ssh.execute   command=lxc-attach -n 0xe004 -- kill -2 ${pid.replace('\r\n','')}   connection=${ALIAS_ASIK}
#
# Setup My Suite
#     TestSuilt.Init
#     GNB.SwconfigReplace  file_path=${CFGFILE_PATH}/5GC002267
#     GNB.Commissioning   scf_file=2267_scf_original.xml   file_path=${CFGFILE_PATH}/5GC002267
#
# Wireshark.Check reest request in f1ap
#     Run Keyword And Continue On Failure    Wireshark.CheckExpression   expression=nr-rrc.reestablishmentCause == 2
#
# Check Reestablishment_Counters
#     COAM_Admin.CheckBTSConterWithTraget     counter_id=M55124C00505
#     COAM_Admin.CheckBTSConterWithTraget     counter_id=M55124C00502
#
#
# COAM_Admin.GetBTSConter
#     [Arguments]    ${counter_id}    ${expected_value}=1
#     ${date}   Get Current Date   exclude_millis=True
#     ${res}  selenium_coam.get_bts_counters_info   counter_id=${counter_id}
#     ${values}    get dictionary values   ${res}
#     log  The latest one is: ${values[-1]}
#     should be true    ${values[-1]}==${expected_value}
#
# COAM_Admin.CheckBTSConterWithTraget
#     [Arguments]    ${counter_id}    ${target_value}=0
#     ${date}   Get Current Date   exclude_millis=True
#     ${res}  selenium_coam.get_bts_counters_info   counter_id=${counter_id}      timeout_for_loading_available_counters=60
#     ${values}    get dictionary values   ${res}
#     log  The latest one is: ${values[-1]}
#     should be true    ${values[-1]}>${target_value}
#
#
#
#
#
# Process.UE Attach and UL traffic with Log Capturing
#     [Arguments]    ${connection}=${ALIAS_ASIK}
#     gNB.Connect
#     Wireshark.StartCaptureNGLog   filename=NG_2267_A_case2.pcap
#     #Wireshark.StartCaptureLogFromContainer  filename=CPIF_UL.pcap   container=0xe004
#     Run Keyword And Continue On Failure    Process.UE Attach
#     Run Keyword And Continue On Failure    Proess.Start UL Traffic    Duration=300s
#     sleep   10s
#     Wireshark.StopCapturingAlllog
#     Wireshark.DownloadLogToUTE   filename=NG_2267_A_case2.pcap
# #    Wireshark.DownloadLogFromContainerToUTE    filename=CPIF_UL.pcap   remote_dir=/tmp/node_0xe004/tmp
#
