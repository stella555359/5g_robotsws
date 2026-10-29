*** Settings ***

Library    taf.sw.reporting_portal
Library    taf.rfrl.common_resources.python.report_to_rep
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/utilities.robot


*** Keywords ***
DL_Throughput_2-DRB_OTA
    [Arguments]    ${capabilities}    ${duration}    ${tput}    ${protocol}    ${deviation}    ${parallel_streams}=1    ${size_packet}=1400B
    ...    ${buffer_client}=${None}    ${buffer_server}=${None}    ${interval}=1    ${reboot_ue}=${False}    ${timeout_reboot_ue}=100
    ...    ${qci}=${None}    ${start_transfer_in_new_pm_period}=${False}    ${linux_congestion}=${None}
    ...    ${delete_source_pcap_files}=${False}

    Run Keyword If  ${start_transfer_in_new_pm_period}  REAL_UE.Wait for next PM period
    Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 Call One Way Data Transfer for Multi Radio Bearer    direction=DL    duration=${duration}    tput=${tput}
    ...    protocol=${protocol}    deviation=${deviation}    parallel_streams=${parallel_streams}    size_packet=${size_packet}
    ...    buffer_client=${buffer_client}    buffer_server=${buffer_server}    interval=${interval}  qci=${qci}
    ...    linux_congestion=${linux_congestion}

    [Teardown]  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...         tput_dl=${tput}  protocol=${protocol}  deviation=${deviation}  is_traffic_multi_radio_bearer=${True}
    ...         delete_source_pcap_files=${delete_source_pcap_files}
