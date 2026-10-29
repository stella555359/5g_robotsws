*** Settings ***
Documentation
...  author: Yang Liqin
...  contact: liqin.yang@nokia-sbell.com
...  squad group:PZ3_05
...  Feature CB008680 in SBTS23R2 program

Force Tags                             5G_RAN    5G_RAN_TDD    CRT_TRUNK    CRT_23R2  PY36

Library     taf.selenium.sbts     WITH NAME     selenium_coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource             ${CURDIR}/Resource/CB008680_Keyword.robot
Resource    ${CURDIR}/Resource/keywords_8680_RRM.robot


Suite Setup          Suite Case Setup
Suite Teardown       Suite Case Teardown
Test Setup           Run Keywords    robot_common_operations.Common Case Setup
...    AND     Connect to gnb coam via ssl
Test Teardown        Run Keywords    robot_common_operations.Common Case Teardown
...    AND  Run keyword and ignore error
...  Connect and Modify the parameter on enblte
...  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=unlocked
...  AND  Run Keyword And Ignore Error  Unbarred nr cell  cell_idx=${1} 
...  AND  Run Keyword And Ignore Error  Unbarred nr cell  cell_idx=${2}
...  AND  Run Keyword And Ignore Error    COAM Teardown gnb connections


*** Variables ***
${TS_CASE_LOG_PATH}      /home/ute/CB008680_log
${mrbtsID}        ${tl.gnbs[0].instance_id}
${nrbtsID}        ${tl.gnbs[0].global_bts_id}
${if_commissioning}            True
${UL_TP}                       50M
${UL_TP_THRESHOLD}              1
${DL_TP}                       300M
${DL_TP_THRESHOLD}              1
${GLOBAL_CELL1_ID}              1
${GLOBAL_CELL2_ID}              2
${ue_index}                     0
${cell1_dist}                  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
${cell2_dist}                  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
${NR_AMF_Dist}                 MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-1
${lte_cell2_dist}              MRBTS-${ENB_MRBTS_ID}/LNBTS-${ENB_LNBTS_ID}/LNCEL-1
${E_1_DELTA}                   ${CURDIR}/jsons/E1.json
${E_6_DELTA}                   ${CURDIR}/jsons/E6.json
${E_11_DELTA}                  ${CURDIR}/jsons/E11.json
${E_12_DELTA}                  ${CURDIR}/jsons/E12.json
${E_11_30M_DELTA}                  ${CURDIR}/jsons/E11_30M.json
${E_11_30M_DELTA_9755}             ${CURDIR}/jsons/E11_30M_9755.json

*** Test Cases ***     
[1]Verify MRC or IRC function
    [Setup]     Test Case Setup   Verify MRC or IRC function
    [Tags]     Verify_MRC
    Barred nr cell
    Connect to gnb coam via ssl
    Connect and Modify the parameter on enblte  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=locked

    #power_ue.Prepare UE    ue_type=qct_dx50
    Get full SCF
    Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach qct_dx50
    ...    ul_tp=85M    ul_tp_threshold=55    attach_mode=SA
    ...    dl_tp=635M    dl_tp_threshold=603
    ...    global_cell_id=1
    COAM Teardown gnb connections


[1]CB008680-I_36_Peak throughput with UL 256QAM Modulation on different bandwidth - DoD_Band_chbw_40MHz
    [Documentation]    NSA+D-band_40MHz+actDl256Qam_true+actUl256Qam_true+UDP  C-band_100MHz
    [Setup]     Test Case Setup    Peak_throughput_with_UL_256QAM_Modulation_on_different_bandwidth_DBand_chbw_40MHz
    [Teardown]  Run Keywords    Test Case Teardown    AND     CI_interface.Common Case Teardown
    [Tags]  I_36 
    log to console  Peak_throughput_with_UL_256QAM_Modulation_on_different_bandwidth_DBand_chbw_40MHz    
    Peak throughput with different Modulation on different bandwidth
    ...  file=${delta_256QAM_dband_40M}
    ...  cell_id=1  direction=both
    
