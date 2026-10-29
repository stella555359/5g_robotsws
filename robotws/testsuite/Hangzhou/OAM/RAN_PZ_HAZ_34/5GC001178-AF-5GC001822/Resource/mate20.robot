*** Settings ***
Documentation
...   author: Wang David
...   contact: david.wang@nokia-sbell.com
...   squad group: SG_08
...   feature : 5GC001178-AF
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource   ../../common/l3call.robot

*** Variables ***
#${tl.core.default_ssh_connection_details.addr}   10.57.163.34
#${tl.core.default_ssh_connection_details.username}   root
#${tl.core.default_ssh_connection_details.password}   nokia123
#${tl.appserver._iperf_details_on_appserver2.network_interface_address}   10.57.163.35
#${tl.appserver._iperf_details_on_appserver2.port}   58128
${ue_index}   0
${ue_type}   huawei

*** Keywords ***
Set up Call Mate20
    [Arguments]    ${dl_traffic}    ${ul_traffic}   ${mode}=${EMPTY}
    Check UE device exist
    power_ue.Prepare UE   ue_type=${ue_type}
    Attach and Retry if Failed
    Sleep   10s
    Run Keyword   Start Traffic ${mode}   dl_traffic=${dl_traffic}   ul_traffic=${ul_traffic}

Start Traffic
    [Arguments]    ${dl_traffic}    ${ul_traffic}
    Run Keyword and Continue on Failure   Start DL Traffic with Throughput ${dl_traffic}
    Sleep   1m
    Run Keyword   Start UL Traffic with Throughput ${ul_traffic}

