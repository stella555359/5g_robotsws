*** Settings ***
Documentation    E2E Throughput OTA

Library    ute_reporting_portal
Library    taf.rfrl.common_resources.python.report_to_rep
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot


*** Keywords ***
Bi-Directional_Throughput_1-DRB_OTA
    [Arguments]    ${capabilities}    ${duration}    ${tput_dl}    ${tput_ul}    ${protocol}
    ...    ${parallel_streams_dl}=1    ${parallel_streams_ul}=1    ${size_packet}=1400B    ${size_packet_dl}=${size_packet}
    ...    ${size_packet_ul}=${size_packet}    ${buffer_client_dl}=${None}    ${buffer_server_dl}=${None}    ${buffer_client_ul}=${None}
    ...    ${buffer_server_ul}=${None}    ${interval}=1    ${reboot_ue}=${False}    ${timeout_reboot_ue}=100    ${qci_dl}=${None}
    ...    ${qci_ul}=${None}     ${deviation}=25%    ${deviation_dl}=${deviation}    ${deviation_ul}=${deviation}
    ...    ${start_transfer_in_new_pm_period}=${False}    ${linux_congestion_dl}=${None}    ${linux_congestion_ul}=${None}

    Run Keyword If  ${start_transfer_in_new_pm_period}  REAL_UE.Wait for next PM period
    Log    ${capabilities} ${reboot_ue} ${timeout_reboot_ue}
    #Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 Call Data Transfer DL&UL    duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    ...    protocol=${protocol}    deviation_dl=${deviation_dl}    deviation_ul=${deviation_ul}
    ...    parallel_streams_dl=${parallel_streams_dl}    parallel_streams_ul=${parallel_streams_ul}
    ...    size_packet_dl=${size_packet_dl}    size_packet_ul=${size_packet_ul}    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}    buffer_client_ul=${buffer_client_ul}    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}    qci_dl=${qci_dl}    qci_ul=${qci_ul}    linux_congestion_dl=${linux_congestion_dl}
    ...    linux_congestion_ul=${linux_congestion_ul}


    [Teardown]  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...         tput_dl=${tput_dl}  tput_ul=${tput_ul}  protocol=${protocol}  deviation=${deviation}

DL_Throughput_1-DRB_OTA
    [Arguments]    ${capabilities}    ${duration}    ${tput}    ${protocol}    ${deviation}    ${parallel_streams}=1    ${size_packet}=1400B
    ...    ${buffer_client}=${None}    ${buffer_server}=${None}    ${interval}=1    ${reboot_ue}=${False}    ${timeout_reboot_ue}=100
    ...    ${qci}=${None}    ${start_transfer_in_new_pm_period}=${False}    ${linux_congestion}=${None}

    Log    ${capabilities} ${reboot_ue} ${timeout_reboot_ue}
    Run Keyword If  ${start_transfer_in_new_pm_period}  REAL_UE.Wait for next PM period
    #Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 Call One Way Data Transfer    direction=DL    duration=${duration}    tput=${tput}
    ...    protocol=${protocol}    deviation=${deviation}    parallel_streams=${parallel_streams}    size_packet=${size_packet}
    ...    buffer_client=${buffer_client}    buffer_server=${buffer_server}    interval=${interval}  qci=${qci}
    ...    linux_congestion=${linux_congestion}

    [Teardown]  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...         tput_dl=${tput}  protocol=${protocol}  deviation=${deviation}

UL_Throughput_1-DRB_OTA
    [Arguments]    ${capabilities}    ${duration}    ${tput}    ${protocol}    ${deviation}    ${parallel_streams}=1    ${size_packet}=1400B
    ...    ${buffer_client}=${None}    ${buffer_server}=${None}    ${interval}=1    ${reboot_ue}=${False}    ${timeout_reboot_ue}=100
    ...    ${qci}=${None}    ${start_transfer_in_new_pm_period}=${False}    ${linux_congestion}=${None}

    Log    ${capabilities} ${reboot_ue} ${timeout_reboot_ue}
    Run Keyword If  ${start_transfer_in_new_pm_period}  REAL_UE.Wait for next PM period
    #Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 Call One Way Data Transfer    direction=UL    duration=${duration}    tput=${tput}
    ...    protocol=${protocol}    deviation=${deviation}    parallel_streams=${parallel_streams}    size_packet=${size_packet}
    ...    buffer_client=${buffer_client}    buffer_server=${buffer_server}    interval=${interval}  qci=${qci}
    ...    linux_congestion=${linux_congestion}

    [Teardown]  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...         tput_ul=${tput}  protocol=${protocol}  deviation=${deviation}

Pre Conditions
    Verify gNB is onAir
    Verify Allowed Alarms on gNB    allowed_alarms=@{allowed_alarms}

Post Conditions
    Verify gNB is onAir
    Verify Allowed Alarms on gNB    allowed_alarms=@{allowed_alarms}
