*** Settings ***
Documentation   Robot Test Suite for feature '5GC002481-CIAB-SyVe Test Only for 5GC000706 Inter-frequency handover via Xn (SA option 2)' \n
...             Team: 'MN 5G&SC PZ ULM 2 SqdGp63' \n
...             Email: 'I_MN_5GSC_PZ_ULM_SQD_63@nokia.com' \n
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.hw.rf_attenuator              WITH NAME   attenuator
Library    taf.ul.messaging.mtk              WITH NAME   mtk
Library    taf.ue

Library    ute_tshark

Library    5GC000706.py

Resource    ../../resources/Common/testline.robot
Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/tcpdump.robot
Resource    ../../resources/Common/bip_trace.robot
Resource    ../../resources/Common/git_handling.robot

Resource    ../resources/syve_testline.robot
Resource    ../resources/hanging_resources.robot
Resource    ../resources/scf_info.robot

*** Variables ***
${gnb_reboot}   false
${LOGS}         X2-C_S1-C_IFs, testSuiteConfigs
${DEVIATION}    20%

*** Keywords ***
Start UL and DL Traffic for MTK
    [Arguments]    ${dl_rate}  ${ul_rate}  ${protocol}  ${duration}  ${ue_alias}  ${transfer}
    [Documentation]     start DL/UL Traffic on default PDU and second PDU
    ${dl_dt_name}=  Set Variable    DL_${ue_alias}_${transfer}
    ${ul_dt_name}=  Set Variable    UL_${ue_alias}_${transfer}
    IF    '${dl_rate}'!='0Mbits/sec'    taf.ue.Start Data Transfer  dt_name=${dl_dt_name}
    ...    ue_alias=${ue_alias}  direction=dl  duration=${duration}    throughput=${DL_RATE}  protocol=${PROTOCOL}
    ...    packet_size=${1000}, buffer=16M
    IF    '${ul_rate}'!='0Mbits/sec'    taf.ue.Start Data Transfer  dt_name=${ul_dt_name}
    ...    ue_alias=${ue_alias}  direction=ul  duration=${duration}    throughput=${UL_RATE}  protocol=${PROTOCOL}
    ...    packet_size=${1000}, buffer=16M
    RETURN    ${dl_dt_name}    ${ul_dt_name}

Stop DL and UL Traffic for MTK and check throughput
    [Arguments]    ${dl_dt_name}    ${ul_dt_name}  ${dl_rate}  ${ul_rate}
    [Documentation]     Stop DL/UL Traffic and check throughput dl_rate
    IF    '${dl_dt_name}'!='None'    taf.ue.Await Data Transfer Finish  ${dl_dt_name}
    IF    '${ul_dt_name}'!='None'    taf.ue.Await Data Transfer Finish  ${ul_dt_name}
    Run keyword and continue on failure    taf.ue.Verify Average Throughput With Deviation  dt_name=${dl_dt_name}  tput=${DL_RATE}
    ...    deviation=${DEVIATION}
    Run keyword and continue on failure    taf.ue.Verify Average Throughput With Deviation  dt_name=${ul_dt_name}  tput=${UL_RATE}
    ...    deviation=${DEVIATION}

Attach MTK UE, Start and Stop Traffic, Detach
    [Arguments]    ${dl_rate}  ${ul_rate}  ${duration}  ${ue_alias}=${ue_alias}  ${scenario}=SEN1  ${protocol}=udp  ${transfer}=${1}
    hanging_resources.Get resources before test for all nodes
    taf.ue.Attach Ue    ${ue_alias}
    Sleep    5s    reason=Wait to establish all bearers
    Sleep    5s    reason=Wait for sgNB addition
    Log to console    UE MTK Attach done, starting UL and DL traffic
    ${dl_dt_name}    ${ul_dt_name}=    Start UL And DL Traffic For MTK  dl_rate=${DL_RATE}  ul_rate=${UL_RATE}  protocol=${protocol}
    ...    duration=${duration}    ue_alias=${ue_alias}  transfer=${transfer}
    sleep  5s
    Set gNB cell attenuation  scenario=${scenario}
    Log to Console    Setting cell attenuation for scenario ${scenario}
    Stop DL and UL Traffic for MTK and check throughput    dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}
    ...    dl_rate=${DL_RATE}    ul_rate=${UL_RATE}

    sleep  10s
    taf.ue.Detach Ue  ${ue_alias}
    sleep  30s  reason=wait release of resources
    hanging_resources.Get resources after test for all nodes


