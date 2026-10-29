*** Settings ***
Documentation
...    author: jack.zeng
...    contact: jack.zeng@nokia-sbell.com
...    squal group: SG03
...    feature: CB010764

Force Tags    CA_5G_RRM    CRT_TRUNK    RAN_5G    RAN_5G_TDD
...    PY36
...    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIOB1_2xAWHHF_ENB    SBTS00

Suite Setup    Run Keywords
...    SUITE SETUP FOR UTE    AND
...    Common Suite Setup for COAM


Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown
...    AND        Common Suite Teardown for COAM
...    AND        Run Keyword And Ignore Error    COAM Teardown gnb connections

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010764/Resources/CB010764_common_keywords.robot

*** Variables ***
${CB010764_gnb1_A_1001_1}    CB010764_gnb1_A_1001_1.pcap
${CB010764_gnb1_A_1001_2}    CB010764_gnb1_A_1001_2.pcap
${CB010764_gnb1_A_3006_1}    CB010764_gnb1_A_3006_1.pcap
${CB010764_gnb1_A_3006_2}    CB010764_gnb1_A_3006_2.pcap
${dl_expect}    1
${ul_expect}    1
${dl_throughput}    10M
${ul_throughput}    2M
${duration_A}    1200
${enb_instance}    38421
${enb1_def_gnb_dist}     MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enb_def_cell_para}     defaultLnRelGnbCellId


${CB010764_gnb1_C_4001_1}    CB010764_gnb1_C_4001_1.pcap
${CB010764_gnb1_C_4001_2}    CB010764_gnb1_C_4001_2.pcap
${CB010764_gnb1_C_4001_3}    CB010764_gnb1_C_4001_3.pcap
${CB010764_gnb1_C_5002_1}    CB010764_gnb1_C_5002_1.pcap
${CB010764_gnb1_C_5002_2}    CB010764_gnb1_C_5002_2.pcap
${CB010764_gnb1_C_5002_3}    CB010764_gnb1_C_5002_3.pcap
${CB010764_gnb1_C_7001_1}    CB010764_gnb1_C_7001_1.pcap
${CB010764_gnb1_C_7001_2}    CB010764_gnb1_C_7001_2.pcap
${CB010764_gnb1_C_7001_3}    CB010764_gnb1_C_7001_3.pcap
${CB010764_gnb1_C_10001_1}    CB010764_gnb1_C_10001_1.pcap
${CB010764_gnb1_C_10001_2}    CB010764_gnb1_C_10001_2.pcap
${CB010764_gnb1_C_10001_3}    CB010764_gnb1_C_10001_3.pcap
${duration_C}    600
${CB010764_gnb1_D_2001_1}    CB010764_gnb1_D_2001_1.pcap
${CB010764_gnb1_D_2001_2}    CB010764_gnb1_D_2001_2.pcap
${CB010764_gnb1_D_3001_1}    CB010764_gnb1_D_3001_1.pcap
${CB010764_gnb1_D_3001_2}    CB010764_gnb1_D_3001_2.pcap
${CB010764_gnb1_D_4001_1}    CB010764_gnb1_D_4001_1.pcap
${CB010764_gnb1_D_4001_2}    CB010764_gnb1_D_4001_2.pcap
${CB010764_gnb1_D_14001_1}    CB010764_gnb1_D_14001_1.pcap
${CB010764_gnb1_D_14001_2}    CB010764_gnb1_D_14001_2.pcap
${CB010764_gnb1_D_14001_3}    CB010764_gnb1_D_14001_3.pcap
${CB010764_gnb1_D_18001_1}    CB010764_gnb1_D_18001_1.pcap
${CB010764_gnb1_D_18001_2}    CB010764_gnb1_D_18001_2.pcap
${CB010764_gnb1_D_18001_3}    CB010764_gnb1_D_18001_3.pcap

${CB010764_gnb1_B_2001_BIP1}    CB010764_gnb1_B_2001_BIP1
${CB010764_gnb1_B_2001_BIP2}    CB010764_gnb1_B_2001_BIP2
${CB010764_gnb1_B_2001_BIP3}    CB010764_gnb1_B_2001_BIP3

