*** Settings ***
Documentation      Keywords for CB007672 feature

Resource           ../../../common_resources/admin/admin.robot
Resource           ../../../common_resources/netact/netact_operations.robot
Resource           ../../../common_resources/commissioning/commissioning.robot
Library            taf.sbts.oam.coam.admin    WITH NAME    coam_admin
Library            ./resources.py    WITH NAME    main_resource
Library            XML   True

*** Variables ***
# ipRmDropPcktsRtLimICMP [M51328C15] test settings
${M51328C15_BURST}=                               32
${M51328C15_LIMIT}=                               1000
${M51328C15_INCREASE_PERCENT}=                    0.10
${M51328C15_PPS}=                                 ${M51328C15_LIMIT} + (${M51328C15_LIMIT} * ${M51328C15_INCREASE_PERCENT})
${M51328C15_LOOP}=                                10
${M51328C15_PACKETS}=                             ${M51328C15_LOOP} * (${M51328C15_PPS})
${M51328C15_TCPDUMP_STATISTICAL_ERROR}=           0.25
${M51328C15_TCPDUMP_STATISTICAL_ERROR_MORE}=      (1 + ${M51328C15_TCPDUMP_STATISTICAL_ERROR})
${M51328C15_TCPDUMP_STATISTICAL_ERROR_LESS}=      (1 - ${M51328C15_TCPDUMP_STATISTICAL_ERROR})
${M51328C15_SHOULD_BE_COLLECTED}=                 ${M51328C15_PACKETS} - (${M51328C15_LIMIT} * ${M51328C15_LOOP}) - ${M51328C15_BURST}
${M51328C15_TEST_STATISTICAL_ERROR}=              (${M51328C15_LOOP} * (${M51328C15_PPS})) / 10
# ipRmDropPcktsRtLim5GCplane [M51328C14] test settings
${M51328C14_BURST}=                               544
${M51328C14_BURST_SECOND_FOR_ASIL}=               80
${M51328C14_LIMIT}=                               11000
${M51328C14_INCREASE_PERCENT}=                    0.182
${M51328C14_PPS}=                                 ${M51328C14_LIMIT} + (${M51328C14_LIMIT} * ${M51328C14_INCREASE_PERCENT})
${M51328C14_LOOP}=                                10
${M51328C14_PACKETS}=                             ${M51328C14_LOOP} * (${M51328C14_PPS})
${M51328C14_TCPDUMP_STATISTICAL_ERROR}=           0.35
${M51328C14_TCPDUMP_STATISTICAL_ERROR_MORE}=      (1 + ${M51328C14_TCPDUMP_STATISTICAL_ERROR})
${M51328C14_TCPDUMP_STATISTICAL_ERROR_LESS}=      (1 - ${M51328C14_TCPDUMP_STATISTICAL_ERROR})
${M51328C14_SHOULD_BE_COLLECTED}=                 ${M51328C14_PACKETS} - (${M51328C14_LIMIT} * ${M51328C14_LOOP}) - ${M51328C14_BURST}
${M51328C14_TEST_STATISTICAL_ERROR}=              (${M51328C14_LOOP} * (${M51328C14_PPS})) / 10
# ipRmDropPcktsRtLimDefault [M51328C12] test settings
${M51328C12_BURST}=                               32
${M51328C12_LIMIT}=                               2000
${M51328C12_INCREASE_PERCENT}=                    0.10
${M51328C12_PPS}=                                 ${M51328C12_LIMIT} + (${M51328C12_LIMIT} * ${M51328C12_INCREASE_PERCENT})
${M51328C12_LOOP}=                                10
${M51328C12_PACKETS}=                             ${M51328C12_LOOP} * (${M51328C12_PPS})
${M51328C12_TCPDUMP_STATISTICAL_ERROR}=           0.25
${M51328C12_TCPDUMP_STATISTICAL_ERROR_MORE}=      (1 + ${M51328C12_TCPDUMP_STATISTICAL_ERROR})
${M51328C12_TCPDUMP_STATISTICAL_ERROR_LESS}=      (1 - ${M51328C12_TCPDUMP_STATISTICAL_ERROR})
${M51328C12_SHOULD_BE_COLLECTED}=                 ${M51328C12_PACKETS} - (${M51328C12_LIMIT} * ${M51328C12_LOOP}) - ${M51328C12_BURST}
${M51328C12_TEST_STATISTICAL_ERROR}=              (${M51328C12_LOOP} * (${M51328C12_PPS})) / 10
# ipRmDropPcktsRtLimMplane [M51328C18] test settings
${M51328C18_BURST}=                               300
${M51328C18_LIMIT}=                               4000
${M51328C18_INCREASE_PERCENT}=                    0.10
${M51328C18_PPS}=                                 ${M51328C18_LIMIT} + (${M51328C18_LIMIT} * ${M51328C18_INCREASE_PERCENT})
${M51328C18_LOOP}=                                10
${M51328C18_PACKETS}=                             ${M51328C18_LOOP} * (${M51328C18_PPS})
${M51328C18_TCPDUMP_STATISTICAL_ERROR}=           0.25
${M51328C18_TCPDUMP_STATISTICAL_ERROR_MORE}=      (1 + ${M51328C18_TCPDUMP_STATISTICAL_ERROR})
${M51328C18_TCPDUMP_STATISTICAL_ERROR_LESS}=      (1 - ${M51328C18_TCPDUMP_STATISTICAL_ERROR})
${M51328C18_SHOULD_BE_COLLECTED}=                 ${M51328C18_PACKETS} - (${M51328C18_LIMIT} * ${M51328C18_LOOP}) - ${M51328C18_BURST}
${M51328C18_TEST_STATISTICAL_ERROR}=              (${M51328C18_LOOP} * (${M51328C18_PPS})) / 10
# ipRmDropPcktsRtLimSplane [M51328C8] test settings
${M51328C8_BURST}=                                5
${M51328C8_LIMIT}=                                512
${M51328C8_INCREASE_PERCENT}=                     0.171875
${M51328C8_PPS}=                                  ${M51328C8_LIMIT} + (${M51328C8_LIMIT} * ${M51328C8_INCREASE_PERCENT})
${M51328C8_LOOP}=                                 10
${M51328C8_PACKETS}=                              ${M51328C8_LOOP} * (${M51328C8_PPS})
${M51328C8_TCPDUMP_STATISTICAL_ERROR}=            0.25
${M51328C8_TCPDUMP_STATISTICAL_ERROR_MORE}=       (1 + ${M51328C8_TCPDUMP_STATISTICAL_ERROR})
${M51328C8_TCPDUMP_STATISTICAL_ERROR_LESS}=       (1 - ${M51328C8_TCPDUMP_STATISTICAL_ERROR})
${M51328C8_SHOULD_BE_COLLECTED}=                  ${M51328C8_PACKETS} - (${M51328C8_LIMIT} * ${M51328C8_LOOP}) - ${M51328C8_BURST}
${M51328C8_TEST_STATISTICAL_ERROR}=               (${M51328C8_LOOP} * (${M51328C8_PPS})) / 10
# ipRmDropPcktsRtLimTwamp [M51328C7] test settings
${M51328C7_BURST}=                                100
${M51328C7_LIMIT}=                                2000
${M51328C7_INCREASE_PERCENT}=                     0.10
${M51328C7_PPS}=                                  ${M51328C7_LIMIT} + (${M51328C7_LIMIT} * ${M51328C7_INCREASE_PERCENT})
${M51328C7_LOOP}=                                 10
${M51328C7_NUMBER_OF_SCAPY_RUNS}=                 2
${M51328C7_PACKETS}=                              ${M51328C7_LOOP} * (${M51328C7_PPS})
${M51328C7_TCPDUMP_STATISTICAL_ERROR}=            0.25
${M51328C7_TCPDUMP_STATISTICAL_ERROR_MORE}=       (1 + ${M51328C7_TCPDUMP_STATISTICAL_ERROR})
${M51328C7_TCPDUMP_STATISTICAL_ERROR_LESS}=       (1 - ${M51328C7_TCPDUMP_STATISTICAL_ERROR})
${M51328C7_SHOULD_BE_COLLECTED}=                  SEPARATOR=
...  ${M51328C7_NUMBER_OF_SCAPY_RUNS} * (${M51328C7_PACKETS} - (${M51328C7_LIMIT} * ${M51328C7_LOOP}) - ${M51328C7_BURST})
${M51328C7_TEST_STATISTICAL_ERROR}=               (${M51328C7_LOOP} * (${M51328C7_PPS})) / 10

