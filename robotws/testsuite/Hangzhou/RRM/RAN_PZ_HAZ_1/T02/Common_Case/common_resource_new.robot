*** Settings ***
Documentation
...    Author: mengli yang
...    Contact: mengli.yang@nokia-sbell.com
...    this file is common resource for VRF HAZ1 TC02.
...    Please do not modify the file without notification to author.

Library             taf.sw.scout       WITH NAME    scout

*** Variables ***
${TL11073_basic_wts}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone_AIC/APCFG/wts_TL11073_basic.cfg
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}

*** Keywords ***
Case Precondition For RRM With AP
    log to console    Case Precondition
    Common Test Setup For RRM
    Case Precondition For AP

Case Postcondition For RRM With AP
    log to console    Case Postcondition
    Common Test Teardown For RRM
    Case Postcondition For AP

Case Precondition For AP
    [Arguments]    ${tag}=SA_HO    ${product_type}=vdu    ${operation}=env_setup_sa
    log to console    Case Precondition
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=${operation}
    ...                   product_type=${product_type}
    ...                   traffic_info_dic=${None}
    ...                   tag=${tag}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s

Case Postcondition For AP
    log to console    Case Postcondition
    Airphone Operation    operation=aplog
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s

############################## parameter ##############################
Parameter Updated
    [Arguments]    ${para_list}   ${value_list_true}    ${mo_list_vdu}    ${product_type}=vdu
    ${out}                Parameter Operation    operation=parameter_update    product_type=${product_type}
    ...                                          para_list=${para_list}    value_list=${value_list_true}
    ...                                          mo_list=${mo_list_vdu}
    Log To Console        VCU paramter update result: ${out}

Full Commission
    [Arguments]    ${product_type}=vdu    ${scf_path}=/home/ute/scf.xml
    ${out}   Parameter Operation    operation=full_commission   product_type=${product_type}
    ...                             scf_path=${scf_path}
    Log To Console    full commission result: ${out}

############################## counter ##############################
Start Counter
    [Arguments]    ${rule_list}    ${product_type}    ${bts_index}=${0}    ${interval}=5
    Log To Console    \n start counter \n
    Counter Operation    operation=start_collect_counter    product_type=${product_type}    bts_index=${bts_index}
    ...                                                     counter_rule=${rule_list}        interval=${interval}

Collect And Check Counter
    [Arguments]    ${product_type}    ${bts_index}=${0}    ${cudu_index}=0
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=${product_type}
    ...                               bts_index=${bts_index}   cudu_index=${cudu_index}
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}

###################################### log ######################################
Collect Wireshark Log
    [Arguments]    ${log_type}=wireshark    ${product_type}=vcu    ${bts_index}=${0}
    Log Collection    operation=start    log_type=${log_type}    product_type=${product_type}    bts_index=${bts_index}

Stop And Download Wireshark Log
    [Arguments]    ${log_type}=wireshark    ${product_type}=vcu    ${bts_index}=${0}
    ${local_file_path}    Log Collection    operation=stop_and_download    log_type=${log_type}
    ...                                     product_type=${product_type}    bts_index=${bts_index}
    Log To Console    \nwireshark log: ${local_file_path}
    [Return]    ${local_file_path}

Collect Sys Log In vDU
    ${local_file_path}    Log Collection    start    syslog    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Log To Console        \nSyslog log of VCU: ${local_file_path}

Collect snapshot log
    ${local_file_path}    Log Collection    start    snapshot    product_type=vcu    bts_index=${0}
    Log To Console    \nSnapshot log: ${local_file_path}

Start Emil log
    [Arguments]    ${product_type}=gnb    ${bts_index}=${0}
#    start_dcap_controller_common
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    emil    product_type=${product_type}    bts_index=${bts_index}
    ...                                dict_argument=${dict_argument}

Stop And Download Emil Log
     [Arguments]    ${product_type}=gnb    ${bts_index}=${0}
    ${local_file_path}    Log Collection    stop_and_download    emil    product_type=${product_type}
    ...                                                                  bts_index=${bts_index}
    Log To Console    \nTTI log: ${local_file_path}
    [Return]    ${local_file_path}