${CB010764_gnb1_B_3001_BIP1}    CB010764_gnb1_B_3001_BIP1
${CB010764_gnb1_B_3001_BIP2}    CB010764_gnb1_B_3001_BIP2
${CB010764_gnb1_A_1001_BIP1}    CB010764_gnb1_A_1001_BIP1
${CB010764_gnb1_A_1001_BIP2}    CB010764_gnb1_A_1001_BIP2
${CB010764_gnb1_C_1001_BIP1}    CB010764_gnb1_C_1001_BIP1
${CB010764_gnb1_C_1001_BIP2}    CB010764_gnb1_C_1001_BIP2
${CB010764_gnb1_C_1001_BIP3}    CB010764_gnb1_C_1001_BIP3

${CB010764_gnb1_D_3001_BIP1}    CB010764_gnb1_D_3001_BIP1
${CB010764_gnb1_D_3001_BIP2}    CB010764_gnb1_D_3001_BIP2

${CB010764_gnb1_D_14001_BIP1}    CB010764_gnb1_D_14001_BIP1
${CB010764_gnb1_D_14001_BIP2}    CB010764_gnb1_D_14001_BIP2
${CB010764_gnb1_D_14001_BIP3}    CB010764_gnb1_D_14001_BIP3
${CB010764_gnb1_D_18001_BIP1}    CB010764_gnb1_D_18001_BIP1
${CB010764_gnb1_D_18001_BIP2}    CB010764_gnb1_D_18001_BIP2
${CB010764_gnb1_D_18001_BIP3}    CB010764_gnb1_D_18001_BIP3
${5G_NSA}     5G_NSA

*** Test Cases ***
[1]CB010764-B#3_001_PRACH_noise_power_real_estimate_reported_with_pegging_of_CB008021_PM_counters
    [Documentation]    CB010764-B
    [Tags]    CB010764-B    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,4681
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    Adjust the TL Topyoung attenuation value
    Adjust the HBTE attenuation value
    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_B_3001_1}    skip_parameter_relation_errors=True
    Comment    capture the BIP log and syslog when 5G cell on air without attach
    ${CB010764_gnb1_B_3001_bip_01}=    Collect Biplog on WEBUI    target_dir=${epc_log_path}    nr_phy_cell_ids=${51}
    ...    Capture_bip_time=3s    target_file_name=${CB010764_gnb1_B_3001_BIP1}
    Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_3001_bip_01}
    ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_3001_bip_01}
    Should not Be Equal As Strings    ${noisePower_value}    ['-140']
#    ${max_aW_value}     Check noisepowerLinear_value and prach_PRB_number    noisepowerLinear_value=${noisePower_value}
#    ...     prach_PRB_number=${prach_PRB_number}[1]
    Prepare with PM counter time to caculate    period=end
    sleep    90s
    Check counter for B3001_gnb1_UL_RIP_scheduled_PRB
    Comment    step4 change the value of actnrulripmeasurement = enabledWithPRACH_PUCCH_F1 and capture the BIP log and syslog
    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_B_3001_2}    skip_parameter_relation_errors=True
    Comment    capture the BIP log and syslog when 5G cell on air without attach
    ${CB010764_gnb1_B_3001_bip_02}=    Collect Biplog on WEBUI    target_dir=${epc_log_path}    nr_phy_cell_ids=${51}
    ...    Capture_bip_time=3s    target_file_name=${CB010764_gnb1_B_3001_BIP2}
    Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_3001_bip_02}
    ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_3001_bip_02}
    Should not Be Equal As Strings    ${noisePower_value}    ['-140']
