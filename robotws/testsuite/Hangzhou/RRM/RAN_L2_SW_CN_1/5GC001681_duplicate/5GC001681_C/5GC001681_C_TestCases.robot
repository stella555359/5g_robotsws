*** Settings ***
Documentation    ...
#Documentation      author: suhou   contact: susie.hou@nokia-sbell.com
#Library            OperatingSystem
#Library            Process
#Library            String
#Library            DateTime
#Library            taf.transport.ssh    WITH NAME    ssh
#Resource           ../../CUDU_L2/report_portal.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#
#*** Variables ***
#${Search}  cat /sharedvolume/flowtracer/config/_controller_config.txt |grep ^autoCollectorList=DataCollector@
#${dcap_delete_test_file_2}  echo dcapuser123 | sudo -S rm -rf /sharedvolume/flowtracer/tmp/5G/*
#${delete_dcap_session_by_ta}    docker exec -it flowtracer /bin/bash -c './fcmd 127.0.0.1:40001 dm TA_C006_S'
#${delete_files}   docker exec -it flowtracer /bin/bash -c 'rm -rf CheckAndCreateSessionForTA.sh; rm -rf result.txt'
#${gnb_ip}         ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
#${gNB_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
#${gNB_password}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#${set_filter}   echo -e "{\n  \\"TraceFilter\\":\n  [\n    {\n    \\"hostname\\":\\"CPNB-0\\",\n    \\"mode\\":1,\n    \\"type\\":1,\n
#...              \\"format\\":0,\n    \\"msgid\\":\\"0x2b83, 0x0001-0xFFF0\\",\n    \\"heavyload_id\\":\\"0x2b83:5\\"\n    },\n
#...              {\n    \\"hostname\\":\\"CPNRT-0\\",\n    \\"mode\\":1,\n    \\"type\\":1,\n
#...              \\"format\\":0,\n    \\"msgid\\":\\"0x2b83, 0x0001-0xFFF0\\",\n    \\"heavyload_id\\":\\"0x2b83:5\\"\n    },\n
#...              {\n    \\"hostname\\":\\"CPCL-0\\",\n    \\"mode\\":1,\n    \\"type\\":1,\n
#...              \\"format\\":0,\n    \\"msgid\\":\\"0x2b83, 0x0001-0xFFF0\\",\n    \\"heavyload_id\\":\\"0x2b83:5\\"\n    },\n
#...              {\n    \\"hostname\\":\\"CPRT-0\\",\n    \\"mode\\":1,\n    \\"type\\":1,\n
#...              \\"format\\":0,\n    \\"msgid\\":\\"0x2b83, 0x0001-0xFFF0\\",\n    \\"heavyload_id\\":\\"0x2b83:5\\"\n    }\n
#...              ]\n}" >./TracerFilter.txt
#${use_C006_filter}   docker exec -it flowtracer /bin/bash -c '${set_filter}'
#${cp_script_to_dcap}  docker cp /home/dcapuser/CheckAndCreateSessionForTA.sh flowtracer:/home/tracer/FlowTracer
#
#*** Test Cases ***
#5GC001681_C_006_Verify_capturing_and_streaming_of_SysCom_messages_exchanged_inside_CP-NRT_CP-RT_CP-NB_CP-CELL_VMs_in_classical_BTS
#    [Documentation]    The purpose of the UC is to verify SysCom message.
#    [Tags]    Classical    CRT_HNZ    5GC001681    FR1    FR2    QCD_MN_5G    QCP_5G
#    ...    IPV4    Owner_susie    PRI-Medium    CN1    5G19A
#    [Setup]    Dynamic set QC instance ID tag    Classical_5G19A    QC_291707    Classical_Trunk    QC_396473
#    Prepare Test
#    Check COAM gNB cell setup
#    Connect to DCAP
#    ${SessionIp}  ssh.execute  command=${Search}  connection=DCAP-conn  timeout=1s
#    ${SIp}    Replace String   ${SessionIp}   \r\n   ${EMPTY}
#    ${Ip}   Get Substring   ${SIp}   32   49
#    ${Ip}   Fetch From Right  ${SIp}  @
#    Log to console  \n dcap_ip:${Ip}
#    ssh.execute  docker exec -it flowtracer /bin/bash -c './CheckAndCreateSessionForTA.sh C006 ${Ip}'   connection=DCAP-conn
#    Reboot gnb and check its status
#    Sleep  60s
#    ${current_date}     Get Current Date    result_format=%Y%m%d
#    ${tmp}   ssh.execute  find /sharedvolume/flowtracer/tmp/5G/${current_date}/ -name *${current_date}*.5gm|awk 'END {print}'  connection=DCAP-conn
#    ${tracefile_1}    Replace String   ${tmp}   \r\n   ${EMPTY}
#    ${file_size1_tmp}   ssh.execute   ls -lrt ${tracefile_1}|awk '{print $5}'   connection=DCAP-conn
#    ${file_size1}   Replace String    ${file_size1_tmp}   \r\n   ${EMPTY}
#    Sleep  10s
#    ${tmp}   ssh.execute  find /sharedvolume/flowtracer/tmp/5G/${current_date}/ -name *${current_date}*.5gm|awk 'END {print}'  connection=DCAP-conn
#    ${tracefile_2}    Replace String   ${tmp}   \r\n   ${EMPTY}
#    ${file_size2_tmp}   ssh.execute   ls -lrt ${tracefile_2}|awk '{print $5}'   connection=DCAP-conn
#    ${file_size2}    Replace String    ${file_size2_tmp}   \r\n   ${EMPTY}
#    ${result}     run keyword if     ${file_size2}>=${file_size1}    set variable    PASS    ELSE    set variable    FAIL
#    should contain    ${result}    PASS
#    [Teardown]  Recover TL
#
#*** Keywords ***
#Check COAM gNB cell setup
#    [Documentation]
#    ...              Description: Wait until GNB status ready.
#    [Timeout]  20 min
#    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM
#    Wait until keyword succeeds    ${timeout}    20 sec    Connect to gnb coam via ssl    connection=${connection}
#    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB ABIL status    connection=${connection}
#    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB cell on air    connection=${connection}
#
#Connect to DCAP
#   ssh.connect_to    hostname=${DCAP_IP}    username=${DCAP_USER}    password=${DCAP_PASSWD}    alias=DCAP-conn
#
#Close connect of DCAP
#   ssh.disconnect    connection=DCAP-conn
#
#Prepare Test
#   run   export no_proxy=localhost,127.0.0.0/8
#   ${filelocation}  run  find / -name CheckAndCreateSessionForTA.sh 2>/dev/null
#   run process   sudo sshpass -p ${DCAP_PASSWD} scp ${filelocation} ${DCAP_USER}@${DCAP_IP}:/home/dcapuser/  shell=yes
#   Connect to DCAP
#   ssh.execute  command=${dcap_delete_test_file_2}  connection=DCAP-conn   timeout=1s
#   ssh.execute  command=${use_C006_filter}   connection=DCAP-conn   timeout=1s
#   ssh.execute  command=${cp_script_to_dcap}  connection=DCAP-conn   timeout=1s
#   Close connect of DCAP
#
#Recover TL
#   COAM Teardown gnb connections
#   ssh.execute  command=${delete_dcap_session_by_ta}   connection=DCAP-conn   timeout=1s
#   ssh.execute   command=${delete_files}               connection=DCAP-conn   timeout=1s
#   Close connect of DCAP
#
#Reboot gnb and check its status
#   ssh.connect_to    hostname=${gNB_ip}   username=${gNB_username}   password=${gNB_password}   alias=gNB-conn
#   ssh.execute   reboot     connection=gNB-conn
#   wait until keyword succeeds   5min   60sec   check COAM gNB cell setup
#   ssh.connect_to    hostname=${gNB_ip}   username=${gNB_username}   password=${gNB_password}   alias=gNB-conn
#   ${gNB_Ret}   ssh.execute   netstat -pantu |grep 9999   connection=gNB-conn
#   should contain   ${gNB_Ret}   ESTABLISHED
#
