*** Settings ***
Library           taf.transport.ssh    WITH NAME    csn
Library     taf.rfrl.common_resources.python.gNB_l2_lo_throughput
Library           ${CURDIR}/throughput_caculate.py

*** Variables ***


*** Keywords ***
Calculate the E2E Appserver side UL TP
    [Arguments]    ${UPLINK_DATA_TRANSFER}
    Connect to APPserver    alias=APPserver
    ${UL_tp} =    Calculate_End2End_throughoutput    alias=APPserver    port=${ul_port}    iperf_path=iperf
    ssh.disconnect     connection=APPserver
    should be true    ${UL_tp} > ${UPLINK_DATA_TRANSFER}

Evaluate UL and DL throughput on ${hw_abil}
    wait until keyword succeeds    1min    10s    Connect to ASIK
	wait until keyword succeeds    1min    10s    Connect to ${hw_abil}
    ${DL_throughoutput}=    Calculate DL throughoutput    alias=${hw_abil}
    ${UL_throughoutput}=    Calculate UL throughoutput    alias=${hw_abil}
    csn.disconnect    connection=${hw_abil}
    csn.disconnect    connection=ASIK
    should be true    ${DL_throughoutput} > ${DOWNLINK_DATA_TRANSFER}
    should be true    ${UL_throughoutput} > ${UPLINK_DATA_TRANSFER}

Start DL traffic via iperf on Appserver
    [Arguments]     ${ue_addr}    ${dl_time}    ${dl_port}    ${dl_throughput}    ${dl_length}
    wait until keyword succeeds    5 min    10 sec    Connect to APPserver
	csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
	csn.send command    command= iperf -c ${ue_addr} -u -t ${dl_time} -i 1 -p ${dl_port} -P 1 -f m -b ${dl_throughput} -l ${dl_length} -T 64 &
	...    connection=APPserver

Close the iperf process on APPserver
     wait until keyword succeeds    5 min    10 sec    Connect to APPserver
     csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
     sleep    3s
     csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${ul_port}| awk '{print $2}' |xargs kill -9    connection=APPserver

Connect to APPserver
    [Arguments]    ${alias}=APPserver
	csn.Connect to    hostname=${APPserver_addr}    username=${APPserver_username}    password=${APPserver_password}
	...    alias=${alias}

Connect to EPCsim
    [Arguments]    ${alias}=Epcsim
    csn.Connect to    hostname=${tl.core.default_ssh_connection_details.addr}
    ...    username=${tl.core.default_ssh_connection_details.username}
    ...    password=${tl.core.default_ssh_connection_details.password}    alias=${alias}

Connect MTK CtrlPC
    [Arguments]    ${alias}=MTK_CPC
    ssh.connect to    hostname=${MTK_CtrlPC_IP}   username=${MTK_CtrlPC_USERNAME}  password=${MTK_CtrlPC_PASSWORD}  alias=MTK_CPC

Disconnect MTK CtrlPC
    ssh.disconnect    connection=MTK_CPC
