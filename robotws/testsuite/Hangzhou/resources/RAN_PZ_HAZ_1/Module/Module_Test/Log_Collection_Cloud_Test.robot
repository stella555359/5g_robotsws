*** Settings ***
Documentation
...   Author: Liu Renhui, Du Ning
...   Contact: renhui-david.liu@nokia-sbell.com, ning.du@nokia-sbell.com
...   Description: This is the module test case

Resource          ../Module.robot
Resource          ../../../../RRM/RAN_PZ_HAZ_1/Resources/Cloud/AIC_Common_Resource.robot

Suite Setup       Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC
Test Setup        Common Test Setup For AIC
Test Teardown     Common Test Teardown For AIC


Force Tags        RAN_VRF_HAZ1

Test Timeout      60 minutes

*** Variables ***
&{dcap_info}    host=10.69.9.51    port=443    username=dcapuser    password=Nokia1234!

*** Test Cases ***
# Normal cases
T01_Wireshark_Vdu
    Log Collection    start    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}
    sleep    30s
    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nWireshark log of VDU: ${local_file_path}

T02_Wireshark_Vcu
    Log Collection    start    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
    sleep    30s
    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nWireshark log of VCU: ${local_file_path}

T03_Syslog_Vdu
    ${local_file_path}    Log Collection    start    syslog    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nSyslog of VDU: ${local_file_path}

T04_Syslog_Vcu
    ${local_file_path}    Log Collection    start    syslog    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nSyslog of VCU: ${local_file_path}

T05_Snapshot_Vdu
    ${local_file_path}    Log Collection    start    snapshot    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nSnapshot of VDU: ${local_file_path}

T06_Snapshot_Vcu
    ${local_file_path}    Log Collection    start    snapshot    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nSnapshot of VCU: ${local_file_path}

T07_Bip_Vdu
    Log Collection    start    bip    product_type=vdu    bts_index=${0}    cudu_index=${0}
    sleep    10s
    ${local_file_path}    Log Collection    stop_and_download    bip    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nBIP log of VDU: ${local_file_path}

T08_Tti_Vdu
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}
    sleep    1min    reason=Waiting For TTI capture
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nTTI log of VDU: ${local_file_path}

# Abnormal cases
T21_Wrong_Operation
    ${case_result}    ${out}    Run Keyword And Ignore Error    Log Collection    sdge    wireshark_cp
    ...                                                                           product_type=vcu    bts_index=${0}    cudu_index=${2}
    Log To Console    \nOut: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

T22_Wrong_Log_Type
    ${case_result}    ${out}    Run Keyword And Ignore Error    Log Collection    start    wiresheek_ck
    ...                                                                           product_type=vcu    bts_index=${0}    cudu_index=${2}
    Log To Console    \nOut: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

T23_Wireshark_Vdu_No_Start
    ${case_result}    ${local_file_path}    Run Keyword And Ignore Error    Log Collection    stop_and_download    wireshark_cp
    ...                                                                                       product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nWireshark log of VDU: ${local_file_path}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    PASS

T24_Wireshark_Vcu_Not_Existing_Vcu
    ${case_result}    ${out}    Run Keyword And Ignore Error    Log Collection    start    wireshark_cp
    ...                                                                           product_type=vcu    bts_index=${0}    cudu_index=${2}
    Log To Console    \nOut: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

T25_Syslog_Vdu_Stop
    ${case_result}    ${local_file_path}    Run Keyword And Ignore Error    Log Collection    stop    syslog
    ...                                                                                       product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nSyslog of VCU: ${local_file_path}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

T26_Snapshot_Vcu_Stop
    ${case_result}    ${local_file_path}    Run Keyword And Ignore Error    Log Collection    stop    snapshot
    ...                                                                                       product_type=vcu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nSnapshot of VCU: ${local_file_path}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

T030_ip_traffic_Vdu_vcu
    ${pod_names}    Create List    po-cran1-cprt-0
#    ${dict_argument}   Create Dictionary    capture_type=pod    measurement_point=NE_Terminated    plane_type=C-Plane    pod_names=${pod_names}
    ${dict_argument}   Create Dictionary    pod_names=${pod_names}
    Log Collection    start    ip_traffic    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}

    sleep    20s    reason=Waiting For TTI capture
    ${local_file_path}    Log Collection    stop_and_download
    ...    ip_traffic    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}
    Log To Console    \nTTI log of VDU: ${local_file_path}


    ${pod_names1}    Create List    po-cran18-upue-0    po-cran18-cpif-0
    ${dict_argument1}   Create Dictionary    capture_type=pod    measurement_point=NE_Terminated    pod_names=${pod_names1}
#    ${dict_argument}   Create Dictionary    pod_names=${pod_names}
    Log Collection    start    ip_traffic    product_type=vcu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument1}

    sleep    20s    reason=Waiting For TTI capture
    ${local_file_path}    Log Collection    stop_and_download
    ...    ip_traffic    product_type=vcu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument1}
    Log To Console    \nTTI log of VCU: ${local_file_path}

T031_k8s_Vdu
    ${dict_argument}   Create Dictionary    pod_name=l2rt    container_name=l2rt    duration=1h
    ${local_file_path}    Log Collection    start    k8s    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}
    Log To Console    \nk8slog of VDU: ${local_file_path}

T032_k8s_vcu
    ${dict_argument}   Create Dictionary    pod_name=cpif    container_name=cpif    duration=1h
    ${local_file_path}    Log Collection    start    k8s    product_type=vcu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}
    Log To Console    \nk8slog of VCU: ${local_file_path}

T033_k8s_vcu_All
    ${dict_argument}   Create Dictionary    pod_name=cpif    container_name=All    duration=1h
    ${local_file_path}    Log Collection    start    k8s    product_type=vcu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}
    Log To Console    \nk8slog of VCU: ${local_file_path}

T034_k8s_vdu_All
    ${dict_argument}   Create Dictionary    container_name=All    duration=2h
    ${local_file_path}    Log Collection    start    k8s    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}
    Log To Console    \nk8slog of VDU: ${local_file_path}


