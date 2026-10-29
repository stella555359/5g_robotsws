*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   ./Resource/common.robot


*** Variables ***
${times}    50


*** Test Cases ***
Cloud_SiSo_Common_CU_Import_SCF
    [Setup]
    FOR    ${time}   IN RANGE   ${times}
         Log To Console    this is ${time} CU_Import_SCF!
        Single_Cloud_SiSo_Common_CU_Import_SCF
    END
    [Teardown]   Run Keyword If Test Failed  COAM VCU Log Collection


*** Keywords ***
Single_Cloud_SiSo_Common_CU_Import_SCF
    # Log To Console   ${all_gnbs_detail}
    COAM CU Login
    COAM CU Backup Current SCF
    COAM CU Perform Commission

    Wait Until Keyword Succeeds   15m   1m   COAM CU Check All Cell Status

    [Teardown]   Run Keyword And Ignore Error   COAM CU Logout
