*** Settings ***
Documentation
...    author:
...    contact: I_MN_5GSC_PZ_ULM_SQD_63@nokia.com
...    Description: Keywords for feature CB008917

Library    taf.sbts.oam.coam.admin            WITH NAME   admin
Library    taf.hw.rf_attenuator               WITH NAME   attenuator
Library    taf.ue

Library    ute_tshark
Library    capture.py

Resource   ../../../resources/Common/log_collection.robot
Resource   ../../../resources/Common/tcpdump.robot
Resource   ../../../resources/Common/btslog.robot
Resource   ../../../resources/Common/connect.robot
Resource   ../../../resources/Common/core.robot
Resource   ../../../resources/Common/commissioning.robot
Resource   ../../../resources/Common/util.robot
Resource   ../../../resources/Common/gnb.robot
Resource   ../../../resources/Common/coam_ulm.robot
Resource   ../../../resources/Common/git_handling.robot

Resource   ../../resources/traffic.robot
Resource   ../../resources/syve_testline.robot
Resource   ../../resources/attenuator_scenario.robot
Resource   ../../resources/enb_log_collection.robot
Resource   ../../resources/hanging_resources.robot
Resource   ../../resources/iperf_processes.robot
Resource   ../../resources/scf_info.robot

Resource   verification.robot

*** Variables ***

${withPMcountersCheck}    true

*** Keywords ***

Save all Logs and Teardown TL
    IF    'testSuiteLogs' in ${LOGS}    Collect logs from gNBs
    IF    'testSuiteConfigs' in ${LOGS}
        Collect configs from gNBs
        Collect configs from eNBs
    END
    syve_testline.Testline Teardown for CCRT


Collect logs from gNBs
    ${resultSuiteLogDir}=    testline.Get test suite log directory
    log_collection.Save DU logs from all gNBs    resultLogsDir=${resultSuiteLogDir}

Collect configs from gNBs
    ${resultSuiteConfigDir}=    testline.Get test suite config directory
    log_collection.Save DU configs from all gNBs    resultConfigsDir=${resultSuiteConfigDir}

Collect configs from eNBs
    ${resultSuiteConfigDir}=    testline.Get test suite config directory
    enb_log_collection.Save configs from all eNBs    resultConfigsDir=${resultSuiteConfigDir}

Start Tcpdump on gNB
    [Documentation]     starts tcpdump on gNB asib
    [Arguments]    @{}   ${number}=${0}    ${gnb_id}=${0}
        tcpdump.Start Tcpdump on gNB Common Unit
        ...   gnb_id=${gnb_id}
        ...   collector=Xn_traces_gnb${gnb_id}_master_${number}
        ...   options=-i any port 38472 or port 38412 or port 38422 or port 38462 or port 36422


Stop Tcpdump on gNB
    [Documentation]     stops tcpdump on gNB asib
    [Arguments]    ${number}=${0}    ${gnb_id}=${0}
    ${tcp_file_master}  tcpdump.Stop TCP Dump on gNB Common Unit
    ...    collector=Xn_traces_gnb${gnb_id}_master_${number}  tcpdump_filename=Xn_traces_gnb${gnb_id}_master_${number}.pcap
    IF    'intragNB' in ${TEST TAGS} and ${gnb_id}==${1}
    ...   Set Test Variable  ${tcp_file_gnb_target_master_${number}}    ${tcp_file_master}
    ...   ELSE    Set Test Variable  ${tcp_file_gnb_source_master_${number}}    ${tcp_file_master}


Common UE setup
    [Arguments]    ${ue_alias}=${UE_ALIAS_1}
    Log to Console    ${ue_alias}: UE setup might take up to 2 min
    IF    '${ue_alias}'=='${UE_ALIAS_1}'    taf.ue.Require Ue   ${UE_ALIAS_1}  capabilities=UE_1
    ...   ELSE IF    '${ue_alias}'=='${UE_ALIAS_2}'    taf.ue.Require Ue   ${UE_ALIAS_2}  capabilities=UE_2
    Sleep    150s    reason=Wait for setup
    Run keywords
    # MTK does not need execution of taf.ue.reboot, keyword not working since it is already part of Require UE
    ${capabilities}=    Set Variable     ${tl.ues[0].capabilities}
    IF   'REAL_QUALCOMM_UE' in ${capabilities}
        Log to Console    ${ue_alias}: UE reboot will be executed
        taf.ue.Reboot Ue  ${ue_alias}
        Sleep  30s  reason=wait for setup (askey ues are slow)
    END

