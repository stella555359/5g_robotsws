*** Settings ***
Documentation
...    author:JackZeng
...    contact:jack.zeng@nokia-sbell.com
...    squad group: 5G_PZ_HZ_3_SG
...    feature : TMO_Non_Feature

Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup
...                            AND    check SA or NSA suite name
...                            AND    FDD_TMO_common_keyword_new.Common Suite Setup for COAM
...                            AND    get traffic direction and ho times    cell_type=SA
...                            AND    get value of control parameter
##...                            AND    Prepare the gnb commission for SFE two testline    cell_type=${cell_type}
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
##...                           AND    check hanging resource    AND
...                            AND    SFE_TMO_common_keywords.Get bts package version
...                            AND    Run keyword and continue on failure    collect snapshot for gNB with PM_filter    gnb_index=${0}
...                                   package_version=${package_version}
...                            AND    Run keyword and continue on failure    collect snapshot for Both gNB
...                            AND    sleep    100s
...                            AND    Run Keyword And Ignore Error    SFE_TMO_common_keywords.generate new report and get report id
...                           file_path=${path_1}    report_name=${report_name_1}
...                           tl_id=${tl_id}     package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
...                           AND    Run Keyword And Ignore Error    Crawling and download kpi data   file_path=${excel_kpi_path}
...                           report_id=${report_id}    file_name=${report_name_1}_${package_version}_${start_time_str}    tl_id=${tl_id}
...                           AND    Run Keyword And Ignore Error    SFE_TMO_HO_common_keywords.Download Kpi File
...                           report_id=${report_id}    path=${excel_kpi_path}
...                           AND    Run Keyword And Ignore Error    SFE_TMO_common_keywords.generate new report and get report id
...                           file_path=${path_2}    report_name=${report_name_2}
...                           tl_id=${tl_id}     package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
...                           AND    Run Keyword And Ignore Error    Crawling and download kpi data   file_path=${excel_kpi_path}
...                           report_id=${report_id}    file_name=${report_name_2}_${package_version}_${start_time_str}    tl_id=${tl_id}
...                           AND    Run Keyword And Ignore Error    SFE_TMO_HO_common_keywords.Download Kpi File
...                           report_id=${report_id}    path=${excel_kpi_path}
...                           AND    Run Keyword If Any Tests Failed    Teardown for case failure



Resource    ../Resources/FDD_TMO_common_keyword_new.robot
Resource    ../Resources/TDD_FDD_HO_common_keyword_new_335.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/SFE_TMO_common_keywords.robot
Variables    ../Resources/HBTE_PA_setting_335.py
Resource    ../TDD_FDD_SFE_Regression/SISO_Resource/SiSo_common_keywords.robot
Library     ../TDD_FDD_SFE_Regression/SISO_Resource/SiSo_common_keywords.py