Test Decoded Emil Log To Csv File
    [Arguments]    ${local_file_path}
    ${local_file_path}    catenate   SEPARATOR=    ${local_file_path}
    Log To Console    \nemil log: ${local_file_path}
    ${filter}    create list    ZMQ/SCTP name=CpUePmiTicket
    ${result}=    Log Analysis   check   emil   ${local_file_path}   filter_emil=${filter}    convert_type=csv
    Log To Console    \nAnalyze log: ${result}0

#################################### PA ############################################
Modify PA
    [Arguments]    ${source_pa_port_list}    ${source_pa_value_list}    ${target_pa_port_list}    ${target_pa_value_list}
    ...            ${step}=${10}
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${step}
    &{target}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list}
    ...                               step=${step}
    PA Operation    source=&{source}    target=&{target}

Modify PA Only In Source
    [Arguments]    ${source_pa_port_list}    ${source_pa_value_list}    ${step}=${10}
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}
    ...                               pa_value=${source_pa_value_list}    step=${step}
    PA Operation    source=&{source}    target=none

Set Initialize PA Value
    [Arguments]    ${pa_port}=5-8;1,2;9;    ${pa_value}=0;127;127
    ${pa_port_list}    ${pa_value_list}    Split And Expand PA Parameters    pa_port=${pa_port}    pa_value=${pa_value}
    &{source}    Create Dictionary    att_index=${0}    pa_port=${pa_port_list}    pa_value=${pa_value_list}
    PA Operation    operation=Initialize PA Value    source=&{source}

#################################### BTS ############################################
BTS Operation With Module
    [Arguments]    ${operation}=cell_lock    ${product_type}=vdu    ${bts_index}=${0}    ${distname_id}=NRCELL-1
    BTS Operation    operation=${operation}    product_type=${product_type}    bts_index=${bts_index}
    ...              distname_id=${distname_id}    need_verify=yes


#################################### AP ############################################
AP Traffic
    [Arguments]    ${operation}    ${traffic_info_dic}
    ${Tput_dict}    Airphone Operation    operation=${operation}
    ...                                   product_type=${None}
    ...                                   traffic_info_dic=${traffic_info_dic}
    ...                                   tag=${None}
    ...                                   cmd=${None}
    ...                                   pass_regexp=${None}
    ...                                   timeout=600s

Send AP Command
    [Arguments]    ${cmd}    ${pass_regexp}=${None}    ${timeout}=100s
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd}
    ...                   pass_regexp=${pass_regexp}
    ...                   timeout=${timeout}

Config Iphy Ip For Local Env_250
    ${ap_version}    Get AP Build Name From UTE Cloud
    Log To Console  \n===upgrade AP ===
    ${cmd}  Catenate  python /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/library/airphone_worker/sw_update_local.py
    OperatingSystem.Run    ${cmd} -a ${ap_version}
    Log To Console  \n===configure eth0 ===
    OperatingSystem.Run    sudo ip addr add 10.97.65.238/32 dev eth0
    OperatingSystem.Run    sudo ip addr add 10.97.65.239/32 dev eth0
    OperatingSystem.Run    sudo ip addr add 10.97.65.240/32 dev eth0
    Log To Console  \n===configure eth3 ===
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/32 dev eth3
    Log To Console  \n===Open SCTP port on VM to allow SCTP traffic between WTS and gNB ===
    OperatingSystem.Run    sudo iptables -I INPUT -i eth0 -p sctp -m sctp --dport 38412 -j ACCEPT
    OperatingSystem.Run    sudo iptables -I INPUT -i eth0 -p sctp -m sctp --dport 38422 -j ACCEPT
    OperatingSystem.Run    sudo iptables -I INPUT -i eth0 -p sctp -m sctp --dport 36422 -j ACCEPT
    Log To Console  \n===Save changes ===
    OperatingSystem.Run    sudo sh -c 'iptables-save > /etc/iptables/rules.v4'
    Log To Console  \n===Copy TL11073 basic wts cfg file to /opw/wts/latest/ ===
    OperatingSystem.Run    cp ${TL11073_basic_wts} /opt/wts/latest/basic_setup.cfg
    Case Precondition For AP    tag=TL11073_basic    product_type=vdu    operation=env_setup_sa
    Log To Console  \n===configure done ===

