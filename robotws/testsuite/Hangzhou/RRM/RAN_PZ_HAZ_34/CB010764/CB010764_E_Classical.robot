*** Settings ***
Documentation
...    author: jack.zeng
...    contact: jack.zeng@nokia-sbell.com
...    squal group: SG03
...    feature: CB010764-E

Force Tags    CA_5G_RRM    CRT_TRUNK    RAN_5G    RAN_5G_TDD
...    PY36
...    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIOB1_2xAWHHF_ENB    SBTS00

Suite Setup    Run Keywords
...                            robot_common_operations.Common Suite Setup    AND
...                            Common Suite Setup for COAM    AND
...                            Update the swconfig file classical gNB    AND
...                            Load Scf depends on Release

Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010764/Resources/CB010764_common_keywords.robot

*** Variables ***
${CB010764_gnb1_E_1001_1}    CB010764_gnb1_E_1001_1.pcap
${CB010764_gnb1_E_1001_2}    CB010764_gnb1_E_1001_2.pcap
${CB010764_gnb1_E_9001_1}    CB010764_gnb1_E_9001_1.pcap
${CB010764_gnb1_E_9001_2}    CB010764_gnb1_E_9001_2.pcap
${CB010764_gnb1_E_9001_3}    CB010764_gnb1_E_9001_3.pcap
${CB010764_gnb1_E_11001_1}    CB010764_gnb1_E_11001_1.pcap
${CB010764_gnb1_E_11001_2}    CB010764_gnb1_E_11001_2.pcap
${CB010764_gnb1_E_11001_3}    CB010764_gnb1_E_11001_3.pcap
${CB010764_gnb1_E_16001_1}    CB010764_gnb1_E_16001_1.pcap
${CB010764_gnb1_E_16001_2}    CB010764_gnb1_E_16001_2.pcap
${CB010764_gnb1_E_16001_3}    CB010764_gnb1_E_16001_2.pcap
${dl_expect}    1
${ul_expect}    1
${dl_throughput}    10M
${ul_throughput}    2M
${duration}    1200
${enb_instance}    ${tl.enbs[0].instance_id}
${enb1_def_gnb_dist}     MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enb_def_cell_para}     defaultLnRelGnbCellId


*** Test Cases ***
[1]CB010764-E#5&6_001_PRACH_noise_power_real_estimate_reported_with_and_without_pegging_of_CB008021_PM_counters_ABIP_or_ABIQ
    [Documentation]    CB010764-E
    ...    20250523 chat with 10764 and PR829965 ferature owner,current case not correct trigger noisepower and counter.
    [Tags]    CB010764-E    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
