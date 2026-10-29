*** Settings ***
Documentation   Robot Test Suite for feature CB013859- Carrier Aggregation support based on slice ID configuration
...             Team: I_MN_RAN_RD_VRF_ULM_VT2
...             Email: i_mn_ran_rd_vrf_ulm_vt2@internal.nsn.com
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library     taf.hw.rf_attenuator                             WITH NAME    attenuator
Library     ../../resources/Common/python/alarm_handling.py  WITH NAME    alarm
Library     ute_tshark
Library     taf.sbts.oam.coam.admin
Library     OperatingSystem

Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/connect.robot
Resource    ../../resources/Common/pmcounters.robot
Resource    ../../resources/Common/alarm_handling.robot

Resource    ../../resources/Common/tcpdump.robot
Resource    ../resources/syve_testline.robot
Resource    ../resources/attenuator.robot
Resource    ../resources/attenuator_scenario.robot
Resource    ../resources/scf_info.robot
Resource    ../resources/pcap_analysis.robot
Resource    ../resources/bts_log_analysis.robot
Resource    ../../resources/Common/pmcounters.robot

Resource    CB013859_commissioning.robot
Resource    CB013859_verification.robot
Resource    CB013859_pm_counter.robot


*** Keywords ***

Prepare TL For Testing
    testline.Create Test Suite Log Folders
    testline.Check TL Infos
    pcap_analysis.Set Correct F1AP Protocol Name For Wireshark Check

Setup Test
    syve_testline.Testline Setup For CCRT
    testline.Create Testcase Log Directory
    attenuator.Set Attenuator To Max Value
    ute_tshark.Setup Tshark    eth1
    ${alarms_gnb0_before}  alarm_handling.Get All Alarms From Node  node_id=0  node_type=gnb
    Set Suite Variable  ${ALARMLIST_GNB0_BEFORE}  ${alarms_gnb0_before}
    ${alarms_gnb1_before}  alarm_handling.Get All Alarms From Node  node_id=1  node_type=gnb
    Set Suite Variable  ${ALARMLIST_GNB1_BEFORE}  ${alarms_gnb1_before}

Perform Preconditions Of Test Scenario
   [Arguments]  ${gnb_id_0}  ${p_cell_1}  ${s_cell_1}  ${gnb_id_1}=1  ${s_cell_2}=${None}  ${s_cell_3}=${None}  ${s_cell_target_2}=${None}
   ...  ${s_cell_target_3}=${None}  ${ext_s_cell_1}=${None}  ${ext_s_cell_2}=${None}  ${ext_s_cell_3}=${None}

# common TC part
    Set All Suite Variables
    Set Test Variable  ${gnb_id_0}
    Set Test Variable  ${gnb_id_1}
    Set Test Variable  ${p_cell_1}
    Set Test Variable  ${s_cell_1}
    Set Test Variable  ${s_cell_2}
    Set Test Variable  ${s_cell_3}
    Set Test Variable  ${s_cell_target_2}
    Set Test Variable  ${s_cell_target_3}
    Set Test Variable  ${ext_s_cell_1}
    Set Test Variable  ${ext_s_cell_2}
    Set Test Variable  ${ext_s_cell_3}
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id_0}
    ${configSuiteDir}=    testline.Get Test Suite Config Directory
    gnb.Store Current SCF From GNB  gnb_id=${gnb_id_0}  target_dir=${configSuiteDir}
    gnb.Store Current SCF From GNB  gnb_id=${gnb_id_1}  target_dir=${configSuiteDir}
    attenuator_scenario.Register All Attenuators
    ${RESULTTESTDIR}=    testline.Get testcase log directory
    Set Suite Variable  ${RESULTTESTDIR}
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=${gnb_id_0}
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=${gnb_id_1}
# TC specific part
    CB013859_commissioning.Commissioning GNB  test_name=${TEST_NAME}

Execution CB013859
    [Documentation]  Starting Execution CB013859, Qualcomm slicing check
    ...              Part 1: With Qualcomm all 3 Scells shall be attached, since slice std3 is allowed
    ...              Part 2: With MTK only 2 Scells shall be attached, since slice std3 is not allowed
    [Arguments]  ${ue_alias}  ${test}
    taf.ue.Require UE  ${ue_alias}  capabilities=${ue_alias}
