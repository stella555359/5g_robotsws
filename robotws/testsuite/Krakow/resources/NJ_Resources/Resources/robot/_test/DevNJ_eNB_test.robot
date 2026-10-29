*** Settings ***
Documentation
...    author: Haiyang Zhao
...    contact: haiyang.a.zhao@nokia-sbell.com
...    Purpose: test enb keywords
...    Command: robot -L TRACE --outputdir /home/ute/logs/test_enb_keywords
...             -V /home/ute/testline_configuration/7_21_CLOUD006TL006
...             testsuite/OAM/Nanjing/Resources/robot/_test/DevNJ_eNB_test.robot

Resource    ../DevNJ_eNB_rpc_keywords.robot

*** Variables ***
${target_version}       SBTS20A_ENB_0000_001770_000000
${lmp_ip}               192.168.255.129

*** Test Cases ***
Test Install eNB VM RPC Server
    Install eNB VM RPC Server

Test Setup Enb To Onair Status
    Setup Enb To Onair Status

Test Setup Enb To Onair Status With Build Version
    Setup Enb To Onair Status    ${target_version}    ${lmp_ip}

Test Setup Enb To Onair Status Only Commission
    Setup Enb To Onair Status    ${target_version}    ${lmp_ip}
