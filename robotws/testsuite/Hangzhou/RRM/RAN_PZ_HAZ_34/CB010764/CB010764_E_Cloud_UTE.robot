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
...    SUITE SETUP FOR UTE    AND
#...    Common commissioning for Cloud gNB    AND
...    Common Suite Setup for COAM

Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown
...    AND        Common Suite Teardown for COAM
...    AND        Run Keyword And Ignore Error    COAM Teardown gnb connections

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
${enb_instance}   38421
${enb1_def_gnb_dist}     MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enb_def_cell_para}     defaultLnRelGnbCellId
${CB010764_gnb1_E_1001_BIP1}    CB010764_gnb1_E_1001_BIP1
${CB010764_gnb1_E_1001_BIP2}    CB010764_gnb1_E_1001_BIP2
*** Test Cases ***
[1]CB010764-E#1_001_PUCCH_F3_DTX_Decoding_Based_Method_on_and_off_with_qpsk_modulation_and_UCI_3Bits_at_same_SNR_point_CB009363_8RX
    [Documentation]    CB010764-E, 20250220,change ABIP to ABIO,delete some checkpoint.
    [Tags]    CB010764-E    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,4681
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Comment    step1.start to capture btslog/bip/wireshark logs
    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S21UI3.1    power_reset=True
    Start capture gNB log on master    filename=${CB010764_gnb1_E_1001_1}   gNB_index=${0}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
    sleep    10s
    Stop and download the Logs    filename=${CB010764_gnb1_E_1001_1}   gNB_index=${0}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
    ...    AND    Adjust the TL Topyoung attenuation value
    ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

[1]test
    [Documentation]     EDA
    [Tags]     CRT_TRUNK
    [Timeout]    10 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${0}
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S21UI3.1
#    Start capture gNB log on master    filename=${CB010764_gnb1_E_1001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    sleep    10s
#    Stop and download the Logs    filename=${CB010764_gnb1_E_1001_1}   gNB_index=${0}
#    start UL    ue_index=${0}    ul_throughput=10M    duration=${3600}
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_alias=RU    ru_index=${4}    container_id=0x1018
    log to console    excute shell command
    ${output}  csn.execute    command=cd /mnt/runtime && ./EthLinkUp_down_TeSi_ifconfig_arb0p3_DownUp.sh;echo $?    connection=RU
#    ${cmd}    Set Variable    bash -c "cd /mnt/runtime && ./EthLinkUp_down_TeSi_ifconfig_arb0p3_DownUp.sh"
#    ${process}    Start Process    ${cmd}    stdout=${EXECDIR}/script_output.log    stderr=STDOUT    shell=True
#    Wait Until Keyword Succeeds    5x    2s    Log Shell Output
#    Wait For Process    ${process}
    Log Shell Output
    Should Contain     ${output}    loop round
    Should Match Regexp    ${output}    \r\n0\r\n
    log to console    check Fault ID 1904
    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown   AND
#    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
#    ...    Adjust the TL Topyoung attenuation value    #AND
    ...    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot   AND
    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#[1]CB010764-E#1_001_PUCCH_F3_DTX_Decoding_Based_Method_on_and_off_with_qpsk_modulation_and_UCI_3Bits_at_same_SNR_point_CB009363_8RX
