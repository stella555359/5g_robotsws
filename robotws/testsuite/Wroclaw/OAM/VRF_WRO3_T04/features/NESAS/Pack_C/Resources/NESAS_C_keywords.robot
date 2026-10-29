*** Settings ***
Documentation      Keywords for CB007672 feature

Resource           ../../../../common_resources/admin/admin.robot
Resource           ../../../../common_resources/netact/netact_operations.robot
Resource           ../../../../common_resources/commissioning/commissioning.robot
Library            taf.sbts.oam.coam.admin    WITH NAME    coam_admin
#Library            ./resources.py    WITH NAME    main_resource
Library            XML   True

*** Variables ***
${pm_technology}=    Nokia SRAN SBTS 25R3
${TRANSPORT_COUNTERS_PATH}=             TRS/TNL-1/IPNO/IPNO-1/IP_filtering_Stats/
${TRANSPORT_COUNTERS_PATH_NEW}=         TRS/MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IP_filtering_Stats/
${TRANSPORT_COUNTERS_PATH_NE3S}=        MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1



# ipRmDropPcktsRtLimMplane [M51328C18] test settings
${M51328C18_BURST}=                               300
${M51328C18_LIMIT}=                               4000
${M51328C18_INCREASE_PERCENT}=                    0.10
${M51328C18_PPS}=                                 ${M51328C18_LIMIT} + (${M51328C18_LIMIT} *
...                                               ${M51328C18_INCREASE_PERCENT})
${M51328C18_LOOP}=                                10
${M51328C18_PACKETS}=                             ${M51328C18_LOOP} * (${M51328C18_PPS})
${M51328C18_TCPDUMP_STATISTICAL_ERROR}=           0.25
${M51328C18_TCPDUMP_STATISTICAL_ERROR_MORE}=      (1 + ${M51328C18_TCPDUMP_STATISTICAL_ERROR})
${M51328C18_TCPDUMP_STATISTICAL_ERROR_LESS}=      (1 - ${M51328C18_TCPDUMP_STATISTICAL_ERROR})
${M51328C18_SHOULD_BE_COLLECTED}=                 ${M51328C18_PACKETS} - (${M51328C18_LIMIT} * ${M51328C18_LOOP}) -
...                                               ${M51328C18_BURST}
${M51328C18_TEST_STATISTICAL_ERROR}=              (${M51328C18_LOOP} * (${M51328C18_PPS})) / 10

# ipRmDropPcktsRtLimTwamp [M51328C7] test settings
${M51328C7_BURST}=                                100
${M51328C7_LIMIT}=                                2000
${M51328C7_INCREASE_PERCENT}=                     0.10
${M51328C7_PPS}=                                  ${M51328C7_LIMIT} + (${M51328C7_LIMIT} *
...                                               ${M51328C7_INCREASE_PERCENT})
${M51328C7_LOOP}=                                 10
${M51328C7_NUMBER_OF_SCAPY_RUNS}=                 2
${M51328C7_PACKETS}=                              ${M51328C7_LOOP} * ${M51328C7_PPS}
${M51328C7_TCPDUMP_STATISTICAL_ERROR}=            0.25
${M51328C7_TCPDUMP_STATISTICAL_ERROR_MORE}=       (1 + ${M51328C7_TCPDUMP_STATISTICAL_ERROR})
${M51328C7_TCPDUMP_STATISTICAL_ERROR_LESS}=       (1 - ${M51328C7_TCPDUMP_STATISTICAL_ERROR})
${M51328C7_SHOULD_BE_COLLECTED}=                  SEPARATOR=
...   ${M51328C7_NUMBER_OF_SCAPY_RUNS} * (${M51328C7_PACKETS} - (${M51328C7_LIMIT} * ${M51328C7_LOOP}) -
...   ${M51328C7_BURST})
${M51328C7_TEST_STATISTICAL_ERROR}=               (${M51328C7_LOOP} * (${M51328C7_PPS})) / 10

