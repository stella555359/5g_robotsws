*** Settings ***
Documentation
...  author: Han Ruiyu
...  contact: ruiyu.han@nokia-sbell.com

Resource   ./Resource/common.robot

*** Variables ***
${times}   20
${rulog_exist}    ${False}
${gnb_index}     ${0}
${vdu_index}     ${0}
${btslog_pc_addr}    ${tl.test_pcs[2].default_ssh_connection_details.addr}
${btslog_pc_username}    ${tl.test_pcs[2].default_ssh_connection_details.username}
${btslog_pc_password}    ${tl.test_pcs[2].default_ssh_connection_details.password}

*** Test Cases ***
Cloud_SiSo_Common_vDU_Combine
    [Setup]    Recovery at Case Setup

    FOR   ${i}   IN RANGE   ${times}
        Log To Console    this is ${i} VDU Reset !
        run keyword if  ${rulog_exist}    VDU RU Log Operation Setup in Siso Common
        Run Keyword And Continue On Failure    Cloud_SiSo_Common_vDU_Reset_Keywords
    END


    FOR   ${time}    IN RANGE   ${times}
        Log To Console    this is ${time} Rannic_Reset !
        run keyword if  ${rulog_exist}    VDU RU Log Operation Setup in Siso Common
        Run Keyword And Continue On Failure    Single_Cloud_SiSo_Common_vDU_Rannic_Reset
    END


    FOR   ${i}   IN RANGE   ${times}
        Log To Console    this is ${i} RU_Lock_Unlock!
        run keyword if  ${rulog_exist}    VDU RU Log Operation Setup in Siso Common
        Run Keyword And Continue On Failure    Single_Cloud_SiSo_Common_vDU_RU_Lock_Unlock
    END

    FOR    ${time}   IN RANGE   ${times}
         Log To Console    this is ${time} Cell_Block_Unblock!
         run keyword if  ${rulog_exist}    VDU RU Log Operation Setup in Siso Common
        Run Keyword And Continue On Failure    Single_Cloud_SiSo_Common_vDU_Cell_Block_Unblock
    END

    FOR    ${time}   IN RANGE    ${times}
        Log To Console    this is ${time} Cell_Reset!
        run keyword if  ${rulog_exist}    VDU RU Log Operation Setup in Siso Common
        Run Keyword And Continue On Failure    Single_Cloud_SiSo_Common_vDU_Cell_Reset
    END

    FOR   ${time}    IN RANGE   ${times}
        Log To Console    this is ${time} import SCF!
        run keyword if  ${rulog_exist}    VDU RU Log Operation Setup in Siso Common
        Run Keyword And Continue On Failure    Single_Cloud_SiSo_Common_vDU_Import_SCF
    END


     FOR   ${i}   IN RANGE   ${times}
        Log To Console    this is ${i} RU_Reset!
        run keyword if  ${rulog_exist}    VDU RU Log Operation Setup in Siso Common
        Run Keyword And Continue On Failure    Cloud_SiSo_Common_vDU_RU_Reset_Keywords
    END

    [Teardown]   Run Keyword And Ignore Error   VDU Siso Common Save Logs

