*** Settings ***
Documentation   Resources file for feature 'CB007219 Carrier Aggregation with MFBI NR cells'
...             Team: 'MN 5G&SC PZ ULM 2 SqdGp62'
...             Email: 'I_MN_5GSC_PZ_ULM_SQD_62@nokia.com'
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.sbts.oam.coam.admin   WITH NAME   admin
Library    taf.config.scf            WITH NAME   scf
Library    taf.hw.pdu                WITH NAME   pdu
Library    ute_tshark
Library    taf.ue
Library    ../../resources/Common/python/MCSharkDissectors.py

Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/testline.robot
Resource    ../../resources/Common/tcpdump.robot

Resource    ../resources/attenuator.robot
Resource    ../resources/attenuator_scenario.robot
Resource    ../resources/syve_testline.robot
Resource    ../resources/bts_log_analysis.robot
Resource    ../resources/enb.robot
Resource    ../resources/scf_info.robot

Resource    CB007219_verification.robot
Resource    CB007219_commissioning.robot
Resource    CB007219_pm_counter.robot


*** Keywords ***

Prepare TL for Testing
    testline.Create Test Suite Log Folders
    Set correct protocol name for wireshark check

Setup test
    testline.Create testcase log directory
    attenuator.Set Attenuator to Max Value
    ute_tshark.setup tshark    eth1
    syve_testline.Testline Setup for CCRT
    Reset UE On Port

Set correct protocol name for wireshark check
    [Documentation]     checks the wireshark plugins and sets the protocol name
    ...                 for the verification of the wireshark file depending of the installed plugins
    ${ft1ap_filter}  MCSharkDissectors.get_f1ap_tshark_filter_string
    Set Suite Variable  $PROTOCOL_NAME   ${ft1ap_filter}

Perform Preconditions of Test Scenario
   [Arguments]  ${gnb_id}  ${p_cell}  ${s_cell}  ${freq_pcell}  ${freq_scell}
   ...          ${target_gnb_id}=1  ${target_p_cell}=1  ${target_s_cell}=1  ${target_freq_pcell}=78  ${target_freq_scell}=66
   ...          ${enb_id}=${0}  ${enb_cell}=${1}  ${capabilities}=REAL_MTK
# common TC part
    set test variable  ${gnb_id}
    set test variable  ${p_cell}
    set test variable  ${s_cell}
    set test variable  ${freq_pcell}
    set test variable  ${freq_scell}
    set test variable  ${target_p_cell}
    set test variable  ${target_s_cell}
    set test variable  ${target_freq_pcell}
    set test variable  ${target_freq_scell}
    set test variable  ${target_gnb_id}
    set test variable  ${enb_id}
    set test variable  ${enb_cell}
    set test variable  ${capabilities}
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}
    ${configDir}=    testline.Get Testcase Log Directory
    gnb.Store Current SCF from gNB  gnb_id=${gnb_id}  target_dir=${configDir}
    enb.Get SCF from eNB  enb_id=${enb_id}    resultDir=${configDir}
    taf.ue.Require Ue  ${UE_ALIAS_1}  capabilities=${capabilities}
# attenuator setup needs to be changed because there are 2 att on tl
    attenuator_scenario.register all attenuators
    ${nrbts_id_1}  scf_info.Get NRBTS-Id  ${gnb_id}
    set test variable  ${nrbts_id_${gnb_id}}  ${nrbts_id_1}
    attenuator_scenario.Get runtimeobjects from gNB with cOAM  gnbScfName=scf_${gnb_id}  resultConfigDir=${configDir}
    ...  node_id=${gnb_id}
    attenuator_scenario.Get Gnb Cell Mapping  scf_file=${configDir}/scf_${gnb_id}  node_id=${gnb_id}
# TC specific part
    CB007219_commissioning.Commissioning gNB  test_name=${TEST_NAME}

# keyword Rest UE On Port will be moved later to common keyword
Reset UE On Port
    [Documentation]  Powers OFF given port, waits a number of seconds and power ON given port.
    [Arguments]      ${time_interval}=5  ${ue_id}=0

    ${pdu}                Set Variable   ${tl.ues[${ue_id}].pdu_port.pdu}
    ${pdu_port_number}    Create List    ${tl.ues[${ue_id}].pdu_port.port_no}
    ${pdu_alias}  pdu.Setup Pdu     ${pdu}
    pdu.Reset Ports    ports=${pdu_port_number}    time_interval=${time_interval}    pdu_device=${pdu_alias}
    Sleep  30s  reason=wait for ue reboot

Get MRBTS-Id
    [Arguments]    ${enb_id}=${0}
    [Documentation]     get mrbts id
    ${bts_distNames}=    Get distNames from eNB SCF    regex=MRBTS-\\d+    enb_id=${enb_id}
    ${bts_distName}=    Get From List    ${bts_distNames}    ${0}
    ${nrbts_id}=  string.Fetch From Right  ${bts_distName}  -
    RETURN  ${nrbts_id}

Get distNames from eNB SCF
    [Documentation]    get name for eNB
    [Arguments]    ${regex}    ${enb_id}=${0}
    ${oam_alias}=    connect.Setup OAM http session  node_id=${enb_id}  node_type=enb
    ${scf_content}=  admin.get_scf  parameters_save_variant=actualValues   timeout=${10}    connection=${oam_alias}
    ${distNames}=    gnb_internal.get_distNames_from_scf    regex=${regex}    scf_content=${scf_content}
    connect.Teardown OAM http session    node_type=enb  node_id=${enb_id}
    RETURN    ${distNames}

