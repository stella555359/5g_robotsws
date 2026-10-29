*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   ./Resource/common.robot


*** Variables ***
${times}    50
${rulog_exist}    ${False}
${gnb_index}     ${0}
${vdu_index}     ${0}
${btslog_pc_addr}    ${tl.test_pcs[2].default_ssh_connection_details.addr}
${btslog_pc_username}    ${tl.test_pcs[2].default_ssh_connection_details.username}
${btslog_pc_password}    ${tl.test_pcs[2].default_ssh_connection_details.password}

*** Test Cases ***
Cloud_SiSo_Common_vDU_Snapshot
    [Setup]
    FOR    ${time}   IN RANGE   ${times}
        Log To Console    this is ${time} Single_Cloud_SiSo_Common_vDU_Snapshot!
        Single_Cloud_SiSo_Common_vDU_Snapshot
    END
    [Teardown]   Run Keyword If Test Failed  VDU Siso Common Save Logs


