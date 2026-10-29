*** Settings ***
Documentation
...   Author: xiaowei.1.chen@nokia-sbell.com
...   Contact: xiaowei.1.chen@nokia-sbell.com
...   Description: This user scenario describes

Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Test Timeout    120 minutes

Resource          ../../../Resources/Cloud/AIC_Common_Resource.robot


Library     ute_wtssim
Library     String
Library     OperatingSystem
Library     Collections
Library     ta5g_ue_measurements
Library     taf.config.wts        WITH NAME    wts_conf

*** Variables ***
#${Setup_5QI5_Success}
#...    Setup QosFlow with QFI:1 5QI:5
${TL10760_wts}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/New_Feature_TA/CB013550/APCFG/wts_cloud_Trunk.cfg
*** Test Cases ***
wireshark
    Start Collect Wireshark For Cloud
    sleep   60s
    Stop Collect Wireshark For Cloud

Case_Precondition
    Case Precondition

AP_Upgrade
    AP upgrade

*** Keywords ***
AP upgrade
    Airphone Operation    operation=local_ap_upgrade    product_type=${None}
    ...               eth_config_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/New_Feature_TA/CB013550/ap_tl10760.json
    ...               ap_build=${None}
    OperatingSystem.Run    cp ${TL10760_wts} /opt/wts/latest/basic_setup.cfg
Start Collect Wireshark For Cloud
    Log Collection    start    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Log Collection    start    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}

Stop Collect Wireshark For Cloud
    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console        \nWireshark log of VCU: ${local_file_path}
    Log To Console        \nWireshark log of VDU: ${local_file_path}

Case Precondition
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=vdu
    ...                   traffic_info_dic=${None}
    ...                   tag=cloud_Trunk
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
#    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
#    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s