Config network For Local Env_250
    Log To Console  \n===configure eth0 ===
    OperatingSystem.Run    sudo ip addr add 10.97.65.238/32 dev eth0
    OperatingSystem.Run    sudo ip addr add 10.97.65.239/32 dev eth0
    OperatingSystem.Run    sudo ip addr add 10.97.65.240/32 dev eth0
    Log To Console  \n===configure eth3 ===
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/32 dev eth3
    Log To Console  \n===Open SCTP port on VM to allow SCTP traffic between WTS and gNB ===
    OperatingSystem.Run    sudo iptables -I INPUT -i eth0 -p sctp -m sctp --dport 38412 -j ACCEPT
    OperatingSystem.Run    sudo iptables -I INPUT -i eth0 -p sctp -m sctp --dport 38422 -j ACCEPT
    OperatingSystem.Run    sudo iptables -I INPUT -i eth0 -p sctp -m sctp --dport 36422 -j ACCEPT
    Log To Console  \n===Save changes ===
    OperatingSystem.Run    sudo sh -c 'iptables-save > /etc/iptables/rules.v4'
    Log To Console  \n===configure done ===

Config Iphy Ip For Local Env_248
    [Arguments]    ${ap_version}=4.0.31553
    Log To Console  \n===upgrade AP ===
    ${cmd}  Catenate  python /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/library/airphone_worker/sw_update_local.py
    OperatingSystem.Run    ${cmd} -a ${ap_version}
    Log To Console  \n===configure eth0 ===
    OperatingSystem.Run    sudo ip addr add 10.97.65.235/32 dev eth0
    OperatingSystem.Run    sudo ip addr add 10.97.65.236/32 dev eth0
    OperatingSystem.Run    sudo ip addr add 10.97.65.237/32 dev eth0
    Log To Console  \n===configure eth3 ===
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/32 dev eth3
    Log To Console  \n===Open SCTP port on VM to allow SCTP traffic between WTS and gNB ===
    OperatingSystem.Run    sudo iptables -I INPUT -i eth0 -p sctp -m sctp --dport 38412 -j ACCEPT
    OperatingSystem.Run    sudo iptables -I INPUT -i eth0 -p sctp -m sctp --dport 38422 -j ACCEPT
    OperatingSystem.Run    sudo iptables -I INPUT -i eth0 -p sctp -m sctp --dport 36422 -j ACCEPT
    Log To Console  \n===Save changes ===
    OperatingSystem.Run    sudo sh -c 'iptables-save > /etc/iptables/rules.v4'

Get AP Latest Build Version
    [Arguments]    ${branch}    ${release_prefix}=airphone_
    ...            ${promotion_tags}=RAN_MRAT_CRT
    ${package_states}    Create List    RELEASED
    ${latest_build_name}    wft.get_name_of_latest_build    branch=${branch}
    ...                          release_prefix=${release_prefix}
    ...                          package_states=${package_states}
    ...                          promotion_tags=${promotion_tags}
    Log To Console    ${latest_build_name}

############################## call ##############################
Prepare And Attach UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=MATE40PROUI1.0
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_${ue_index}_type}

Start traffic For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}    ${direction}=dl
    ...            ${capabilities}=huawei1    ${call_number}=004488
    Run Keyword If    '${direction}' == 'dl'    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}
    ...                                                          direction=dl
    ...                                                          dt_index=${ue_index}
    ...              throughput=110M    duration=${600}
    ...       ELSE IF     '${direction}' == 'ul'    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}
        ...                                                          direction=ul
    ...                                                              dt_index=${ue_index}
    ...              throughput=110M    duration=${600}
    ...       ELSE IF     '${direction}' == 'all'    Start DL and UL Call For UE    ue_index=${ue_index}
        ...                                                                         ue_type=${ue_type}
    ...              throughput=110M    duration=${600}
    ...       ELSE IF     '${direction}' == 'vonr'    Start VONR Call For UE    ue_index=${ue_index}
    ...                                                                         capabilities=${capabilities}
    ...                                                                         call_number=${call_number}

Start Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}    ${direction}=dl
    ...            ${RemoteHost}=10.69.53.149
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}    dt_index=${ue_index}
	...              throughput=110M    duration=${600}    RemoteHost=${RemoteHost}

Start DL and UL Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    dt_index=${ue_index}
	...              throughput=110M    duration=${600}
	Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    dt_index=${ue_index}
	...              throughput=110M    duration=${600}

