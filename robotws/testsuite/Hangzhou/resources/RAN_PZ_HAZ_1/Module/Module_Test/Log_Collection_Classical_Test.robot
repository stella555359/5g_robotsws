*** Settings ***
Documentation
...   Author: Liu Renhui, Du Ning
...   Contact: renhui-david.liu@nokia-sbell.com, ning.du@nokia-sbell.com
...   Description: This is the module test case

Resource          ../Module.robot
#Resource          ../../../../RRM/RAN_PZ_HAZ_1/Resources/Cloud/AIC_Common_Resource.robot

#Suite Setup       Common Suite Setup For AIC
#Suite Teardown    Common Suite Teardown For AIC
#Test Setup        Common Test Setup For AIC
#Test Teardown     Common Test Teardown For AIC


Force Tags        RAN_VRF_HAZ1

Test Timeout      60 minutes

*** Variables ***
&{dcap_info}    host=10.69.9.51    port=443    username=dcapuser    password=Nokia1234!
${DEFAULT_ADDR}    192.168.255.129

*** Test Cases ***
# GNB
#T01_Gnb_Snapshot
#    ${local_file_path}    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
#    Log To Console    \nSnapshot log: ${local_file_path}
#
#T02_Gnb_Syslog
#    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
#    sleep    20s
#    ${local_file_path}    Log Collection    stop_and_download    syslog    product_type=gnb    bts_index=${0}
#    Log To Console    \nSyslog log: ${local_file_path}
#
#T03_Gnb_TTI_5G
#    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
#    Log Collection    start    tti_5G    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
#    sleep    60s
#    ${local_file_path}    Log Collection    stop_and_download    tti_5G    product_type=gnb    bts_index=${0}
#    Log To Console    \nTTI log: ${local_file_path}

#T04_Gnb_TTI_4G
#    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
#    Log Collection    start    tti_4G    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
#    sleep    60s
#    ${local_file_path}    Log Collection    stop_and_download    tti_4G    product_type=gnb    bts_index=${0}
#    Log To Console    \nTTI log: ${local_file_path}

#T05_Gnb_TTI_4G_5G
#    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
#    Log Collection    start    tti_4G_5G    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
#    sleep    60s
#    ${local_file_path}    Log Collection    stop_and_download    tti_4G_5G    product_type=gnb    bts_index=${0}
#    Log To Console    \nTTI log: ${local_file_path}

#T06_Gnb_Bip
## only for gnb
#    ${BBMOD_Index}    set variable    ${2}
#    ${bip_argument}   Create Dictionary   bip_options=-c ${BBMOD_Index}
#    ${dict_argument}   Create Dictionary   argument=${bip_argument}
#    Log Collection    start    bip    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
#    sleep    10s
#    ${local_file_path}    Log Collection    stop_and_download    bip    product_type=gnb    bts_index=${0}
#    Log To Console    \nBip log: ${local_file_path}
#
#T07_Gnb_Wireshark
#    ${wireshark_argument}   Create Dictionary   wireshark_options=-i any
#    ${dict_argument}   Create Dictionary   argument=${wireshark_argument}
#    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
#    sleep    10s
#    ${local_file_path}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${0}
#    Log To Console    \nwireshark log: ${local_file_path}
#
#T08_Gnb_Wireshark
#    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}
#    sleep    10s
#    ${local_file_path}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${0}
#    Log To Console    \nwireshark log: ${local_file_path}


# ENB
T09_Enb_Snapshot
    ${local_file_path}    Log Collection    start    snapshot    product_type=enb    bts_index=${0}
    Log To Console    \nSnapshot log: ${local_file_path}

T10_Enb_Syslog
    Log Collection    start    syslog    product_type=enb    bts_index=${1}
    sleep    30s
    ${local_file_path}    Log Collection    stop_and_download    syslog    product_type=enb    bts_index=${1}
    Log To Console    \nSyslog log: ${local_file_path}

T11_Gnb_Wireshark
    Log Collection    start    wireshark    product_type=enb    bts_index=${0}
    sleep    10s
    ${local_file_path}    Log Collection    stop_and_download    wireshark    product_type=enb    bts_index=${0}
    Log To Console    \nwireshark log: ${local_file_path}

T12_Gnb_ET_Emil
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    emil    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
    sleep    30s
    ${local_file_path}    Log Collection    stop_and_download    emil    product_type=gnb    bts_index=${0}
    Log To Console    \nTTI log: ${local_file_path}


