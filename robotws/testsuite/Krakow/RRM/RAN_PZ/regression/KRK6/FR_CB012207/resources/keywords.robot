*** Settings ***
Documentation
...    author: Kamil Bielecki
...    contact: kamil.bielecki@nokia.com

Library     DateTime                                                                          WITH NAME    dt
Library     OperatingSystem                                                                   WITH NAME    os
Library     String                                                                            WITH NAME    str
Library     ute_ue                                                                            WITH NAME    ue
Library     SSHLibrary                                                                        WITH NAME    ssh_lib

Library     taf.ccs.aashell                                                                   WITH NAME    cli
Library     taf.transport.ssh                                                                 WITH NAME    ssh
Library     taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter                                  WITH NAME    gnbcounter
Library     taf.rfrl.ue.ute_ue_config.UteUeConfig                                             WITH NAME    uteueconfig
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations                         WITH NAME    gnbcell
Library     taf.rfrl.bts.devices.du.logs_collecting.basic_logs.GnbLog                         WITH NAME    gnb_log
Library     tcp_runner.py
Library     verification.py
Library     data_transfer.py

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/RRM/RAN_PZ/resources/collect_logs.robot
Resource    testsuite/Krakow/RRM/RAN_PZ/resources/resources.robot

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./variables.py


*** Variables ***
${ABSTRACT_LIB_CONFIG}       ${NONE}
${SKIP_COMMISSIONING}        ${NONE}
${COLLECT_MANDATORY_LOGS}    ${False}

@{allowed_alarms}    SSH enabled
...                  R&D Service Port enabled
...                  LMP access via port 443
...                  Service account root access is enabled
...                  Ethernet port security is disabled
...                  Sanity Check Error
...                  Diagnostic Check Error
...                  No Xn link available
...                  Xn SCTP setup fail
...                  Xn SCTP endpoint broken

${GNB1_PCAP_FILE}        gnb1_tcpdump.pcap
${GNB2_PCAP_FILE}        gnb2_tcpdump.pcap

${INTERFACE}            any

${CB008806_COUNTERS}=     SEPARATOR=
...                       M55125C01501,M55125C07502,M55125C07503,M55125C07504,M55125C07512,M55125C07514,M55125C07520,
...                       M55125C07523,M55125C07525,M55125C07526,M55125C09013,M55125C09014,M55125C09015,M55125C09516,
...                       M55149C03001,M55149C03002,M55149C03003,M55153C00501,M55153C00502,M55153C00503,M55163C00513,
...                       M55163C00514,M55163C00515,M55163C00521,M55178C00020,M55178C00022

${CB008127_COUNTERS}=     SEPARATOR=
...                       M55125C09516,M55145C00222,M55145C00341,M55145C00342,M55145C00362,M55149C00008,M55187C00001,
...                       M55190C00001

${CB008699_COUNTERS}=     SEPARATOR=
...                       M55147C00036,M55147C00037


*** Keywords ***
Suite Setup
    [Documentation]    Common part for all test cases
    &{ABSTRACT_LIB_CONFIG}=    Get ute UE Configuration Dict
    Set Suite Variable    ${ABSTRACT_LIB_CONFIG}
    Common Suite Setup With OnAir Test Line Preparation
    ...     swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...     should_LTE_neighbour_be_changed=False
    ...     should_5G_neighbour_be_changed=True
    ...     list_of_additional_allowed_alarms=@{allowed_alarms}

Get Cell Parameters For Both Gnb
    ${gnb1_cell1_parameters}=  gnbcell.Get Cell Parameters    bts_id=0    cell_id=${260}    du_id=0
    Set Suite Variable    ${gnb1_cell1_nrid}    ${gnb1_cell1_parameters['nrCellIdentity']}
    ${gnb2_cell1_parameters}=  gnbcell.Get Cell Parameters    bts_id=1    cell_id=${270}    du_id=0
    Set Suite Variable    ${gnb2_cell1_nrid}    ${gnb2_cell1_parameters['nrCellIdentity']}

