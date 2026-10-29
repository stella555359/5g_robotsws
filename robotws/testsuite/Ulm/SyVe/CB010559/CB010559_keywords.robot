*** Settings ***
Documentation   Resources file for feature 'CB010559'
...             Team: 'MN 5G&SC PZ ULM 4'
...             Email: 'I_MN_RAN_RD_VRF_ULM_*XYZ*@nokia.com'
# ----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.sbts.oam.coam.admin                              WITH NAME   admin
Library    taf.config.scf                                       WITH NAME   scf
Library    ute_tshark
Library    ../../resources/Common/python/MCSharkDissectors.py
Library    ../../resources/Common/python/alarm_handling.py      WITH NAME   alarm

Resource    ../../resources/Common/alarm_handling.robot
Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/testline.robot
Resource    ../../resources/Common/tcpdump.robot
Resource    ../resources/attenuator.robot
Resource    ../resources/attenuator_scenario.robot
Resource    ../resources/syve_testline.robot
Resource    ../resources/bts_log_analysis.robot
Resource    ../resources/enb.robot
Resource    ../resources/scf_info.robot
Resource    ../resources/pcap_analysis.robot

Resource    ./CB010559_Verification.robot
Resource    ./CB010559_Commissioning.robot


*** Keywords ***

Prepare TL For Testing
    [Documentation]     in Test [Suite Setup] run the following keywords
    testline.Create Test Suite Log Folders
    testline.Check TL Infos
    pcap_analysis.Set Correct F1AP Protocol Name For Wireshark Check

Setup Test For CB010559
    [Documentation]     in Test Case [Setup] run the following keywords
    #  Start syslogs for all nodes depending on param ENABLED_LOGS (default=syslog)
    syve_testline.Testline Setup For CCRT

    testline.Create Testcase Log Directory

    ${gnb_sw_version}=    Get GNB SW Version    gnb_id=${GNB_ID_0}
    Log To Console    ${\n}INFO: GNB-${GNB_ID_0} SW Version is: ${gnb_sw_version}

    attenuator.Set Attenuator To Max Value
    ute_tshark.Setup Tshark    eth1

    ${alarms_1}  alarm_handling.Get All Alarms From Node
    Set Suite Variable  ${ALARMLIST_1}  ${alarms_1}

Set Test Case Variables For SA
    [Documentation]    Set the variables needed in the scope of SA test cases
    ...   The cell PCELL_UE_1_P2S is the source primary cell and gets a target scell
    ...
    [Arguments]   ${TC_NUMBER}
    ...           ${gnb_id_0}=0   ${gnb_id_1}=1   ${enb_id}=0
    ...           ${capabilities}=REAL_ANDROID_UE
    ...           ${GNB0_SOURCE_P_CELL_UE_1}=${0}   ${GNB0_SOURCE_S_CELL_UE_1}=${0}
    ...           ${GNB0_NRREL_TO_TARGET_P_CELL_UE_1}=${0}
    ...           ${GNB1_TARGET_P_CELL_UE_1}=${0}   ${GNB1_TARGET_S_CELL_UE_1}=${0}
    ...           ${ADJ_CELLS_GNB0}=${0}   ${ADJ_CELLS_GNB1}=${0}

    Set Test Variable     ${TC_NUMBER}
    Set Test Variable     ${gnb_id_0}
    Set Test Variable     ${gnb_id_1}
    Set Test Variable     ${enb_id}
    Set Test Variable     ${capabilities}

    Set Test Variable     ${GNB0_SOURCE_P_CELL_UE_1}
    Set Test Variable     ${GNB0_SOURCE_S_CELL_UE_1}
    Set Test Variable     ${GNB0_NRREL_TO_TARGET_P_CELL_UE_1}
    Set Test Variable     ${GNB1_TARGET_P_CELL_UE_1}
    Set Test Variable     ${GNB1_TARGET_S_CELL_UE_1}
    Set Test Variable     ${ADJ_CELLS_GNB0}
    Set Test Variable     ${ADJ_CELLS_GNB1}


