*** Settings ***
Documentation           author: Li Yajie
...                     contact: yajie.li@nokia-sbell.com
...                     squad group: SG_01
...                     feature : 5GC000988
Library                 taf.transport.ssh    WITH NAME    csn
Library    taf.analyzer.pcap    WITH NAME   cap
Resource                ../../5GC000496_C/Resources/L3Call.robot

Library                 taf.collectors.core   WITH NAME   core
Library                 taf.collectors.btslog  WITH NAME   btslog
Library                 taf.ue    WITH NAME    ute_ue
Library                 taf.hw.rf_attenuator    WITH NAME    PA
#Variables               ${CFGFILE_ON_GIT}/5GC000988/Delta_SCF.py
#Variables               ${CFGFILE_ON_GIT}/TLDelta.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot


*** Variables ***
#${UE_TYPE}              huawei_sigspark
${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}

${log_dir}              /ffs/run/config/toor4nsn

#${CFGFILE_ON_GIT}       /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
#${GoldenSCF_PATH}       ${GoldenSCF_ON_GIT}/${GoldenSCF}
#${GoldenSCF_ON_GIT}       /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG

#${TL_DeltaPath}         ${CFGFILE_PATH}/TLDelta.py
#${DeltaPath}            ${CFGFILE_PATH}/5GC000988/Delta_SCF.py

${MRBTS_ID}             ${tl.gnbs[0].instance_id}
${NRBTS_ID}             ${tl.gnbs[0].global_bts_id}


${ASIK_LMP_IP}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}              ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${UTE_IP}               ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}         ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}         ${tl.test_pc.default_ssh_connection_details.password}

${WEBUI_IP}             ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}       ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}            https://${tl.gnbs[0].cu.oam_http_connection_details.addr}


${PB_ASIK_IP}           ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}         ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}           ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}         ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}


${IMSI}                 ${tl.ues[0].imsi}

${5GC_IP}               ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}         ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}         ${tl.core.default_ssh_connection_details.password}

${SPARK_APN_IP}         ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${SPARK_APN_USERNAME}   ${tl.ues[0].iperf_details.ssh_connection_details.username}
${SPARK_APN_PASSWORD}    ${tl.ues[0].iperf_details.ssh_connection_details.password}

${MODIFIED_SCF_1}        ${LOG_PATH}/988_A2_S1_SCF.xml
@{988_pcap_files}    988_NG_A2.pcap    988_etha01_A2.pcap    988_A2_S1_SCF.xml

${ipV4AddressDN1_except_value1}    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2
#${ipV4AddressDN1_except_value2}    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3

## Attenuator parameter ##
${PA_INFO}            ${tl.attenuator}

####GNB1####
${5GRU1_ANT1}    ${1}
${5GRU1_ANT2}    ${2}
${5GRU2_ANT1}    ${3}
${5GRU2_ANT2}    ${4}
${5GRU3_ANT1}    ${5}
${5GRU3_ANT2}    ${6}

####GNB2####
${5GRU4_ANT1}    ${7}
${5GRU4_ANT2}    ${8}

##################define these variable for convenient############################
${ALIAS_ASIK}               asik                                                ##
${ALIAS_ASIK_SLAVE}         asik_slave                                          ##
${ALIAS_ABIL}               abil                                                ##
${ALIAS_ABIL_SLAVE}         abil_slave                                          ##
${ALIAS_UTE}                ute                                                 ##
${ALIAS_ASP_1A}             ASP_1A                                              ##
${ALIAS_AMF}                AMF                                                 ##
${ALIAS_QC}                 QC                                                  ##
${ALIAS_UPF}                UPF                                                 ##
${ASIK_SSH_IP}              asik_ssh                                            ##
${ALIAS_5GC}                5gc                                                 ##

${ALIAS_APN}                APN                                                 ##
########################END of alias Define#######################################



