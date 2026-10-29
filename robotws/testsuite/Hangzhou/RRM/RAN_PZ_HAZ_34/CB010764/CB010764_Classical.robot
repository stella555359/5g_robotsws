*** Settings ***
Documentation
...    author: jack.zeng
...    contact: jack.zeng@nokia-sbell.com
...    squal group: SG03
...    feature: CB010764

#Force Tags  CA_5G_RRM
#...    PY36
#Suite Setup    Run Keywords
#...                            robot_common_operations.Common Suite Setup    AND
#...                            Common Suite Setup for COAM    AND
#...                            Update the swconfig file classical gNB    AND
#...                            Load SCF for each TL
#
#Suite Teardown     Run Keywords
#...                            Load SCF for each TL    AND
#...                            Common Suite Teardown for COAM    gnb_list=${gnb_list}
#
#Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010764/Resources/CB010764_common_keywords.robot
#
#*** Variables ***
#${CB010764_gnb1_A_1001_1}    CB010764_gnb1_A_1001_1.pcap
#${CB010764_gnb1_A_1001_2}    CB010764_gnb1_A_1001_2.pcap
#${CB010764_gnb1_A_3006_1}    CB010764_gnb1_A_3006_1.pcap
#${CB010764_gnb1_A_3006_2}    CB010764_gnb1_A_3006_2.pcap
#${dl_expect}    1
#${ul_expect}    1
#${dl_throughput}    10M
#${ul_throughput}    2M
#${duration_A}    1200
#${enb_instance}    ${tl.enbs[0].instance_id}
#${enb1_def_gnb_dist}     MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
#${enb_def_cell_para}     defaultLnRelGnbCellId
#
#
#${CB010764_gnb1_C_4001_1}    CB010764_gnb1_C_4001_1.pcap
#${CB010764_gnb1_C_4001_2}    CB010764_gnb1_C_4001_2.pcap
#${CB010764_gnb1_C_4001_3}    CB010764_gnb1_C_4001_3.pcap
#${CB010764_gnb1_C_5002_1}    CB010764_gnb1_C_5002_1.pcap
#${CB010764_gnb1_C_5002_2}    CB010764_gnb1_C_5002_2.pcap
#${CB010764_gnb1_C_5002_3}    CB010764_gnb1_C_5002_3.pcap
#${CB010764_gnb1_C_7001_1}    CB010764_gnb1_C_7001_1.pcap
#${CB010764_gnb1_C_7001_2}    CB010764_gnb1_C_7001_2.pcap
#${CB010764_gnb1_C_7001_3}    CB010764_gnb1_C_7001_3.pcap
#${CB010764_gnb1_C_10001_1}    CB010764_gnb1_C_10001_1.pcap
#${CB010764_gnb1_C_10001_2}    CB010764_gnb1_C_10001_2.pcap
#${CB010764_gnb1_C_10001_3}    CB010764_gnb1_C_10001_3.pcap
#${duration_C}    600
#${CB010764_gnb1_D_2001_1}    CB010764_gnb1_D_2001_1.pcap
#${CB010764_gnb1_D_2001_2}    CB010764_gnb1_D_2001_2.pcap
#${CB010764_gnb1_D_3001_1}    CB010764_gnb1_D_3001_1.pcap
#${CB010764_gnb1_D_3001_2}    CB010764_gnb1_D_3001_2.pcap
#${CB010764_gnb1_D_4001_1}    CB010764_gnb1_D_4001_1.pcap
#${CB010764_gnb1_D_4001_2}    CB010764_gnb1_D_4001_2.pcap
#${CB010764_gnb1_D_14001_1}    CB010764_gnb1_D_14001_1.pcap
#${CB010764_gnb1_D_14001_2}    CB010764_gnb1_D_14001_2.pcap
#${CB010764_gnb1_D_14001_3}    CB010764_gnb1_D_14001_3.pcap
#${CB010764_gnb1_D_18001_1}    CB010764_gnb1_D_18001_1.pcap
#${CB010764_gnb1_D_18001_2}    CB010764_gnb1_D_18001_2.pcap
#${CB010764_gnb1_D_18001_3}    CB010764_gnb1_D_18001_3.pcap
#
#*** Test Cases ***
#[1]CB010764-B#2_001_PRACH_noise_power_real_estimate_reported_without_pegging_of_CB008021_PM_counters
#    [Documentation]    CB010764-B
#    [Tags]    CB010764-B    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust HBTE gNB_eNB_RU Attenuation
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_B_2001_1}    skip_parameter_relation_errors=True
#    Comment    capture the BIP log and syslog when 5G cell on air without attach
#    ${CB010764_gnb1_B_2001_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2
#    Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_2001_bip_01}
#    ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_2001_bip_01}
#    Should Be Equal As Strings    ${noisePower_value}    ['10']
#    Comment    step3 set the NRBTS/NRCELL/actPrachNoPreambleNoisePwrEst=true
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_B_2001_2}    skip_parameter_relation_errors=True
#    Comment    capture the BIP log and syslog when 5G cell on air without attach
#    ${CB010764_gnb1_B_2001_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2
#    Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_2001_bip_02}
#    ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_2001_bip_02}
#    Should not Be Equal As Strings    ${noisePower_value}    ['10']
#    Check noisepowerLinear_value and prach_PRB_number    noisepowerLinear_value=${noisePower_value}
#    ...     prach_PRB_number=${prach_PRB_number}[0]
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    Check counter for B2001_gnb1_UL_RIP_scheduled_PRB
#    Comment    step7.change the value of actnrulripmeasurement = enabledWithoutPRACH and capture the BIP log and syslog
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_B_2001_3}    skip_parameter_relation_errors=True
#    Comment    capture the BIP log and syslog when 5G cell on air without attach
#    ${CB010764_gnb1_B_2001_bip_03}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2
#    Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_2001_bip_03}
#    ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_2001_bip_03}
#    Should not Be Equal As Strings    ${noisePower_value}    ['10']
#    Check noisepowerLinear_value and prach_PRB_number    noisepowerLinear_value=${noisePower_value}
#    ...     prach_PRB_number=${prach_PRB_number}[0]
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    Check counter for B2001_gnb1_UL_RIP_scheduled_PRB
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND     CB010764_common_keywords.check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}
#    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB010764-B#3_001_PRACH_noise_power_real_estimate_reported_with_pegging_of_CB008021_PM_counters
#    [Documentation]    CB010764-B
#    [Tags]    CB010764-B    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust HBTE gNB_eNB_RU Attenuation
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_B_3001_1}    skip_parameter_relation_errors=True
#    Comment    capture the BIP log and syslog when 5G cell on air without attach
#    ${CB010764_gnb1_B_3001_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2
#    Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_3001_bip_01}
#    ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_3001_bip_01}
#    Should not Be Equal As Strings    ${noisePower_value}    ['10']
#    ${max_aW_value}     Check noisepowerLinear_value and prach_PRB_number    noisepowerLinear_value=${noisePower_value}
#    ...     prach_PRB_number=${prach_PRB_number}[0]
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    Check counter for B3001_gnb1_UL_RIP_scheduled_PRB    max_aW_value= ${max_aW_value}
#    Comment    step4 change the value of actnrulripmeasurement = enabledWithPRACH_PUCCH_F1 and capture the BIP log and syslog
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_B_3001_2}    skip_parameter_relation_errors=True
#    Comment    capture the BIP log and syslog when 5G cell on air without attach
#    ${CB010764_gnb1_B_3001_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2
#    Check IE prachPreambleIndex not exist in BIP Log with mcshark    file_path=${CB010764_gnb1_B_3001_bip_02}
#    ${noisePower_value}=    Check noisepower in BIP Log with mcshark    file_path=${CB010764_gnb1_B_3001_bip_02}
#    Should not Be Equal As Strings    ${noisePower_value}    ['10']
#    ${max_aW_value}     Check noisepowerLinear_value and prach_PRB_number    noisepowerLinear_value=${noisePower_value}
#    ...     prach_PRB_number=${prach_PRB_number}[0]
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    Check counter for B3001_gnb1_UL_RIP_scheduled_PRB    max_aW_value= ${max_aW_value}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
###    ...    AND     CB010764_common_keywords.check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}
###    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB010764-A#1_001_PUCCH_F3_DTX_Decoding_Based_Method_on_and_off_with_qpsk_modulation_and_UCI_3Bits_at_same_SNR_point
#    [Documentation]    CB010764-A
#    [Tags]    CB010764-A    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust HBTE gNB_eNB_RU Attenuation
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${10}
#    Adjust the ENB1CELL1 HBTE attenuation value    enb1_cell1_value=${5}
#    Connect and Modify the ENB parameter    value=2    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_A_1001_1}    skip_parameter_relation_errors=True
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_A_1001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${1}    gnb_index=${0}    duration=${duration_A}
#    Prepare with PM counter time to caculate    period=end
#    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=2    duration=80
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${20}
#    sleep    10s
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${30}
#    sleep    10s
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${35}
#    sleep    500s
#    Stop and download the Logs    filename=${CB010764_gnb1_A_1001_1}   gNB_index=${0}
#    Stop UL DL data transfer    ue_index=${1}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    ###check counters
#    ${CB010764_gnb1_A_1001_bip_01}=    Download gnb_logs after log collection finsished
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#    ...    dic_path=${counter_dic_path_A_1001_cell2}
#    Comment    Online modify NIDD parameter:actPucchF3MethodDTX=false
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_A_1001_3_Cell2}    skip_parameter_relation_errors=True
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${15}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_A_1001_2}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${1}    gnb_index=${0}    duration=${duration_A}
#    Prepare with PM counter time to caculate    period=end
#    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=2    duration=80
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${20}
#    sleep    10s
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${30}
#    sleep    10s
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${35}
#    sleep    500s
#    Stop and download the Logs    filename=${CB010764_gnb1_A_1001_2}   gNB_index=${0}
#    Stop UL DL data transfer    ue_index=${1}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    ###check counters
#    ${CB010764_gnb1_A_1001_bip_02}=    Download gnb_logs after log collection finsished
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#    ...    dic_path=${counter_dic_path_A_1001_cell2}
#    Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true} < ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
#    ...    AND    Connect and Modify the ENB parameter    value=3    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}
#    ...    AND    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_A_1001_2}
#    ...           skip_parameter_relation_errors=True
###    ...    AND     CB010764_common_keywords.check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}
###    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
##
#[1]CB010764-A#3_006_PUCCH_F3_DTX_Decoding_Based_Method_on_and_off_with_Open_Loop_Power_Control_and_UCI_17Bits_at_same_SNR_point
#    [Documentation]    CB010764-A
#    [Tags]    CB010764-A    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust HBTE gNB_eNB_RU Attenuation
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${10}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_A_3006_1_cell2}    skip_parameter_relation_errors=True
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_A_3006_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${1}    gnb_index=${0}    duration=${duration_A}
#    Prepare with PM counter time to caculate    period=end
#    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=2    duration=80
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${20}
#    sleep    10s
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${27}
#    sleep    10s
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${36}
#    sleep    600s
#    ##Run Keyword And Continue On Failure    Check DLUL tput    gnb_index=${0}    lcrid=${2}
#    Stop and download the Logs    filename=${CB010764_gnb1_A_3006_1}   gNB_index=${0}
#    Stop UL DL data transfer    ue_index=${1}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    ###check counters
#    ${CB010764_gnb1_A_3006_bip_01}=    Download gnb_logs after log collection finsished
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true}=    Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#    ...    dic_path=${counter_dic_path_D_2001}
#    Comment    Online modify NIDD parameter:actPucchF3MethodDTX=false
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_A_1001_3_Cell2}    skip_parameter_relation_errors=True
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${10}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_A_3006_2}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${1}    gnb_index=${0}    duration=${duration_A}
#    Prepare with PM counter time to caculate    period=end
#    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=2    duration=80
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${20}
#    sleep    10s
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${27}
#    sleep    10s
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${37}
#    sleep    600s
#    ##Run Keyword And Continue On Failure    Check DLUL tput    gnb_index=${0}    lcrid=${2}
#    Stop and download the Logs    filename=${CB010764_gnb1_A_3006_2}   gNB_index=${0}
#    Stop UL DL data transfer    ue_index=${1}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    ###check counters
#    ${CB010764_gnb1_A_3006_bip_02}=    Download gnb_logs after log collection finsished
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}=    Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#    ...    dic_path=${counter_dic_path_D_2001}
#    ##Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true} > 0
#    ##Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false} > 0
#    Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true} < ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
###    ...    AND     CB010764_common_keywords.check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}
###    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
##
#[1]CB010764-C#7_001_PUSCH_A-CSI_CSI_Part2_handling_with_bursty_UL_data_with_2RX_for_TDD_IWK_with_adaptive_reTX
#    [Documentation]    CB010764-C
#    [Tags]    CB010764-C    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust HBTE gNB_eNB_RU Attenuation
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${10}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_C_7001_1_Cell2}    skip_parameter_relation_errors=True
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_C_7001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    Comment    Start bursty UL data transmission change the data rate frequently for 10min
#    Start bursty UL data transmission on Commercial with first UE    ue_index=${1}
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${30}
#    ${CB010764_gnb1_C_7001_1_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs    filename=${CB010764_gnb1_C_7001_1}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_7001_1_bip_01}
#    Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_C_7001_2_Cell2}    skip_parameter_relation_errors=True
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_C_7001_2}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    Comment    Start bursty UL data transmission change the data rate frequently for 10min
#    Start bursty UL data transmission on Commercial with first UE    ue_index=${1}
#    ${CB010764_gnb1_C_7001_1_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs    filename=${CB010764_gnb1_C_7001_2}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_7001_1_bip_02}
#    Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${10}
#    sleep    2s
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_C_7001_3}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${28}
#    Comment    Start bursty UL data transmission change the data rate frequently for 10min
#    Start bursty UL data transmission on Commercial with first UE    ue_index=${1}
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${32}
#    ${CB010764_gnb1_C_7001_1_bip_03}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs    filename=${CB010764_gnb1_C_7001_3}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio3}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_7001_1_bip_03}
#    ##Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio1}
#    ##Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio3}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
###    ...    AND     CB010764_common_keywords.check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}
###    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
###
#[1]CB010764-C#10_001_PUSCH_A-CSI_CSI_Part2_handling_with_low_UL_data_profile_with_4RX_for_TDD_WK_with_adaptive_reTX_and_DFT-OFDM
#    [Documentation]    CB010764-C
#    [Tags]    CB010764-C    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust HBTE gNB_eNB_RU Attenuation
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${10}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_C_10001_1_Cell2}    skip_parameter_relation_errors=True
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_C_10001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    start UL    ue_index=${1}    gnb_index=${0}    duration=${duration_C}
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${34}
#    ${CB010764_gnb1_C_10001_1_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=350
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs    filename=${CB010764_gnb1_C_10001_1}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_10001_1_bip_01}
#    Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_C_10001_2_Cell2}    skip_parameter_relation_errors=True
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_C_10001_2}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    start UL    ue_index=${1}    gnb_index=${0}    duration=${duration_C}
#    ${CB010764_gnb1_C_10001_1_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=350
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs    filename=${CB010764_gnb1_C_10001_2}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_10001_1_bip_02}
#    Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${20}
#    sleep    2s
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_C_10001_3}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${30}
#    start UL    ue_index=${1}    gnb_index=${0}    duration=${duration_C}
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${35}
#    ${CB010764_gnb1_C_10001_1_bip_03}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=350
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs    filename=${CB010764_gnb1_C_10001_3}   gNB_index=${0}
#    ${dtxCsiPart2_DTX_Ratio3}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_10001_1_bip_03}
#    ##Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio1}
#    ##Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio3}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
###    ...    AND     CB010764_common_keywords.check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}
#    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
##
##
#[1]CB010764-D#3_001_PUCCH_F3_DTX_Decoding_Based_Method_on_and_off_with_Closed_Loop_Power_Control_pucch_and_UCI_7Bits_at_same_SNR_point_ABIP_or_ABIQ
#    [Documentation]    CB010764-D
#    [Tags]    CB010764-D    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust HBTE gNB_eNB_RU Attenuation
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${10}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_3001_1_cell1}    skip_parameter_relation_errors=True
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_D_3001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${1}    gnb_index=${0}    duration=${duration_A}
#    Prepare with PM counter time to caculate    period=end
#    Run Keyword And Ignore Error    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=1    duration=80
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${25}
#    sleep    10s
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${32}
#    sleep    10s
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${42}
#    sleep    600s
#    Stop and download the Logs    filename=${CB010764_gnb1_D_3001_1}   gNB_index=${0}
#    Run Keyword And Ignore Error    Stop UL DL data transfer    ue_index=${1}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    ###check counters
#    ${CB010764_gnb1_D_3001_bip_01}=    Download gnb_logs after log collection finsished
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#    ...    dic_path=${counter_dic_path_D_2001_cell1}
#    Comment    Online modify NIDD parameter:actPucchF3MethodDTX=false
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_3_cell1}    skip_parameter_relation_errors=True
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${22}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_D_3001_2}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${1}    gnb_index=${0}    duration=${duration_A}
#    Prepare with PM counter time to caculate    period=end
#    Run Keyword And Ignore Error    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=1    duration=80
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${25}
#    sleep    10s
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${32}
#    sleep    10s
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${42}
#    sleep    600s
#    Stop and download the Logs    filename=${CB010764_gnb1_D_3001_2}   gNB_index=${0}
#    Run Keyword And Ignore Error    Stop UL DL data transfer    ue_index=${1}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    ###check counters
#    ${CB010764_gnb1_D_3001_bip_02}=    Download gnb_logs after log collection finsished
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
#
#
#[1]CB010764-D#4_001_PUCCH_F3_DTX_Decoding_Based_Method_on_and_off_with_additional_DMRS_in_not_high_speed_cell_ABIP_or_ABIQ
#    [Documentation]    CB010764-B
#    [Tags]    CB010764-B    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust HBTE gNB_eNB_RU Attenuation
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${10}
#    Adjust the ENB1CELL1 HBTE attenuation value    enb1_cell1_value=${5}
#    Connect and Modify the ENB parameter    value=1    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_4001_1_cell1}    skip_parameter_relation_errors=True
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_D_4001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${1}    gnb_index=${0}    duration=${duration_A}
#    Prepare with PM counter time to caculate    period=end
#    Run Keyword And Ignore Error    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=1    duration=80
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${20}
#    sleep    10s
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${30}
#    sleep    10s
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${43}
#    sleep    600s
#    Stop and download the Logs    filename=${CB010764_gnb1_D_4001_1}   gNB_index=${0}
#    Run Keyword And Ignore Error    Stop UL DL data transfer    ue_index=${1}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    ###check counters
#    ${CB010764_gnb1_D_4001_bip_01}=    Download gnb_logs after log collection finsished
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#    ...    dic_path=${counter_dic_path_D_2001_cell1}
#    Comment    Online modify NIDD parameter:actPucchF3MethodDTX=false
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_3}    skip_parameter_relation_errors=True
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${10}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_D_4001_2}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${1}    gnb_index=${0}    duration=${duration_A}
#    Prepare with PM counter time to caculate    period=end
#    Run Keyword And Ignore Error    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=1    duration=80
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${20}
#    sleep    10s
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${30}
#    sleep    10s
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${43}
#    sleep    600s
#    Stop and download the Logs    filename=${CB010764_gnb1_D_4001_2}   gNB_index=${0}
#    Run Keyword And Ignore Error    Stop UL DL data transfer    ue_index=${1}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    ###check counters
#    ${CB010764_gnb1_D_4001_bip_02}=    Download gnb_logs after log collection finsished
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#    ...    dic_path=${counter_dic_path_D_2001_cell1}
#    Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true} < ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Connect and Modify the ENB parameter    value=3    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}
#    ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
#    ...    AND    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_2}
#    ...           skip_parameter_relation_errors=True
###    ...    AND     CB010764_common_keywords.check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}
###    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
###
#[1]CB010764-D#14_001_PUSCH_A-CSI_CSI_Part2_with_PUSCH_Transform_Precoding_for_FDD_NSA_CPRI_15M_high_CQI_Jitter_with_2Rx_ABIP_or_ABIQ
#    [Documentation]    CB010764-D
#    [Tags]    CB010764-D    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust HBTE gNB_eNB_RU Attenuation
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${10}
#    Adjust the ENB1CELL1 HBTE attenuation value    enb1_cell1_value=${5}
#    Connect and Modify the ENB parameter    value=1    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_14001_1_Cell1}    skip_parameter_relation_errors=True
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_D_14001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    start UL    ue_index=${1}    gnb_index=${0}    duration=${duration_A}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${44}
#    ${CB010764_gnb1_D_14001_1_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs    filename=${CB010764_gnb1_D_14001_1}   gNB_index=${0}
#    ##${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_D_14001_1_bip_01}
#    Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_14001_2_Cell1}    skip_parameter_relation_errors=True
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_D_14001_2}   gNB_index=${0}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${30}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    start UL    ue_index=${1}    gnb_index=${0}    duration=${duration_A}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${44}
#    ${CB010764_gnb1_D_14001_1_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs    filename=${CB010764_gnb1_D_14001_2}   gNB_index=${0}
#    ##${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_D_14001_1_bip_02}
#    Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${20}
#    sleep    2s
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_D_14001_3}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${34}
#    start UL    ue_index=${1}    gnb_index=${0}     duration=${duration_A}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${45}
#    ${CB010764_gnb1_D_14001_1_bip_03}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs    filename=${CB010764_gnb1_D_14001_3}   gNB_index=${0}
#    ##${dtxCsiPart2_DTX_Ratio3}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_D_14001_1_bip_03}
#    ##Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio1}
#    ##Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio3}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Connect and Modify the ENB parameter    value=3    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}
#    ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
#    ...    AND    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_2}
#    ...           skip_parameter_relation_errors=True
###    ...    AND     CB010764_common_keywords.check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}
#    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
##
#[1]CB010764-D#18_001_PUSCH_A-CSI_CSI_Part2_handling_with_bursty_UL_data_with_4RX_for_TDD_IWK_with_adaptive_reTX_and_DFT-OFDM_ABIP_or_ABIQ
#    [Documentation]    CB010764-D
#    [Tags]    CB010764-D    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust HBTE gNB_eNB_RU Attenuation
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${20}
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_18001_1_Cell1}    skip_parameter_relation_errors=True
#    Comment    step1.start to capture btslog/bip/wireshark logs
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_D_18001_1}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    Comment    Start bursty UL data transmission change the data rate frequently for 10min
#    Start bursty UL data transmission on Commercial with first UE    ue_index=${1}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${44}
#    ${CB010764_gnb1_D_18001_1_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs    filename=${CB010764_gnb1_D_18001_1}    gNB_index=${0}
#    ##${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_D_18001_1_bip_01}
#    Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
#    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_18001_2_Cell1}    skip_parameter_relation_errors=True
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_D_18001_2}   gNB_index=${0}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${20}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    Comment    Start bursty UL data transmission change the data rate frequently for 10min
#    Start bursty UL data transmission on Commercial with first UE    ue_index=${1}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${44}
#    ${CB010764_gnb1_D_18001_1_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs    filename=${CB010764_gnb1_D_18001_2}   gNB_index=${0}
#    ##${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_D_18001_1_bip_02}
#    Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${30}
#    sleep    2s
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${CB010764_gnb1_D_18001_3}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${34}
#    Comment    Start bursty UL data transmission change the data rate frequently for 10min
#    Start bursty UL data transmission on Commercial with first UE    ue_index=${1}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${45}
#    ${CB010764_gnb1_D_18001_1_bip_03}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=1    duration=300
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs    filename=${CB010764_gnb1_D_18001_3}   gNB_index=${0}
#    ##${dtxCsiPart2_DTX_Ratio3}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_D_18001_1_bip_03}
#    ##Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio1}
#    ##Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio3}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
###    ...    AND     CB010764_common_keywords.check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}
###    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
###
##[1]CB010764-E#1_001_PUCCH_F3_DTX_Decoding_Based_Method_on_and_off_with_qpsk_modulation_and_UCI_3Bits_at_same_SNR_point_CB009363_8RX
##    [Documentation]    CB010764-E
##    [Tags]    CB010764-E    CRT_TRUNK
##    [Timeout]    2 hour
##    [Setup]
##    robot_common_operations.Common Case Setup
##    [Teardown]    Run Keywords
##    ...    robot_common_operations.Common Case Teardown
####    ...    AND     CB010764_common_keywords.check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}
##    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
##    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
##
##
##[1]CB010764-E#5&6_001_PRACH_noise_power_real_estimate_reported_with_and_without_pegging_of_CB008021_PM_counters_ABIP_or_ABIQ
##    [Documentation]    CB010764-E
##    [Tags]    CB010764-E    CRT_TRUNK
##    [Timeout]    2 hour
##    [Setup]
##    robot_common_operations.Common Case Setup
##    [Teardown]    Run Keywords
##    ...    robot_common_operations.Common Case Teardown
####    ...    AND     CB010764_common_keywords.check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}
##    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
##    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
##
##[1]CB010764-E#9_001_PUSCH A-CSI CSI Part2 handling_with_low_UL_data_profile_with_8RX_for_TDD_beamforming_SA_70M_CB009363
##    [Documentation]    CB010764-E
##    [Tags]    CB010764-E    CRT_TRUNK
##    [Timeout]    2 hour
##    [Setup]
##    robot_common_operations.Common Case Setup
##    [Teardown]    Run Keywords
##    ...    robot_common_operations.Common Case Teardown
####    ...    AND     CB010764_common_keywords.check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}
##    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
##    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
##
##[1]CB010764-E#11_001_PUSCH_A-CSI_CSI_Part2_with_PUSCH_Close_loop_power_control_for_TDD_NSA_eCPRI_60M_high_CQI_Jitter_with_8Rx_CB009363
##    [Documentation]    CB010764-E
##    [Tags]    CB010764-E    CRT_TRUNK
##    [Timeout]    2 hour
##    [Setup]
##    robot_common_operations.Common Case Setup
##    [Teardown]    Run Keywords
##    ...    robot_common_operations.Common Case Teardown
####    ...    AND     CB010764_common_keywords.check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}
##    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
##    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#
#*** Keywords ***
#
#Check counter for B2001_gnb1_UL_RIP_scheduled_PRB
#    ${counter_time}=    Get current PM counter time
#    Get the all PM counter value should be Null
#    ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_2001}    dic_path=${counter_dic_path_B_2001_cell2}
#    ...    date=${counter_time}
#    ${counter_value_list2}    Get the all PM counter value
#    ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_2001_2}    dic_path=${counter_dic_path_B_2001_cell2}
#    ${counter_lenth}    Get Length    ${counter_value_list2}
#    FOR    ${index}    IN RANGE    ${counter_lenth}
#        ${counter_value}    Set Variable    ${counter_value_list2[${index}]}
#        Should Be True      ${counter_value} == 0
#    END
#
#Check counter for B3001_gnb1_UL_RIP_scheduled_PRB
#    [Arguments]    ${max_aW_value}
#    ${counter_value_list}    Get the all PM counter value
#    ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_3001}    dic_path=${counter_dic_path_B_2001_cell2}
#    ${counter_lenth}    Get Length    ${counter_value_list}
#    FOR    ${index}    IN RANGE    ${counter_lenth}
#        ${counter_value}    Set Variable    ${counter_value_list[${index}]}
#    ##    Should Be True     -130 < ${counter_value} < -100
#    END
#    ${counter_value_list2}    Get the all PM counter value
#    ...    gnb_index=${gnb_index}    counter_id=${counter_id_B_3001_max}    dic_path=${counter_dic_path_B_2001_cell2}
#    ${counter_lenth2}    Get Length    ${counter_value_list2}
#    FOR    ${index}    IN RANGE    ${counter_lenth2}
#        ${counter_value}    Set Variable    ${counter_value_list2[${index}]}
#        Should Be True     -130 < ${counter_value} < -100
#        Run Keyword And Ignore Error    Should Be True      ${counter_value} <= ${max_aW_value}
#    END
#    [Return]    ${counter_value_list}