@{BRANCHES_WITH_OLD_COUNTERS}       SBTS23R3    SBTS23R4   SBTS24R1

*** Keywords ***
Get Rejected Packets Interval and Reporting Interval parameters value
    ${connection}=  Connect to ADMIN
    ${correct_ipFilteringInterval_dist}=  Set Variable   MRBTS-${BTS_ID}/TNLSVC-1/PMTNLINT-1
    ${param_name_ipFilteringInterval}=    Set Variable   ipFilteringInterval
    ${xpath_ipFilteringInterval}=  Catenate  cmData/managedObject[@distName="${correct_ipFilteringInterval_dist}"]/
    ...  p[@name="${param_name_ipFilteringInterval}"]

    ${correct_reportingIntervalPm_dist}=  Set Variable   MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    ${param_name_reportingIntervalPm}=    Set Variable   reportingIntervalPm
    ${xpath_reportingIntervalPm}=  Catenate  cmData/managedObject[@distName="${correct_reportingIntervalPm_dist}"]/
    ...  p[@name="${param_name_reportingIntervalPm}"]

    ${scf_xml}=  coam_admin.get_scf   connection=${connection}   timeout=${600}
    Log  Getting ipFilteringInterval and reportingIntervalPm parameters value  console=True
    ${value_ipFilteringInterval}=  XML.Get Element Text   ${scf_xml}   xpath=${xpath_ipFilteringInterval}
    ${value_reportingIntervalPm}=  XML.Get Element Text   ${scf_xml}   xpath=${xpath_reportingIntervalPm}

    Disconnect from ADMIN  ${connection}
    [Return]  ${value_ipFilteringInterval}  ${value_reportingIntervalPm}

Change Rejected Packets Interval To 5min
    ${connection}=  Connect to ADMIN
    ${correct_dist}=  Set Variable      MRBTS-${BTS_ID}/TNLSVC-1/PMTNLINT-1
    change parameter on bts             dist_name=${correct_dist}
    ...                                 param_name=ipFilteringInterval
    ...                                 param_value=5min
    ...                                 skip_parameter_relation_errors=${FALSE}
    ...                                 connection=${connection}
    [Teardown]  Disconnect from ADMIN   ${connection}

Change Reporting Interval To 5min
    ${connection}=  Connect to ADMIN
    ${correct_dist}=  Set Variable      MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    change parameter on bts             dist_name=${correct_dist}
    ...                                 param_name=reportingIntervalPm
    ...                                 param_value=5min
    ...                                 skip_parameter_relation_errors=${FALSE}
    ...                                 connection=${connection}
    [Teardown]  Disconnect from ADMIN   ${connection}

Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
    ${value_ipFilteringInterval}  ${value_reportingIntervalPm}  Get Rejected Packets Interval and Reporting Interval parameters value
    Run Keyword If  '${value_ipFilteringInterval}' != '5min' or '${value_reportingIntervalPm}' != '5min'
    ...   Run Keywords
    ...   Log  Changing ipFilteringInterval and reportingIntervalPm parameters value and waiting 5 minutes to refresh counters  console=True
    ...   AND   counters_keywords.Change Rejected Packets Interval To 5min
    ...   AND   counters_keywords.Change Reporting Interval To 5min
    ...   AND   Sleep  300  reason=start new counters interval

