*** Settings ***
Documentation   Resources file for feature 'CB013142'
...             Team: 'MN RAN RD VRF ULM 1'
...             Email: 'ou_mn_ran_rd_vrf_ulm_1_53028392@internal.nsn.com'
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
Resource    ../resources/hanging_resources.robot

Resource    CB013142_verification.robot
Resource    CB013142_commissioning.robot
Resource    CB013142_pm_counter.robot


*** Keywords ***

Prepare TL For Testing
    testline.Create Test Suite Log Folders
    Set Correct Protocol Name For Wireshark Check

Setup Test
    syve_testline.Testline Setup For CCRT
    testline.Create Testcase Log Directory
    attenuator.Set Attenuator To Max Value
    ute_tshark.Setup Tshark    eth1
    ${alarms_gnb0_before}  alarm_handling.Get All Alarms From Node  node_id=0  node_type=gnb
    Set Suite Variable  ${alarmlist_gnb0_before}  ${alarms_gnb0_before}
    ${alarms_gnb1_before}  alarm_handling.Get All Alarms From Node  node_id=1  node_type=gnb
    Set Suite Variable  ${alarmlist_gnb1_before}  ${alarms_gnb1_before}

Set Correct Protocol Name For Wireshark Check
    [Documentation]     checks the wireshark plugins and sets the protocol name
    ...                 for the verification of the wireshark file depending of the installed plugins
    ${ft1ap_filter}  MCSharkDissectors.Get F1ap Tshark Filter String
    Set Suite Variable  $F1AP_WS_DISPLAY_FILTER   ${ft1ap_filter}

Perform Preconditions Of Test Scenario
   [Arguments]  ${gnb_id}  ${p_cell_1}  ${s_cell_1}  ${enb_id}  ${capabilities}  ${s_cell_2}=${1}  ${enb_cell}=${1}
# common TC part
    Set Test Variable  ${gnb_id}
    Set Test Variable  ${p_cell_1}
    Set Test Variable  ${s_cell_1}
    Set Test Variable  ${s_cell_2}
    Set Test Variable  ${enb_id}
    Set Test Variable  ${enb_cell}
    #${meas_period}/${P_MEAS_PERIOD.gnb_${gnb_id}} will be set as suite variable in keyword: Fetch Measurement Period From SCF
    #--> to overcome the problem if in test suite the pm counter interval is different: set variable again to none
    Set Suite Variable    ${meas_period}    ${None}
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}
    ${configSuiteDir}=    testline.Get Test Suite Config Directory
    gnb.Store Current SCF From GNB  gnb_id=${gnb_id}  target_dir=${configSuiteDir}
    attenuator_scenario.Register All Attenuators
    ${nrbts_id_1}  scf_info.Get NRBTS-Id  ${gnb_id}
    Set Test Variable  ${nrbts_id_${gnb_id}}  ${nrbts_id_1}
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=${gnb_id}
    taf.ue.Require Ue  ${UE_ALIAS_1}  capabilities=${capabilities}
# TC specific part
    CB013142_commissioning.Commissioning GNB  test_name=${TEST_NAME}

Start Neccessary Traces
    tcpdump.Start Tcpdump On GNB Common Unit  gnb_id=${gnb_id}
    ...   collector=tcpdump_gnb_${gnb_id}
    ...   options=-i any port 38472 or port 38412 or port 38422 or port 38462 or port 36422 or port 49148 or port 49151 or port 15010
    tcpdump.Start Tcpdump On TestPc  options=-i eth3  collector=tcpdump_testpc

Start Traffic And Wait For RRC Release
    CB013142_keywords.Start UL And DL Traffic On UE
    CB013142_keywords.Await UL And DL Traffic
    Sleep  15s  reason=wait for inactive state

Start UL And DL Traffic On UE
    taf.ue.Start Data Transfer  dt_name=DL_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}  direction=dl  duration=${TRAFFIC.DURATION}
    ...   throughput=${TRAFFIC.DL_THROUGHPUT}    protocol=${TRAFFIC.PROTOCOL}  packet=1320  buffer=16M  apn=ulmsa
    taf.ue.Start Data Transfer  dt_name=UL_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}  direction=ul  duration=${TRAFFIC.DURATION}
    ...    throughput=${TRAFFIC.UL_THROUGHPUT}    protocol=${TRAFFIC.PROTOCOL}  packet=1320  buffer=16M  apn=ulmsa
    Sleep  5s  reason=wait for traffic


Await UL And DL Traffic
    Run Keyword And Ignore Error  taf.ue.Await Data Transfer Finish  DL_${UE_ALIAS_1}
    Run Keyword And Ignore Error  taf.ue.Await Data Transfer Finish  UL_${UE_ALIAS_1}

Stop All Traces
    [Arguments]  ${tcpdump_filename}=Xn_traces_gnb.pcap
    ${tcp_file_gnb}  tcpdump.Stop TCP Dump On GNB Common Unit
    ...  collector=tcpdump_gnb_${gnb_id}  tcpdump_filename=${tcpdump_filename}
    Set Test Variable  ${tcp_file_gnb${gnb_id}}  ${tcp_file_gnb}
    ${tcp_file}  tcpdump.Stop Tcpdump On TestPc  collector=tcpdump_testpc
    Set Test Variable  ${tcp_file}  ${tcp_file_gnb}