*** Variables ***
@{pm_all_list}
${atten_ip}    ${tl.attenuator[0].ip_addr}     #atten1
${atten_ip2}    ${tl.attenuator[1].ip_addr}    #atten2
${att_api_port}    ${tl.attenuator[0].port}
${max_attenuation_value}    ${127}
${vendor}    ${tl.attenuators[0].vendor}
${cell_type}    SA
${pa_settime}    0.6
${paerror_counter}    0
${DL_traffic_send}    10M
${UL_traffic_send}    1M
${ue_type}    samsung
${path_1}    /opt/workspace/SCF/SA_kpi_report.yml
${path_2}    /opt/workspace/SCF/NSA_kpi_report.yml
${report_name_1}    TL335_SA
${report_name_2}    TL335_NSA
${tl_id}    335
${excel_kpi_path}    /opt/workspace/SCF/Excel_KPI/
${brust_traffic_path}    /opt/workspace/SCF/
${brust_file_name}    ryan.py
${sh_file_name}    5GC007835_SA.sh
${ANR_ho_times}    6
${interval_ANR_ho}   10
${interval_case2}   10
${interval_case3}   4
${interval_case4}   20
##${interval}    90
${case2_ho_times}    20
${case4_ho_times}    30
${case3_ho_times}    40
${connection_name}    GNB_OAM
@{PC1_UE_attach_sn}
@{PC2_UE_attach_sn}
#${DL_UDP_send_Case2}    2M
${DL_UDP_send_Case3}    3M
${DL_UDP_send_Case4}    10M
${TCP_file_name}     5GC007835_TCP.sh
${TCP_file_name_case3}     5GC007835_TCP_case3.sh
${UDP_file_name_case2}     5GC007835_UDP_case2.sh
${UL_UDP_send_Case3}    1M
${UL_UDP_send_Case2}    2M
*** Test Cases ***
[1]CB007835_5G_A_004_SA_intergnb_intrafre_TDD_HO_TDD_704_stability
    [Documentation]    SA CELL301-CELL401 Intra F(TDD-TDD) inter gnb HO
    [Timeout]    10 hour
    [Tags]    classical    CRT_24R1    CRT_TRUNK    CRT_23R3    CRT_23R4
    [Setup]
    #sleep    600s
    robot_common_operations.Common Case Setup
    slect selected index of ue on TL335
    Start TCP server on UE via CPC
    #Log to console     Stop ALL UE DL UDP traffic on 335
    #Stop ALL UE DL UDP traffic on 335
    #multi_all_ues_network_operate    action_index=${1}
    #PA recover
    run keyword and continue on failure    Online modify parmeters    parameters_to_update=${PARAMToModify_gnb1_NRDLMUMIMO}
    ...     gnb_index=${0}
    Run Keyword And Ignore Error    Online delete objects with timeout    parameters_to_update=${ObjectToDelete_gnb1}
    ...    gnb_index=${0}
    Run Keyword And Ignore Error    Online delete objects with timeout    parameters_to_update=${ObjectToDelete_gnb2}
    ...     gnb_index=${1}
    check site status
    Prepare with PM counter time caculate    period=start
    Get record time    label=start
    Log to console    report start time: ${start_time}
    ${start_time_str} =    Convert Date     date=${start_time}     date_format=%Y-%m-%d %H:%M    exclude_millis=yes
    ...     result_format=%Y_%m_%d_%H_%M
    Set Suite Variable    ${start_time_str}
    ANR setup
    ##Prepare with PM counter time caculate    period=start
    Set Test Variable    ${test_round}    2
    FOR    ${count}    IN RANGE    ${test_round}
        Log to console    current case4 test_round: ${count}
        Repeat case4
    END
    Prepare with PM counter time caculate    period=start
    Set Test Variable    ${test_round}    2
    FOR    ${count}    IN RANGE    ${test_round}
        Log to console    current case3 test_round: ${count}
        Run Keyword If    ${count} >= 1    Prepare with PM counter time caculate    period=start
        Repeat case3
    END
    Prepare with PM counter time caculate    period=start
    Set Test Variable    ${test_round}    2
    FOR    ${count}    IN RANGE    ${test_round}
        Log to console    current case2 test_round: ${count}
        Repeat case2
    END
    Prepare with PM counter time caculate    period=start
    Get record time    label=end
    Log to console    report end time: ${end_time}
    check site status
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect snapshot for Both gNB
    ...    AND    Log to console     hang up EMC and VONR
    ...    AND    run keyword and continue on failure    hang up mutil UE for EMC Setup with special index
    ...    AND    run keyword and continue on failure    hang up mutil UE for VONR Setup with special index
    ...    AND    multi_all_ues_network_operate    action_index=${1}
    ...    AND    PA recover
    ...    AND    Log to console     Stop brust DL TCP traffic
    ...    AND    Kill ute process after pgrep by name    process_name=5GC007835
    ...    AND    Kill ute process after pgrep by name    process_name=iperf
    ...    AND    run keyword and continue on failure    Stop ALL UE DL UDP traffic on 335
    ...    AND    run keyword and continue on failure    Stop All UE UL UDP data transfer on 335 via CPC
#    ...    AND    run keyword and continue on failure    Stop TCP server on UE via CPC  #already covered


