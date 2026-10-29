*** Settings ***
Documentation    Author: lily.l.xu@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.

Library    ../python/tak_qualcomm/

*** Keywords ***
Qualcomm Wait Throughput Timer
    [Arguments]    ${time}
    [Documentation]    This keyword is used to sleep several seconds after start data traffic.
    ...    | Input Parameters | Man. | Description |
    ...    | time | Yes | time, unit is second |
    ...    Example:
    ...    | Wait Throughput Timer | 15 |
    Sleep    ${time}

Qualcomm Attach UE
    [Arguments]    ${ue_id}
    ${status}    Qualcomm Attach With Adb    ${ue_id}
    Run Keyword If    ${status} == False    Run Keywords    Qualcomm Detach UE    ${ue_id}    AND
    ...    Qualcomm Attach With Adb    ${ue_id}
    Wait '5s' for stable

Qualcomm Detach UE
    [Arguments]    ${ue_id}
    Qualcomm Detach With Adb    ${ue_id}
    Wait '2s' for stable

Qualcomm UE Reboot
    [Arguments]    ${ue_id}
    Qualcomm Execute Adb Cmd    ${ue_id}    reboot
    Wait '2s' for stable

Qualcomm Start DL Data
    [Arguments]    ${device_id}    ${port}    ${server_log_path}    ${extra_cmd}
    ${ue_ip}=    Qualcomm Get Ip With Adb    ${device_id}
    Qualcomm Start Iperf Server On Ue    ${device_id}    ${port}    log_path=${server_log_path}
    Qualcomm Start Iperf Client On Pc    ${port}    ${ue_ip}    extra_cmd=${extra_cmd}

Qualcomm Stop DL Data
    [Arguments]    ${device_id}    ${port}
    Qualcomm Stop Iperf Server On Ue    ${device_id}    ${port}
    Qualcomm Stop Iperf Client On Pc    ${port}

Qualcomm Start UL Data
    [Arguments]    ${device_id}    ${port}    ${server_log_path}    ${extra_cmd}    ${iperf_path}= /data/data/com.magicandroidapps.iperf/bin/iperf
    Qualcomm Start Iperf Server On Pc    ${port}    log_path=${server_log_path}
    Qualcomm Start Iperf Client On Ue    ${device_id}    ${port}    extra_cmd=${extra_cmd}    iperf_path=${iperf_path}

Qualcomm Stop UL Data
    [Arguments]    ${device_id}    ${port}
    Qualcomm Stop Iperf Server On Pc    ${port}
    Qualcomm Stop Iperf Client On Ue    ${device_id}    ${port}

Wait '${time}' for stable
    sleep    ${time}