Check If There Are Any Transport Counter Issues And Reboot BTS If Neened
    [Arguments]  ${counter_name}
    Get Counter Value From WebEm  ${counter_name}
    [Teardown]  Reboot BTS If There Are A Transport Counter Issues

Reboot BTS If There Are A Transport Counter Issues
    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Reboot BTS and wait until available

Wait Until Transport Counters Available After Reboot
    [Arguments]  ${counter_name}
    ${TRANSPORT_COUNTERS_PATH}=         Set Variable    TRS/TNL-1/IPNO/IPNO-1/IP_filtering_Stats/
    ${TRANSPORT_COUNTERS_PATH_NEW}=     Set Variable    TRS/MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IP_filtering_Stats/
    ${TRANSPORT_COUNTERS_PATH_NE3S}=    Set Variable     MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    ${INSTALLED_SW_BRANCH}=   admin.Get Software Release Name
    Run Keyword If    "${INSTALLED_SW_BRANCH}" in ${BRANCHES_WITH_OLD_COUNTERS}    Set Global Variable   ${status}    0
    ...         ELSE    Set Global Variable   ${status}    1
    Run Keyword If    '${status}'=='0'    Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}    ${TRANSPORT_COUNTERS_PATH}
    ...         ELSE    Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}   ${TRANSPORT_COUNTERS_PATH_NEW}
    Wait Until Keyword Succeeds  15 min  1 min  get_dropped_packets_counter_value  ${TRANSPORT_COUNTERS_PATHS}
    ...                                         ${counter_name}  ${SSH_IP}  ${WEBEM_PASSWORD}

Get Counter Time From WebEm
    [Arguments]  ${counter_name}
    ${INSTALLED_SW_BRANCH}=   admin.Get Software Release Name
    ${TRANSPORT_COUNTERS_PATH}=         Set Variable    TRS/TNL-1/IPNO/IPNO-1/IP_filtering_Stats/
    ${TRANSPORT_COUNTERS_PATH_NEW}=     Set Variable    TRS/MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IP_filtering_Stats/
    ${TRANSPORT_COUNTERS_PATH_NE3S}=    Set Variable     MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    Run Keyword If    "${INSTALLED_SW_BRANCH}" in ${BRANCHES_WITH_OLD_COUNTERS}    Set Global Variable   ${status}    0
    ...         ELSE    Set Global Variable   ${status}    1
    Run Keyword If    '${status}'=='0'    Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}    ${TRANSPORT_COUNTERS_PATH}
    ...         ELSE    Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}   ${TRANSPORT_COUNTERS_PATH_NEW}
    ${counter_time}=   get_dropped_packets_counter_time  ${TRANSPORT_COUNTERS_PATHS}  ${counter_name}  ${SSH_IP}  ${WEBEM_PASSWORD}
    [Return]  ${counter_time}

Get Counter Value From WebEm
    [Arguments]  ${counter_name}
    ${INSTALLED_SW_BRANCH}=   admin.Get Software Release Name
    ${TRANSPORT_COUNTERS_PATH}=         Set Variable    TRS/TNL-1/IPNO/IPNO-1/IP_filtering_Stats/
    ${TRANSPORT_COUNTERS_PATH_NEW}=     Set Variable    TRS/MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IP_filtering_Stats/
    ${TRANSPORT_COUNTERS_PATH_NE3S}=    Set Variable     MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    Run Keyword If    "${INSTALLED_SW_BRANCH}" in ${BRANCHES_WITH_OLD_COUNTERS}    Set Global Variable   ${status}    0
    ...         ELSE    Set Global Variable   ${status}    1
    Run Keyword If    '${status}'=='0'    Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}    ${TRANSPORT_COUNTERS_PATH}
    ...         ELSE    Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}   ${TRANSPORT_COUNTERS_PATH_NEW}
    ${counter_value}=  get_dropped_packets_counter_value  ${TRANSPORT_COUNTERS_PATHS}  ${counter_name}  ${SSH_IP}  ${WEBEM_PASSWORD}
    [Return]  ${counter_value}

Compare Counter Values
    [Arguments]  ${start_value}  ${counter_name}
    ${INSTALLED_SW_BRANCH}=   admin.Get Software Release Name
    ${TRANSPORT_COUNTERS_PATH}=         Set Variable    TRS/TNL-1/IPNO/IPNO-1/IP_filtering_Stats/
    ${TRANSPORT_COUNTERS_PATH_NEW}=     Set Variable    TRS/MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IP_filtering_Stats/
    ${TRANSPORT_COUNTERS_PATH_NE3S}=    Set Variable     MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    Run Keyword If    "${INSTALLED_SW_BRANCH}" in ${BRANCHES_WITH_OLD_COUNTERS}    Set Global Variable   ${status}    0
    ...         ELSE    Set Global Variable   ${status}    1
    Run Keyword If    '${status}'=='0'    Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}    ${TRANSPORT_COUNTERS_PATH}
    ...         ELSE    Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}   ${TRANSPORT_COUNTERS_PATH_NEW}
    ${value}=   get_dropped_packets_counter_time  ${TRANSPORT_COUNTERS_PATHS}  ${counter_name}  ${SSH_IP}  ${WEBEM_PASSWORD}
    log to console  waiting for new ipFilteringInterval start, previous time is ${value}
    should not be equal  ${start_value}  ${value}