Perform Preconditions Of Test Scenario
    [Documentation]    common TC part:
    ...   get SCFs, register attenuator, check UE, block all LTE cells, do commissioning
    [Arguments]  ${gnb_id_0}=${0}  ${gnb_id_1}=${1}  ${enb_id}=${0}  ${capabilities}=UE_1

    #  1. get and store all SCFs from the nodes of the testline
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id_0}
# - do be deleted when it works: ;-)  ${configDir}=         testline.Get Testcase Log Directory
# - do be deleted when it works: ;-)  better user the following 2 lines: (Get testcase ... includes the Create Testcase ....)
    ${RESULT_TEST_DIR}=    testline.Get Testcase Log Directory
    Set Test Variable  ${RESULT_TEST_DIR}
    Log To Console   ${\n}Get SCF from gNB-${gnb_id_0}, gNB-${gnb_id_1} and eNB-${enb_id} and store it in target_dir
    Log To Console   ${RESULT_TEST_DIR}${\n}
    gnb.Store Current SCF From GNB  gnb_id=${gnb_id_0}  target_dir=${RESULT_TEST_DIR}
    gnb.Store Current SCF From GNB  gnb_id=${gnb_id_1}  target_dir=${RESULT_TEST_DIR}
    enb.Get SCF From ENB  enb_id=${enb_id}    resultDir=${RESULT_TEST_DIR}

    #  2. register all attenuators and mapp the cells to the attenuator ports
    attenuator_scenario.Register All Attenuators
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=${gnb_id_0}  node_type=gnb
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=${gnb_id_1}  node_type=gnb
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=${enb_id}  node_type=enb

    #  3. initialise the the given UE, clear the NAA storage on the UE and get the UE Infos
    taf.ue.Require Ue  ${UE_ALIAS_1}  capabilities=${capabilities}
    Log To Console    UE_Alias_1 parameter is: ${UE_ALIAS_1}
#    taf.ue.Reboot Ue  ${UE_ALIAS_1}
    taf.ue.Clear Naa Storage   ${UE_ALIAS_1}
    taf.ue.Log UE Info   ${UE_ALIAS_1}

    #  4. Block all eNB LTE/4G cells as default
    IF  $BLOCK_ENB
        ${enb_alias}  Setup OAM HTTP Session  node_type=enb  node_id=${enb_id}
        admin.Block All Cells  rat=LTE  timeout=${20}  connection=${enb_alias}
        Log To Console  ALL LTE cells on eNB-${enb_id} are BLOCKED as default - unblock, in NSA case, is done in commissioning part
    END

    #  4. TC specific commissioning part and block adjacent cells
    IF  $WITH_TC_COMMISSIONING
        CB010559_Commissioning.Commissioning GNB  test_name=${TEST_NAME}  gnb_id=${gnb_id_0}
        CB010559_Commissioning.Commissioning GNB  test_name=${TEST_NAME}  gnb_id=${gnb_id_1}
    END

    IF  $BLOCK_GNB_ADJACENT_CELLS
        CB010559_Commissioning.Block Adjacent Cells On GNB
        ...    gnb_id=${gnb_id_0}    adjacentCellsToBeBlocked=${ADJ_CELLS_GNB0}
        CB010559_Commissioning.Block Adjacent Cells On GNB
        ...    gnb_id=${gnb_id_1}    adjacentCellsToBeBlocked=${ADJ_CELLS_GNB1}
    END


Start Tracing On GNB
    [Documentation]   Start tracing tcpdump directly on gNB
    [Arguments]  ${gnb_id}=0
    tcpdump.Start Tcpdump On GNB Common Unit
    ...    gnb_id=${gnb_id}
    ...    collector=tcpdump_gnb_${gnb_id}
    ...    options=-i any port 38472 or port 38412 or port 38422 or port 38462 or port 36422

Stop Tracing On GNB
    [Arguments]  ${gnb_id}=0   ${tcpdump_filename}=Xn_traces_gnb.pcap
    ${tcp_file_gnb}  tcpdump.Stop TCPDump On GNB Common Unit
    ...  collector=tcpdump_gnb_${gnb_id}  tcpdump_filename=${tcpdump_filename}
    Set Test Variable  ${tcpdump_gnb_${gnb_id}}  ${tcp_file_gnb}

Start Tracing On Test PC Mirror Port
    [Documentation]    Start tracing tcpdump on eth3 interface
    [Arguments]  ${gnb_id}=0
    CB010559_keywords.Get IP Hosts For Tracing   gnb_id=${gnb_id}