[1]CB007835_5G_A_002_SA_intergnb_interfre_FDD_HO_TDD_706_stability
    [Documentation]    (case 2 already cover)
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    sleep    2s
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
    ...    sleep    2s

[1]CB007835_5G_A_003_SA_intragnb_interfre_FDD_HO_TDD_706_stability
    [Documentation]    (case 2 already cover)
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    sleep    2s
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
    ...    sleep    2s

[1]CB007835_5G_A_005_SA_intergnb_interfre_FDD_HO_TDD_NG_705_stability
    [Documentation]    (case 2 already cover)
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    sleep    2s
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
    ...    sleep    2s


[1]CB007835_5G_A_007_SA_intragnb_intrafre_FDD_HO_FDD_6112_VoNR
    [Documentation]    (case 2 and case 3 already cover)
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    sleep    2s
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
    ...    sleep    2s

[1]CB007835_5G_A_007_SA_intragnb_intrafre_FDD_HO_FDD_784_EC_call
    [Documentation]    (case 2 and case 3 already cover)
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    Run Keyword And Ignore Error    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    sleep    20s
    [Teardown]    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown

[1]CB007835_5G_A_008_NSA_intergnb_interfre_FDD_HO_TDD_1095_stability
    [Documentation]    case2 already cover this case
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    sleep    2s
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
    ...    sleep    2s
[1]CB007835_5G_A_009_NSA_intragnb_interfre_FDD_HO_TDD_1095_stability
    [Documentation]    case3 already cover this case
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    sleep    2s
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
    ...    sleep    2s
[1]CB007835_5G_A_010_NSA_intergnb_intrafre_TDD_HO_TDD_573_stability
    [Documentation]    case4 already cover this case
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    sleep    2s
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
    ...    sleep    2s

[1]CB007834-5G-A_Verify_3CC_peakTput_for_DL_FDD_N25_PCell_FDD_N71_TDD_N41_Scell
    [Documentation]    CB007834-5G-A_Verify_3CC_peakTput_for_DL_FDD_N25_PCell_FDD_N71_TDD_N41_Scell
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    #set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][1]
    #Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
    ...    sleep    2s

[1]CB007835_5G_A_001_SA_intragnb_intrafre_FDD_HO_FDD_704_stability
    [Documentation]    [1]CB007835_5G_A_001_SA_intragnb_intrafre_FDD_HO_FDD_704_stability
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    #set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][1]
    #Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
    ...    sleep    2s

[1][1.0] E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Documentation]   [1][1.0] E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    #set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][1]
    #Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
    ...    sleep    2s

[1][1.0] E2E_TL_RU_Reset_with_OAM_KPI
    [Documentation]    [1][1.0] E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    #set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][1]
    #Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
    ...    sleep    2s

[1]AVHA_enter_deep_sleep_and_exit
    [Documentation]    [1]AVHA_enter_deep_sleep_and_exit
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    #set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][1]
    #Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
    ...    sleep    2s

E2E_gNB_SW_Upgrade_loops_with_WebUI_TL357
    [Documentation]    E2E_gNB_SW_Upgrade_loops_with_WebUI_TL357
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    #set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][1]
    #Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
    ...    sleep    2s

[1]E2E_Reset_with_HWF_deletion_TL357
    [Documentation]    [1]E2E_Reset_with_HWF_deletion_TL357
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    #set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][1]
    #Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
    ...    sleep    2s

[1]CB007834-5G-A_001_UL_DL_peak_Tput_verify_per_release
    [Documentation]    [1]CB007834-5G-A_001_UL_DL_peak_Tput_verify_per_release
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    #set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][1]
    #Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
    ...    sleep    2s

