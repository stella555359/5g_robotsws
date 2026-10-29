*** Settings ***
Documentation    ...
#Resource    ./../../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Run Keywords
#...    Fisrt Time Sart DCAP server
#...    Suite Setup Update GNB
#Test Teardown    Run Keyword    Testcase Teardown
##Suite Teardown    Common Suite Teardown
#Force Tags         5G_RAN    SBTS00    SBTS23R1    SBTS22R4    SBTS22R2
#
#*** Variables ***
#${UE_ID}          1
#${GNB_ID}         2
#${CELL_ID}        2
#${BEARER_ID}      2
#${DST_FOR_FRM}    MRBTS-1/NRBTS-1/NRCELL-1
#${OK}      OK
#${DST_FOR_GROUP}    MRBTS-1/NRBTS-1/NRCELLGRP-0
#${PING_MATCH}     from\\s+[0-9,\.\:]+\\s+[a-z,\_\=]+\\d+\\s+[a-z,\=,0-9]+
#&{AP}                   hostname=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu
#&{GNB}                  hostname=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu
#${WEBUI_USER}           Nemuadmin
#${WEBUI_PWD}            nemuuser
#${SCFC_PATH}            ${CURDIR}/resources/scfc
#${WTS_DIR}              /opt/iphy/latest
#${WTS_CFG}              basic_fullstack_nsa_call_tdd_cmwv.cfg
#${WTS_AP_XML}           AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml
#${GNBCUTYPE}    NSA
#${SCF_PATH}    ${CURDIR}/config
#${RESOURCE_PATH}       ${CURDIR}/resources
#@{log_name_list}    #btslog    tcpdump
#*** Test Cases ***
#5GC001681-A001-ZMQ message can be traced from a CP component via DCAP clia in classical BTS
#    [Tags]    Classical    CRT_HNZ    5GC001681    FR1    IPV4    Owner_trshen    PRI-Medium    CN1    5G20A    5G00    5G20B
#    ...    CLOUD_5G_BL_AP_NSA_FS_CMWV_TDD    master_classicalbts_all    STATE_CONFIGURED    CRT    5G_RAN_TDD    QCD_MN_5G    QCP_5G
#    Kill egate and edaemon process
#    Reboot TL And Check Configured
#    Delete Old Logfile
#    DCAP Start Monitor Session     session_name=ZmqSession    filter_file=zmq_5gfilter.txt
#    Onair and UE attach
#    sleep    120S
#    DCAP Stop Monitor Session    ZmqSession
#    Check Log Exist
#
#5GC001681-A005-No message can be traced once no filter is set in DCAP clia in classical BTS
#    [Tags]    Classical    CRT_HNZ    5GC001681    FR1    IPV4    Owner_trshen    PRI-Medium    CN1    5G20A    5G00    5G20B
#    ...    CLOUD_5G_BL_AP_NSA_FS_CMWV_TDD    master_classicalbts_all    STATE_CONFIGURED    CRT    5G_RAN_TDD    QCD_MN_5G    QCP_5G
#    Kill egate and edaemon process
#    Reboot TL And Check Configured
#    Delete Old Logfile
#    DCAP Start Monitor Session    session_name=NulSession    filter_file=null_5gfilter.txt
#    Onair and UE attach
#    sleep    120S
#    DCAP Stop Monitor Session    NulSession
#    Check NoLog Exist
#
#5GC001681-C006-Verify capturing and streaming of SysCom messages exchanged inside CP-NRT CP-RT CP-NB CP-CELL Container in classical BTS
#    [Tags]    Classical    CRT_HNZ    5GC001681    FR1    IPV4    Owner_trshen    PRI-Medium    CN1    5G20A    5G00    5G20B
#    ...    CLOUD_5G_BL_AP_NSA_FS_CMWV_TDD    master_classicalbts_all    STATE_CONFIGURED    CRT    5G_RAN_TDD    QCD_MN_5G    QCP_5G
#    Kill egate and edaemon process
#    Reboot TL And Check Configured
#    Delete Old Logfile
#    DCAP Start Monitor Session Syscom    session_name=SyscomSession    filter_file=syscom_filter.txt
#    Onair and UE attach
#    sleep    120S
#    DCAP Stop Monitor Session    SyscomSession
#    Check Log Exist
#
#5GC001681-A004-Status of cplane tracing machine can be changed via NIDD parameter in WebEM in classical BTS
#    [Tags]    Classical    CRT_HNZ    5GC001681    FR1    IPV4    Owner_trshen    PRI-Medium    CN1    5G20A    5G00    5G20B
#    ...    CLOUD_5G_BL_AP_NSA_FS_CMWV_TDD    master_classicalbts_all    STATE_CONFIGURED    CRT    5G_RAN_TDD    QCD_MN_5G    QCP_5G
#    Kill egate and edaemon process
#    Online SCF Commission One Para    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1    actInternalTrace    false
#    Reboot TL And Check Configured
#    Delete Old Logfile
#    DCAP Start Monitor Session     session_name=ZmqSession    filter_file=zmq_5gfilter.txt
#    Onair and UE attach
#    sleep    120S
#    DCAP Stop Monitor Session    ZmqSession
#    Check NoLog Exist
#    Online SCF Commission One Para    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1    actInternalTrace    true
#
#*** Keywords ***
#Common Suite Setup
#    Suite Setup Update GNB
#    Suite Setup Copy WTS Config Files From QT
#    Suite Setup Start WTS And Check OnAir
#
#Easy Common Suite Setup
#    Create Suite Directory
#    Kill egate and edaemon process
#    Suite Setup Start WTS And Check OnAir
#
#Kill egate and edaemon process
#    OperatingSystem.run    sudo pkill edaemon
#    OperatingSystem.run    sudo pkill egate
#
#Fisrt Time Sart DCAP server
#    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    sudo docker ps -a
#    ${no_flowtracer_container_flag}=    Run Keyword And Return Status    Should Not Contain    ${output}    flowtracer
#    Run Keyword If    ${no_flowtracer_container_flag}==True    DCAP Start Docker Container
#
#DCAP Start Docker Container
#    OperatingSystem.Run And Return Rc And Output    sudo sshpass -p dcapuser123 scp -r dcapuser@10.57.205.43:/sharedvolume/ /
#    ${cmd}=    Catenate    sudo docker load -i
#    ...    /sharedvolume/flowtracer/images/flowtracer_RHEL7_20.08.482_docker.img
#    ${ret}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
#    ${cmd}=    Catenate    sudo sed -i
#    ...    's/collectorIpAddress=[0-9]*.[0-9]*.[0-9]*.[0-9]*:9999/collectorIpAddress=10.0.1.1:9999/'
#    ...    /sharedvolume/flowtracer/config/_collector_config.txt
#    OperatingSystem.Run And Return Rc And Output    ${cmd}
#    ${cmd}=    Catenate    sudo sed -i
#    ...    's/providerControllerAddrList = [0-9]*.[0-9]*.[0-9]*.[0-9]*:20401/providerControllerAddrList = 10.0.1.2:20401/'
#    ...    /sharedvolume/flowtracer/config/_controller_config.txt
#    OperatingSystem.Run And Return Rc And Output    ${cmd}
#    ${cmd}=    Catenate    sudo sed -i
#    ...    's/autoCollectorList=DataCollector@[0-9]*.[0-9]*.[0-9]*.[0-9]*:9999/autoCollectorList=DataCollector@10.0.1.1:9999/'
#    ...    /sharedvolume/flowtracer/config/_controller_config.txt
#    OperatingSystem.Run And Return Rc And Output    ${cmd}
#    ${cmd_start_docker}=    Catenate    sudo docker run -d --network host --name flowtracer
#    ...    -v /sharedvolume/flowtracer/:/home/tracer/FlowTracer/ext flowtracer:latest
#    OperatingSystem.Run And Return Rc And Output    ${cmd_start_docker}
#    OperatingSystem.Run And Return Rc And Output    sudo docker ps -a
#
#DCAP Start Monitor Session
#    [Documentation]    optional_filer: 5gfilter.txt
#    [Arguments]    ${session_name}=ZmqSession    ${filter_file}=5gfilter.txt
#    OperatingSystem.Run And Return Rc And Output    sudo cp ${CURDIR}/${filter_file} /sharedvolume/flowtracer/
#    ${cmd0}=    Catenate    SEPARATOR=    './fcmd 127.0.0.1:40001 cm n=${session_name} p=AutoProvider d=DataCollector\\\@10.0.1.1:9999 m=
#    ...    [f5c:@ext/${filter_file}][su:GIVAXI-0][gnb:gNB5G] pl=[n:flowdiskwriter][c:@ext/config/_diskwriter.conf][s:1]'
#    ${cmd}=    Catenate    sudo docker exec -it flowtracer bash -c    ${cmd0}
#    OperatingSystem.Run And Return Rc And Output    ${cmd}
#
#DCAP Start Monitor Session Syscom
#    [Documentation]    optional_filer: 5gfilter.txt
#    [Arguments]    ${session_name}=SyscomSession    ${filter_file}=syscom_filter.txt
#    OperatingSystem.Run And Return Rc And Output    sudo cp ${CURDIR}/${filter_file} /sharedvolume/flowtracer/
#    ${cmd0}=    Catenate    SEPARATOR=    './fcmd 127.0.0.1:40001 cm n=SyscomSession p=AutoProvider d=DataCollector\\\@10.0.1.1:9999 m=
#    ...    [f5s:@ext/${filter_file}][sh:CPRT00,CPNRT00,CPNB00,CPCL00][gnb:gNB5G][f:0000] pl=[n:flowdiskwriter][c:@ext/config/_diskwriter.conf][s:1]'
#    ${cmd}=    Catenate    sudo docker exec -it flowtracer bash -c    ${cmd0}
#    OperatingSystem.Run And Return Rc And Output    ${cmd}
#
#DCAP Stop Monitor Session
#    [Arguments]    ${session_name}=ZmqSession
#    OperatingSystem.Run And Return Rc And Output    sudo docker exec -it flowtracer bash -c './fcmd 127.0.0.1:40001 dm ${session_name}'
#
#Onair and UE attach
#    Suite Setup Copy WTS Config Files From QT
#    Suite Setup Start WTS And Check OnAir
#    NSA LTE Attach    ue_id=1    profile_id=1
#    NSA 5G Attach    ue_id=1    gnb_id=2    cell_id=1    bearer_id=2
#    NSA Start DL Traffic    ue_id=1    bearer_id=2    mbps=100
#    NSA Start UL Traffic    ue_id=1    bearer_id=2    mbps=20
#    NSA Check Average Traffic Bigger Than Target    ue_id=1    bearer_id=2    dir=dl    tp_rate=9
#
#Suite Setup Start WTS And Check OnAir
#    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Start UTE WTS
#    Run Keyword If    '${GNBCUTYPE}'=='NSA'    Setup X2 Connection
#    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
#    Verify Cell Setup
#
#Check Log Exist
#    OperatingSystem.Directory Should Not Be Empty   /sharedvolume/flowtracer/tmp/5G/
#
#Check NoLog Exist
#    OperatingSystem.Directory Should Be Empty   /sharedvolume/flowtracer/tmp/5G/
#
#Online SCF Commission One Para
#    [Arguments]   ${dist_name}    ${parameter}    ${value}
#    COAM.Setup Admin
#    COAM.Perform Parameter Recommissioning
#    ...    dist_name=${dist_name}    parameter=${parameter}    operation=update    value=${value}    skip_parameter_relation_errors=True
#    COAM.Teardown
#
#Delete Old Logfile
#    OperatingSystem.Run And Return Rc And Output    sudo rm -rf /sharedvolume/flowtracer/tmp/5G/*
#
#clean edaemon and egate
#    ute_wtssim.Teardown Edaemon    alias=edaemon
#    ute_wtssim.Teardown Egate
#
#Testcase Teardown
#    Common Test Teardown
#    clean edaemon and egate