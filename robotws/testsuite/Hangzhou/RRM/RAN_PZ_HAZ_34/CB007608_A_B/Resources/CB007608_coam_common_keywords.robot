*** Settings ***
Documentation
...   author: Hu Jiao
...   contact: jiao.hu@nokia-sbell.com
...   squad group: SG_05


Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    Telnet
Library    DateTime
Library    Process
Library    taf.transport.ssh    WITH NAME    csn
Resource    ./../../../../resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    ./../../../../resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    ./../../../../resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    ./../../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    ./../../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    ./../../../../resources/RAN_PZ_HAZ_34/robot/asod.robot
Resource          ./../../../../resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Library        taf.collectors.btslog       WITH NAME   btslog
#Library         ./DownloadLibrary.py
Library    taf.analyzer.pcap    WITH NAME    pcap
Library    pdmlanalyzer.py
Library    ./../../5GC000772/resources/5GC000772_Resources.py                  WITH NAME       mylib772

*** Variables ***
${TS_LOG_PATH_BASE}      /opt/workspace/CIT/Master/Case_Logs
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${ENB_ADDRESS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${SN}    ${tl.ues[0].serial_number}
${gnb_path}    /tmp/
${gnb_index}=    0
${iperf_path}    ${tl.ues[0].iperf_details.iperf_path}
${cpif_log_name}    cpif.pcap
${packet_filters}    x2ap.X2AP_PDU == 1 && x2ap.procedureCode == 27
${TESTLINE_NAME}    7_5_CLOUD402T0${tl.enbs[0].instance_id}
${enb_path}    /user/toor4nsn



*** Keywords ***

##Iperf server
Start the DL data throughput
    [Arguments]    ${ue_index}=${0}    ${ue_addr}=${UE_IP}
    #${ue_addr} =    Get the UE Ip address    ue_index=${ue_index}
    Close the iperf process on APPserver    port=${dl_port}
   # Close the iperf process on Qualcomm    ue_index=${ue_index}
    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${dl_port}
    Start DL traffic via iperf on Appserver    ue_addr=${ue_addr}    dl_time=${dl_time}    dl_port=${dl_port}
    ...    dl_throughput=${dl_throughput}    dl_length=${dl_length}

Start the UL data throughput
    [Arguments]    ${ue_index}=${0}
    Close the iperf process on APPserver     port=${ul_port}
    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${ul_port}
    Start UL traffic via iperf command    time=${ul_time}    traffic=${ul_throughput}    ue_index=${ue_index}
    ...    UL_port=${ul_port}    buffer_size=${ul_length}
    #Check the iperf progress exist    connection=cygwin    port=${ul_port}    ue_sn=${serial_number}
    #Start UL traffic via iperf from andriod UE    ue_index=${ue_index}    ul_time=${ul_time}
    #...    ul_port=${ul_port}    ul_throughput=${ul_throughput}    ul_length=${ul_length}

Close iperf progress
    [Arguments]    ${ue_index}=${0}
    Close the iperf process on APPserver    port=${dl_port}
    Close the iperf process on APPserver    port=${ul_port}
    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${dl_port}    ue_index=${ue_index}
    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${ul_port}


##BTS keyword
Common Suite Setup for COAM
    COAM Create log directory    ${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${local_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${local_path}

snapshot collect
    Connect to gnb coam via ssl
    #COAM Download scf from cluster    scf_dir_path=${local_path}
    COAM Save snapshot via rest api    log_path=${local_path}
    COAM Teardown gnb connections

Prepare the classical COAM BTS cell onair
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare with COAM classical BTS cell onair
    set suite variable    ${cell_status}

Prepare with COAM classical BTS cell onair
    5GC000886_coam_common_keywords.Perform full commission for COAM gnb
    Reset UE Control PC
    Run Keyword And Ignore Error    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}
    ...                    parameter=${enbx2_para}    value=locked
    sleep    300s
    #Check gnb COAM classical start normally
    Run Keyword And Ignore Error    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}
    ...                     parameter=${enbx2_para}    value=unlocked
    sleep    600s
    #Check the gnb cell status onair


Start To Capture Wireshark Logs
    [Arguments]     ${filename}    ${connection}    ${interface}
    gNB connections
    csn.send command    command=tcpdump sctp -i ${interface} -w ${gnb_path}${filename}   connection=${connection}

Start To Capture x2 Wireshark Logs

    [Arguments]     ${filename}    ${connection}    ${interface}
    ...    ${dst}=${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    gNB connections
    csn.send command    command=tcpdump sctp -i ${interface} -w ${gnb_path}${filename} and dst ${dst}
    ...    connection=${connection}




gNB connections
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=gnb

Stop and Save classical WS Logs
    [Arguments]    ${x2logname}    ${f1logname}
    gNB connections
    Stop and download Logs    logname=${f1logname}    connection=gnb
    Stop and download Logs    logname=${x2logname}    connection=gnb

Stop and download Logs
    [Arguments]    ${logname}    ${connection}
    gNB connections
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   ${gnb_path}${logname}   ${local_path}${logname}   connection=${connection}
    sleep    3

Change the COAM parameter online
    [Arguments]    ${dist_name}    ${parameter_name}    ${new_value}
    coam_admin.connect_to
    ...        bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...        username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...        password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    #...        name=${connection}
    ${para_MO}=    Get MO For Uniq Parameter    ${parameter_name}
    ${para_old}=    get Parameter    ${para_MO}    ${parameter_name}
    set test variable     ${para_old}
    set test variable     ${para_MO}
    run keyword if   '${para_old}'!='${new_value}'    Change parameter    ${para_MO}    ${parameter_name}
    ...    ${new_value}
    coam_admin.teardown

Check the gnb cell status onair
    Connect to gnb coam via ssl
    wait until keyword succeeds    5min   30s    COAM Check GNB cell on air
    COAM Teardown gnb connections

Get info status check
    [Arguments]    ${info_status}
    ${Status} =   get from dictionary    ${info_status}    Status
    ${opr_state} =   get from dictionary    ${Status}    Operational state
    should be equal    ${opr_state}    Enabled
    ${avi_state} =   get from dictionary    ${Status}   Availability status
    should be equal    ${avi_state}    Online
    ${adm_state} =   get from dictionary    ${Status}    Administrative state
    should be equal    ${adm_state}    Unlocked

Check gnb COAM classical start normally
    Check Airscale HW module status
    #wait until keyword succeeds    5min   30s    Check the sctp port UP    port_num=${f1_sctp_port}
    Check the gnb RU status ready
    wait until keyword succeeds    5min   30s    Check the sctp port UP    port_num=${x2_sctp_port}

Check the sctp port UP
    [Arguments]    ${port_num}
    Connect to BB1 master    alias=BB1
    csn.send Command    command=netstat -anl |grep sctp    connection=BB1
    sleep    3s
    ${sctp_status} =    csn.read_output    connection=BB1
    csn.disconnect     connection=BB1
    should contain     ${sctp_status}     ${port_num}

Check the gnb RU status ready
    Connect to gnb coam via ssl
    wait until keyword succeeds    5min   30s    COAM Check GNB RU status
    COAM Teardown gnb connections

Caculate the wireshark timevalue to seconds
    [Arguments]    ${input_value}    ${index}
    ${list} =    Evaluate    ${input_value}[${index}].split(' ')
    ${list_0} =    Evaluate    ${list}[-2].split(':')
    ${msg_time_sec} =    EVALUATE  float(${list_0}[0])*0+float(${list_0}[1])*60+float(${list_0}[2])*1
    [Return]    ${msg_time_sec}


##ENB Keyword
Start To Capture ENB Logs
    [Arguments]     ${filename}  ${connection}=ENB    ${interface}=any
    wait until keyword succeeds    5 min    10 sec    Connect to ENB    alias=ENB
    csn.send command    command=tcpdump -i ${interface} -w ${enb_path}${filename}   connection=${connection}

Stop and download ENB Logs
    [Arguments]     ${filename}=s1x2log.pcap    ${connection}=ENB
    #wait until keyword succeeds    5 min    10 sec    Connect to ENB    alias=ENB
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    5
    csn.download_file   ${enb_path}${filename}   ${local_path}${filename}   connection=${connection}

Stop and download ENB Logs for 21B
    [Arguments]     ${filename}=s1x2log.pcap    ${connection}=ENB
    wait until keyword succeeds    5 min    10 sec    Connect to ENB    alias=ENB
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    5
    csn.download_file   ${enb_path}${filename}   ${local_path}${filename}   connection=${connection}


Precondition for power UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    capatibility_index=${0}    reset_sol=pc_reset
    ...    detach_request=${true}    ui_version=S21UI3.1

Attach and check power UE
    [Arguments]    ${ue_type}    ${MCI_value}    ${5Gstatus}=PASS    ${ue_index}=${0}
     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    log_type=Aasyslog
     ${power_status}    Run Keyword And Return Status  power_ue.Verify attach    ue_type=${ue_type}
     ...    5Grach_ed=${5Grach_ed}    5Gstatus=${5Gstatus}    ue_index=${ue_index}
     Run Keyword If   ${power_status} ==False   Verify attach by adb   ue_index=${ue_index}    MCI_value=${MCI_value}


Detach for power UE
    [Arguments]    ${ue_type}=${ue_type}    ${ue_index}=${0}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}




ADB Service Restart
    [Documentation]  Use adb command to recover adb service
    [Arguments]    ${serial_number}    ${cpc_alias}
    log to console     \nInfo:Reboot ADB Service on ${cpc_alias}!
    csn.execute    command=sudo adb -s ${serial_number} kill-server    connection=${cpc_alias}
    csn.execute    command=sudo adb -s ${serial_number} start-server    connection=${cpc_alias}
    sleep   2s

Reboot UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...             ${cpc_alias}=cygwin
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${cpc_alias}
    sleep   5s
    ADB Service Restart     serial_number=${serial_number}    cpc_alias=${cpc_alias}
    Sleep   15s
    csn.send_command   command=adb -s ${serial_number} reboot     connection=${cpc_alias}      timeout=5
    Sleep   5s
    [Teardown]         Run Keyword And Ignore Error    csn.disconnect    connection=cygwin

check aireplane state and wait the PM period expire
    [Arguments]    ${ue_index}=${ue_index}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    #...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    #...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}
     ${status}    Check airplane mode status on    ue_index=${ue_index}
     Run Keyword If	    '${status}' == 'False'
     ...    Run Keywords    Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}
     ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}
     ...    ue_index=${ue_index}
     ...    close_task=${close_task}
     Wait until the next Measurement Period starts