@{BRANCHES_WITH_OLD_COUNTERS}       SBTS23R3    SBTS23R4   SBTS24R1



*** Keywords ***
Get Rejected Packets Interval and Reporting Interval parameters value
    ${connection}=  Connect to ADMIN
    ${correct_ipFilteringInterval_dist}=  Set Variable   MRBTS-${BTS_ID}/TNLSVC-1/PMTNLINT-1
    ${param_name_ipFilteringInterval}=    Set Variable   ipFilteringInterval
    ${xpath_ipFilteringInterval}=  Catenate
    ...  cmData/managedObject[@distName="${correct_ipFilteringInterval_dist}"]/
    ...  p[@name="${param_name_ipFilteringInterval}"]

    ${correct_reportingIntervalPm_dist}=  Set Variable   MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    ${param_name_reportingIntervalPm}=    Set Variable   reportingIntervalPm
    ${xpath_reportingIntervalPm}=  Catenate
    ...  cmData/managedObject[@distName="${correct_reportingIntervalPm_dist}"]/
    ...  p[@name="${param_name_reportingIntervalPm}"]

    ${scf_xml}=  coam_admin.get_scf   connection=${connection}   timeout=${600}
    Log  Getting ipFilteringInterval and reportingIntervalPm parameters value  console=True
    ${value_ipFilteringInterval}=  XML.Get Element Text   ${scf_xml}   xpath=${xpath_ipFilteringInterval}
    ${value_reportingIntervalPm}=  XML.Get Element Text   ${scf_xml}   xpath=${xpath_reportingIntervalPm}

    Disconnect from ADMIN  ${connection}
    [Return]  ${value_ipFilteringInterval}  ${value_reportingIntervalPm}


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
    ${value_ipFilteringInterval}  ${value_reportingIntervalPm}
    ...  Get Rejected Packets Interval and Reporting Interval parameters value
    Run Keyword If  '${value_ipFilteringInterval}' != '5min' or '${value_reportingIntervalPm}' != '5min'
    ...   Run Keywords
    ...   Log  Changing ipFilteringInterval and reportingIntervalPm parameters value and waiting
    ...   5 minutes to refresh counters  console=True
    ...   AND   counters_keywords.Change Rejected Packets Interval To 5min
    ...   AND   counters_keywords.Change Reporting Interval To 5min
    ...   AND   Sleep  300  reason=start new counters interval

Wait Until Transport Counters Available After Reboot
    [Arguments]  ${counter_name}
    ${INSTALLED_SW_BRANCH}=   admin.Get Software Release Name
    Run Keyword If    "${INSTALLED_SW_BRANCH}" in ${BRANCHES_WITH_OLD_COUNTERS}
    ...         Set Global Variable   ${status}    0
    ...         ELSE    Set Global Variable   ${status}    1
    Run Keyword If    '${status}'=='0'
    ...         Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}   ${TRANSPORT_COUNTERS_PATH}
    ...         ELSE    Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}   ${TRANSPORT_COUNTERS_PATH_NEW}
    Wait Until Keyword Succeeds  15 min  1 min  get_dropped_packets_counter_value  ${TRANSPORT_COUNTERS_PATHS}
    ...                                         ${counter_name}  ${SSH_IP}  ${WEBEM_PASSWORD}

Get Counter Time From WebEm
    [Arguments]  ${counter_name}
    ${INSTALLED_SW_BRANCH}=   admin.Get Software Release Name
    Run Keyword If    "${INSTALLED_SW_BRANCH}" in ${BRANCHES_WITH_OLD_COUNTERS}
    ...         Set Global Variable   ${status}    0
    ...         ELSE    Set Global Variable   ${status}    1
    Run Keyword If    '${status}'=='0'    Set Global Variable
    ...         ${TRANSPORT_COUNTERS_PATHS}   ${TRANSPORT_COUNTERS_PATH}
    ...         ELSE    Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}   ${TRANSPORT_COUNTERS_PATH_NEW}
    ${counter_time}=   get_dropped_packets_counter_time  ${TRANSPORT_COUNTERS_PATHS}  ${counter_name}  ${SSH_IP}
    ...   ${WEBEM_PASSWORD}
    [Return]  ${counter_time}