#    Set Test Variable    ${testPc_mirrorPort_eth3}    testPc_mirrorPort_eth3
    ${tcpdump_options}=     Catenate    -i eth3 '(sctp or tcp port 49148) and (${IP_Hosts})'
    ${testPc_mirrorPort_eth3}=  tcpdump.Start Tcpdump On TestPC    options=${tcpdump_options}  collector=testPc_mirrorPort_eth3
    Set Test Variable    ${testPc_mirrorPort_eth3}
#    ${eth3_collector}=  tcpdump.Start Tcpdump On TestPC    options=${tcpdump_options}
#    Set Test Variable    ${eth3_collector}
    Log To Console   testPc_mirrorPort_eth3 is ${testPc_mirrorPort_eth3}

Stop Tracing On Test PC Mirror Port And Save As
    [Documentation]    Stop tracing tcpdump on eth3 interface
    [Arguments]    ${tcp_file}
    ${file_captured}  tcpdump.Stop Tcpdump On TestPc   collector=${testPc_mirrorPort_eth3}  target_dir=${RESULT_TEST_DIR}
#    ${file_captured}  tcpdump.Stop Tcpdump On TestPc   collector=${eth3_collector}  target_dir=${RESULT_TEST_DIR}
    OperatingSystem.Run  cp ${file_captured} ${RESULT_TEST_DIR}/${tcp_file}
    Set Test Variable    ${testPc_mirrorPort_eth3}    ${file_captured}
#   Set Test Variable    ${${tcp_file}}    ${file_captured}
    Log To Console   This is the stop of tcpdump on Test PC mirror port
    Log To Console   file_captured is ${file_captured}

Get IP Hosts For Tracing
    [Arguments]  ${gnb_id}=0
#    ${configSuiteDir}=    testline.Get Test Suite Config Directory
    scf.Load SCF  file_path=${RESULT_TEST_DIR}/SCFC_gNB${gnb_id}_DU.xml
    ${LocalIpAddrList}    Create List
    FOR  ${IpIndex}  IN  1  2  3
        ${localIpAddr}=  scf.Get Value From SCF    p_name=localIpAddr
        ...    dist_name=MRBTS-${NRBTS_ID_0}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-${IpIndex}
        Collections.Append To List   ${LocalIpAddrList}    ip host ${localIpAddr}
    END
    ${IP_Hosts}=  Catenate  SEPARATOR= or${SPACE}  @{LocalIPAddrList}
    Set Test Variable    ${IP_Hosts}


Revert GNB Delta Commissioning
    [Documentation]    Commissioning of gnb, create new updated SCF with delta changes.
    ...                Only one file is required for updating gnb with delta changes.
    [Arguments]        ${gnb_id}

    Log To Console  Start - Revert delta commissioning
# - do be deleted when it works: ;-)      ${RESULT_TEST_DIR}=    testline.Get Testcase Log Directory
# - do be deleted when it works: ;-)      OperatingSystem.Create Directory  ${RESULT_TEST_DIR}/revert_scf
    gnb.Store Current SCF From GNB  gnb_id=${gnb_id}  target_dir=${RESULT_TEST_DIR}/revert_scf
    scf.Calculate Delta SCF
    ...    target_scf_path=${RESULT_TEST_DIR}/SCFC_gNB${gnb_id}_DU.xml.orig
    ...    actual_scf_path=${RESULT_TEST_DIR}/revert_scf/SCFC_gNB${gnb_id}_DU.xml
    ...    delta_scf_path=${RESULT_TEST_DIR}/revert_scf/SCFC_gNB${gnb_id}_revert_${TC_NUMBER}.xml

    ${oam_alias}=   connect.Setup OAM HTTP Session   node_id=${gnb_id}
    ${revert_scf_size}=  OperatingSystem.Get File Size  ${RESULT_TEST_DIR}/revert_scf/SCFC_gNB${gnb_id}_revert_${TC_NUMBER}.xml

    IF   ${revert_scf_size} != ${0}
        admin.Perform Delta Recommissioning
        ...    delta_file=${RESULT_TEST_DIR}/revert_scf/SCFC_gNB${gnb_id}_revert_${TC_NUMBER}.xml
        ...    skip_parameter_relation_errors=${True}
        ...    connection=${oam_alias}
    END

    Run Keyword And Ignore Error  admin.Unblock All Cells  rat=NR  timeout=${20}  connection=${oam_alias}
    Log To Console  Stopp - Revert delta commissioning and UNBLOCK all 5G cells on gNB-${gnb_id}