Start VONR Call For UE
    [Arguments]    ${ue_index}=${0}    ${capabilities}=huawei1    ${call_number}=004488
    Start VONR Call    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    vc_alias=VC_1
    ...                call_number=${call_number}    duration=600s    capabilities=${capabilities}

Reboot UE
    [Arguments]    ${ue_index}=${0}
    ADB Reboot UE    ue_index=${ue_index}
    sleep    300s    reason=wait reboot UE suceesfully

Detach UE
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_${ue_index}_type}
    UE Detach    ${ue_type}    ue_index=${ue_index}
    sleep    60s    reason=wait detach UE Successfully

Prepare And Attach UE For Qualcomm
    [Arguments]    ${ue_index}=${0}    ${capabilities}=REAL_QUALCOMM_UE
    set test variable    ${ue_type}    qualcomm
    Log to Console    \n***Prepare UE***
    ute_ue.Require Ue    ue_alias=UE_${ue_index}    capabilities=${capabilities}
    Detach UE    ue_index=${ue_index}    ue_type=qualcomm
    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_type}

Start Emergency Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}
    Start VONR Call    ue_type=${ue_type}    ue_index=${ue_index}    vc_alias=VC_1    call_number=911
    ...            duration=600s    capabilities=huawei1

Stop Call For UE
    [Arguments]    ${ue_index}=${0}
    Log to Console    \n***Prepare to Stop a Call..***
    Stop traffic    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    direction=dl
    sleep    5s    reason=wait call stoped
    Log to Console    \n***Call stoped..***

Stop VONR Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}
    Stop VONR Call    ue_type=${ue_type}    vc_alias=VC_1

Start VONR Call Without Require Ue
    [Arguments]    ${ue_index}=${0}
    Start Voice Call    vc_alias=VC_1   ue_alias=UE_${ue_index}    to=004488    duration=600s

############################## spark ##############################
Connect All UEs For Spark
    [Arguments]     ${ue_alias}=UE_connection
    Log    connect UEs for spark   console=True
    SigSpark.Require Platform    ue_alias=${ue_alias}
    SigSpark.disconnect_ues    ue_alias=${ue_alias}
    SigSpark.delete_ues    ue_alias=${ue_alias}
    SigSpark.connect_ues    ue_alias=${ue_alias}

Attach Single UE For Spark
    [Arguments]    ${ue_index}=${0}
    Attach UE For Spark   ue_index=${ue_index}

Attach UE For Spark
   [Arguments]    ${ue_index}=${0}
   Log    Start power on and Prepare UE   console=True
   spark.Prepare UE    ue_alias=UE_${ue_index}    ue_index=${ue_index}
   spark.start one log    ue_alias=UE_${ue_index}
   spark.UE power off    ue_alias=UE_${ue_index}
   spark.UE power on    ue_alias=UE_${ue_index}

Detach UE For Spark
    [Arguments]    ${ue_index}=${0}
    spark.UE Detach    ue_alias=UE_${ue_index}

Disconnect All UEs For Spark
    [Arguments]    ${ue_alias}=UE_connection
    SigSpark.disconnect_ues    ue_alias=${ue_alias}


Start Traffic For Spark
    [Arguments]     ${ue_index}=${0}    ${direction}=dl    ${duration}=360    ${throughput}=10Mbits/sec    ${protocal}=UDP
    Log    Start dl traffic for all UEs   console=True
    spark.Start traffic    direction=${direction}    duration=${duration}    throughput=${throughput}    ue_alias=UE_${ue_index}
    ...                    dt_name=download   iperf_port=8018   EQIndex=${-1}    protocal=${protocal}
    Sleep    10
    ${tput}    spark.Check throughput    ue_alias=UE_${ue_index}   ue_index=${ue_index}    direction=${direction}
    ...                                  expected_throughput=1
    sleep   5


Start DL Traffic For Spark
    [Arguments]     ${ue_index}=${0}    ${duration}=360    ${protocal}=UDP
    Log    Start dl traffic for all UEs   console=True
    spark.Start traffic    direction=dl    duration=${duration}    throughput=10Mbits/sec    ue_alias=UE_${ue_index}
    ...                    dt_name=download   iperf_port=8018   EQIndex=${-1}    protocal=${protocal}
    Sleep    10
    ${tput}    spark.Check throughput    ue_alias=UE_${ue_index}   ue_index=${ue_index}    direction=dl
    ...                                  expected_throughput=1
    sleep   5