Start neccessary traces
    ${options}   Catenate   -i any port 38472 or port 38412 or port 38422 or port 38462
    ...                     or port 36422 or port 15010 or port 49148
    tcpdump.Start Tcpdump on gNB Common Unit  gnb_id=${gnb_id}
    ...                                       collector=tcpdump_gnb_${gnb_id}
    ...                                       options=${options}
    tcpdump.Start TCPdump on eNB    enb_id=${enb_id}
    tcpdump.Start Tcpdump on TestPc  options=-i eth3 sctp  collector=tcpdump_testpc

Set gNB scells attenuation
   [Arguments]  ${scells}   ${value}   ${gnbid}=${0}
   ${cells}  split string  ${scells}  ,
   FOR  ${i}  IN  @{cells}
     Set gNB cell attenuation to setup cell  globalcellid=${i}  value=${value}  gnbid=${gnbid}
   END

Set gNB cell attenuation to setup cell
    [Arguments]  ${globalcellid}  ${value}  ${gnbid}=${0}
    ${globalcellid}  convert to integer  ${globalcellid}
    ${ruid}  set variable  ${RU_gnb${gnbid}}[${globalcellid}]
    ${ports_per_node}  get variable value  ${PORTS_gnb${gnbid}}
    attenuator_scenario.set att per cell per step per port  ${ports_per_node[${globalcellid}]}  ${value}

Start UL and DL traffic on UE
    taf.ue.Start Data Transfer  dt_name=DL_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}  direction=dl  duration=${TRAFFIC.DURATION}
    ...    throughput=${TRAFFIC.DL_THROUGHPUT}    protocol=${TRAFFIC.PROTOCOL}  packet=1320  buffer=16M
    taf.ue.Start Data Transfer  dt_name=UL_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}  direction=ul  duration=${TRAFFIC.DURATION}
    ...    throughput=${TRAFFIC.UL_THROUGHPUT}    protocol=${TRAFFIC.PROTOCOL}  packet=1320  buffer=16M
    sleep  20s  reason=wait for traffic

Await UL and DL traffic
    Run Keyword And ignore Error  taf.ue.Await Data Transfer Finish  DL_${UE_ALIAS_1}
    Run Keyword And ignore Error  taf.ue.Await Data Transfer Finish  UL_${UE_ALIAS_1}

Stop all traces
    [Arguments]  ${tcpdump_filename}=Xn_traces_gnb.pcap
    ${tcp_file_gnb}  tcpdump.Stop TCP Dump on gNB Common Unit
    ...  collector=tcpdump_gnb_${gnb_id}  tcpdump_filename=${tcpdump_filename}
    set test variable  ${tcp_file_gnb${gnb_id}}  ${tcp_file_gnb}
    tcpdump.Stop TCPdump on eNB    enb_id=${enb_id}
    ${tcp_file}  tcpdump.Stop Tcpdump on TestPc  collector=tcpdump_testpc
    set test variable  ${tcp_file}  ${tcp_file}

Verify qc test case
    [Documentation]   check wireshark messages: check messages and correct content
    ...               check traffic: check throughput with deviation
    ...               check hanging resources
    ...               check PM counter
    # check PM counter
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  Run Keyword And Continue On Failure
    ...  CB007219_pm_counter.Check Performance counter  test_name=${TEST_NAME}
    # check wireshark messages common part
    ##e.g. Run Keyword And Continue On Failure    Check HandoverRequired  tcp_file=${tcp_file}
    # check traffic
    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation
    ...  dt_name=DL_${UE_ALIAS_1}  tput=${TRAFFIC.DL_THROUGHPUT}  deviation=${TRAFFIC.TPUT_DEVIATION}  omit=${3}  end=${100}
    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation
    ...  dt_name=UL_${UE_ALIAS_1}  tput=${TRAFFIC.UL_THROUGHPUT}  deviation=${TRAFFIC.TPUT_DEVIATION}  omit=${3}  end=${100}
    Run Keyword And ignore Error  taf.ue.Stop Data Transfer  DL_${UE_ALIAS_1}
    Run Keyword And ignore Error  taf.ue.Stop Data Transfer  UL_${UE_ALIAS_1}
    # check hanging resources
    hanging_resources.no check of resource nbOfFreeCRNTI
    hanging_resources.Verify resource usage for all nodes
    # check wireshark messages TC specific part
    Run Keyword And Continue On Failure  CB007219_verification.Verify test case  test_name=${TEST_NAME}

Perform Postconditions of Test Scenario
    [Arguments]    ${gnb_id}=${0}
    teardown tshark
    Run Keyword And Ignore Error    tcpdump.Stop Tcpdump on TestPc   collector=tcpdump_testpc
    ${enb_alias}  Setup OAM http session  node_type=enb  node_id=${enb_id}
    Run Keyword And ignore Error  admin.unblock_all_cells  rat=LTE  timeout=${10}  connection=${enb_alias}
    syve_testline.Save current loads
    ${tc_log_directory}=  Get testcase log directory
    ${ue_pc_alias}=  Run Keyword And Ignore Error  connect.Connect to UE PC   ${ue_id}=${1}
    Run Keyword And Ignore Error  ssh.execute  mv /cygdrive/c/taf_ue_proxy/logs/proxy.log ${tc_log_directory}  connection=${ue_pc_alias}
    IF  '${INITIAL_SCF_FILE_ACTIVATION}' == 'true'  syve_testline.Testline Teardown for CCRT    gnb_id=${gnb_id}

Save all Logs and Teardown TL
    ${suiteBaseDirectory}=  testline . Get test suite result base directory
    Run Keyword And ignore Error  filter logs for all gNBs  btslogpath=${suiteBaseDirectory}
#    bts_log_analysis.print filtered btslog in log file