Perform Postconditions Of Test Scenario
    [Documentation]    used in Test Case [Teardown]
    ...   shutdown tshark - unblock all LTE cells - get UE NUC PC proxy logs
    ...   Put all attenuator ports to maximum value
    ...   revert the gNB delta commissioning to original SCF
    ...   check alarms
    [Arguments]     ${gnb_id_0}=0  ${gnb_id_1}=1  ${enb_id}=0

    ute_tshark.Teardown Tshark

    ${enb_alias}  connect.Setup OAM HTTP Session  node_type=enb  node_id=${enb_id}
    Run Keyword And Ignore Error  admin.Unblock All Cells  rat=LTE  timeout=${10}  connection=${enb_alias}
    ${oam_alias_0}=   connect.Setup OAM HTTP Session   node_id=${gnb_id_0}
    Run Keyword And Ignore Error  admin.Unblock All Cells  rat=NR  timeout=${10}  connection=${oam_alias_0}
    ${oam_alias_1}=   connect.Setup OAM HTTP Session   node_id=${gnb_id_1}
    Run Keyword And Ignore Error  admin.Unblock All Cells  rat=NR  timeout=${10}  connection=${oam_alias_1}
    #  Save name of eNB and gNB load to file for reporting after test end
    syve_testline.Save Current Loads

    ${tc_log_directory}=  Get Testcase Log Directory
    ${ue_pc_alias}=  Run Keyword And Ignore Error  connect.Connect To UE PC   ${ue_id}=${1}
    Run Keyword And Ignore Error  ssh.Execute  mv /cygdrive/c/taf_ue_proxy/logs/proxy.log ${tc_log_directory}  connection=${ue_pc_alias}

    Log To Console    Put all attenuator ports to maximum value
    attenuator.Set Attenuator To Max Value

    #  TC specific revert delta commissioning part
    IF  $WITH_TC_COMMISSIONING
        Revert GNB Delta Commissioning  gnb_id=${gnb_id_0}
        Revert GNB Delta Commissioning  gnb_id=${gnb_id_1}
    END

    ${alarms_2}  alarm_handling.Get All Alarms From Node
    Set Suite Variable  ${alarmlist_2}  ${alarms_2}
    ${cleared_alarms}  ${active_alarms}  alarm.Check For New Alarms  ${alarmlist_1}  ${alarmlist_2}
    alarm_handling.Log Alarm List  ${cleared_alarms}
    alarm_handling.Log Alarm List  ${active_alarms}

Save All Logs And Teardown TL
    [Documentation]
    ...     in Test [Suite Teardown]
    ${suiteBaseDirectory}=  testline.Get Test Suite Result Base Directory
    Log To Console    Initial SCF File Activation is set to ${INITIAL_SCF_FILE_ACTIVATION}
    IF   $INITIAL_SCF_FILE_ACTIVATION
        syve_testline.Testline Teardown For CCRT
        syve_testline.Load Initial GNB SCF For CCRT        ${gnb_id_0}
        syve_testline.Load Initial GNB SCF For CCRT        ${gnb_id_1}
    END
    Run Keyword And Ignore Error  Filter Logs For All GNBs  btslogpath=${suiteBaseDirectory}

    bts_log_analysis.Print Filtered BTSLog In Log File


#   ------------------------------------------------------------------------
#   keywords for common test steps within the testcases of feature CB010559:
#   ------------------------------------------------------------------------

