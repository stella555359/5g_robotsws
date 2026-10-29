*** Settings ***
Documentation   The feature introduces security improvements and new hardening measures

...             Test Case scenario author: Vladyslava Shvets
...             Test Case scenario contact: vladyslava.shvets@nokia.com

...             Test Case automation author: Szymon Romanowski
...             Test Case automation contact: szymon.romanowski@nokia.com

Resource            ../../CB007672-A/Resources/Keywords.robot
Resource            ../../../common_resources/scf/scf_objects.robot
Resource            ../../../common_resources/alarms/alarm.robot
Resource            ../../../common_resources/alarms/watchdog.robot
Resource            ../../../common_resources/mantaray/mantaray.robot
Resource            ../../../common_resources/ip_traffic/ip_traffic.robot
Resource            ../../../common_resources/tls/tls.robot
Resource            ../../../common_resources/scf/scf_objects.robot
Resource            ../../../common_resources/counters/counters_keywords.robot
Resource            ../Resources/Keywords.robot
Resource            ../../../common_resources/pdu/pdu_keywords.robot
Library             ../../CB007672-A/Resources/resources.py    WITH NAME    main_resource
Library             Telnet
Library             DateTime

*** Variables ***
${CRL_alarm_new}=     CRL Update failure
${CRL_alarm_old}=     CRL Update Failure
@{BRANCHES_WITH_OLD_ALARM}       SBTS24R1     SBTS23R4     SBTS23R3
${NMS_USERNAME}          omc
${NMS_PASSWORD}          Medsql!_1893
${ECDSA_SUBJECT_NAME_9482}    CN=CB010265_EC_Cloud
${RSA_SUBJECT_NAME_9482}      CN=CB005999_test

${M51328C17_BURST}=                               4000
${M51328C17_LIMIT}=                               4064
${M51328C17_PPS}=                                 ${M51328C17_LIMIT} * 2
${M51328C17_LOOP}=                                10
${M51328C17_PACKETS_LIMIT}=                       (${M51328C17_LIMIT} * ${M51328C17_LOOP} + ${M51328C17_BURST})
${M51328C17_PACKETS}=                             ${M51328C17_LOOP} * (${M51328C17_PPS})
${M51328C17_TCPDUMP_STATISTICAL_ERROR}=           0.1
${M51328C17_TCPDUMP_STATISTICAL_ERROR_MORE}=      (1 + ${M51328C17_TCPDUMP_STATISTICAL_ERROR})
${M51328C17_TCPDUMP_STATISTICAL_ERROR_LESS}=      (1 - ${M51328C17_TCPDUMP_STATISTICAL_ERROR})
${M51328C17_SHOULD_BE_COLLECTED}=                 ${M51328C17_PACKETS} - (${M51328C17_LIMIT} * ${M51328C17_LOOP}) - ${M51328C17_BURST}
${M51328C17_TEST_STATISTICAL_ERROR}=              (${M51328C17_LOOP} * (${M51328C17_PPS})) / 10

&{PARAMS_SYSLOG}            remoteSyslogDSCP=0    remoteSyslogFormat=RFC5424   remoteSyslogServerHost=10.42.63.247
...                         remoteSyslogServerPortNo=6516   remoteSyslogTransmitDuration=10080
...                         remoteSyslogTransportProtocol=TLS
&{PARAMS_RTPM}              certTypeForTlsAuth=RSA    rTPmCollEntityHost=10.42.209.74   rTPmCollEntityPortNum=49525
...                         rTPmCollInterval=60s   tlsEnabled=true
@{PARAMS_RTPM_2}            55318 NR eCPRI U-Plane and Fast-C-Plane  55308 NR Cell Utilization

