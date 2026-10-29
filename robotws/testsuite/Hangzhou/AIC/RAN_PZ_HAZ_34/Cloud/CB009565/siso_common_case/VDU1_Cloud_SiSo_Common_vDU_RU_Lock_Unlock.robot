*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   ./Resource/common.robot


*** Variables ***
${times}    300
${rulog_exist}    ${False}
${gnb_index}     ${0}
${vdu_index}     ${0}
${btslog_pc_addr}    ${tl.test_pcs[2].default_ssh_connection_details.addr}
${btslog_pc_username}    ${tl.test_pcs[2].default_ssh_connection_details.username}
${btslog_pc_password}    ${tl.test_pcs[2].default_ssh_connection_details.password}

*** Test Cases ***
Cloud_SiSo_Common_vDU_RU_Lock_Unlock
    [Setup]    Recovery at Case Setup
    FOR   ${i}   IN RANGE   ${times}
        Log To Console    this is ${i} RU_Lock_Unlock!
        run keyword if  ${rulog_exist}    VDU RU Log Operation Setup in Siso Common
        Single_Cloud_SiSo_Common_vDU_RU_Lock_Unlock
    END
    [Teardown]   Run Keyword And Ignore Error   VDU Siso Common Save Logs