Combined Test Teardown
    [Documentation]    Performs the postconditions of each TC and adds a CCRT.
    [Arguments]    ${node_type}=gnb
    Perform Postconditions of Test Scenario
    syve_testline.CCRT Test Cases Teardown  node_type=${node_type}


Attach UE and start traffic
    [Arguments]    ${ul_rate}    ${dl_rate}    ${ue_alias}=${UE_ALIAS_1}
    ...    ${Mobility_type}=None
    Log Variables
    set test variable  ${Mobility_tput}  ${Mobility_type}
    sleep  10s  reason=wait release of resources
    hanging_resources.Get resources before test for all nodes
    taf.ue.Attach Ue  ${ue_alias}
    Sleep    5s    reason=Wait for sgNB addition
    ${dl_dt_name}    ${ul_dt_name}=    Start traffic for ue    dl_rate=${dl_rate}    ul_rate=${ul_rate}
    ...    ue_alias=${ue_alias}


Attach UE for mobility and start traffic
    [Arguments]    ${ul_rate}    ${dl_rate}    ${ue_alias}=${UE_ALIAS_1}    ${scenario}=SEN1
    #Start connecting to source Cell
    set test variable  ${Mobility_tput}  Source
    Log Variables
    sleep  10s  reason=wait release of resources
    hanging_resources.Get resources before test for all nodes
    taf.ue.Attach Ue  ${ue_alias}
    Sleep    5s    reason=Wait for sgNB addition
    ${dl_dt_name}    ${ul_dt_name}=    Start traffic for ue    dl_rate=${dl_rate}    ul_rate=${ul_rate}
    ...    ue_alias=${ue_alias}
    taf.ue.Await Data Transfer Finish    ${dl_dt_name}
    taf.ue.Await Data Transfer Finish    ${ul_dt_name}
    Stop traffic for ue    dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}
    ...    expected_dl_rate=${dl_rate}    expected_ul_rate=${ul_rate}
    Log to console  \nStop DL and UL Data Transfer done and verify throuput before HO!
    #Start of First HO
    set test variable  ${Mobility_tput}  Target
    Log to console  \nFirst Handover Start!
    Sleep    5s    reason=Wait for sgNB addition
    ${dl_dt_name}    ${ul_dt_name}=    Start traffic for ue    dl_rate=${dl_rate}    ul_rate=${ul_rate}
    ...    ue_alias=${ue_alias}
    Set gNB cell attenuation with file  scenario=${scenario}_One_side
    taf.ue.Await Data Transfer Finish    ${dl_dt_name}
    taf.ue.Await Data Transfer Finish    ${ul_dt_name}
    Log to console  \nFirst Handover Stop!
    #End of First HO
    Log to console  \nStart data after First HO!
    sleep    5s    reason=Wait for sgNB addition
    ${dl_dt_name}    ${ul_dt_name}=    Start traffic for ue    dl_rate=${dl_rate}    ul_rate=${ul_rate}
    ...    ue_alias=${ue_alias}
    taf.ue.Await Data Transfer Finish    ${dl_dt_name}
    taf.ue.Await Data Transfer Finish    ${ul_dt_name}
    Stop traffic for ue    dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}
    ...    expected_dl_rate=${dl_rate}    expected_ul_rate=${ul_rate}
    Log to console  \nStop DL and UL Data Transfer done and verify throuput after First HO!
    Sleep    10s    reason=Wait for Data Trasnfer to be finished
    Stop Tcpdump on gNB    number=${0}
    IF    'CB007271-C_TC11' in ${TEST TAGS}
    ...    Start Scell release data transfer    ul_rate=${ul_rate}    dl_rate=${dl_rate}
    #Start of Second HO
    set test variable  ${Mobility_tput}  Source
    Start Tcpdump on gNB    number=${1}
    Log to console  \nSecond Handover Start!
    Sleep    5s    reason=Wait for sgNB addition
    ${dl_dt_name}    ${ul_dt_name}=    Start traffic for ue    dl_rate=${dl_rate}    ul_rate=${ul_rate}
    ...    ue_alias=${ue_alias}
    Set gNB cell attenuation with file  scenario=${scenario}_two_side
    taf.ue.Await Data Transfer Finish    ${dl_dt_name}
    taf.ue.Await Data Transfer Finish    ${ul_dt_name}
    Log to console  \nSecond Handover Stop!
    #End of Second HO
    Log to console  \nStart data after Second HO!
    sleep    5s    reason=Wait for sgNB addition
    ${dl_dt_name}    ${ul_dt_name}=    Start traffic for ue    dl_rate=${dl_rate}    ul_rate=${ul_rate}
    ...    ue_alias=${ue_alias}
    taf.ue.Await Data Transfer Finish    ${dl_dt_name}
    taf.ue.Await Data Transfer Finish    ${ul_dt_name}
    Stop traffic for ue    dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}
    ...    expected_dl_rate=${dl_rate}    expected_ul_rate=${ul_rate}
    Log to console  \nStop DL and UL Data Transfer done and verify throuput after Second HO!
    Sleep    10s    reason=Wait for Data Trasnfer to be finished
    Detach  UE only    ue_alias=${UE_ALIAS_1}
    sleep  20s  reason=wait release of resources
    hanging_resources.Get resources after test for all nodes