Suite Teardown
    Log Action To Console    Suite Teardown
    Common Suite Teardown

Upload SCF commission and wait onAir
    [Arguments]  ${prefix_tag}  ${gnb_id}
    [Documentation]    Keyword uploads swconfig.txt on gNB and performs commissioning from given scf file.
    ...    :param prefix_tag:  prefix used to select SCF for comissoning
    Perform Full Commissioning on Classical gNB    prefix_tag=${prefix_tag}    awaiting_time=240    bts_id=${gnb_id}
    Wait until all cells are onair      bts_id=${gnb_id}

Test Setup Common
    Log Action To Console    Start Test Setup
    os.Create Directory    ${LOG_PATH}
    Setup UE Before Test

Test Setup NG HO
    Test Setup Common
    Upload SCF commission and wait onAir    prefix_tag=CB012207_NG_HO       gnb_id=0
    Upload SCF commission and wait onAir    prefix_tag=CB012207_NG_HO       gnb_id=1
    Common Preconditions
    Get Cell Parameters For Both Gnb
    Log Action To Console    End Test Setup
    Log Action To Console    Start Test Procedure

Test Setup XN HO
    Test Setup Common
    Upload SCF commission and wait onAir    prefix_tag=CB012207_XN_HO       gnb_id=0
    Upload SCF commission and wait onAir    prefix_tag=CB012207_XN_HO       gnb_id=1
    Common Preconditions
    Get Cell Parameters For Both Gnb
    Log Action To Console    End Test Setup
    Log Action To Console    Start Test Procedure