[1]CB008680-I_37_Peak throughput with UL 256QAM Modulation on different bandwidth - DoD_Band_chbw_40MHz_TCP
    [Documentation]    NSA+D-band_40MHz+actDl256Qam_true+actUl256Qam_true+TCP  C-band_100MHz
    [Setup]     Test Case Setup    Peak_throughput_with_UL_256QAM_Modulation_on_different_bandwidth_DBand_chbw_40MHz_TCP
    [Tags]  I_37 
    [Teardown]  Run Keywords    Test Case Teardown  protocol=tcp    AND     CI_interface.Common Case Teardown
    log to console  Peak_throughput_with_UL_256QAM_Modulation_on_different_bandwidth_DBand_chbw_40MHz_TCP    
    Peak throughput with different Modulation on different bandwidth
    ...  file=${delta_256QAM_dband_40M}  attach_mode=5G_NSA
    ...  cell_id=1  protocol=tcp  direction=both
    
[1]CB008680-I_40_Peak throughput with UL 64QAM Modulation on different bandwidth - C-Band_chbw_40MHz_TCP
    [Documentation]    NSA+C-band_40MHz+actDl256Qam_true+actUl256Qam_false+TCP  D-band_20MHz
    [Setup]     Test Case Setup    Peak_throughput_with_UL_64QAM_Modulation_on_different_bandwidth_CBand_chbw_40MHz_TCP
    [Tags]  I_40
    [Teardown]  Run Keywords    Test Case Teardown  protocol=tcp    AND     CI_interface.Common Case Teardown
    log to console  Peak_throughput_with_UL_64QAM_Modulation_on_different_bandwidth_CBand_chbw_40MHz_TCP    
    Peak throughput with different Modulation on different bandwidth
    ...  file=${delta_64QAM_cband_40M}  attach_mode=5G_NSA
    ...  protocol=tcp  direction=both 

[1]CB008680-I_23_Peak throughput with DL 64QAM Modulation on different bandwidth - C-Band_chbw_60MHz
    [Documentation]    SA+C-band_60MHz+actDl256Qam_false+actUl256Qam_false+UDP  D-band_40MHz 
    [Setup]     Test Case Setup    Peak_throughput_with_DL_64QAM_Modulation_on_different_bandwidth_CBand_chbw_60MHz
    [Teardown]  Run Keywords    Test Case Teardown    AND     CI_interface.Common Case Teardown
    [Tags]  I_23
    ${I_23_file}  Select json file  ${delta_64QAM_cband_60M}  ${delta_cband_60M_9755}
    log to console  Peak_throughput_with_DL_64QAM_Modulation_on_different_bandwidth_CBand_chbw_60MHz    
    Peak throughput with different Modulation on different bandwidth
    ...  file=${I_23_file}  direction=both  duration_time=10m

[1]CB008680-I_33_Peak throughput with DL 256QAM Modulation on different bandwidth - C-Band_chbw_100MHz
    [Documentation]    SA+C-band_100MHz+actDl256Qam_true+actUl256Qam_false+UDP  D-band_20MHz   
    [Setup]     Test Case Setup    Peak_throughput_with_DL_256QAM_Modulation_on_different_bandwidth_CBand_chbw_100MHz
    [Teardown]  Run Keywords    Test Case Teardown    AND     CI_interface.Common Case Teardown
    [Tags]  I_33
	scf commission and wait for on-air RRM
    ${I_33_file}  Select json file  ${delta_256QAM_cband_100M}  ${delta_cband_100M_9755}
    log to console  Peak_throughput_with_DL_256QAM_Modulation_on_different_bandwidth_CBand_chbw_100MHz
    Peak throughput with different Modulation on different bandwidth
    ...  file=${I_33_file}  direction=both
#    CI_interface.Common Suite Setup
    
[1]CB008680-I_38_Peak throughput with DL 256QAM Modulation on different bandwidth - C-Band_chbw_100MHz_TCP
    [Documentation]    SA+C-band_100MHz+actDl256Qam_true+actUl256Qam_false+TCP  D-band_20MHz    
    [Setup]     Test Case Setup    Peak_throughput_with_DL_256QAM_Modulation_on_different_bandwidth_CBand_chbw_100MHz_TCP
    [Tags]  I_38
    [Teardown]  Run Keywords    Test Case Teardown  protocol=tcp    AND     CI_interface.Common Case Teardown
    log to console  Peak_throughput_with_DL_256QAM_Modulation_on_different_bandwidth_CBand_chbw_100MHz_TCP
    Peak throughput with different Modulation on different bandwidth
    ...  file=${delta_256QAM_cband_100M}  protocol=tcp  direction=both
    