Set Attenuator to default
    [Arguments]    ${attenuator}    ${gnb_id_source}    ${ru_id_source}
    log to console    Setting Attenuator back to default
    Log    Set attenuation to default
    attenuator.Set Attenuator to Max Value
    attenuator.set_attenuation    port=${tl.gnbs[${gnb_id_source}].dus[${du_id_source}].rus[${ru_id_source}].attenuation_ports[0]}
    ...  value=${20}    attenuator_device=${attenuator}
    attenuator.set_attenuation    port=${tl.gnbs[${gnb_id_source}].dus[${du_id_source}].rus[${ru_id_source}].attenuation_ports[1]}
    ...  value=${20}    attenuator_device=${attenuator}


Set gNB ids
    [Arguments]    ${gnb_id_target}  ${gnb_id_source}  ${ru_id_source}  ${ru_id_target}   ${du_id_source}=${0}  ${du_id_target}=${0}
    [Documentation]     set test variable for target and source ids
    set test variable  ${gnb_id_target}  ${gnb_id_target}
    set test variable  ${gnb_id_source}  ${gnb_id_source}
    set test variable  ${du_id_source}  ${du_id_source}
    set test variable  ${du_id_target}  ${du_id_target}
    set test variable  ${ru_id_source}  ${ru_id_source}
    set test variable  ${ru_id_target}  ${ru_id_target}
    ${gnb_cellid_source}  evaluate   ${ru_id_source}+1
    ${gnb_cellid_target}  evaluate   ${ru_id_target}+1
    set test variable   ${gnb_cellid_source}   ${gnb_cellid_source}
    set test variable   ${gnb_cellid_target}  ${gnb_cellid_target}

Save all Logs and Teardown TL
     connect.Disconnect all available ssh connections
     IF    ('testSuiteLogs' in '${LOGS}')    Collect logs from gNBs
     IF    ('testSuiteConfigs' in '${LOGS}')    Collect configs from gNBs
     syve_testline.Testline Teardown for CCRT

Collect logs from gNBs
    ${resultSuiteLogDir}=    testline.Get test suite log directory
    log_collection.Save DU logs from all gNBs    resultLogsDir=${resultSuiteLogDir}

Collect configs from gNBs
    ${resultSuiteConfigDir}=    testline.Get test suite config directory
    log_collection.Save DU configs from all gNBs    resultConfigsDir=${resultSuiteConfigDir}

Start Tcpdump on gNB
    [Documentation]     starts tcpdump on gNB 0 and 1
    tcpdump.Start Tcpdump on gNB Common Unit  gnb_id=0  collector=gnb0_master
    ...   options=-i any port 38472 or port 38412 or port 38422 or port 38462 or port 36422
    tcpdump.Start Tcpdump on gNB Common Unit  gnb_id=1  collector=gnb1_master
    ...  options=-i any port 38472 or port 38412 or port 38422 or port 38462 or port 36422

Stop Tcpdump on gNB
    [Documentation]     stops tcpdump on gNB 0 and 1
    ${tcp_file_gnb_source_master}  tcpdump.Stop TCP Dump on gNB Common Unit  collector=gnb0_master  tcpdump_filename=Xn_traces_gnb0_master.pcap
    ${tcp_file_gnb_target_master}  tcpdump.Stop TCP Dump on gNB Common Unit  collector=gnb1_master  tcpdump_filename=Xn_traces_gnb1_master.pcap
    set test variable  ${tcp_file_gnb_source_master}
    set test variable  ${tcp_file_gnb_target_master}