Attach UE only
    [Arguments]    ${ue_alias}=${UE_ALIAS_1}
    taf.ue.Detach Ue  ${ue_alias}
    sleep  30s  reason=wait for Detach
    taf.ue.Attach Ue  ${ue_alias}
    Sleep    30s    reason=Wait to establish all bearers

Detach UE only
    [Arguments]    ${ue_alias}=${UE_ALIAS_1}
    taf.ue.Detach Ue  ${ue_alias}
    Sleep    10s    reason=Wait for logging issues

Set eNB gNB ids
    [Arguments]    ${gnb_id_source}  ${ru_id_source_pcell}  ${ru_id_source_scell}  ${du_id_source}=${0}
    ...    ${gnb_id_target}=${0}  ${ru_id_target_pcell}=${0}  ${ru_id_target_scell}=${0}  ${du_id_target}=${0}  ${tc_mimo_mode}=${4}
    ...    ${S_Pcell}=${None}  ${S_Scell_1}=${None}  ${S_Scell_2}=${None}  ${block_extra_cell}=${None}
    ...    ${T_Pcell}=${None}  ${T_Scell_1}=${None}  ${T_Scell_2}=${None}  ${ru_id_source_scell2}=${0}  ${ru_id_target_scell2}=${0}
    [Documentation]     set test variable for target and source ids
    set test variable  ${gnb_id_source}  ${gnb_id_source}
    set test variable  ${du_id_source}  ${du_id_source}
    set test variable  ${ru_id_source_pcell}  ${ru_id_source_pcell}
    set test variable  ${ru_id_source_scell}  ${ru_id_source_scell}
    set test variable  ${ru_id_source_scell2}  ${ru_id_source_scell2}
    set test variable  ${gnb_id_target}  ${gnb_id_target}
    set test variable  ${du_id_target}  ${du_id_target}
    set test variable  ${ru_id_target_pcell}  ${ru_id_target_pcell}
    set test variable  ${ru_id_target_scell}  ${ru_id_target_scell}
    set test variable  ${ru_id_target_scell2}  ${ru_id_target_scell2}
    set test variable  ${tc_mimo_mode}  ${tc_mimo_mode}
    set suite variable  ${S_Pcell}  ${S_Pcell}
    set suite variable  ${S_Scell_1}  ${S_Scell_1}
    set suite variable  ${S_Scell_2}  ${S_Scell_2}
    set test variable  ${T_Pcell}  ${T_Pcell}
    set test variable  ${T_Scell_1}  ${T_Scell_1}
    set test variable  ${T_Scell_2}  ${T_Scell_2}
    set test variable  ${block_extra_cell}  ${block_extra_cell}
#    set eNB blocked cells


Set eNB ids
    [Arguments]    ${eNB_id_target}  ${eNB_id_source}  ${rm_id_target}  ${rm_id_source}
    [Documentation]     set test vairable for target and source ids
    set test variable  ${enb_id_target}  ${enb_id_target}
    set test variable  ${enb_id_source}  ${enb_id_source}
    set test variable  ${rm_id_target}  ${rm_id_target}
    set test variable  ${rm_id_source}  ${rm_id_source}


Get gnb physCellId
    [Arguments]    ${gnb_id}  ${nrcell_id}
    [Documentation]     get physical cell id from gnb
    ${oam_alias}   connect.Setup OAM HTTP Session   node_id=${gnb_id}
    ${physCellId}  coam_ulm.Get SCF Single Value From Current Xml File   alias=${oam_alias}
    ...   dist_name=NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell_id}
    ...   parameter=physCellId
    RETURN  ${physCellId}