#    ${max_aW_value}     Check noisepowerLinear_value and prach_PRB_number    noisepowerLinear_value=${noisePower_value}
#    ...     prach_PRB_number=${prach_PRB_number}[1]
    Prepare with PM counter time to caculate    period=end
    sleep    90s
    Check counter for B3001_gnb1_UL_RIP_scheduled_PRB
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#[1]CB010764-B#2_001_PRACH_noise_power_real_estimate_reported_without_pegging_of_CB008021_PM_counters
#    [Documentation]    CB010764-B 20250415 modify trigger condition due to F52509 ADD parameter new feature actNrUlRipCounters
#    ...    20250523 chat with 10764 and PR829965 ferature owner,current case not correct trigger noisepower and counter.
#    [Tags]    CB010764-B    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,4681
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    Adjust the TL Topyoung attenuation value
#    Comment    20250610 IWK tnansfer to actNrUlRipCounter, for generate a counter ,add a modify parameter step to get it
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_B_2001_0}    skip_parameter_relation_errors=True
#    Prepare with PM counter time to caculate    period=end
#    sleep    40s
#    Comment    20250408 disable parameter 5 and 6(25R2) of actNrUlRipCounters,refer to PR823598 chat trams with Adrian Fulias and precheck email
#    ...        it is conflict with CB010764
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_B_2001_1}    skip_parameter_relation_errors=True
#    Comment    capture the BIP log and syslog when 5G cell on air without attach
#    ${CB010764_gnb1_B_2001_bip_01}=    Collect Biplog on WEBUI    target_dir=${epc_log_path}    nr_phy_cell_ids=${456}
#    ...    Capture_bip_time=3s    target_file_name=${CB010764_gnb1_B_2001_BIP1}
#    Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_2001_bip_01}
#    ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_2001_bip_01}
#    Should Be Equal As Strings    ${noisePower_value}    ['-140']
#    Comment    step3 set the NRBTS/NRCELL/actPrachNoPreambleNoisePwrEst=true
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_B_2001_2}    skip_parameter_relation_errors=True
#    Comment    capture the BIP log and syslog when 5G cell on air without attach
#    ${CB010764_gnb1_B_2001_bip_02}=    Collect Biplog on WEBUI    target_dir=${epc_log_path}    nr_phy_cell_ids=${456}
#    ...    Capture_bip_time=3s    target_file_name=${CB010764_gnb1_B_2001_BIP2}
#    Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_2001_bip_02}
#    ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_2001_bip_02}
#    Should not Be Equal As Strings    ${noisePower_value}    ['-140']
##    Check noisepowerLinear_value and prach_PRB_number    noisepowerLinear_value=${noisePower_value}
##    ...     prach_PRB_number=${prach_PRB_number}[1]
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    Check counter for B2001_gnb1_UL_RIP_scheduled_PRB    #20250319 modify TL to TMO config result to modify PRACH PRB counter
#    Comment    step7.change the value of actnrulripmeasurement = enabledWithoutPRACH and capture the BIP log and syslog
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_B_2001_3}    skip_parameter_relation_errors=True
#    Comment    capture the BIP log and syslog when 5G cell on air without attach
#    ${CB010764_gnb1_B_2001_bip_03}=    Collect Biplog on WEBUI    target_dir=${epc_log_path}    nr_phy_cell_ids=${456}
#    ...    Capture_bip_time=3s    target_file_name=${CB010764_gnb1_B_2001_BIP3}
#    Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_2001_bip_03}
#    ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_2001_bip_03}
#    Should not Be Equal As Strings    ${noisePower_value}    ['-140']
##    Check noisepowerLinear_value and prach_PRB_number    noisepowerLinear_value=${noisePower_value}
##    ...     prach_PRB_number=${prach_PRB_number}[1]
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    Check counter for B2001_gnb1_UL_RIP_scheduled_PRB    #20250319 modify TL to TMO config result to modify PRACH PRB counter
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_B_2001_Recovery}    skip_parameter_relation_errors=True    AND
#    ...    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot   AND
#    ...    CI_interface.Common Case Teardown