*** Keywords ***
####Case Level  Keywords#####
TC.5GC000988_B_2_Vlan for network slice mutual isolation function check
    set test variable     @{988_B2_pcap_files}    988_B2_NG.pcap     988_B2_traffic.pcap
    Generate 988 B2 scf file
    gNB.CommissionWithRetry    scf_file=${LOG_PATH}/988_B_2_SNSSAI.xml    model=HBTE
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady
    #ASIK/ASIB different check method for GTP-U
    gNB.Connect
    ${resp}    ssh.execute    command=ddal -s ddal_sysinfo_module_get_unit_id 0    connection=${ALIAS_ASIK}
    ${NG_port}      set variable if   ${resp.count("ASIB")} > 0     br1    fp0
    run keyword if     ${resp.count("ASIB")} > 0     Run keywords
    ...    Multi_UE Call with_traffic_ASIB    filename=${988_pcap_files}    NG_port=${NG_port}
    ...    AND    wait until keyword succeeds    5x    2min    Process.Check Counters of 988 B2    VLANIF=VLANIF-${vlanId}
    ...    ELSE    Run keywords    Multi_UE Call with_traffic    filename=${988_B2_pcap_files}
    ...    AND    COAM_WebEM.Login
    ...    AND    Check Vlan id and soucre destination ip address     input_pcap=988_B2_traffic.pcap   ip_type=ipv4
    ...    AND    COAM_WebEM.Logout

Multi_UE Call with_traffic_ASIB
    [Arguments]    ${filename}    ${log_dir}=${log_dir}    ${NG_port}=br1
    gNB.Connect
    Run Keyword And Continue On Failure    Wireshark.StartCaptureNGLog   filename=${filename[0]}    log_dir=${log_dir}
    Run Keyword And Continue On Failure    Spark.UE attach with ULDL traffic
    ...    ue_index=${0}    throughput=20MKbits/sec    duration=300    apn_address=${SA_APN}   ue_mode=SA
#    Run Keyword And Continue On Failure    Spark.UE attach with ULDL traffic    ue_index=${1}    apn_address=${NSA_APN}   ue_mode=NSA
    sleep    4min
    Run Keyword And Continue On Failure    gNB.Connect
    Run Keyword And Continue On Failure    Wireshark.Download_Pcap    listen_port=${NG_port}    filename=${filename[0]}
    Run Keyword And Ignore Error    Spark.Detach UE with Stop traffic    ue_index=${0}     apn_address=${SA_APN}   ue_mode=SA
#    Run Keyword And Ignore Error    Spark.Detach UE with Stop traffic    ue_index=${1}    apn_address=${NSA_APN}   ue_mode=NSA

Process.Check Counters of 988 B2
    [Documentation]   M51302C2: DL>>>VlanEthIfInOctets    M51302C4:UL>>>VlanEthIfOutOctets
    [Arguments]    ${VLANIF}
    Run Keyword And Continue On Failure    COAM_WebEM.Login
    Run Keyword And Continue On Failure    COAM_WEBEM.CheckTRSConutersWithUPandLowerValue
    ...    counter_id=M51302C2    full_path=TNL-1/VLANIF/${VLANIF}/VLAN_stats/VlanEthIfInOctets    up_value=500000000    lower_value=5000000
    Run Keyword And Continue On Failure    COAM_WEBEM.CheckTRSConutersWithUPandLowerValue
    ...    counter_id=M51302C4    full_path=TNL-1/VLANIF/${VLANIF}/VLAN_stats/VlanEthIfOutOctets    up_value=500000000    lower_value=5000000
    Run Keyword And Continue On Failure    COAM_WebEM.Logout

Check Vlan id and soucre destination ip address
    [Arguments]   ${input_pcap}    ${ip_type}

     ${NgU_ip_addr}   ${NgU_dist_name}   Get NgU ip address of slice through WebUI    ue_index=${0}  ip_type=${ip_type}
     ${Vlan_id}        Get vlan ID of slice through WebUI      NgU_dist_name=${NgU_dist_name}
     Check Vlan ID in package of slice    expected_vlan=${Vlan_id}   NgU_ip_addr=${NgU_ip_addr}  input_pcap=${input_pcap}

