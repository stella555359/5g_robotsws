*** Settings ***
Library   Collections
Library   taf.ue
Library   ./ue.py
Resource  testsuite/Wroclaw/RRM/resources/preconditions.robot
Library   String


*** Variables ***
${cell_setup_file}   cell_setup.pcap
&{ue_ip_dict}
&{ue_rnti_dict}

${THROUGHPUT START}
${THROUGHPUT END}
${THROUGHPUT LOGS}

*** Keywords ***
Attach
    [Arguments]   ${ue_alias}
    Start tcpdump on LTE   filename=attach_lte.pcap
    Start tcpdump on CU
    Attach Ue     ue_alias=${ue_alias}
    Stop tcpdump on LTE and get logs   filename=attach_lte.pcap
    Stop tcpdump on CU and download logs
    ${ue_ip}=   Get ue ip from lte attach pcap   pcap_file=${LOG_PATH}/attach_lte.pcap
    ${ue_rnti}=    Get ue rnti from lte attach pcap
    Set to dictionary   ${ue_ip_dict}      ${ue_alias}=${ue_ip}
    Set to dictionary   ${ue_rnti_dict}    ${ue_alias}=${ue_rnti}
    Log dictionary      ${ue_ip_dict}
    Log dictionary      ${ue_rnti_dict}


Detach
    [Arguments]   ${ue_alias}
    Detach ue     ${ue_alias}


Start traffic on UE
    [Arguments]   @{args}   &{kwargs}
    [Documentation]  This is pretty ugly workaround. It will be changed after multi UE traffic implementation
    ...              in taf.ue will be done.
    ...   args:      (str) ue aliases (UE_1 or UE_2)
    ...   kwargs:    for specific traffic values set:
    ...                 * ul_throughput: (str) f.e. 40M
    ...                 * ul_traffic_time: (str) in seconds, do not set if traffic should be only in dl direction
    ...                 * dl_throughput: (str) f.e. 40M
    ...                 * dl_traffic_time: (str) in seconds, do not set if traffic should be only in ul direction
    ...                 * do_not_kill_pppd: set this if eny traffic is already started
    Start traffic on mue config   @{args}   &{kwargs}
    ${THROUGHPUT START}=   Get current time
    Set Global Variable    ${THROUGHPUT START}


Let traffic run for given duration
    [Arguments]  ${duration}
    Sleep  ${duration}
    ${THROUGHPUT END}=    Get current time
    Set Global Variable   ${THROUGHPUT END}


Get throughput logs
    [Documentation]        Gather throughput statistics from gNB
    [Arguments]            ${start_time}=${THROUGHPUT START}
    ...                    ${stop_time}=${THROUGHPUT END}
    ${abil_alias}=         Connect to ABIL MASTER
    ${command}=            catenate  SEPARATOR=${SPACE}
    ...                    journalctl --since\="${start_time}" --until\="${stop_time}" --no-pager
    ...                    \| grep -e "-L2_LO_UL_0" -e "-L2_LO_TB_BUI0" -e "L-RLC numOfBearers"
    ${THROUGHPUT LOGS}=    ssh.Execute
    ...                    ${command}
    ...                    connection=${abil_alias}
    ...                    timeout=120s
    [Return]               ${THROUGHPUT LOGS}


Throughput results analyse
    [Arguments]            ${uplink}   ${downlink}
    ${averages}=           Get Average UL DL Throughput    ${THROUGHPUT LOGS}
    ${UL Mbits}=           Set variable                    ${averages[0]}
    ${DL Mbits}=           Set variable                    ${averages[1]}
    Log to console         Uplink:\t${UL Mbits} Mbit/s
    Log to console         Downlink:\t${DL Mbits} Mbit/s
    should be true         ${UL Mbits} >= ${uplink}
    should be true         ${DL Mbits} >= ${downlink}


Get current time
    ${asik_alias}=   Connect to ASIK
    ${timestamp}=    ssh.execute
    ...              date "+%G-%m-%e %H:%M:%S"
    ...              connection=${asik_alias}
    [Return]         ${timestamp.strip()}


Set synchronisation
    ${asik_alias}=   Connect to ASIK
    ${command}=  set variable  ddal -s ddal_clk_io_configure_output_signal 1 DDAL_CLK_IO_SIGNAL_10M_INTERNAL DDAL_CLK_IO_PORT_SINGLE_ENDED_OUT_1
    ssh.Execute   command=${command}  connection=${asik_alias}


Get RNTI
    [Arguments]   ${UE}
    ${rnti_ue}=  Get From Dictionary   ${ue_rnti_dict}   ${UE}
    [Return]   ${rnti_ue}


Attach on SA
    [Arguments]   ${ue_alias}
    Attach Ue     ue_alias=${ue_alias}
    ${output}=  Run  command=sshpass -p ute ssh -A -t ute@10.42.61.2 "sudo mue/pppd_1.sh"
    Sleep  5s
    ${ip}=   Get UE IP
    Set to dictionary   ${ue_ip_dict}      ${ue_alias}=${ip}
    Log dictionary      ${ue_ip_dict}


Get UE IP
    ${output}=  Run  command=sshpass -p ute ssh -A -t ute@10.42.61.2 "sudo ip a |grep ppp0"
    @{ip}=  Get Regexp Matches  ${output}  inet\\s(\\d{1,3}[.]\\d{1,3}[.]\\d{1,3}[.]\\d{1,3})\\speer  1
    ${ip}=  set variable  @{ip}[0]
    [Return]  ${ip}