#[1]CB010764-A#1_001_PUCCH_F3_DTX_Decoding_Based_Method_on_and_off_with_qpsk_modulation_and_UCI_3Bits_at_same_SNR_point
#    [Documentation]    CB010764-A
#    [Tags]    CB010764-A    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,4681
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
##    robot_common_operations.Common Case Setup
##    ...    gnb_index=${0}
##    ...    allowed_faults_ids=7107
#    Adjust the TL Topyoung attenuation value    gnb1_cell1_value=${10}    enb1_cell1_value=${10}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_A_1001_1_cloud}    skip_parameter_relation_errors=True
#    AlarmWatchdog.add_allow_alarms    fault_id=7523
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_A_1001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    ...    4G_check=${True}
#    sleep    10s
#    start DL UL    ue_index=${1}    duration=${duration_A}    #gnb_index=${0}
#    Prepare with PM counter time to caculate    period=end
#    Adjust PA step by step    gnb1_cell1_value=${5}    start_value=${6}    target_value=${57}    step=${10}    enb1_cell1_value=${10}
#    sleep    10s
#    Start to Capture Logs With WebUI without wait_to_finish     nr_phy_cell_ids=${456}
#    ...    target_file_name=${CB010764_gnb1_A_1001_BIP1}
#    Prepare wait 10mins time to caculate
#    Stop and download the Logs    filename=${CB010764_gnb1_A_1001_1}   gNB_index=${0}
#    Stop UL DL data transfer    ue_index=${1}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    ###check counters
#    ${CB010764_gnb1_A_1001_bip_01}=    Stop and collect Bip Log Via Interface Mirroring Collector from WEBUI
#    ...    target_dir=${epc_log_path}    target_file_name=${CB010764_gnb1_A_1001_BIP1}
##    Prepare with PM counter time to caculate    period=end
##    sleep    90s
#    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#    ...    dic_path=${counter_dic_path_A_1001_trunk}
#    Comment    Online modify NIDD parameter:actPucchF3MethodDTX=false
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_A_1001_3}    skip_parameter_relation_errors=True
#    Adjust the TL Topyoung attenuation value    gnb1_cell1_value=${1}    enb1_cell1_value=${10}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_A_1001_2}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    ...   4G_check=${True}
#    sleep    10s
#    start DL UL    ue_index=${1}    duration=${duration_A}    #gnb_index=${0}
#    Prepare with PM counter time to caculate    period=end
#    Adjust PA step by step    gnb1_cell1_value=${5}    start_value=${6}    target_value=${57}    step=${10}    enb1_cell1_value=${10}
#    sleep    10s
#    Start to Capture Logs With WebUI without wait_to_finish     nr_phy_cell_ids=${456}
#    ...    target_file_name=${CB010764_gnb1_A_1001_BIP2}
#    Prepare wait 10mins time to caculate
#    Stop and download the Logs    filename=${CB010764_gnb1_A_1001_2}   gNB_index=${0}
#    Stop UL DL data transfer    ue_index=${1}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    ###check counters
#    ${CB010764_gnb1_A_1001_bip_02}=        Stop and collect Bip Log Via Interface Mirroring Collector from WEBUI
#    ...    target_dir=${epc_log_path}    target_file_name=${CB010764_gnb1_A_1001_BIP2}
##    Prepare with PM counter time to caculate    period=end
##    sleep    90s
#    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#    ...    dic_path=${counter_dic_path_A_1001_trunk}
#    Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true} <= ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
#    ...    AND    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    ...    AND    Adjust the TL Topyoung attenuation value
#    ...    AND    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_A_1001_2}
#    ...           skip_parameter_relation_errors=True
#    ...    AND    AlarmWatchdog.remove_allow_alarms    fault_id=7523
#    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB010764-C#10_001_PUSCH_A-CSI_CSI_Part2_handling_with_low_UL_data_profile_with_4RX_for_TDD_WK_with_adaptive_reTX_and_DFT-OFDM
#    [Documentation]    CB010764-C
#    [Tags]    CB010764-C    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,4681
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${15}
#    Comment    20250423 actProactUlScheduling CB012810-SR-E Parameter deleted, replaced by NRCELL.actProactUlSchedulingEnh
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_C_10001_1_Cell3}    skip_parameter_relation_errors=True
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S21UI3.1    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_C_10001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    start UL    ue_index=${0}    duration=${duration_C}    #gnb_index=${0}
#    ##Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${30}
#    Adjust PA step by step    gnb1_cell3_value=${16}    start_value=${18}    target_value=${33}    step=${5}
#    ${CB010764_gnb1_C_10001_1_bip_01}=    Collect Biplog on WEBUI    target_dir=${epc_log_path}    nr_phy_cell_ids=${72}
#    ...    Capture_bip_time=550s    target_file_name=${CB010764_gnb1_C_1001_BIP1}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${CB010764_gnb1_C_10001_1}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_10001_1_bip_01}
#    Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
#    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${15}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_C_10001_2_Cell3}    skip_parameter_relation_errors=True
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_C_10001_2}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    start UL    ue_index=${0}    duration=${duration_C}    #gnb_index=${0}
#    ##Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${30}
#    Adjust PA step by step    gnb1_cell3_value=${16}    start_value=${18}    target_value=${33}    step=${5}
#    ${CB010764_gnb1_C_10001_1_bip_02}=    Collect Biplog on WEBUI    target_dir=${epc_log_path}    nr_phy_cell_ids=${72}
#    ...    Capture_bip_time=550s    target_file_name=${CB010764_gnb1_C_1001_BIP2}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${CB010764_gnb1_C_10001_2}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_10001_1_bip_02}
#    Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
#    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${15}
#    sleep    2s
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_C_10001_3}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${20}
#    start UL    ue_index=${0}    duration=${duration_C}    #gnb_index=${0}
#    ##Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${31}
#    Adjust PA step by step    gnb1_cell3_value=${16}    start_value=${18}    target_value=${35}    step=${5}
#    ${CB010764_gnb1_C_10001_1_bip_03}=    Collect Biplog on WEBUI    target_dir=${epc_log_path}    nr_phy_cell_ids=${72}
#    ...    Capture_bip_time=550s    target_file_name=${CB010764_gnb1_C_1001_BIP3}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${CB010764_gnb1_C_10001_3}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio3}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_10001_1_bip_03}
#    Should Be True     ${dtxCsiPart2_DTX_Ratio2} <= ${dtxCsiPart2_DTX_Ratio1}
#    Should Be True     ${dtxCsiPart2_DTX_Ratio2} <= ${dtxCsiPart2_DTX_Ratio3}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB010764-D#3_001_PUCCH_F3_DTX_Decoding_Based_Method_on_and_off_with_Closed_Loop_Power_Control_pucch_and_UCI_7Bits_at_same_SNR_point_ABIP_or_ABIQ
#    [Documentation]    CB010764-D
#    [Tags]    CB010764-D    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,4681
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${1}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_3001_1_cloud}    skip_parameter_relation_errors=True
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S21UI3.1    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_D_3001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${0}    duration=${duration_A}    #gnb_index=${0}
#    Prepare with PM counter time to caculate    period=end
#    Adjust PA step by step    gnb1_cell2_value=${1}    start_value=${1}    target_value=${25}    step=${10}
#    sleep    10s
#    Start to Capture Logs With WebUI without wait_to_finish     nr_phy_cell_ids=${61}
#    ...    target_file_name=${CB010764_gnb1_D_3001_BIP1}
#    Prepare wait 10mins time to caculate
#    Stop and download the Logs    filename=${CB010764_gnb1_D_3001_1}   gNB_index=${0}
#    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    ###check counters.
#    ${CB010764_gnb1_D_3001_bip_01}=    Stop and collect Bip Log Via Interface Mirroring Collector from WEBUI
#    ...    target_dir=${epc_log_path}    target_file_name=${CB010764_gnb1_D_3001_BIP1}
##    Prepare with PM counter time to caculate    period=end
##    sleep    90s
#    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#    ...    dic_path=${counter_dic_path_D_2001_trunk}
#    Comment    Online modify NIDD parameter:actPucchF3MethodDTX=false
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_3}    skip_parameter_relation_errors=True
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${1}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_D_3001_2}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${0}    duration=${duration_A}    #gnb_index=${0}
#    Prepare with PM counter time to caculate    period=end
#    Adjust PA step by step    gnb1_cell2_value=${1}    start_value=${1}    target_value=${25}    step=${10}
#    sleep    10s
#    Start to Capture Logs With WebUI without wait_to_finish     nr_phy_cell_ids=${61}
#    ...    target_file_name=${CB010764_gnb1_D_3001_BIP2}
#    Prepare wait 10mins time to caculate
#    Stop and download the Logs    filename=${CB010764_gnb1_D_3001_2}   gNB_index=${0}
#    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    ###check counters
#    ${CB010764_gnb1_D_3001_bip_02}=        Stop and collect Bip Log Via Interface Mirroring Collector from WEBUI
#    ...    target_dir=${epc_log_path}    target_file_name=${CB010764_gnb1_D_3001_BIP2}
##    Prepare with PM counter time to caculate    period=end
##    sleep    90s
#    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#    ...    dic_path=${counter_dic_path_D_2001_trunk}
#    Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true} <= ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
#    ...    AND    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    ...    AND    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_2}
#    ...           skip_parameter_relation_errors=True
#    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB010764-D#14_001_PUSCH_A-CSI_CSI_Part2_with_PUSCH_Transform_Precoding_for_FDD_NSA_CPRI_15M_high_CQI_Jitter_with_2Rx_ABIP_or_ABIQ
#    [Documentation]    CB010764-D
#    [Tags]    CB010764-D    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,4681
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${25}    enb1_cell1_value=${10}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_14001_1_Cell2}    skip_parameter_relation_errors=True
##    AlarmWatchdog.add_allow_alarms    fault_id=7523
#    Comment    step1.start to capture btslog/bip/wireshark logs.
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S21UI3.1    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_D_14001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    ...    4G_check=${True}
#    start UL    ue_index=${0}    duration=${duration_A}    #gnb_index=${0}
#    Adjust PA step by step    gnb1_cell2_value=${26}    start_value=${28}    target_value=${43}    step=${5}
#    ...        enb1_cell1_value=${10}
#    ${CB010764_gnb1_D_14001_1_bip_01}=    Collect Biplog on WEBUI    target_dir=${epc_log_path}    nr_phy_cell_ids=${61}
#    ...    Capture_bip_time=600s    target_file_name=${CB010764_gnb1_D_14001_BIP1}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${CB010764_gnb1_D_14001_1}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_D_14001_1_bip_01}
#    Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_14001_2_Cell2}    skip_parameter_relation_errors=True
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_D_14001_2}   gNB_index=${0}
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${25}    enb1_cell1_value=${10}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    ...   4G_check=${True}
#    start UL    ue_index=${0}    duration=${duration_A}    #gnb_index=${0}
#    Adjust PA step by step    gnb1_cell2_value=${26}    start_value=${28}    target_value=${43}    step=${5}
#    ...        enb1_cell1_value=${10}
#    ${CB010764_gnb1_D_14001_1_bip_02}=    Collect Biplog on WEBUI    target_dir=${epc_log_path}    nr_phy_cell_ids=${61}
#    ...    Capture_bip_time=600s    target_file_name=${CB010764_gnb1_D_14001_BIP2}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${CB010764_gnb1_D_14001_2}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_D_14001_1_bip_02}
#    Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${25}    enb1_cell1_value=${10}
#    sleep    2s
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_D_14001_3}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    ...    4G_check=${True}
#    start UL    ue_index=${0}    duration=${duration_A}    #gnb_index=${0}
#    Adjust PA step by step    gnb1_cell2_value=${26}    start_value=${28}    target_value=${44}    step=${5}
#    ...        enb1_cell1_value=${10}
#    ${CB010764_gnb1_D_14001_1_bip_03}=    Collect Biplog on WEBUI    target_dir=${epc_log_path}    nr_phy_cell_ids=${61}
#    ...    Capture_bip_time=600s    target_file_name=${CB010764_gnb1_D_14001_BIP3}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${CB010764_gnb1_D_14001_3}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio3}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_D_14001_1_bip_03}
#    Should Be True     ${dtxCsiPart2_DTX_Ratio2} <= ${dtxCsiPart2_DTX_Ratio1}
#    Should Be True     ${dtxCsiPart2_DTX_Ratio2} <= ${dtxCsiPart2_DTX_Ratio3}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
#    ...    AND    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_2}
#    ...           skip_parameter_relation_errors=True
#    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB010764-D#18_001_PUSCH_A-CSI_CSI_Part2_handling_with_bursty_UL_data_with_4RX_for_TDD_IWK_with_adaptive_reTX_and_DFT-OFDM_ABIP_or_ABIQ
#    [Documentation]    CB010764-D
#    [Tags]    CB010764-D    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,4681
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${25}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_18001_1_Cell2}    skip_parameter_relation_errors=True
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S21UI3.1    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_D_18001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    Comment    Start bursty UL data transmission change the data rate frequently for 10min
#    Start bursty UL data transmission on Commercial with first UE
#    Adjust PA step by step    gnb1_cell2_value=${26}    start_value=${28}    target_value=${39}    step=${5}
#    ${CB010764_gnb1_D_18001_1_bip_01}=    Collect Biplog on WEBUI    target_dir=${epc_log_path}    nr_phy_cell_ids=${61}
#    ...    Capture_bip_time=600s    target_file_name=${CB010764_gnb1_D_18001_BIP1}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${CB010764_gnb1_D_18001_1}    gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_D_18001_1_bip_01}
#    Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_18001_2_Cell2}    skip_parameter_relation_errors=True
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_D_18001_2}   gNB_index=${0}
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${25}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    Comment    Start bursty UL data transmission change the data rate frequently for 10min
#    Start bursty UL data transmission on Commercial with first UE
#    Adjust PA step by step    gnb1_cell2_value=${26}    start_value=${28}    target_value=${39}    step=${5}
#    ${CB010764_gnb1_D_18001_1_bip_02}=    Collect Biplog on WEBUI    target_dir=${epc_log_path}    nr_phy_cell_ids=${61}
#    ...    Capture_bip_time=600s    target_file_name=${CB010764_gnb1_D_18001_BIP2}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${CB010764_gnb1_D_18001_2}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_D_18001_1_bip_02}
#    Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${25}
#    sleep    2s
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_D_18001_3}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    Comment    Start bursty UL data transmission change the data rate frequently for 10min
#    Start bursty UL data transmission on Commercial with first UE
#    Adjust PA step by step    gnb1_cell2_value=${26}    start_value=${28}    target_value=${40}    step=${5}
#    ${CB010764_gnb1_D_18001_1_bip_03}=    Collect Biplog on WEBUI    target_dir=${epc_log_path}    nr_phy_cell_ids=${61}
#    ...    Capture_bip_time=600s    target_file_name=${CB010764_gnb1_D_18001_BIP3}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${CB010764_gnb1_D_18001_3}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio3}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_D_18001_1_bip_03}
#    Should Be True     ${dtxCsiPart2_DTX_Ratio2} <= ${dtxCsiPart2_DTX_Ratio1}
#    Should Be True     ${dtxCsiPart2_DTX_Ratio2} <= ${dtxCsiPart2_DTX_Ratio3}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
#    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    AlarmWatchdog.remove_allow_alarms    fault_id=7523
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#[1]CB010764-A#3_006_PUCCH_F3_DTX_Decoding_Based_Method_on_and_off_with_Open_Loop_Power_Control_and_UCI_17Bits_at_same_SNR_point
#    [Documentation]    CB010764-A
#    [Tags]    CB010764-A    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${5}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_A_3006_1_cloud}    skip_parameter_relation_errors=True
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_A_3006_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${0}    gnb_index=${0}    duration=${duration_A}
#    Prepare with PM counter time to caculate    period=end
#    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=3    duration=80
#    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${15}
#    sleep    10s
#    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${20}
#    sleep    10s
#    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${33}
#    sleep    500s
#    ##Run Keyword And Continue On Failure    Check DLUL tput    gnb_index=${0}    lcrid=${2}
#    Stop and download the Logs    filename=${CB010764_gnb1_A_3006_1}   gNB_index=${0}
#    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    ###check counters
#    ${CB010764_gnb1_A_3006_bip_01}=    Download gnb_logs after log collection finsished
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true}=    Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#    ...    dic_path=${counter_dic_path_A_3006_trunk}
#    Comment    Online modify NIDD parameter:actPucchF3MethodDTX=false
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_A_3006_3_cloud}    skip_parameter_relation_errors=True
#    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${5}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_A_3006_2}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${0}    gnb_index=${0}    duration=${duration_A}
#    Prepare with PM counter time to caculate    period=end
#    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=3    duration=80
#    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${15}
#    sleep    10s
#    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${20}
#    sleep    10s
#    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${33}
#    sleep    500s
#    ##Run Keyword And Continue On Failure    Check DLUL tput    gnb_index=${0}    lcrid=${2}
#    Stop and download the Logs    filename=${CB010764_gnb1_A_3006_2}   gNB_index=${0}
#    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    ###check counters
#    ${CB010764_gnb1_A_3006_bip_02}=    Download gnb_logs after log collection finsished
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}=    Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#    ...    dic_path=${counter_dic_path_A_3006_trunk}
#    ##Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true} > 0
#    ##Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false} > 0
#    Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true} < ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
###    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#