Get NgU ip address of slice through WebUI
    [Arguments]   ${ue_index}    ${ip_type}

    ${abbr} =  Set Variable if   '${ip_type}' == 'ipv4'      ipV4AddressDN1        ipV6AddressDN1
    ${filter} =  Set Variable if   '${ip_type}' == 'ipv4'    IPv4        IPv6
    ${dist_name} =  Set Variable if   ${ue_index} == 0     ${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1    ${MRBTS_ID}/${NRBTS_ID}/SNSSAI-3


    log to console      ${dist_name}
    ${NgU_dist_name}     COAM.GetParameterValue     dist_name=${dist_name}
    ...                                             filter_param=${filter} address 1 distinguished name   abbr=${abbr}
    ${ngU_ip_addr}       COAM.GetParameterValue     dist_name= ${NgU_dist_name}
    ...                                             filter_param=Local ${filter} address  abbr=localIpAddr
    [Return]   ${ngU_ip_addr}   ${NgU_dist_name}

Get vlan ID of slice through WebUI
    [Arguments]   ${NgU_dist_name}

    ${IPIF_dist_name}   ${rest}   Split String From Right    string=${NgU_dist_name}   separator=/    max_split=1

    log to console     ${IPIF_dist_name}

    ${Vlan_dist_name}    COAM.GetParameterValue     dist_name=${IPIF_dist_name}
    ...                                             filter_param=Layer 2 interface reference    abbr=interfaceDN

    ${Vlan_ID}           COAM.GetParameterValue     dist_name=${Vlan_dist_name}
    ...                                             filter_param=VLAN ID    abbr=vlanId

    [Return]   ${Vlan_ID}

Check Vlan ID in package of slice
    [Documentation]   Check UL data first, then DL data
    [Arguments]    ${expected_vlan}   ${NgU_ip_addr}   ${input_pcap}

    Wireshark.ReadLog    filename=${input_pcap}    filter=ip.src == ${NgU_ip_addr}
    @{vlan_id}    Wireshark.GetElementValue    check_param=vlan.id
    should be equal    ${vlan_id}[0]     ${expected_vlan}

    Wireshark.ReadLog    filename=${input_pcap}    filter=ip.dst == ${NgU_ip_addr}
    @{vlan_id}    Wireshark.GetElementValue    check_param=vlan.id
    should be equal    ${vlan_id}[0]     ${expected_vlan}

COAM.GetParameterValue
    [Arguments]    ${dist_name}   ${filter_param}   ${abbr}
    ${value}   Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}    abbr=${abbr}
    [Return]       ${value}

Generate 988 B2 scf file
    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}
    gNB.ModifySCF         InputFile=${TL_S1_base_SCF}                       OutputFile=${LOG_PATH}/988_B_2_SNSSAI.xml
    ...                   ParameterToDelete=${PARAMS_TO_DELETE_988_B}
    ...                   ParamterToModify=${PARAMs_TO_MODIFY_988_B}      MOsToAdd=${ADD_MOs_988_B}
    ...                   ListParamterToModify=${LIST_TO_MODIFY_988_B}    ListToAdd=${ADD_TO_LIST_988_B}

Refine PA Port
    run keyword and ignore error    Set Suite Variable     ${5GRU1_ANT1}    ${PA_PORT[0]}
    run keyword and ignore error    Set Suite Variable     ${5GRU1_ANT2}    ${PA_PORT[1]}
    run keyword and ignore error    Set Suite Variable     ${5GRU2_ANT1}    ${PA_PORT[2]}
    run keyword and ignore error    Set Suite Variable     ${5GRU2_ANT2}    ${PA_PORT[3]}
    run keyword and ignore error     Set Suite Variable     ${5GRU3_ANT1}    ${PA_PORT[4]}
    run keyword and ignore error     Set Suite Variable     ${5GRU3_ANT2}    ${PA_PORT[5]}
    run keyword and ignore error     Set Suite Variable     ${5GRU4_ANT1}    ${PA_PORT[6]}
    run keyword and ignore error     Set Suite Variable     ${5GRU4_ANT2}    ${PA_PORT[7]}

WEBUI.Get Alarm Info
    [Arguments]
    Run Keyword And Ignore Error    COAM_WebEM.Login
    ${alarm_info}    selenium_coam.get_active_alarm_info
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    [Return]    ${alarm_info}