Wait For New Interval Start
    [Arguments]  ${counter_name}
    ${INSTALLED_SW_BRANCH}=   admin.Get Software Release Name
    ${TRANSPORT_COUNTERS_PATH}=         Set Variable    TRS/TNL-1/IPNO/IPNO-1/IP_filtering_Stats/
    ${TRANSPORT_COUNTERS_PATH_NEW}=     Set Variable    TRS/MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IP_filtering_Stats/
    ${TRANSPORT_COUNTERS_PATH_NE3S}=    Set Variable     MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    Run Keyword If    "${INSTALLED_SW_BRANCH}" in ${BRANCHES_WITH_OLD_COUNTERS}    Set Global Variable   ${status}    0
    ...         ELSE    Set Global Variable   ${status}    1
    Run Keyword If    '${status}'=='0'    Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}    ${TRANSPORT_COUNTERS_PATH}
    ...         ELSE    Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}   ${TRANSPORT_COUNTERS_PATH_NEW}
    ${start_value}=   get_dropped_packets_counter_time  ${TRANSPORT_COUNTERS_PATHS}  ${counter_name}  ${SSH_IP}  ${WEBEM_PASSWORD}
    wait until keyword succeeds     10min
    ...                             20s
    ...                             Compare Counter Values  ${start_value}  ${counter_name}

Get Counter Value From BTS Via SSH For ASIL For Certain Counter
    [Arguments]  ${rule_number}
    ssh.connect to    ${SSH_IP}    ${OAM_USERNAME}    ${OAM_PASSWORD}    alias=conn_bts_counter_asil
    ${command}=  Catenate  /opt/trs/bin/vtc l4clfr rl_ctr | grep -w '${rule_number}' | awk '{print $NF}'
    ${counter_value}=  ssh.execute  ${command}  connection=conn_bts_counter_asil
    ssh.disconnect  connection=conn_bts_counter_asil
    [Return]  ${counter_value}

Get Counter Value From BTS Via SSH For ASIB For Certain Counter
    [Arguments]  ${rule_number}
    ssh.connect to    ${SSH_IP}    ${OAM_USERNAME}    ${OAM_PASSWORD}    alias=conn_bts_counter_asib
    ${command}=  Catenate  /opt/trs/bin/vtc l4clfr rl_counter_showall | grep -E -w 'RL Index: \+${rule_number}' | awk '{print $7}'
    ${counter_value}=  ssh.execute  ${command}  connection=conn_bts_counter_asib
    ssh.disconnect  connection=conn_bts_counter_asib
    [Return]  ${counter_value}

Get Counter Value From BTS Via SSH For ASIK For Certain Counter
    [Arguments]  ${rule_number}
    ssh.connect to    ${SSH_IP}    ${OAM_USERNAME}    ${OAM_PASSWORD}    alias=conn_bts_counter_asik
    ${command}=  Catenate  /opt/trs/bin/trs-vppctl show pps-policer counters | awk '{if ($1 == "${rule_number}") print $2}'
    ${counter_value}=  ssh.execute  ${command}  connection=conn_bts_counter_asik
    ssh.disconnect  connection=conn_bts_counter_asik
    ${counter_value_stripped}=  Strip String  ${counter_value}
    ${counter_value}=  Set Variable If  "${counter_value_stripped}" == "${EMPTY}"  0  ${counter_value_stripped}
    [Return]  ${counter_value}

Get ASIB Or ASIL PPS Number For Certain Counter
    [Arguments]  ${rule_number}
    ssh.connect to    ${SSH_IP}    ${OAM_USERNAME}    ${OAM_PASSWORD}    alias=conn_asib_pps
    ${command}=  Catenate  /opt/trs/bin/vtc iprl show | grep -w "${rule_number} pr" | awk '{print $3}'
    ${pps_number}=  ssh.execute  ${command}  connection=conn_asib_pps
    ssh.disconnect  connection=conn_asib_pps
    ${pps_number_stripped}=  Strip String  ${pps_number}
    [Return]  ${pps_number_stripped}

Get ASIB Or ASIL Burst Number For Certain Counter
    [Arguments]  ${rule_number}
    ssh.connect to    ${SSH_IP}    ${OAM_USERNAME}    ${OAM_PASSWORD}    alias=conn_asib_burst
    ${command}=  Catenate  /opt/trs/bin/vtc iprl show | grep -w "${rule_number} pr" | awk '{print $5}'
    ${burst_number}=  ssh.execute  ${command}  connection=conn_asib_burst
    ssh.disconnect  connection=conn_asib_burst
    ${burst_number_stripped}=  Strip String  ${burst_number}
    [Return]  ${burst_number_stripped}

Get ASIK PPS Number For Certain Counter
    [Arguments]  ${rule_number}
    ssh.connect to    ${SSH_IP}    ${OAM_USERNAME}    ${OAM_PASSWORD}    alias=conn_asib_pps
    ${command}=  Catenate  /opt/trs/bin/trs-vppctl show pps-policer | grep -w "policy-${rule_number}" | awk '{print $9}'
    ${pps_number}=  ssh.execute  ${command}  connection=conn_asib_pps
    ssh.disconnect  connection=conn_asib_pps
    ${pps_number_stripped}=  Strip String  ${pps_number}
    [Return]  ${pps_number_stripped}

Get ASIK Burst Number For Certain Counter
    [Arguments]  ${rule_number}
    ssh.connect to    ${SSH_IP}    ${OAM_USERNAME}    ${OAM_PASSWORD}    alias=conn_asib_burst
    ${command}=  Catenate  /opt/trs/bin/trs-vppctl show pps-policer | grep -w "policy-${rule_number}" | awk '{print $13}'
    ${burst_number}=  ssh.execute  ${command}  connection=conn_asib_burst
    ssh.disconnect  connection=conn_asib_burst
    ${burst_number_stripped}=  Strip String  ${burst_number}
    [Return]  ${burst_number_stripped}

Start Tcpdump For M51328C15 Counter
    ssh.connect to    ${SSH_IP}    ${OAM_USERNAME}    ${OAM_PASSWORD}    alias=conn_m51328c15_tcpdump
    ${m_plane_interface}=  ssh.execute  ip a | grep ${MPLANE_IPV4} | awk '{print $7}'  connection=conn_m51328c15_tcpdump
    ${m_plane_interface_stripped}=  Strip String  ${m_plane_interface}
    ${start_command}=  Catenate  tcpdump -i ${m_plane_interface_stripped} icmp -w 7672-A.cap
    ${tcpdump_pid}=  ssh.send command  ${start_command}  connection=conn_m51328c15_tcpdump