Get gnb physCellIds
    [Documentation]     get the physCellId for the testscenario
    [Arguments]    ${physSCell}=${None}  ${physPCell}=${None}
    ${ru_id_Psource}=    Evaluate  ${ru_id_source_pcell}+${1}
    IF  '${physPCell}'=='None'    set test variable  ${ru_id_Psource}
    ...    ELSE    set test variable  ${ru_id_Psource}  ${physPcell}
    ${PHYSCELLIDSOURCEPCELL}  Get gnb physCellId  gnb_id=${gnb_id_source}  nrcell_id=${ru_id_Psource}
    set suite variable  ${PHYSCELLIDSOURCEPCELL}
    ${ru_id_Ssource}=    Evaluate  ${ru_id_source_scell}+${1}
    IF  '${physSCell}'=='None'     set test variable  ${ru_id_Ssource}
    ...    ELSE    set test variable  ${ru_id_Ssource}  ${physSCell}
    ${PHYSCELLIDSOURCESCELL}  Get gnb physCellId  gnb_id=${gnb_id_source}  nrcell_id=${ru_id_Ssource}
    set suite variable  ${PHYSCELLIDSOURCESCELL}


Start traffic for ue
    [Arguments]    ${dl_rate}    ${ul_rate}    ${ue_alias}=${UE_ALIAS_1}
    set suite variable  ${dl_dt_name}  DL_${ue_alias}
    set suite variable  ${ul_dt_name}  UL_${ue_alias}
    IF    '${dl_rate}'!='0Mbits/sec'    taf.ue.Start Data Transfer    dt_name=${dl_dt_name}
    ...    ue_alias=${ue_alias}    direction=dl    throughput=${dl_rate}Mbits/sec    bearer_alias=UeAutomatic    protocol=${DL_Protocol}
    ...    timeout=60    duration=${DURATION_DL}s    buffer=50M    packet_size=1330    parallel=${DL_Parallel_Stream}
    IF    '${ul_rate}'!='0Mbits/sec'    taf.ue.Start Data Transfer    dt_name=${ul_dt_name}
    ...    ue_alias=${ue_alias}    direction=ul    throughput=${ul_rate}Mbits/sec    bearer_alias=UeAutomatic    protocol=${UL_Protocol}
    ...    timeout=60    duration=${DURATION_UL}s    buffer=50M    packet_size=1330
    RETURN    ${dl_dt_name}    ${ul_dt_name}


Stop traffic for ue
    [Arguments]    ${dl_dt_name}    ${ul_dt_name}    ${expected_dl_rate}    ${expected_ul_rate}
    ...    ${DL_analysis_start}=${0}    ${DL_analysis_end}=${DURATION_DL}    ${UL_analysis_start}=${0}    ${UL_analysis_end}=${DURATION_UL}
    Record iperf data    dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}
    ...    DL_in_time=${DL_analysis_start}    DL_out_time=${DL_analysis_end}    UL_in_time=${UL_analysis_start}
    ...    UL_out_time=${UL_analysis_end}
    IF    '${dl_dt_name}'!='None'    taf.ue.Await Data Transfer Finish    dt_name=${dl_dt_name}
    IF    '${ul_dt_name}'!='None'    taf.ue.Await Data Transfer Finish    dt_name=${ul_dt_name}
    IF    'Multi_UE' in ${TEST TAGS} and '${Mobility_tput}' == 'Two_UEs'
    ...           verify Multi UE DL UL throughput    Expected_DL_RATE=${expected_dl_rate}   Expected_UL_RATE=${expected_ul_rate}
    ...    ELSE   verify Single DL UL throughput    Expected_DL_RATE=${expected_dl_rate}   Expected_UL_RATE=${expected_ul_rate}
    ...    dl_dt_name=${dl_dt_name}    ul_dt_name=${ul_dt_name}
    Log to console  \nStop DL and UL Data Transfer done!
    Sleep    10s    reason=Wait for Data Transfer to be finished


verify Multi UE DL UL throughput
    [Arguments]    ${Expected_DL_RATE}    ${Expected_UL_RATE}
    ${Total_UL}=    Fetch from left   ${Expected_UL_RATE}   Mbits/sec
    ${Total_DL}=    Fetch from left   ${Expected_DL_RATE}   Mbits/sec
    ${ul_status}=    Evaluate
    ...    ${Total_UL} * 0.92 <= ${observed_ul_throughput_in_Mbps} <= ${Total_UL} * 1.08
    ${dl_status}=    Evaluate
    ...    ${Total_DL} * 0.92 <= ${observed_dl_throughput_in_Mbps} <= ${Total_DL} * 1.08
    Should be true    ${ul_status}
    Should be true    ${dl_status}


