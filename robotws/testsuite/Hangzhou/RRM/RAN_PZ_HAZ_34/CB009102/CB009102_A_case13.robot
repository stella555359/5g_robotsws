*** Settings ***
Documentation
...    author: Jiang Hongyu
...    contact: hongyu.jiang@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB009102-SR-A

Resource    ./Resources/CB009102_common_keyword.robot
Library     ./Resources/CB009102_common_keywords.py
Variables   ./Resources/CB009102_modify_para.py
Resource        ./Resources/CB009102_common_keyword_2.robot


Suite Setup    Case13 Suit Setup
Suite Teardown    robot_common_operations.Common Suite Teardown


*** Test Cases ***
[1]CB009102_A_13_SA_DL_UL_Tput_BW_30MHz_4x4MIMO_QAM256_for_multi_UE
    [Tags]  CRT_23R2    CRT_22R4    CRT_TRUNK
    [Setup]  robot_common_operations.Common case Setup
    ${ue_index_list}    create list    ${0}
    Xiaomi12 UE Detach    ue_index_list=${ue_index_list}
    Xiaomi12 Attach And Verify attach    ue_index_list=${ue_index_list}
    start power ue traffic ul and dl    ue_index_list=${ue_index_list}    ul_throughput=50M    dl_throughput=400M
    run keyword and continue on failure    Check xiaomi UE throughput      ul_throughput=20    dl_throughput=100
    attach power ue
    start power ue traffic ul and dl Samsung      ul_throughput=60M    dl_throughput=1000M
    ${cellid_list}    create list    185473    185474
    Check power ue Tput    ul_throughput=28    dl_throughput=700    time=1m    cells=${cellid_list}
    ${csv_path_dict}    Capture TTI log
    run keyword and continue on failure    Check TTI Log For Case13    UL_DL_csv_file_path_dict=${csv_path_dict}    direction=DL
    ...    msc_expect_value=QAM256    prb_sum_expect_value=${78}
    run keyword and continue on failure    Check TTI Log For Case13    UL_DL_csv_file_path_dict=${csv_path_dict}    direction=UL
    ...    msc_expect_value=QAM256    prb_sum_expect_value=${68}
    Run Keyword And Ignore Error    CB009102_common_keyword.stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}
    Run Keyword And Ignore Error    stop multi power ue traffic ul and dl samsung
    [Teardown]  Run Keyword And Ignore Error    Case Teardown

[1]CB009102_W_07_NSA_DL_UL_peak_Tput_with_CA_BW_30M+30MHz
    [Tags]    23R2    Trunk
    [Setup]    robot_common_operations.Common case Setup
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    ${L3_call_cell_list}    create list    NRCELL-1    NRCELL-2
    ${2cc_dl_cell_list}    create list    1    2
    ${expect_ul_tp}    ${expect_dl_tp}    Get Theoretical TP From NRDIM    dl_cell_list=${2cc_dl_cell_list}
    log to console    ${expect_dl_tp},${expect_ul_tp}
    attach power ue
    start power ue traffic ul and dl Samsung      ul_throughput=40M    dl_throughput=1000M
    sleep    15s
    ${cellid_list}    create list    185473    185474
    Check power ue Tput    ul_throughput=${expect_ul_tp}    dl_throughput=${expect_dl_tp}    time=5m    cells=${cellid_list}
    Run Keyword And Ignore Error    stop multi power ue traffic ul and dl samsung
    Run Keyword And Ignore Error    detach multi power ue
    [Teardown]   Run Keyword And Ignore Error    Case Teardown