Verify attach by adb

    [Arguments]    ${ue_index}=${0}    ${sleep_time_before_read_output}=${None}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
	...    ${MCI_value}=2579969

    Connect to control pc enhanced    ${ue_index}

        csn.send command
    ...    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep -E "mCellIdentity=CellIdentityLte|mTelephonyDisplayInfo"
    ...    connection=cpc_${ue_index}
    ...    timeout=15
    run keyword if    '${sleep_time_before_read_output}'!='${None}'    BuiltIn.sleep    ${sleep_time_before_read_output}
    ${result} =    csn.read output    connection=cpc_${ue_index}
    Should contain  ${result}    override=NR_NSA    mCi=${MCI_value}

    Log to console    \nINFO:UE ATTACH NSA successfully.
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=cpc_${ue_index}

Change Parameter
    [Arguments]    ${DN}    ${PARAM}    ${NEW_VALUE}    ${OP}=update
    ${res}=    coam_admin.perform_parameter_recommissioning    dist_name=${DN}    parameter=${PARAM}    operation=${OP}    value=${NEW_VALUE}
    ...    skip_parameter_relation_errors=${True}
    should be true    '${res['commissioningResult']['activationResult']['resultNode']['parameters']['result']}'=='Success'


Get Parameter
    [Arguments]    ${DN}    ${PARAM}

    ${SCF}=    coam_admin.get_scf    export_type=configurationAndRuntimeObjects
    ${xml_root}=    XML.Parse XML           ${SCF}
    ${value}=       XML.Get Element Text    ${xml_root}      .//managedObject[@distName="${DN}"]/p[@name\="${PARAM}"]

    [Return]    ${value}