Verify Qc Test Case
    [Documentation]   check wireshark messages: check messages and correct content
    ...               check traffic: check throughput with deviation
    ...               check hanging resources
    ...               check PM counter
    # check PM counter
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  Run Keyword And Continue On Failure
    ...  CB013142_pm_counter.Check Performance Counter  test_name=${TEST_NAME}
    # check wireshark messages common part
    ##e.g. Run Keyword And Continue On Failure    Check HandoverRequired  tcp_file=${tcp_file}
    # check traffic
    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation
    ...  dt_name=DL_${UE_ALIAS_1}  tput=${TRAFFIC.DL_THROUGHPUT}  deviation=${TRAFFIC.TPUT_DEVIATION}  omit=${2}  end=${100}
    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation
    ...  dt_name=UL_${UE_ALIAS_1}  tput=${TRAFFIC.UL_THROUGHPUT}  deviation=${TRAFFIC.TPUT_DEVIATION}  omit=${2}  end=${100}
    Run Keyword And Ignore Error  taf.ue.Stop Data Transfer  DL_${UE_ALIAS_1}
    Run Keyword And Ignore Error  taf.ue.Stop Data Transfer  UL_${UE_ALIAS_1}
    # check hanging resources
    hanging_resources.No Check Of Resource NbOfFreeCRNTI
    hanging_resources.Verify Resource Usage For All Nodes
    # check wireshark messages TC specific part
    Run Keyword And Continue On Failure  CB013142_verification.Verify Test Case  test_name=${TEST_NAME}

Revert GNB Delta Commissioning
    [Arguments]        ${gnb_id}
    [Documentation]    Commissioning of gnb, create new updated SCF with delta changes.
    ...                Only one file is required for updating gnb with delta changes.

    Log To Console  Revert delta commissioning

    ${configSuiteDir}=    testline.Get Test Suite Config Directory
    Create Directory  ${configSuiteDir}/revert_scf
    gnb.Store Current SCF From GNB  gnb_id=${gnb_id}  target_dir=${configSuiteDir}/revert_scf
    scf.Calculate Delta SCF
    ...    target_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml.orig
    ...    actual_scf_path=${configSuiteDir}/revert_scf/SCFC_gNB${gnb_id}_DU.xml
    ...    delta_scf_path=${configSuiteDir}/revert_scf/SCFC_gNB${gnb_id}_revert_${tc_number}.xml

    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id}
    ${file1}=  Get File  ${configSuiteDir}/revert_scf/SCFC_gNB${gnb_id}_revert_${tc_number}.xml
    IF  ${file1} != []
    ...  admin.Perform Delta Recommissioning    delta_file=${configSuiteDir}/revert_scf/SCFC_gNB${gnb_id}_revert_${tc_number}.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}
    Run Keyword And Ignore Error  admin.Unblock All Cells  rat=NR  timeout=${10}  connection=${oam_alias}
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}

Perform Postconditions Of Test Scenario
    ${alarms_gnb0_after}  alarm_handling.Get All Alarms From Node  node_id=0  node_type=gnb
    Set Suite Variable  ${alarmlist_gnb0_after}  ${alarms_gnb0_after}
    ${alarms_gnb1_after}  alarm_handling.Get All Alarms From Node  node_id=1  node_type=gnb
    Set Suite Variable  ${alarmlist_gnb1_after}  ${alarms_gnb1_after}
    ${cleared_alarms_gnb0}  ${active_alarms_gnb0}  alarm.Check For New Alarms  ${alarmlist_gnb0_before}  ${alarmlist_gnb0_after}
    alarm_handling.Log Alarm List  ${cleared_alarms_gnb0}
    alarm_handling.Log Alarm List  ${active_alarms_gnb0}
    ${cleared_alarms_gnb1}  ${active_alarms_gnb1}  alarm.Check For New Alarms  ${alarmlist_gnb1_before}  ${alarmlist_gnb1_after}
    alarm_handling.Log Alarm List  ${cleared_alarms_gnb1}
    alarm_handling.Log Alarm List  ${active_alarms_gnb1}
# needs to be changed for second TC    Should Be Empty  ${active_alarms_gnb1}
    Teardown Tshark
    Run Keyword And Ignore Error    tcpdump.Stop Tcpdump on TestPc   collector=tcpdump_testpc
    syve_testline.Save Current Loads
    ${tc_log_directory}=  Get Testcase Log Directory
    ${ue_pc_alias}=  Run Keyword And Ignore Error  connect.Connect To UE PC   ${ue_id}=${1}
    Run Keyword And Ignore Error  ssh.Execute  mv /cygdrive/c/taf_ue_proxy/logs/proxy.log ${tc_log_directory}  connection=${ue_pc_alias}
    Revert GNB Delta Commissioning  gnb_id=${gnb_id}
    ${enb_alias}  Setup OAM Http Session  node_type=enb  node_id=${enb_id}
    Run Keyword And Ignore Error  admin.Unblock All Cells  rat=LTE  timeout=${20}  connection=${enb_alias}

Save All Logs And Teardown TL
    ${suiteBaseDirectory}=  testline . Get Test Suite Result Base Directory
    IF  '${INITIAL_SCF_FILE_ACTIVATION}' == 'true'  syve_testline.Testline Teardown For CCRT  node_list=gnb_0
    Run Keyword And Ignore Error  Filter Logs For All GNBs  btslogpath=${suiteBaseDirectory}
    bts_log_analysis.Print Filtered Btslog In Log File