Stop Traffic For Spark
    [Arguments]     ${direction}=dl   ${ue_index}=${0}
    spark.Stop traffic   direction=${direction}    ue_alias=UE_${ue_index}    ue_index=${ue_index}     EQIndex=${-1}

Start UL Traffic For Spark
    [Arguments]     ${ue_index}=${0}    ${duration}=18000    ${protocal}=UDP
    Log    Start ul traffic for all UEs   console=True
    spark.Start traffic    direction=ul    duration=${duration}    throughput=10Mbits/sec    ue_index=${ue_index}
    ...   ue_alias=UE_${ue_index}    dt_name=download    protocal=${protocal}
    Sleep    10
    ${tput}    spark.Check throughput    ue_alias=UE_${ue_index}   ue_index=${ue_index}    direction=ul
    ...                                  expected_throughput=1
    sleep   5

Stop UL Traffic For Spark
    [Arguments]     ${ue_index}=${0}
    spark.Stop traffic   direction=ul    ue_alias=UE_${ue_index}    ue_index=${ue_index}

Start Log For Spark
    [Arguments]    ${ue_index}=${0}
    Log    Start log for all UEs   console=True
#    spark.Start log    ue_alias=UE_${ue_index}
    spark.start one log    ue_alias=UE_${ue_index}

Stop Log For Spark
    [Arguments]    ${ue_index}=${0}
    Log    Start log for all UEs   console=True
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    spark.stop one log    ue_alias=UE_${ue_index}    logname=UE_LOG_${timestamp}.xml

Start VONR For Spark
    [Arguments]    ${ue_index}=${0}    ${timeout}=60    ${index}=None    ${command}=ATD006688
    spark.Start VONR Call    ue_alias=UE_${ue_index}     index=${index}    timeout=${timeout}   command=${command}
#    ${event_result}=    SigSpark.check_event_sucessful    ue_alias=UE_${ue_index}    event_index=${0}
#    ${event_List}    set variable    ${event_result['EventList']}


Stop VONR For Spark
    [Arguments]    ${ue_index}=${0}     ${index}=None    ${timeout}=${30}    ${command}=ATH
    spark.Stop VONR Call    ue_alias=UE_${ue_index}     index=${index}    timeout=${timeout}    command=${command}

############################## dingli ##############################

Prepare UE For Dingli
    [Arguments]     ${ue_index}=${0}
    Log    connect UEs for pioneer   console=True
    @{UEs_info}=    AIC_UE.pioneer.Detect UE and get UEs info
    ${ue_alias}   set variable    UE_${ue_index}
    AIC_UE.pioneer.Prepare UE     imei=${UEs_info[${ue_index}]}[imei]    ue_alias=${ue_alias}

Attach single UE For Dingli
    [Arguments]    ${ue_index}=${0}
    ${ue_alias}   set variable    UE_${ue_index}
    AIC_UE.pioneer.UE Attach    ue_alias=${ue_alias}

Detach single UE For Dingli
    [Arguments]    ${ue_index}=${0}
    ${ue_alias}   set variable    UE_${ue_index}
    AIC_UE.pioneer.UE Detach    ue_alias=${ue_alias}

Start DL Traffic For Dingli
    [Arguments]    ${ue_index}=${0}
    Log    start dl traffic for ue  console=True
    ${ue_alias}   set variable    UE_${ue_index}
    AIC_UE.pioneer.Start DL Traffic    dl_time=360   dl_port=8018   dl_throughput=80M   dl_length=1024B   hostname=${PC_HOST}
    sleep  30s
    AIC_UE.pioneer.Check Throughput    direction=dl   expected_throughput=10   ue_alias=${ue_alias}

Start UL Traffic For Dingli
    [Arguments]    ${ue_index}=${0}
    Log    start ul traffic for ue  console=True
    ${ue_alias}   set variable    UE_${ue_index}
    pioneer.Start UL Traffic    address=10.101.2.23    buffersize=20    port=5013    ue_alias=${ue_alias}
    sleep  30s