#    [Documentation]    CB010764-E
#    [Tags]    CB010764-E    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${20}
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S21UI3.1    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_E_1001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${0}    #gnb_index=${0}
#    Prepare with PM counter time to caculate    period=end
#    Start to Capture Logs With WebUI without wait_to_finish     nr_phy_cell_ids=${61}
#    ...    target_file_name=${CB010764_gnb1_E_1001_BIP1}
#    Adjust PA step by step    gnb1_cell2_value=${24}    start_value=${28}    target_value=${40}    step=${5}
#    #sleep    150s
#    Prepare wait 10mins time to caculate
#    Stop and download the Logs    filename=${CB010764_gnb1_E_1001_1}   gNB_index=${0}
#    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    ###check counters
#    ${CB010764_gnb1_E_1001_bip_01}=    Stop and collect Bip Log Via Interface Mirroring Collector from WEBUI
#    ...    target_dir=${epc_log_path}    target_file_name=${CB010764_gnb1_E_1001_BIP1}
##    Prepare with PM counter time to caculate    period=end
##    sleep    90s
#    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#    ...    dic_path=${counter_dic_path_D_2001_trunk}
#    Comment    Online modify NIDD parameter:actPucchF3MethodDTX=false
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_3}    skip_parameter_relation_errors=True
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${20}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_E_1001_2}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${0}    #gnb_index=${0}
#    Prepare with PM counter time to caculate    period=end
#    Start to Capture Logs With WebUI without wait_to_finish     nr_phy_cell_ids=${61}
#    ...    target_file_name=${CB010764_gnb1_E_1001_BIP2}
#    Adjust PA step by step    gnb1_cell2_value=${24}    start_value=${28}    target_value=${40}    step=${5}
#    #sleep    150s
#    Prepare wait 10mins time to caculate
#    Stop and download the Logs    filename=${CB010764_gnb1_E_1001_2}   gNB_index=${0}
#    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    ###check counters
#    ${CB010764_gnb1_E_1001_bip_02}=    Stop and collect Bip Log Via Interface Mirroring Collector from WEBUI
#    ...    target_dir=${epc_log_path}    target_file_name=${CB010764_gnb1_E_1001_BIP2}
##    Prepare with PM counter time to caculate    period=end
##    sleep    90s
#    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#    ...    dic_path=${counter_dic_path_D_2001_trunk}
#    Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true} <= ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
#   ## ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#[1]CB010764-E#5&6_001_PRACH_noise_power_real_estimate_reported_with_and_without_pegging_of_CB008021_PM_counters_ABIP_or_ABIQ
#    [Documentation]    CB010764-E
#    [Tags]    CB010764-E    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust the TL Topyoung attenuation value
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_E_56001_1_cloud}    skip_parameter_relation_errors=True
#    Comment    capture the BIP log and syslog when 5G cell on air without attach
#    ${CB010764_gnb1_B_56001_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2
#    Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_56001_bip_01}
#    ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_56001_bip_01}
#    Should not Be Equal As Strings    ${noisePower_value}    ['10']
#    ${max_aW_value}     Check noisepowerLinear_value and prach_PRB_number    noisepowerLinear_value=${noisePower_value}
#    ...     prach_PRB_number=@{prach_PRB_number}[1]
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    ##M55360C00*** should exist  and M55360C01*** have a valid value on PRACH PRB
#    Check counter for E56001_gnb1_UL_RIP_scheduled_PRB      max_aW_value=${max_aW_value}
#    Comment    step3 change the value of actnrulripmeasurement = enabledWithoutPRACH and capture the BIP log and syslog
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_E_56001_2_cloud}    skip_parameter_relation_errors=True
#    Comment    capture the BIP log and syslog when 5G cell on air without attach
#    ${CB010764_gnb1_B_56001_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2
#    Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_56001_bip_02}
#    ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_56001_bip_02}
#    Should not Be Equal As Strings    ${noisePower_value}    ['10']
#    Check noisepowerLinear_value and prach_PRB_number    noisepowerLinear_value=${noisePower_value}
#    ...     prach_PRB_number=@{prach_PRB_number}[1]
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    ##M55360C00*** should not exist  and M55360C01***=0
#    Check counter for E56002_gnb1_UL_RIP_scheduled_PRB
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
##    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
##
##
#[1]CB010764-E#9_001_PUSCH A-CSI CSI Part2 handling_with_low_UL_data_profile_with_8RX_for_TDD_beamforming_SA_70M_CB009363
#    [Documentation]    CB010764-E
#    [Tags]    CB010764-E    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_E_9001_1_Cell2}    skip_parameter_relation_errors=True
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_E_9001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    Comment    Start bursty UL data transmission change the data rate frequently for 10min
#    Start bursty UL data transmission on Commercial with first UE
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${44}
#    ${CB010764_gnb1_E_9001_1_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${CB010764_gnb1_E_9001_1}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_E_9001_1_bip_01}
#    Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_E_9001_2_Cell2}    skip_parameter_relation_errors=True
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_E_9001_2}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    Comment    Start bursty UL data transmission change the data rate frequently for 10min
#    Start bursty UL data transmission on Commercial with first UE
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${44}
#    ${CB010764_gnb1_E_9001_1_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${CB010764_gnb1_E_9001_2}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_E_9001_1_bip_02}
#    Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}
#    sleep    2s
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_E_9001_3}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${38}
#    Comment    Start bursty UL data transmission change the data rate frequently for 10min
#    Start bursty UL data transmission on Commercial with first UE
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${45}
#    ${CB010764_gnb1_E_9001_1_bip_03}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${CB010764_gnb1_E_9001_3}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio3}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_E_9001_1_bip_03}
#    ##Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio1}
#    ##Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio3}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
##    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB010764-E#11_001_PUSCH_A-CSI_CSI_Part2_with_PUSCH_Close_loop_power_control_for_TDD_NSA_eCPRI_60M_high_CQI_Jitter_with_8Rx_CB009363
#    [Documentation]    CB010764-E
#    [Tags]    CB010764-E    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}    enb1_cell1_value=${10}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_E_11001_1_Cell2}    skip_parameter_relation_errors=True
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_E_11001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    start UL    ue_index=${0}    gnb_index=${0}
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${44}    enb1_cell1_value=${10}
#    ${CB010764_gnb1_E_11001_1_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${CB010764_gnb1_E_11001_1}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_E_11001_1_bip_01}
#    Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_14001_2_Cell2}    skip_parameter_relation_errors=True
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_E_11001_2}   gNB_index=${0}
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}    enb1_cell1_value=${10}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    start UL    ue_index=${0}    gnb_index=${0}
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${44}    enb1_cell1_value=${10}
#    ${CB010764_gnb1_E_11001_1_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${CB010764_gnb1_E_11001_2}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_E_11001_1_bip_02}
#    Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}    enb1_cell1_value=${10}
#    sleep    2s
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_E_11001_3}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${38}    enb1_cell1_value=${10}
#    start UL    ue_index=${0}    gnb_index=${0}
#    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${45}    enb1_cell1_value=${10}
#    ${CB010764_gnb1_E_11001_1_bip_03}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${CB010764_gnb1_E_11001_3}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio3}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_E_11001_1_bip_03}
#    ##Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio1}
#    ##Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio3}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
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
##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}
##    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_E_9001_1_Cell2}    skip_parameter_relation_errors=True
##    Comment    step1.start to capture btslog/bip/wireshark logs
##    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
##    Start capture gNB log on master    filename=${CB010764_gnb1_E_16001_1}   gNB_index=${0}
##    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
##    start UL    ue_index=${0}    gnb_index=${0}
##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${39}
##    ${CB010764_gnb1_E_9001_1_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=300
##    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
##    Stop and download the Logs    filename=${CB010764_gnb1_E_16001_1}   gNB_index=${0}
##    ${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_E_9001_1_bip_01}
##    Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
##    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_E_9001_2_Cell2}    skip_parameter_relation_errors=True
##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}
##    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
##    Start capture gNB log on master    filename=${CB010764_gnb1_E_16001_2}   gNB_index=${0}
##    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
##    start UL    ue_index=${0}    gnb_index=${0}
##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${39}
##    ${CB010764_gnb1_E_9001_1_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=300
##    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
##    Stop and download the Logs    filename=${CB010764_gnb1_E_16001_2}   gNB_index=${0}
##    ${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_E_9001_1_bip_02}
##    Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}
##    sleep    2s
##    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
##    Start capture gNB log on master    filename=${CB010764_gnb1_E_16001_3}   gNB_index=${0}
##    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${38}
##    start UL    ue_index=${0}    gnb_index=${0}
##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${41}
##    ${CB010764_gnb1_E_9001_1_bip_03}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=300
##    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
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
    [Arguments]    ${max_aW_value}
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_E56002}    dic_path=${counter_dic_path_B_E56002_trunk}
    ${counter_lenth}    Get Length    ${counter_value_list}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value}    Set Variable    ${counter_value_list[${index}]}
        Should Be True     -130 < ${counter_value} < -100
    END
    ${counter_value_list2}    Get the all PM counter value
    ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_E56002_2}    dic_path=${counter_dic_path_B_E56002_trunk}
    ${counter_lenth2}    Get Length    ${counter_value_list2}
    FOR    ${index}    IN RANGE    ${counter_lenth2}
        ${counter_value}    Set Variable    ${counter_value_list2[${index}]}
        Should Be True     -130 < ${counter_value} < -100
        Should Be True      ${counter_value} <= ${max_aW_value}
    END
    [Return]    ${counter_value_list}