Start Tcpdump For M51328C15 Counter IPv6
    ssh.connect to    ${SSH_IP}    ${OAM_USERNAME}    ${OAM_PASSWORD}    alias=conn_m51328c15_tcpdump
    ${m_plane_interface}=  ssh.execute  ip a | grep ${MPLANE_IPV4} | awk '{print $7}'  connection=conn_m51328c15_tcpdump
    ${m_plane_interface_stripped}=  Strip String  ${m_plane_interface}
    ${start_command}=  Catenate  tcpdump -i ${m_plane_interface_stripped} icmp6 -w 7672-A.cap
    ${tcpdump_pid}=  ssh.send command  ${start_command}  connection=conn_m51328c15_tcpdump

Kill Tcpdump For M51328C15 Counter
    ${tcpdump_pid_command}=  Catenate  ps aux | grep 'icmp -w 7672-A.cap' | grep -wv 'grep' | awk '{print $2}'
    ${tcpdump_pid}=  ssh.execute  ${tcpdump_pid_command}  connection=conn_m51328c15_tcpdump
    ${tcpdump_pid_stripped}=  Strip String  ${tcpdump_pid}
    ${kill_comand}=  Catenate  kill -9 ${tcpdump_pid_stripped}
    ssh.execute  ${kill_comand}  connection=conn_m51328c15_tcpdump
    ssh.disconnect  connection=conn_m51328c15_tcpdump

Start Tcpdump For M51328C14 Counter
    ssh.connect to    ${SSH_IP}    ${OAM_USERNAME}    ${OAM_PASSWORD}    alias=conn_m51328c14_tcpdump
    ${c_plane_interface}=  ssh.execute  ip a | grep ${XNC} | awk '{print $7}'  connection=conn_m51328c14_tcpdump
    ${c_plane_interface_stripped}=  Strip String  ${c_plane_interface}
    ${start_command}=  Catenate  tcpdump -i ${c_plane_interface_stripped} sctp -w 7672-A.cap
    ${tcpdump_pid}=  ssh.send command  ${start_command}  connection=conn_m51328c14_tcpdump

Kill Tcpdump For M51328C14 Counter
    ${tcpdump_pid_command}=  Catenate  ps aux | grep 'sctp -w 7672-A.cap' | grep -wv 'grep' | awk '{print $2}'
    ${tcpdump_pid}=  ssh.execute  ${tcpdump_pid_command}  connection=conn_m51328c14_tcpdump
    ${tcpdump_pid_stripped}=  Strip String  ${tcpdump_pid}
    ${kill_comand}=  Catenate  kill -9 ${tcpdump_pid_stripped}
    ssh.execute  ${kill_comand}  connection=conn_m51328c14_tcpdump
    ssh.disconnect  connection=conn_m51328c14_tcpdump

Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    ssh.connect to    ${SSH_IP}    ${SSH_USERNAME}    ${SSH_PASSWORD}    alias=conn_m51328c18_12_7_tcpdump
    ${m_plane_interface}=  ssh.execute  ip a | grep ${MPLANE_IPV4} | awk '{print $7}'  connection=conn_m51328c18_12_7_tcpdump
    ${m_plane_interface_stripped}=  Strip String  ${m_plane_interface}
    ${start_command}=  Catenate  tcpdump -i ${m_plane_interface_stripped} udp -w 7672-A.cap
    ${tcpdump_pid}=  ssh.send command  ${start_command}  connection=conn_m51328c18_12_7_tcpdump

Kill Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    ${tcpdump_pid_command}=  Catenate  ps aux | grep 'udp -w 7672-A.cap' | grep -wv 'grep' | awk '{print $2}'
    ${tcpdump_pid}=  ssh.execute  ${tcpdump_pid_command}  connection=conn_m51328c18_12_7_tcpdump
    ${tcpdump_pid_stripped}=  Strip String  ${tcpdump_pid}
    ${kill_comand}=  Catenate  kill -9 ${tcpdump_pid_stripped}
    ssh.execute  ${kill_comand}  connection=conn_m51328c18_12_7_tcpdump
    ssh.disconnect  connection=conn_m51328c18_12_7_tcpdump

Start Tcpdump For M51328C8 Counter
    [Arguments]  ${master_ip_addr}
    ssh.connect to    ${SSH_IP}    ${OAM_USERNAME}    ${OAM_PASSWORD}    alias=conn_m51328c8_tcpdump
    ${s_plane_interface}=  ssh.execute  ip a | grep ${S1U} | awk '{print $7}'  connection=conn_m51328c8_tcpdump
    ${s_plane_interface_stripped}=  Strip String  ${s_plane_interface}
    ${master_ip_addr_stripped}=  Strip String  ${master_ip_addr}
    ${start_command}=  Catenate  tcpdump -i ${s_plane_interface_stripped} host ${master_ip_addr_stripped} -w 7672-A.cap
    ${tcpdump_pid}=  ssh.send command  ${start_command}  connection=conn_m51328c8_tcpdump

Kill Tcpdump For M51328C8 Counter
    [Arguments]  ${master_ip_addr}
    ${master_ip_addr_stripped}=  Strip String  ${master_ip_addr}
    ${tcpdump_pid_command}=  Catenate  ps aux | grep 'host ${master_ip_addr_stripped} -w 7672-A.cap' | grep -wv 'grep' | awk '{print $2}'
    ${tcpdump_pid}=  ssh.execute  ${tcpdump_pid_command}  connection=conn_m51328c8_tcpdump
    ${tcpdump_pid_stripped}=  Strip String  ${tcpdump_pid}
    ${kill_comand}=  Catenate  kill -9 ${tcpdump_pid_stripped}
    ssh.execute  ${kill_comand}  connection=conn_m51328c8_tcpdump
    ssh.disconnect  connection=conn_m51328c8_tcpdump