[1]CB008680-I_39_Peak throughput with DL 64QAM Modulation on different bandwidth - C-Band_chbw_60MHz_TCP
    [Documentation]    SA+C-band_60MHz+actDl256Qam_false+actUl256Qam_false+TCP  D-band_40MHz 
    [Setup]     Test Case Setup    Peak_throughput_with_DL_64QAM_Modulation_on_different_bandwidth_CBand_chbw_60MHz_TCP
    [Tags]  I_39
    [Teardown]  Run Keywords    Test Case Teardown  protocol=tcp    AND     CI_interface.Common Case Teardown
    log to console  Peak_throughput_with_DL_64QAM_Modulation_on_different_bandwidth_CBand_chbw_60MHz_TCP    
    Peak throughput with different Modulation on different bandwidth
    ...  file=${delta_64QAM_cband_60M}  protocol=tcp  direction=both

#[1]CB008680-E_1_attach SR on different Prach configuration recommison - frame structure 5GC001208 - prach format C2
#    [Documentation]    Author: xudong.1.li@nokia-sbell.com
#    ...   prachConfigurationIndex_list is 190+NSA+C-band(BWP-Index5-51)   CBAND 40   DOD 40
#    [Setup]     Test Case Setup   CB008680_E_1
#    [Tags]  E_1
#    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#    Run Keyword If  ${release}  Add New PARAMS to json  ${E_1_DELTA}
#    scf.Modify json file before testing  json_file=${E_1_DELTA}
#    coam.perform_delta_recommissioning    delta_file=${E_1_DELTA}
#    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
#    Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    if_lock=unlocked    
#    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#    Connect and Modify the parameter on enblte  dist_name=${lte_cell2_dist}  parameter=${lnrel_para}   value=1
#    Convert BTS Mode To NSA
#    #Reset UE First
#    #power_ue.Prepare UE    ue_type=qct_dx50
#    Get full SCF
#    Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
#    ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
#    ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
#    ...    global_cell_id=${GLOBAL_CELL1_ID}
#    [Teardown]  Case Teardown  json_file=${E_1_DELTA}  
#
#[1]CB008680-E_12_attach SR on different Prach configuration recommison - frame structure 5GC001070 - prach format C2
#    [Documentation]    Author: xudong.1.li@nokia-sbell.com
#    ...   prachConfigurationIndex_list is 196+NSA+C-band(BWP-Index6-65)   CBAND 80   DOD 30
#    [Tags]  E_12
#    [Setup]     Test Case Setup   CB008680_E_12 
#    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#    Run Keyword If  ${release}  Add New PARAMS to json  ${E_12_DELTA}
#    scf.Modify json file before testing  json_file=${E_12_DELTA}
#    coam.perform_delta_recommissioning    delta_file=${E_12_DELTA}
#    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
#    Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    if_lock=unlocked
#    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
#    Connect and Modify the parameter on enblte  dist_name=${lte_cell2_dist}  parameter=${lnrel_para}   value=1
#    Convert BTS Mode To NSA
#    #Reset UE First
#    #power_ue.Prepare UE    ue_type=qct_dx50
#    Get full SCF
#    Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
#    ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
#    ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
#    ...    global_cell_id=${GLOBAL_CELL1_ID}
#    [Teardown]  Case Teardown  json_file=${E_12_DELTA}
#
#[1]CB008680-E_6_attach SR on different Prach configuration recommison - frame structure 5GC001116 with 3ms shift - prach format A2
#    [Documentation]    Author: xudong.1.li@nokia-sbell.com
#    ...   prachConfigurationIndex_list is 88+SA+DOD-band(BWP-Index8-80)   CBAND 100   DOD 20
#    [Tags]    E_6
#    [Setup]     Test Case Setup   CB008680_E_6
#    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#    Run Keyword If  ${release}  Add New PARAMS to json  ${E_6_DELTA}
#    scf.Modify json file before testing  json_file=${E_6_DELTA}
#    coam.perform_delta_recommissioning    delta_file=${E_6_DELTA}
#    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
#    Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    #if_lock=unlocked
#    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#    Barred nr cell  cell_idx=${1} 
#    #Reset UE First
#    #power_ue.Prepare UE    ue_type=qct_dx50
#    Get full SCF
#    Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
#    ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=SA
#    ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
#    ...    global_cell_id=${GLOBAL_CELL2_ID}
#    [Teardown]  Case Teardown  json_file=${E_6_DELTA}  
#
#
#
#attach SR on different Prach msg1frequencyStart change
#    [Setup]     Test Case Setup   attach SR on different Prach msg1frequencyStart change 
#    [Tags]     attach_SR
#    CI_interface.Common Suite Setup
#    Connect and Modify the parameter on enblte  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=locked
#    Barred nr cell
#    #power_ue.Prepare UE    ue_type=qct_dx50
#    General_SiSo_Cell_lock_and_unlock_on different Prach msg1frequencyStart
#
#uDTX function activation
#    [Setup]     Test Case Setup   uDTX function activation 
#    [Tags]    uDTX
#    CI_interface.Common Suite Setup
#    #Lock nr cell
#    #Connect and Modify the parameter on enblte  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=locked
#
#    #power_ue.Prepare UE    ue_type=qct_dx50
#    uDTX function activation
#
#[1]CB008680-E_11_attach SR on different Prach configuration recommison - frame structure 5GC001116 with 0ms shift - prach format F0
#    [Documentation]    Author: xudong.1.li@nokia-sbell.com
#    ...   prachConfigurationIndex_list is 9+SA+DOD-band(BWP-Index7-71)   CBAND 20   DOD 40
#    ...   prachConfigurationIndex_list is 194+SA+DOD-band(BWP-Index7-78)   CBAND 100   DOD 30
#    [Tags]    E_11
#    [Setup]     Test Case Setup   CB008680_E_11
#    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#    Run Keyword If  ${release}  Add New PARAMS to json  ${E_11_DELTA}
#    scf.Modify json file before testing  json_file=${E_11_DELTA}
#    coam.perform_delta_recommissioning    delta_file=${E_11_DELTA}
#    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
#    Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    #if_lock=unlocked
#    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
#    Barred nr cell  cell_idx=${1} 
#    #Reset UE First
#    #power_ue.Prepare UE    ue_type=qct_dx50
#    Get full SCF
#    Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
#    ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=SA
#    ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
#    ...    global_cell_id=${GLOBAL_CELL2_ID}
#    
#    ${E_11_30M_file}  Select json file  ${E_11_30M_DELTA}  ${E_11_30M_DELTA_9755}
#    # Unlock BTS All 5G Cells
#    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#    Run Keyword If  ${release}  Add New PARAMS to json  ${E_11_30M_file}
#    scf.Modify json file before testing  json_file=${E_11_30M_file}
#    coam.perform_delta_recommissioning    delta_file=${E_11_30M_file}
#    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
#    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
#    Barred nr cell  cell_idx=${1} 
#    Get full SCF
#    Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
#    ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=SA
#    ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
#    ...    global_cell_id=${GLOBAL_CELL2_ID}
#    [Teardown]  Run Keywords  Case Teardown  json_file=${E_11_DELTA}  AND  scf.Modify json file after testing
#    ...  json_file=${E_11_30M_file}  AND  Run Keyword If  ${release}  Delete New PARAMS from json  ${E_11_30M_file}