Record iperf data
    [Arguments]    ${dl_dt_name}    ${ul_dt_name}
    ...    ${DL_in_time}    ${DL_out_time}   ${UL_in_time}    ${UL_out_time}
    capture.reset_capture
    taf.ue.Await Data Transfer Finish   ${dl_dt_name}
    taf.ue.Stop Data Transfer   ${dl_dt_name}
    ${iperf_capture}=    capture.get_capture
    ${iperf_server_file_list}=    Get RegExp Matches    ${iperf_capture}    (?ms)^(\-+\nServer listening on.*?\n(?:\n|\\Z))    1
    ${iperf_server_file}=    Get From List    ${iperf_server_file_list}    ${0}
    Create File    ${resultTestDir}/dl_iperf_server.log     ${iperf_server_file}
    capture.reset_capture
    taf.ue.Await Data Transfer Finish    ${ul_dt_name}
    taf.ue.Stop Data Transfer   ${ul_dt_name}
    ${iperf_capture}=    capture.get_capture
    ${iperf_server_file_list}=    Get RegExp Matches    ${iperf_capture}    (?ms)^(\-+\nServer listening on.*?\n(?:\n|\\Z))    1
    ${iperf_server_file}=    Get From List    ${iperf_server_file_list}    ${0}
    Create File    ${resultTestDir}/ul_iperf_server.log     ${iperf_server_file}
    Log DL and UL throughput    DL_analysis_in=${DL_in_time}    DL_analysis_out=${DL_out_time}
    ...    UL_analysis_in=${UL_in_time}    UL_analysis_out=${UL_out_time}


Log DL and UL throughput
    [Arguments]    ${DL_analysis_in}    ${DL_analysis_out}    ${UL_analysis_in}    ${UL_analysis_out}
    ${observed_dl_throughput_in_Mbps}=    traffic.Get average throughput
        ...    file_path=${resultTestDir}/dl_iperf_server.log    desired_unit=M
        ...    analysis_start=${DL_analysis_in}    analysis_end=${DL_analysis_out}
    ${observed_ul_throughput_in_Mbps}=    traffic.Get average throughput
        ...    file_path=${resultTestDir}/ul_iperf_server.log    desired_unit=M
        ...    analysis_start=${UL_analysis_in}    analysis_end=${UL_analysis_out}
    Set suite variable  ${observed_dl_throughput_in_Mbps}    ${observed_dl_throughput_in_Mbps}
    Set suite variable  ${observed_ul_throughput_in_Mbps}    ${observed_ul_throughput_in_Mbps}
    Log to console    \nAverage DL Throughput ${observed_dl_throughput_in_Mbps} Mbits/s
    Log to console    \nAverage UL Throughput ${observed_ul_throughput_in_Mbps} Mbits/s

Start X2-C_S1-C_IFs logs
    IF    'X2-C_S1-C_IFs' in ${LOGS}    tcpdump.Start TCPdump on all eNBs


Stop X2-C_S1-C_IFs logs
    IF    'X2-C_S1-C_IFs' in ${LOGS}    tcpdump.Stop TCPdump on all eNBs

Prepare TL for Testing
    Log Variables
    git_handling.Save Current Workspace Info
    testline.Create Test Suite Log Folders
    syve_testline.Save current loads
    syve_testline.Testline Setup for CCRT
    testline.Check TL Infos
    ${configSuiteDir}=    testline.Get test suite config directory
    ${gnb_sw_branch}  Get gNB SW Branch
    Set suite variable  ${gnb_sw_branch}
    Set suite variable  ${configSuiteDir}
    ${mrbts_id_0}=  scf_info.Get MRBTS-Id  enb_id=${0}
    set suite variable  ${mrbts_id_0}
    ${nrbts_id_0}=  scf_info.Get NRBTS-Id  gnb_id=${0}
    set suite variable  ${nrbts_id_0}


Configure testline attenuation
    [Arguments]    ${on_value}=${20}    ${enb_id}=${0}
    Set eNB cell attenuation    value_in_db=${on_value}    enb_id=${enb_id}    ru_id=${0}    port_id=${0}
    Set eNB cell attenuation    value_in_db=${on_value}    enb_id=${enb_id}    ru_id=${0}    port_id=${1}


Get current testline name
    ${tl_name}=    testline.Get Testline Name
    ${_}	   ${last}=	   String.split string from right    string=${tl_name}    separator=_    max_split=${1}
    ${ctl}=    String.convert to lowercase    ${last}
    RETURN    ${ctl}