Precondition: check gNB can be on air

    log to console     \nINFO:Check gNB can be on air
    coam_admin.connect_to
    ...        bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...        username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...        password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...        name=coam_admin

    ${RES}=    coam_admin.get_bts_statuses    connection=coam_admin
    should be equal as strings    ${RES['proceduralState']}    OnAir    msg=gNB is not OnAir
    log to console     \nINFO:gNB is on air
    log to console     \nINFO:start BTS log
    #Start Btslog
   [Teardown]  coam_admin.teardown    connection=coam_admin

Tests_Recover
    Close iperf progress     ue_index=${0}
    Change the COAM parameter online    dist_name=${dist_name_A02}    parameter_name=${parameter_name_A02}    new_value=${new_value_A02_Back}
    Detach for power UE    ue_type=samsung     ue_index=${0}
    Run Keyword If Test Failed    snapshot collect
    #Stop Btslog    target_dir=${local_path}
Tests_Recover_7200
    Run Keyword If Test Failed    snapshot collect
    #Stop Btslog    target_dir=${local_path}
Tests_Recover_6555
    Close iperf progress     ue_index=${0}
    Run Keyword If Test Failed    snapshot collect
    #Stop Btslog    target_dir=${local_path}
Start Btslog
    [Documentation]    :Author: Soenke Kullberg
    ...     KW starts Btslog on Testpc with log-collector
    ...     https://confluence.int.net.nokia.com/display/EE/EE+BTSlog
    ...     *Note:* KW works only on ute-vm
    Return From Keyword If  '${tl.test_pc.default_ssh_connection_details.username}'!='ute'   message=Works only on Cloud
    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${tl.test_pc.default_ssh_connection_details.addr}
    ...     user=${tl.test_pc.default_ssh_connection_details.username}
    ...     password=${tl.test_pc.default_ssh_connection_details.password}
    ${btslog_collector_name}=   Set Variable    btslog
    btslog.create_btslog_collector
    ...     name=${btslog_collector_name}
    ...     executor=${testpc_ssh_config}
    btslog.setup_collectors    names=${btslog_collector_name}
    btslog.start_collectors    names=${btslog_collector_name}
    btslog.set_suite_alias     ${btslog_collector_name}


Stop Btslog
    [Documentation]    :Author: Soenke Kullberg
    ...    Stop and fetch btslog from Testpc
    ...    *Note:* KW works only on ute-vm
    ...    :return path: Path to btslog file
    ...    :param target_dir: Directory to store the btslog file
    [Arguments]    ${target_dir}=None
    Return From Keyword If  '${tl.test_pc.default_ssh_connection_details.username}'!='ute'   message=Works only on Cloud
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${btslog_collector_name}=   Set Variable    btslog
    btslog.stop_collectors         names=${btslog_collector_name}
    # WA for https://jira3.int.net.nokia.com/browse/TALIB-854
    Builtin.Sleep   15 sec      # wait for btslog to close
    # WA for https://jira3.int.net.nokia.com/browse/TALIB-854
    btslog.collect_collectors      names=${btslog_collector_name}   target_dir=${target_dir}
    btslog.teardown_collectors     names=${btslog_collector_name}
    [RETURN]    ${target_dir}/${btslog_collector_name}/syslog_files.tgz