#[1.0] E2E_gNB_SW_Upgrade_loops_with_WebUI
#    [Documentation]    [1.0] E2E_gNB_SW_Upgrade_loops_with_WebUI
#    [Timeout]    10 hour
#    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
#    [Setup]
#    robot_common_operations.Common Case Setup
#    #set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][1]
#    #Prepare all online UE with data start test    cell_type=SA
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    sleep    2s
#
#[1][1.0] E2E_Reset_with_HWF_deletion
#    [Documentation]    [1][1.0] E2E_Reset_with_HWF_deletion
#    [Timeout]    10 hour
#    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
#    [Setup]
#    robot_common_operations.Common Case Setup
#    #set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][1]
#    #Prepare all online UE with data start test    cell_type=SA
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    sleep    2s
*** Keywords ***
ANR setup
    Log to console    set all PA ports and one cell set designated value:gnb1_cell301:${gnb1_cell301_pa_value}[setup][0]
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][0]
    ...    cell_type=SA
    Log to console    set PA port on one cell:enb1_cell11:${enb1_cell11_pa_value}[setup][0]
    set PA port on one cell    pa_name=${enb1_cell11_pa_info}    value=${enb1_cell11_pa_value}[setup][0]
    Log to console    make multi ues network with single pc1 UEs attach
    make multi ues network with single pc    control_pc_ip=${control_pc_ip1}    action_index=${0}
    sleep     210s
    Log to console    trigger ANR for gnb1Cell301 and gnb2Cell401
    Adjust_HBTE_PA with loop    pa_name=${gnb2_cell401_pa_info}    s_value=${gnb2_cell401_pa_value}[setup][1]
    ...    e_value=${gnb2_cell401_pa_value}[setup][2]    step=${gnb2_cell401_pa_info}[step][0]    ho_times=${ANR_ho_times}
    ...    interval=${interval_ANR_ho}
    PA recover

    Log to console    set all PA ports and one cell set designated value:gnb1_cell1:${gnb1_cell1_pa_value}[setup][3]
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][3]
    ...    cell_type=SA
    Log to console    set PA port on one cell:enb1_cell11:${enb1_cell11_pa_value}[setup][0]
    set PA port on one cell    pa_name=${enb1_cell11_pa_info}    value=${enb1_cell11_pa_value}[setup][0]
    Log to console    Adjust_HBTE_PA gnb2_cell401 with loop: ho_times=${ANR_ho_times}
    Adjust_HBTE_PA with loop interval for ngHO    pa_name=${gnb2_cell401_pa_info}    s_value=${gnb2_cell401_pa_value}[setup][1]
    ...    e_value=${gnb2_cell401_pa_value}[setup][5]    step=${gnb2_cell401_pa_info}[step][0]    ho_times=${ANR_ho_times}
    ...    interval=${interval_ANR_ho}

    make multi ues network with single pc    control_pc_ip=${control_pc_ip1}    action_index=${1}
    PA recover
    Online modify parmeters    parameters_to_update=${PARAMToModify_gnb1}    gnb_index=${0}
    Online modify parmeters    parameters_to_update=${PARAMToModify_gnb2}    gnb_index=${1}