*** Keywords ***
Reset UE
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    [Arguments]     ${ue_index}=${0}     ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...     ${serial_number}=${tl.ues[${ue_index}].serial_number}
    log to console  \nReset UE\n
    Connect to control pc via cygwin     hostname=${hostname}     ue_index=${ue_index}
    csn.send_command     command=adb -s ${serial_number} reboot     connection=cygwin
    sleep     90s
    csn.disconnect     connection=cygwin

Power UE L3 Call
    [Arguments]  ${cell_id}=1    ${UL_TP}=85M   ${DL_TP}=635M   ${ul_tp_threshold}=55
    ...    ${dl_tp_threshold}=605
    Connect to gnb coam via ssl
    #Reset UE
    #power_ue.Prepare UE    ue_type=qct_dx50
    Wait Until Keyword Succeeds    3x    10s     UE Attach And Check Throughput With Detach qct_dx50
    ...    ul_tp=${UL_TP}    ul_tp_threshold=${ul_tp_threshold}    attach_mode=SA
    ...    dl_tp=${DL_TP}    dl_tp_threshold=${dl_tp_threshold}
    ...    global_cell_id=${cell_id}
    COAM Teardown gnb connections

UE Attach And Check Throughput With Detach qct_dx50
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    global_cell_id(Global cell ID): 1
    ...    ul_tp: 50M    ul_tp_threshold: 15
    ...    dl_tp: 300M    dl_tp_threshold: 220
    ...    [Return]    ul_tp: 20    dl_tp; 200
    [Arguments]    ${global_cell_id}    ${ul_tp}   ${ul_tp_threshold}
    ...    ${dl_tp}    ${dl_tp_threshold}    ${attach_mode}=SA    ${iperf_type}=via_command
    ...    ${ul_duration}=600    ${dl_duration}=600    ${ue_index}=${0}  ${call_duration}=2m
    ${nr_cell_identity}    Get NR Cell Identity Via Index "${global_cell_id}"
    ${ue_type}    translate power ue type from testline    ${ue_index}
    #power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=0

    Reboot UE If no UE IP

    Wait Until Keyword Succeeds    3x    60s    Run Keyword If    '${attach_mode}'=='NSA'    power_ue.Verify attach
    ...    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=True
    ...    ELSE    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${ul_tp}     duration=${ul_duration}
    ...    ue_index=${ue_index}    iperf_type=via_app
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${dl_tp}     duration=${dl_duration}
    ...    ue_index=${ue_index}    iperf_type=via_app
