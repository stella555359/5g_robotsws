*** Settings ***
Documentation     author: ming.shi
...                 contact: ming.shi@nokia-sbell.com

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007834/resources/CB007834_5G_A_common_keyword.robot

*** Variables ***
${dl_throughput}    100M
${duration_dl}    600
${check_duration_dl}    60
${ul_throughput}    100M
${duration_ul}    600
${check_duration_ul}    60
${expect_throughput_dl}    1
${expect_throughput_ul}    1
@{cell_ids}    303    21


*** Keywords ***
adjust pa value and L3 call on whole steps
    UE prepare common keyword
    FOR    ${cellid}    IN    @{cell_ids}
        Adjust gNB_RU Attenuation TL363    cell${cellid}_value=${0}
        L3 call on whole steps    lcrid=${cellid}
    END

UE prepare common keyword
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${tl.ues[${ue_index}].capabilities[0]}
    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}

L3 call on whole steps
    [Arguments]
    ...    ${lcrid}
    ...    ${ue_index}=${0}    ${ue_type}=${tl.ues[${ue_index}].capabilities[0]}    ${4G_check}=False    ${gnb_index}=${0}
    ...    ${protocol}=udp    ${seg_size}=1180
    ...    ${dl_throughput}=${dl_throughput}    ${duration_dl}=${duration_dl}    ${dl_length}=${DL_LENGTH}
    ...    ${dl_port}=${tl.ues[${ue_index}].iperf_details.port}    ${process_num}=${1}    ${window}=2M    ${cap_index}=${0}
    ...    ${ul_throughput}=${ul_throughput}   ${duration_ul}=${duration_ul}    ${ul_length}=${UL_LENGTH}
    ...    ${ul_port}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}    ${process_num}=${1}    ${iperf_type}=via_app
    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}    gnb_index=${gnb_index}
    Power UE Start DL traffic    ue_type=${ue_type}    ue_index=${ue_index}    dl_throughput=${dl_throughput}
    ...    duration=${duration_dl}    dl_length=${dl_length}    dl_port=${dl_port}    protocol=${protocol}
    ...    process_num=${process_num}    seg_size=${seg_size}    window=${window}    cap_index=${cap_index}
    Power UE Start UL traffic    ue_type=${ue_type}    ue_index=${ue_index}    ul_throughput=${ul_throughput}
    ...    duration=${duration_ul}    ul_length=${ul_length}    ul_port=${ul_port}    protocol=${protocol}
    ...    process_num=${process_num}    seg_size=${seg_size}    iperf_type=${iperf_type}
    check throughput common keyword    lcrid=${lcrid}    duration_dl=${check_duration_dl}    duration_ul=${check_duration_ul}
    [Teardown]    Run Keywords
    ...    Stop UL DL data transfer    ue_type=${ue_type}    ue_index=${ue_index}    dl_port=${dl_port}    ul_port=${ul_port}
    ...    AND    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

check throughput common keyword
    [Arguments]    ${lcrid}    ${expect_throughput_dl}=${expect_throughput_dl}    ${expect_throughput_ul}=${expect_throughput_ul}
    ...            ${duration_dl}=${600}    ${duration_ul}=${600}    ${gnb_index}=0    ${direction_dl}=DL    ${direction_ul}=UL
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${ue_type}=${ue_type}    ${ue_index}=${0}
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${lcrid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Run Keyword And Continue On Failure
    ...    Check single direction throughput    expect_throughput=${expect_throughput_dl}    list_of_cell_ids=${nrcellid_cell}
    ...    duration=${duration_dl}    direction=${direction_dl}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword And Continue On Failure
    ...    Check Single Direction Throughput    expect_throughput=${expect_throughput_ul}    list_of_cell_ids=${nrcellid_cell}
    ...    duration=${duration_ul}    direction=${direction_ul}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    ue_type=${ue_type}    ue_index=${ue_index}