#[1]CB010764-C#7_001_PUSCH_A-CSI_CSI_Part2_handling_with_bursty_UL_data_with_2RX_for_TDD_IWK_with_adaptive_reTX
#    [Documentation]    CB010764-C
#    [Tags]    CB010764-C    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${15}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_C_7001_1_Cell3}    skip_parameter_relation_errors=True
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_C_7001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    Comment    Start bursty UL data transmission change the data rate frequently for 10min
#    Start bursty UL data transmission on Commercial with first UE
#    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${24}
#    ${CB010764_gnb1_C_7001_1_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=3    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${CB010764_gnb1_C_7001_1}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_7001_1_bip_01}
#    Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_C_7001_2_Cell3}    skip_parameter_relation_errors=True
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_C_7001_2}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    Comment    Start bursty UL data transmission change the data rate frequently for 10min
#    Start bursty UL data transmission on Commercial with first UE
#    ${CB010764_gnb1_C_7001_1_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=3    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${CB010764_gnb1_C_7001_2}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_7001_1_bip_02}
#    Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
#    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${15}
#    sleep    2s
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_C_7001_3}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${16}
#    Comment    Start bursty UL data transmission change the data rate frequently for 10min
#    Start bursty UL data transmission on Commercial with first UE
#    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${27}
#    ${CB010764_gnb1_C_7001_1_bip_03}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=3    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${CB010764_gnb1_C_7001_3}   gNB_index=${0}
#    ###${dtxCsiPart2_DTX_Ratio3}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_7001_1_bip_03}
#    ##Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio1}
#    ##Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio3}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
##    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#

