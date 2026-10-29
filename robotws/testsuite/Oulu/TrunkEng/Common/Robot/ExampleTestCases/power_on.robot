*** Settings ***

Documentation
...  Author:   Jere Jacklin
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot

Suite Teardown       Common Suite Teardown
Test Teardown        Common Test Teardown

*** Test Cases ***
Switch Power On To All Local Units
    Run Keyword and Continue On Failure  PowerBreakers.Switch Power On To All Local Units
    Run Keyword and Continue On Failure  Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
    ...                                  disconnection=False    time_to_wait=300
    Run Keyword and Continue On Failure  Wait Time And Reason    sleep_time=60  wait_reason=Waiting for admin
    ${ADMIN_FOLDER}=                     Create Admin Folder
    ADMIN.Connect to                     admin_api_log_dir=${ADMIN_FOLDER}  bts_host=192.168.255.129