Suite Setup For 988
    Import Variables     ${CFGFILE_PATH}/5GC000988/Delta_SCF.py
    TestSuite.Start
    set suite variable   ${TL_SCF}         ${CFGFILE_PATH}/5GC000988/TL203_base_scf.xml
    set suite variable   ${GoldenSCF_PATH}    ${GoldenSCF_ON_GIT}/${GoldenSCF}
    set suite variable   ${TL_DeltaPath}              ${CFGFILE_PATH}/TLDelta.py
    set suite variable   ${DeltaPath}                 ${CFGFILE_PATH}/5GC000988/Delta_SCF.py
    run keyword and ignore error     PA.AdjustAttenuationValueByGroups
    Create Log Directories
    set suite variable    ${Log_PATH_Artifactory}    /opt/ute/workspace/CIT/Master/Case_Logs
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    gNB.FormatBTSID
    gNB.SetLoggingSeverity    LoggingSeverity=debug
    ${info}     Basic.GetStreamInfo     vstring=${AF_PATH}
    ${StreamInfo}    convert to string    ${info}
    ${TL_S1_base_SCF}    Run Keyword If    "${StreamInfo}"=="None"    gNB.Generate TL SCF
    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}    TLDelta_PATH=${CFGFILE_PATH}
    ...            TestLineSCF_cell_num=${1}   cell_type=Both
    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    ...    ELSE    gNB.Generate TL SCF
    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${info['GoldenSCF']}    TLDelta_PATH=${CFGFILE_PATH}/TLDelta_${info['StreamPrefix']}.py
    ...            TestLineSCF_cell_num=${1}   cell_type=Both
    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    set suite variable    ${TL_S1_base_SCF}


Teardown Suite
    TestSuite.Stop

#Spark.Change UE Mode To SA
#    [Arguments]    ${ue_alias}=UE_1
#    spark.config_5g_deployment    ue_alias=${ue_alias}    nettype=SA+NSA
#    spark.configure_apn    ue_alias=${ue_alias}    apnname=wap4     apn=wap4.nokia.com    mcc="460"    mnc="02"
#
#
#Spark.Change UE Mode To NSA
#    [Arguments]    ${ue_alias}=UE_1
#    spark.config_5g_deployment    ue_alias=${ue_alias}    nettype=NSA
#    spark.configure_apn    ue_alias=${ue_alias}    apnname=DXDATA2     apn=DXDATA2    mcc="460"    mnc="02"


Case Setup For 988
    TestCase.Start
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection

Case Teardown For 988
    [Arguments]   ${connection}=COAM
    TestCase.Stop
    Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog
    Run Keyword And Ignore Error    WEBUI.Backup current SCF
    log     ${TEST STATUS}
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    gNB.CollectSnapshot
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect snapshot logs
    Run Keyword And Ignore Error    GNB.Clean pcap logs
    Run Keyword And Ignore Error    GNB.kill admin process
    Run Keyword And Ignore Error    run   command=killall firefox
    Conn.ResetCache

WEBUI.Backup current SCF
    [Arguments]    ${filename}=${TEST NAME.replace(" ", "_")}.xml
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    coam.get_current_scf_file   local_dir_path=${LOG_PATH}   file_name=${filename}   connection=COAM   timeout=10
    COAM_Admin.Logout

GNB.kill admin process
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9