#    ${release_info}    Get gnb release info
#    Adjust HBTE gNB Attenuation
#    Comment    20250408 disable parameter 5 and 6(25R2) of actNrUlRipCounters,refer to PR823598 chat trams with Adrian Fulias and precheck email
#    ...        it is conflict with CB010764
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_E_56001_1_cell1}    skip_parameter_relation_errors=True
#    Comment    capture the BIP log and syslog when 5G cell on air without attach
#    #${CB010764_gnb1_B_56001_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1
#    ${CB010764_gnb1_B_56001_bip_01}=    Collect Biplog on WEBUI    target_dir=${epc_log_path}    nr_phy_cell_ids=${69}
#    Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_56001_bip_01}
#    ####    20250120 remove this checkpoint due to noise power linear has been descoped by CNI,refer to email precheck
#    ####    new mcshark do not filter message ‘’noisePowerLinear (Uint32)‘’ from bip log
##    ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_56001_bip_01}
##    Should not Be Equal As Strings    ${noisePower_value}    ['10']
##    ${max_aW_value}     Check noisepowerLinear_value and prach_PRB_number    noisepowerLinear_value=${noisePower_value}
##    ...     prach_PRB_number=${prach_PRB_number}[1]
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    ##M55360C00*** should exist  and M55360C01*** have a valid value on PRACH PRB
#    Run Keyword IF    '${release_info}' == 'SBTS24R1'     Check counter for E56001_gnb1_UL_RIP_scheduled_PRB
#    ...            gnb_index=${0}    dic_path=${counter_dic_path_B_E56002_cell1}    #max_aW_value=${max_aW_value}
#    ...    ELSE     Check counter for E56001_gnb1_UL_RIP_scheduled_PRB
#    ...            gnb_index=${0}    dic_path=${counter_dic_path_B_E56002_cell1_trunk}    #max_aW_value=${max_aW_value}
##    Run Keyword If    '${var_dict}[stream]' == 'SBTS00'    Check counter for E56001_gnb1_UL_RIP_scheduled_PRB
##    ...            max_aW_value=${max_aW_value}    dic_path=${counter_dic_path_B_E56002_cell1_trunk}
##    ...    ELSE     Check counter for E56001_gnb1_UL_RIP_scheduled_PRB
##    ...            max_aW_value=${max_aW_value}    dic_path=${counter_dic_path_B_E56002_cell1}
#    Comment    step3 change the value of actnrulripmeasurement = enabledWithoutPRACH and capture the BIP log and syslog
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_E_56001_2_cloud}    skip_parameter_relation_errors=True
#    Comment    capture the BIP log and syslog when 5G cell on air without attach
#    #${CB010764_gnb1_B_56001_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1
#    ${CB010764_gnb1_B_56001_bip_02}=    Collect Biplog on WEBUI    target_dir=${epc_log_path}    nr_phy_cell_ids=${69}
#    Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_56001_bip_02}
#    ####    20250120 remove this checkpoint due to noise power linear has been descoped by CNI,refer to email precheck
#    ####    new mcshark do not filter message ‘’noisePowerLinear (Uint32)‘’ from bip log
##    ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_56001_bip_02}
##    Should not Be Equal As Strings    ${noisePower_value}    ['10']
##    Check noisepowerLinear_value and prach_PRB_number    noisepowerLinear_value=${noisePower_value}
##    ...     prach_PRB_number=${prach_PRB_number}[1]
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    ##M55360C00*** should not exist  and M55360C01***=0
#    Run Keyword IF    '${release_info}' == 'SBTS24R1'     wait until keyword succeeds    10min    60s
#    ...    Check counter for E56002_gnb1_UL_RIP_scheduled_PRB    gnb_index=${0}    dic_path=${counter_dic_path_B_E56002_cell1}
#    ...    ELSE     wait until keyword succeeds    10min    60s
#    ...            Check counter for E56002_gnb1_UL_RIP_scheduled_PRB    gnb_index=${0}    dic_path=${counter_dic_path_B_E56002_cell1_trunk}
##    Run Keyword If    '${var_dict}[stream]' == 'SBTS00'    wait until keyword succeeds    10min    60s
##    ...    Check counter for E56002_gnb1_UL_RIP_scheduled_PRB    dic_path=${counter_dic_path_B_E56002_cell1_trunk}
##    ...    ELSE         wait until keyword succeeds    10min    60s
##    ...    Check counter for E56002_gnb1_UL_RIP_scheduled_PRB    dic_path=${counter_dic_path_B_E56002_cell1}
#    Stop capture syslog via btslog on ute
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Adjust HBTE gNB Attenuation    AND
#    ...    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_E_56001_1_cell1_Recovery}
#    ...    skip_parameter_relation_errors=True    AND
#    ...    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute    AND
#    ...    get and analysis syslog    AND
    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#[1]CB010764-E#1_001_PUCCH_F3_DTX_Decoding_Based_Method_on_and_off_with_qpsk_modulation_and_UCI_3Bits_at_same_SNR_point_CB009363_8RX