#   Sleep    ${call_duration}

    ${list_of_cell_ids}  create list  ${nr_cell_identity}
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}  duration=${call_duration}  filter=L2Lo  ue_index=${ue_index}
    ...  ignore_time=1min  check_source=aasyslog
#    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    log=${log}
#    ...        cells=${list_of_cell_ids}    target_throughput=${ul_tp_threshold}    min_percent=0
#    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log}
#    ...        cells=${list_of_cell_ids}    target_throughput=${dl_tp_threshold}    min_percent=0

    power_ue.Check Bi Tput  ue_type=${ue_type}    log=${log}
    ...    cells=${list_of_cell_ids}  ultarget_throughput=${ul_tp_threshold}  dltarget_throughput=${dl_tp_threshold}  
    ...    min_percent=0.8

    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    ...    AND    Run Keyword And Ignore Error    UE Dettach and Stop traffic    ue_type=${ue_type}   ue_index=${ue_index}
    #...    AND    Run Keyword And Ignore Error   _Detach Qualcomm Mobile    ue_index=${ue_index}

UE Start DL Traffic
    [Arguments]    ${throughput}    ${ue_index}=0    ${dl_time}=600    ${dl_port}=53038    ${process_num}=5    ${seg_size}=1360    ${window}=2M
    Close the iperf process on APPserver    port=${dl_port}
    ${ue_ip}  Get UE IP Address  ${ue_index}
    csn.send command
    ...    command=iperf -c ${ue_ip} -u -t ${dl_time} -i 1 -p ${dl_port} -P 1 -f m -b ${throughput} -l 1400B -T 64&
    ...    connection=APPserver

UE Start UL Traffic
    [Arguments]    ${throughput}    ${ue_index}=0    ${ul_time}=600    ${ul_port}=53038
    ${command}    Catenate    adb -s ${tl.ues[${ue_index}].serial_number} shell /data/local/tmp/iperf
    ...     -c ${tl.ues[${ue_index}].iperf_details.network_interface_address} -u -p ${ul_port}
    ...     -t ${ul_time} -P 1 -i 1 -f m -b ${throughput} -l 1400B -T 64
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send_command    command=${command}    connection=cpc_${ue_index}

Connect to control pc enhanced
    [Documentation]  This keyword's is to connect to the UE control PC, add WA to restart the ssh servers.
    [Arguments]    ${ue_index}=${0}   ${telnet}=${true}
    ...             ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...             ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...             ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ${cpc_status}    run keyword and return status
    ...              Connect to control pc    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}    alias=cpc_${ue_index}

uDTX function activation
    selenium login and disable screen lock    version=SBTS23R2
    uDTX counters check
    selenium logout and close browser