Test Teardown HO with source shutdown
    run keyword and ignore error    Detach UE
    run keyword and ignore error    Stop Downlink and Uplink TCP Data Transmission
    run keyword and ignore error    Unlock gNB Cell    gnb_id=0    cell_id=260
    run keyword and ignore error    Unlock gNB Cell    gnb_id=1    cell_id=270
    Common Postconditions

Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${True}
    [Documentation]  :param msg:     message logged
    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   dt.Get Current Date
    Run keyword if    '${datatime}'=='${True}'   Log To Console    [*][${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console    [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}

Setup UE Before Test
    [Documentation]    Keyword sets up UE using taf.ue and restarts proxy service on UEPC in case of failure
    ${status}=    Run Keyword And Return Status    ue.Require Ue    UE    CPE
    Run Keyword If    '${status}' == '${False}'    Run Keywords     Restart UE PROXY Service     AND    ue.Require Ue    UE    CPE
    Run Keyword And Ignore Error    ue.Detach UE   UE

Attach UE With PDU Session Setup to Cell 1 of gNB 2
    [Documentation]    Keyword performs attach to Cell 1 of gNB 2 while collecting pcap file during attach procedure
    Log Action To Console    Attach UE With PDU Session Setup to Cell 1 of gNB 2
    ${date}=    Get Current Date   result_format=%Y_%m_%d_%H_%M_%S
    ${pcap_file}=    Set variable    ue_attach_${date}.pcap
    ${bts_id}=    Set variable    1
    Start Tcpdump on gNB    ${pcap_file}   bts_id=${bts_id}
    Set Test Variable    ${pcap_attach_log_path}    ${pcap_file}
    ue.Attach UE   UE
    ue.Create PDU Session    UE
    Sleep  20s
    Stop Tcpdump on gNB    ${pcap_file}   bts_id=${bts_id}

Attach UE With PDU Session Setup to Cell 1 of gNB 1
    [Documentation]    Keyword performs attach to Cell 1 of gNB 1 while collecting pcap file during attach procedure
    Log Action To Console    Attach UE With PDU Session Setup to Cell 1 of gNB 1
    ${date}=    Get Current Date   result_format=%Y_%m_%d_%H_%M_%S
    ${pcap_file}=    Set variable    ue_attach_${date}.pcap
    ${bts_id}=    Set variable    0
    Start Tcpdump on gNB    ${pcap_file}   bts_id=${bts_id}
    Set Test Variable    ${pcap_attach_log_path}    ${pcap_file}
    ue.Attach UE   UE
    ue.Create PDU Session    UE
    Sleep  20s
    Stop Tcpdump on gNB    ${pcap_file}   bts_id=${bts_id}

Perform UE HO to cell 1 of gNB 1
    [Documentation]    Keyword collects pcap and cell 1 of gNB 2 is set to state Shutting Down triggering HO to gNB 1
    Log Action To Console    Perform UE NG HO to Cell 1 of gNB 1
    ${date}=    Get Current Date   result_format=%Y_%m_%d_%H_%M_%S
    ${pcap_file}=    Set variable    ue_ho_${date}.pcap
    ${bts_id}=    Set variable    0
    Start Tcpdump on gNB    ${pcap_file}   bts_id=${bts_id}
    Set Test Variable    ${pcap_ho_log_path}    ${pcap_file}
    Set administrativeState for cell 1 on gNB 2 to Shutting Down
    Sleep  70s
    Stop Tcpdump on gNB    ${pcap_file}   bts_id=${bts_id}

Detach UE
    Log Action To Console    Detach UE
    ue.Detach UE   UE

Restart UE PROXY Service
    [Documentation]    Keyword logs into UEPC from ue_config.yaml and restarts UE PROXY service using ssh
    Log Action To Console        Restart UE PROXY Service

    ${host}=    Set Variable  ${ABSTRACT_LIB_CONFIG.UE_PC.ue_pc_ip}
    ${username}=    Set Variable  ${ABSTRACT_LIB_CONFIG.UE_PC.ue_pc_login}
    ${password}=    Set Variable  ${ABSTRACT_LIB_CONFIG.UE_PC.ue_pc_password}

    ssh_lib.Open Connection      host=${host}    timeout=60s
    ssh_lib.Login                username=${username}    password=${password}
    ssh_lib.Execute Command      net stop UE_PROXY_AT && net start UE_PROXY_AT
    Sleep                        10s

    [Teardown]   ssh_lib.Close Connection

Start Tcpdump on gNB
    [Arguments]     ${pcap_file}    ${bts_id}=0
    gnb_log.Start Tcpdump On SMOD   bts_id=${bts_id}
    ...                             interface=${INTERFACE}
    ...                             capture_file=${pcap_file}
    ...                             background=${True}

Stop Tcpdump on gNB
    [Arguments]     ${pcap_file}    ${bts_id}=0
    gnb_log.Stop Tcpdump On SMOD    bts_id=${bts_id}
    ${directory}=   gnb_log.Download Tcpdump From BTS       bts_id=${bts_id}
    ...                                     interface=FCT
    ...                                     log_file_name=${pcap_file}

Check If UE Is Attached To Cell 1 Of gNB 2
    Log Action To Console    Check If UE Is Attached To Cell 1 Of gNB 2
    Verify Ngap Initial Context Setup    pcap_file=${LOG_PATH}/${pcap_attach_log_path}      nrcell_id=${gnb2_cell1_nrid}

Check If UE Is Attached To Cell 1 Of gNB 1
    Log Action To Console    Check If UE Is Attached To Cell 1 Of gNB 1
    Verify Ngap Initial Context Setup    pcap_file=${LOG_PATH}/${pcap_attach_log_path}      nrcell_id=${gnb1_cell1_nrid}

Check If UE performed NG HO To Cell 1 Of gNB 1
    Log Action To Console    Check If UE performed NG HO To Cell 1 Of gNB 1
    Verify Ng Handover Performed    pcap_file=${LOG_PATH}/${pcap_ho_log_path}

Check If UE performed XN HO To Cell 1 Of gNB 1
    Log Action To Console    Check If UE performed XN HO To Cell 1 Of gNB 1
    Verify Xn Handover Performed    pcap_file=${LOG_PATH}/${pcap_ho_log_path}

Set administrativeState for cell 1 on gNB 2 to Shutting Down
    Log Action To Console    Set administrativeState for cell 1 on gNB 2 to Shutting Down
    gnbscf.Perform Bts Delta Commissioning    delta=${delta_shuttingdown}    bts_id=1

Set administrativeState for cell 1 on gNB 2 to Unlocked
    Log Action To Console    Set administrativeState for cell 1 on gNB 2 to Unlocked
    gnbscf.Perform Bts Delta Commissioning    delta=${delta_unlocked}    bts_id=1

Run Downlink and Uplink TCP Data Transmission for ${duration} seconds
    Log Action To Console    Run Downlink and Uplink TCP Data Transmission for ${duration} seconds

    tcp_runner.Start Data Transfer    dt_name=DL_UE_DT    ue_alias=UE
    ...    app_server_cmd=iperf3 -s -B <APP_SERVER_BIND_IP> -p <APP_SERVER_IPERF_PORT> -i 1
    ...    ue_cmd=/usr/bin/iperf3 -c <APP_SERVER_BIND_IP> -p <UE_IPERF_PORT> -t ${duration} -B <UE_IP> -i 1 -P 6 -R

    tcp_runner.Start Data Transfer    dt_name=UL_UE_DT    ue_alias=UE
    ...    app_server_cmd=iperf3 -s -B <APP_SERVER_BIND_IP> -p <APP_SERVER_IPERF_PORT> -i 1
    ...    ue_cmd=/usr/bin/iperf3 -c <APP_SERVER_BIND_IP> -p <UE_IPERF_PORT> -t ${duration} -B <UE_IP> -i 1 -P 6
    Sleep   30s

Stop Downlink and Uplink TCP Data Transmission
    tcp_runner.Stop Data Transfer    dt_name=DL_UE_DT
    tcp_runner.Stop Data Transfer    dt_name=UL_UE_DT

Verify Downlink and Uplink TCP Data Transmission
    Log Action To Console    Verify Downlink and Uplink TCP Data Transmission

    ${iperf_log_path}=    tcp_runner.Get App Server Iperf Log Path    dt_name=DL_UE_DT
    Verify TCP Data Transfer    minimum_level=50 Mbits/sec     maximum_level=550 Mbits/sec    iperf_log_path=${iperf_log_path}

    ${iperf_log_path}=    tcp_runner.Get App Server Iperf Log Path    dt_name=UL_UE_DT
    Verify TCP Data Transfer    minimum_level=10 Mbits/sec     maximum_level=400 Mbits/sec   iperf_log_path=${iperf_log_path}

Activate Full RRC Reconfiguration on both gNBs
    Log Action To Console    Enable Full RRC Reconfiguration with SA HO

    gnbscf.Perform Bts Delta Commissioning    delta=${full_rrc_reconfiguration_enable_gnb0}    bts_id=0
    gnbscf.Perform Bts Delta Commissioning    delta=${full_rrc_reconfiguration_enable_gnb1}    bts_id=1

Deactivate Full RRC Reconfiguration on both gNBs
    Log Action To Console    Disable Full RRC Reconfiguration with SA HO
    gnbscf.Perform Bts Delta Commissioning    delta=${full_rrc_reconfiguration_disable_gnb0}    bts_id=0
    gnbscf.Perform Bts Delta Commissioning    delta=${full_rrc_reconfiguration_disable_gnb1}    bts_id=1

Wait until all cells are onair
    [Arguments]    ${waiting_time}=10min    ${checking_interval}=15s       ${bts_id}=0
    [Documentation]    The keyword waits until all cells will be in on air.
    ...                :param waiting_time:    time to wait
    ...                :param checking_interval: time between checking
    Log Action To Console    Wait until all cells are onair
    Wait Until Keyword Succeeds    ${waiting_time}    ${checking_interval}
    ...    Verify Setup Of All Cells    gnb_id=${bts_id}    du_id=0
    ...                                 operational_state=Enabled    procedural_status=configured
    ...                                 availability_status=Online    administrative_state=Unlocked

Check PM counters for CB008806
    [Documentation]    The keyword checks all CB012207 related counters for sub-feature CB008806
    Log Action To Console    Waiting for counters to update
    Sleep   60s
    Log Action To Console    Check CB008806 counters
    ${counters_bts_0}=    gnbcounter.Get Counter    counter_ids=${CB008806_COUNTERS}      bts_id=0
    ${counters_bts_1}=    gnbcounter.Get Counter    counter_ids=${CB008806_COUNTERS}      bts_id=1
    ${is_incorrect}=    Check CB008806 counters     counters_bts_0=${counters_bts_0}
    ...                         counters_bts_1=${counters_bts_1}
    Run Keyword If      ${is_incorrect} == True
    ...                 Fail    Counters value incorrect. Check logs for more info.

Check PM counters for CB008127
    [Documentation]    The keyword checks all CB012207 related counters for sub-feature CB008127
    Log Action To Console    Waiting for counters to update
    Sleep   60s
    Log Action To Console    Check CB008127 counters
    ${counters_bts_0}=    gnbcounter.Get Counter    counter_ids=${CB008127_COUNTERS}      bts_id=0
    ${counters_bts_1}=    gnbcounter.Get Counter    counter_ids=${CB008127_COUNTERS}      bts_id=1
    ${is_incorrect}=    Check CB008127 counters    counters_bts_0=${counters_bts_0}
    ...                         counters_bts_1=${counters_bts_1}
    Run Keyword If      ${is_incorrect} == True
    ...                 Fail    Counters value incorrect. Check logs for more info.

Check PM counters for CB008699
    [Documentation]    The keyword checks all CB012207 related counters for sub-feature CB008699
    Log Action To Console    Waiting for counters to update
    Sleep   60s
    Log Action To Console    Check CB008699 counters
    ${counters_bts_0}=    gnbcounter.Get Counter    counter_ids=${CB008699_COUNTERS}      bts_id=0
    ${counters_bts_1}=    gnbcounter.Get Counter    counter_ids=${CB008699_COUNTERS}      bts_id=1
    ${is_incorrect}=    Check CB008699 counters    counters_bts_0=${counters_bts_0}
    ...                         counters_bts_1=${counters_bts_1}
    Run Keyword If      ${is_incorrect} == True
    ...                 Fail    Counters value incorrect. Check logs for more info.

Wait For Next PM measurements
    [Arguments]   ${interval}=15min    ${delay}=30
    [Documentation]  Wait for the next counter cycle, indicated by the interval
    ...              :param interval:    Interval of the counter
    ...              :param delay:    delay for checking PM counters after specified period
    Log Action To Console   Wait For Next PM measurements period
    gnbcounter.Wait For Next Pm Period    ${interval}    ${delay}

Trigger E-CID initialization request
    [Documentation]    The keyword triggers E-CID messages netween NLS server attached to AMF-NALA and Real UE
    Log Action To Console    Trigger E-CID request from LMF to gNB
    ${date}=    Get Current Date   result_format=%Y_%m_%d_%H_%M_%S
    ${pcap_file}=    Set variable    ecid_${date}.pcap
    ${bts_id}=    Set variable    0
    Start Tcpdump on gNB    ${pcap_file}   bts_id=${bts_id}
    Set Test Variable    ${pcap_ecid_path}    ${pcap_file}
    ssh.connect_to    hostname=10.27.227.254    username=root    password=nls72NSN    alias=LMF_conn
    ssh.execute    cd /root/CB012207 && curl -v http://10.27.227.254:9210 -d @gnala-001019001210607.xml    connection=LMF_conn
    Sleep   30s
    Stop Tcpdump on gNB    ${pcap_file}   bts_id=${bts_id}

Verify E-CID request received and measurements correct
    Log Action To Console    Check If E-CID request is received and if response with measurements is sent
    Verify Ecid Messages    pcap_file=${LOG_PATH}/${pcap_ecid_path}