Repeat case3
    slect specified index of ue on TL335 for VONR for case3    slect_num=${3}
    slect specified index of ue on TL335 for EMC for case3    slect_num=${3}
    Log to console    set all PA ports and one cell set designated value:gnb1_cell1:${gnb1_cell1_pa_value}[setup][6]
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][6]
    ...    cell_type=SA
    Log to console    set PA port on one cell:enb1_cell11:${enb1_cell11_pa_value}[setup][0]
    set PA port on one cell    pa_name=${enb1_cell11_pa_info}    value=${enb1_cell11_pa_value}[setup][0]
    Log to console    multi_all_ues_network_operate action_index=${0}
    multi_all_ues_network_operate    action_index=${0}
    Log to console     Start brust DL TCP traffic
    Start brust DL UDP traffic    tl_id=${tl_id}    path=${brust_traffic_path}    file_name=${brust_file_name}
    ...    shell_file_name=${TCP_file_name_case3}

    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=default
    Log to console    set PA port add 1scell:gnb1_cell23:${gnb1_cell23_pa_value}[setup][0]
    set PA port on one cell    pa_name=${gnb1_cell23_pa_info}    value=${gnb1_cell23_pa_value}[setup][0]
    Log to console      Make mutil UE for VoNR Setup
    Make mutil UE for VoNR Setup with special index
    Log to console     Make mutil UE for EMC Setup
    Make mutil UE for EMC Setup with special index

    Log to console     Start selected UE DL UDP data transfer on 335:${DL_UDP_send_Case3}
    Start selected UE DL UDP data transfer on 335    throughput=${DL_UDP_send_Case3}
    Log to console     Start All UE UL UDP data transfer on 335
    Start All UE UL UDP data transfer on 335 via CPC    traffic=${UL_UDP_send_Case3}

    Log to console    Adjust_HBTE_PA gnb1_cell301 with loop: ho_times=${case3_ho_times}
    Log to console    scell gnb1_cell311 also added after set PA cell301
    Adjust_HBTE_PA with loop interval for ngHO    pa_name=${gnb1_cell301_pa_info}    s_value=${gnb1_cell301_pa_value}[setup][1]
    ...    e_value=${gnb1_cell301_pa_value}[setup][2]    step=${gnb1_cell301_pa_info}[step][0]    ho_times=${case3_ho_times}
    ...    interval=${interval_case3}

    Prepare with PM counter time caculate    period=start
    Log to console     hang up EMC and VONR
    run keyword and continue on failure    hang up mutil UE for EMC Setup with special index
    run keyword and continue on failure    hang up mutil UE for VONR Setup with special index
    Log to console     Detach all the UEs
    multi_all_ues_network_operate    action_index=${1}
    PA recover
    Log to console     Stop selected UE DL UDP traffic on 335
    Stop selected UE DL UDP traffic on 335
    Log to console     Stop brust DL TCP traffic
    Kill ute process after pgrep by name    process_name=${TCP_file_name_case3}
    Kill ute process after pgrep by name    process_name=iperf
    Log to console     Stop ALL UE UL UDP traffic on 335
    Stop All UE UL UDP data transfer on 335 via CPC
    Get record time    label=end
    Log to console    current round case3 report end time: ${end_time}

Repeat case4
    Log to console    set all PA ports and one cell set designated value:gnb1_cell301:${gnb1_cell301_pa_value}[setup][0]
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][0]
    ...    cell_type=SA
    Log to console    set PA port on one cell:enb1_cell11:${enb1_cell11_pa_value}[setup][0]
    set PA port on one cell    pa_name=${enb1_cell11_pa_info}    value=${enb1_cell11_pa_value}[setup][0]
    Log to console    multi_all_ues_network_operate action_index=${0}
    multi_all_ues_network_operate    action_index=${0}

    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=default
    Log to console     Start selected UE DL UDP data transfer on 335:${DL_UDP_send_Case4}
    Start selected UE DL UDP data transfer on 335    throughput=${DL_UDP_send_Case4}

    Log to console     Start brust DL TCP traffic
    Start brust DL UDP traffic    tl_id=${tl_id}    path=${brust_traffic_path}    file_name=${brust_file_name}
    ...    shell_file_name=${TCP_file_name}

    Log to console    set PA port add 1scell:gnb1_cell23:${gnb1_cell23_pa_value}[setup][0]
    set PA port on one cell    pa_name=${gnb1_cell23_pa_info}    value=${gnb1_cell23_pa_value}[setup][0]

    Log to console    Adjust_HBTE_PA gnb2_cell401 with loop: ho_times=${case4_ho_times}
    Adjust_HBTE_PA with loop    pa_name=${gnb2_cell401_pa_info}    s_value=${gnb2_cell401_pa_value}[setup][1]
    ...    e_value=${gnb2_cell401_pa_value}[setup][2]    step=${gnb2_cell401_pa_info}[step][0]    ho_times=${case4_ho_times}
    ...    interval=${interval_case4}

    Prepare with PM counter time caculate    period=start
    Log to console     Detach all the UEs
    multi_all_ues_network_operate    action_index=${1}
    PA recover
    Log to console     Stop brust DL TCP traffic
    Kill ute process after pgrep by name    process_name=${TCP_file_name}
    Kill ute process after pgrep by name    process_name=iperf
    Log to console     Stop selected UE DL UDP traffic on 335
    Stop selected UE DL UDP traffic on 335
    Get record time    label=end
    Log to console    current round case4 report end time: ${end_time}