uDTX counters check
    [Arguments]    ${change_interval}=15min
    ${dist_name}    set variable    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}

    scf.Activate Parameter Value    dist_name=${dist_name}    p_name=actMicroDTX    new_value=false
    Get full SCF
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    3x    10s     UE Attach And Check Throughput With Detach qct_dx50
    ...    ul_tp=85M    ul_tp_threshold=55    attach_mode=SA
    ...    dl_tp=635M    dl_tp_threshold=605
    ...    global_cell_id=1    call_duration=900s
    ...    ul_duration=1000    dl_duration=1000
    COAM Teardown gnb connections

#    sleep  900s
    Wait for New Interval BTS counters Generate    interval=${change_interval}

    ${interval_seconds}    Get Interval Seconds    ${change_interval}
    Connect To BTS Csn Via Lmp     alias=ASIK Master
    ${SBTS_RFM_Energy_Monitoring_counter_noDTX}    Get PM Counter via Webem    counter_id=M40003C2    interval=${change_interval}    counter_type=BTS
    ${SBTS_RFM_Energy_Monitoring_counter_noDTX}    convert to integer     ${SBTS_RFM_Energy_Monitoring_counter_noDTX}
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    log to console  M40003C2 get successfully

    scf.Activate Parameter Value    dist_name=${dist_name}    p_name=actMicroDTX    new_value=true

    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    3x    10s     UE Attach And Check Throughput With Detach qct_dx50
    ...    ul_tp=85M    ul_tp_threshold=55    attach_mode=SA
    ...    dl_tp=635M    dl_tp_threshold=605
    ...    global_cell_id=1    call_duration=900s
    ...    ul_duration=1000    dl_duration=1000
    COAM Teardown gnb connections

#    sleep  900s
    Wait for New Interval BTS counters Generate    interval=${change_interval}

    Connect To BTS Csn Via Lmp     alias=ASIK Master
    ${SBTS_RFM_Energy_Monitoring_counter_DTX}    Get PM Counter via Webem    counter_id=M40003C2    interval=${change_interval}    counter_type=BTS
    ${SBTS_RFM_Energy_Monitoring_counter_DTX}    convert to integer     ${SBTS_RFM_Energy_Monitoring_counter_DTX}
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    log to console  M40003C2 get successfully 2

    ${expression1}    Evaluate    ${SBTS_RFM_Energy_Monitoring_counter_noDTX}-${SBTS_RFM_Energy_Monitoring_counter_DTX}
    ${expression2}    Evaluate    ${expression1}*1.0/${SBTS_RFM_Energy_Monitoring_counter_noDTX}

    ${expression}=                     Run Keyword If      0.1 < ${expression2} and ${expression2} < 0.4
    ...                                                    Set Variable    True
    ...                                            ELSE    Set Variable    False
    #should be equal as strings    ${expression}       True


General_SiSo_Cell_lock_and_unlock_on different Prach msg1frequencyStart
    connect to gnb coam via ssl
    log to console  \n***Lock cell 2 and check status***
    perform_cell_lock_via_admin    cell_id=2    connection=GNB_OAM   lock_timeout=120
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=2
    COAM Teardown gnb connections

    ${dist_name1}    set variable    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    scf.Activate Parameter Value    dist_name=${dist_name1}    p_name=msg1FrequencyStart    new_value=0
    Get full SCF
    Power UE L3 Call    cell_id=1
    scf.Activate Parameter Value    dist_name=${dist_name1}    p_name=msg1FrequencyStart    new_value=4
    Power UE L3 Call    cell_id=1
    scf.Activate Parameter Value    dist_name=${dist_name1}    p_name=msg1FrequencyStart    new_value=33
    Power UE L3 Call   cell_id=1


    log to console  \n***unLock cell2 and check status***
    connect to gnb coam via ssl
    perform_cell_unlock_via_admin    cell_id=2    connection=GNB_OAM    lock_timeout=120
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked   cell_id=2    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    30s    Verify all cells should be onair
    COAM Teardown gnb connections

    scf.Activate Parameter Value    dist_name=${dist_name1}    p_name=msg1FrequencyStart    new_value=0
    [Teardown]  Run Keywords    connect to gnb coam via ssl  AND
    ...    Run Keyword And Ignore Error    perform_cell_unlock_via_admin    cell_id=2
    ...    connection=GNB_OAM    lock_timeout=120  AND    COAM Teardown gnb connections