Get MO For Uniq Parameter
    [Arguments]    ${PARAM}

    ${SCF}=    coam_admin.get_scf    export_type=configurationAndRuntimeObjects
    ${xml_root}=    XML.Parse XML           ${SCF}
    ${n_param}=     XML.get element count   ${xml_root}     .//p[@name="${PARAM}"]

    should be true    ${n_param}==1
    Log To Console      get elementcount successfully

    ${DN}=          Set Variable        MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    [Return]    ${DN}

Check value in new Pcap
    [Arguments]    ${value_filters}   ${expect_value}    ${alias}
    @{valuesList}=    pcap.Get Field Value By Xpath    xpath=${value_filters}    pcap_parser=${alias}
    ${values}    Set Variable    ${valuesList}[0]
    ${passed}=    Run Keyword And Return Status    Should Be String    ${values}
    Run Keyword If    ${passed}    should be true    '${values}'=='${expect_value}'
    ...    ELSE    should be true    '${values[0]}'=='${expect_value}'


Check string value in new Pcap
    [Arguments]    ${value_filters}   ${expect_value}    ${alias}
    @{valuesList}=    pcap.Get Field Value By Xpath    xpath=${value_filters}    pcap_parser=${alias}
    ${values}    Set Variable    ${valuesList}[0]
    ${passed}=    Run Keyword And Return Status    Should Be String    ${values}
    Run Keyword If    ${passed}    should be true    '${values}'=='${expect_value}'
    ...    ELSE    should be true    '${values[0]}'=='${expect_value}'

Check value not exist in new Pcap
    [Arguments]    ${value_filters}    ${alias}
    @{valuesList}=    pcap.Get Field Value By Xpath    xpath=${value_filters}    pcap_parser=${alias}
    ${values}    Set Variable    ${valuesList}[0]
    ${passed}=    Run Keyword And Return Status    Should Be String    ${values}
    Run Keyword If    ${passed}    Should Be Empty    ${values}
    ...    ELSE    Should Be Empty    ${values[0]}

-----------------------------------------------------------------------
# [1] CB007608_A_CB006555_Migration_rules_for_22R1_verification_config_2_mmW_ASIL_eCPRI
#-----------------------------------------------------------------------
Step 1: Collect CPIF log

     log to console     \nStep 1: Collect CPIF log
    ssh.Connect to
    ...    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...    alias=CPIF
    Start Tcpdump    ${gnb_path}    ${cpif_log_name}    CPIF    ${empty}      any    protocol=sctp
    log to console     \nINFO:start to collect CPIF log

Step 2: Attach UE and Send DL traffic
    [Arguments]    ${MCI_value}

    log to console     \nStep 2: Attach UE and Send DL traffic

    Precondition for power UE    ue_type=samsung     ue_index=${0}
    #Attach and check power UE    ue_type=samsung     ue_index=${0}    log_type=journallog
    #Attach and check power UE    ue_type=samsung     ue_index=${0}    log_type=Aasyslog
    Attach and check power UE    MCI_value=234    ue_type=samsung      ue_index=${0}
    log to console     \nINFO:Attach UE successfully


    Start the DL data throughput        ue_index=${0}    ue_addr=${UE_IP}

    log to console     \nINFO:tart DL taffic successfully

Step 3: Stop pcap on CPIF and download to testPc

    log to console     \nStep 3: Stop pcap on CPIF and download to testPc
    ssh.Connect to
    ...    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...    alias=CPIF

    asod.Stop Tcpdump     connection=CPIF
    Download Pcap Log    log_path=${gnb_path}    log_name=${cpif_log_name}    connection=CPIF
    log to console     \nINFO:logs are saved to:${local_path}/${cpif_log_name}

Step 4: Stop DL traffic and detach UE


    log to console     \nStep 4: Stop DL traffic and detach UE
    Detach for power UE    ue_type=samsung     ue_index=${0}

    log to console     \nINFO:Detach UE successfully