#    taf.ue.Reboot  ${ue_alias}
    taf.ue.Detach UE   ${ue_alias}
    Sleep  20s  reason=wait release of resources
    hanging_resources.Get Resources Before Test For All Nodes
    CB013859_keywords.Start Tracing
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        Log To Console    \nPMcounters: Wait for next Measurement Period to start.
        pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${gnb_id_0}
    END
    attenuator_scenario.Set Cell Attenuation  globalcellid=${p_cell_1}  value=${50}  node_id=${gnb_id_0}
    taf.ue.Attach UE   ${ue_alias}  timeout=180
    Sleep  20s  reason=Wait for RRC Release, UE idle mode
    attenuator_scenario.Prepare Single Scenario File  scenfile=${CURDIR}/attenuator_scenario_CB013859.txt  scenario=SEN_CB013859_A03
    attenuator_scenario.Run Attenuator Scenario By Cell  scenario=SEN_CB013859_A03  att_file=${P_resultSuiteBaseDir}/attenuator_scenario_tl.txt
    ${dl_dt_name}    ${ul_dt_name}=    CB013859_keywords.Start UL And DL Traffic  dl_throughput=${TRAFFIC.DL_THROUGHPUT}
    ...                                ul_throughput=${TRAFFIC.UL_THROUGHPUT}  duration_dl=${TRAFFIC.DURATION}  duration_ul=${TRAFFIC.DURATION}
    ...                                ue_alias=${ue_alias}
    CB013859_keywords.Await UL And DL Traffic  dl_dt_name=DT_DL_${Part}  ul_dt_name=DT_UL_${Part}
    CB013859_keywords.Stop Tracing And Save As    tcp_file=UE1_CB013859_${test}_Part${Part}
    taf.ue.Detach UE   ${ue_alias}
    attenuator.Set Attenuator To Max Value
    hanging_resources.Get Resources After Test For All Nodes

Verify Qc Test Case
    [Documentation]   check wireshark messages: check messages and correct content
    ...               check traffic: check throughput with deviation
    ...               check hanging resources
    ...               check PM counter
    # check PM counter
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  Run Keyword And Continue On Failure
    ...  CB013859_pm_counter.Check Performance Counter  test_name=${TEST_NAME}
    # check wireshark messages common part
    ##e.g. Run Keyword And Continue On Failure    Check HandoverRequired  tcp_file=${tcp_file}
    # check traffic
    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation
    ...  dt_name=DT_DL_${Part}  tput=${TRAFFIC.DL_THROUGHPUT}  deviation=${TRAFFIC.TPUT_DEVIATION}  omit=${2}  end=${100}
    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation
    ...  dt_name=DT_UL_${Part}  tput=${TRAFFIC.UL_THROUGHPUT}  deviation=${TRAFFIC.TPUT_DEVIATION}  omit=${2}  end=${100}
    Run Keyword And Ignore Error  taf.ue.Stop Data Transfer  DT_DL_${Part}
    Run Keyword And Ignore Error  taf.ue.Stop Data Transfer  DT_UL_${Part}
    # check hanging resources
    hanging_resources.No Check Of Resource NbOfFreeCRNTI
    hanging_resources.Verify Resource Usage For All Nodes
    # check wireshark messages TC specific part
    Run Keyword And Continue On Failure  CB013859_verification.Verify Test Case  test_name=${TEST_NAME}

Set All Suite Variables
    ${CONFIGSUITEDIR}  testline.Get Test Suite Config Directory
    Set Suite Variable  ${CONFIGSUITEDIR}
    ${TL_NAME}  testline.Get Testline Name
    Set Suite Variable  ${TL_NAME}
    ${GNB_SW_BRANCH}  Get GNB SW Branch
    Set Suite Variable  ${GNB_SW_BRANCH}
    ${LNBTS_ID_0}=  scf_info.Get LNBTS-Id  gnb_id=${0}
    Set Suite Variable  ${LNBTS_ID_0}
    ${NRBTS_ID_0}=  scf_info.Get NRBTS-Id  gnb_id=${0}
    Set Suite Variable  ${NRBTS_ID_0}
    ${NRBTS_ID_1}=  scf_info.Get NRBTS-Id  gnb_id=${1}
    Set Suite Variable  ${NRBTS_ID_1}

Start Tracing
    [Documentation]    Start tracing tcpdump on eth3 interface
    CB013859_keywords.Get IP Hosts For Tracing
    ${tcpdump_options}=     Catenate    -i eth3 '(sctp or tcp port 49148) and (${IP_Hosts})'
    ${eth3_collector}=  tcpdump.Start Tcpdump On TestPC    options=${tcpdump_options}
    Set Test Variable    ${eth3_collector}