Prepare TL for Testing
    Log Variables
    git_handling.Save Current Workspace Info
    testline.Create Test Suite Log Folders
    syve_testline.Save current loads
    syve_testline.Testline Setup for CCRT
    testline.Check TL Infos
    Wait Until Keyword Succeeds    1 min    10 sec    gnb.Wait until Node to be onair state    node_type=gnb  node_id=${0}
    Wait Until Keyword Succeeds    1 min    10 sec    gnb.Wait until Node to be onair state    node_type=gnb  node_id=${1}
    ${configSuiteDir}=    testline.Get test suite config directory
    ${gnb_sw_branch}  Get gNB SW Branch
    Set suite variable  ${gnb_sw_branch}
    Set suite variable  ${configSuiteDir}
    ${nrbts_id_0}=  scf_info.Get NRBTS-Id  gnb_id=${0}
    set suite variable  ${nrbts_id_0}
    ${nrbts_id_1}=  scf_info.Get NRBTS-Id  gnb_id=${1}
    set suite variable  ${nrbts_id_1}
    Commission delta gnb_scf


Activate actInterFreqHoSA
    [Arguments]    ${actInterFreqHoSA}  ${gnb_id}
    [Documentation]     change actInterFreqHoSA to the needed value
    Log To Console    \online change of actInterFreqHoSA
    ${configSuiteDir}=    testline.Get test suite config directory
    ${parameter1}=  create dictionary  value=${actInterFreqHoSA}  dist_name=NRBTS-${nrbts_id_${gnb_id}}  p_name=actInterFreqHoSA
    ${param_list}=  Create List  ${parameter1}
    ${delta_scf_path}=  Generate Delta Commissioning File  scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml  parameters_list=${param_list}
    ...  target_local_path=${resultTestDir}/gNB${gnb_id}_actInterFreqHoSA_${actInterFreqHoSA}.xml
    Execute delta commissioning   delta_scf_template=${delta_scf_path}    resultDir=${resultTestDir}    gnb_id=${gnb_id}

Configure actCDrx
    [Arguments]    ${gnb_id}  ${actCDrx}  ${nrcell_id}
    [Documentation]     change actCDrx to the needed value
    Log To Console    \online change of actCDrx
    ${configSuiteDir}=    testline.Get test suite config directory
    ${parameter1}=  create dictionary  value=${actCDrx}  dist_name=NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell_id}  p_name=actCDrx
    ${param_list}=  Create List  ${parameter1}
    ${delta_scf_path}=  Generate Delta Commissioning File  scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU.xml  parameters_list=${param_list}
    ...  target_local_path=${resultTestDir}/gNB${gnb_id}_delta_scf_file_actCDrx_${actCDrx}.xml
    Execute delta commissioning   delta_scf_template=${delta_scf_path}    resultDir=${resultTestDir}    gnb_id=${gnb_id}

Perform Postconditions of Test Scenario
    Sleep    10s    reason=Wait for logging issues
    IF    ('X2-C_S1-C_IFs' in '${LOGS}')    tcpdump.Stop TCPdump on all eNBs
    syve_testline.Save current loads
    log to console    Setting Attenuator back to max value
    Log    Set attenuation to max value
    attenuator.Set Attenuator to Max Value
    teardown tshark


Combined Test Teardown
    [Documentation]
    ...    Performs the postconditions of each TC and adds a CCRT.

    Perform Postconditions of Test Scenario
    CCRT Test Cases Teardown


Commission delta gnb_scf
    Log To Console    \Loading delta gnb scf parameters
    Create Delta Commission Json For 706_gnb0  nrbts_id=${nrbts_id_0}  gnb_id=0
    Create Delta Commission Json For 706_gnb1  nrbts_id=${nrbts_id_1}  gnb_id=1

Load initial gnb scf
    Log To Console    \Loading initial scf file for both gnbs
    ${initial_scf_path_gnb1}=       syve_testline.Get GNB initial config path    1
    commissioning.Execute full commissioning    ${initial_scf_path_gnb1}    1
    ${initial_scf_path_gnb0}=       syve_testline.Get GNB initial config path    0
    commissioning.Execute full commissioning    ${initial_scf_path_gnb0}    0

Commission delta gnb_scf for FD-05
    Log To Console    \Loading delta gnb-1 scf parameters for FD-05
    Create Delta Commission Json For 706-FD05  nrbts_id=${nrbts_id_1}  gnb_id=1