#    [Documentation]    CB010764-E
#    [Tags]    CB010764-E    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust HBTE gNB_eNB_RU Attenuation
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${20}
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_E_1001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${1}    gnb_index=${0}
#    Prepare with PM counter time to caculate    period=end
#    Run Keyword And Ignore Error    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=1    duration=80
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${36}
#    sleep    10s
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${40}
#    sleep    10s
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${44}
#    sleep    300s
#    Stop and download the Logs    filename=${CB010764_gnb1_E_1001_1}   gNB_index=${0}
#    Run Keyword And Ignore Error    Stop UL DL data transfer    ue_index=${1}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    ###check counters
#    ${CB010764_gnb1_E_1001_bip_01}=    Download gnb_logs after log collection finsished
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#    ...    dic_path=${counter_dic_path_D_2001_cell1}
#    Comment    Online modify NIDD parameter:actPucchF3MethodDTX=false
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_3_cell1}    skip_parameter_relation_errors=True
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${30}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_E_1001_2}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${1}    gnb_index=${0}
#    Prepare with PM counter time to caculate    period=end
#    Run Keyword And Ignore Error    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=1    duration=80
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${36}
#    sleep    10s
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${40}
#    sleep    10s
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${45}
#    sleep    300s
#    Stop and download the Logs    filename=${CB010764_gnb1_E_1001_2}   gNB_index=${0}
#    Run Keyword And Ignore Error    Stop UL DL data transfer    ue_index=${1}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    ###check counters
#    ${CB010764_gnb1_E_1001_bip_02}=    Download gnb_logs after log collection finsished
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#    ...    dic_path=${counter_dic_path_D_2001_cell1}
#    Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true} < ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
#   ## ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown


#[1]CB010764-E#9_001_PUSCH A-CSI CSI Part2 handling_with_low_UL_data_profile_with_8RX_for_TDD_beamforming_SA_70M_CB009363
#    [Documentation]    CB010764-E
#    [Tags]    CB010764-E    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust HBTE gNB_eNB_RU Attenuation
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${30}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_E_9001_1_Cell1}    skip_parameter_relation_errors=True
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_E_9001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    Comment    Start bursty UL data transmission change the data rate frequently for 10min
#    Start bursty UL data transmission on Commercial with first UE    ue_index=${1}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${47}
#    ${CB010764_gnb1_E_9001_1_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs    filename=${CB010764_gnb1_E_9001_1}   gNB_index=${0}
#    ##${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_E_9001_1_bip_01}
#    Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_E_9001_2_Cell1}    skip_parameter_relation_errors=True
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${30}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_E_9001_2}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    Comment    Start bursty UL data transmission change the data rate frequently for 10min
#    Start bursty UL data transmission on Commercial with first UE    ue_index=${1}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${47}
#    ${CB010764_gnb1_E_9001_1_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs    filename=${CB010764_gnb1_E_9001_2}   gNB_index=${0}
#    ##${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_E_9001_1_bip_02}
#    Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${30}
#    sleep    2s
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_E_9001_3}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${38}
#    Comment    Start bursty UL data transmission change the data rate frequently for 10min
#    Start bursty UL data transmission on Commercial with first UE    ue_index=${1}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${48}
#    ${CB010764_gnb1_E_9001_1_bip_03}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs    filename=${CB010764_gnb1_E_9001_3}   gNB_index=${0}
#    ##${dtxCsiPart2_DTX_Ratio3}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_E_9001_1_bip_03}
#    ##Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio1}
#    ##Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio3}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
##    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
##
#[1]CB010764-E#11_001_PUSCH_A-CSI_CSI_Part2_with_PUSCH_Close_loop_power_control_for_TDD_NSA_eCPRI_60M_high_CQI_Jitter_with_8Rx_CB009363
#    [Documentation]    CB010764-E
#    [Tags]    CB010764-E    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${30}
#    Adjust the ENB1CELL1 HBTE attenuation value    enb1_cell1_value=${5}
#    Connect and Modify the ENB parameter    value=1    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_E_11001_1_Cell1}    skip_parameter_relation_errors=True
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_E_11001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    start UL    ue_index=${1}    gnb_index=${0}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${46}
#    ${CB010764_gnb1_E_11001_1_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs    filename=${CB010764_gnb1_E_11001_1}   gNB_index=${0}
#    ##${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_E_11001_1_bip_01}
#    Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_14001_2_Cell1}    skip_parameter_relation_errors=True
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_E_11001_2}   gNB_index=${0}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${30}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    start UL    ue_index=${1}    gnb_index=${0}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${46}
#    ${CB010764_gnb1_E_11001_1_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs    filename=${CB010764_gnb1_E_11001_2}   gNB_index=${0}
#    ##${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_E_11001_1_bip_02}
#    Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${30}
#    sleep    2s
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_E_11001_3}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${45}
#    start UL    ue_index=${1}    gnb_index=${0}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${47}
#    ${CB010764_gnb1_E_11001_1_bip_03}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs    filename=${CB010764_gnb1_E_11001_3}   gNB_index=${0}
#    ##${dtxCsiPart2_DTX_Ratio3}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_E_11001_1_bip_03}
#    ##Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio1}
#    ##Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio3}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
#    ...    AND    Connect and Modify the ENB parameter    value=3    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}
#    ...    AND    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_2}
#    ...           skip_parameter_relation_errors=True
#   ## ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#