Step 5: Verify parameters of dynamic pdcch configured correctly

    log to console    \nStep 5: Verify parameters of dynamic pdcch configured correctly
    pcap.load_pcap_file    ${local_path}/${cpif_log_name}    command_template=${command_template_with_Y}    alias=step5
    pcap.Filter Packets By Expression    filter_expression=${packet_filters}    pcap_parser=step5

    # check initial BWP locationAndBandwidth
    Check value in new Pcap    value_filters=${rrc_initial_DL_BWP_RIV}   expect_value=17875    alias=step5
    Check value in new Pcap    value_filters=${rrc_initial_UL_BWP_RIV}   expect_value=17875    alias=step5

    # check dedicated BWP locationAndBandwidth
    Check value in new Pcap    value_filters=${rrc_dedicated_DL_BWP_RIV}    expect_value=17875    alias=step5
    Check value in new Pcap    value_filters=${rrc_dedicated_UL_BWP_RIV}   expect_value=17875    alias=step5

    #check common search space
    Check value in new Pcap    value_filters=${rrc_PDCCH_common_searchSpace_type1_1}    expect_value=0    alias=step5
    Check value not exist in new Pcap    value_filters=${rrc_PDCCH_common_searchSpace_type1_2}    alias=step5
    Check string value in new Pcap    value_filters=${rrc_PDCCH_common_searchSpace_type1_3&4}      expect_value=c0:00    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_common_searchSpace_type1_5}      expect_value=0    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_common_searchSpace_type1_6}      expect_value=2    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_common_searchSpace_type1_7}      expect_value=0    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_common_searchSpace_type1_8}      expect_value=0    alias=step5
    Check value not exist in new Pcap    value_filters=${rrc_PDCCH_common_searchSpace_type1_9&12}    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_common_searchSpace_type1_10}      expect_value=1    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_common_searchSpace_type1_11}      expect_value=1    alias=step5

    #check dedicated coreset
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_coresetDedicated_1}       expect_value=1    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_coresetDedicated_2}       expect_value=1    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_coresetDedicated_4}       expect_value=1    alias=step5
    Check value in new Pcap    value_filters=${coresetDedicated_7}       expect_value=ff:00:00:00:00:00    alias=step5

    #check dedicated search space type3
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_type3_1}      expect_value=0    alias=step5
    Check value not exist in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_type3_2}    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_type3_3&4}      expect_value=c0:00    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_type3_5}      expect_value=0    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_type3_6}      expect_value=0    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_type3_7}      expect_value=2    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_type3_8}      expect_value=0    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_type3_9}      expect_value=0    alias=step5
    Check value not exist in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_type3_10&13}    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_type3_11}      expect_value=2    alias=step5

    #check dedicated search space UE-specific
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_UE_specific_1}      expect_value=1    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_UE_specific_2}      expect_value=1    alias=step5
    Check string value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_UE_specific_3&4}      expect_value=c0:00    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_UE_specific_5}      expect_value=0    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_UE_specific_6}      expect_value=0    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_UE_specific_7}      expect_value=2    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_UE_specific_8}      expect_value=0    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_UE_specific_9}      expect_value=0    alias=step5
    Check value not exist in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_UE_specific_10&13}    alias=step5
    Check value in new Pcap    value_filters=${rrc_PDCCH_Dedicated_searchSpace_UE_specific_11}      expect_value=3    alias=step5

    #check dmrsTypeAPosition
    Check value in new Pcap    value_filters=${dmrsTypeAPosition}     expect_value=0    alias=step5


    log to console      \nINFO:Verificaiton pass




##CB007608	common keyword