Get Number Of Packets After Packets Flood
    ssh.connect to    ${SSH_IP}    ${OAM_USERNAME}    ${OAM_PASSWORD}    alias=conn_4
    ${info_about_packets}=  ssh.execute  tcpdump -r 7672-A.cap | wc -l  connection=conn_4
    ${number_of_packets}=  Get Line  ${info_about_packets}  -1
    ssh.execute  rm 7672-A.cap  connection=conn_4
    ssh.disconnect  connection=conn_4
    [Return]  ${number_of_packets}

Send Packets For M51328C15 Counter To BTS
     ${python_path}=  Run  which python
     ${command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether() / scapy.IP(dst="${MPLANE_IPV4}")
     ...                     / scapy.ICMP(type=8, code=0)), pps=${M51328C15_PPS}, iface="eth0", loop=${M51328C15_PACKETS}, parse_results=1)'
     Run  sudo -E ${python_path} -c ${command}

Send Packets For M51328C15 Counter To BTS IPv6
     ${python_path}=  Run  which python
     ${command}=  Catenate  "import scapy.all as scapy; scapy.sendpfast([scapy.Ether() / scapy.IPv6(dst='${M_PLANE_IPv6}')
     ...                    / scapy.ICMPv6EchoRequest()], pps=${M51328C15_PPS}, iface='eth0', loop=${M51328C15_PACKETS}, parse_results=1)"
     Run  sudo -E ${python_path} -c ${command}

Send Packets For M51328C14 Counter To BTS
     ${python_path}=  Run  which python
     ${command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether() / scapy.IP(dst="${XNC}")
     ...          / scapy.SCTP(sport=36422, dport=36422)), pps=${M51328C14_PPS}, iface="eth0", loop=${M51328C14_PACKETS}, parse_results=1)'
     Run  sudo -E ${python_path} -c ${command}

Send Packets For M51328C14 Counter To BTS IPv6
     ${python_path}=  Run  which python
     ${command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether() / scapy.IPv6(dst="${XNC_V6}")
     ...          / scapy.SCTP(sport=36422, dport=36422)), pps=${M51328C14_PPS}, iface="eth0", loop=${M51328C14_PACKETS}, parse_results=1)'
     Run  sudo -E ${python_path} -c ${command}

Send Packets For M51328C12 Counter To BTS
     ${python_path}=  Run  which python
     ${command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether() / scapy.IP(dst="${MPLANE_IPV4}")
     ...                     / scapy.UDP(dport=33900)), pps=${M51328C12_PPS}, iface="eth0", loop=${M51328C12_PACKETS}, parse_results=1)'
     Run  sudo -E ${python_path} -c ${command}

Send Packets For M51328C12 Counter To BTS IPv6
     ${python_path}=  Run  which python
     ${command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether() / scapy.IPv6(dst="${MPLANE_IPV6}")
     ...                     / scapy.UDP(dport=33900)), pps=${M51328C12_PPS}, iface="eth0", loop=${M51328C12_PACKETS}, parse_results=1)'
     Run  sudo -E ${python_path} -c ${command}

Send Packets For M51328C18 Counter To BTS
     ${python_path}=  Run  which python
     ${command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether() / scapy.IP(dst="${MPLANE_IPV4}")
     ...                     / scapy.UDP(sport=53, dport=53)), pps=${M51328C18_PPS}, iface="eth0", loop=${M51328C18_PACKETS}, parse_results=1)'
     Run  sudo -E ${python_path} -c ${command}

Send Packets For M51328C18 Counter To BTS IPv6
     ${python_path}=  Run  which python
     ${command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether() / scapy.IPv6(dst="${MPLANE_IPV6}")
     ...                     / scapy.UDP(sport=53, dport=53)), pps=${M51328C18_PPS}, iface="eth0", loop=${M51328C18_PACKETS}, parse_results=1)'
     Run  sudo -E ${python_path} -c ${command}

Send Packets For M51328C8 Counter To BTS
     [Arguments]  ${master_ip_addr}
     ${python_path}=  Run  which python
     ${command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether() / scapy.IP(src="${master_ip_addr}", dst="${S1U}")
     ...                     / scapy.UDP(dport=320)), pps=${M51328C8_PPS}, iface="eth0", loop=${M51328C8_PACKETS}, parse_results=1)'
     Run  sudo -E ${python_path} -c ${command}

Send Packets For M51328C8 Counter To BTS IPv6
     [Arguments]  ${master_ip_addr}
     ${python_path}=  Run  which python
     ${command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether() / scapy.IPv6(src="${master_ip_addr}", dst="${S1U_V6}")
     ...                     / scapy.UDP(dport=320)), pps=${M51328C8_PPS}, iface="eth0", loop=${M51328C8_PACKETS}, parse_results=1)'
     Run  sudo -E ${python_path} -c ${command}

Send Packets For M51328C7 Counter To BTS
     ${python_path}=  Run  which python
     # here we run scapy two times to test different TWAMP ports: 5018 and 7
     ${first_command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether() / scapy.IP(dst="${MPLANE_IPV4}")
     ...                     / scapy.UDP(dport=5018)), pps=${M51328C7_PPS}, iface="eth0", loop=${M51328C7_PACKETS}, parse_results=1)'
     ${second_command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether() / scapy.IP(dst="${MPLANE_IPV4}")
     ...                     / scapy.UDP(dport=7)), pps=${M51328C7_PPS}, iface="eth0", loop=${M51328C7_PACKETS}, parse_results=1)'
     Run  sudo -E ${python_path} -c ${first_command}
     Sleep    30
     Run  sudo -E ${python_path} -c ${second_command}
     Sleep    30