#norun
#####no run
##[1]CB010764-E#16_001_PUSCH_A-CSI_CSI_Part2_handling_with_low_UL_data_profile_with_8RX_for_TDD_WK_with_adaptive_reTX_and_DFT-OFDM_CB009636
##    [Documentation]    CB010764-E
##    [Tags]    CB010764-E    CRT_TRUNK
##    [Timeout]    2 hour
##    [Setup]
##    robot_common_operations.Common Case Setup
##    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${30}
##    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_E_9001_1_Cell2}    skip_parameter_relation_errors=True
##    Comment    step1.start to capture btslog/bip/wireshark logs
##    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
##    Start capture gNB log on master    filename=${CB010764_gnb1_E_16001_1}   gNB_index=${0}
##    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
##    start UL    ue_index=${1}    gnb_index=${0}
##    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${39}
##    ${CB010764_gnb1_E_9001_1_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1    duration=300
##    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
##    Stop and download the Logs    filename=${CB010764_gnb1_E_16001_1}   gNB_index=${0}
##    ${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_E_9001_1_bip_01}
##    Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
##    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_E_9001_2_Cell2}    skip_parameter_relation_errors=True
##    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${30}
##    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
##    Start capture gNB log on master    filename=${CB010764_gnb1_E_16001_2}   gNB_index=${0}
##    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
##    start UL    ue_index=${1}    gnb_index=${0}
##    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${39}
##    ${CB010764_gnb1_E_9001_1_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1    duration=300
##    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
##    Stop and download the Logs    filename=${CB010764_gnb1_E_16001_2}   gNB_index=${0}
##    ${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_E_9001_1_bip_02}
##    Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
##    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${30}
##    sleep    2s
##    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
##    Start capture gNB log on master    filename=${CB010764_gnb1_E_16001_3}   gNB_index=${0}
##    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
##    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${38}
##    start UL    ue_index=${1}    gnb_index=${0}
##    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${41}
##    ${CB010764_gnb1_E_9001_1_bip_03}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1    duration=300
##    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
##    Stop and download the Logs    filename=${CB010764_gnb1_E_16001_3}   gNB_index=${0}
##    ${dtxCsiPart2_DTX_Ratio3}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_E_9001_1_bip_03}
##    Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio1}
##    Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio3}
##    [Teardown]    Run Keywords
##    ...    robot_common_operations.Common Case Teardown
###    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
##    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

*** Keywords ***
Check counter for E56001_gnb1_UL_RIP_scheduled_PRB
    [Arguments]    ${dic_path}    ${gnb_index}=${0}    #${max_aW_value}
    #20241210 after merge SCF,prach PRB config change from PRB67-78 to PRB36-47
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_E56002}    dic_path=${dic_path}
    ${counter_lenth}    Get Length    ${counter_value_list}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value}    Set Variable    ${counter_value_list[${index}]}
        Should Be True     -130 < ${counter_value} < -100
    END
    #20241210 after merge SCF,prach PRB config change from PRB67-78 to PRB36-47
    ${counter_value_list2}    Get the all PM counter value
    ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_E56002_2}    dic_path=${dic_path}
    ${counter_lenth2}    Get Length    ${counter_value_list2}
    FOR    ${index}    IN RANGE    ${counter_lenth2}
        ${counter_value}    Set Variable    ${counter_value_list2[${index}]}
        Should Be True     -130 < ${counter_value} < -100
        # 20241211 confirm with junjie, should be >=(get counter value is 5mins max value)
        ####    20250120 remove this checkpoint due to noise power linear has been descoped by CNI,refer to email precheck
        ####    new mcshark do not filter message ‘’noisePowerLinear (Uint32)‘’ from bip log，so can not caculate ${max_aW_value}