Get Counter Value From WebEm
    [Arguments]  ${counter_name}
    ${INSTALLED_SW_BRANCH}=   admin.Get Software Release Name
    Run Keyword If    "${INSTALLED_SW_BRANCH}" in ${BRANCHES_WITH_OLD_COUNTERS}
    ...         Set Global Variable   ${status}    0
    ...         ELSE    Set Global Variable   ${status}    1
    Run Keyword If    '${status}'=='0'
    ...         Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}   ${TRANSPORT_COUNTERS_PATH}
    ...         ELSE    Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}   ${TRANSPORT_COUNTERS_PATH_NEW}
    ${counter_value}=  get_dropped_packets_counter_value  ${TRANSPORT_COUNTERS_PATHS}  ${counter_name}  ${SSH_IP}
    ...   ${WEBEM_PASSWORD}
    [Return]  ${counter_value}

Compare Counter Values
    [Arguments]  ${start_value}  ${counter_name}
    ${INSTALLED_SW_BRANCH}=   admin.Get Software Release Name
    Run Keyword If    "${INSTALLED_SW_BRANCH}" in ${BRANCHES_WITH_OLD_COUNTERS}
    ...         Set Global Variable   ${status}    0
    ...         ELSE    Set Global Variable   ${status}    1
    Run Keyword If    '${status}'=='0'
    ...         Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}   ${TRANSPORT_COUNTERS_PATH}
    ...         ELSE    Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}   ${TRANSPORT_COUNTERS_PATH_NEW}
    ${value}=   get_dropped_packets_counter_time  ${TRANSPORT_COUNTERS_PATHS}  ${counter_name}  ${SSH_IP}
    ...   ${WEBEM_PASSWORD}
    log to console  waiting for new ipFilteringInterval start, previous time is ${value}
    should not be equal  ${start_value}  ${value}

Wait For New Interval Start
    [Arguments]  ${counter_name}
    ${INSTALLED_SW_BRANCH}=   admin.Get Software Release Name
    Run Keyword If    "${INSTALLED_SW_BRANCH}" in ${BRANCHES_WITH_OLD_COUNTERS}
    ...         Set Global Variable   ${status}    0
    ...         ELSE    Set Global Variable   ${status}    1
    Run Keyword If    '${status}'=='0'
    ...         Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}   ${TRANSPORT_COUNTERS_PATH}
    ...         ELSE    Set Global Variable   ${TRANSPORT_COUNTERS_PATHS}   ${TRANSPORT_COUNTERS_PATH_NEW}
    ${start_value}=   get_dropped_packets_counter_time  ${TRANSPORT_COUNTERS_PATHS}  ${counter_name}  ${SSH_IP}
    ...   ${WEBEM_PASSWORD}
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

Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    ssh.connect to    ${SSH_IP}    ${OAM_USERNAME}    ${OAM_PASSWORD}    alias=conn_m51328c18_12_7_tcpdump
    ${m_plane_interface}=
    ...   ssh.execute  ip a | grep ${MPLANE_IPV4} | awk '{print $7}'  connection=conn_m51328c18_12_7_tcpdump
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

Get Number Of Packets After Packets Flood
    ssh.connect to    ${SSH_IP}    ${OAM_USERNAME}    ${OAM_PASSWORD}    alias=conn_4
    ${info_about_packets}=  ssh.execute  tcpdump -r 7672-A.cap | wc -l  connection=conn_4
    ${number_of_packets}=  Get Line  ${info_about_packets}  -1
    ssh.execute  rm 7672-A.cap  connection=conn_4
    ssh.disconnect  connection=conn_4
    [Return]  ${number_of_packets}