##
##[1]CB010764-D#4_001_PUCCH_F3_DTX_Decoding_Based_Method_on_and_off_with_additional_DMRS_in_not_high_speed_cell_ABIP_or_ABIQ
##    [Documentation]    CB010764-D
##    [Tags]    CB010764-D    CRT_TRUNK
##    [Timeout]    2 hour
##    [Setup]
##    robot_common_operations.Common Case Setup
##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${25}    enb1_cell1_value=${10}
##    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_4001_1_cloud}    skip_parameter_relation_errors=True
##    Comment    step1.start to capture btslog/bip/wireshark logs
##    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
##    Start capture gNB log on master    filename=${CB010764_gnb1_D_4001_1}   gNB_index=${0}
##    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
##    sleep    10s
##    start DL UL    ue_index=${0}    gnb_index=${0}    duration=${duration_A}
##    Prepare with PM counter time to caculate    period=end
##    Run Keyword And Ignore Error    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=2    duration=80
##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${37}    enb1_cell1_value=${10}
##    sleep    10s
##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${42}    enb1_cell1_value=${10}
##    sleep    10s
##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${47}    enb1_cell1_value=${10}
##    sleep    500s
##    Stop and download the Logs    filename=${CB010764_gnb1_D_4001_1}   gNB_index=${0}
##    Run Keyword And Ignore Error    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
##    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
##    ###check counters
##    ${CB010764_gnb1_D_4001_bip_01}=    Download gnb_logs after log collection finsished
##    Prepare with PM counter time to caculate    period=end
##    sleep    90s
##    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
##    ...    dic_path=${counter_dic_path_D_2001_trunk}
##    Comment    Online modify NIDD parameter:actPucchF3MethodDTX=false
##    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_3}    skip_parameter_relation_errors=True
##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}    enb1_cell1_value=${10}
##    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
##    Start capture gNB log on master    filename=${CB010764_gnb1_D_4001_2}   gNB_index=${0}
##    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
##    sleep    10s
##    start DL UL    ue_index=${0}    gnb_index=${0}    duration=${duration_A}
##    Prepare with PM counter time to caculate    period=end
##    Run Keyword And Ignore Error    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=2    duration=80
##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${36}    enb1_cell1_value=${10}
##    sleep    10s
##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${42}    enb1_cell1_value=${10}
##    sleep    10s
##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${47}    enb1_cell1_value=${10}
##    sleep    500s
##    Stop and download the Logs    filename=${CB010764_gnb1_D_4001_2}   gNB_index=${0}
##    Run Keyword And Ignore Error    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
##    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
##    ###check counters
##    ${CB010764_gnb1_D_4001_bip_02}=    Download gnb_logs after log collection finsished
##    Prepare with PM counter time to caculate    period=end
##    sleep    90s
##    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
##    ...    dic_path=${counter_dic_path_D_2001_trunk}
##    Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true} < ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}
##    [Teardown]    Run Keywords
##    ...    robot_common_operations.Common Case Teardown
##    ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
##    ...    AND    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_2}
##    ...           skip_parameter_relation_errors=True
##   ## ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
##    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#####


