*** Settings ***
Documentation     Author: Chen Yin
...               Email: yin.1.chen@nokia-sbell.com
...               Squad group: SG_02
Force Tags        5G_SISO
...    PY36
Suite Setup       SBTS Suite Setup
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Resource          Resources/E2E_CMCC_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Common/SBTS_Setup_And_Teardown.robot

*** Variables ***
&{fault_61652}    faultId=${61652}
&{fault_61524}    faultId=${61524}
&{fault_4694}    faultId=${4694}
&{fault_4655}    faultId=${4655}
&{fault_4654}    faultId=${4654}
@{ALLOWED_FAULT_ID}    &{fault_61652}    &{fault_61524}    &{fault_4694}    &{fault_4655}    &{fault_4654}

*** Test Cases ***
E2E_eNB_SW_Upgrade_loops_with_WebUI
    [Tags]    UUF
    [Setup]    SBTS Test Setup
    ${package_path}    Get eNB package link and Download to VM
    ${current_version}      Check current eNB version
    FOR    ${n}    IN RANGE    1
        Selenium Logout and kill process
        Upgrade Site and Check eNB Status    package_path=${package_path}
        Rollback Site and Check eNB Status      current_version=${current_version}
    END
    [Teardown]    Run Keywords    Test Case Teardown for CMCC eNB    need_Btslog=${False}    AND    Clear SW Build

E2E_Reset_with_HWF_deletion
    [Tags]    UUF
    [Setup]    SBTS Test Setup
    selenium_coam.reset_site
    sleep    240s
    ${is_startup_window_exist}      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_ID}
    [Teardown]    Test Case Teardown for CMCC eNB    need_Btslog=${True}    btslog_name=btslog
    
****** Keywords ***