Check counter for E56002_gnb1_UL_RIP_scheduled_PRB
    ${counter_time}=    Get current PM counter time
    Get the all PM counter value should be Null
    ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_E56002}    dic_path=${counter_dic_path_B_E56002_trunk}
    ...    date=${counter_time}
    ${counter_value_list2}    Get the all PM counter value
    ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_E56002_2}    dic_path=${counter_dic_path_B_E56002_trunk}
    ${counter_lenth}    Get Length    ${counter_value_list2}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value}    Set Variable    ${counter_value_list2[${index}]}
        Should Be True      ${counter_value} == 0
    END

Get alarms to check
    [Arguments]     ${connection}=GNB_OAM
    ${activate_alarms}=    coam.get_active_alarms    connection=${connection}    timeout=60
    ${count_alarm}    Get length    ${activate_alarms}
#    Should be true    ${count_alarm}>=${1}    msg=Check cell status failed as total cell number is less than 1
    FOR  ${alarm}  IN  @{activate_alarms}
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1904'
                                      ...  msg=Current alarm faultId is equal 1904
    END
    ${history_alarms}=    coam.get_historic_alarms    connection=${connection}    timeout=60    load_history=True
    FOR  ${fault}  IN  @{history_alarms}
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1904'
                                      ...  msg=Current alarm faultId is equal 1904
    END

Log Shell Output
    ${output}    Get File    ${EXECDIR}/script_output.log
    Log    ${output}