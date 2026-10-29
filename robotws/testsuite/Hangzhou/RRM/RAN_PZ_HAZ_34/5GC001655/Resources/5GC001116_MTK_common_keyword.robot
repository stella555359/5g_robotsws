*** Settings ***
Documentation
...    author: Bi Jiajian
...    contact: jiajian.bi@nokia-sbell.com
...    Group: HGZ_SG2

Library         taf.transport.ssh		WITH NAME	csn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource        taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/MTK_common_keywords.robot

*** Variables ***
${IMSI}              ${tl.ues[0].imsi}
${pdu_ue_addr}       ${tl.ues[0].pdu.pdu.addr}
@{pdu_ue_port}       ${tl.ues[0].pdu.port_no}
${ELT_PATH}         ${tl.ues[0].elt_path}

${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

${MTK_CtrlPC_IP}           ${tl.ues[0].ssh_connection_details.addr}
${MTK_CtrlPC_USERNAME}     ${tl.ues[0].ssh_connection_details.username}
${MTK_CtrlPC_PASSWORD}     ${tl.ues[0].ssh_connection_details.password}

*** Keywords ***
Clear UE info from AMF
   [Arguments]  ${ue_imsi}=${IMSI}
   Connect to 5GC
   ${imsi_presence}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi} | head -n 7 | grep GENERALINFO    connection=5GC
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    csn.execute   command=cmm subscriber delete --imsi ${ue_imsi}    connection=5GC
   Disconnect from 5GC

Verify if UE registered to AMF
   [Arguments]  ${ue_imsi}=${IMSI}
   Connect to 5GC
   ${output}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep amfRmState   connection=5GC
   should contain   ${output}   REGISTERED
   ${output}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep amfCmState  connection=5GC
   should contain   ${output}   CONNECTED
   Disconnect from 5GC
   
Connect to 5GC
    csn.connect to    hostname=${5GC_IP}   username=${5GC_USERNAME}    password=${5GC_PASSWORD}    alias=5GC

Disconnect from 5GC
    csn.disconnect    connection=5GC

Connect MTK CtrlPC
    csn.connect to    hostname=${MTK_CtrlPC_IP}   username=${MTK_CtrlPC_USERNAME}  password=${MTK_CtrlPC_PASSWORD}  alias=MTK_CPC

Disconnect MTK CtrlPC
    csn.disconnect    connection=MTK_CPC

Close the iperf process on MTK
    wait until keyword succeeds    5 min    10 sec    Connect MTK CtrlPC
    ${output}=    csn.execute    command=ps -ef |grep iperf    connection=MTK_CPC
    ${len}=    Get length    ${output}
    ${iperf_pid_list}=    Run Keyword If    ${len}>0    csn.execute    command=ps -ef |grep iperf |awk '{print $2}'
    ...    connection=MTK_CPC
    @{iperf_pid_list}=    Split To Lines    ${iperf_pid_list}
    FOR    ${iperf_pid}    IN    @{iperf_pid_list}
        csn.execute    command=kill -9 ${iperf_pid}    connection=MTK_CPC
    END

Clear Python in MTK CtrlPC
    [Arguments]    ${elt_path}=${ELT_PATH}
    Connect MTK CtrlPC
    ${pythonCnt}    csn.Execute    command=ps -Wef | grep python |grep -v grep|awk '{print$2}'|awk 'END{print NR}'    connection=MTK_CPC
    Should not be empty    ${pythonCnt}
    FOR    ${i}    IN RANGE    ${pythonCnt}
        ${PID1}   csn.Execute   command=ps -Wef|grep python|awk '{{print $2}}'|head -n 1    connection=MTK_CPC
        Log  message=Killing ${i+1}st python process with PID ${PID1}.
        csn.Execute    command=/bin/kill -f ${PID1.strip()}    connection=MTK_CPC
    END
    csn.Execute    command=ps -Wef | grep python |grep -v grep    connection=MTK_CPC
    csn.Execute    command=cd ${elt_path}/Temp;ls |grep "\.tmp" |xargs rm -rf    connection=MTK_CPC
    Disconnect MTK CtrlPC

Modify netcard mode to DHCP
    Connect MTK CtrlPC
    csn.execute    command=netsh interface ipv4 set address name="Ethernet 2" dhcp    connection=MTK_CPC
    Disconnect MTK CtrlPC