Select Testline
    [Documentation]
    ...     Select the testline for the running TC from the NRBTS ID and
    ...     set the according parameters: used cells, ...

    ${NRBTS_ID_0}        scf_info.Get NRBTS-Id  ${GNB_ID_0}
    Set Test Variable     ${NRBTS_ID_0}
    ${NRBTS_ID_1}        scf_info.Get NRBTS-Id  ${GNB_ID_1}
    Set Test Variable     ${NRBTS_ID_1}
    Log To Console    ${\n}GNB-${GNB_ID_0} NRBTS ID is ${NRBTS_ID_0} and GNB-${GNB_ID_1} NRBTS ID is ${NRBTS_ID_1}

    IF   ${NRBTS_ID_0} in [401261,403871]
        #   TL387 is the clone of the master testline TL126
        CB010559_keywords.Set Test Case Variables For SA
        ...   TC_NUMBER=${TC_NUMBER}
        ...   gnb_id_0=${GNB_ID_0}  gnb_id_1=${GNB_ID_1}  enb_id=${ENB_ID_0}
        ...   capabilities=UE_1
        ...   GNB0_SOURCE_P_CELL_UE_1=${11}   GNB0_SOURCE_S_CELL_UE_1=${0}
        ...   GNB0_NRREL_TO_TARGET_P_CELL_UE_1=${101}
        ...   GNB1_TARGET_P_CELL_UE_1=${1}   GNB1_TARGET_S_CELL_UE_1=${0}
        ...   ADJ_CELLS_GNB0=${{ [5,7,9] }}   ADJ_CELLS_GNB1=${0}

    ELSE IF   ${NRBTS_ID_0} == [403641,403511]
        #   TL351 is the clone of the master testline TL364
        CB010559_keywords.Set Test Case Variables For SA
        ...   TC_NUMBER=${TC_NUMBER}
        ...   gnb_id_0=${GNB_ID_0}  gnb_id_1=${GNB_ID_1}  enb_id=${ENB_ID_0}
        ...   capabilities=UE_1
        ...   GNB0_SOURCE_P_CELL_UE_1=${11}   GNB0_SOURCE_S_CELL_UE_1=${0}
        ...   GNB0_NRREL_TO_TARGET_P_CELL_UE_1=${101}
        ...   GNB1_TARGET_P_CELL_UE_1=${1}   GNB1_TARGET_S_CELL_UE_1=${0}
        ...   ADJ_CELLS_GNB0=${{ [5,7,9] }}   ADJ_CELLS_GNB1=${3}

    ELSE
        Fail    No TC variables are defined for gNB with NRBTS ID ${NRBTS_ID_0}
    END

   ${tc_settings}=   catenate   SEPARATOR=
      ...   \nbrief testcase scenario settings for chosen testline:
      ...   \n5G call starts on source gNB-${gnb_id_0} pcell is ${GNB0_SOURCE_P_CELL_UE_1} and
      ...   \ 5G s-cell is ${GNB0_SOURCE_S_CELL_UE_1}
      ...   \nRRC connection re-establishment to an unprepared gNB is done to
      ...   \ gNB-${gnb_id_1} target p-cell is ${GNB1_TARGET_P_CELL_UE_1} and
      ...   \ 5G target s-cell is ${GNB1_TARGET_S_CELL_UE_1}
      ...   \nAdjacent cells on gNB-${gnb_id_0} are ${ADJ_CELLS_GNB0}
      ...   \nAdjacent cells on gNB-${gnb_id_1} are ${ADJ_CELLS_GNB1}
    Log To Console   ${tc_settings}