Send Packets For M51328C18 Counter To BTS
     SSHLibrary.Open Connection      ${TEST_PC}
     SSHLibrary.Login                ${PC_LOGIN}    ${PC_PASS}
     SSHLibrary.Write             sudo su
     Sleep    2
     SSHLibrary.Write             ${PC_PASS}
     ${command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether()
    ...                     / scapy.IP(dst="${MPLANE_IPV4}") / scapy.UDP(sport=53, dport=53)),
    ...                     pps=5000, iface="${PC_iface}", loop=50000, parse_results=1)'
    SSHLibrary.Write                sudo -E python3 -c ${command}
    Sleep    30
    SSHLibrary.Read


Send Packets For M51328C7 Counter To BTS
     ${python_path}=  Run  which python
     # here we run scapy two times to test different TWAMP ports: 5018 and 7
     ${first_command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether()
     ...                     / scapy.IP(dst="${MPLANE_IPV4}") / scapy.UDP(dport=5018)),
     ...                    pps=${M51328C7_PPS}, iface="eth0", loop=${M51328C7_PACKETS}, parse_results=1)'
     ${second_command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether()
     ...                     / scapy.IP(dst="${MPLANE_IPV4}") / scapy.UDP(dport=7)),
     ...                     pps=${M51328C7_PPS}, iface="eth0", loop=${M51328C7_PACKETS}, parse_results=1)'
     Run  sudo -E ${python_path} -c ${first_command}
     Sleep    30
     Run  sudo -E ${python_path} -c ${second_command}
     Sleep    30


Activate Reporting PM
    [Arguments]   ${na_instance}
    ...           ${dist_name}=${TRANSPORT_COUNTERS_PATH_NE3S}
    main_resource.activate_pm_counters_reporting    dist_name=${dist_name}
    ...                               path_to_scf=current_scf.xml
    ...                               reporting_interval=5min
    ...                               na_instance=${na_instance}

Compare NetAct And WebEm Counter Time
    [Arguments]  ${webem_counter_time}=${NONE}
    ${new_time}=    Run Keyword If    "${webem_counter_time}"=="${NONE}"
    ...             Get Counter Time From WebEm  ${counter_id}
    ...             ELSE               Set Variable    ${NONE}
    ${webem_counter_time}=    Set Variable If    "${webem_counter_time}"=="${NONE}"    ${new_time}
    ...                                                                                ${webem_counter_time}
    ${netact_report_time}=  get_netact_report_time
    ${comparison_value}=  compare_netact_and_webem_raport_time  ${webem_counter_time}  ${netact_report_time}
    Should Be True  ${comparison_value}

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
    [Documentation]      This keyword creates IPAPP objects if it doesn't exists.
    ...                  If oject exists keyword changes parameter list value.
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

Get counter from Mantaray
    [Arguments]    ${counter}    ${time}   ${time_difference}    ${NMS_LAB}
    ${WebEm_counter_time}=    Split String    ${time}    :
    ${NetAct_counter_h}=      Evaluate  int('${WebEm_counter_time}[0]') + int(${time_difference})
    ${NetAct_counter_min}=    Set Variable    ${WebEm_counter_time}[1]
    ${NetAct_counter_time}=    Catenate  SEPARATOR=:    ${NetAct_counter_h}    ${NetAct_counter_min}
    ${counter_NetAct_list}=    Get PM Counters from Mantaray    mrbts_id=${BTS_ID}    alias=${NMS_LAB}
    ...   technology=${pm_technology}
    ${index}=    Get Length    ${counter_NetAct_list}
    ${index}=    Evaluate    ${index} - 1
    ${value_mantaray}=    Set Variable    ${EMPTY}
    FOR    ${i}    IN RANGE   ${index}
        ${time_mantaray}    Get From Dictionary   ${counter_NetAct_list}[${i}]    period_start_time
        ${correct_time}=    Run Keyword and Return Status    Should Contain
        ...                 ${time_mantaray}  ${NetAct_counter_time}
        IF    ${correct_time}==True
            ${value_mantaray}=    Get From Dictionary   ${counter_NetAct_list}[${i}]   ${counter}
        ELSE
        Log    next loop    console=true
        END
    END
    [Return]    ${value_mantaray}