Stop Tracing and Save As
    [Documentation]    Stop tracing tcpdump on eth3 interface
    [Arguments]    ${tcp_file}
    ${file_captured}  tcpdump.Stop Tcpdump On TestPc   collector=${eth3_collector}  target_dir=${resultTestDir}
    OperatingSystem.Run  cp ${file_captured} ${resultTestDir}/${tcp_file}.pcap
    Set Test Variable    ${${tcp_file}}    ${file_captured}

Get IP Hosts For Tracing
    ${configSuiteDir}=    testline.Get Test Suite Config Directory
    scf.Load SCF  file_path=${configSuiteDir}/SCFC_gNB${gnb_id_0}_DU.xml
    ${LocalIpAddrList}    Create List
    FOR  ${IpIndex}  IN  1  2  3
        ${localIpAddr}=  scf.Get Value From SCF    p_name=localIpAddr
        ...    dist_name=MRBTS-${NRBTS_ID_0}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-${IpIndex}
        Collections.Append To List   ${LocalIpAddrList}    ip host ${localIpAddr}
    END
    ${IP_Hosts}=  Catenate  SEPARATOR= or${SPACE}  @{LocalIPAddrList}
    Set Test Variable    ${IP_Hosts}

Start UL And DL Traffic
    [Documentation]     start DL/UL Traffic on default PDU and second PDU
    [Arguments]    ${dl_throughput}  ${ul_throughput}  ${duration_dl}  ${duration_ul}  ${ue_alias}
    ${dl_dt_name}=  Set Variable    DT_DL_${Part}
    ${ul_dt_name}=  Set Variable    DT_UL_${Part}
    taf.ue.Start Data Transfer    ${dl_dt_name}  ${ue_alias}  DL  duration=${duration_dl}
    ...                           throughput=${dl_throughput}    protocol=${TRAFFIC.PROTOCOL}  packet_size=1300
    taf.ue.Start Data Transfer    ${ul_dt_name}  ${ue_alias}  UL  duration=${duration_ul}
    ...                           throughput=${ul_throughput}    protocol=${TRAFFIC.PROTOCOL}  packet_size=1300
    RETURN    ${dl_dt_name}    ${ul_dt_name}

Await UL And DL Traffic
    [Documentation]     Await UL And DL Traffic to finish
    [Arguments]    ${dl_dt_name}    ${ul_dt_name}
    Run Keyword And ignore Error  taf.ue.Await Data Transfer Finish  ${dl_dt_name}
    Run Keyword And ignore Error  taf.ue.Await Data Transfer Finish  ${ul_dt_name}

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
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id_0}

Save All Logs And Teardown TL
    ${suiteBaseDirectory}=  testline . Get Test Suite Result Base Directory
    IF  '${INITIAL_SCF_FILE_ACTIVATION}' == 'true'  syve_testline.Testline Teardown For CCRT  node_list=gnb_0  ignore_eNB=True
    Run Keyword And Ignore Error  Filter Logs For All GNBs  btslogpath=${suiteBaseDirectory}
    bts_log_analysis.Print Filtered Btslog In Log File

Perform Postconditions Of Test Scenario
    ${alarmlist_gnb0_after}  alarm_handling.Get All Alarms From Node  node_id=0  node_type=gnb
    ${alarmlist_gnb1_after}  alarm_handling.Get All Alarms From Node  node_id=1  node_type=gnb
    ${cleared_alarms_gnb0}  ${active_alarms_gnb0}  alarm.Check For New Alarms
    ...  alarm_list_1=${alarmlist_gnb0_before}
    ...  alarm_list_2=${alarmlist_gnb0_after}
    ...  exclude_cleared_alarms=faultId:49 faultId:7311
	...  exclude_active_alarms=faultId:49
    Should Be Empty  ${active_alarms_gnb0}
    ${cleared_alarms_gnb1}  ${active_alarms_gnb1}  alarm.Check For New Alarms  ${ALARMLIST_GNB1_BEFORE}  ${alarmlist_gnb1_after}
    Should Be Empty  ${active_alarms_gnb1}
    ute_tshark.Teardown Tshark
    attenuator.Set Attenuator To Max Value
    syve_testline.Save Current Loads
    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id_0}
    Run Keyword And Ignore Error  admin.Unblock All Cells  rat=LTE  timeout=${20}  connection=${oam_alias}
    Revert GNB Delta Commissioning  gnb_id=${gnb_id_0}
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id_0}  timeout=900s