Send Packets For M51328C7 Counter To BTS IPv6
     ${python_path}=  Run  which python
     # here we run scapy two times to test different TWAMP ports: 5018 and 7
     ${first_command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether() / scapy.IPv6(dst="${MPLANE_IPV6}")
     ...                     / scapy.UDP(dport=5018)), pps=${M51328C7_PPS}, iface="eth0", loop=${M51328C7_PACKETS}, parse_results=1)'
     ${second_command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether() / scapy.IPv6(dst="${MPLANE_IPV6}")
     ...                     / scapy.UDP(dport=7)), pps=${M51328C7_PPS}, iface="eth0", loop=${M51328C7_PACKETS}, parse_results=1)'
     Run  sudo -E ${python_path} -c ${first_command}
     Run  sudo -E ${python_path} -c ${second_command}

Download BTS File
    ${connection}=      Connect to ADMIN
    download scf file  ${connection}
    [Teardown]  Disconnect from ADMIN  ${connection}

Activate Reporting PM
    [Arguments]   ${na_instance}
    ...           ${dist_name}=${TRANSPORT_COUNTERS_PATH_NE3S}
    main_resource.activate_pm_counters_reporting    dist_name=${dist_name}
    ...                               path_to_scf=current_scf.xml
    ...                               reporting_interval=5min
    ...                               na_instance=${na_instance}

Get Counters Report Using NetAct
    [Arguments]     ${na_instance}   ${pm_file_path}=./PM_Report.gz
    fetch_latest_pm_report    pm_file_path=${pm_file_path}    na_instance=${na_instance}

Download Gzip File With PM Report
    Download BTS File
    ${na_instance}=  Connect to NetAct
    Activate Reporting PM  ${na_instance}
    Get Counters Report Using NetAct  ${na_instance}
    [Teardown]  Disconnect from NetAct  ${na_instance}

Actualize NetAct Counters
    Download Gzip File With PM Report
    Run  rm PM_Report.gz

Get Counter Value From NetAct
    [Arguments]     ${counter_number}
    Download Gzip File With PM Report
    Run  gunzip -c PM_Report.gz > PM_Report.xml
    ${counter_value}=  main_resource.get_counter_value_via_netact  ${counter_number}
    Run  rm PM_Report.gz
    [Return]  ${counter_value}

Remove NetAct Counters Raport
    Run  rm PM_Report.xml

Compare NetAct And WebEm Counter Time
    [Arguments]  ${webem_counter_time}=${NONE}
    ${new_time}=    Run Keyword If    "${webem_counter_time}"=="${NONE}"    Get Counter Time From WebEm  ${counter_id}
    ...             ELSE               Set Variable    ${NONE}
    ${webem_counter_time}=    Set Variable If    "${webem_counter_time}"=="${NONE}"    ${new_time}
    ...                                                                                ${webem_counter_time}
    ${netact_report_time}=  get_netact_report_time
    ${comparison_value}=  compare_netact_and_webem_raport_time  ${webem_counter_time}  ${netact_report_time}
    Should Be True  ${comparison_value}

Get C-Plane IPv4 Address Path
    ${dist_name}=  Set Variable  MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ${parameter}=  Set Variable  xnCplane
    ${connection}=  Connect to ADMIN
    ${xpath}=  Catenate  cmData/managedObject[@distName="${dist_name}"]/
    ...  list[@name="${parameter}"]/item/p[@name="ipV4AddressDN1"]
    ${scf_xml}=  coam_admin.get_scf   connection=${connection}   timeout=${600}
    ${value}=  XML.Get Element Text   ${scf_xml}   xpath=${xpath}
    ${value_2}=  XML.Get Element Text   ${scf_xml}   xpath=${value}/localIpAddr
    Disconnect from ADMIN  ${connection}
    [Return]  ${value_2}

Get M_Plane IPv4 Address Path
    [Arguments]  ${admin_conn}
    ${dist_name}=  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ${parameter}=  Set Variable  mPlaneIpv4AddressDN
    ${xpath}=  Catenate  cmData/managedObject[@distName="${dist_name}"]/p[@name="${parameter}"]
    ${scf_xml}=  coam_admin.get_scf   connection=${admin_conn}   timeout=${600}
    ${value}=  XML.Get Element Text   ${scf_xml}   xpath=${xpath}
    [Return]  ${value}

Delete IPAPP Object From BTS
    [Arguments]  ${admin_conn}
    ${dist_name}=  Set Variable  MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPAPP-1
    @{empty_list}=   Create List
    Run Keyword And Ignore Error  coam_admin.perform_object_recommissioning  dist_name=${dist_name}
    ...                                         parameter=${empty_list}
    ...                                         operation=delete
    ...                                         skip_parameter_relation_errors=${FALSE}
    ...                                         should_activate=${True}
    ...                                         connection=${admin_conn}

Create IPAPP Object if doesn't Exist or Change Parameter
    [Documentation]      This keyword creates IPAPP objects if it doesn't exists. If oject exists keyword changes
    ...                  parameter list value.
    [Arguments]          ${connection}
    ${params_list}=      get_list_of_params_for_ipapp_object
    ${object_status}     commissioning.Check if Object Exists in Scf File
    ...                  dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/
    ...                  object_name=IPAPP-1
    ...                  timeout=900
    ...                  connection=${connection}
    Run Keyword if       ${object_status}==False    coam_admin.perform_object_recommissioning
    ...                  dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPAPP-1
    ...                  parameter=${params_list}
    ...                  operation=create
    ...                  skip_parameter_relation_errors=${FALSE}
    ...                  should_activate=${True}
    ...                  connection=${connection}
    ...    ELSE          coam_admin.perform_parameter_recommissioning
    ...                  dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPAPP-1
    ...                  parameter=${params_list}
    ...                  value=1
    ...                  operation=update
    ...                  skip_parameter_relation_errors=${FALSE}
    ...                  timeout=300
    ...                  connection=${connection}

