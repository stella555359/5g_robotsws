*** Settings ***
Documentation
...  author: Jiang Shengyuan
...  contact: shengyuan.jiang@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keywords ***
CB010575-SR-E_003_SA_ClassicalgNB_StreamingPCMD_gNBDU_records
    [Arguments]  ${tcpdump}=${TCPDUMP_PATH}   ${txt_msg}=${ALL_PCMD_MSG}
    Check DU records   tcpdump=${tcpdump}   txt_msg=${txt_msg}

Case Setup: SR-E_003
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Log To Console   Case Setup: SR-E_003

Case Teardown: SR-E_003
    robot_common_operations.Common Case Teardown
    Log To Console   Case Teardown: SR-E_003