Convert PCAP2PDML
    [Arguments]    ${resultTestDir}    ${node_id}=${0}    ${node_type}=gnb    ${number}=${0}
    ${dist_path}           Set Variable If     '${node_type}'=='gnb'   Xn_traces_gnb${node_id}_master_${number}
    ...                                     '${node_type}'=='enb'   enb${node_id}_s1x2_tcpdump
    util.Convert PCAP to PDML    source=${resultTestDir}/${dist_path}/${dist_path}.pcap
    ...    target=${resultTestDir}/${dist_path}/${dist_path}.pdml
    #Create pdml file for filtered pcap file
    ${output}    ute_tshark.read pcap    packet_filter=f1ap.procedureCode == 7    output_type=pdml
    ...    pcap_file_path=${resultTestDir}/${dist_path}/${dist_path}.pcap
    Create File  ${resultTestDir}/f1ap_filtered_traces_gnb${gnb_id_source}_master_${number}.pdml  ${output}
    IF    'intragNB' in ${TEST TAGS}    Convert target gnb files
    IF    'CB007271-C_TC10' in ${TEST TAGS}    Convert gnb files of two UEs  max_files=${4}
    IF    'Mobility' in ${TEST TAGS}    Convert extra mobility files
    IF    'Multi_UE' in ${TEST TAGS}    Convert gnb files of two UEs  max_files=${3}


Convert target gnb files
    [Documentation]    do extra convert due to target gnb
    util.Convert PCAP to PDML    source=${resultTestDir}/Xn_traces_gnb${gnb_id_target}_master_0/Xn_traces_gnb${gnb_id_target}_master_0.pcap
    ...    target=${resultTestDir}/Xn_traces_gnb${gnb_id_target}_master_0/Xn_traces_gnb${gnb_id_target}_master_0.pdml
    ${output}    ute_tshark.read pcap    packet_filter=f1ap.procedureCode == 7    output_type=pdml
    ...    pcap_file_path=${resultTestDir}/Xn_traces_gnb${gnb_id_target}_master_0/Xn_traces_gnb${gnb_id_target}_master_0.pcap
    Create File    ${resultTestDir}/f1ap_filtered_traces_gnb${gnb_id_target}_master_0.pdml  ${output}


Convert extra mobility files
    [Documentation]    do extra convert due to mobility
    util.Convert PCAP to PDML    source=${resultTestDir}/gnb${gnb_id_source}_master_1/Xn_traces_gnb${gnb_id_source}_master_1.pcap
    ...    target=${resultTestDir}/Xn_traces_gnb${gnb_id_source}_master_1/Xn_traces_gnb${gnb_id_source}_master_1.pdml
    ${output}    ute_tshark.read pcap    packet_filter=f1ap.procedureCode == 7    output_type=pdml
    ...    pcap_file_path=${resultTestDir}/Xn_traces_gnb${gnb_id_source}_master_1/Xn_traces_gnb${gnb_id_source}_master_1.pcap
    Create File    ${resultTestDir}/f1ap_filtered_traces_gnb${gnb_id_source}_master_1.pdml  ${output}


Block unBlock cells
     [Documentation]    block or unblock cells for eNB or gNB
     [Arguments]    ${block_cell_1}    ${block_cell_2}=None    ${block_extra_cell}=None    ${node_type}=gnb    ${cell_op}=block    ${node_id}=${0}
     log to console    \n${cell_op} cells of ${node_type}
     ${dist_path}           Set Variable If     '${node_type}'=='gnb'   NRBTS-${nrbts_id_${node_id}}/NRCELL
    ...                                     '${node_type}'=='enb'   LNBTS-${mrbts_id_${node_id}}/LNCEL
     ${oam_alias}=   wait until keyword succeeds   3 min   20 sec   connect.Setup OAM http session  node_type=${node_type}  node_id=${node_id}
     set test variable  ${oam_alias}
     ${bts_id}=    Set Variable if    '${node_type}'=='gnb'    ${nrbts_id_${node_id}}
                   ...                '${node_type}'=='enb'    ${mrbts_id_${node_id}}
     IF    '${block_cell_1}'!='${None}'    Run keyword   admin.${cell_op}_cell
     ...    dist_name=MRBTS-${bts_id}/${dist_path}-${block_cell_1}  connection=${oam_alias}
     IF    '${block_cell_2}'!='${None}'    Run keyword   admin.${cell_op}_cell
     ...    dist_name=MRBTS-${bts_id}/${dist_path}-${block_cell_2}  connection=${oam_alias}
     IF    '${block_extra_cell}'!='${None}'    Run keyword   admin.${cell_op}_cell
     ...    dist_name=MRBTS-${bts_id}/${dist_path}-${block_extra_cell}  connection=${oam_alias}
     Sleep    30s    reason=Wait for cells to block