*** Keywords ***

Check counter for B2001_gnb1_UL_RIP_scheduled_PRB
    ${counter_time}=    Get current PM counter time
    Get the all PM counter value should be Null
    ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_3001_cloud}    dic_path=${counter_dic_path_B_2001_cloud_trunk}
    ...    date=${counter_time}
    ${counter_value_list2}    Get the all PM counter value for B#2_001
    ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_3001_cloud_max}    dic_path=${counter_dic_path_B_2001_cloud_trunk}
    ...    date=${counter_time}
    ${counter_lenth}    Get Length    ${counter_value_list2}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value}    Set Variable    ${counter_value_list2[${index}]}
         #20250206 from PR teams chat, after PR811769 from CNI126050 both counters are nullable now, 0 should not be reported
#        Should Be True      ${counter_value} == 0
         Should Be Equal As Strings    ${counter_value}    None
    END

Check counter for B3001_gnb1_UL_RIP_scheduled_PRB
    #[Arguments]    ${max_aW_value}
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_3001_cloud}    dic_path=${counter_dic_path_B_2001_cloud_trunk}
    ${counter_lenth}    Get Length    ${counter_value_list}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value}    Set Variable    ${counter_value_list[${index}]}
        Should Be True     -130 < ${counter_value} < -100
    END
    ${counter_value_list2}    Get the all PM counter value
    ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_3001_cloud_max}    dic_path=${counter_dic_path_B_2001_cloud_trunk}
    ${counter_lenth2}    Get Length    ${counter_value_list2}
    FOR    ${index}    IN RANGE    ${counter_lenth2}
        ${counter_value}    Set Variable    ${counter_value_list2[${index}]}
        Should Be True     -130 < ${counter_value} < -100
        ##Should Be True      ${counter_value} >= ${max_aW_value}
    END
    [Return]    ${counter_value_list}
