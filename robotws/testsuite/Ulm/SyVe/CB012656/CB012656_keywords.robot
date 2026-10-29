*** Settings ***
Documentation   Resources file for feature 'CB012656'
...             Team: 'MN 5G&SC PZ ULM 2 SqdGp62'
...             Email: 'I_MN_5GSC_PZ_ULM_SQD_62@nokia.com'
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.sbts.oam.coam.admin                           WITH NAME   admin
Library    taf.config.scf                                    WITH NAME   scf
Library    ute_tshark
Library    ../../resources/Common/python/alarm_handling.py   WITH NAME   alarm
Library    ../../resources/Common/python/MCSharkDissectors.py

Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/testline.robot
Resource    ../../resources/Common/tcpdump.robot
Resource    ../../resources/Common/alarm_handling.robot

Resource    ../resources/attenuator.robot
Resource    ../resources/attenuator_scenario.robot
Resource    ../resources/syve_testline.robot
Resource    ../resources/bts_log_analysis.robot
Resource    ../resources/enb.robot
Resource    ../resources/scf_info.robot

Resource    CB012656_verification.robot
Resource    CB012656_commissioning.robot
Resource    CB012656_pm_counter.robot


*** Keywords ***

Prepare TL for Testing
    testline.Create Test Suite Log Folders
    Set correct protocol name for wireshark check

Setup test
    syve_testline.Testline Setup for CCRT
    testline.Create testcase log directory
    attenuator.Set Attenuator to Max Value
    ute_tshark.setup tshark    eth1
    ${alarms_gnb0_before}  alarm_handling.Get All Alarms From Node  node_id=0  node_type=gnb
    set suite variable  ${alarmlist_gnb0_before}  ${alarms_gnb0_before}
    ${alarms_gnb1_before}  alarm_handling.Get All Alarms From Node  node_id=1  node_type=gnb
    set suite variable  ${alarmlist_gnb1_before}  ${alarms_gnb1_before}
    Reset UE On Port

Set correct protocol name for wireshark check
    [Documentation]     checks the wireshark plugins and sets the protocol name
    ...                 for the verification of the wireshark file depending of the installed plugins
    ${ft1ap_filter}  MCSharkDissectors.get_f1ap_tshark_filter_string
    Set Suite Variable  $PROTOCOL_NAME   ${ft1ap_filter}


Perform Preconditions of Test Scenario
   [Arguments]  ${gnb_id}  ${cell}  ${wrr_frequency}  ${non_wrr_frequency}  ${capabilities}  ${enb_id}  ${repeat_rrc_release}
# common TC part
    set test variable  ${gnb_id}
    set test variable  ${cell}
    set test variable  ${repeat_rrc_release}
    set test variable  ${enb_id}
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}
    ${configSuiteDir}=    testline.Get test suite config directory
    gnb.Store Current SCF from gNB  gnb_id=${gnb_id}  target_dir=${configSuiteDir}
    attenuator_scenario.register all attenuators
    ${nrbts_id_1}  scf_info.Get NRBTS-Id  ${gnb_id}
    set test variable  ${nrbts_id_${gnb_id}}  ${nrbts_id_1}
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=${gnb_id}
    taf.ue.Require Ue  ${UE_ALIAS_1}  capabilities=${capabilities}
    ${wrr_frequency_list}  split string  ${wrr_frequency}   ,
    ${number_of_wrr_frequencies}  Get Length  ${wrr_frequency_list}
    set test variable  ${wrr_frequency_list}
    set test variable  ${number_of_wrr_frequencies}
    ${non_wrr_frequency_list}  split string  ${non_wrr_frequency}   ,
    ${number_of_non_wrr_frequencies}  Get Length  ${non_wrr_frequency_list}
    set test variable  	${number_of_non_wrr_frequencies}
    set test variable  ${non_wrr_frequency_list}
    ${number_of_cells_with_reselection}  Evaluate  ${number_of_non_wrr_frequencies}+${number_of_wrr_frequencies}
    set test variable  ${number_of_cells_with_reselection}
# TC specific part
    CB012656_commissioning.Commissioning gNB  test_name=${TEST_NAME}

