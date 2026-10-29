*** Settings ***
Resource     ../../../robot/common_resource.robot


*** Test Cases ***
Test windows
	${pc_info}    create list    10.140.160.226    tdlte-tester    btstest    23
    start_udp_iperf_server    ${pc_info}     15301     d:/server2.log   alias=server
    start_udp_iperf_client    ${pc_info}     10.140.160.226  15301   20   alias=client
    sleep    3
    stop_iperf_client     10.140.160.226    15301    alias=client
    stop_iperf_server     15301    alias=server


Test linux
    ${pc_info}    create list    10.56.78.18    ute    ute    22
    start_udp_iperf_server    ${pc_info}     15301     /home/ute/server1.log
    start_udp_iperf_client    ${pc_info}     10.56.78.18  15301   20
    sleep    3
    stop_iperf_client     10.56.78.18    15301
    stop_iperf_server     15301

Test win and linux
    ${pc_info_server}    create list    10.56.78.18    ute    ute    22
    ${pc_info_client}    create list    10.140.160.226    tdlte-tester    btstest    23
    start_udp_iperf_server    ${pc_info_server}       15301     /home/ute/server3.log
    start_udp_iperf_client    ${pc_info_client}     10.56.78.18  15301   20
    sleep    3
    stop_iperf_client     10.56.78.18    15301
    stop_iperf_server     15301


get throughput
    ${tp}    get_iperf_throughput     ${CURDIR}${/}111.log
    ${tp}    get_iperf_throughput     ${CURDIR}${/}throughput.txt      ${True}
    ${tp}    get_iperf_throughput     ${CURDIR}${/}throughput.txt      ${False}