#    AIC_UE.pioneer.Check Throughput    direction=ul   expected_throughput=0.0   ue_alias=${ue_alias}

Stop UL Traffic For Dingli
    [Arguments]    ${ue_index}=${0}
    ${ue_alias}   set variable    UE_${ue_index}
    AIC_UE.pioneer.Stop UL Traffic   ue_alias=${ue_alias}


Stop DL Traffic For Dingli
    [Arguments]    ${ue_index}=${0}
    ${ue_alias}   set variable    UE_${ue_index}
    AIC_UE.pioneer.Stop DL Traffic   ue_alias=${ue_alias}
    Detach single UE For Dingli   ue_index=${ue_index}

Start Log For Dingli
    [Arguments]    ${logpath}=C:/pioneer_logs/    ${logname}=ta_log    ${service}=pioneer
    client.startlog    logpath=${logpath}    logname=${logname}    service=${service}

Stop Log For Dingli
    [Arguments]    ${folder_path}=C:/pioneer_logs/    ${service}=pioneer
    client.stoplog    service=${service}
    client.remove_remote_files    folder_path=${folder_path}   service=${service}

AT Module Test
    AT Operation    operation=detach
    AT Operation    operation=reboot
    AT Operation    operation=attach
    AT Operation    operation=attach
    # AT Operation    operation=reboot
    AT Operation    operation=start_traffic    IperfOptions=-u -i 1 -t 300 -b 10M -p 50001
    ...    direction=ul
    AT Operation    operation=start_traffic    IperfOptions=-u -i 1 -t 300 -b 10M -p 50001
    ...    direction=dl
    AT Operation    operation=stop_traffic    direction=ul
    AT Operation    operation=stop_traffic    direction=dl
    AT Operation    operation=start_traffic    IperfOptions=-i 1 -t 300 -b 10M -p 50001
    ...    direction=ul    remote_hostname=10.108.233.142
    ...    remote_username=spark
    ...    remote_password=spark123
    ...    protocol_type=tcp
    AT Operation    operation=stop_traffic    direction=ul    protocol_type=tcp
    ...    remote_hostname=10.108.233.142
    ...    remote_username=spark
    ...    remote_password=spark123
    AT Operation    get    item=ueip
    AT Operation    set    item=apn    before_intf_name=ststatic
    ...    after_intf_name=ststatic
    AT Operation    get    item=ueip
    AT Operation    set    item=apn    before_intf_name=ststatic
    ...    after_intf_name=ststatic
    AT Operation    get    item=ueip    intf_name=ims
    AT Operation    operation=start_call    number=6688
    AT Operation    operation=stop_call

HAZ TC02 Get SCF Internal Id By Scout
    [Timeout]    3 minutes
    [Arguments]    ${no_ute}=${True}    ${flag}=Single
    ${bts_id}     Run Keyword If     '${flag}'=='Single'    HAZ TC02 Get Testline Name
    ...    ELSE IF    '${flag}'=='Multiple'    OperatingSystem.Run    echo `hostname` | sed 's/-/_/g'
    scout.setup_scout    ${bts_id}
    ${status}    scout.get_scout_testline_status
    ${scf_id}    scout.request_scf    use_scout_internal_id=${no_ute}
    Log to Console   scf id is: ${scf_id}
    [Return]    ${scf_id}
    [Teardown]    scout.teardown_scout_api

HAZ TC02 Get Testline Name
    ${key_list}    Create List    CM_RESOURCES    0    properties    name
    ${TestLine_Name}    HAZ TC02 Get Info From UTE Reservation File    key_list=${key_list}
    Log to Console    \n***TestLine Name ${testline_name}***
    ${TestLine_Name_List}    Split String    ${TestLine_Name}    .
    Set Suite Variable    ${TESTLINE_NAME}    ${TestLine_Name_List[-1]}
    [Return]    ${TESTLINE_NAME}