Reset UE On Port
    [Documentation]  Powers OFF given port, waits a number of seconds and power ON given port.
    [Arguments]      ${time_interval}=5  ${ue_id}=0

    ${pdu}                Set Variable   ${tl.ues[${ue_id}].pdu_port.pdu}
    ${pdu_port_number}    Create List    ${tl.ues[${ue_id}].pdu_port.port_no}
    ${pdu_alias}  pdu.setup_pdu     ${pdu}
    pdu.reset_ports    ports=${pdu_port_number}    time_interval=${time_interval}    pdu_device=${pdu_alias}
    Sleep  30s  reason=wait for ue reboot

Start neccessary traces
    tcpdump.Start Tcpdump on gNB Common Unit  gnb_id=${gnb_id}
    ...                                       collector=tcpdump_gnb_${gnb_id}
    ...                                       options=-i any port 38472 or port 38412 or port 38422 or port 38462 or port 36422
    tcpdump.Start Tcpdump on TestPc  options=-i eth2 sctp  collector=tcpdump_testpc

Start traffic and wait for RRC release
    CB012656_keywords.Start UL and DL traffic on UE
    CB012656_keywords.Await UL and DL traffic
    sleep  15s  reason=wait for inactive state

Start UL and DL traffic on UE
    taf.ue.Start Data Transfer  dt_name=DL_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}  direction=dl  duration=${TRAFFIC.DURATION}
    ...    throughput=${TRAFFIC.DL_THROUGHPUT}    protocol=${TRAFFIC.PROTOCOL}  packet=1320  buffer=16M
#	...  port=${tl.appserver.iperf_details.ports[0]}
    taf.ue.Start Data Transfer  dt_name=UL_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}  direction=ul  duration=${TRAFFIC.DURATION}
    ...    throughput=${TRAFFIC.UL_THROUGHPUT}    protocol=${TRAFFIC.PROTOCOL}  packet=1320  buffer=16M
#	...  port=${tl.appserver.iperf_details.ports[0]}
#    sleep  20s  reason=wait for traffic


Await UL and DL traffic
    Run Keyword And ignore Error  taf.ue.Await Data Transfer Finish  DL_${UE_ALIAS_1}
    Run Keyword And ignore Error  taf.ue.Await Data Transfer Finish  UL_${UE_ALIAS_1}

Stop all traces
    [Arguments]  ${tcpdump_filename}=Xn_traces_gnb.pcap
    ${tcp_file_gnb}  tcpdump.Stop TCP Dump on gNB Common Unit
    ...  collector=tcpdump_gnb_${gnb_id}  tcpdump_filename=${tcpdump_filename}
    set test variable  ${tcp_file_gnb${gnb_id}}  ${tcp_file_gnb}
    ${tcp_file}  tcpdump.Stop Tcpdump on TestPc  collector=tcpdump_testpc
    set test variable  ${tcp_file}  ${tcp_file_gnb}

Verify qc test case
    [Documentation]   check wireshark messages: check messages and correct content
    ...               check traffic: check throughput with deviation
    ...               check hanging resources
    ...               check PM counter
    # check PM counter
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  Run Keyword And Continue On Failure
    ...  CB012656_pm_counter.Check Performance counter  test_name=${TEST_NAME}
    # check wireshark messages common part
    ##e.g. Run Keyword And Continue On Failure    Check HandoverRequired  tcp_file=${tcp_file}
    # check traffic
    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation
    ...  dt_name=DL_${UE_ALIAS_1}  tput=${TRAFFIC.DL_THROUGHPUT}  deviation=${TRAFFIC.TPUT_DEVIATION}  omit=${2}  end=${100}
    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation
    ...  dt_name=UL_${UE_ALIAS_1}  tput=${TRAFFIC.UL_THROUGHPUT}  deviation=${TRAFFIC.TPUT_DEVIATION}  omit=${2}  end=${100}
    Run Keyword And ignore Error  taf.ue.Stop Data Transfer  DL_${UE_ALIAS_1}
    Run Keyword And ignore Error  taf.ue.Stop Data Transfer  UL_${UE_ALIAS_1}
    # check hanging resources
