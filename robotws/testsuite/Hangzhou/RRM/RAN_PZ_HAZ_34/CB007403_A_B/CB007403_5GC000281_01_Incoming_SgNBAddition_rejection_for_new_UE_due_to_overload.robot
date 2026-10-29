# *** Settings ***
# Documentation
# ...     author: echo.xu
# ...     contact: echo.xu@nokia-sbell.com
# ...     feature : CB007403_5GC000281
# 
# Force Tags    SBTS00    SBTS22R3    RAN_5G    CA_5G_RRM
# ...    PY36
# ...           RAN_5G_TDD    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEUD_ENB
# Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup
# ...    AND     CI_interface.Common Suite Setup
# Suite Teardown       robot_common_operations.Common Suite Teardown
# Test Setup           robot_common_operations.Common Case Setup 
# Test Teardown        robot_common_operations.Common Case Teardown
# 
# Library        taf.rfrl.bts.commissioning    WITH NAME   commissioning
# Library        taf.rfrl.ue
# Library	       testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007403_A_B/Resources/5GC000281_keywords.py
# Library        taf.collectors.tcpdump      WITH NAME   tcpdump
# Resource       testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007608_A_B/Resources/pmcounters.robot
# Resource       testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007608_A_B/Resources/testline.robot
# Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Library        ute_tshark
# Library        taf.collectors.btslog       WITH NAME   btslog
# Variables      testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007608_A_B/Resources/CB007608_5GC000281_enabling_ovl_parameters.py
# Resource       taf/rfrl/bts/robot/common/gnb_scf.robot
# Library        taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands
# Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource       ../../../resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# *** Variables ***
# ${DIST_NAME}               MRBTS-{}/NRBTS-{}
# ${scfc_file}               ${CURDIR}/scf/CB007403_5GC000281_5GC000795.xml
# ${ue_id}                   ${0}
# ${withPMcountersCheck}     true
# ${5G_source_gNB}           ${0}
# ${Cell}                    1
# ${gnb_index}               0
# ${ue_index}                0
# 
# *** Test Cases ***
# CB007403_5GC000281_01_Incoming_SgNBAddition_rejection_for_new_UE_due_to_overload
#     [Documentation]     This test case verifies if feature activation and deactivation is successful when gNB is already in OVL state.
#     ...     Additionally, test case verifies if new UE is not allowed to connect due to overload.
#     [Tags]    SBTS00    SBTS22R3    5GC000281
#     [Setup]        Test Setup
#     Log to console    session 1
#     Wait until the next Measurement Period starts
#     Create testcase log directory
#     Change ovlNsaAddRej parameter    param_value=${enable_ovlNsaAddRej}
#     Enable OVL
#     setup tshark    eth1    ssh_password=iW_K#8.ute%A10h0m0ra
#     Start TCPdump on eNB    log_num=1
#     sleep    5s
#     ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
#     Set test variable    ${ue_type}
#     Attach UE to CELL
#     Detach UE to CELL
#     Wait until the current Measurement Period stops
#     Verify counter update           #expected_value==1
#     Stop TCPdump on eNB    log_num=1
#     Log to console    session 2
#     Check SgNBAdditionRequestReject element    log_num=1    num_instances=0    enb_id=0
#     Wait until the next Measurement Period starts
#     Change ovlNsaAddRej parameter    param_value=${disable_all_ovl_parameters}
#     Start TCPdump on eNB    log_num=2
#     sleep    5s
#     ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
#     Set test variable    ${ue_type}
#     Attach UE to CELL_1
#     Detach UE to CELL
#     Wait until the current Measurement Period stops
#     Verify counter not update        #expected_value=0
#     Stop TCPdump on eNB    log_num=2
#     Check Attach EN-DC    log_num=2    num_instances0=0    num_instances1=0    enb_id=0
#     Log to console    session 3
#     Change actCuOvlProt parameter    param_value=false
#     Start TCPdump on eNB    log_num=3
#     sleep    5s
#     ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
#     Set test variable    ${ue_type}
#     Attach UE to CELL_1
#     Detach UE to CELL
#     Verify counter not update 2        #expected_value=0
#     Stop TCPdump on eNB    log_num=3
#     Check Attach EN-DC    log_num=3    num_instances0=0    num_instances1=0    enb_id=0
#     Change actCuOvlProt parameter    param_value=true
#     [Teardown]    Run Keywords    Test Teardown
# 
# 
# 
# *** Keywords ***
# Test Setup
#     Log to console    \n--Test Setup--\n
#     #Set Scfc file path
#     #Perform Comissioning
#     Start Btslog
# 
# Set Scfc file path
#     Set Suite Variable    ${scfc_file}
# 
# Perform Comissioning
#     Log to console   \n--Perform Comissioning--\n
#     commissioning.Perform Full Commissioning On Classical Gnb    bts_id=0    scf_path=${scfc_file}
#     COAM Wait for gnb ready and cell setup    timeout=20min
# 
# Change ovlNsaAddRej parameter
#     [Arguments]    ${param_value}
#     [Documentation]     This keyword changes value of ovlNsaAddRej parameter on Classical gNB
#     ...                 :param param_value: expected value of ovlNsaAddRej parameter
#     Log To Console    \n--Change ovlNsaAddRej parameter--\n
#     Perform configuration parameter recommissioning on gNB    dist_name=${DIST_NAME}
#     ...  param_name=cuOvlHa     param_value=${param_value}     skip_parameter_relation_errors=true
#     ...  timeout=300
#     COAM Wait for gnb ready and cell setup    timeout=20min
# 
# Enable OVL
#     set ovlthreshold to specific value      0
#     Log to console    OVL Enabled
# 
# Disable OVL
#     set ovlthreshold to specific value      20
#     Log to console    OVL Disabled
# 
# Verify counter update
#     ${PM_dir}=     run keyword if    '${withPMcountersCheck}'=='true'   pmcounters.Collect PM Counter    gnb_id=${5G_source_gNB}
#     ...    collector_alias=pm_counters
#     run keyword if    '${withPMcountersCheck}'=='true'     pmcounters.Check PM counter value equal     1   ${PM_dir}
#     ...   M55112C05501   NRCELL-${Cell}
# 
# Verify counter not update
#     ${PM_dir}=     run keyword if    '${withPMcountersCheck}'=='true'   pmcounters.Collect PM Counter    gnb_id=${5G_source_gNB}
#     ...    collector_alias=pm_counters2
#     run keyword if    '${withPMcountersCheck}'=='true'    pmcounters.Check PM counter value equal     0   ${PM_dir}
#     ...   M55112C05501   NRCELL-${Cell}
# 
# Verify counter not update 2
#     ${PM_dir}=     run keyword if    '${withPMcountersCheck}'=='true'   pmcounters.Collect PM Counter    gnb_id=${5G_source_gNB}
#     ...    collector_alias=pm_counters3
#     run keyword if    '${withPMcountersCheck}'=='true'    pmcounters.Check PM counter value equal     0   ${PM_dir}
#     ...   M55112C05501   NRCELL-${Cell}
# 
# Attach UE to CELL
#     power_ue.Prepare UE     ue_type=${ue_type}    ui_version=S21UI3.1
#     ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
# 
# Attach UE to CELL_1
#     ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
#     power_ue.Verify attach     ue_type=${ue_type}     4G_check=False     5Grach_ed=${5Grach_ed}
# 
# Detach UE to CELL
#     Run keyword And Ignore Error    power_ue.UE Detach     ue_type=${ue_type}
# 
# Start TCPdump on eNB
#     [Documentation]    :Author: Soenke Kullberg
#     ...     Start tcpdump on eNB common unit on interface brl
#     [Arguments]    ${log_num}    ${enb_id}=${0}
#     ${oam_ssh_config}=  Create Dictionary
#     ...     host=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.addr}
#     ...     user=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.username}
#     ...     password=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.password}
#     tcpdump.create_tcpdump_collector
#     ...     name=enb${enb_id}_${log_num}_s1x2_tcpdump
#     ...     options=-i br1 -s0 sctp or icmp
#     ...     executor=${oam_ssh_config}
#     tcpdump.setup_collectors    names=enb${enb_id}_${log_num}_s1x2_tcpdump
#     tcpdump.start_collectors    names=enb${enb_id}_${log_num}_s1x2_tcpdump
#     tcpdump.set_suite_alias     enb${enb_id}_${log_num}_s1x2_tcpdump
#     [Return]  enb${enb_id}_${log_num}_s1x2_tcpdump
# 
# Stop TCPdump on eNB
#     [Documentation]    :Author: Soenke Kullberg
#     ...     Stop tcpdump on eNB and store logs in Log directory
#     ...     :param target_dir: Directory to store the pcap file
#     ...     :return tcpdump_path: Path to tcpdump pcap file
#     [Arguments]    ${log_num}    ${enb_id}=${0}    ${target_dir}=None
#     ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
#     ...    ELSE    Set Variable    ${target_dir}
#     tcpdump.stop_collectors         names=enb${enb_id}_${log_num}_s1x2_tcpdump
#     tcpdump.collect_collectors      names=enb${enb_id}_${log_num}_s1x2_tcpdump   target_dir=${target_dir}
#     tcpdump.teardown_collectors     names=enb${enb_id}_${log_num}_s1x2_tcpdump
#     [RETURN]    ${target_dir}/enb${enb_id}_s1x2_tcpdump/enb${enb_id}_${log_num}_s1x2_tcpdump.pcap
# 
# Check SgNBAdditionRequestReject element
#     [Documentation]   Check SgNBAdditionRequestReject element
#     [Arguments]    ${log_num}    ${num_instances}     ${enb_id}=0
#     log to console     Check SgNBAdditionRequestReject element
#     ${target_dir}=    testline.Get Testcase Log Directory
#     ${output}    ute_tshark.read pcap    packet_filter=x2ap.SgNBAdditionRequestReject_element    output_type=pdml
#     ...   pcap_file_path=${target_dir}/enb${enb_id}_${log_num}_s1x2_tcpdump/enb${enb_id}_${log_num}_s1x2_tcpdump.pcap
#      ${SgNBAdditionRequest}  Get Element count  ${output}
#      ...    .//field[@name='x2ap.SgNBAdditionRequestReject_element']
#     log to console    detected SgNBAdditionRequestReject ${SgNBAdditionRequest}
#     should not be equal  ${SgNBAdditionRequest}     ${num_instances}
# 
# Check Attach EN-DC
#     [Documentation]   This keyword verifies if attach EN-DC is successful
#     [Arguments]     ${log_num}    ${num_instances0}    ${num_instances1}     ${enb_id}=0
#     log to console     Check ig attach EN-DC is successful
#     ${target_dir}=    testline.Get Testcase Log Directory
#     ${output}    ute_tshark.read pcap    packet_filter=x2ap.SgNBReconfigurationComplete_element    output_type=pdml
#     ...   pcap_file_path=${target_dir}/enb${enb_id}_${log_num}_s1x2_tcpdump/enb${enb_id}_${log_num}_s1x2_tcpdump.pcap
#      ${SgNBReconfigurationComplete}  Get Element count  ${output}
#      ...    .//field[@name='x2ap.SgNBReconfigurationComplete_element']
#     log to console    detected SgNBReconfigurationComplete ${SgNBReconfigurationComplete}
#     should not be equal  ${SgNBReconfigurationComplete}    ${num_instances0}
#     ${output}    ute_tshark.read pcap    packet_filter=x2ap.procedureCode == 29    output_type=pdml
#     ...   pcap_file_path=${target_dir}/enb${enb_id}_${log_num}_s1x2_tcpdump/enb${enb_id}_${log_num}_s1x2_tcpdump.pcap
#     ${SgNBAdditionRequest}  Get Element count  ${output}
#      ...    .//field[@name='x2ap.SgNBAdditionRequest_element']//field[@name='x2ap.scgFailureInfo']
#     log to console    detected SgNBAdditionRequest ${SgNBAdditionRequest}
#     should be equal as strings  ${SgNBAdditionRequest}    ${num_instances1}
# 
# Change actCuOvlProt parameter
#     [Arguments]    ${param_value}
#     [Documentation]     This keyword changes value of actCuOvlProt parameter on Classical gNB
#     ...                 :param param_value: expected value of actCuOvlProt parameter
#     Log To Console    \n--Change actCuOvlProt to ${param_value}--\n
#     Perform configuration parameter recommissioning on gNB    dist_name=${DIST_NAME}
#     ...  param_name=actCuOvlProt    param_value=${param_value}     skip_parameter_relation_errors=true
#     ...  timeout=300
#     COAM Wait for gnb ready and cell setup    timeout=20min
# 
# Test Teardown
#     Log to console   \n--End Test--\n
#     Run Keyword If Test Failed    pmcounters.Collect Snapshot
#     Disable OVL
#     #Stop Btslog
#     Disconnect all available ssh connections
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
# Report to QC
#     [Arguments]  ${testcase_name}    ${qc_test_set_name}    ${qc_test_set_path}
#     set test variable   ${testcase_name}
#     set test variable   ${qc_test_set_name}
#     Report    ${testcase_name}    ${testcase_name}    ${qc_test_set_name}    ${qc_test_set_path}