Create TWAMPREFLECT Object
    [Arguments]  ${admin_conn}
    ${dist_name}  Set Variable  MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPAPP-1/TWAMPREFLECT-1
    ${m_plane_path}=  Get M_Plane IPv4 Address Path  ${admin_conn}
    ${params_list}=  get_list_of_params_for_twampreflect_object  ${m_plane_path}
    coam_admin.perform_object_recommissioning        dist_name=${dist_name}
    ...                                         parameter=${params_list}
    ...                                         operation=create
    ...                                         skip_parameter_relation_errors=${FALSE}
    ...                                         should_activate=${True}
    ...                                         connection=${admin_conn}

Delete TOP Object From BTS
    [Arguments]  ${admin_conn}
    ${dist_name}=  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1
    @{empty_list}=   Create List
    Run Keyword And Ignore Error  coam_admin.perform_object_recommissioning  dist_name=${dist_name}
    ...                                         parameter=${empty_list}
    ...                                         operation=delete
    ...                                         skip_parameter_relation_errors=${FALSE}
    ...                                         should_activate=${True}
    ...                                         connection=${admin_conn}

Get S_Plane IPv4 Address Path
    [Arguments]  ${admin_conn}
    ${dist_name}=  Set Variable  MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ${parameter}=  Set Variable  s1Uplane
    ${xpath}=  Catenate  cmData/managedObject[@distName="${dist_name}"]/
    ...  list[@name="${parameter}"]/item/p[@name="ipV4AddressDN1"]
    ${scf_xml}=  coam_admin.get_scf   connection=${admin_conn}   timeout=${600}
    ${value}=  XML.Get Element Text   ${scf_xml}   xpath=${xpath}
    [Return]  ${value}

Get S_Plane IPv6 Address Path
    [Arguments]  ${admin_conn}
    ${dist_name}=  Set Variable  MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ${parameter}=  Set Variable  s1Uplane
    ${xpath}=  Catenate  cmData/managedObject[@distName="${dist_name}"]/
    ...  list[@name="${parameter}"]/item/p[@name="ipV6AddressDN1"]
    ${scf_xml}=  coam_admin.get_scf   connection=${admin_conn}   timeout=${600}
    ${value}=  XML.Get Element Text   ${scf_xml}   xpath=${xpath}
    [Return]  ${value}

Create TOP Object
    [Arguments]  ${admin_conn}
    ${dist_name}=  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1
    ${s_plane_ipv4_address_path}=  Get S_Plane IPv4 Address Path  ${admin_conn}
    ${params_list}=  get_list_of_params_for_top_object  ${s_plane_ipv4_address_path}
    coam_admin.perform_object_recommissioning        dist_name=${dist_name}
    ...                                  parameter=${params_list}
    ...                                  operation=create
    ...                                  skip_parameter_relation_errors=${FALSE}
    ...                                  should_activate=${True}
    ...                                  connection=${admin_conn}

Get Source IPv4 Address
    ${source_ipv4}=  Run  ip a | grep eth0 -A 2 | grep -w inet | awk {'print $2'} | awk -F/ {'print $1'}
    [Return]  ${source_ipv4}

Get Source IPv6 Address
    ${source_ipv6}=  Run  ip a | grep eth0 -A 2 | grep -w inet6 | awk {'print $2'} | awk -F/ {'print $1'}
    [Return]  ${source_ipv6}

Create TOPP Object
    [Arguments]  ${admin_conn}
    ${dist_name}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ${master_ip_addr}=  Get Source IPv4 Address
    ${params_list}=  get_list_of_params_for_topp_object  ${master_ip_addr}
    coam_admin.perform_object_recommissioning        dist_name=${dist_name}
    ...                                  parameter=${params_list}
    ...                                  operation=create
    ...                                  skip_parameter_relation_errors=${FALSE}
    ...                                  should_activate=${True}
    ...                                  connection=${admin_conn}

Get MasterIpAddress From BTS
    [Arguments]  ${admin_conn}
    ${dist_name}=  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ${list_name}=  Set Variable  topMasterList
    ${parameter_name}=  Set Variable  masterIpAddr
    ${xpath}=  Catenate  cmData/managedObject[@distName="${dist_name}"]/list[@name="${list_name}"]/item/p[@name="${parameter_name}"]
    ${scf_xml}=  coam_admin.get_scf   connection=${admin_conn}   timeout=${600}
    ${value}=  XML.Get Element Text   ${scf_xml}   xpath=${xpath}
    [Return]  ${value}

Get SPlaneIpAddressDN From BTS
    [Arguments]  ${admin_conn}
    ${dist_name}=  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1
    ${parameter_name}=  Set Variable  sPlaneIpAddressDN
    ${xpath}=  Catenate  cmData/managedObject[@distName="${dist_name}"]/p[@name="${parameter_name}"]
    ${scf_xml}=  coam_admin.get_scf   connection=${admin_conn}   timeout=${600}
    ${value}=  XML.Get Element Text   ${scf_xml}   xpath=${xpath}
    [Return]  ${value}

Change SPlaneIpAddressDN On BTS
    [Arguments]  ${admin_conn}  ${s_plane_DN}
    ${dist_name}=  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1
    ${params_list}=  get_s_plane_ip_address_dn_parameter  ${s_plane_DN}
    coam_admin.perform_object_recommissioning   dist_name=${dist_name}
    ...                                         parameter=${params_list}
    ...                                         operation=update
    ...                                         skip_parameter_relation_errors=${FALSE}
    ...                                         should_activate=${True}
    ...                                         connection=${admin_conn}

Change TOP MasterIpAddress On BTS
    [Arguments]  ${admin_conn}  ${master_ip_addr}
    ${dist_name}=  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ${params_list}=  get_top_object_parameters  ${master_ip_addr}
    coam_admin.perform_object_recommissioning   dist_name=${dist_name}
    ...                                         parameter=${params_list}
    ...                                         operation=update
    ...                                         skip_parameter_relation_errors=${TRUE}
    ...                                         should_activate=${True}
    ...                                         connection=${admin_conn}