#    hanging_resources.no check of resource nbOfFreeCRNTI
#    hanging_resources.Verify resource usage for all nodes
    # check wireshark messages TC specific part
    Run Keyword And Continue On Failure  CB012656_verification.Verify test case  test_name=${TEST_NAME}

Revert gNB Delta Commissioning
    [Arguments]        ${gnb_id}
    [Documentation]    Commissioning of gnb, create new updated SCF with delta changes.
    ...                Only one file is required for updating gnb with delta changes.

    Log to Console  Revert delta commissioning

    ${configSuiteDir}=    testline.Get test suite config directory
    Create Directory  ${configSuiteDir}/revert_scf
    gnb.Store Current SCF from gNB  gnb_id=${gnb_id}  target_dir=${configSuiteDir}/revert_scf
    scf.calculate delta scf
    ...    target_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml.orig
    ...    actual_scf_path=${configSuiteDir}/revert_scf/SCFC_gNB${gnb_id}_DU.xml
    ...    delta_scf_path=${configSuiteDir}/revert_scf/SCFC_gNB${gnb_id}_revert_${tc_number}.xml

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    ${file1}=  get file  ${configSuiteDir}/revert_scf/SCFC_gNB${gnb_id}_revert_${tc_number}.xml
    IF  ${file1} != []
    ...  admin.Perform_Delta_Recommissioning    delta_file=${configSuiteDir}/revert_scf/SCFC_gNB${gnb_id}_revert_${tc_number}.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}
    Run Keyword And ignore Error  admin.unblock_all_cells  rat=NR  timeout=${10}  connection=${oam_alias}

Perform Postconditions of Test Scenario
    ${alarms_gnb0_after}  alarm_handling.Get All Alarms From Node  node_id=0  node_type=gnb
    set suite variable  ${alarmlist_gnb0_after}  ${alarms_gnb0_after}
    ${alarms_gnb1_after}  alarm_handling.Get All Alarms From Node  node_id=1  node_type=gnb
    set suite variable  ${alarmlist_gnb1_after}  ${alarms_gnb1_after}
    ${cleared_alarms_gnb0}  ${active_alarms_gnb0}  alarm.Check For New Alarms
	...  alarm_list_1=${alarmlist_gnb0_before}
        ...  alarm_list_2=${alarmlist_gnb0_after}
	...  exclude_cleared_alarms=faultId:49
	...  exclude_active_alarms=faultId:49
    Should Be Empty  ${active_alarms_gnb0}
    ${cleared_alarms_gnb1}  ${active_alarms_gnb1}  alarm.Check For New Alarms  ${alarmlist_gnb1_before}  ${alarmlist_gnb1_after}
    Should Be Empty  ${active_alarms_gnb1}
    teardown tshark
    Run Keyword And Ignore Error    tcpdump.Stop Tcpdump on TestPc   collector=tcpdump_testpc
    ${enb_alias}  Setup OAM http session  node_type=enb  node_id=${enb_id}
    Run Keyword And ignore Error  admin.unblock_all_cells  rat=LTE  timeout=${10}  connection=${enb_alias}
    syve_testline.Save current loads
    ${tc_log_directory}=  Get testcase log directory
    ${ue_pc_alias}=  Run Keyword And Ignore Error  connect.Connect to UE PC   ${ue_id}=${1}
    Run Keyword And Ignore Error  ssh.execute  mv /cygdrive/c/taf_ue_proxy/logs/proxy.log ${tc_log_directory}  connection=${ue_pc_alias}
    Revert gNB Delta Commissioning  gnb_id=${gnb_id}

Save all Logs and Teardown TL
    ${suiteBaseDirectory}=  testline . Get test suite result base directory
    IF  '${INITIAL_SCF_FILE_ACTIVATION}' == 'true'  syve_testline.Testline Teardown For CCRT  node_list=gnb_0  gnb_id=${0}
    Run Keyword And ignore Error  filter logs for all gNBs  btslogpath=${suiteBaseDirectory}
    bts_log_analysis.print filtered btslog in log file