Download luashark

    [Documentation]                    Extract the SW Version from WebEM

         coam_admin.connect_to
    ...        bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...        username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...        password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...        name=coam_admin

        ${swversion}=                      coam_admin.get_sw_version  connection=coam_admin
    Set Suite Variable      ${swversion}
    OperatingSystem.Create Directory    /home/ute/luashark
    OperatingSystem.List Files In Directory    /home/ute    *luashark*
    OperatingSystem.Remove Files    /home/ute/*luashark.zip*
    OperatingSystem.Remove Files    /home/ute/luashark*.zip*
    OperatingSystem.List Files In Directory    /home/ute    *luashark* 
    ${files}    mylib772.get_file_for_Load    ${SW_Version}     
    run keyword if  not 'No' in '${files}'    mylib772.unzip_file    ${files}
    OperatingSystem.Directory Should Not Be Empty      /home/ute/luashark/generated_luashark  

   [Teardown]  coam_admin.teardown    connection=coam_admin


Check gNB can be on test mode

    log to console     \nINFO:Check gNB can be on test mode
    sleep     120s
    log to console     \nINFO:test
    coam_admin.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
    #coam_admin.connect_to
    #...        bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    #...        username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    #...        password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    #...        name=coam_admin
    log to console     \nconnect
    wait until keyword succeeds    30x  5s   gnb can be on test mode
    log to console     \nINFO:gNB is on test mode
   [Teardown]  coam_admin.teardown    connection=coam_admin

gnb can be on test mode
     ${RES}=    coam_admin.get_bts_statuses    connection=coam_admin
     should be equal as strings    ${RES['proceduralState']}    Test    msg=gNB is not OnAir



Start DL Test Transmitter
    [Arguments]   ${test_model}    ${ru_mode}    ${pci}    ${polarization}    ${beamPatternId}   ${p_max}    ${power_backoff}    ${mimo_rank}
    [Documentation]
    ...     Start 5G Downlik Test
    ...    :param test_model:  One of the following: TM1_1, TM1_2, TM2, TM2A, TM3_1, TM3_1A, TM3_2, TM3_3, TM3_1N.
    ...    :param ru_mode: One of the following: NR_Only, MSR (MSR is supported when RU contains EUTRA.Frequency.Band)
    ...    :param pci: Physical Cell ID -  [1..1007]
    ...    :param polarization: One of the following: P_plus45_or_0, P_minus45_or_90, P_both.
    ...    :param beam: Beam Pattern [0..1200]
    ...    :return:   It returns dict with data.
    ...    +-----------------------------------------------------------------------------------------------------------+
    ...    | Usage from Robot                                                                                           |
    ...    +============================================================================================================+
    ...    | Start DL Test Transmitter with the following parameters [TM1_1, NR_Only, 50, P_both, 1200, 26]             |
    ...    +------------------------------------------------------------------------------------------------------------+
    log to console      \nINFO:Start DL Test Transmitter
    set suite variable          ${test_model_value}     ${test_model}

    coam_admin.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin

     ${cell_list}=    coam_admin.get_cell_list    connection=coam_admin

     FOR     ${cell}    IN    @{cell_list['cells']['nr']}
            continue for loop if   '${cell['status']['administrativeState']}' != 'Unlocked'

              continue for loop if  '${cell['status']['blockingState']}' != 'Unblocked'
             ${cell_DN}=    set variable    ${cell['id']['internal']}
     END

     should not be equal    ${cell_DN}    unknown     msg=no cell available found

    ${dist_name}=    set variable     ${cell_DN}

    set suite variable    ${dist_name}
    ${my_response}=    coam_admin.start_5g_downlink_test
    ...                dist_name=${dist_name}

    ...                test_model=${test_model}
    ...                beam_pattern_id=${beamPatternId}
    ...                polarization=${polarization}
    ...                power_backoff=${power_backoff}
    ...                ru_mode=${ru_mode}
    ...                phys_cell_id=${pci}
    ...                i11_codebook_4_antports=0
    ...                i2_codebook_4_antports=0
    ...                i13_codebook_4_antports=${0}
    ...                mimo_rank=${mimo_rank}
    ...                codebook_2_antports=${0}
    ...                p_max=${p_max}
    ...                connection=coam_admin
    Log to console        ${my_response}
    ${my_result_node}=    Get From Dictionary    ${my_response}        resultNode
    ${my_parameters}=     Get From Dictionary    ${my_result_node}     parameters
    ${status}=            Get From Dictionary    ${my_parameters}      status
    Log to console        ${status}
    Should Contain         ${status}    Succeeded
    [Return]            ${test_model_value}
    [Teardown]  coam_admin.teardown    connection=coam_admin
    Log Variables




Stop Test Transmitter test model
    [Documentation]
    ...     Stop 5G Downlik Test
    ...    :param str dist_name: `NRCELL_R` object to stop the test on.
    ...    :return:   It returns dict with data.
     Log to console                       \nINFO:Stop Transmitter_test_model
     coam_admin.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
     ${my_response}=    coam_admin.stop_5g_downlink_test
    ...                dist_name=${dist_name}
    ...                connection=coam_admin

     Log to console        ${my_response}
     ${my_result_node}=    Get From Dictionary    ${my_response}        resultNode
     ${my_parameters}=     Get From Dictionary    ${my_result_node}     parameters
     ${status}=            Get From Dictionary    ${my_parameters}      status
     Log to console        ${status}
     Should Contain         ${status}    Succeeded
     [Teardown]  coam_admin.teardown    connection=coam_admin


Activate Test dedicated Mode

     log to console     \nINFO:Enter Test dedicated Mode
    coam_admin.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
    coam_admin.Reset_To_Test_Dedicated    connection=coam_admin
    [Teardown]  coam_admin.teardown    connection=coam_admin



Capture BIP log


    log to console     \nINFO:connect to common unit master
    Wait Until Keyword Succeeds	  3x	2s   connect and pre for bip capture
    log to console     \nINFO:start to capture bip logs
    ASIL Bip Capture with gnbMirroring scripts   connection=ASIL_Master



    sleep    2s
    log to console     \nINFO:stop capture bip logs and download logs to testPC
    Stop BIP capture on ASIL if needed and download BIP Logs to testPC   interface=ethbp1  connection=ASIL_Master

    csn.execute      command=rm -rf ${/}tmp${/}${bip_remote_log_name}     connection=ASIL_Master
    csn.Disconnect    connection=ASIL_Master
     Log Variables

connect and pre for bip capture
    Connect to Common Unit Master    alias=ASIL_Master
    log to console     \nINFO:prepare gnbMirroring scripts
    Precondition for bip capture with gnbMirroring scripts   connection=ASIL_Master

ASIL Bip Capture with gnbMirroring scripts
    [Documentation]    Author:zheng.4.liu@nokia-sbell.com
    ...    Descrition：Start BIP capture on gnb ASIK to support for 19A, 19B and trunk. also support feature 1514.
    ...    The scripts location: \\eseefsn50.emea.nsn-net.net\rotta4internal\5G_2\Oulu\juhakang\tools\gnbMirroring\V49
    ...    # General options
    ...    :param MIRRORING_MODE='local' # remote/local/manual, remote mirrors to EIF2, local dumps data to gNB,
    ...    manual enables mirroring but ABIL Master/Slave Xeon but does not capture data or disable mirroring
    ...    :param BB_BOARD_TYPE='ABIL' # 'ABIL'/'ABIO'
    ...    # Mirror BB boards
    ...    :param BB_SLOT_1='true' # true/false
    ...    :param BB_SLOT_2='false' # true/false, do not enable for CA configs
    ...    :param BB_SLOT_3='false' # true/false, do not enable for CA configs
    ...    :param BB_SLOT_5='false' # true/false, do not enable for CA configs
    ...    :param BB_SLOT_6='false' # true/false, do not enable for CA configs
    ...    :param BB_SLOT_7='false' # true/false, do not enable for CA configs
    ...    # Mirrored interfaces, the less interfaces are configured for mirroring, the better are chances to not to drop packets
    ...    :param L2_L1_BIP='true' # true/false
    ...    :param SYSCOM_MIRRORING='true' # true/false, mirrors syscom traffic between control and baseband boards
    ...    :param CARRIER_AGGREGATION='false' # true/false, for GC2/GD2 L2-RT instances
    ...    :param BACKHAUL_MIRRORING='false' # true/false, S1/X2 in Classical deployment, F1-U in Cloud deployment, works only in ASIK
    ...    :param L2HI_L2LO_MIRRORING='false' # true/false, traffic between L2-HI - L2-LO, only in ASIK
    ...    # Local mode options
    ...    :param FILTERING='off' # off/on, on filters out control messages sent in every TTI
    ...    :param USE_GULP='true' # true/false, use gulp engine for capturing instead of tcpdump, provides better performance
    ...    :param CAPTURING_TIME_SECONDS=5 # in seconds/special value 'infinite' keeps capture rolling
    ...    :param NUMBER_OF_FILES=1 # number of files created, tcpdump -W
    ...    :param FILE_SIZE_MBYTES=100 # size of file create, tcpdump -C
    ...    # connection
    ...    :param XTRACE='off' # on/off
    ...    # Debug options
    ...    :param connection <str> : asik master connection alias
    ...    the tcpdump command is like:
    ...    ssh -o ConnectTimeout=5s -F /etc/bsoc/bsoc_ssh_config 192.168.253.21 tcpdump -i ethbp1 -C 100 -W 1 -w /tmp/tcpdumpL2L1_filtering_off.pcap
    ...    2020/04/09 Chen Tong: update the invoke shell method to send command due to invoke shell not take effect on ASIB environment.
    [Arguments]    ${connection}=ASIK Master    ${gnb_mirroring}=gnbMirroring.sh     ${mirroring_mode}=local
    ...            ${bb_slot_1}=true    ${bb_slot_2}=false    ${bb_slot_3}=false
    ...            ${bb_slot_5}=true    ${bb_slot_6}=false    ${bb_slot_7}=false    ${l2_l1_bip}=true
    ...            ${syscom_mirroring}=true    ${carrier_aggregation}=false    ${backhaul_mirroring}=false
    ...            ${filtering}=off    ${use_gulp}=false     ${capturing_time_seconds}=infinite
    ...            ${number_of_files}=1    ${file_size_mbytes}=1    ${xtrace}=off    ${sleep_time}=10s    ${bip_prefix}=tcpdump_L2L1
    ${cmd_local}    catenate    nohup sh /ffs/run/config/scripts/${gnb_mirroring} --mirroring_mode=${mirroring_mode}
    ...             --bb_slot_1=${bb_slot_1} --bb_slot_2=${bb_slot_2}
    ...             --bb_slot_3=${bb_slot_3} --bb_slot_5=${bb_slot_5} --bb_slot_6=${bb_slot_6} --bb_slot_7=${bb_slot_7}
    ...             --l2_l1_bip=${l2_l1_bip} --syscom_mirroring=${syscom_mirroring}
    ...             --carrier_aggregation=${carrier_aggregation} --backhaul_mirroring=${backhaul_mirroring}
    ...             --filtering=${filtering} --use_gulp=${use_gulp}
    ...             --capturing_time_seconds=${capturing_time_seconds} --number_of_files=${number_of_files}
    ...             --file_size_mbytes=${file_size_mbytes} --xtrace=${xtrace} &>/dev/null &
     #...             --file_size_mbytes=${file_size_mbytes} --xtrace=${xtrace}


    csn.send_command    command=${cmd_local}    connection=${connection}
    Sleep    ${sleep_time}
    Wait Until Keyword Succeeds	  3x	2s   Trace capturing process should be triggered    log_prefix=${bip_prefix}
    ...    connection_alias=${connection}


Stop BIP capture on ASIL if needed and download BIP Logs to testPC
    [Documentation]
    [Arguments]     ${interface}=pepbp1    ${connection}=ASIK Master
    ...             ${log_path}=${bip_remote_log_path}    ${download_type}=Download
    #...             ${log_name}=${bip_remote_log_name}     ${bip_prefix}=tcpdump_L2L1
    #${multiRAT}    Check if multiRAT BTS
    #run keyword if    ${multiRAT}    Connect To MultiRAT GNB Common Unit Master
    #${connection}    set variable if    ${multiRAT}    MultiRAT GNB Master    ${connection}
    #${common_unit_type}    Get hardware type    alias=${connection}
    #${capture_interface}    set variable if    '${common_unit_type}'=='ASIB'    eths2    ${interface}
    #Stop BIP Capture On ASIK    interface=${capture_interface}    connection=${connection}
        #csn.execute
    #...    command=kill -2 `ps -ef | grep tcpdump | grep -v grep | awk '{print $2}'`
    #...    connection=${connection}

    csn.Execute        ps -ef | grep tcpdump | grep -v grep | grep ${interface} | awk '{print $2}' | xargs kill -9
    ...                connection=${connection}

     #Wait Until Keyword Succeeds	 10x	3s   check bip file exists   connection=${connection}


    sleep  5s


     ${cmd}=    set variable    ls -ltr /tmp/tcpdump*|tail -1|awk -F'/' '{print $(NF)}'
    csn.Send Command    command=${cmd}    connection=${connection}

    ${bip_remote_log_name}=   csn.Read Output    connection=${connection}
    ${bip_remote_log_name}=   strip_string    ${bip_remote_log_name}

    set suite variable    ${bip_remote_log_name}

    Download bip Logs to testPC    log_path=${log_path}    log_name=${bip_remote_log_name}   connection=${connection}

check bip file exists

   [Arguments]    ${connection}=none

    ${status}=    csn.file_exists    remote_path=${bip_remote_log_path}/${bip_remote_log_name}    connection=${connection}

     should be true   ${status}==True
    #${oam}=  Create Dictionary
    #...  host=192.168.255.129
    #...  user=toor4nsn
    #...  password=oZPS0POrRieRtu
    #tcpdump.create_tcpdump_collector
    #...     name=tcpdump
    #...     options=-i any
    #...     executor=${oam}
    #&{executor_ASIL_vm}=  Create Dictionary
    #...  host=192.168.255.129
    #...  user=toor4nsn
    #...  password=oZPS0POrRieRtu
    #l1l2bip.create_l1l2bip_collector
    #...     name=l1l2bip
    #...     collector=tcpdump
    #...     executor=${executor_ASIL_vm}
   # ...     mirroring_mode=manual
    #...     gnb_mirroring_path=/home/ute/Projects/robotws5g/testsuite/RRM/Hangzhou/CB007200_ET/gnbMirroring.sh
    #...     gnb_mirroring_config_path=/home/ute/Projects/robotws5g/testsuite/RRM/Hangzhou/CB007200_ET/gnbMirroringConfig.sh
    #...     enable_syscom_mirroring=true
    #...     mirror_capacity_units=[1]
    #...     carrier_aggregation=false

    #core.setup_collectors    names=l1l2bip
    #core.start_collectors    names=l1l2bip
    #sleep    10s
    #core.stop_collectors    names=l1l2bip
     #core.collect_collectors    names=l1l2bip   target_dir=${bip_path}
    #core.teardown_collectors    names=l1l2bip
Download bip Logs to testPC
    [Documentation]
    ...                Description: Download log from remote
    [Arguments]       ${log_path}    ${log_name}    ${connection}
    csn.download_file    remote_path=${log_path}/${log_name}
    ...                  local_path=${local_path}/${log_name}
    ...                  connection=${connection}

Verify that message DlData_PdcchSendReq
    [Arguments]    ${pdml_path}
     log to console     \nINFO:Verify that message DlData_PdcchSendReq

     FOR   ${IE}   IN   @{DICTONARY_PDCCHSENDREQ_IE}
         ${values} =    get_list_of_values    ${pdml_path}    ${IE}
         ${expect_value}=    Get From Dictionary    ${DICTONARY_PDCCHSENDREQ_IE}    ${IE}
        should be true    '${values[0]}'=='${expect_value}'
     END

Verify message DlData_PdschSendReq for UE1_rnti0
    [Arguments]    ${pdml_path}
     log to console     \nINFO:Verify message DlData_PdschSendReq for UE1_rnti0

     FOR   ${IE}   IN   @{DICTONARY_PDSCHSENDREQ_IE_rnti0}
         ${values} =    get_list_of_values    ${pdml_path}    ${IE}
		 ${expect_value}=    Get From Dictionary    ${DICTONARY_PDSCHSENDREQ_IE_rnti0}    ${IE}
        should be true    '${values[0]}'=='${expect_value}'
     END

Verify message DlData_PdschSendReq for UE1_rnti1
    [Arguments]    ${pdml_path}
     log to console     \nINFO:Verify message DlData_PdschSendReq for UE1_rnti1

     FOR   ${IE}   IN   @{DICTONARY_PDSCHSENDREQ_IE_rnti2}
        ${values} =    get_list_of_values    ${pdml_path}    ${IE}
        ${expect_value}=    Get From Dictionary    ${DICTONARY_PDSCHSENDREQ_IE_rnti2}    ${IE}
		should be true    '${values[0]}'=='${expect_value}'
     END