Repeat case2
    slect specified index of ue on TL335 for VONR for case2    slect_num=${3}
    slect specified index of ue on TL335 for EMC for case2    slect_num=${3}
    Log to console    set all PA ports and one cell set designated value:gnb1_cell1:${gnb1_cell1_pa_value}[setup][3]
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][3]
    ...    cell_type=SA
    Log to console    set PA port on one cell:enb1_cell11:${enb1_cell11_pa_value}[setup][0]
    set PA port on one cell    pa_name=${enb1_cell11_pa_info}    value=${enb1_cell11_pa_value}[setup][0]
    Log to console    multi_all_ues_network_operate All UEs attach
    multi_all_ues_network_operate    action_index=${0}

    Log to console     Start brust DL UDP traffic
    Start brust DL UDP traffic    tl_id=${tl_id}    path=${brust_traffic_path}    file_name=${brust_file_name}
    ...    shell_file_name=${UDP_file_name_case2}
    Log to console    set PA port add 1scell:gnb1_cell23:${gnb1_cell23_pa_value}[setup][0]
    set PA port on one cell    pa_name=${gnb1_cell23_pa_info}    value=${gnb1_cell23_pa_value}[setup][0]
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=default
    Log to console     Start All UE UL UDP data transfer on 335
    Start All UE UL UDP data transfer on 335 via CPC    traffic=${UL_UDP_send_Case2}
    Log to console      Make mutil UE for VoNR Setup
    Make mutil UE for VoNR Setup with special index
    Log to console     Make mutil UE for EMC Setup
    Make mutil UE for EMC Setup with special index
    Log to console    Adjust_HBTE_PA gnb2_cell401 with loop: ho_times=${case2_ho_times}
    Adjust_HBTE_PA with loop interval for ngHO    pa_name=${gnb2_cell401_pa_info}    s_value=${gnb2_cell401_pa_value}[setup][1]
    ...    e_value=${gnb2_cell401_pa_value}[setup][5]    step=${gnb2_cell401_pa_info}[step][0]    ho_times=${case2_ho_times}
    ...    interval=${interval_case2}

    Prepare with PM counter time caculate    period=start
    Log to console     hang up EMC and VONR
    run keyword and continue on failure    hang up mutil UE for EMC Setup with special index
    run keyword and continue on failure    hang up mutil UE for VONR Setup with special index
    Log to console     Detach all the UEs
    multi_all_ues_network_operate    action_index=${1}
    PA recover
    Log to console     Stop brust DL UDP traffic
    Kill ute process after pgrep by name    process_name=${UDP_file_name_case2}
    Kill ute process after pgrep by name    process_name=iperf
    Log to console     Stop ALL UE UL UDP traffic on 335
    Stop All UE UL UDP data transfer on 335 via CPC
    Get record time    label=end
    Log to console    current round case2 report end time: ${end_time}


check site status
    check gNB status    gnb_index=${0}
    check gNB status    gnb_index=${1}


check gNB status
    [Timeout]    1 hours
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Wait Until Keyword Succeeds    5min    10s    Check systemModule status
    ${check_result}=    check if ASOD or ASOE or ASOF or ASOG or ASOH testline    gnb_index=${gnb_index}
    Run Keyword If    ${check_result} == ${False}
    ...    Wait Until Keyword Succeeds    10min    10s    Check basebandModule status
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF or ASOG or ASOH
    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...      Wait Until Keyword Succeeds    15min    10s    Check cell status    cell_type=${cell_type}
        ...     AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...     ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

collect snapshot for Both gNB
    collect snapshot for gNB    gnb_index=${0}
    collect snapshot for gNB    gnb_index=${1}

collect snapshot for gNB
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Save snapshot with BTS    connection=${connection_name}    timeout=${1200}
    [Teardown]    Disconnect With BTS    connection=${connection_name}