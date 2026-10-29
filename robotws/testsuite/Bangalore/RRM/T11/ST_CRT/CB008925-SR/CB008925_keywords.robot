*** Settings ***
Documentation
...   author: Sruthi Jacob
...   contact: VRF_T11
...   Description: keywords for CB008925

Library    BuiltIn
Library    Collections
Library    String
Library    OperatingSystem
Library    SSHLibrary
Library    SeleniumLibrary
Library    DateTime
Library    taf.sw.scout    WITH NAME    scout
Library    taf.sbts.oam.coam.admin    WITH NAME    CoamAdmin
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.tcpdump   WITH NAME   tcpdump
Library    taf.fdsw.rc     WITH NAME    rc
Library    taf.sw.dcap.rd   WITH NAME   rd
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.ue  WITH NAME  ue
Library    testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller
Library    Process
Library    ../../../../resources/python/Traffic_handler.py
Variables   ta5g_global_var
Resource    ../CB013233/expected_alarms.robot

Resource    ../../../../resources/NPS/SWENG/robot/PacketSearch_mcshark.robot
#Resource    /home/ute/MN/UTE/robotws/testsuite/Bangalore/RRM/T02/resources/robot/UE_keywords.resource

*** Variables ***
#${voice_call_TC}=    VONR_Server_Call
@{data_transfer_protocol}=    UDP
${j}    0
${i}    0
${E}    0
${DCAP_host}                10.58.239.215                                               			# DCAP server IP 10.58.238.126
${port}                     443                                                         			# Port value for DCAP connection
${secure}                   True                                                        			# Secure value for DCAP connection
${rd_version}               dcapv3                                                      			# DCAP version
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs
${emil_path}                C://Emil                                                    			# Emil path in UE PC machine
${emil_profile_path}        ${emil_path}//profiles//5G                                  			# Emil profile path in UE PC machine
${Default_DCAP_duration}    12                                                           			# DCAP log duration
${dcap_log_timeout}         1200                                                        			# Timeout for DCAP log collection
&{BTS_INFO}                 host=${mplane_ip}	port=443                        			# BTS details
@{gnb_custom_filters}       cp_5g    condor5gSyslog         			# gnb custom filters for DCAP
@{bts_custom_filter}        condor5gSyslog                #immediateSnapshot    scf    ipCapture         			# BTS custom filters for DCAP
@{collection_timing}        Immediate       TraceEnd                                    			# Snapshot collet option for DCAP
@{counter_values}
${dcapusr}    utfuser
${dcappwd}    utfadmin!
${MCG_IP}     10.53.164.142
${MCG_usn}    ute
${MCG_pwd}    BT5l@bus3rl0g1n
${VM_IP}     10.53.164.31
${mplane_ip}  10.53.203.243
${ABSTRACT_LIB_CONFIG}=    /home/ute/testline_configuration/1_2_CLOUD465/__init__.py
${SCF_PATH}               /home/ute/MN/robotws/testsuite/Bangalore/RRM/T11/ST_CRT/CB008925-SR/config/CB008925-SR_Trunk.xml
*** Keywords ***

Prepare Test UE
     [Arguments]  ${ue_alias}=Quectel_UE    ${capabilities}=Quectel_UE
    ue.Require Ue    ${ue_alias}     ${capabilities}
    # supported: ALL, imsi, imei, device_model, commercial_name, ip, ips, ips_uepc, manufacturer, model,
    # revision, gcap, signal_strength, cell_id, cell_info
    Log Ue Info    Quectel_UE    ALL



Start GNB TcpdumpLogs
    [Documentation]    this keyword is used to capture wiresharkog in wireshark PC
    log to console    \nStarting Wireshark Logs
    ${executor_oam_vm}=  Create Dictionary
    ...  host=${mplane_ip}
    ...  user=toor4nsn
    ...  password=oZPS0POrRieRtu
    tcpdump.create_tcpdump_collector
    ...    name=tcpdump
    ...    options=-n -X -tt -i any
    ...    executor=${executor_oam_vm}
    core.setup_collectors    names=tcpdump
    core.set_suite_alias   tcpdump
    core.start_collectors    names=tcpdump