#        Should Be True      ${counter_value} >= ${max_aW_value}
#        run keyword and ignore error     Should Be True      ${counter_value} <= ${max_aW_value}
    END
    [Return]    ${counter_value_list}

Check counter for E56002_gnb1_UL_RIP_scheduled_PRB
    [Arguments]    ${dic_path}    ${gnb_index}=${0}
    ${counter_time}=    Get current PM counter time
    #20241210 after merge SCF,prach PRB config change from PRB67-78 to PRB36-47
    #20241214 found not load golden SCF,result chekpoint failed,
    #modify code link:https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/145868
    #run keyword and ignore error     Get the all PM counter value should be Null
    Get the all PM counter value should be Null
    ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_E56002}    dic_path=${dic_path}
    ...    date=${counter_time}
    #20241210 after merge SCF,prach PRB config change from PRB67-78 to PRB36-47
    ${counter_value_list2}    Get the all PM counter value for E56002
    ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_E56002_2}    dic_path=${dic_path}    date=${counter_time}
    ${counter_lenth}    Get Length    ${counter_value_list2}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value}    Set Variable    ${counter_value_list2[${index}]}
    #20241214 found not load golden SCF,result chekpoint failed,
    #modify code link:https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/145868
#        run keyword and ignore error     Should Be True      ${counter_value} == 0
    #20250206 from PR teams chat, after PR811769 from CNI126050 both counters are nullable now, 0 should not be reported
#        Should Be True      ${counter_value} == 0
         Should Be Equal As Strings    ${counter_value}    None
    END

Load Scf depends on Release
    #20241210 CB0017064 already branchout some release and now only run trunk,so modify this keyword
    Common Case TestLine Setup    ModifySCF_Beforecommission=True
    ...    golden_scf_name=${tl_36011_scf_gnb1}
#    ...    scf_path=${tl_36011_scf_gnb1}
    ...    ParamterToModify=${CB010764_E_ParamterToModify_classical}    ParameterToDelete=${CB010764_E_ParamterToDelete_classical}
    ...    MOsToAdd=${CB010764_E_MOsToAdd_classical}    ListParamterToModify=${CB010764_E_LIST_PARAMETERS_TO_MODIFY_GNB1}
#    [Arguments]   ${gnb_index}=${0}   ${du_index}=${0}    ${common_unit_index}=${0}     #${connection}==du_coam
#    ${var_status}    ${var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
#    ...    gnb_index=${gnb_index}   du_index=${du_index}    common_unit_index=${common_unit_index}
#    set suite variable    ${var_dict}
#    Run Keyword If    '${var_dict}[stream]' == 'SBTS00'    Common Case TestLine Setup    ModifySCF_Beforecommission=True
#    ...    scf_path=${tl_36011_scf_gnb1}
#    ...    ParamterToModify=${CB010764_E_ParamterToModify_classical}    ParameterToDelete=${CB010764_E_ParamterToDelete_classical}
#    ...    MOsToAdd=${CB010764_E_MOsToAdd_classical}    ListParamterToModify=${CB010764_E_LIST_PARAMETERS_TO_MODIFY_GNB1}
#    ...    ELSE     Common Case TestLine Setup    ModifySCF_Beforecommission=True
#    ...    scf_path=${tl_36011_scf_gnb1}
#    ...    ParamterToModify=${CB010764_E_ParamterToModify_classical}    ParameterToDelete=${CB010764_E_ParamterToDelete_classical}
#    ...    MOsToAdd=${CB010764_E_MOsToAdd_classical}    ListParamterToModify=${CB010764_E_LIST_PARAMETERS_TO_MODIFY_GNB1_disabled}

Adjust HBTE gNB Attenuation
    Adjust the GNB1CELL1 HBTE attenuation value
    Adjust the GNB1CELL2 HBTE attenuation value