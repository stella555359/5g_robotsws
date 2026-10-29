# *** Settings ***
# Documentation     author: Zhao Xiaofei
# ...               contact: xiaofei.zhao@nokia-sbell.com
# ...               squad group: mmW_05
# ...               feature : CB007403_5GC000795
# 
# Force Tags    SBTS00    SBTS22R3    RAN_5G    CA_5G_RRM
# ...    PY36
# ...           RAN_5G_TDD    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEUD_ENB
# 
# Library     taf.rfrl.bts.commissioning    WITH NAME   commissioning
# Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007608_A_B/Resources/testline.robot
# Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007608_A_B/Resources/pmcounters.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ipsl.robot
# Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007608_A_B/X2_pcap_checks.robot
# Library     taf.ue    WITH NAME    ute_ue
# Library     taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands
# Library     taf.collectors.tcpdump      WITH NAME   tcpdump
# Library     taf.collectors.btslog       WITH NAME   btslog
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup
# ...    AND     CI_interface.Common Suite Setup
# Suite Teardown       Run Keywords    robot_common_operations.Common Suite Teardown
# ...    AND     Teardown TL
# Test Setup           robot_common_operations.Common Case Setup 
# Test Teardown        robot_common_operations.Common Case Teardown
# 
# *** Variables ***
# ${ipsl_config_dir}         C:/Tools/IPSL_tool/IPSL/TA_UTE
# ${withPMcountersCheck}     true
# ${5G_source_gNB}           ${0}
# ${Cell}                    1
# ${P_console}               true
# ${ue_id}                   ${0}
# &{qci_port_mapping}        7=50007    8=50008    9=50009    5=50005    6=50006    69=50069    70=50070
# ${P_DL_COUNTER}            0
# ${ipsl_listen_port}        13868
# ${ipsl_alias}              ipsl
# ${gnb_index}               0
# ${IPSLDIR}                 ${CURDIR}/../CB007608_A_B
# ${scfc_file}               ${CURDIR}/scf/CB007403_5GC000281_5GC000795.xml
# ${UE_CAPABILITIES}      REAL_UE
# ${TPUT_DURATION}        200s
# ${TPUT_BANDWITH}        10
# ${TPUT_DEVIATION}       0
# ${TPUT_TARGET}          0.5
# ${UE_TYPE}              samsung
# 
# *** Test Cases ***
# CB007403_5GC000795_A_1_SgNbAddition_successful_with_eight_E_RAB_for_one_UE
#     [Documentation]    This test case is used to verify the signalling of SgNB Addition procedure with multiple DRBs on one UE
#     ...    and also verify the counters update.
#     [Tags]    SBTS00    5GC000795    SBTS22R3
#     [Setup]    Perform Preconditions of each Test    ipsl_template_dir=${IPSLDIR}/ipsl_5GC000795-A1/
#     Wait until the next Measurement Period starts
#     Reboot Qualcomm Ue and wait for reconnection
#     power_ue.Prepare UE    ue_type=${UE_TYPE}
#     ${5Grach_ed}    power_ue.UE Attach    ue_type=${UE_TYPE}    attach_mode=5G_NSA
#     power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}    4G_check=False
#     sleep    5s
#     Stop TCPdump on eNB
#     Check number of SgNBModificationRequest due to radio reasons is zero
#     Check number of SgNBReleaseRequired due to user-inactivity is zero
#     Check number of SgNBReleaseRequired due to UE-lost is zero
#     Check number of SgNBAdditionRequest equal   ${1}
#     sleep    10s
#     Wait until the current Measurement Period stops
#     ${PM_dir}=     run keyword if    '${withPMcountersCheck}'=='true'   pmcounters.Collect PM Counter    gnb_id=${5G_source_gNB}
#     ...    collector_alias=pm_counters
#     run keyword if    '${withPMcountersCheck}'=='true'     pmcounters.Check PM counter value equal     5   ${PM_dir}
#     ...   M55112C03001   NRCELL-${Cell}
#     run keyword if    '${withPMcountersCheck}'=='true'     pmcounters.Check PM counter value equal     5   ${PM_dir}
#     ...   M55112C03002   NRCELL-${Cell}
#    [Teardown]    Run Keywords    Perform Postconditions of each Test
# 
# 
# CB007403_5GC000795_B_5_Stability_SgNB_Modification_setup_and_delete_E-RABs_for_one_Ue
#     [Documentation]    This user scenario is to verifies multi SCG DRBs add and delete successfully
#     ...    it is Stability testing, cycle time is 10. it add and delete qci8 in cycle.
#     [Tags]    SBTS00    CB007608    SBTS22R3
#     [Setup]    Perform Preconditions of each Test    ipsl_template_dir=${IPSLDIR}/ipsl_5GC000795-B5/
#     Wait until the next Measurement Period starts
#     Reboot Qualcomm Ue and wait for reconnection
#     power_ue.Prepare UE    ue_type=${UE_TYPE}
#     ${5Grach_ed}    power_ue.UE Attach    ue_type=${UE_TYPE}    attach_mode=5G_NSA
#     power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}    4G_check=False
#     sleep    20s
#     Stop TCPdump on eNB
#     Check number of SgNBModificationRequest due to radio reasons is zero
#     Check number of SgNBReleaseRequired due to user-inactivity is zero
#     Check number of SgNBReleaseRequired due to UE-lost is zero
#     Check number of SgNBAdditionRequest equal   ${1}
#     Check number of successful SgNBAdditionRequestAcknowledge equal    ${1}
#     Check number of SgNBModificationRequest addition equal    ${10}
#     Check number of SgNBModificationRequest deletion equal    ${10}
#     Check number of successful SgNBModificationRequestAcknowledge equal     ${20}
#     Check number of successful SgNBReconfigurationComplete equal    ${21}
#     Wait until the current Measurement Period stops
#     ${PM_dir}=     run keyword if    '${withPMcountersCheck}'=='true'   pmcounters.Collect PM Counter    gnb_id=${5G_source_gNB}
#     ...    collector_alias=pm_counters
#     run keyword if    '${withPMcountersCheck}'=='true'     pmcounters.Check PM counter value equal     11   ${PM_dir}
#     ...   M55112C03001   NRCELL-${Cell}
#     run keyword if    '${withPMcountersCheck}'=='true'     pmcounters.Check PM counter value equal     10   ${PM_dir}
#     ...   M55112C03003   NRCELL-${Cell}
#     [Teardown]    Run Keywords    Perform Postconditions of each Test
# 
# CB007403_5GC000795_A_2_SgNbAddition_successful_with_eight_E-RAB_DL_traffic_for_one_UE
#     [Documentation]    This test case is used to verify user data DL or UL traffic after of SgNB Addition procedure with multiple DRBs on one UE
#     [Tags]    SBTS00    5GC000710    SBTS22R3
#     [Setup]    Perform Preconditions of each Test    ipsl_template_dir=${IPSLDIR}/ipsl_5GC000795-A2/
#     Reboot Qualcomm Ue and wait for reconnection
#     sleep    5s
#     power_ue.Prepare UE    ue_type=${UE_TYPE}
#     ${5Grach_ed}    power_ue.UE Attach    ue_type=${UE_TYPE}    attach_mode=5G_NSA
#     power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}    4G_check=False
#     sleep    20s
#     ${list_of_cell_ids}    Create List    32374815
#     power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=${TPUT_BANDWITH}M    duration=${TPUT_DURATION}    ue_type=${UE_TYPE}
#     ...    protocol=udp    iperf_port=45009
#     power_ue.Start traffic    ue_index=${0}    direction=ul    throughput=${TPUT_BANDWITH}M    duration=${TPUT_DURATION}    ue_type=${UE_TYPE}
#     ...    protocol=udp    iperf_port=45010    iperf_type=via_command
#     ${log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    filter=L2Lo    duration=${TPUT_DURATION}
#     ${all_tp}    power_ue.Check Tput    ue_type=${UE_TYPE}    direction=DL    log=${log}    cells=${list_of_cell_ids}
#     ...    target_throughput=${TPUT_BANDWITH}    target_avg_percent=${TPUT_TARGET}    min_percent=${TPUT_DEVIATION}
#     ${all_tp2}    power_ue.Check Tput    ue_type=${UE_TYPE}    direction=UL    log=${log}    cells=${list_of_cell_ids}
#     ...    target_throughput=${TPUT_BANDWITH}    target_avg_percent=${TPUT_TARGET}    min_percent=${TPUT_DEVIATION}
#     Stop TCPdump on eNB
#     Check number of SgNBModificationRequest due to radio reasons is zero
#     Check number of SgNBReleaseRequired due to user-inactivity is zero
#     Check number of SgNBReleaseRequired due to UE-lost is zero
#     Check number of SgNBAdditionRequest equal   ${1}
#     ${target_qci_list}    create list   6   7   8
#     Check QCIs in SgNBAdditionRequest   ${target_qci_list}
#     Check number of successful SgNBAdditionRequestAcknowledge equal   ${1}
#     Check number of successful SgNBReconfigurationComplete equal     ${1}
#     [Teardown]    Run Keywords    Perform Postconditions of each Test
# 
# *** Keywords ***
# Perform Preconditions of each Test
#     [Arguments]    ${ipsl_template_dir}
#     BuiltIn.Log   start preconditions    console=${P_console}
#     BuiltIn.Log   check cells on air    console=${P_console}
#     Connect to gnb coam via ssl
#     COAM Check GNB cell on air
#     COAM Teardown gnb connections
#     Create testcase log directory
#     BuiltIn.Log    ${\n}Start IPSL        console=${P_console}
#     IPSL server preparation        ${ipsl_template_dir}    ${ipsl_config_dir}   ${ipsl_alias}    ${ipsl_listen_port}
#     BuiltIn.Log   setup tshark    console=${P_console}
#     setup tshark    eth1    ssh_password=iW_K#8.ute%A10h0m0ra
#     BuiltIn.Log   start TCPdump    console=${P_console}
#     Start TCPdump on eNB
#     sleep    5s
#     BuiltIn.Log   start syslog    console=${P_console}
#     Kill fsyslog process
# #    Start Btslog
# 
# Perform Postconditions of each Test
#     BuiltIn.Log   Postconditions    console=${P_console}
#     Turn on Airplane Mode
# #   Stop Btslog
#     Run Keyword If Test Failed    pmcounters.Collect Snapshot
#     teardown all aliases for tshark
# 
# Kill fsyslog process
#     ${testpc_alias}=    connect.Connect to TestPC
#     ssh.execute    command=pkill fsyslog    connection=${testpc_alias}
#     ssh.disconnect    connection=${testpc_alias}
# 
# Connect to UE PC
#     [Documentation]   :Author: Jing Liang
#     ...     Setup ssh connection to UE control PC
#     ...     :param ue_id: (optional) ue id
#     ...     :param alias: (optional) alias used for ssh connection
#     ...     :return: alias for ssh connection to Testpc
#     [Arguments]    ${ue_id}=${0}    ${alias}=ssh-ue-pc-${ue_id}
#     ssh.Connect to    hostname=${tl.ues[${ue_id}].ssh_connection_details.addr}
#     ...    username=${tl.ues[${ue_id}].ssh_connection_details.username}
#     ...    password=${tl.ues[${ue_id}].ssh_connection_details.password}
#     ...    alias=${alias}
#     [Return]    ${alias}
# 
# Reboot Qualcomm Ue
#     [Documentation]    :Author: Nikolay Shkulepov
#     ...    This a HIGH Level Keyword which reboots Qualcomm UE.
#     ...    Important: if that keyword works, then your TL is properly configured; otherwise please reference to
#     ...    the following http://files.ute.nsn-rdnet.net/package_documentation/ute_ue/interfaces/ute_ue.html.
#     ...    :param  ue_id: (default 0) the ID of UE, Integer or String
#     [Arguments]    ${ue_id}=0
#     ${testpc_alias}=    Connect to UE PC    ue_id=${ue_id}
#     ssh.Send Command    adb reboot    connection=${testpc_alias}
#     ${output}=    ssh.Read Output    connection=${testpc_alias}
#     BuiltIn.Log    Reboot Qualcomm Ue_${ue_id}: stdoutStr = ${output}    level=DEBUG
#     ${ue_alias}=    Get Ue Alias    ue_id=${ue_id}
#     BuiltIn.Log    Qualcomm Ue [${ue_alias}] rebooted    console=${P_console}
#     [Teardown]    ssh.disconnect    connection=${testpc_alias}
# 
# Get Ue Alias
#     [Documentation]    :Author: Jing Liang
#     ...    :param  ue_id: (default 0) the ID of UE, Integer or String
#     ...    :return: ue alias for ute_ue
#     [Arguments]    ${ue_id}=0
#     ${ue_alias}=    Set Variable    UE_${ue_id}
#     set suite variable      ${ue_alias}
#     [Return]    ${ue_alias}
# 
# Delete pyro logs
#     [Documentation]    :Author: Vasileios Papoutsis
#     ...    Delete pyro logs from qualcomm test pc.
#     ...    :param  ue_id: (default 0) the ID of UE, Integer or String
#     [Arguments]    ${ue_id}=0
#     ${testpc_alias}=    connect.Connect to UE PC    ue_id=${ue_id}
#     ${log_files}=    Create list    ta_ue_uepc_local.log    ta_uepc_pyro.log
#     FOR    ${file}    IN    @{log_files}
#         ssh.Send Command    command=rm ${tl.ues[${ue_id}].server_dir}/logs/${file}    connection=${testpc_alias}
#     END
#     [Teardown]    ssh.disconnect    connection=${testpc_alias}
# 
# Start IPSL
#     [Arguments]    ${ipsl_config_dir}    ${ipsl_template_dir}
#     connect to IPSL server
#     Stop IPSL server process
#     Replace IPSL config files    ${ipsl_config_dir}    ${ipsl_template_dir}
#     compile files and start IPSL server    ${ipsl_config_dir}
#     Verify IPSL server process is started
# 
# Start TCPdump on eNB
#     [Documentation]    :Author: Soenke Kullberg
#     ...     Start tcpdump on eNB common unit on interface brl
#     [Arguments]    ${enb_id}=${0}
#     ${oam_ssh_config}=  Create Dictionary
#     ...     host=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.addr}
#     ...     user=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.username}
#     ...     password=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.password}
#     tcpdump.create_tcpdump_collector
#     ...     name=enb${enb_id}_s1x2_tcpdump
#     ...     options=-i br1 -s0 sctp or icmp
#     ...     executor=${oam_ssh_config}
#     tcpdump.setup_collectors    names=enb${enb_id}_s1x2_tcpdump
#     tcpdump.start_collectors    names=enb${enb_id}_s1x2_tcpdump
#     tcpdump.set_suite_alias     enb${enb_id}_s1x2_tcpdump
#     [Return]  enb${enb_id}_s1x2_tcpdump
# 
# Stop TCPdump on eNB
#     [Documentation]    :Author: Soenke Kullberg
#     ...     Stop tcpdump on eNB and store logs in Log directory
#     ...     :param target_dir: Directory to store the pcap file
#     ...     :return tcpdump_path: Path to tcpdump pcap file
#     [Arguments]    ${enb_id}=${0}    ${target_dir}=None
#     ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
#     ...    ELSE    Set Variable    ${target_dir}
#     tcpdump.stop_collectors         names=enb${enb_id}_s1x2_tcpdump
#     tcpdump.collect_collectors      names=enb${enb_id}_s1x2_tcpdump   target_dir=${target_dir}
#     tcpdump.teardown_collectors     names=enb${enb_id}_s1x2_tcpdump
#     [RETURN]    ${target_dir}/enb${enb_id}_s1x2_tcpdump/enb${enb_id}_s1x2_tcpdump.pcap
# 
# Start Btslog
#     [Documentation]    :Author: Soenke Kullberg
#     ...     KW starts Btslog on Testpc with log-collector
#     ...     https://confluence.int.net.nokia.com/display/EE/EE+BTSlog
#     ...     *Note:* KW works only on ute-vm
#     Return From Keyword If  '${tl.test_pc.default_ssh_connection_details.username}'!='ute'   message=Works only on Cloud
#     ${testpc_ssh_config}=  Create Dictionary
#     ...     host=${tl.test_pc.default_ssh_connection_details.addr}
#     ...     user=${tl.test_pc.default_ssh_connection_details.username}
#     ...     password=${tl.test_pc.default_ssh_connection_details.password}
#     ${btslog_collector_name}=   Set Variable    btslog
#     btslog.create_btslog_collector
#     ...     name=${btslog_collector_name}
#     ...     executor=${testpc_ssh_config}
#     btslog.setup_collectors    names=${btslog_collector_name}
#     btslog.start_collectors    names=${btslog_collector_name}
#     btslog.set_suite_alias     ${btslog_collector_name}
# 
# 
# Stop Btslog
#     [Documentation]    :Author: Soenke Kullberg
#     ...    Stop and fetch btslog from Testpc
#     ...    *Note:* KW works only on ute-vm
#     ...    :return path: Path to btslog file
#     ...    :param target_dir: Directory to store the btslog file
#     [Arguments]    ${target_dir}=None
#     Return From Keyword If  '${tl.test_pc.default_ssh_connection_details.username}'!='ute'   message=Works only on Cloud
#     ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
#     ...    ELSE    Set Variable    ${target_dir}
#     ${btslog_collector_name}=   Set Variable    btslog
#     btslog.stop_collectors         names=${btslog_collector_name}
#     # WA for https://jira3.int.net.nokia.com/browse/TALIB-854
#     Builtin.Sleep   15 sec      # wait for btslog to close
#     # WA for https://jira3.int.net.nokia.com/browse/TALIB-854
#     btslog.collect_collectors      names=${btslog_collector_name}   target_dir=${target_dir}
#     btslog.teardown_collectors     names=${btslog_collector_name}
#     [RETURN]    ${target_dir}/${btslog_collector_name}/syslog_files.tgz
# 
# Kill all iperf process
#    ssh.Connect_to      hostname=${tl.test_pc.default_ssh_connection_details.addr}
#    ...                 username=${tl.test_pc.default_ssh_connection_details.username}
#    ...                 password=${tl.test_pc.default_ssh_connection_details.password}
#    ...                 alias=ssh-AppSvr
#    Run Keyword and ignore error    ssh.Execute    killall -9 iperf    connection=${ssh-AppSvr}
# 
# Teardown TL
#     connect to IPSL server
#     Stop IPSL server process
#     Kill all iperf process
#     Disconnect all available ssh connections
# 
# Start DL traffic
#     [Arguments]        ${duration}    ${throughput}   ${qci}   ${ue_id}=${0}
#     return from keyword if  '${throughput}' == '0Mbits/sec'
#     ${traffic_alias}=   Start DL Data Transfer Qualcomm Ue   ue_id=${ue_id}   duration=${duration}
#     ...        throughput=${throughput}  qci=${qci}
#     [Return]    ${traffic_alias}
# 
# Start UL traffic
#     [Arguments]        ${duration}    ${throughput}   ${qci}   ${ue_id}=${0}
#     return from keyword if  '${throughput}' == '0Mbits/sec'
#     ${traffic_alias}=   qualcomm.Start UL Data Transfer Qualcomm Ue   ue_id=${ue_id}   duration=${duration}
#     ...        throughput=${throughput}  qci=${qci}    packet_size=1330
#     [Return]    ${traffic_alias}
# 
# Remove Airplane Mode
#     [Arguments]    ${ue_index}=${ue_id}    ${serial_number}=${tl.ues[${ue_id}].serial_number}
#     ${status1}    Check airplane mode status on    ue_index=${ue_id}
#     Get product brand
#     Get all pointer variable
#     Run Keyword Unless	    '${status1}' == 'False'	   Run Keywords     Connect to control pc via cygwin    ue_index=${ue_id}
#     ...     AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_id}
#     ...    close_task=${close_task}
#     ${status2}    Check airplane mode status on    ue_index=${ue_id}
#     [Return]    ${status2}
# 
# Turn on Airplane Mode
#     [Arguments]    ${ue_index}=${ue_id}    ${serial_number}=${tl.ues[${ue_id}].serial_number}
#     ${status1}    Check airplane mode status on    ue_index=${ue_id}
#     Get product brand
#     Get all pointer variable
#     Run Keyword Unless	    '${status1}' == 'True'	   Run Keywords     Connect to control pc via cygwin    ue_index=${ue_id}
#      ...     AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_id}
#      ...    close_task=${close_task}
#      ${status2}    Check airplane mode status on    ue_index=${ue_id}
#      [Return]    ${status2}
# 
# Reboot Qualcomm Ue and wait for reconnection
#     [Documentation]    :Author: Vasileios Papoutsis
#     ...    Reboot Qualcomm Ue and wait until it is up again
#     [Arguments]    ${ue_id}=0    ${timeout}=${240}
#     Reboot Qualcomm Ue    ue_id=${ue_id}
#     Wait until keyword succeeds    ${timeout}    5 sec    Qualcomm Ue is connected    ue_id=${ue_id}
#     ${ue_alias}=    Get Ue Alias    ue_id=${ue_id}
#     BuiltIn.Log    Qualcomm Ue [${ue_alias}] reconnected    console=${P_console}
# 
# Qualcomm Ue is connected
#     [Documentation]    :Author: Vasileios Papoutsis
#     ...    Check if Qualcomm Ue is connected
#     [Arguments]    ${ue_id}=0
#     ${testpc_alias}=    connect.Connect to UE PC    ue_id=${ue_id}
#     ssh.Send command    adb devices    connection=${testpc_alias}
#     ${output}=    ssh.Read output    connection=${testpc_alias}
#     BuiltIn.Log    ${\n}Qualcomm UE_${ue_id} Id=${output}    console=${P_console}
#     Should contain    ${output}    ${tl.ues[${ue_id}].serial_number}
#     [Teardown]    ssh.disconnect    connection=${testpc_alias}
# 
# Perform Comissioning
#     Log to console   \n--Perform Comissioning--\n
#     Set Scfc file path
#     commissioning.Perform Full Commissioning On Classical Gnb    bts_id=0    scf_path=${scfc_file}
#     COAM Wait for gnb ready and cell setup    timeout=20min
# 
# Set Scfc file path
#     Set Suite Variable    ${scfc_file}