Set Active Bands For Test Ue
    [Arguments]    ${bands}    ${ue_alias}=Quectel_UE    ${technology}=LTE
    ue.Set active bands    ${ue_alias}    ${technology}    ${bands}

Attach Test UE
    [Arguments]  ${ue_alias}=Quectel_UE

    ue.Attach Ue    ue_alias=${ue_alias}


Detach Test UE
  [Arguments]  ${ue_alias}=Quectel_UE
    ue.Detach Ue   ue_alias=${ue_alias}

Start Data Transfer UL Protocol UDP
    ue.Start Data Transfer    DT_1    Quectel_UE    UL    protocol=udp      throughput=10kbits/sec
    Sleep    60s
    Stop Data Transfer     DT_1

Start Data Transfer DL Protocol UDP
    ue.Start Data Transfer    DT_1    Quectel_UE    DL    protocol=udp      throughput=10kbits/sec
    Sleep    60s
    Stop Data Transfer     DT_1

Setup Test
    Log To Console    connecting to BTS
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    CoamAdmin.Setup_Admin    bts_host=192.168.255.129    alias=oam
    Log To Console    BTS is Connected
    ${opt}    set variable    ${OUTPUT_DIR}/Pre/
    set test variable    ${opt}
    create directory     ${opt}
#    ${scf_path}    Download SCF    ${opt}
#    set global variable    ${scf_path}
    log to console    Commissioning started
    CoamAdmin.Perform_Commissioning
    ...    465
    ...    ${SCF_PATH}
    ...    True
    ...    timeout=1200
    ...    connection=oam
    sleep    600
    log to console    Commissioning completed
    Check BTS is OnAir
    Log to console   \n--Starting Syslogs Logs--
    Run     killall btslog
    ${executor_test_vm}=  Create Dictionary
    ...  host=${VM_IP}
    ...  user=ute
    ...  password=BT5l@bus3rl0g1n
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   executor=${executor_test_vm}
    ...   log_dir=/tmp/btslog2
    core.setup_collectors      names=btslog
    core.set_suite_alias	btslog
    core.start_collectors      names=btslog
    Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ABSTRACT_LIB_CONFIG}



UDP_Traffic_DL_via_IPERF
    [Arguments]    ${ue_ip}    ${ftpserverip}    ${ftpusername}    ${ftppassword}
    ...    ${length}    ${intervel}    ${timeout}    ${sizeofdata}

    Traffic_handler.Udp Data Transfer    ue_ip=${ue_ip}
    ...    ftpserverip=${ftpserverip}
    ...    ftpusername=${ftpusername}
    ...    ftppassword=${ftppassword}
    ...    length=${length}
    ...    intervel=${intervel}
    ...    timeout=${timeout}
    ...    sizeofdata=${sizeofdata}


Start DL Data Traffic
    ${ue_ip}    ue.Get UE info    Quectel_UE    IP
    ${Traffic_status}=   UDP_Traffic_DL_via_IPERF    ue_ip=${ue_ip}
    ...                ftpserverip=10.58.241.84
    ...                ftpusername=ftpuser
    ...                ftppassword=ftpuser
    ...                length=1200
    ...                intervel=1
    ...                timeout=300
    ...                sizeofdata=20K



Start UL Data Traffic
    [Arguments]   ${alias}    ${dt_index}  ${ul_time}=120s   ${ul_throughput}=16KBytes/sec   ${ul_deviation}=10
    ...    ${packet_size}=${8}
    ue.Start Data Transfer   duration=${ul_time}   throughput=${ul_throughput}   dt_name=DT_${dt_index}
    ...   ue_alias=${alias}  protocol=udp   direction=ul    packet_size=${packet_size}
    Log To Console  ${ul_throughput} UDP Data is transfer is started
    Log To Console    Deviation applied ${ul_deviation}