Block unBlock all cells except needed
    [Documentation]    block cells for eNB or gNB
    [Arguments]    ${all_cells}    ${needed_cells}    ${node_type}=gnb    ${cell_op}=block    ${node_id}=${0}
    log to console    \n${cell_op} cells of ${node_type} which not needed
    ${bts_id}=  IF   '${node_type}'=='gnb'   scf_info.Get NRBTS-Id  ${node_id}
    ...    ELSE    Get MRBTS-Id  ${node_id}
    ${dist_path}           Set Variable If     '${node_type}'=='gnb'   NRBTS-${bts_id}/NRCELL
    ...                                     '${node_type}'=='enb'   LNBTS-${bts_id}/LNCEL
    ${oam_alias}=   wait until keyword succeeds   3 min   20 sec   connect.Setup OAM http session  node_type=${node_type}  node_id=${node_id}
    set test variable  ${oam_alias}
    FOR   ${node_cell_block}  IN  @{all_cells}
        IF    '${node_cell_block}' not in ${needed_cells}    Run keyword   admin.${cell_op}_cell
        ...    dist_name=MRBTS-${bts_id}/${dist_path}-${node_cell_block}  connection=${oam_alias}
    END
    Sleep    30s    reason=Wait for cells to block

set cell attenuation value
    [Documentation]    sets the attenuation values for pcell for gNB
    [Arguments]    ${value}    ${node_type}=gnb    ${node_id}=${0}    ${ru_id}=${0}    ${mimo}=${4}    ${attenuator_device}=attenuator
    FOR   ${port}  IN RANGE  ${0}  ${mimo}
        attenuator.set_attenuation    port=${tl.${node_type}s[${node_id}].dus[${0}].rus[${ru_id}].attenuation_ports[${port}]}
    ...  value=${value}    attenuator_device=${attenuator_device}
    END

set testcase attenuation
    [Documentation]    sets the attenuation values for pcell for gNB
    [Arguments]    ${ru_id_pcell}    ${ru_id_scell}    ${ru_id_scell2}    ${pcell_value}=${15}    ${Scell_value}=${20}
    log to console    \nSet attenuation for RU of Pcell
    IF    '${ru_id_pcell}'!='${None}'    common_keywords.set cell attenuation value
    ...    value=${pcell_value}    ru_id=${ru_id_pcell}
    IF    '${ru_id_scell}'!='${None}'    common_keywords.set cell attenuation value
    ...    value=${Scell_value}    ru_id=${ru_id_scell}
    IF    '${ru_id_scell2}'!='${None}'    common_keywords.set cell attenuation value
    ...    value=${Scell_value}    ru_id=${ru_id_scell2}

Attach to Pcell
    [Documentation]    block Scells and attach to Pcell
    [Arguments]    ${block_cell_1}  ${block_cell_2}=None  ${block_extra_cell}=None
    log to console    \nBlock Scells and attach to PCell Starts
    Block unBlock all cells except needed    all_cells=@{all_enb_cells}    needed_cells=@{enb_cells_not_block}
    ...    node_type=enb    cell_op=block    node_id=${enb_id_source}
    Block unBlock cells    block_cell_1=${block_cell_1}    block_cell_2=${block_cell_2}    block_extra_cell=${block_extra_cell}
    ...    node_type=gnb    cell_op=block    node_id=${gnb_id_source}
    Attach UE only    ue_alias=${UE_ALIAS_1}
    IF    'Multi_UE' in ${TEST TAGS}    Attach UE only    ue_alias=${UE_ALIAS_2}
    Sleep    15s    reason=Wait to establish connection
    Detach UE only    ue_alias=${UE_ALIAS_1}
    IF    'Multi_UE' in ${TEST TAGS}    Detach UE only    ue_alias=${UE_ALIAS_2}
    Block unBlock cells    block_cell_1=${block_cell_1}    block_cell_2=${block_cell_2}    block_extra_cell=${block_extra_cell}
    ...    node_type=gnb    cell_op=unblock    node_id=${gnb_id_source}
    log to console    \nBlock Scells and attach to PCell is Done