HAZ TC02 Get Info From UTE Reservation File
    [Arguments]    ${key_list}    ${file_path}=${UTE_RESERVATION_CONTEXT_JSON}
    [Documentation]    This kw is used to get Info From UTE Reservation File
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ${key_list} | Yes | The keys list need to get from ute reservation file |
    ...    | ${file_path} | No | The UTE reservation file. Default is ${UTE_RESERVATION_CONTEXT_JSON} |
    ...
    ...    | Return Value | Description |
    ...    | ${dict} | The needed info for the keys in key list |
    ...
    ...    Example
    ...    |  ${key_list}            |  Create List                         |  CM_ARTIFACTS          |  0  |  name  |
    ...    |  ${Expect_Sw_Version}=  |  Get Info From UTE Reservation File  |  key_list=${key_list}  |     |        |
    ...
    ${context}    OperatingSystem.Get File    ${file_path}
    &{context_dict}    json.Loads    ${context}
    ${dict}    Set Variable    ${context_dict}
    FOR    ${k}    IN    @{key_list}
        ${k_convert}    Run Keyword If    ${k.isdigit()}
        ...    Convert To Integer    ${k}
        ...    ELSE    Set Variable    ${k}
        ${dict}    Run Keyword If    ${k.isdigit()}
        ...    Set Variable    ${dict}[${k_convert}]
        ...    ELSE    Collections.Get From Dictionary    ${dict}    ${k_convert}
    END
    [Return]    ${dict}

Trigger BTC failure
    [Arguments]    ${instance_abbr}=TCM
    [Documentation]    this kw is used to Trigger BTC failure
    ...    | Input Parameters | Man. | Description |
    ...	   | instance_abbr | yes | TCM or TCC |
    ${ns}    Get vCU Namespace From Config File

    ${conn}    tafssh.connect_to    hostname=${VCU_HOSTNAME}
    ...                             username=${VCU_USERNAME}
    ...                             password=${VCU_PASSWORD}
    ...                             alias=vcu_master
    ${pod_name}=    Run Keyword If    '${instance_abbr}' == 'TCC'
        ...    Get Active Pod Name For Redundant layout of CNF    pod_abbr=oamext    connection=${conn}
    ...    ELSE IF    '${instance_abbr}' == 'TCM'
        ...    Get Pod Name    ${ns}    pod_abbr=tracecontroller    connection=${conn}
    Log To Console    \nPod_name is ${pod_name}

    ${container_name}=    Run Keyword If    '${instance_abbr}' == 'TCC'
        ...    k8s.get_container_name    namespace=${ns}    pod_name=${pod_name}    container_type=tracecontrollerconfigurator    conn=${conn}
    ...    ELSE IF    '${instance_abbr}' == 'TCM'
        ...    k8s.get_container_name    namespace=${ns}    pod_name=${pod_name}    container_type=tracecontrollermaster    conn=${conn}
    Log To Console    \nContainer_name is ${container_name}

    Log To Console    Trigger BTC failure
    Run Keyword If    '${instance_abbr}'=='TCM'   Trigger TCM instance failure    ${pod_name}    ${container_name}    ${conn}
    ...    ELSE IF    '${instance_abbr}'=='TCC'    Trigger TCC instance failure    ${pod_name}    ${container_name}    ${conn}
    ...    ELSE    Log To Console    Invalid instance abbreviation
    [Teardown]    Run Keyword And Ignore Error    tafssh.disconnect    connection=${conn}

Get Active Pod Name For Redundant layout of CNF
    [Arguments]    ${pod_abbr}=oamext    ${connection}=${None}
#    oc get pods --selector='healing-controller.rcpha/service-selector' | grep oamext | awk '{print $1}'
    ${get_active_pod}=    Catenate    oc get pods --selector='healing-controller.rcpha/service-selector' |
    ...                               grep ${pod_abbr} | awk '{print \$1}'
    ${active_pod}    tafssh.execute    command=${get_active_pod}    connection=${connection}
    ${active_pod_list}=    split_string    ${active_pod}    \r\n
    ${active_pod_name}    set variable    ${active_pod_list}[0]
    [Return]    ${active_pod_name}

Get Pod Name
    [Arguments]    ${ns}    ${pod_abbr}=oamext    ${connection}=${None}
    ${get_pod}=    Catenate    oc get pods -n ${ns} |egrep "(-${pod_abbr})" --color=never|awk '{print $1}'
    ${out}    tafssh.execute    command=${get_pod}    connection=${connection}
    ${pod_list}=    split_string    ${out}    \r\n
    ${pod_name}    set variable    ${pod_list}[0]
    [Return]    ${pod_name}