RRE With TcpLog PMcount And Traffic
#  Start Tcpdump on gNB Common Unit and Test PC
#    CB010559_keywords.Start Necessary Traces   gnb_id=${GNB_ID_0}
    #  1. START tracing on the source and target gNB AND on the test PC wireshark mirror port
    Log To Console    ${\n}Start tracing on the source and target gNB AND on the wireshark mirror port
    CB010559_keywords.Start Tracing On GNB   gnb_id=${GNB_ID_0}
    CB010559_keywords.Start Tracing On GNB   gnb_id=${GNB_ID_1}
    CB010559_keywords.Start Tracing On Test PC Mirror Port   gnb_id=${GNB_ID_0}

    #  2. Wait for next PM counter measurement period STARTS
    Log To Console    $WITH_PM_COUNTER_CHECK is ${WITH_PM_COUNTER_CHECK}
    IF  $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: WAIT for START of next Measurement Period
       pmcounters.Wait Until The Next Measurement Period Starts    gnb_id=${GNB_ID_1}
       Log To Console    ${\n}Measurement Period STARTED, let traffic run for the whole period
    END
    Sleep   20sec  reason=wait for 20s until start of the scenario

    #  3. Attach UE to SOURCE gNB 5G cell ${GNB0_SOURCE_P_CELL_UE_1}
    Log To Console    ${\n}Attach UE to 5G source cell ${GNB0_SOURCE_P_CELL_UE_1} and (add scells XXX)
    attenuator_scenario.Set Cell Attenuation
    ...   globalcellid=${GNB0_SOURCE_P_CELL_UE_1}  value=${20}  node_id=${GNB_ID_0}  node_type=gnb
    Log To Console    UE_Alias_1 parameter is: ${UE_ALIAS_1}
    taf.ue.Attach Ue   ${UE_ALIAS_1}   timeout=40
    Sleep   20s  reason=wait for attach

    #  4. Start UL + DL traffic on all cells
    Log To Console    ${\n}Start DL traffic with datarate ${TRAFFIC.DL_THROUGHPUT}
    taf.ue.Start Data Transfer
    ...    dt_name=DL_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}
    ...    direction=dl   duration=${TRAFFIC.DURATION}
    ...    throughput=${TRAFFIC.DL_THROUGHPUT}    protocol=${TRAFFIC.PROTOCOL}
    ...    packet=1320  buffer=16M
    Sleep  5s  reason=wait for traffic started up

    Log To Console    ${\n}Start UL traffic with datarate ${TRAFFIC.UL_THROUGHPUT}
    taf.ue.Start Data Transfer
    ...    dt_name=UL_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}
    ...    direction=ul   duration=${TRAFFIC.DURATION}
    ...    throughput=${TRAFFIC.UL_THROUGHPUT}    protocol=${TRAFFIC.PROTOCOL}
    ...    packet=1320  buffer=16M
    Sleep    30sec  reason=let traffic run for 30 seconds until start of attenuation scenario

    #  5. Start pcell switch attenuator scenario from source to target pcell and scells
    #  NO attenuator scenario is necessary, only open target cell and close source cell
    Log To Console    ${\n}OPEN 5G cell on TARGET gNB-1 ${GNB1_TARGET_P_CELL_UE_1}
    attenuator_scenario.Set Cell Attenuation
    ...   globalcellid=${GNB1_TARGET_P_CELL_UE_1}  value=${30}  node_id=${GNB_ID_1}  node_type=gnb

    Log To Console    ${\n}CLOSE 5G cell on SOURCE gNB-0 ${GNB0_SOURCE_P_CELL_UE_1}
    attenuator_scenario.Set Cell Attenuation
    ...   globalcellid=${GNB0_SOURCE_P_CELL_UE_1}  value=${127}  node_id=${GNB_ID_0}  node_type=gnb
    Sleep    30sec  reason=let traffic run for 30 seconds until stop testcase

    #  6. Wait for next PM counter measurement period STOPS
    IF  $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: Wait until current Measurement Period stops
       pmcounters.Wait Until The Current Measurement Period Stops    gnb_id=${GNB_ID_1}
       Log To Console    ${\n}Measurement Period STOPPED
       ${PM_FILES}=    Collect PM Counter    gnb_id=${GNB_ID_1}
       Set Test Variable    ${PM_FILES}
    END

    #  7. Stop Tcpdump on gNB Common Unit and Test PC
    Log To Console    ${\n}Stop ALL tracing on the source and target gNB AND on the wireshark mirror port
    CB010559_keywords.Stop Tracing On GNB   gnb_id=${GNB_ID_0}   tcpdump_filename=tcpdump_gnb_${GNB_ID_0}.pcap
    CB010559_keywords.Stop Tracing On GNB   gnb_id=${GNB_ID_1}   tcpdump_filename=tcpdump_gnb_${GNB_ID_1}.pcap
    CB010559_keywords.Stop Tracing On Test PC Mirror Port And Save As   tcp_file=${testPc_mirrorPort_eth3}.pcap

    #  8. Stop DL traffic and detach UE
    Log To Console    ${\n}Stop UL and DL data transfer and detach UE
    taf.ue.Stop Data Transfer    UL_${UE_ALIAS_1}
    taf.ue.Stop Data Transfer    DL_${UE_ALIAS_1}
    taf.ue.Detach Ue  ${UE_ALIAS_1}
    Sleep  20s  reason=wait release of resources