Convert gnb files of two UEs
    [Arguments]   ${max_files}=${3}
    [Documentation]    do extra convert for TC10
    FOR   ${id}    IN RANGE    0    ${max_files}
        set test variable    ${dist_path}    Xn_traces_gnb${gnb_id_source}_master_${id}
        util.Convert PCAP to PDML
        ...    source=${resultTestDir}/${dist_path}/${dist_path}.pcap    target=${resultTestDir}/${dist_path}.pdml
        ${output}    ute_tshark.read pcap    packet_filter=f1ap.procedureCode == 7    output_type=pdml
        ...    pcap_file_path=${resultTestDir}/${dist_path}/${dist_path}.pcap
        Create File    ${resultTestDir}/f1ap_filtered_traces_gnb${gnb_id_source}_master_${id}.pdml  ${output}
    END

DL UL Data traffic for multiple UE
    [Arguments]      ${gnb_attenuation}=False    ${scenario}=SEN1
    ...    ${DL_analysis_start}=${0}    ${DL_analysis_end}=${DURATION_DL}    ${UL_analysis_start}=${0}
    ...    ${UL_analysis_end}=${DURATION_UL}
    Log Variables
    Attach UE only    ue_alias=${UE_ALIAS_1}
    Attach UE only    ue_alias=${UE_ALIAS_2}
    set test variable    ${DURATION_UL}    130
    set test variable    ${DURATION_DL}    140
    ${dl_UE0}    ${ul_UE0}=    Start traffic for ue    ue_alias=${UE_ALIAS_1}    dl_rate=${dl_rate}    ul_rate=${ul_rate}
    ${dl_UE1}    ${ul_UE1}=    Start traffic for ue    ue_alias=${UE_ALIAS_2}    dl_rate=${dl_rate}    ul_rate=${ul_rate}
    IF    '${gnb_attenuation}'=='True'    Set gNB cell attenuation with file  scenario=${scenario}_One_side
    taf.ue.Await Data Transfer Finish    ${dl_UE1}
    taf.ue.Await Data Transfer Finish    ${ul_UE1}
    taf.ue.Await Data Transfer Finish    ${dl_UE0}
    taf.ue.Await Data Transfer Finish    ${ul_UE0}
    ${Total_UL}=    Fetch from left   ${expected_ul}   Mbits/sec
    ${Expected_UL}=    Evaluate    ${Total_UL} * 0.5
    ${Total_DL}=    Fetch from left   ${expected_dl}   Mbits/sec
    ${Expected_DL}=    Evaluate    ${Total_DL} * 0.5
    Log to console  \nStop DL and UL Data Transfer and verify throughput for UE-0
    Stop traffic for ue    dl_dt_name=${dl_UE0}    ul_dt_name=${ul_UE0}
    ...    expected_dl_rate=${Expected_DL}Mbits/sec    expected_ul_rate=${Expected_UL}Mbits/sec
    ...    DL_analysis_start=${DL_analysis_start}    DL_analysis_end=${DL_analysis_end}    UL_analysis_start=${UL_analysis_start}
    ...    UL_analysis_end=${UL_analysis_end}
    Log to console  \nStop DL and UL Data Transfer and verify throughput for UE-1
    Stop traffic for ue    dl_dt_name=${dl_UE1}    ul_dt_name=${ul_UE1}
    ...    expected_dl_rate=${Expected_DL}Mbits/sec    expected_ul_rate=${Expected_UL}Mbits/sec
    ...    DL_analysis_start=${DL_analysis_start}    DL_analysis_end=${DL_analysis_end}    UL_analysis_start=${UL_analysis_start}
    ...    UL_analysis_end=${UL_analysis_end}
    Sleep    10s    reason=Wait for Data Trasnfer to be finished


Load initial gnb scf
    Log To Console    \Loading initial scf file for gnb
    ${init_gnb_scf_path}=    syve_testline.Get GNB initial config path    gnb_id=${0}
    ${gnb_path}=    Fetch from left   ${init_gnb_scf_path}   /scf.xml
    IF    '2x2MIMO' in ${TEST TAGS}
    ...    commissioning.Execute full commissioning
    ...    scf_path=${gnb_path}/scf_2x2.xml  gnb_id=${0}
    IF    '4x4MIMO' in ${TEST TAGS}
    ...    commissioning.Execute full commissioning
    ...    scf_path=${gnb_path}/scf_4x4.xml  gnb_id=${0}
    Wait Until Node To Be Onair State   node_id=${0}


Load and Commission SCFs
    [Documentation]    Load and commission SCF files for eNB and gNB
    Load initial gnb scf
    Log to console    Init files loaded
    Commission delta gnb_scf
    Log to console    Commission parameters Done