GNB.Clean pcap logs
    [Arguments]
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.Execute  cmd=rm -rf /ffs/run/config/toor4nsn/*.pcap   alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}

Wireshark.Capture_etha01_Pcap
    [Arguments]  ${filename}    ${connection}=${ALIAS_ASIK}
    gNB.Connect
    ssh.send command    command=dbgrrc mirror sport 14 dport 2 e b    connection=${connection}
    ssh.send command    command=tcpdump -s 0 -i etha01 -w ${log_dir}/${filename} -vv &>/dev/null &    connection=${connection}


Wireshark.Download_Pcap
    [Arguments]  ${filename}    ${listen_port}=fp0    ${log_dir}=${log_dir}
    gNB.Connect
    Wireshark.StopCapturinglog    listen_port=${listen_port}
    sleep    5s
    Wireshark.DownloadLogToUTE    filename=${filename}   log_dir=${log_dir}
    gNB.Disconnect


Wireshark.Download_CPIF_Pcap
    [Arguments]  ${filename}
    gNB.Connect
    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    sleep    5s
    wireshark.DownloadLogToUTEFromContainer    filename=${filename}    nodename=CPIF
    sleep    20s
    gNB.Disconnect

Spark.UE attach with ULDL traffic
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${throughput}=10MKbits/sec    ${duration}=600
    ...            ${apn_address}=${SA_APN}   ${ue_mode}=SA
    Run Keyword And Continue On Failure    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}     ue_index=${ue_index}    power_reset=True
    sleep    10s
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}     ue_index=${ue_index}    power_reset=True
    sleep    5s
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}    5Grach_ed=${5Grach_ed}   4G_check=${false}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=${throughput}
    ...    duration=${duration}    apn_address=${apn_address}    ue_mode=${ue_mode}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul     throughput=${throughput}
    ...    duration=${duration}    apn_address=${apn_address}    ue_mode=${ue_mode}
    sleep    10s
    power_ue.Check throughput    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=5
    power_ue.Check throughput    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    throughput=2

Spark.Detach UE with Stop traffic
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${apn_address}=${SA_APN}   ${ue_mode}=SA
    power_ue.Stop traffic    ue_type=${UE_TYPE}    ue_index=${ue_index}    direction=dl    apn_address=${apn_address}    ue_mode=${ue_mode}
    power_ue.Stop traffic    ue_type=${UE_TYPE}    ue_index=${ue_index}    direction=ul    apn_address=${apn_address}    ue_mode=${ue_mode}
    power_ue.UE Detach    ue_type=${UE_TYPE}     ue_index=${ue_index}    power_reset=True

Multi_UE Call with_traffic
    [Arguments]    ${filename}    ${log_dir}=${log_dir}
    gNB.Connect
    Run Keyword And Continue On Failure    Wireshark.StartCaptureNGLog   filename=${filename[0]}    log_dir=${log_dir}
    Run Keyword And Continue On Failure    Spark.UE attach with ULDL traffic    ue_index=${0}    apn_address=${SA_APN}   ue_mode=SA
#    Run Keyword And Continue On Failure    Spark.UE attach with ULDL traffic    ue_index=${1}    apn_address=${NSA_APN}   ue_mode=NSA
    Run Keyword And Continue On Failure    gNB.Connect
    Run Keyword And Continue On Failure    Wireshark.Capture_etha01_Pcap   filename=${filename[1]}
    sleep    20s
    Run Keyword And Continue On Failure    Wireshark.Download_Pcap    listen_port=etha01    filename=${filename[1]}
    Run Keyword And Continue On Failure    gNB.Connect
    ${resp}    ssh.execute    command=ddal -s ddal_sysinfo_module_get_unit_id 0    connection=${ALIAS_ASIK}
    ${NG_port}      set variable if     ${resp.count("ASIB")} > 0     br1    fp0
    Run Keyword And Continue On Failure    Wireshark.Download_Pcap    listen_port=${NG_port}    filename=${filename[0]}

    Run Keyword And Ignore Error    Spark.Detach UE with Stop traffic    ue_index=${0}     apn_address=${SA_APN}   ue_mode=SA
#    Run Keyword And Ignore Error    Spark.Detach UE with Stop traffic    ue_index=${1}    apn_address=${NSA_APN}   ue_mode=NSA

Multi_UE Call with_traffic And CaptureLogs For 988_B
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    ...    ${power_reset}=false    ${ue_mode}=SA    ${apn}=wap1nokiacom    ${iperf_port}=default
    ...    ${multidrb_QoS_dest}=null   ${check_tput_on_ue}=false    ${target_avg_percent}=0.8
    ...    ${target_min_percent}=0.5    ${check_throughput_duration}=120    ${call_loop}=1
    ...    ${cell_index_list}=1    ${dl_target_throughput}=5    ${ul_target_throughput}=5
    ...    ${ue_index}=0    ${detach_request}=true
    ${UECFG}=    run keyword if     "${UECFG}"=="NULL"   MultiUE._L3CallBuildParameters
    ...    power_reset=${power_reset}    ue_mode=${ue_mode}    apn=${apn}    iperf_port=${iperf_port}
    ...    multidrb_QoS_dest=${multidrb_QoS_dest}   check_tput_on_ue=${check_tput_on_ue}    target_avg_percent=${target_avg_percent}
    ...    target_min_percent=${target_min_percent}    check_throughput_duration=${check_throughput_duration}    call_loop=${call_loop}
    ...    cell_index_list=${cell_index_list}    dl_target_throughput=${dl_target_throughput}    ul_target_throughput=${ul_target_throughput}
    ...    ue_index=${ue_index}    detach_request=${detach_request}
    ...    ELSE    set variable    ${UECFG}
    set suite variable    ${UECFG}    ${UECFG}
    gNB.Connect
    Run Keyword And Continue On Failure    Wireshark.StartCaptureNGLog   filename=988_B2_NG.pcap   log_dir=${log_dir}
    Run Keyword And Continue On Failure    MultiUE.PrepareUE    UECFG=${UECFG}    default_ue_index=${default_ue_index}
    Run Keyword And Continue On Failure    MultiUE.Attach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
    sleep    5
    Run Keyword And Continue On Failure    MultiUE.StartDLTraffic       UECFG=${UECFG}    default_ue_index=${default_ue_index}
    Run Keyword And Continue On Failure    MultiUE.StartULTraffic       UECFG=${UECFG}    default_ue_index=${default_ue_index}
    Run Keyword And Continue On Failure    MultiUE.CheckThoughput       UECFG=${UECFG}    default_ue_index=${default_ue_index}
    Run Keyword And Continue On Failure    gNB.Connect
    Run Keyword And Continue On Failure    Wireshark.Capture_etha01_Pcap   filename=988_B2_traffic.pcap
    sleep    20s
    Run Keyword And Continue On Failure    Wireshark.Download_Pcap    listen_port=etha01    filename=988_B2_traffic.pcap
    Run Keyword And Continue On Failure    gNB.Connect
    ${resp}    ssh.execute    command=ddal -s ddal_sysinfo_module_get_unit_id 0    connection=${ALIAS_ASIK}
    ${NG_port}      set variable if     ${resp.count("ASIB")} > 0     br1    fp0
    Run Keyword And Continue On Failure    Wireshark.Download_Pcap    listen_port=${NG_port}    filename=988_B2_NG.pcap
    Run Keyword And Continue On Failure    MultiUE.StopDLTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
    Run Keyword And Continue On Failure    MultiUE.StopULTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
    Run Keyword And Continue On Failure    MultiUE.Detach               UECFG=${UECFG}    default_ue_index=${default_ue_index}


COAM.Lock all cells via WEBUI
    ${cell_num}    selenium_coam.get_number_of_cells
    FOR    ${i}    IN RANGE    ${cell_num}
        ${cell_info}    selenium_coam.get_cell_info    cell_idx=${i+1}
        log    ${cell_info} and ${cell_info['Status']['Administrative state']}
        run keyword if    '${cell_info['Status']['Administrative state']}'=="Unlocked"
        ...         Run Keywords    selenium_coam.lock_cell    cell_idx=${i+1}    timeout=60    AND    sleep    2min
        ...         ELSE     Log    continue the next steps
    END


COAM.Lock all snssai via WEBUI
    [Arguments]    ${snssai_num}
    FOR    ${i}    IN RANGE    ${snssai_num}
        set suite variable    ${num}   ${i+1}
        Run Keyword    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-${num}    filter_param=Administrative state
        ...    new_value=Locked    abbr=administrativeState
    END

Process.Prepare for 988 commission
    [Arguments]    ${filename}
    WEBUI.Backup current SCF    filename=${filename}
    COAM_WebEM.Login
    COAM.Lock all cells via WEBUI
    load_scf    ${LOG_PATH}/${filename}
    ${snssaiDNList}    get_all_values_from_scf    dist_name=${MRBTS_ID}/${NRBTS_ID}/TRACKINGAREA-210     list_name=snssaiDNList
    ${snssai_num}=   Get Match Count   ${snssaiDNList}    ${MRBTS_ID}/${NRBTS_ID}*
    set suite variable    ${snssai_num}
    COAM.Lock all snssai via WEBUI    snssai_num=${snssai_num}
    Run Keyword And Continue On Failure    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.Logout

CheckX2StatusUntilReady
    [Arguments]    ${alias}=${ALIAS_ASIK_SLAVE}
    gNB.Connect
    gNB.CheckX2StatusUntilReady    dep_1514=Yes    alias=${alias}
    gNB.Disconnect

COAM_WEBEM.CheckTRSConutersWithUPandLowerValue
    [Arguments]    ${counter_id}   ${up_value}   ${lower_value}    ${full_path}=${None}
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_transport_counters   counter_id=${counter_id}    full_path=${full_path}
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    should be true    ${values[-1]} > ${lower_value}
    should be true    ${values[-1]} < ${up_value}
