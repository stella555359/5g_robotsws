*** Settings ***
Documentation
...   Author: zhuo.1.gao@nokia-sbell.com
...   Contact: zhuo.1.gao@nokia-sbell.com
...   Description: This user scenario describes


Resource           ../Resources/vran_resource.robot
Suite Setup       Common Suite Setup For AIC
# Test Setup        Common Test Setup For AIC
Test Setup        Run Keywords    Common Test Setup For AIC    AND
...     AIC Case Setup    airphone_config_tag=SA_Cloud_DC
...    base_path=${CURDIR}/Airphone
Test Teardown     Common Test Teardown For AIC
Suite Teardown    Common Suite Teardown For AIC


Test Timeout    120 minutes

*** Test Cases ***
wireshark
    Start Collect Wireshark For Cloud
    sleep   60s
    Stop Collect Wireshark For Cloud



*** Keywords ***
Start Collect Wireshark For Cloud
    Log Collection    start    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Log Collection    start    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}

Stop Collect Wireshark For Cloud
    ${local_file_pathcu}    Log Collection    stop_and_download    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
    ${local_file_pathdu}    Log Collection    stop_and_download    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console        \nWireshark log of VCU: ${local_file_pathcu}
    Log To Console        \nWireshark log of VDU: ${local_file_pathdu}