*** Keywords ***
CB009482-SR-E_Rate_limit_for_ARP_packets-ipRmDropPcktsRtLimARP
    [Arguments]  ${Test_PC_connection_to_activate}  ${Test_PC_interface}
    Log    Step 1: Integration to MantaRay    console=true
    ${NMS_LAB}    Integrate BTS to MantaRay without TLS    PREFERRED_LAB=srnclab1047
    Log    Step 2: Changing reporting counters interval    console=true
    counters_keywords.Change Rejected Packets Interval To 5min
    counters_keywords.Change Reporting Interval To 5min
    Sleep    11min    reason=Wait until counters will be collected in 5-minutes intervals
    Log    Step 3: Activate test PC to send packets    console=true
    Activate connection on Test PC  ${Test_PC_connection_to_activate}
    ${mac_address_for_m_place}=  Get MAC address for IPv4 address  ${MPLANE_IPV4}
    Log    Step 4: Waiting for new counter to send the packets    console=true
    ${1st_time}  ${1st_value}    Wait For Next Counter Interval and Get Counter Timestamp with Value    M51328C17
    Start Tcpdump For M51328C17 Counter
    ${scapy_status}=  Send Packets For M51328C17 Counter To BTS  ${mac_address_for_m_place}  ${M51328C17_PPS}
    ...   ${M51328C17_PACKETS}  ${Test_PC_interface}
    Kill Tcpdump For M51328C17 Counter
    Log    Step 5: Waiting if the next intervals will collect the traffic    console=true
    ${2st_time}  ${2st_value}    Wait For Next Counter Interval and Get Counter Timestamp with Value    M51328C17
    ${3st_time}  ${3st_value}    Wait For Next Counter Interval and Get Counter Timestamp with Value    M51328C17
    Log    Step 6: Getting the counter value from MantaRay    console=true
    ${counter_mantaray}    Wait Until Keyword Succeeds  20m  60s
    ...   Get PM Counters from Mantaray    mrbts_id=${BTS_ID}   counters=ipRmDropPcktsRtLimArp    alias=${NMS_LAB}
    ${filtered_list}=    Evaluate    [i for i in ${counter_mantaray} if '${3st_time}' in i['period_start_time']]
    Log    Step 7: Comparing the values of counter from WebEM and MantaRay    console=true
    ${M51328C17_Webem}    Catenate    ${2st_value} + ${3st_value}
    ${M51328C17_MantaRay}    Set Variable    ${filtered_list[0]['ipRmDropPcktsRtLimArp']}
    ${equation_WebEm}=  Catenate  (${M51328C17_Webem} > ${M51328C17_SHOULD_BE_COLLECTED} -
    ...  ${M51328C17_TEST_STATISTICAL_ERROR}) and (${M51328C17_Webem} <
    ...  ${M51328C17_SHOULD_BE_COLLECTED} + ${M51328C17_TEST_STATISTICAL_ERROR})
    ${equation_MantaRay}=  Catenate  (${M51328C17_MantaRay} > ${M51328C17_SHOULD_BE_COLLECTED} -
    ...  ${M51328C17_TEST_STATISTICAL_ERROR}) and (${M51328C17_MantaRay} <
    ...  ${M51328C17_SHOULD_BE_COLLECTED} + ${M51328C17_TEST_STATISTICAL_ERROR})
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_MantaRay}
    [Teardown]    Run Keywords    Deintegrate BTS from MantaRay    ${NMS_LAB}
    ...           AND             Turn On TLS