Trigger TCM instance failure
    [Arguments]    ${pod_name}    ${container_name}    ${connection}=${None}
    Log To Console    Trigger TCM instance failure
    ${extract_TCM_PIDs}=    Catenate    kubectl exec -it ${pod_name} -c ${container_name} -- bash -c
    ...                                "ps aux | grep TC-Master-NR | grep 'S<l' | awk '{print \\$2}' | head -n 4"
    ${process_ids}    tafssh.execute    command=${extract_TCM_PIDs}    connection=${connection}
    ${process_ids}=    Strip String    ${process_ids}
    ${process_ids_list} =    split_string    ${process_ids}    \r\n
    Log To Console    All Process ID of TC-Master-NR are: ${process_ids_list}

    ${count_flag}    Set Variable    0
    FOR    ${process_id}    IN    @{process_ids_list}
        ${count_flag}    Evaluate    ${count_flag}+1
        Log To Console    The value of count_flag is: ${count_flag}
#        exit for loop if    '${count_flag}'=='3'
        Log To Console    Kill TC-Master-NR Process with PID: ${process_id}
        ${kill_TCM_PID}=    Catenate    kubectl exec -it ${pod_name} -c ${container_name} -- bash -c
        ...                             "kill -9 ${process_id}"
        ${output}    tafssh.execute    command=${kill_TCM_PID}    connection=${connection}
        sleep    300s    reason=wait TC-Master-NR Process restart
    END

    Log To Console    Trigger TCM instance failure Done

Trigger TCC instance failure
    [Arguments]    ${pod_name}    ${container_name}    ${connection}=${None}
    Log To Console    Trigger TCC instance failure
    ${extract_TCC_PIDs}=    Catenate    kubectl exec -it ${pod_name} -c ${container_name} -- bash -c
    ...                                "ps aux | grep TC-Configurator | grep 'Sl' | awk '{print \\$2}'"
    ${process_ids}    tafssh.execute    command=${extract_TCC_PIDs}    connection=${connection}
    ${process_ids}=    Strip String    ${process_ids}
    ${process_ids_list} =    split_string    ${process_ids}    \r\n
#    need to check if the process id is empty
    Log To Console    Process ID of TC-Configurator is: ${process_ids_list}\n

    Log To Console    Kill TC-Configurator Process
    ${kill_TCC_PID}=    Catenate    kubectl exec -it ${pod_name} -c ${container_name} -- bash -c
    ...                                "kill -9 ${process_ids_list[0]}"
    ${output}    tafssh.execute    command=${kill_TCC_PID}    connection=${connection}
    sleep    180s    reason=wait TC-Configurator Process restart

    Log To Console    Trigger TCC instance failure Done

Get Pod Restarts
    [Arguments]    ${ns}    ${pod_name}    ${connection}=${None}
    ${cmd}=    Catenate    kubectl get pods -n ${ns}|egrep ${pod_name} |awk '{print \$4}'
    ${out}    tafssh.execute    command=${cmd}    connection=${connection}
    ${restarts}=    Strip String    ${out}
    [Return]    ${restarts}

Get TCP Connection Status
    [Arguments]    ${ns}    ${pod_name}    ${dcap_server}    ${connection}=${None}
    ${cmd}=    Catenate    kubectl exec -it ${pod_name} -n ${ns} -- bash -c
    ...                                "netstat -tan | grep ${dcap_server} | awk '{print \\$6}'"
    ${out}    tafssh.execute    command=${cmd}    connection=${connection}
    ${status}=    Strip String    ${out}
    [Return]    ${status}

Start Scout Cli
    OperatingSystem.Run     source /home/ute/.pyenv/versions/3.10.12/envs/agent_scout_env/bin/activate
    ${cmd}    catenate
    ...    pip install -U --trusted-host
    ...    artifactory-espoo1.int.net.nokia.com -i
    ...    https://artifactory-espoo1.int.net.nokia.com/artifactory/api/pypi/pypi-scout-local/simple
    ...    scout-cli
    OperatingSystem.Run    ${cmd}
    ${cmd}    catenate    scout-cli testline start --testline-ip 192.168.255.129 --config
    ...    /home/ute/testline_init_results/agent_scout/results/config_files/scout.conf
    OperatingSystem.Run    ${cmd}