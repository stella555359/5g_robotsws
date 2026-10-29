***Settings***
Documentation
...            [Author]         "Monika Parasar"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"



Resource    ${CURDIR}/../resources/common_keywords.robot

Suite Setup         Setup Oamops
Suite Teardown     Teardown Oamops

***Variables***
${source_file}                  /tmp/192.168.255.129_scf.xml
${Backup_file}                  ${CURDIR}/SCFC.xml
${PLMN}                         244:09
${dst_Port1}                    5001
${MBMS_GW}                      10.0.1.5
${dst_MAC_ADDR}                 01:00:5e:00:00:01


***Test Cases***
[1][2.0] TRAN_MBMS_Counter_Correctness

#MBMS session start
    Bring Up Logical Interface
    sleep   120
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=Initial_MBMS_conf
    Call Setup    lte=MBMS_IPV4_plain:data     parallel=${False}    verify_attach=${False}       attach=${False}
    sleep       450
    ${MBMS_start}=       Traffic Capture Stop        alias=Initial_MBMS_conf
    sleep   120
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=MBMS_Start
    Execute Cmd On Egate        lte=MBMS_IPV4_plain:data        cmd=mbms_session_start tmgi=1:244:09 duration=0:900
    ...      sai=1 m1_dst_addr=232.0.0.1 m1_teid=200 mbmsgw_trf_tun_ip=2.2.2.1 dst_ip=3.3.3.254 dst_port=5001
    ...      max_delay=50 trf_adapt_scheme=buffering sync_seq=1 sync_period=100 qci=1 gbr=50
    sleep       60
    Check M3 Link Status
    ${MBMS_session}=       Traffic Capture Stop        alias=MBMS_Start
    verify Wireshark For MBMS session message           ${MBMS_session}
    Pm Counters Start     analysis=verify_MBMS_IPv4_counters       counter_analysis_file=${MBMS_counter}
    Start tcpdump on the ENB            IGMP.pcap       br1
    FOR    ${index}    IN RANGE    0  4
           Execute Cmd On Egate        lte=MBMS_IPV4_plain:data        cmd=mbms_session_stop tmgi=1:244:09
           sleep       30
           Execute Cmd On Egate        lte=MBMS_IPV4_plain:data        cmd=mbms_session_start tmgi=1:244:09
           ...   duration=0:900 sai=1 m1_dst_addr=232.0.0.1 m1_teid=200 mbmsgw_trf_tun_ip=2.2.2.1 dst_ip=3.3.3.254
           ...   dst_port=5001 max_delay=50 trf_adapt_scheme=buffering sync_seq=1 sync_period=100 qci=1 gbr=50
           sleep       30
    END
    Stop tcpdump on the ENB
    ${IGMP_pkts_count}=     Evaluate    ${IGMP_start_pkts_count}+${IGMP_stop_pkts_count}
    Verify Pm Counters    analysis=verify_MBMS_IPv4_counters       counter_analysis_file=${MBMS_counter}
    Execute Cmd On Egate        lte=MBMS_IPV4_plain:data        cmd=mbms_session_stop tmgi=1:244:09
    Wait for next iteration of counter

#Counter:ifInMCastPackets
    Pm Counters Start     analysis=verify_MBMS_IPv4_counters       counter_analysis_file=${MBMS_counter}
    Execute Cmd On Egate        lte=MBMS_IPV4_plain:data        cmd=mbms_session_start tmgi=1:244:09
    ...     duration=0:900 sai=1 m1_dst_addr=232.0.0.1 m1_teid=200 mbmsgw_trf_tun_ip=2.2.2.1 dst_ip=3.3.3.254
    ...     dst_port=5001 max_delay=50 trf_adapt_scheme=buffering sync_seq=1 sync_period=100 qci=1 gbr=50
    Run     iperf -B 2.2.2.254 -c 2.2.2.1 -p 5001 -u -t 1000000 -i 1 -b 500k -l 250 -t 10
    sleep   10
    Execute Cmd On Egate        lte=MBMS_IPV4_plain:data        cmd=mbms_session_stop tmgi=1:244:09
    sleep       10
    ${sync_pkts_count}=     Run  tshark -o gtp.dissect_tpdu_as:SYNC -r sync.pcap -Y "sync" | wc -l
    Verify Pm Counters    analysis=verify_MBMS_IPv4_counters       counter_analysis_file=${MBMS_counter}

***Keywords***
Wait for next iteration of counter
    ${secs}=  Get Time  epoch   UTC
    ${mod_time} =    Evaluate    ${secs}%900
    ${latest_time} =    Evaluate    ${secs}-${mod_time}
    ${current_time} =  Get Time    ${EMPTY}    ${latest_time}
    @{date_list}=    Split String    ${current_time}
    ${current_time} =   Catenate    ${date_list[0]}T${date_list[1]}.000+00:00:00
    ${end_epoch_time}=              Get Time        format=epoch    time_=UTC
    ${end_epoch_mod_900}=           Evaluate        ${end_epoch_time}%900
    ${Sleep_time}=      Evaluate        960-${end_epoch_mod_900}
    Sleep       ${Sleep_time}
Start Capturing the packets
    Set Suite Variable    ${log_file}
    Start Capturing              alias=mirror_eth3

Stop capturing the packets
    Stop Capturing          alias=mirror_eth3
    Teardown Tshark         alias=mirror_eth3
    Copy File       ${EXECDIR}/${log_file}  ${OUTPUT DIR}/BTSSM_CLI_Tool_Logs/
Check M3 Link Status
    ${flag_status}=     Get Parameter      param_path=MRBTS-1/LNBTS-1/LNMCE-0/LNM3-0:m3LinkStatus
    Should Be Equal     '${flag_status}'    'available'
Download BTS_TRS File from eNB
    ${status}=  Get Element text        ${source_file}     .//managedObject[@class="NOKLTE:LNM3"]/p[@name="m3LinkStatus"]
    Should be equal     ${status}    ${m3_status}
Bring Up Logical Interface
    Run    sudo ifconfig eth3.200:100 ${MBMS_GW} netmask 255.255.255.0
verify Wireshark For M3 setup message
    [Arguments]         ${Wireshark_file}
     Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=M3_setup_request     filter_file_name=${pcap_file}
     Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=M3_setup_response     filter_file_name=${pcap_file}
verify Wireshark For MBMS session message
    [Arguments]         ${pcap_file}
    ${output}=  Run  tshark -r ${pcap_file} -Y "m3ap.procedureCode == 0 && ip.src==10.0.1.2 && ip.dst==10.0.1.1"
    Should Not Be Empty   ${output}
    ${output}=  Run  tshark -r ${pcap_file} -Y "m3ap.procedureCode == 0 && ip.src==10.0.1.1 && ip.dst==10.0.1.2"
    Should Not Be Empty   ${output}
    ${output}=  Run  tshark -o gtp.dissect_tpdu_as:SYNC -r ${pcap_file} -Y "sync && ip.src==10.0.1.5 && ip.dst==232.0.0.1"
    Should Not Be Empty   ${output}
Start tcpdump on the ENB
    [Arguments]    ${tshark_file_name}     ${interface}
    Run     expect ${CURDIR}/../resources/ENB_TCPDUMP.exp ${tshark_file_name} ${interface}
Stop tcpdump on the ENB
    ${cmd}=     Set Variable    killall tcpdump
    Execute command on GNB   ${cmd}