CB009482-X_Rate_limit_for_EAP_packets-ipRmDropPcktsRtLimEap
    [Arguments]  ${Test_PC_connection_to_activate}  ${Test_PC_interface}  ${mac_address_for_m_plane}=${EMPTY}
    Turn Off TLS
    Integrate BTS to MantaRay without TLS    ${LAB_IP}    ${LAB_NAME}
    counters_keywords.Change Rejected Packets Interval To 5min
    counters_keywords.Change Reporting Interval To 5min
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C19
    Wait Until Transport Counters Available After Reboot  M51328C19
    Actualize NetAct Counters
    log  waiting for new interval start to test counter's burst value  console=yes
    Wait For New Interval Start  M51328C19
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C19
    #${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C19
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C19
    ${epoch_time}=    Convert Time To Epoch    ${WebEm_counter_time}
    #${counter_NetAct_value_after}=  Get First Counter From NetAct    ipRmDropPcktsRtLimEap    65
    ${webem_counters}=    Get Counters from WebEM    M51328C19
    ${counter_WebEm_value_before}=    Get Correct Counter Value by Epoch Time    ${webem_counters}    ${epoch_time}    300
    #Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    Activate connection on Test PC  ${Test_PC_connection_to_activate}
    ${get_current_mac_addres}=  Get MAC address for IPv4 address  ${MPLANE_IPV4}
    ${mac_address_for_m_plane}=  Set Variable If  '${mac_address_for_m_plane}' == ''  ${get_current_mac_addres}  ${mac_address_for_m_plane}
    Start Tcpdump For M51328C19 Counter
    ${scapy_status}=  Send Packets For M51328C19 Counter To BTS  ${mac_address_for_m_plane}  ${M51328C19_LIMIT}  ${M51328C19_LIMIT}
    ...  ${Test_PC_interface}
    Kill Tcpdump For M51328C19 Counter
    ${number_of_packets}=  Get Number Of Packets After Packets Flood For M51328C19
    Should Be True  ${number_of_packets} > ${M51328C19_LIMIT} - ${M51328C19_LIMIT} * ${M51328C19_TCPDUMP_STATISTICAL_ERROR}
    Should Be True  ${number_of_packets} < ${M51328C19_LIMIT} + ${M51328C19_LIMIT} * ${M51328C19_TCPDUMP_STATISTICAL_ERROR}
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C19
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C19
    #${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C19
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C19
    ${epoch_time}=    Convert Time To Epoch    ${WebEm_counter_time}
    #${counter_NetAct_value_after}=  Get First Counter From NetAct    ipRmDropPcktsRtLimEap    65
    ${webem_counters}=    Get Counters from WebEM    M51328C19
    ${counter_WebEm_value_after}=    Get Correct Counter Value by Epoch Time    ${webem_counters}    ${epoch_time}    300
    #Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} == 0)
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} == 0)
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    log  packets were successfully sent and counter's burst works properly  console=yes
    log  waiting for new interval start to test counter's packets per second value  console=yes
    Wait For New Interval Start  M51328C19
    Start Tcpdump For M51328C19 Counter
    ${scapy_status}=  Send Packets For M51328C19 Counter To BTS  ${mac_address_for_m_plane}  ${M51328C19_PPS}
    ...   ${M51328C19_PACKETS}  ${Test_PC_interface}
    Kill Tcpdump For M51328C19 Counter
    ${number_of_packets}=  Get Number Of Packets After Packets Flood For M51328C19
    Should Be True  ${number_of_packets} > (${M51328C19_PACKETS_LIMIT} * ${M51328C19_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C19_PACKETS_LIMIT} * ${M51328C19_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C19
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C19
    #${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C19
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C19
    ${epoch_time}=    Convert Time To Epoch    ${WebEm_counter_time}
    #${counter_NetAct_value_after}=  Get First Counter From NetAct    ipRmDropPcktsRtLimEap    65
    ${webem_counters}=    Get Counters from WebEM    M51328C19
    ${counter_WebEm_value_after}=    Get Correct Counter Value by Epoch Time    ${webem_counters}    ${epoch_time}    300
    #Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C19_SHOULD_BE_COLLECTED} -
    ...  ${M51328C19_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C19_SHOULD_BE_COLLECTED} + ${M51328C19_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C19_SHOULD_BE_COLLECTED} -
    ...  ${M51328C19_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C19_SHOULD_BE_COLLECTED} + ${M51328C19_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after}
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    log  packets were successfully collected in M51328C19 transport counter  console=yes
    Deintegrate BTS from MantaRay    ${LAB_NAME}
    Turn On TLS

CB009482-B_TC_04_CNUM_Syslog_RTPM_Servers_Report_TLS_failure_with_an_Additional_Text_Field
    Log    Step 1: Clearing certificate before connecting to Mantaray    console=True
    Clear Certificates
    ${NMS_LAB}    Integrate BTS to MantaRay with TLS   PREFERRED_LAB=srnclab1047
    Log    Step 2: Activate CNUM user   console=True
    Activate CNUM user    ${NMS_LAB}
    Log    Step 3: Disabling syslog and RTPM transmission   console=True
    Start Syslog and RTPM Transmission    false    false
    Log    Step 4: Adding structures (remoteSyslogConfig, rTPmCollEntity, nrRTPMMeasurementsList)    console=True
    Add remoteSyslogConfig and rTPmCollEntity and nrRTPMMeasurementsList Structures To SCF
       ...                                    list_elements=&{PARAMS_SYSLOG}
       ...                                    nrRTPMMeasurementsList_elements=@{PARAMS_RTPM_2}
       ...                                    rTPmCollEntity_elements=&{PARAMS_RTPM}
    Wait Until Keyword Succeeds  20m  30s    Wait until BTS reach state   state=OnAir
    Change Parameter on BTS             MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                 certTypeForTlsAuth
    ...                                 ECDSA
    Change Parameter on BTS             MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...                                 userAuthentication
    ...                                 disabled
    Change Parameter on BTS             MRBTS-${BTS_ID}/MNL-1/AMGR-1
    ...                                 actCnumLdapClientAcctSup
    ...                                 false
    Wait Until Keyword Succeeds    5x    1min    Wait until BTS reach state   state=OnAir
    Log    Step 5: Change the enableCnumLdapCtrlAlarm parameter to see CNUM alarm    console=true
    Change Parameter on BTS         MRBTS-${BTS_ID}/MNL-1/AMGR-1
    ...                             enableCnumLdapCtrlAlarm
    ...                             true
    Log    Step 6: Setting all correct RSA and ECDSA settings to initialize certificates    console=true
    Settings Certificates for Syslog and RTPM    ca_ECDSA=${ECDSA_SUBJECT_NAME_9482}    ca_RSA=${RSA_SUBJECT_NAME_9482}
    Log    Step 7: Starting collecting PCAP file    console=True
    Start TCPDump
    Log    Step 8: Enable syslog and rtpm server and login as CNUM user    console=true
    Start Syslog and RTPM Transmission    true    false
    Sleep    15s    reason=Wait until parameter was changed and connection could be established
    Connect to ADMIN    username=omc    password=Medsql!_1893    alias=cnum
    Disconnect from ADMIN    connection=cnum
    Log    Step 9: Collect PCAP and disable syslog and rtpm    console=True
    Stop TCPDump And Download PCAP     tcpdump_filename=syslog.pcap
    Log    Step 10: Checking if any unallowed alarm was not visible on BTS    console=True
    Add Alarm To Allowed Alarms    61074    CRL Update failure or certificate revoked
    Wait Until Keyword Succeeds  20m  30s   No Faults Except Allowed Should Be Present On BTS
    Add Multiple Alarms to Watchdog List    4752    4203    4776    4590
    &{results}    mantaray.Get Active Alarms From BTS via MantaRay    ${NMS_LAB}
    Log    ${results}
    No Faults Except Allowed Should Be Present On BTS    active_faults=${results}
    Start Syslog and RTPM Transmission    false    false
    Log    Step 11: Checking if handshake is visible (syslog, RTPM and MantaRay)    console=True
    ${SYSLOG_IP}    Get From Dictionary    ${PARAMS_SYSLOG}    remoteSyslogServerHost
#    ${RTPM_IP}      Get From Dictionary    ${PARAMS_RTPM}      rTPmCollEntityHost
    ${NETACT_IP1}  Get IP From MantaRay  ${NMS_LAB}   LBJBI_IP
    ${NETACT_IP2}  Get IP From MantaRay  ${NMS_LAB}   LBWAS_IP
    PCAP Should Contain Message    tshark_filter=tls.record.content_type == 22 && ip.addr==${SYSLOG_IP} && ip.addr==${MPLANE_IPV4}
    ...                            pcap_file=${OUTPUT DIR}/${TEST NAME}/syslog.pcap
#    PCAP Should Contain Message    tshark_filter=tls.record.content_type == 22 && ip.addr==${RTPM_IP} && ip.addr==${MPLANE_IPV4}
#    ...                            pcap_file=${OUTPUT DIR}/${TEST NAME}/syslog.pcap
    PCAP Should Contain Message    tshark_filter=tls.record.content_type == 22 && ip.addr==${NETACT_IP1} && ip.addr==${MPLANE_IPV4}
    ...                            pcap_file=${OUTPUT DIR}/${TEST NAME}/syslog.pcap
    PCAP Should Contain Message    tshark_filter=tls.record.content_type == 22 && ip.addr==${NETACT_IP2} && ip.addr==${MPLANE_IPV4}
    ...                            pcap_file=${OUTPUT DIR}/${TEST NAME}/syslog.pcap
    Log    Step 12: Setting ECDSA and RSA to wrong settings    console=True
    Clear Certificates
    Settings Certificates for Syslog and RTPM    ca_ECDSA=CN=CB005999_test    ca_RSA=CN=CB007672
    Log    Step 13: Starting PCAP and enable syslog, rtpm    console=true
    Start TCPDump
    Sleep                               15
    ...                                 reason=Wait until tcpdump starts properly
    Log    Step 14: Enabling syslog and RTPM transmission
    Start Syslog and RTPM Transmission    true    true
    Sleep    15s
    Run Keyword and Return Status    Connect to ADMIN    username=omc    password=Medsql!_1893    alias=cnum
    Stop TCPDump And Download PCAP     tcpdump_filename=syslog1.pcap
    Log    Step 15: Check if PCAP contains error (syslog, RTPM and MantaRay)    console=True
    ${syslog_filters}=     Catenate    ip.addr == ${MPLANE_IPV4}  and ip.addr == ${SYSLOG_IP} and tls.record.content_type == 21
    ${syslog_err}=    Run    tshark -r ${OUTPUT DIR}/${TEST NAME}/syslog1.pcap -Y "${syslog_filters}"
    Should Contain         ${syslog_err}    Level: Fatal
    Should Contain         ${syslog_err}    Unknown CA
#    ${syslog_filters}=     Catenate    ip.addr == ${MPLANE_IPV4}  and ip.addr == ${RTPM_IP} and tls.record.content_type == 21
#    ${syslog_err}=    Run    tshark -r ${OUTPUT DIR}/${TEST NAME}/syslog1.pcap -Y "${syslog_filters}"
#    Should Contain         ${syslog_err}    Level: Fatal
#    Should Contain         ${syslog_err}    Unknown CA
    ${syslog_filters}=     Catenate    ip.addr == ${MPLANE_IPV4}  and ip.addr == ${NETACT_IP1} and tls.record.content_type == 21
    ${syslog_err}=    Run    tshark -r ${OUTPUT DIR}/${TEST NAME}/syslog1.pcap -Y "${syslog_filters}"
    Should Contain         ${syslog_err}    Level: Fatal
    Should Contain         ${syslog_err}    Unknown CA
    ${syslog_filters}=     Catenate    ip.addr == ${MPLANE_IPV4}  and ip.addr == ${NETACT_IP2} and tls.record.content_type == 21
    ${syslog_err}=    Run    tshark -r ${OUTPUT DIR}/${TEST NAME}/syslog1.pcap -Y "${syslog_filters}"
    Should Contain         ${syslog_err}    Level: Fatal
    Should Contain         ${syslog_err}    Unknown CA
    Log    Step 16: Check supplAlarmInfo if contains proper error messages    console=True
    ${response_list}    Get Alarms with suplinfo
    Get Supplementary Alarm Information    ${response_list}
    Log    Step 17: Reset site and wait until BTS is onAir    console=True
    Reset Site And Reconnect
    Wait Until Keyword Succeeds  20m  30s   Wait until BTS reach state   state=OnAir
    ${response_list}    Get Alarms with suplinfo
    Get Supplementary Alarm Information    ${response_list}
    Log    Step 18: Power off and power on SMOD on PDU    console=True
    Turn Off SMOD on PDU
    Wait Until Keyword Succeeds  20m  30s    Wait until BTS reach state   state=OnAir
    ${response_list}    Get Alarms with suplinfo
    Get Supplementary Alarm Information    ${response_list}
    Log    Step 19: Setting ECDSA and RSA to correct settings    console=True
    Start Syslog and RTPM Transmission    false    false
    Clear Certificates
    Setup Mantaray
    Settings Certificates for Syslog and RTPM    ca_ECDSA=${ECDSA_SUBJECT_NAME_9482}    ca_RSA=${RSA_SUBJECT_NAME_9482}
    Log    Step 20: Starting PCAP and enabling syslog and rtpm and login as CNUM user    console=True
    Start TCPDump
    Start Syslog and RTPM Transmission    true    false
    Sleep    15s
    Connect to ADMIN    username=omc    password=Medsql!_1893    alias=cnum
    Disconnect from ADMIN    connection=cnum
    Sleep                               30
    ...                                 reason=Wait until tcpdump starts properly
    Stop TCPDump And Download PCAP     tcpdump_filename=syslog3.pcap
    Log    Step 21: Check if no any additional alarm is visible on BTS    console=True
    Wait Until Keyword Succeeds  20m  30s   No Faults Except Allowed Should Be Present On BTS
    &{results}    mantaray.Get Active Alarms From BTS via MantaRay    ${NMS_LAB}
    No Faults Except Allowed Should Be Present On BTS    active_faults=${results}
    Start Syslog and RTPM Transmission    false    false
    Log    Step 22: Check if PCAP contains handshake (syslog, RTPM and MantaRay)    console=True
    PCAP Should Contain Message    tshark_filter=tls.record.content_type == 22 && ip.addr==${SYSLOG_IP} && ip.addr==${MPLANE_IPV4}
    ...                            pcap_file=${OUTPUT DIR}/${TEST NAME}/syslog3.pcap
#    PCAP Should Contain Message    tshark_filter=tls.record.content_type == 22 && ip.addr==${RTPM_IP} && ip.addr==${MPLANE_IPV4}
#    ...                            pcap_file=${OUTPUT DIR}/${TEST NAME}/syslog3.pcap
    PCAP Should Contain Message    tshark_filter=tls.record.content_type == 22 && ip.addr==${NETACT_IP1} && ip.addr==${MPLANE_IPV4}
    ...                            pcap_file=${OUTPUT DIR}/${TEST NAME}/syslog3.pcap
    PCAP Should Contain Message    tshark_filter=tls.record.content_type == 22 && ip.addr==${NETACT_IP2} && ip.addr==${MPLANE_IPV4}
    ...                            pcap_file=${OUTPUT DIR}/${TEST NAME}/syslog3.pcap
    [Teardown]    Run Keywords
    ...           Change Parameter on BTS   MRBTS-${BTS_ID}/MNL-1/AMGR-1  enableCnumLdapCtrlAlarm  false
    ...           AND    Clear Certificates
    ...           AND    Start Syslog and RTPM Transmission    false    false
    ...           AND    Run Keyword and Ignore Error    Deintegrate BTS from MantaRay    ${NMS_LAB}
    ...           AND    Remove Multiple Alarms from Watchdog List    4752    4203    4776    4590


