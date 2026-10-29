*** Settings ***
Documentation    CB009235 TA cases common steps
...              Author: xiaoxia.hao@nokia-sbell.com


Resource     CB010889_keywords.robot

*** Variables ***
@{btslog_dirs}        /opt/btslog     /opt/ute/tools/btslog
${7_5_UTE5G402T273_HW_TYPE}    GUANGHETONG
${7_5_UTE5G402T272_HW_TYPE}    YIYUAN

*** Keywords ***
CB010889_SR_AA_04_ULMUMIMO_2_rank2_paired_with_ulsrsbm_2CC_4UE
    [Documentation]    Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]   ${pcell_id}=1    ${scell_id}=2
    Run Keyword IF    'SBTS00' in '${stream}'    Set MCS Phase And ATT For CA
    ...    ELSE    Set MCS Phase And ATT For CA For Branch
    DingLi_Client.UE Prepare    HW_TYPE=${${testline_name}_HW_TYPE}
    DingLi_Client.SA And NSA Mode Change
    Run Keyword And Ignore Error    client.detach     ue=${uegroup}    until_timeout=${300}     withpdu=1
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${pcell_id}    timeout=${180}
    ${5G_band}    Set Variable    78
    ${is_restart_ue}    Set Variable IF    'SBTS24R3' in '${stream}'    ${True}    ${False}
    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach With Retry    ues_index=${${0},${1}}
    ...     5G_band=${5G_band}    is_restart_ue=${is_restart_ue}
    ${expect_pci}    Set Variable IF    'SBTS00' in '${stream}'    721    732
    Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info
    ...    ues_index=${${0}}    expect_pci=${expect_pci}
    Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=attach failed.
    DingLi_Client.Start Data Transfer    ues_index=${${0},${1}}    dl_throughput=1000M
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${scell_id}    timeout=${180}
    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach With Retry    ues_index=${${2},${3}}
    ...     5G_band=${5G_band}    is_restart_ue=${is_restart_ue}
    ${expect_second_cell_pci}    Set Variable IF    'SBTS00' in '${stream}'    722    733
    Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info
    ...    ues_index=${${0}}    expect_pci=${expect_second_cell_pci}
    Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=attach failed.
    DingLi_Client.Start Data Transfer    ues_index=${${2},${3}}   ue_index_in_tl=${3}    dl_throughput=1000M
    Check UL MUMO Tput And DL CA With Power UE    expect_ul_tput=200
    ...                                duration=120
    ...                                expect_dl_tput_pcell=1000
    ...                                expect_dl_tput_scell=1000
    ...                                pcell_id=${pcell_id}
    ...                                scell_id=${scell_id}
    ...                                ue_type=huawei_sigspark
    ...                                check_source=aasyslog
    ...                                target_avg_percent=0.80
    ...                                min_percent=0.3
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Check UE1 and UE2 Pair on Cell1 And UE3 and UE4 Pair on Cell2 on TTI
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer    AND
    ...                           Run Keyword And Ignore Error    DingLi_Client.Detach
